# MessageLens — Feature 34
## Prompt 123 — Checkpoint Production Handoff Audit and Qualify Data Update Stop-and-Drain

**Task:** Characterization-first, narrowly bounded production lifecycle correction. **Not:** production process restarter, native handoff, activation, database repair, populated reconstruction, or a fresh AppCzar jurisdiction.

### 0. Governing decision and Fair Witness

Response 122 completed a read-only audit and found that production AppCzar handoff remains blocked by an inadequate native exit/launch acknowledgment protocol and incomplete jurisdiction quiescence. It recommended exactly one prerequisite here: Data Update must retain its scheduled and active work, synchronously seal new admission, settle that work before restart/quit, and have its own cancelable-application-exit host. Implement only that prerequisite. Do **not** attempt the native restarter or describe fake-process completion as fresh application admission.

Current seven AppCzar jurisdictions, root archive admission, Stage 1/2 reset-denial contract, the disabled production activation, the independent Local Data Repair operation, preserved overlays, Presence, historical sources and attachment payloads are immutable constraints. The existing selected Data Update flow legitimately mutates through `liveGraphUpdate`; tests in this task **must never invoke that real operation**. All test executors and restarters must be injected inert fakes before selected controller/provider construction. No real Messages/Contacts/application database, admitted WD/Toshiba root, native process, launch, permission, bookmark, signing, S3, archive payload or Ball/tenure access.

Treat source inspection, observed test execution, and proposed future native behavior as three different evidence levels. Fail closed on unowned active work, incomplete drain or lifecycle ambiguity; don't add a timeout that claims a worker was canceled, and don't convert an in-process reassessment into a new PID. Production AppCzar remains OFF.

### 1. Re-establish and preserve the precise baseline

1. Verify branch `fix/onboarding-import-stuck-state`, actual HEAD, upstream 0/0 or report differences, worktree/index, all four registered worktrees, shared-instructions submodule (previously `95326f515ef4719f155ce6e223990398daad6311`), and tracked/untracked file hashes. Do not assume the Response 122 HEAD `1d6bc6524f2f0252798f0b02c9788afb681c0889` is still current.
2. Prompt/Response 122 should receive a separate **documentation-only** checkpoint if they are still untracked, complete and unchanged. Verify any existing checkpoint instead of duplicating it. Normally push only exact authorized documentation. Preserve the onboarding navigation README, 218 restored documents, `_ARCHIVED` backup scripts and every unrelated untracked path; never `git clean`, stash, hard reset, switch other worktrees, force-push or sweep-stage.
3. Read the current controller, harness, relevant Data Update executor/worker, shared restarter port/provider, cancelable-exit host patterns for the other jurisdictions, Operating drain pattern, and canonical Feature 34 Project Conformance standard. Verify all existing symbols before editing. Capture pre-edit hashes and current behavior. If the actual API or required change contradicts the bounded scope below, **STOP** with an exact discrepancy rather than improvising a second lifecycle owner.
4. Stage 1 source `e21334de96c2ab1484acbb8f3378ccad2cc49972` and Stage 2 source `daac3e6b54812c98d56dba7eb3ea8fb8f8296798` must remain preserved in ancestry and unaffected by this task.

### 2. Exact implementation allowlist

Only these **four existing handwritten files** may change:

- `lib/essentials/app_czar_data_update/application/app_czar_data_update_controller.dart`
- `lib/essentials/app_czar/presentation/app_czar_startup_harness.dart`
- `test/essentials/app_czar_data_update/application/app_czar_data_update_controller_test.dart`
- `test/essentials/app_czar/presentation/app_czar_startup_harness_test.dart`

The only permitted generated companion is `lib/essentials/app_czar_data_update/application/app_czar_data_update_controller.g.dart`, and **only if** the normal generator changes it as a consequence of the authorized annotated source edit. Never edit generated code manually. Prompt/Response 122 prerequisite docs and separate Prompt/Response 123 docs at the existing `34-INTEGRATION-QUALIFICATION.md/01-ONBOARDING/` paths are the only document changes.

All other `lib/`, source/test/generated files, native Runner, `main.dart`, restart port/provider/implementation, shared archive mutation coordinator, workers/executors, other six coordinators, models/jurisdictions, schemas/migrations, dependencies, entitlements, release metadata and FTS/reconstruction helpers are **read-only**. No new source/helper file, policy engine, process-handoff abstraction, UI redesign or architecture exemption. If an additional source file is actually required for safe application-exit refusal or a new generated file appears, STOP and name it rather than exceeding the allowlist.

### 3. Characterize existing behavior before implementation

Add the minimum deterministic, inert focused characterization to the two allowed tests **before editing production source**:

- Data Update's selected-generation build schedules `_runSelectedUpdate`, potentially across a microtask gap; the current controller does not expose equivalent `stopAndDrain` ownership.
- A worker and its attachment preservation may be outstanding when restart is considered. Verify the exact execution and restart sequence with recording Completers and an overridden executor, not actual workers.
- Data Update's screen currently has no dedicated cancelable-exit host in the harness, while Diagnostic, Onboarding, Local Data Repair and Attachment Archive Repair already have relevant patterns. Confirm which host/test conventions are safe to reuse.
- Classify which current callbacks are nested within the selected run and which can fire independently; identify any genuine possibility that a restart, drain, or quit path would await the same future currently executing it.

Run focused baseline characterization and preserve attributable output. It may demonstrate missing behavior as expected red or source observation; never mark an unimplemented safety requirement PASS. If existing code already supplies the full requested lifecycle under different names, STOP before duplicating it.

### 4. Data Update: one owner for scheduled work and settlement

Implement a narrowly scoped controller lifecycle with the following **observable contract**, reusing project controller idioms:

1. Selected-generation automatic work continues to start **exactly once** when admitted. Capture the entire scheduled-to-settled work interval, including before the scheduled microtask begins, executor acquisition, graph update, preservation and error settlement. Only the actual executor completion (and associated existing capability cleanup) counts as completion; do not infer completion from a UI state transition.
2. `stopAndDrain` (or the verified matching project-conventional method) seals admission **synchronously before its first await**, invalidates late callbacks/epochs, suppresses automatic and manual restart dispatch, and waits for the tracked **work** future only. If stopped before scheduled execution, the worker must never be resolved or constructed. Calling stop twice should share settled work and never schedule a second update or restart.
3. Keep worker completion and restart dispatch in **separate ownership domains**. After a successful update/preservation result, restart may be requested only once the tracked worker future is settled and cleared. The restarter must not execute from inside the exact future that `stopAndDrain` awaits; a fake restarter reentering drain must complete without deadlock. If necessary, defer restart outside the tracked work with an explicit epoch/stop gate; avoid a free-running orphan microtask or duplicate scheduler.
4. When quit or disposition/selection change begins during worker execution, the worker is allowed to settle naturally; no new work or restart starts afterward. Late result/error/assessment callbacks must not republish failure/success or reopen admission after stop/disposal. Distinguish stale observation suppression from cancellation of an operation that is already underway.
5. Preserve existing selected-generation data-update semantics, failed/deferred-preservation reporting, explicit failed-state restart behavior when admission remains open, and error handling for restarter failures. Do not change the executor, worker or capability operation itself.
6. If a worker or preservation future never settles, drain remains unresolved: it cannot produce exit permission or a restart. No synthetic timeout, `Future.timeout`, disposed Riverpod state or aborted waiting task may be represented as confirmed worker quiescence. A controller may report refusal/failure only when the existing UI/error model can express it faithfully; otherwise STOP rather than invent new state/UI files.
7. No route may use `runAgain`, navigation, dialog dismissal or a fake completed restarter as substitute for process exit or fresh archive admission.

### 5. Harness: cancelable application-exit ownership

Add only a Data Update-specific host at its existing jurisdiction branch in `app_czar_startup_harness.dart`, following the actual existing specialist host pattern.

- For a cancelable application-exit request, await that exact Data Update controller's `stopAndDrain` and return exit permission **only when successful settlement is proven**. If drain throws/fails, refuse/cancel exit through the existing supported response instead of allowing unconditional exit.
- Ensure host registration/removal follows app lifecycle conventions and does not leave multiple exit observers or persistent subscriptions. Widget disposal itself is not a substitute for awaited drain.
- Do not create or start another controller merely by attaching the host; avoid unnecessary auto-executing provider watches. Preserve the other six jurisdiction hosts and the neutral Operating shell unchanged.
- Future production handoff owns actual termination and admission. This host owns only the **permission-to-exit-after-quiescence** boundary. A crash or forced OS termination is outside its guarantees.

### 6. Mandatory deterministic adversarial matrix

Use controlled Completers, recording providers and inert restarters. No sleeps; no real executor/worker, mutation Ball or native process. Include tests for:

- stop before selected microtask begins (zero worker/executor provider construction);
- stop during executor prerequisite, graph and attachment-preservation waits (no exit or restart until the precise future settles);
- normal success, deferred preservation and worker error (preserve existing outcomes and restart eligibility as appropriate);
- duplicate stop, duplicate restart, stop racing successful completion, stop racing failed-state explicit restart;
- fake restarter calling `stopAndDrain` from its restart callback (must settle, no recursive self-await);
- restarter failure after work settlement, with honest failure state and no second request;
- callbacks after disposal/epoch change or selected assessment replacement (no stale mutation or presentation publication);
- never-settling executor (no exit permission, no restart, no false timeout-as-cancel);
- cancelable exit host: success permits exit only after settled work; failure cancels/refuses; repeated requests do not duplicate work or listeners;
- existing development selector, reset-denial Stage 1/2, other jurisdiction hosting, sole Operating currentness and no generic legacy App/background poller fallback remain unchanged by the scoped edit.

Every test must finish by explicitly releasing its synthetic pending completers where needed, disposing containers and removing listeners. Assert construction counts and timing *by causal barriers*, not wall-clock delays. Inert fake restarter completion is **not** a successful new process/admission.

A failure mode that cannot be safely modeled under the four-file allowlist is a STOP finding, not a reason to weaken an assertion or invent a general shutdown framework.

### 7. Verification, conformance, and Git handoff

Run actual attributable processes with exit statuses for:

- the two focused controller/harness tests;
- relevant Data Update executor/restarter regressions, selected startup composition/Operating tests, and any relevant safe screen/exit host tests;
- the applicable architecture/forbidden-import suites per the project standard, screening destructive/real-tenure tests before running them;
- `flutter analyze --no-pub`, targeted format check, generated consistency (if applicable), working/staged `git diff --check`, exact changed-file allowlist and baseline hash preservation.

The full suite is not required unless the conformance standard or an observed failure demands it. Do not mistake a sandbox/SDK cache refusal or interrupted run for PASS. Do not run destructive tests simply because their filenames appear related.

Conduct a canonical Project Conformance review. A PASS requires zero in-scope BLOCKER and SHOULD FIX findings: one Data Update flight owner, synchronous stop sealing, no self-await, awaited exit permission, preservation of qualified mutation authority/other hosts, only allowed edits, no new policy/source identity or native claims, and no actual data access. If any mandatory gate fails, **do not create a success source checkpoint**; preserve evidence and produce a factual STOP Response 123.

On success, create one exact implementation commit of authorized code/tests/generated output, push normally, then checkpoint only exact Prompt/Response 123 in a separate docs commit. Avoid self-referential response hashes: report the actual docs hash in the final Codex handoff. Preserve all unrelated files and other worktrees.

**Response 123 must explicitly record:** baseline and hashes; red/source characterization; exact controller/harness lifecycle sequencing; whether fake reentrant drain passed; whether exit permission follows complete worker settlement; counts, screened exclusions and test exit codes; state/refusal semantics; cleanup, epoch and disposal behavior; implementation/docs checkpoint IDs; remaining unknowns (production native launch/old PID death/archive lock release/new admission, other jurisdiction drain gaps, signed/FDA and real data continuity). End with:

- `DATA UPDATE STOP-AND-DRAIN QUALIFIED: YES/NO`
- `DATA UPDATE CANCELABLE EXIT HOST QUALIFIED: YES/NO`
- `RESTART AFTER WORK SETTLEMENT: YES/NO`
- `REENTRANT SELF-AWAIT AVOIDED: YES/NO`
- `REAL PRODUCTION HANDOFF IMPLEMENTED: NO`
- `STAGE 1/2 RESET DENIAL UNCHANGED: YES/NO`
- `SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES/NO`
- `PRODUCTION APPCZAR ACTIVATION: OFF`
- `PROJECT CONFORMANCE: PASS/FAIL`
- `READY FOR A SEPARATE PROMPT 124: YES/NO`

**STOP after this one prerequisite.** Do not edit native Runner, implement a launcher, enable production, make a real process exit/restart, reopen FTS/populated reconstruction, or proceed to other jurisdiction lifecycles without a separately authorized prompt.
