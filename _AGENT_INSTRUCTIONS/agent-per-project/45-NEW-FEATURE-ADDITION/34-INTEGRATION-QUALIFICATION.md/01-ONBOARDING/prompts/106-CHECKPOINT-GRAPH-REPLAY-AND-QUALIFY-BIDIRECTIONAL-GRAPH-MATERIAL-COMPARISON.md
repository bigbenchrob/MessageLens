# MessageLens — Feature 34
## Prompt 106 — Checkpoint Graph Replay and Qualify Bidirectional Graph Material Comparison

**Milestone:** Test-only, schema-wide comparison characterization using the disposable production graph replay harness established in Response 105.

**Governing status:** Eight source-scoped projections and the rich-text semantic projection are qualified. Prompt 105 exercised actual production graph repositories against disposable production-schema databases. It did **not** establish equivalence for a populated installation, protected references, full FTS internals, or safe destructive Start Fresh. Production AppCzar activation remains OFF. Seven jurisdictions remain unchanged.

### 1. Preflight and prior documentation checkpoint

Work only in `/Users/rob/Development/FlutterProjects/remember_every_text` on `fix/onboarding-import-stuck-state`. Establish actual HEAD and upstream `0/0`, clean tracked worktree/index, shared-instructions submodule clean at `95326f515ef4719f155ce6e223990398daad6311`, one worktree on this branch, and an exact inventory of unrelated untracked files. Verify implementation commit `d364df01374abad9e1f8832fa04d70ed237715ff` and the earlier eight projections plus rich-text extraction in ancestry.

Determine whether Prompt 105 and Response 105 are already committed and pushed. If so, report the documentation checkpoint without duplication. If not, checkpoint **only** those two files and push normally before edits. Do not touch unrelated untracked files. Capture a source-only baseline outside the repository. Read the canonical Project Conformance standard, global project instructions, Responses 102–105, and actual graph schema, replay harness, and tests. On any material preflight contradiction, STOP.

### 2. Read-only comparator coverage audit before implementation

Inspect the current test-only replay harness and its comparator. Inventory every material graph table, key, column, nullability, identity, and relationship cardinality from the actual schema (currently schema version 3), including `messages`, `handles`, `canonical_handles`, `handle_aliases`, `chats`, `chat_to_message`, `chat_to_handle`, `contacts`, `contact_to_handle`, `attachments`, and `message_to_attachment`. Inspect `message_text_fts` separately: external-content reads do not establish internal index integrity.

For each material table, show exactly what the existing comparator reads, how rows are keyed and ordered, and whether it detects missing keys, extra keys, changed values, null-versus-absent distinctions, and duplicate/uniqueness differences. Do not assume a sorted snapshot or equal counts is a complete anti-difference proof. Record any gaps before modifying tests.

Classify comparison fields as material versus operational using source-grounded schema and writer behavior. Do not silently exclude a field because it appears operational. Preserve packed source identities, aliases, classifications, sender references, associated-message references, relationship pairs, and raw versus derived provenance distinctions.

### 3. Authorized implementation scope

Only the existing two Prompt 105 test files may change:

- `test/essentials/conversation_graph/application/reconstruction/production_graph_replay_harness.dart`
- `test/essentials/conversation_graph/application/reconstruction/production_graph_replay_feasibility_test.dart`

If a narrowly named additional test-only file is demonstrably necessary, STOP and request approval rather than expanding scope. No `lib/`, source importers, graph writers, database schemas, migrations, generated files, providers, FTS configuration, release metadata, archive, AppCzar, or Start Fresh edits.

Reuse the actual production-schema disposable ledger/graph and actual graph writer repositories. The comparison must be test-only and incapable of accessing the admitted/live root. Never create a production witness, evaluator, coordinator, repair operation, or mutation capability.

### 4. Characterize the comparator itself

Before changing its implementation, add or identify tests freezing its actual current behavior. Then improve only what is necessary for schema-wide material anti-differences. Require deterministic, bounded comparison output for:

- exact equality of two independent disposable graph snapshots;
- one expected row missing from observed;
- one extra observed row;
- one shared key with a changed material value;
- null versus non-null, including nullable message text;
- changed packed source identity with otherwise similar visible content;
- changed canonical representative or alias mapping;
- changed sender canonical/associated-message references and message semantic flags;
- changed participant-derived `is_group`;
- changed contact-to-handle material;
- extra/missing relationship endpoint pairs in each of the three graph join tables;
- changed attachment metadata;
- repeated replay equality and the previously qualified stale-contact, stale-chat, and extra-edge nonconvergence cases.

Use small synthetic data and deliberate test-only modifications of **disposable** observed graphs where needed to exercise comparator failure classification. Do not repair or normalize differences away. Assert stable table/key/field-specific diagnostics, not merely a boolean mismatch or aggregate count.

If duplicate rows are structurally forbidden by a primary key or unique constraint, characterize the constraint and test the relevant cardinality/identity behavior rather than manufacturing an impossible persisted state.

### 5. FTS boundary

Keep FTS comparison explicitly separate from material-table equivalence. Preserve Response 105's bounded search-query characterization, including its documented `co-op` parser limitation. Test-only FTS checks may use the disposable databases and production schema/triggers, but must not claim exhaustive FTS internal-index equivalence merely from external-content row reads or a finite query corpus.

If internal-index verification would require a new comparator architecture or unsafe live operations, record it as an unresolved future obligation; do not broaden Prompt 106. No live `rebuild`, `optimize`, or repair.

### 6. Boundedness and error semantics

Use a fixed, small synthetic corpus and deterministic key ordering. Comparison must account for every actual material table and column without relying on unbounded logs or dumping user content. Report bounded diagnostic summaries. Ensure both disposable database handles close and temporary roots are removed even on failures. Preserve stage-failure and replay nonconvergence observations as evidence, not test failures to be hidden.

Do not infer full-size production memory or time bounds from the small fixture. The Prompt 105 incremental RSS target remains unqualified unless separately measured with attributable evidence.

### 7. Validation and stop gates

Run focused characterization/comparator/replay tests, relevant architecture enforcement, analyzer, formatting, generated-code/diff hygiene, and canonical Project Conformance. Run the complete Flutter suite only if governing project instructions require it for this test-only scope; report clearly if not run. Record actual counts, errors, and retry provenance. Never sum overlapping groups as a unique total.

STOP AND REPORT if: the comparator cannot cover a material table/column without production changes; production writer instantiation leaks to live paths; test behavior requires changing schema, graph writers, FTS, or source identity policy; an observed mismatch is suppressed or converted to equality; a test needs real user data; a required check fails; or any unauthorized file changes. Restore exploratory tracked test changes to the baseline on a stop, preserving the evidence in Response 106.

### 8. Checkpoints and Response 106

Only after all gates pass, stage exactly the authorized test files, commit a narrowly named implementation checkpoint, and push normally. Create Prompt 106 and Response 106 documentation as a separate checkpoint and push normally, preserving unrelated untracked files. Do not build or launch the app.

Response 106 must include: baseline and Prompt/Response 105 checkpoint; exact graph schema/table/column coverage; pre-edit comparator behavior and gaps; final comparison algorithm and deterministic diagnostics; missing/extra/changed/null/identity/alias/classification/relationship test matrix; stale-populated nonconvergence results; FTS limitations; path isolation and boundedness; validation and conformance evidence; implementation and documentation commits; final Git state; remaining reconstruction proof obligations.

Conclude exactly:

`GRAPH REPLAY CHECKPOINTED: YES / NO`

`ALL MATERIAL GRAPH TABLES AND COLUMNS INVENTORIED: YES / NO`

`BIDIRECTIONAL MATERIAL GRAPH ANTI-DIFFERENCES QUALIFIED IN DISPOSABLE TESTS: YES / NO`

`KNOWN STALE-POPULATED NONCONVERGENCE PRESERVED AS MISMATCH: YES / NO`

`FTS INTERNAL EQUIVALENCE FULLY QUALIFIED: NO`

`COMPLETE POPULATED RECONSTRUCTION WITNESS IMPLEMENTED: NO`

`DESTRUCTIVE OPERATING START FRESH AUTHORIZED: NO`

`SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES / NO`

`PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES / NO`

`PROJECT CONFORMANCE: PASS / FAIL`

`READY FOR NEXT SEPARATE EVIDENCE MILESTONE: YES / NO`

`READY TO RESUME DESTRUCTIVE STAGE 2C: NO`

`READY FOR PRODUCTION APPCZAR CUTOVER: NO`

Then **STOP**. Do not implement a populated witness, protected-reference checker, production reset, or cutover in this task.
