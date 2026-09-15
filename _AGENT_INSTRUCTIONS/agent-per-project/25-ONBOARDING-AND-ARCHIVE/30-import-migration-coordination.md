# Graph Build Coordination

## Purpose

Onboarding coordinates startup/retry lifecycle but does not own source-scoped
import, projection, or graph query systems. This document describes the current
graph-first setup flow and the retired cleanup-storage boundary.

## Ownership Boundaries

| System | Owner | Location |
|--------|-------|----------|
| Bootstrap gate and user-facing status | Onboarding | `lib/essentials/onboarding/` |
| Source-scoped import ledger | source_scoped_import | `lib/essentials/source_scoped_import/` |
| Conversation graph build/projection/readiness | conversation_graph | `lib/essentials/conversation_graph/` |
| Archive metadata and historical cleanup storage | overlay / db / database health / reset infrastructure | Overlay metadata plus explicit diagnostics and reset boundaries only |
| Attachment archiving and recovery | attachments feature | `lib/features/attachments/` |

**Rule:** `OnboardingJourneyCoordinator` owns Journey transitions and delegates
admitted reimport/automatic-recovery cleanup to `MessageDataResetService` and
graph build/rebuild to `ConversationGraphBuildController`. `OnboardingGate` is
only the compatibility projection/intent-forwarding seam. Neither may call
`DbImportControlViewModel`, `runImportAndMigration()`, or retired legacy
migration paths as the app-facing setup path.

> **Safety:** `MessageDataResetService` removes only enumerated rebuildable
> derived database files and SQLite companions. Archived attachment payloads
> are preservation data, not rebuild inputs or cleanup targets. See
> [`ATTACHMENT-PRESERVATION-INVARIANT.md`](ATTACHMENT-PRESERVATION-INVARIANT.md).

## Pipeline Sequence

```
OnboardingJourneyCoordinator.startVirginImportAndGraphBuild()
  │
  ├─ 1. Source and mutation admission for proven Virgin state
  │
  ├─ 2. Durable initial-import operation begins
  │
  ├─ 3. Source-scoped graph build
  │   └─ ConversationGraphBuildController.runOnce(...)
  │       Source: ~/Library/Messages/chat.db (FDA-gated)
  │       Import ledger: ./macos_import_ss.db
  │       Working graph: ./working_ss.db
  │       Builds messages, chats, handles, topology, attachments,
  │       bounded text enrichment, and graph indexes/readiness state.
  │
  └─ 4. Durable readiness verification and completion
      └─ OnboardingJourneyCoordinator publishes the complete Episode
          Operation status/stage/substage remains persisted
          Overlay shows summary
```

A proven Virgin first import constructs fresh derived stores and does not run a
pre-emptive reset. Reimport and separately admitted automatic recovery use the
enumerated derived-data reset path where their evidence requires it.

## Progress Reporting

Onboarding progress is a durable projection of typed facts supplied by the
source-import and Conversation Graph services. Retired database files may
still be reset or inspected by diagnostics, but onboarding does not consume
`DbImportControlViewModel`, `runImportAndMigration()`, or retired projection
paths.

Enumerable import, rich-text, and row-oriented projection work reports exact
completed and total units at bounded cadence. Fast set-based projectors,
derived-store reset, and final readiness probes report typed coarse substages
without a fabricated percentage. Presentation consumes
`OnboardingOperationSnapshot`; it does not calculate work by inspecting
repositories.

The app-facing setup path is the Journey coordinator plus
`ConversationGraphBuildController` for source-scoped graph build/rebuild.
`MessageDataResetService` participates only in admitted reimport, automatic
recovery, Start Fresh, and development reset paths that require enumerated
derived-data cleanup.

Source import also publishes fixed, domain-owned anomaly totals. The
orchestrator coalesces those totals with real progress, and Onboarding persists
them in its existing operation snapshot. Source identity failures remain
fatal. Optional interpretation may degrade only where the source domain has an
explicit truthful representation; relationship importers validate both source
endpoints before omitting and accounting for an invalid child edge.

Message import and attributed-body enrichment use frozen high-water windows,
keyset pages, per-page transactions, and source-scoped `ss_id` decoder keys.
Onboarding receives their typed observations; it does not own their cursors,
page sizes, byte limits, or retry predicates. See
[`12-bounded-message-import-and-rich-text-enrichment.md`](../20-DATA-IMPORT-MIGRATION/12-bounded-message-import-and-rich-text-enrichment.md).

## Failure Handling

| Failure | Behavior |
|---------|----------|
| Source-scoped graph build fails | Failure is persisted and the compatibility status becomes `awaitingUserAction` |
| User clicks retry | Derived data is prepared and graph build re-runs |
| Process ends mid-pipeline with an exact persisted substage | Startup reconciles the prior running snapshot to interrupted; committed bounded work remains durable and `Continue Setup` resumes from the safe boundary |
| Coarse graph failure plus exact interrupted substage | Exact operation evidence remains resumable; it is not flattened into a generic non-resumable graph failure |
| Stale partial source-scoped import/graph state separately classified for derived-data recovery | The admitted recovery path resets only enumerated rebuildable DB files, then returns to the truthful Journey state |

**Persistence:** Results are stored as JSON in the overlay DB `OverlaySettings`
table, surviving app restarts.

## Database Topology

```
Source (read-only)         Source-scoped graph          App-owned user intent
─────────────────          ──────────────────────       ─────────────────────
~/Library/Messages/        ./macos_import_ss.db         ./user_overlays.db
  chat.db            ───→    (source facts)        ───→  (overlay DB)
                               │                          │
~/Library/Application          ▼                          │
  Support/.../          ./working_ss.db           ◄──────┘
  AddressBook-*          (conversation graph)       (merged at read time)
```

**Key:** Source-scoped import preserves source facts/provenance. Graph
projection writes canonical app graph rows keyed by `ss_id`. Archive service
writes to `user_overlays.db` and the filesystem archive folder. Providers merge
graph + overlay at read time.

## Re-Import Flow

When a user triggers re-import from Settings:

1. Settings intent reaches `OnboardingJourneyCoordinator.startReimport()`
   directly or through the compatibility `OnboardingGate` forwarder
2. Compatibility status transitions:
   `reimporting` → `reimportBuildingGraph` → `reimportComplete`
3. `MessageDataResetService` resets enumerated rebuildable derived stores while
   preserving overlay intent and archived attachment payloads
4. `ConversationGraphBuildController` rebuilds the source-scoped graph
5. Archive rows in overlay are additive — existing entries survive

The rebuild reuses the same bounded message/enrichment implementation as first
import and live sync. Reimport does not create a whole-corpus variant.

## Auto-Sync Integration

After initial onboarding completes, `ChatDbChangeMonitor` keeps the app current:

- Primes from the graph/source-scoped import cursor and checks startup catch-up.
- Polls `MAX(ROWID)` in `~/Library/Messages/chat.db` every 15 seconds.
- On change: runs the source-scoped graph build lifecycle.
- Archives newly imported live graph source ranges.
- Bumps graph/message data version providers on success.
- Runs a periodic graph-attachment sweep every 5 minutes for attachments that
  become locally available later.
- No user interaction required

See [`60-reimport-and-ongoing-sync.md`](60-reimport-and-ongoing-sync.md) for
details.
