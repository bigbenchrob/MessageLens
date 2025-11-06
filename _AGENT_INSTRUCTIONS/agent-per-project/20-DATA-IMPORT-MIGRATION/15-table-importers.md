---
tier: project
scope: data-import-migration
owner: agent-per-project
last_reviewed: 2025-11-06
source_of_truth: code
links:
  - ./01-overview.md
  - ./10-import-orchestrator.md
  - ./02-import-migration-schema-reference.md
  - ../10-DATABASES/01-db-import.md
  - ../../agent-per-project_old/40-integration/import-orchestrator.md
  - ../../agent-per-project_old/40-integration/pipelines.md
  - lib/essentials/db_importers/infrastructure/sqlite/import_context_sqlite.dart
  - lib/essentials/db_importers/infrastructure/sqlite/importers/messages_importer.dart
  - lib/essentials/db_importers/application/services/base_table_importer.dart
  - lib/essentials/db_importers/domain/i_importers.dart/table_importer.dart
---

# Table Importers Guide

Reference for authoring and maintaining the ledger importers that populate `macos_import.db`. Use this when touching `MessagesImporter`, `ContactsImporter`, or any importer registered with `ImportOrchestrator`.

## Importer Anatomy

Each importer must implement `TableImporter` (prefer extending `BaseTableImporter`). Core pieces:
- **name**: Machine identifier used for dependency edges and logging.
- **displayName**: Human-friendly label surfaced in progress events (provided by `BaseTableImporter`).
- **dependsOn**: List of other importer names that must complete before this importer runs.
- **validatePrereqs(ctx)**: Non-mutating guard checks.
- **copy(ctx)**: Transactional `INSERT` work that stages new data in the ledger.
- **postValidate(ctx)**: Ensures the copy produced correct row counts and referential integrity.

Importers are constructed with the shared `ImportContext` supplied by `ImportOrchestrator.run(...)`.

## ImportContext Summary

`ImportContext` (see `import_context_sqlite.dart`) bundles:
- `importDb`: `SqfliteImportDatabase` handle that exposes ledger helper methods.
- `messagesDb`, `messagesDbPath`: Live `chat.db` connection and absolute path for shelling out to the Rust extractor.
- `addressBookDb`: Live AddressBook connection for contact importers.
- `batchId`: Primary key from `import_batches` for current run.
- `dryRun`: Skip writes when true; validations still execute.
- `log`: Optional logger used by `ctx.info(...)` to emit structured progress.
- `extractor`: `MessageExtractorPort` for rich text decoding.
- `rustExtractionLimit`: Upper bound for extractor batch size (default 200000).
- `previousMax*RowId` fields: High-water marks that incremental importers can consult.
- `hasExistingLedgerData`: Signals whether tables already contain rows (important for first-run heuristics).
- `scratchpad`: Mutable `Map<String, Object?>` for passing stats between phases (e.g., `messages.richTextApplied`).

### Convenience Helpers
- `ledgerSqlite`: Async getter returning the raw `Database` from `importDb` for ad-hoc SQL.
- `info(message)`: Emits a log entry if `log` is set.
- `readScratch<T>(key)` / `writeScratch(key, value)`: Share data among importers in one orchestration run.

## Execution Lifecycle

When `ImportOrchestrator` runs, each importer goes through three phases:
1. **validatePrereqs**
   - Must not mutate data.
   - Verify source row availability, detect duplicate primary keys, check foreign keys.
   - Abort early with descriptive exceptions (`expectTrueOrThrow`, etc.).
2. **copy**
   - Wrap inserts in a transaction (handled by `BaseTableImporter` helper methods).
   - Prefer deterministic `INSERT OR REPLACE` / `INSERT OR IGNORE` statements.
   - Respect `ctx.dryRun`; skip writes but still log intent.
   - For append-style importers, compare against `previousMax*RowId` to avoid reprocessing.
3. **postValidate**
   - Confirm row counts match expectations (`count` helper).
   - Re-run key integrity checks, ensuring new rows have valid foreign keys into previously imported tables.
   - Optionally stash metrics in `scratchpad` for later phases (for example, message rich text coverage).

## Dependency Rules

- Declare upstream tables in `dependsOn` so `_sorted()` can enforce ordering (e.g., `MessagesImporter` depends on `ChatsImporter` and `HandlesImporter`).
- Avoid cross-importer coordination via global state; use `scratchpad` instead.
- When introducing new dependencies, update `../10-DATABASES/10-group-import-working.md` and revisit migration ordering so projection remains aligned.

## Validation Practices

- Use `BaseTableImporter` helpers (`count`, `expectTrueOrThrow`, `expectZeroOrThrow`) to keep messaging consistent.
- Guard against partial writes by requiring prerequisite tables to contain source rows before copying.
- Log before and after each phase (`ctx.info(...)`) so the orchestrator transcript highlights which importer failed if something goes wrong.
- For extract-dependent importers (like `MessageRichTextImporter`), check `ctx.extractor?.isAvailable()` and note results in `scratchpad`.

## Adding or Modifying Importers

1. Create a new class extending `BaseTableImporter`, implement required methods, and register it in the registry used by `ImportOrchestrator`.
2. Update unit or integration coverage to exercise `validatePrereqs`, `copy`, and `postValidate` branches.
3. Document any new ledger tables or columns in `02-import-migration-schema-reference.md`.
4. Ensure migration counterparts exist so data flows all the way into `working.db` (`migration_orchestrator.dart`).
5. Run `dart run build_runner build --delete-conflicting-outputs` if annotations are introduced, and execute the import control panel in dry-run mode to validate logs before committing.

## Related References

- `./10-import-orchestrator.md` for orchestration details.
- `./11-rust-message-extractor.md` for the rich text helper binary contract.
- `../10-DATABASES/10-group-import-working.md` for cross-database responsibilities.
- `lib/essentials/db_importers/infrastructure/sqlite/importers/messages_importer.dart` as the canonical example importer.
