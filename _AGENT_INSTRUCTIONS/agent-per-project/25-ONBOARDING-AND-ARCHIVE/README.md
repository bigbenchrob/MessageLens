# 25 — Onboarding, Bootstrap, and Attachment Archive

This folder documents the full lifecycle from first launch through ongoing
attachment preservation. It covers how MessageLens evaluates the macOS
environment, gates access, builds the source-scoped conversation graph, and
maintains a durable image archive independent of Apple's volatile storage.

Current code reality wins over older narrative in this folder. Where this
folder intersects with app surfaces, `ViewSpec`, or coordinator boundaries,
follow [`../42-SPEC-SYSTEM/`](../42-SPEC-SYSTEM/) and treat older overlay-only
wording as legacy/transitional.

## Reading Order

| Doc | Purpose |
|-----|---------|
| [`00-overview.md`](00-overview.md) | Evolution narrative — how the onboarding system grew from a simple gate to a comprehensive bootstrap and archive pipeline |
| [`10-onboarding-gate.md`](10-onboarding-gate.md) | The single-authority `OnboardingJourneyCoordinator`, typed Episodes, evidence, transition rules, and compatibility Gate |
| [`20-environment-readiness.md`](20-environment-readiness.md) | Environment evaluation: FDA checks, source database probes, sync plausibility, readiness classification |
| [`30-import-migration-coordination.md`](30-import-migration-coordination.md) | How onboarding coordinates graph build/rebuild lifecycle without owning source-scoped import/projection internals |
| [`../20-DATA-IMPORT-MIGRATION/12-bounded-message-import-and-rich-text-enrichment.md`](../20-DATA-IMPORT-MIGRATION/12-bounded-message-import-and-rich-text-enrichment.md) | Canonical message/rich-text paging, source-scoped identity, decoder bounds, and durable retry semantics |
| [`40-attachment-archive.md`](40-attachment-archive.md) | Living attachments archive: overlay schema, content-addressable storage, resolution pipeline, import-time archiving |
| [`ATTACHMENT-PRESERVATION-INVARIANT.md`](ATTACHMENT-PRESERVATION-INVARIANT.md) | Hard safety rule: archived payloads are preservation data and remain outside every ordinary reset/rebuild boundary |
| [`50-deterministic-recovery.md`](50-deterministic-recovery.md) | Deterministic historical recovery from Time Machine or backup snapshots via GUID-based mapping |
| [`60-reimport-and-ongoing-sync.md`](60-reimport-and-ongoing-sync.md) | Re-import flow, `ChatDbChangeMonitor` auto-sync, and how the archive stays current |
| [`handoff.txt`](handoff.txt) | Historical branch handoff only; not current architecture guidance |

## Key Ownership Boundaries

- **`lib/essentials/onboarding/`** — single Journey coordination authority,
  environment evaluation, operation truth, overlay presentation, and
  preservation-safe bootstrap orchestration
- **`lib/essentials/presence/`** — generic Schedule, Trip, Step, routing,
  checkpoint, run, trace, and persistence machinery; a shared `presence.db`
  does not make Presence the semantic owner of onboarding, and Presence
  receives an already-composed opaque Test Agent resolver
- **`lib/features/environment_readiness/`** — current readiness panel content for `ViewSpec.environmentReadiness`
- **`lib/essentials/navigation/`** — readiness panel synchronization, panel stack ownership, and sidebar parking
- **`lib/essentials/source_scoped_import/`** — source-scoped import ledger
- **`lib/essentials/conversation_graph/`** — graph build, projection, readiness, and app-facing graph queries
- **Retired `lib/essentials/db_importers/`** — removed; source-scoped importers live in `lib/essentials/source_scoped_import/`, live monitoring and graph lifecycle live in `lib/essentials/conversation_graph/`, and retired-storage diagnostics live in `lib/essentials/db/`
- **Retired `lib/essentials/db_migrate/`** — historical retired projection
  cleanup context only; no active onboarding setup ownership
- **`lib/features/attachments/`** — archive service, resolver, deterministic recovery, settings
- **`lib/essentials/db/`** — overlay database schema including `archived_attachments` table

## Hard Invariants

1. Onboarding **coordinates and presents** — it does not own source-scoped import/projection logic.
2. Archive metadata is **user intent** — written only to the overlay database.
3. The source-scoped conversation graph is the app-facing projection of source data.
4. Providers **merge** graph + overlay at read time; overlay wins on conflict.
5. No attachment record is ever suppressed because its file is missing — the record renders with an availability state.
6. The Messages Attachments folder is **never written to** by MessageLens.
7. Historical snapshots are opened **read-only** — never mutated.
8. FDA and ready-to-import states are current center-panel readiness states, not overlay-only states.
9. New work must not bypass `ViewSpec` or introduce widget-returning coordinator patterns for onboarding/readiness surfaces.
10. Archived attachment payloads are **preservation data**. No onboarding,
    reset, reimport, recovery, migration cleanup, rebuild, or test operation may
    mutate them as a side effect. See
    [`ATTACHMENT-PRESERVATION-INVARIANT.md`](ATTACHMENT-PRESERVATION-INVARIANT.md).
11. `OnboardingJourneyCoordinator` is the only authority that selects or
    advances an Onboarding Episode. Presence, Environment Readiness, widgets,
    dialogs, focus callbacks, and operation snapshots publish facts or intent
    only.
12. Persisted operation stage/substage is exact interruption evidence. A coarse
    environment classification must not erase a safely resumable bounded-work
    checkpoint.

## Related Documentation

- [`45-NEW-FEATURE-ADDITION/23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/09-PRESENCE-TESTSTEP-CONSOLIDATION-AUDIT.md`](../45-NEW-FEATURE-ADDITION/23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/09-PRESENCE-TESTSTEP-CONSOLIDATION-AUDIT.md) — current generic TestAgent/TestStep ownership result
- [`45-NEW-FEATURE-ADDITION/23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/11-MESSAGES-SOURCE-HISTORY-SUFFICIENCY-TESTAGENT-IMPLEMENTATION.md`](../45-NEW-FEATURE-ADDITION/23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/11-MESSAGES-SOURCE-HISTORY-SUFFICIENCY-TESTAGENT-IMPLEMENTATION.md) — current Onboarding-owned local-history sufficiency Agent boundary
- [`10-DATABASES/00-all-databases-accessed.md`](../10-DATABASES/00-all-databases-accessed.md) — database locations and access patterns
- [`10-DATABASES/INVIOLATE_RULES.md`](../10-DATABASES/INVIOLATE_RULES.md) — overlay/working separation, no suppression
- [`20-DATA-IMPORT-MIGRATION/01-overview.md`](../20-DATA-IMPORT-MIGRATION/01-overview.md) — source import, graph build, and retired storage cleanup/diagnostic boundaries
- [`60-BUILD-CONSIDERATIONS/02-macos-fda-grant-continuity.md`](../60-BUILD-CONSIDERATIONS/02-macos-fda-grant-continuity.md) — FDA grant preservation across builds
