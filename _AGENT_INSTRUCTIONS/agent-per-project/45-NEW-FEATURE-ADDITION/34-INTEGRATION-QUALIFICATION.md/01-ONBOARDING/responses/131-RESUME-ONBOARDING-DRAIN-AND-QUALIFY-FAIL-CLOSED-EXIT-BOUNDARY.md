# Response 131 — PASS: Onboarding work drain and fail-closed exit boundary

## Result and evidence limits

The three expressly authorized Onboarding obligations are implemented and qualified with inert executable tests: every admitted Settings request is owned until settlement; ordinary stop suppresses queued restart and explicitly refuses an already-active restart without self-await; the actual selected Onboarding exit listener returns `cancel` on drain failure/refusal and `exit` only on successful drainage.

All five preserved Prompt 129/130 expected-red tests now pass. Production AppCzar activation remains unconditionally OFF. No actual Settings navigation, FDA/TCC/bookmark operation, Messages/Contacts/database/archive access, external-drive payload access, graph build, mutation tenure, process launch/restart/quit, signing, cloud or populated FTS/reconstruction operation ran. An `AppExitResponse` is permission/refusal from the Dart listener, not evidence of native process death or a fresh launch.

The other four still-unguarded Prompt 128 listeners—Diagnostic Review, Local Data Repair, Attachment Archive Repair, and distinct Operating—remain unchanged and are **not newly qualified for failure-to-cancel here**. Existing Data Update and Source Access behavior was regression-tested, not redesigned.

## Recovered state and exact checkpoints

- Branch: `fix/onboarding-import-stuck-state`.
- Verified initial HEAD: `8c61d69bac7103a0cae90b8754eada567880e07f`, upstream `0/0`, empty index, precisely two inherited unstaged test files. Prompt 131 contains a shortened/mistyped HEAD string; the actual full commit and its exact Prompt/Response 129 STOP contents were verified instead of relying on that spelling.
- Initial manifest `/private/tmp/prompt131-baseline.json`: 6,038 tracked regular files and 52 untracked files. The 49 unrelated items, navigation README, restored historical documents and three archived scripts were preserved.
- Starting controller-test hash matched `8c7ae0e61af6917fa8d730cf49ddcedfe11a0f1601daae560b478933921f7fcf`; harness-test hash matched `1aa86a43f18b8d40d785634bca48dbdff845fcc2744d7f6f22ea9e97813fbd60`. No reconciliation discrepancy or overwrite occurred.
- Exact complete Prompt/Response 130 STOP were committed separately and pushed as `48e4d556cf34b40283cae08d3f157442a141a57a` (`docs(feature34): checkpoint stopped onboarding exit boundary`). The records remain historical STOP evidence, not rewritten success records.
- Qualified source/test/generated checkpoint: `8e10bd58537f5fa2f409b3c69e16a805be8b12b2` (`fix(app-czar): drain onboarding work and fail closed on exit`), pushed normally. Exactly the five allowed Dart files were staged; staged paths and content hashes were verified against the qualified final manifest before committing.
- Exact Prompt/Response 131 form the separate completion documentation checkpoint. Its actual hash is reported in the Codex handoff, not self-referentially in this file.
- Shared-instructions submodule remains clean at `95326f515ef4719f155ce6e223990398daad6311`. Other worktree HEADs remain feature-35 `09b1c767cc01410da5799273206e2ab2a4d3b283`, main `b67bfafc3ad4f4f0c15792f0245bfecf5e45f43f`, gradle-fix `4f3e4fcc4eed2bd69eb237ae0aa328c917bbce37`. No write command targeted another worktree.
- All 17 recorded Stage 2/reset-denial hashes and both qualified exit-probe hashes match. Source Access recorded hashes differ only for the expressly allowed shared harness and its test; the production diff outside the Onboarding host branch is byte-identical to baseline. Probe was not rerun or changed.

## Ownership and state contract

| Work | Ownership and completion | Ordinary stop behavior |
| --- | --- | --- |
| Prerequisite/build | `_activeRun` owns the scheduled work only; restart dispatch is no longer awaited inside that work future. | Seal synchronously, await actual completion; retain failures occurring after sealing. |
| Every Settings action | An instance-owned set holds a settlement future registered before invoking the existing adapter. `_openSettings` directly awaits the real port future and completes/removes that member only in `finally`. | Wait for the entire admitted set, including multiple independent requests and overlap with prerequisite/build work. |
| Queued restart intent | `_restartAfterCurrentRun` records intent while work settles; separate `_restartFlight` owns dispatch/continuation. | Revoke intent and permanently mark the occurrence stopped. Queued callbacks recheck before resolving the restarter. |
| Active restart | `_restartActive` is set before entering the port, while `_restartFlight` retains its completion and error handling. | Refuse with `StateError` after other admitted work settles. Do not await a restart that could itself be requesting drain. |
| Explicit restart | `stopAndDrain(restart: true)` seals admissions and drains work before requesting one tracked restart. | A concurrent ordinary stop supersedes queued explicit intent; active dispatch remains accounted for by refusal. |
| Exit host | Captures the selected notifier's drain tear-off once at host initialization. | Await it; translate any synchronous/asynchronous throw to `AppExitResponse.cancel`; successful drain returns `exit`. |

The Settings barriers are tied to actual port settlement, not timers, permission observations, UI state or invented completion. The returned action still handles the real navigation future. Registration precedes port entry, including a synchronous reentrant stop from a fake port. Completed members are removed on success and error; there is no historical accumulation of completed futures and no change to the existing multiple-call admission policy.

Failure policy is explicit:

- A Settings error handled while its captured occurrence is still accepting preserves the existing user-facing issue. A later stop does not retroactively treat that already-handled error as pending or failed drainage.
- A Settings error after admission/epoch retirement is retained once with its stack, never published to stale UI. All other admitted work still settles before drain reports that failure. Repeated drains observe the same retained failure.
- Prerequisite/build failures during sealing are also retained; successful completion of their wrapper is not misreported as successful drainage.
- Restart dispatch failure is retained and prevents later successful exit. Failure UI is published only for a still-current, non-stopped occurrence. Active-restart refusal itself is temporary: after actual successful port settlement, a later ordinary drain may succeed; after port failure it continues to refuse.
- A restarter that reenters ordinary drain observes deterministic refusal. The test catches that refusal inside the inert restarter, then finishes; no recursive await, timeout or fictitious process completion is used.

`ref.listen` plus the initial `ref.read` replaces assessment `ref.watch` rebuilding, following the existing Source Access/Data Update lifetime idiom. This lets disposal sealing coexist with assessment updates without accidentally treating each assessment notification as provider disposal. `_considerAssessment` preserves initial selection and intentional generation-triggered restart behavior. Disposal/invalidation seals the instance permanently; it does not certify that outstanding work settled. Settings and restart continuations check currentness before publication. `_publish` itself was not broadly changed.

Normal safe-empty construction, human guidance, denied/unavailable/UNKNOWN evidence and intentional fresh-process restart paths remain intact in regressions. Settings navigation completion does not change source evidence or establish FDA permission. No process-to-process state transfer or new public provider/API/jurisdiction is introduced.

## Five preserved red-before/green-after cases

On unchanged production, the exact five-case selection ran with **exit 1, 0 passed, 5 failed**, log `/private/tmp/prompt131-red.log`:

```text
flutter test --no-pub test/essentials/app_czar_onboarding/application/app_czar_onboarding_controller_test.dart test/essentials/app_czar/presentation/app_czar_startup_harness_test.dart --name 'Prompt 129|Prompt 130' --reporter expanded
```

| Preserved case | Observed red | Observed green |
| --- | --- | --- |
| Settings success | Premature drain while Settings pending | Drain remains pending until real fake-port completion. |
| Settings failure | Premature drain and late issue publication | No premature completion or late publication; settled failure is reported by drain. |
| Queued reassessment restart | Restart starts after stop; drain returns while it remains pending; zero Settings calls | Stop suppresses restart completely; build settles; zero restart calls. |
| Actual host with Settings pending | Returns exit before Settings settles | Withholds permission until settlement, then returns exit. |
| Actual host with injected refusal | Same StateError escapes callback | Returns cancel with no escaping error. |

First corrected five-case run: **exit 0, 5 passed**, `/private/tmp/prompt131-five-green.log`. All five also pass in final complete focused validation. The Settings-failure test was strengthened to require retained drain failure after settlement instead of assuming its old swallowed-success result. Its premature-completion and stale-publication assertions remain intact. The injected refusal test remains an actual registered callback test; the real-owner Settings and restart tests provide separate owner evidence.

## Adversarial and regression qualification

Final focused command:

```text
flutter test --no-pub test/essentials/app_czar_onboarding/application/app_czar_onboarding_controller_test.dart test/essentials/app_czar/presentation/app_czar_startup_harness_test.dart --reporter expanded
```

**Exit 0, 55 passed** (34 controller, 21 harness), `/private/tmp/prompt131-focused-final.log`.

Coverage includes multiple Settings requests, reverse completion order, mixed success/error, failure before versus after seal, repeated drains, rejected post-stop actions, synchronous port reentry during admission, pending prerequisites/build overlapping Settings, work failure during sealing, queued restart revoked by ordinary stop, explicit restart waiting for Settings, ordinary stop superseding explicit intent, active restart success/failure, reentrant drain refusal, duplicate explicit and assessment-triggered restart requests, disposed/retired Settings callbacks, and unchanged literal source/Contacts/safe-empty behavior.

Actual host tests cover multiple pending Settings requests and repeated exit requests, real owner error-to-cancel, active-restart refusal and retained failure, synchronous and asynchronous injected refusal, listener removal and single callback invocation per request. The host uses its captured notifier, with no provider lookup in the exit handler. A new test initially assumed provider invalidation would construct a second notifier; that assumption failed (20 passed, 1 failed in `/private/tmp/prompt131-harness.log`). Riverpod rebuilt the same notifier instance. The test was corrected to assert the actual instance identity, continued callback ownership and absence of duplicate registration. It then passed with the complete harness file (21 passed, exit 0, `/private/tmp/prompt131-harness-final.log`). This was a test-fixture assumption correction, not a weakened preserved red test or an ignored production defect.

Controlled pending operations are released and observed during cleanup. The disposal characterization deliberately disposes while Settings is pending to prove stale callback suppression, then releases and awaits that operation; it does not infer drainage from disposal. No new wall-clock sleep or timeout-based cancellation was introduced. Existing legacy diagnostic deadlines/pump helpers were not rewritten.

Screened regression command selected these six existing files:

- `test/essentials/app_czar_onboarding/presentation/app_czar_onboarding_screen_test.dart`
- `test/essentials/app_czar_data_update/application/app_czar_data_update_controller_test.dart`
- `test/essentials/app_czar_data_update/presentation/app_czar_data_update_screen_test.dart`
- `test/essentials/app_czar_source_access/application/app_czar_source_access_controller_test.dart`
- `test/essentials/app_czar_source_access/presentation/app_czar_source_access_screen_test.dart`
- `test/essentials/app_czar_operating_session/presentation/app_czar_operating_session_app_test.dart`

Ran together with `flutter test --no-pub ... --reporter expanded`: **exit 0, 51 passed**, `/private/tmp/prompt131-regressions.log`. Real executor-provider, native process-restarter, archive/data and mutation-tenure tests were not selected. Controller tests override executable ports; screen tests use synthetic readers/fixed controllers; Operating presentation uses inert routing/callback seams. Safe-empty build ordering is covered via the injected Onboarding executor, not the actual graph build provider.

Complete `flutter test --no-pub test/architecture --reporter expanded`: **exit 0, 644 passed**, `/private/tmp/prompt131-architecture.log`. Screened as source/AST inspection and disposable parser fixtures; its test named “critical tenure tests use real Feature 35 authorities” inspects test source and does not execute those tenure tests. No architecture assertions or exemptions changed. Six specialist listener constructions and the distinct Operating listener remain, with unchanged ownership counts.

## Static, generation and preservation checks

- `flutter analyze --no-pub`: **exit 0**, no issues, `/private/tmp/prompt131-analyze.log` (7.7 seconds).
- Targeted `dart format --output=none --set-exit-if-changed` on all four handwritten allowlisted files: **exit 0**, zero changes.
- Normal filtered generation: `dart run build_runner build --build-filter=lib/essentials/app_czar_onboarding/application/app_czar_onboarding_controller.g.dart`, **exit 0**. The final source edit was followed by regeneration (`/private/tmp/prompt131-generation-final.log`). Only the allowed generated companion differs, solely its source hash. The generator reports cached/lazy outputs too; the full byte manifest verifies that no other tracked or unrelated untracked bytes changed.
- `git diff --check`, `git diff --cached --check`, exact staged allowlist/hash comparison: **exit 0**.
- Full initial-versus-final byte comparison: only the five allowed Dart files changed, plus the separately authorized documentation additions/checkpoints. No broad cleanup, restore, stash, reset, rebase, force push or sweeping staging.
- All SDK commands completed using approved SDK-cache access. None was denied or interrupted. Full application suite was not needed or run.

Final qualified implementation hashes (`/private/tmp/prompt131-final-hashes.json`):

| Exact path | SHA-256 |
| --- | --- |
| `lib/essentials/app_czar_onboarding/application/app_czar_onboarding_controller.dart` | `74e6d13b54f30ee7c7a56f4040dd460dac63f092e8058a2c7660507258cbde73` |
| `lib/essentials/app_czar_onboarding/application/app_czar_onboarding_controller.g.dart` | `dc90cfb0004438197089724bb91fd9db282b61d607d041f09afb1db9efb0a617` |
| `lib/essentials/app_czar/presentation/app_czar_startup_harness.dart` | `4997f1d529b5f8466eb889fac6e06f15dc7b79920db8fa3eef1f2fa66a4c4e1e` |
| `test/essentials/app_czar_onboarding/application/app_czar_onboarding_controller_test.dart` | `255a1036e88a77174251cf36ce52da23c98b5f5325071b398169d39f4bb9439f` |
| `test/essentials/app_czar/presentation/app_czar_startup_harness_test.dart` | `4ab19adb6db1b2f9c9be5b94f16360e256676dbd5640744c9241ee33818bcea8` |

## Bounded Project Conformance audit

**Reviewed against:** repository AGENTS.md; shared global guardrails, Dart and Riverpod patterns; project README; canonical `MESSAGELENS-PROJECT-CONFORMANCE-AUDIT-STANDARD.md`; Prompt 131; preserved STOP Responses 129/130; existing Onboarding state/assessment/port contracts and Source Access/Data Update drain idioms. Scope is the authorized accumulated owner/Onboarding-host correction and preserved/new tests, against the pre-implementation source checkpoint. No whole-branch or native production conformance claim is made.

**BLOCKER: 0. SHOULD FIX: 0.**

- Reuse/layering/dependency direction: existing generated notifier, assessment seam, Settings adapter and restarter port reused; no new provider, helper file, domain state, policy or authority. Host translates the owner result only.
- Single source of truth/project idioms: lifetime state remains instance-owned; generated provider remains generated. Physical data paths, source observations, jurisdiction choices and reset authority are unchanged.
- Bounded work/performance: only admitted pending Settings flights retained; removal on both success and failure; no polling/timers/history accumulation; restart dispatch separately retained and checked before port resolution.
- Privacy/mutation safety: no added logs of user data, persistence, data access, mutation or native operation. Overlay/Presence/archive/source preservation unchanged.
- Error/currentness semantics: complete work settlement before success/failure, permanent ordinary stop, no stale Settings/build/restart publication, explicit active-restart refusal without self-await, catch-to-cancel at the exact host boundary.
- Dead code/generated/dependency hygiene: existing helpers repurposed within the owner; no duplicate controller, obsolete alternate exit path, dependency change or extra generated delta introduced.
- Tests/architecture: final focused, screened regressions and all architecture tests pass; no expectations weakened to admit an unsafe behavior. Intermediate red results and the new invalidation-test assumption failure are disclosed.
- Documentation/UX: literal denied/unavailable/UNKNOWN and existing guidance preserved; no new UI or release activation. This gated internal qualification does not alter release metadata, which is outside the explicit allowlist. “Hosts unchanged” below means census and ownership plus all non-Onboarding branch bytes; the authorized Onboarding error-to-cancel edit is explicitly recorded.

Remaining unknowns: real native termination, actual restart implementation interaction, launcher packaging/signing, FDA continuity, archive-lock release, independent successor admission and production data continuity. The inert restarter proves only the controller contract. The remaining four Prompt 128 listener corrections need separate authorization/qualification. No further task was started.

ONBOARDING MULTIPLE SETTINGS FLIGHTS OWNED: YES
ONBOARDING ORDINARY STOP AWAITS SETTINGS: YES
QUEUED RESTART AFTER ORDINARY STOP PREVENTED: YES
ACTIVE RESTART DURING STOP HANDLED WITHOUT SELF-AWAIT: YES
ONBOARDING ACTUAL EXIT CALLBACK FAILS CLOSED: YES
FIVE PRESERVED RED TESTS NOW PASS: YES
OTHER PROMPT 128 EXIT LISTENERS QUALIFIED: NO
SIX SPECIALIST + ONE OPERATING HOSTS UNCHANGED: YES
STAGE 1/2 RESET DENIAL UNCHANGED: YES
REAL PRODUCTION FRESH LAUNCH IMPLEMENTED: NO
PRODUCTION APPCZAR ACTIVATION: OFF
PROJECT CONFORMANCE: PASS
READY FOR SEPARATE PROMPT 132: YES
