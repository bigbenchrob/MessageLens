# MessageLens — Feature 34
## Prompt 103 — Checkpoint Reconstruction-Gap Audit and Extract Canonical Rich-Text Semantic Projection

**Milestone:** First narrowly qualified post-import transformation following Response 102.

**Governing status:** Eight source-scoped projections are qualified, but a complete populated reconstruction-equivalence witness does not exist. Destructive Operating Start Fresh/Stage 2C remains BLOCKED. Production AppCzar activation remains OFF. Neither restriction may be lifted by this prompt.

> Characterize the actual production `MessageRichTextEnricher` before modifying it. Extract only the deterministic per-record semantic decision into one typed pure function used by that same enricher. Preserve exact persisted text, errors, anomaly counts, progress, paging, conditional updates, and decoder behavior.

### 1. Preflight and checkpoint

Work only in `/Users/rob/Development/FlutterProjects/remember_every_text`. Require `fix/onboarding-import-stuck-state`, synchronized upstream 0/0, clean tracked worktree and index, clean shared-instructions submodule at `95326f515ef4719f155ce6e223990398daad6311`, exactly one Feature 34 worktree on this branch, and preservation of all unrelated untracked files. Verify eight source-projection implementation checkpoints in ancestry, including `b788c07e0bfead2e67f47027ff43fdf50423f494`, and the Response 101 documentation checkpoint `540a52c908724629cefbb7ee4db113509a9edd99`.

If Prompt 102 and Response 102 have already been committed/pushed together, record that checkpoint and do not duplicate it. Otherwise stage and commit **only Prompt 102 and Response 102**, push normally, and reverify a clean synchronized baseline before editing source. Capture an external source-only SHA-256 manifest. Read global agent instructions, canonical Project Conformance, Responses 91–103 as applicable (particularly 92, 94, and 102), and the actual enricher, Rust bridge/decoder interfaces, ledger API, tests, and schema. If preflight materially differs, STOP.

### 2. Allowed scope and exclusions

Allowed production edits: the existing `lib/essentials/source_scoped_import/application/messages/message_rich_text_enricher.dart` and one new narrowly named sibling `message_rich_text_semantic_projection.dart`, plus only a minimal existing pure utility import if source tracing proves necessary. Allowed tests: actual-enricher pre/post characterization using synthetic blobs and disposable database/decoder seams, direct pure projection tests, and one focused AST/import-boundary architecture test. Existing tests may be extended only when necessary to freeze actual behavior, not change it.

**Forbidden:** Rust decoder or Flutter Rust Bridge generation; typedstream parsing rules or dependency versions; source queries, candidate selection, high-water/cursor/page size, byte budgets, source or transaction lifecycle, conditional `text IS NULL` updates, anomaly/progress behavior, schema/migrations, Contacts/Messages/Handles/Chats/Attachments source projections, relationship importers, graph/FTS, archive/payloads, AppCzar, Start Fresh, production composition, signing, and release metadata unless independently mandated by governing project rules. No build, install, app launch, real Apple/MessageLens data access, or WD/Toshiba archive access.

### 3. Trace actual production semantics before editing

Inventory the precise `MessageRichTextEnricher` call graph and every persisted field it may update. Distinguish:
- candidate eligibility (existing `text`, attributed-body bytes, high-water and source occurrence);
- bounded candidate count, 500-row paging, approximate 8 MiB page target and individual 8 MiB limit;
- expected-length verification and source read behavior;
- Rust invocation and decoder availability/systemic failure;
- decoded text trimming, empty/error classification and typed anomaly reporting;
- conditional database update where `text IS NULL`, including zero-updated race outcomes;
- transaction, progress, counts, cancellation, ordering, exception and source lifecycle.

Confirm whether trimming/candidate selection belongs to the Rust decoder or Dart layer. Do not duplicate Rust semantic rules in Dart. The pure projection may receive **the existing decoder result or typed failure**, explicit raw per-record facts, and return a typed deterministic decision; it must not invoke the decoder, access bytes from a database, or decide paging, persistence, or systemic process behavior. If the existing implementation cannot be separated this way without changing semantics, STOP and document why.

### 4. Freeze actual writer characterization first

Before production edits, create tests that execute the **actual unchanged production enricher** using supported synthetic/disposable source and ledger/decoder seams. Capture deterministic persisted text, no-update cases, anomalies, progress, candidate counts, exact error types, and update ordering. Exercise at least:
- already non-null text;
- null text with valid decoded output;
- trimming, empty and whitespace decoded output;
- exact 8 MiB boundary and oversized input, without unnecessarily allocating giant fixture collections;
- expected byte-length mismatch;
- per-record decoder error and panic-converted error through existing supported seams;
- systemic decoder unavailability;
- conditional `text IS NULL` persistence and a concurrent-update/no-op case if safely representable;
- frozen candidate count/high-water mismatch;
- multiple pages, resource bounds, and progress/anomaly totals where supported.

Use no real content or live data. Preserve wall-clock and operational nondeterminism by its actual semantic contract, never fabricated fixed timestamps. Record pre-edit fixture/test hash, passing test count, and exact writer behavior. If a complete baseline cannot be characterized using existing seams without changing source policy, STOP before production edits.

### 5. Extract one typed pure semantic projection

Create a synchronous immutable typed input/output boundary for the **per-record semantic outcome only**, with explicit raw/decoder facts and typed success, empty, or failure results as justified by source tracing. Keep one concrete canonical implementation and have `MessageRichTextEnricher` call it on the existing path. No injected alternative strategy, global state, clock, database, filesystem, Riverpod, Flutter UI, graph, archive, coordinator, mutation capability, `Future`, `Stream`, I/O, or decoder invocation inside the pure function.

Keep Rust responsible for its existing typedstream parsing and accepted-candidate rules. Keep the enricher responsible for source observation, decoder invocation, resource bounds, error classification where systemic, transaction and conditional update, progress, anomaly counts, and lifecycle. Do not change source row suppression, material text, or error semantics. Remove the superseded importer-local deterministic decision after parity is demonstrated.

### 6. Post-edit parity and tests

Rerun the **unchanged** actual-enricher characterization and require exact parity for all deterministic persisted values, non-updates, anomalies, progress, ordering, error/rollback and lifecycle observations. Do not revise baseline expectations to accommodate new behavior. Add direct projection tests covering every typed outcome and relevant boundary. Add mechanical architecture tests enforcing pure dependencies, exactly one production consumer edge, and preservation of all stateful authority in the enricher and Rust decoder.

Validate focused characterization/direct/architecture tests; rich-text and source-scoped import regressions; Contacts/Messages and eight-projection parity regressions; graph/FTS, AppCzar, archive and Operating regressions; full architecture suite; `flutter analyze`; complete deterministic Flutter suite; formatting, generated consistency, `git diff --check` and staged hygiene; canonical Project Conformance with BLOCKER 0 and SHOULD FIX 0. Report actual unique full-suite count and any intermediate failures literally. No build or live qualification.

### 7. Stop gates

STOP, restore any exploratory source/test edits to the recorded baseline, and report if: pre-edit characterization fails; pure extraction requires Rust, schema, source query, paging, resource or transaction changes; decoder policy is duplicated; conditional update or anomaly semantics change; exact material parity fails; an additional authority/reader is introduced; unrelated files are affected; or full validation/conformance cannot pass. Do not commit a half-extraction. A truthful safety stop is an acceptable result.

### 8. Git checkpoints

Only if all gates pass, stage the exact authorized implementation/test/architecture files; commit and push normally with a narrow rich-text projection subject. Then write Response 103 in the Feature 34 `01-ONBOARDING/responses/` directory; checkpoint Prompt 103 and Response 103 in a separate documentation-only commit and push. Preserve unrelated untracked files and the shared submodule. Report final exact implementation and documentation commit hashes, HEAD/upstream, worktree/index state. No rebase, squash or force push.

If stopped, leave an uncommitted Response 103 with the source-grounded blocker and no partial implementation.

### 9. Required Response 103

Document preflight, Prompt/Response 102 checkpoint, actual production call graph, persisted field and decoder boundary inventory, resource/error/conditional update contracts, pre-edit actual-writer characterization and hashes, pure typed input/output, exact consumer edge, unchanged Rust and stateful ownership, post-edit parity, direct/architecture tests, all regression/analyzer/conformance evidence, bounded diff and commits, final Git state, and the next narrow evidence milestone.

Conclude exactly:

`RECONSTRUCTION-GAP AUDIT CHECKPOINTED: YES / NO`

`ACTUAL RICH-TEXT ENRICHER CHARACTERIZED BEFORE EDITS: YES / NO`

`CANONICAL PER-RECORD RICH-TEXT SEMANTIC PROJECTION PURE AND SHARED: YES / NO`

`RUST DECODER AND RESOURCE/ERROR POLICIES UNCHANGED: YES / NO`

`RICH-TEXT PERSISTED OUTPUT, ANOMALY, PROGRESS, AND ERROR PARITY: PASS / FAIL / NOT REACHED`

`FULL POPULATED RECONSTRUCTION WITNESS IMPLEMENTED: NO`

`DESTRUCTIVE OPERATING START FRESH IMPLEMENTED: NO`

`SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES / NO`

`PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES / NO`

`PROJECT CONFORMANCE: PASS / FAIL`

`READY FOR NEXT NARROW RECONSTRUCTION-EQUIVALENCE MILESTONE: YES / NO`

`READY TO RESUME DESTRUCTIVE STAGE 2C: NO`

`READY FOR PRODUCTION APPCZAR CUTOVER: NO`

Then **STOP**. Do not implement the populated witness, graph/FTS refactor, Start Fresh, or production cutover in the same task.
