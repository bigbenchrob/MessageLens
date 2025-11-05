# Import Orchestrator

## Purpose
- Replaces the legacy monolithic import runner with a deterministic sequence of table-focused importers.
- Ensures every ledger table is ingested with pre-flight validation, transactional copy logic, and post-flight verification.
- Provides granular progress, logging, and failure reporting so issues surface with the specific importer responsible.

## Location
- Orchestrator: `lib/essentials/db_importers/application/orchestrator/import_orchestrator.dart`
- Shared context: `lib/essentials/db_importers/infrastructure/sqlite/import_context_sqlite.dart`
- Base importer helpers: `lib/essentials/db_importers/application/services/base_table_importer.dart`
- Importer contract: `lib/essentials/db_importers/domain/i_importers.dart/table_importer.dart`
- Progress events: `lib/essentials/db_importers/domain/states/table_import_progress.dart`

## Execution Model
1. **Importer registry** – The orchestrator receives a list of `TableImporter` instances (one per ledger table) and captures them in `_importers` as an unmodifiable list.
2. **Dependency sorting** – `_sorted()` runs a Kahn topological sort over each importer’s `dependsOn` list. Any unresolved cycle throws before work begins, preventing partial runs.
3. **Phase lifecycle** – For each importer the orchestrator invokes:
   - `validatePrereqs(ctx)` – must not mutate data; catches duplicate IDs, broken foreign keys, invalid enums, missing sources.
   - `copy(ctx)` – wrapped in a single transaction. Skipped automatically when `ImportContext.dryRun` is true.
   - `postValidate(ctx)` – confirms row counts, FK integrity, and any importer-specific invariants.
4. **Progress events** – `_runPhase()` publishes `TableImportProgressEvent`s (`started`, `succeeded`, `failed`) with human-friendly names via `BaseTableImporter.displayName`. UI view models surface these updates in the import control panel.
5. **Structured logging** – Every phase prints a timestamped banner (`=== [ISO8601] importer :: phase ===`) through `ImportContext.info()`, giving a chronological trace in console logs and batch notes.
6. **Dry-run support** – Validation and post-validation still execute while copy is skipped, enabling “check everything” workflows on user machines without mutating the ledger.

## Import Context Facts
- Exposes the `SqfliteImportDatabase`, live `chat.db` / AddressBook `Database` handles, active `batchId`, and an optional `MessageExtractorPort`.
- Stores previously imported max ROWIDs so append importers can detect true deltas.
- Includes a scratchpad map for importer-to-importer coordination (e.g., sharing statistics or staging paths).

## Importer Responsibilities
- Each importer owns one logical ledger table (or tight cluster) and is solely responsible for copying rows from macOS sources into `macos_import.db`.
- Source identifiers **must remain unchanged**; importers never fabricate new primary keys.
- Importers can enrich rows with derived columns, but link reconciliation already happened in macOS data—do not invent cross-table relationships here.
- Use the helpers provided by `BaseTableImporter` (`count`, `expectTrueOrThrow`, `expectZeroOrThrow`) to keep validation consistent.

## Error Handling
- Any exception thrown from an importer phase causes `_runPhase()` to emit a failure event, log the error context, and rethrow so the orchestrator stops immediately.
- Consumers should surface the failure message and encourage reviewing the importer-specific logs for details.

## When Adding Importers
1. Implement the `TableImporter` contract (or extend `BaseTableImporter`).
2. Declare every prerequisite table in `dependsOn`.
3. Keep copy logic idempotent (`INSERT OR REPLACE`, `INSERT OR IGNORE`).
4. Use the orchestrator’s progress callback to report meaningful status messages.
5. Update `_AGENT_INSTRUCTIONS/agent-per-project/40-integration/pipelines.md` with the new stage ordering.
