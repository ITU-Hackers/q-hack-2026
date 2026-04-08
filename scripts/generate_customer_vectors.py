#!/usr/bin/env python3
"""
generate_customer_vectors.py

Build one fixed-size (128-dim) vector per synthetic customer and store
it in PostgreSQL. Vectors are derived from the existing synthetic tables.

Usage:
    python scripts/generate_customer_vectors.py \
        --db-url "postgresql://picky:Password123@localhost:5432/primary"
"""

from __future__ import annotations

import argparse
import hashlib
import sys
from dataclasses import dataclass
from typing import Iterable

try:
    import psycopg2
    from psycopg2.extras import execute_values
except ImportError:
    sys.exit(
        "psycopg2-binary not found.\n"
        "Run: uv add psycopg2-binary --directory services/picky-recs"
    )

DIM = 128
VECTOR_VERSION = 1
HASH_BUCKETS = 93

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


@dataclass
class UserRow:
    user_id: int
    archetype: str
    household_type: str
    dietary_restrictions: list[str]
    budget_tier: str
    cooking_time_tolerance: str
    monthly_budget_cents: int


@dataclass
class MetricsRow:
    avg_weekly_spend_cents: float
    avg_spend_trend: float
    avg_budget_util_rate: float
    avg_reorder_interval_days: float
    avg_order_interval_consistency: float
    avg_days_since_last_order: float
    avg_loyalty_staples_fraction: float
    avg_loyalty_one_time_fraction: float
    avg_top_category_concentration: float
    weeks_total: int
    weeks_active: int
    category_fractions: dict[str, float]


@dataclass
class OrdersRow:
    order_count: int
    avg_order_spend_cents: float
    avg_items_per_order: float
    total_spend_cents: float
    unique_products: int


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Generate customer vectors in PostgreSQL.")
    p.add_argument(
        "--db-url",
        default="postgresql://picky:Password123@localhost:5432/primary",
        help="PostgreSQL connection URL",
    )
    p.add_argument(
        "--clear-existing",
        action="store_true",
        help="Drop and recreate the vectors table before inserting",
    )
    p.add_argument(
        "--dry-run",
        action="store_true",
        help="Compute vectors but skip DB writes",
    )
    return p.parse_args()


def connect_db(db_url: str):
    try:
        conn = psycopg2.connect(db_url)
        conn.autocommit = False
        return conn
    except psycopg2.OperationalError as exc:
        sys.exit(f"[ERROR] Could not connect to database:\n  {exc}")


def create_schema(conn, clear_existing: bool) -> None:
    with conn.cursor() as cur:
        if clear_existing:
            cur.execute("DROP TABLE IF EXISTS user_profile_vectors CASCADE;")
        cur.execute(
            """
            CREATE TABLE IF NOT EXISTS user_profile_vectors (
                user_id     INTEGER PRIMARY KEY REFERENCES synthetic_users(id) ON DELETE CASCADE,
                vector      FLOAT8[] NOT NULL,
                dim         INTEGER NOT NULL,
                version     INTEGER NOT NULL,
                computed_at TIMESTAMP DEFAULT NOW()
            );
            """
        )
    conn.commit()


def _one_hot(value: str, options: Iterable[str]) -> list[float]:
    return [1.0 if value == opt else 0.0 for opt in options]


def _norm(value: float, scale: float) -> float:
    if scale <= 0:
        return 0.0
    return min(value / scale, 1.0)


def load_users(conn) -> dict[int, UserRow]:
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT id, archetype, household_type, dietary_restrictions,
                   budget_tier, cooking_time_tolerance, monthly_budget_cents
            FROM synthetic_users
            ORDER BY id
            """
        )
        rows = cur.fetchall()

    users: dict[int, UserRow] = {}
    for row in rows:
        users[row[0]] = UserRow(
            user_id=row[0],
            archetype=row[1] or "",
            household_type=row[2] or "",
            dietary_restrictions=list(row[3] or []),
            budget_tier=row[4] or "",
            cooking_time_tolerance=row[5] or "",
            monthly_budget_cents=int(row[6] or 0),
        )
    return users


def load_metrics(conn) -> dict[int, MetricsRow]:
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT
                user_id,
                AVG(weekly_spend_cents)::float,
                AVG(spend_trend)::float,
                AVG(budget_util_rate)::float,
                AVG(avg_reorder_interval_days)::float,
                AVG(order_interval_consistency)::float,
                AVG(days_since_last_order)::float,
                AVG(loyalty_staples_fraction)::float,
                AVG(loyalty_one_time_fraction)::float,
                AVG(top_category_concentration)::float,
                COUNT(*)::int,
                SUM(CASE WHEN weekly_spend_cents > 0 THEN 1 ELSE 0 END)::int,
                AVG(protein_fraction)::float,
                AVG(dairy_fraction)::float,
                AVG(carbs_fraction)::float,
                AVG(vegetables_fraction)::float,
                AVG(snacks_fraction)::float
            FROM user_weekly_metrics
            GROUP BY user_id
            """
        )
        rows = cur.fetchall()

    metrics: dict[int, MetricsRow] = {}
    for row in rows:
        metrics[row[0]] = MetricsRow(
            avg_weekly_spend_cents=row[1] or 0.0,
            avg_spend_trend=row[2] or 0.0,
            avg_budget_util_rate=row[3] or 0.0,
            avg_reorder_interval_days=row[4] or 0.0,
            avg_order_interval_consistency=row[5] or 0.0,
            avg_days_since_last_order=row[6] or 0.0,
            avg_loyalty_staples_fraction=row[7] or 0.0,
            avg_loyalty_one_time_fraction=row[8] or 0.0,
            avg_top_category_concentration=row[9] or 0.0,
            weeks_total=row[10] or 0,
            weeks_active=row[11] or 0,
            category_fractions={
                CATEGORY_FRACTIONS[0]: row[12] or 0.0,
                CATEGORY_FRACTIONS[1]: row[13] or 0.0,
                CATEGORY_FRACTIONS[2]: row[14] or 0.0,
                CATEGORY_FRACTIONS[3]: row[15] or 0.0,
                CATEGORY_FRACTIONS[4]: row[16] or 0.0,
            },
        )
    return metrics


def load_order_stats(conn) -> dict[int, OrdersRow]:
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT
                user_id,
                COUNT(*)::int,
                AVG(total_spend_cents)::float,
                AVG(num_items)::float,
                SUM(total_spend_cents)::float
            FROM orders
            GROUP BY user_id
            """
        )
        rows = cur.fetchall()

    stats: dict[int, OrdersRow] = {}
    for row in rows:
        stats[row[0]] = OrdersRow(
            order_count=row[1] or 0,
            avg_order_spend_cents=row[2] or 0.0,
            avg_items_per_order=row[3] or 0.0,
            total_spend_cents=row[4] or 0.0,
            unique_products=0,
        )

    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT o.user_id, COUNT(DISTINCT oi.product_name)::int
            FROM order_items oi
            JOIN orders o ON o.id = oi.order_id
            GROUP BY o.user_id
            """
        )
        for user_id, unique_count in cur.fetchall():
            if user_id in stats:
                stats[user_id].unique_products = unique_count or 0

    return stats


def load_product_buckets(conn, user_ids: Iterable[int]) -> dict[int, list[float]]:
    buckets: dict[int, list[float]] = {uid: [0.0] * HASH_BUCKETS for uid in user_ids}
    totals: dict[int, float] = {uid: 0.0 for uid in user_ids}

    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT o.user_id, oi.product_name,
                   SUM(oi.unit_price_cents * oi.quantity)::float
            FROM order_items oi
            JOIN orders o ON o.id = oi.order_id
            GROUP BY o.user_id, oi.product_name
            """
        )
        for user_id, product_name, spend_cents in cur.fetchall():
            if user_id not in buckets:
                continue
            key = product_name or ""
            digest = hashlib.md5(key.encode("utf-8")).hexdigest()
            bucket = int(digest, 16) % HASH_BUCKETS
            value = float(spend_cents or 0.0)
            buckets[user_id][bucket] += value
            totals[user_id] += value

    for user_id, bucket_vals in buckets.items():
        total = totals.get(user_id, 0.0)
        if total > 0:
            buckets[user_id] = [v / total for v in bucket_vals]

    return buckets


def build_vector(user: UserRow, metrics: MetricsRow | None, orders: OrdersRow | None, buckets: list[float]) -> list[float]:
    m = metrics
    o = orders

    features: list[float] = []
    if m:
        for name in CATEGORY_FRACTIONS:
            features.append(float(m.category_fractions.get(name, 0.0)))
    else:
        features.extend([0.0] * len(CATEGORY_FRACTIONS))

    avg_weekly_spend = m.avg_weekly_spend_cents if m else 0.0
    avg_spend_trend = m.avg_spend_trend if m else 0.0
    avg_budget_util = m.avg_budget_util_rate if m else 0.0
    avg_reorder = m.avg_reorder_interval_days if m else 0.0
    avg_consistency = m.avg_order_interval_consistency if m else 0.0
    avg_days_since = m.avg_days_since_last_order if m else 0.0
    avg_loyalty_staples = m.avg_loyalty_staples_fraction if m else 0.0
    avg_loyalty_one_time = m.avg_loyalty_one_time_fraction if m else 0.0
    avg_top_cat = m.avg_top_category_concentration if m else 0.0
    weeks_total = m.weeks_total if m else 0
    weeks_active = m.weeks_active if m else 0

    order_count = o.order_count if o else 0
    avg_order_spend = o.avg_order_spend_cents if o else 0.0
    avg_items = o.avg_items_per_order if o else 0.0
    total_spend = o.total_spend_cents if o else 0.0
    unique_products = o.unique_products if o else 0

    weeks_total = max(weeks_total, 1)

    features.extend([
        _norm(avg_weekly_spend, 10000.0),
        avg_spend_trend,
        avg_budget_util,
        _norm(avg_reorder, 30.0),
        avg_consistency,
        _norm(avg_days_since, 30.0),
        avg_loyalty_staples,
        avg_loyalty_one_time,
        avg_top_cat,
        _norm(float(user.monthly_budget_cents), 40000.0),
        _norm(order_count / weeks_total, 1.0),
        _norm(avg_items, 50.0),
        _norm(avg_order_spend, 10000.0),
        _norm(total_spend, 300000.0),
        _norm(float(unique_products), 200.0),
        _norm(weeks_active / weeks_total, 1.0),
    ])

    features.extend(_one_hot(user.archetype, ARCHETYPES))
    features.extend(_one_hot(user.household_type, HOUSEHOLD_TYPES))
    features.extend(_one_hot(user.budget_tier, BUDGET_TIERS))
    features.extend(_one_hot(user.cooking_time_tolerance, COOKING_TIME))

    dietary_flags = {d: 0.0 for d in DIETARY}
    for restriction in user.dietary_restrictions:
        if restriction in dietary_flags:
            dietary_flags[restriction] = 1.0
    features.extend([dietary_flags[d] for d in DIETARY])

    features.extend(buckets)

    if len(features) != DIM:
        raise ValueError(f"Vector length mismatch: {len(features)} != {DIM}")

    return features


def insert_vectors(conn, vectors: list[tuple[int, list[float]]]) -> None:
    with conn.cursor() as cur:
        execute_values(
            cur,
            """
            INSERT INTO user_profile_vectors (user_id, vector, dim, version)
            VALUES %s
            ON CONFLICT (user_id) DO UPDATE SET
                vector = EXCLUDED.vector,
                dim = EXCLUDED.dim,
                version = EXCLUDED.version,
                computed_at = NOW()
            """,
            [(user_id, vector, DIM, VECTOR_VERSION) for user_id, vector in vectors],
        )
    conn.commit()


def main() -> None:
    args = parse_args()
    conn = None
    if not args.dry_run:
        print(f"[INFO] Connecting to {args.db_url}")
        conn = connect_db(args.db_url)
        create_schema(conn, args.clear_existing)

    if args.dry_run:
        conn = connect_db(args.db_url)

    users = load_users(conn)
    metrics = load_metrics(conn)
    orders = load_order_stats(conn)
    buckets = load_product_buckets(conn, users.keys())

    vectors: list[tuple[int, list[float]]] = []
    for user_id, user in users.items():
        vector = build_vector(user, metrics.get(user_id), orders.get(user_id), buckets[user_id])
        vectors.append((user_id, vector))

    if args.dry_run:
        print(f"[dry-run] Computed {len(vectors)} vectors")
        return

    insert_vectors(conn, vectors)
    print(f"[DONE] Upserted {len(vectors)} customer vectors")
    if conn:
        conn.close()


if __name__ == "__main__":
    main()
