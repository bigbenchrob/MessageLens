# MessageLens — Feature 34
## Prompt 120 — Checkpoint Stage 1 and implement Stage 2 command/construction/lifetime reset denial

**Scope:** Stage 2 of Response 118's explicitly reviewed two-stage design. Stage 1 (`e21334de96c2ab1484acbb8f3378ccad2cc49972`) is implemented and qualified in Response 119. **Do not enable production AppCzar, execute resets, or resume populated reconstruction/FTS work.**

### 0. Governing intent and safety

Close all enumerated higher-level paths by which `startFresh` or `messageDataReset` may be requested or constructed after AppCzar selection, missing selection, or composition lifetime revocation. Reuse **only** the Stage 1 `ArchiveResetAdmission` root lifetime, consumer bindings and typed denial. Preserve explicitly selected current `startupApp` legacy entry points with their existing confirmation/eligibility/checkpoint/authority checks. Preserve `localDataRepair` and every other operation's existing semantics unchanged. The Stage 1 lower pre-tenure denial remains in force regardless of failures higher up.

No real Messages/Contacts/MessageLens databases, source histories, overlays, Presence, archive payloads, WD/Toshiba drives, FDA/TCC, S3, native identity claims or production installed app may be opened. No real reset body, file deletion, schema migration, mutation Ball, exclusive tenure or writable lease may be acquired. Do not build, install or launch MessageLens. Only inert synthetic spies and screened tests are authorized. No new evaluator, jurisdiction, ambient global switch, display-derived authorization, legacy fallback or populated reconstruction witness.

### 1. Baseline, checkpoints and dependency contract

1. Inspect current branch/HEAD/upstream, tracked/index state, four registered worktrees, shared-instructions submodule and byte/hash inventory including all unrelated untracked material. Expected branch `fix/onboarding-import-stuck-state`; verify rather than assume; protect the restored 218 documents, navigation README and three archived scripts. No clean/stash/hard reset/rebase/squash/force push.
2. Verify source commit `e21334de96c2ab1484acbb8f3378ccad2cc49972` and Prompt/Response 119. If the exact two documents are complete and not yet checkpointed, commit/push **only** those documentation files before editing; otherwise verify the existing commit without duplication. STOP on mismatched edits or unrelated dirty changes.
3. Read governing project/architecture/database/overlay/attachment rules and canonical Feature 34 Conformance standard, Prompt/Responses 116–119, and inspect actual current source before editing. Record complete constructor/call-site census and source hashes.
4. Establish the Stage 1 facts: final selected composition root object; default unavailable; monotonic revocation; consumer binding closure; typed denial for only `startFresh` and `messageDataReset`; `run` and `runWithCapability` pre-tenure gate. Do not edit or replace these semantics.

### 2. Exact implementation allowlist

**Existing handwritten production files only:**

- `lib/essentials/sidebar/application/sidebar_action_dispatcher.dart`
- `lib/essentials/onboarding/application/advanced_start_fresh_action_provider.dart`
- `lib/essentials/onboarding/application/advanced_start_fresh_action.dart`
- `lib/essentials/onboarding/application/start_fresh_service_provider.dart`
- `lib/essentials/onboarding/application/start_fresh_service.dart`
- `lib/essentials/onboarding/application/message_data_reset_service.dart`

**Generated outputs, only if genuinely changed by normal regeneration:** `sidebar_action_dispatcher.g.dart`, `advanced_start_fresh_action_provider.g.dart`, `start_fresh_service_provider.g.dart`, and `message_data_reset_service.g.dart` beside their corresponding source files. Never hand-edit generated outputs or accept unrelated generator changes.

**Test files only:**

- `test/essentials/app_czar/application/non_destructive_operating_composition_characterization_test.dart`
- `test/essentials/sidebar/application/sidebar_action_dispatcher_test.dart`
- `test/essentials/onboarding/application/advanced_start_fresh_action_provider_test.dart`
- `test/essentials/onboarding/application/advanced_start_fresh_action_test.dart`
- `test/essentials/onboarding/application/start_fresh_service_test.dart`
- **NEW** `test/essentials/onboarding/application/reset_construction_lifetime_denial_test.dart`
- `test/architecture/onboarding_start_fresh_architecture_test.dart`
- `test/architecture/app_czar_architecture_test.dart`
- `test/architecture/forbidden_imports_test.dart`

Only the exact Prompt/Response 120 docs pair, and the prerequisite Prompt/Response 119 pair if not already tracked, may be documentation checkpointed. Do not change Stage 1 source, main/startup selector, Local Data Repair source/tests, other providers, UI screens, project settings, platform/native code, schemas or dependencies. **STOP** if a necessary file or generated output lies outside this finite list.

### 3. Characterization before modification

Using only inert provider overrides and synthetic composition lifetimes, establish present dispatch/factory/cached-instance edges. Keep Response 116's demonstrated hidden-menu unsafe reachability visible as historical baseline; after implementation test that AppCzar denies it. Distinguish resolving a provider, constructing an action, reading an operation/Presence dependency, invoking `request`, awaiting state/authorization, requesting a lower operation and executing mutation. None of the latter real destructive behaviours may run.

Characterize constructors and their call sites. For explicit live legacy lifetime L1, suspend inert current-state, authorization, frame and provider-creation callbacks. Revoke/dispose L1; assert old action/service instances cannot advance or publish. New live legacy lifetime L2 must not revive L1 (ABA). Probe missing/throwing/revoked/AppCzar separately, and prove a throwing reset-input provider does not prevent a separately authorized local-repair method from using its shared service. Capture safe attributable red-before/green-after tests where feasible; never execute a real body to make a failing fixture run.

### 4. Stage 2 enforcement requirements

**Dispatcher:** At `ResetMessageDataRequested`, consult the existing composition reset lifetime *before* reading `advancedStartFreshActionProvider`. On AppCzar/missing/throwing/revoked, emit nonmutating typed denial: no action factory, request or service read. Menu visibility cannot be authority. Explicit live legacy retains the old inert dispatch path.

**Advanced action provider:** Bind the root lifetime and register consumer disposal *before* reading presentation or constructing the action. Direct provider resolution must fail closed before dependencies when selection is unavailable. Do not supply a permissive default binding.

**Retained advanced action:** Its plain constructor requires the same binding. Guard `request`, `retry`, `dismissFailure`, claim/logging, presentation writes, and each async continuation after awaits (state, user authorization, frame wait, service resolution and outcome publication). On revocation, no further provider read, logging, service call or stale UI publication; do not relabel typed denial as generic failure that mutates presentation. A new container with same composition does not revive an old instance.

**Start Fresh service provider:** Deny before the first operation-controller await or any Presence/authority/reset/failure dependency. Recheck the captured binding after every await, before each subsequent dependency read and before publication. Register per-instance disposal. Previously completed legitimate construction is not retrospectively erased; no additional dependencies may be touched after revocation.

**Retained Start Fresh service:** Require its binding; check before `readCurrentState`, after awaited read, and before any lower `startFresh` request or pre-Ball side effects. Preserve existing explicit-legacy entry-point eligibility, user confirmation, archive checkpoint and recovery semantics. Never invoke a real reset body in this milestone.

**Shared message-data reset service:** Do **not** globally block factory construction; `localDataRepair` uses it. For `resetDerivedData` and `resetDerivedDataForStartFresh` only, add the proposed lazy reset-binding accessor, bound to the existing root lifetime and closed with provider disposal. General reset invocation must deny AppCzar/missing/revoked/cached L1 before lower operation or deletion. Do not alter `resetActiveDerivedDataForLocalDataRepair`, the exact safety/binding checks, reset footprint, physical postcondition or executor. Any binding read must remain lazy enough that missing reset input does not affect local repair.

**Invariant:** only the Stage 1 contract makes selection/lifetime decisions; no new free-standing policy or cached allow-bool. All seven jurisdictions and the production selector/disabled activation remain unchanged.

### 5. Required adversarial test cases

1. Hidden Settings reset and direct/stale typed intent: zero action factory, zero request, zero service construction in AppCzar and unavailable states.
2. Direct action/provider and service/provider resolution: AppCzar, missing, throwing, revoked deny **before** side-effecting dependencies; exact counts for presentation, operation controller, Presence and authority.
3. Cached legacy L1 action: revoke during initial claim/state, authorization, frame wait, retry and dismiss; no later logging, provider read, service call or stale presentation. L2 remains independent.
4. Cached legacy L1 service: revoke before/after awaited state or during async provider construction; no subsequent dependency reads or lower request; L2 cannot resurrect L1.
5. Both general shared reset methods deny AppCzar/missing/revoked/cached invocation before lower authority/callback; shared service local-repair route unaffected without executing real repair.
6. Explicit current legacy retains dispatcher/action/service *inert* reachability and existing eligibility/confirmation; no actual reset or Ball.
7. Stage 1 denied front-door `run` and `runWithCapability` tests, and no-tenure ordinary/reentrant friend tests, remain green unchanged.
8. No runtime reclassification, eighth jurisdiction, duplicate evaluator, local-repair semantic change, new direct delete caller or fallback. Add source/architecture tripwires where possible.
9. Provider invalidation/disposal, asynchronous exception, cancellation, retry and same-composition ABA do not publish stale state or reopen a revoked binding.

If a newly found reset alias or a necessary additional file invalidates the coverage, STOP and document it. Do not call partial high-level coverage full reset closure.

### 6. Validation and conformance

Run *screened inert* focused Stage 2 tests, relevant existing permitted action/service/dispatcher tests with explicitly reported safe case selection, complete Stage 1 focused suite, startup/eligibility regressions, applicable AppCzar/architecture tests (`forbidden_imports`, `onboarding_start_fresh_architecture`, `app_czar_architecture`, `exclusive_authority_architecture` as appropriate), full `flutter analyze`, targeted `dart format --output=none --set-exit-if-changed`, generated diff audit, `git diff --check`, staged file allowlist and pre/post source/untracked manifest preservation. Record exact command results, counts, exclusions and retries. Do not misreport selected tests as a full suite. Never run existing tests that acquire real tenure, reset databases, call filesystem deletion or access real data simply because their filename looks relevant.

Project Conformance PASS requires **zero BLOCKER and SHOULD FIX findings within this Stage 2 scope**. If an unsafe constructor or async path cannot be qualified inside this allowlist, STOP without success checkpoint. No dependency/codegen churn, signing change or production activation is permissible.

### 7. Checkpoints and handoff

After a genuine PASS, commit/push **only** the permitted handwritten/test/generated Stage 2 delta in one implementation checkpoint. Then checkpoint exact Prompt/Response 120 separately and verify upstream `0/0`. Preserve every unrelated item, including onboarding index and archived scripts. Never invent a self-referential documentation commit hash.

Response 120 must report baseline and Prompt/Response 119 checkpoint, exact diff files/hashes, red-before/green-after, counts for factory/continuation/method observations, root/binding reuse, delayed revocation and ABA, direct/reset message-data methods, explicit legacy preservation, unchanged Local Data Repair, generated/architecture/analyzer/conformance evidence, and remaining production lifecycle/migration/signing/backup/human blockers. Disclose unqualified real nested tenure and real signed-runtime behavior; neither is proven by inert tests.

End with exact flags:

- `STAGE 1 LOWER RESET DENIAL PRESERVED: YES/NO`
- `STAGE 2 COMMAND/CONSTRUCTION DENIAL: PASS/FAIL`
- `CACHED ACTION/SERVICE REVOCATION: PASS/FAIL`
- `GENERAL MESSAGE DATA RESET DENIED IN APPCZAR: YES/NO`
- `LOCAL DATA REPAIR SEMANTICS CHANGED: NO/YES`
- `ENUMERATED GENERAL RESET REACHABILITY CLOSED IN APPCZAR: YES/NO`
- `SEVEN JURISDICTIONS UNCHANGED: YES/NO`
- `PRODUCTION APPCZAR ACTIVATION: OFF`
- `COMPLETE POPULATED RECONSTRUCTION WITNESS: NOT REQUIRED FOR CUTOVER TRACK`
- `PROJECT CONFORMANCE (STAGE 2): PASS/FAIL`
- `READY FOR SEPARATE PRODUCTION-LIFECYCLE MILESTONE: YES/NO`

**STOP.** Do not proceed to production activation, signed app, database/recovery rehearsal, FTS integration or other feature development under this prompt.
