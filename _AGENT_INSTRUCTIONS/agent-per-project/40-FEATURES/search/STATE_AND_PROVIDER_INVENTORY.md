---
feature: search
doc_type: state-provider-inventory
owner: @rob
status: draft
last_updated: 2025-11-06
---

# State & Provider Inventory — Search

| Provider | Type | Parameters | Description | Downstream Users |
| --- | --- | --- | --- | --- |
| `searchQueryStateProvider` | @riverpod notifier | N/A | Holds active query string, filters, sorting state. | Search UI components.
| `searchResultsProvider` | @riverpod stream | query params | Streams paginated search results. | Result list view, quick jump features.
| `searchIndexStatusProvider` | @riverpod future | N/A | Reports index freshness and rebuild progress. | Settings/diagnostics UI.
| `searchRecentQueriesProvider` | @riverpod future | limit | Returns recent user queries. | UI suggestions, analytics.

## State Objects & Caches
- In-memory query cache keyed by normalized query.
- Index rebuild progress state persisted to overlay or local cache.

## Invalidations & Triggers
- Data imports/migrations trigger index update tasks.
- Manual handle or chat title overrides should invalidate associated index segments.
- Query state changes drive result provider recomputation.

## TODO
- Define canonical provider locations (likely under `features/search/application`).
- Investigate streaming results for long-running queries.
