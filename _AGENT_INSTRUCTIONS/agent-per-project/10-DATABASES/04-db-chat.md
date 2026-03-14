---
tier: project
scope: databases
owner: agent-per-project
last_reviewed: 2026-03-13
source_of_truth: doc
links:
  - ./00-all-databases-accessed.md
  - ./01-db-import.md
  - ./10-group-import-working.md
  - ../15-MACOS-SOURCE-DATABASES/00-overview.md
  - ../15-MACOS-SOURCE-DATABASES/10-chat-db-orphan-messages.md
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

## Important Reality Check

Direct source-db inspection showed that `chat.db` contains a substantial population of message rows that are not linked by `chat_message_join`.

These orphan rows can still contain:

- plain text
- `attributedBody` rich text blobs
- attachment joins
- real handle linkage

Do not assume `message` plus `chat_message_join` gives a complete picture of all potentially meaningful source content. See `../15-MACOS-SOURCE-DATABASES/10-chat-db-orphan-messages.md`.

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
- `../15-MACOS-SOURCE-DATABASES/README.md` — Source-database behavior and reverse-engineering notes.
