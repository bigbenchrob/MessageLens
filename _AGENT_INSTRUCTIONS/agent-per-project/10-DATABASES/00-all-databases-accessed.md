---
tier: project
scope: databases
owner: agent-per-project
last_reviewed: 2025-11-06
source_of_truth: doc
links:
       - ../00-PROJECT/03-data-locations.md
       - ./03-db-address-book.md
       - ./04-db-chat.md
       - ./05-db-overlay.md
       - ./06-addressbook-path-resolution.md
       - ./07-overlay-database-independence.md
       - ../20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md
tests: []
---

# All Databases Accessed

This is the canonical index for every SQLite database the project touches. Treat it as the jumping-off point before drilling into individual docs.

## 🚨 Read This First

- **Resolve AddressBook paths via providers only.** Use `getFolderAggregateEitherProvider` (documented in `06-addressbook-path-resolution.md`). Never hardcode `/Sources/<UUID>/...`.
- **Do not open SQLite files directly.** Always go through the Riverpod providers declared in `lib/essentials/db/feature_level_providers.dart`. Extra connections will lock the file.
- **`db-import` and `db-working` are inseparable.** The import ledger feeds the working projection; never write across them manually. See `07-overlay-database-independence.md` for how working and overlay data converge in providers.
- **Shut everything down before manual access.** Quit the Flutter app and tooling prior to backups or ad-hoc SQL to avoid WAL/locking surprises.

## Canonical Database Aliases

Use these aliases consistently across docs, code comments, and conversations.

| Alias | Physical File | Primary Purpose | Provider Entry Point | Storage Location |
| --- | --- | --- | --- | --- |
| `db-address-book` | `AddressBook-v22.abcddb` inside the most recent `/Library/Application Support/AddressBook/Sources/<UUID>/` | macOS contact source of truth | `getFolderAggregateEitherProvider` → `AddressBookFolderAggregate.mostRecentFolderPath` | Resolved dynamically at runtime |
| `db-chat` | `chat.db` | macOS Messages source ledger | `PathsHelper.messagesDatabasePath` (import pipeline) | `~/Library/Messages/chat.db` |
| `db-import` | `macos_import.db` | Immutable staging register of Messages + AddressBook data | `sqfliteImportDatabaseProvider` | `~/sqlite_rmc/remember_every_text/macos_import.db` |
| `db-working` | `working.db` | Drift projection consumed by the Flutter UI | `driftWorkingDatabaseProvider` | `~/sqlite_rmc/remember_every_text/working.db` |
| `db-overlay` | `user_overlays.db` | Long-lived user overrides and preferences | `overlayDatabaseProvider` | `~/sqlite_rmc/remember_every_text/user_overlays.db` |

## Coupled Database Groups

- **`group-import-working-db`**: `db-import` and `db-working` operate as a pipeline. Source data (Messages + AddressBook) lands in `db-import`, then migrators/projectors translate it into normalized structures in `db-working`. All primary keys and relationships from the macOS sources are preserved during the import → projection handoff.

## Source → Projection Flow

```
macOS AddressBook (db-address-book)
            +
 macOS Messages (db-chat)
            ↓
     db-import (ledger)
            ↓
     db-working (projection)
            ↕
     db-overlay (user overrides merged by providers)
```

## Provider Access Map

- `db-address-book`: `getFolderAggregateEitherProvider` (features/address_book_folders) → `AddressBookFolderAggregate.mostRecentFolderPath`.
- `db-chat`: retrieved via `PathsHelper` inside the import pipeline (never opened directly by app code).
- `db-import`: `sqfliteImportDatabaseProvider` (generated from `sqfliteImportDatabase`).
- `db-working`: `driftWorkingDatabaseProvider` (generated from `driftWorkingDatabase`).
- `db-overlay`: `overlayDatabaseProvider` (generated from `overlayDatabase`).

## When to Touch What

| Need | Database(s) | Notes |
| --- | --- | --- |
| Inspect raw macOS Contacts | `db-address-book` | Only via provider overrides in tooling/tests; ensure Full Disk Access. |
| Inspect raw macOS Messages | `db-chat` | Read-only; consumed exclusively by the import orchestrator. |
| Verify import batches or schema diffs | `db-import` | Treat as append-only audit log; never mutate rows manually. |
| Debug app-visible state | `db-working` | Projection backing the UI. Manual edits are overwritten on the next migration. |
| Review manual overrides (handles, UI prefs) | `db-overlay` | Persistent user customizations. Follow overlay independence rules before editing. |

## Next References

- `03-db-address-book.md` — macOS AddressBook source database.
- `04-db-chat.md` — macOS Messages source database.
- `01-db-import.md` — Ledger details for the import database.
- `02-db-working.md` — Projection schema and usage notes.
- `05-db-overlay.md` — Persistent user overrides and preferences.
- `06-addressbook-path-resolution.md` — Provider chain for locating the live AddressBook.
- `07-overlay-database-independence.md` — Non-negotiable rule set for overlay/working separation.
- `10-group-import-working.md` — Contract tying the import and working databases together.
- `../20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md` — Table schemas for all ledger/projection databases.
