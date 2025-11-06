---
tier: project
scope: data-import-migration
owner: agent-per-project
last_reviewed: 2025-11-06
source_of_truth: code
links:
  - ./01-overview.md
  - ./20-migration-orchestrator.md
  - ./02-import-migration-schema-reference.md
  - ../10-DATABASES/02-db-working.md
  - ../10-DATABASES/10-group-import-working.md
  - lib/essentials/db_migrate/application/orchestrator/migration_orchestrator.dart
  - lib/essentials/db_migrate/application/orchestrator/handles_migration_service.dart
  - lib/essentials/db_migrate/application/services/base_table_migrator.dart
  - lib/essentials/db_migrate/domain/i_migrators.dart/table_migrator.dart
  - lib/essentials/db_migrate/infrastructure/sqlite/migration_context_sqlite.dart
---

# Table Migrators Guide

Reference for building and maintaining the projection migrators that move data from `macos_import.db` into `working.db`. Start here when updating `MessagesMigrator`, introducing new working tables, or adjusting migration ordering.

## Migrator Anatomy

Every migrator implements `TableMigrator` (typically by extending `BaseTableMigrator`). Core elements:
- **name**: Stable identifier used for dependency ordering and logging.
- **displayName**: Friendly label published in progress events (provided by `BaseTableMigrator`).
- **dependsOn**: Migrators that must finish before this one runs.
- **targetTables**: Working tables cleared during preparation (supplied by `BaseTableMigrator`).
- **validatePrereqs(ctx)**: Guard checks that run before any writes.
- **copy(ctx)**: Copy logic that moves rows from the ledger to the working projection.
- **postValidate(ctx)**: Final assertions to ensure the projection is consistent.

Migrators receive a shared `MigrationContext` instance from `HandlesMigrationService` when the orchestrator runs.

## MigrationContext Summary

`MigrationContext` (see `migration_context_sqlite.dart`) includes:
- `importDb`: Attached `Database` handle for `macos_import.db`.
- `workingDb`: Drift-backed `DatabaseConnectionUser` for `working.db` operations.
- `log`: Optional logger used by `ctx.log(...)` to emit orchestrator transcripts.
- `dryRun`: When true, preparation and validation run but copy steps skip writes.
- `handleIdCanonicalMap`, `chatIdMap`, and similar helpers: Provide deterministic ID lookups between ledger and working tables.
- `ensureImportReady(label)` / `ensureImportClean(label)`: Safety checks that assert ledger attachment state before and after each phase.

### Utilities
- `ctx.transaction((txn) async { ... })`: Helper for transactional copy work when using raw SQL.
- `ctx.attachImport()` / `ctx.detachImport()`: Managed automatically by migrator helpers; call explicitly only for advanced flows.
- `ctx.expectTrue` / `ctx.expectZero`: Assertion helpers mirroring those on `BaseTableMigrator`.

## Execution Lifecycle

`HandlesMigrationService` executes the orchestrator with a deterministic phase order:
1. **validatePrereqs**
   - Must not mutate data.
   - Confirm the ledger contains rows for required tables.
   - Verify canonical ID maps have entries for the relationships this migrator expects.
2. **copy**
   - Perform `INSERT ... SELECT` statements from the attached ledger into `working.db`.
   - Use `INSERT OR REPLACE` semantics unless the table is append-only by design.
   - Respect `ctx.dryRun`; always log planned work when skipping writes.
   - Restore user overrides after copying (for example, handle visibility flags) if the migrator clears those columns.
3. **postValidate**
   - Recount rows to confirm the projection matches the ledger.
   - Rebuild derived indexes if the migrator invalidates them (handled in the service once messages and attachments finish).
   - Surface metrics via `TableMigrationProgressEvent` so the UI can display detailed stage information.

## Dependency Rules

- Declare every prerequisite in `dependsOn`; the orchestrator's topological sort enforces the order and fails fast on cycles.
- Group related tables into the same migrator when they must update atomically (for example, `ChatToHandleMigrator`).
- When introducing a migrator, update `HandlesMigrationService` to include it in the sequence and assign an appropriate progress stage.
- Mirror import dependencies: if an importer waits on handles before copying messages, the projection migrator should retain the same ordering.

## Validation Practices

- Use `BaseTableMigrator` helpers (`count`, `expectTrueOrThrow`, `expectZeroOrThrow`) to provide consistent assertion messaging.
- Call `ctx.ensureImportReady` at the start of each phase and `ctx.ensureImportClean` afterward to avoid lingering attachments or write locks.
- Preserve ledger identifiers verbatim; migrators should not mint new IDs.
- When migrating denormalized tables, compare hash or timestamp columns to catch drift between ledger and projection.
- Log before and after each phase using `ctx.log(...)` so progress transcripts identify failing migrators quickly.

## Adding or Modifying Migrators

1. Implement the new migrator class (extend `BaseTableMigrator`) and register it in `HandlesMigrationService`.
2. Add dependency edges via `dependsOn` so ordering remains valid.
3. Update `targetTables` to ensure preparation truncates the correct working tables when not in dry-run mode.
4. Document schema changes in `02-import-migration-schema-reference.md` and confirm matching Drift table updates in `working_database.dart`.
5. Verify overlay restoration logic still replays user overrides after migration, updating `HandlesMigrationService` if needed.
6. Exercise the migration via the admin UI or targeted tests, capturing progress logs to confirm all phases succeed.

## Related References

- `./20-migration-orchestrator.md` for orchestrator flow and phase details.
- `./10-import-orchestrator.md` to compare importer responsibilities with projection work.
- `../10-DATABASES/02-db-working.md` for working database schema highlights.
- `lib/essentials/db_migrate/application/orchestrator/handles_migration_service.dart` for the service that sequences migrators and restores overrides.
- `lib/essentials/db_migrate/infrastructure/sqlite/migrators/messages_migrator.dart` as the canonical example.
