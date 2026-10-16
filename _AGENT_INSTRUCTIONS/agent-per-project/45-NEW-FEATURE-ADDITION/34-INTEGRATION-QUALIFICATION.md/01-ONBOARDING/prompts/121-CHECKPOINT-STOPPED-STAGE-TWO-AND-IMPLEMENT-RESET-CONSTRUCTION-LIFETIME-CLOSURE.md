# MessageLens — Feature 34
## Prompt 121 — Checkpoint Stopped Stage 2 and Implement Command/Construction/Lifetime Reset Denial

**Task:** Execute the already-designed Stage 2 of composition-bound reset denial, correcting the **test feasibility conflict** identified in Response 120. Characterization first; exact finite scope; fail closed. **No production AppCzar activation, real reset, real authority tenure, app launch, real databases, or populated-reconstruction work.**

### 0. Controlling facts and resolution of the STOP

Response 119 qualified Stage 1: `ArchiveResetAdmission` binds an explicit root-selected startup composition to a revocable lifetime; both `ArchiveMutationOperation.startFresh` and `.messageDataReset` are denied at the coordinator's shared pre-tenure entry unless there is an explicitly selected, live `startupApp` binding. Other operations, notably `localDataRepair`, bypass this new veto and retain their previous safety requirements. Implementation checkpoint: `e21334de96c2ab1484acbb8f3378ccad2cc49972`.

Response 120 STOPPED *before editing* because the original Prompt 120 demanded direct executable method-entry qualification of `resetDerivedDataForStartFresh(ArchiveMutationCapability)` and `resetActiveDerivedDataForLocalDataRepair(ArchiveMutationCapability)` without allowing a genuine capability. The capability is final, privately constructed only after admission/tenure; Stage 1's inert helper deliberately cannot mint or expose it. No unapproved nullable/dynamic forgery, private-constructor change, new test-access capability seam, or real Ball/tenure may be introduced.

**Explicitly resolved qualification contract for this prompt:**

- **MUST execute** safe tests of real dispatcher, action and provider entry, plain `StartFreshService` entry, retained/cached lifetime and suspended continuation, and the parameterless/general-reset entry `resetDerivedData()` where it is safely callable using inert dependency substitutions. Validate their actual typed denial, dependency counters and non-publication without real authority acquisition.
- **MUST inspect and assert source-level guard dominance** for capability-taking `resetDerivedDataForStartFresh(capability)` and `resetActiveDerivedDataForLocalDataRepair(capability)`. Their direct real-method invocation is expressly **NOT required or authorized**. Assertions must examine production source/AST or another robust source-grounded ordering check, not a copied policy test. Preserve the exact private, final, non-nullable capability API and classify direct runtime invocation as **UNKNOWN / not exercised**. Do not count source-order checks as executable runtime coverage.
- For `localDataRepair`, run the existing **capability-free safety/model and executor-wiring** tests that do not create tenure, supplemented by source/hash review of its capability-taking reset route. A throwing/missing `archiveResetAdmissionProvider` must **not become a new constructor-level dependency** of local repair. Do not assert that the real capability-taking local repair method was executed.
- The lower pre-tenure Stage 1 real-front-door denial already qualified by Response 119 remains a required unchanged regression. Do not repeat a real admitted, allowed reset to prove it.

If any of these safe tests cannot be carried out using the authorized files and inert dependencies, STOP with the exact missing seam. Do not broaden the access contract or disguise a mock as the real method.

### 1. Verify baseline and checkpoint Response 120

1. Inspect actual branch, HEAD, upstream, tracked/index status, all registered worktrees, shared instructions submodule, and complete tracked/untracked manifests with SHA-256. Expected only as an item to verify: `fix/onboarding-import-stuck-state`, HEAD `2c95f9a20bf162a67b2827ab04aab49054263a77`, upstream 0/0, submodule `95326f515ef4719f155ce6e223990398daad6311`; exactly one worktree on the branch. Preserve the other three worktrees, all unrelated untracked files, the restored documentation, `01-ONBOARDING/README.md`, and archived scripts. Never use git clean, stash, reset, squash, rebase or force push.
2. Verify the exact Prompt 120 and Response 120 are present, complete and untracked/otherwise appropriately checkpointed. If untracked, stage **only the exact pair** in Feature 34's `01-ONBOARDING/prompts/` and `responses/`, diff/whitespace review, commit documentation alone, and push normally. If already committed, verify ancestry; do not duplicate. If unexpectedly modified, STOP. Response 120 was a STOP, not an implementation success.
3. Read current canonical conformance standard, `AGENTS.md`, shared instructions, Responses 116–120 (especially 118's Stage 2 exact allowlist), and current Stage 1 source/tests. Capture initial hashes and document any differences from the purported baseline before editing.
4. Confirm official-production AppCzar activation is still hard-disabled and no already-implemented equivalent Stage 2 denial exists. Do not modify selector or native archive admission.

### 2. Exact implementation allowlist

**Only these six existing handwritten production files** may change:

1. `lib/essentials/sidebar/application/sidebar_action_dispatcher.dart`
2. `lib/essentials/onboarding/application/advanced_start_fresh_action_provider.dart`
3. `lib/essentials/onboarding/application/advanced_start_fresh_action.dart`
4. `lib/essentials/onboarding/application/start_fresh_service_provider.dart`
5. `lib/essentials/onboarding/application/start_fresh_service.dart`
6. `lib/essentials/onboarding/application/message_data_reset_service.dart`

**Generated outputs:** only their existing corresponding `.g.dart` files, and only if the normal generator changes them. Never hand-edit generated files. STOP for any other generated churn, dependency or configuration changes.

**Test allowlist, following Response 118:**

- `test/essentials/app_czar/application/non_destructive_operating_composition_characterization_test.dart`
- `test/essentials/sidebar/application/sidebar_action_dispatcher_test.dart`
- `test/essentials/onboarding/application/advanced_start_fresh_action_provider_test.dart`
- `test/essentials/onboarding/application/advanced_start_fresh_action_test.dart`
- `test/essentials/onboarding/application/start_fresh_service_test.dart`
- **NEW** `test/essentials/onboarding/application/reset_construction_lifetime_denial_test.dart`
- `test/architecture/onboarding_start_fresh_architecture_test.dart`
- `test/architecture/app_czar_architecture_test.dart`
- `test/architecture/forbidden_imports_test.dart`

Existing Stage 1 source and support/architecture files are **read/reuse only**, never modified. Run Stage 1 tests as unchanged regressions. Do not modify the general exclusive-authority registry, capability constructor, archive admission policy, main, startup selector, Local Data Repair model/reader/executor or its physical deletion footprint.

Documentation-only: exact Prompt/Response 120 prerequisite; exact Prompt/Response 121 in existing Feature 34 `01-ONBOARDING/` prompt/response folders, separately checkpointed. No new helper files or test friend besides the one explicitly named new test.

### 3. Characterize before implementing

Establish in source and (where safe) executable inert tests the currently reachable behaviour and precise dependency order:

- Hidden Settings reset row does not prevent `ResetMessageDataRequested` from resolving the advanced action (Response 116's previously qualified unsafe finding). In the existing characterization test, retain or clearly label the historical red fact; after correction assert the selected AppCzar path becomes denied before action construction. Do not rewrite history.
- Direct action-provider access currently constructs a presentation notifier and plain action; direct Start Fresh service provider awaits operation and Presence dependencies before it could be denied by lower admission.
- Existing action instances can be retained through request/retry/dismiss, current-state/authorization/frame/service awaits and logging/presentation callbacks; existing plain Start Fresh service reads current state before lower admission.
- Shared `MessageDataResetService` is also needed for qualified `localDataRepair` and **must remain constructible** even if reset admission is unavailable. Only general-reset method paths are denied by the new contract; never disable its factory globally.
- Stage 1 denial is at the lower pre-tenure owner, not a guarantee that these higher dependencies were never constructed.

Record actual initial executable results and source facts separately. Characterization must use inert ports only: no real service construction through a destructive callback, no archive root or SQL, no real Ball/lease/tenure. If an old existing test implicitly uses actual authority, screen it out and report the exclusion; don't run it for convenience.

### 4. Implement composition-bound construction and command denial

Reuse Stage 1's `ArchiveResetAdmission` and revocable consumer binding, without creating another selection decision or policy boolean. Only explicitly live `startupApp` can proceed to the **existing** eligibility/consent/checkpoint rules; AppCzar, missing/rejected/throwing input, revoked lifetime, and stale instance must fail closed. A successful admission check is **not** permission to reset.

1. **Dispatcher**: deny `ResetMessageDataRequested` before reading `advancedStartFreshActionProvider`, irrespective of menu visibility. Use typed, nonmutating unavailable handling, with no legacy or Journey fallback. Keep unrelated typed intents unaffected.
2. **Advanced action provider**: guard before presentation notifier/other dependency construction. Bind created plain action to the original consumer epoch, register consumer closure before resolving dependencies. On denied selection, nothing stateful should be constructed.
3. **Plain action**: require binding; inspect all actual constructor call sites and update permitted tests. Check before `request`, `retry`, `dismissFailure` and before lifecycle logging, presentation mutation or input/provider callbacks. Recheck after each awaited continuation and before new effects, service read and result publication. Revocation (including legacy L1 → legacy L2 ABA) must prevent old objects from re-entering or publishing stale state. Handle typed denied outcome without converting it into a retry/failure UI transition. No unbounded polling or new owner.
4. **Start Fresh service provider**: reject before first operation/Presence read/await; register lifetime closure early, recheck after each await and before publishing the service. A previously permitted asynchronous construction may have performed earlier reads; prove none occur *after* revocation, and do not describe that as undoing past effects.
5. **Plain Start Fresh service**: require original binding; guard before `readCurrentState` and after every await before new side effects or authority request. Preserve all existing legacy entry-point validation and lower archive gate. Do not change the actual reset body or allow a fresh L2 token to revive S1.
6. **Shared message-data reset service**: preserve construction for Local Data Repair. Bind general-reset entry lazily to the root lifetime without a permissive default, ensure provider-instance revocation and no rebind after disposal. The safely callable `resetDerivedData()` must deny before lower mutation admission on AppCzar/missing/revoked states. The capability-taking Start Fresh-specific method must have a **provable first-statement / pre-side-effect guard** before its capability check or physical deletion path; guard-ordering proof only, no forged invocation. The local-repair capability-taking method must retain unchanged safety/footprint semantics and must not consult or depend upon the new general-reset lifetime. Source hashes/diff and capability-free tests must establish this limited noninterference. Preserve all existing typed capability/currentness checks.

The same root selection must govern all above boundaries; never read display-only projected evidence, menu availability, development eligibility, archive environment label, current assessment, or a mutable global fallback as reset permission. Do not add an eighth jurisdiction or a second AppCzar evaluator.

### 5. Required adversarial qualification matrix

Use deterministic inert spies, explicit provider overrides and cancellable/suspendable Futures. Capture *provider construction*, *plain object construction*, *method request*, *dependency read*, *lower admission*, *callback* and *publication* separately. Include:

- AppCzar selected, missing, rejected/throwing, revoked: dispatcher typed intent results in **zero action-provider factory/service/provider entries**, no callbacks, no mutation; same denial with hidden and visible reset rows.
- Direct action-provider, direct Start Fresh service provider and plain-object calls fail before stateful dependencies when denied; explicit live legacy continues to inert existing behaviour subject to old gates.
- `request`, `retry`, `dismissFailure` on retained old instance; suspended current-state, authorization, frame, service resolution and publication; revoke at each boundary and resume. No stale logs, presentation updates, new reads or service construction after revocation.
- Cached action/service from legacy L1 cannot become valid when a different legacy L2 container is installed; same-composition name does not imply same identity. Invalidation/disposal of one consumer does not inadvertently revoke a valid sibling binding.
- Start Fresh service provider construction paused at every permitted await: after revocation no later dependency construction and no published service. Ensure cleanup and disposer callbacks do not revive old input.
- Real safely callable general-reset method `resetDerivedData()` with inert dependencies: denied in AppCzar/missing/revoked before coordinator invocation. No Ball or service file delete.
- Capability-taking `resetDerivedDataForStartFresh` source-level ordering assertion: first effective operation is binding validity check, followed by original capability and deletion guards. No method-entry execution; label runtime UNKNOWN. Capability-taking local-repair route: source-level unchanged and capability-free safety/constructor access tests; runtime execution UNKNOWN. A throwing reset input does not block local-repair service construction or alter its model/safety/executor source.
- Existing lower denial front door and inert ordinary/reentrant branch tests for both reset operation kinds stay green. Non-reset operations (especially localDataRepair) do not read reset provider.
- Existing selected legacy startup reset and general reset entry remain potentially callable through original qualification, **without executing the actual reset**. Never interpret absence of a real reset test as qualification of legacy completion.
- Typed failure/unknown precedence, no reliance on hidden UI, exact seven jurisdictions, selector remains production-off. No thrown denial should be swallowed by a generic failure handler that mutates stale UI.

If a case cannot execute safely through an allowed interface, explicitly mark it source-level/UNKNOWN and explain; do **not** silently change a MUST-execute case to an assertion or skip it. If the inability affects a MUST-execute case other than the two expressly revised capability-taking methods, STOP.

### 6. Validation and Project Conformance

Attributable gates after implementation:

- focused new denial test and exact changed test files that use only inert fixtures;
- unchanged Stage 1 `archive_reset_admission_test.dart` and `archive_mutation_pre_tenure_admission_test.dart`;
- screened selector, dispatcher, Start Fresh, app_czar Operating, and protected-source tests without real archive tenure or SQL;
- relevant architecture suites including `onboarding_start_fresh_architecture_test.dart`, `app_czar_architecture_test.dart`, `forbidden_imports_test.dart`, `exclusive_authority_architecture_test.dart`;
- `flutter analyze --no-pub`, targeted `dart analyze` if needed; `dart format --output=none --set-exit-if-changed`; standard code generation if required;
- exact generated-path inventory, `git diff --check`, `git diff --cached --check`, pre/post SHA manifest, shared submodule/worktree/upstream preservation.

The full Flutter suite is required only if the canonical conformance standard or a concrete failure demands it. Do not count an interrupted/sandbox-denied process as success. An existing test demanding an actual Ball or destructive fixture is **not eligible** for this inert milestone; document exactly which cases were skipped and why. No silent weakening or global architecture allowlist exemption.

Conduct canonical Project Conformance audit. PASS requires no unresolved `BLOCKER` or `SHOULD FIX` within the explicitly amended Stage 2 contract. Exact selected-composition identity, non-reviving epoch/binding, early denial, safe async continuations, no new authority source, Local Data Repair preservation, nullable/private capability constraints, diagnostics privacy and cleanup must all be reviewed.

### 7. Checkpoint and final response

On all mandatory gates passing, stage and commit **only** authorized handwritten production/tests and the corresponding generated files in one implementation commit, push normally. In a second separate checkpoint, add only Prompt/Response 121 and push. Never mix documentation, untracked navigation/index/scripts or other worktrees into code checkpoint. If any mandatory gate cannot be established, STOP with a factual Response 121, no success commit, preserve exact baseline and reproducible evidence.

Response 121 must state actual Git baselines/hashes and changed-file inventory; red/green characterization; direct-dispatch/action/provider/service/general-reset test counts; cache/ABA/async revocation; the **source-only, unexecuted** evidence and remaining UNKNOWN for both capability-taking methods; Local Data Repair unchanged scope; Stage 1 regressions; architecture/analyzer/generation results; Project Conformance; all excluded real-tenure/destructive tests; and remaining independent production blockers.

End with:

`STAGE 1 PRE-TENURE DENIAL PRESERVED: YES/NO`

`STAGE 2 COMMAND/CONSTRUCTION DENIAL QUALIFIED: YES/NO`

`CACHED OBJECT REVOCATION QUALIFIED IN INERT TESTS: YES/NO`

`GENERAL RESET PARAMETERLESS METHOD DENIAL QUALIFIED: YES/NO`

`CAPABILITY-TAKING METHOD DIRECT EXECUTION: NOT AUTHORIZED / NOT RUN`

`LOCAL DATA REPAIR SAFETY SEMANTICS CHANGED: NO` (or report actual violation)

`ENUMERATED RESET REACHABILITY CLOSED IN SELECTED APPCZAR: YES/NO`, explicitly qualified to the observed/source-level scope

`PRODUCTION APPCZAR ACTIVATION: OFF`

`PROJECT CONFORMANCE: PASS/FAIL`

`READY FOR SEPARATE PRODUCTION-LIFECYCLE MILESTONE: YES/NO`

**STOP.** No production activation, signed/staged human rehearsal, migration, process restarter, live data or archive access, real reset, actual private-capability test, or populated witness under this prompt.
