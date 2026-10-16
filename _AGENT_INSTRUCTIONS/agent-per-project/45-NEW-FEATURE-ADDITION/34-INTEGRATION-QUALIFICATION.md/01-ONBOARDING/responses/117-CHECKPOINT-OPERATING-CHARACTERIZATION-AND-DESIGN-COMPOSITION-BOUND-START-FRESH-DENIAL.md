# Feature 34 — Response 117

Date: 2026-10-16. Read-only production-code design review. **STOP: no complete implementation specification or success checkpoint.**

## Decision and evidence labels

**Verified source fact:** the exact command, action-provider, service-provider and lower-operation boundaries exist, but the currently available seams do not establish all of Prompt 117's missing-selection, stale-instance and no-tenure reentry requirements. A four-file patch guarding dispatcher/action/service/coordinator with the existing composition provider would fail closed for explicitly selected AppCzar, but would silently allow a missing selection and would not revoke retained action/service objects.

**Proposed design:** retain a composition-bound denial at those four boundaries, but first resolve the explicit-selection/lifetime input and an inert lower admission/reentry test seam. Do not create an ambient boolean or promote support evidence into mutation authority. No implementation is authorized by this response.

**UNKNOWN:** a complete narrow implementation allowlist and safe executable reentry proof under the no-Ball constraint. The candidate list below is an impact inventory, not a ready Prompt 118. The source does not disprove non-destructive cutover feasibility; it disproves treating the existing four-boundary sketch as complete.

Prompt 117 section 3 says: “If a boundary has no safe existing injection/admission seam, STOP”. Its final section says to write a factual STOP response “without a success checkpoint.” Those gates apply here. No tests, app, native startup, reset or mutation operation ran. Prompt/Response 117 remain untracked; no commit or push was made in this milestone.

## Provenance and preservation

**Verified source/Git facts:**

- Branch `fix/onboarding-import-stuck-state`, HEAD `5120999325ab34fbca4ae47d58f022686923a0a3`, upstream `origin/fix/onboarding-import-stuck-state`, 0/0.
- Implementation `6b90bea234f074a3ae641401f2e8b686406a132f` is an ancestor. Prompt/Response 116 are the exact pair in `51209993`; the preceding test-only checkpoint and pair are already pushed. No duplicate checkpoint.
- Tracked worktree/index clean; shared submodule clean at `95326f515ef4719f155ce6e223990398daad6311`.
- Other worktrees unchanged: Feature 35 `09b1c767cc01410da5799273206e2ab2a4d3b283`; main `b67bfafc3ad4f4f0c15792f0245bfecf5e45f43f`; Gradle `4f3e4fcc4eed2bd69eb237ae0aa328c917bbce37`. Four worktrees total.
- Pre-write manifest `/private/tmp/messagelens-prompt117-baseline.json` records SHA-256 for 6,003 tracked and 50 pre-existing untracked regular files. The 50 comprise the 49 unrelated files preserved in Response 116 plus Prompt 117. Complete durable path inventory for the unrelated files is in Response 116; this manifest holds current hashes.
- Preserved navigation `01-ONBOARDING/README.md`, three `prompts/_ARCHIVED` scripts, restored 218 document paths and all other material. No reorganization, clean, stash, reset, branch switch or staging.

**Historically qualified tests:** Response 116 records 12 new cases, 42 selected regression cases, 429 architecture cases and a clean analyzer. These were not rerun here. Inert action construction/request counts establish dispatcher reachability only. Historical Responses 85–92 preserve earlier cutover, neutral-source/support and stopped destructive-reset work; their results are not production qualification.

## Complete bounded source map

All paths below are repository-relative. Anchors refer to the unchanged source at HEAD; no application method was executed.

### Selection and presentation

**Verified source facts:**

- `lib/main.dart:322–338`: admitted archive identity feeds development eligibility and production eligibility separately. Actual `selectMessageLensStartupPresentation` receives `ProductionAppCzarActivation.disabled`; selected presentation is then mapped to `StartupPresentationComposition.appCzar` or `.startupApp`.
- `main.dart:373–375` overrides `startupPresentationCompositionProvider` with that final selected composition. This is the correct source fact to reuse, not an environment label or eligibility result.
- `lib/essentials/startup_presentation_evidence/application/startup_presentation_evidence_inputs.dart:11–13` defaults to `.startupApp` when no override exists. That default loses the distinction between **explicitly selected legacy** and **missing selection**. The generated provider has no independent admission evidence.
- `.../domain/startup_presentation_evidence.dart:3` has two composition values. The immutable evidence record in the same file is explicitly display-only. The raw root selection input is distinct from projected support evidence.
- `main.dart:367–372` still keys reset visibility and navigation restoration to `!appCzarDevelopmentCompositionEnabled`. These are presentation policies, not authoritative denial.
- `features/sidebar_utilities/.../settings_reset_message_data_action_availability_provider.dart:12`, SettingsRootResolver and its historical tests control menu omission. `settings_top_menu_row.dart:48` emits `ShowResetMessageDataFlow`; sidebar dispatcher `:95` builds reset-panel state. `features/settings/.../resolvers/reset_message_data_settings_resolver.dart:30` emits `ResetMessageDataRequested`. No new click is needed to construct a stale/programmatic typed intent. No dedicated URL reset handler was found in the inspected chain; no exhaustive deep-link safety claim is made.

### Command, action and service construction

**Verified source facts:**

1. `lib/essentials/sidebar/application/sidebar_action_dispatcher.dart:269–271`, `dispatch(...)`, unconditionally reads `advancedStartFreshActionProvider` and awaits `request()`. Its `build()` is stateless. Cached provider resolution still supplies the same callable action.
2. `lib/essentials/onboarding/application/advanced_start_fresh_action_provider.dart:17`: constructs `AdvancedStartFreshActionImpl`, immediately resolves the presentation notifier, and installs lazy callbacks for current-state reading, authorization, service, frame wait and logging. It does **not** construct StartFreshService just by returning the action. Earliest direct-action construction denial is before these reads and constructor.
3. `advanced_start_fresh_action.dart`: `request()` enters `_claimRequest`; `_runInitialRequest` reads installation state before user authorization; `retry(occurrence:)` also claims work and manipulates presentation; `_execute` waits for a frame, checks occurrence, resolves retry entry point, then reads service and calls `startFresh(entryPoint:)` at line 218. `_claimRequest` joins an active request and emits lifecycle logging; its request ID is per action, not a composition-generation identity. `dismissFailure` writes presentation state. No composition/lifetime guard exists in the plain action instance.
4. `advanced_start_fresh_overlay.dart:143,152` directly reads the action for retry/dismiss, independently of the dispatcher. Guarding only dispatcher cannot cover these calls or a retained action object.
5. `start_fresh_service_provider.dart:25`: first awaits the operation controller, then Presence repository; later reads archive authority, constructs validators, reset service, failure store and refresh closures. Earliest direct-service denial must be **before the first await/read**, and must be revalidated across asynchronous construction before continuing or publishing. Guarding only the final `runWithCapability` cannot prevent those dependencies from being built.
6. `start_fresh_service.dart:72`, `StartFreshServiceImpl.startFresh({entryPoint = incompleteInstallation})`, first awaits `readCurrentState`, checks entry-point eligibility, then requests mutation authority. Within the capability callback it resets operation/failure/Presence evidence, resets derived files and validates virgin state. A cached instance can already hold all dependencies. A new provider-factory guard cannot retroactively unconstruct them and cannot alone prevent the pre-Ball read. This distinction is mandatory.
7. `main.dart:877–878` is the other `.startFresh()` call: legacy confirmed startup reset, via the service provider. The two observed call sites are this and the advanced action. `StartFreshEntryPoint` is eligibility/consent context, not proof of selected composition.

### Lower authority and independent reset routes

**Verified source facts:**

- `lib/essentials/archive_environment/application/archive_mutation_coordinator_provider.dart:127,142` exposes `run<T>(operation, ownerLabel, action)` and `runWithCapability<T>(...)`; both funnel into `_run` at line 153.
- `_run` reads the private Zone context, then calls the registry's `runReentrant` or `runExclusive`. A proposed denial belongs before either registry access and before the branch. Checking in `_runAdmittedArchiveScope` is too late: tenure is already obtained.
- `_runAdmittedArchiveScope:198` activates scope, then awaits applicable checkpoint validation, creates private callback-local capability and enters the owner Zone. Capability currentness checks coordinator identity, tenure, exact active scope and disposal; these mechanisms do not currently inspect selected composition.
- `ExclusiveAuthorityRegistry` uses private tenure construction and owns a container lifetime. Existing test support can only capture/replay cleanup of an **already active** tenure. It cannot supply a no-tenure private coordinator Zone. Existing nested coordinator tests create a real tenure; they are unsuitable for the required inert proof and were not run.
- `archive_mutation_operation.dart`: **startFresh itself does not requireVerifiedCheckpoint**; messageDataReset does. The direct capability-specific Start Fresh reset does not request a second messageDataReset Ball. Do not describe a generic production checkpoint requirement as an existing Start Fresh guard. This is more precise than a broad reading of Response 115's “production destructive operations” summary.
- `message_data_reset_service.dart:60–82`: `resetDerivedData()` acquires **messageDataReset**; `resetDerivedDataForStartFresh(capability)` requires **startFresh**; `resetActiveDerivedDataForLocalDataRepair(capability)` requires **localDataRepair**. Shared deletion logic permits those three distinct operations.
- Alternate callers of `resetDerivedData()` include `onboarding_dev_panel_actions_provider.dart:24` and Journey reimport/recovery paths at `onboarding_journey_coordinator_provider.dart:1426,1458,1484,1887`. The last can nest messageDataReset within automaticRecovery. A startFresh-only operation denial does not deny these alternate destructive commands.
- Shared reset-provider construction (`message_data_reset_service.dart:329`) reads logger, file-store and version notifier and installs DB-close callbacks. Blocking that whole provider would break Local Data Repair; a blanket service ban is not acceptable.

**Search boundary:** searched `lib/**/*.dart` excluding generated files for `.startFresh(`, action/service provider references, reset intents, `ArchiveMutationOperation.startFresh`, `resetDerivedData`, local-repair reset and teardown operation names; inspected the positive call sites above. This is a static call-site census, not a proof against arbitrary retained callbacks, future routes, native code, general file deletion or every specialist operation. Generated files were read only to check provider shape. A wrong guessed path/glob produced source-discovery errors, not evidence of absence.

### Local repair and automatic hosts

**Verified source facts:** LocalDataRepair executor `app_czar_local_data_repair_executor_provider.dart:70–111` rereads archive/safety, compares exact mutation binding, checks ongoing admission, acquires localDataRepair, rechecks scope/generation and only then resolves the shared reset service. `app_czar_models.dart:120` requires rebuildable live-only partial condition and complete binding/footprint evidence; safety reader `:75` refuses consequential graph rows and checks supported/live-only provenance. It is not voluntary populated reset.

Harness first-watch behavior remains relevant: assessment schedules observations; selected Data Update, Onboarding and Local Data Repair schedule automatic work; selected Attachment Archive Repair creates an executor and schedules inspection before explicit preservation; Source Access waits for human action; Diagnostic captures a snapshot; Operating initializes a session and owns currentness. None may be instantiated merely to obtain composition denial evidence. No host was constructed in this review. Seven jurisdictions remain unchanged.

## Why the four-file sketch is incomplete

### Blocker 1 — missing selection and stale-instance lifetime

**Verified source fact:** raw composition has an allow-like legacy default and no revocation/generation token. Main establishes a fixed selection once and mounts an UncontrolledProviderScope. No runtime update of this selection was found; a process restart naturally removes in-memory objects. This does not prove retained objects are inert in disposal/updateOverrides tests or asynchronous provider rebuilding.

**Proposed necessary contract:** one root-owned, explicitly established selected-composition input, no implicit legacy default; missing/error/rejected/disposed input denies. Same source feeds command and lower denial. Freeze selection for a container lifetime; a supported change requires stopping/draining and replacing the container/process, never live fallback. Retained action/service objects need a revocable lifetime check before work, and rechecks after awaits before new dependency resolution or publication. Disposal must permanently close the old instance even if a later container chooses legacy again (ABA). A single cached bool is insufficient.

The smallest missing port is an **explicit selected-composition/lifetime read contract**, owned by startup composition, consumed by archive operation admission and legacy action/service guards. It must not evaluate AppCzar facts or grant mutation itself. Current raw input can be refined, but that changes its default semantics and requires generated/provider-consumer qualification. Projecting StartupSupportEvidence into this role would violate display-only ownership.

**UNKNOWN:** exact compatible API and generated/test fallout of refining that input versus introducing a narrowly scoped lower admission input. A direct import of the existing raw input has no evident construction cycle (it reads no lower provider); however its default/lifetime semantics are inadequate. This is not a claim that a circular dependency makes the feature impossible.

### Blocker 2 — required inert reentry proof has no existing seam

**Verified source fact:** a direct denied lower request can be tested safely after adding a front-door gate by overriding registry resolution with a throwing/counting spy. Actual reentry requires the coordinator's private Zone and a private tenure. Existing cleanup support requires a live tenure. Subclassing the registry does not mint the private coordinator context.

**Proposed missing port:** archive-environment-owned, test-restricted access to the same pre-tenure admission path/continuation, so denial and both proposed downstream branch continuations can be observed with inert counters. It must not fabricate an admitted archive identity, mint capability/tenure or expose general authority in production. A test-only helper exercising only a copied predicate would not prove the production gate. The exact port needs a separately reviewed scope and architecture restriction before implementation.

A permitted localDataRepair *policy decision* can be characterized without a Ball. Calling its real lower allowed admission cannot be called inert merely because its callback is empty. That test must use the reviewed continuation seam or remain unqualified. Existing nested/allowed-operation tests were excluded.

### Additional completeness limit — alternate messageDataReset

**Verified source fact:** closing startFresh leaves direct messageDataReset routes. These do not falsify the specific Start Fresh call-site result, but prevent claiming a complete non-destructive reset boundary. **Proposed decision needed:** explicitly include messageDataReset denial in selected AppCzar, leaving localDataRepair unchanged, or assign alternate legacy route exclusion to a separate mandatory shell-closure gate. Do not silently add operation kinds to scope or describe startFresh-only blocking as all reset protection.

## Candidate finite impact list — not an approved Prompt 118

**Proposed design impact inventory, based on existing paths:**

| Existing production file | Why it would need review/change |
|---|---|
| `lib/essentials/startup_presentation_evidence/application/startup_presentation_evidence_inputs.dart` | Explicit missing-selection and lifetime contract, rather than implicit legacy |
| its `startup_presentation_evidence_inputs.g.dart` | Generated output only, never hand edit |
| `lib/main.dart` | Supply one final selection/lifetime input and align presentation flags; activation stays disabled |
| `lib/essentials/sidebar/application/sidebar_action_dispatcher.dart` | Deny before action resolution; stale show-flow is presentation, reset execution is authority |
| `lib/essentials/onboarding/application/advanced_start_fresh_action_provider.dart` | Deny before presentation/action construction and supply lifetime guard |
| `lib/essentials/onboarding/application/advanced_start_fresh_action.dart` | Cached request/retry/dismiss and async continuation guard; factory-only denial insufficient |
| `lib/essentials/onboarding/application/start_fresh_service_provider.dart` | Deny before operation/Presence reads, revalidate async construction, guard publication |
| `lib/essentials/onboarding/application/start_fresh_service.dart` | Cached service invocation before readCurrentState and after awaited evidence |
| `lib/essentials/archive_environment/application/archive_mutation_coordinator_provider.dart` | Shared front-door denial before direct/reentrant registry path; inert test seam requires separate definition |

This is **eight handwritten production files plus one generated output**, before resolving the test-only reentry port. It exceeds approximately four. The extra work is not cosmetic: missing defaults, retained plain objects and async construction are independent requirements. Reject hiding the scope by putting a new framework or unrelated wrappers inside one file. This list is deliberately **not** a final executable allowlist; a complete Prompt 118 implementation is not ready.

Candidate existing test files to reuse/review after ports are settled:

- `test/essentials/app_czar/application/non_destructive_operating_composition_characterization_test.dart` — preserve historical unsafe characterization semantics in its record; future assertions explicitly become denial expectations.
- `test/essentials/sidebar/application/sidebar_action_dispatcher_test.dart` — select safe cases, inert action factory counts; avoid unrelated SQLite cases.
- `test/essentials/startup_presentation_evidence/application/startup_presentation_evidence_provider_test.dart` — missing versus explicitly selected legacy, presentation adapters.
- `test/app_czar_startup_composition_test.dart` — actual selector remains disabled for production.
- `test/essentials/archive_environment/application/archive_mutation_coordinator_provider_test.dart` — review prospective no-tenure cases only, not existing real-tenure nested fixtures.
- `test/architecture/app_czar_architecture_test.dart` and `test/architecture/forbidden_imports_test.dart` — dependency/side-effect and test-port exposure boundaries.

Any additional new test-helper/port file needs an exact separately reviewed path, not an invented filename presented as inspected evidence. The next smallest task is to settle those two ports and the alternate-operation scope, then issue a complete finite Prompt 118; do not start the denial implementation from this inventory.

## Prospective red/green matrix

All rows are **proposed**, none executed in Prompt 117.

| Case | Red/current observation | Required green evidence / STOP gate |
|---|---|---|
| Hidden row plus direct/stale ResetMessageDataRequested | Historical spy reaches action | Zero action factory entries, zero service entries, zero callbacks; deny before provider read |
| Direct action resolution | Constructs real action/presentation dependencies | Typed unavailable/denied outcome before constructor; no logging/source/auth port; missing selection also denied |
| Direct service resolution | Reads operation/Presence before authority | Deny before first dependency; pause construction at each await, revoke, resume: no later construction/publication |
| Cached action/service | No composition lifetime check | Old instance cannot request/retry/read state after revocation or container replacement, including ABA; construction already performed is not retroactively absent |
| Direct lower run and runWithCapability | No selected-composition gate | Both deny before registry factory/runExclusive, archive authority/checkpoint read, capability or callback |
| Nested/reentrant lower request | Current proof needs real tenure | STOP until reviewed inert seam demonstrates shared pre-branch gate; no real tenure test |
| Legacy explicitly selected | Historical reachable action via spy | Preserve inert command reachability only for explicit live legacy input; never actual destructive service |
| Development AppCzar / hypothetical future production AppCzar | Same selected enum available synthetically | Same denial based only on selected composition; actual production selector remains disabled; synthetic input is not native admission |
| Missing/rejected/throwing selection | Current default is legacy | Explicit fail-closed, no ambient fallback, no mutable global flag |
| LocalDataRepair | Separate typed operation and exact reader/binding gate | Unchanged bytes for safety reader/model/executor/reset footprint; policy continuation tests only via safe port; no real allowed Ball |
| Alternative messageDataReset | Separate destructive operation reachable | Explicit scope decision; cannot claim closure by only denying startFresh |
| Seven jurisdictions / neutral shell / ordinary actions | Historical bounded tests only | Relevant inert regressions, source tripwires, no automatic coordinator/provider construction; no exhaustive runtime claim |

Future validation: focused red/green tests, screened regressions, architecture gates, full analyzer, generated-file/diff/format checks and exact manifests. STOP on extra uncontrolled production scope, native/SQL/real source access, fabricated admission, real Ball/lease in inert qualification, changed local-repair safety, fallback, or production enablement.

## Rejected alternatives and ordered release groups

**Proposed alternatives rejected:** menu visibility as authority; production eligibility/environment/development flag as selection; mutable global reset switch; read-and-cache bool in a provider; only denying inside service mutation callback; only guarding dispatcher; blanket shared-reset-service ban that breaks local repair; new evaluator; real-tenure tests labeled inert; claims that populated FTS/reconstruction proof solves any of these composition problems.

**Proposed six ordered release groups:**

1. Resolve the explicit selection/lifetime and inert admission seams, then close reset capability/constructor routes with the scoped alternative-operation decision.
2. Production process handoffs: drain, terminate old PID, admit replacement native/Dart identity, reassess; no in-process legacy fallback.
3. In-place schema/data/sidecar continuity, historical provenance and protected independent-state preservation. Keep specialist/local-repair proof scopes separate.
4. Complete shell/provider and interaction closure, single currentness owner, safe Settings/support and constructor behavior.
5. Separately authorized signed/staged FDA/permission/volume and specialist human qualification; no production enablement by this document.
6. Verified backup/restore/rollback, independent release/conformance audit and explicit human activation decision.

**UNKNOWN:** actual installed production identity, data diversity, runtime permissions, full mounted interactions and recovery outcomes. Architecturally feasible means no mandatory reconstruction prerequisite for healthy in-place operation; production-ready means all these independent gates actually pass. No FTS or populated-witness work is reopened.

## Design conformance and final integrity

Reviewed against repository AGENTS.md; shared global guardrails and project README; architecture/database/overlay/attachment-preservation invariants previously read in this audit chain; canonical Feature 34 Project Conformance Audit Standard; current source; relevant Responses 85–92, 115–116; exact Prompt 117. No new skill or delegation was used.

**Design BLOCKER 1:** fail-closed missing selection and stale-instance lifetime are not supplied by the current raw input. **Design BLOCKER 2:** no existing no-tenure reentry test seam meets the specified executable proof. No claim of zero blockers or implementation readiness. Alternative messageDataReset scope is an explicit unresolved completeness decision.

Reuse/ownership: reuse actual selector and lower authority; do not invent a second evaluator. Layering: do not promote display records to authorization. Privacy/mutation: read repository source/Git only; no real data or capability obtained. State honesty: historical/executable source findings and proposals distinguished. Generated/dependency hygiene: untouched. UX: no edits. Tests: none executed, as permitted for this review. Preservation: baseline hashes rechecked at handoff; source/test/index/submodule unchanged; only this new response added (51 untracked total including Prompt 117). No success checkpoint or push.

PROJECT CONFORMANCE: FAIL

This verdict applies to the incomplete proposed denial design, not a claim that preserving the STOP violates project rules.

RESET-DENIAL DESIGN COMPLETE: NO

PRODUCTION RESET REACHABILITY CLOSED: NO

PRODUCTION APPCZAR ACTIVATION: OFF

POPULATED RECONSTRUCTION REQUIRED FOR CUTOVER: NO (architectural)

PROJECT CONFORMANCE (DESIGN): FAIL

READY FOR PROMPT 118 IMPLEMENTATION: NO
