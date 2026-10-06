---
tier: project
scope: data
owner: agent-per-project
last_reviewed: 2026-10-06
source_of_truth: code
links:
  - ../10-DATABASES/00-all-databases-accessed.md
  - ../10-DATABASES/01-db-import.md
  - ../10-DATABASES/02-db-working.md
  - ../10-DATABASES/05-db-overlay.md
  - ../10-DATABASES/06-addressbook-path-resolution.md
  - ../20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md
  - ../25-ONBOARDING-AND-ARCHIVE/40-attachment-archive.md
  - ../25-ONBOARDING-AND-ARCHIVE/ATTACHMENT-PRESERVATION-INVARIANT.md
tests: []
---

# Data Locations

This page lists runtime paths only. Schema, lifecycle, and access rules belong
in `../10-DATABASES/` and `../20-DATA-IMPORT-MIGRATION/`.

## MessageLens Runtime Data

The production macOS bundle stores runtime app data under:

```text
~/Library/Application Support/com.bigbenchsoftware.MessageLens/
```

Development normally uses:

```text
~/Library/Application Support/com.bigbenchsoftware.MessageLens.development/
```

A machine-local development launch may override that complete root through
`MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT`. The primary development machine
currently uses:

```text
/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development/
```

The override is development-only and fail-closed. Native and Dart admission
must independently resolve the same canonical existing directory. If the
configured external root is unavailable, MessageLens stops before persistent
provider construction rather than falling back. Production and test root
policies are unchanged.

On macOS the canonical override is the existing directory's POSIX `realpath`.
Equivalent absolute inputs—including trailing separators, `.` / `..`,
symlinks, and `/tmp` versus `/private/tmp`—must converge to the same exact
filesystem path independently on the native and Dart sides. Missing paths and
regular files are not normalized into admissible roots.

Current app-owned files/directories include:

| Data | Path | Owner |
| --- | --- | --- |
| Source-scoped import ledger | `macos_import_ss.db` | Physical construction: `sourceScopedImportDatabaseProvider` in `essentials/db`; ordinary import semantics: `sourceScopedImportLedgerProvider` |
| Conversation graph projection | `working_ss.db` | `driftConversationGraphDatabaseProvider`, graph projection/readers |
| Retired import cleanup file | `macos_import.db` | Transitional cleanup file only; no central app provider |
| Retired working cleanup file | `working.db` | Transitional cleanup file only; no central app provider |
| Overlay database | `user_overlays.db` | `overlayDatabaseProvider`, user-intent and archive-source metadata services |
| Attachment archive | `attachment_archive/` | Attachment archive service |
| Historical import/projection audit logs | `import_log`, `migrate_log` | Historical retired diagnostics; source-scoped graph status is reported through graph lifecycle/health surfaces |

The repository folder may still be named `remember_every_text`; do not confuse
the repo path with runtime storage paths.

All relative paths in the table are children of the admitted archive root.
Attachments do not have separate root-selection authority.

The common root does not imply a common deletion lifecycle. Source-scoped
import and graph stores are rebuildable; `attachment_archive/` is preservation
data. No ordinary reset, reimport, recovery, migration cleanup, or test cleanup
may delete the archive root or its payloads. See
[`ATTACHMENT-PRESERVATION-INVARIANT.md`](../25-ONBOARDING-AND-ARCHIVE/ATTACHMENT-PRESERVATION-INVARIANT.md).

## macOS Source Files

| Source | Path | Access rule |
| --- | --- | --- |
| Messages | `~/Library/Messages/chat.db` | Read-only through import/monitor infrastructure. Requires Full Disk Access. |
| AddressBook | `~/Library/Application Support/AddressBook/Sources/<UUID>/AddressBook-v22.abcddb` | Resolve through `getFolderAggregateEitherProvider`; never hardcode the UUID. |
| Messages attachments | `~/Library/Messages/Attachments/...` | Read-only source for attachment archiving/resolution; MessageLens never writes back here. |

## Backup Wording

The database providers do not own a nightly backup system. If a developer or
deployment environment configures external backups, treat that as operational
infrastructure outside the app code.

Do not document `~/sqlite_rmc/backups` as guaranteed app behavior unless code or
deployment automation in this repository owns that behavior.

## Manual SQL Rules

- Shut down the Flutter app and any tooling before opening SQLite files manually.
- Use the centralized providers from app code; direct extra SQLite connections
  can lock files.
- Never manually mutate `macos_import_ss.db`, `working_ss.db`,
  `macos_import.db`, `working.db`, or `user_overlays.db` as a substitute for
  source import, graph projection, retired-file cleanup diagnostics, or
  overlay service behavior.

## Schema References

- Physical app database filenames: `lib/essentials/db/app_database_files.dart`
- Source-scoped import DB provider: `lib/essentials/db/feature_level_providers.dart`
- Source-scoped import DB implementation: `lib/essentials/source_scoped_import/infrastructure/import_database_provider.dart`
- Conversation graph DB: `lib/essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart`
- Retired import/working DBs: no live providers or schemas remain; existing
  `macos_import.db` and `working.db` files are transitional cleanup storage only
  and may be inspected read-only by diagnostics or removed by reset cleanup.
- Overlay DB: `lib/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart`
- High-level summaries: `../20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md`
