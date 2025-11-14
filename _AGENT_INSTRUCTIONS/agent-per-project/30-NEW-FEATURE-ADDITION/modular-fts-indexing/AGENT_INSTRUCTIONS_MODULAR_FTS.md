You are helping implement the **Modular FTS Indexing** feature for my macOS Flutter iMessage app.

## 0. Files you MUST read first

Before doing ANY code changes:

1. Carefully read these documents in this feature folder:
   - `PROPOSAL.md`
   - `DESIGN_NOTES.md`
   - `CHECKLIST.md`
   - `TESTS.md`

2. Do NOT start coding until you understand:
   - The role of `SearchIndexOrchestrator`, `SearchIndexer`, and `SearchIndexContext`.
   - The responsibilities and limits of:
     - `SimpleLexicalIndexer` (legacy single-term LIKE search, logical indexer only).
     - `FtsMultiTermIndexer` (physical FTS index for multi-term ranked search).
   - The phased execution guardrails:
     - Step 1: Orchestrator + SimpleLexicalIndexer only.
     - Step 2: FtsMultiTermIndexer + multi-term FTS search.
     - Step 3: Integration + validation.
   - That semantic/embedding/emotional indexers are explicitly OUT OF SCOPE for this feature.

If anything in the codebase appears to contradict the docs, assume the docs are the source of truth and propose doc updates.

## 1. Global guardrails

Follow these rules throughout:

1. **Phased execution (do not interleave):**

   - Finish **Step 1** (orchestrator + SimpleLexicalIndexer) and get it passing tests before you start **any** FTS-specific implementation.
   - Only then proceed to **Step 2** (FtsMultiTermIndexer + multi-term search).
   - Only after Step 2 is working and validated, do **Step 3** (integration, manual validation, cleanup).

   Do not start semantic synonym, embedding, or emotional indexers at all in this task.

2. **Small, discrete steps with verification:**

   For each checklist item you work on:

   - Implement only what is needed for that item.
   - Run the relevant tests (`flutter test` plus any narrower tests you add).
   - Fix issues until tests pass.
   - Only then move to the next checklist item.

3. **Respect modularity and independence:**

   - Indexers must only depend on canonical tables and `SearchIndexContext`.
   - Do NOT make indexers depend on each other’s tables, helpers, or internal logic.
   - `SimpleLexicalIndexer` is a logical indexer (no physical index); its rebuilds are no-ops and it focuses on validation and fallback behavior.
   - `FtsMultiTermIndexer` only owns schema/maintenance of `messages_fts` and related triggers; query building and ranking live in the search service / query parser.

4. **Orchestrator usage and rebuild semantics:**

   - The orchestrator is a **maintenance tool** (bootstrap, disaster recovery, schema changes, onboarding new indexers).
   - Routine search freshness should rely on triggers, NOT `rebuildAll()` being called on app startup.
   - `rebuildForMessages` is an escape hatch (e.g. when triggers are temporarily disabled or suspected of being out of sync), not a normal hot path.

5. **Feature flags and fallbacks:**

   - Keep FTS behind a feature flag (e.g. `useFtsSearchByDefault`) until manual validation is complete.
   - Ensure there is a clean fallback path:
     - If FTS is unavailable or disabled, the app must still work using the SimpleLexicalIndexer path (legacy LIKE searches).

6. **Documentation and test alignment:**

   Any time your implementation diverges from the existing docs, or you adjust behavior during review:

   - Update `CHECKLIST.md` to reflect what is done, what changed, and any new subtasks you introduced.
   - Update `TESTS.md` to:
     - Add new test cases or scenarios you created.
     - Update expectations if ranking/scoring behavior or failure modes changed.
   - If you make architectural changes or clarify trade-offs, update `DESIGN_NOTES.md`.
   - If you change scope/risks/goals, update `PROPOSAL.md`.

   Do NOT let the docs drift from the actual implementation.

## 2. Step-by-step execution order

### Step 1 – Orchestrator foundations + SimpleLexicalIndexer (no behavioral change)

Goal: Introduce the modular orchestrator and formalize the legacy search path WITHOUT changing observable behavior.

1. Implement `SearchIndexer` and `SearchIndexContext` exactly as described in the design notes.
2. Implement `SearchIndexOrchestrator`:
   - Sequential execution of indexers.
   - Error isolation (one failing indexer does not prevent others from running).
   - Logging and lightweight metrics per indexer (`last_rebuild_started_at`, `last_rebuild_finished_at`, `last_rebuild_status`, optional `last_rebuild_message_count`).
3. Implement `SimpleLexicalIndexer`:
   - `rebuildAll` and `rebuildForMessages` are no-ops (or pure validation helpers).
   - `validate` runs sample LIKE queries, checks required columns/indices exist, and ensures the legacy search path is healthy.
4. Wire the orchestrator into the existing migration/maintenance flow as described (e.g., call `rebuildAll()` after migrations, but do NOT make it part of normal app startup).
5. Update the search service / providers so that:
   - They call through the orchestrated path.
   - Behavior and results remain identical to current single-term LIKE search when FTS is disabled.
6. Run tests defined for this step in `TESTS.md` and update that file if you add new cases.
7. Once tests pass and behavior is confirmed identical, mark the relevant items in `CHECKLIST.md` as complete and adjust wording if you needed to tweak the plan.

Do NOT touch `messages_fts` or multi-term search logic in Step 1.

### Step 2 – FtsMultiTermIndexer + multi-term FTS search

Goal: Implement the physical FTS indexer and multi-term ranking, behind a feature flag.

1. Implement `FtsMultiTermIndexer`:
   - Own `messages_fts` schema and trigger expectations.
   - `rebuildAll` = truncate + bulk insert from `working_messages` in batches.
   - `rebuildForMessages` = delete + reinsert rows for specific message IDs as an escape hatch.
   - `validate` = row count checks, trigger smoke tests, and small sample queries.
2. Implement or extend the query pipeline (in search service / query parser, not in the indexer):
   - Parse user queries into tokens/phrases.
   - Build FTS query strings using AND semantics by default.
   - Execute FTS query, get bm25 scores.
   - Blend bm25 with a small recency boost (as described in `DESIGN_NOTES.md`), keeping the formula simple and clearly documented.
3. Integrate the FTS-backed path into search:
   - When the FTS feature flag is enabled and the index is healthy, use FTS results.
   - When disabled or unhealthy, fall back cleanly to SimpleLexicalIndexer.
4. Implement and run the tests listed for this step in `TESTS.md`, including:
   - Synthetic corpus ranking invariants (3-term > 2-term > 1-term).
   - End-to-end multi-term search with expected ranking.
   - Partial rebuild correctness.
5. Update `CHECKLIST.md` to reflect exactly what’s been implemented for FTS and what remains.
6. If you adjust the ranking heuristic, update `DESIGN_NOTES.md` and `TESTS.md` accordingly.

Do NOT add semantic synonyms, embeddings, or emotion scoring here. Only FTS lexical multi-term search.

### Step 3 – Integration, regression, and manual validation

Goal: Make sure the new indexing layer is wired through DI/providers, passes tests, and works in the macOS app.

1. Ensure provider graph / DI is updated so:
   - Orchestrator and indexers are constructed correctly.
   - Existing search providers use the orchestrated search service.
2. Run:
   - `flutter test` for the whole project.
   - Targeted integration tests described in `TESTS.md` (in-memory DB scenarios, rebuild flows, concurrency scenario).
3. Perform manual validation in the macOS app:
   - With the FTS feature flag OFF, confirm legacy single-term searches behave identically to the pre-feature behavior.
   - With the FTS feature flag ON, confirm multi-term searches behave as described in the design notes (ranking, fallbacks, reasonable performance).
4. Update `CHECKLIST.md` and `TESTS.md` with any notes from manual validation:
   - Document any deviations from the original expectations.
   - Add or adjust test scenarios if you discovered new edge cases.
5. Update `DESIGN_NOTES.md` with any final architectural decisions, trade-offs, or operational guidance (how to trigger rebuilds, approximate runtimes, known limitations).

Only after these are complete should you consider this feature “shipped” and ready to move into the `40-FEATURES/` documentation area.

## 3. Communication expectations

Throughout this work, whenever you respond:

- Explicitly state which checklist items you are addressing.
- Before changing scope or sequence, restate the guardrails and explain why the change is necessary.
- When you finish a step, summarize:
  - Code changes.
  - Tests added/updated.
  - Documentation updates in `PROPOSAL.md`, `DESIGN_NOTES.md`, `CHECKLIST.md`, `TESTS.md`.

Always keep the implementation, tests, and documentation in sync.