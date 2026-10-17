# Response 135 — PASS: Diagnostic Review restart registration and reentrant drain

## Result and evidence limits

Diagnostic Review now registers its scheduled lifecycle flight before publishing draining state or invoking the restarter. Dispatch rechecks permanent stop/currentness, and the active flag is set before resolving the port. Ordinary stop seals synchronously, suppresses queued dispatch, and deterministically refuses an active restart with `StateError` rather than returning false success or awaiting its own caller. After successful synthetic port settlement, later drainage succeeds. No new process or assessment is inferred.

**Controller-only PASS.** The production Diagnostic host is unchanged. Its registered callback now propagates active-restart refusal; it does not return a qualified `AppExitResponse.cancel`. That remains a separate production-cutover blocker. All four remaining listener changes, native termination/launcher integration, archive-lock release, signing/FDA continuity and independent next-process admission remain unqualified/unimplemented. Production activation stays OFF.

No real source, database, archive payload, admitted root, Settings/FDA/TCC/bookmark, process, native Runner, cloud, Ball/tenure/capability/lease, import, graph or repair operation ran. Fixed synthetic observations/assessments, clocks and inert restarters were installed before selected controller/host construction. Test path strings were evidence only, never filesystem authority.

## Verified recovery and checkpoint sequence

- Baseline branch `fix/onboarding-import-stuck-state`; HEAD `004e25858712e121592672c09e202cfe840aadaa`; upstream `0/0`; index empty; one intended unstaged harness-test edit.
- Inherited harness SHA-256 exactly `bc8ac3772d1ee0d911b8fba1cf986dfd4895b5dcaf97ab4ce80c151e3c36bb85`, matching Response 134's 109 additions/zero deletions. Its historical baseline `a71180c8664108c3c2a841a435c49314cf72049fcf9f59cbee410847e023fa1f` remains recorded. Preserved the real-owner causal assertion and fixtures; strengthened the final refusal classification and later-drain assertion.
- `/private/tmp/prompt135-baseline.json` inventories 6,046 tracked regular files and 52 untracked files: 49 unrelated plus Prompt/Response 134 and Prompt 135. No unexpected divergence or already-completed owner correction.
- Exact prior STOP pair checkpointed and pushed before source changes: `041f642a59bd67d765d73255ea07b51c06983821`. Historical STOP not rewritten.
- Exact four-file qualified implementation checkpoint, pushed: `35fab08a77c5f872acfd1afe84cee1777e62c5bc`.
- Exact Prompt/Response 135 are checkpointed separately afterward. Actual documentation commit hash belongs in final Codex handoff, not this self-referential body. Source push synchronized; final docs push/upstream checked at handoff.

Protected ancestry verified: Stage 1 `e21334de96c2ab1484acbb8f3378ccad2cc49972`, Stage 2 `daac3e6b54812c98d56dba7eb3ea8fb8f8296798`, Data Update `a90612830fac05d79fff5d6097c2b0d35dd23b6e`, Source Access `5eb7e58b4e24589114d18bac1bf6aef0bba4ab5a`, Onboarding `8e10bd58537f5fa2f409b3c69e16a805be8b12b2`, Local Repair `891ae8483a8a463e895cf656924226268d758b0b`, disposable observer `c5d727a9c21aaced5fe000ae8bae0f8d096df6d2`. All recorded Stage 2 and probe hashes match; probe not rerun.

Four worktrees verified. Other HEADs unchanged: Feature 35 `09b1c767cc01410da5799273206e2ab2a4d3b283`, main `b67bfafc3ad4f4f0c15792f0245bfecf5e45f43f`, Gradle `4f3e4fcc4eed2bd69eb237ae0aa328c917bbce37`. Shared submodule clean at `95326f515ef4719f155ce6e223990398daad6311`. No writes to other worktrees. Full manifest preserves navigation README, historical restored documents, three archived scripts and 49 unrelated untracked files. No archive moves staged, stash/clean/reset/rebase/force push or sweeping staging.

## Characterization and correction

Before production edits, the preserved harness test (`--plain-name 'Prompt 134'`) failed, **exit 1, 0 passed/1 expected failure**; `/private/tmp/prompt135-inherited-red.log`:

```text
restartCalls=1 restartSettled=false
drainSucceeded=true drainFailure=null
exitResponse=null exitFailure=null
```

This matches Response 134: direct synchronous reentrant drain falsely succeeded; registered host remained pending. It was not an early-exit host trace.

A new direct-controller characterization (`--plain-name 'Prompt 135'`) also failed against unchanged source, **exit 1, 0 passed/1 expected failure**; `/private/tmp/prompt135-controller-red.log`. The restarter synchronously called ordinary stop before returning its controlled future, and drain succeeded prematurely. No fixture/SDK/compilation failure was counted as behavioral evidence.

The corrected preserved actual-host test passes with these asserted observations while the restarter barrier is still held:

```text
restartCalls=1 restartSettled=false
drainSucceeded=false drainFailure=StateError
exitResponse=null exitFailure=StateError
```

Refusal message: `Diagnostic Review restart is still active.` The host exception is observed by the test, not caught inside production owner to manufacture successful drain. The port is then released, all futures awaited, and a later ordinary drain succeeds. Listener unmount/container disposal follow settlement. Neither exception nor fake success proves native cancellation, death or fresh launch.

Implementation contract:

- `_activeLifecycleAction` retains queued work before any publication/port callback can reenter. It cannot be replaced while present; duplicate actions remain inert.
- The existing approved `unawaited(action.whenComplete(...))` cleanup idiom is preserved around the owned action. The action is stored and returned; no detached port operation, new scheduler/provider or architecture exception was introduced. Active state/slot clear only when the actual action settles.
- Stop permanently seals actions and advances publication generation before any await. Queued work checks sealing before port resolution; ordinary stop awaits queued retirement. Active restart is refused immediately, avoiding self-await even when the fake restarter awaits the refusal itself.
- Assessment identity replacement seals the existing occurrence, retaining its captured diagnostic snapshot. `ref.listen` handles replacement without rebuilding/discarding the owner, and disposal seals without pretending to settle work.
- Current restart errors retain the literal `restartFailed` presentation and human retry. Errors are also retained with original stack for later drain refusal, including late errors after stop/disposal/currentness loss. A successful explicit retry clears that prior restart failure. Failed/unaccounted restart never becomes a successful ordinary drain.
- Stop still publishes `quitRequested` when mounted. Late port completion cannot reopen admission or replace the stopped/stale presentation. Disposed owners do not publish. No new UX state, evaluator, jurisdiction, work or authority.

One existing simultaneous quit/restart test was refined to expect the newly required active-restart refusal while preserving its no-second-dispatch assertion. No safety assertion was weakened. The inherited host test now explicitly asserts propagated StateError and later successful drain after settlement.

## Adversarial qualification and commands

All commands use project SDK `/Users/rob/Development/flutter/bin/flutter` or `dart` with approved cache access. No denied/interrupted invocation is treated as PASS.

| Gate | Result | Evidence |
| --- | --- | --- |
| Diagnostic controller + startup harness, complete files | exit 0; **44 passed** (21 controller, 23 harness) | `/private/tmp/prompt135-focused-qualified.log` |
| Ten screened related regression files below | exit 0; **117 passed** | `/private/tmp/prompt135-regressions-qualified.log` |
| Complete `flutter test --no-pub test/architecture --reporter expanded` | exit 0; **644 passed** | `/private/tmp/prompt135-architecture-qualified.log` |
| Full `flutter analyze --no-pub` | exit 0; no issues; 11.7 seconds | `/private/tmp/prompt135-analyze-qualified.log` |
| Targeted `dart format --output=none --set-exit-if-changed` | exit 0; 3 files, 0 changes | command output |
| Normal filtered `dart run build_runner build --build-filter=lib/essentials/app_czar_diagnostic_review/application/app_czar_diagnostic_review_controller.g.dart` | exit 0; 21 seconds | `/private/tmp/prompt135-generation.log` |
| Working/staged whitespace, exact staged allowlist and hashes | exit 0 | command output |

Focused commands: `flutter test --no-pub test/essentials/app_czar_diagnostic_review/application/app_czar_diagnostic_review_controller_test.dart test/essentials/app_czar/presentation/app_czar_startup_harness_test.dart --reporter expanded`. Earlier corrected focused runs passed 32 and then 44 tests; final 44-test run follows the final approved cleanup pattern and generation.

New direct tests cover pre-registration reentry; restarter awaiting its own drain refusal; zero restarter resolutions when stop wins queued dispatch; duplicate active actions and concurrent stops; success/error through ordinary stop, assessment replacement and disposal; suppressed stale publication; synchronous and asynchronous restart failure; retained error on repeated quit; and successful explicit retry from live restart-failed state. Every controlled pending port is released, action observed, and container/listener disposed. No new sleep or timeout-as-cancellation is used. Existing inherited time-advance/polling checks remain unchanged.

Screened related regression paths, relative to repository root:

- `test/essentials/app_czar_diagnostic_review/presentation/app_czar_diagnostic_review_screen_test.dart`
- `test/essentials/app_czar_local_data_repair/application/app_czar_local_data_repair_controller_test.dart`
- `test/essentials/app_czar_local_data_repair/presentation/app_czar_local_data_repair_screen_test.dart`
- `test/essentials/app_czar_onboarding/application/app_czar_onboarding_controller_test.dart`
- `test/essentials/app_czar_onboarding/presentation/app_czar_onboarding_screen_test.dart`
- `test/essentials/app_czar_data_update/application/app_czar_data_update_controller_test.dart`
- `test/essentials/app_czar_data_update/presentation/app_czar_data_update_screen_test.dart`
- `test/essentials/app_czar_source_access/application/app_czar_source_access_controller_test.dart`
- `test/essentials/app_czar_source_access/presentation/app_czar_source_access_screen_test.dart`
- `test/essentials/app_czar_operating_session/presentation/app_czar_operating_session_app_test.dart`

These use fixed view states, inert callbacks/readers/settings/executors/restarters and inert Operating routes. Real executor/tenure/capability/archive/reset/graph suites excluded. Architecture suite is source/AST inspection and disposable parser fixtures, including tests whose names mention real tenure but only inspect test source. No complete unrelated Flutter suite, build/signing/native launch or OS exit probe was needed/run.

## Manifest and Project Conformance

Full initial/final byte comparison permits only these four Dart changes, plus exact separate documentation checkpoints. Generator reported 24 cached/lazy/generated outputs, but only the named companion's source hash changed. No schema/dependency/native/generated churn elsewhere. Final implementation manifest `/private/tmp/prompt135-final-hashes.json`:

| Path | SHA-256 |
| --- | --- |
| `lib/essentials/app_czar_diagnostic_review/application/app_czar_diagnostic_review_controller.dart` | `bc6bb7c306bd90d52ff835ae26063310eea674b59f916a574aab658c0e8a39ca` |
| `lib/essentials/app_czar_diagnostic_review/application/app_czar_diagnostic_review_controller.g.dart` | `57d474e165bb0a3c55b8d0737e1a8066317e30605dbb4c8a76097fcc15e8f051` |
| `test/essentials/app_czar_diagnostic_review/application/app_czar_diagnostic_review_controller_test.dart` | `54968a9325221da349783d8a80b9aa3c3f63ec15f7f20f70f4cb298d78ac5f9c` |
| `test/essentials/app_czar/presentation/app_czar_startup_harness_test.dart` | `2a474cdf6981ef81e6c1388535fb92b53c94ad46beac394eb6482036fb7a92d5` |

Production host is unchanged; all prior Local Repair, Onboarding, Data Update and Source Access owner bytes are preserved. Census remains six specialist listeners and one separate Operating listener. Stage 1/2 reset denial and Local Repair safe-partial eligibility/executor boundary unchanged.

**Reviewed against:** repository AGENTS.md; shared global guardrails, Dart and Riverpod instructions; project README; database and attachment-preservation rules; canonical Feature 34 Project Conformance Audit Standard; Prompt 135 and preserved Response 134; actual Diagnostic controller/state/presentation/host/port; existing Source Access/Local Repair refusal idioms and architecture conventions. Scope: accumulated authorized owner/test delta against recovered `004e2585`, not whole-branch/native integration.

**Controller-scope BLOCKER: 0. SHOULD FIX: 0.**

- Reuse/layering/dependencies: existing notifier, typed state, fixed occurrence and restarter seam retained; no new public API, lifecycle framework, provider or authority.
- Single source of truth/project idioms: no policy duplication, source constants, schema or path authority. Generated Riverpod companion regenerated normally; existing approved async cleanup boundary preserved.
- Work/error semantics: one retained lifecycle action, registration before dispatch, permanent sealing, deterministic active refusal, queued retirement, retained original failure and no stale publication. Executed adversarial evidence supports these claims.
- Performance/privacy/mutation: bounded single flight, no poller/history collection, no new logging/user content/persistence/network/native access, no authority broadened.
- Dead code/generated/dependencies: existing flow corrected in place; no alternate restart/assessment route, obsolete parallel implementation or dependency churn.
- Tests/architecture: final focused/regression/architecture and analyzer gates pass without new exemption or changed architecture assertion.
- Documentation/UX: existing diagnostic snapshot and explicit retry/quit preserved; no release metadata or activation change in this gated internal owner milestone. Error retention is explicitly refined and tested, not misrepresented as native quiescence.

**Out-of-scope production-cutover blocker:** unchanged Diagnostic listener still propagates drain refusal instead of returning cancel. Remaining Attachment/Operating owner prerequisites and the complete four-listener correction are not resumed here. Signed/native process death, archive lock release, fresh launcher, persistence/backup/data continuity and independently admitted next AppCzar assessment remain UNKNOWN/unimplemented.

DIAGNOSTIC RESTART FLIGHT REGISTERED BEFORE PORT INVOCATION: YES
REENTRANT DIAGNOSTIC DRAIN FALSE SUCCESS PREVENTED: YES
DIAGNOSTIC RESTART SELF-AWAIT PREVENTED: YES
ORDINARY DIAGNOSTIC STOP AND ERROR SEMANTICS QUALIFIED: YES
DIAGNOSTIC EXIT LISTENER ERROR-TO-CANCEL QUALIFIED: NO
FOUR REMAINING EXIT LISTENERS QUALIFIED: NO
STAGE 1/2 RESET DENIAL UNCHANGED: YES
SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES
PRODUCTION APPCZAR ACTIVATION: OFF
REAL PROCESS EXIT/FRESH LAUNCH IMPLEMENTED: NO
PROJECT CONFORMANCE (CONTROLLER SCOPE): PASS
READY FOR NEW SEPARATE PROMPT 136: YES
