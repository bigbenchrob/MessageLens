---
tier: project
scope: overview
owner: agent-per-project
last_reviewed: 2026-09-15
source_of_truth: doc
links:
  - ../../agent-instructions-shared/INDEX.md
  - ./01-aggregate-boundaries.md
  - ./02-architecture-overview.md
  - ./03-data-locations.md
  - ../42-SPEC-SYSTEM/README.md
  - ../30-ESSENTIALS/README.md
  - ../40-FEATURES/README.md
  - ../10-DATABASES/00-all-databases-accessed.md
  - ../20-DATA-IMPORT-MIGRATION/01-overview.md
  - ../20-DATA-IMPORT-MIGRATION/12-bounded-message-import-and-rich-text-enrichment.md
  - ../25-ONBOARDING-AND-ARCHIVE/README.md
tests: []
---

# Project Overview

MessageLens is a macOS-first Flutter app for importing, projecting, searching,
and browsing local Apple Messages and AddressBook data. The repository may still
be named `remember_every_text`; runtime storage, bundle identity, and user-facing
documentation use MessageLens.

This folder is the project-level map. It should stay high level and defer to
the subsystem docs when details matter.

## Current Top-Level Shape

| Area | Current owner |
| --- | --- |
| App shell, navigation, global flow, sidebar, panel stacks, search, onboarding gate, database providers, source-scoped import, graph build, and retired-file diagnostic boundaries | `lib/essentials/` |
| Business feature content, feature-owned specs, domain repositories, terminal feature rendering | `lib/features/` |
| Shared DDD helpers and generic utilities | `lib/domain_driven_development/`, `lib/core/` |
| Graph, overlay archive metadata, retired cleanup/diagnostic files, and overlay database infrastructure | `lib/essentials/db/` plus `lib/essentials/source_scoped_import/` |
| Attachment archive, deterministic recovery, attachment resolution | `lib/features/attachments/` plus overlay database metadata |

## Authoritative Reading Paths

- Spec-driven surfaces: start at `../42-SPEC-SYSTEM/README.md`.
- Essentials vs feature ownership: read `../30-ESSENTIALS/README.md` and `../40-FEATURES/README.md`.
- Database access and boundaries: read `../10-DATABASES/00-all-databases-accessed.md` and `../10-DATABASES/INVIOLATE_RULES.md`.
- Source import, graph build, and retired storage cleanup/diagnostic behavior:
  read `../20-DATA-IMPORT-MIGRATION/01-overview.md`; for the current bounded
  message/rich-text path, read
  `../20-DATA-IMPORT-MIGRATION/12-bounded-message-import-and-rich-text-enrichment.md`.
- Onboarding, environment readiness, archive, and recovery: read `../25-ONBOARDING-AND-ARCHIVE/README.md`.
- Build/FDA continuity: read `../60-BUILD-CONSIDERATIONS/02-macos-fda-grant-continuity.md` before production builds.

## Non-Negotiable Architectural Contracts

- Specs are the declarative bridge between state and rendering:
  `Spec → Coordinator → Resolver → Payload / ViewModel → Rendering`.
- Features provide content and approved feature-owned spec interpretation; they
  do not own app-level orchestration, global flow state, sidebar topology, panel
  stack policy, or shared chrome.
- Ordinary app data flows through source-scoped import into `macos_import_ss.db`
  and graph projection into `working_ss.db`; archive-source metadata lives in
  overlay storage, and retired `macos_import.db` / `working.db` files are
  retired cleanup inventory only.
- Source message import and attributed-body enrichment are separately bounded
  and separately checkpointed. They freeze source-scoped high-water marks,
  page by stable identity, and preserve anomalous records rather than using a
  whole-corpus extraction limit as a memory-control mechanism.
- User intent writes to `user_overlays.db`. Providers merge graph projection +
  overlay at read time, and overlay wins on conflict.
- Onboarding coordinates and presents graph readiness/build state; it does not
  own source-scoped import, graph projection, or retired-file diagnostics.
- Attachment archive metadata lives in overlay; archive files live under the app
  support archive directory and are never written back to Apple's Messages
  Attachments folder.
