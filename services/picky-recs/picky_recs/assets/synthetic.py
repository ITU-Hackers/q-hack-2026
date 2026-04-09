"""
Dagster asset: seed synthetic user data into PostgreSQL.

Generates 300 synthetic Picnic user profiles (4 archetypes × 75) with
52 weeks of realistic order history and pre-computed weekly ML metrics,
then loads everything into PostgreSQL.

This asset is idempotent — it skips execution if synthetic_users already
contains rows, so it is safe to include in automated pipelines.
"""

import os

import numpy as np
from dagster import AssetExecutionContext, MaterializeResult, MetadataValue, asset

from picky_recs.synthetic_data import (
    ARCHETYPES,
    compute_metrics,
    connect_db,
    create_schema,
    generate_order_history,
    generate_users,
    insert_metrics,
    insert_order_items,
    insert_orders,
    insert_users,
    validate_and_print,
)

__all__ = ["seed_synthetic_users"]

_DEFAULT_DB_URL = "postgresql://picky:Password123@postgres.picky.local:5432/training"

SEED = 42
USERS_PER_ARCHETYPE = 75
NUM_WEEKS = 52


@asset(
    description=(
        "Seed PostgreSQL with 300 synthetic Picnic user profiles "
        "(4 archetypes × 75) and 52 weeks of order history + weekly ML metrics. "
        "Idempotent: skips if data already exists."
    ),
)
def seed_synthetic_users(context: AssetExecutionContext) -> MaterializeResult:
    db_url = os.environ.get("TRAINING_DB_URL", _DEFAULT_DB_URL)
    conn = connect_db(db_url)

    # Ensure schema exists before the idempotency check — on a fresh database
    # the synthetic_users table won't exist yet, so the SELECT below would fail
    # with "relation does not exist" without this call first.
    # create_schema uses CREATE TABLE IF NOT EXISTS so it is safe to call every run.
    create_schema(conn, clear_existing=False)

    # Idempotency check
    with conn.cursor() as cur:
        cur.execute("SELECT COUNT(*) FROM synthetic_users")
        row = cur.fetchone()
        existing = row[0] if row is not None else 0

    if existing > 0:
        context.log.info(
            f"synthetic_users already contains {existing:,} rows — skipping seed."
        )
        conn.close()
        return MaterializeResult(
            metadata={
                "skipped": MetadataValue.bool(True),
                "existing_users": MetadataValue.int(existing),
            }
        )

    rng = np.random.default_rng(SEED)
    users = generate_users(rng, USERS_PER_ARCHETYPE)
    context.log.info(
        f"Generating orders for {len(users)} users "
        f"({len(ARCHETYPES)} archetypes × {USERS_PER_ARCHETYPE})…"
    )

    user_orders: dict[int, list] = {}
    for idx, user in enumerate(users):
        cfg = ARCHETYPES[user.archetype]
        user_orders[idx] = generate_order_history(user, cfg, rng, num_weeks=NUM_WEEKS)
        if idx % 50 == 49:
            context.log.info(f"  Generated orders for {idx + 1}/{len(users)} users…")

    # Insert users → assign db_ids
    insert_users(conn, users)

    # Bind user db_ids → flatten orders
    all_orders = []
    for idx, user in enumerate(users):
        for order in user_orders[idx]:
            order.user_id = user.db_id
            all_orders.append(order)

    insert_orders(conn, all_orders)

    # Bind order db_ids → flatten items
    all_items = []
    for order in all_orders:
        for item in order.items:
            item.order_id = order.db_id
            all_items.append(item)

    insert_order_items(conn, all_items)

    context.log.info("Computing weekly metrics…")
    all_metrics = []
    for user in users:
        user_order_list = [o for o in all_orders if o.user_id == user.db_id]
        all_metrics.extend(compute_metrics(user, user_order_list))

    insert_metrics(conn, all_metrics)
    validate_and_print(conn)
    conn.close()

    return MaterializeResult(
        metadata={
            "skipped": MetadataValue.bool(False),
            "users": MetadataValue.int(len(users)),
            "orders": MetadataValue.int(len(all_orders)),
            "order_items": MetadataValue.int(len(all_items)),
            "weekly_metrics": MetadataValue.int(len(all_metrics)),
            "seed": MetadataValue.int(SEED),
            "archetypes": MetadataValue.text(", ".join(ARCHETYPES.keys())),
        }
    )
