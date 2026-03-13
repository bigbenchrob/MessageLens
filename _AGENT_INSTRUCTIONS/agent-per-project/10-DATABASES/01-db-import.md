---
tier: project
scope: databases
owner: agent-per-project
last_reviewed: 2025-11-06
source_of_truth: doc
links:
  - ./00-all-databases-accessed.md
  - ./02-db-working.md
  - ./03-db-address-book.md
  - ./04-db-chat.md
  - ./10-group-import-working.md
  - ../20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md
  - ../20-DATA-IMPORT-MIGRATION/20-migration-orchestrator.md
  - ../20-DATA-IMPORT-MIGRATION/10-import-orchestrator.md
tests: []
---

# `db-import` — macOS Import Ledger (`macos_import.db`)

## Overview

`db-import` stores an append-only ledger of data extracted from macOS Messages (`db-chat`) and AddressBook (`db-address-book`). It preserves every source ROWID and batch, acting as the immutable bridge between the raw Apple databases and the app-facing projection in `db-working`.

- **Alias**: `db-import`
- **Physical File**: `~/Library/Application Support/com.bigbenchsoftware.MessageLens/macos_import.db`
- **Primary Consumers**: Import orchestrator, migration orchestrator, analytics/debug tooling

## File Location

| Item | Value |
| --- | --- |
| Directory | `~/Library/Application Support/com.bigbenchsoftware.MessageLens/`
| Filename | `macos_import.db`
| Provisioning | Created on demand by `sqfliteImportDatabaseProvider` (see below) |
| Backups | Nightly copy to `~/sqlite_rmc/backups/` via launchd cron |

Always let the provider create and open the file; manual SQLite clients will lock it while the app runs.

## Provider Access

- **Riverpod entry point**: `sqfliteImportDatabaseProvider`
- **Definition**: `lib/essentials/db/feature_level_providers.dart`
- **Type**: `Future<SqfliteImportDatabase>` (Sqflite-backed)

Access pattern:

```dart
final importDb = await ref.watch(sqfliteImportDatabaseProvider.future);
```

Do not instantiate `SqfliteImportDatabase` manually; the provider handles directory creation, debug settings, and graceful shutdown.

## Schema & Drift Definitions

`db-import` is a plain Sqflite database; schema definitions live alongside the import infrastructure. Key references:

- `lib/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart` — Sqflite helper and schema bootstrap.
- `_AGENT_INSTRUCTIONS/agent-per-project/20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md` — Canonical table/column descriptions.

Core tables include:

| Table | Purpose |
| --- | --- |
| `import_batches` | Audit log for each import run (timestamps, versions, paths). |
| `contacts` | AddressBook contacts with original `Z_PK`, organization flags, names. |
| `contact_phone_email` | Normalised phone/email rows keyed by `ZOWNER`. |
| `handles` | Raw chat handles from `db-chat`; retains original ROWIDs. |
| `chat_to_handle` | Membership mapping directly from Messages source data. |
| `messages` / `attachments` / `message_to_attachment` | Raw message payloads and attachments copied from `db-chat`. |
| `contact_to_chat_handle` | Confidence-scored linkages between AddressBook contacts and chat handles. |

## Typical Use Cases

- Inspect the latest import batch metadata before running migrations.
- Verify a particular contact/handle exists in the ledger before debugging projection issues.
- Diff raw source rows against the working projection to confirm migration invariants.

Because `db-import` is append-only, it provides a reliable audit trail for diagnosing data discrepancies without risking mutation of the UI-facing projection.

## Related Rules & Contracts

- **IDs never change**: Every ROWID from `db-address-book` and `db-chat` is preserved in `db-import` and passed through untouched to `db-working`. See `10-group-import-working.md` for the full contract.
- **Provider-only access**: Always obtain connections via `sqfliteImportDatabaseProvider`; direct connections create locking issues.
- **No business logic here**: `db-import` captures raw data. All transformations happen in the migration layer when projecting into `db-working`.

## Cross-References

- `10-group-import-working.md` — How `db-import` feeds `db-working`.
- `02-db-working.md` — Projection database consuming this ledger.
- `../40-INTEGRATION/import-orchestrator.md` — Pipeline that populates `db-import`.
- `../20-DATA-IMPORT-MIGRATION/20-migration-orchestrator.md` — Pipeline that reads from `db-import`.
