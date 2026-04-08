<div align="center">
  <h1>🛒 Picky</h1>
  <p><strong>AI-powered shopping agent for Picnic</strong></p>
  <p>
    Q-Summit · Mannheim University Hackathon
  </p>
  <br />
</div>

---

## What is Picky?

**Picky** is an AI agent built for [Picnic](https://picnic.app/de/) — Germany's smart online supermarket. Picky acts as an intelligent shopping companion that understands natural language, learns your preferences, and helps you build the perfect grocery basket with zero friction.

Whether you're asking _"What can I cook tonight with what's on sale?"_ or _"Reorder my usual weekend essentials"_ — Picky has you covered.

> Built in 24 hours at **Q-Summit**, the innovation & entrepreneurship conference at the University of Mannheim.

---

## Features

- 🧠 **Conversational Shopping** — Chat naturally to find products, get recommendations, and build your cart
- 🔍 **Semantic Search** — Powered by vector embeddings so you find what you mean, not just what you type
- 🔄 **Smart Reordering** — Remembers your habits and suggests reorders at the right time
- 📦 **Inventory Awareness** — Always knows what's in stock and what's on promotion
- ⚡ **Real-time Pipelines** — Live data ingestion keeps product info fresh

---

## Tech Stack

### Services

| Service         | Description                 | Stack                              |
| --------------- | --------------------------- | ---------------------------------- |
| `svc/picky`     | Core AI agent & API backend | Rust                               |
| `svc/picky-app` | User-facing web interface   | Next.js 16, React 19, Tailwind CSS |

### Infrastructure

| Component         | Purpose                                     |
| ----------------- | ------------------------------------------- |
| **PostgreSQL 17** | Primary relational database                 |
| **Qdrant**        | Vector database for semantic product search |

### Monorepo Tooling

- **Turborepo** — Monorepo task orchestration with caching
- **pnpm** — Fast, disk-efficient package manager
- **Biome** — Linting & formatting for TypeScript

---

## Project Structure

```
picky/
├── svc/
│   ├── picky/              # Rust backend — AI agent core & REST API
│   │   └── src/
│   │       └── main.rs
│   └── picky-app/          # Next.js frontend — chat UI & dashboard
│       ├── app/
│       ├── components/
│       ├── hooks/
│       └── lib/
├── packages/
│   ├── ui/                 # Shared component library (shadcn/ui)
│   └── typescript-config/  # Shared TypeScript configurations
├── docker-compose.yml      # Full local infrastructure stack
├── turbo.json              # Turborepo pipeline config
└── pnpm-workspace.yaml     # Workspace definitions
```

---

## Getting Started

### Prerequisites

- [Node.js](https://nodejs.org/) >= 24
- [pnpm](https://pnpm.io/) >= 10
- [Rust](https://rustup.rs/) (latest stable)
- [Docker](https://www.docker.com/) & Docker Compose

### 1. Start the infrastructure

```sh
docker compose up -d
```

This starts PostgreSQL and Qdrant locally.

### 2. Install frontend dependencies

```sh
pnpm install
```

### 3. Run the development servers

**Frontend (Next.js):**

```sh
pnpm dev
```

**Backend (Rust):**

```sh
cargo run --bin picky
```

The web app will be available at [http://localhost:3000](http://localhost:3000).

---

## Synthetic Training Data

The `scripts/generate_synthetic_users.py` script populates PostgreSQL with 300 synthetic Picnic user profiles and 52 weeks of order history for ML model training.

### Prerequisites

- Docker infrastructure running (`docker compose up -d`)
- [uv](https://docs.astral.sh/uv/) installed

### Generate the data

```sh
python -m uv run --with psycopg2-binary python scripts/generate_synthetic_users.py \
  --seed 42 \
  --db-url "postgresql://picky:Password123@localhost:5432/primary" \
  --clear-existing

# If you have `uv` on your PATH, this also works:
uv run --directory services/picky-recs python scripts/generate_synthetic_users.py \
  --seed 42 \
  --db-url "postgresql://picky:Password123@localhost:5432/primary" \
  --clear-existing
```

| Flag | Default | Description |
|---|---|---|
| `--seed` | `42` | RNG seed for reproducibility |
| `--db-url` | `postgresql://picky:Password123@localhost:5432/primary` | PostgreSQL connection URL |
| `--users-per-archetype` | `75` | Users per archetype (300 total) |
| `--clear-existing` | off | Drop and recreate tables before inserting |
| `--dry-run` | off | Generate data in memory, skip DB writes |

### Schema

Four tables are created in the `primary` database:

| Table | Description |
|---|---|
| `synthetic_users` | Static user profiles (archetype, household, dietary, budget) |
| `orders` | Weekly orders with spend, basket size, and contextual signals |
| `order_items` | Individual line items with product, category, quantity, price |
| `user_weekly_metrics` | Pre-computed ML feature vectors per user per week |

### User archetypes

| Archetype | Weekly spend | Key behaviour |
|---|---|---|
| `budget_student` | €25–50 | Regular Sunday orders, protein-heavy, month-end spend drop |
| `big_family` | €70–100 | Large baskets, high variety, occasional skipped weeks |
| `gym_goer` | €50–90 | Irregular schedule, 60% protein spend |
| `vegetarian_couple` | €60–90 | No meat products, meal-plan oriented |

### Reset the database

To wipe all synthetic data and start fresh:

```sh
python -m uv run --with psycopg2-binary python scripts/generate_synthetic_users.py \
  --seed 42 \
  --db-url "postgresql://picky:Password123@localhost:5432/primary" \
  --clear-existing

# If you have `uv` on your PATH, this also works:
uv run --directory services/picky-recs python scripts/generate_synthetic_users.py \
  --seed 42 \
  --db-url "postgresql://picky:Password123@localhost:5432/primary" \
  --clear-existing
```

Use a different `--seed` to get a different (but still reproducible) dataset.

### Using the data for model training

Query `user_weekly_metrics` joined with `synthetic_users` to get feature vectors:

```python
import pandas as pd
import psycopg2

conn = psycopg2.connect("postgresql://picky:Password123@localhost:5432/primary")

df = pd.read_sql("""
    SELECT m.*, u.archetype, u.budget_tier, u.household_type
    FROM user_weekly_metrics m
    JOIN synthetic_users u ON u.id = m.user_id
    WHERE m.weekly_spend_cents > 0
""", conn)
```

Key feature columns: `loyalty_staples_fraction`, `spend_trend`, `budget_util_rate`, `order_interval_consistency`, `protein_fraction`, `dairy_fraction`, `carbs_fraction`, `vegetables_fraction`, `snacks_fraction`, `pantry_depletion` (JSONB).

---

## Customer Vectors (128-dim)

The `scripts/generate_customer_vectors.py` script derives **one fixed-size 128-dimensional vector per user** from the existing synthetic tables and stores it in PostgreSQL.

It writes to:

- `user_profile_vectors` (one row per `synthetic_users.id`)
- `vector` is stored as `FLOAT8[]`

### Generate customer vectors

```sh
python -m uv run --with psycopg2-binary python scripts/generate_customer_vectors.py \
  --db-url "postgresql://picky:Password123@localhost:5432/primary"
```

Optional flags:

- `--clear-existing` drops and recreates the `user_profile_vectors` table first
- `--dry-run` computes vectors but skips DB writes

---

## Connect with DBeaver (PostgreSQL)

To inspect the generated data locally in DBeaver, create a new PostgreSQL connection with:

- **Host:** `localhost`
- **Port:** `5432`
- **Database:** `primary`
- **Username:** `picky`
- **Password:** `Password123`
- **SSL:** disabled / prefer (default) unless you configured it otherwise

If the connection fails, ensure infrastructure is running:

```sh
docker compose up -d
```

---

## Team

| Name                          | Mail           |
|-------------------------------|----------------|
| Dara Georgieva                | <dage@itu.dk>  |
| Johan Schmidt                 | <jhsc@itu.dk>  |
| Kasper Jønsson                | <kasjo@itu.dk> |
| Karl Theodor Ruby Schmidt     | <krub@itu.dk>  |
| Lukas Shagashvili-Johannessen | <lush@itu.dk>  |

Built with ❤️ at **Q-Summit Hackathon** · University of Mannheim

---
