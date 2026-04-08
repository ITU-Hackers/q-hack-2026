# AGENTS.md

## Product context

Picky — ITU Hackers @ Q-Summit Hackathon 2026 (Picnic case: make the shopping experience effortless).

## Repo structure

This is a **Turborepo + pnpm monorepo** with a **Cargo workspace** for Rust and a **uv workspace** for Python.

```
/
├── services/
│   ├── picky-app/     # Next.js frontend (App Router, PWA) — primary UI
│   ├── picky-api/     # Rust/Axum backend API
│   ├── dagster/       # Dagster webserver + daemon infra (Dockerfile, workspace.yaml)
│   └── picky-recs/    # Python Dagster code location — ML pipelines & assets
├── packages/
│   ├── ui/            # Shared React component library (@workspace/ui)
│   └── typescript-config/  # Shared TS config
├── crates/
│   ├── picky-axum/    # Shared Axum utilities
│   └── picky-utils/   # Shared Rust utilities
├── docs/              # Project documentation
├── scripts/           # Utility scripts (e.g. init_database.sh)
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
| Frontend         | Next.js 16 (App Router, PWA via Serwist) + TypeScript, in `services/picky-app/`        |
| Shared UI        | `@workspace/ui` package in `packages/ui/` — shadcn components built on **Base UI**      |
| Styling          | Tailwind CSS v4                                                                         |
| Icons            | `@tabler/icons-react` (used in both `picky-app` and `packages/ui`)                      |
| Backend          | Rust + Axum, in `services/picky-api/`                                                   |
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
pnpm format       # format everything
pnpm typecheck    # typecheck everything
```

### Frontend (`services/picky-app/`)

```bash
pnpm dev          # Next.js dev server with Turbopack
pnpm build        # production build (uses webpack)
pnpm lint         # biome lint
pnpm format       # biome format --write
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
- `picky_recs/synthetic_data.py` — synthetic data generation utilities
- `definitions.py` (root of service) — re-exports `defs` for both `-m picky_recs` and `-f definitions.py` entry points

Key dependencies: `dagster`, `dagster-aws`, `dagster-postgres`, `boto3`, `scikit-learn`, `pandas`, `numpy`, `skl2onnx`, `psycopg2-binary`.

## shadcn setup and components

The shadcn CLI is configured in two places:

- **`packages/ui/components.json`** — canonical home for shared components; style is `base-vega`.
- **`services/picky-app/components.json`** — mirrors the same style and points aliases at `@workspace/ui/*`; used when scaffolding app-specific components (hooks, lib utilities) directly inside `picky-app`.

**Always add reusable UI components to `packages/ui/`**, not to `picky-app/components/`.

To add a shared component, run from `packages/ui/`:

```bash
pnpm dlx shadcn@latest add <component>
```

Components land in `packages/ui/src/components/`. Check there before adding — it may already exist.

The `packages/ui` package exports:

```
@workspace/ui/globals.css        → src/styles/globals.css
@workspace/ui/components/<name>  → src/components/<name>.tsx
@workspace/ui/lib/<name>         → src/lib/<name>.ts
@workspace/ui/hooks/<name>       → src/hooks/<name>.ts
```

## Base UI, not Radix

This project uses shadcn's Base UI distribution. Imports look like:

```ts
import { Dialog } from "@base-ui/react/dialog";
```

Do **not** import from `@radix-ui/*`. Base UI's API differs from Radix (e.g. `Dialog.Popup` vs `Dialog.Content`, `render` prop instead of `asChild`). When in doubt, check an existing `packages/ui/src/components/*` file for the pattern, or consult https://base-ui.com.

**Portal/layout caveat:** If the app root does not already have `isolation: isolate`, add it when introducing Dialog, Popover, Menu, or any other component that portals content.

## Frontend app structure (`services/picky-app/`)

The app uses the Next.js App Router with the following layout:

```
app/
├── layout.tsx          # Root layout
├── page.tsx            # Root page (redirect / landing)
├── manifest.ts         # PWA manifest
├── sw.ts               # Serwist service worker entry
└── (app)/              # Authenticated app shell (bottom nav)
    ├── layout.tsx      # App shell layout with bottom navigation bar
    ├── browse/         # Meal browsing page
    ├── cart/           # Shopping cart page
    └── profile/        # User profile page
components/             # App-specific components (non-shared)
hooks/                  # App-specific hooks
lib/                    # App-specific utilities
```

The `(app)` route group renders a fixed bottom navigation bar (Browse / Cart / Profile) and is the primary UI surface. This is a **PWA** — Serwist is integrated via `@serwist/next`. The service worker is disabled in development.

## UI / Layout requirements

**Target form factor: vertical smartphone screen.** The primary users will be on portrait-orientation phones. Every layout, page, and component must work well at narrow widths (360 px–430 px). Specifically:
- Use vertical stacking and full-width elements as the default; horizontal layouts only where they genuinely fit small screens.
- Touch targets must be large enough to tap comfortably (minimum 44 × 44 px).
- Avoid horizontal overflow — no element should cause the page to scroll sideways.
- Test responsive behaviour at 390 px width (iPhone 14 viewport) as the baseline.
- Prioritise content legibility and thumb-reachability in all interaction design decisions.

## Conventions

### TypeScript / React

- Server Components by default in `services/picky-app/`; add `"use client"` only when you need state, effects, or browser APIs.
- Use the `cn()` helper from `@workspace/ui/lib/utils` for conditional classes.
- Path alias `@/*` maps to the `services/picky-app/` root — prefer it over relative imports within that service.
- `@workspace/ui/*` maps to `packages/ui/src/*` and is available in both `picky-app` and `ui` packages.
- Tailwind only; no CSS modules or styled-components.
- Use `@tabler/icons-react` for all icons — do not introduce other icon libraries.
- Follow existing file/folder casing and component structure rather than inventing new patterns.

### Rust

- Follow existing module layout in `crates/` and `services/picky-api/`.
- `unwrap_used` is denied by Clippy — use `?` or proper error handling.
- `unused_imports`, `unused_variables`, and `dead_code` are currently allowed (early project phase) — do not rely on this long-term.
- Key workspace dependencies: `axum 0.8`, `tokio 1`, `sqlx 0.8`, `mongodb 2.8`, `qdrant-client 1.17`, `rig-core` (AI), `rig-qdrant`, `ort` (ONNX Runtime), `rmcp` (MCP), `utoipa` (OpenAPI), `aws-sdk-s3` (MinIO/S3).

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