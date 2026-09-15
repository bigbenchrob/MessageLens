# Onboarding and Archive — Evolution Overview

## How We Got Here

The onboarding system in MessageLens has evolved through four distinct phases,
each driven by real-world user problems. This document traces that evolution
and explains why each layer exists.

---

## Phase 1: Simple Bootstrap Gate

**Problem:** First-run users saw a blank app with no data and no guidance.

**Solution:** A startup gate that answered two questions:

1. Can the app read `~/Library/Messages/chat.db`? (Full Disk Access check)
2. Do the source-scoped import ledger and conversation graph exist and contain
   usable graph data?

If either check failed, the earlier implementation presented a modal overlay
with a stepper UI that guided the user through:

- Granting Full Disk Access in System Settings
- Starting the initial import of Messages and Contacts data
- Waiting for the source-scoped conversation graph to be built

This established `OnboardingGate` in `lib/essentials/onboarding/`.

**Current state:** FDA and ready-to-import states are now synchronized into the
center panel through `ViewSpec.environmentReadiness` by
`OnboardingCenterPanelSyncObserver`. `OnboardingOverlay` remains the
full-window blocking surface for active workflow phases such as recovery,
import, graph build, completion, and reimport completion.

**Key code:**

| File | Role |
|------|------|
| `onboarding_journey_coordinator_provider.dart` | Sole typed Journey transition and operation authority |
| `onboarding_gate_provider.dart` | Read-only compatibility projection and action forwarding seam |
| `onboarding_operation_snapshot.dart` | Persisted operation stage, exact substage, progress, interruption, and recovery truth |
| `onboarding_overlay.dart` | Full-window blocking overlay for workflow phases |
| `onboarding_dev_panel.dart` | Development/simulation controls and graph build status |
| `database_existence_checker.dart` | Filesystem-only DB presence check |
| `fda_checker.dart` | FDA probe via `File.openSync()` on `chat.db` |
| `navigation/presentation/widgets/onboarding_center_panel_sync_observer.dart` | Syncs FDA/user-action states into the readiness panel |

**Architectural rule:** Onboarding coordinates and presents. Source-scoped
import/projection and graph build logic stay in their owning essentials.
Onboarding never owns those pipelines.

---

## Phase 2: Comprehensive Environment Evaluation

**Problem:** Field testers reported being stranded at launch with ambiguous
error states. The two-question gate could not distinguish between:

- FDA missing
- Messages database exists but is empty (this Mac not syncing)
- AddressBook path resolution failing
- Import succeeded but graph projection/build failed
- Databases exist but are stale or corrupt
- Pipeline errors masquerading as permission problems

**Solution:** An environment evaluation layer that produces a structured
readiness report before and during bootstrap. The report evaluates:

- Messages database readability and content richness
- AddressBook database readability and path resolution
- Presence and health of source-scoped import ledger and conversation graph
- Last import/graph-projection failure (persisted in overlay DB)
- Sync plausibility — whether this Mac appears to have meaningful local
  Messages history

This is implemented by `onboardingEnvironmentReportProvider`, which probes the
environment and classifies the result into user-facing states:

| State | Meaning |
|-------|---------|
| `permissionBlocked` | FDA not granted |
| `sourceUnavailable` | `chat.db` or AddressBook not found |
| `sourceSparseOrUnsynced` | Source exists but has very little data |
| `readyToImport` | Sources healthy, app databases empty |
| `importFailed` | Last import attempt failed |
| `graphProjectionFailed` | Last graph projection/build attempt failed |
| `ready` | App databases populated and healthy |

**Current surface:** `features/environment_readiness` owns readiness panel
content for `EnvironmentReadinessSpec.readinessPanel`. Essentials owns the
onboarding gate, panel-stack synchronization, active sidebar mode, and sidebar
parking.

The environment state is intentionally coarse. Exact active or interrupted
work comes from the persisted `OnboardingOperationSnapshot`, which distinguishes
message import, attributed-body extraction, rich-text persistence, individual
relationship imports, graph projection units, and final durable verification.
An interrupted exact substage remains resumable even if older durable database
evidence also causes the environment report to classify the installation as
`graphProjectionFailed`.

---

## Phase 3: Living Attachments Archive

**Problem:** A user's Messages Attachments folder shrank from 42 GB to 6 GB
overnight. Apple's storage optimization had silently evicted local attachment
files to iCloud. The database records in `chat.db` still referenced every
attachment, but the files were gone. MessageLens rendered "Image unavailable"
for the majority of image messages.

**Root cause:** macOS treats `~/Library/Messages/Attachments` as a volatile
cache. When Messages in iCloud is active with storage optimization, Apple
evicts files to free disk space. Apple Messages can re-download on demand;
MessageLens cannot.

**Solution:** A MessageLens-managed attachment archive that:

1. **Copies locally available attachment files at import time** into app-owned
   content-addressable storage
2. **Models availability state explicitly** (`pendingArchive`, `available`,
   `unavailableAwaitingRecovery`, `nonRecoverable`) rather than treating
   missing files as broken
3. **Resolves attachments through a source-policy pipeline** — archive-enabled
   mode displays from the MessageLens archive and uses live files as ingestion
   sources; live-only mode can display directly from Messages paths
4. **Stores archive metadata in the overlay database** — graph projection is a
   derived source-data view, and retired cleanup/diagnostic files are
   transitional compatibility inputs only; neither owns durable archive metadata

Archive storage uses SHA-256 content addressing:
```
attachment_archive/
└── {first-2-chars-of-hash}/
    └── {full-sha256}.{original-extension}
```

The archive service runs after graph live updates for newly imported source
ranges, on demand when a live file is seen by the resolver, and through a
periodic graph attachment sweep. Historical archive/recovery workflows may
invoke the same archive service explicitly, but retired projection is not an
app update or recovery path.

See [`40-attachment-archive.md`](40-attachment-archive.md) for full
architectural details.

---

## Phase 4: Deterministic Historical Recovery

**Problem:** The initial attempt to recover files from a Time Machine backup
of the Attachments folder used heuristic matching (path-tail coincidence,
SHA-256 hash comparison). Forensic analysis proved this approach fundamentally
broken:

- Sent-attachment directory conventions (`at_0_` GUID prefix) change between
  historical and current `chat.db`, breaking path-tail matching
- `sha256_hex` is frequently NULL in retired working projection rows,
  disabling hash-based matching in historical reference tables
- Common filenames (e.g. `IMG_1234.jpeg`) create false-positive ambiguity
- Real-world success rate: ~40%

**Solution:** Replace heuristic matching with a deterministic three-layer
mapping flow using a matched historical `chat.db` snapshot:

1. **Historical snapshot DB** provides authoritative message↔attachment
   relationships via SQL joins (not filesystem heuristics)
2. **Source-scoped import DB** bridges Apple's `attachment.guid` to canonical
   source-scoped message/attachment identity for graph-native recovery.
   Retired import files are transitional compatibility inputs only.
3. **Overlay archive metadata** receives archive rows with provenance
   `imported_historical_snapshot`

Primary graph-native match: `attachment.guid` → source-scoped import facts →
canonical graph message/attachment identity. The overlay archive key remains
compatibility-shaped for existing archive rows, but retired import/working DBs
are cleanup/audit evidence only.
Single-attachment fallback: when GUID is NULL and exactly one attachment
exists on both sides.
No further fallback: no path-tail, transfer_name, or ordinal matching.

See [`50-deterministic-recovery.md`](50-deterministic-recovery.md) for full
mapping logic and edge cases.

---

## Current State

The onboarding pipeline today works as follows:

1. **App launches** → `OnboardingGate` evaluates environment via
   `onboardingEnvironmentReportProvider`
2. **FDA/user-action gate** → `OnboardingCenterPanelSyncObserver` projects
   `awaitingFda` and `awaitingUserAction` into the center panel with
   `ViewSpec.environmentReadiness`
3. **Recovery reconciliation** → persisted operation status and exact substage
   are reconciled with durable store evidence; committed bounded work remains
   resumable and the UI offers `Continue Setup`. Reset is reserved for the
   separately classified preservation-safe derived-data recovery path.
4. **Graph build** → `ConversationGraphBuildController` runs the
   source-scoped import/projection lifecycle, producing `macos_import_ss.db`
   and `working_ss.db`
5. **Archive maintenance** → graph incremental sync archives newly imported
   source ranges and runs periodic graph attachment sweeps; explicit
   full/manual graph archive sweeps may still call `archiveAllAvailable()`
   after archive/recovery rebuilds
6. **Completion** → overlay shows summary, user clicks "Get Started"
7. **Ongoing** → `ChatDbChangeMonitor` polls `chat.db` every 15 seconds by
   source `MAX(ROWID)`, running the same frozen-high-water, keyset-paged
   source-scoped graph lifecycle for new rows and maintaining the archive

Historical recovery from a backup snapshot is available as a separate
user-initiated flow via the Settings panel.

The canonical paging, checkpoint, decoder, and `ss_id` contract is
[`12-bounded-message-import-and-rich-text-enrichment.md`](../20-DATA-IMPORT-MIGRATION/12-bounded-message-import-and-rich-text-enrichment.md).
