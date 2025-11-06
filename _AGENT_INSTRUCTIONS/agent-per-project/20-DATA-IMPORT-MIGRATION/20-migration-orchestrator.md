---
tier: project
scope: data-import-migration
owner: agent-per-project
last_reviewed: 2025-11-06
source_of_truth: code
links:
  - ./01-overview.md
  - ./02-import-migration-schema-reference.md
  - ./10-import-orchestrator.md
  - ./25-table-migrators.md
  - ../10-DATABASES/02-db-working.md
---

# Migration Orchestrator

## Purpose
- Project staged ledger data (`macos_import.db`) into the UI-ready projection (`working.db`).
- Delegate work to focused migrators so validation, data movement, and error reporting stay table-specific.
- Preserve all source identifiers created during import (chat ROWIDs, handle ROWIDs, message ROWIDs, AddressBook `Z_PK` values).

## Entry Points
- Orchestrator: `lib/essentials/db_migrate/application/orchestrator/migration_orchestrator.dart`
- Service wrapper: `lib/essentials/db_migrate/application/orchestrator/handles_migration_service.dart`
- Base migrator helpers: `lib/essentials/db_migrate/application/services/base_table_migrator.dart`
- Migrator contract: `lib/essentials/db_migrate/domain/i_migrators.dart/table_migrator.dart`
- Progress events: `lib/essentials/db_migrate/domain/states/table_migration_progress.dart`

## Execution Model
1. **HandlesMigrationService** assembles the ordered migrator list (handles -> chats -> memberships -> participants -> messages -> attachments -> reactions -> read-state) and instantiates `MigrationOrchestrator`.
2. **Preparation** - Working tables are truncated (unless `dryRun`) while preserving user-managed overrides (`is_visible`, `is_blacklisted`) so they can be restored after projection.
3. **Dependency sorting** - `_sorted()` runs a Kahn algorithm across every migrator's `dependsOn`. Cycles throw immediately.
4. **Phase lifecycle** - For each migrator the orchestrator executes:
  - `validatePrereqs(ctx)` - no writes allowed; run anti-joins, integrity checks, duplicate detection.
  - `copy(ctx)` - transactional `INSERT ... SELECT` from the attached ledger. Skipped automatically in dry-run mode.
  - `postValidate(ctx)` - verify row counts, FK integrity, and canonical-map expectations.
5. **Health checks** - `ctx.ensureImportReady()` and `ctx.ensureImportClean()` guard each phase to catch lingering `ATTACH` statements or locked sqlite handles.
6. **Progress reporting** - `TableMigrationProgressEvent`s map to user-facing `DbMigrationProgress` updates (`preparingSources`, `migratingIdentities`, etc.). Failures surface clear phase names.

## Migrator Responsibilities
- Move rows only from the corresponding ledger table to the working table(s). No new IDs or relationships are created; link reconciliation already happened during import.
- Use canonical ID maps supplied by `MigrationContext` (e.g., `handleIdCanonicalMap`) rather than recalculating merges.
- Keep copy logic idempotent so reruns overwrite the same rows without duplication.
- Apply consistent validation using `BaseTableMigrator` helpers (`count`, `expectTrueOrThrow`, `expectZeroOrThrow`).

## Error Handling
- Migrator exceptions are wrapped by `_runPhase()`, logged with the phase label, and rethrown as `MigrationException` so the orchestrator halts immediately.
- `HandlesMigrationService` pushes a final progress update indicating success or failure and captures the error message in `DbMigrationResult`.

## When Adding Migrators
1. Implement the `TableMigrator` contract (prefer extending `BaseTableMigrator`).
2. Declare every parent table in `dependsOn` so topological sort enforces a valid order.
3. Attach the import database once per phase and detach in `finally` blocks when using custom SQL helpers.
4. Update `../10-DATABASES/10-group-import-working.md` if stage ordering changes.
5. Extend the progress stage mapping in `HandlesMigrationService._stageForTable` when introducing new table groups.
6. Verify overlay restoration logic still replays user overrides after the new migrator runs.
