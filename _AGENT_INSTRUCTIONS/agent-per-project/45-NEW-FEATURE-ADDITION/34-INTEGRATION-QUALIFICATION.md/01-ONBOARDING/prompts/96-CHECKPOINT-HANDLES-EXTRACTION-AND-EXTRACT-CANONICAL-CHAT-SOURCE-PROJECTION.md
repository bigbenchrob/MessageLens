# MessageLens Feature 34 — Prompt 96
## Checkpoint Handles Extraction and Extract Canonical Chat Source Projection

**Purpose:** Continue the bounded shared-transformation sequence from Response 92. First checkpoint Prompt 95/Response 95 if not already committed, then extract only the existing deterministic chat source-row-to-ledger transformation from the production ChatImporter into one pure, typed canonical function. This is not a new importer, witness, graph projection, or change to import policy.

## 1. Preflight and recovery

Work in `/Users/rob/Development/FlutterProjects/remember_every_text` on `fix/onboarding-import-stuck-state`. Establish actual HEAD, upstream divergence, tracked/index cleanliness, shared-instructions submodule identity and cleanliness, registered worktrees, and untracked baseline. Verify Contacts, Messages, and Handles implementation commits are in ancestry (`a36feac8a48d1702aad5830076157830d6efb975`, `d77d08c6c55e18ade47983fb959b8023c893283c`, `ae6aa6496e9dd98378c61be1aa7d7984d7207f4c`). Verify Prompt/Response 95 documentation checkpoint and push status. If not yet checkpointed, commit and push **only** Prompt 95 and Response 95 before edits; do not duplicate an existing checkpoint. Preserve every unrelated untracked file. Stop on material baseline discrepancies.

Read Responses 92–95, the canonical Project Conformance standard, project instructions, actual `chat_importer.dart`, source-scoped import schema and ledger API, existing chat tests, and relevant architecture tests. Capture a fresh source-only external baseline manifest outside the repository. Do not inspect real databases or archives.

## 2. Narrow scope

Permitted production edits: the existing source-scoped Chats importer and one pure sibling module such as `chat_source_projection.dart`. Permitted tests: pre/post actual-writer characterization, direct pure-projection tests, focused architecture/AST enforcement, and minimal existing chat-importer test adjustments that do not change expectations.

Forbidden: changes to SQL, source query order, paging, transactions, batch allocation, progress, error handling, duplicate/insertIgnore policy, source registration, schemas/migrations, Messages/Contacts/Handles/Attachments/joins importers, graph chat projection or `is_group` classification, canonical handles, rich text, FTS, AppCzar, Start Fresh, Local Data Repair, archive authority, production activation, signing, or release metadata unless an independently mandatory convention requires it. No app build, launch, real source read, or real data mutation.

## 3. Characterize the actual production writer BEFORE editing

Source-trace `ChatImporter.importChats(...)` and all shared row-formation paths. Inventory **every** persisted `chats` column from the actual schema, including packed/source identity, GUID, service fallback, group identifiers, read-date conversion, batch lineage, and any other current field. Document the exact source SQL, order, fallback/default/null semantics, duplicate handling, transaction and progress behavior, and error/omission policy. Do not infer columns from earlier summaries.

Create a synthetic `ReadOnlySourceDatabase` fixture using the actual production `ChatImporter` and actual disposable source-scoped ledger. Freeze full persisted row maps, exact IDs, source lineage, batch references, insert order, anomalies/omissions, duplicate/incremental rerun, progress and failure behavior. Include null, blank, whitespace, Unicode, anomalous GUID/service/group fields, Apple date boundaries, and any existing fallback. Test more than one page only if the actual production contract pages; never invent a paging path. Record the passing **pre-edit** characterization. If it cannot be done without changing writer behavior, STOP.

## 4. Extract only the pure deterministic row transformation

Introduce immutable typed input/output and one concrete function, conceptually `projectSourceChat(...)`, which yields exactly the existing ledger insert-value map (or typed omission only where already proven). Reuse `SourceScopedRowKey`, `DateConverter`, and other established pure authorities. Database-dependent lookups remain in the importer and are passed as explicit resolved inputs. No SQL, I/O, provider, mutable global state, clock, async, progress, mutation capability, UI, or alternative injected transformation strategy in the pure module.

Make the production importer consume that function on its sole row-formation path. Preserve source reads, ordering, transaction, inserts, counts, errors, and progress at their existing ownership points. Remove duplicate importer-local row mapping only when the parity tests demonstrate equivalence.

## 5. Exact parity and architecture proof

Rerun the **unchanged** actual-writer characterization against the refactored importer. Require equality of every material persisted field, ID, omission, fallback, anomaly, count, progress event, and duplicate/error result. Operational timestamps may be compared under their existing temporal contract, never fabricated as fixed values. Add direct pure-function tests for all actual columns, immutability, material/irrelevant input changes, and edge cases.

Add an architecture test proving the pure module's permitted dependencies, the one concrete importer call edge, and continued importer ownership of SQL, source state, transactions, progress, and writes. Verify graph chat/group projection remains untouched. A failed parity assertion is a STOP, not permission to rewrite expected behavior.

## 6. Validation and conformance

Run focused chat characterization and pure tests; Chats, Handles, Contacts, Messages, joins and source-scoped ledger regressions; graph chat/group/canonical identity regressions; AppCzar Onboarding/Data Update/Local Data Repair/Operating tests; archive/historical/attachment tests; complete architecture suite; analyzer; full deterministic Flutter suite; formatting/generated consistency; `git diff --check` and staged diff hygiene. Report actual unique full-suite counts rather than summing overlapping groups. Require Project Conformance PASS with BLOCKER 0 and SHOULD FIX 0.

No app build or live qualification.

## 7. Checkpoint and response

Only after all gates pass: commit and push a narrow implementation checkpoint (`refactor(import): extract canonical Chats source projection`), then write Response 96 and checkpoint/push Prompt 96 + Response 96 as a separate documentation-only commit. No force push, rebase, squash, unrelated staging, or submodule change. Report the final documentation commit in the handoff, not retrospectively inside its own response.

Response 96 must document baseline, prior documentation checkpoint, complete chat schema and actual writer call graph, pre-edit fixture and result, pure input/output contract, exact post-edit parity, regression results, architecture proof, conformance, precise changed-file list, commits, and final Git/worktree state.

Conclude with literal verdicts:

`HANDLES EXTRACTION CHECKPOINTED: YES / NO`

`ACTUAL CHATS IMPORTER CHARACTERIZED BEFORE EDITS: YES / NO`

`CANONICAL CHATS SOURCE PROJECTION IS PURE AND SHARED: YES / NO`

`PRODUCTION CHATS IMPORTER HAS ONE CANONICAL ROW-TRANSFORMATION PATH: YES / NO`

`CHATS PERSISTED OUTPUT, OMISSIONS, AND PROGRESS PARITY: PASS / FAIL / NOT REACHED`

`GRAPH CHAT/GROUP SEMANTICS UNCHANGED: YES / NO`

`FULL POPULATED RECONSTRUCTION WITNESS IMPLEMENTED: NO`

`DESTRUCTIVE OPERATING START FRESH IMPLEMENTED: NO`

`SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES / NO`

`PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES / NO`

`PROJECT CONFORMANCE: PASS / FAIL`

`READY FOR NEXT NARROW EXTRACTION: YES / NO`

`READY TO RESUME DESTRUCTIVE STAGE 2C: NO`

`READY FOR PRODUCTION APPCZAR CUTOVER: NO`

STOP. Do not begin Attachments, joins, rich text, graph projection, reconstruction witness, or production activation in this task.
