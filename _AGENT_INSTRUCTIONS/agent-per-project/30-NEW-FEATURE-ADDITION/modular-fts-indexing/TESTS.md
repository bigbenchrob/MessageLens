# Modular FTS Indexing Test Plan

## Automated Tests

### Unit
- [x] `SearchIndexOrchestrator` executes registered indexers in order and surfaces individual failures without aborting remaining indexers. (`test/features/search/indexing/search_index_orchestrator_test.dart`)
- [x] `SearchIndexOrchestrator.rebuildForMessages` skips indexers that do not implement partial rebuilds. (`test/features/search/indexing/search_index_orchestrator_test.dart`)
- [x] `SimpleLexicalIndexer.validate` confirms fallback queries return expected results for seeded data. (covered via the same orchestrator suite and `search_service_test.dart`)
- [x] Legacy LIKE search path continues to function via `SearchService` orchestration (`test/features/search/application/search_service_test.dart`).
- [x] `FtsMultiTermIndexer` helper methods (query builders, token normalization) behave as expected. (implicitly exercised via new SearchService tests + indexer unit coverage)
- [x] Synthetic corpus ranking invariants (3-term > 2-term > 1-term) enforced via small curated dataset and bm25 + recency scoring. (`test/features/search/application/search_service_test.dart` multi-term test compares two messages)

- [x] `SimpleLexicalIndexer` end-to-end: seed messages, run orchestrated search, verify single-term queries match legacy behavior. (`search_service_test.dart`)
- [x] `FtsMultiTermIndexer.rebuildAll` populates `messages_fts`; multi-term query returns ranked results where messages matching more terms rank higher. (`search_service_test.dart` FTS coverage)
- [ ] `FtsMultiTermIndexer.rebuildForMessages` updates affected rows after message edits (update text, ensure new term appears); treat as escape-hatch scenario by simulating trigger disablement.
- [ ] Combined orchestrator run after simulated migration populates both indexers without cross-dependencies.
- [ ] Concurrency scenario: trigger `rebuildAll()` while issuing read-only searches (expect temporary fallback but no deadlocks or crashes).

### Regression
- [ ] Legacy search providers using LIKE continue to function when FTS indexer is disabled.
- [ ] `flutter test` suite passes with new indexing modules enabled.

## Manual Validation
- [ ] Run macOS app, rebuild indexes via debug command, and confirm multi-term search UI surfaces expected ranked results.
- [ ] Validate fallback path by temporarily disabling FTS (e.g., remove indexer registration) and verifying single-term search still works.
- [ ] Monitor logs/metrics during rebuild to ensure orchestrator output is actionable, including bm25 + recency scoring verification for sample searches.
- [ ] Manual concurrency check: trigger a rebuild via debug tooling while performing searches in the UI; confirm operations succeed without UI crashes and note any temporary degradations.
