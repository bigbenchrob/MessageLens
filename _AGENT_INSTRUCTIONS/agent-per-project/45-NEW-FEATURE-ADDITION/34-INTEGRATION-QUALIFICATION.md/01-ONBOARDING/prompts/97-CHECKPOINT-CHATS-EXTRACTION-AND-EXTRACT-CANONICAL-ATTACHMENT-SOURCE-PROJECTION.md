# MessageLens — Feature 34
## Prompt 97 — Checkpoint Chats Extraction and Extract Canonical Attachment Source Projection

**Scope:** Fifth narrowly bounded shared-transformation extraction. This is not a reconstruction-equivalence witness, archive repair, payload relocation, destructive Start Fresh, or production AppCzar activation.

### 1. Preflight and checkpoint

Work only in `/Users/rob/Development/FlutterProjects/remember_every_text` on `fix/onboarding-import-stuck-state`. Verify actual HEAD, synchronized upstream (0/0), clean tracked tree/index, shared-instructions submodule clean at `95326f515ef4719f155ce6e223990398daad6311`, and existing untracked files preserved. Verify implementation ancestry for Contacts `a36feac8`, Messages `d77d08c6`, Handles `ae6aa649`, and Chats `10732e2986c5e40f7d097f35e2d12daff663fc4f`. Read Responses 92–96 and canonical Project Conformance instructions.

Check whether Prompt 96/Response 96 have already been committed and pushed as a documentation-only checkpoint. If so, record the exact commit; if not, checkpoint *only* those two documents and push normally before source edits. Never duplicate the checkpoint. Create an external source-only baseline manifest recording hashes of relevant importer/schema/tests. No real application data or external archives may be read.

### 2. Source-trace before deciding the extraction boundary

Inspect the actual production attachment importer(s), current source SQL, raw selected columns, ordering, batching/paging, source registry and ledger schema, transaction and insert-ignore behavior, progress, anomalies, error paths, and closure. Enumerate **every persisted attachment metadata column** from the current schema and insert code; do not infer names or semantics from this prompt. Trace any joins, message-attachment relationships, source file paths, transfer names, MIME/UTI, timestamps, sizes, flags, and identifiers as they actually exist. Explicitly distinguish raw source metadata, database-dependent lookup, filesystem-dependent availability, and archive payload authority.

**Stop gate:** If there is no coherent deterministic source-row-to-ledger slice separable from I/O and stateful resolution without changing existing behavior, stop and report a source-grounded smaller proposal. Do not invent a new attachment model.

### 3. Characterize the unmodified production writer

Before editing production source, create tests invoking the **actual existing importer** against a synthetic/disposable `ReadOnlySourceDatabase` and the actual disposable source-scoped ledger API. Freeze complete persisted row maps, identities, source/batch lineage, nullable fields, raw paths, date conversions, ordering, insert-ignore/duplicates, incremental reruns, progress/anomalies, and exception/rollback/close behavior. Include unusual or missing metadata, Unicode, null/blank values, attachment-only messages if relevant, and boundary numeric values. Cover multiple pages only if existing importer supports paging. Do not invent a paging implementation to test it.

Run and record this characterization **before** any production source edit. Preserve the exact expected values for the post-extraction run. If deterministic characterization cannot be achieved without production behavior changes, stop.

### 4. Extract exactly one pure projection

Create a narrowly named sibling such as `attachment_source_projection.dart` with typed immutable input/output and a synchronous concrete projection function, using established project naming. It must produce the **exact existing ledger insertion value shape**. Pass explicit importer-resolved facts as inputs; retain all database-dependent lookups, SQL, filesystem checks, archive interactions, transactions, batch allocation, writes, progress, and errors in their existing owners. Reuse canonical `SourceScopedRowKey`, `DateConverter`, and other already-authoritative pure utilities where actually applicable. Do not duplicate normalization or policy logic.

The pure module may not import SQLite/DAO, Flutter, Riverpod, filesystem/network I/O, clocks, Future/Stream, UI, AppCzar, mutation capability, archive repair, payload readers, or other importers. Do not interpret whether an attachment payload exists or is recoverable. Do not read attachment bytes or change Apple eviction handling. Preserve raw metadata and omissions exactly.

Modify only the existing attachment importer to consume the concrete projection on its existing row-formation path. Remove duplicate local mapping only after the parity tests pass. If multiple materially distinct attachment writers exist, do not merge their semantics speculatively; stop or narrow to one proven path.

### 5. Exact behavioral parity

Rerun the *identical*, unchanged actual-writer characterization. Require equality of all deterministic persisted fields, omissions, row ordering, identities, joins (if within this writer), counts, anomalies, progress, errors, transactions, source closure, and incremental behavior. Wall-clock operational fields should be tested by their original contract rather than fabricated timestamps. Add direct projection tests for every actual persisted column and edge case, including immutability and sensitivity to material versus irrelevant inputs.

Any material difference is a stop gate. Fix or revert implementation, never rewrite frozen expectations to make it pass.

### 6. Hard exclusions

Do not change source SQL, paging, batch allocation, schema/migrations, source registry, join importers, Messages/Chats/Handles/Contacts projections, rich-text enrichment, graph projectors, FTS, canonical identity, attachment archive payloads, archive coverage/repair, relocation/adoption, Operating currentness, Local Data Repair, Start Fresh, AppCzar jurisdictions, development/production routing, signing, or release metadata unless an independently binding repository rule requires the latter. Do not build, install, or launch the app. Do not open real Apple Messages/Contacts, real MessageLens stores, or WD/Toshiba archives. Use synthetic/disposable fixtures only.

### 7. Architecture and regression enforcement

Add a narrow AST/dependency architecture test proving pure imports and the one concrete production call edge, while enforcing that SQL, I/O, writes, progress, and stateful resolution stay importer-owned. Verify no second attachment reader, archive fact authority, payload scanner, or mutation path is created.

Run focused importer/projection tests, previous four projections, source-scoped ledger and relationship regressions, attachment/archive/historical workflows, graph/FTS, AppCzar/Onboarding/Data Update/Local Data Repair/Operating, full architecture suite, analyzer, complete deterministic Flutter suite, formatting/generated-code checks, `git diff --check`, and canonical Project Conformance. Report actual unique full-suite count; do not add overlapping group counts. Require BLOCKER 0 and SHOULD FIX 0.

### 8. Checkpoints and response

Only if all gates pass: commit and push a narrowly scoped implementation (`refactor(import): extract canonical Attachments source projection`), then create Response 97, checkpoint Prompt 97/Response 97 in a separate documentation-only commit, and push normally. No force push, rebase, squash, unrelated staging, or submodule modification. If a stop gate occurs, restore exploratory tracked edits to the verified baseline, leave an uncommitted factual Response 97, and stop.

Response 97 must include baseline/ancestry, documentation checkpoint, actual writer call graph and complete schema-column inventory, pre-edit fixture/output and test result, exact pure contract, importer ownership, post-edit parity, direct tests, architecture enforcement, all regression/analyzer/conformance outcomes, changed-file inventory, commit hashes, final Git state, and explicit limitations.

Conclude with:

`CHATS EXTRACTION CHECKPOINTED: YES / NO`

`ACTUAL ATTACHMENTS IMPORTER CHARACTERIZED BEFORE EDITS: YES / NO`

`CANONICAL ATTACHMENTS SOURCE PROJECTION IS PURE AND SHARED: YES / NO`

`ATTACHMENT METADATA, OMISSIONS, PROGRESS, AND ERROR PARITY: PASS / FAIL / NOT REACHED`

`ATTACHMENT PAYLOAD/ARCHIVE AUTHORITY UNCHANGED: YES / NO`

`FULL POPULATED RECONSTRUCTION WITNESS IMPLEMENTED: NO`

`DESTRUCTIVE OPERATING START FRESH IMPLEMENTED: NO`

`SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES / NO`

`PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES / NO`

`PROJECT CONFORMANCE: PASS / FAIL`

`READY FOR NEXT NARROW EXTRACTION: YES / NO`

`READY TO RESUME DESTRUCTIVE STAGE 2C: NO`

`READY FOR PRODUCTION APPCZAR CUTOVER: NO`

Then STOP.
