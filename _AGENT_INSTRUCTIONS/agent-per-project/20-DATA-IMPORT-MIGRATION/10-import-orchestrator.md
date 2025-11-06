---
tier: project
scope: data-import-migration
owner: agent-per-project
last_reviewed: 2025-11-06
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
6. **Dry-run support** - Validation and post-validation still execute while copy is skipped, enabling "check everything" workflows on user machines without mutating the ledger.

## Import Context Facts
- Exposes the `SqfliteImportDatabase`, live `chat.db` / AddressBook handles, active `batchId`, and an optional `MessageExtractorPort`.
- Stores previously imported max ROWIDs so append importers can detect true deltas.
- Includes a scratchpad map for importer-to-importer coordination (e.g., sharing statistics or staging paths).

## Importer Responsibilities
- Own one logical ledger table (or tight cluster) and copy rows from macOS sources into `macos_import.db` without altering source primary keys.
- Enrich rows with derived columns when needed, but do not invent cross-table relationships; that work happens during migration.
- Use `BaseTableImporter` helpers (`count`, `expectTrueOrThrow`, `expectZeroOrThrow`) to keep validation consistent.
- Emit progress names that help the UI explain which portion of the pipeline is running.

## Error Handling
- Any exception from an importer phase causes `_runPhase()` to emit a failure event, log the error context, and rethrow so the orchestrator stops immediately.
- Downstream consumers should surface the failure message and encourage reviewing importer-specific logs for details.

## When Adding Importers
1. Implement the `TableImporter` contract (prefer extending `BaseTableImporter`).
2. Declare every prerequisite table in `dependsOn` so topological sort enforces ordering.
3. Keep copy logic idempotent (`INSERT OR REPLACE`, `INSERT OR IGNORE`).
4. Use the orchestrator's progress callback to report meaningful status messages.
5. Update `../10-DATABASES/10-group-import-working.md` if stage ordering or ledger expectations change.
6. Coordinate with the migration team so new ledger fields are projected during migration before UI code relies on them.
