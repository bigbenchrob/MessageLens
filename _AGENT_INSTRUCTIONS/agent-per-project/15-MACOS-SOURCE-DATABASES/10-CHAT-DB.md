---
tier: project
scope: macos-source-databases
owner: agent-per-project
last_reviewed: 2026-09-15
source_of_truth: live-source-db-analysis
links:
  - ./00-overview.md
  - ./10-chat-db-orphan-messages.md
  - ./apple-typedstream-format-reference.md
  - ../20-DATA-IMPORT-MIGRATION/12-bounded-message-import-and-rich-text-enrichment.md
  - ../10-DATABASES/01-db-import.md
  - ../20-DATA-IMPORT-MIGRATION/10-import-orchestrator.md
tests: []
---

# `chat.db` Source Contract

`~/Library/Messages/chat.db` is an Apple-owned SQLite source database. MessageLens reads it as an external source contract; it does not own the schema, it must not write to it, and importer code must not infer columns or relationships from MessageLens ledger/working schemas.

This document is intentionally not an exhaustive schema dump. It records the app-relevant semantic access surface for readers and importers.

## Contract Rules

- Treat `chat.db` as read-only external source data.
- Verify source fields and relationship ownership before using them in importer logic.
- Do not infer source columns from MessageLens import ledgers, graph
  projection, retired cleanup databases, or Drift entities.
- Preserve source-local row identity as provenance, not canonical app identity.
- For multi-source/archive support, source provenance should include `source_id + source_table + source_rowid`.

## App-Relevant Tables

| Source table | App relevance |
| --- | --- |
| `message` | Message payload and source-local message row identity. |
| `handle` | Sender/contact endpoint identities used by messages and chats. |
| `chat` | Conversation/thread source rows. |
| `chat_message_join` | Owns message-to-chat membership. |
| `chat_handle_join` | Owns chat-to-handle membership. |
| `attachment` | Source attachment records and source path hints. |
| `message_attachment_join` | Owns message-to-attachment membership. |

## Relationship Ownership

Relationship ownership is the critical contract.

| Relationship | Source owner | Important clarification |
| --- | --- | --- |
| message → chat | `chat_message_join` | `message` does **not** directly own `chat_id`. |
| chat → handle | `chat_handle_join` | Chat participants are not inferred from message rows. |
| message → attachment | `message_attachment_join` | Attachments are associated through the join table, not by a direct message column. |
| message → sender handle | `message.handle_id` where present | This is sender/source handle provenance, not chat membership. |

Incorrect assumption identified: `message.chat_id` is not part of the observed source schema and must not be read directly from `chat.db.message`.

## `message`

App-relevant fields include:

| Field | Meaning for MessageLens |
| --- | --- |
| `ROWID` | Source-local message row id. Preserve as provenance, scoped to `source_id` and `source_table='message'`. |
| `guid` | Strong message identity/dedupe key when present. |
| `handle_id` | Source-local sender handle row id when present. |
| `service` | Source service such as iMessage/SMS. |
| `is_from_me` | Direction flag. |
| `date`, `date_read`, `date_delivered` | Source timing fields; conversion semantics belong in importer code. |
| `text` | Plain text payload when present. Absence of text is not evidence that the row is meaningless. |
| `attributedBody` | Rich text / typedstream payload when present. See `apple-typedstream-format-reference.md`. |
| `message_summary_info`, `payload_data` | Additional source blobs that may carry app-relevant payload details. |
| `item_type`, `associated_message_type`, `associated_message_guid`, `thread_originator_guid`, `balloon_bundle_id` | Message semantics, reactions, replies, plugin/balloon payloads, and threading clues. |

Do not assume every meaningful source row is linked to a chat. Rows lacking `chat_message_join` are source-orphaned from ordinary chat topology and must remain distinguishable. See `10-chat-db-orphan-messages.md`.

## `handle`

App-relevant fields include:

| Field | Meaning for MessageLens |
| --- | --- |
| `ROWID` | Source-local handle row id. |
| `id` | Raw address/identifier such as phone number, email, or service identifier. |
| `service` | Service context for the handle when present. |
| `country` | Region hint when present. |

Handle identity is source-local. Canonical contact/display identity is resolved
later through source-scoped import, graph projection, handle canonicalization,
overlay user intent, and AddressBook matching.

## `chat`

App-relevant fields include:

| Field | Meaning for MessageLens |
| --- | --- |
| `ROWID` | Source-local chat row id. |
| `guid` | Source chat guid when present. |
| `service_name` / service fields | Service context when present in observed source schemas. |
| display-name fields | Group/thread display hints when present. |
| `creation_date` | Source chat creation timing when present. Legacy import maps this to `chats.created_at_utc`. |
| `last_read_message_timestamp` | Source chat recency/read timing when present. Legacy import maps this to `chats.updated_at_utc`. |

Do not infer chat participants from `chat` alone. Participants are represented by `chat_handle_join`.

## `chat_message_join`

This table owns message-to-chat membership.

App-relevant fields include:

| Field | Meaning for MessageLens |
| --- | --- |
| `chat_id` | Source-local `chat.ROWID`. |
| `message_id` | Source-local `message.ROWID`. |
| `message_date` / ordering fields when present | Source ordering hints. |

Importer logic that needs a message’s chat must join through this table. A missing row is meaningful source topology absence, not permission to fabricate membership.

## `chat_handle_join`

This table owns chat-to-handle membership.

App-relevant fields include:

| Field | Meaning for MessageLens |
| --- | --- |
| `chat_id` | Source-local `chat.ROWID`. |
| `handle_id` | Source-local `handle.ROWID`. |

This relationship is the source fact for chat participant topology. Preserve it
through source-scoped import and project it as canonical `chat_to_handle`
graph edges; do not infer participants from chat rows or handle rows alone.

## `attachment`

App-relevant fields include:

| Field | Meaning for MessageLens |
| --- | --- |
| `ROWID` | Source-local attachment row id. |
| `guid` | Source attachment guid when present. |
| `filename` | Source path hint, not durable file availability. |
| `transfer_name` | User-facing/source transfer name when present. |
| `uti`, `mime_type` | Type hints. |
| `total_bytes` | Size hint. |
| created/date fields | Attachment timing hints when present. |

`attachment.filename` must be treated as a source path hint. iCloud/macOS storage optimization can leave rows and paths while removing local files.

## `message_attachment_join`

This table owns message-to-attachment membership.

App-relevant fields include:

| Field | Meaning for MessageLens |
| --- | --- |
| `message_id` | Source-local `message.ROWID`. |
| `attachment_id` | Source-local `attachment.ROWID`. |

Attachment relationships for source-orphaned messages must preserve the source topology while keeping recovered-unlinked content distinguishable.

## Importer Guidance

Before adding or changing a `chat.db` reader/importer:

1. Identify the source table that owns the fact or relationship.
2. Read only observed/source-documented fields.
3. Preserve source identity as `source_id + source_table + source_rowid`.
4. Keep source relationship identity separate from canonical app identity.
5. Add focused tests that would fail if an inferred source column is used.
6. Freeze the eligible message `ROWID` high-water, use keyset pages with an
   explicit projection, and defer later rows to the next run. Never select the
   entire message table or use `m.*` as an application-layer convenience.

Current graph-era invariant: message rows do not own chat membership. Preserve
message facts in the message importer, preserve chat/message topology from
`chat_message_join`, and keep canonical chat resolution out of message-row
import logic.

Current attributed-body decoding reads preserved ledger BLOBs in bounded
`ss_id`-keyed byte pages; it does not rescan this source database after message
facts have been imported. See the canonical bounded import document linked
above.
