# Feature 34 — Response 118

Date: 2026-10-16. **Read-only design resolution; no implementation or test execution.**

## Decision

**Proposed design, resolved for review:** use one narrow root-established reset-admission lifetime input, keep existing display-composition inputs unchanged, install the two-operation denial at the shared pre-tenure coordinator path, then guard command/construction/cached execution boundaries. Implement in exactly two separately authorized stages. Prompt 119 should authorize **Stage 1 only**.

Decisions A/B/C are resolved as a finite design. This is not a claim that the proposed gate or test port exists or is runtime-qualified. Production activation stays OFF throughout both stages and until separate release qualification. No populated reconstruction or FTS work is required by these decisions.

Evidence labels throughout: **FACT** = verified current source/Git; **HISTORICAL** = recorded earlier test result; **PROPOSAL** = future change; **UNKNOWN** = not established by this review.

## Baseline, checkpoint and preservation

**FACT:** initial HEAD `5120999325ab34fbca4ae47d58f022686923a0a3`, branch `fix/onboarding-import-stuck-state`, upstream `origin/fix/onboarding-import-stuck-state`, 0/0. Tracked worktree/index clean. Prompt/Response 117 remained untracked and complete; their source baseline hashes matched the prior manifest. Prompt 118 was the only new user prompt relative to the prior handoff.

**FACT:** Prompt/Response 117 alone were committed as `d7de9fbb650298583516eded229d965383b6e1b2` (`docs(feature34): checkpoint stopped reset denial design`) and pushed normally. This records the STOP; it does not change that design verdict or activate implementation. No duplicate 116 checkpoint. Prior implementation `6b90bea234f074a3ae641401f2e8b686406a132f` and 116 documentation `51209993` remain ancestors.

**FACT:** four worktrees, primary branch unique. Other worktree tips remain Feature 35 `09b1c767cc01410da5799273206e2ab2a4d3b283`, main `b67bfafc3ad4f4f0c15792f0245bfecf5e45f43f`, Gradle `4f3e4fcc4eed2bd69eb237ae0aa328c917bbce37`. Shared instructions clean at `95326f515ef4719f155ce6e223990398daad6311`.

Independent `/private/tmp/messagelens-prompt118-baseline.json` records **6,003 tracked and 52 untracked regular-file paths and SHA-256 hashes** before checkpointing 117. Untracked inventory = the 49 unrelated files listed in Response 116, plus Prompt 117, Response 117 and Prompt 118. Navigation README, three archived scripts and 218 restored document paths are preserved verbatim. Final checks compare bytes even when a permitted documentation file becomes tracked. Only Response 118 is newly authored; the two exact documentation pairs are the only checkpoint changes. Actual final documentation hash is reported after commit creation.

**HISTORICAL:** Response 116's 12 new characterization cases, 42 selected regressions, 429 architecture cases and analyzer PASS were not rerun. Its dispatcher spy intercepted real service construction and proved reachability, not lower safety.

## Current source and construction timeline

**FACT:**

| Source anchor | Current contract / consequence |
|---|---|
| `lib/main.dart:322–338,373–375` | Exact admitted identity feeds separate development/production eligibility; disabled activation feeds actual selector; final presentation maps to StartupPresentationComposition and is overridden in the root container |
| `lib/essentials/startup_presentation_evidence/application/startup_presentation_evidence_inputs.dart:11–13` | Raw provider defaults to startupApp; no distinction between missing selection and explicit legacy |
| `.../domain/startup_presentation_evidence.dart:3` | Existing two-valued composition enum; projected support/evidence records are explicitly display-only |
| `main.dart:340,394` | One root ProviderContainer / UncontrolledProviderScope; no hot composition-update path found. Process/container replacement must not be inferred from navigation |
| `sidebar/application/sidebar_action_dispatcher.dart:269–271` | Stateless dispatcher resolves action and invokes request regardless of menu availability |
| `onboarding/application/advanced_start_fresh_action_provider.dart:17–43` | Constructs action and presentation notifier; current-state, authorization and service callbacks are lazy |
| `advanced_start_fresh_action.dart:70–218,263` | request/retry enter request-claim logic; current-state read, authorization and frame wait precede service resolution; dismiss writes presentation; retained instance has no lifetime guard |
| `start_fresh_service_provider.dart:25–44` | First await resolves operation controller; second resolves Presence repository; then authority/reset/failure dependencies. Guarding only mutation is too late for construction absence |
| `start_fresh_service.dart:72–112` | Plain service reads current state before acquiring startFresh capability; after admission writes operation/failure/Presence, resets derived files and validates virgin state |
| `message_data_reset_service.dart:60–96,329` | General reset acquires messageDataReset; Start Fresh and Local Data Repair accept distinct capabilities. Factory reads logger/file-store/version notifier; local repair shares this service |
| `archive_mutation_coordinator_provider.dart:127,142,153–222` | run and runWithCapability share _run; private Zone selects exclusive/reentrant registry branch; only then scope/checkpoint/capability/callback |
| `exclusive_authority_registry_provider.dart:45–55,70–119` | Container-lifetime registry owns private tenure. Existing cleanup friend requires an already live scope; it is not an inert reentry mechanism |

**FACT:** action request IDs and presentation occurrences are not composition epochs. Provider disposal by itself does not revoke a retained plain Dart action/service. Real registry tenure is private and must remain so. These are the reasons a small additional contract is necessary.

## Decision A — one narrow lifetime input

### Options compared

**PROPOSAL considered, rejected:** refine the existing raw presentation provider to nullable/explicit lifetime input or change its default to throw. This would alter support/environment consumers and exhaustive enum/adaptor handling, need regenerated input code and test migrations unrelated to reset denial, and still require a retained-object lifetime mechanism. Making a display default an authorization default is unsafe. Merely reading the old enum with a deny check cannot distinguish a missing override.

**PROPOSAL chosen:** add a single narrow `ArchiveResetAdmission` contract and `archiveResetAdmissionProvider` in archive_environment. Main supplies it from the **same final selected composition local variable** already used for startup presentation. This is an operation veto, not archive admission, an AppCzar evaluator, or a new general policy framework. It can only permit further consideration by existing authority gates; it cannot mint a Ball, capability, lease or native identity.

The domain contract reuses `StartupPresentationComposition` from its existing domain file; it never reads projected evidence/support or assessment. Dependencies: main -> reset input -> reset domain -> existing composition enum and ArchiveMutationOperation. The domain enum file imports only metadata; the input provider has no database, coordinator, registry, main, AppCzar-provider or display-adapter dependency. Coordinator and action/service consumers read the new input; no back edge is required. Importing a neutral enum is distinct from importing display behavior. This limited cross-domain edge receives an architecture test; no new enum duplicating the root's selection is introduced.

### Exact semantics

**PROPOSAL:**

- Root creates one object per root container, after final startup selection and before mounting. Immutable fields: selected composition (or absent), identity `Object` epoch, selection status. Mutable state is only monotonic revocation on that object; no global/static allow switch, epoch counter or setter that can reselect legacy.
- Observable states: explicit live legacy, explicit live AppCzar, unavailable/missing/rejected, revoked/disposed. Provider default creates an unavailable object, never legacy. Provider errors are translated to typed reset denial before any dependent constructor; do not catch and choose legacy.
- The only reset policy predicate is owned by this contract: for **startFresh and messageDataReset**, allow consideration only for explicit live legacy. Explicit AppCzar, unavailable, revoked or failed input denies. Other operations receive **no authorization from this contract** and retain existing gates unchanged.
- Use a typed reset-denial exception/reason in the same new domain file, with no roots/content. Do not reuse the current “another owner held authority” exception text to describe composition denial.
- Root input provider registers revocation before returning the supplied object. Disposal/invalidation permanently revokes that object; do not revive or replace its selection in the same container. A root override must register this callback itself because an overridden provider does not execute the default factory. Main's override is part of Stage 1.
- Consumers obtain a binding to that object. A binding retains the immutable epoch/object and has its own monotonic local closed flag; provider disposal/rebuild closes that binding, not every other consumer's root object. Binding validity requires both parent lifetime and local binding live. Only the parent object owns the allow/deny policy. The local flag is revocation evidence, not an independent allow decision or sole cached bool.
- Plain action/service constructors require the binding (no permissive default); provider factories register binding closure **before their first dependency read/await**. A held instance cannot swap its old binding for a new container's token. Normal dependency rebuilding can create a new instance bound to the same still-live root; it cannot revive the old instance.
- Supported composition change: close new command admission, drain existing owned work, revoke/dispose old container, then create a new container/process with a new object. No hot toggle or updateOverrides is a supported production operation. Invalidation of the root input only revokes; it must not mint a new selected token implicitly. Architecture/source tests prohibit production updateOverrides/reselection paths.

**PROPOSAL timeline:** legacy L1 creates action A1/service S1; A1 awaits current-state/authorization/frame or S1 awaits current-state. Revoke L1 while suspended; on resumption the next guard fails before logging/presentation updates, new service/dependency reads, lower admission or mutation. New legacy container L2 has a distinct object; A1/S1 still fail (ABA). A newly created L2 instance can proceed to existing legacy prerequisites, not automatically reset. A fresh AppCzar token always denies both resets.

Checks are required before request claim/logging, retry/dismiss, every asynchronous continuation that could advance this reset request, provider dependency reads after each await, return/publication of the factory result, service pre-Ball reads and lower admission. Error/cancellation paths must not publish stale presentation after revocation. Catch the typed denial before generic failure handlers that themselves log or mutate presentation; direct callers receive an explicit nonmutating denied result/exception, not silent legacy fallback.

**Limit:** denial does not undo constructors/reads/writes that completed while L1 was legitimately current. A legacy factory suspended after constructing its operation controller cannot claim zero past construction; it can guarantee no further dependency construction after revocation. Graceful replacement drains admitted operations before revocation. Unexpected termination/disposal mid-reset cannot be advertised as transactional rollback; existing recovery requirements remain. Stage tests pause before mutation and never execute a destructive body.

## Decision B — shared pre-tenure branch seam

**PROPOSAL:** extract one source-local private dispatch helper in `archive_mutation_coordinator_provider.dart`. Both public run methods still call `_run`; `_run` delegates its existing ordinary/reentrant choice to this helper. The helper performs reset-admission verification **first**, then evaluates the real candidate branch decision and invokes exactly one supplied continuation. No await between successful check and branch dispatch; downstream asynchronous admission rechecks before capability/callback.

Inputs: operation; lazy reset-input reader; candidate-owner predicate; ordinary and reentrant continuations. Production supplies its existing private Zone/coordinator-identity predicate and exact registry continuations. The helper, not a duplicate test function, chooses the branch. For non-reset operations, do not resolve the new provider at all: this preserves localDataRepair and other existing admission semantics even if reset input is unavailable. All reset-state decisions call the same domain contract used by higher guards.

**PROPOSAL test access:** a small `part` friend file exposes a test-only entry calling this identical private helper. It supplies a synthetic ordinary/reentrant candidate predicate and inert continuation counters returning fixed sentinels. Its public friend signature accepts only the synthetic branch candidate, operation and reset-lifetime value and returns counter/sentinel observations; the friend constructs its inert continuations internally. It cannot accept arbitrary caller callbacks or accept/return tenure, capability, registry, root, writable lease or the real application mutation callback. No archive identity is fabricated. A denied operation reaches neither branch continuation. An explicit-legacy decision can return an inert branch sentinel; this does not run the original reset body. A localDataRepair decision follows an inert continuation while its actual executor/gates remain untouched.

The friend entry must explicitly reject non-debug execution (`kDebugMode` check, not an assert that disappears in release). Hide it from the public feature-level export and forbid its use by production sources via architecture tests; keep the private helper unexported. Direct imports of the friend entry are permitted only in its exact test file. This is the same source-local encapsulation pattern as existing exclusive-authority cleanup support, with stricter no-tenure arguments. Production continuations are never injectable through the public coordinator API. The port is a future reviewed implementation, not currently safe executable code.

**Qualification distinction:**

- Prove the real coordinator front door reaches the shared helper: in AppCzar/missing states call real `run` and `runWithCapability` with registry/authority/checkpoint providers replaced by throwing counters; expect typed denial with zero registry construction/entries, callback calls, authority reads and state activation.
- Prove the helper gates both candidate branches: use friend entry, candidate ordinary/reentrant, exact same policy object and branch helper; zero continuations on denial. For live legacy and non-reset inert cases, exactly the selected continuation returns its sentinel.
- The friend supplies a **candidate branch fact**, not a real active owner. It does not demonstrate genuine nested Zone/tenure validation, release or reentry. Those remain historically tested/unqualified for the future change. The accepted no-tenure goal is pre-branch denial: because the gate dominates both continuations, a real nested caller cannot reach registry reentry without passing it. Keep source tripwires and trace review proving that dominance.
- Existing nested coordinator/registry tests acquire real tenure and are excluded from the inert milestone. If extraction changes Zone/tenure ownership or requires a fake admitted tenure, STOP; do not weaken encapsulation.

Additional lower lifecycle defense: recheck the captured reset binding after any wait/checkpoint validation and before minting/invoking reset capability; capability-currentness for those two operations must cease on lifetime revocation. Keep these checks confined to reset operations; localDataRepair currentness code remains semantically identical. The initial gate must remain before registry access even if later checks also exist. True post-tenure timing is not runtime-qualified by inert tests; source review must identify this limit.

## Decision C — operation and entry-point scope

**FACT + PROPOSAL matrix:** “unchanged” below means this new reset veto grants nothing and does not waive existing guards.

| Current route / evidence | Construction and callback boundary | Selected AppCzar | Explicit current legacy | Missing/revoked / direct use |
|---|---|---|---|---|
| startFresh: sidebar -> action; overlay retry/dismiss; main confirmed startup reset | Action presentation construction; service operation/Presence construction; current-state/auth/frame awaits; then startFresh Ball | Deny before command/provider construction and before lower tenure | Preserve existing consent/eligibility/authority behavior; inert spies only in qualification | Deny; retained instance checks old binding, cannot adopt new legacy token |
| messageDataReset: `MessageDataResetService.resetDerivedData()` | Shared service factory; method obtains messageDataReset before deletion | Deny method before lower call and deny lower before tenure | Existing checkpoint/authority/reset semantics remain | Deny general-reset method even when shared service remains obtainable |
| Journey reimport/recovery: coordinator `:1426,1458,1484,1887`; dev panel actions `:24` | Journey may construct/write its own operation evidence before calling shared reset; recovery may already hold automaticRecovery | Inner messageDataReset denied before **additional** reset tenure; no new reset body | Existing selected legacy flow only | No claim that denying inner reset undoes earlier outer work; shell must not mount legacy Journey in AppCzar |
| localDataRepair: executor `:70–111`; safety reader `:75`; model `:120` | Exact live-only partial/binding reread, localDataRepair capability, shared service specific method, active derived footprint/postcondition | Existing gate unchanged | Existing gate unchanged; not newly exposed | Reset veto does not decide this operation; existing archive/executor/disposal guards apply, never reinterpret unknown as repair permission |
| File-store delete adapter: `FilesystemDerivedMessageDataFileStore.deleteDatabaseBaseFiles:32` | Public filesystem adapter deletes enumerated base/WAL/SHM files. Current production call-site census reaches it only through shared reset service | No additional operation added; approved callers protected by method/capability gate | Existing enumerated behavior | Adapter itself has no capability parameter. Not a sandbox against arbitrary internal Dart calls; add source tripwire forbidding new production deletion callers outside reset service |
| historicalArchiveRemoval: Settings workflow `:2223`; source-scoped removal service `:116` | Own operation, live-source exclusion, scoped ledger deletion then graph reproject | Unchanged specialist gate, still separate qualification | Unchanged | No reset-alias permission; direct service APIs remain an internal reachability/authority review concern, not licensed by this plan |
| automaticRecovery: deterministic attachment recovery `:137`; recovered writer; Journey recovery | Attachment writer requires typed capability and writable-root admission; Journey inner reset is separate messageDataReset | Leave attachment specialist unchanged; deny nested general reset | Unchanged | Do not blanket-disable automaticRecovery; it has non-reset preservation uses |
| attachmentClearing / adoption / attachmentReconciliation | ArchiveSettings.clearArchive `:79–117`, writable-root lease and operation-specific guards; adoption and repair own independent routes | Unchanged by this two-operation cut; no claim of production-safe clearing/adoption | Unchanged | Explicit destructive attachment feature is outside Start Fresh scope; never use it as reset workaround; preservation/release audit remains required |
| graphBuild / schema migrations / projection reset | Graph build controller acquires graphBuild; ordinary DB upgrade can drop/replace projection structures; historical removal reprojects | Unchanged normal pipeline, requires in-place continuity qualification | Unchanged | Blocking these indiscriminately would stop normal operation; no general zero-write/delete guarantee |
| destructiveMaintenance enum; checkpoint/adoption temporary cleanup | Bounded search found policy declarations and scoped infrastructure cleanup; no extra broad derived-reset acquisition found under this operation | No silent scope expansion | Unchanged | Future general teardown route is a STOP/new review trigger |

**FACT:** startFresh is not in `requiresVerifiedCheckpoint`; messageDataReset is. Neither checkpoint receipt nor UI visibility is an AppCzar denial. All direct/cached methods in the first two rows are covered; do not rely on an absent UI.

**PROPOSAL shared-service treatment:** do not deny its factory globally because Local Data Repair uses it. Add a provider-lifetime-bound, lazy reset-binding accessor only for `resetDerivedData` and `resetDerivedDataForStartFresh`. Its local closed flag is registered on construction before dependencies; it binds the root token on first general-reset use, revokes on provider disposal, and cannot resolve a token after disposal. `resetActiveDerivedDataForLocalDataRepair`, reader, binding recheck, capability operation, footprints and physical postcondition remain unchanged. A throwing reset-input override must not prevent construction/use of the local-repair method through its existing safe gate. No independent policy boolean in this service.

**Search scope/limits:** bounded `lib/**/*.dart` non-generated searches for startFresh/reset providers and calls, deleteDatabaseBaseFiles, deleteRowsForSource, database-delete/drop and named archive operations; source inspection of positive routes above. Import DB migrations (`import_database_provider.dart:39,43`) and source deletion (`:399`) are real distinct mutation paths. Temporary checkpoint/adoption cleanup and marker writes are not a newly discovered full populated reset alias. This is sufficient to define the two named reset semantics in current call sites, not proof against arbitrary filesystem code or all production mutation. If implementation finds another caller with the same general teardown semantics, STOP and report rather than silently extending the operation set.

## Two finite implementation stages

**PROPOSAL:** Stage 1 intentionally installs the **lower** veto first, along with its input/test seam. Stage 2 completes construction and command denial. This reverses no dependencies and avoids a test helper that exercises a disconnected policy. Neither stage authorizes activation. Stage 1 alone does not prevent legacy action/Presence construction and is not a completed cutover.

### Stage 1 — proposed Prompt 119: explicit lifetime and pre-tenure denial

Exact anticipated production allowlist (new paths explicitly proposed):

1. **NEW** `lib/essentials/archive_environment/domain/archive_reset_admission.dart` — single two-operation policy, explicit state, immutable epoch, revocable root/bindings, typed denial. No I/O or authority minting.
2. **NEW** `lib/essentials/archive_environment/application/archive_reset_admission_provider.dart` — generated-provider declaration, default unavailable; no side-effect dependency.
3. **NEW GENERATED** `lib/essentials/archive_environment/application/archive_reset_admission_provider.g.dart` — generator output only.
4. Existing `lib/main.dart` — create input from final selected composition, register disposal in override, retain disabled activation. Do not alter the selector or implement production restart.
5. Existing `lib/essentials/archive_environment/feature_level_providers.dart` — exact provider/domain exports; hide test friend from coordinator export.
6. Existing `lib/essentials/archive_environment/application/archive_mutation_coordinator_provider.dart` — same shared pre-tenure helper on both run APIs, two-operation veto and bounded lifetime rechecks; no changes to registry algorithms.
7. Existing GENERATED `lib/essentials/archive_environment/application/archive_mutation_coordinator_provider.g.dart` — regenerated only if generator changes it.
8. **NEW test-support part** `lib/essentials/archive_environment/application/archive_mutation_admission_test_support.dart` — debug-only counter/sentinel port calling the private helper; no tenure-shaped input/output.

Exact test edit/create allowlist:

- **NEW** `test/essentials/archive_environment/application/archive_reset_admission_test.dart` — all explicit/missing/revoked/binding/ABA states; both reset operations; non-reset policy bypass without authority.
- **NEW** `test/essentials/archive_environment/application/archive_mutation_pre_tenure_admission_test.dart` — real denied front doors plus friend branch tests and zero side-effect counters.
- Existing `test/app_czar_startup_composition_test.dart` — disabled selector assertions and source link from final composition to new input; no main launch.
- Existing `test/architecture/app_czar_architecture_test.dart` — same selector, seven jurisdictions, no assessment dependency in new input.
- Existing `test/architecture/exclusive_authority_architecture_test.dart` — friend exposure/use restrictions and unchanged tenure ownership.
- Existing `test/architecture/forbidden_imports_test.dart` — exact source-local port/layering checks; no broad allowlist exemption.

**Stage 1 red/green:** before change missing raw selection indistinguishable from legacy and no pre-tenure veto. After: missing/throwing/revoked/AppCzar denies both operations via real front doors before registry/authority/checkpoint resolution; same helper denies both candidate branches; explicit legacy and local-repair synthetic paths only return inert continuations. Two root objects with same composition have different epochs; revoking one never revives its bindings. Consumer binding closure does not revoke another current consumer. No native identity or real capability created. Actual production selector stays legacy because activation is disabled.

**Stage 1 completion:** bounded domain/provider/helper implemented and safely characterized; exact lower denial exists, root connection source-proven. **Non-goals:** dispatcher/action/service closure, UI, full container startup, actual nested tenure, real allowed reset, SQL, local repair execution. Stage 2 remains mandatory. STOP on extra production files, cycles, a public tenure forge, real Ball in tests, local-repair semantic change, broad test allowlist changes or generated churn outside named paths. Constructor consumers are not changed in Stage 1, so no unrelated reset tests need migration merely to compile.

### Stage 2 — complete command/construction/stale-object denial

Exact anticipated production allowlist:

1. `lib/essentials/sidebar/application/sidebar_action_dispatcher.dart` — require live reset binding before action-provider read; explicit nonmutating denial.
2. `lib/essentials/onboarding/application/advanced_start_fresh_action_provider.dart` — guard before presentation/action construction, register per-instance revocation.
3. `lib/essentials/onboarding/application/advanced_start_fresh_action.dart` — mandatory binding, request/retry/dismiss and asynchronous continuation guards; no stale failure/log publication.
4. `lib/essentials/onboarding/application/start_fresh_service_provider.dart` — guard before first read; after each await; before every remaining dependency/publication. Inject binding into plain service.
5. `lib/essentials/onboarding/application/start_fresh_service.dart` — guard before current-state read and after awaited evidence before requesting authority; retain explicit legacy semantics and recovery limits.
6. `lib/essentials/onboarding/application/message_data_reset_service.dart` — lazy general-reset binding and disposal guard for the two general-reset methods only; local-repair method/footprint unchanged.
7–10. Corresponding existing GENERATED paths, regeneration only: `sidebar_action_dispatcher.g.dart`, `advanced_start_fresh_action_provider.g.dart`, `start_fresh_service_provider.g.dart`, `message_data_reset_service.g.dart` in their respective directories.

Exact test edit/create allowlist:

- Existing `test/essentials/app_czar/application/non_destructive_operating_composition_characterization_test.dart` — change unsafe current expectations into clearly documented denial regression assertions, preserve historical record in Response 116.
- Existing `test/essentials/sidebar/application/sidebar_action_dispatcher_test.dart` — explicit live legacy fixture for selected inert reset case; screen other cases for SQL.
- Existing `test/essentials/onboarding/application/advanced_start_fresh_action_provider_test.dart` — denied factory resolution, no presentation/service reads.
- Existing `test/essentials/onboarding/application/advanced_start_fresh_action_test.dart` — binding constructor migration and safe pre-service suspended/cached request cases; no real service.
- Existing `test/essentials/onboarding/application/start_fresh_service_test.dart` — mandatory binding constructor migration; existing real-tenure/destructive-body cases must not run under inert qualification. Constructor compilation is not runtime reset qualification.
- **NEW** `test/essentials/onboarding/application/reset_construction_lifetime_denial_test.dart` — denied factories, service/operation/Presence counters, await/revoke/ABA, shared-service general-reset rejection with inert dependencies, unchanged local-repair source checks.
- Existing `test/architecture/onboarding_start_fresh_architecture_test.dart`, `test/architecture/app_czar_architecture_test.dart`, `test/architecture/forbidden_imports_test.dart` — guard ordering, deletion caller census and invariants.

**Stage 2 red/green:** hidden menu and direct/stale dispatcher requests yield zero action factory/service entries in AppCzar. Direct action/service factories deny before any side-effect dependency; explicit legacy remains reachable using inert spies. Suspended legacy construction may have earlier legitimate entries, but after revocation counters stop and no instance is published. Retained actions/services reject on old bindings before request logging/state reads; replacing the container with legacy again does not rescue them. Shared reset service remains available for the specific local-repair route, but general-reset methods deny before lower admission. No actual StartFreshService reset body, database read, Ball or file deletion is executed. Tests distinguish method request, object construction, lower invocation and callback counts.

**Stage 2 completion:** all enumerated high-level general-reset entry points use the same Stage 1 contract, no legacy fallback, and source-local lower veto remains the backstop. **Non-goals:** authorizing production, eliminating every specialist mutation, retrospective cancellation of already completed construction, verifying real nested tenure or live legacy reset. If test fixtures force a new public production helper, a new reset API or more source files, STOP and revise the finite allowlist before continuing.

Across both stages: **12 handwritten production/test-support files plus up to 6 generated files** (Stage 1 six handwritten + two generated; Stage 2 six handwritten + four generated). The breadth is disclosed; no four-file safety claim. New test files are explicitly proposed above, not misrepresented as current files. Existing selector/input read-model files are deliberately unchanged by the chosen alternative. Main's development-keyed presentation flags remain a later UX/composition closure issue; they are never admission authority.

## Validation and checkpoint plan for implementation

**PROPOSAL:** each stage separately: inspect baseline, capture manifest, perform exact edit scope, run new inert focused cases and screened existing regressions; required architecture suites above plus relevant startup-presentation evidence gate; full analyzer, targeted format, generated/diff checks, conformance and preservation. Do not run existing real-tenure or real-reset tests merely because their filenames are relevant. No full-suite claim. For generated output, use normal generator, verify only listed generated paths change; STOP on unrelated changes rather than sweeping or silently restoring user material.

For each stage, require zero design/implementation BLOCKER and SHOULD FIX findings before staging. Commit only that stage's authorized source/tests/generated outputs; push normally. Then create its separately authorized Prompt/Response documentation checkpoint. Preserve index/scripts/untracked material. Both checkpoints report exact test selection and limits. No new source commit in Prompt 118.

**UNKNOWN retained:** true runtime reentry and post-tenure lifetime timing after implementation, all app-shell interactions, real legacy reset completion, signed production identity/FDA, existing data migrations/sidecars, backup restorability and specialist production-human outcomes. These do not block a truthful pre-tenure design/specification; they block claims of active production safety. Source review plus inert continuations proves the specified gate location, not a live nested execution.

## Design conformance and remaining critical path

Reviewed against repository AGENTS.md; shared global guardrails; project README/architecture and database/overlay/attachment-preservation invariants; canonical Feature 34 Project Conformance Audit Standard; Prompt/Responses 115–117 and Prompt 118; relevant 85–89 history; current source/tests. No skill/delegation used.

**PROPOSAL conformance assessment:** reuse actual selected composition and existing coordinator/registry; one two-operation policy, one root selection lifetime, no second evaluator. Narrow input has no I/O/provider cycle. Friend helper cannot carry tenure/capability, is debug-fenced and hidden with architecture restrictions. Non-reset operations and local-repair exact semantics stay unchanged. Missing and stale evidence fail closed; no fake admission claims. Privacy, bounded work, dependency/generated hygiene and unrelated preservation are explicit. No UI change or release version bump in this design-only milestone. Historical tests are labelled historical. Stage boundaries and finite paths prevent another witness project.

**Design BLOCKER: 0; SHOULD FIX: 0.** The required decisions are resolved as proposals, not verified implemented guarantees. Any implementation contradiction triggers the named STOP conditions. Production blockers remain independent: reset closure (both stages), production process handoffs, safe in-place data/schema continuity, full shell/provider closure, signed/FDA and specialist human rehearsal, backup/rollback and final release audit/user activation approval.

**Prompt 119 recommendation:** implement only Stage 1's explicit lifetime input, two-operation lower pre-tenure veto and no-tenure characterization using the exact allowlist. Do not include Stage 2 constructors/commands, actual nested tenure, production activation, app launch or reconstruction work.

## Audit verification and documentation disposition

**FACT:** no tests, analyzer, generation, app build/launch, live SQL, source/archive/volume/permission/cloud access, or mutation/tenure acquisition ran in this prompt. Only source/document/Git inspection and authorized documentation writes/checkpoints. Whitespace and exact hash preservation are checked; historical tests were not rerun. Final tracked tree/index/submodule remain clean after documentation commit; 49 unrelated untracked files remain. All original manifest bytes are preserved. The final Prompt/Response 118 pair receives its own docs-only commit and normal push; actual hash reported at handoff.

EXPLICIT COMPOSITION/LIFETIME CONTRACT RESOLVED: YES

SAFE PRE-TENURE ADMISSION TEST SEAM RESOLVED: YES

STARTFRESH AND MESSAGEDATARESET SCOPE RESOLVED: YES

LOCAL DATA REPAIR CONTRACT UNCHANGED: YES

TWO-STAGE IMPLEMENTATION PLAN COMPLETE: YES

PRODUCTION START FRESH DENIAL IMPLEMENTED: NO

PRODUCTION APPCZAR ACTIVATION: OFF

POPULATED RECONSTRUCTION WITNESS ON CUTOVER CRITICAL PATH: NO (architectural)

PROJECT CONFORMANCE (DESIGN): PASS

READY FOR NARROW PROMPT 119: YES
