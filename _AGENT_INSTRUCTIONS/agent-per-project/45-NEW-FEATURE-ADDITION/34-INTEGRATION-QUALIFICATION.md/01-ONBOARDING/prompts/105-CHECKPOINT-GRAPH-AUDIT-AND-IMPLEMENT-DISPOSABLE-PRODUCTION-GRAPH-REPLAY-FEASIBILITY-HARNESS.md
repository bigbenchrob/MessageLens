# MessageLens — Feature 34
## Prompt 105 — Checkpoint Graph Audit and Implement Disposable Production Graph Replay Feasibility Harness

**Milestone:** Test-only feasibility characterization of the actual production Conversation Graph writers against isolated synthetic source-scoped ledger and graph databases.

**Governing status:** Response 104 is an audit/design PASS, not a populated reconstruction proof. Destructive Operating Start Fresh / Stage 2C remains BLOCKED. Production AppCzar activation remains OFF. Seven jurisdictions remain unchanged.

### 1. Preflight and documentation checkpoint

Work only in `/Users/rob/Development/FlutterProjects/remember_every_text` on `fix/onboarding-import-stuck-state`. Verify actual HEAD and upstream synchronized 0/0; clean tracked worktree and index; shared-instructions submodule clean at `95326f515ef4719f155ce6e223990398daad6311`; exactly one Feature 34 branch worktree; preserve all unrelated untracked files. Verify ancestry of all eight source projection implementations and rich-text implementation `e340bdca0c6b8af9d40ab312a7f455d2fd9910db`.

Determine whether Prompt 104 and Response 104 have already been checkpointed and pushed together. If yes, record the exact documentation commit; do not duplicate. If not, stage/commit/push **only** Prompt 104 and Response 104 before test edits. Read canonical Project Conformance, global instructions, Responses 102–104, and the actual graph schema, repository constructors, projectors, ordering and existing tests. Capture an external source-only baseline and untracked inventory. Stop on material preflight discrepancy.

### 2. Strict permitted scope

Only these two test files may be added or edited:

- `test/essentials/conversation_graph/application/reconstruction/production_graph_replay_harness.dart`
- `test/essentials/conversation_graph/application/reconstruction/production_graph_replay_feasibility_test.dart`

Plus Prompt 105 and Response 105 records. Do not edit `lib/`, Rust, schema, migrations, generated files, dependencies, production providers, graph writers, AppCzar, reset, release metadata, or other tests. Do not create a production witness, comparator, policy, coordinator, or mutation capability. No build, app launch, real Messages/Contacts/MessageLens data access, external drive or archive access, FDA/TCC change, or S3 action.

### 3. Characterize actual current writer behavior before constructing the harness

Source-trace and document the real repository call edges, dependency injection, stage ordering, schema and transaction boundaries. Freeze expected outcomes from current committed tests and production SQL: `INSERT OR IGNORE` nonconvergence for existing contacts/chats, additive extra edges, canonical handle/alias preference, sender references, message classification, participant-derived `is_group`, FTS triggers, and source-registry packed IDs. Do not assume empty replay and populated replay are equivalent. If the test harness cannot use existing public production repository constructors without live/admitted providers, STOP rather than change production code.

### 4. Disposable harness

Construct only uniquely named temporary production-schema `ImportDatabase` and `ConversationGraphDatabase` files beneath a verified disposable test root. Verify every opened path belongs to that root. Ensure cleanup in `finally`, including failures. Use fixed source registry IDs, deterministic batch/row IDs, and an explicit starting graph state. Do not instantiate the app provider graph or use native source paths, archive bookmarks, live account readers, or installed app root. Call **actual** production graph repositories in their source-grounded order; never reimplement their transformations.

Bound the synthetic fixture to approximately <=50 messages, <=12 handles, <=8 contacts, <=8 chats, <=24 attachments, plus necessary relationships. Cover at minimum two source identities, ambiguous/unnormalizable handles and canonical alias preference, competing contacts, local-account input where safely injectable, participant ordering/group classification, associated and missing GUIDs, rich-text present/absent outcomes, duplicate raw join relationships, source-registry identity changes, and FTS text updates. Do not import or decode real user content.

### 5. Exact feasibility tests

Compare full material rows and edges across all actual graph tables, using deterministic sorted maps and bidirectional missing/extra/value differences in **test assertions** only. Keep the harness a characterization tool, not a production reconstruction witness.

Characterize separately:

1. Empty graph replay with fixed ledger/source IDs.
2. Repeated replay and idempotence.
3. Deliberately stale contact name, chat group state, and extra relationship edges; record literal nonconvergence, do not repair writers.
4. Full versus incremental replay where existing production entry points support it.
5. Historical-source projection and removal/reprojection where supported by existing injected APIs; preserve original registry identities.
6. Alias ambiguity, contact competition, sender/associated-message resolution, and missing endpoints.
7. FTS production-schema trigger effects and bounded representative search queries (case, diacritics, punctuation, 2/3/4 prefix, null text, Unicode). Do not claim exhaustive internal FTS equivalence from external-content rows or a finite query corpus.
8. Failure or cancellation between writer stages: document partial committed state and bounded cleanup, without asserting global transactionality.
9. No path escape, live provider construction, archive mutation, or protected-overlay write.

Where an existing API cannot safely exercise a scenario, mark it NOT QUALIFIED and explain rather than adding a production seam. A known material difference is a truthful characterization, not a test failure to conceal by adjusting expected outcomes.

### 6. Validation and performance

Run focused harness tests, relevant existing architecture tests, and `flutter analyze` on final test-only changes. Check formatting, `git diff --check`, and generated-source consistency. Do not run full Flutter suite unless canonical Project Conformance specifically requires it for this test-only milestone; if required, record why and run it. Record actual focused wall time and peak memory only when reliable measurement exists; target <10 seconds and roughly <64 MiB incremental RSS, but do not assert flaky time limits. Stop if unexplained nondeterminism, live dependency leakage, schema/production changes, unbounded resources, or incomplete mandatory safety conditions appear.

### 7. Checkpoints and Response 105

If and only if characterization, tests, safety gates and conformance pass, stage only the two authorized test files, commit and push a narrow implementation checkpoint. Create Response 105 with exact Git baseline, constructors/paths, test corpus, source-registry binding, writer order, complete material comparisons, known nonconvergence, FTS limitations, failure boundaries, performance evidence, test/analyzer results, conformance verdict, and any NOT QUALIFIED cases. Then checkpoint Prompt 105 and Response 105 separately and push normally. Never stage unrelated files or alter the submodule.

If a stop gate is encountered, revert only exploratory test changes, leave a truthful uncommitted Response 105, and STOP.

Conclude with:

`GRAPH AUDIT CHECKPOINTED: YES / NO`

`ACTUAL PRODUCTION GRAPH WRITERS EXERCISED ONLY AGAINST DISPOSABLE DATABASES: YES / NO`

`NO LIVE OR ADMITTED ROOT ACCESSED: YES / NO`

`EMPTY/REPEATED/STALE GRAPH BEHAVIOR CHARACTERIZED: YES / NO`

`FTS AND PROTECTED-REFERENCE LIMITATIONS RETAINED: YES / NO`

`COMPLETE POPULATED RECONSTRUCTION WITNESS IMPLEMENTED: NO`

`DESTRUCTIVE OPERATING START FRESH IMPLEMENTED: NO`

`SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES / NO`

`PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES / NO`

`PROJECT CONFORMANCE: PASS / FAIL`

`READY FOR NEXT SEPARATE EVIDENCE MILESTONE: YES / NO`

`READY TO RESUME DESTRUCTIVE STAGE 2C: NO`

`READY FOR PRODUCTION APPCZAR CUTOVER: NO`

Then STOP. Do not begin the populated witness, graph repair, or production cutover.
