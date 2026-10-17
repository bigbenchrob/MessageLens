# MessageLens — Feature 34
## Prompt 134 — Checkpoint Local Data Repair Drain and Qualify Four Remaining Fail-Closed Exit Listeners

**Task type:** Characterization-first, finite exit-listener implementation and qualification. **Not:** coordinator redesign, actual application termination, fresh-launch/launcher integration, production activation, populated reconstruction, or a new jurisdiction.

### 0. Governing decision and Fair Witness

Response 133 qualified the Local Data Repair controller's ordinary stop/restart ownership at implementation checkpoint `891ae8483a8a463e895cf656924226268d758b0b`. Its actual harness exit callback **still propagates** the controller's `StateError` rather than returning `AppExitResponse.cancel`. The earlier Response 132 STOP also identified missing fail-closed exception handling for Diagnostic Review, Attachment Archive Repair and the independent Operating Session listener. Onboarding, Data Update and Source Access Repair already have their own qualified catch-to-cancel hosts; they must remain unchanged.

**Goal:** In exactly the existing owners' exit-listener code and tests, qualify that all four outstanding listeners translate *synchronous and asynchronous* drainage failures into `AppExitResponse.cancel` rather than leaking an exception, and that `AppExitResponse.exit` is returned **only after an actually successful owned drain**. Retain the source-grounded truth that a refusal is not settlement; do not swallow it and then exit. Preserve the six specialist listeners, the one separate Operating listener, seven AppCzar jurisdictions, and Stage 1/2 reset-denial contracts.

**No coordinator-to-coordinator handoff.** The lifecycle remains **coordinator completion → process exit → fresh launch → independent AppCzar reassessment**. These listener results are only *permission or refusal to exit*: they do not prove old-process death, lock release, a new PID, signed identity, FDA continuity or fresh archive admission.

**Absolute prohibitions:** Do not open any real Messages/Contacts/MessageLens database, overlay, Presence, admitted production/development root, WD/Toshiba attachment archive or payload; do not operate FDA/TCC/bookmarks, start/quit MessageLens, acquire a Ball, tenure, capability or writable lease, invoke a real graph/archive/repair executor, run the OS exit probe, perform a native launch, or enable production AppCzar. Keep all fake readers, workers, settings ports, restarters and controllers inert. Do not resume FTS or populated reconstruction work.

**Fair Witness:** Label actual source facts, executed test results, and remaining unqualified behavior separately. STOP rather than manufacture a passing test, invent completion, or describe caught errors as evidence of clean drainage.

### 1. Recover Git, records and scope before editing

1. Inspect branch, HEAD, upstream ahead/behind, tracked tree/index, all four registered worktrees, and shared-instructions submodule. Expect `fix/onboarding-import-stuck-state` and clean submodule `95326f515ef4719f155ce6e223990398daad6311`, but **verify rather than assume**. Record a path-and-SHA-256 manifest for tracked and all pre-existing untracked files. Preserve navigation README, restored historical documents, three `_ARCHIVED` scripts and every unrelated file. No `git clean`, stash, hard reset, broad staging, rebase, force push, branch switch or unrelated changes.
2. Verify Stage 1 (`e21334de96c2ab1484acbb8f3378ccad2cc49972`), Stage 2 (`daac3e6b54812c98d56dba7eb3ea8fb8f8296798`), Data Update (`a90612830fac05d79fff5d6097c2b0d35dd23b6e`), Source Access (`5eb7e58b4e24589114d18bac1bf6aef0bba4ab5a`), Onboarding (`8e10bd58537f5fa2f409b3c69e16a805be8b12b2`), Local Data Repair (`891ae8483a8a463e895cf656924226268d758b0b`) and the disposable observer (`c5d727a9c21aaced5fe000ae8bae0f8d096df6d2`) in ancestry. Verify no reset/activation change; record exact hashes of the qualification-critical files if available.
3. Locate the exact complete Prompt 133 and Response 133 under Feature 34 `01-ONBOARDING/prompts` and `responses`. If those two documents are untracked, complete and unchanged, checkpoint **only** that exact pair in a separate docs-only commit and push normally before implementation; if already tracked, verify and do not duplicate. STOP on unexpected divergence. Preserve all other untracked material.
4. Inspect the actual four listener implementations, the actual Diagnostic/Local Repair/Attachment Repair/Operating drain owners, and the existing architecture/test conventions. Read the canonical Feature 34 `00-PREPARATION/MESSAGELENS-PROJECT-CONFORMANCE-AUDIT-STANDARD.md`, Response 132's STOP and Response 133's corrected owner contract. Do not rely on presumed paths, state types or exceptions where current code differs.

### 2. Exact production/test allowlist

Only these existing handwritten paths may change, subject to verifying the actual repo structure:

- `lib/essentials/app_czar/presentation/app_czar_startup_harness.dart` — only the Diagnostic Review, Local Data Repair and Attachment Archive Repair exit-host error handling; **do not alter** Data Update, Source Access Repair or Onboarding hosts, selection, routing or their existing listeners.
- `lib/essentials/app_czar_operating_session/presentation/app_czar_operating_session_app.dart` — only the Operating exit-listener/drain-callback error-to-cancel boundary; no currentness controller or router redesign.
- `test/essentials/app_czar/presentation/app_czar_startup_harness_test.dart` — retain existing real Local Repair pending-restart test and add bounded real-host tests for the three specialist listeners.
- `test/essentials/app_czar_operating_session/presentation/app_czar_operating_session_app_test.dart` — real registered Operating callback with inert exact-occurrence drain.
- `test/architecture/app_czar_architecture_test.dart` — **only if an existing host census / source tripwire needs to reflect or positively enforce this specific fail-closed behavior**. Do not change listener counts or weaken other assertions.

No other handwritten, generated, provider, model, coordinator/controller, mutation, native Runner, Flutter SDK, dependency, config, schema/migration, signing or release file may change. Do not introduce a helper, generic exit framework, new provider or extra listener. No generator run is expected. Exact Prompt/Response 134 documentation is permitted in the existing Feature 34 numbered directories, **separately** from the implementation checkpoint.

If the actual correction needs a controller change, additional file, or unexpected generated output, **STOP** and report the minimal amended scope rather than editing it silently.

### 3. Owner-quiescence prerequisite: inspect, characterize, STOP on false success

Before changing production host code, establish the present truth of each owner and its current exit route. At minimum:

- **Local Data Repair:** Reuse the real controller and the preserved Response 132/133 expected-red/qualified test. Trigger the legitimate failed-state manual retry through an inert restarter held pending. Verify ordinary `stopAndDrain()` now refuses with the actual `StateError` while restart remains active and later succeeds after settlement. The current host must be shown to propagate this refusal before editing. Do not reintroduce a real repair executor or change the safe-partial-data predicate.
- **Diagnostic Review:** Identify its `_activeLifecycleAction`, restart/reassessment and quit paths. Prove that a successful owned drain cannot bypass any already-admitted action. Use inert restarter/clock and a reachable real owner state; include reentrant/pending lifecycle action reasoning. If a successful drain can conceal admitted work, STOP before host implementation.
- **Attachment Archive Repair:** Identify the controller active run and executor drain, restart/stale paths and retained futures. Establish that a successful drain covers already-admitted work and does not recursively await its own restart. Never call real preservation. If a success can conceal an active admitted operation, STOP.
- **Operating Session:** Examine exact occurrence selection/currentness `stopAndDrain` and the separate listener. Prove with inert owner/controller seams that a successful drain corresponds to settlement of that occurrence's active flight and no competing ambient monitor. If admission/flight ownership cannot be qualified without a real worker or a new seam, STOP rather than replacing it with a fake owner that proves nothing.

A source-inspected contract is not an executed host test. Distinguish the two. The four target listeners currently lack explicit error-to-cancel handling, but do not assume a catch is sufficient before checking ownership.

**Do not make this another broad audit.** Stop only on a concrete independently relevant owner-quiescence counterexample or an impossible safe test seam; otherwise proceed immediately to the narrowly allowed listener changes.

### 4. Characterization-first RED evidence

Add minimal controlled tests in the two allowed test files **before production changes**. The registered listener must be exercised using the actual Flutter lifecycle callback (`tester.binding.handleRequestAppExit()` or the verified equivalent), not merely invoking a copied closure or a fake exit listener. Use provider overrides and fixed synthetic assessments **before** a selected controller is constructed; no default process, database, mutation, archive or Settings path may be resolved.

For Diagnostic Review, Local Data Repair, Attachment Archive Repair and Operating, characterize where safely feasible:

1. **Pending real owner drain:** hold the relevant injected work future; the host must not return exit while owned work is unsettled. Release it deterministically and show response after settlement.
2. **Successful drain:** exactly one registered callback per host, `AppExitResponse.exit` only after settlement; no extra listener, provider reconstruction or unexpected worker/poller.
3. **Synchronous and asynchronous failures/refusals:** drain throws immediately and after an awaited barrier; require `AppExitResponse.cancel`, **no escaping exception**, with the same exact owner selected. For Local Repair, the real pending-restart `StateError` is mandatory, not a substitute synthetic throw.
4. **Disposal/listener removal, repeated exit requests and stale selection:** no newly constructed coordinator, no duplicate registration, no conversion of a stopped or stale occurrence into permission. When host not mounted, no phantom callback persists.
5. **Truthful UNKNOWN:** an unresolved future remains unresolved. Do not use `Future.timeout`, `pumpAndSettle` exhaustion, container disposal or a fake restarter result as evidence of quiescence/new PID.

Preserve the historical Response 132 red case, adding only clearly named tests where needed. Capture attributable baseline exits. If a test cannot produce a safe real-owner/registered-host reproduction under this scope, label that case unqualified and determine whether it is mandatory; STOP for an essential unsupported case rather than claiming a fake is real owner evidence.

### 5. Minimal fail-closed exit-listener correction

Only after owner prerequisites and baseline characterization:

- At the three target branches in `app_czar_startup_harness.dart`, await the **already selected** notifier's actual `stopAndDrain` using the existing host ownership/lifecycle pattern. On **any synchronous or asynchronous drain throw**, return `AppExitResponse.cancel`. On successful awaited drain, return `AppExitResponse.exit`. Preserve exact callback registration and removal.
- For `app_czar_operating_session_app.dart`, apply the same fail-closed handling to the already owned exact-currentness occurrence drain. Do not create a second assessment, retry, session/controller or process-level exit owner.
- Catch only at the exit-permission boundary, not by swallowing errors in controllers. Do not reinterpret an active restart refusal as settled. Do not report a successful exit if a worker is still pending. No native force-terminate, app launch or catch-and-continue into a different coordinator.
- Keep the other three specialist listeners (Data Update, Source Access Repair and Onboarding) byte-identical in their functional behavior and test their existing catch-to-cancel protections as regressions. Keep six specialist listeners plus one separate Operating listener; no eighth jurisdiction.

If adding an exit catch changes how Flutter's observer resolves a genuine cancellation, characterize the actual SDK/test binding and adjust **only within the allowed listener and test files**. Never alter the SDK or introduce a general exception interceptor.

### 6. Mandatory qualification matrix and validation

Run the actual command selections with attributable exit codes. At minimum:

- Focused startup-harness and Operating Session app tests, with named RED-to-GREEN assertions for all four target listeners, including the Local Repair active-restart refusal case.
- Screened controller/host regressions for Diagnostic Review, Attachment Archive Repair, Local Data Repair, Data Update, Source Access Repair, Onboarding and Operating currentness/presentation; **exclude cases that acquire real mutation tenure or execute live archive/source operations**. Name all screened exclusions explicitly.
- Full `flutter test --no-pub test/architecture --reporter expanded` if the source-inspection suite is safe as previously qualified; existing listener census must remain six specialist/one Operating. Do not add broad exceptions, import exemptions or suppressions.
- Full `flutter analyze --no-pub`, targeted `dart format --output=none --set-exit-if-changed`, `git diff --check` (working/staged), exact generated/dependency comparison (no generation expected), SHA-256 manifest/allowlist checks and source identity/activation invariants.
- Include causal tests for pending futures; explicitly release owned fake operations and dispose all listeners/containers. No wall-clock sleeps or claimed native cancellation.

The complete unrelated Flutter suite is not necessary without a concrete failure or a governing standard requirement. Treat denied SDK-cache/tool invocations and interrupted processes as **unverified**, not PASS.

Canonical Project Conformance **PASS** requires `BLOCKER: 0`, `SHOULD FIX: 0` for this exact host scope: real owner work settlement before successful exit, no leaked exceptions, zero unauthorized mutation, no second evaluator or new host, exact edits, bounded fixtures, no user-data exposure, analyzer/architecture/test passes and preserved Stage 1/2 reset denial.

If any mandatory test fails, STOP, preserve the failed test and leave the implementation uncommitted. Never weaken the failing expected behavior to obtain PASS.

### 7. Checkpoints and Response 134

When all mandatory gates pass:

1. Stage **only** the allowed implementation/test files actually changed; inspect staged diff, whitespace and hashes. Commit a single bounded implementation checkpoint, e.g. `fix(app-czar): fail closed on remaining exit listener errors`; push normally.
2. Stage **only** exact Prompt 134 and Response 134 as a separate documentation checkpoint; push normally. Do not invent a document's own commit hash inside itself—report the actual hash in the final handoff.
3. Verify clean tracked/index, upstream 0/0, submodule and all other worktrees unchanged, all unrelated untracked bytes preserved. Never rewrite the historical Prompt 128/132 STOP records or earlier qualified responses.

**Response 134 must report** verified Git baseline/commits; per-owner prerequisite outcome; real registered callback red/green evidence, especially Local Data Repair; success/pending/failure/exception disposal cases; exact tests with counts and exit codes; remaining runtime/OS unknowns; touched-file list; canonical conformance findings and literal status flags:

- `DIAGNOSTIC EXIT ERROR-TO-CANCEL QUALIFIED: YES/NO`
- `LOCAL DATA REPAIR EXIT ERROR-TO-CANCEL QUALIFIED: YES/NO`
- `ATTACHMENT ARCHIVE REPAIR EXIT ERROR-TO-CANCEL QUALIFIED: YES/NO`
- `OPERATING EXIT ERROR-TO-CANCEL QUALIFIED: YES/NO`
- `ALL SIX SPECIALIST EXIT LISTENERS FAIL CLOSED: YES/NO`
- `OPERATING EXIT LISTENER FAILS CLOSED: YES/NO`
- `STAGE 1/2 RESET DENIAL UNCHANGED: YES/NO`
- `SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES/NO`
- `REAL PRODUCTION FRESH LAUNCH IMPLEMENTED: NO`
- `PRODUCTION APPCZAR ACTIVATION: OFF`
- `PROJECT CONFORMANCE: PASS/FAIL`
- `READY FOR A SEPARATE PROMPT 135: YES/NO`

**STOP after this milestone.** Do not implement the production process launcher, sign/launch MessageLens, change archive-lock descriptors, alter OS privileges, run actual work or approve AppCzar cutover. Subsequent milestones may separately qualify ordinary termination/fresh launch and in-place data continuity, but no work is authorized here.
