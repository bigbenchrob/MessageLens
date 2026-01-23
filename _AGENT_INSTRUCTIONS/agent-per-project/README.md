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

## Canonical Map

Note: `95-SPEC-INTERPRETATION-AND-CROSS-SURFACE/` is the unified, preferred source
for spec interpretation and cross-surface system guidance. The legacy `80-` and
`90-` folders remain for reference during the transition.

| Folder | Purpose | Canonical docs |
| --- | --- | --- |
| `00-PROJECT/` | Entry points and global context | [`00-overview.md`](00-PROJECT/00-overview.md), [`01-aggregate-boundaries.md`](00-PROJECT/01-aggregate-boundaries.md), [`02-architecture-overview.md`](00-PROJECT/02-architecture-overview.md), [`03-data-locations.md`](00-PROJECT/03-data-locations.md), [`04-env-and-secrets.md`](00-PROJECT/04-env-and-secrets.md) |
| `10-DATABASES/` | Database locations, contracts, and access patterns | [`00-all-databases-accessed.md`](10-DATABASES/00-all-databases-accessed.md), [`05-db-overlay.md`](10-DATABASES/05-db-overlay.md), [`06-addressbook-path-resolution.md`](10-DATABASES/06-addressbook-path-resolution.md), [`11-contact-to-chat-linking.md`](10-DATABASES/11-contact-to-chat-linking.md) |
| `20-DATA-IMPORT-MIGRATION/` | Ledger importers, migrators, and Rust extractor docs. **For questions about message text (`attributedBody`) decoding, see [`apple-typedstream-format-reference.md`](20-DATA-IMPORT-MIGRATION/apple-typedstream-format-reference.md)** | [`01-overview.md`](20-DATA-IMPORT-MIGRATION/01-overview.md), [`10-import-orchestrator.md`](20-DATA-IMPORT-MIGRATION/10-import-orchestrator.md), [`20-migration-orchestrator.md`](20-DATA-IMPORT-MIGRATION/20-migration-orchestrator.md), [`apple-typedstream-format-reference.md`](20-DATA-IMPORT-MIGRATION/apple-typedstream-format-reference.md) |
| `30-NEW-FEATURE-ADDITION/` | Active feature proposals, checklists, and design notes | [`README.md`](30-NEW-FEATURE-ADDITION/README.md), [`manual-handle-to-contact-linking/PROPOSAL.md`](30-NEW-FEATURE-ADDITION/manual-handle-to-contact-linking/PROPOSAL.md) |
| `40-FEATURES/` | Shipped feature documentation with reusable templates | [`README.md`](40-FEATURES/README.md), `*/CHARTER.md`, `*/DOMAIN_AND_DATA_MAP.md`, `*/STATE_AND_PROVIDER_INVENTORY.md`, `*/INTERACTIONS_AND_NAVIGATION.md`, `*/TESTING_AND_MONITORING.md`, `*/WORK_LOG.md` |
| `50-USE-CASE-ILLUSTRATIONS/` | Narrative walkthroughs of cross-layer behaviour | [`README.md`](50-USE-CASE-ILLUSTRATIONS/README.md), [`manual-handle-to-contact-linking.md`](50-USE-CASE-ILLUSTRATIONS/manual-handle-to-contact-linking.md) |
| `60-NAVIGATION/` | ViewSpec-based navigation patterns and panel coordination | [`navigation-overview.md`](60-NAVIGATION/navigation-overview.md) |
| `70-CASSETTE-CONTENT-CONTROL/` | Where UI cassette choices are decided (responsibility boundaries) | [`00-cassette-choice-flow-and-responsibilities.md`](70-CASSETTE-CONTENT-CONTROL/00-cassette-choice-flow-and-responsibilities.md), [`03-cassette-card-design-guidelines.md`](70-CASSETTE-CONTENT-CONTROL/03-cassette-card-design-guidelines.md) |
| `80-FEATURE-SPEC-HANDLING/` | **🔥 CRITICAL**: How features interpret and process specs (ViewSpec, CassetteSpec). Defines layer boundaries, application-layer roles, and multi-surface content support | [`README.md`](80-FEATURE-SPEC-HANDLING/README.md), [`TLDR-for-agents.md`](80-FEATURE-SPEC-HANDLING/TLDR-for-agents.md), [`01-feature-spec-handling-flow.md`](80-FEATURE-SPEC-HANDLING/01-feature-spec-handling-flow.md), [`05-responsibility-boundaries-summary.md`](80-FEATURE-SPEC-HANDLING/05-responsibility-boundaries-summary.md) |
| `90-CROSS-SURFACE-SPEC-SYSTEMS/` | **🔥 CRITICAL**: Architecture pattern for multi-surface systems (onboarding, tooltips, sidebar, etc.). Essentials owns system state & outer routing; features own inner spec interpretation. Prevents feature pollution of global app space. | [`README.md`](90-CROSS-SURFACE-SPEC-SYSTEMS/README.md), [`TLDR-for-agents.md`](90-CROSS-SURFACE-SPEC-SYSTEMS/TLDR-for-agents.md), [`00-principles.md`](90-CROSS-SURFACE-SPEC-SYSTEMS/00-principles.md), [`02-routing-and-ownership.md`](90-CROSS-SURFACE-SPEC-SYSTEMS/02-routing-and-ownership.md), [`EXAMPLE-end-to-end-onboarding-flow.md`](90-CROSS-SURFACE-SPEC-SYSTEMS/EXAMPLE-end-to-end-onboarding-flow.md) |
| `95-SPEC-INTERPRETATION-AND-CROSS-SURFACE/` | **🔥 CRITICAL**: Unified spec interpretation + cross-surface systems. Canonical flow, ownership boundaries, sidebar contract, templates, and failure modes. | [`README.md`](95-SPEC-INTERPRETATION-AND-CROSS-SURFACE/README.md), [`00-overview-and-goals.md`](95-SPEC-INTERPRETATION-AND-CROSS-SURFACE/00-overview-and-goals.md), [`02-sidebar-cassette-spec-to-widget-contract.md`](95-SPEC-INTERPRETATION-AND-CROSS-SURFACE/02-sidebar-cassette-spec-to-widget-contract.md), [`03-cross-surface-spec-systems.md`](95-SPEC-INTERPRETATION-AND-CROSS-SURFACE/03-cross-surface-spec-systems.md), [`TLDR-for-agents.md`](95-SPEC-INTERPRETATION-AND-CROSS-SURFACE/TLDR-for-agents.md) |

## Workflow Expectations

1. **Read shared standards first.** Start with the guardrails in `_AGENT_INSTRUCTIONS/agent-instructions-shared/00-global/agent-guardrails.md`, then follow `_AGENT_INSTRUCTIONS/agent-instructions-shared/INDEX.md` for lint, Riverpod, and architecture rules.
2. **Use these docs when planning work.** Every feature proposal, migration, or provider change should reference the relevant per-project doc before editing code.
3. **Keep metadata current.** Update the `last_reviewed` field whenever a document is edited and ensure links stay valid when files move.
4. **Retire `_agent-per-project_old/` references.** If you find a pointer back to the legacy tree, migrate the content or update the link in this structure.
5. **Reference cross-surface patterns.** When designing new essentials systems (onboarding, tooltips, help, etc.), read `90-CROSS-SURFACE-SPEC-SYSTEMS/` to apply the proven routing and responsibility pattern. This keeps systems independent and prevents feature code from polluting global space.

Maintaining this index keeps new contributors oriented and ensures automation can scaffold future projects from a consistent layout.
