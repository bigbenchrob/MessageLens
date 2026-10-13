# MessageLens — Feature 34
## Prompt 101 — Checkpoint Chat–Handle Extraction and Extract Canonical Message–Attachment Relationship Source Projection

**Milestone:** Third and final source-scoped relationship row-formation extraction. **Not** a reconstruction witness, archive repair, or authorization for destructive Start Fresh or production AppCzar.

### 1. Preconditions and documentation checkpoint

Work only in `/Users/rob/Development/FlutterProjects/remember_every_text` on `fix/onboarding-import-stuck-state`. Verify HEAD and upstream are synchronized (0/0), tracked worktree and index clean, shared-instructions submodule clean at `95326f515ef4719f155ce6e223990398daad6311`, exactly one Feature 34 worktree, and all unrelated untracked files untouched. Verify the prior extraction ancestry, including `32b18a6add2e0280f089f21db0af48a4aaebcc12` (Chat–Handle), `59f86153` (Chat–Message), and the five scalar projection commits recorded in Response 100. Confirm whether Prompt 100 and Response 100 have already been committed and pushed as a documentation-only checkpoint; if not, checkpoint **only those two** and push before source edits. Never duplicate an existing checkpoint. Record actual current HEAD, not an assumed one.

Read canonical Project Conformance, applicable agent instructions, Responses 91–100, especially Response 98's relationship audit and Response 100's parity methods. Capture a fresh source-only baseline manifest outside the repository. No real Apple Messages/Contacts, MessageLens databases, WD/Toshiba archives, installed apps, or external drive access.

### 2. Exact scope

The selected production family is `MessageAttachmentJoinImporter`, source table `message_attachment_join`, ledger table `message_to_attachment`. Source-audit actual current file names and interfaces before proceeding. Permitted production edits: **only** the current Message–Attachment join importer and one new pure sibling named according to existing conventions, e.g. `message_attachment_relationship_source_projection.dart`. Permitted tests: one actual-production-writer pre/post characterization test, one direct pure projection test, and one narrow AST/dependency authority test; modify existing tests only if indispensable to preserving literal current semantics and explain any expansion. Do not modify source SQL, schema, migrations, graph, FTS, rich text, Contacts, scalar importers, other join importers, archive/payload logic, AppCzar, Start Fresh, production composition, generated code, package/release metadata, or signing. No app build or launch.

### 3. Trace and freeze the unchanged production writer FIRST

Before editing production code, enumerate and record the exact current call graph, source port, cursor, query, ordering, batch lifecycle, transaction, endpoint admission, row formation, insert-ignore, progress, result, error, and close semantics. The Response 98 audit reports:

```sql
SELECT maj.ROWID AS source_rowid,
       maj.message_id,
       maj.attachment_id,
       m.ROWID AS existing_message_rowid,
       a.ROWID AS existing_attachment_rowid
FROM message_attachment_join maj
LEFT JOIN message m ON m.ROWID = maj.message_id
LEFT JOIN attachment a ON a.ROWID = maj.attachment_id
ORDER BY message_id ASC, attachment_id ASC
```

Incremental import adds `WHERE maj.message_id > ?` before that ordering, with the orchestrator-supplied starting source Message ROWID. **Verify the exact implementation rather than trusting this audit summary.** The existing query materializes the complete selected result; do not introduce paging or alter its work bounds in this extraction.

Response 98 records that source opening and query occur **before** batch allocation; empty selection publishes `0/0`, allocates **no** batch, and returns. Nonempty selection allocates one batch before the relationship write transaction. A batch survives a later transactional failure. Freeze this distinction against the actual writer, including source-open and query failures, before changing anything.

The persisted `message_to_attachment` row contains exactly these seven columns (verify actual schema and writer):

```text
message_source_id
attachment_source_id
source_message_rowid
source_attachment_rowid
message_ss_id
attachment_ss_id
batch_id
```

Uniqueness is the four-part `(message_source_id, source_message_rowid, attachment_source_id, source_attachment_rowid)` tuple; raw join ROWID is progress/error context, **not persisted**. The current importer supplies the same injected `sourceId` for both endpoint source IDs. Do not invent separate endpoint-source resolution. The two packed endpoint keys must use `SourceScopedRowKey.pack` and the established source IDs. `insertIgnore` collapses duplicate endpoint tuples; distinct attachment endpoints remain distinct. Validate exact behavior, including int/rounded-double coercion and required-field errors.

Endpoint existence comes from `existing_message_rowid` and `existing_attachment_rowid` in the source `LEFT JOIN`. The importer alone interprets these facts, omits incomplete relationships, and increments `omittedMessageAttachmentRelationshipCount`. No endpoint existence query or omission decision may move into the pure projection.

### 4. Pre-edit actual-writer characterization

Create a synthetic `ReadOnlySourceDatabase` fixture with the **actual disposable source-scoped `ImportDatabase`** and invoke the unchanged production importer. Freeze full persisted row maps, order, both source IDs, both raw endpoints, both packed IDs, batch reference, duplicate endpoint collapse, live/non-live provenance, empty selection, full/incremental cursor and SQL arguments, int/double conversions, missing Message and missing Attachment omissions, invalid raw join identity, typed omission counts, progress sequence including raw join ROWID, reruns, error propagation, rollback after an admitted earlier row, batch survival, and source closure after every post-open outcome. Verify query/open failures do not allocate a batch, while a post-query nonempty failure retains its allocated batch. Freeze the precise handling of observer errors. Use a source double only where the actual disposable writer cannot safely inject lifecycle failures.

Run and record the characterization **on unmodified production code**. Record importer and frozen-test hashes. If supported fixtures cannot characterize current behavior deterministically, STOP; do not substitute a handwritten imitation or revise behavior to fit a test.

### 5. Extract only the pure row formation

Create one immutable typed input representing the admitted raw Message and Attachment endpoint identities, and one immutable projected result containing the complete seven-column ledger map and any needed coerced facts. The synchronous pure function receives explicit `sourceId` and importer-owned `batchId`. Preserve current coercion and errors; use `SourceScopedRowKey.pack` directly rather than copying key logic. The importer still validates the raw join ROWID for progress, interprets source endpoint-existence evidence, and decides omission **before** invoking the projection. It invokes the one concrete projection once per admitted row and passes its immutable values to the existing `insertIgnore`. Remove the old inline row-formation branch.

The pure module must have no SQL, DAO, SQLite, Riverpod, Flutter, filesystem, clock, archive, payload, graph, FTS, AppCzar, provider, source reader, transaction, batch allocation, progress, callback, async, global mutable state, or mutation capability. No alternate injectable mapping strategy or second relationship authority.

### 6. Exact parity and tests

Rerun the **identical frozen pre-edit characterization**, without adjusting material expected rows, omissions, progress, error, transaction, or lifecycle outcomes. Add direct projection tests for all seven persisted fields, source/batch lineage, immutable output, int/double coercion and required-field failures, live/non-live IDs, packed-key boundaries, duplicate endpoint tuples, and irrelevant versus material raw input changes.

Add AST/dependency architecture assertions for one importer-to-projection call, no duplicate row mapping, importer-owned source SQL/cursor/order, source endpoint proof and omission, batch-after-query/nonempty behavior, transaction/insert-ignore/progress/source close, and exclusion of graph/archive/AppCzar/mutation authority. Preserve Message–Attachment graph projector and attachment archive coverage semantics exactly.

Run focused characterization/projection/architecture tests; source-scoped import and join regressions; graph Message–Attachment/topology regressions; attachment metadata/archive/coverage/repair regressions; historical-source, AppCzar, Onboarding, Data Update, Local Data Repair and Operating regressions; complete architecture suite; `flutter analyze`; complete deterministic serial `flutter test` suite; formatting; generated-source consistency; `git diff --check`; staged diff hygiene; and canonical Project Conformance. Report unique complete-suite totals and any intermediate failures literally. Do not call a rerun proof that an earlier concurrency issue was fixed.

### 7. Stop gates and checkpoints

STOP AND REPORT without committing partial source changes if actual writer behavior differs materially from Response 98's audit, if baseline characterization cannot pass, if exact pre/post parity fails, or if any SQL, endpoint proof, omission, batch timing, transaction, error, progress, graph, archive, AppCzar, schema, or production behavior must change. A safety stop must leave no exploratory production diff. Do not treat a partial projection as a reconstruction-equivalence witness.

Only after all validation passes and Project Conformance reports **BLOCKER 0 / SHOULD FIX 0**, stage the exact authorized implementation/test files, commit and push normally with a narrow subject such as `refactor(import): extract canonical Message-Attachment relationship source projection`. Then create Response 101 and checkpoint Prompt 101/Response 101 separately; push normally. No rebase, force push, squash, unrelated staging, or submodule change.

### 8. Required Response 101

Record: exact preflight and prior documentation checkpoint; baseline hashes; actual source query/full-incremental ordering and cursor; seven-column schema and uniqueness; raw join ROWID role; endpoint source IDs and packing; stateful endpoint admission/omission; batch-after-query and empty-selection behavior; transaction/progress/errors/closure; pre-edit writer fixture and passing baseline; pure typed contract; importer call edge; unchanged post-edit characterization; direct and AST tests; graph/archive/AppCzar regressions; analyzer/full deterministic suite and intermediate failures; conformance; exact implementation and documentation commit hashes; final Git/upstream/submodule/untracked state; and readiness for the next **separate audit of remaining reconstruction-equivalence gaps**.

Conclude exactly:

```text
CHAT-HANDLE EXTRACTION CHECKPOINTED: YES / NO
ACTUAL MESSAGE-ATTACHMENT JOIN IMPORTER CHARACTERIZED BEFORE EDITS: YES / NO
CANONICAL MESSAGE-ATTACHMENT RELATIONSHIP PROJECTION IS PURE AND SHARED: YES / NO
SOURCE ENDPOINT-EXISTENCE AND OMISSION AUTHORITY REMAINS IMPORTER-OWNED: YES / NO
EMPTY SELECTION AND BATCH-AFTER-QUERY SEMANTICS UNCHANGED: YES / NO
MESSAGE-ATTACHMENT LEDGER ROWS, DUPLICATES, PROGRESS, ERROR, AND LIFECYCLE PARITY: PASS / FAIL / NOT REACHED
ATTACHMENT PAYLOAD/ARCHIVE AND GRAPH AUTHORITY UNCHANGED: YES / NO
FULL POPULATED RECONSTRUCTION WITNESS IMPLEMENTED: NO
DESTRUCTIVE OPERATING START FRESH IMPLEMENTED: NO
SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES / NO
PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES / NO
PROJECT CONFORMANCE: PASS / FAIL
READY FOR SEPARATE RECONSTRUCTION-GAP AUDIT: YES / NO
READY TO RESUME DESTRUCTIVE STAGE 2C: NO
READY FOR PRODUCTION APPCZAR CUTOVER: NO
```

Then **STOP**. Do not begin a reconstruction witness, graph/FTS/rich-text extraction, destructive Start Fresh, or production cutover in this task.
