---
tier: project
scope: index
owner: agent-per-project
last_reviewed: 2025-11-06
source_of_truth: doc
links:
  - ../agent-instructions-shared/INDEX.md
  - ./00-PROJECT/00-overview.md
tests: []
---

# Agent (Per-Project) Index

This directory captures Remember Every Text–specific documentation that complements the shared rules in `agent-instructions-shared/`. Start here before modifying the app or its data pipelines.

> ⚠️ Read `_AGENT_INSTRUCTIONS/agent-instructions-shared/00-global/agent-guardrails.md` before using this index. The guardrails define planning, approval, and diff-scope rules for all agents.

## Canonical Map

| Folder | Purpose | Canonical docs |
| --- | --- | --- |
| `00-PROJECT/` | Entry points and global context | [`00-overview.md`](00-PROJECT/00-overview.md), [`01-aggregate-boundaries.md`](00-PROJECT/01-aggregate-boundaries.md), [`02-architecture-overview.md`](00-PROJECT/02-architecture-overview.md), [`03-data-locations.md`](00-PROJECT/03-data-locations.md), [`04-env-and-secrets.md`](00-PROJECT/04-env-and-secrets.md) |
| `10-DATABASES/` | Database locations, contracts, and access patterns | [`00-all-databases-accessed.md`](10-DATABASES/00-all-databases-accessed.md), [`05-db-overlay.md`](10-DATABASES/05-db-overlay.md), [`06-addressbook-path-resolution.md`](10-DATABASES/06-addressbook-path-resolution.md), [`11-contact-to-chat-linking.md`](10-DATABASES/11-contact-to-chat-linking.md) |
| `20-DATA-IMPORT-MIGRATION/` | Ledger importers, migrators, and Rust extractor docs | [`01-overview.md`](20-DATA-IMPORT-MIGRATION/01-overview.md), [`10-import-orchestrator.md`](20-DATA-IMPORT-MIGRATION/10-import-orchestrator.md), [`20-migration-orchestrator.md`](20-DATA-IMPORT-MIGRATION/20-migration-orchestrator.md) |
| `30-NEW-FEATURE-ADDITION/` | Active feature proposals, checklists, and design notes | [`README.md`](30-NEW-FEATURE-ADDITION/README.md), [`manual-handle-to-contact-linking/PROPOSAL.md`](30-NEW-FEATURE-ADDITION/manual-handle-to-contact-linking/PROPOSAL.md) |
| `40-FEATURES/` | Shipped feature documentation with reusable templates | [`README.md`](40-FEATURES/README.md), `*/CHARTER.md`, `*/DOMAIN_AND_DATA_MAP.md`, `*/STATE_AND_PROVIDER_INVENTORY.md`, `*/INTERACTIONS_AND_NAVIGATION.md`, `*/TESTING_AND_MONITORING.md`, `*/WORK_LOG.md` |
| `50-USE-CASE-ILLUSTRATIONS/` | Narrative walkthroughs of cross-layer behaviour | [`README.md`](50-USE-CASE-ILLUSTRATIONS/README.md), [`manual-handle-to-contact-linking.md`](50-USE-CASE-ILLUSTRATIONS/manual-handle-to-contact-linking.md) |
| `60-NAVIGATION/` | ViewSpec-based navigation patterns and panel coordination | [`navigation-overview.md`](60-NAVIGATION/navigation-overview.md) |

## Workflow Expectations

1. **Read shared standards first.** Start with the guardrails in `_AGENT_INSTRUCTIONS/agent-instructions-shared/00-global/agent-guardrails.md`, then follow `_AGENT_INSTRUCTIONS/agent-instructions-shared/INDEX.md` for lint, Riverpod, and architecture rules.
2. **Use these docs when planning work.** Every feature proposal, migration, or provider change should reference the relevant per-project doc before editing code.
3. **Keep metadata current.** Update the `last_reviewed` field whenever a document is edited and ensure links stay valid when files move.
4. **Retire `_agent-per-project_old/` references.** If you find a pointer back to the legacy tree, migrate the content or update the link in this structure.

Maintaining this index keeps new contributors oriented and ensures automation can scaffold future projects from a consistent layout.
