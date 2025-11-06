---
tier: feature
scope: charter
owner: agent-per-project
last_reviewed: 2025-11-06
links:
	- ./DOMAIN_AND_DATA_MAP.md
	- ./STATE_AND_PROVIDER_INVENTORY.md
tests: []
feature: chats
doc_type: charter
status: draft
last_updated: 2025-11-06
---

# Feature Charter — Chats

## Mission
- Maintain the chat aggregate responsible for conversation metadata, membership, and derived counters.
- Provide a coherent experience across list views, detail panels, and background projections.

## Primary Outcomes
- Accurate chat summaries (last message, unread counts, pinned/archived state).
- Deterministic participant rosters synchronized with handle canonicalization.
- Efficient paging and filtering for the chat list.

## Success Metrics
- Chat list render time under target threshold.
- Zero drift between chat membership projection and source ledger.
- Reliability of unread counter updates during import/migration batches.

## Non-Goals
- Message rendering (covered by messages feature).
- Navigation shell layout (tracked separately).

## Stakeholders & Dependencies
- Depends on chat migrators, handle canonicalization, and overlay preferences.
- Feeds messages feature (chat context) and search indexing.

## Open Questions
- How to stage incremental sync for large chat histories without full re-projection.
- Preferred strategy for handling archived chats in navigation vs. search.
