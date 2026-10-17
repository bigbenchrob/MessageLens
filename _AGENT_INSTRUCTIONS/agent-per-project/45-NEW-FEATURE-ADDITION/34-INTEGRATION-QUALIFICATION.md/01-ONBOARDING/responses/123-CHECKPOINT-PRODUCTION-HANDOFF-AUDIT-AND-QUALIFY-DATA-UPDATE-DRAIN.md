# Response 123 — STOP: Data Update drain qualification

## Disposition

**STOP. Implementation is preserved unstaged, not qualified or committed.** The requested Data Update cancelable-exit host adds a fifth `AppLifecycleListener` to the harness. The mandatory architecture test at `test/architecture/app_czar_architecture_test.dart:1147` requires exactly four. That test is outside Prompt 123's four-file handwritten allowlist. It must be explicitly brought into scope and updated to protect the new fifth jurisdiction host, while retaining the existing four and the separate Operating listener. Hiding a listener from its source census or changing other hosts to satisfy the old count would be an inappropriate workaround.

There is a second architecture failure: the new controller's `unawaited` continuation is outside the approved boundaries checked by `test/architecture/forbidden_imports_test.dart:2075`. This is an implementation issue requiring a conformant ownership correction; this response does **not** request an architecture exemption. Analyzer also found six test-file lint issues, detailed below. No success checkpoint is created with these unresolved gates.

The focused behavioral results are useful evidence, but do not override the failed mandatory qualification gates. Production AppCzar remains OFF. No native restarter or process handoff was implemented.

## Verified baseline and document disposition

- Branch: `fix/onboarding-import-stuck-state`.
- HEAD remains `d64c0ef20125c31a32d20d258969ecdf85f52b3e`; upstream ahead/behind `0/0` at start and final verification.
- That existing commit contains exactly Prompt/Response 122 and follows `1d6bc6524f2f0252798f0b02c9788afb681c0889`. No duplicate documentation checkpoint was made.
- Stage 1 `e21334de96c2ab1484acbb8f3378ccad2cc49972` and Stage 2 `daac3e6b54812c98d56dba7eb3ea8fb8f8296798` verified ancestors. All 17 Stage 2 implementation hashes recorded in `/private/tmp/prompt121-implementation-hashes.json` still match.
- Shared-instructions submodule remains `95326f515ef4719f155ce6e223990398daad6311`, clean.
- Four worktrees were verified: primary at the HEAD above; Feature 35 at `09b1c767cc01410da5799273206e2ab2a4d3b283`; main at `b67bfafc3ad4f4f0c15792f0245bfecf5e45f43f`; Gradle worktree at `4f3e4fcc4eed2bd69eb237ae0aa328c917bbce37`. Only primary holds the active branch. No other worktree was changed.
- Pre-edit inventory `/private/tmp/prompt123-baseline.json`: SHA-256 for 6,022 tracked regular files and 50 untracked files. Initial tracked tree/index were clean. Fifty includes Prompt 123 plus 49 unrelated files.
- Final comparison: exactly the four allowed handwritten paths and one allowed generated companion differ. Every other baseline tracked file and all 50 baseline untracked file contents remain unchanged. No new untracked generated file appeared. `/private/tmp/prompt123-stopped-hashes.json` records the five stopped implementation hashes.
- This response is the only additional untracked repository file. The onboarding README, restored historical documents, `_ARCHIVED` material and all unrelated files remain untouched. Index is empty. No source or documentation commit/push was made under Prompt 123; the success-only two-commit workflow did not become applicable.

## Instructions, architecture and invariants

Reviewed against the supplied `AGENTS.md`, shared `00-global/agent-guardrails.md`, project README, shared Dart and Riverpod provider instructions, Feature 34 Project Conformance standard, Prompt/Response 122 and Prompt 123. The preceding source audit's database, overlay, attachment preservation and production FDA constraints remain applicable and unchanged. Current controller, harness, executor/worker, restarter, other specialist exit hosts and Operating drain pattern were inspected before implementation.

Native startup owns archive identity and process lock; the admitted root owns composition/reset lifetime. Data Update coordinates one selected generation; its existing executor owns `liveGraphUpdate` mutation work. The harness owns cancelable-exit permission, not actual process death. No second worker, jurisdiction or mutation authority was introduced. Production activation, root admission, seven jurisdiction cases, Stage 1/2 reset denial, independent Local Data Repair, overlay separation and archive preservation remain unchanged.

All newly selected Data Update test paths override executor and restarter before construction. The existing controller test that exercised real archive mutation tenure was replaced with inert sequencing coverage in the allowed test file. This deliberately does not requalify capability release: the unchanged executor/coordinator's await/finally ordering is source evidence only in this task.

## Characterization before production edits

Only the two allowed test files were changed first. The controller characterization used a recording executor and a result Completer to demonstrate zero immediate execution before scheduling, no restart while its result was pending, then one execution and one inert restart after completion. A source-only harness characterization confirmed direct Data Update screen rendering and absence of its own exit host. That source assertion was replaced by runtime host tests after implementation.

Pre-edit source inspection established the missing safety behavior: `_runSelectedUpdate` was scheduled without retaining its future; automatic restart was awaited inside that selected run; there was no Data Update stop/drain method. Failed-state manual restart could run independently. A future generic restarter calling a drain that included its own callback would be a recursive self-await hazard. The new reentrant fake test directly exercises that hazard without any process operation.

Baseline test command:

```text
flutter test --no-pub test/essentials/app_czar_data_update/application/app_czar_data_update_controller_test.dart test/essentials/app_czar/presentation/app_czar_startup_harness_test.dart --reporter expanded
```

Final characterization result: **12 passed, exit 0**, recorded in `/private/tmp/prompt123-characterization-final.log`. This does not mark absent stop/drain behavior as passing. The initial sandboxed attempt exited 1 because Flutter could not write its SDK `engine.stamp`; the approved SDK-cache retry was interrupted to correct the test's missing live provider subscription. Neither preliminary attempt is qualification evidence.

## Preserved implementation and observed behavior

Changed handwritten files:

1. `lib/essentials/app_czar_data_update/application/app_czar_data_update_controller.dart`.
2. `lib/essentials/app_czar/presentation/app_czar_startup_harness.dart`.
3. `test/essentials/app_czar_data_update/application/app_czar_data_update_controller_test.dart`.
4. `test/essentials/app_czar/presentation/app_czar_startup_harness_test.dart`.

Generated only: `lib/essentials/app_czar_data_update/application/app_czar_data_update_controller.g.dart`; normal generator changed its source hash, not a manual edit.

Controller sequencing in the stopped delta:

- A build-owned assessment listener selects once and retains the scheduled microtask as `_activeWork` before execution starts. It avoids rebuilding the owner on each assessment publication. A replacement generation/disposition irreversibly seals this controller's admission.
- `stopAndDrain` seals synchronously before awaiting `_activeWork`. Stop/disposal/assessment replacement suppress further publication and automatic/manual dispatch. A pre-microtask stop prevents executor provider construction.
- The actual executor result includes its prerequisite/graph/preservation interval. Controlled tests now give those three stages distinct causal barriers. Stopping does not cancel an admitted worker; each barrier must settle before drain can finish.
- Work exceptions are retained with stack traces and published only while admission remains open. A drain rethrows retained failure; the host refuses exit. Late callbacks after stop/disposal cannot republish. Failed/deferred-preservation state retains explicit restart eligibility while admission is open.
- A continuation outside `_activeWork` clears that work slot before requesting restart. A separately recorded restart microtask checks admission again; stop wins before dispatch. Duplicate requests share dispatch. This continuation currently uses disallowed `unawaited`, so its architecture conformance is **not** qualified despite behavioral passes.
- An inert restarter reentering `stopAndDrain` completed successfully. No test interprets its completion as new PID/archive admission. A never-settling synthetic executor produced neither drain completion nor restart; the test explicitly completed it for cleanup.

Harness sequencing:

- Only Data Update's branch gains a dedicated host. On mounting, the host captures the already-selected notifier's drain method; exit does not resolve a replacement controller.
- Its `AppLifecycleListener` awaits drain, returns `AppExitResponse.exit` on success and `AppExitResponse.cancel` on exception. Repeated pending requests do not duplicate the executor. Removing the host removes its listener; a subsequent binding exit request no longer reaches the host.
- The two host tests observed pending exit permission until work settled, successful permission after success, and refusal after synthetic failure. No actual exit was called. Crashes/forced OS termination remain outside this guarantee.
- Other six jurisdiction source paths, neutral Operating shell and generic legacy monitor selection are unchanged. The new fifth listener is the deliberate change rejected by the read-only historical architecture count.

Cleanup in new tests explicitly completes pending worker/barrier futures and closes provider subscriptions/containers; widgets unmount hosts. Disposal is not represented as awaited work settlement. There are no added wall-clock sleeps or production timeouts. One pre-existing test timeout remains a test failure bound, not a cancellation or quiescence claim.

## Actual verification results

| Process / evidence | Result |
| --- | --- |
| Baseline characterization, two allowed test files | 12 passed, exit 0; `/private/tmp/prompt123-characterization-final.log` |
| First implementation focused run | Compile failure from invalid const test fixture construction, exit 1; `/private/tmp/prompt123-focused.log` |
| Corrected intermediate focused run | 25 passed, exit 0; `/private/tmp/prompt123-focused-2.log` |
| Final focused plus screened regressions, eight files listed below | **58 passed, exit 0**; `/private/tmp/prompt123-regressions.log` |
| `flutter test --no-pub test/architecture --reporter expanded` | **642 passed, 2 failed, exit 1**; `/private/tmp/prompt123-architecture.log` |
| `flutter analyze --no-pub` | **6 issues, exit 1**; `/private/tmp/prompt123-analyze.log` |
| Normal `dart run build_runner build --build-filter=lib/essentials/app_czar_data_update/application/app_czar_data_update_controller.g.dart` | Both runs exit 0; final source generation in `/private/tmp/prompt123-generator-final.log`; exact tracked/untracked hash check found only the permitted companion changed |
| `dart format --output=none --set-exit-if-changed` on four handwritten files | 4 checked, 0 changed, exit 0 |
| Working and staged `git diff --check` | Exit 0; staged check has an empty index and is not a source-checkpoint approval |
| Baseline and Stage 2 hash checks | Only five allowed implementation paths changed; unrelated baseline files preserved |

The final 58-test command named:

- `test/essentials/app_czar_data_update/application/app_czar_data_update_controller_test.dart`
- `test/essentials/app_czar/presentation/app_czar_startup_harness_test.dart`
- `test/essentials/app_czar_data_update/infrastructure/macos_development_process_restarter_test.dart`
- `test/essentials/app_czar_data_update/presentation/app_czar_data_update_screen_test.dart`
- `test/app_czar_startup_composition_test.dart`
- `test/essentials/app_czar/application/non_destructive_operating_composition_characterization_test.dart`
- `test/essentials/app_czar_operating_session/presentation/app_czar_operating_session_app_test.dart`
- `test/essentials/app_czar_attachment_archive_repair/presentation/app_czar_attachment_archive_repair_screen_test.dart`

Screened exclusions: the Data Update executor-provider regression invokes the real `liveGraphUpdate` coordinator/tenure and was not run. Operating currentness controller coverage contains a real-worker/tenure case and was not run wholesale; the selected Operating presentation/exit and composition regressions were run instead. No full repository suite, native Runner tests or signed app test ran. Architecture files were screened as source/AST checks; their disposable virtual fixtures write/delete source text only, not archive data. Screening notes: `/private/tmp/prompt123-architecture-api-screen.txt` and `/private/tmp/prompt123-architecture-screening.txt`.

Analyzer details at the stopped revision:

- Duplicate `dart:async` import and directive ordering in the harness test.
- Additional directive ordering for the added harness-test package imports.
- Directive ordering in the controller test.
- Non-const immutable constructor list literals in the two synthetic assessment fixtures.

These are not waived. Source edits stopped at the explicit allowlist conflict; lint cleanup and renewed validation remain necessary on resumption.

## Canonical Project Conformance — failed qualification

Scope: accumulated unstaged Prompt 123 delta against `d64c0ef20125c31a32d20d258969ecdf85f52b3e`, exactly four handwritten files plus generated companion. No unrelated branch history is included as new work. Reviewed against the instruction list above and `34-INTEGRATION-QUALIFICATION.md/00-PREPARATION/MESSAGELENS-PROJECT-CONFORMANCE-AUDIT-STANDARD.md`.

| Classification | Finding and governing rule | Smallest required resolution |
| --- | --- | --- |
| BLOCKER | Fifth required exit host conflicts with `app_czar_architecture_test.dart:1147`; mandatory architecture gate fails; test is read-only under Prompt 123 | Explicitly amend scope for that exact architecture test, update the count to five with Data Update ownership assertions, retain existing jurisdiction exclusions, rerun. Do not hide the listener or alter other hosts |
| BLOCKER | Data Update introduces `unawaited` outside the approved boundary census at `forbidden_imports_test.dart:2075`; asynchronous lifecycle ownership must conform | Correct the controller's explicit future ownership within its existing allowance, preserving post-work dispatch and reentrant drain; no new architecture exemption is authorized |
| SHOULD FIX | Six analyzer issues in allowed test files; required analyzer gate failed | Clean imports and immutable literals in those files, then rerun affected tests/analyzer |
| NO ISSUE | Exact edit scope, generated treatment, baseline preservation and absence of real-data/native operations | Preserve these boundaries on resumption |
| NO ISSUE, bounded behavioral evidence | Inert reentrant drain and awaited/refused exit tests passed; selected automatic update, deferred/error and manual restart behavior covered | Do not promote these passes into overall qualification or signed runtime proof |

Checklist: existing controller/host idioms reused; owner responsibilities unchanged; no new dependency direction or identity authority; generated provider pattern retained. Scheduled/active work is bounded by actual executor settlement, never a timeout assertion. No new content logging or data retention. No reset/mutation authority expansion, schema/dependency/signing changes or obsolete-source deletion. Error/refusal behavior is explicit, but no new UI is claimed. Tests are inert and architecture failures remain visible. Documentation matches the stopped state. Visual UX redesign is not applicable; signed/runtime UX remains unqualified. Reuse, safety and scope checks do not erase the unresolved asynchronous-boundary and mandatory-gate failures.

PROJECT CONFORMANCE: FAIL

## Remaining work and unknowns

No implementation checkpoint ID exists; no Prompt/Response 123 documentation checkpoint ID exists. HEAD remains the prior audit checkpoint. The implementation and this response are intentionally left for review; no reset/stash/clean or rollback was performed.

A continuation needs the exact architecture-test scope amendment above, in-scope ownership/lint corrections and renewed qualification. This is not permission to begin a different lifecycle milestone. Real production target validation, native launch protocol, old PID death, archive-lock release/inheritance, new PID/native/Dart admission, signed/FDA continuity and real-data continuity all remain UNKNOWN. Other jurisdiction drain gaps from Response 122 remain unresolved. No populated reconstruction or FTS witness is introduced.

DATA UPDATE STOP-AND-DRAIN QUALIFIED: NO
DATA UPDATE CANCELABLE EXIT HOST QUALIFIED: NO
RESTART AFTER WORK SETTLEMENT: YES
REENTRANT SELF-AWAIT AVOIDED: YES
REAL PRODUCTION HANDOFF IMPLEMENTED: NO
STAGE 1/2 RESET DENIAL UNCHANGED: YES
SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES
PRODUCTION APPCZAR ACTIVATION: OFF
PROJECT CONFORMANCE: FAIL
READY FOR A SEPARATE PROMPT 124: NO
