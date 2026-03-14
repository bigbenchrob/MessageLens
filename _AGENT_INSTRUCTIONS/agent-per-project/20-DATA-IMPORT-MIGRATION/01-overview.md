---
tier: project
scope: data-import-migration
owner: agent-per-project
last_reviewed: 2026-03-13
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

## 🔥 Automatic Background Sync

**Imports are triggered automatically** — the app polls `chat.db` every **15 seconds** and runs import + migration when new messages are detected.

| Component | Purpose |
|-----------|---------|
| `ChatDbChangeMonitor` | Polls `MAX(ROWID)` from `chat.db`, triggers import on change |
| `ImportOrchestrator` | Runs table importers to stage new data in `macos_import.db` |
| `MigrationOrchestrator` | Projects ledger data into `working.db` (incremental mode) |
| `driftWorkingDatabaseProvider` | Invalidated after migration → UI automatically refreshes |

**Result:** New messages appear in the UI within ~15-20 seconds of arrival without user action.

See `10-import-orchestrator.md` for detailed auto-polling documentation.

## High-Level Flow

```
chat.db + AddressBook.sqlite
            │
    ┌───────┴───────┐
    │ ChatDbChange  │ ← polls every 15s
    │    Monitor    │
    └───────┬───────┘
            │ (triggers on ROWID change)
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

## Audit Logs

Every full or incremental pipeline run now writes two filesystem audit reports alongside the runtime databases:

- `~/Library/Application Support/com.bigbenchsoftware.MessageLens/import_log`
- `~/Library/Application Support/com.bigbenchsoftware.MessageLens/migrate_log`

Use these as the first stop when diagnosing import or projection anomalies. They capture:

- Source row counts from macOS `chat.db` and AddressBook
- Destination row counts in `macos_import.db` and `working.db`
- Rich-text extraction stats such as `messages.richTextApplied`
- Message text-presence counts before and after migration
- Source-vs-destination deltas that explain intentional JOIN-driven exclusions

## Current Source Reality: Chat-Orphan Messages

macOS `chat.db` can contain `message` rows that have no corresponding row in `chat_message_join`.

MessageLens now treats these source orphans as a first-class recovery path instead of silently leaving them outside the app's message model.

Current pipeline behavior:

- chat-linked source rows continue to flow into the normal `messages` ledger/projection path
- source orphan rows are preserved in dedicated recovered ledger tables
- recovered rich text and recovered attachment joins are preserved on that separate path
- migration projects them into dedicated recovered working-db tables rather than inventing a normal `chat_id`

Audit logs therefore now show both:

- the source orphan count from `chat.db`
- the preserved recovered-row count in ledger/projection tables

This distinction matters: a source-vs-thread-linked delta is no longer automatically equivalent to app-side invisibility.

## Recovered Context Reconstruction

The app's recovered browsing path deliberately separates **confirmed recovered rows** from **inferred nearby context**.

- confirmed rows are matched by surviving sender identity
- some outbound orphan rows preserve timing/content but lose handle identity
- contact-scoped recovered browsing can conservatively include nearby outgoing no-handle rows as best-guess context

This is an app-side recovery heuristic, not a claim that the source database proved original thread membership. Its purpose is to restore human-readable conversation meaning when Apple's visible thread graph no longer does.

## Operational Guardrails

- **Never bypass orchestrators.** Manual SQL shortcuts risk breaking the ID contracts that downstream providers rely on.
- **Treat ledger tables as append-only.** Corrections happen by re-running importers, not by editing rows in place.
- **Run migration after every successful import batch.** Projection is disposable; rebuilding is cheaper than debugging drift.
- **Keep the Rust extractor available.** Without `extract_messages_limited` the majority of messages land without bodies, crippling search and UI rendering.
- **Use incremental mode for existing data.** When working.db has existing rows, use `incrementalMode: true` to avoid DELETE bottlenecks. See `30-incremental-mode-flag.md` for details.

## Runbook Snapshot

| Action | Command / Trigger | Notes |
| --- | --- | --- |
| **Automatic sync** | Always running | `ChatDbChangeMonitor` polls every 15s; no user action required. |
| Manual full import + migration | `flutter run` -> Import control panel | Only needed for initial setup or recovery. |
| Headless import | `dart run tool/import.dart --dry-run` | Uses the same orchestrator stack; dry-run leaves the ledger untouched. |
| Inspect latest batch | `sqlite3 macos_import.db 'SELECT * FROM import_batches ORDER BY started_at DESC LIMIT 1;'` | Confirms source paths, batch IDs, and row counts. |
| Inspect latest audit logs | Open `import_log` / `migrate_log` in app-support directory | Use before inspecting tables manually; logs already summarize row deltas, text counts, and extractor health. |
| Rerun migration only | `HandlesMigrationService` via admin UI or script | Auto-detects incremental mode when working.db has data. Uses INSERT OR IGNORE for performance. |
| Force full migration | Set `incrementalMode: false` explicitly | Clears all tables and rebuilds from scratch. See `30-incremental-mode-flag.md`. |

## Related Reading

- `../10-DATABASES/10-group-import-working.md` - Contract binding import and projection.
- `../10-DATABASES/03-db-address-book.md` and `../10-DATABASES/04-db-chat.md` - Source database expectations.
- `../10-DATABASES/11-contact-to-chat-linking.md` - Verification path for participant linkage after migration.
