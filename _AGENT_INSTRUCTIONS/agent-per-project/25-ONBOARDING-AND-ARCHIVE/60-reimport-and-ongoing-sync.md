# Re-Import and Ongoing Sync

## Purpose

After initial onboarding completes, MessageLens stays current with the user's
Messages data through automatic polling and supports explicit re-import for
recovery scenarios.

## Auto-Sync: ChatDbChangeMonitor

### Mechanism

`ChatDbChangeMonitor` polls `~/Library/Messages/chat.db` every 15 seconds by
reading source `MAX(ROWID)` from the `message` table. On startup it primes
from the graph/source-scoped import cursor when available, then runs
an immediate catch-up check before periodic polling begins.

**Location:** `lib/essentials/conversation_graph/application/monitor/`

### On Change Detected

1. Run the source-scoped graph build lifecycle.
2. Archive the newly imported graph message source range with
   `archiveGraphMessageSourceRange(...)`.
3. Bump graph/message data version signals so data-dependent providers rebuild.

The graph build uses a frozen source `ROWID` high-water and keyset-paged message
reads. Attributed-body enrichment then uses a frozen candidate `ss_id`
high-water, metadata pages, byte-bounded decoder sub-pages, and per-page
persistence. Auto-sync does not use a reduced-safety or whole-corpus path.

In parallel with message polling, the monitor also runs a 5-minute attachment
maintenance sweep with `archiveNextGraphSweepChunk()`.

### User Experience

- New messages appear after the polling/debounce/source-scoped graph build cycle
- No user action required
- No visible indicator during normal sync; errors are logged in monitor state

### Constraints

- Requires FDA to remain granted for source reads
- If `chat.db` is locked by another process, the poll retries on the next cycle
- The monitor initializes on macOS and is meaningful after import data exists
- It uses a debounce and in-flight guard so overlapping probes coalesce
- Rows arriving above an active import run's frozen high-water wait for the
  next probe by design

## Manual Re-Import

### Trigger

User navigates to Settings and clicks "Re-scan & Import."

### Flow

```
Settings → "Re-scan & Import"
  │
  ├─ OnboardingJourneyCoordinator.startReimport()
  │   └─ OnboardingGate may forward established callers' intent
  │
  ├─ compatibility status = reimporting
  │   └─ Derived data is prepared/reset as needed
  │   └─ No separate readiness gate is shown
  │   └─ No welcome preamble in overlay
  │
  ├─ compatibility status = reimportBuildingGraph
  │   └─ ConversationGraphBuildController rebuilds the source-scoped graph
  │   └─ working_ss graph tables are rebuilt from source-scoped import facts
  │   └─ graph archive maintenance runs after successful build
  │
  └─ compatibility status = reimportComplete
      └─ Summary shown, "Done" button
```

### Why Re-Import?

Common reasons a user might re-import:

- AddressBook updated with new contacts
- Suspected data integrity issue
- Recovery from a partially failed previous import
- After restoring macOS from backup

### Data Safety

- Re-import resets only enumerated rebuildable source-scoped import/graph
  stores, then graph build reconstructs `working_ss.db` from source-scoped
  import facts
- Overlay DB rows (archive metadata, user preferences, favorites, etc.)
  survive re-import because overlay is never touched by graph projection
- Archive files on disk are preserved — archive maintenance is additive and
  idempotent
- Archived payloads are preservation data, not a reimport source that may be
  discarded and recreated. See
  [`ATTACHMENT-PRESERVATION-INVARIANT.md`](ATTACHMENT-PRESERVATION-INVARIANT.md).
- Message and rich-text rebuilding retains the same page/checkpoint bounds used
  by initial import and ongoing sync. See
  [`12-bounded-message-import-and-rich-text-enrichment.md`](../20-DATA-IMPORT-MIGRATION/12-bounded-message-import-and-rich-text-enrichment.md).

## Archive Maintenance During Sync

Each auto-sync cycle maintains the living archive:

1. **New attachments:** Imported-batch files are archived before incremental
   graph projection when locally available and not already in the archive.

2. **Evicted files:** If a file was archived previously and Apple has since
   evicted the original, the archive copy remains valid. The resolution
   provider will find it via the overlay lookup.

3. **Re-downloaded files:** If Apple re-downloads a previously evicted file
   (e.g., user opened it in Messages.app), the Messages path becomes valid
   again. In archive-enabled mode the resolver can trigger on-demand archive
   ingestion, and the periodic sweep can archive it later.

## Relationship to Onboarding

| Phase | Sync mechanism | Archive behavior |
|-------|---------------|-----------------|
| First run | OnboardingGate → source-scoped graph build | Graph source-range archive and graph attachment sweeps |
| Normal use | ChatDbChangeMonitor every 15 seconds plus 5-minute sweep | Graph source-range archive, on-demand archive, and rolling graph sweep |
| Re-import | Manual trigger from Settings | Source-scoped graph rebuild + archive maintenance |
| Historical recovery | User-initiated from Settings | Deterministic snapshot → archive |

## File Inventory

| File | Role |
|------|------|
| `lib/essentials/conversation_graph/application/monitor/chat_db_change_monitor_provider.dart` | Poll-based auto-sync and attachment sweep |
| `lib/essentials/onboarding/application/onboarding_gate_provider.dart` | `startReimport()` trigger |
| `lib/essentials/conversation_graph/application/orchestrators/conversation_graph_build_controller_provider.dart` | Source-scoped graph build/rebuild lifecycle |
| `lib/features/attachments/application/attachment_archive_service_provider.dart` | `archiveGraphMessageSourceRange()`, graph sweeps, typed archive compatibility lookup |
| `lib/essentials/source_scoped_import/application/messages/message_importer.dart` | Frozen-window, keyset-paged source message import |
| `lib/essentials/source_scoped_import/application/messages/message_rich_text_enricher.dart` | Frozen-window, row/byte-bounded attributed-body enrichment |
