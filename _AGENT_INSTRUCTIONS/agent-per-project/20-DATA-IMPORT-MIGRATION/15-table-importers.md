---
tier: project
scope: data-import-migration
owner: agent-per-project
last_reviewed: 2026-09-15
source_of_truth: code
links:
  - ./01-overview.md
  - ./10-import-orchestrator.md
  - ./11-rust-message-extractor.md
  - ./12-bounded-message-import-and-rich-text-enrichment.md
  - ./02-import-migration-schema-reference.md
  - ../10-DATABASES/01-db-import.md
  - lib/essentials/source_scoped_import/
---

# Retired Table Importers Guide

Historical reference for the deleted retired ledger importer framework
that populated `macos_import.db`. Use this only to interpret old logs, old docs,
or old user data folders.

> Current conformance note (2026-06-08): new ordinary import work must target
> the source-scoped import spine (`macos_import_ss.db`) and conversation graph
> build lifecycle. The retired `ImportOrchestrator`, `ImportContext`, and
> `TableImporter` framework are not present in the current source tree.

## Importer Anatomy

Each importer must implement `TableImporter` (prefer extending `BaseTableImporter`). Core pieces:
- **name**: Machine identifier used for dependency edges and logging.
- **displayName**: Human-friendly label surfaced in progress events (provided by `BaseTableImporter`).
- **dependsOn**: List of other importer names that must complete before this importer runs.
- **validatePrereqs(ctx)**: Non-mutating guard checks.
- **copy(ctx)**: Transactional `INSERT` work that stages new data in the ledger.
- **postValidate(ctx)**: Ensures the copy produced correct row counts and referential integrity.

Historically, importers were constructed with the shared `ImportContext`
supplied by `ImportOrchestrator.run(...)`.

## ImportContext Summary

The retired `ImportContext` bundled:
- `importDb`: `SqfliteImportDatabase` handle that exposes retired ledger helper methods.
- `messagesDb`, `messagesDbPath`: Live `chat.db` connection and absolute path for shelling out to the Rust extractor.
- `addressBookDb`: Live AddressBook connection for contact importers.
- `batchId`: Primary key from `import_batches` for current run.
- `dryRun`: Skip writes when true; validations still execute.
- `log`: Optional logger used by `ctx.info(...)` to emit structured progress.
- `extractor`: `MessageExtractorPort` for rich text decoding.
- `rustExtractionLimit`: Upper bound for extractor batch size (default 200000).
- `previousMax*RowId` fields: High-water marks that incremental importers can consult.
- `hasExistingLedgerData`: Signals whether retired tables already contain rows.
- `scratchpad`: Mutable `Map<String, Object?>` for passing stats between phases (e.g., `messages.richTextApplied`).

That `rustExtractionLimit` fact belongs only to the deleted framework described
here. It was neither a byte bound nor an active-path memory guarantee. Current
rich-text work uses the separately documented FFI, metadata-page, byte-page,
per-record, and native resource bounds in
[`12-bounded-message-import-and-rich-text-enrichment.md`](12-bounded-message-import-and-rich-text-enrichment.md).

### Convenience Helpers
- `ledgerSqlite`: Async getter returning the raw `Database` from `importDb` for ad-hoc SQL.
- `info(message)`: Emits a log entry if `log` is set.
- `readScratch<T>(key)` / `writeScratch(key, value)`: Share data among importers in one orchestration run.

## Execution Lifecycle

When the retired `ImportOrchestrator` ran, each importer went through three
phases:
1. **validatePrereqs**
   - Must not mutate data.
   - Verify source row availability, detect duplicate primary keys, check foreign keys.
   - Abort early with descriptive exceptions (`expectTrueOrThrow`, etc.).
2. **copy**
   - Use importer-owned deterministic SQL and transactions where the importer needs atomic multi-statement work.
   - Prefer deterministic `INSERT OR REPLACE` / `INSERT OR IGNORE` statements.
   - Respect `ctx.dryRun`; skip writes but still log intent.
   - For incremental importers, compare against `previousMax*RowId` fields and preserve prior imported rows.
3. **postValidate**
   - Confirm row counts match expectations (`count` helper).
   - Re-run key integrity checks, ensuring new rows have valid foreign keys into previously imported tables.
   - Optionally stash metrics in `scratchpad` for later phases (for example, message rich text coverage).

## Dependency Rules

- Declare upstream tables in `dependsOn` so `_sorted()` can enforce ordering. Current registry ordering is owned by `OrchestratedLedgerImportService`; the topological sort is the contract, not the literal source order.
- Avoid cross-importer coordination via global state; use `scratchpad` instead.
- When introducing new dependencies, update `../10-DATABASES/10-group-import-working.md` and revisit migration ordering so projection remains aligned.

## Validation Practices

- Use `BaseTableImporter` helpers (`count`, `expectTrueOrThrow`, `expectZeroOrThrow`) to keep messaging consistent.
- Guard against partial writes by requiring prerequisite tables to contain source rows before copying.
- Log before and after each phase (`ctx.info(...)`) so the orchestrator transcript highlights which importer failed if something goes wrong.
- For extract-dependent importers (like `MessageRichTextImporter`), check `ctx.extractor?.isAvailable()` and note results in `scratchpad`.

## Adding or Modifying Importers

Do not add retired-era importers for ordinary app behavior. New source
facts belong in `lib/essentials/source_scoped_import/` and should project into
the conversation graph. If old `macos_import.db` contents matter for
archive/recovery, treat them as cleanup/audit evidence to migrate, export,
or intentionally discard. Do not recreate the retired importer framework.

## Related References

- `./10-import-orchestrator.md` for orchestration details.
- `./11-rust-message-extractor.md` for the current FFI decoder and the
  compatibility helper boundary.
- `./12-bounded-message-import-and-rich-text-enrichment.md` for current
  source-scoped message and rich-text architecture.
- `../10-DATABASES/10-group-import-working.md` for cross-database responsibilities.
- Source-scoped importers under `lib/essentials/source_scoped_import/` are the current production examples for new graph-era work.
- Retired importer descriptions remain historical examples only.
