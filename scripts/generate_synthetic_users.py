#!/usr/bin/env python3
"""
generate_synthetic_users.py

Generates 300 synthetic Picnic user profiles (4 archetypes × 75) with 52 weeks
of realistic order history and pre-computed weekly ML metrics, then loads
everything into PostgreSQL.

Usage:
    python scripts/generate_synthetic_users.py --seed 42 \
        --db-url "postgresql://picky:Password123@localhost:5432/primary"
"""

from __future__ import annotations

import argparse
import calendar
import sys
from collections import defaultdict
from dataclasses import dataclass, field
from datetime import date, timedelta
from statistics import mean, stdev
from typing import Any

import numpy as np

try:
    import psycopg2
    import psycopg2.extras
    from psycopg2.extras import execute_values, Json
except ImportError:
    sys.exit(
        "psycopg2-binary not found.\n"
        "Run: uv add psycopg2-binary --directory services/picky-recs"
    )

# ── CONSTANTS ─────────────────────────────────────────────────────────────────

REFERENCE_DATE = date(2025, 1, 6)  # Monday, start of week 1
CATEGORIES = ["protein", "dairy", "carbs", "vegetables", "snacks"]
BATCH_SIZE = 1_000

MEAT_PRODUCTS = {
    "Chicken breast 500g",
    "Ground beef 400g",
    "Salmon fillet 300g",
    "Canned tuna 185g",
    "Turkey mince 400g",
}

# ── PRODUCT CATALOGUE ─────────────────────────────────────────────────────────
# Each product: {"name": str, "price_range": (min_cents, max_cents)}

PRODUCT_CATALOGUE: dict[str, list[dict]] = {
    "protein": [
        {"name": "Chicken breast 500g",    "price_range": (280, 450)},
        {"name": "Ground beef 400g",       "price_range": (310, 500)},
        {"name": "Eggs 12-pack",           "price_range": (200, 350)},
        {"name": "Tofu 400g",              "price_range": (150, 250)},
        {"name": "Salmon fillet 300g",     "price_range": (420, 720)},
        {"name": "Lentils 500g",           "price_range": (80, 150)},
        {"name": "Canned tuna 185g",       "price_range": (90, 160)},
        {"name": "Chickpeas 400g",         "price_range": (70, 130)},
        {"name": "Turkey mince 400g",      "price_range": (290, 460)},
        {"name": "Greek yoghurt 500g",     "price_range": (180, 280)},
        {"name": "Tempeh 200g",            "price_range": (200, 320)},
        {"name": "Protein powder 1kg",     "price_range": (1800, 3500)},
        {"name": "Black beans 400g",       "price_range": (70, 120)},
        {"name": "Edamame 400g",           "price_range": (180, 280)},
    ],
    "dairy": [
        {"name": "Whole milk 1L",          "price_range": (90, 140)},
        {"name": "Semi-skimmed milk 1L",   "price_range": (85, 135)},
        {"name": "Cheddar 200g",           "price_range": (200, 340)},
        {"name": "Mozzarella 125g",        "price_range": (120, 210)},
        {"name": "Butter 250g",            "price_range": (160, 260)},
        {"name": "Cream cheese 150g",      "price_range": (140, 220)},
        {"name": "Sour cream 200ml",       "price_range": (110, 190)},
        {"name": "Oat milk 1L",            "price_range": (170, 280)},
        {"name": "Almond milk 1L",         "price_range": (180, 290)},
        {"name": "Feta cheese 200g",       "price_range": (190, 310)},
    ],
    "carbs": [
        {"name": "Pasta 500g",             "price_range": (80, 160)},
        {"name": "Rice 1kg",               "price_range": (110, 210)},
        {"name": "Bread loaf",             "price_range": (130, 230)},
        {"name": "Oats 1kg",               "price_range": (120, 200)},
        {"name": "Potatoes 1.5kg",         "price_range": (130, 230)},
        {"name": "Sweet potato 1kg",       "price_range": (160, 260)},
        {"name": "Tortillas 8-pack",       "price_range": (150, 250)},
        {"name": "Quinoa 500g",            "price_range": (280, 450)},
        {"name": "Couscous 500g",          "price_range": (140, 240)},
        {"name": "Noodles 250g",           "price_range": (90, 160)},
    ],
    "vegetables": [
        {"name": "Mixed salad 150g",       "price_range": (120, 200)},
        {"name": "Broccoli 400g",          "price_range": (130, 220)},
        {"name": "Spinach 200g",           "price_range": (140, 220)},
        {"name": "Carrots 500g",           "price_range": (80, 140)},
        {"name": "Cherry tomatoes 250g",   "price_range": (140, 230)},
        {"name": "Bell peppers 3-pack",    "price_range": (160, 270)},
        {"name": "Cucumber",               "price_range": (80, 140)},
        {"name": "Onions 1kg",             "price_range": (90, 150)},
        {"name": "Garlic bulb",            "price_range": (50, 100)},
        {"name": "Courgette 2-pack",       "price_range": (130, 210)},
        {"name": "Aubergine",              "price_range": (120, 200)},
        {"name": "Mushrooms 250g",         "price_range": (130, 220)},
    ],
    "snacks": [
        {"name": "Crisps 150g",            "price_range": (120, 210)},
        {"name": "Chocolate bar",          "price_range": (80, 160)},
        {"name": "Granola bars 6-pack",    "price_range": (180, 300)},
        {"name": "Mixed nuts 200g",        "price_range": (250, 420)},
        {"name": "Hummus 200g",            "price_range": (140, 230)},
        {"name": "Rice cakes 100g",        "price_range": (110, 190)},
        {"name": "Dried fruit 150g",       "price_range": (160, 270)},
        {"name": "Popcorn 80g",            "price_range": (90, 160)},
    ],
}


def _season(d: date) -> str:
    m = d.month
    if m in (12, 1, 2):
        return "winter"
    if m in (3, 4, 5):
        return "spring"
    if m in (6, 7, 8):
        return "summer"
    return "autumn"


# ── DATACLASSES ───────────────────────────────────────────────────────────────


@dataclass
class ArchetypeConfig:
    name: str
    weekly_spend_range: tuple[int, int]          # cents
    order_interval_range: tuple[int, int]        # days between orders
    items_per_order: tuple[int, int]
    category_mix: dict[str, float]               # fractions summing to 1.0
    preferred_dow: int | None                    # 0=Mon … 6=Sun; None = random
    dow_jitter: int                              # ± days around preferred DOW
    skip_week_prob: float
    month_end_spend_multiplier: float            # applied when month_fraction > 0.75
    dietary_restrictions: list[str]
    household_type: str
    budget_tier: str
    cuisine_prefs: list[str]
    cooking_time_tolerance: str
    monthly_budget_range: tuple[int, int]        # cents


@dataclass
class User:
    archetype: str
    household_type: str
    dietary_restrictions: list[str]
    budget_tier: str
    cuisine_prefs: list[str]
    cooking_time_tolerance: str
    monthly_budget_cents: int
    db_id: int | None = None


@dataclass
class OrderItem:
    product_name: str
    category: str
    quantity: float
    unit_price_cents: int
    order_id: int | None = None
    db_id: int | None = None


@dataclass
class Order:
    user_id: int
    order_date: date
    week_number: int
    total_spend_cents: int
    num_items: int
    day_of_week: int
    month_fraction: float
    budget_remaining_fraction: float
    season: str
    items: list[OrderItem] = field(default_factory=list)
    db_id: int | None = None


@dataclass
class WeeklyMetrics:
    user_id: int
    week_number: int
    weekly_spend_cents: int
    avg_weekly_spend_4wk_cents: int
    spend_trend: float
    budget_util_rate: float
    cumulative_spend_cents: int
    loyalty_staples_fraction: float
    loyalty_one_time_fraction: float
    avg_reorder_interval_days: float
    top_category_concentration: float
    order_interval_consistency: float
    days_since_last_order: int
    pantry_depletion: dict[str, float]
    protein_fraction: float
    dairy_fraction: float
    carbs_fraction: float
    vegetables_fraction: float
    snacks_fraction: float


# ── ARCHETYPE DEFINITIONS ─────────────────────────────────────────────────────

ARCHETYPES: dict[str, ArchetypeConfig] = {
    "budget_student": ArchetypeConfig(
        name="budget_student",
        weekly_spend_range=(2500, 5000),          # €25–50
        order_interval_range=(6, 8),
        items_per_order=(8, 12),
        category_mix={"protein": 0.40, "carbs": 0.30, "dairy": 0.15, "vegetables": 0.10, "snacks": 0.05},
        preferred_dow=6,                          # Sunday
        dow_jitter=1,
        skip_week_prob=0.02,
        month_end_spend_multiplier=0.65,          # 35% drop
        dietary_restrictions=[],
        household_type="student_single",
        budget_tier="tight",
        cuisine_prefs=["quick_meals", "high_protein"],
        cooking_time_tolerance="short",
        monthly_budget_range=(10000, 18000),      # €100–180/month
    ),
    "big_family": ArchetypeConfig(
        name="big_family",
        weekly_spend_range=(7000, 10000),         # €70–100
        order_interval_range=(5, 7),
        items_per_order=(30, 45),
        category_mix={"protein": 0.20, "dairy": 0.25, "carbs": 0.25, "vegetables": 0.20, "snacks": 0.10},
        preferred_dow=3,                          # Thursday
        dow_jitter=2,
        skip_week_prob=0.10,
        month_end_spend_multiplier=0.95,
        dietary_restrictions=[],
        household_type="family_young",
        budget_tier="moderate",
        cuisine_prefs=["family_meals", "kid_friendly", "variety"],
        cooking_time_tolerance="medium",
        monthly_budget_range=(28000, 40000),      # €280–400/month
    ),
    "gym_goer": ArchetypeConfig(
        name="gym_goer",
        weekly_spend_range=(5000, 9000),          # €50–90
        order_interval_range=(4, 9),
        items_per_order=(12, 20),
        category_mix={"protein": 0.60, "dairy": 0.15, "carbs": 0.15, "vegetables": 0.07, "snacks": 0.03},
        preferred_dow=None,                       # irregular
        dow_jitter=0,
        skip_week_prob=0.02,
        month_end_spend_multiplier=0.95,
        dietary_restrictions=["high_protein"],
        household_type="student_single",
        budget_tier="moderate",
        cuisine_prefs=["high_protein", "meal_prep"],
        cooking_time_tolerance="medium",
        monthly_budget_range=(20000, 32000),      # €200–320/month
    ),
    "vegetarian_couple": ArchetypeConfig(
        name="vegetarian_couple",
        weekly_spend_range=(6000, 9000),          # €60–90
        order_interval_range=(5, 7),
        items_per_order=(18, 28),
        category_mix={"protein": 0.35, "dairy": 0.25, "vegetables": 0.25, "carbs": 0.10, "snacks": 0.05},
        preferred_dow=5,                          # Saturday
        dow_jitter=1,
        skip_week_prob=0.02,
        month_end_spend_multiplier=0.92,
        dietary_restrictions=["vegetarian"],
        household_type="couple",
        budget_tier="moderate",
        cuisine_prefs=["mediterranean", "asian", "vegetarian"],
        cooking_time_tolerance="long",
        monthly_budget_range=(24000, 36000),      # €240–360/month
    ),
}


# ── USER GENERATION ───────────────────────────────────────────────────────────


def generate_users(rng: np.random.Generator, users_per_archetype: int) -> list[User]:
    users: list[User] = []
    for cfg in ARCHETYPES.values():
        for _ in range(users_per_archetype):
            budget = int(rng.integers(cfg.monthly_budget_range[0], cfg.monthly_budget_range[1]))
            users.append(User(
                archetype=cfg.name,
                household_type=cfg.household_type,
                dietary_restrictions=list(cfg.dietary_restrictions),
                budget_tier=cfg.budget_tier,
                cuisine_prefs=list(cfg.cuisine_prefs),
                cooking_time_tolerance=cfg.cooking_time_tolerance,
                monthly_budget_cents=budget,
            ))
    return users


# ── ORDER HISTORY GENERATION ──────────────────────────────────────────────────


def _draw_items(
    rng: np.random.Generator,
    cfg: ArchetypeConfig,
    n_items: int,
    total_spend: int,
    is_vegetarian: bool,
) -> list[OrderItem]:
    """Allocate total_spend across categories and fill with catalogue products."""
    items: list[OrderItem] = []
    remaining_spend = total_spend
    items_remaining = n_items

    cat_order = list(cfg.category_mix.keys())
    # shuffle category order slightly for variety
    rng.shuffle(cat_order)  # type: ignore[arg-type]

    for i, cat in enumerate(cat_order):
        is_last = i == len(cat_order) - 1
        cat_budget = remaining_spend if is_last else int(total_spend * cfg.category_mix[cat])
        cat_items_target = max(1, round(n_items * cfg.category_mix[cat]))
        if is_last:
            cat_items_target = max(1, items_remaining)

        catalogue = [
            p for p in PRODUCT_CATALOGUE[cat]
            if not (is_vegetarian and p["name"] in MEAT_PRODUCTS)
        ]
        if not catalogue:
            continue

        spent = 0
        added = 0
        while spent < cat_budget * 0.85 and added < cat_items_target:
            product = catalogue[int(rng.integers(0, len(catalogue)))]
            price = int(rng.integers(product["price_range"][0], product["price_range"][1]))
            qty_raw = rng.random()
            quantity = 2.0 if qty_raw > 0.75 else 1.0

            items.append(OrderItem(
                product_name=product["name"],
                category=cat,
                quantity=quantity,
                unit_price_cents=price,
            ))
            spent += int(price * quantity)
            added += 1

        remaining_spend = max(0, remaining_spend - spent)
        items_remaining = max(0, items_remaining - added)

    return items if items else [OrderItem(
        product_name="Pasta 500g", category="carbs", quantity=1.0, unit_price_cents=total_spend
    )]


def generate_order_history(
    user: User,
    cfg: ArchetypeConfig,
    rng: np.random.Generator,
    num_weeks: int = 52,
) -> list[Order]:
    orders: list[Order] = []
    is_vegetarian = "vegetarian" in user.dietary_restrictions
    cumulative_spend = 0
    monthly_budget = user.monthly_budget_cents

    # Track current order date via an advancing pointer
    current_date = REFERENCE_DATE

    for week in range(1, num_weeks + 1):
        week_start = REFERENCE_DATE + timedelta(weeks=week - 1)

        # Skip check
        if rng.random() < cfg.skip_week_prob:
            current_date = week_start + timedelta(days=7)
            continue

        # Order date
        if cfg.preferred_dow is not None:
            # Move to preferred day of week within this week's window
            base_dow = week_start.weekday()
            delta = (cfg.preferred_dow - base_dow) % 7
            order_date = week_start + timedelta(days=delta)
            jitter = int(rng.integers(-cfg.dow_jitter, cfg.dow_jitter + 1))
            order_date = order_date + timedelta(days=jitter)
            # Clamp to the week window ±3 days
            order_date = max(week_start - timedelta(days=3), min(week_start + timedelta(days=10), order_date))
        else:
            interval = int(rng.integers(cfg.order_interval_range[0], cfg.order_interval_range[1] + 1))
            order_date = current_date + timedelta(days=interval)
            # Clamp to reasonable range around week start
            order_date = max(week_start, min(week_start + timedelta(days=9), order_date))

        current_date = order_date

        # Month context
        days_in_month = calendar.monthrange(order_date.year, order_date.month)[1]
        month_fraction = (order_date.day - 1) / days_in_month

        # Spend with month-end effect
        base_spend = int(rng.integers(cfg.weekly_spend_range[0], cfg.weekly_spend_range[1]))
        if month_fraction > 0.75:
            multiplier = cfg.month_end_spend_multiplier + rng.random() * (1 - cfg.month_end_spend_multiplier) * 0.5
            base_spend = int(base_spend * multiplier)
        base_spend = max(500, base_spend)

        # Number of items
        n_items = int(rng.integers(cfg.items_per_order[0], cfg.items_per_order[1] + 1))

        # Budget remaining fraction
        budget_remaining = max(0, monthly_budget - (cumulative_spend % monthly_budget))
        budget_remaining_frac = budget_remaining / monthly_budget

        # Draw items
        item_list = _draw_items(rng, cfg, n_items, base_spend, is_vegetarian)

        # Recompute actual spend from items
        actual_spend = sum(int(it.unit_price_cents * it.quantity) for it in item_list)
        actual_spend = max(500, actual_spend)
        cumulative_spend += actual_spend

        orders.append(Order(
            user_id=0,  # filled in after DB insert
            order_date=order_date,
            week_number=week,
            total_spend_cents=actual_spend,
            num_items=len(item_list),
            day_of_week=order_date.weekday(),
            month_fraction=round(month_fraction, 4),
            budget_remaining_fraction=round(budget_remaining_frac, 4),
            season=_season(order_date),
            items=item_list,
        ))

    return orders


# ── METRICS COMPUTATION ───────────────────────────────────────────────────────


def _safe_mean(values: list[float]) -> float:
    return mean(values) if values else 0.0


def _safe_stdev(values: list[float]) -> float:
    return stdev(values) if len(values) >= 2 else 0.0


def compute_metrics(user: User, orders: list[Order]) -> list[WeeklyMetrics]:
    """Compute 52 weekly metric rows for a single user."""
    # Build fast lookups
    orders_by_week: dict[int, Order] = {o.week_number: o for o in orders}
    order_dates_sorted = sorted(o.order_date for o in orders)

    # Product-level purchase history for loyalty metrics
    product_weeks: dict[str, list[int]] = defaultdict(list)
    for o in orders:
        for item in o.items:
            product_weeks[item.product_name].append(o.week_number)

    n_order_weeks = len(orders)
    staple_threshold = 0.75 * n_order_weeks
    staples = {p for p, weeks in product_weeks.items() if len(weeks) >= staple_threshold}
    one_timers = {p for p, weeks in product_weeks.items() if len(weeks) == 1}
    total_unique_products = len(product_weeks)

    loyalty_staples_frac = len(staples) / max(total_unique_products, 1)
    loyalty_one_time_frac = len(one_timers) / max(total_unique_products, 1)

    # Average reorder interval across all products bought more than once
    reorder_gaps: list[float] = []
    for p, wks in product_weeks.items():
        if len(wks) >= 2:
            wks_sorted = sorted(wks)
            for i in range(len(wks_sorted) - 1):
                reorder_gaps.append((wks_sorted[i + 1] - wks_sorted[i]) * 7.0)
    avg_reorder_interval = _safe_mean(reorder_gaps) if reorder_gaps else 7.0

    # Category-level last purchase date tracking (updated per week)
    cat_last_week: dict[str, int] = {}   # category -> last week it had purchases
    cat_gaps: dict[str, list[float]] = defaultdict(list)
    for o in sorted(orders, key=lambda x: x.week_number):
        for cat in CATEGORIES:
            if any(it.category == cat for it in o.items):
                if cat in cat_last_week:
                    gap = (o.week_number - cat_last_week[cat]) * 7.0
                    cat_gaps[cat].append(gap)
                cat_last_week[cat] = o.week_number

    avg_cat_interval: dict[str, float] = {
        cat: _safe_mean(cat_gaps[cat]) if cat_gaps[cat] else 7.0
        for cat in CATEGORIES
    }

    annual_budget = user.monthly_budget_cents * 12

    results: list[WeeklyMetrics] = []
    cumulative_spend = 0

    for week in range(1, 53):
        order = orders_by_week.get(week)
        week_start = REFERENCE_DATE + timedelta(weeks=week - 1)

        if order:
            cumulative_spend += order.total_spend_cents
            weekly_spend = order.total_spend_cents
        else:
            weekly_spend = 0

        # Rolling 4-week avg
        window = [orders_by_week[w].total_spend_cents for w in range(max(1, week - 3), week + 1) if w in orders_by_week]
        avg_4wk = int(_safe_mean(window)) if window else 0

        # Spend trend: (mean of last 2 weeks - mean of prior 2 weeks) / prior 2 weeks
        last2 = _safe_mean([orders_by_week[w].total_spend_cents for w in [week - 1, week] if w in orders_by_week])
        prior2 = _safe_mean([orders_by_week[w].total_spend_cents for w in [week - 3, week - 2] if w in orders_by_week])
        spend_trend = (last2 - prior2) / prior2 if prior2 > 0 else 0.0
        spend_trend = round(max(-5.0, min(5.0, spend_trend)), 4)

        # Budget utilization rate
        expected_spend = annual_budget * (week / 52)
        budget_util_rate = round(cumulative_spend / max(expected_spend, 1), 4)

        # Order interval consistency (using all orders up to week w)
        past_dates = sorted(o.order_date for o in orders if o.week_number <= week)
        if len(past_dates) >= 2:
            gaps = [(past_dates[i + 1] - past_dates[i]).days for i in range(len(past_dates) - 1)]
            mean_gap = _safe_mean(gaps)
            std_gap = _safe_stdev(gaps)
            consistency = round(max(0.0, min(1.0, 1.0 - std_gap / mean_gap if mean_gap > 0 else 1.0)), 4)
        else:
            consistency = 1.0

        # Days since last order
        if order:
            days_since = 0
        else:
            past_orders = [o for o in orders if o.week_number < week]
            if past_orders:
                last_date = max(o.order_date for o in past_orders)
                days_since = (week_start - last_date).days
            else:
                days_since = week * 7

        # Pantry depletion per category
        pantry_depletion: dict[str, float] = {}
        for cat in CATEGORIES:
            cat_orders_to_week = [o for o in orders if o.week_number <= week and any(it.category == cat for it in o.items)]
            if not cat_orders_to_week:
                pantry_depletion[cat] = 0.0
                continue
            last_cat_date = max(o.order_date for o in cat_orders_to_week)
            days_elapsed = (week_start - last_cat_date).days
            avg_interval = avg_cat_interval.get(cat, 7.0)
            depletion = round(max(0.0, 1.0 - min(days_elapsed / avg_interval, 1.0)), 4)
            pantry_depletion[cat] = depletion

        # Category fractions (current week)
        if order and order.items:
            total_item_value = sum(it.unit_price_cents * it.quantity for it in order.items)
            cat_spend: dict[str, float] = defaultdict(float)
            for it in order.items:
                cat_spend[it.category] += it.unit_price_cents * it.quantity
            fractions = {cat: round(cat_spend[cat] / max(total_item_value, 1), 4) for cat in CATEGORIES}
        else:
            fractions = {cat: 0.0 for cat in CATEGORIES}

        top_cat_conc = round(max(fractions.values()), 4)

        results.append(WeeklyMetrics(
            user_id=user.db_id,  # type: ignore[arg-type]
            week_number=week,
            weekly_spend_cents=weekly_spend,
            avg_weekly_spend_4wk_cents=avg_4wk,
            spend_trend=spend_trend,
            budget_util_rate=budget_util_rate,
            cumulative_spend_cents=cumulative_spend,
            loyalty_staples_fraction=round(loyalty_staples_frac, 4),
            loyalty_one_time_fraction=round(loyalty_one_time_frac, 4),
            avg_reorder_interval_days=round(avg_reorder_interval, 2),
            top_category_concentration=top_cat_conc,
            order_interval_consistency=consistency,
            days_since_last_order=days_since,
            pantry_depletion=pantry_depletion,
            **fractions,
        ))

    return results


# ── DATABASE HELPERS ──────────────────────────────────────────────────────────


def connect_db(db_url: str):
    try:
        conn = psycopg2.connect(db_url)
        conn.autocommit = False
        return conn
    except psycopg2.OperationalError as e:
        sys.exit(f"[ERROR] Could not connect to database:\n  {e}")


DROP_DDL = """
DROP TABLE IF EXISTS user_weekly_metrics CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS synthetic_users CASCADE;
"""

CREATE_DDL = """
CREATE TABLE IF NOT EXISTS synthetic_users (
    id                     SERIAL PRIMARY KEY,
    archetype              VARCHAR(50),
    household_type         VARCHAR(50),
    dietary_restrictions   TEXT[]   DEFAULT '{}',
    budget_tier            VARCHAR(20),
    cuisine_prefs          TEXT[]   DEFAULT '{}',
    cooking_time_tolerance VARCHAR(50),
    monthly_budget_cents   INTEGER,
    created_at             TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS orders (
    id                        SERIAL PRIMARY KEY,
    user_id                   INTEGER REFERENCES synthetic_users(id) ON DELETE CASCADE,
    order_date                DATE,
    week_number               INTEGER,
    total_spend_cents         INTEGER,
    num_items                 INTEGER,
    day_of_week               INTEGER,
    month_fraction            FLOAT,
    budget_remaining_fraction FLOAT,
    season                    VARCHAR(20),
    created_at                TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS order_items (
    id               SERIAL PRIMARY KEY,
    order_id         INTEGER REFERENCES orders(id) ON DELETE CASCADE,
    product_name     VARCHAR(100),
    category         VARCHAR(50),
    quantity         FLOAT,
    unit_price_cents INTEGER,
    created_at       TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS user_weekly_metrics (
    id                         SERIAL PRIMARY KEY,
    user_id                    INTEGER REFERENCES synthetic_users(id) ON DELETE CASCADE,
    week_number                INTEGER,
    weekly_spend_cents         INTEGER,
    avg_weekly_spend_4wk_cents INTEGER,
    spend_trend                FLOAT,
    budget_util_rate           FLOAT,
    cumulative_spend_cents     INTEGER,
    loyalty_staples_fraction   FLOAT,
    loyalty_one_time_fraction  FLOAT,
    avg_reorder_interval_days  FLOAT,
    top_category_concentration FLOAT,
    order_interval_consistency FLOAT,
    days_since_last_order      INTEGER,
    pantry_depletion           JSONB,
    protein_fraction           FLOAT,
    dairy_fraction             FLOAT,
    carbs_fraction             FLOAT,
    vegetables_fraction        FLOAT,
    snacks_fraction            FLOAT,
    created_at                 TIMESTAMP DEFAULT NOW(),
    UNIQUE (user_id, week_number)
);

CREATE INDEX IF NOT EXISTS idx_orders_user_week ON orders (user_id, week_number);
CREATE INDEX IF NOT EXISTS idx_orders_user_date ON orders (user_id, order_date);
CREATE INDEX IF NOT EXISTS idx_order_items_order_cat ON order_items (order_id, category);
"""


def create_schema(conn, clear_existing: bool) -> None:
    with conn.cursor() as cur:
        if clear_existing:
            print("[INFO] Dropping existing tables...")
            cur.execute(DROP_DDL)
        cur.execute(CREATE_DDL)
    conn.commit()
    print("[INFO] Schema ready.")


def _chunked(lst: list, n: int):
    for i in range(0, len(lst), n):
        yield lst[i : i + n]


def insert_users(conn, users: list[User]) -> None:
    with conn.cursor() as cur:
        rows = [
            (u.archetype, u.household_type, u.dietary_restrictions,
             u.budget_tier, u.cuisine_prefs, u.cooking_time_tolerance,
             u.monthly_budget_cents)
            for u in users
        ]
        ids = execute_values(
            cur,
            """INSERT INTO synthetic_users
               (archetype, household_type, dietary_restrictions, budget_tier,
                cuisine_prefs, cooking_time_tolerance, monthly_budget_cents)
               VALUES %s RETURNING id""",
            rows,
            fetch=True,
        )
    conn.commit()
    for user, (uid,) in zip(users, ids):
        user.db_id = uid
    print(f"  \u2713 Inserted {len(users)} users")


def insert_orders(conn, all_orders: list[Order]) -> None:
    total = 0
    for chunk in _chunked(all_orders, BATCH_SIZE):
        rows = [
            (o.user_id, o.order_date, o.week_number, o.total_spend_cents,
             o.num_items, o.day_of_week, o.month_fraction,
             o.budget_remaining_fraction, o.season)
            for o in chunk
        ]
        with conn.cursor() as cur:
            ids = execute_values(
                cur,
                """INSERT INTO orders
                   (user_id, order_date, week_number, total_spend_cents,
                    num_items, day_of_week, month_fraction,
                    budget_remaining_fraction, season)
                   VALUES %s RETURNING id""",
                rows,
                fetch=True,
            )
        conn.commit()
        for order, (oid,) in zip(chunk, ids):
            order.db_id = oid
        total += len(chunk)
    print(f"  \u2713 Inserted {total:,} orders")


def insert_order_items(conn, all_items: list[OrderItem]) -> None:
    total = 0
    for chunk in _chunked(all_items, BATCH_SIZE):
        rows = [
            (it.order_id, it.product_name, it.category, it.quantity, it.unit_price_cents)
            for it in chunk
        ]
        with conn.cursor() as cur:
            execute_values(
                cur,
                """INSERT INTO order_items
                   (order_id, product_name, category, quantity, unit_price_cents)
                   VALUES %s""",
                rows,
            )
        conn.commit()
        total += len(chunk)
    print(f"  \u2713 Inserted {total:,} order items")


def insert_metrics(conn, all_metrics: list[WeeklyMetrics]) -> None:
    total = 0
    for chunk in _chunked(all_metrics, BATCH_SIZE):
        rows = [
            (m.user_id, m.week_number, m.weekly_spend_cents,
             m.avg_weekly_spend_4wk_cents, m.spend_trend, m.budget_util_rate,
             m.cumulative_spend_cents, m.loyalty_staples_fraction,
             m.loyalty_one_time_fraction, m.avg_reorder_interval_days,
             m.top_category_concentration, m.order_interval_consistency,
             m.days_since_last_order, Json(m.pantry_depletion),
             m.protein_fraction, m.dairy_fraction, m.carbs_fraction,
             m.vegetables_fraction, m.snacks_fraction)
            for m in chunk
        ]
        with conn.cursor() as cur:
            execute_values(
                cur,
                """INSERT INTO user_weekly_metrics
                   (user_id, week_number, weekly_spend_cents,
                    avg_weekly_spend_4wk_cents, spend_trend, budget_util_rate,
                    cumulative_spend_cents, loyalty_staples_fraction,
                    loyalty_one_time_fraction, avg_reorder_interval_days,
                    top_category_concentration, order_interval_consistency,
                    days_since_last_order, pantry_depletion,
                    protein_fraction, dairy_fraction, carbs_fraction,
                    vegetables_fraction, snacks_fraction)
                   VALUES %s
                   ON CONFLICT (user_id, week_number) DO NOTHING""",
                rows,
            )
        conn.commit()
        total += len(chunk)
    print(f"  \u2713 Inserted {total:,} weekly metric rows")


# ── VALIDATION ────────────────────────────────────────────────────────────────


def validate_and_print(conn) -> None:
    print("\n[VALIDATION] Summary queries")
    print("=" * 60)

    with conn.cursor() as cur:
        # Row counts
        print("\nTable row counts:")
        for table in ("synthetic_users", "orders", "order_items", "user_weekly_metrics"):
            cur.execute(f"SELECT COUNT(*) FROM {table}")
            count = cur.fetchone()[0]
            print(f"  {table:<30} {count:>10,}")

        # Archetype distribution
        print("\nArchetype distribution:")
        cur.execute("SELECT archetype, COUNT(*) FROM synthetic_users GROUP BY archetype ORDER BY archetype")
        for row in cur.fetchall():
            print(f"  {row[0]:<30} {row[1]:>5} users")

        # Avg weekly spend per archetype
        print("\nAvg weekly spend (orders with non-zero spend):")
        cur.execute("""
            SELECT u.archetype,
                   ROUND(AVG(o.total_spend_cents) / 100.0, 2) AS avg_euros,
                   ROUND(MIN(o.total_spend_cents) / 100.0, 2) AS min_euros,
                   ROUND(MAX(o.total_spend_cents) / 100.0, 2) AS max_euros
            FROM orders o
            JOIN synthetic_users u ON u.id = o.user_id
            GROUP BY u.archetype
            ORDER BY u.archetype
        """)
        for row in cur.fetchall():
            print(f"  {row[0]:<30} avg=€{row[1]}  min=€{row[2]}  max=€{row[3]}")

        # Vegetarian constraint check
        meat_list = tuple(MEAT_PRODUCTS)
        cur.execute("""
            SELECT COUNT(*)
            FROM order_items oi
            JOIN orders o ON o.id = oi.order_id
            JOIN synthetic_users u ON u.id = o.user_id
            WHERE u.archetype = 'vegetarian_couple'
              AND oi.product_name = ANY(%s)
        """, (list(meat_list),))
        meat_count = cur.fetchone()[0]
        status = "\u2713" if meat_count == 0 else "\u2717"
        print(f"\nVegetarian constraint — meat items in vegetarian_couple orders: {meat_count} {status}")

        # Month-end spend drop for budget_student
        cur.execute("""
            SELECT
              ROUND(AVG(CASE WHEN week_number % 4 = 0 THEN total_spend_cents END) / 100.0, 2) AS month_end_avg,
              ROUND(AVG(CASE WHEN week_number % 4 != 0 THEN total_spend_cents END) / 100.0, 2) AS other_avg
            FROM orders o
            JOIN synthetic_users u ON u.id = o.user_id
            WHERE u.archetype = 'budget_student'
        """)
        row = cur.fetchone()
        if row and row[0] and row[1]:
            drop_pct = round((1 - row[0] / row[1]) * 100, 1)
            print(f"\nBudget student month-end spend drop:")
            print(f"  Week-4 avg=€{row[0]}  Other-weeks avg=€{row[1]}  Drop={drop_pct}%")

        # Category fractions by archetype
        print("\nAvg protein fraction in weekly metrics by archetype:")
        cur.execute("""
            SELECT u.archetype, ROUND(AVG(m.protein_fraction) * 100, 1) AS pct
            FROM user_weekly_metrics m
            JOIN synthetic_users u ON u.id = m.user_id
            WHERE m.weekly_spend_cents > 0
            GROUP BY u.archetype
            ORDER BY u.archetype
        """)
        for row in cur.fetchall():
            print(f"  {row[0]:<30} protein={row[1]}%")

        # Sample user per archetype
        print("\nSample user detail (1 per archetype):")
        cur.execute("""
            SELECT DISTINCT ON (u.archetype)
                u.id, u.archetype,
                COUNT(o.id) OVER (PARTITION BY u.id)     AS order_count,
                SUM(o.total_spend_cents) OVER (PARTITION BY u.id) / 100.0 AS total_eur
            FROM synthetic_users u
            LEFT JOIN orders o ON o.user_id = u.id
            ORDER BY u.archetype, u.id
        """)
        for row in cur.fetchall():
            print(f"  User {row[0]:>4} ({row[1]}): {row[2]} orders, €{row[3]:.2f} total")

    print("\n[DONE] Data generation complete. Ready for model training.")


# ── CLI ENTRY POINT ───────────────────────────────────────────────────────────


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(
        description="Generate synthetic Picnic user profiles and order histories in PostgreSQL."
    )
    p.add_argument("--seed", type=int, default=42, help="RNG seed (default: 42)")
    p.add_argument(
        "--db-url",
        default="postgresql://picky:Password123@localhost:5432/primary",
        help="PostgreSQL connection URL",
    )
    p.add_argument(
        "--users-per-archetype",
        type=int,
        default=75,
        metavar="N",
        help="Users per archetype (default: 75)",
    )
    p.add_argument(
        "--num-weeks",
        type=int,
        default=52,
        metavar="W",
        help="Weeks of order history per user (default: 52)",
    )
    p.add_argument(
        "--clear-existing",
        action="store_true",
        help="Drop and recreate all tables before inserting",
    )
    p.add_argument(
        "--dry-run",
        action="store_true",
        help="Generate data in memory but skip all DB writes",
    )
    return p.parse_args()


def main() -> None:
    args = parse_args()

    import random
    random.seed(args.seed)
    rng = np.random.default_rng(args.seed)

    conn = None
    if not args.dry_run:
        print(f"[INFO] Connecting to {args.db_url}")
        conn = connect_db(args.db_url)
        print("[INFO] Creating schema...")
        create_schema(conn, args.clear_existing)

    n = args.users_per_archetype
    print(f"[INFO] Generating {len(ARCHETYPES)} archetypes × {n} users = {len(ARCHETYPES) * n} total\n")

    users = generate_users(rng, n)

    # Generate all order histories in memory
    user_orders: dict[int, list[Order]] = {}
    for idx, user in enumerate(users):
        cfg = ARCHETYPES[user.archetype]
        orders = generate_order_history(user, cfg, rng, num_weeks=args.num_weeks)
        user_orders[idx] = orders
        if idx % 50 == 0:
            print(f"  Generated orders for user {idx + 1}/{len(users)}...")

    # Archetype order summaries
    for arch_name in ARCHETYPES:
        arch_users = [u for u in users if u.archetype == arch_name]
        arch_indices = [i for i, u in enumerate(users) if u.archetype == arch_name]
        total_orders = sum(len(user_orders[i]) for i in arch_indices)
        print(f"  {arch_name}: {len(arch_users)} users, {total_orders} total orders")

    if args.dry_run:
        total_orders = sum(len(v) for v in user_orders.values())
        total_items = sum(len(o.items) for orders in user_orders.values() for o in orders)
        print(f"\n[dry-run] Would insert {len(users)} users, {total_orders:,} orders, {total_items:,} items")
        return

    print("\n[INFO] Inserting into database...")

    # Insert users → get IDs
    insert_users(conn, users)

    # Bind user IDs to orders, flatten
    all_orders: list[Order] = []
    for idx, user in enumerate(users):
        for order in user_orders[idx]:
            order.user_id = user.db_id  # type: ignore[assignment]
            all_orders.append(order)

    # Insert orders → get IDs
    insert_orders(conn, all_orders)

    # Bind order IDs to items, flatten
    all_items: list[OrderItem] = []
    for order in all_orders:
        for item in order.items:
            item.order_id = order.db_id
            all_items.append(item)

    insert_order_items(conn, all_items)

    print("\n[INFO] Computing weekly metrics...")
    all_metrics: list[WeeklyMetrics] = []
    for user in users:
        user_order_list = [o for o in all_orders if o.user_id == user.db_id]
        all_metrics.extend(compute_metrics(user, user_order_list))

    insert_metrics(conn, all_metrics)

    validate_and_print(conn)
    if conn:
        conn.close()


if __name__ == "__main__":
    main()
