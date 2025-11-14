# Modular FTS Indexing Proposal

## Summary
Introduce a modular search indexing subsystem that mirrors the existing migration orchestrator pattern. The system will coordinate independent indexers so that new search capabilities can be added, removed, or iterated without touching unrelated flows. Initial scope delivers an orchestrator plus two indexers: the current single-string lookup (formalized as a lexical indexer) and a new multi-term FTS indexer that supports ranked results for multiple terms.

## Motivations
- Current search only handles a single contiguous string; there is no native ranking or multi-term support.
- Planned semantic and emotional search modes require a scalable, testable indexing architecture.
- Past monolithic indexing/migration implementations were brittle and difficult to debug; we want isolated, composable components.

## Goals
- Define a SearchIndexOrchestrator that can rebuild all or selected indexes and run per-index validations.
- Extract the existing single-string search path into a dedicated `SimpleLexicalIndexer` with explicit rebuild/validate hooks.
- Implement a new `FtsMultiTermIndexer` that leverages `messages_fts` for ranked multi-term queries.
- Deliver documentation and tests so each indexer can be evaluated independently and in aggregate.

## Non-Goals
- No semantic synonym expansion, embeddings, or emotional scoring in this phase.
- No UI changes beyond wiring in the new search API; front-end updates may be deferred.
- No changes to migration pipelines beyond invoking the orchestrator after data import.

## Constraints & Considerations
- Indexers must run without relying on one another, drawing only from canonical working database tables.
- The orchestrator must support partial rebuilds (e.g., for a subset of message IDs) to keep future incremental updates feasible.
- Changes must follow the documented Riverpod and database access patterns (use providers, no direct db instantiation).

## Deliverables
1. Orchestrator interface and implementation with per-index validation.
2. `SimpleLexicalIndexer` extracted from current single-string search path.
3. `FtsMultiTermIndexer` providing ranked multi-term support.
4. Updated search service layer to route queries through the orchestrated indexes.
5. Automated tests covering orchestrator coordination and both indexers.
6. Documentation updates (design notes, checklist, tests) maintained in this feature folder.

## Risks
- Reusing existing triggers and FTS tables requires careful validation to avoid regressions.
- Partial rebuild support could complicate transaction handling if not scoped carefully.
- Need to ensure new orchestration points integrate cleanly with macOS app lifecycle without blocking UI.

## Open Questions
- What is the preferred entry point for triggering partial rebuilds (manual command, background task, UI control)?
- Should the orchestrator expose metrics or logging hooks for diagnostics?
- Do we need shims for older search APIs to preserve backwards compatibility during rollout?
