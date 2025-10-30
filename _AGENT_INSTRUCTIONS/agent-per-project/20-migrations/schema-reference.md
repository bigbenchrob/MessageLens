---
tier: project
scope: data
owner: @rob
last_reviewed: 2025-10-30
source_of_truth: code
links:
  - ../../_shared/DDD/database-guidelines.md
  - ../../_shared/Riverpod/providers.md
tests: []
---

# Database Schema Reference

Authoritative table lists for the two SQLite databases this project maintains.
Consult this note before running ad-hoc SQL or modifying migrators.

## macos_import.db (Ingest Ledger)

Location: `~/sqlite_rmc/remember_every_text/macos_import.db`
Schema source: `lib/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart`

| Table | Purpose / Notes |
| ----- | --------------- |
| `schema_migrations` | Applied sqflite migration versions. |
| `import_batches` | Provenance for each ingest run (source paths, timestamps). |
| `source_files` | Checksums and metadata for every imported source file. |
| `import_logs` | Structured log events captured during ingest. |
| `contacts` | AddressBook `ZABCDRECORD` projection (preserves `Z_PK`). |
| `contact_phone_email` | Normalised phone/email values linked by `ZOWNER`. |
| `handles` | Raw chat.db handles (`ROWID` preserved in `id`). |
| `chats` | Raw chat.db chats (`ROWID` preserved). |
| `chat_to_handle` | Bridge joining chats ↔ handles (chat_handle_join). |
| `messages` | Full message rows including attributed bodies. |
| `chat_to_message` | Chat ↔ message join table (mirrors Apple linking). |
| `attachments` | Attachment metadata imported from chat.db. |
| `message_attachments` | Join table linking messages ↔ attachments. |
| `reactions` | Parsed tapback events (carrier + target metadata). |
| `message_links` | Extracted URL spans from messages. |
| `contact_to_chat_handle` | AddressBook ↔ handle matches with batch IDs. |
| `contacts_new` | Scratch table used during incremental contact imports (may be empty; never relied on at runtime). |

### Ledger Rules of Thumb
- Treat tables as append-only; mutation flags (`is_ignored`) gate projection without deleting history.
- Always insert within a recorded `import_batches` row so provenance is traceable.
- Before attaching this database in external tools, stop the Flutter app to avoid locking conflicts.

## working.db (Projection / Runtime)

Location: `~/sqlite_rmc/remember_every_text/working.db`
Schema source: `lib/essentials/db/infrastructure/data_sources/local/working/working_database.dart`

| Table | Purpose / Notes |
| ----- | --------------- |
| `schema_migrations` | Drift migration history. |
| `projection_state` | Singleton row tracking last projected batch and cursors. |
| `app_settings` | Key/value pairs for runtime configuration. |
| `handles` | Canonical messaging identities surfaced to the UI. |
| `handles_canonical` | Future-facing canonical handle store (one per endpoint). |
| `working_participants` | Contacts that participate in conversations. |
| `handle_to_participant` | Confidence-scored mapping of handles ↔ participants. |
| `handles_canonical_to_alias` | Alias records linking raw handles to canonical entries. |
| `chat_to_handle` | Chat membership resolved to canonical handles. |
| `chats` | Conversation metadata for presentation (last message, counts). |
| `messages` | Fully normalised message timeline consumed by widgets. |
| `attachments` | Projected attachment metadata (paths, hashes, direction). |
| `reactions` | Canonicalised reactions linked to handle IDs. |
| `reaction_counts` | Cached tallies per message for quick display. |
| `read_state` | Chat-level read markers. |
| `message_read_marks` | Per-message read receipts. |
| `supabase_sync_state` | Checkpoints for outbound sync processes. |
| `supabase_sync_logs` | Audit log for sync attempts. |

### Projection Rules of Thumb
- Population is idempotent: migrators use deterministic selects from `macos_import.db` and `INSERT OR REPLACE` semantics.
- Never modify rows manually; instead adjust the corresponding migrator and re-run projection.
- Any schema change must be reflected here **and** in the Drift definitions inside `working_database.dart`.

## Quick Checks
- Need table DDL? Run `dart run drift_dev schema dump` or inspect the schema files listed above.
- Unsure if a column exists? Search in the schema source files rather than guessing — both databases are versioned and enforced by migrations.
- See `_AGENT_INSTRUCTIONS/agent-per-project/20-migrations/migration-playbook.md` for operational steps before/after schema changes.
