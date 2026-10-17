# Response 130 — STOP: required host exception gate conflicts with owner-only scope

## Disposition

STOP before production implementation. The explicit host exception gate in Prompt 130 §5 fails against the actual registered Onboarding listener. One added inert fault-injection test demonstrates propagation of a drain refusal without a cancel response. Production owner, generated companion and all hosts remain unchanged. This is the already-known listener deficiency, now exercised against the new strict gate; it is not a newly invented independent owner defect.

Prompt 130 §5 requires:

> classify any exception that the unchanged host does not safely handle and **STOP** rather than treating that as passed.

Section 2 forbids changing `app_czar_startup_harness.dart` or the unguarded listeners, and §6 also requires STOP if error-to-cancel host changes are required. Therefore neither swallowing an owner failure nor calling an escaping exception a safely canceled exit can satisfy this task. The owner fixes remain explicitly authorized in principle but were not started once this qualification gate failed. No success checkpoint is created.

## Recovered baseline and prerequisite checkpoint

- Branch `fix/onboarding-import-stuck-state`; initial HEAD `b74813976f137bdb32d232ae287cff92954e8bd0`; upstream `0/0`; empty index; exactly the two unstaged test changes from Response 129.
- Captured `/private/tmp/prompt130-baseline.json`: 6,036 tracked regular files and 52 untracked files (Response 129's 51 plus new Prompt 130).
- Both stopped test hashes match exactly: controller test `8c7ae0e61af6917fa8d730cf49ddcedfe11a0f1601daae560b478933921f7fcf`; harness test `33d66589fddb843c8034f3cc0f0962e4aaa1ef382a42777febd1651f3191cbd3`.
- Exact Prompt/Response 128 are already committed at `b7481397`. Stage 1 `e21334de96c2ab1484acbb8f3378ccad2cc49972`, Stage 2 `daac3e6b54812c98d56dba7eb3ea8fb8f8296798`, Data Update `a90612830fac05d79fff5d6097c2b0d35dd23b6e`, and Source Access `5eb7e58b4e24589114d18bac1bf6aef0bba4ab5a` remain ancestors. All ancestry commands exit 0.
- All 17 Stage 2 recorded hashes and both exit-probe hashes match. Source Access hash records match except its harness test, already modified by the authorized Response 129 characterization. No probe was executed.
- Exact complete Prompt/Response 129 were checkpointed alone as `8c61d69bac7103a0cae90b8754eada567880e07f` (`docs(feature34): checkpoint stopped onboarding drain qualification`) and pushed normally. Staged whitespace, commit and push exit 0. No tests or archival moves were staged.
- Prompt 129 SHA-256: `cae82ba43098d759a917f09c396575a75da3c836d05c51720747735f03b310ba`; Response 129 SHA-256: `ad7761f1ee56e6ce8f0e8e591c9d911a9b723a5700329f7f4bdc04fd72b87b33`. Their STOP content was preserved.
- Current synchronized HEAD is `8c61d69bac7103a0cae90b8754eada567880e07f`, upstream `0/0`. Shared submodule remains clean at `95326f515ef4719f155ce6e223990398daad6311`. Other worktree HEADs remain feature-35 `09b1c767cc01410da5799273206e2ab2a4d3b283`, main `b67bfafc3ad4f4f0c15792f0245bfecf5e45f43f`, gradle-fix `4f3e4fcc4eed2bd69eb237ae0aa328c917bbce37`; none was targeted by mutation commands.
- Navigation README, restored 218 historical documents, three archived scripts and every unrelated untracked file remain byte-preserved by the baseline comparison.

## Work and continuation ownership table — source inspection

No production change was made. This table records the source state, not a qualified proposed implementation.

| Work/continuation | Current admission and ownership | Current sealing/settlement |
| --- | --- | --- |
| Assessment subscription | `build()` watches assessment; first eligible generation admits Onboarding; later generation invokes `_queueRestartAfterCurrentRun()` | No explicit disposal sealing hook; an assessment rebuild can queue restart. |
| Prerequisite reads and build | `_schedule` retains a microtask in `_activeRun`; `_selfLocateAndContinue` captures occurrence generation; `_runInitialBuild` awaits executor | Ordinary stop closes `_accepting`, increments epoch and awaits one `_activeRun` snapshot; most read/build continuations check `_canPublish`. |
| Settings requests | `openSystemSettings()` admits independently whenever state eligibility and `_accepting` permit; directly awaits adapter | No retained collection. Ordinary stop omits these futures. Error handler publishes without post-await generation check. |
| Queued assessment restart | `_queueRestartAfterCurrentRun` seals admission and records `_restartAfterCurrentRun` while work is pending | `_schedule.whenComplete` can schedule restart after ordinary stop; pending intent is not revoked. |
| Build-success/error and invalid-prerequisite restart | `_requestRestart` may be awaited inside `_activeRun`; `_restartAfterDrain` seals then calls it | Restart is not owned separately from work. Already-started restart/reentrant drain is not newly qualified. |
| Explicit `stopAndDrain(restart: true)` | Public argument exists; after awaiting snapshot, calls `_requestRestart` | No repository call using this explicit argument was found; its preservation would still require tests in an implementation task. |
| State publication | `_publish` assigns `_current` and notifier state unconditionally | Call sites must guard currentness; Settings and restart error paths currently lack adequate post-stop suppression. |
| Actual exit host | Installed `AppLifecycleListener` awaits selected notifier's `stopAndDrain()`, then returns `AppExitResponse.exit` | No error-to-cancel handling. Flutter listener and binding forward/await the same exception. |

Source Access's separate `_restartFlight`, guarded publication and active-restart refusal were inspected as a possible existing pattern. Data Update's work-versus-restart continuation separation was also inspected. Neither controller was changed, and neither pattern was copied into an unqualified Onboarding patch.

## Fresh executable evidence

### Preserved four red tests

Ran on unchanged production before adding the new test:

```text
flutter test --no-pub test/essentials/app_czar_onboarding/application/app_czar_onboarding_controller_test.dart test/essentials/app_czar/presentation/app_czar_startup_harness_test.dart --plain-name 'Prompt 129' --reporter expanded
```

**Exit 1: 0 passed, 4 failed.** Log `/private/tmp/prompt130-red-baseline.log`.

The results reproduce Response 129: Settings success drains prematurely; Settings failure drains prematurely and publishes late; actual host returns exit while Settings is pending; reassessment queues restart which begins after ordinary stop and remains pending after drain returns, with zero Settings calls. These cases were neither removed nor weakened.

### New host refusal boundary test

Added only `Prompt 130 Onboarding host cancels a refused drain` and an isolated test subclass to the existing harness test file. The real assessment and inherited controller build use fixed safe-empty/source-denied observations. Settings, build executor and restarter are inert overrides supplied before construction. The test subclass inherits real admission and first awaits `super.stopAndDrain()`, then awaits a controlled barrier that fails with a retained `StateError` object. This is **explicit fault injection at the drain result boundary**; it does not claim that production Onboarding already has truthful refusal semantics or that either owner defect has been repaired.

The test invokes the **actual registered** callback through `tester.binding.handleRequestAppExit()`. Before releasing the barrier, there is no response or error. After injecting refusal:

```text
response=null identicalFailure=true
```

There is one drain call and zero Settings/build/restarter invocations. The identical injected error reaches the test's observation handler; the host returned neither `cancel` nor `exit`. The test catches at its own boundary only to inspect the result and clean up. It does not add a catch to the production host or infer anything about actual native termination.

Command:

```text
flutter test --no-pub test/essentials/app_czar/presentation/app_czar_startup_harness_test.dart --plain-name 'Prompt 130' --reporter expanded
```

**Exit 1: 0 passed, 1 failed.** Expected no escaping failure and `AppExitResponse.cancel`; observed `StateError: synthetic Onboarding drain refused`. Log `/private/tmp/prompt130-host-refusal.log`. Controlled barriers settle, the exit future is observed, listener is unmounted and container disposed. No wall-clock sleeps or real external operations are added.

Source confirmation: `app_czar_startup_harness.dart:355` awaits drain without catch; Flutter SDK `widgets/app_lifecycle_listener.dart:204` forwards the callback future; `widgets/binding.dart:818` awaits observers without translating this error into cancel. Source inspection and injected executable evidence agree. No claim is made that an exception causes native exit; the missing cancellation response is the demonstrated defect.

## Scope conflict and minimum next instruction

Prompt 130 authorizes both owner fixes, but its host-exception STOP gate prevents declaring an owner-only correction qualified while the unchanged listener propagates errors. This deficiency was already known and intended for later Prompt 128 work; §5 now explicitly makes it a stop condition. Continuing production implementation after observing it would disregard that instruction.

The next instruction should resolve this sequencing constraint explicitly, using one of these bounded choices:

1. Permit owner-only qualification to report an escaping drain refusal as a known unresolved host limitation, without claiming safe canceled exit, and defer listener cancellation to the separately authorized task; or
2. Add the Onboarding host's narrow error-to-cancel correction to the allowlist so the required actual-host cancellation gate can pass alongside the two owner fixes.

No additional jurisdiction, native launcher, real data access, broad listener redesign or activation change is needed merely to resolve this instruction conflict. Multiple-Settings retention/failure policy, queued restart revocation, independently owned started restart/reentry refusal and disposal/currentness still require implementation and the full authorized adversarial matrix. No such semantics are claimed as implemented here.

## Validation and conformance

- Fresh characterization: four prior expected failures plus one added boundary failure in separate commands, each exit 1. No green-after owner result exists.
- Full `flutter analyze --no-pub`: exit 0, no issues (5.1 seconds), `/private/tmp/prompt130-analyze.log`.
- Targeted `dart format --output=none --set-exit-if-changed` on all three handwritten allowlisted paths: exit 0, zero changes.
- `git diff --check` and `git diff --cached --check`: exit 0. Index empty after the prerequisite docs checkpoint.
- Full focused-file regressions, other specialist/Operating regressions, architecture suite, multi-flight/disposal/reentry matrix: **NOT RUN**, because the explicit host STOP gate failed before production changes. These gates are not historical PASS claims. No real-tenure, Settings, data, archive, native-process or destructive tests were executed.
- No generator run: no production annotation/source changed; generated companion is unchanged.
- SDK tests/analyzer/format used approved cache access; all completed with recorded exit codes, none denied or interrupted.
- Compared with start-of-130 manifest, only the harness test changed. Removing exactly the new test and isolated fault-injection subclass reproduces its starting SHA-256 exactly. Controller test remains byte-identical to the preserved four-red baseline. Current harness test hash: `1aa86a43f18b8d40d785634bca48dbdff845fcc2744d7f6f22ea9e97813fbd60`.
- Production owner remains `08a23fad618b180821a3abedcd4e3cfccc293fb4a7e9b569923711ca5f576752`; generated companion `0d934d453d112de9d16a1ea9c73b671b64cbea4ae325d1a3207d4b71bb99cd82`; production harness `03942c7287f57734bbd197f1a3c3828a8d7b093df023c3aa0940197cc27fbc7b`.

**Reviewed against:** repository AGENTS.md, shared global guardrails, project README, shared Dart/Riverpod instructions, canonical `MESSAGELENS-PROJECT-CONFORMANCE-AUDIT-STANDARD.md`, Prompt 130 and preserved Response 129. Scope is the added test evidence and accumulated stopped Onboarding test delta, not a claim to audit the entire branch.

- **BLOCKER:** required actual-host exception-to-cancel gate fails; fixing it is forbidden by current production allowlist.
- **BLOCKER:** both authorized owner defects remain unfixed; the original four tests remain red.
- **NO ISSUE in inspected delta:** existing provider/port reuse, test-only dependency direction, no new production authority/jurisdiction/state/API, no schema or dependency churn, no user-data logging or mutation, no altered reset gate. No new production performance behavior. All six specialist and the separate Operating listener are byte-preserved; production activation is still `isEnabled => false`.
- **NOT QUALIFIED:** owner retention and restart/refusal contracts, full architecture/regression gates and production/runtime behavior. No UI/release change or version bump. No success documentation/code mismatch is introduced.

Only prerequisite Prompt/Response 129 were committed and pushed. No implementation or Prompt/Response 130 success checkpoint. Final state: HEAD `8c61d69bac7103a0cae90b8754eada567880e07f`, upstream `0/0`, empty index, two unstaged test files (the controller test preserved from 129; harness test extended here), 51 untracked files including exact Prompt/Response 130 and 49 unrelated items. STOP records 128/129 remain intact. Production activation, real process death/launch, signing/FDA continuity, archive lock release, independent successor admission and data continuity remain unqualified and unchanged.

ONBOARDING MULTIPLE SETTINGS FLIGHTS OWNED: NO
ONBOARDING SETTINGS DRAIN QUALIFIED: NO
QUEUED RESTART AFTER ORDINARY STOP BLOCKED: NO
ALREADY-STARTED RESTART ACCOUNTED FOR: NO
ONBOARDING EXIT HOST PENDING-WORK REFUSAL/WAIT: FAIL
PROMPT 128 FAIL-CLOSED LISTENERS RESUMED: NO
SIX SPECIALIST AND ONE OPERATING HOSTS UNCHANGED: YES
STAGE 1/2 RESET DENIAL UNCHANGED: YES
REAL FRESH LAUNCH/ADMISSION IMPLEMENTED: NO
PRODUCTION APPCZAR ACTIVATION: OFF
PROJECT CONFORMANCE: FAIL
READY FOR SEPARATE PROMPT 131: NO
