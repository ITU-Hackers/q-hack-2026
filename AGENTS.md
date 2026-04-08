# AGENTS.md

## Product context

Picky — ITU Hackers @ Q-Summit Hackathon 2026 (Picnic case: make the shopping experience effortless).

## Repo structure

This is a **Turborepo + pnpm monorepo** with a **Cargo workspace** for Rust.

```
/
├── services/
│   ├── picky-app/     # Next.js frontend (App Router) — primary UI
│   ├── picky/         # Rust/Axum backend API
│   └── dagster/       # Python data pipeline
├── packages/
│   ├── ui/            # Shared React component library (@workspace/ui)
│   └── typescript-config/  # Shared TS config
├── crates/
│   ├── picky-axum/    # Shared Axum utilities
│   └── picky-utils/   # Shared Rust utilities
├── turbo.json
├── pnpm-workspace.yaml
└── Cargo.toml
```

Work in the sub-project that matches your task. Do **not** edit unrelated sub-projects unless the task explicitly says so.

## Stack

| Layer | Technology |
|---|---|
| Frontend | Next.js 16 (App Router) + TypeScript, in `services/picky-app/` |
| Shared UI | `@workspace/ui` package in `packages/ui/` — shadcn components built on **Base UI** |
| Styling | Tailwind CSS v4 |
| Backend | Rust + Axum, in `services/picky/` |
| Pipeline | Python + Dagster, in `services/dagster/` |
| Package manager | pnpm (Node), Cargo (Rust) |
| Linter/formatter | Biome (JS/TS), Clippy (Rust) |

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

Always use `pnpm` for Node — never `npm` or `yarn`.

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
import { Dialog } from "@base-ui/react/dialog"
```
Do **not** import from `@radix-ui/*`. Base UI's API differs from Radix (e.g. `Dialog.Popup` vs `Dialog.Content`, `render` prop instead of `asChild`). When in doubt, check an existing `packages/ui/src/components/*` file for the pattern, or consult https://base-ui.com.

**Portal/layout caveat:** If the app root does not already have `isolation: isolate`, add it when introducing Dialog, Popover, Menu, or any other component that portals content.

## Conventions

### TypeScript / React
- Server Components by default in `services/picky-app/`; add `"use client"` only when you need state, effects, or browser APIs.
- Use the `cn()` helper from `@workspace/ui/lib/utils` for conditional classes.
- Path alias `@/*` maps to the `services/picky-app/` root — prefer it over relative imports within that service.
- Tailwind only; no CSS modules or styled-components.
- Follow existing file/folder casing and component structure rather than inventing new patterns.

### Rust
- Follow existing module layout in `crates/` and `services/picky/`.
- `unwrap_used` is denied by Clippy — use `?` or proper error handling.

## Keeping AGENTS.md up to date

After any significant change (new dependencies, changed commands, restructured folders, new conventions), update this file to reflect the current state. It is the primary source of context for agents working in this repo — stale instructions cause mistakes.

## Before finishing
1. Inspect existing files before creating new ones — prefer the smallest change that works.
2. Do not add dependencies without first checking whether the functionality already exists in the project.
3. For JS/TS changes: run `pnpm lint && pnpm typecheck && pnpm build` from the relevant package or repo root. Fix everything you introduced.
4. For Rust changes: run `cargo clippy && cargo build`. Fix all warnings you introduced.
5. Do not commit `.next/`, `node_modules/`, `target/`, or `.env*`.
6. If you hit a blocker you cannot resolve, report it clearly rather than working around it silently.
