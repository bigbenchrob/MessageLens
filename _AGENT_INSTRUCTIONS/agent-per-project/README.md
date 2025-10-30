# Agent (Per-Project)

This directory lives inside your app repo and captures project-specific context.
Mount the shared repo at `agent/_shared` or similar.

## Canonical Index

| Folder | Purpose | Canonical docs |
| --- | --- | --- |
| `00-project/` | Entry points and global context | [`overview.md`](00-project/overview.md), [`data-locations.md`](00-project/data-locations.md), [`aggregate-boundaries.md`](00-project/aggregate-boundaries.md), [`env-and-secrets.md`](00-project/env-and-secrets.md) |
| `10-features/` | Per-feature briefs and prompts | [`chats/overview.md`](10-features/chats/overview.md), [`messages/overview.md`](10-features/messages/overview.md) |
| `20-migrations/` | Schema history and playbooks | [`migration-playbook.md`](20-migrations/migration-playbook.md), [`schema-history.md`](20-migrations/schema-history.md), [`schema-reference.md`](20-migrations/schema-reference.md) |
| `30-decisions/` | Architectural decisions | [`ADR-0001-riverpod-codegen-only.md`](30-decisions/ADR-0001-riverpod-codegen-only.md) |
| `40-integration/` | External services and pipelines | [`services-and-keys.md`](40-integration/services-and-keys.md), [`pipelines.md`](40-integration/pipelines.md), [`rust-message-extractor.md`](40-integration/rust-message-extractor.md) |
| `90-local/` | Personal scratchpads | [`scratchpad.md`](90-local/scratchpad.md), [`TODO.md`](90-local/TODO.md) |

## Recommended Layout

- `00-project/` — overview, data locations, env setup, aggregate boundaries
- `10-features/` — per-feature briefs, prompts, decisions
- `20-migrations/` — schema history and playbooks
- `30-decisions/` — ADRs for this project
- `40-integration/` — services, pipelines, import/export
- `90-local/` — scratch notes
