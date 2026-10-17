# MessageLens — Feature 34
## Prompt 136 — Checkpoint Diagnostic Drain and Qualify Diagnostic / Local Data Repair Fail-Closed Exit

**Task type:** Characterization-first, tightly scoped implementation of **two existing AppCzar cancelable-exit boundaries**. This is **not** a production launcher, general shutdown framework, new jurisdiction, or resumption of the entire stopped Prompt 134 four-listener task.

### 0. Objective and controlling architecture

Response 135 qualified Diagnostic Review's restart ownership and ordinary drainage (source checkpoint `35fab08a77c5f872acfd1afe84cee1777e62c5bc`). Response 133 independently qualified Local Data Repair's work/restart separation and refusal of ordinary drain while an admitted restart is active (source checkpoint `891ae8483a8a463e895cf656924226268d758b0b`). **Both existing production exit hosts still propagate drain exceptions instead of returning `AppExitResponse.cancel`.** The remaining Attachment Archive Repair and Operating Session exit hosts have not yet received complete ownership/failure qualification and must not be changed in this milestone.

Implement the smallest correction so **Diagnostic Review and Local Data Repair's actual registered `AppLifecycleListener` callbacks await the exact admitted controller's drain, return `AppExitResponse.exit` only after successful completion, and return `AppExitResponse.cancel` on synchronous or asynchronous drain failure/refusal**. No exception, UNKNOWN, active-restart refusal, or uncompleted drain may be transformed into successful exit permission.

Preserve the original principle:

**Coordinator completion → process exit → fresh launch → independent AppCzar reassessment.** There is no coordinator-to-coordinator handoff or state/authority transfer. The exit listener grants or refuses permission for an ordinary application termination request; it does **not** prove process death, archive-lock release, relaunch, new PID, or re-admission.

Absolute invariants: seven AppCzar jurisdictions; six specialist exit listeners plus one separate Operating listener; Stage 1/2 composition-bound denial of `startFresh`/`messageDataReset`; distinct exact Local Data Repair safety; no production activation (`ProductionAppCzarActivation.disabled`). **Never** change production activation, root/identity policy, any database or archive, source/Contacts access, native Runner, permissions, executable launch, process exit, signing, entitlements, mutation Balls/capabilities/leases, UI routing or coordinator selection. Tests use only fixed synthetic assessments and inert controlled ports. Do not run existing real-tenure/real-worker/real-reset test cases just because their filenames are relevant.

**Fair Witness:** distinguish source inspection, executed test results, qualified listener semantics and unqualified production runtime facts. Historical Response 133/135 test counts are not new Prompt 136 validation. If either owner's successful drain conceals admitted unfinished work in an independently reproduced trace, **STOP without adding a broad catch**, preserve the reproducer and report the owner defect for a separately authorized correction.

### 1. Recover exact baseline and checkpoint the prerequisite, not unrelated work

1. Verify current `git status --short`, branch, HEAD, upstream ahead/behind, tracked/index cleanliness, registered four worktrees, and shared-instructions submodule (historically `95326f515ef4719f155ce6e223990398daad6311`). Response 135's source audit began at `004e25858712e121592672c09e202cfe840aadaa`, but the implementation and later documentation checkpoint have advanced HEAD. **Do not assume a commit hash or source contents without checking.** Capture tracked/untracked inventories and SHA-256 of the potential edit paths and all unrelated material. Preserve the onboarding navigation README, 218 restored historical documents, three `_ARCHIVED` scripts and all unrelated untracked work.
2. Verify the qualified Diagnostic source commit `35fab08a77c5f872acfd1afe84cee1777e62c5bc`, Local Repair source `891ae8483a8a463e895cf656924226268d758b0b`, and preserved relevant ancestors (Stage 1 `e21334de96c2ab1484acbb8f3378ccad2cc49972`, Stage 2 `daac3e6b54812c98d56dba7eb3ea8fb8f8296798`, Onboarding `8e10bd58537f5fa2f409b3c69e16a805be8b12b2`). Compare to the final source hashes reported in Responses 133 and 135 before edits. No ancestor's qualified source may be silently reset or rewritten.
3. Inspect the exact Prompt 135 and Response 135 under Feature 34 `01-ONBOARDING/prompts/` and `responses/`. If they remain complete, untracked and byte-identical, stage **only those two** and make one separate docs checkpoint, normally push and verify. If already tracked, verify ancestry and do not duplicate. If there is an unexplained staged/tracked change or document conflict, STOP and report before coding.
4. Read the current `AppCzarStartupHarness` Diagnostic and Local Repair hosts, their two real controllers, existing tests, the two current owner red/green reports and the canonical Project Conformance standard. Inspect the current Flutter exit callback type/behavior already characterized in Responses 126 and 130. Establish whether listeners capture the selected owner at mount or resolve it at exit, and identify any provider construction side effect. Capture actual source anchors rather than relying on old line numbers.
5. Do not `git clean`, stash, hard reset, rebase, switch another worktree, force-push, sweep-stage or mutate unrelated untracked content.

### 2. Exact change allowlist

Only these **existing** handwritten files may be modified:

- `lib/essentials/app_czar/presentation/app_czar_startup_harness.dart` — **only** the existing Diagnostic Review and Local Data Repair listener branches and immediately necessary private callback glue in this same file.
- `test/essentials/app_czar/presentation/app_czar_startup_harness_test.dart` — actual registered-listener characterization and qualification with inert dependencies; preserve earlier causal tests and their historical provenance.
- `test/architecture/app_czar_architecture_test.dart` — **only if needed** to add positive tests guarding the two fail-closed callback contracts while keeping the six-plus-one host census and all existing owner boundaries intact.

These remain **read-only**: Diagnostic and Local Repair controllers and their tests/generated companions; `app_czar_operating_session_app.dart`; every other specialist/Operating host; `main.dart`; shared restarter/provider; Data Update/Source Access/Onboarding owner and host code; Stage 1/2; executor/worker; archive mutation coordinator; schemas/migrations; dependencies; generated providers; native Runner; probe C/Python files; release metadata. No new source/test/helper/architecture allowlist exemption. **No code generation is expected** because no annotated provider changes are authorized. If the required safe listener correction needs a controller edit, new file, new provider or generated change, STOP and describe the exact mismatch.

Documentation only at the existing Feature 34 `34-INTEGRATION-QUALIFICATION.md/01-ONBOARDING/` paths: prerequisite exact Prompt/Response 135 if needed, and exact Prompt/Response 136 as a separate post-qualification checkpoint. Do not combine docs and code commits.

### 3. Pre-edit owner and listener characterization (do this before production edits)

Add the smallest new deterministic tests in the authorized harness-test file, reusing the **real** selected Diagnostic/Local Repair controllers and actual registered lifecycle callbacks. Existing Response 134 Diagnostic real-owner reproduction, Response 132 Local Repair real-owner reproduction and Response 133/135 corrected owner expectations must remain intact. **Do not replace a real owner with a fake drain in the sole proof of owner correctness.** Fake-drain fault injection is permitted as a separately labelled callback/error-contract test.

Mandatory isolated characterizations:

**A. Local Data Repair (real owner):** select a fixed synthetic assessment that genuinely enters Local Data Repair; use an inert executor that fails *before mutation* to reach the real visible failed/retry state. Invoke the controller's actual restart action, hold the injected restarter pending. Verify that ordinary `stopAndDrain` refuses with the existing `StateError` while restart is active. Invoke `tester.binding.handleRequestAppExit()` against the **mounted actual host**, establish its current error-vs-response behavior, and retain the injected request until cleanup. After releasing the port, verify subsequent controller drainage can complete. No real repair, Ball, store or privileged provider may be resolved.

**B. Diagnostic Review (real owner):** use the same full fixed synthetic Diagnostic assessment used in the qualified Response 135 harness tests. Start actual `tryAssessmentAgain()` through an inert restarter and hold its future pending. Exercise ordinary drain and the registered exit callback. Verify the Diagnostic controller refuses active-restart drain, does not re-enter itself and can later drain after restarter settlement. Keep the Response 134 synchronous-reentry reproducer as a distinct owner test: if the exit request is still pending before controller registration, do not assert a premature host return; qualify active-refusal and later-success boundaries separately.

**C. Callback error classification (explicitly labelled injected failures):** inject both a synchronous failure and an asynchronously completed future error from a controlled drain callback for each of the two **actual host branches**. These prove response translation, not that a real worker throws that exception. Characterize the current propagation before adding a catch. If the existing host API does not permit this without fabricating an impossible owner, use source inspection for that subcase and report the limitation, not a false runtime PASS.

For each case assert no real restarter launch, archive/database work, extra controller construction, secondary provider worker/poller or legacy-App mount. Record red-before results with attributable command/exit status. If existing callbacks already return `cancel` in the verified source, STOP rather than duplicating a qualified correction.

### 4. Minimal fail-closed listener correction

In the two named host branches only:

1. **Bind the intended selected controller/occurrence.** Preserve the existing host construction rules and prefer capture of the actual selected notifier's drain at host initialization where safe, following the qualified Data Update/Source Access/Onboarding host idiom. Never resolve a replacement coordinator in the exit callback. If capture at mount could auto-execute an unselected controller, inspect and characterize that before modification; do not widen provider effects for convenience.
2. Await actual `stopAndDrain()` completion. Return `AppExitResponse.exit` only on a successful completed future. If it throws either synchronously or asynchronously—including active-restart refusal, retained worker/restart error, or an unknown source of drain failure—catch at **that listener boundary** and return `AppExitResponse.cancel`. Do not catch and return `exit`, swallow a failure into a success-shaped result, or mark a still-pending drain as completed.
3. Do not modify owner semantics, retry state, the original error object stored by the owner, presenter failure state, worker lifecycle, archive mutation admission, or coordinator selection. A catch at the presentation boundary is not an owner repair or generic cancellation of the underlying operation. Do not claim a cancel response terminated an already-running restarter.
4. Register exactly one lifecycle listener per mounted host; remove it on disposal. Retain existing specialist count **six** and separately owned Operating listener **one**. Keep all other specialist/Operating host byte changes out of this milestone.
5. Repeated ordinary exit requests must not spawn duplicate work; each uses the same admitted owner. If a previous exit attempt seals an occurrence, a later request may only reflect that owner's actual stopped/settled state, not implicitly reopen admission. A still-pending future yields **no exit permission**, never a synthetic success via elapsed time.
6. No forced exit, `runAgain`, timer delay, navigation fallback, manual unlock, app launch or cross-process state transfer is an acceptable substitute.

### 5. Mandatory adversarial qualification

Use controlled completers and causal barriers (no sleeps, no real SQLite/native/tenure) to prove:

- Real Local Repair active restart → owner refusal → actual registered listener returns `cancel`; **not** early `exit` or escaping `StateError`.
- Real Diagnostic active restart → owner refusal → registered listener returns `cancel`; qualified synchronous reentry remains refusal without deadlock.
- For both owners: outstanding ordinary work prevents exit permission until actual settlement; normal successful drainage returns `exit`; worker/restart failure returns `cancel`. A later successful drain is tested only when source semantics permit it.
- For both listener branches: separately labelled synchronous and asynchronous injected drain exceptions return `cancel`; the same failure is not translated into an unrelated success or false source observation.
- A thrown drain never surfaces as an uncaught Flutter exit-observer exception. The negative result is an explicit `AppExitResponse.cancel`, not `null` or an unrelated UI failure.
- Listener disposal unregisters it; no callback after unmount, no duplicate registrations or selected-owner replacement during exit; source-only assertion of no generic legacy monitor or new AppCzar evaluator.
- No changes in six specialist listener census, one Operating listener, Stage 1/2 reset-denial behavior, Local Repair's safe-partial eligibility/executor, or Diagnostic's normal user retry/quit UI.

**STOP conditions:** discovered successful-but-incomplete owner drain; required edits outside allowlist; tests trying to create or execute real mutation authority; a real Settings/source/DB/volume/native operation; exception-to-cancel that masks unsettled work; new generic shutdown mechanism; direct production activation; a changed architecture rule rather than adding a positive assertion. Leave factual STOP Response 136 and preserve all implementation evidence instead of claiming success.

### 6. Validation and Project Conformance

Run and record real attributable completion/exit status for:

1. Entire `test/essentials/app_czar/presentation/app_czar_startup_harness_test.dart` and the Diagnostic and Local Repair controller tests (with inert ports verified for each selected test). Re-run historical owner red/green adversarial cases, not only the new catch tests.
2. Screened relevant Diagnostic/Local Repair/Onboarding/Data Update/Source Access presentation tests and Operating presentation/exit tests, with known real-tenure, graph, mutation, native or archive tests excluded and named explicitly.
3. **Complete** `flutter test --no-pub test/architecture --reporter expanded` under safe source/AST screening. If the architecture test file changed, verify the census remains six plus one, all original tests and no blanket allowlist exemption.
4. `flutter analyze --no-pub`, targeted `dart format --output=none --set-exit-if-changed` on changed handwritten files, `git diff --check`, `git diff --cached --check`, exact edited-file inventory and baseline hash preservation. No build_runner run unless a pre-existing generated consistency issue is directly attributable and separately authorized; ordinarily none is required.

Conduct the canonical Feature 34 Project Conformance audit. **PASS requires `BLOCKER: 0` and `SHOULD FIX: 0` within this narrow listener qualification**, including explicit owner-success-versus-pending distinctions, correct permission-to-exit semantics, no second owner, bounded work/cleanup, privacy, preserved provider/architecture boundaries and honest test screening. Report all failed intermediate runs, fixture corrections and excluded tests. Historical counts are not fresh results. Do not run a full repository integration suite solely to add listener catches unless project rules or a concrete regression require it.

### 7. Git checkpoints and Response 136

On full PASS only:

1. Stage **only** the exact permitted source/test paths and confirm names/hashes, clean whitespace and preserved unrelated files. Make a dedicated commit, e.g. `fix(app-czar): fail closed on diagnostic and local repair exit` and push normally. No unrelated stage/reset/cleanup.
2. Create the complete factual Response 136 at the exact Feature 34 `01-ONBOARDING/responses/136-...md` path, preserving exact descriptive Prompt 136 filename. Checkpoint Prompt/Response 136 together in a **separate docs-only commit**, normally push. Report actual docs commit hash in Codex's final handoff, not inside the response that the commit contains.
3. Verify clean tracked tree/index, upstream synchronization, shared submodule, four-worktree preservation and every pre-existing unrelated untracked byte. If any mandatory gate fails, **no success source checkpoint**: preserve changes/reproducers, report STOP and do not proceed to another jurisdiction.

Response 136 must report:

- Verified baseline, source ancestry, exact files/hashes, existing Prompt/Response 135 disposition and independent checkpoints.
- Red-before/green-after results for both real owners, registered listeners and injected failures; differentiate host `cancel` from controller refusal and actual process death.
- Full test counts/exit codes, screened exclusions, generated-file status, analysis, architecture, preservation and Project Conformance findings.
- The retained limits: Attachment Archive Repair and Operating Session owner/listener proof, actual native ordinary termination and process observation, launch-target identity/signing, archive-lock release, successor native/Dart admission, FDA continuity, in-place data/migration and backup/rollback.

Conclude with literal flags:

- `DIAGNOSTIC EXIT FAILURE-TO-CANCEL QUALIFIED: YES/NO`
- `LOCAL DATA REPAIR EXIT FAILURE-TO-CANCEL QUALIFIED: YES/NO`
- `REAL OWNER ACTIVE-RESTART REFUSAL PRESERVED: YES/NO`
- `ATTACHMENT ARCHIVE REPAIR EXIT QUALIFIED HERE: NO`
- `OPERATING EXIT QUALIFIED HERE: NO`
- `SIX SPECIALIST + ONE OPERATING LISTENER CENSUS PRESERVED: YES/NO`
- `STAGE 1/2 RESET DENIAL UNCHANGED: YES/NO`
- `SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES/NO`
- `REAL FRESH LAUNCH/PRODUCTION ACTIVATION IMPLEMENTED: NO`
- `PRODUCTION APPCZAR ACTIVATION: OFF`
- `PROJECT CONFORMANCE: PASS/FAIL`
- `READY FOR ONE SEPARATE PROMPT 137: YES/NO`

**STOP after this narrowly scoped milestone.** Do not automatically begin Attachment/Operating listener work or the macOS launcher.
