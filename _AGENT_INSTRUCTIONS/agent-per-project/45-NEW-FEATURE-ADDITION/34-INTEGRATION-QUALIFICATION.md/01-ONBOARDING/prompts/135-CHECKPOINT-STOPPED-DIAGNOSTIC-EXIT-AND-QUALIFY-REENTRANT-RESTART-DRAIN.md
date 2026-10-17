# MessageLens — Feature 34
## Prompt 135 — Checkpoint Stopped Diagnostic Exit Qualification and Correct Diagnostic Review Restart Ownership

**Task:** Resume from Response 134's preserved expected-red characterization; correct and qualify **only the Diagnostic Review controller's restart-registration / ordinary-drain boundary**. This is a concrete owner-lifecycle implementation milestone. It is **not** the four-listener error-to-cancel implementation, native launch, production activation, or a new coordination framework.

### 0. Controlling evidence and safety

Response 134 STOPPED correctly. An inert restarter invoked from the real Diagnostic Review controller synchronously reentered the real controller's `stopAndDrain()` before `_activeLifecycleAction` had been assigned. The drain returned success while the restart port remained pending. The actual registered host's exit callback remained pending in that trace: **do not claim it returned early exit permission**. The current Diagnostic host still lacks an explicit error-to-`AppExitResponse.cancel` guard; correcting it is outside this prompt.

Source anchors recorded in Response 134 (verify against current HEAD):

- `lib/essentials/app_czar_diagnostic_review/application/app_czar_diagnostic_review_controller.dart`: `tryAssessmentAgain`, `_restartAtProcessBoundary`, `_activeLifecycleAction`, `stopAndDrain`.
- The restart port is invoked before `_activeLifecycleAction` registration in the existing path. `stopAndDrain` seals admissions and currently awaits that slot only.
- The preserved real-controller / real-registered-host reproducer is in `test/essentials/app_czar/presentation/app_czar_startup_harness_test.dart`, with case name beginning `Prompt 134`.

**Fair Witness:** Preserve the distinction between (a) a controller prematurely reporting drainage, (b) an exception escaping the *unchanged* registered host, (c) an actual `AppExitResponse.cancel`, and (d) OS process exit. Only (a) is the confirmed Prompt 134 counterexample. Execute inert tests for the corrected controller; do not promote a controller-level refusal into host-level cancellation or a native handoff.

Absolute restrictions: **no real MessageLens or Apple Messages/Contacts database, overlay, Presence, attachment archive, admitted development/production root, external volume, FDA/TCC/bookmark or Settings action; no real mutation tenure, Ball, lease, repair, import, graph build, process spawn/exit, native Runner call, signature validation, cloud access or application launch**. Replace all potentially side-effecting inputs with inert fixed assessments, clock and restarter before constructing a selected controller/harness. Preserve seven AppCzar jurisdictions, Stage 1/2 reset denial, Local Data Repair safe-partial gate, six specialist plus one Operating exit listeners, and `ProductionAppCzarActivation.disabled` unchanged. No coordinator-to-coordinator state transfer.

### 1. Recover the precise repository state; checkpoint only known STOP documents

1. Verify branch `fix/onboarding-import-stuck-state`, current HEAD/upstream sync, tracked tree/index, four registered worktrees, shared-instructions submodule (historically `95326f515ef4719f155ce6e223990398daad6311`) and full tracked/untracked byte-hash inventory. Response 134 reports HEAD `004e25858712e121592672c09e202cfe840aadaa`, upstream `0/0`, **one intentionally unstaged harness-test edit**, and untracked Prompt/Response 134. Verify, do not assume. Never clean, stash, hard reset, rebase, force-push, bulk-stage, switch/edit other worktrees or alter unrelated files.
2. Locate exact Prompt 134 and Response 134 in the established Feature 34 `01-ONBOARDING/prompts/` and `responses/` folders. If complete, unchanged and still untracked, stage **only that pair**, run whitespace checks, make one documentation-only checkpoint and push normally. If already committed, verify ancestry and avoid duplicate commit. STOP if unexpected tracked modifications or mismatching preserved test/STOP documents exist.
3. Compare the inherited harness-test hash to Response 134's stopped SHA-256 `bc8ac3772d1ee0d911b8fba1cf986dfd4895b5dcaf97ab4ce80c151e3c36bb85`. Its historical baseline was `a71180c8664108c3c2a841a435c49314cf72049fcf9f59cbee410847e023fa1f`. Preserve the **existing new 109-line test and its causal assertions**; do not restore it or change other historical tests. Capture implementation/test file hashes before touching them.
4. Read the controller, its actual selected presentation, the registered harness host, current controller tests, the shared development-gated restarter port, Source Access/Local Data Repair restart-refusal idioms, and the canonical Feature 34 Project Conformance Audit Standard. Confirm real names/paths and whether any identical work is already present. If the ownership boundary has already been corrected, STOP and report rather than duplicate it.

### 2. Exact change allowance

Only these **three existing handwritten Dart files** may be edited:

1. `lib/essentials/app_czar_diagnostic_review/application/app_czar_diagnostic_review_controller.dart`
2. `test/essentials/app_czar_diagnostic_review/application/app_czar_diagnostic_review_controller_test.dart`
3. `test/essentials/app_czar/presentation/app_czar_startup_harness_test.dart` (preserve the unstaged Response 134 characterization)

One generated companion is conditionally allowed: `lib/essentials/app_czar_diagnostic_review/application/app_czar_diagnostic_review_controller.g.dart`, **only if normal filtered build_runner regeneration following the authorized controller edit changes it**. Never hand-edit generated files.

Documentation only: exact Prompt/Response 134 prerequisite checkpoint (when needed) and exact Prompt/Response 135 separate completion documents in the established Feature 34 `01-ONBOARDING/` structure. The two code/test checkpoint groups must not absorb documentation or unrelated untracked items.

All other files—including `app_czar_startup_harness.dart`, Operating exit listener, all other controller/hosts, architecture test rules, main, restarter/provider/port, archive authority, reset services, root selection, schemas, dependencies, native Runner, signing/entitlements, exit-observer probe and Feature 35—are **read-only**. No new test helper or source file, architecture exemption, generated churn beyond the named companion, or additional jurisdiction.

**If a safe correction needs another production source file or changing the Diagnostic host to catch errors, STOP** and supply the exact needed amendment; do not silently broaden.

### 3. Characterize the actual existing ownership before editing

1. Run the preserved `Prompt 134` harness-test reproducer against unchanged Diagnostic controller source, using the real registered listener and injected inert restarter. Capture exact process status and trace. The expected red observation is `restartCalls=1`, `restartSettled=false`, `drainSucceeded=true` while the actual host exit callback remains pending. Do not rewrite the case to say the host exited early.
2. Add the minimum additional characterization to the existing Diagnostic controller test, with controlled `Completer`s, to isolate synchronous reentry **before** registration of `_activeLifecycleAction`, and any ordinary stop or explicit retry admission occurring in the same boundary. Verify exactly which existing callbacks and state changes happen before and after awaited work. Run the red tests and record attributable failure without weakening their safety expectations.
3. Inspect existing successful/failed Diagnostic actions and their state transitions. Preserve the human-initiated `Try Assessment Again` and quit semantics, current diagnostic reporting, single selected occurrence and existing restart-failure presentation as far as they are compatible with truthful sealing. Do not introduce new UX states to make tests pass.
4. If observed source/runtime evidence contradicts Response 134, STOP before speculative edits.

### 4. Minimal single-owner correction

Implement the smallest controller-only contract consistent with the project's existing source-access/local-repair idioms:

- **Register the admitted restart flight before the restarter port can synchronously call back into the controller.** A port entering its callback must encounter an already-visible active restart state. Avoid a race between invoking `_restartAtProcessBoundary()` and assigning `_activeLifecycleAction`. If controlled scheduling is needed, its future and state must be owned before dispatch; it must not become an untracked fire-and-forget microtask.
- **Synchronous stop sealing:** `stopAndDrain()` must prevent new Diagnostic lifecycle actions before its first await, invalidate stale publication/callbacks and suppress any queued retry that has not entered the port. No late action or assessment callback reopens admission on the stopped occurrence.
- **Active-restart refusal rather than recursive self-await:** An ordinary drain invoked while an admitted restart port is active must deterministically **refuse**, e.g. a typed/source-grounded `StateError`, not return success or await a future that depends on its own drain. An injected restarter that reenters must observe this refusal, settle its own controlled future, and permit a *later* truthful drain if no retained failure remains. Refusal is **not** `AppExitResponse.cancel` while the host is unchanged.
- **Complete other owned actions:** If the controller already owns other synchronous/async Diagnostic lifecycle actions, normal drainage must continue waiting for them as appropriate, without overwriting one admitted future with another or losing errors. Duplicate retry/assessment requests must not initiate an untracked second port flight.
- **Failure fidelity:** Existing restart error/failure state is retained when admission is current. Errors after sealing must not publish stale state, and a later drain must not claim success while an admitted error remains unaccounted for. Document any existing failure semantics that are preserved or intentionally refined and support them with inert tests.
- **Ordinary quit vs explicit restart:** Do not invent a new coordination protocol, process receipt, automatic relaunch loop or in-process reassessment substitute. Preserve the existing port's meaning and ensure no application work or authority crosses the later process boundary.
- **No `unawaited` or unowned asynchronous boundary** outside existing approved architecture rules. Do not weaken architecture tests, suppress analyzer findings, or add an exception merely to schedule a restart.
- **No real mutation or native work.** `Future.timeout`/test deadline is not evidence that a port or OS operation settled. Dispose and release every synthetic pending Completer deterministically.

### 5. Required adversarial proof (existing tests only)

Test with the **actual Diagnostic Review controller**, real harness listener when relevant, and inert assessment/restarter/clock. At minimum:

1. Preserved reentrant case: when the fake restarter synchronously calls `stopAndDrain` before it returns its pending future, drainage does **not** report success; pending work remains owned. After synthetic port settlement, a later drain behaves according to the now-stable state.
2. Direct controller reentry test independently verifies registration-before-invocation, no recursive await, exactly one port call, and deterministic refusal rather than a hang.
3. Start/stop races: stop before any queued restart port resolution; stop during an active flight; duplicate stop; duplicate `Try Assessment Again` while pending; currentness/assessment changes during a pending call; disposal while pending. Assert no new port construction after sealing, no stale presentation, no extra restarter call or listener.
4. Port success/error, including synchronous throw and async failure: retained ownership, correct diagnostic/restart-failed state when still current, no swallowed terminal errors. A fake success is **not** a fresh native/Dart admission.
5. Existing Diagnostic Review presentation/quit and non-restart drain regressions remain green; no background worker is invented.
6. The *unchanged registered Diagnostic host* remains the source of truth for host observations. While the restarted port is pending, inspect its callback state honestly. If controller refusal escapes as an exception rather than producing cancel, assert/report this accurately and **do not fail this owner-only milestone solely because the host catch is deferred**. Do not claim `AppExitResponse.cancel` without implementing that separate listener change.
7. Continue to verify no mutation capability, archived data, source/database/Settings access or real process operation occurred. All fixtures must override side-effecting providers before selected notifier/host construction.

**STOP conditions:** another independent controller-quiescence defect outside this owner scope; a new public API or listener change necessary for truthful *controller* safety; inability to test without real authority, root, source, app or native work; unowned future, architecture exemption, added file, unsimulatable cancellation, or weakening the red reproducer. If the only remaining issue is the known unchanged host's missing catch-to-cancel, qualify the corrected owner explicitly and leave the host limitation for the later exit-listener prompt.

### 6. Verification and conformance

Run attributable commands with exit statuses (screen real-tenure/destructive cases before running):

- Focused Diagnostic controller and startup-harness test files, including preserved red-to-green and active-refusal classification.
- Screened Diagnostic screen and relevant specialist/Operating exit presentation and lifecycle regressions with fully inert input ports; do not run broad suites containing real archive/executor/Ball operations without screening.
- Complete `test/architecture` suite if, as usual, it consists of source/AST checks and disposable parser fixtures; record exact count. Do not change architecture assertions/allowlists.
- Full `flutter analyze --no-pub`, targeted formatting of edited handwritten files, normal filtered generation only if needed, `git diff --check` and staged whitespace check, exact file allowlist and baseline hash comparison, submodule/worktree preservation.
- Canonical Feature 34 Project Conformance audit: **PASS requires BLOCKER 0 and SHOULD FIX 0 within this controller-only qualification scope**. Distinguish previously qualified Local Repair and Onboarding behaviour, the unchanged Diagnostic host limitation, and unqualified native execution.

If sandbox/SDK cache denies an invocation, it provides no test result; rerun through the established approved project SDK environment as appropriate. Avoid repeating the entire Flutter suite unless the standard or a concrete regression requires it. Never infer success from a partially completed tool run.

### 7. Checkpoints and Response 135

After all gates pass, stage/commit **only the permitted controller, existing tests and conditional generated companion**, with a descriptive `fix(app-czar): ... diagnostic restart drain ...` subject; push normally. Separately checkpoint the exact Prompt/Response 135 documents and push. Verify upstream `0/0`, clean tracked/index, clean shared submodule, preserved unrelated untracked files and untouched other worktrees. Do not incorporate the archived scripts, navigation README, other Feature 34 docs or unrelated work.

If a mandatory gate fails, **do not make a success source checkpoint**. Leave factual evidence and exact preserved work state in a STOP Response 135; do not reset, revert unrelated material or reinterpret an error as acceptance.

Response 135 must explicitly distinguish:

- the recovered baseline, inherited harness-test hash, expected-red and post-correction traces;
- registration-before-port invocation, active-restart refusal, ownership of queued/admitted work, and fake reentrant-drain outcomes;
- controller truth versus the **unchanged** Diagnostic listener's error-to-cancel limitation;
- test counts/exact exits, source/generated file inventory and checkpoints, conformance verdict;
- remaining four-listener task, signed/native process exit, archive lock, fresh launch and independently admitted next AppCzar assessment.

End with literal flags:

- `DIAGNOSTIC RESTART FLIGHT REGISTERED BEFORE PORT INVOCATION: YES/NO`
- `REENTRANT DIAGNOSTIC DRAIN FALSE SUCCESS PREVENTED: YES/NO`
- `DIAGNOSTIC RESTART SELF-AWAIT PREVENTED: YES/NO`
- `ORDINARY DIAGNOSTIC STOP AND ERROR SEMANTICS QUALIFIED: YES/NO`
- `DIAGNOSTIC EXIT LISTENER ERROR-TO-CANCEL QUALIFIED: NO`
- `FOUR REMAINING EXIT LISTENERS QUALIFIED: NO`
- `STAGE 1/2 RESET DENIAL UNCHANGED: YES/NO`
- `SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES/NO`
- `PRODUCTION APPCZAR ACTIVATION: OFF`
- `REAL PROCESS EXIT/FRESH LAUNCH IMPLEMENTED: NO`
- `PROJECT CONFORMANCE (CONTROLLER SCOPE): PASS/FAIL`
- `READY FOR NEW SEPARATE PROMPT 136: YES/NO`

**STOP after this owner-only correction.** Do not resume Prompt 134, add catches to the remaining listeners, wire the exit-observer probe, modify native Runner, attempt real restart, enable production or reopen populated reconstruction/FTS work under this prompt.
