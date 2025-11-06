---
tier: project
scope: databases
owner: agent-per-project
last_reviewed: 2025-11-06
source_of_truth: doc
links:
  - ./00-all-databases-accessed.md
  - ./01-db-import.md
  - ./10-group-import-working.md
  - ../20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md
tests: []
---

# `db-chat` — macOS Messages Source (`chat.db`)

`db-chat` is Apple Messages' live sqlite database. It provides chat, handle, and message source data that seeds the import ledger.

- **Alias**: `db-chat`
- **Physical File**: `~/Library/Messages/chat.db`
- **Primary Consumer**: Import orchestrator (read-only)

## Location & Access

| Item | Value |
| --- | --- |
| Path | `~/Library/Messages/chat.db` |
| Access pattern | Resolved via `PathsHelper.messagesDatabasePath` inside the import infrastructure |
| Permissions | Requires Full Disk Access |

The Flutter application never opens `chat.db` directly. The import pipeline copies data into `db-import`, where migrations can safely project it forward.

## Tables Consumed During Import

| Table | Purpose |
| --- | --- |
| `chat` | Chat metadata, GUIDs, style, service. |
| `handle` | Raw handle records (phone/email/service tuples). |
| `chat_handle_join` | Many-to-many linkage between chats and handles. |
| `message` | Message payloads, GUIDs, timestamps, delivery info. |
| `chat_message_join` | Mapping needed to associate messages with chats. |
| `attachment` / `message_attachment_join` | Attachments tied to messages. |

Importers persist these tables into ledger equivalents (`chats`, `handles`, `messages`, `chat_to_handle`, `chat_message_join`, `message_attachments`) while preserving the original ROWIDs. See `01-db-import.md` for ledger schema expectations.

## Usage Rules

1. **Never mutate** `chat.db`. Copy data into `db-import` and operate on the ledger instead.
2. **Respect ROWIDs/GUIDs**: Preserve all primary keys to maintain referential integrity across the import → migration pipeline.
3. **WAL discipline**: Close all application handles before running manual SQLite tooling to avoid write-ahead-log conflicts.
4. **Testing**: Provide fixture copies of `chat.db` when exercising import logic; avoid touching the live file in automated tests.

## Cross-References

- `01-db-import.md` — Ledger schema seeded from `chat.db`.
- `10-group-import-working.md` — Contract ensuring IDs survive into `db-working`.
- `../20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md` — Detailed ledger table definitions.
