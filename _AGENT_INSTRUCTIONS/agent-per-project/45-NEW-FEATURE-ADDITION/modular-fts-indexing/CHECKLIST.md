# Modular FTS Indexing Checklist

> 🚦 **Execution guardrails**: ship Step 1 (orchestrator + SimpleLexicalIndexer) before starting Step 2 (FTS indexer). Enable FTS behind a feature flag and perform manual validation before flipping it on. Defer semantic/emotion indexers to future feature branches.

## Preparation
- [ ] Confirm proposal approval with stakeholders.
- [ ] Review existing indexing code paths and ensure no pending migrations are running.
- [ ] Capture baseline search performance metrics (single-term queries).

## Orchestrator Foundations
- [x] Define `SearchIndexer` interface (id, rebuildAll, rebuildForMessages?, validate).
- [x] Implement `SearchIndexContext` abstraction for shared data access.
- [x] Implement `SearchIndexOrchestrator` with sequential execution, error isolation, and logging.
- [x] Add integration point so migrations invoke `SearchIndexOrchestrator.rebuildAll()` after message imports.
- [x] Persist baseline metrics per indexer (`last_rebuild_started_at`, `last_rebuild_finished_at`, `last_rebuild_status`, optional `last_rebuild_message_count`).
- [x] Write unit tests for orchestrator sequencing, error handling, and context wiring.
- [ ] Document operational guidance: rebuilds are manual maintenance tasks (debug tooling / CLI), not part of normal app startup.

## SimpleLexicalIndexer Extraction
- [x] Identify current single-string search logic and extract shared code into new indexer module.
- [x] Implement `SimpleLexicalIndexer.rebuildAll()` (likely no-op or validation of base tables).
- [x] Implement validation that ensures fallback LIKE queries remain available.
- [x] Update search service to call through orchestrated API while preserving existing behavior when FTS is disabled.
- [x] Add tests verifying existing single-term search still works via orchestrated path.

## FtsMultiTermIndexer Implementation
- [x] Audit `messages_fts` schema and triggers; document expectations in design notes.
- [x] Implement `FtsMultiTermIndexer.rebuildAll()` to repopulate FTS table (truncate + bulk insert) if needed.
- [x] Implement optional `rebuildForMessages` for incremental updates (delete + reinsert specific rowids).
- [x] Implement validation ensuring row counts align with eligible messages and sample queries return expected hits.
- [x] Extend search service to construct multi-term FTS queries, consume ranking scores, and merge with existing filters.
- [x] Write tests covering multi-term ranking, term weighting, and fallback when FTS table unavailable.
- [x] Add synthetic corpus tests asserting ranking invariants (e.g., 3-term match scores higher than 2-term, which scores higher than 1-term).

## Integration & Regression Testing
- [ ] Update provider graph / DI bindings to expose orchestrator and indexers.
- [ ] Execute full test suite (`flutter test`) and address regressions.
- [ ] Run targeted database integration tests verifying rebuild and partial rebuild flows.
- [ ] Perform manual validation in macOS app for single and multi-term searches.

## Documentation & Handoff
- [ ] Update `DESIGN_NOTES.md` with architectural decisions and trade-offs.
- [ ] Add scenarios and acceptance criteria to `TESTS.md`.
- [ ] Document operations guidance (how to trigger rebuilds, expected runtime) in design notes.
- [ ] Prepare rollout plan (feature flags, metrics) if required by stakeholders.
- [ ] Obtain final approval and move documentation to `40-FEATURES/` when shipped.
