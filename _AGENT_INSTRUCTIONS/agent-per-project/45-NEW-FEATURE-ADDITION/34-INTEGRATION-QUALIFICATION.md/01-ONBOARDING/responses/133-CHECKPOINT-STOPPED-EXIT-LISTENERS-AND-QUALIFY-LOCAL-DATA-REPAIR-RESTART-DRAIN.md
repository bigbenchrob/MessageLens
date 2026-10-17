# Response 133 — PASS: Local Data Repair restart ownership and ordinary drain

## Result and limits

The Local Data Repair owner now retains scheduled repair work and a distinct restart flight, seals admission synchronously on ordinary stop/disposal/assessment retirement, and refuses ordinary drainage with `StateError` while a restart is active. Automatic restart waits for actual worker settlement without being part of that worker's future. A restarter reentering stop therefore receives explicit refusal without self-await. Manual retries coalesce with an existing flight, and stop prevents later port resolution/dispatch.

**Owner-scope qualification only.** The production exit host is byte-for-byte unchanged. The actual registered callback propagates the owner's refusal and returns no exit response while restart remains pending. It does NOT return a qualified `AppExitResponse.cancel`. Exception-to-cancel remains an out-of-scope production-cutover BLOCKER; no OS refusal, process death or native relaunch is inferred. Production activation remains OFF.

Only synthetic observations, disposable test containers and inert overridden executor/restarter/settings ports were executed. No real source, graph/import/overlay/Presence store, archive payload, root admission, Ball/tenure/lease, Settings/FDA/TCC/bookmark, native process launch/exit, signing or cloud operation ran. Fake post-mutation outcomes test classification only; they do not acquire or exercise repair authority.

## Recovery and checkpoints

- Baseline branch `fix/onboarding-import-stuck-state`, HEAD `f9a3cdfe3c256831dee8ce8306e91ed22b25b345`, upstream `0/0`, empty index.
- One inherited tracked modification: harness test, 142 additions/0 deletions, SHA-256 `1282b07d6f020bde13ccab4e0b5e46b4b449baddb0c1db30c04d4bb3a552fa5c`. Verified before changes; preserved its causal test and fixtures. Final assertions explicitly distinguish an escaping refusal from cancellation and verify later drain after actual fake settlement.
- `/private/tmp/prompt133-baseline.json`: 6,042 tracked regular files and 52 untracked files: 49 unrelated plus Prompt/Response 132 and Prompt 133. Compared with Prompt 132 baseline: only its expected harness modification and the two subsequently added documents differed; no unexplained change.
- Prerequisite exact Prompt/Response 132 STOP pair committed separately and pushed before source edits: `88543ca196761a7bbc8547d10e3f58639ffedc55`. Historical STOP remains unchanged.
- Qualified source/test checkpoint, exactly four authorized Dart files, pushed: `891ae8483a8a463e895cf656924226268d758b0b`.
- This exact Prompt/Response 133 pair is a separate subsequent docs checkpoint. Its self-referential hash is reported in the Codex handoff, not this body. Source push completed with upstream synchronized; final docs push/status is verified at handoff.

Verified ancestors: Stage 1 `e21334de96c2ab1484acbb8f3378ccad2cc49972`, Stage 2 `daac3e6b54812c98d56dba7eb3ea8fb8f8296798`, Data Update `a90612830fac05d79fff5d6097c2b0d35dd23b6e`, Source Access `5eb7e58b4e24589114d18bac1bf6aef0bba4ab5a`, Onboarding `8e10bd58537f5fa2f409b3c69e16a805be8b12b2`, and disposable exit observer `c5d727a9c21aaced5fe000ae8bae0f8d096df6d2`. All 17 recorded Stage 2 hashes and both exit-probe hashes match. No probe rerun occurred.

Four worktrees remain registered. Other worktree HEADs unchanged: Feature 35 `09b1c767cc01410da5799273206e2ab2a4d3b283`, main `b67bfafc3ad4f4f0c15792f0245bfecf5e45f43f`, Gradle `4f3e4fcc4eed2bd69eb237ae0aa328c917bbce37`. Shared instructions submodule is clean at `95326f515ef4719f155ce6e223990398daad6311`. No commands wrote to those worktrees. Full byte comparison preserves the navigation README, 218 restored historical documents, three archived scripts and all 49 unrelated untracked items; no archive moves were staged, no stash/reset/clean/rebase/force push occurred.

## Red-before evidence and corrected contract

Unchanged inherited test executed with project Flutter SDK:

`flutter test --no-pub test/essentials/app_czar/presentation/app_czar_startup_harness_test.dart --plain-name 'Prompt 132' --reporter expanded`

Exit **1**, 0 passed/1 expected failure; `/private/tmp/prompt133-inherited-red.log`:

```text
restartCalls=1 restartSettled=false
drainSucceeded=true drainFailure=null
exitResponse=AppExitResponse.exit exitFailure=null
```

Before editing production, added two controller characterizations and ran `--plain-name 'Prompt 133'`: exit **1**, 0 passed/2 expected failures; `/private/tmp/prompt133-controller-red.log`. Manual restart allowed successful drain. Automatic restart left drain pending rather than refusing: source confirmed `_run` awaited the restarter inside `_activeRun`, exposing reentrant self-await risk. These are attributable behavioral failures, not SDK/compilation failures.

The preserved actual-host test selects the real controller from fixed local-repair assessment, uses an executor that fails before mutation, observes the normal failed state and visible retry, then calls its real button action. With one injected restart held pending, the final passing assertions establish:

```text
restartCalls=1 restartSettled=false
drainSucceeded=false drainFailure=StateError
exitResponse=null exitFailure=StateError
```

The refusal message is `Local Data Repair restart is still active.` It escapes the unchanged host; it is not cancellation. After release, the action and observed callbacks settle, and a new ordinary drain succeeds. Settings calls remain zero; teardown releases all controlled work, unmounts and disposes. No fake owner or copied exit callback replaces the actual path.

Controller policy:

- Work is registered before executor entry and retained through its actual completion. Stop awaits that work; disposal alone is never treated as drainage.
- Automatic completed/stale and typed post-mutation failure classifications still request reassessment. Pre-mutation failure remains visible and retryable without automatic restart.
- Restart scheduling is a synchronous owner helper that stores the future; it waits for the work future and rechecks sealing/currentness before setting active ownership and resolving the port.
- Explicit retries are allowed only from live failed state or coalesce with an existing flight. They cannot start after permanent stop. No second executor/reset is introduced.
- Ordinary stop revokes queued dispatch. Active restart raises deterministic refusal; stop never awaits a restarter that is calling stop itself. After successful real fake settlement, a later drain can succeed.
- Post-stop worker failures and admitted restart failures retain their original object/stack for subsequent drain refusal. Already presented pre-mutation failure is not retroactively a new drain failure. A successful live retry can clear a prior restart failure. Late failures after retirement do not publish UI or revive admission.
- Assessment object replacement retires the admitted occurrence conservatively, even within the same generation. New provider occurrence eligibility and all executor safety/revalidation/mutation rules remain unchanged.

## Qualification and validation

Final executed commands use `/Users/rob/Development/flutter/bin/flutter` and `dart`, with approved SDK-cache access:

| Gate | Result | Log |
| --- | --- | --- |
| Full Local Repair controller + startup harness files (`flutter test --no-pub ... --reporter expanded`) | exit 0; **48 passed** (26 controller, 22 harness) | `/private/tmp/prompt133-focused-final.log` |
| Screened related regressions, eight exact files below | exit 0; **88 passed** | `/private/tmp/prompt133-regressions.log` |
| Complete `test/architecture` rerun | exit 0; **644 passed** | `/private/tmp/prompt133-architecture-final.log` |
| Full `flutter analyze --no-pub` | exit 0; no issues, 8.6 seconds | `/private/tmp/prompt133-analyze-final.log` |
| Targeted `dart format --output=none --set-exit-if-changed` | exit 0; 3 files, 0 changed | command output |
| Filtered normal build_runner, exact controller companion | exit 0; 28 reported cached/lazy/generated outputs, only authorized companion bytes changed | `/private/tmp/prompt133-generation-final.log` |
| `git diff --check`, staged whitespace, exact staged paths/hashes | exit 0 | command output |

Adversarial controller coverage includes manual/automatic pending restart, duplicate retry and concurrent refusals, later successful drain, stop-before-retry with **zero restarter resolutions**, two concurrent stops awaiting actual worker completion/error, queued automatic completed/stale/post-mutation outcomes suppressed by stop, manual/automatic restarter reentry, synchronous/asynchronous restart failures before/after stop, assessment replacement and disposal during work/restart, stale UI suppression, and legitimate live retry after failed automatic restart. No new sleeps or timeout-as-cancellation were introduced. Existing inherited polling helpers remain unchanged; new causality uses controlled futures/state subscriptions and bounded microtask observations.

Related regression files, relative to repository root:

- `test/essentials/app_czar_onboarding/application/app_czar_onboarding_controller_test.dart`
- `test/essentials/app_czar_onboarding/presentation/app_czar_onboarding_screen_test.dart`
- `test/essentials/app_czar_data_update/application/app_czar_data_update_controller_test.dart`
- `test/essentials/app_czar_data_update/presentation/app_czar_data_update_screen_test.dart`
- `test/essentials/app_czar_source_access/application/app_czar_source_access_controller_test.dart`
- `test/essentials/app_czar_source_access/presentation/app_czar_source_access_screen_test.dart`
- `test/essentials/app_czar_local_data_repair/presentation/app_czar_local_data_repair_screen_test.dart`
- `test/essentials/app_czar_operating_session/presentation/app_czar_operating_session_app_test.dart`

Screened for inert observation/executor/settings/restarter overrides, fake presentation owners, and inert Operating routes/drain callbacks. Real executor/tenure/capability/reset/archive/graph suites were excluded. Architecture suite screened as source/AST inspection and disposable parser fixtures; tests naming real tenure inspect source, not execute those authorities. No full Flutter suite or production build was needed/run.

Intermediate results are not hidden: first corrected focused run passed 31; expanded controller run passed 26; first analysis clean; first architecture run **exit 1, 643 passed/1 failure**, because `unawaited()` was outside this controller's approved boundary. Resolved inside the authorized controller by retaining automatic restart in a synchronous scheduling helper rather than discarding a returned future. No architecture test/exemption change. Final generation, focused tests, analysis and full architecture rerun passed. The 88 related regressions passed before this final internal scheduling-signature adjustment; their files and dependencies outside this owner stayed unchanged. No interrupted or denied SDK run was counted as a pass.

## Manifest and bounded conformance audit

The complete baseline comparison shows only these four Dart byte changes, plus the exact separately authorized documentation checkpoints. Generated delta is solely the controller source hash. Final qualified hashes:

| Path | SHA-256 |
| --- | --- |
| `lib/essentials/app_czar_local_data_repair/application/app_czar_local_data_repair_controller.dart` | `37745f6b929e11fafefb998aabeab994a156c9afb53c5985acff95f56245f543` |
| `lib/essentials/app_czar_local_data_repair/application/app_czar_local_data_repair_controller.g.dart` | `2b089ada006b9cb1465b54a5fb61ef474470eb11aaa3424f9c0ab4e8b48bc0ec` |
| `test/essentials/app_czar_local_data_repair/application/app_czar_local_data_repair_controller_test.dart` | `e6a603c8d9e066b83d641d443dac5958b2a43ace181fa59b03e6d8c3ae76c899` |
| `test/essentials/app_czar/presentation/app_czar_startup_harness_test.dart` | `a71180c8664108c3c2a841a435c49314cf72049fcf9f59cbee410847e023fa1f` |

Baseline production owner hash: `fd144475acaecd9aeae2177d02b6e5aacef34da0bd8180787643507b26d546f7`. Unchanged production harness hash: `4997f1d529b5f8466eb889fac6e06f15dc7b79920db8fa3eef1f2fa66a4c4e1e`. Final implementation manifest: `/private/tmp/prompt133-final-hashes.json`. Source checkpoint contains only those four files; inherited harness delta is preserved within it.

**Reviewed against:** repository AGENTS.md; global agent guardrails; project README; shared Dart/Riverpod rules; database access rules; attachment-preservation invariant; canonical Feature 34 `00-PREPARATION/MESSAGELENS-PROJECT-CONFORMANCE-AUDIT-STANDARD.md`; Prompts/Responses 131–132 and Prompt 133; existing local repair state/executor/restarter, host, tests and qualified Onboarding lifetime idioms. Scope is accumulated authorized owner/test delta against recovered `f9a3cdfe`, not whole-branch/native release qualification.

**In-scope BLOCKER: 0. SHOULD FIX: 0.**

- Reuse/layering/dependency direction: existing generated owner and existing executor/restarter seams; no new provider, framework, public authority, file or dependency. Internal lifecycle belongs to the owner.
- Single source of truth/project idioms: no duplicated safety policy, paths, schema, admission or jurisdictions. Generated companion regenerated normally. Immutable state model unchanged.
- Bounded work: one worker and one restart slot, no overwriting pending work, polling, timer, retention history or source scans. Work and restart cannot form a self-await cycle.
- Error/currentness: actual worker settlement, permanent sealing, retained failures, explicit active-restart refusal, no stale publication and no disposal-as-settlement claim. Covered by executable synthetic tests.
- Safety/privacy: exact eligibility predicate/executor/reset service unchanged; no data access, logging, mutation authority or archival change. Overlay/Presence/payload preservation and Stage 1/2 denial unchanged.
- Dead code/dependencies/generated output: replaced old restart helpers with one owner scheduling path; no second recovery route, dependency/native/release churn or generated change outside allowlist.
- UX/documentation: existing failed-state/retry semantics preserved. No new UI or production activation. Release metadata is outside this gated owner-only scope. Six specialist listeners and one Operating listener remain unchanged in count and bytes.
- Tests/architecture: corrected initial boundary finding without weakening architecture; focused and full architecture final gates pass. No production-runtime guarantee is inferred from synthetic evidence.

**Out-of-scope production-cutover BLOCKER:** unchanged host exception-to-cancel boundary, along with still-unqualified remaining listeners. Complete native death/fresh launch, signing/FDA continuity, successor admission, persistence/backup/data continuity and runtime qualification remain UNKNOWN/unimplemented. No broader task was started.

LOCAL DATA REPAIR RESTART FLIGHT OWNED: YES
ORDINARY STOP WITH ACTIVE RESTART RETURNS SUCCESS: NO
REENTRANT SELF-AWAIT PREVENTED: YES
ACTUAL HOST EXIT PERMISSION WHILE RESTART PENDING: NO
LOCAL REPAIR SAFE-PARTIAL CONTRACT CHANGED: NO
REMAINING HOST EXCEPTION-TO-CANCEL QUALIFIED: NO
SIX SPECIALIST / ONE OPERATING LISTENERS PRESERVED: YES
STAGE 1/2 RESET DENIAL UNCHANGED: YES
REAL FRESH LAUNCH IMPLEMENTED: NO
PRODUCTION APPCZAR ACTIVATION: OFF
PROJECT CONFORMANCE (OWNER SCOPE): PASS
READY FOR SEPARATE PROMPT 134: YES
