# Response 134 — STOP: Diagnostic Review reentrant drain bypasses admitted restart

## Disposition

STOP before any production listener edit. The real Diagnostic Review controller can return successful ordinary drainage while its already-invoked restart port remains pending. Prompt 134 §3 requires STOP on this concrete owner-quiescence counterexample. Controller correction is outside the exact allowlist; adding an exit catch cannot repair a successful but incomplete owner drain.

One expected-red test is preserved, unstaged, in the allowed existing startup-harness test. No production, generated, architecture, dependency or activation file changed. No implementation/documentation commit or push occurred. Prompt/Response 134 remain untracked; historical records are unchanged.

## Verified recovery

- Branch `fix/onboarding-import-stuck-state`, HEAD `004e25858712e121592672c09e202cfe840aadaa`, upstream `0/0`; initially clean tracked tree and index.
- HEAD already contains exact Prompt/Response 133, separately from source checkpoint `891ae8483a8a463e895cf656924226268d758b0b`. Verified the two-document commit; no duplicate checkpoint.
- All four Prompt 133 qualified hashes matched initially. Final comparison changes only the allowed harness test; the Local Repair owner/generated/controller-test bytes remain qualified and unchanged.
- Verified ancestry: Stage 1 `e21334de96c2ab1484acbb8f3378ccad2cc49972`, Stage 2 `daac3e6b54812c98d56dba7eb3ea8fb8f8296798`, Data Update `a90612830fac05d79fff5d6097c2b0d35dd23b6e`, Source Access `5eb7e58b4e24589114d18bac1bf6aef0bba4ab5a`, Onboarding `8e10bd58537f5fa2f409b3c69e16a805be8b12b2`, Local Repair above, disposable observer `c5d727a9c21aaced5fe000ae8bae0f8d096df6d2`.
- `/private/tmp/prompt134-baseline.json`: 6,046 tracked regular files and 50 untracked files (49 unrelated plus Prompt 134). All baseline bytes except the one test remain unchanged. This response is the sole additional file. Restored historical documents, navigation README and three archived scripts are preserved; no archival moves staged.
- Four registered worktrees verified. Other HEADs unchanged: Feature 35 `09b1c767cc01410da5799273206e2ab2a4d3b283`, main `b67bfafc3ad4f4f0c15792f0245bfecf5e45f43f`, Gradle `4f3e4fcc4eed2bd69eb237ae0aa328c917bbce37`. No write targeted those worktrees.
- Shared instructions submodule clean at `95326f515ef4719f155ce6e223990398daad6311`. All 17 recorded Stage 2 hashes and both observer hashes match. No probe, real data operation, stash/reset/clean/rebase/force-push or sweeping staging.

## Executed owner counterexample

Source, relative to repository root:

- `lib/essentials/app_czar_diagnostic_review/application/app_czar_diagnostic_review_controller.dart:102` calls `_restartAtProcessBoundary` before line 103 assigns `_activeLifecycleAction`.
- `_restartAtProcessBoundary` invokes the restarter at line 119 before its first await returns control.
- `stopAndDrain` closes admission and publishes quitRequested, then line 151 awaits the current `_activeLifecycleAction`. A synchronous port reentry reaches it before that slot is assigned.

The new test `Prompt 134 Diagnostic reentrant restart cannot drain or exit early` mounts the actual startup harness, actual Diagnostic controller and actual registered listener. It uses the existing inert `_ArchiveVariantReader(_unknownCoverageArchive)` so the real assessment provider produces complete diagnostic presentation evidence. Fixed clock and inert restarter overrides are installed before construction. The visible Diagnostic screen and real `presenting` phase are verified before invoking `tryAssessmentAgain()`.

The injected restarter records entry, synchronously invokes the real owner's drain and requests exit through `tester.binding.handleRequestAppExit()`, then returns an unresolved Completer future. No owner or lifecycle callback is replaced. Before releasing the port, the executed trace is:

```text
restartCalls=1 restartSettled=false
drainSucceeded=true drainFailure=null
exitResponse=null exitFailure=null
```

The owner drain success is the concrete prerequisite violation. **The registered host remains pending in this trace.** It does not demonstrate early host exit or confirmed cancellation; the test binding delivers the callback after lifecycle-action registration. After releasing the port, the action and both observed futures complete, then the test fails its preserved assertion that premature owner drain must not succeed. Cleanup releases the port in finally, awaits all operations, unmounts the listener and disposes the container. No timeout, sleep, disposal-as-settlement or native termination inference.

Source also shows why merely moving assignment is insufficient as a complete design: a restarter that awaits reentrant drainage could cause self-await once its own flight is retained. That is a source-grounded risk, not a separately executed deadlock claim. A future owner correction needs registration-before-port invocation plus explicit active-restart refusal or another proven non-cyclic ownership contract.

## Per-owner prerequisite outcome

| Owner | Evidence and disposition |
| --- | --- |
| Local Data Repair | Preserved Prompt 132/133 actual-host test rerun unchanged: PASS. Real failed-state retry remains pending, owner refuses with StateError, unchanged host propagates refusal, later drain succeeds after settlement. Host cancellation remains unqualified. |
| Diagnostic Review | Executed real-owner registration-gap counterexample above. BLOCKER; STOP before catches. Actual host request stayed pending in this reproduction. |
| Attachment Archive Repair | Source inspected: drain awaits executor drain and `_activeRun`; `retryRestart`, `_restartForFreshAssessment`, and detached stale-drain continuation require ownership qualification. No executable certification completed before STOP; no real executor invoked. |
| Operating Session | Source inspected: host chooses session occurrence; currentness drain suppresses restart, stops admission and awaits `_activeFlight`. `restartAfterIssuePresented` separately awaits restarter. Full occurrence/restart ownership and actual registered fault matrix NOT QUALIFIED before STOP. No real worker invoked. |

All four outstanding exception-to-cancel boundaries remain unchanged. Prior Data Update, Source Access and Onboarding host protections remain byte-identical. Census remains six specialist listeners and one independent Operating listener, seven jurisdictions. No reset or activation edits.

## Validation and limitations

Commands use `/Users/rob/Development/flutter/bin/flutter` and `dart` with approved SDK-cache access.

- `flutter test --no-pub test/essentials/app_czar/presentation/app_czar_startup_harness_test.dart --plain-name 'Prompt 134' --reporter expanded`: final exact preserved test **exit 1, 0 passed/1 expected failure**. `/private/tmp/prompt134-diagnostic-preserved.log`. Failure is the owner-quiescence assertion, not setup.
- Same command with `--plain-name 'Prompt 132'`: **exit 0, 1 passed**; `/private/tmp/prompt134-local-repair.log`. This verifies the existing owner refusal/host propagation contract, not catch-to-cancel.
- Full `flutter analyze --no-pub`: final **exit 0, no issues**, 5.2 seconds; `/private/tmp/prompt134-analyze-final.log`.
- Targeted `dart format --output=none --set-exit-if-changed`: **exit 0**, one file/zero changes.
- Working/staged `git diff --check`: **exit 0**, index empty. Full baseline byte comparison: only authorized harness test changed.
- Full focused files, broader controller regressions, complete architecture and four-host fault/disposal matrix: **NOT RUN/NOT COMPLETED due to the explicit prerequisite STOP**. No historical counts are promoted into fresh qualification. Real tenure/capability/archive/reset/graph suites excluded; no full Flutter suite, generator, production build or observer probe.

Initial fixture attempt failed because a manually abbreviated assessment lacked the observation fields required by the real Diagnostic screen. It was corrected to reuse the existing inert full observation reader; that setup failure is not owner evidence. Initial analysis also found a duplicate import/directive ordering issue; removed the duplicate, then final analysis passed. These intermediate failures are disclosed, not counted as qualification passes.

Harness test delta: **109 additions, zero deletions**. Baseline SHA-256 `a71180c8664108c3c2a841a435c49314cf72049fcf9f59cbee410847e023fa1f`; stopped SHA-256 `bc8ac3772d1ee0d911b8fba1cf986dfd4895b5dcaf97ab4ce80c151e3c36bb85`. Prior Local Repair and other tests remain intact.

## Conformance and minimum next scope

**Reviewed against:** repository AGENTS.md, global guardrails, project README, previously read shared Dart/Riverpod rules and database/archive preservation rules, canonical Feature 34 Project Conformance Audit Standard, Prompt 134, Responses 132–133, current four host/owner sources and existing inert test conventions. Audit scope is this prerequisite characterization, not whole-branch or release qualification.

- **BLOCKER:** Diagnostic successful reentrant drain conceals admitted pending restart. Owner correction is outside this prompt's allowlist.
- **NO ISSUE in inspected test delta:** real provider/host reuse, inert port isolation, bounded controlled work and cleanup, no new authority, persistence, user-data logging, jurisdiction, source mutation or generated churn.
- **NOT QUALIFIED:** four-host catch-to-cancel matrix, remaining owner continuation/restart contracts and broader runtime gates. A clean analyzer does not resolve the behavioral blocker.

Minimal proposed separate correction scope: Diagnostic controller, its existing controller test, preserved startup-harness test, and its generated companion only if normal generation requires it. Register admitted restart before port invocation, prevent reentrant self-await, permanently seal actions and retain relevant failures, then qualify the real host. This is a proposed amended scope, not authorization exercised here. Attachment/Operating owner prerequisites still need honest completion before host-only success can be claimed.

Final HEAD unchanged and synchronized, index empty, one unstaged test modification and 51 untracked files (49 unrelated plus exact Prompt/Response 134). No success checkpoint. Real process death/relaunch, signing/FDA continuity, new archive admission, data/backup continuity and production runtime remain UNKNOWN/unimplemented. Production AppCzar OFF.

DIAGNOSTIC EXIT ERROR-TO-CANCEL QUALIFIED: NO
LOCAL DATA REPAIR EXIT ERROR-TO-CANCEL QUALIFIED: NO
ATTACHMENT ARCHIVE REPAIR EXIT ERROR-TO-CANCEL QUALIFIED: NO
OPERATING EXIT ERROR-TO-CANCEL QUALIFIED: NO
ALL SIX SPECIALIST EXIT LISTENERS FAIL CLOSED: NO
OPERATING EXIT LISTENER FAILS CLOSED: NO
STAGE 1/2 RESET DENIAL UNCHANGED: YES
SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES
REAL PRODUCTION FRESH LAUNCH IMPLEMENTED: NO
PRODUCTION APPCZAR ACTIVATION: OFF
PROJECT CONFORMANCE: FAIL
READY FOR A SEPARATE PROMPT 135: NO
