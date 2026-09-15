---
tier: project
scope: architecture
owner: agent-per-project
last_reviewed: 2026-09-15
source_of_truth: doc
links:
  - ./01-aggregate-boundaries.md
  - ./05-CURRENT-STATE.md
  - ../30-ESSENTIALS/README.md
  - ../40-FEATURES/README.md
  - ../42-SPEC-SYSTEM/README.md
  - ../10-DATABASES/00-all-databases-accessed.md
  - ../20-DATA-IMPORT-MIGRATION/01-overview.md
  - ../20-DATA-IMPORT-MIGRATION/12-bounded-message-import-and-rich-text-enrichment.md
tests: []
---

# Architecture Overview

This document is the project-level architecture map. It describes current
ownership boundaries and points to the authoritative subsystem docs. Do not use
older generic DDD examples as evidence of current code structure.

The canonical description of cross-surface behavior and spec-driven
architecture lives in `../42-SPEC-SYSTEM/`. This document is a high-level map
and must not be used to infer implementation patterns that contradict that
layer.

## Current Code Structure

```text
lib/
├── essentials/                  # App-level systems and shared infrastructure
├── features/                    # Business feature modules and feature content
├── domain_driven_development/   # Shared DDD helpers
├── core/                        # Shared utilities
├── config/                      # Theme/config support
└── constants/                   # Shared constants
```

Current feature modules include `address_book_folders`, `attachments`,
`contacts`, `conversations`, `environment_readiness`, `handles`, `messages`,
`settings`, and `sidebar_utilities`.

Current essentials areas include app mode, navigation, sidebar, search,
onboarding, db, source-scoped import, conversation graph, archive
compatibility, paths, retired storage cleanup/diagnostic boundaries, logging,
window state, config, debug, services, tooltips, and shared contacts
infrastructure.

## Essentials vs Features

Essentials owns app-level orchestration:

- global flow state
- sidebar cassette rack topology and shared sidebar chrome
- panel stack ownership and `ViewSpec` routing
- onboarding gate state and overlay lifecycle
- shared search service and graph search/evidence selection
- database providers, source-scoped import, graph build, and retired-file
  compatibility orchestration
- logging, window state, app shell, and cross-cutting services

Features own domain content:

- feature-owned inner specs
- feature data resolution and repositories
- payloads/view models for approved feature surfaces
- terminal feature rendering inside essentials-owned surface contracts

Current feature boundary highlights:

- `features/conversations` owns user-facing Conversation presentation:
  Conversation cards, signature glyphs, Favourites/Core Favourite affordances,
  Conversation collections, and Conversation excerpt panels.
- `features/messages` owns message evidence surfaces: evidence scopes,
  timeline skeleton/hydration, message headers/search controls, message rows,
  and attachment evidence presentation.
- `essentials/conversation_graph` owns graph projection/build/read facts and
  source-scoped graph identity. It does not own user-facing Conversation
  widgets.
- `essentials/search` owns shared graph search infrastructure and evidence
  selection. Search may request a Conversation excerpt, but Conversation UI is
  rendered by the Conversations feature.

Path location alone does not prove architectural ownership. Some contact-related
logic is shared infrastructure under essentials; other contact-related logic is
feature-owned under `lib/features/contacts`.

## Spec-Driven Surface Architecture

For sidebar, panel, onboarding, and related surfaces, the canonical architecture
is defined under `../42-SPEC-SYSTEM/`.

Canonical pipeline:

```text
Spec → Coordinator → Resolver → Payload / ViewModel → Rendering
```

New work must not introduce widget-returning coordinator patterns or move
rendering logic across the data boundary. Older panel code still has a
documented migration boundary; treat that as transitional, not permission for
new work.

## Data Pipeline

The ordinary app-facing data pipeline is:

```text
macOS Messages + AddressBook
→ macos_import_ss.db
→ working_ss.db / conversation graph
→ provider merge with user_overlays.db
→ specs / payloads / rendering
```

The old `macos_import.db` -> `working.db` projection implementation is
retired from active app code. Archive-source metadata now lives in overlay
storage. Existing `macos_import.db` and `working.db` files are retired
file/schema cleanup inventory for reset cleanup and read-only diagnostics.
Source import, graph build, and retired-file cleanup details belong in
`../20-DATA-IMPORT-MIGRATION/`.
Database boundaries and provider access rules belong in `../10-DATABASES/`.

Within the source-scoped import boundary, source-message copy and rich-text
enrichment are distinct bounded stages. Message copy uses a frozen source-row
high-water mark and keyset pages whose cursor advances only after a page
transaction commits. Rich-text enrichment uses the persisted source-scoped
`ss_id`, a separately frozen candidate frontier, metadata-only pages, and
byte-bounded BLOB fetch/decode subpages. The native typedstream decoder also
enforces per-record input, control-marker, reference-run, nesting, and node
limits. Record-level failures are retained as diagnostic anomalies rather than
suppressed. See
`../20-DATA-IMPORT-MIGRATION/12-bounded-message-import-and-rich-text-enrichment.md`.

For the current project phase and active product/release priorities, see
`./05-CURRENT-STATE.md` and
`../55-READERS-INTEGRATORS-ORCHESTRATORS/85-RELEASE-EXIT-PLAN.md`.

Hard boundaries:

- source-scoped import writes only to `macos_import_ss.db`
- graph projection writes only to `working_ss.db`
- archive-source metadata writes only to overlay-owned services
- user intent writes only to `user_overlays.db`
- providers merge graph projection + overlay at read time

## Onboarding And Archive

Onboarding is essentials-owned orchestration. It evaluates environment
readiness, drives the onboarding overlay lifecycle, coordinates graph build
actions, persists the exact interrupted import/projection substage, and syncs
readiness states into panel surfaces. Its coarse readiness classification and
exact operation snapshot have different responsibilities: the former explains
readiness, while the latter makes a safe `Continue Setup` decision. Retired-file
cleanup storage is not the ordinary onboarding success path.

Attachment archive and deterministic recovery are feature-owned attachment
systems that coordinate with onboarding and the database providers. Archive
metadata lives in overlay; archive files live under the MessageLens app support
directory.

Use `../25-ONBOARDING-AND-ARCHIVE/` for current behavior.

## Naming And Provider Conventions

- Riverpod providers should use project-standard generated-provider patterns.
- `feature_level_providers.dart` files are public seams for external consumers,
  not convenience barrels for code inside the same feature or essential module.
  Internal code must import the exact sibling provider, repository, action,
  model, or type file it depends on. Public provider seams should remain
  export-only.
- External consumers that import a public provider seam must use an explicit
  `show` list. A seam import should advertise exactly which provider, action,
  render builder, or type the file needs; broad seam imports hide authority and
  are treated as architectural drift.
- Public provider seams must not have generated `feature_level_providers.g.dart`
  siblings.
  Generated provider state belongs in named application/provider files.
- Public provider seams should not export infrastructure implementation files.
  Expose application/domain contracts, providers, and render-edge types; keep
  data sources and repository implementations behind named provider or
  application boundaries.
- The root `providers.dart` barrel has been retired. Cross-cutting providers
  that were historically defined there now live behind owned essential seams,
  such as `essentials/paths/feature_level_providers.dart` and
  `essentials/app_mode/feature_level_providers.dart`.
- Use the current provider names from code and database docs. Ordinary graph
  reads use `driftConversationGraphDatabaseProvider`; source-scoped import DB
  construction lives behind `sourceScopedImportDatabaseProvider` exported by
  `lib/essentials/db/feature_level_providers.dart`, while ordinary source
  import, graph projection, archive snapshot, and diagnostic semantics consume
  `sourceScopedImportLedgerProvider` or named repositories/query layers;
  overlay user intent and archive-source metadata use `overlayDatabaseProvider`.
  Retired `macos_import.db` and `working.db` are transitional cleanup file concerns
  and no longer have central app providers.
- Do not invent generic provider names such as `workingDatabaseProvider`; use
  the current centralized provider names.
- Keep generated files untouched unless running the approved generator.

## Historical Note

Older project docs used generic feature scaffolds such as `_import_and_dbs` and
example files like `import_db.dart`. Those examples are superseded by the
current essentials-owned database, source import, graph build, and retired-file
compatibility structure. Use this document and the linked subsystem docs for
current placement decisions.
