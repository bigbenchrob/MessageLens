---
feature: messages
doc_type: domain-data-map
owner: @rob
status: draft
last_updated: 2025-11-06
---

# Domain & Data Map — Messages

## Core Entities
- `Message` aggregate stored in `working.db` (`working.messages`).
- Attachments, reactions, and message metadata tables.

## Supporting Tables & Views
| Database | Table/View | Purpose | Notes |
| --- | --- | --- | --- |
| `db-import` | `messages` | Raw message payloads from `chat.db`. | Preserve GUID, ROWID, timestamps. |
| `db-import` | `message_attachment_join` | Connects messages to attachments. | Required for attachment projection.
| `db-working` | `messages` | Projection consumed by UI. | Includes derived columns (has_attachments, direction, status).
| `db-working` | `message_reactions` | Reaction events normalized for timeline. | Must merge duplicates gracefully.
| `db-working` | `message_attachments` | Attachment metadata and local cache pointers. | Align with file storage service.

## External Inputs
- Rust extractor for attributed bodies and inline metadata.
- Attachment downloaders / thumbnail generators.

## Downstream Consumers
- Messages UI timeline.
- Search (full-text indexing, filters).
- Analytics or export tooling.

## Data Contracts
- Message GUID and ROWID must remain stable across re-imports.
- Attachments must reference existing message rows before projection.
- Reaction aggregation must be deterministic when events arrive out of order.
