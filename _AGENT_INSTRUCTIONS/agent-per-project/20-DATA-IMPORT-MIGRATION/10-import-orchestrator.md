---
tier: project
scope: data-import-migration
owner: agent-per-project
last_reviewed: 2026-03-13
source_of_truth: code
links:
  - ./01-overview.md
  - ./02-import-migration-schema-reference.md
  - ./11-rust-message-extractor.md
  - ./15-table-importers.md
  - ../10-DATABASES/01-db-import.md
  - ../10-DATABASES/10-group-import-working.md
---

# Import Orchestrator

## 🔥 Automatic Polling (ChatDbChangeMonitor)

**Imports are triggered automatically** — no manual intervention required.

The app includes a `ChatDbChangeMonitor` provider that continuously watches macOS `chat.db` for new messages:

| Aspect | Detail |
|--------|--------|
| **Provider** | `chatDbChangeMonitorProvider` (keepAlive: true) |
| **Location** | `lib/essentials/db_importers/application/monitor/chat_db_change_monitor_provider.dart` |
| **Poll interval** | Every **15 seconds** |
| **Detection method** | Compares `MAX(ROWID)` from `message` table against stored value |
| **Trigger** | When ROWID increases, schedules debounced import (350ms debounce) |

### Auto-Import Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│  ChatDbChangeMonitor (runs in background)                           │
├─────────────────────────────────────────────────────────────────────┤
│  1. Timer fires every 15 seconds                                    │
│  2. Read MAX(ROWID) from ~/Library/Messages/chat.db                 │
│  3. Compare with lastMaxRowId stored in state                       │
│  4. If increased → schedule probe (350ms debounce)                  │
│  5. Probe runs:                                                     │
│     a. orchestratedLedgerImportServiceProvider.runImport()          │
│     b. handlesMigrationServiceProvider.run(incrementalMode: true)   │
│     c. ref.invalidate(driftWorkingDatabaseProvider) → UI refresh    │
└─────────────────────────────────────────────────────────────────────┘
```

### Wiring

The monitor is activated in `main.dart` via:
```dart
ref.watch(chatDbChangeMonitorProvider);
```

This ensures the monitor starts at app launch and runs continuously.

### Implications for Debugging

- **New messages appear automatically** within ~15-20 seconds of arrival
- **If messages aren't showing**, the monitor may have encountered an error — check console for `chat.db monitor` logs
- **Manual import is only needed** for initial setup or recovery scenarios

---

## Purpose
- Replace the legacy monolithic import runner with a deterministic sequence of table-focused importers.
- Ensure every ledger table is ingested with pre-flight validation, transactional copy logic, and post-flight verification.
- Provide granular progress, logging, and failure reporting so issues surface with the specific importer responsible.

## Location
- Orchestrator: `lib/essentials/db_importers/application/orchestrator/import_orchestrator.dart`
- Shared context: `lib/essentials/db_importers/infrastructure/sqlite/import_context_sqlite.dart`
- Base importer helpers: `lib/essentials/db_importers/application/services/base_table_importer.dart`
- Importer contract: `lib/essentials/db_importers/domain/i_importers.dart/table_importer.dart`
- Progress events: `lib/essentials/db_importers/domain/states/table_import_progress.dart`
- Riverpod wiring: `lib/essentials/db_importers/feature_level_providers.dart`

## Execution Model
1. **Importer registry** - The orchestrator receives a list of `TableImporter` instances (one per ledger table) and keeps them in `_importers` as an unmodifiable list.
2. **Dependency sorting** - `_sorted()` runs a Kahn topological sort over each importer's `dependsOn`. Any unresolved cycle throws before work begins, preventing partial runs.
3. **Phase lifecycle** - For every importer the orchestrator executes:
  - `validatePrereqs(ctx)` - must not mutate data; catches duplicate IDs, broken foreign keys, invalid enums, missing sources.
  - `copy(ctx)` - wrapped in a single transaction. Skipped automatically when `ImportContext.dryRun` is true.
  - `postValidate(ctx)` - confirms row counts, FK integrity, and any importer-specific invariants.
4. **Progress events** - `_runPhase()` publishes `TableImportProgressEvent`s (`started`, `succeeded`, `failed`) with human-friendly names via `BaseTableImporter.displayName`. UI view models surface these updates in the import control panel.
5. **Structured logging** - Every phase prints a timestamped banner (`=== [ISO8601] importer :: phase ===`) through `ImportContext.info()`, giving a chronological trace in console logs and batch notes.
6. **Filesystem audit report** - At the end of each run the orchestrated service writes `import_log` in the MessageLens app-support directory, capturing source counts, ledger counts, rich-text extraction stats, and source-vs-destination deltas.
7. **Dry-run support** - Validation and post-validation still execute while copy is skipped, enabling "check everything" workflows on user machines without mutating the ledger.

## Import Context Facts
- Exposes the `SqfliteImportDatabase`, live `chat.db` / AddressBook handles, active `batchId`, and an optional `MessageExtractorPort`.
- Stores previously imported max ROWIDs so append importers can detect true deltas.
- Includes a scratchpad map for importer-to-importer coordination (e.g., sharing statistics or staging paths).

## Importer Responsibilities
- Own one logical ledger table (or tight cluster) and copy rows from macOS sources into `macos_import.db` without altering source primary keys.
- Enrich rows with derived columns when needed, but do not invent cross-table relationships; that work happens during migration.
- Use `BaseTableImporter` helpers (`count`, `expectTrueOrThrow`, `expectZeroOrThrow`) to keep validation consistent.
- Emit progress names that help the UI explain which portion of the pipeline is running.

## Message Import Specifics

- Chat-linked source rows are staged into the normal `messages` ledger path.
- Source `message` rows that lack a `chat_message_join` mapping are now preserved on a dedicated recovery path instead of being left outside the app entirely.
- The current ledger split is:
  - `messages` for thread-linked rows
  - `recovered_unlinked_messages` for source rows that remain materially present but are no longer reachable through normal chat linkage
- Attachment joins and rich-text extraction now operate on both paths.
- This distinction matters operationally: a source row can be absent from the visible conversation graph while still surviving in `chat.db` with meaningful payloads.
- When rich-text extraction succeeds, the importer updates text-bearing rows on both the normal and recovered paths so later migration and diagnostics do not continue reporting them as `attachment-only`, `unknown`, or otherwise misleadingly sparse.

## Error Handling
- Any exception from an importer phase causes `_runPhase()` to emit a failure event, log the error context, and rethrow so the orchestrator stops immediately.
- Downstream consumers should surface the failure message and encourage reviewing importer-specific logs for details.
- If the run completes but the data looks wrong, inspect `import_log` before querying tables manually. In practice it is the fastest way to distinguish extractor failure, source orphan rows, and schema/count mismatches.

## When Adding Importers
1. Implement the `TableImporter` contract (prefer extending `BaseTableImporter`).
2. Declare every prerequisite table in `dependsOn` so topological sort enforces ordering.
3. Keep copy logic idempotent (`INSERT OR REPLACE`, `INSERT OR IGNORE`).
4. Use the orchestrator's progress callback to report meaningful status messages.
5. Update `../10-DATABASES/10-group-import-working.md` if stage ordering or ledger expectations change.
6. Coordinate with the migration team so new ledger fields are projected during migration before UI code relies on them.
