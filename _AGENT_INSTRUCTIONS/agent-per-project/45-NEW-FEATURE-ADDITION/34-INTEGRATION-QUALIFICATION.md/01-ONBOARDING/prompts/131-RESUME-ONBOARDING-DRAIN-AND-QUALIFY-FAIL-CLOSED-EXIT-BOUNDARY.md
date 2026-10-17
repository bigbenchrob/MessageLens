# MessageLens — Feature 34
## Prompt 131 — Resume Onboarding Drain and Qualify Its Fail-Closed Exit Boundary

**Task:** Complete the stopped Prompt 129/130 Onboarding lifecycle correction with an explicitly amended source allowlist. Characterization-first, preserve all failing tests, fail closed. **This is not** the broader five-listener Prompt 128 task, a native launcher, process restart integration, production activation, or populated reconstruction.

### 0. Governing decision and authority

Responses 128–130 exposed a coupled but finite Onboarding shutdown problem:

1. `openSystemSettings()` admits one or more independent Settings-open Futures that `stopAndDrain()` does not retain/await, and a late failure can publish after sealing.
2. An assessment-triggered `_restartAfterCurrentRun` continuation can start after ordinary `stopAndDrain()` has sealed admission and awaited its earlier `_activeRun` snapshot; a restart can then remain pending after the drain returned.
3. The **actual Onboarding `AppLifecycleListener`** awaits `stopAndDrain()` without catching an error and translating it to `AppExitResponse.cancel`. Response 130 executed a controlled refusal through the registered callback and observed the same `StateError` escaping rather than a cancel response.

These are **three obligations to correct in one precisely authorized Onboarding scope**. Unlike Prompt 130, this prompt expressly authorizes the Onboarding host's narrow error-to-cancel change. Do not stop merely because that known host deficiency is present. Preserve the existing red tests, make all three green, and qualify the actual exit callback against pending and failed owner work.

**Fundamental architecture:** selected coordinator completes admitted work -> ordinary process exit -> fresh launch -> new native/Dart archive admission -> independent AppCzar assessment. No coordinator-to-coordinator state/authority transfer. No invented successful process exit from a Dart `AppExitResponse`.

Hard constraints: seven jurisdictions unchanged; six specialist hosts and one separate Operating host unchanged in number and ownership; Stage 1/2 `startFresh` and `messageDataReset` denial preserved; `localDataRepair` safety unchanged; production AppCzar activation unconditionally OFF. No access to actual Messages, Contacts, app database/archive, WD/Toshiba roots, payloads, FDA/TCC/bookmark, process launches, real Settings, app native Runner, S3, mutation Ball/tenure, or writable-root lease. Test only with synthetic observations, recording inert ports and controlled Completers. No FTS/populated-witness work.

**Fair Witness:** distinguish source inspection, observed red/green execution and unknown native/runtime behaviour. Stop on a genuinely additional owner defect or a needed file outside this allowlist; do not silently broaden scope or fabricate completed quiescence.

### 1. Recover the stopped work faithfully

1. Verify Git branch `fix/onboarding-import-stuck-state`, current HEAD/upstream, clean index, all four worktrees, shared-instructions submodule, tracked/untracked byte manifest. Response 130 last reported HEAD `8c61d69bac7103a0cae90b8754e8bd0` synchronized `0/0`; verify rather than assume. Preserve 49 unrelated untracked items, navigation README, restored historical documents, three `_ARCHIVED` scripts and other worktrees. No `git clean`, stash, reset, broad staging, rebase or force push.
2. Verify the existing Prompt/Response 130 disposition. If they remain complete and untracked, checkpoint **only that exact STOP pair** in a separate documentation-only commit, with whitespace/staged-path check and normal push. Do not rewrite the STOP as a PASS. If already checkpointed, verify and do not duplicate. Prompt/Response 129 STOP are already recorded at `8c61d69bac7103a0cae90b8754e8bd0`; verify.
3. **Preserve the two unstaged test files** inherited from Responses 129/130. Before editing, verify their current bytes/hashes against the stopped records, in particular the accumulated four `Prompt 129` expected-red tests and the `Prompt 130 Onboarding host cancels a refused drain` expected-red test. Response 130 reported harness-test hash `1aa86a43f18b8d40d785634bca48dbdff845fcc2744d7f6f22ea9e97813fbd60` and the controller test inherited from 129 at `8c7ae0e61af6917fa8d730cf49ddcedfe11a0f1601daae560b478933921f7fcf`. A changed baseline is a STOP for reconciliation, not license to overwrite another worker's edits.
4. Read the current Onboarding controller/host/tests, its Settings adapter, restart port, selected assessment tests and canonical Feature 34 Project Conformance standard. Check existing source symbols/API before patching; test names and line positions are evidence anchors, not authority overriding current source.
5. Rerun all **five** red characterization cases against unchanged production source, with exact attributable exit codes. If a test now passes unexpectedly, investigate before editing; do not alter expectations merely to make them red. Keep logs outside the repo and disclose all results.

### 2. Exact implementation allowlist

Only these **four existing handwritten Dart files** may be edited:

- `lib/essentials/app_czar_onboarding/application/app_czar_onboarding_controller.dart`
- `lib/essentials/app_czar/presentation/app_czar_startup_harness.dart` — **only** the existing Onboarding exit-listener branch, to catch a refused/failed drain and explicitly return `AppExitResponse.cancel`; do not change other specialist or Operating listeners in this prompt.
- `test/essentials/app_czar_onboarding/application/app_czar_onboarding_controller_test.dart`
- `test/essentials/app_czar/presentation/app_czar_startup_harness_test.dart`

Only permitted generated companion, if normal source generation actually changes it:

- `lib/essentials/app_czar_onboarding/application/app_czar_onboarding_controller.g.dart`

Documentation only: exact prerequisite Prompt/Response 130 if legitimately untracked, and the new Prompt/Response 131 pair at the existing Feature 34 `01-ONBOARDING/prompts/` and `responses/` paths. **All other source, test, architecture rules, generated files, dependencies, native Runner, process restarter, reset admission, archive mutation, databases, build/signing configuration, other controllers/hosts are read-only.** Architecture source assertions should remain valid; if a genuine in-scope correction requires a different architecture test change, STOP and request an exact amended allowlist rather than editing it.

No new lifecycle framework, helper file, provider, jurisdiction, global shutdown state, reset authority, injected fake tenure, or public admission API. No exception to `forbidden_imports_test.dart` or other architecture tests.

### 3. One accountable Onboarding owner: Settings flights

Use the current project controller idioms to establish these observable facts:

1. Every Settings navigation request admitted before sealing must be retained until settlement. The controller currently permits multiple calls; a single latest-future slot is insufficient. Use a small instance-owned collection or equivalent complete ownership. Repeated requests that current policy admits must remain representable; do not silently serialize or suppress them to simplify tests.
2. Admission is sealed **synchronously** on ordinary `stopAndDrain()` before its first await. No Settings/open-source/build/restart action may newly enter after that seal. Drain waits for **all** Settings flights admitted before sealing, alongside already admitted prerequisite/build work, until those Futures actually settle. Waiting for a Settings navigation request never claims FDA grant, Settings-window closure or accessibility of Messages.
3. Settings success/failure while admitted retains the existing user-facing semantics. A Settings failure completing **after sealing** cannot publish a stale state, open another action, or schedule a restart. If failure makes drainage uncertain/failed, surface the existing failure as a drain refusal; do not silently swallow it so that exit appears safe. The chosen source-grounded policy must be tested, without retroactively treating an already-handled failure as new pending work.
4. Stop and disposal may suppress publication, but do not represent suppression as cancellation or settlement of an active Settings Future. Multiple-flight completion order, one failure among successes, repeated stop and late callback races require explicit causal tests.
5. Retain the real port Future rather than adding a new timer, shell process or fake completion. If a Settings Future never settles, ordinary drain must not report success or permit exit; no timeout-as-cancel.

### 4. Queued and active restart closure

Correct **the same controller**, without extending the scope to the restarter implementation:

1. Distinguish scheduled prerequisite/build work, assessment-triggered queued restart intent, active restart dispatch, and an explicit `stopAndDrain(restart: true)` request. Use one owner for each admitted Future; do not mistake a state field for quiescence.
2. **Ordinary stop wins over any queued assessment restart.** Seal synchronously, revoke queued intent before/while awaiting the already admitted build, and ensure `_schedule.whenComplete` cannot start restart after the seal. The four-test reproducer from Response 129 must turn green with **zero** restart invocations after ordinary stop.
3. Do not abandon an already-started restart or deadlock by awaiting a Future that includes its own caller. If a restart is already active when an external ordinary drain is requested, use a source-grounded **explicit refusal** rather than claiming successful quiescence or recursively awaiting it (as in Source Access Repair), unless the existing contract safely supports an independently awaited completion. Report the exact selected semantics and test them; a refusal must reach the Onboarding exit host as cancellation. No actual restart runs in tests.
4. Preserve current intentional restart paths and `stopAndDrain(restart: true)` semantics for admitted/current instances, including a safe pre-restart work drain. Separate the tracked work Future from the restart Future/continuation as necessary to avoid self-await. Do not implement a new generic lifecycle controller or transfer state across processes.
5. Disposition/assessment replacement and disposal permanently prevent late restart scheduling and late state/error publication for the retired occurrence. Idempotent repeated stop and restart requests must not duplicate work. Any queued callback after sealing must check admission before resolving the restarter provider.
6. Failure of a queued/active restart must not become exit permission. Prevent a generic catch from converting an incomplete operation into success. An inert restarter that re-enters ordinary drain must observe deterministic refusal or safe completion according to the now-qualified owner contract, never a deadlock or fabricated new process.

### 5. Narrow Onboarding exit-listener correction — expressly authorized

In **only** the Onboarding branch of `app_czar_startup_harness.dart`:

- Await the exact already-selected Onboarding controller's `stopAndDrain()` through its existing ownership path; never resolve a replacement provider at exit time.
- On successful complete owner drain, return `AppExitResponse.exit`.
- On **any** synchronous or asynchronous drain throw/refusal, return **`AppExitResponse.cancel`**, without swallowing the error to grant exit and without opening a new work flight. Use current widget/SDK conventions for listener registration, disposal and repeat requests. Do not log user-source data or turn refusal into AppCzar re-evaluation.
- The owner/controller remains the authority for whether work settled; the listener only translates its outcome into exit permission/refusal. The handler must not close/delete database handles or request a native exit itself.
- The other four currently unguarded listeners (Diagnostic, Local Data Repair, Attachment Archive Repair and separate Operating) remain unchanged and **not qualified here**. Do not call this task the completion of Prompt 128.

The fifth preserved expected-red test must turn green using the **actual registered** `tester.binding.handleRequestAppExit()` callback and the injected error barrier. Pending Settings must withhold exit permission; releasing all admitted Settings must allow the correct result. An injected drain refusal must yield `cancel` **and not escape**. Also verify listener removal and no duplicate observer registration.

### 6. Mandatory adversarial qualification

Use only injected synthetic assessment/source/Settings/build/restarter ports **before selecting/mounting Onboarding**. Preserve all five tests from Responses 129/130 and add the smallest deterministic matrix needed for:

- two or more concurrent Settings requests; out-of-order completions; success, failed port, mixed outcomes and repeated stop;
- stop before Settings admission; stop with one/many pending requests; no late publication on success/error; no newly admitted work after stop;
- pending source/prerequisite/build separately and simultaneously with Settings; actual awaited settlement, not mere state transition;
- queued assessment restart while build is pending, then ordinary stop, then build settlement; no new restart and successful drain only after all admitted work settles;
- already-started restart and reentrant `stopAndDrain` (truthful refusal/settlement and no self-await); explicit `stopAndDrain(restart: true)` existing semantics; restart failure, duplicates, selected-assessment replacement and disposal;
- actual installed Onboarding exit listener pending until complete drain; success returns exit; active-restart or failing Settings/drain returns cancel; synchronous and asynchronous refusal; listener removal and repeat request handling;
- Source Access, Data Update, other specialist-host and Operating ownership unmodified; six specialist listeners plus one Operating remain source/architecture truth;
- no real Settings, FDA state, app process, archive/source database, mutation authority, or external launch.

No wall-clock sleeps for causal sequencing; use controlled Completers/barriers. Finish every test by explicitly releasing admitted synthetic Futures, draining/subscription cleanup where supported, unmounting listeners and disposing containers. **Do not claim container disposal itself awaited arbitrary work**. A deliberately never-settling Future is an UNKNOWN/held-drain case; release it for test cleanup.

### 7. Verification and stop gates

Run actual, attributable commands (retain command/exit/count logs) for:

1. Focused Onboarding controller and AppCzar startup-harness test files, including all original `Prompt 129` and `Prompt 130` red cases.
2. Relevant inert Onboarding source/Settings/build/screen tests and Data Update/Source Access host/controller regressions. Screen out any existing test that acquires real mutation tenure, touches real source/archive or launches Settings.
3. Complete `test/architecture` suite if its source/AST fixtures remain safe, including unchanged six-specialist/one-Operating listener census and forbidden-import tests.
4. Full `flutter analyze --no-pub`, targeted `dart format --output=none --set-exit-if-changed` on touched handwritten files, and generated consistency if the controller's annotation changes.
5. `git diff --check`, staged-diff check, exact implementation allowlist and before/after byte manifests, including all unrelated untracked content and Stage 1/2/probe hashes.

A bounded Project Conformance **PASS** requires `BLOCKER: 0`, `SHOULD FIX: 0` within the explicitly amended task and no unqualified positive safety statement. Treat SDK cache refusals, interrupted commands or selected test exclusions literally. No full Flutter suite unless project standard or concrete failure requires it.

**STOP** if: a further independent lifecycle owner is discovered with admitted untracked work; an active restart cannot be safely refused/drained in the existing API; the owner must change another controller/worker; another production or architecture file is genuinely needed; registered exit callback cannot return `cancel` under the allowed host edit; added tests need real FDA/native/db/tenure; or any mandatory qualification gate fails. On STOP, preserve unstaged work and provide a truthful response, no success checkpoint.

### 8. Git checkpoints and Response 131

Upon a fully qualified PASS:

1. Keep the previously stopped Prompt/Response 130 documentation in its own prerequisite checkpoint only, never as successful implementation.
2. Commit the narrowly authorized source/test/generated implementation as **one exact source checkpoint**, push normally. Preserve unrelated unstaged/untracked bytes; never use sweeping staging.
3. Separately checkpoint exact Prompt/Response 131 as documentation and push normally. Report the actual documentation commit hash in final Codex handoff, not inside the document containing itself.

Response 131 must report: verified starting and final repository state, preserved five red-before/green-after observations, precise touched paths and hashes, Settings-flight admission/settlement/failure semantics, queued-versus-active restart ownership/refusal, synchronous sealing, actual exit-listener cancel/exit tests, any remaining UNKNOWN, focused/regression/architecture/analyzer outcomes, exclusions, generated diff and Project Conformance verdict. State clearly that the remaining Prompt 128 listeners are **not yet completed**.

Required literal flags:

- `ONBOARDING MULTIPLE SETTINGS FLIGHTS OWNED: YES/NO`
- `ONBOARDING ORDINARY STOP AWAITS SETTINGS: YES/NO`
- `QUEUED RESTART AFTER ORDINARY STOP PREVENTED: YES/NO`
- `ACTIVE RESTART DURING STOP HANDLED WITHOUT SELF-AWAIT: YES/NO`
- `ONBOARDING ACTUAL EXIT CALLBACK FAILS CLOSED: YES/NO`
- `FIVE PRESERVED RED TESTS NOW PASS: YES/NO`
- `OTHER PROMPT 128 EXIT LISTENERS QUALIFIED: NO`
- `SIX SPECIALIST + ONE OPERATING HOSTS UNCHANGED: YES/NO`
- `STAGE 1/2 RESET DENIAL UNCHANGED: YES/NO`
- `REAL PRODUCTION FRESH LAUNCH IMPLEMENTED: NO`
- `PRODUCTION APPCZAR ACTIVATION: OFF`
- `PROJECT CONFORMANCE: PASS/FAIL`
- `READY FOR SEPARATE PROMPT 132: YES/NO`

**STOP after this Onboarding correction.** Do not resume the other four Prompt 128 listeners, introduce native fresh-launch code, or activate production in this task.
