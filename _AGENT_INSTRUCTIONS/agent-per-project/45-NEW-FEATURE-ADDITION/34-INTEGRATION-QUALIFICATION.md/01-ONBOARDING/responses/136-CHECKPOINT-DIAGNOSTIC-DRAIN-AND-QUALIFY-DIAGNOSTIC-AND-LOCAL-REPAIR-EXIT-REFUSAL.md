# Response 136 — PASS: Diagnostic and Local Repair exit refusal

## Result and limits

The two actual registered Diagnostic Review and Local Data Repair exit callbacks now capture their already-selected owner's drain at mount, await it, return `exit` only after successful completion, and return `cancel` on synchronous/asynchronous failure or active-restart refusal. Capturing these owners is safe under the existing selection path: the coordinator host has already read the corresponding controller and selected its visible state before mounting its lifecycle host. Exit no longer resolves a replacement provider.

This is permission-to-exit qualification, not native termination or cancellation of the underlying operation. An active restart remains pending after its owner's refusal and the listener's cancel response until its controlled port actually settles. No native launch/death, process observation, archive-lock release or successor admission is inferred.

Attachment Archive Repair and Operating owner/listener proof remain unqualified here. Real termination, launch-target identity/signing, FDA continuity, independent native/Dart admission, in-place migration/data continuity and backup/rollback remain UNKNOWN/unimplemented. Production activation stays OFF. No real source/database/archive/root/Settings/permission/native/tenure/lease/Ball/cloud work ran.

## Recovery and preservation

Baseline: branch `fix/onboarding-import-stuck-state`, HEAD `193762bbca3f4271e217aaa374ccedac1b15a156`, upstream `0/0`, clean tracked tree and index. That HEAD already checkpointed exact Prompt/Response 135; verified rather than duplicating it.

Verified qualified Diagnostic source `35fab08a77c5f872acfd1afe84cee1777e62c5bc`, Local Repair `891ae8483a8a463e895cf656924226268d758b0b`, Stage 1 `e21334de96c2ab1484acbb8f3378ccad2cc49972`, Stage 2 `daac3e6b54812c98d56dba7eb3ea8fb8f8296798`, and Onboarding `8e10bd58537f5fa2f409b3c69e16a805be8b12b2` ancestry. Diagnostic final hashes and Local Repair owner/generated/controller-test hashes matched the prior qualification manifests. The shared harness test appropriately matched the later Prompt 135 hash, not its older Prompt 133 version.

`/private/tmp/prompt136-baseline.json` records 6,050 tracked regular files and 50 untracked files (49 unrelated plus Prompt 136). Full comparison preserves every baseline byte outside the exact three authorized paths. The navigation README, 218 restored historical documents, three archived scripts and unrelated files remain untouched/un-staged. No generation, dependency/native/release changes, stash/reset/clean/rebase/force-push or broad staging.

Four worktrees remain registered. Other HEADs unchanged: Feature 35 `09b1c767cc01410da5799273206e2ab2a4d3b283`, main `b67bfafc3ad4f4f0c15792f0245bfecf5e45f43f`, Gradle `4f3e4fcc4eed2bd69eb237ae0aa328c917bbce37`. Clean shared submodule `95326f515ef4719f155ce6e223990398daad6311`. Recorded Stage 2 and exit-probe hashes match; no probe execution.

Implementation checkpoint: `ab013750491fb9ddf5208446ee8367f388882912`, pushed separately from this documentation. Exact Prompt/Response 136 form the subsequent docs checkpoint; its actual hash belongs in the final handoff. Final upstream/index/byte checks are performed after that push.

## Red-before and green-after evidence

Current SDK source `packages/flutter/lib/src/widgets/binding.dart:818` awaits each observer and aggregates explicit cancel responses; it does not translate thrown observer errors to cancel. Both target production callbacks originally performed an exit-time notifier read and awaited drain without a catch.

Before production edits, ran the entire harness file with new desired cancellation assertions and explicitly labelled injected faults:

`flutter test --no-pub test/essentials/app_czar/presentation/app_czar_startup_harness_test.dart --reporter expanded`

**Exit 1: 24 passed, 8 expected failures**, `/private/tmp/prompt136-red.log`. Eight failures were two real active-restart refusals, two real retained restart failures, and synchronous/asynchronous injected drain exceptions for each target branch. All failed because the current callback propagated error instead of returning cancel. Pending/success controls passed; no setup or compilation failure was counted as owner evidence.

Preserved Prompt 134 Diagnostic and Prompt 132 Local Repair cases keep their real owners and original causal fixtures. The Local Repair executor still fails before mutation and shows the legitimate failed/retry UI. Diagnostic uses the complete fixed inert observation reader and clock. The port remains pending; direct ordinary drain reports StateError. Before the edit both host requests propagated that error (`exitResponse=null`, `exitFailure=StateError`). After the edit each returns `AppExitResponse.cancel`, with no escaping error; owner refusal remains StateError and the port remains unsettled until explicitly released. Subsequent actual registered exit succeeds only after successful settlement and later owner drainage.

A separate ordinary Diagnostic active-restart test (distinct from synchronous reentry) calls drain, then repeats actual exit requests while the port is pending: both return cancel, exactly one restart call remains, and after settlement exit succeeds. The real retained-restart-error tests make the inert port fail, await its action, and verify actual host cancel while the original owner retains the failure. No fake owner substitutes for these ownership proofs.

Separately labelled injected callback tests override only `stopAndDrain` on test subclasses while using the actual host and its normal selected presentation. They prove translation, not real-worker failure provenance. For each branch:

- synchronous throw returns cancel;
- asynchronous failure stays pending until the controlled future errors, then returns cancel;
- successful controlled drain stays pending until actual completion, then returns exit;
- concurrent requests invoke the selected drain twice without duplicate owner construction;
- provider invalidation rebuilds the existing notifier in place, and the mounted host still uses the captured drain; no new construction is claimed;
- after unmount the listener is removed: a binding request returns exit and does not increment the retired callback's count.

A real Local Repair controller test holds its injected non-mutation executor pending: registered exit remains pending until stale-result settlement, then exits with zero restart calls and exactly one executor call. Diagnostic has no analogous ordinary background worker: its owned asynchronous work is restart, covered by real refusal/settlement tests; the controlled pending-drain matrix separately proves callback waiting.

All controlled futures are settled and awaited before teardown; listeners/widgets/containers disposed. No new sleeps, timeouts, disposal-as-drain or exhausted-pump success inference. Prior owner tests remain intact; historical host assertions are strengthened from propagated error to cancel and retain provenance in their names.

## Validation

Project SDK `/Users/rob/Development/flutter/bin/flutter` and `dart`, approved cache access. All final commands completed with exit 0:

| Gate | Count/result | Log |
| --- | --- | --- |
| Entire startup harness + Diagnostic controller + Local Repair controller files | 80 passed (33 + 21 + 26) | `/private/tmp/prompt136-focused-final.log` |
| Six screened presentation/exit regression files | 15 passed | `/private/tmp/prompt136-regressions-final.log` |
| Complete `test/architecture --reporter expanded` | 646 passed | `/private/tmp/prompt136-architecture-final.log` |
| Full `flutter analyze --no-pub` | no issues; 11.5 seconds | `/private/tmp/prompt136-analyze-final.log` |
| Targeted `dart format --output=none --set-exit-if-changed` | 3 files, zero changes | command output |
| Working/staged whitespace, exact paths and hashes | pass | command output |

Focused command used `flutter test --no-pub` with the harness, `test/essentials/app_czar_diagnostic_review/application/app_czar_diagnostic_review_controller_test.dart`, and `test/essentials/app_czar_local_data_repair/application/app_czar_local_data_repair_controller_test.dart`, reporter expanded. The initial corrected run passed 79; final run adds the distinct ordinary Diagnostic restart case and follows final source/test edits.

Regression files under `test/essentials/`: Diagnostic Review, Local Data Repair, Onboarding, Data Update and Source Access `presentation/*_screen_test.dart`, plus `app_czar_operating_session/presentation/app_czar_operating_session_app_test.dart`. Screened as inert view states/callbacks, overridden ports and inert Operating routes. Excluded real tenure/capability/lease, repair executor, graph/import/reset/archive/native suites; no full unrelated Flutter suite or production build.

Architecture remains source/AST inspection and disposable parser fixtures. Two positive tests were added to the existing architecture file for captured drains, error-to-cancel response, no exit-time provider read, disposal and one listener per target. All original assertions and six-plus-one census remain; no exemption or existing rule was changed. No generator ran or generated bytes changed. No denied/interrupted attempt was counted as passing. No fixture correction was needed in this milestone.

## Exact delta and conformance

Only production changes: Diagnostic Review and Local Data Repair lifecycle host state classes in the existing startup harness, adding captured drain tear-offs and try/await/catch-to-cancel. A byte comparison with those two class blocks removed proves all other host and selection/routing code is identical. Controllers, other hosts, Operating app, reset/activation rules and generated files remain byte-identical.

Other changed files: existing harness test and existing architecture test. Final manifest `/private/tmp/prompt136-final-hashes.json`:

| Path | SHA-256 |
| --- | --- |
| `lib/essentials/app_czar/presentation/app_czar_startup_harness.dart` | `e9c3e406998f7cdf0d1bd5b8fdd13389914ac49e3f37328b48b30437dbb253b6` |
| `test/essentials/app_czar/presentation/app_czar_startup_harness_test.dart` | `9a970edd97d953055acab5bc725d91d067f241496eadadde46860550d216bf5b` |
| `test/architecture/app_czar_architecture_test.dart` | `4b064e13c7e07dd421e29f173a1f363600533eb0235f2c388b97d167b7f98aa7` |


**Reviewed against:** repository AGENTS.md; shared global guardrails, Dart/Riverpod rules; project README; database/archive preservation constraints; canonical Feature 34 Project Conformance Audit Standard; Prompt 136 and Responses 133/135; current selected host/controller/presentation/port implementations and Flutter callback source. Scope: authorized two-host delta against `193762bb`, not release or whole-branch integration.

**BLOCKER: 0. SHOULD FIX: 0 within this milestone.**

- Reuse/layering: existing selected owners and lifecycle host idiom; no evaluator, new provider, generic shutdown mechanism or authority transfer. Presentation translates drain result only.
- Ownership/error semantics: capture after existing selection; no replacement lookup on exit; actual awaited success required for exit; errors/refusals become cancel without changing owner state/error or claiming cancellation of its work. Tests distinguish pending, success, active refusal and retained error.
- Performance/privacy/safety: bounded callbacks, no timer/poller/history, no new logging or data/persistence/native access, no broadened reset or mutation permission.
- Provider/generated/dependency hygiene: no annotated/provider edits, generator or dependencies. Other qualified hosts and owners unchanged.
- Architecture/tests/documentation: all original guards preserved, positive contract tests added; final executable/analysis checks pass. Runtime limitations remain explicit, and no release/activation claim is made.
- UI: no new state, routing or diagnostic text; existing retry/quit semantics unchanged except the intended explicit refusal at the permission boundary.

Attachment/Operating owner and listener proof, ordinary native termination/process observation, launcher identity/signing, archive lock release, next-process admission, FDA, in-place data/migration and backup/rollback remain out of scope and unqualified. No next jurisdiction was started.

DIAGNOSTIC EXIT FAILURE-TO-CANCEL QUALIFIED: YES
LOCAL DATA REPAIR EXIT FAILURE-TO-CANCEL QUALIFIED: YES
REAL OWNER ACTIVE-RESTART REFUSAL PRESERVED: YES
ATTACHMENT ARCHIVE REPAIR EXIT QUALIFIED HERE: NO
OPERATING EXIT QUALIFIED HERE: NO
SIX SPECIALIST + ONE OPERATING LISTENER CENSUS PRESERVED: YES
STAGE 1/2 RESET DENIAL UNCHANGED: YES
SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES
REAL FRESH LAUNCH/PRODUCTION ACTIVATION IMPLEMENTED: NO
PRODUCTION APPCZAR ACTIVATION: OFF
PROJECT CONFORMANCE: PASS
READY FOR ONE SEPARATE PROMPT 137: YES
