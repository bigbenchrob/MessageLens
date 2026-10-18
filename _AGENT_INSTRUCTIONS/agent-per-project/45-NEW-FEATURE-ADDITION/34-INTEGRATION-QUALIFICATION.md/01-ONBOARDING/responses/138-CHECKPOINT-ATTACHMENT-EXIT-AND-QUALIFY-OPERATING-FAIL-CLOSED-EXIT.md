# Response 138 — STOP: Operating drain omits an active restart

## Disposition

Mandatory STOP before any production listener edit. The real selected Operating currentness owner returns successful ordinary drainage while its already-invoked restart port remains pending. The actual registered Operating listener then returns `AppExitResponse.exit`. Prompt 138 §0/§3 requires STOP on this owner-precondition failure, and expressly excludes controller correction. Adding a listener catch would not repair this successful-but-incomplete drain.

One passing pending-observation control and one expected-red restart reproducer are preserved, unstaged, in the authorized existing Operating app test file. No production, generated, architecture, dependency, native, release or activation file changed. No commit or push was made. Exact Prompt/Response 138 remain untracked. This is a qualification STOP, not an observed real application termination or production incident.

## Verified recovery

- Branch `fix/onboarding-import-stuck-state`; HEAD `a1e1ffc6ab40460eab6b4a3f5caa7345dfd1b080`; upstream `0/0`; clean tracked baseline and empty index.
- Source ancestor `41a088fe95546726cd61bf2d4c8a9233500b010a` verified. HEAD already contains exact Prompt/Response 137, separately from that source checkpoint; no duplicate documentation commit.
- All six final Prompt 137 source/test/generated hashes match. All 17 protected Prompt 121 reset hashes and both Prompt 127 observer hashes also match; equality is provenance, not fresh behavioral qualification.
- `/private/tmp/prompt138-baseline.json`: 6,054 tracked regular files and 50 untracked files, comprising the 49 unrelated files plus Prompt 138. Final comparison changes only the allowed test; Response 138 is the only additional file. All other baseline bytes are preserved, including navigation README, historical documents, archived backup scripts, screenshots and configuration.
- Four registered worktrees; one holds this branch. Other HEADs unchanged: Feature 35 `09b1c767cc01410da5799273206e2ab2a4d3b283`, main `b67bfafc3ad4f4f0c15792f0245bfecf5e45f43f`, Gradle `4f3e4fcc4eed2bd69eb237ae0aa328c917bbce37`.
- Shared instructions submodule clean at `95326f515ef4719f155ce6e223990398daad6311`. No stash/reset/clean/rebase/force push, branch switch, archival staging or other worktree writes.

## Source findings

`lib/essentials/app_czar_operating_session/presentation/app_czar_operating_session_app.dart:98` reads the session at exit time. Its callback passes that session to `drainAppCzarOperatingExitRequest`, whose selected occurrence is used for an exit-time currentness notifier read at lines 102–108. The helper awaits that notifier's drain, then returns exit; neither helper nor callback catches drain errors. One listener is registered in `initState` and disposed on unmount. The production workspace has one subordinate currentness status host, which starts currentness after the shell frame and schedules restart after issue presentation. The test router replaces the data-bearing workspace with an inert route; the actual Operating app and registered lifecycle callback remain mounted.

`app_czar_operating_currentness_controller.dart:67–80` seals polling/work and sets `_restartSuppressed`, but waits only `_activeFlight`. Observation/update work is registered in that slot before the cycle runs. Its completion clears the slot. `restartAfterIssuePresented` at lines 86–110 has a separate `_restartStarted` flag, drains observation/update work, checks suppression, then awaits the restarter at line 102. That awaited restart future is not retained in `_activeFlight`, and ordinary drain neither awaits nor refuses it. Once the port is entered, setting suppression cannot undo the outstanding call.

The session controller independently owns admission/visual initialization. Assessment replacement invokes occurrence-specific currentness drainage before releasing the old occurrence, then can initialize a new one. This replacement path and exit-time reselection still need qualification; no absence-of-bypass claim is made. Disposal cancels polling and suppresses publication but is not an awaited drain. The owner also converts observation errors into issue state and completes its observation flight; the passing control below proves settlement only, not complete error retention.

| Path | Evidence in this milestone |
| --- | --- |
| Pending admitted observation | Actual owner and registered exit remain pending until the controlled observation settles; executable PASS |
| Active restart | Actual owner falsely reports successful drain and actual listener grants exit before port settlement; executable BLOCKER |
| Pending live update/preservation | Source retained under observation flight; not executed after STOP |
| Synchronous/asynchronous injected drain failures | Host has no catch in source; translation matrix not run after STOP |
| Occurrence replacement/disposal during work | Source inspected; complete runtime qualification not performed |
| Listener unmount | Positive control unmounts the actual app; subsequent exit request returns exit without another observation |
| Native termination/new process/admission | Not executed or inferred |

## Causal runtime evidence

Ran the entire allowed file:

```text
/Users/rob/Development/flutter/bin/flutter test --no-pub test/essentials/app_czar_operating_session/presentation/app_czar_operating_session_app_test.dart --reporter expanded
```

**Exit 1: 4 passed, 1 expected failure.** Log: `/private/tmp/prompt138-characterization.log`. No setup/compilation failure was counted as owner evidence.

New passing control: `Prompt 138 actual Operating exit waits for admitted observation`.

A real session controller is admitted from fixed synthetic assessment and inert visual initialization. Its actual occurrence selects a real currentness controller, retained with a test subscription. Before either owner is constructed, the fixture installs an inert observation provider, restarter, router and a rejecting update-executor provider. Starting currentness calls the controlled coverage observation exactly once. The actual binding exit request remains pending until that future is explicitly completed with an inert error. The owner suppresses late publication, settles the flight and the callback returns exit. No restart or update-executor resolution occurs. This is proof of waiting for an observation, not proof of update/preservation completion or error-to-cancel handling.

Expected-red case: `Prompt 138 active Operating restart cannot drain or exit early`.

The same real session/currentness setup receives a controlled observation error while live. The real owner's catch publishes its normal `issue` phase. After a presentation pump, the test invokes the existing `restartAfterIssuePresented` method. Its inert restarter synchronously reenters the real owner's `stopAndDrain()` and calls the actual `tester.binding.handleRequestAppExit()`, then returns an unresolved Completer future. No fake controller or copied exit callback substitutes for the owner or host.

Observed and recorded before releasing the restarter:

```text
restartCalls=1
restartSettled=false
drainSucceeded=true
drainFailure=Null
exitResponse=AppExitResponse.exit
exitFailure=Null
```

The final assertion requires premature drain success to be false, so it fails causally. The captured premature exit response is also `exit`; the subsequent desired no-early-exit assertion is retained, although the first failing assertion ends that assertion sequence. The trace is observed runtime data, not an inferred native exit. There was no `StateError` refusal and no cancellation response.

Cleanup releases the restarter, awaits the restart action, direct drain and exit request, then drains settled work, unmounts the actual app, closes the subscription and disposes container/router. Controlled observation futures are also released. No timeout, sleep, timer expiry or disposal is used to infer settlement. The original three tests are unchanged and passed.

The route is intentionally inert; automatic status-host restart scheduling and the full workspace are not claimed as exercised. The real restart entry point, real occurrence selected by a real session controller, real currentness owner and real registered Operating exit callback are exercised. Update-executor resolution remains zero, proving this fixture does not reach its real worker/tenure seam.

## Safety and validation boundaries

All new inputs are synthetic. No real Messages/Contacts/database/archive/payload/root, mutation capability/Ball/tenure/lease, native launch/exit, Settings/FDA/TCC/bookmark, signing, cloud or app build ran. The real observation provider's filesystem/archive reads are replaced before admission. No real live worker is constructed.

Screened and explicitly excluded `stopAndDrain waits for the real live-update Ball to release` in `test/essentials/app_czar_operating_session/application/app_czar_operating_currentness_controller_test.dart`: its fixture uses a concrete `LiveGraphUpdateWorker`, admitted authority and the real update-executor admission path. The whole currentness test file was not run. Other controller/currentness matrices, specialist regressions and full architecture execution were not run after the mandatory precondition STOP; unchanged source hashes do not substitute for those runtime gates. No whole Flutter suite or build_runner ran.

Completed validation:

| Command/gate | Result |
| --- | --- |
| Entire Operating app test file | Exit 1; 4 passed, 1 expected-red owner counterexample |
| `flutter analyze --no-pub` | Exit 0; no issues, 5.9 seconds; `/private/tmp/prompt138-analyze.log` |
| Targeted `dart format --output=none --set-exit-if-changed` | Exit 0; one file, zero changes; `/private/tmp/prompt138-format.log` |
| `git diff --check` | Exit 0 |
| Exact allowlist and full baseline hash comparison | Only authorized test changed; all unrelated files preserved |
| Staged diff | Empty; no checkpoint attempted |
| Architecture/regression/full fail-closed matrix | NOT RUN / NOT QUALIFIED after required STOP |

Only changed tracked path:

`test/essentials/app_czar_operating_session/presentation/app_czar_operating_session_app_test.dart`

278 added lines, zero deletions. SHA-256:

`822117e0552734631d71820fa90d3e64f942be9673091014902414c72a831dfc`

## Project Conformance and required follow-up

**Reviewed against:** repository AGENTS.md; shared global guardrails, Dart/Riverpod rules; project README; database and archive-preservation constraints; Feature 34 Project Conformance Audit Standard; Prompt 138, Response 137 and Response 126's Operating audit; actual Operating app/session/currentness/status/observer/update-executor implementations and relevant tests. Scope is the final Operating listener qualification against baseline `a1e1ffc6`, including the unstaged reproducer, not a production release audit.

**BLOCKER: 1. SHOULD FIX: 0 identified within the inspected scope.** The blocker is real-owner incomplete drainage during active restart. Remaining runtime matrix items are unqualified, not silently counted as NO ISSUE.

The reproducer respects layering, generated-provider seams, privacy, preservation authority, single-currentness ownership and file scope. It adds no production abstraction, dependency, public test forge, poller, authority or jurisdiction. Existing tests and all production bytes remain intact. Error-to-cancel alone is insufficient because this demonstrated owner path returns success. Documentation accurately distinguishes explicit exit permission from native termination.

A separately authorized owner-focused prompt must address Operating currentness restart ownership and ordinary/reentrant stop precedence, including registration before port entry, queued versus active restart, failure retention and disposal/currentness retirement, with complete inert qualification. The callback's occurrence capture and failure-to-cancel matrix can only proceed after that prerequisite is satisfied. This response does not authorize or implement that correction.

OPERATING EXIT OWNER QUIESCENCE QUALIFIED: NO
OPERATING ACTUAL EXIT LISTENER FAILS CLOSED: NO
SIX SPECIALIST EXIT LISTENERS PRESERVED: YES
OPERATING SOLE CURRENTNESS OWNER PRESERVED: YES
SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES
STAGE 1/2 RESET DENIAL UNCHANGED: YES
REAL PROCESS EXIT/FRESH LAUNCH IMPLEMENTED: NO
PRODUCTION APPCZAR ACTIVATION: OFF
PROJECT CONFORMANCE: FAIL
READY FOR SEPARATE PROMPT 139: NO
