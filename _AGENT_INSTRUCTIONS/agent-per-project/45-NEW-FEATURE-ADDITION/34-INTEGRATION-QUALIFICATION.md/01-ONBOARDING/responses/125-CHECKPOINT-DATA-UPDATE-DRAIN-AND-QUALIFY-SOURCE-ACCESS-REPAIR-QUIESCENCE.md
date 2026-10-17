# Response 125 — Source Access Repair quiescence qualified

## Outcome and evidence boundary

Source Access Repair now owns its admitted Settings, source-check, check-continuation and restart futures. Stop seals admission before its first await. It awaits actual non-restart work and refuses exit on a drain failure or a still-active restart. Its dedicated cancelable-exit host captures the selected controller and awaits this contract. Architecture now requires exactly six specialist listeners and the separately owned Operating listener.

**Reentrant restart safety is refusal-based.** A restarter re-entering `stopAndDrain` receives a `StateError` while its own restart flight exists; it does not recursively await itself. External exit receives the same refusal while restart is pending. The fake explicitly observes this refusal, completes its independent work, and only then can a later drain succeed. This is not a successful reentrant shutdown, cancellation of the restart, or proof of production process handoff. A future production restarter must not interpret refusal as quiescence.

All runtime evidence uses injected inert ports and synthetic observations. `AppExitResponse.exit` is permission to exit, not OS termination. No native launch/exit, real Settings launch, permission change, source/database access, archive operation, Ball, tenure, writable lease or signed execution was performed. Production activation remains OFF.

## Recovery and checkpoints

Recovered branch: `fix/onboarding-import-stuck-state`; HEAD `b49e67f8d72b8c7014c2b624b48caa7e67d0c29e`; upstream `0/0`; index and tracked tree clean. Exact Prompt/Response 124 were already committed in that HEAD, following qualified Data Update source `a90612830fac05d79fff5d6097c2b0d35dd23b6e`; no duplicate checkpoint was made. Historical STOP 123 remains at `594d06cd57ed9a5e48d32312a39507560ed4a971`.

Source checkpoint **`5eb7e58b4e24589114d18bac1bf6aef0bba4ab5a`**, normally pushed, contains precisely the six implementation paths listed below. This exact Prompt/Response 125 pair forms the subsequent separate documentation checkpoint; its resulting hash is reported in the final handoff, not embedded here.

Baseline `/private/tmp/prompt125-baseline.json` recorded 6,026 tracked regular files and 50 untracked files (Prompt 125 plus 49 unrelated). Full SHA-256 comparison confirms all unrelated tracked and all baseline untracked bytes unchanged. The navigation README, restored historical documents, three `_ARCHIVED` scripts and unrelated files were not staged or edited. The post-documentation expected disposition is clean tracked tree/index, upstream `0/0`, and 49 preserved unrelated untracked files; final verification is reported in the handoff.

Four worktrees were inspected; only the primary advanced:

| Worktree | Recovered HEAD |
| --- | --- |
| `remember_every_text` | `b49e67f8d72b8c7014c2b624b48caa7e67d0c29e` |
| `remember_every_text-feature-35` | `09b1c767cc01410da5799273206e2ab2a4d3b283` |
| `remember_every_text-main` | `b67bfafc3ad4f4f0c15792f0245bfecf5e45f43f` |
| `remember_every_text.worktrees/gradle-fix-flutter-projects` | `4f3e4fcc4eed2bd69eb237ae0aa328c917bbce37` |

Shared instructions remain clean at `95326f515ef4719f155ce6e223990398daad6311`. Stage 1 `e21334de96c2ab1484acbb8f3378ccad2cc49972` and Stage 2 `daac3e6b54812c98d56dba7eb3ea8fb8f8296798` remain ancestors. All 17 recorded Stage 2 implementation hashes match. Data Update controller, generated companion and controller-test hashes match the qualified Prompt 124 manifest; only the shared harness/tests and census change within this task's explicit scope.

## Characterization before implementation

Inspected the existing controller, source/Settings/restarter seams, presentation branch, five specialist hosts, Operating host, and tests. No equivalent Source Access drain owner existed. Baseline had `_checkInFlight`, `_settingsOpenInFlight` and `_restartRequested` flags; explicit source check awaited source observation and could await restart; Settings could independently remain pending; manual restart could also be pending. Build published waiting state but the watched assessment provider could itself perform initial observation. Fixed-assessment fixtures prove no Source Access action from selected/dormant construction; existing assessment fixtures use an inert reader and explicitly account for its initial read.

Before production edits, controller/harness characterization passed **17 tests, exit 0**, recorded in `/private/tmp/prompt125-characterization.log`. The same two-file focused command shown below was used. Baseline source-only harness assertions established direct Source Access rendering and five specialist listeners; they were subsequently replaced by the required six-host assertions and runtime exit tests. Baseline absence of drain was not presented as passing drainage.

## Owned lifetime and changes

- Controller: retains `_settingsFlight`, `_checkFlight`, `_checkContinuation`, `_restartFlight`; synchronous sealing blocks new explicit actions and queued dispatch. Listening to assessment changes seals an already-selected occurrence on replacement without reconstructing its work owner. Disposal seals publication/admission only; it is not proof of settlement.
- Settings: only explicit invocation starts the existing port. Duplicate invocation remains single-flight. A completed open request means navigation completed, never FDA permission. Source reads may independently run, and drain waits for both when admitted.
- Source: read future is distinct from the continuation that may request restart. Readable evidence follows the existing restart path only while admitted. Denied/unavailable remain waiting; UNKNOWN remains inconclusive. Reader failure remains UNKNOWN. Late success/error cannot publish or schedule restart after stop/disposal/replacement.
- Restart: an owned microtask awaits Settings/source work before dispatch; admission is checked before port invocation. Manual and automatic requests retain single-flight behavior. Drain never waits on a restart that may be calling drain. Instead it refuses while `_restartFlight` exists. Once absent, sealed admission ensures the remaining check continuation can only retire, so drain awaits it safely.
- Errors: while admission is open, existing Settings/source/restart failure presentation remains. Errors occurring after sealing are retained and cause drain refusal, rather than disappearing behind suppressed UI publication. An already-handled error before stop does not retrospectively imply pending work failed to settle.
- Harness: new private Source Access host captures the already-selected notifier's drain in `initState`, awaits it before exit permission, converts exceptions to cancel, and removes the listener on disposal. Exit does not look up a replacement controller. Other five hosts and Operating remain distinct.
- Architecture: only the relevant test section changes. It requires six specialist constructions, names all six, and positively checks captured ownership, one Source Access listener, awaited drain before exit, no exit-time provider read, exception-to-cancel and removal. Data Update's isolated assertions and exactly-one Operating listener remain; forbidden-import rules are unchanged.
- Tests: causal Completers/counters cover pending Settings/source success/failure, repeated stop, sealed actions, all source outcomes, errors, duplicate requests, pending restart refusal/reentry, queued restart suppression, concurrent non-restart work, restart-after-Settings, positive-result/dispatch race, disposal/replacement, host waiting/cancel/success and listener removal. Controlled flights are released for cleanup. No elapsed-time timeout claims cancellation; old phase-polling sleeps were replaced by provider-listener completion.
- Generated companion: normal build_runner output only; no manual generated edit or new provider/dependency.

## Fresh validation

All final commands completed with exit 0 on the qualified bytes. No full Flutter suite or signed/native rehearsal is claimed.

```sh
flutter test --no-pub test/essentials/app_czar_source_access/application/app_czar_source_access_controller_test.dart test/essentials/app_czar/presentation/app_czar_startup_harness_test.dart --reporter expanded
```

**38 passed**, `/private/tmp/prompt125-focused-final.log`.

```sh
flutter test --no-pub test/essentials/app_czar_source_access/presentation/app_czar_source_access_screen_test.dart test/essentials/app_czar_data_update/application/app_czar_data_update_controller_test.dart test/essentials/app_czar_data_update/infrastructure/macos_development_process_restarter_test.dart test/essentials/app_czar_data_update/presentation/app_czar_data_update_screen_test.dart test/app_czar_startup_composition_test.dart test/essentials/app_czar/application/non_destructive_operating_composition_characterization_test.dart test/essentials/app_czar_operating_session/presentation/app_czar_operating_session_app_test.dart test/essentials/app_czar_attachment_archive_repair/presentation/app_czar_attachment_archive_repair_screen_test.dart --reporter expanded
```

**50 passed**, `/private/tmp/prompt125-regressions.log`. Development-restarter tests use injected inert launch/exit dependencies. These are not native-default executions.

```sh
flutter test --no-pub test/architecture --reporter expanded
flutter analyze --no-pub
dart format --output=none --set-exit-if-changed lib/essentials/app_czar_source_access/application/app_czar_source_access_controller.dart lib/essentials/app_czar/presentation/app_czar_startup_harness.dart test/essentials/app_czar_source_access/application/app_czar_source_access_controller_test.dart test/essentials/app_czar/presentation/app_czar_startup_harness_test.dart test/architecture/app_czar_architecture_test.dart
dart run build_runner build --build-filter=lib/essentials/app_czar_source_access/application/app_czar_source_access_controller.g.dart
git diff --check
git diff --cached --check
```

Architecture **644 passed** (`/private/tmp/prompt125-architecture.log`), full analyzer **no issues** (`/private/tmp/prompt125-analyze.log`), targeted format **zero changed**, generator **exit 0** (`/private/tmp/prompt125-generator-qualified.log`), working/staged whitespace **clean**. Generator reported 26 outputs including same/cached dependent output; manifest verification shows only the authorized generated companion changed tracked bytes and no extra untracked outputs. SDK-cache access was approved for tools. No failed mandatory qualification gate remains.

Screened exclusions: Data Update executor-provider tests and the whole Operating-currentness controller file include real worker/mutation-tenure paths, so they were not run. Selected Operating presentation/neutral composition tests are inert. Architecture tests inspect source/AST and disposable source-text fixtures, not real archive tenure. No actual Messages/Contacts/MessageLens store, archive root, Settings, process restarter default, native Runner, full runtime suite or production application was exercised.

## Exact implementation inventory and SHA-256

Repository-relative paths; pre-edit hashes from the baseline and post-edit hashes from `/private/tmp/prompt125-implementation-hashes.json`. The staged bytes were compared to this same qualified manifest before commit.

| Path | Before | Qualified |
| --- | --- | --- |
| `lib/essentials/app_czar/presentation/app_czar_startup_harness.dart` | `40b4c3ba8eaee113becc2d40d1e8e3dd2174019e1822c7c0958fecb17230ebf8` | `03942c7287f57734bbd197f1a3c3828a8d7b093df023c3aa0940197cc27fbc7b` |
| `lib/essentials/app_czar_source_access/application/app_czar_source_access_controller.dart` | `a573e5048414551d6f1ddebafccedfa77115faec90b2135966701e1d39258420` | `ffcce4302c137ea24ad2baef1f0f02909e7ba15bbd2dbcd0487f5c3e3995f59d` |
| `lib/essentials/app_czar_source_access/application/app_czar_source_access_controller.g.dart` | `c68a7bcca4c30ed8e85be770afe6c0ea573c894ef712b43348490ea86ee3c436` | `eb12341e05f005acaf4e6c6d7214efaf8a3a951220e4a54a8dd02a2dfac6bc0e` |
| `test/architecture/app_czar_architecture_test.dart` | `6ca6c0494656d8add0873deb0a14e8c104613496bf90a880599c518a73e0b15d` | `e5ef08a29d727f6f729e8c085a9ae10702432de756cce7d3f761c8b46ba13356` |
| `test/essentials/app_czar/presentation/app_czar_startup_harness_test.dart` | `b3d23ff9a496fd4f85fc45f2facfa0360f098920462769219d06bdd9228723b5` | `dbcf4c5177f8240ae38247f692474af436fd8cfcb45e47ddce07d08c41b4c9ac` |
| `test/essentials/app_czar_source_access/application/app_czar_source_access_controller_test.dart` | `c3fadfdeb20062c74d53660cdfc149857bfba06259639abe26cebc335aa0ddc0` | `43b531b6fd200bfbb783fd7485854cca8c5dab92dd5bc431d2199810f4a04e13` |


## Canonical Project Conformance Audit

Scope: complete accumulated Prompt 125 delta from `b49e67f8d72b8c7014c2b624b48caa7e67d0c29e`, including all six then-unstaged implementation paths, now source checkpoint `5eb7e58b4e24589114d18bac1bf6aef0bba4ab5a`. This is the narrow lifecycle prerequisite audit, not a whole Feature 34 release/integration audit.

**Reviewed against:** `AGENTS.md`; `_AGENT_INSTRUCTIONS/agent-instructions-shared/00-global/agent-guardrails.md`; `_AGENT_INSTRUCTIONS/agent-per-project/README.md`; shared `10-language/dart.md`, `20-flutter/riverpod-provider-patterns.md`; the canonical `00-PREPARATION/MESSAGELENS-PROJECT-CONFORMANCE-AUDIT-STANDARD.md`; Prompt 125 and prior Responses 122–124; existing AppCzar jurisdiction/host and architecture boundaries; project database, overlay-independence, source-UNKNOWN and attachment-preservation invariants. Explicit Prompt 125 authorization controls the narrow edit/checkpoint scope. No release metadata or production activation was authorized or changed.

| Area | Classification and evidence |
| --- | --- |
| Reuse before invention | NO ISSUE: existing source, Settings, restarter ports and specialist listener pattern; no second lifecycle coordinator or generic shutdown abstraction. |
| Layering / ownership / dependency direction | NO ISSUE: controller owns work; host only awaits captured owner; no new import exception, native adapter or cross-feature private dependency. |
| Single source of truth | NO ISSUE: assessment occurrence remains authority; no new schema/path/permission/jurisdiction taxonomy. |
| Project idioms | NO ISSUE: annotated generated provider, existing typed immutable state, same hooks_riverpod conventions; no manual provider. |
| Performance / bounded work | NO ISSUE: finite single-flight references and event-driven observation; no polls, scans, I/O startup additions or unowned unawaited continuation. |
| Privacy / logging | NO ISSUE: no new logging, persistence, network or user-content diagnostics; existing literal failure fields retained. |
| Mutation / authority safety | NO ISSUE: no new mutation authority; Stage 1/2 and unrelated sources hash-preserved; overlays, Presence and attachment payloads untouched. |
| State / errors | NO ISSUE: UNKNOWN never grants permission; synchronous seal; actual non-restart waits; restart-active refusal prevents premature exit and recursive self-await. |
| Dead / superseded code | NO ISSUE: obsolete boolean work flags replaced by owned futures; direct Source Access branch replaced by its host; no abandoned abstraction. |
| Tests / architecture | NO ISSUE: causal real-controller/inert-port races plus host tests; six specialist / one Operating census and unchanged forbidden-import suite pass. |
| Generated / dependency hygiene | NO ISSUE: normal targeted generation, one changed companion, dependencies/lockfiles unchanged. |
| Documentation agreement | NO ISSUE: refusal is explicitly distinguished from successful reentrant drain; fake exit permission from native exit; no release claims. |
| UX conventions | NO ISSUE for inspected scope: existing Source Access screen and messages reused. Visual layout/accessibility redesign was not inspected because no rendering changes were made. |

Zero unresolved BLOCKER, zero SHOULD FIX, no OPTIONAL cleanup proposed. The non-settling-port contract remains intentionally pending; there is no timeout pretending to stop a native operation. Restart-active refusal is the explicit boundary required to avoid both self-await and false success within the existing API. No new refusal/status API was introduced.

## Remaining production prerequisites

Still unqualified: production target identity/integrity, external launch responsibility, old PID death, archive-lock release, new native/Dart admission, real FDA continuity and signed human qualification, and in-place data continuity. The current source and inert tests establish none of these OS facts. Cancelable exit can be bypassed by crash/forced termination. Prompt 126 must be separately authorized; no native/process/data/FTS work follows this checkpoint.

SOURCE ACCESS STOP-AND-DRAIN QUALIFIED: YES
SOURCE ACCESS CANCELABLE EXIT HOST QUALIFIED: YES
REENTRANT RESTART SELF-AWAIT AVOIDED: YES
SIX SPECIALIST EXIT HOSTS ARCHITECTURALLY QUALIFIED: YES
STAGE 1/2 RESET DENIAL UNCHANGED: YES
SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES
REAL PRODUCTION PROCESS HANDOFF IMPLEMENTED: NO
PRODUCTION APPCZAR ACTIVATION: OFF
PROJECT CONFORMANCE: PASS
READY FOR SEPARATE PROMPT 126: YES
