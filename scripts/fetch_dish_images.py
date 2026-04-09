#!/usr/bin/env python3
"""
Download missing dish images via DuckDuckGo and update DISH_PHOTOS.

Fetches the first N images per dish so you can pick the best one manually.
Already-downloaded dishes are skipped on re-run.

Usage:
    python3 scripts/fetch_dish_images.py            # download missing images
    python3 scripts/fetch_dish_images.py --dry-run  # preview only
    python3 scripts/fetch_dish_images.py --update-ts-only  # just rebuild DISH_PHOTOS
"""

import re
import sys
import time
import unicodedata
from pathlib import Path
from urllib.error import HTTPError
from urllib.request import Request, urlopen

from ddgs import DDGS

REPO_ROOT = Path(__file__).parent.parent
DISHES_DIR = REPO_ROOT / "services/picky-app/public/dishes"
BROWSE_PAGE = REPO_ROOT / "services/picky-app/app/(app)/browse/page.tsx"
SQL_FILE = REPO_ROOT / "migrations/20260409120000_create_recipes_and_ingredients.sql"

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
                  "(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
}

# How many candidate images to fetch per dish (download all, delete bad ones manually)
CANDIDATES = 3


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def to_slug(dish: str) -> str:
    normalized = unicodedata.normalize("NFKD", dish)
    ascii_str = normalized.encode("ascii", "ignore").decode("ascii")
    return re.sub(r"[^a-z0-9-]+", "-", ascii_str.lower().replace("_", "-")).strip("-")


def parse_dishes() -> list[tuple[str, str]]:
    sql = SQL_FILE.read_text(encoding="utf-8")
    results = []
    for line in sql.splitlines():
        m = re.match(r"\s*\('([^']+)',\s*'((?:[^']|'')+)',\s*'[^']*'\)", line)
        if m:
            results.append((m.group(1), m.group(2).replace("''", "'")))
    return results


# ---------------------------------------------------------------------------
# DuckDuckGo image search
# ---------------------------------------------------------------------------

def ddg_image_urls(query: str, count: int = 3) -> list[str]:
    """Return up to `count` image URLs from DuckDuckGo for the query."""
    try:
        with DDGS() as ddgs:
            results = list(ddgs.images(query, max_results=count))
        return [r["image"] for r in results if r.get("image")]
    except Exception as e:
        print(f"    [ddg error] {e}")
        return []


# ---------------------------------------------------------------------------
# Download with retry
# ---------------------------------------------------------------------------

def download_image(url: str, dest: Path) -> bool:
    for attempt in range(3):
        try:
            req = Request(url, headers=HEADERS)
            with urlopen(req, timeout=15) as resp:
                data = resp.read()
            if len(data) < 2048:
                return False
            dest.write_bytes(data)
            return True
        except HTTPError as e:
            if e.code == 429 and attempt < 2:
                time.sleep(5 * (2 ** attempt))
            else:
                return False
        except Exception:
            return False
    return False


# ---------------------------------------------------------------------------
# DISH_PHOTOS updater — rebuilds the entire block from what's on disk
# ---------------------------------------------------------------------------

def update_dish_photos(all_dishes: list[tuple[str, str]]) -> None:
    # Only use the first candidate (no _2, _3 suffix) as the canonical image
    on_disk = {f.stem for f in DISHES_DIR.iterdir() if f.suffix in {".jpg", ".jpeg", ".png", ".webp"}}

    lines = ["const DISH_PHOTOS: Record<string, string> = {"]
    current_region = None
    count = 0
    for region, dish in all_dishes:
        slug = to_slug(dish)
        if slug not in on_disk:
            continue
        if region != current_region:
            lines.append(f"  // {region}")
            current_region = region
        key = f'"{dish}"' if re.search(r"[^A-Za-z0-9_]", dish) else dish
        lines.append(f"  {key}: \"/dishes/{slug}.jpg\",")
        count += 1
    lines.append("};")
    new_block = "\n".join(lines)

    source = BROWSE_PAGE.read_text(encoding="utf-8")
    updated = re.sub(
        r"const DISH_PHOTOS: Record<string, string> = \{.*?\};",
        new_block,
        source,
        flags=re.DOTALL,
    )
    if updated == source:
        print("  [warn] DISH_PHOTOS block not found")
        return
    BROWSE_PAGE.write_text(updated, encoding="utf-8")
    print(f"  Updated DISH_PHOTOS with {count} entries.")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    dry_run = "--dry-run" in sys.argv
    update_ts_only = "--update-ts-only" in sys.argv

    DISHES_DIR.mkdir(parents=True, exist_ok=True)
    all_dishes = parse_dishes()

    if update_ts_only:
        print("Rebuilding DISH_PHOTOS from disk...")
        update_dish_photos(all_dishes)
        return

    on_disk = {f.stem for f in DISHES_DIR.iterdir()}
    missing = [(r, d) for r, d in all_dishes if to_slug(d) not in on_disk]

    print(f"Total dishes : {len(all_dishes)}")
    print(f"On disk      : {len(on_disk)}")
    print(f"To download  : {len(missing)}")
    if CANDIDATES > 1:
        print(f"Candidates   : {CANDIDATES} per dish (delete the bad ones)")
    if dry_run:
        print("(dry-run)\n")

    downloaded = 0
    failed = []

    for region, dish in missing:
        slug = to_slug(dish)
        query = f"{dish.replace('_', ' ')} food"
        print(f"  [{region}] {dish}")

        if dry_run:
            downloaded += 1
            continue

        urls = ddg_image_urls(query, count=CANDIDATES)
        if not urls:
            print(f"    no results")
            failed.append((region, dish))
            time.sleep(1)
            continue

        saved = 0
        for i, url in enumerate(urls):
            suffix = f"_{i+1}" if i > 0 else ""
            dest = DISHES_DIR / f"{slug}{suffix}.jpg"
            if download_image(url, dest):
                print(f"    saved {dest.name}")
                saved += 1
            else:
                print(f"    failed: {url[:70]}")

        if saved == 0:
            failed.append((region, dish))
        else:
            downloaded += 1

        time.sleep(1.5)

    print(f"\nDownloaded: {downloaded}  |  Failed: {len(failed)}")
    if failed:
        print("Failed:")
        for r, d in failed:
            print(f"  [{r}] {d}")

    if not dry_run:
        print("\nRebuilding DISH_PHOTOS...")
        update_dish_photos(all_dishes)


if __name__ == "__main__":
    main()
