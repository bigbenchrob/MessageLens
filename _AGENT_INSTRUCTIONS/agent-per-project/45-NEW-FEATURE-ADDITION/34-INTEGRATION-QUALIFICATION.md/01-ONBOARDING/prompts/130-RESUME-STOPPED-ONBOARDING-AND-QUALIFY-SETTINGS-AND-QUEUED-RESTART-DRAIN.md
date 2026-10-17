# MessageLens — Feature 34
## Prompt 130 — Resume Stopped Onboarding and Qualify Settings and Queued-Restart Drain

**Task type:** Narrow characterization-first lifecycle correction in the existing Onboarding coordinator. Resolve the two independent defects reproduced in Response 129. **Not** Prompt 128 exit-listener error handling, a fresh-launch implementation, production activation, database reconstruction, or another AppCzar jurisdiction.

### 0. Decision, authority, and absolute safety rules

Response 129 STOPPED correctly before modifying production. It established **four executable expected-red cases** against unchanged production code: (1) pending Settings success permits premature drain; (2) pending Settings failure permits premature drain and late publication; (3) the actual Onboarding harness listener permits exit while Settings remains pending; and (4) a queued reassessment-triggered restart can be launched *after* ordinary `stopAndDrain()` seals admission, with the drain returning while the restart is still outstanding. The fourth case contains **zero Settings invocations**, so it is an independent lifecycle defect, not a variation on Settings ownership. Response 129's new tests are preserved **unstaged** and must not be discarded, weakened, or disguised as PASS.

**This prompt explicitly authorizes both Onboarding-owner fixes together**: retain and drain **every** admitted Settings-opening operation; and make ordinary stop dominate queued restart while accounting accurately for any already-started restart. Both changes belong to the same existing Onboarding controller. Do not launch Prompt 128's listener changes in this task; the old Onboarding host remains source-unchanged. A later prompt will separately close the five remaining exit-listener error-to-cancel paths.

Architecture and Fair Witness: one selected AppCzar coordinator owns its flights. Coordinator completion → actual process exit → fresh launch → **independent** native/Dart admission and AppCzar reassessment. No coordinator-to-coordinator state/authority handoff. The seven jurisdictions, six specialist exit hosts plus distinct Operating listener, Stage 1/2 composition-bound reset denial, narrow Local Data Repair, production activation `OFF`, immutable user overlays/Presence/historical material and attachment payload preservation remain unchanged. A settled Settings-navigation request does **not** mean FDA was granted, that Settings closed, or that the Messages source became readable.

**Forbidden:** any actual Messages/Contacts/MessageLens source/database/archive/root read or mutation; WD/Toshiba payloads; real Full Disk Access/Settings opening; real worker/graph build, process quit/restart/launch, mutation Ball, tenure, writable-root lease, signing/FDA/TCC changes, cloud operations, real user data, destructive reset, AppCzar production activation, FTS/reconstruction witness work. All newly executed tests must replace Settings, source, build and restarter dependencies with inert synthetic/controlled ports **before** construction. Do not assume that a timeout cancels an unfinished native operation.

If current source contradicts the recorded behavior, a required fix needs another production file or API outside the allowlist, or a second independent owner problem is found, **STOP** with literal evidence. Do not create a success checkpoint if a mandatory gate fails.

### 1. Recover the exact stopped state; preserve the red evidence

1. Inspect branch, HEAD, upstream, all four registered worktrees, index/tracked status and shared instructions submodule; do not assume previous hashes are still current. Response 129 reports branch `fix/onboarding-import-stuck-state`, synchronized HEAD `b74813976f137bdb32d232ae287cff92954e8bd0`, clean index, **two unstaged test-file modifications** and 51 untracked files including Prompt/Response 129. Confirm the real state before proceeding. Preserve the navigation README, 218 restored historical documents, three archived backup scripts and 49 unrelated untracked items, without sweep staging, clean, stash, hard reset, rebasing or touching other worktrees.
2. Verify that exact Prompt/Response 128 STOP are already checkpointed at `b74813976f137bdb32d232ae287cff92954e8bd0` and that Stage 1/2 reset denial, Data Update and Source Access source checkpoints remain ancestors, with their protected source hashes unchanged.
3. Preserve the **four red characterization tests** in the two existing test files. Compare current unstaged hashes with the Response 129 record when possible:
   - `test/essentials/app_czar_onboarding/application/app_czar_onboarding_controller_test.dart` — `8c7ae0e61af6917fa8d730cf49ddcedfe11a0f1601daae560b478933921f7fcf`.
   - `test/essentials/app_czar/presentation/app_czar_startup_harness_test.dart` — `33d66589fddb843c8034f3cc0f0962e4aaa1ef382a42777febd1651f3191cbd3`.
   If their bytes differ, investigate; do not overwrite user's changes. Inspect Response 129's `/private/tmp/prompt129-characterization-final.log` if available, but do not depend on its persistence. The durable Response 129 record reports four expected failures, zero passes. Re-run red tests on unchanged production if safe and attributable; retain actual counts and exit codes. Do not infer new PASS from prior output.
4. Before editing production, read the current Onboarding coordinator, its generated provider, existing controller tests, harness and harness tests, synthetic assessment/readers/build/Settings/restarter seams, applicable controller-drain examples (Data Update and Source Access), and canonical Project Conformance standard. Establish all existing `_schedule`, `_activeRun`, `openSystemSettings`, `_queueRestartAfterCurrentRun`, `_requestRestart`, `stopAndDrain({restart})`, `_publish`, generation, disposal and assessor-listener semantics. Draw an exact work/continuation ownership table before changing code. Distinguish source inspection from executable evidence.
5. **Documentation prerequisite:** Prompt/Response 129 intentionally remain untracked and uncommitted as a STOP. After confirming both exact documents are complete and untouched, checkpoint **only that pair** in a separate docs commit and push normally. Never transform the STOP into a success claim or combine docs with source changes. If already tracked, verify and do not duplicate. If unexpected state prevents a safe docs checkpoint, STOP and report.

### 2. Exact implementation allowlist

Only the following **existing handwritten files** may be edited, including the two already containing the red tests:

- `lib/essentials/app_czar_onboarding/application/app_czar_onboarding_controller.dart`
- `test/essentials/app_czar_onboarding/application/app_czar_onboarding_controller_test.dart`
- `test/essentials/app_czar/presentation/app_czar_startup_harness_test.dart`

**Only if produced by normal generation from the authorized controller:**

- `lib/essentials/app_czar_onboarding/application/app_czar_onboarding_controller.g.dart`

Exact Prompt/Response 129 prerequisite docs and future Prompt/Response 130 docs under existing Feature 34 `01-ONBOARDING/{prompts,responses}/` are separately allowed for their own commits. No other production/test/generated/documentation files. In particular **do not edit** `app_czar_startup_harness.dart`, the five unguarded exit listeners, restart interfaces/implementations, `main.dart`, any lower mutation coordinator or reset admission file, provider/schema/migration/native Runner/entitlement, architecture allowlist, model/jurisdiction or release code. Reuse existing types or STOP if a new public state/API/file is truly needed.

### 3. Contract A — every admitted Settings flight belongs to Onboarding

1. Retain each independently admitted Settings-navigation future from before its first await through completion. The existing public method allows multiple Settings requests: tracking just the latest future would silently lose earlier work. Use bounded, explicit controller-owned flight membership (or source-grounded existing single-flight admission if present), with deterministic removal on both success and failure. Do not leak completed futures or accumulate an unbounded historical list.
2. `stopAndDrain(restart: false)` must **seal new admissions synchronously before awaiting** and settle the complete admitted set, including Settings requests initiated when `_activeRun` is already null. It must also correctly account for a build/prerequisite run that is still pending. No exit permission while any such admitted work is unresolved. Drain closure, not the absence of a UI spinner, is the invariant.
3. A Settings navigation error while admission is still open retains the existing user-facing behavior. After stop, no late error/success may mutate notifier state or publish a new failure, trigger a build, prompt permission, or initiate restart. Use the existing generation/acceptance semantics consistently; do not hide an actual unhandled failure or convert failure to false success. State the explicit policy for how a flight's error affects drain once work actually settles, and test it.
4. Stop and disposal are different: provider disposal may suppress stale publication, but it cannot be claimed to await an outstanding native request. Tracking must not be lost just because the UI or controller changes disposition. Concurrent drains share the same settlement evidence and neither admits further Settings work.
5. Keep the FDA/source observation results literal: denied, unavailable and UNKNOWN do not become authorization to initialize, repair or restart. Settings `openSettings()` returning does not establish any FDA permission transition.

### 4. Contract B — ordinary stop dominates queued reassessment restart

This is an **explicitly authorized companion fix**, not a hidden scope expansion.

1. Preserve Response 129's independent causal red case: safe-empty build pending; real synthetic assessment `runAgain()` changes generation; `_queueRestartAfterCurrentRun()` records restart intent; ordinary `stopAndDrain()` seals; build then completes; baseline `_schedule.whenComplete` starts `_requestRestart()` afterward and the drain returns prematurely. **After the fix, ordinary stop must suppress this queued restart completely**. Record zero restarter invocations, no late state changes and complete accounted-for build settlement.
2. Distinguish **queued (not yet started)** restart from **already-started** restart. A queued restart is revoked by ordinary stop and must not reappear via `_schedule`, `whenComplete`, stale callback or late assessment. For an already-started restart, **do not pretend it is canceled**. Either retain and await its actual independent future *without self-await* or explicitly refuse drain/exit while it is active, as supported by existing typed contracts. Choose the smallest source-grounded policy and document/exercise it. A successful ordinary drain must never conceal active restart work.
3. Preserve the coordinator's **intentionally requested restart** behaviour (`stopAndDrain(restart: true)` and/or assessment-triggered restart as actually implemented) when ordinary stop has not superseded it. A real reassessment still requires a **fresh process**; a fake restarter returning successfully is only fake completion. Do not solve the issue by disabling all restarts or silently adding `runAgain` as a substitute for process exit.
4. Any continuation that triggers restart must have explicit ownership, be admitted under the correct generation/epoch and be distinct from the work future that its restarter may ask to drain. An inert restarter reentering controller drain must not deadlock or be declared quiescent falsely. Do not add a free-running `unawaited` call outside the existing approved architecture or solve self-await with an arbitrary timer.
5. Repeated restart intents, repeated stop requests, stop racing build success/error and changing assessments must not create duplicate restarts, lose an already-owned future or revive sealed admission. Preserve existing qualified safe-empty Onboarding/build, human waiting state and error paths unless the exact owner-safety contract requires a narrowly justified change.

### 5. Mandatory deterministic red/green and adversarial matrix

Extend the existing two test files using **only fixed synthetic facts, controlled Completers, provider overrides and inert restarters**:

- All four original Response 129 expected-red cases turn **green with stronger assertions**, without removing them or compromising the real `handleRequestAppExit()` callback test.
- One and **multiple overlapping** Settings requests; stop before/after admission, one completion while another stays pending, success/error combinations; no drain or exit until *every* required flight settles. No blind retention of only the most recent request.
- Pending Settings with no active build; pending Settings plus concurrent active build. Stop sealing prevents new actions and late publication. Confirm a late Settings error does not change the notifier after stop, even if a callback resumes exceptionally.
- Actual registered Onboarding host: while an inert Settings request is pending, cancelable exit cannot return `exit`; when it settles successfully, exit may be granted **only if** all other owned work is settled; a drain error must not become unconditional exit. The host production code remains unchanged in this task; classify any exception that the unchanged host does not safely handle and **STOP** rather than treating that as passed. Prompt 128 will later add fail-closed listener catches.
- Queued restart during active build; stop before build settles; verify no restart starts, no exit/stop success with outstanding work. The fourth independent Response 129 test has **zero Settings calls**.
- Already-started restart racing ordinary stop, failure/success, repeated stop, and a fake restarter which reenters drain. Assert either safe refusal or proven settlement, *never* premature success or recursive self-await.
- Legitimate assessment-triggered restart when no ordinary stop supersedes it; explicit restart entry when supported; no duplicate worker or restart on repeated reassessments. Preserve failure UI/currentness only while admitted.
- Disposal, reassessment/epoch replacement and stale callbacks: no post-stop publication, no new Settings/build/restart, no former-instance revival. Test containers and subscriptions are disposed only after controlled pending work is released; no disposal-as-drain inference.
- Use causal barriers and controlled microtasks, **no wall-clock sleeps**. Any test deadline is diagnostic only; it does not imply native cancellation. Do not construct unoverridden real executor, Settings authority, filesystem/database, native process restarter, mutation Ball or archive observer. If a required existing regression would acquire real tenure, screen/exclude it with a literal explanation rather than running it blindly.

The Onboarding tests may have different results for deliberate fail-closed refusal versus successful settlement; state the contract and assert precisely which. A method that returns successfully while its own admitted activity remains pending is always a failure.

### 6. Qualification, conformance and strict STOP gates

Run attributable completed commands (record exact counts/exit statuses, including intermediate red):

1. Focused existing Onboarding controller and harness test files, including all Prompt 129 characterization plus newly added adversarial cases.
2. Screened Onboarding safe-empty/build/source-access/restart and relevant specialist host/Operating presentation regressions, with inert dependencies.
3. Complete repository `test/architecture` suite, including existing seven-host census, forbidden imports, and async ownership checks (avoid changes to architecture rules).
4. `flutter analyze --no-pub`, targeted `dart format --output=none --set-exit-if-changed` for the three handwritten files, normal filtered generation if applicable, `git diff --check`, staged-diff check, exact allowed-path diff, tracked/untracked SHA-256 preservation and submodule/worktree checks.
5. Canonical Feature 34 Project Conformance audit. PASS requires **BLOCKER: 0, SHOULD FIX: 0** in this owner-correction scope. Do not count failed SDK-cache commands, aborted tools or historical results as successful new validation. Full Flutter suite only when governing standard or observed failure requires it.

**STOP instead of claiming success** if the existing Onboarding harness cannot be made safe from admitted pending work with the controller-only correction; if queued/started restart still escapes owner drainage; if multiple Settings flights are lost; if a drain succeeds during a pending operation; if controller publication leaks after stop; if error-to-cancel changes to harness production code or another file are required; if it takes an unsanctioned extra file, a new jurisdiction/authority, a real app or data operation, a generator change outside the companion, a changed Stage 1/2 reset gate, or a weakened architecture test to pass. A new independent defect deserves an exact STOP, not speculative widening.

### 7. Git checkpoints, response and next milestone

Once and **only once** all gates PASS:

1. Stage **exactly** the authorized three handwritten implementation/test files and the generated companion if legitimately changed. Reconcile their final hashes with the preserved Response 129 red-test baseline. Commit a single narrow source/test checkpoint (e.g. `fix(appczar): drain onboarding settings and queued restarts`) and push normally; no squash/rebase/force-push or unrelated staging.
2. Checkpoint exact Prompt/Response 130 separately as documentation, with normal push. Keep prior Prompt/Response 128 and Prompt/Response 129 STOP records intact. The response cannot truthfully contain the commit hash that includes itself; put that final hash in the Codex handoff.
3. If any mandatory gate fails, **do not** commit an implementation success. Preserve relevant unstaged test/source evidence and author a factual STOP Response 130 with all failed checks and current repository state.

Response 130 must report: exact recovered HEAD and preservation; prerequisite STOP docs disposition; red-before/green-after tests; provenance of both independent defects; multiple-Settings-future retention/settlement and failure semantics; queued versus already-started restart ordering and reentry/refusal; actual Onboarding host exit result; fresh focused/regression/architecture/analyzer numbers; exact allowlist, generated output and Git checkpoints; remaining separate exit-listener catches and real process-launch/signing/FDA/data-continuity blockers.

End with literal flags:

- `ONBOARDING MULTIPLE SETTINGS FLIGHTS OWNED: YES/NO`
- `ONBOARDING SETTINGS DRAIN QUALIFIED: YES/NO`
- `QUEUED RESTART AFTER ORDINARY STOP BLOCKED: YES/NO`
- `ALREADY-STARTED RESTART ACCOUNTED FOR: YES/NO`
- `ONBOARDING EXIT HOST PENDING-WORK REFUSAL/WAIT: PASS/FAIL`
- `PROMPT 128 FAIL-CLOSED LISTENERS RESUMED: NO`
- `SIX SPECIALIST AND ONE OPERATING HOSTS UNCHANGED: YES/NO`
- `STAGE 1/2 RESET DENIAL UNCHANGED: YES/NO`
- `REAL FRESH LAUNCH/ADMISSION IMPLEMENTED: NO`
- `PRODUCTION APPCZAR ACTIVATION: OFF`
- `PROJECT CONFORMANCE: PASS/FAIL`
- `READY FOR SEPARATE PROMPT 131: YES/NO`

**STOP.** Do not begin Prompt 128 listener correction, native helper integration, signed rehearsals or production activation under this prompt.
