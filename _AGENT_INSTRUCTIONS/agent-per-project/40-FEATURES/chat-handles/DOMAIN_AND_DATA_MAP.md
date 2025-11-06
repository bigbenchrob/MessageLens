---
tier: feature
scope: domain-data-map
owner: agent-per-project
last_reviewed: 2025-11-06
links:
	- ./CHARTER.md
	- ./STATE_AND_PROVIDER_INVENTORY.md
tests: []
feature: chat-handles
doc_type: domain-data-map
status: draft
last_updated: 2025-11-06
---

# Domain & Data Map — Chat Handles

## Core Entities
- `HandleId` value object — canonical identifier shared across aggregates.
- `Handle` projection rows in `working.db` (`working.handles`).
- Import ledger tables: `import_handles`, `import_chat_handle_join`.

## Supporting Tables & Views
| Database | Table/View | Purpose | Notes |
| --- | --- | --- | --- |
| `db-import` | `handles` | Raw Apple handle rows with service + identifier. | Immutable staging data.
| `db-import` | `chat_handle_join` | Relates handles to chats in source ledger. | Feeds chat membership.
| `db-working` | `handles` | Canonicalized handles powering UI queries. | Updated via migrators.
| `db-overlay` | `handle_overrides` (planned) | User overrides for handle → participant mapping. | Consult manual link workflow.

## External Inputs
- Rust extractor surfaces raw handle metadata from `chat.db`.
- Manual override service writes via `ManualHandleLinkService`.

## Downstream Consumers
- Chats feature for participant roster.
- Messages feature for sender resolution.
- Search feature for handle-based lookups.

## Data Contracts
- Canonical handle must remain stable across re-imports.
- Service + normalized address pair uniquely identifies a handle.
- Manual overrides must reconcile with future imports without duplication.
