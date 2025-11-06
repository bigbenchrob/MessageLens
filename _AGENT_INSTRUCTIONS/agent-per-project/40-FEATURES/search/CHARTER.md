---
tier: feature
scope: charter
owner: agent-per-project
last_reviewed: 2025-11-06
links:
	- ./DOMAIN_AND_DATA_MAP.md
	- ./STATE_AND_PROVIDER_INVENTORY.md
tests: []
feature: search
doc_type: charter
status: draft
last_updated: 2025-11-06
---

# Feature Charter — Search

## Mission
- Deliver unified search across chats, messages, and contacts with performant indexing and responsive UI.
- Provide extensible query capabilities (text, participants, dates, attachments) while respecting aggregate boundaries.

## Primary Outcomes
- Indexed corpus kept up-to-date with imports, migrations, and overlays.
- Search UI that supports fast filtering, result previews, and navigation into underlying features.
- Clear APIs for programmatic search (e.g., future automation or integrations).

## Success Metrics
- Query latency P95 under agreed threshold.
- Index freshness (time between data change and index update) within SLA.
- Relevance scores validated via curated test corpus.

## Non-Goals
- Analytics dashboards (belongs elsewhere).
- Navigation architecture beyond search entry points.

## Stakeholders & Dependencies
- Consumes chat, message, and handle projections.
- Publishes results to navigation system and feature panels.

## Open Questions
- What indexing backend will we ship (SQLite FTS vs. external service)?
- How do we prioritize ranking signals (recency vs. message importance)?
