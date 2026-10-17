# MessageLens — Feature 34
## Prompt 124 — Resume Stopped Data Update Drain and Close Architecture Gates

**Task:** Correct and qualify the preserved, unstaged Prompt 123 implementation. **Not:** a new lifecycle design, production restarter, native launch, AppCzar activation, reset, FTS/reconstruction work or a new jurisdiction.

### 0. Governing disposition and Fair Witness

Response 123 correctly STOPPED without an implementation checkpoint. The bounded controller/harness implementation remains **unstaged**; its focused/regression run reported 58 passed, but the mandatory architecture run reported 642 passed / 2 failed and full analyzer reported six issues. This is a continuation and correction, not permission to overwrite, discard, reimplement, or claim prior PASS. Verify every reported fact against current Git/source. Preserve the prior response as an honest STOP record.

The specific blockers are:

1. `test/architecture/app_czar_architecture_test.dart`, near line 1147, currently requires exactly four specialist `AppLifecycleListener`s. Data Update now legitimately introduces a fifth. The test must be amended to require **exactly five with positive Data Update ownership assertions**, while preserving checks for all four prior specialists and the separate Operating exit host. Do not weaken it into a lower bound or hide a listener.
2. `test/architecture/forbidden_imports_test.dart`, near line 2075, rejects a newly introduced `unawaited` continuation outside the existing authorized boundaries. Correct the controller's ownership/scheduling mechanism so **no new architecture exception or allowlist change** is needed. Preserve actual worker settlement before restart, prevent an active-work future from awaiting its own restart path, and ensure an orphan asynchronous error cannot escape.
3. `flutter analyze --no-pub` reported six test-file issues: duplicate/incorrectly ordered imports and non-const literals in immutable synthetic fixtures. Fix only those reported issues.

The core safety contract remains: synchronous sealing before await; no executor constructed when stopped before scheduling; actual executor/preservation settlement before exit; restart dispatched only after clearing tracked work and subject to current admission; fake restarter may reenter drain without self-await; no exit if drain fails/hangs. A finished fake restarter is not a new process.

### 1. Recover the exact working state without damaging it

1. Verify branch `fix/onboarding-import-stuck-state`, HEAD/upstream, worktrees, index, shared-instructions submodule, and exact tracked/untracked file manifests. Response 123 reported baseline HEAD `d64c0ef20125c31a32d20d258969ecdf85f52b3e`, synchronized upstream, and clean submodule `95326f515ef4719f155ce6e223990398daad6311`. These are expectations, not assumptions.
2. Inspect `git status`, `git diff --name-status`, and actual file hashes. The preserved unstaged Prompt 123 delta must consist of exactly four handwritten files and one generated companion:
   - `lib/essentials/app_czar_data_update/application/app_czar_data_update_controller.dart`
   - `lib/essentials/app_czar/presentation/app_czar_startup_harness.dart`
   - `test/essentials/app_czar_data_update/application/app_czar_data_update_controller_test.dart`
   - `test/essentials/app_czar/presentation/app_czar_startup_harness_test.dart`
   - generated `lib/essentials/app_czar_data_update/application/app_czar_data_update_controller.g.dart`, if generator genuinely changed it.
3. Confirm exact Prompt 123 and Response 123 are complete and untracked unless already legitimately checkpointed. Inspect `/private/tmp/prompt123-stopped-hashes.json` if present, but do not require that ephemeral file when the original Response 123 and current Git suffice.
4. Preserve the navigation README, 218 restored documents, `_ARCHIVED` backup scripts, unrelated untracked files, and all other worktrees. **Never** use `git clean`, `reset --hard`, stash, force push, broad staging, speculative source restoration or rebase.
5. If the five-file stopped delta differs materially, has been replaced, or additional unrelated edits appeared, STOP and describe the exact conflict. Do not treat any previous test run as current qualification.

### 2. Exact amended implementation allowlist

The **only newly authorized handwritten path** compared with Prompt 123 is:

- `test/architecture/app_czar_architecture_test.dart` — narrowly update the exact five-host source/AST census and positive ownership assertions.

The four existing Prompt 123 handwritten paths above may be edited solely to correct the lifecycle ownership and test analyzer issues, with otherwise preserved semantics. The one generated Data Update controller companion may be regenerated **only by the normal generator** and only if its source input requires it. No hand-editing of generated code.

**Read-only:** `test/architecture/forbidden_imports_test.dart` (the architecture rule must stay intact); native Runner, `main.dart`, all restarter ports/providers/implementations, executor/worker, archive coordinator, reset-denial Stage 1/2 source/tests, the other six jurisdictions, schemas, dependencies, entitlements, signing, release, FTS and reconstruction modules. No new helper/source/test file, new provider, jurisdiction, Ball, mutation lease, policy or architecture exception.

Documentation-only paths: exact existing Feature 34 `01-ONBOARDING/prompts/123-...md` and matching `responses/123-...md` for a separate STOP checkpoint when complete and not already checkpointed; exact Prompt/Response 124 as a later separate completion checkpoint. Never commit a STOP as a source success.

### 3. Correction sequence — characterize, repair, prove

**First, reproduce the current failure attribution** if the unstaged source remains unchanged. Capture the two architecture failures and analyzer six issues with attributable command exits. If source has already been corrected, verify current reality instead of manufacturing red results. Review the current controller's `_activeWork`, scheduled microtask, restart scheduling, disposal and `stopAndDrain` before any edit.

**Architecture host count:** inspect the actual existing architecture test. Amend the exact four-listener assumption to verify precisely five specialist hosts: original Diagnostic, Onboarding, Local Data Repair and Attachment Archive Repair, **plus Data Update**. Check Data Update's cancelable-exit listener awaits the already selected controller's `stopAndDrain` and returns exit only upon successful settlement, cancelling/refusing on an exception. Keep the separately owned Operating listener and all existing absence/sole-owner assertions. Don't rewrite unrelated architecture suites or loosen a global host-count rule.

**Async ownership:** remove the newly nonconforming `unawaited` from the Data Update controller. Choose the smallest project-conforming, explicitly owned restart scheduling pattern already supported in the repository. Ensure (a) `_activeWork` represents only the scheduled-to-settled executor work, (b) its slot is cleared before restart may run, (c) the restart future is independently owned/observed and its errors are handled through existing state, (d) stop/disposal/epoch closure prevents scheduled restart, (e) the fake restarter can reenter `stopAndDrain`, and (f) no microtask or completer is allowed to become an unobserved error or duplicate restart. If the existing four-file scope cannot express that safely, **STOP** and report why instead of hiding the call or weakening the architecture test.

**Analyzer:** repair the duplicate/order imports and non-const immutable fixture literals in the two allowed test files. Keep assertions and causal barriers intact; never disable a lint or remove a test to achieve PASS.

### 4. Mandatory inert adversarial acceptance

Run the corrected focused controller/harness tests with exact exit status. Confirm at minimum:

- stop before worker's scheduled microtask: zero executor construction;
- stop during prerequisites/graph/preservation: drain awaits actual work; no premature exit/restart;
- normal success, deferred preservation and worker error preserve existing results;
- duplicate stops/restarts, stop/result races and disposal suppress duplicate or late work;
- fake restarter reentering `stopAndDrain` completes with no self-await;
- fake restarter failure is handled without unobserved future errors;
- a never-settling fake worker yields neither exit permission nor restart (explicitly resolve test completers during teardown);
- harness's fifth specialist exit listener registers/removes appropriately and refuses exit when drain fails; all original four plus the separate Operating host remain unaffected;
- development-only restarter remains unchanged and production AppCzar remains disabled;
- Stage 1/2 reset-denial source hashes and local-repair safety remain unchanged.

Never execute real graph/import/preservation workers, real exclusive-authority tenure, a Ball, archive access, native launch, process exit, TCC/FDA, or signed app. Screen test files before choosing regression cases; do not run tests known to create real authority merely because their filenames match.

### 5. Validation and conformance

Execute and report **fresh** attributable results for:

1. focused Data Update controller and harness tests;
2. screened Data Update presentation, inert restarter, startup composition, Operating shell and affected exit-host regressions;
3. **complete** architecture suite `flutter test --no-pub test/architecture --reporter expanded` (the previous result was 642 passed / 2 failed); retain all prior assertions except the deliberately obsolete four-host census, which must become a stronger five-host census;
4. full `flutter analyze --no-pub`, target 0 issues;
5. `dart format --output=none --set-exit-if-changed` on the five handwritten files;
6. normal generation check if required; `git diff --check`, staged whitespace check, exact six-path maximum source/test/generated inventory, pre/post hashes, clean shared submodule, preserved unrelated untracked and other worktrees.

If an SDK-cache/sandbox interruption occurs, report it as unverified and rerun with approved SDK access. Do not count partial commands as PASS. Full non-architecture Flutter suite is not required unless the project conformance standard or a concrete regression requires it.

Canonical Project Conformance PASS requires **BLOCKER: 0, SHOULD FIX: 0** in scope. Preserve the one-owner lifecycle, no self-await/unawaited exception, synchronous seal, awaited settlement, no added mutation authority, no extra listeners beyond the intended fifth, exact source allowlist and no production handoff claim.

### 6. Git checkpoints and response

When the existing STOP documents are complete and still untracked, checkpoint **only Prompt 123 and Response 123** in one documentation-only commit before staging the corrected implementation; push normally. Verify rather than duplicate any existing checkpoint. This is preservation of the STOP record, not a rewriting of failure history.

Only after every mandatory gate passes, stage exactly the four prior handwritten implementation/test files, the newly authorized `app_czar_architecture_test.dart` and genuinely updated generated controller companion. Review staged paths and content, make one source/test checkpoint and normally push. Then separately checkpoint **only Prompt 124 and Response 124**; report the self-referential documentation commit hash in final handoff rather than within the document. If any gate fails, leave a factual STOP response and **do not** create success commits or discard preserved changes.

Response 124 must include baseline/current HEAD; prerequisite documentation disposition; pre/post exact hashes and changed-file inventory; original red gate evidence; architecture five-host assertions; description of the conformant replacement for `unawaited`; worker-versus-restart ownership, fake reentrant-drain result and cancelable-exit ordering; test counts/exit statuses and screened exclusions; generated-source hygiene; Project Conformance; source/docs checkpoint IDs; untouched Stage 1/2 reset denial and other worktrees. It must explicitly distinguish fake awaited exit permission from native old-process death, lock release or new process admission.

Final literal flags:

- `DATA UPDATE STOP-AND-DRAIN QUALIFIED: YES/NO`
- `DATA UPDATE CANCELABLE EXIT HOST QUALIFIED: YES/NO`
- `RESTART AFTER WORK SETTLEMENT: YES/NO`
- `REENTRANT SELF-AWAIT AVOIDED: YES/NO`
- `FIVE SPECIALIST EXIT HOSTS ARCHITECTURALLY QUALIFIED: YES/NO`
- `ASYNC OWNERSHIP ARCHITECTURE: PASS/FAIL`
- `REAL PRODUCTION PROCESS HANDOFF IMPLEMENTED: NO`
- `STAGE 1/2 RESET DENIAL UNCHANGED: YES/NO`
- `SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES/NO`
- `PRODUCTION APPCZAR ACTIVATION: OFF`
- `PROJECT CONFORMANCE: PASS/FAIL`
- `READY FOR A NEW SEPARATE PROMPT 125: YES/NO`

**STOP after repairing and qualifying this one Data Update prerequisite.** Do not build a native launcher or continue other lifecycle work under Prompt 124.
