---
tier: feature
scope: domain-data-map
owner: agent-per-project
last_reviewed: 2025-11-06
links:
	- ./CHARTER.md
	- ./STATE_AND_PROVIDER_INVENTORY.md
tests: []
feature: messages
doc_type: domain-data-map
status: draft
last_updated: 2025-12-23
---

# Domain & Data Map — Messages

This document nails down the *contact-scoped messages* implementation (“Messages for Contact”).
Chat-specific message UI has been intentionally removed for now.

## Core Entities
- **Message projection (working DB):** `workingMessages` (Drift table: `db.workingMessages`)
	- Consumed by UI as `ChatMessageListItem` (defined in `lib/features/messages/presentation/view_model/messages_for_chat_provider.dart`).
- **Contact ↔ message mapping:** `contact_message_index` (Drift table: `db.contactMessageIndex`)
	- Provides a stable ordering context for “messages with contact across all chats”.

## Contact Messages Ordering Model (Ordinal)

The UI never pages by “offset + limit” directly. Instead it uses an **ordinal** model:

- For a given `contactId`, the index layer exposes:
	- `totalCount`: number of messages available
	- `ordinal -> messageId` mapping
	- `monthKey -> firstOrdinal` mapping

This enables:
- fast list skeleton (count-only)
- stable scroll targeting (`jumpToLatest`, `jumpToMonth`)
- per-row hydration (`ordinal -> message`) without rebuilding the whole list

Canonical files:
- Ordinal/jump provider: `lib/features/messages/presentation/view_model/contact_messages/jump/contact_messages_ordinal_provider.dart`
- Index data source: `lib/features/messages/infrastructure/data_sources/contact_message_index_data_source.dart`
- Hydration provider: `lib/features/messages/presentation/view_model/contact_messages/hydration/message_by_contact_ordinal_provider.dart`

## Supporting Tables & Views
| Database | Table/View | Purpose | Notes |
| --- | --- | --- | --- |
| `db-working` | `workingMessages` | Primary UI projection for message rows. | Must include stable `id`, `guid`, `sentAtUtc`, sender handle refs.
| `db-working` | `contactMessageIndex` | Contact-scoped ordering and lookup. | Provides `messageId` ordering and month bucketing.
| `db-working` | `workingAttachments` (+ joins) | Attachments referenced by `ChatMessageListItem.attachments`. | Loaded via `attachment_info_loader.dart` when needed.

Notes:
- Import DB tables still exist and are essential to migration/import pipelines, but the contact-messages UI depends on the *working* projection.

## External Inputs
- Message import/migration populates `workingMessages` and `contactMessageIndex`.
- Rust extractor may enrich attributed bodies; contact messages UI currently uses `textContent` and attachment metadata.

## Downstream Consumers
- Contact Messages center panel UI.
- Search feature:
	- `contactMessageSearchResultsProvider` calls into `SearchService.searchContactMessages`, which joins `contactMessageIndex`.

## Data Contracts
- **ID stability:** `workingMessages.id` must be stable enough for scroll targeting and linking.
- **Index integrity:** every `contactMessageIndex.messageId` must exist in `workingMessages`.
- **Month key format:** `YYYY-MM` (e.g. `2025-12`) for jump behavior.
- **Maintenance safety:** during destructive DB maintenance/reset, contact messages providers must not open the DB.
	- The ordinal provider short-circuits to an empty state when `dbMaintenanceLockProvider` is true.
