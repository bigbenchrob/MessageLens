# MessageLens — Feature 34
## Prompt 128 — Checkpoint Disposable Exit Observer and Qualify Fail-Closed AppCzar Exit Listeners

**Task:** Narrow production lifecycle safety correction; characterize first, then qualify explicit cancellation of application exit when an owned jurisdiction's `stopAndDrain` fails. **Not:** production launcher, process-exit integration, native admission, production AppCzar activation, populated reconstruction, or another coordinator.

### 0. Governing decision and authority

Response 127 successfully qualified an isolated macOS `EVFILT_PROC`/`NOTE_EXIT` observer and *synthetic* at-most-once sink using disposable parent/helper processes. It did **not** integrate MessageLens, launch an application, or prove native/Dart readmission. Preserve that source, its exact test evidence, and the one-shot design. The agreed application terminology is **coordinator completion → process exit → fresh launch → independent AppCzar reassessment**. There is **no coordinator-to-coordinator handoff**, transfer of AppCzar assessment, jurisdiction selection, provider container, database handle, Ball, lease, or work state.

Response 126 inspected Flutter's application-termination behavior and identified a concrete blocker: the older specialist cancelable-exit hosts (Diagnostic Review, Onboarding, Local Data Repair, Attachment Archive Repair), and the separate Operating Session exit listener, await jurisdiction drains without explicit `Object`/asynchronous-error-to-`AppExitResponse.cancel` handling. In the inspected Flutter SDK, an unhandled termination-listener exception may not reliably cancel native termination. In contrast, the Data Update and Source Access Repair hosts added/qualified in Responses 124–125 already catch drain failure and explicitly cancel exit.

**Authorize only the smallest correction needed to make exit refusal explicit for those five existing listeners.** Do not refactor owner controllers, invent a central shutdown engine, treat cancellation as native process death, or try to solve the actual fresh-launch mechanism in this prompt.

The following must remain unchanged: seven AppCzar jurisdictions; all six specialist listeners and the separate Operating listener; Data Update and Source Access Repair's qualified drain/refusal semantics; Stage 1/2 composition-bound denial of `startFresh` and `messageDataReset`; exact Local Data Repair safety; overlay/Presence/historical/attachment preservation; production AppCzar activation unconditionally **OFF**.

Absolute safety boundaries: **no** real Messages, Contacts, MessageLens database, actual archive/root/volume, attachment payload, FDA/TCC/bookmark, cloud backup, native application launch/quit, mutation Ball/tenure, writable lease, signature operation, or user data. All controller, assessment, exit and other provider dependencies in executable tests must be replaced with inert fixtures *before* any automatic controller can be built. Do not execute real mutations merely because a test filename is relevant. Fair Witness: distinguish executed callback tests, source/AST assertions, and unqualified Flutter/AppKit signed-runtime behavior.

### 1. Verify baseline, preserve assets, checkpoint Response 127

1. Verify actual branch, HEAD, upstream, tracked worktree/index, four registered worktrees, shared-instructions submodule, and pre-existing untracked inventory and hashes. Expected branch `fix/onboarding-import-stuck-state`; earlier submodule `95326f515ef4719f155ce6e223990398daad6311`. Do not assume the prior HEAD is unchanged.
2. Verify source checkpoint `c5d727a9c21aaced5fe000ae8bae0f8d096df6d2` in ancestry. The two isolated probe files `tool/macos_fresh_launch_probe.c` and `tool/macos_fresh_launch_probe_test.py` are **reuse/read-only** here. Prompt/Response 127 should be checkpointed as one exact docs-only commit, if not already; if they are committed, verify and do not duplicate. Normally push only that exact checkpoint when necessary.
3. Preserve every unrelated tracked and untracked file, the onboarding navigation README, restored historical documents, three archived backup scripts, and the other worktrees. No `git clean`, stash, reset, rebase, force push, broad staging, mass formatting, or unrelated regeneration.
4. Read the exact current source for the seven exit listeners, the harness's selected-jurisdiction branches, their controller `stopAndDrain` contracts, the existing Data Update/Source Access catch-to-cancel patterns, relevant listener tests, and the canonical Feature 34 Project Conformance standard. Source inspection must precede tests and edits. Confirm source/runtime API signatures instead of relying on historical line numbers.
5. If current source contradicts the described five unguarded listeners, or any one is already fail-closed under a proved alternative contract, record the precise distinction and **STOP** rather than duplicating policy.

### 2. Strict source and test allowlist

Only these **existing handwritten files** may be modified:

- `lib/essentials/app_czar/presentation/app_czar_startup_harness.dart`
- `lib/essentials/app_czar_operating_session/presentation/app_czar_operating_session_app.dart`
- `test/essentials/app_czar/presentation/app_czar_startup_harness_test.dart`
- `test/essentials/app_czar_operating_session/presentation/app_czar_operating_session_app_test.dart`
- `test/architecture/app_czar_architecture_test.dart` — only the narrowly relevant assertions for listener count/ownership, fail-closed error-to-cancel and listener disposal; do **not** alter unrelated architecture rules.

Documentation-only: exact Prompt/Response 127 prerequisite pair, if not already checkpointed, and exact Prompt/Response 128 pair under the established Feature 34 `01-ONBOARDING/` prompts/responses directories, in separate documentation commits as appropriate.

No new source/helper/test file. No generated Dart changes expected. All controller files, native Runner, Flutter SDK, restarter ports/providers, C/Python probe, Stage 1/2 reset code, `main.dart`, dependencies, pubspec, entitlements, schema/migrations, release metadata, and other jurisdiction/feature files are **read-only**. If a safe test or production correction needs another file, **STOP** and report the exact missing seam rather than expanding scope or weakening the test.

### 3. Characterize the actual gap before editing production

Within the two authorized presentation test files:

1. Inspect existing tests and host/listener construction patterns. Provide controlled provider overrides and an inert already-selected jurisdiction controller; ensure the test does not instantiate real selected automatic Data Update/Onboarding/Local Repair/Archive Repair workers, real restarter, filesystem, or native bridge.
2. Capture the present baseline: for each of **Diagnostic Review, Onboarding, Local Data Repair, Attachment Archive Repair and Operating Session**, invoke its *actual registered cancelable-exit callback* with a controller/drain fake whose `stopAndDrain()` throws a fixed synthetic error (both synchronous throw and asynchronous Future error, as applicable). State precisely whether it propagates or returns `AppExitResponse.cancel`.
3. Also verify a completed successful drain returns `AppExitResponse.exit` under existing behavior, without establishing OS termination. The actual listener's selected owner/occurrence and host disposal must be observable via inert counters.
4. If feasible with the existing hooks, retain attributable **expected red** tests asserting explicit cancellation on the unmodified source. If a particular owner cannot be safely instantiated under these files, use source/AST characterization and label it unexecuted; do not fake the application listener by testing a copied callback. **STOP** if this prevents a meaningful qualification of the required change under the allowlist.
5. Record the exact pre-edit commands, counts and observed failure types, including any SDK/cache sandbox interruption that did not execute tests.

The purpose is to prove the existing gap, not to mark an absent guard PASS.

### 4. Implement the minimal fail-closed correction

For each of the four older specialist listeners **and** the Operating listener:

1. Preserve the already selected host/controller/occurrence ownership and the existing `stopAndDrain` invocation. Do not resolve a fresh owner at exit merely to make the test pass, and do not instantiate a jurisdiction in a callback that was previously inert.
2. Await actual drain completion before returning `AppExitResponse.exit`. Catch all failure/error forms compatible with the project and Flutter callback signature (including asynchronous Future errors), return explicit `AppExitResponse.cancel`, and do not rethrow into Flutter's native termination reply channel. Prefer the same well-qualified style used by the Data Update and Source Access listeners. Do not claim a thrown listener automatically means cancellation.
3. Do not grant exit when an owner returns a typed refusal, has an outstanding restart-owning flight, or lacks proven quiescence; retain the controller's existing refusal behavior and do not convert an error into a successful drain. If a controller's **successful** drain currently conceals unsettled work, that is a separate owner defect: **STOP and report it**, not a reason to add a broad catch or unconditional exit.
4. Maintain one listener per specialist host, one separate Operating listener, correct mounting/disposal and no lingering listeners. Do not introduce another global listener, timer, catch-all restart owner, legacy monitor, or fallback shell.
5. Preserve existing user-visible error/diagnostic semantics insofar as the current API permits without new code: a canceled exit is not a successful quit, an archive repair, or a new assessment. Do not include source content/paths in new logs. Do not hide an actual failed drain from the controller's existing state, or invent a new UX/status system.
6. Do not modify the two already-qualified Data Update/Source Access catch-to-cancel implementations except if they are in the same shared harness and an incidental whitespace change is unavoidable (prefer none). Do not change the underlying controller methods.
7. Do not use `Future.timeout`, forced exit, `SystemNavigator.pop`, `exit(0)`, `runAgain`, an in-process navigation transition or a synthetic successful restarter as evidence of settled work, application death or fresh admission.

A listener catches drain errors so AppKit is instructed to **cancel** the ordinary requested exit. It is not a guarantee against crash, force-kill, OS-level required termination, or any other cause bypassing cancelable exit.

### 5. Deterministic adversarial qualification

Use controlled Completers, inert read-free providers, observed callback invocations, and clear causal barriers. No wall-clock sleeps, real controller worker or real OS quit. At minimum qualify:

- For each of the five corrected listeners: success returns `exit` **only after** drain settlement; synchronous and asynchronous failures return `cancel`, never propagate to Flutter's termination callback; a pending drain does not prematurely complete the callback.
- Diagnostic, Onboarding, Local Repair, Archive Repair and Operating each capture/use their correct *existing* owner, not an arbitrary replacement controller created during exit.
- Repeated exit requests do not initiate new jurisdiction work, select a replacement owner, or install duplicate listeners. Where Flutter can invoke callbacks independently, qualify listener-level behavior without inventing global request deduplication.
- Unmount/disposal removes exactly the owning listener. A pending explicit drain remains subject to its owner; disposal is not mistaken for settlement.
- At least one refusal that originates from an existing controller's deliberate `StateError`/typed refusal remains `cancel`, including the Source Access active-restart refusal as a **regression** if safely testable; the new listeners must not interfere with it.
- All six specialist hosts remain in their respective AppCzar jurisdiction branches, while Operating retains its separate one-route shell; no generic `App`/legacy ambient monitor, additional currentness owner or Start Fresh exposure.
- Update the existing architecture test to assert six specialist listener constructions, the distinct Operating listener, and positive error-to-cancel behavior on **all seven**, without relaxing existing structure/disposal checks or providing a broad exception for unguarded listeners. If AST-only checks cannot meaningfully establish exception handling, pair source checks with actual inert callback tests; never equate textual `catch` presence with native termination qualification.
- A synthetic listener future that never settles yields neither exit permission nor a claimed cancel/termination; explicitly complete all test-owned futures during cleanup.

Where existing controller tests would acquire mutation tenure or native/UI access, screen and omit the unsafe selection; list that exact exclusion. Do not run a real worker to obtain a prettier test count.

### 6. Validation, scope integrity and STOP gates

Report exact attributable process exit codes and counts for:

- the two focused presentation/listener test files;
- screened existing Data Update and Source Access controller/host and Operating presentation regressions, plus relevant diagnostic/onboarding/local-repair/archive-repair host tests that are provably inert;
- `test/architecture` (or the canonical standard's required architecture set), retaining the complete six-plus-one census;
- `flutter analyze --no-pub`, targeted `dart format --output=none --set-exit-if-changed`, working and staged `git diff --check`, exact file allowlist and original tracked/untracked hash preservation.

No generator run is expected (neither provider signatures nor annotations should change). If the generator would be required or reports edits, **STOP** and report the exact need. Run a full Flutter suite only when mandated by the canonical Project Conformance standard or a concrete issue. Distinguish historical tests from fresh executed results. Record intermediate red tests and corrective iterations rather than silently dropping them.

Canonical Project Conformance **PASS requires** zero in-scope BLOCKER and SHOULD FIX findings, including: only listed files; same seven jurisdictions; exactly six specialist exit hosts plus Operating; explicit awaited drain or explicit cancellation on error; no new authority/policy/evaluator/launcher; unchanged Stage 1/2 reset denial and Local Data Repair; no real data or native process operation; no new architecture exemptions; no unowned async side effects; and no unsupported OS/runtime claims.

Mandatory STOP on: safe source tests requiring more files, missing/controller quiescence defect outside allowlist, escaped exception after proposed guard, failing architecture/analyzer gates, activated production selector, mutation-capability use, native/app launch, data access, unapproved cleanup, or evidence inconsistent with the established ownership contract. On STOP, preserve unstaged work and a factual response; do not create a success source checkpoint.

### 7. Checkpoints and Response 128

On PASS, stage and commit **only** the exact authorized handwritten source/test/architecture files as one implementation commit, push normally, and then separately checkpoint exact Prompt/Response 128 documentation. If prerequisite Prompt/Response 127 remain untracked, checkpoint them separately *before* implementation. No unrelated stage, reset, amend, force push, checkout or history rewrite.

Response 128 must report verified baseline and source/docs commit hashes, exact changed paths, pre-edit characterization (including expected failures), all seven listener outcomes and host census, successful/failing/pending drain behavior, ownership/disposal, tests/analyzer/architecture/format results and exclusions, SHA preservation, Project Conformance verdict, and literal remaining unknowns: normal versus required OS exit, actual process death, archive-lock release, one-shot launcher packaging/identity, LaunchServices, new native/Dart admission, FDA/signed-runtime continuity and in-place data continuity.

End with literal flags:

- `SPECIALIST EXIT FAILURE-TO-CANCEL QUALIFIED: YES/NO`
- `OPERATING EXIT FAILURE-TO-CANCEL QUALIFIED: YES/NO`
- `SIX SPECIALIST + ONE OPERATING HOSTS PRESERVED: YES/NO`
- `COORDINATOR-TO-COORDINATOR HANDOFF INTRODUCED: NO`
- `REAL PRODUCTION FRESH-LAUNCH IMPLEMENTED: NO`
- `STAGE 1/2 RESET DENIAL UNCHANGED: YES/NO`
- `SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES/NO`
- `PRODUCTION APPCZAR ACTIVATION: OFF`
- `PROJECT CONFORMANCE: PASS/FAIL`
- `READY FOR SEPARATE PROMPT 129: YES/NO`

**STOP.** Do not integrate the C/Python probe into Runner, package a production helper, alter the process restarter, execute native/app shutdown or fresh launch, enable production, or reopen populated reconstruction/FTS under this prompt.
