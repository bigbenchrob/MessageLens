---
tier: project
scope: data-import-migration
owner: agent-per-project
last_reviewed: 2025-11-06
source_of_truth: doc
links:
      - ./02-import-migration-schema-reference.md
      - ./10-import-orchestrator.md
      - ./11-rust-message-extractor.md
      - ./20-migration-orchestrator.md
      - ./30-incremental-mode-flag.md
      - ../10-DATABASES/00-all-databases-accessed.md
tests: []
---

# Import ⟶ Migration Overview

This folder documents the end-to-end data pipeline that keeps Remember Every Text in sync with the macOS Messages and AddressBook sources. Use it as the starting point whenever you touch ledger ingestion, projection, or the Rust helper binary.

## High-Level Flow

```
chat.db + AddressBook.sqlite
            │
            ▼
      ImportOrchestrator
            │ (per-table importers)
            ▼
     macos_import.db (ledger)
            │
            ▼
     MigrationOrchestrator
            │ (per-table migrators)
            ▼
      working.db (projection)
            │
            ▼
 overlay merge providers
```

- **Import phase** pulls raw data out of the system databases and stages it in `macos_import.db` without mutating the originals. Each table importer owns validation, copying, and post-flight checks for a single ledger table.
- **Migration phase** reads the ledger and constructs the UI-facing projection in `working.db`, preserving every identifier emitted by import. Migrators are sequenced so dependency ordering (handles -> chats -> messages, etc.) is enforced automatically.
- **Overlay providers** merge user overrides at runtime; they are documented in `../10-DATABASES/05-db-overlay.md` and operate strictly after projection.

## Responsibilities

| Concern | Owner | Document |
| --- | --- | --- |
| Table import sequencing, validation, logging | `ImportOrchestrator` | `10-import-orchestrator.md` |
| Rich text extraction for attributed bodies | Rust helper binary | `11-rust-message-extractor.md` |
| Projection + canonical ID preservation | `MigrationOrchestrator` | `20-migration-orchestrator.md` |
| Incremental mode for existing data | Migrators + MigrationContext | `30-incremental-mode-flag.md` |
| Schema expectations for both databases | Drift + Sqflite schema | `02-import-migration-schema-reference.md` |

## Operational Guardrails

- **Never bypass orchestrators.** Manual SQL shortcuts risk breaking the ID contracts that downstream providers rely on.
- **Treat ledger tables as append-only.** Corrections happen by re-running importers, not by editing rows in place.
- **Run migration after every successful import batch.** Projection is disposable; rebuilding is cheaper than debugging drift.
- **Keep the Rust extractor available.** Without `extract_messages_limited` the majority of messages land without bodies, crippling search and UI rendering.
- **Use incremental mode for existing data.** When working.db has existing rows, use `incrementalMode: true` to avoid DELETE bottlenecks. See `30-incremental-mode-flag.md` for details.

## Runbook Snapshot

| Action | Command / Trigger | Notes |
| --- | --- | --- |
| Full import + migration | `flutter run` -> Import control panel | UI invokes orchestrators with progress reporting. |
| Headless import | `dart run tool/import.dart --dry-run` | Uses the same orchestrator stack; dry-run leaves the ledger untouched. |
| Inspect latest batch | `sqlite3 macos_import.db 'SELECT * FROM import_batches ORDER BY started_at DESC LIMIT 1;'` | Confirms source paths, batch IDs, and row counts. |
| Rerun migration only | `HandlesMigrationService` via admin UI or script | Auto-detects incremental mode when working.db has data. Uses INSERT OR IGNORE for performance. |
| Force full migration | Set `incrementalMode: false` explicitly | Clears all tables and rebuilds from scratch. See `30-incremental-mode-flag.md`. |

## Related Reading

- `../10-DATABASES/10-group-import-working.md` - Contract binding import and projection.
- `../10-DATABASES/03-db-address-book.md` and `../10-DATABASES/04-db-chat.md` - Source database expectations.
- `../10-DATABASES/11-contact-to-chat-linking.md` - Verification path for participant linkage after migration.
