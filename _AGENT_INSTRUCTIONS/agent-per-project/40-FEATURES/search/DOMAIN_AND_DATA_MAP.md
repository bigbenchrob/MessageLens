---
tier: feature
scope: domain-data-map
owner: agent-per-project
last_reviewed: 2025-11-06
links:
	- ./CHARTER.md
	- ./STATE_AND_PROVIDER_INVENTORY.md
tests: []
feature: search
doc_type: domain-data-map
status: draft
last_updated: 2025-11-06
---

# Domain & Data Map — Search

## Core Components
- Search index (candidate: SQLite FTS tables) covering chats + messages.
- Query service orchestrating filtering and ranking.

## Supporting Tables & Views
| Database | Table/View | Purpose | Notes |
| --- | --- | --- | --- |
| `db-working` | `fts_messages` (planned) | Full-text index for message bodies. | Needs deterministic rebuild routine.
| `db-working` | `fts_chats` (planned) | Index for chat titles, participant names. | Consider overlay-merged names.
| `db-working` | `search_recent_queries` | Stores user query history. | Optional overlay table.
| External | Spotlight integration (future?) | Potential system-level search hook. | Research required.

## Data Sources
- Messages feature for content payloads.
- Chats feature for metadata and participant names.
- Chat handles feature for normalized identifiers.

## Downstream Consumers
- Search UI.
- Navigation deep links via `ViewSpec` conversions.
- Potential automation hooks (quick actions, shortcuts).

## Data Contracts
- Index must reflect overlay adjustments (manual handle links, pinned chats) after merge.
- Query API returns stable identifiers (chatId, messageGuid) for navigation.
- Support incremental index updates to avoid full rebuild each import cycle.
