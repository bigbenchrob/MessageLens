# Response 124 — Data Update drain correction qualified

## Outcome and checkpoint disposition

The preserved Prompt 123 implementation is corrected and qualified within the amended scope. Data Update seals admission synchronously, drains actual scheduled/active executor work, dispatches restart outside that drained future, and grants cancelable-exit permission only after successful settlement. The fake reentrant-drain case passes. The architecture suite now protects exactly five specialist exit listeners plus the separately owned Operating listener. No new asynchronous-boundary exemption was added.

Checkpoints, normally pushed on `fix/onboarding-import-stuck-state`:

- Preserved STOP record: `594d06cd57ed9a5e48d32312a39507560ed4a971`, exactly Prompt 123 and Response 123; their bytes were not rewritten.
- Qualified implementation: `a90612830fac05d79fff5d6097c2b0d35dd23b6e`, exactly five handwritten files and one generated companion.
- This exact Prompt/Response 124 pair is the subsequent separate documentation checkpoint; its resulting hash is reported in the final handoff rather than invented within this document.

**Evidence limit:** all lifecycle execution here uses inert executors/restarters and synthetic observations. Awaited `AppExitResponse.exit` is permission to exit, not proof of native old-process death, archive-lock release, replacement launch or new-process admission. Production AppCzar remains OFF. No native launcher, real worker, archive mutation tenure, Ball, process exit, permission/signing action, database or attachment operation ran.

## Verified recovery and preservation

Initial HEAD was `d64c0ef20125c31a32d20d258969ecdf85f52b3e`, upstream `0/0`. Index was empty. The exact five-file unstaged Prompt 123 delta matched every SHA-256 in `/private/tmp/prompt123-stopped-hashes.json`; no replacement or unexpected tracked edit was found. Prompt 123 and its complete STOP response were untracked and subsequently checkpointed separately before implementation staging.

A new baseline manifest, `/private/tmp/prompt124-baseline.json`, recorded 6,022 tracked regular files and 52 untracked files: Prompt/Response 123, Prompt 124 and 49 unrelated files. Every baseline untracked file's bytes remain unchanged despite the authorized tracking-disposition changes. All tracked files outside the six-path implementation scope also retain their baseline hashes. The retained harness implementation is byte-identical to the stopped baseline; only the ownership correction, test lint corrections, architecture assertion and generated source hash changed during Prompt 124.

Four worktrees were verified and preserved:

| Worktree | Recovered HEAD / disposition |
| --- | --- |
| Primary `remember_every_text` | `d64c0ef2`, only holder of active branch; advanced through the authorized checkpoints |
| `remember_every_text-feature-35` | `09b1c767cc01410da5799273206e2ab2a4d3b283`, untouched |
| `remember_every_text-main` | `b67bfafc3ad4f4f0c15792f0245bfecf5e45f43f`, untouched |
| `remember_every_text.worktrees/gradle-fix-flutter-projects` | `4f3e4fcc4eed2bd69eb237ae0aa328c917bbce37`, untouched |

Shared instructions remain clean at `95326f515ef4719f155ce6e223990398daad6311`. Stage 1 `e21334de96c2ab1484acbb8f3378ccad2cc49972` and Stage 2 `daac3e6b54812c98d56dba7eb3ea8fb8f8296798` remain ancestors. All 17 recorded Stage 2 implementation hashes match. Main, reset admission/services/actions, Local Data Repair, shared coordinator, worker/executor, restarter, native Runner and the other six jurisdiction sources remain unchanged. Navigation README, historical/restored documents, `_ARCHIVED` scripts and unrelated untracked files were neither staged nor edited.

## Reproduced red gates before correction

The unchanged stopped source was rechecked with actual fresh processes:

| Command | Observed result | Local evidence |
| --- | --- | --- |
| `flutter test --no-pub test/architecture --reporter expanded` | 642 passed, 2 failed; exit 1 | `/private/tmp/prompt124-red-architecture.log` |
| `flutter analyze --no-pub` | Six issues; exit 1 | `/private/tmp/prompt124-red-analyze.log` |

Architecture failures were the exact four-versus-five listener census in `test/architecture/app_czar_architecture_test.dart:1147` and the unapproved `unawaited` boundary in `test/architecture/forbidden_imports_test.dart:2075`. Analyzer reproduced duplicate/directive-order imports and non-const immutable fixture literals in the two allowed test files. Prior Prompt 123 passing tests were not reused as current qualification. SDK-cache access was requested explicitly for Flutter/Dart commands; no partial or interrupted Prompt 124 command was counted as PASS.

## Narrow corrections and lifecycle ownership

`lib/essentials/app_czar_data_update/application/app_czar_data_update_controller.dart` now assigns the post-work continuation to `_restartFlight` using `_restartAfterWork(work)`. The helper awaits the retained work future, clears `_activeWork`, and only then requests restart while admission is open and work has no failure. It awaits that request and handles unexpected errors through the existing retained failure/state path. `_requestRestart` retains its separately scheduled dispatch future, catches restarter errors, and returns the same dispatch for duplicate requests. A sealed admission returns a completed no-dispatch future rather than adopting an unrelated pending restart. There is no `unawaited` call or new exception to the forbidden-import rule.

The owned continuation is never part of `_activeWork`. Thus a restarter calling `stopAndDrain` cannot await the restart that called it. `_activeWork` begins before its microtask starts and ends only when the executor/preservation result and existing result checks settle. It does not use a UI state transition as completion. Stop closes admission before any await; a scheduled-but-not-started worker is not resolved. Stop/disposal/assessment replacement cannot reopen admission or publish late results. Already admitted work settles naturally; suppression is not cancellation.

The harness implementation from Prompt 123 is preserved. Its Data Update host captures the already selected notifier's drain method when mounted, awaits it in the cancelable-exit handler, returns exit only on success and cancel on an exception. It does not create a new owner at exit time. Listener disposal removes the callback; disposal itself is not presented as an awaited drain. A permanently pending worker produces neither permission nor restart; no timeout pretends to cancel it. Crash/forced OS termination remain outside this contract.

`test/architecture/app_czar_architecture_test.dart` changes only the relevant exit-host test. It now requires exactly five `AppLifecycleListener` constructions in the harness, positively names and requires the return branch for Diagnostic Review, Onboarding, Local Data Repair, Attachment Archive Repair and Data Update, and isolates Data Update's host to assert:

- exactly one listener and the exit-request callback;
- captured Data Update notifier `stopAndDrain` method;
- no provider lookup in the exit handler;
- awaited drain before exit permission;
- exception-to-cancel handling and listener disposal.

All previous controller ownership/exclusion assertions and the separate exactly-one Operating listener assertion remain. The global forbidden-import suite is unchanged. No listener was hidden or relocated to satisfy the count.

The only test-file corrections during Prompt 124 are duplicate/order imports and `const` fixture lists. Existing assertions, controlled barriers, disposal cleanup and test cases remain intact. No lint suppression or test removal was used to obtain PASS. The prior Prompt 123 replacement of a real-tenure controller test with inert sequencing coverage remains explicitly documented in its STOP response; this task does not claim that replacement proves real tenure release.

## Fresh qualification

All results below have observed process exit codes on the corrected source:

| Gate | Result | Evidence |
| --- | --- | --- |
| Two focused controller/harness test files | **27 passed, exit 0** | `/private/tmp/prompt124-focused.log` |
| Six screened regression files | **31 passed, exit 0** | `/private/tmp/prompt124-regressions.log` |
| Complete `test/architecture` suite | **644 passed, exit 0** | `/private/tmp/prompt124-architecture.log` |
| `flutter analyze --no-pub` | **No issues, exit 0** | `/private/tmp/prompt124-analyze.log` |
| Targeted format check, five handwritten files | **0 changes, exit 0** | Tool process output |
| Normal filtered generator | **Exit 0** | `/private/tmp/prompt124-generator.log` |
| Working/staged `git diff --check` | **Exit 0** | Exact scoped staging checks |
| Hash/allowlist verification | **Exactly six source/test/generated paths; unrelated baseline bytes preserved** | `/private/tmp/prompt124-qualified-hashes.json` and baseline comparison |

Focused command used `flutter test --no-pub`, `--reporter expanded`, and exactly:

- `test/essentials/app_czar_data_update/application/app_czar_data_update_controller_test.dart`
- `test/essentials/app_czar/presentation/app_czar_startup_harness_test.dart`

Regression command used the same options and exactly:

- `test/essentials/app_czar_data_update/infrastructure/macos_development_process_restarter_test.dart`
- `test/essentials/app_czar_data_update/presentation/app_czar_data_update_screen_test.dart`
- `test/app_czar_startup_composition_test.dart`
- `test/essentials/app_czar/application/non_destructive_operating_composition_characterization_test.dart`
- `test/essentials/app_czar_operating_session/presentation/app_czar_operating_session_app_test.dart`
- `test/essentials/app_czar_attachment_archive_repair/presentation/app_czar_attachment_archive_repair_screen_test.dart`

The focused matrix passed pre-microtask stop with zero executor construction; separate prerequisite/graph/preservation barriers; normal success; deferred preservation and worker error; duplicate stops/restarts; stop/result and stop/manual-restart races; stale assessment/disposal suppression; inert restarter failure; reentrant drain without self-await; pending-worker no-completion; successful and refused exit, repeated requests and listener removal. Tests explicitly release synthetic pending work and dispose containers/listeners. Fake restart completion never becomes evidence of new admission.

Screening retained Prompt 123's exclusions: the Data Update executor-provider test acquires actual mutation tenure and was not executed; Operating currentness controller tests include a real-worker/tenure case and were not run wholesale. The selected Operating shell/exit and composition tests use inert seams. Architecture tests inspect source/AST, including temporary source-text fixtures; they do not execute the real-authority code whose text they inspect. No full non-architecture suite, production build, native test or signed runtime rehearsal was run.

Generation command was `dart run build_runner build --build-filter=lib/essentials/app_czar_data_update/application/app_czar_data_update_controller.g.dart`. Build tooling reported cached/dependent outputs, but file/hash inspection verified that only the permitted controller companion changed in the repository. Its only diff is the generated source hash. No new untracked generated file, dependency change or manually edited generated output exists.

## Exact source inventory and SHA-256 preservation

The table compares the recovered **stopped working tree**, not the earlier committed pre-implementation source, with the tested/committed result. The unchanged harness row is intentional. The full cumulative implementation diff against the prior audit source is six paths, 710 insertions and 116 deletions; Prompt 124 did not discard or reimplement the preserved delta.

| Path | Recovered SHA-256 | Qualified SHA-256 |
| --- | --- | --- |
| `lib/essentials/app_czar/presentation/app_czar_startup_harness.dart` | `40b4c3ba8eaee113becc2d40d1e8e3dd2174019e1822c7c0958fecb17230ebf8` | `40b4c3ba8eaee113becc2d40d1e8e3dd2174019e1822c7c0958fecb17230ebf8` |
| `lib/essentials/app_czar_data_update/application/app_czar_data_update_controller.dart` | `e7efbf37746e4a7eae36c4f01f27e4437d451b42f1736e855a748e93e12b703b` | `651af30b99cad504d47fb114264b609e2b472e3bb939b98fb7244e63ab6c7609` |
| `lib/essentials/app_czar_data_update/application/app_czar_data_update_controller.g.dart` | `ff16bc3e1ae7073fd2408b049f806c5d4ce32ef8ca6217d24c73dc6e77154911` | `7b6df6e7dd5a23655e2d80ff91a1617b5dd64ba8293b33651f7c2bc5e4d58c08` |
| `test/architecture/app_czar_architecture_test.dart` | `c2f256745f175e8b8cbd1088ad84acf3bf90c0686b8cb42ec9542375b923d19c` | `6ca6c0494656d8add0873deb0a14e8c104613496bf90a880599c518a73e0b15d` |
| `test/essentials/app_czar/presentation/app_czar_startup_harness_test.dart` | `c37943bd180469eca7b2237cccf66d58c880b6bc460cf1fd0f2b028e4a9bb37a` | `b3d23ff9a496fd4f85fc45f2facfa0360f098920462769219d06bdd9228723b5` |
| `test/essentials/app_czar_data_update/application/app_czar_data_update_controller_test.dart` | `401cd5761465090945b6463063c4c173fc7e3884091cc4db7234c7b1c105b0d7` | `ae1f202a0e44e69f4d520db8c6e10de6436dacfa6393186bcc0b08560352e061` |

## Canonical Project Conformance

**Scope:** complete accumulated Prompt 123/124 source/test/generated delta against `d64c0ef20125c31a32d20d258969ecdf85f52b3e`, carried unchanged through prerequisite STOP-doc commit `594d06cd` and qualified before source staging. This is not a whole-feature integration or production-cutover certification.

**Reviewed against:** supplied `AGENTS.md`; shared `00-global/agent-guardrails.md`, `10-language/dart.md`, `20-flutter/riverpod-provider-patterns.md`; project README and architecture/database/overlay/attachment-preservation constraints carried from the source audit; Feature 34 `00-PREPARATION/MESSAGELENS-PROJECT-CONFORMANCE-AUDIT-STANDARD.md`; Prompts/Responses 122–123; and Prompt 124's exact scope and inert-validation requirements. Explicit Prompt 124 authorization permits these corrections and exact checkpoints; it does not authorize native/runtime/data work.

Pre-checkpoint review: **BLOCKER: 0; SHOULD FIX: 0**. The three reproduced blockers/issues are closed by the stronger host census, explicitly retained/handled asynchronous continuation and clean analyzer. No architecture exemption was added.

| Review area | Finding |
| --- | --- |
| Reuse before invention; layering/ownership | NO ISSUE: existing Data Update notifier and specialist-host pattern; worker and restart futures have distinct ownership, no new coordinator/provider |
| Dependency direction and single source of truth | NO ISSUE: no new infrastructure/presentation coupling, path/identity/schema authority or operation; restart port and native authority unchanged |
| Project idioms | NO ISSUE: generated Riverpod companion, existing immutable state/error semantics, explicit futures; forbidden-import gate passes without modifying its rule |
| Performance/bounded work | NO ISSUE in scope: one selected execution and one dispatch; no new polling, archive scan or payload I/O. Unsettled worker remains unresolved, not falsely canceled |
| Privacy/logging | NO ISSUE: no new user-content logging or persistent evidence store; test paths/data synthetic |
| Mutation/authority safety | NO ISSUE: Stage 1/2 and Local Data Repair unchanged; no expansion of capability, reset, archive or overlay authority; real operations excluded from tests |
| State/error semantics | NO ISSUE: work failure retained, stale publication suppressed, restarter failure reported, exit refused on drain error; same-process fake completion not labeled new admission |
| Dead/superseded code | NO ISSUE in this delta: old direct screen branch replaced by its host; detached continuation removed; no abandoned provider or duplicate owner |
| Tests/architecture | NO ISSUE: fresh 27 + 31 behavioral/regression tests, all 644 architecture tests; precise host count strengthened, no tests weakened for PASS |
| Generated/dependency hygiene | NO ISSUE: normal generation, only permitted hash companion changed; no dependency/lockfile/signing changes |
| Documentation agreement | NO ISSUE: STOP remains historical and unchanged; current response distinguishes fresh tests, source evidence and native unknowns |
| UX conventions | NO ISSUE within scope: existing screen/state unchanged; host changes lifecycle permission only. Signed-runtime/user-facing launch behavior remains unqualified |

PROJECT CONFORMANCE: PASS

## Final handoff boundary

Source commit `a90612830fac05d79fff5d6097c2b0d35dd23b6e` is pushed; tracked tree/index were clean and upstream `0/0` before creating this response. Final documentation staging is restricted to exact Prompt/Response 124, followed by normal commit/push and another preservation/status check. The resulting documentation hash and final status are reported in the handoff. After tracking those documents, 49 unrelated untracked files remain intentionally preserved; no broad staging or cleanup is performed.

Production process handoff remains unimplemented: target signing/integrity, external launcher responsibility, old PID death, lock release/inheritance and replacement native/Dart admission are still UNKNOWN without separately authorized work and signed qualification. Other jurisdiction lifecycle gaps remain outside this task. Existing native, FDA, data continuity and reconstruction findings are not upgraded by inert tests. Stop here; a new Prompt 125 must separately authorize any next milestone.

DATA UPDATE STOP-AND-DRAIN QUALIFIED: YES
DATA UPDATE CANCELABLE EXIT HOST QUALIFIED: YES
RESTART AFTER WORK SETTLEMENT: YES
REENTRANT SELF-AWAIT AVOIDED: YES
FIVE SPECIALIST EXIT HOSTS ARCHITECTURALLY QUALIFIED: YES
ASYNC OWNERSHIP ARCHITECTURE: PASS
REAL PRODUCTION PROCESS HANDOFF IMPLEMENTED: NO
STAGE 1/2 RESET DENIAL UNCHANGED: YES
SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES
PRODUCTION APPCZAR ACTIVATION: OFF
PROJECT CONFORMANCE: PASS
READY FOR A NEW SEPARATE PROMPT 125: YES
