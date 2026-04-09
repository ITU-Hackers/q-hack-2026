<div align="center">
  <h1>Picky</h1>
  <p><strong>Personalized meal & grocery recommendations for Picnic</strong></p>
  <p>
    Q-Summit · Mannheim University Hackathon
  </p>
  <br />
</div>

---

## What is Picky?

**Picky** is a personalized meal and grocery recommendation system built for [Picnic](https://picnic.app/de/). It learns your dietary preferences, cuisine tastes, and cooking habits — then surfaces recipes and products tailored to you, powered by a trained ML model running at inference time.

> Built in 24 hours at **Q-Summit**, the innovation & entrepreneurship conference at the University of Mannheim.

---

## Features

- 🤖 **ML-Powered Recommendations** — A trained MLP user-tower maps your 128-dim profile vector to a shared embedding space with recipes, enabling personalized suggestions at inference time
- 🥗 **Semantic Recipe & Product Search** — Recipes are embedded via food2vec (100-dim ingredient mean-pooling) and stored in Qdrant for fast nearest-neighbour retrieval
- 👤 **User Profiling** — Dietary restrictions, cuisine preferences, cooking habits, and budget are encoded into a fixed-size feature vector that drives all personalization
- 🔄 **Dagster ML Pipelines** — Automated pipelines handle synthetic data generation, feature engineering, model training, and ONNX export to S3 for cross-language inference

---

## Tech Stack

### Services

| Service                  | Description                          | Stack                              |
| ------------------------ | ------------------------------------ | ---------------------------------- |
| `services/picky-app`     | User-facing web interface (PWA)      | Next.js 16, React 19, Tailwind CSS |
| `services/picky-api`     | Core AI agent & REST API backend     | Rust + Axum                        |
| `services/picky-recs`    | ML pipelines & recommendation assets | Python + Dagster                   |
| `services/dagster`       | Dagster webserver & daemon           | Docker                             |

### Infrastructure

| Component         | Purpose                                     | Port(s)               |
| ----------------- | ------------------------------------------- | --------------------- |
| **PostgreSQL 17** | Primary relational database                 | 5432                  |
| **Qdrant**        | Vector database for semantic product search | 6333, 6334            |
| **MongoDB 8**     | Document store                              | 27017                 |
| **MinIO**         | S3-compatible object storage                | 9000 (API), 9001 (UI) |

### Monorepo Tooling

- **Turborepo** — Monorepo task orchestration with caching
- **pnpm** — Fast, disk-efficient package manager
- **Biome** — Linting & formatting for TypeScript
- **uv** — Python dependency management

---

## Getting Started

### Prerequisites

- [Node.js](https://nodejs.org/) >= 24
- [pnpm](https://pnpm.io/) >= 10
- [Rust](https://rustup.rs/) (latest stable)
- [uv](https://docs.astral.sh/uv/) (Python package manager)
- [Docker](https://www.docker.com/) & Docker Compose

### 1. Start the infrastructure

```sh
docker compose up -d
```

This starts PostgreSQL, Qdrant, MongoDB, MinIO, and the Dagster stack locally.

### 2. Seed Qdrant recipe embeddings (first-time only)

The Qdrant `recipes` collection lives in a local Docker volume and must be seeded once per machine.

**Option A — Dagster UI** (recommended): open [http://localhost:3009](http://localhost:3009), go to **Assets**, select `recipe_collection` and `recipe_vectors`, and click **Materialize**.

**Option B — CLI:**

```sh
cd services/picky-recs
uv run dagster asset materialize --select "recipe_collection,recipe_vectors"
```

### 3. Install frontend dependencies

```sh
pnpm install
```

### 4. Run the development servers

**All services (via Turborepo):**

```sh
pnpm dev
```

**Frontend only:**

```sh
cd services/picky-app && pnpm dev
```

**Backend only (`services/picky-api/`):**

```sh
cargo run --bin picky-api
```

**Python pipelines only:**

```sh
cd services/picky-recs
uv run dagster dev
```

The web app is available at [http://localhost:3000](http://localhost:3000) and the Dagster UI at [http://localhost:3009](http://localhost:3009).

---

## ML Data Pipeline

Synthetic training data and customer vectors are managed as **Dagster assets** in `services/picky-recs`. Materialize them from the Dagster UI at [http://localhost:3009](http://localhost:3009) or via the CLI:

```sh
cd services/picky-recs
uv run dagster asset materialize --select "*"
```

### Customer vectors script

A standalone script also exists for generating 128-dim profile vectors outside of Dagster:

```sh
python scripts/generate_customer_vectors.py \
  --db-url "postgresql://picky:Password123@localhost:5432/primary"
```

Optional flags: `--clear-existing`, `--dry-run`

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
