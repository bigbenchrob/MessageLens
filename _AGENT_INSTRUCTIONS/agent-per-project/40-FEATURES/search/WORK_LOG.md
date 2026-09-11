---
tier: feature
scope: work-log
owner: agent-per-project
last_reviewed: 2026-09-11
links:
	- ./CHARTER.md
	- ./TESTING_AND_MONITORING.md
tests: []
feature: search
doc_type: work-log
status: active
last_updated: 2026-09-11
---

# Work Log — Search

| Date | Change Summary | Author | Notes |
| --- | --- | --- | --- |
| 2025-11-06 | Seeded documentation scaffold for search feature. | GitHub Copilot | Added charter, data map, provider inventory, interactions, testing, and log template. |
| 2026-06-14 | Recorded graph-backed search state. | Codex | Search resolves graph `message_ss_id` evidence scopes through `lib/essentials/search` and the shared Message Evidence Spine; legacy `working.db` FTS is not an ordinary app path. |
| 2026-07-18 | Shipped declarative Search investigation compatibility. | Codex | Added an opaque generation owned by Search; Conversation excerpts carry originating provenance; effective right-panel state derives from identity compatibility while stored state remains restorable. |
| 2026-09-11 | Completed message-text search enhancement. | Codex | Added structured exact/prefix semantics, raw whitespace preservation, graph FTS5 over visible text, aligned highlighting, and per-term AND/OR composition across text and tags. Deferred Apple-stored link-preview indexing to a separate feature branch. |

## Open Stewardship Items
- Measure FTS-backed graph search latency against a representative non-private
  corpus and keep future evidence domains behind `GraphSearchRepository`.
