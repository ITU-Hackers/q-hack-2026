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