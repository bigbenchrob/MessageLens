---
tier: feature
scope: interactions
owner: agent-per-project
last_reviewed: 2026-09-11
links:
	- ./CHARTER.md
	- ./STATE_AND_PROVIDER_INVENTORY.md
	- ./SEARCH_SEMANTICS.md
	- ../../42-SPEC-SYSTEM/CANONICAL-ARCHITECTURE/30-panel-viewspec-system.md
tests: []
feature: search
doc_type: interactions
status: current
last_updated: 2026-09-11
---

# Interactions & Navigation — Search

> Current conformance note (2026-07-18): search is graph-backed through
> `lib/essentials/search` and rendered through the Message Evidence Spine.
> Source-specific search controls may choose scope, but result evidence must
> remain graph `message_ss_id` evidence, not legacy `working.db` ids.

Query fields preserve the editor text exactly, including trailing whitespace.
That whitespace completes the preceding token for exact matching. AND means
**Match all terms** and OR means **Match any term** across visible message text
and message tags; `is:saved` and the selected scope remain mandatory filters.
See [`SEARCH_SEMANTICS.md`](SEARCH_SEMANTICS.md) for the complete contract.

## Primary Entry Points
- Message evidence header search within the selected logical scope.
- Search All Messages / global graph message search.
- Bounded search-result context views that preserve the selected result while
  showing surrounding evidence.

## User Flows
1. **Enter Query** — header/search surfaces update typed search state for the
   selected evidence scope.
2. **Resolve Matches** — graph search returns `message_ss_id` matches for the
   full selected logical scope.
3. **Navigate Result** — result-context routes produce a bounded
   `MessageEvidenceScope`; the center panel renders through shared evidence
   widgets.
4. **Refine Scope** — participant, handle, conversation, saved, or tag filters
   create different graph scopes without creating source-specific renderers.

All Messages rows with canonical Conversation identity may request a bounded
Conversation excerpt, whether they appear in ordinary browsing, month browsing,
or query results. Search text controls highlighting and evidence scope; it is
not an eligibility gate for Conversation navigation.

## Search Investigation Compatibility

The user's current Search investigation is primary state. A selected result,
Conversation excerpt, selected-message anchor, and right-panel visibility are
subordinate presentations.

`SearchInvestigationId` is an opaque generation, not a structural tuple of
query values. It advances when the primary investigation changes:

* query text changes, including clear via the actual clear-button path
* AND/OR mode changes
* month browsing begins

It does not advance when the user temporarily leaves Search, returns unchanged,
opens a Conversation excerpt, or selects another result within the same
investigation.

A Search-created Conversation excerpt carries the current identity as opaque
provenance. The stored excerpt is effective only while:

```text
Search All Messages is active
AND
originating investigation == current investigation
```

When this fails, the stored spec is retained but the effective right-panel
stack is empty. Sidebar visibility and the selected-message anchor disappear
because they consume effective state. No query field, heatmap, or mode control
issues `clear`, `close`, or `dismiss` commands.

This permits temporary navigation away and back to restore unchanged work while
preventing query A -> query B -> query A from reviving context created by the
earlier occurrence of query A.

This is an application of the
[Mechanical Impossibility Principle](../../00-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION/10-MESSAGE-LENS-ARCHITECTURAL-CONSTITUTION.md#the-mechanical-impossibility-principle):
an incompatible excerpt can remain stored for restoration purposes, but it
cannot become effective under the wrong investigation.

## Investigation Status Presentation

Search All Messages presents one Search Investigation Status row below its
controls. The row describes the active investigation and derives its activity
state from the same asynchronous evidence request that supplies results. It is
not a second loading-state authority.

The row is one Track occupant whose presentation changes in place. Searches
that remain unresolved for 175 ms show an integrated activity indicator and
`Searching...`; faster searches never flash activity chrome. Completed and
active presentations retain the same natural vertical geometry.

The status description aligns to the Search field through their shared leading
slot presentation contract. The row contains no discretionary vertical
padding; reviewed separation from message content remains an explicit ordinary
fixed-height occupant in the page matrix.

## Cross-Feature Touchpoints
- Messages: shared evidence header, skeleton, hydration, term highlighting,
  and result-context navigation.
- Conversations: conversation-scoped search and result context.
- Contacts/handles: contact and handle-scoped search through canonical graph
  identity plus display identity resolution.
- Overlay: saved/tag/user-intent search is merged through named graph
  repository boundaries.

## Navigation Guardrails
- Search execution belongs behind graph search boundaries; Search interaction
  state and transitions belong in the Messages application layer. Header
  widgets render controls and emit intent without performing Search semantics.
- Widgets emit Search intent only. Search-owned transitions advance the
  investigation; navigation derives compatibility; Conversations carries but
  does not interpret Search provenance.
- Pagination is not timeline navigation. Timeline-like search scopes preserve
  the full skeleton while hydrating visible rows.
- Do not reintroduce `working.db` FTS/index fallback as ordinary search
  behavior.

## Outstanding Decisions
- Whether a future dedicated search workspace is needed beyond embedded
  evidence-scope search.
- Whether graph-native acceleration is needed behind `GraphSearchRepository`
  after ordinary search latency is measured.
