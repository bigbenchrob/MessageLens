---
tier: feature
scope: state-provider-inventory
owner: agent-per-project
last_reviewed: 2026-09-11
links:
	- ./CHARTER.md
	- ./DOMAIN_AND_DATA_MAP.md
	- ./SEARCH_SEMANTICS.md
tests: []
feature: search
doc_type: state-provider-inventory
status: current
last_updated: 2026-09-11
---

# State & Provider Inventory — Search

> Current conformance note (2026-09-11): current public providers are
> `searchServiceProvider` and `graphSearchRepositoryProvider` from
> `lib/essentials/search/feature_level_providers.dart`. Visible message text is
> indexed by graph-owned `message_text_fts` behind that repository contract.

| Provider | Type | Parameters | Description | Downstream Users |
| --- | --- | --- | --- | --- |
| `searchServiceProvider` | `@riverpod` service | graph search scope + structured query + AND/OR mode | Facade used by message evidence/search surfaces. | Message Evidence Spine, search result context surfaces. |
| `graphSearchRepositoryProvider` | `@riverpod` repository | graph DB + overlay DB | Composes per-term visible-text and tag hits, applies AND/OR, then applies saved/scope restrictions and the final result cap. | `SearchService`. |
| `currentSearchInvestigationProvider` | keep-alive generated notifier | none | Owns the opaque, generation-based identity of the current Search All Messages investigation. | Search transitions and effective panel compatibility. |
| `globalMessagesSearchSessionProvider` | keep-alive generated family notifier | optional month anchor | Owns query text and AND/OR mode for a global-message Search session; real mutations advance the current investigation generation. | Message evidence header and Search-page Track presentations. |
| `globalMessagesInvestigationActionsProvider` | generated action provider | none | Owns explicit primary-investigation transitions that are not query mutations; currently `browseMonth`. | Search sidebar heatmap. |
| `globalMessagesEvidencePresentationProvider` | generated presentation provider | optional month anchor | Merges the current Search session with asynchronous evidence state and prepares metadata plus the semantic Search Investigation Status model. | Search-page Track occupants and global message evidence. |

## State Objects & Caches
- `GraphMessageSearchScope`: global, conversation, handle, or contact-canonical-handle scope.
- `MessageTextSearchQuery`: unchanged editor text plus parsed exact/prefix
  tokens and the `is:saved` filter.
- `MessageTextSearchExecutionIntent`: cache-safe executable semantics without
  editor-only whitespace differences.
- Graph search result ids keyed by `message_ss_id`.
- Overlay saved/tag matches merged at read time.
- `SearchInvestigationId`: opaque monotonic generation. Equal query values do
  not imply the same investigative episode.
- `ConversationsSpec.conversationExcerpt.originatingInvestigationId`: opaque
  provenance carried by a subordinate Conversation presentation.
- Stored right-panel state is distinct from the effective right-panel stack
  derived by navigation compatibility.
- `SearchInvestigationStatusPresentationModel`: a prepared description plus
  whether the current query evidence is still unresolved. It is derived from
  the existing evidence `AsyncValue`; it is not an independent source of
  Search truth.

## Invalidations & Triggers
- Source-scoped graph builds and graph/message data-version bumps refresh searchable evidence.
- Overlay saved/tag/manual-link changes invalidate relevant evidence/search readers.
- Query state changes recompute graph repository searches for the selected logical scope.
- Query mutations, query clearing, AND/OR changes, and month browsing advance
  `SearchInvestigationId`.
- Navigating away and returning, opening an excerpt, or choosing another result
  inside the unchanged investigation do not advance it.
- The navigation resolver compares only opaque identity equality. It does not
  interpret query text, search mode, heatmap semantics, or result structure.
- The Search Investigation Status row derives activity from the current
  evidence request. Its 175 ms activity-indicator delay is presentation-local
  timing and does not introduce another application-state provider.

## Open Stewardship Items
- Do not add new search providers under `features/search/application` without first deciding to move search out of `essentials/search`.
- Keep future evidence domains behind `GraphSearchRepository`; do not widen
  `message_text_fts` beyond visible message text.
