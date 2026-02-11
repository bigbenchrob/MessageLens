---
tier: project
scope: index
owner: agent-per-project
last_reviewed: 2026-01-19
source_of_truth: doc
links:
  - ../agent-instructions-shared/INDEX.md
  - ./00-PROJECT/00-overview.md
tests: []
---

# Agent (Per-Project) Index

This directory captures Remember Every Text–specific documentation that complements the shared rules in `agent-instructions-shared/`. Start here before modifying the app or its data pipelines.

> ⚠️ Read `_AGENT_INSTRUCTIONS/agent-instructions-shared/00-global/agent-guardrails.md` before using this index. The guardrails define planning, approval, and diff-scope rules for all agents.

## 🔥 Quick Facts

| Fact | Detail |
|------|--------|
| **Auto-sync enabled** | `ChatDbChangeMonitor` polls `chat.db` every **15 seconds** and auto-imports new messages |
| **Manual import rarely needed** | Only for initial setup or recovery; ongoing sync is automatic |
| **New messages appear in ~15-20s** | After arrival in macOS Messages, no user action required |
| **Provider** | `chatDbChangeMonitorProvider` in `lib/essentials/db_importers/application/monitor/` |

## Canonical Map

| Folder | Purpose | Canonical docs |
| --- | --- | --- |
| `00-PROJECT/` | Entry points and global context | [`00-overview.md`](00-PROJECT/00-overview.md), [`01-aggregate-boundaries.md`](00-PROJECT/01-aggregate-boundaries.md), [`02-architecture-overview.md`](00-PROJECT/02-architecture-overview.md), [`03-data-locations.md`](00-PROJECT/03-data-locations.md), [`04-env-and-secrets.md`](00-PROJECT/04-env-and-secrets.md) |
| `10-DATABASES/` | Database locations, contracts, and access patterns | [`00-all-databases-accessed.md`](10-DATABASES/00-all-databases-accessed.md), [`05-db-overlay.md`](10-DATABASES/05-db-overlay.md), [`06-addressbook-path-resolution.md`](10-DATABASES/06-addressbook-path-resolution.md), [`11-contact-to-chat-linking.md`](10-DATABASES/11-contact-to-chat-linking.md) |
| `20-DATA-IMPORT-MIGRATION/` | Ledger importers, migrators, Rust extractor, **and auto-sync polling**. **🔥 Messages auto-import every 15 seconds via `ChatDbChangeMonitor`**. For `attributedBody` decoding, see [`apple-typedstream-format-reference.md`](20-DATA-IMPORT-MIGRATION/apple-typedstream-format-reference.md) | [`01-overview.md`](20-DATA-IMPORT-MIGRATION/01-overview.md), [`10-import-orchestrator.md`](20-DATA-IMPORT-MIGRATION/10-import-orchestrator.md), [`20-migration-orchestrator.md`](20-DATA-IMPORT-MIGRATION/20-migration-orchestrator.md), [`apple-typedstream-format-reference.md`](20-DATA-IMPORT-MIGRATION/apple-typedstream-format-reference.md) |
| `30-NEW-FEATURE-ADDITION/` | Active feature proposals, checklists, and design notes | [`README.md`](30-NEW-FEATURE-ADDITION/README.md), [`manual-handle-to-contact-linking/PROPOSAL.md`](30-NEW-FEATURE-ADDITION/manual-handle-to-contact-linking/PROPOSAL.md) |
| `40-FEATURES/` | Shipped feature documentation with reusable templates | [`README.md`](40-FEATURES/README.md), [`contact-favourites/RECENTS-FAVORITES.md`](40-FEATURES/contact-favourites/RECENTS-FAVORITES.md), `*/CHARTER.md`, `*/DOMAIN_AND_DATA_MAP.md`, `*/STATE_AND_PROVIDER_INVENTORY.md`, `*/INTERACTIONS_AND_NAVIGATION.md`, `*/TESTING_AND_MONITORING.md`, `*/WORK_LOG.md` |
| `50-CROSS-SURFACE-SPEC-SYSTEMS-OVERVIEW/` | **🔥 CRITICAL**: How sealed spec classes coordinate UI across all surfaces (sidebar, panels, future tooltips) | [`README.md`](50-CROSS-SURFACE-SPEC-SYSTEMS-OVERVIEW/README.md), [`00-cross-surface-spec-system.md`](50-CROSS-SURFACE-SPEC-SYSTEMS-OVERVIEW/00-cross-surface-spec-system.md), [`INVIOLATE_RULES.md`](50-CROSS-SURFACE-SPEC-SYSTEMS-OVERVIEW/INVIOLATE_RULES.md) |
| `52-FEATURE-HANDLING-OF-X-SURFACE-SPECS/` | Universal coordinator → resolver → widget_builder pattern for all surfaces | [`README.md`](52-FEATURE-HANDLING-OF-X-SURFACE-SPECS/README.md), [`00-universal-spec-handling-pattern.md`](52-FEATURE-HANDLING-OF-X-SURFACE-SPECS/00-universal-spec-handling-pattern.md), [`INVIOLATE_RULES.md`](52-FEATURE-HANDLING-OF-X-SURFACE-SPECS/INVIOLATE_RULES.md) |
| `54-SIDEBAR-CASSETTE-SPEC-SYSTEM/` | Sidebar cassette rack state, cascade topology, card chrome, CassetteWidgetCoordinator dispatch | [`README.md`](54-SIDEBAR-CASSETTE-SPEC-SYSTEM/README.md), [`00-cassette-system-architecture.md`](54-SIDEBAR-CASSETTE-SPEC-SYSTEM/00-cassette-system-architecture.md), [`INVIOLATE_RULES.md`](54-SIDEBAR-CASSETTE-SPEC-SYSTEM/INVIOLATE_RULES.md) |
| `56-VIEW-SPEC-PANEL-CONTENT-SYSTEM/` | ViewSpec panel navigation, PanelStack, PanelCoordinator, feature dispatch | [`README.md`](56-VIEW-SPEC-PANEL-CONTENT-SYSTEM/README.md), [`00-view-spec-panel-architecture.md`](56-VIEW-SPEC-PANEL-CONTENT-SYSTEM/00-view-spec-panel-architecture.md), [`INVIOLATE_RULES.md`](56-VIEW-SPEC-PANEL-CONTENT-SYSTEM/INVIOLATE_RULES.md) |
| `90-USE-CASE-ILLUSTRATIONS/` | Narrative walkthroughs of cross-layer behaviour | [`README.md`](90-USE-CASE-ILLUSTRATIONS/README.md), [`manual-handle-to-contact-linking.md`](90-USE-CASE-ILLUSTRATIONS/manual-handle-to-contact-linking.md) |

## Workflow Expectations

1. **Read shared standards first.** Start with the guardrails in `_AGENT_INSTRUCTIONS/agent-instructions-shared/00-global/agent-guardrails.md`, then follow `_AGENT_INSTRUCTIONS/agent-instructions-shared/INDEX.md` for lint, Riverpod, and architecture rules.
2. **Use these docs when planning work.** Every feature proposal, migration, or provider change should reference the relevant per-project doc before editing code.
3. **Keep metadata current.** Update the `last_reviewed` field whenever a document is edited and ensure links stay valid when files move.
4. **Retire `_agent-per-project_old/` references.** If you find a pointer back to the legacy tree, migrate the content or update the link in this structure.
5. **Reference cross-surface patterns.** When designing new essentials systems (onboarding, tooltips, help, etc.), read `50-CROSS-SURFACE-SPEC-SYSTEMS-OVERVIEW/` and `52-FEATURE-HANDLING-OF-X-SURFACE-SPECS/` to apply the proven routing and responsibility pattern. This keeps systems independent and prevents feature code from polluting global space.

Maintaining this index keeps new contributors oriented and ensures automation can scaffold future projects from a consistent layout.
