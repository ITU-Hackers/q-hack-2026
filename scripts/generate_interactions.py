#!/usr/bin/env python3
"""
generate_interactions.py

For each customer, determine their best-matching cuisine by scoring all recipes
via ingredient overlap with their purchase history, then emit the top 10-12
recipes from that cuisine as interaction pairs.

Output CSV columns:
  user_id  — 0-based rank when synthetic_users are sorted by DB id (0..N-1)
  meal_id  — 0-based row index in recipes.csv (0..M-1)

Usage:
    python scripts/generate_interactions.py \
        --db-url "postgresql://picky:Password123@localhost:5432/primary" \
        --recipes services/picky-recs/data/recipes.csv \
        --output data/user_meal_interactions.csv \
        --top-k 10
"""

from __future__ import annotations

import argparse
import csv
import sys
from collections import defaultdict
from pathlib import Path

try:
    import psycopg2
except ImportError:
    sys.exit(
        "psycopg2-binary not found.\n"
        "Run: uv add psycopg2-binary --directory services/picky-recs"
    )

# ── Units mirrored from recipes.py / food2vec.rs ──────────────────────────────

_UNITS: frozenset[str] = frozenset({
    "tsp", "tsps", "teaspoon", "teaspoons",
    "tbsp", "tbsps", "tablespoon", "tablespoons",
    "cup", "cups",
    "oz", "ounce", "ounces",
    "lb", "lbs", "pound", "pounds",
    "g", "gram", "grams",
    "kg", "kilogram", "kilograms",
    "ml", "milliliter", "milliliters",
    "l", "liter", "liters",
    "pint", "pints", "quart", "quarts", "gallon", "gallons",
    "can", "cans", "package", "packages", "pkg",
    "bunch", "bunches", "clove", "cloves",
    "slice", "slices", "piece", "pieces",
    "handful", "pinch", "dash",
    "pack", "packs", "bag", "bags",
})

# ── Dietary restriction → blocked ingredient tokens ───────────────────────────

_MEAT_TOKENS: frozenset[str] = frozenset({
    "chicken", "beef", "pork", "lamb", "turkey", "bacon", "anchovy",
    "shrimp", "prawn", "mussel", "tuna", "salmon", "fish_sauce", "pork_broth",
    "sausage", "mince",
})

_DAIRY_EGG_TOKENS: frozenset[str] = frozenset({
    "egg", "milk", "cream", "butter", "cheese", "ghee", "yogurt",
    "mozzarella", "parmesan", "feta", "bechamel", "whey",
})

_GLUTEN_TOKENS: frozenset[str] = frozenset({
    "noodles", "pasta", "bread", "flour", "soy_sauce", "couscous",
    "ramen", "udon", "wheat",
})

# ── Archetype → cuisine mapping ───────────────────────────────────────────────
# Derived from purchase behavior: what each archetype actually buys
# maps naturally to these cuisines.

ARCHETYPE_CUISINES: dict[str, list[str]] = {
    "budget_student":     ["Italian"],
    "big_family":         ["German"],
    "gym_goer":           ["Asian"],
    "vegetarian_couple":  ["Mediterranean"],
}
# Fallback if archetype unknown: all cuisines
_ALL_CUISINES = ["Asian", "French", "German", "Indian", "Italian", "Mediterranean", "Mexican", "Thai"]

RESTRICTION_BLOCKS: dict[str, frozenset[str]] = {
    "vegetarian": _MEAT_TOKENS,
    "vegan": _MEAT_TOKENS | _DAIRY_EGG_TOKENS,
    "gluten_free": _GLUTEN_TOKENS,
}

INGREDIENT_COLS = [f"ingredient_{i}" for i in range(1, 9)]


# ── Normalization ─────────────────────────────────────────────────────────────

def _normalize(text: str) -> str:
    """Strip quantities/units, lowercase, join remaining tokens with '_'."""
    tokens = []
    for tok in text.split():
        try:
            float(tok)
            continue
        except ValueError:
            pass
        if "/" in tok:
            parts = tok.split("/", 1)
            try:
                int(parts[0])
                int(parts[1])
                continue
            except ValueError:
                pass
        if tok.lower() in _UNITS:
            continue
        tokens.append(tok.lower())
    return "_".join(tokens)


def _expand_tokens(normalized: str) -> set[str]:
    """'chicken_breast' → {'chicken', 'breast', 'chicken_breast'}"""
    parts = normalized.split("_")
    return set(parts) | {normalized}


# ── CLI ───────────────────────────────────────────────────────────────────────

def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Generate user–meal interaction pairs by cuisine.")
    p.add_argument(
        "--db-url",
        default="postgresql://picky:Password123@localhost:5432/primary",
    )
    p.add_argument(
        "--recipes",
        default="services/picky-recs/data/recipes.csv",
    )
    p.add_argument(
        "--output",
        default="data/user_meal_interactions.csv",
    )
    p.add_argument(
        "--top-k",
        type=int,
        default=10,
        help="Recipes to recommend per customer (default 10)",
    )
    p.add_argument(
        "--dry-run",
        action="store_true",
    )
    return p.parse_args()


# ── DB helpers ────────────────────────────────────────────────────────────────

def connect_db(db_url: str):
    try:
        conn = psycopg2.connect(db_url)
        conn.autocommit = True
        return conn
    except psycopg2.OperationalError as exc:
        sys.exit(f"[ERROR] Could not connect to database:\n  {exc}")


def load_users(conn) -> list[tuple[int, str, list[str]]]:
    """[(db_id, archetype, dietary_restrictions), ...] sorted by db_id."""
    with conn.cursor() as cur:
        cur.execute(
            "SELECT id, archetype, dietary_restrictions FROM synthetic_users ORDER BY id"
        )
        return [(row[0], row[1] or "", list(row[2] or [])) for row in cur.fetchall()]


def load_user_products(conn) -> dict[int, set[str]]:
    """{db_user_id: set of normalized product names from order history}."""
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT o.user_id, oi.product_name
            FROM order_items oi
            JOIN orders o ON o.id = oi.order_id
            GROUP BY o.user_id, oi.product_name
            """
        )
        rows = cur.fetchall()

    products: dict[int, set[str]] = {}
    for user_id, product_name in rows:
        products.setdefault(user_id, set()).add(_normalize(product_name or ""))
    return products


# ── Recipe loading ────────────────────────────────────────────────────────────

def load_recipes(path: str) -> list[dict]:
    """Return list of dicts with keys: meal_id, region, dish, ingredients (set)."""
    recipes = []
    with open(path, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for meal_id, row in enumerate(reader):
            ingredients: set[str] = set()
            for col in INGREDIENT_COLS:
                val = (row.get(col) or "").strip()
                if val:
                    ingredients.add(val)
            recipes.append({
                "meal_id": meal_id,
                "region": row.get("region", "").strip(),
                "dish": row.get("dish", "").strip(),
                "ingredients": ingredients,
            })
    return recipes


# ── Scoring ───────────────────────────────────────────────────────────────────

def build_user_tokens(normalized_products: set[str]) -> set[str]:
    tokens: set[str] = set()
    for p in normalized_products:
        tokens.update(_expand_tokens(p))
    return tokens


def build_forbidden(restrictions: list[str]) -> set[str]:
    blocked: set[str] = set()
    for r in restrictions:
        blocked.update(RESTRICTION_BLOCKS.get(r, frozenset()))
    return blocked


def is_forbidden(ingredients: set[str], forbidden: set[str]) -> bool:
    for ing in ingredients:
        if (_expand_tokens(ing)) & forbidden:
            return True
    return False


def build_idf_weights(recipes: list[dict]) -> dict[str, float]:
    """IDF weight per ingredient token.

    Ingredients that appear in many cuisines (garlic, onion) score near 0;
    cuisine-specific ingredients (garam_masala, miso) score high.
    IDF = log(N / df) where N = number of cuisines, df = cuisines containing token.
    """
    import math
    cuisines_per_token: dict[str, set[str]] = defaultdict(set)
    all_cuisines = {r["region"] for r in recipes}
    n = len(all_cuisines)
    for recipe in recipes:
        for ing in recipe["ingredients"]:
            for tok in _expand_tokens(ing):
                cuisines_per_token[tok].add(recipe["region"])
    return {
        tok: math.log(n / len(tok_cuisines))
        for tok, tok_cuisines in cuisines_per_token.items()
        if len(tok_cuisines) < n  # tokens in every cuisine → weight 0, skip
    }


def overlap(
    ingredients: set[str],
    user_tokens: set[str],
    idf: dict[str, float],
) -> float:
    """IDF-weighted overlap: cuisine-specific ingredients score higher."""
    if not ingredients:
        return 0.0
    total_weight = sum(
        max(idf.get(tok, 0.0) for tok in _expand_tokens(ing))
        for ing in ingredients
    )
    if total_weight == 0.0:
        return 0.0
    matched_weight = sum(
        max(idf.get(tok, 0.0) for tok in _expand_tokens(ing))
        for ing in ingredients
        if _expand_tokens(ing) & user_tokens
    )
    return matched_weight / total_weight


# ── Main ──────────────────────────────────────────────────────────────────────

def main() -> None:
    args = parse_args()

    recipes_path = Path(args.recipes)
    if not recipes_path.exists():
        sys.exit(f"[ERROR] Recipes file not found: {recipes_path}")

    print(f"[INFO] Loading recipes from {recipes_path}")
    recipes = load_recipes(str(recipes_path))

    # Group recipe indices by cuisine
    by_cuisine: dict[str, list[dict]] = defaultdict(list)
    for r in recipes:
        by_cuisine[r["region"]].append(r)

    cuisines = sorted(by_cuisine.keys())
    print(f"[INFO] {len(recipes)} recipes across cuisines: {', '.join(cuisines)}")

    idf = build_idf_weights(recipes)

    print(f"[INFO] Connecting to {args.db_url}")
    conn = connect_db(args.db_url)
    users = load_users(conn)
    user_products = load_user_products(conn)
    conn.close()
    print(f"[INFO] Loaded {len(users)} users")

    pairs: list[tuple[int, int]] = []
    cuisine_counts: dict[str, int] = defaultdict(int)

    for user_idx, (db_id, archetype, restrictions) in enumerate(users):
        products = user_products.get(db_id, set())
        tokens = build_user_tokens(products)
        forbidden = build_forbidden(restrictions)

        # Candidate cuisines come from the user's archetype (derived from purchase behavior)
        candidate_cuisines = set(ARCHETYPE_CUISINES.get(archetype, _ALL_CUISINES))

        # Score allowed recipes that belong to a candidate cuisine
        scored: list[tuple[float, dict]] = []
        for recipe in recipes:
            if recipe["region"] not in candidate_cuisines:
                continue
            if is_forbidden(recipe["ingredients"], forbidden):
                continue
            score = overlap(recipe["ingredients"], tokens, idf)
            scored.append((score, recipe))

        if not scored:
            # Fallback: open up to all cuisines, ignore dietary filter
            scored = [
                (overlap(r["ingredients"], tokens, idf), r)
                for r in recipes
                if r["region"] in candidate_cuisines
            ] or [(overlap(r["ingredients"], tokens, idf), r) for r in recipes]

        # Best cuisine = highest mean overlap among candidate cuisines
        cuisine_scores: dict[str, list[float]] = defaultdict(list)
        for score, recipe in scored:
            cuisine_scores[recipe["region"]].append(score)

        best_cuisine = max(
            cuisine_scores,
            key=lambda c: sum(cuisine_scores[c]) / len(cuisine_scores[c]),
        )

        # Pick top-k from that cuisine, ranked by overlap
        cuisine_recipes = [
            (score, recipe)
            for score, recipe in scored
            if recipe["region"] == best_cuisine
        ]
        cuisine_recipes.sort(key=lambda x: x[0], reverse=True)
        top = cuisine_recipes[: args.top_k]

        for _, recipe in top:
            pairs.append((user_idx, recipe["meal_id"]))
        cuisine_counts[best_cuisine] += 1

    print(f"[INFO] Total pairs: {len(pairs)}")
    print(f"[INFO] Avg pairs/user: {len(pairs)/len(users):.1f}")
    print(f"[INFO] Best-cuisine distribution:")
    for c, n in sorted(cuisine_counts.items(), key=lambda x: -x[1]):
        print(f"         {c}: {n} users")

    # Verify coverage
    unique_meals = len({meal_id for _, meal_id in pairs})
    unique_users = len({uid for uid, _ in pairs})
    print(f"[INFO] Unique users: {unique_users}, unique meals: {unique_meals}")

    if args.dry_run:
        print("[dry-run] No output written.")
        return

    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["user_id", "meal_id"])
        writer.writerows(pairs)

    print(f"[DONE] Written {len(pairs)} rows to {output_path}")


if __name__ == "__main__":
    main()
