# MessageLens — Feature 34
## Prompt 129 — Checkpoint Stopped Exit-Listener Qualification and Qualify Onboarding Settings Drain

**Task type:** One narrowly scoped production lifecycle correction, characterization first. **This is NOT a resumption of Prompt 128's five-listener exception-to-cancel implementation.**

### 0. Governing decision, safety, and Fair Witness

Response 128 STOPPED correctly before implementation. Its source inspection found a concrete Onboarding owner gap: `AppCzarOnboardingController.openSystemSettings()` admits and awaits `realFdaSettingsOpeningAuthorityProvider.openSettings()` without retaining its future as part of `stopAndDrain()`. In the ordinary `sourceNeedsHuman` state, `_activeRun` may already be null; the existing `stopAndDrain(restart: false)` can then return while an admitted Settings-open request is still pending. The Onboarding exit listener takes that result as exit permission. The Settings error path can also publish after admission is sealed. **A catch in the exit listener does not fix a successful but incomplete drain.**

The objective is exactly this: **Onboarding must retain and settle every admitted Settings-opening operation before reporting successful drainage, and must not publish late results/errors or admit further Settings work after sealing.** A Settings-open future's completion proves only that the OS navigation request settled; it does not prove that Full Disk Access was granted or that a Settings window closed. Preserve UNKNOWN as UNKNOWN.

The already-qualified Stage 1/2 reset denial, all seven jurisdictions, six specialist hosts plus the distinct Operating host, source/provenance preservation, protected overlays/Presence, attachment archive, and the unconditionally disabled production AppCzar activation are immutable constraints.

**Absolute prohibitions:** no real System Settings launch, real FDA/TCC/bookmark, Messages/Contacts, actual MessageLens database or archive root, WD/Toshiba drive access, native process restart or quit, mutation Ball/tenure, real graph build/import, destructive Start Fresh, release/signing work, and no FTS or populated reconstruction witness. Tests must replace Settings, source, graph-build, assessment, restarter, and any other executable external dependency with inert fakes **before** the selected Onboarding controller/harness is built. No coordinator-to-coordinator transfer of responsibility.

Source inspection, synthetic executable qualification, and actual OS/runtime behavior are separate levels of evidence. If a separate unsafe owner gap, a needed extra production file, or an unsimulatable external dependency is discovered, **STOP** rather than broadening this patch.

### 1. Verify baseline; checkpoint only the stopped documents

1. Examine `git status --short`, actual branch/HEAD/upstream relation, index, the four worktrees, shared-instructions submodule, and a tracked/untracked SHA-256 manifest. Expected from Response 128: `fix/onboarding-import-stuck-state`, HEAD `12462fdbea09c64dfe45d262f3b1c487a93fcda4`, upstream `0/0`, clean tracked state, submodule `95326f515ef4719f155ce6e223990398daad6311`. **Verify, do not assume.** Preserve the navigation README, 218 restored documents, three `_ARCHIVED` scripts, and every unrelated untracked item. Do not clean, stash, reset, rebase, force-push, sweep-stage, or alter other worktrees.
2. Find the **exact** Prompt 128 and Response 128 under Feature 34 `01-ONBOARDING/prompts/` and `responses/`. They were intentionally untracked after STOP. If complete and byte-consistent, stage **only that pair**, `git diff --cached --check`, commit as a separate STOP documentation checkpoint and push normally. If already checkpointed, verify ancestry and do not duplicate. If altered or ambiguous, STOP.
3. Confirm the qualified exit-observer probe `c5d727a9c21aaced5fe000ae8bae0f8d096df6d2`, Stage 1 `e21334de96c2ab1484acbb8f3378ccad2cc49972`, Stage 2 `daac3e6b54812c98d56dba7eb3ea8fb8f8296798`, Data Update `a90612830fac05d79fff5d6097c2b0d35dd23b6e`, and Source Access `5eb7e58b4e24589114d18bac1bf6aef0bba4ab5a` remain in ancestry. Do not rerun or change the probe.
4. Read the current Onboarding controller, its existing tests, its exit-host branch and test, its Settings-opening port/adapter and safe-empty prerequisite scheduling, and the canonical Feature 34 Project Conformance standard. Capture exact source hashes and the actual method signatures before modifying any code. This is an owner correction, not a generalized shutdown design.

### 2. Exact implementation allowlist

**Only these three existing handwritten files may change:**

- `lib/essentials/app_czar_onboarding/application/app_czar_onboarding_controller.dart`
- `test/essentials/app_czar_onboarding/application/app_czar_onboarding_controller_test.dart`
- `test/essentials/app_czar/presentation/app_czar_startup_harness_test.dart`

**Only if normal generation actually changes it:**

- `lib/essentials/app_czar_onboarding/application/app_czar_onboarding_controller.g.dart` (generated automatically; never hand-edit).

**Documentation only:** exact Prompt/Response 128 prerequisite checkpoint and exact Prompt/Response 129 separate completion checkpoint under existing Feature 34 `01-ONBOARDING/`. No new helper, dependency, schema, generated output outside the named companion, architecture-test edit, application exit host edit, AppCzar model/jurisdiction edit, native Runner edit, or other production source edit. The existing Onboarding exit host is **reuse-only** and must be exercised as-is by the test.

In particular, do **not** implement the five listener catch-to-cancel changes originally proposed in Prompt 128 here. That is a later separate task after this owner can truthfully drain.

### 3. Reproduce the gap before editing production code

Add deterministic **inert** characterization to the two permitted test files, then run the focused selection on the unchanged Onboarding controller. Establish the real source preconditions, not a fabricated impossible state:

1. Construct an admitted selected Onboarding occurrence with synthetic source-denied/unavailable evidence leading to its ordinary waiting-for-human (`sourceNeedsHuman`) state; establish that the prerequisite `_activeRun` has settled. Override the Settings-opening port with a `Completer<void>` that records invocations and remains pending. Do not open System Settings.
2. Invoke the real controller's `openSystemSettings()` while allowed and keep that returned future pending. Invoke `stopAndDrain(restart: false)` in a separate future. **Required future property:** no completed drain/exit permission until the Settings port actually settles. Against the current source, record the expected-red premature completion or equivalent trace. Preserve accurate exit status, test output and source hashes.
3. Characterize the currently possible late-error publication after `stopAndDrain()` seals the occurrence; label it source-observed unless actually exercised.
4. Confirm the Onboarding host calls this selected notifier's `stopAndDrain` and returns exit permission on success. Use the existing harness test seam with all automatic source/build/native dependencies inert; if safely mounting the actual host is impossible within the allowlist, STOP and report precisely why instead of doing a text-only fake and claiming runtime qualification.

If this baseline unexpectedly proves that the Settings operation is already included in the drain, STOP instead of patching redundant machinery. Do not treat the expected-red tests as a conformance PASS.

### 4. Minimal Onboarding owner correction

Implement only source-grounded changes in the existing Onboarding controller:

1. **Retain every admitted Settings flight.** Register each Settings-open future as owned work before any asynchronous interleaving can allow an exit/stop request. Preserve the existing public Settings action and its status/eligibility semantics. If the current controller already coalesces duplicates, keep that policy and prove only one port invocation; if it admits multiple actions, retain **all** of them, not just the latest. No unbounded new scheduling mechanism or general-purpose lifecycle manager.
2. **Synchronous seal:** `stopAndDrain` must close admission and advance its generation/epoch before the first `await`. Once sealed, no further Settings action, prerequisite/build work, restart, or success/error publication may be initiated by that occurrence. Observe existing `restart` argument and callers; preserve its previously qualified semantics. Do not weaken the existing `_activeRun` drain or introduce a self-await path.
3. **Actual settlement:** drain the existing prerequisite/build `_activeRun` **and every admitted Settings flight**, waiting for all owned futures to settle before returning success. A failed Settings flight must never be silently counted as successful quiescence. Select the smallest source-consistent failure policy; preserve any already-handled pre-seal error semantics, but during a sealing/draining overlap, propagate a bounded failure/refusal to the exit host. If several owned flights exist and one fails early, still settle all the others before reporting failure—never allow an early error to mask a still-live action.
4. **Late callbacks:** after each awaited Settings result or error, validate the captured occurrence/generation/admission before publishing any UI state, failure, restart request or side effect. If sealed or replaced, suppress stale publication while preserving truthful drain/failure evidence. Do not broadly change `_publish` or all other controller flows unless that exact change is unavoidable; if it is, STOP for scope review.
5. **Owner lifecycle:** repeated/concurrent stop calls share the same sealed occurrence's settlement, without double-starting or ignoring Settings operations. Disposal invalidates publication and new admission, but **does not itself certify awaited resource settlement**. Do not use a timeout or completed UI state as a substitute for a settled Future.
6. **Permission semantics:** completion of `openSettings()` is merely completed Settings navigation. A denied/unavailable/UNKNOWN source remains so until a separately qualified fresh check or new process assessment. No assumption of FDA grant, automatic permission repair, in-process jurisdiction transition or successful process exit.
7. **Preserve existing flows:** safe-empty Onboarding, graph-build ordering, selected-generation scheduling, previously qualified stop/restart paths, and the original separation from Data Update, Source Access Repair, Local Data Repair and other jurisdictions remain unchanged. No mutation API or new authority is introduced.

### 5. Mandatory adversarial qualification (inert only)

Use causal `Completer` barriers, fake ports and provider overrides. No wall-clock sleeps, real OS calls or new test helper file. Include:

- Settings admitted while `_activeRun` is settled: drain remains pending until Settings settles, then succeeds only after settlement.
- Host's actual cancelable-exit callback: pending Settings prevents `AppExitResponse.exit`; after completion, exit permission is possible only if all other owned work is also settled.
- Settings future completes with an error while draining: no premature success, truthful error/refusal through the existing host behavior. Do not add a catch in the host in this prompt; verify that an unhandled host exception is **not** misreported as exit permission, and record its remaining fail-closed exception deficiency for the later Prompt 128 continuation.
- All admissible concurrent/duplicate Settings requests: either exact existing one-flight policy with one port invocation, or every independently admitted flight must settle. Failure of one cannot release drain while another remains pending.
- Overlap of admitted prerequisite/build run and Settings work **if the actual state machine permits it**; otherwise prove/explain the exclusivity from current source and test only reachable cases.
- Stop before Settings admission, stop during pending Settings, two concurrent stop calls, disposal/assessment replacement, a late successful completion and a late thrown error: no new port read and no stale state/UI/error publication after sealing.
- Existing source-denied/unavailable/UNKNOWN semantics, human permission guidance, ordinary explicit Settings action and safe-empty build admission remain intact.
- The Onboarding host's selected-controller capture, listener disposal and other specialist/Operating host architecture are unchanged. No phantom exit permission from `Future.timeout` or fake process completion.
- All synthetic Completers are eventually settled in test cleanup, with listeners and provider containers disposed. Never infer provider disposal awaited pending work.

If one of these reveals an **independent** lifecycle owner defect requiring another production file, STOP with the concrete reproducer and a proposed separate correction. Do not widen this patch into listener or native-restart work.

### 6. Validation and canonical conformance

Run and report attributable exit statuses and counts for:

1. Focused Onboarding controller + existing startup-harness tests, showing red-before/green-after where applicable.
2. Safe Onboarding controller/build/presentation regressions and existing specialist exit-listener/Operating presentation tests **screened** so real graph mutation tenure, OS Settings, app launch, archive access or destructive operation tests are not executed under this task.
3. Complete `test/architecture` suite (source/AST suites appropriately screened) and any directly related controller/admission architecture gate; do not weaken test expectations or add an exemption.
4. `flutter analyze --no-pub`, targeted `dart format --output=none --set-exit-if-changed` for the exact handwritten files, normal filtered generated consistency if required, `git diff --check` and `git diff --cached --check`.
5. Exact baseline hash comparison, staged-file allowlist, root submodule/other-worktree preservation and upstream synchronization.

If SDK sandbox/cache access prevents a command, mark it **unverified**, rerun with the already approved environment as appropriate, and never claim an interrupted or denied command as PASS. Full application suite is unnecessary unless the governing conformance standard or a concrete failure requires it.

Audit against `MESSAGELENS-PROJECT-CONFORMANCE-AUDIT-STANDARD.md`. PASS requires zero in-scope BLOCKER and SHOULD FIX, exact ownership of all admitted Settings work, truthful successful/failed drain, no stale publication, safe cleanup, no new AppCzar policy/jurisdiction, no protected data access, no new mutation capability, and only the allowed files changed. **If a required gate fails, do not commit a success implementation checkpoint.** Preserve the stopped delta and write a factual STOP response.

### 7. Exact checkpoints and Response 129

On qualification PASS, commit/push **only** the allowed source/tests/conditional generated output as one implementation checkpoint. Then commit/push **only** exact Prompt 129 and Response 129 as a separate documentation checkpoint. Do not write a self-referential documentation commit hash inside its own response; report it in Codex's handoff after creation. No unrelated staging, restoration, release activation, or migration.

Response 129 must record: actual recovered baseline, prerequisite Prompt/Response 128 STOP checkpoint, source and test hashes, red characterization, precise Settings-flight ownership and multi-flight rules, synchronous sealing, post-await state suppression, failure/drain settlement, harness exit callback behaviour, actual test counts/exit codes/screened exclusions, architecture/analyzer results, conformance verdict, implementation/docs checkpoint IDs, and remaining native/runtime unknowns. Explain whether host exceptions remain unqualified and why a new Prompt 130 must separately resume fail-closed listener handling.

End with literal flags:

- `ONBOARDING ADMITTED SETTINGS FLIGHTS RETAINED: YES/NO`
- `ONBOARDING STOP-AND-DRAIN INCLUDES SETTINGS: PASS/FAIL`
- `PENDING SETTINGS PREVENTS EXIT PERMISSION: PASS/FAIL`
- `LATE SETTINGS PUBLICATION SUPPRESSED: PASS/FAIL`
- `PROMPT 128 FIVE-LISTENER ERROR-TO-CANCEL WORK RESUMED: NO`
- `SIX SPECIALIST AND ONE OPERATING HOSTS UNCHANGED: YES/NO`
- `STAGE 1/2 RESET DENIAL UNCHANGED: YES/NO`
- `PRODUCTION APPCZAR ACTIVATION: OFF`
- `PROJECT CONFORMANCE: PASS/FAIL`
- `READY FOR NEW SEPARATE PROMPT 130: YES/NO`

**STOP after this one owner correction.** No production fresh launcher, native relaunch, app exit, FDA changes, actual data operations, five-listener implementation, or populated reconstruction work is authorized.
