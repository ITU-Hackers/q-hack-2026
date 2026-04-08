<div align="center">
  <h1>🛒 Picky</h1>
  <p><strong>AI-powered shopping agent for Picnic</strong></p>
  <p>
    Built at <a href="https://qsummit.de">Q-Summit</a> · Mannheim University Hackathon
  </p>
  <br />
</div>

---

## What is Picky?

**Picky** is an AI agent built for [Picnic](https://picnic.app/de/) — Germany's smart online supermarket. Picky acts as an intelligent shopping companion that understands natural language, learns your preferences, and helps you build the perfect grocery basket with zero friction.

Whether you're asking _"What can I cook tonight with what's on sale?"_ or _"Reorder my usual weekend essentials"_ — Picky has you covered.

> Built in 24 hours at **Q Summit**, the innovation & entrepreneurship conference at the University of Mannheim.

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

## Team

| Name                          | Mail           |
|-------------------------------|----------------|
| Dara Georgieva                | <dage@itu.dk>  |
| Johan Schmidt                 | <jhsc@itu.dk>  |
| Kasper Jønsson                | <kasjo@itu.dk> |
| Karl Theodor Ruby Schmidt     | <krub@itu.dk>  |
| Lukas Shagashvili-Johannessen | <lush@itu.dk>  |

Built with ❤️ at **Q Summit Hackathon** · University of Mannheim

---
