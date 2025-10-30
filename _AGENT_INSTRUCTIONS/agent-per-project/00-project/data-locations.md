---
tier: project
scope: data
owner: @rob
last_reviewed: 2025-10-25
source_of_truth: doc
links: []
tests: []
---
# Data Locations (No Secrets)

## Local SQLite Stores
- **Import ledger** (`macos_import.db`): `~/sqlite_rmc/remember_every_text/macos_import.db`
  - Staging copy populated directly from macOS `chat.db` and AddressBook exports.
  - Immutable history: each ingest appends to `import_batches`; never edit rows in place.
- **Working projection** (`working.db`): `~/sqlite_rmc/remember_every_text/working.db`
  - Drift-managed database consumed by the Flutter app.
  - Always let migrators/projectors write to it; opening it in another SQLite client while the app runs will deadlock the orchestrators.

## macOS Source Files
- Messages: `~/Library/Messages/chat.db`
- Contacts: `~/Library/Application Support/AddressBook/Sources/<UUID>/AddressBook-v22.abcddb`
  - The `<UUID>` folder varies per machine. Resolve it via `getFolderAggregateEitherProvider` (see `_AGENT_CONTEXT/01-addressbook-database-resolution.md` until the integration note migrates) instead of hard-coding a path.

## Operational Notes
- Keep both `macos_import.db` and `working.db` backed up under `~/sqlite_rmc/backups` (daily cron job runs via `launchd`; check the repo scripts if it fails).
- Before running manual SQL, shut down the Flutter app and any tooling that might hold a lock.
- Schema definitions live in:
  - Import DB: `lib/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart`
  - Working DB: `lib/essentials/db/infrastructure/data_sources/local/working/working_database.dart`
  - High-level summaries: `_AGENT_INSTRUCTIONS/agent-per-project/20-migrations/schema-reference.md`
- Migration playbooks and smoke-query checklists: `_AGENT_INSTRUCTIONS/agent-per-project/20-migrations/`
