# Response 129 — STOP: queued restart escapes ordinary Onboarding drain

## Disposition

STOP after inert expected-red characterization, before production implementation. The requested Settings ownership correction is not implemented or qualified. The two allowlisted test files retain the failing characterization unstaged. Exact Prompt/Response 129 remain untracked and unstaged. No success implementation or completion documentation checkpoint exists.

Prompt 129 §0 requires: “If a separate unsafe owner gap, a needed extra production file, or an unsimulatable external dependency is discovered, **STOP** rather than broadening this patch.” The reproduced queued-restart gap is independent of Settings: the trace contains zero Settings invocations. Although the implicated methods are in the same controller, repairing queued restart admission/ownership would extend the requested Settings-flight correction and alter a flow this prompt requires preserving. No listener changes were attempted.

## Recovered and checkpointed baseline

- Initial branch `fix/onboarding-import-stuck-state`, HEAD `12462fdbea09c64dfe45d262f3b1c487a93fcda4`, upstream `0/0`; tracked tree and index clean.
- `/private/tmp/prompt129-baseline.json` captures SHA-256 for 6,034 tracked regular files and 52 untracked files. All files in `/private/tmp/prompt128-baseline.json` matched byte-for-byte. Its only additional files were Response 128 and Prompt 129.
- Exact complete Prompt/Response 128 were inspected and checkpointed alone as `b74813976f137bdb32d232ae287cff92954e8bd0` (`docs(feature34): checkpoint stopped exit listener qualification`). Cached whitespace check, commit and normal push exited 0. Current HEAD is this checkpoint, upstream `0/0`.
- Exit probe `c5d727a9c21aaced5fe000ae8bae0f8d096df6d2`, Stage 1 `e21334de96c2ab1484acbb8f3378ccad2cc49972`, Stage 2 `daac3e6b54812c98d56dba7eb3ea8fb8f8296798`, Data Update `a90612830fac05d79fff5d6097c2b0d35dd23b6e`, Source Access `5eb7e58b4e24589114d18bac1bf6aef0bba4ab5a` all remain ancestors (each check exit 0).
- Shared-instructions submodule remains clean at `95326f515ef4719f155ce6e223990398daad6311`. Other worktree HEADs remain feature-35 `09b1c767cc01410da5799273206e2ab2a4d3b283`, main `b67bfafc3ad4f4f0c15792f0245bfecf5e45f43f`, gradle-fix `4f3e4fcc4eed2bd69eb237ae0aa328c917bbce37`. No mutation command targeted another worktree.
- Navigation README, restored 218 historical documents, three archived scripts and all 49 unrelated untracked items are preserved. No archival move was staged or committed.
- Full baseline comparison shows exactly the two allowlisted test files changed. All 17 Stage 2 hashes and both probe hashes still match. Source Access recorded hashes match except the explicitly allowed startup-harness test. Probe was neither edited nor executed.

## Actual source contracts

The unchanged owner exposes `Future<void> openSystemSettings()`, `Future<void> checkAgain()`, and `Future<void> stopAndDrain({bool restart = false})`. Private scheduling uses `void _schedule(Future<void> Function() action)`, `void _queueRestartAfterCurrentRun()`, and `Future<void> _requestRestart()`.

Settings admission permits multiple calls whenever the waiting-for-human state permits Settings and `_accepting` is true. Each awaits the real Settings authority independently; none is retained in `_activeRun`. The adapter forwards the FullDiskAccess future. The test overrides replace the underlying operation before provider construction. Completion means navigation-request settlement only; no FDA grant or Settings-window closure is inferred.

`stopAndDrain` seals admission and advances generation, then snapshots and awaits `_activeRun`. With `restart: false`, it does not intentionally request a restart. However `_schedule`'s completion callback can independently enqueue another run after the snapshotted run settles.

## Executed characterization

All four tests ran on unchanged production and generated source. No real Settings, source, archive, database, graph build, mutation tenure, restart or exit was executed. The controller tests reuse synthetic observation reader, fake build executor, inert restarter and Settings adapter overrides. The actual harness test overrides its reader, Settings, build executor and restarter before mounting; the reader selects ordinary safe-empty/source-denied Onboarding through the real assessment provider. No fabricated impossible controller state is injected.

Command (repository root):

```text
/Users/rob/Development/flutter/bin/flutter test --no-pub test/essentials/app_czar_onboarding/application/app_czar_onboarding_controller_test.dart test/essentials/app_czar/presentation/app_czar_startup_harness_test.dart --plain-name 'Prompt 129' --reporter expanded
```

Initial and final runs: **exit 1, 0 passed, 4 failed**. Final log: `/private/tmp/prompt129-characterization-final.log`; first log: `/private/tmp/prompt129-characterization.log`.

| Test | Actual observation on baseline | Required property violated |
| --- | --- | --- |
| Settings success | `prematureDrain=true`, `latePublication=false` | Pending Settings must prevent successful drain. |
| Settings failure | `prematureDrain=true`, `latePublication=true` | Pending Settings must prevent drain; late error must not publish after sealing. |
| Actual Onboarding exit host | `AppExitResponse.exit` returned before fake Settings completion | Host must not permit exit before owned Settings settles. |
| Reassessment restart versus stop | Drain returned with `restartCalls=1`, `restartSettled=false`, `SettingsCalls=0` | Ordinary stop must not start fresh queued work or return successful quiescence with it pending. |

Settings tests reach the real `sourceNeedsHuman` notification and flush the finite microtask chain so the prerequisite run has settled. The harness pumps to settle the same ordinary waiting state before invoking Settings and the registered lifecycle callback. Pending status is controlled by unreleased Completers, never a timeout or a fake process-death assertion. The late-error state identity change is executed evidence, not merely source inspection.

The actual host uses `tester.binding.handleRequestAppExit()` against its installed listener, calls the selected notifier's real drain, and returns exit after that drain succeeds. No callback replacement or text-only surrogate is used. Settings and restart barriers are explicitly released; awaited actions finish and containers/listeners are disposed. Disposal is not treated as proof of resource settlement. Test-only changes to existing fakes add optional barriers; there is no new helper file or production dependency.

## Independent BLOCKER: queued restart escapes drain

Concrete source sequence in `app_czar_onboarding_controller.dart`:

1. An admitted safe-empty occurrence starts a synthetic build and waits on the fake build executor.
2. The real assessment controller's `runAgain()` changes assessment generation. The Onboarding build sees that change and calls `_queueRestartAfterCurrentRun()`.
3. That method closes admission, increments generation, and sets `_restartAfterCurrentRun = true` because the build's `_activeRun` is pending.
4. Ordinary `stopAndDrain()` closes admission again and captures that build future. It neither clears nor takes ownership of the pending restart intent.
5. Releasing the build runs `_schedule`'s `whenComplete`: it clears `_activeRun` and invokes `_schedule(_requestRestart)` because the restart flag remains set. Neither that branch nor `_schedule` checks the stop seal.
6. The fake restart starts and waits on a separate Completer. The earlier `stopAndDrain()` nevertheless returns after its original build snapshot settles.

The regression asserts no restart should begin after ordinary stop. It fails with one invocation, while the restart barrier remains unreleased. Zero Settings invocations demonstrate that merely retaining every Settings flight cannot fix this defect. No native process action ran.

Minimum separate correction to authorize: define precedence of ordinary stop over queued assessment-triggered restart; prevent queued work from starting after ordinary stop; account truthfully for any already-started restart and its failure/settlement; preserve explicitly requested restart behavior without self-await. The current controller and its existing tests are the evident owner. Whether further changes are necessary must be established in that task rather than assumed here. Retain this causal reproducer and include queued-versus-active restart cases before resuming Settings qualification. This is a scope recommendation, not an implemented restart redesign.

## Hash evidence

SHA-256, paths relative to repository root:

| File | Baseline | Final |
| --- | --- | --- |
| `lib/essentials/app_czar_onboarding/application/app_czar_onboarding_controller.dart` | `08a23fad618b180821a3abedcd4e3cfccc293fb4a7e9b569923711ca5f576752` | unchanged |
| `lib/essentials/app_czar_onboarding/application/app_czar_onboarding_controller.g.dart` | `0d934d453d112de9d16a1ea9c73b671b64cbea4ae325d1a3207d4b71bb99cd82` | unchanged |
| `lib/essentials/app_czar/presentation/app_czar_startup_harness.dart` | `03942c7287f57734bbd197f1a3c3828a8d7b093df023c3aa0940197cc27fbc7b` | unchanged |
| `test/essentials/app_czar_onboarding/application/app_czar_onboarding_controller_test.dart` | `11207ae86866823222fd0e94c22fc94ed1dba2fa13f388704179c7c4d31f1526` | `8c7ae0e61af6917fa8d730cf49ddcedfe11a0f1601daae560b478933921f7fcf` |
| `test/essentials/app_czar/presentation/app_czar_startup_harness_test.dart` | `dbcf4c5177f8240ae38247f692474af436fd8cfcb45e47ddce07d08c41b4c9ac` | `33d66589fddb843c8034f3cc0f0962e4aaa1ef382a42777febd1651f3191cbd3` |

## Validation and conformance

- Focused characterization: exit 1, four expected failures; no green-after result exists.
- Full `flutter analyze --no-pub`: initial exit 1 with two import-order infos introduced by the test imports; corrected those positions. Final exit 0, no issues, log `/private/tmp/prompt129-analyze-final.log`.
- Targeted `dart format --output=none --set-exit-if-changed` for the three handwritten allowlisted paths: exit 0, no formatting changes.
- `git diff --check` and `git diff --cached --check`: exit 0. Index empty after prerequisite checkpoint. Only the two test files are modified, unstaged.
- Broader Onboarding/build/presentation and specialist/Operating regressions, full architecture suite, multi-flight Settings matrix, overlap/disposal/replacement qualification and host error propagation after a corrected drain: **NOT RUN / NOT QUALIFIED**, because the independent owner STOP was reached. No full-app, unsafe graph mutation, OS, archive or destructive test was run.
- No generator run required: no annotated production source changed, generated companion remains byte-identical.
- SDK commands used approved escalated cache access; none was denied or interrupted. An exploratory source search used a nonexistent Operating host filename, returned exit 2, then located the actual `app_czar_operating_session_app.dart`; no qualification was inferred from the failed search.

**Reviewed against:** repository AGENTS.md, shared global guardrails, project README, shared Dart and Riverpod guidelines, Prompt 129, preserved Response 128, and `00-PREPARATION/MESSAGELENS-PROJECT-CONFORMANCE-AUDIT-STANDARD.md`. Audit scope is the test-only delta from `12462fdb`, plus the exact prerequisite STOP documentation checkpoint, not the entire accumulated feature branch.

- **BLOCKER:** the requested Settings ownership and post-seal publication defects remain; expected-red tests demonstrate them.
- **BLOCKER:** independent queued-restart ownership gap above triggers mandatory STOP.
- **NO ISSUE in inspected delta:** reuse of existing ports/providers/fixtures; test-only dependency direction; no new authority, schema, constants governing production, logging of user data, mutation capability, jurisdiction, runtime scheduling mechanism, dependency or generated change. Production UI and six specialist plus one Operating host constructions are byte-preserved. Stage 1/2 reset denial and probe preserved. Production activation remains unconditional `isEnabled => false`.
- **Not qualified:** corrected lifecycle behavior, comprehensive architecture/runtime and remaining adversarial matrix. A clean analyzer is not behavioral or project conformance PASS. UI/release behavior was not changed; no version bump or release claim is appropriate.

No implementation checkpoint or Prompt 129 completion checkpoint was committed/pushed. Only the prerequisite STOP pair was checkpointed. Final preserved state: current synchronized HEAD `b74813976f137bdb32d232ae287cff92954e8bd0`, empty index, two unstaged tests, 51 untracked files (49 unrelated plus Prompt/Response 129).

Five-listener exception-to-cancel handling remains deferred. The existing Onboarding listener has no such catch; because no corrected drain exists, error propagation through that corrected owner/host combination is not qualified here. A new Prompt 130 must first explicitly resolve the newly reproduced restart scope (or separately authorize its correction), then complete Settings ownership before resuming the listener changes. Native termination, real process death, archive-lock release, launcher identity/packaging, successor admission, FDA continuity and production data continuity remain unknown.

ONBOARDING ADMITTED SETTINGS FLIGHTS RETAINED: NO
ONBOARDING STOP-AND-DRAIN INCLUDES SETTINGS: FAIL
PENDING SETTINGS PREVENTS EXIT PERMISSION: FAIL
LATE SETTINGS PUBLICATION SUPPRESSED: FAIL
PROMPT 128 FIVE-LISTENER ERROR-TO-CANCEL WORK RESUMED: NO
SIX SPECIALIST AND ONE OPERATING HOSTS UNCHANGED: YES
STAGE 1/2 RESET DENIAL UNCHANGED: YES
PRODUCTION APPCZAR ACTIVATION: OFF
PROJECT CONFORMANCE: FAIL
READY FOR NEW SEPARATE PROMPT 130: NO
