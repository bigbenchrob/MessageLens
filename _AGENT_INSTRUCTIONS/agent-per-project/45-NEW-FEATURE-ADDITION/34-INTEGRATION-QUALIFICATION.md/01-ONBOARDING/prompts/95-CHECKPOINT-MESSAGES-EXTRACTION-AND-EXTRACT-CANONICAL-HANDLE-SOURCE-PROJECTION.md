# MessageLens — Feature 34
## Prompt 95 — Checkpoint Messages Extraction and Extract Canonical Handle Source Projection

**Milestone:** Third narrow shared-transformation extraction, following qualified Contacts (Response 93) and Messages (Response 94) source projections.

**Governing rule:** Characterize the actual production HandleImporter *before* editing production code. Extract only the existing deterministic raw-source-to-ledger handle-row transformation into a pure typed module consumed by that same writer. Preserve all persisted output, omissions, reconciliation, paging, ordering, progress, anomalies, and failure behavior exactly.

**Hard boundaries:** This is NOT graph canonical-handle grouping, alias rebuilding, Contacts linkage, a reconstruction witness, Start Fresh, or production AppCzar cutover. Full populated reconstruction equivalence remains unproven; destructive Stage 2C remains blocked; production activation remains OFF.

---

## 1. Baseline and recovery

Work only in `/Users/rob/Development/FlutterProjects/remember_every_text` on `fix/onboarding-import-stuck-state`.

Before editing:

1. Establish actual HEAD, upstream, divergence, index, tracked changes, untracked inventory, submodule identity, and registered Feature 34 worktrees. Require synchronized upstream, clean index/tracked tree, and clean shared-instructions submodule at `95326f515ef4719f155ce6e223990398daad6311`. Preserve every unrelated untracked path.
2. Verify the Contacts implementation `a36feac8a48d1702aad5830076157830d6efb975`, Messages implementation `d77d08c6c55e18ade47983fb959b8023c893283c`, and the Prompt/Response 94 documentation checkpoint in ancestry. Response 94 itself cannot contain the hash of its subsequent documentation commit; determine that hash from Git. If Prompt/Response 94 are not yet committed, checkpoint *only those two files* and push normally before source edits. Never duplicate a completed checkpoint.
3. Read the canonical Project Conformance standard, global and per-project agent instructions, Responses 92–94, `handle_importer.dart`, its tests, handle identity utilities, source-scoped schema, and relevant graph boundaries.
4. Capture a fresh source-only baseline manifest outside the repository. Do not access real Messages, Contacts, MessageLens databases, archives, WD/Toshiba drives, or installed application data.
5. STOP if any material baseline requirement fails.

---

## 2. Exact scope

Permitted production files:

- `lib/essentials/source_scoped_import/application/handles/handle_importer.dart`;
- one narrow pure sibling such as `handle_source_projection.dart`;
- only indispensable existing pure utilities already authorized for identity/normalization.

Permitted tests:

- actual production HandleImporter pre/post characterization with synthetic source and actual disposable import ledger;
- direct typed projection tests;
- narrow AST/dependency architecture tests;
- minimal existing HandleImporter test additions needed for parity.

Do not modify the source SQL, row ordering, keyset pagination, transactions, source registration, batch allocation, database schema/migrations, ledger insertion semantics, uniqueness, error policy, or progress. Do not modify Messages/Contacts/Chats/Attachments importers, graph handle projector, canonical handle/alias grouping, Contacts linkage, rich-text, FTS, AppCzar, Local Data Repair, Start Fresh, mutation authority, currentness, production startup, signing, packaging, or release metadata unless an independently applicable repository rule strictly requires it. No build or app launch.

---

## 3. Trace actual writer behavior

Before writing the characterization test, trace every entry point and branch of `HandleImporter`, including `importNewHandles(...)`, `reconcileLocalAccountIdentity(...)`, `_interpretIdentifier(...)`, `_readLocalAccountHandleKeys(...)`, and any actual equivalents. Inventory all persisted `handles` columns from the current schema, not from a prior narrative.

For each field, identify the precise current source and whether it is copied, normalized, defaulted, derived, resolved against other state, or operational. Enumerate source-row IDs, packed IDs, raw identifiers, service, `is_me`, source/batch lineage, omission conditions, and duplicate behavior.

**Critical ownership distinction:** Source-row projection may be pure; local-account identity reconciliation may depend on Messages, accounts, import ledger state, ordering, and prior mutations. Do not move stateful lookup or reconciliation into a pure function. If a narrow deterministic identifier interpretation can be shared safely, pass all previously resolved inputs explicitly. Do not make the pure projection claim to determine `is_me` from incomplete evidence.

If no behavior-preserving extraction boundary exists without moving reconciliation or changing its order, STOP AND REPORT instead of inventing one.

---

## 4. Characterize the unchanged production importer first

Use a synthetic read-only source database and the actual disposable source-scoped ledger APIs. The characterization MUST execute the existing `HandleImporter`, not a handwritten approximation.

Before any production source edit, freeze and pass tests asserting:

- complete persisted handle row/value maps in stable order, with every schema column;
- packed source identity and batch/source lineage;
- raw identifier, whitespace, Unicode, malformed/empty identifiers, service variations and nulls as supported by current schema;
- exact omission, fallback, duplicate/insert-ignore, and invalid-key behavior;
- local-account `is_me` reconciliation from supported synthetic account/message/ledger scenarios, including no match, multiple matches, and repeated invocation where supported;
- source SQL/query ordering, page boundaries, incremental reruns, transactions, progress and anomaly accounting;
- current error/refusal semantics.

Exercise more than one source page if possible without changing the importer. Capture deterministic row maps, counts, progress, and decisions in a source-only external manifest. Do not hard-code operational wall-clock timestamps; assert their actual existing semantic contract. Never log real personal identifiers.

If a deterministic characterization of the actual writer cannot be established using supported synthetic APIs, STOP BEFORE EDITING.

---

## 5. Extract one canonical pure transformation

Create typed immutable inputs and outputs, conceptually:

```dart
HandleSourceProjectionResult projectSourceHandle(...);
```

Use actual repository naming. The pure projection may form only the currently deterministic source-row insert values and typed omissions proven by the pre-edit trace. It must reuse existing `SourceScopedRowKey` and canonical pure normalization utilities rather than reimplement them.

No SQL, DAO, SQLite, Riverpod, Flutter, filesystem, clock, I/O, Future, Stream, global state, progress, mutation capability, or UI in the pure module. Keep source reads, ledger writes, transactions, batching, error handling, progress, local-account reconciliation, and any state-dependent `is_me` updates in `HandleImporter` at the same execution points.

The production importer must consume the one concrete shared transformation path and remove its duplicated row-formation logic. Do not introduce an injectable strategy allowing the writer and a future witness to use different semantics.

---

## 6. Exact parity and tests

Rerun the **identical frozen actual-writer characterization** after extraction. No expected row, omission, count, ordering, progress, error, or reconciliation result may be adjusted to make the refactor pass.

Add direct projection tests for every persisted field, packed identity, source lineage, null/blank/Unicode/raw identifier, service, existing defaults, typed omissions, immutability, and irrelevant-versus-material input changes.

Add mechanical architecture enforcement proving:

- the projection is pure and depends only on approved canonical utilities;
- the actual importer calls the concrete projection for every source-row insertion path;
- stateful account reconciliation remains importer-owned, unchanged, and ordered as before;
- raw SQL, paging, transactions, mutation, and progress remain importer-owned;
- graph canonicalization/alias rebuilding and protected-reference semantics remain untouched;
- no second source reader, policy evaluator, or mutation authority was introduced.

Regression matrix: focused handle importer/projection tests; Contacts and Messages characterization; source-scoped identity and DateConverter tests; graph handle/canonical-alias/contact-linkage tests; Onboarding, Data Update, Local Data Repair, Operating and AppCzar tests; attachment/historical-source tests; full architecture suite; `flutter analyze`; full deterministic `flutter test`; format/generated consistency; `git diff --check`; Project Conformance audit with BLOCKER 0 and SHOULD FIX 0. Report unique full-suite count, not sums of overlapping groups.

---

## 7. Stop gates

STOP AND REPORT, leaving no exploratory tracked diff or half-extracted implementation, if:

- the actual importer cannot be characterized before edits;
- any frozen before/after persisted row, omission, reconciliation, anomaly, ordering, progress, or error result differs;
- source SQL, page, transaction, batch, or stateful lookup order must change;
- account-identity reconciliation or graph canonicalization must be moved or redefined;
- a schema column is omitted from the proof;
- another importer/projector, schema, rich-text, FTS, AppCzar, archive, or production selector must change;
- new destructive eligibility is inferred from this partial extraction;
- validation or Project Conformance fails.

Do not normalize a failed parity result by editing the expected baseline.

---

## 8. Checkpoints and final report

Only after every gate passes:

1. Commit and push only the intended source/test/architecture changes; suggested subject `refactor(import): extract canonical Handles source projection`.
2. Create numbered Response 95, containing concrete source/test evidence, in the existing Feature 34 `01-ONBOARDING/responses/` folder.
3. Checkpoint Prompt 95 and Response 95 as a separate documentation-only commit and push normally.
4. Report both hashes, final pushed recovery anchor, branch/upstream divergence, index/worktree/submodule state, and preservation of unrelated untracked files. Do not build or launch.

Response 95 must record the exact schema column inventory; pre-edit actual-writer characterization; stateful account-identity and `is_me` ownership; typed pure boundary; unchanged writer output and reconciliation parity; direct tests; architecture checks; complete validation counts; Project Conformance; exact changed-file inventory; checkpoint hashes; and readiness for a separate next extraction.

Conclude exactly:

`MESSAGES EXTRACTION CHECKPOINTED: YES / NO`

`ACTUAL HANDLES IMPORTER CHARACTERIZED BEFORE EDITS: YES / NO`

`CANONICAL HANDLES SOURCE PROJECTION IS PURE AND SHARED: YES / NO`

`PRODUCTION HANDLES IMPORTER HAS ONE CANONICAL SOURCE-ROW TRANSFORMATION PATH: YES / NO`

`HANDLE ROWS, RECONCILIATION, OMISSIONS, AND PROGRESS PARITY: PASS / FAIL / NOT REACHED`

`STATEFUL LOCAL-ACCOUNT RECONCILIATION REMAINS IMPORTER-OWNED: YES / NO`

`GRAPH CANONICAL-HANDLE AND ALIAS SEMANTICS UNCHANGED: YES / NO`

`FULL POPULATED RECONSTRUCTION WITNESS IMPLEMENTED: NO`

`DESTRUCTIVE OPERATING START FRESH IMPLEMENTED: NO`

`SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES / NO`

`PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES / NO`

`PROJECT CONFORMANCE: PASS / FAIL`

`READY FOR NEXT NARROW SHARED-TRANSFORMATION EXTRACTION: YES / NO`

`READY TO RESUME DESTRUCTIVE STAGE 2C: NO`

`READY FOR PRODUCTION APPCZAR CUTOVER: NO`

Then STOP. Do not opportunistically begin Chats, Attachments, joins, rich-text, graph, FTS, reconstruction witness, or production cutover.
