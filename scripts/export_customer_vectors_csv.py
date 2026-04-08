#!/usr/bin/env python3
"""export_customer_vectors_csv.py

Export customer vectors from PostgreSQL to a CSV file.

By default this writes a "wide" CSV with columns:
  user_id, dim, version, computed_at, v0, v1, ...

Usage:
  python scripts/export_customer_vectors_csv.py \
    --db-url "postgresql://picky:Password123@localhost:5432/primary" \
    --out customer_vectors.csv

If you don't have `uv` on PATH, this works (installs deps temporarily):
  python -m uv run --with psycopg2-binary python scripts/export_customer_vectors_csv.py \
    --db-url "postgresql://picky:Password123@localhost:5432/primary" \
    --out customer_vectors.csv
"""

from __future__ import annotations

import argparse
import csv
import sys
from typing import Any

try:
    import psycopg2
except ImportError:
    sys.exit(
        "psycopg2-binary not found.\n"
        "Run with: python -m uv run --with psycopg2-binary python scripts/export_customer_vectors_csv.py ..."
    )


# This header schema matches the exact feature ordering in
# scripts/generate_customer_vectors.py (DIM=128).
ARCHETYPES = ["budget_student", "big_family", "gym_goer", "vegetarian_couple"]
HOUSEHOLD_TYPES = ["student_single", "family_young", "couple"]
BUDGET_TIERS = ["tight", "moderate"]
COOKING_TIME = ["short", "medium", "long"]
DIETARY = ["vegetarian", "high_protein"]

CATEGORY_FRACTIONS = [
    "protein_fraction",
    "dairy_fraction",
    "carbs_fraction",
    "vegetables_fraction",
    "snacks_fraction",
]

SCALAR_FEATURES = [
    "avg_weekly_spend_norm",
    "avg_spend_trend",
    "avg_budget_util_rate",
    "avg_reorder_interval_days_norm",
    "avg_order_interval_consistency",
    "avg_days_since_last_order_norm",
    "avg_loyalty_staples_fraction",
    "avg_loyalty_one_time_fraction",
    "avg_top_category_concentration",
    "monthly_budget_cents_norm",
    "orders_per_week_norm",
    "avg_items_per_order_norm",
    "avg_order_spend_cents_norm",
    "total_spend_cents_norm",
    "unique_products_norm",
    "weeks_active_fraction",
]


def build_feature_names(dim: int) -> list[str]:
    names: list[str] = []

    names.extend([f"{c}_avg" for c in CATEGORY_FRACTIONS])
    names.extend(SCALAR_FEATURES)

    names.extend([f"archetype_{a}" for a in ARCHETYPES])
    names.extend([f"household_type_{h}" for h in HOUSEHOLD_TYPES])
    names.extend([f"budget_tier_{b}" for b in BUDGET_TIERS])
    names.extend([f"cooking_time_tolerance_{t}" for t in COOKING_TIME])
    names.extend([f"dietary_{d}" for d in DIETARY])

    # Remaining dimensions are hashed product spend buckets.
    remaining = dim - len(names)
    if remaining > 0:
        names.extend([f"product_spend_bucket_{i}" for i in range(remaining)])

    # If dim is smaller than our non-hashed base, truncate.
    return names[:dim]


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Export user_profile_vectors to CSV.")
    p.add_argument(
        "--db-url",
        default="postgresql://picky:Password123@localhost:5432/primary",
        help="PostgreSQL connection URL",
    )
    p.add_argument(
        "--out",
        default="customer_vectors.csv",
        help="Output CSV path (default: customer_vectors.csv)",
    )
    return p.parse_args()


def connect_db(db_url: str):
    try:
        conn = psycopg2.connect(db_url)
        conn.autocommit = True
        return conn
    except psycopg2.OperationalError as exc:
        sys.exit(f"[ERROR] Could not connect to database:\n  {exc}")


def main() -> None:
    args = parse_args()

    print(f"[INFO] Connecting to {args.db_url}")
    conn = connect_db(args.db_url)

    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT user_id, dim, version, computed_at, vector
            FROM user_profile_vectors
            ORDER BY user_id
            """
        )
        rows: list[tuple[Any, ...]] = cur.fetchall()

    if not rows:
        print("[WARN] No rows found in user_profile_vectors")
        return

    max_dim = max(int(r[1] or 0) for r in rows)
    if max_dim <= 0:
        raise SystemExit("[ERROR] dim column is missing/invalid")

    feature_names = build_feature_names(max_dim)
    if len(feature_names) != max_dim:
        raise SystemExit(f"[ERROR] Feature header length mismatch: {len(feature_names)} != {max_dim}")

    header = ["user_id", "dim", "version", "computed_at"] + feature_names

    with open(args.out, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(header)

        for user_id, dim, version, computed_at, vector in rows:
            vec = list(vector or [])
            # Ensure a consistent length in output.
            if len(vec) < max_dim:
                vec = vec + [0.0] * (max_dim - len(vec))
            elif len(vec) > max_dim:
                vec = vec[:max_dim]

            writer.writerow([user_id, dim, version, computed_at] + vec)

    print(f"[DONE] Wrote {len(rows)} rows to {args.out}")


if __name__ == "__main__":
    main()
