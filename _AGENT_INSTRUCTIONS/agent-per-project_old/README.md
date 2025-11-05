# Agent (Per-Project)

This directory lives inside your app repo and captures project-specific context.
Mount the shared repo at `agent/_shared` or similar.

## Canonical Index

| Folder | Purpose | Canonical docs |
| --- | --- | --- |
| `00-project/` | Entry points and global context | [`overview.md`](00-project/overview.md), [`data-locations.md`](00-project/data-locations.md), [`aggregate-boundaries.md`](00-project/aggregate-boundaries.md), [`architecture-overview.md`](00-project/architecture-overview.md), [`env-and-secrets.md`](00-project/env-and-secrets.md) |
| `05-databases/` | Database locations & access patterns | 🚨 **[`overlay-database-independence.md`](05-databases/overlay-database-independence.md)** (READ FIRST), [`README.md`](05-databases/README.md), [`addressbook-path-resolution.md`](05-databases/addressbook-path-resolution.md) |
| `10-features/` | Completed feature documentation | [`navigation-overview.md`](10-features/navigation-overview.md), [`chats/overview.md`](10-features/chats/overview.md), [`messages/overview.md`](10-features/messages/overview.md) |
| `20-new-features/` | **Active feature development** | [`README.md`](20-new-features/README.md) — See [Workflow Guide](../agent-instructions-shared/50-ai-workflow/feature-development-workflow.md) |
| `30-migrations/` | Schema history and playbooks | [`migration-playbook.md`](30-migrations/migration-playbook.md), [`schema-history.md`](30-migrations/schema-history.md), [`schema-reference.md`](30-migrations/schema-reference.md), [`migration-orchestrator.md`](30-migrations/migration-orchestrator.md) |
| `40-decisions/` | Architectural decisions | [`ADR-0001-riverpod-codegen-only.md`](40-decisions/ADR-0001-riverpod-codegen-only.md) |
| `50-integration/` | External services and pipelines | [`services-and-keys.md`](50-integration/services-and-keys.md), [`pipelines.md`](50-integration/pipelines.md), [`import-orchestrator.md`](50-integration/import-orchestrator.md), [`rust-message-extractor.md`](50-integration/rust-message-extractor.md) |
| `90-local/` | Personal scratchpads | [`scratchpad.md`](90-local/scratchpad.md), [`TODO.md`](90-local/TODO.md) |

## Recommended Layout

- `00-project/` — overview, data locations, env setup, aggregate boundaries, architecture
- `05-databases/` — database schemas, access patterns, import/working DB separation
- `10-features/` — **completed feature documentation** (user-facing docs, architecture notes)
- `20-new-features/` — **active feature development** (proposals, checklists, design notes)
- `30-migrations/` — schema history and playbooks
- `40-decisions/` — ADRs for this project
- `50-integration/` — services, pipelines, import/export
- `90-local/` — scratch notes

## Feature Development Workflow

New features should follow the systematic workflow documented in [`../agent-instructions-shared/50-ai-workflow/feature-development-workflow.md`](../agent-instructions-shared/50-ai-workflow/feature-development-workflow.md):

1. **Proposal** in `20-new-features/{feature-name}/PROPOSAL.md`
2. **Planning** with `CHECKLIST.md`, `DESIGN_NOTES.md`, `TESTS.md`
3. **Implementation** with live checklist updates
4. **Completion** with documentation in `10-features/{feature-name}/`

See [`20-new-features/README.md`](20-new-features/README.md) for active feature tracking.
