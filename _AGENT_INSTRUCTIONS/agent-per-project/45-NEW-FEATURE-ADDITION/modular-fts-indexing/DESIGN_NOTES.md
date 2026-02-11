# Modular FTS Indexing Design Notes

## Background
- Existing indexing relies on three structural tables (`global_message_index`, `message_index`, `contact_message_index`) populated during migration and maintained via triggers.
- Full-text search infrastructure (`messages_fts` + triggers) already exists but current search providers rely on `LIKE '%term%'` filters.
- Prior monolithic migration code created maintenance challenges; we will avoid repeating that pattern by isolating responsibilities per indexer with an orchestrator.

## Architecture Overview
```
SearchIndexOrchestrator
  ├── SimpleLexicalIndexer
  └── FtsMultiTermIndexer
```
- Orchestrator coordinates rebuild and validation across all registered indexers.
- Indexers implement a shared `SearchIndexer` contract with methods for full rebuild, optional partial rebuild, and validation.
- `SearchIndexContext` wraps the working Drift database and exposes helper utilities (batched message iteration, message hydration helpers, transaction helpers).
- Indexers operate independently using only canonical tables and context utilities; they never depend on each other.
- Day-to-day search freshness still relies on live triggers (e.g., `messages_fts` triggers). The orchestrator is a maintenance tool used for bootstrap, disaster recovery, schema evolution, and onboarding new indexers. Routine searches should not call `rebuildAll()` unless an operator explicitly requests it.

## Orchestrator Responsibilities
- Accept a list of indexers and execute them sequentially with clear logging and error isolation.
- Provide hooks:
  - `rebuildAll()`
  - `rebuildForMessages(Set<int> messageIds)` (fan-out only to indexers that support partial rebuilds)
  - `validateAll()`
- Integrate with post-migration flow (e.g., `HandlesMigrationService`) and optionally expose manual triggers (CLI command, debug panel).
- Maintain lightweight metrics (duration per indexer, error counts) and persist baseline state per indexer (`last_rebuild_started_at`, `last_rebuild_finished_at`, `last_rebuild_status`, optional `last_rebuild_message_count`). This can be a single logging utility or a small telemetry table and should be updated after each orchestrated run.
- Implementation detail (Step 1): the orchestrator currently persists run metadata via `SearchIndexMetricsRepository` (backed by `SharedPreferences`) and is invoked once per migration cycle immediately after the canonical indexes are rebuilt, ensuring SimpleLexical validation runs on freshly imported data.

## Indexer Contracts
```dart
abstract class SearchIndexer {
  String get id;
  Future<void> rebuildAll(SearchIndexContext ctx);
  Future<void> rebuildForMessages(SearchIndexContext ctx, Iterable<int> messageIds) => Future.value();
  Future<void> validate(SearchIndexContext ctx);
}
```
- `rebuildForMessages` defaults to a no-op; indexers override when partial rebuilds make sense.
- Each indexer owns its schema artifacts (tables, triggers) and documents assumptions.

## SimpleLexicalIndexer
- Purpose: encapsulate existing single-string `LIKE` search behavior to ensure backwards compatibility when other indexers are unavailable.
- This is a logical indexer; it does not create or maintain any physical index structures. Instead it verifies the canonical tables required for live queries remain healthy.
- Implementation notes:
  - `rebuildAll()` and `rebuildForMessages()` are no-ops; there is nothing to materialize.
  - Validation runs sample `LIKE` queries against `working_messages`, confirms essential columns exist, and ensures the legacy search path can still service requests.
- Step 1 extraction routed existing Riverpod providers through a dedicated `SearchService` so that future indexers can be introduced without rewriting UI hooks.
- Search usage: acts as a fallback plan or compatibility layer when FTS-based indexers are disabled or degraded.

## FtsMultiTermIndexer
- Purpose: own the physical FTS index (`messages_fts`) that powers ranked multi-term lexical search.
- Responsibilities:
  - Ensure `messages_fts` schema and triggers exist and match expectations.
- `rebuildAll`: truncate and repopulate `messages_fts` using batched inserts from `working_messages`. In normal operation triggers keep the table fresh; this hook is reserved for bootstrap or full resets.
- `rebuildForMessages`: delete rows matching message IDs (via rowid) and reinsert fresh content. Documented as an escape hatch for resyncing known-bad subsets when triggers are temporarily disabled or suspect.
- `validate`: sample row counts, verify triggers fire after message insert/update/delete, and execute smoke-test queries to confirm index health.
- Step 2 implementation batches inserts in slices of 10k rows to keep rebuild times predictable and uses `SharedPreferences` metrics to capture per-run timestamps alongside SimpleLexical stats.
- Query building and ranking logic (token normalization, AND/OR semantics, bm25 + recency blending) lives in `SearchQueryParser` / `SearchService`, keeping the indexer focused on maintenance.
- Integration plan:
  - Update search service to favor FTS results when the indexer is active and to combine bm25 scores with a lightweight recency boost (e.g., `finalScore = bm25 + λ * recencyBoost`, 0 ≤ λ ≤ 0.2).
  - Provide toggle/feature flag to fall back to SimpleLexicalIndexer if needed.

## Query Pipeline Adjustments
1. Parse raw user query into `SearchQuery` object (tokens, phrases, flags).
2. `SearchService` consults orchestrator to ensure necessary indexers are healthy (optional health check).
3. Build an FTS query string using normalized tokens and AND semantics (with optional OR/phrase support) and execute it to obtain bm25 scores.
4. Combine bm25 scores with a lightweight recency boost (e.g., `finalScore = bm25 + λ * recencyBoost`).
5. Apply existing joins to hydrate `ChatMessageListItem` results.
6. If FTS unavailable, fall back to SimpleLexicalIndexer path.
- Current implementation (Step 2) tokenizes on whitespace, sanitizes punctuation, and constructs a `token* AND token*` `MATCH` string. The ranking formula in `SearchService` is `score = (-bm25) + 0.15 * recencyBoost` where `recencyBoost = 1 / (1 + ageHours / 24)`. Results are hydrated via the existing `ChatMessageRowMapper` to keep formatting consistent with the legacy path.
- Feature flag `useFtsSearchByDefault` remains `false` by default; tests override it to exercise the multi-term path while legacy LIKE queries act as fallback whenever the flag is disabled or FTS returns no candidates.

## Testing Strategy
- Unit tests for orchestrator verifying:
  - Indexers invoked in order.
  - Errors in one indexer do not corrupt others.
  - Partial rebuild correctly targets only supporting indexers.
- Integration tests using in-memory Drift database covering:
  - SimpleLexicalIndexer validation and fallback search.
  - FtsMultiTermIndexer rebuildAll and rebuildForMessages flows.
  - Multi-term queries returning ranked results.
- Regression tests to confirm legacy single-term searches behave identically (result set + ordering) when FTS disabled.

## Future Extensions
- Additional indexers can be layered without architectural changes:
  - Semantic synonym/alias expansion (`SemanticLexiconIndexer`).
  - Embedding-based semantic search (`SemanticEmbeddingIndexer`).
  - Emotional tone features (`MessageEmotionIndexer`).
- Orchestrator supports optional registration so new indexers can be added incrementally.

## Execution Phases & Guardrails
1. **Step 1 – Orchestrator + SimpleLexicalIndexer only**
  - Implement `SearchIndexer`, `SearchIndexContext`, and `SearchIndexOrchestrator`.
  - Wire legacy single-string search through the orchestrated path without changing behavior.
  - Keep feature flags off; confirm all existing tests pass and legacy results are identical.
2. **Step 2 – FtsMultiTermIndexer & multi-term search**
  - Implement physical FTS maintenance (`rebuildAll`, `rebuildForMessages`, `validate`).
  - Add query parsing, ranking, and bm25 + recency blending outside the indexer.
  - Introduce a `useFtsSearchByDefault` (or equivalent) feature flag enabled only after manual validation.
3. **Step 3 – Pause before further scope**
  - After FTS rollout, evaluate results, refactor as needed, and plan semantic/emotional indexers as separate features to avoid a single massive refactor.

## Open Decisions
- How to expose orchestrator triggers to operators (CLI, debug UI, automated schedule).
- Whether to persist orchestrator run metadata for observability.
- Desired heuristics for combining FTS rank with recency or chat relevance.
