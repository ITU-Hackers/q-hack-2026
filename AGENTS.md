# AGENTS.md

## Product context

Picky — ITU Hackers @ Q-Summit Hackathon 2026 (Picnic case: make the shopping experience effortless).

## Repo structure

This is a **Turborepo + pnpm monorepo** with a **Cargo workspace** for Rust and a **uv workspace** for Python.

```
/
├── services/
│   ├── picky-app/     # Next.js frontend (App Router) — primary UI
│   ├── picky/         # Rust/Axum backend API
│   ├── dagster/       # Dagster webserver + daemon infra (Dockerfile, workspace.yaml)
│   └── picky-recs/    # Python Dagster code location — ML pipelines & assets
├── packages/
│   ├── ui/            # Shared React component library (@workspace/ui)
│   └── typescript-config/  # Shared TS config
├── crates/
│   ├── picky-axum/    # Shared Axum utilities
│   └── picky-utils/   # Shared Rust utilities
├── turbo.json
├── pnpm-workspace.yaml
├── pyproject.toml     # uv workspace root (members: services/picky-recs)
├── Cargo.toml
└── docker-compose.yml
```

Work in the sub-project that matches your task. Do **not** edit unrelated sub-projects unless the task explicitly says so.

## Stack

| Layer            | Technology                                                                              |
| ---------------- | --------------------------------------------------------------------------------------- |
| Frontend         | Next.js 16 (App Router) + TypeScript, in `services/picky-app/`                          |
| Shared UI        | `@workspace/ui` package in `packages/ui/` — shadcn components built on **Base UI**      |
| Styling          | Tailwind CSS v4                                                                         |
| Backend          | Rust + Axum, in `services/picky/`                                                       |
| Pipelines        | Python + Dagster, code location in `services/picky-recs/`                               |
| Dagster infra    | `services/dagster/` — Dockerfile and `workspace.yaml` for the webserver and daemon only |
| Package manager  | pnpm (Node), Cargo (Rust), uv (Python)                                                  |
| Linter/formatter | Biome (JS/TS), Clippy (Rust), Ruff (Python)                                             |
| Node version     | >=24                                                                                    |
| pnpm version     | 10.11.0                                                                                 |

## Infrastructure (Docker Compose)

`docker-compose.yml` at the repo root brings up the full stack:

| Service             | Image / Source                   | Port(s)                    |
| ------------------- | -------------------------------- | -------------------------- |
| `postgres`          | postgres:17                      | 5432                       |
| `qdrant`            | qdrant/qdrant                    | 6333, 6334                 |
| `mongodb`           | mongo:8                          | 27017                      |
| `minio`             | minio/minio                      | 9000 (API), 9001 (console) |
| `picky-recs`        | `services/picky-recs/Dockerfile` | 4000 (gRPC code location)  |
| `dagster-webserver` | `services/dagster/Dockerfile`    | 3009 → 3000                |
| `dagster-daemon`    | `services/dagster/Dockerfile`    | —                          |

Start everything with:

```bash
docker compose up -d
```

## Commands

### Root (runs all workspaces via Turbo)

```bash
pnpm dev          # start all dev servers
pnpm build        # build everything
pnpm lint         # lint everything
pnpm typecheck    # typecheck everything
```

### Frontend (`services/picky-app/`)

```bash
pnpm dev          # Next.js dev server with Turbopack
pnpm build        # production build
pnpm lint         # biome lint
pnpm typecheck    # tsc --noEmit
```

### Shared UI (`packages/ui/`)

```bash
pnpm lint
pnpm typecheck
```

### Rust (from repo root or any crate)

```bash
cargo build
cargo clippy
cargo test
```

### Python (from repo root — uv workspace)

```bash
uv run pytest                         # run tests
uv run ruff check services/picky-recs # lint
uv run ruff format services/picky-recs # format
```

To run Dagster locally for development:

```bash
cd services/picky-recs
uv run dagster dev
```

Always use `pnpm` for Node — never `npm` or `yarn`.
Always use `uv` for Python — never `pip` or `poetry`.

## Python workspace

The repo root `pyproject.toml` is a **uv workspace root** (not a package itself). Members:

- `services/picky-recs` — the `picky-recs` Dagster code location

When adding a new Python service, register it in the root `pyproject.toml` under `[tool.uv.workspace] members`.

### picky-recs (`services/picky-recs/`)

A Dagster **code location** that contains ML pipeline assets (recommendations, etc.).

Key files:

- `picky_recs/definitions.py` — exports `defs` (`Definitions`)
- `picky_recs/assets/` — Dagster asset definitions
- `picky_recs/jobs.py`, `schedules.py`, `resources.py` — supporting definitions
- `definitions.py` (root of service) — re-exports `defs` for both `-m picky_recs` and `-f definitions.py` entry points

## shadcn setup and components

Components live in `packages/ui/src/components/`. The shadcn CLI is configured there via `components.json`.

To add a component, run from `packages/ui/`:

```bash
pnpm dlx shadcn@latest add <component>
```

Components land in `packages/ui/src/components/`. Check there before adding — it may already exist.

## Base UI, not Radix

This project uses shadcn's Base UI distribution. Imports look like:

```ts
import { Dialog } from "@base-ui/react/dialog";
```

Do **not** import from `@radix-ui/*`. Base UI's API differs from Radix (e.g. `Dialog.Popup` vs `Dialog.Content`, `render` prop instead of `asChild`). When in doubt, check an existing `packages/ui/src/components/*` file for the pattern, or consult https://base-ui.com.

**Portal/layout caveat:** If the app root does not already have `isolation: isolate`, add it when introducing Dialog, Popover, Menu, or any other component that portals content.

## Conventions

### TypeScript / React

- Server Components by default in `services/picky-app/`; add `"use client"` only when you need state, effects, or browser APIs.
- Use the `cn()` helper from `@workspace/ui/lib/utils` for conditional classes.
- Path alias `@/*` maps to the `services/picky-app/` root — prefer it over relative imports within that service.
- `@workspace/ui/*` maps to `packages/ui/src/*` and is available in both `picky-app` and `ui` packages.
- Tailwind only; no CSS modules or styled-components.
- Follow existing file/folder casing and component structure rather than inventing new patterns.

### Rust

- Follow existing module layout in `crates/` and `services/picky/`.
- `unwrap_used` is denied by Clippy — use `?` or proper error handling.
- `unused_imports`, `unused_variables`, and `dead_code` are currently allowed (early project phase) — do not rely on this long-term.
- Key workspace dependencies: `axum 0.8`, `tokio 1`, `sqlx 0.8`, `mongodb 2.8`, `qdrant-client 1.17`, `rig-core` (AI), `rmcp` (MCP), `utoipa` (OpenAPI).

### Python

- Target Python `>=3.12,<3.14`.
- Use Ruff for linting and formatting.
- Dagster assets go in `services/picky-recs/picky_recs/assets/`.
- Use `uv` for all dependency management — edit `pyproject.toml` in the relevant member, then run `uv lock` from the repo root.

## Keeping AGENTS.md up to date

After any significant change (new dependencies, changed commands, restructured folders, new conventions, new services), update this file to reflect the current state. It is the primary source of context for agents working in this repo — stale instructions cause mistakes.

## Before finishing

1. Inspect existing files before creating new ones — prefer the smallest change that works.
2. Do not add dependencies without first checking whether the functionality already exists in the project.
3. For JS/TS changes: run `pnpm lint && pnpm typecheck && pnpm build` from the relevant package or repo root. Fix everything you introduced.
4. For Rust changes: run `cargo clippy && cargo build`. Fix all warnings you introduced.
5. For Python changes: run `uv run ruff check` and `uv run pytest` where applicable. Fix everything you introduced.
6. Do not commit `.next/`, `node_modules/`, `target/`, `.venv/`, or `.env*`.
7. If you hit a blocker you cannot resolve, report it clearly rather than working around it silently.
