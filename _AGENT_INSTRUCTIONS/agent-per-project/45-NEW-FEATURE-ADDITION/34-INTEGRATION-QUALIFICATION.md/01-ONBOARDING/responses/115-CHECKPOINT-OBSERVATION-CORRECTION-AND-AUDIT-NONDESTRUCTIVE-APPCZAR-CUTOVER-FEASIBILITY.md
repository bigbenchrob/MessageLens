# Feature 34 — Response 115

Date: 2026-10-16 (America/Vancouver).
Scope: read-only source/Git architectural feasibility audit. No implementation, tests, app launch, database access or activation.

## Decision

**YES: a non-destructive production AppCzar cutover is architecturally feasible without populated Operating-owned Start Fresh. NO: the current composition is ready to activate.** Recommend option A, with the independently gated milestones below. A complete populated reconstruction-equivalence witness is **not on this cutover's critical path** if populated reset authority is permanently absent. In-place preservation, schema compatibility, operating updates, process handoffs and production qualification remain mandatory; they are different proofs and cannot be waived.

This finding means the current source does not impose a reset/rebuild prerequisite on admitting a healthy existing installation. It does not establish that every existing production installation is healthy or supported. Unsafe, unsupported, partial historical and unknown cases must remain in Diagnostic Review or the exact existing specialist jurisdiction. No release, app execution, migration, reset or activation is authorized by this response.

“Non-destructive” here means no voluntary populated teardown/reconstruction and preservation of independent material. It does not mean no writes: ordinary import, graph updates, user edits and authorized attachment preservation are still essential. Separately qualified Local Data Repair is itself a narrowly destructive operation on exact partial/empty-graph derived stores; it must never be marketed or widened into populated Start Fresh. If the product requires literally zero derived-file deletion, that jurisdiction's execution would also need separate withholding, not relabeling.

## Baseline and document reorganization

- Branch `fix/onboarding-import-stuck-state`; HEAD `ddc5c85e767cb2b1d6d147c60b005ad700a168a5`; upstream `origin/fix/onboarding-import-stuck-state`, 0/0.
- Source checkpoint `28449d2f7457f9c751b0a683d7012dc3812c62d0` and stopped-binding documentation `29edb8977e63ab87893e0f1415f32c89317cde50` verified in ancestry.
- Prompt/Response 114 already committed separately together in `ddc5c85e767cb2b1d6d147c60b005ad700a168a5` and pushed. No duplicate checkpoint.
- Shared submodule clean at `95326f515ef4719f155ce6e223990398daad6311`; exactly one worktree on this branch. Other three worktrees unchanged: Feature 35 `09b1c767cc01410da5799273206e2ab2a4d3b283`, main `b67bfafc3ad4f4f0c15792f0245bfecf5e45f43f`, Gradle worktree `4f3e4fcc4eed2bd69eb237ae0aa328c917bbce37`.

Initial inspection found 218 tracked documentation deletions with byte-identical `_ARCHIVED` counterparts. The audit stopped. The user confirmed the move was intentional, then separately authorized a better navigation arrangement. Those 218 exact documents were moved back without changing bytes; a new untracked `01-ONBOARDING/README.md` index was created. Three untracked shell scripts remain preserved under `prompts/_ARCHIVED`. No archival move was staged or committed. The user then explicitly requested continuation of this audit.

The resumed source-only baseline, `/private/tmp/messagelens-prompt115-baseline.json`, contains 5,998 tracked file hashes and 50 untracked file hashes, including Prompt 115, the user-authorized navigation index and the preserved scripts. Tracked tree/index were clean at resumed audit start. The index and unrelated files are excluded from this audit's documentation checkpoint. Final preservation is verified against this resumed baseline, not against the superseded archival layout.

## Evidence discipline

**Fresh inspection:** current source paths/methods below, tracked/untracked Git evidence, current test assertions and build configuration text. No method in the execution graph was run.

**Historical qualification only:** Responses 85–92, including development-human results summarized by Response 85; Stage 2A/2B results in 88–89; Stage 2C STOP in 91–92. These remain records, not fresh production tests. Response 114 qualified only the test-only observation publication boundary; production does not consume it as reconstructibility authority.

**Proposed design:** capability exclusion, production lifecycle changes and the staged plan below. None exists merely because described here.

**UNKNOWN:** actual production-root contents, schema distribution, mounted-volume conditions, real TCC/FDA behavior, installed signature/notarization, runtime library identity, backup restorability and production-human outcomes. This audit did not inspect any of them.

## Current execution and dependency graph

The current source graph is:

```text
Native claim + signature/root validation + single-instance authority
  -> Dart archive admission
  -> immutable ArchiveAccessAuthority
  -> main: development policy / production eligibility / activation
       production eligible + activation FALSE -> StartupApp (legacy)
       admitted development -> AppCzarStartupHarness
          -> one AppCzar assessment/evaluator
          -> six explicit coordinator hosts OR admitted Operating Session
             -> AppCzarOperatingSessionApp / one-route router
             -> MessageLensWorkspaceShell
             -> Operating currentness occurrence
             -> shared feature/settings providers

Current production legacy branch:
StartupApp -> installation/Journey classification
           -> _initializePersistentStartup
           -> App -> goRouterProvider + chatDbChangeMonitorProvider
                  -> ProductionMacosAppShell + legacy overlays

Shared reset back door still in source:
ResetMessageDataRequested -> SidebarActionDispatcher
  -> advancedStartFreshActionProvider -> StartFreshService
  -> ArchiveMutationOperation.startFresh -> reset service
```

### Source anchors and implications

All paths below are relative to the repository and line numbers identify the inspected HEAD.

| Anchor | Fresh source fact / implication |
|---|---|
| `lib/main.dart:168`, `_admitArchive` | Native/Dart admission precedes the provider container; composition is not archive admission |
| `macos/Runner/MainFlutterWindow.swift:201`, claim resolver; `:272` canonicalization; `:337` lock | Production signature check, physical canonicalization and root-scoped process exclusion precede Dart; no in-process navigation substitutes for fresh admission |
| `lib/essentials/archive_environment/domain/archive_identity_validator.dart:75` | Invalid production signature cannot yield an admitted production identity |
| `lib/main.dart:322`, `:417`, `selectMessageLensStartupPresentation` | Eligibility and activation are distinct. Development policy OR eligible-and-enabled production chooses harness |
| `lib/essentials/app_czar/application/production_app_czar_activation.dart:1` | Only constructible activation value is disabled; `isEnabled` always false |
| `lib/essentials/app_czar/application/app_czar_production_composition_eligibility_policy.dart:17` | Requires already-admitted official production environment, release build, bundle and product |
| `lib/main.dart:367` | Navigation restoration and Settings reset visibility are keyed to development policy, not selected composition; hypothetical production AppCzar would inherit legacy defaults |
| `lib/main.dart:449`, `_initializePersistentStartup` | Legacy persistent logging/error wiring and completed-install adoption recovery plus window restoration; this callback is supplied to StartupApp, not the AppCzar shell |
| `lib/main.dart:615`, `:857`, `:878`, `:1212` | Legacy installation classification; explicit confirmed startup reset; generic App constructs ambient chat monitor |
| `lib/essentials/app_czar/application/app_czar_assessment_provider.dart:24` | Provider construction schedules read-only assessment automatically; parallel observations are not a cross-store transaction |
| `lib/essentials/app_czar/presentation/app_czar_startup_harness.dart:50`, `:115` | Explicit Operating/diagnostic/local-repair/update/onboarding/source-access/archive-repair hosts; controllers may be constructed before any user button |
| `lib/essentials/app_czar_operating_session/presentation/app_czar_operating_session_app.dart:23`, `:43`, `:115` | Own router, neutral workspace, one currentness status host; no generic App/legacy wrapper; title still “MessageLens Development” |
| `lib/essentials/app_czar_operating_session/application/app_czar_operating_session_controller.dart:16`, `:79` | Operating requires exact current assessment and archive binding; no reset/reconstruction witness predicate |
| `lib/essentials/app_czar_operating_session/application/app_czar_operating_session_visual_initializer_provider.dart:34` | Visual initialization restores window state only; it is not the legacy persistent initializer |
| `lib/essentials/app_czar_operating_session/application/app_czar_operating_currentness_controller.dart:67`, `:86`, `:776` | Occurrence-owned drain/restart and timer; must remain sole currentness owner |
| `lib/essentials/conversation_graph/application/monitor/chat_db_change_monitor_provider.dart:129`, `:193`, `:399`, `:414` | Legacy monitor construction starts path/source work, can request graph build, and owns polling/attachment timers |
| `lib/essentials/sidebar/application/sidebar_action_dispatcher.dart:269` | Direct reset intent reads legacy action without consulting reset visibility; UI omission is not capability absence |
| `lib/features/sidebar_utilities/application/sidebar_cassette_spec/resolver_tools/settings_reset_message_data_action_availability_provider.dart:12` | Default reset availability is true; this is presentation policy only |
| `lib/essentials/onboarding/application/start_fresh_service_provider.dart:25`, `:60` | Constructing service reaches legacy operation controller, Presence maintenance and failure stores; run acquires startFresh capability |
| `lib/essentials/onboarding/application/start_fresh_service.dart:74` | Existing service resets operation evidence and Presence run, then derived stores; it cannot be reused as the supposedly unavailable production command |
| `lib/essentials/archive_environment/application/archive_mutation_coordinator_provider.dart:142`, `:284` | Exclusive lower authority creates callback-local capability; production destructive operations separately require a verified checkpoint; checkpoint is not proof of reconstruction |

The seven enum members are unchanged in `lib/essentials/app_czar/domain/app_czar_models.dart:419`: Operating Session, Onboarding, Source Access Repair, Attachment Archive Repair, Local Data Repair, Data Update and Diagnostic Review. Six have coordinator controllers/screens; Operating has an admitted session controller and shell. Start Fresh is an optional Operating command, not an eighth jurisdiction.

### Construction-time side effects

Provider declarations/overrides alone do not execute every worker. However, watching controllers or shared feature providers can execute work:

- Assessment provider schedules source/store/archive observations on build. These can attempt source access and use native archive-location evidence; no automatic Start Fresh follows.
- Data Update controller `build()` (`app_czar_data_update_controller.dart:26`) schedules `_runSelectedUpdate` when selected; executor (`app_czar_data_update_executor_provider.dart:34`) admits a liveGraphUpdate Ball before reading/running the worker. Import/project/preserve work needs no button.
- Onboarding controller `build()` (`app_czar_onboarding_controller.dart:67`) schedules prerequisite inspection and construction when selected. Its executor calls the existing graph build controller; permissions guidance is explicit, and safe-empty scope is required.
- Local Data Repair controller `build()` (`app_czar_local_data_repair_controller.dart:32`) automatically schedules its bounded repair when selected. It is not a voluntarily invoked populated reset.
- Operating initializes visual state and its currentness controller/observer. Ordinary feature consumption then opens persistent stores; saving window/preferences and user intent is distinct from reset.
- Central persistent providers (`lib/essentials/db/feature_level_providers/persistent_database_providers.dart:44`, `:73`, `:131`) ensure directories, open writable import/graph/overlay, register resource close ownership and permit database-owned creation/migration. Mere screen/feature consumption may therefore cause schema writes.
- Graph `onUpgrade` (`conversation_graph_database.dart:17`) calls schema creation and, for pre-v3 upgrade, rebuilds the message text index. Disabling Start Fresh does **not** disable this migration. Import open/migrations live in `source_scoped_import/infrastructure/import_database_provider.dart:29`; overlay migration in `overlay_database.dart:38`; Presence migration in `presence_database.dart:410`.
- Legacy persistent initialization invokes attachment adoption recovery for a completed installation. The AppCzar visual initializer does not. A production cut must explicitly account for pending journal/recovery evidence; it must not copy this legacy callback wholesale or silently discard recovery needs.
- Attachment Repair factory (`features/attachments/application/app_czar_attachment_archive_repair_executor_factory_provider.dart:27`) constructs an executor; source readers/writers are callback-resolved, and batch mutation uses attachmentReconciliation capability and writable-root admission. This is separate from Settings adoption and its exact development gate.

No current AppCzar startup/coordinator/Operating code calls `.startFresh()`. A complete source search found only two call sites: `main.dart:878` (confirmed legacy startup choice), and `advanced_start_fresh_action.dart:218` (explicit advanced action). Option-launch reset is a legacy choice/confirmation path, not an AppCzar reset. No independent automatic Start Fresh invocation was found in environment switching, diagnostics or recovery. This does not make the reachable shared dispatcher safe: it can still instantiate the legacy service on an explicit/stale/programmatic intent.

## Populated reset exclusion and preservation

### Current availability answers

| Question | Answer | Basis |
|---|---|---|
| Does Operating admission require populated Start Fresh or a reconstruction witness? | NO | `shouldExecuteAppCzarOperatingSession` inspects current facts/binding only |
| Is an Operating-owned populated reset implemented? | NO | Stage 2C STOP record and current call-site census; proposed adapter files absent |
| Is current hidden Settings reset mechanically inaccessible? | NO | Shared dispatcher has an unconditional legacy action edge |
| Can populated Start Fresh be absent from a future production AppCzar composition? | YES, as a proposed explicit service/capability cut | No startup dependency requires it; command, service and lower operation admission must be closed together |
| Does removing reset leave normal browse/search/tag/favourite/support operation dependent on it? | NO direct dependency found | Normal workspace/feature ownership is separate; exhaustive production interaction qualification remains UNKNOWN |
| Does omission eliminate a recovery option? | YES | Corrupt/unsupported/populated-unsafe cases may remain Diagnostic; support and externally verified recovery must be honest alternatives, not hidden reset fallback |
| Can all historical installations currently be admitted without further work? | UNKNOWN | Current-schema complete historical data can pass; incomplete protected/non-live data cannot; real schema/provenance diversity is unobserved |

### Proposed capability-absent design, not implemented

Select a production AppCzar command surface with no populated reset executor/service dependency. Reject `ResetMessageDataRequested` before legacy provider construction even if supplied through stale navigation or programmatically. Do not mount `AdvancedStartFreshOverlayHost`, legacy StartupApp, legacy reset dialogs or the generic legacy App. Make the existing lower operation-admission boundary deny `ArchiveMutationOperation.startFresh` for this composition regardless of a valid checkpoint, so a stray caller cannot acquire a reset Ball. Do not create a second AppCzar evaluator; the operation gate only withholds capability. It must not infer readiness or alter jurisdiction selection.

Keep the presentation unavailable/absent consistently at the selected-composition boundary, not `!developmentEnabled`. A Settings explanation may say “Start Fresh is unavailable in this configuration”; support may report unavailable capability. Neither may claim reconstruction readiness. Legacy code may remain source for an independently selected legacy build during controlled rollback, but there must be no runtime fallthrough from an AppCzar occurrence into it. Historical source removal/adoption remain separate explicit specialist actions, not substitutes for Start Fresh, and require their own lifecycle/tenure review.

### Exact Local Data Repair distinction

`app_czar_evaluator.dart:552` selects repair only for consequential **incomplete** local data with positive exact safety; protected non-live incomplete data goes to Diagnostic. `sqlite_app_czar_local_data_repair_safety_reader.dart:75` refuses any consequential graph rows; it also checks retired artifacts, supported schemas, live-only registry/batch/row lineage and source/binding stability. The model's `mayResetDerivedStores` (`app_czar_models.dart:120`) requires the rebuildable-live-only-partial condition and full binding/footprint evidence.

The executor (`app_czar_local_data_repair_executor_provider.dart:70`) rereads safety, compares mutation binding, checks admission, acquires **localDataRepair**, rechecks archive scope/generation, then calls `resetActiveDerivedDataForLocalDataRepair` at line 111. The reset service requires that operation separately from startFresh. No broadening to a populated graph, historical data or user-consented uncertainty is justified. The existing narrow proof must be requalified on production-shaped fixtures; it is not the missing full populated reconstruction witness.

Safe-empty Onboarding (`app_czar_evaluator.dart:513`) requires conclusive initial scope, coherent archive binding and Contacts/source evidence; it constructs new derived data. A complete historical/non-live installation is not rejected merely for that label: the protected branch at line 552 is conditional on incomplete local data. This corrects any overbroad reading of Response 85's historical-data table. Unknown/retired/unhealthy/unsupported states remain Diagnostic. No absence or unreadability is converted to permission to rebuild.

## Decision matrix

Status means **ready for non-destructive production composition now**, except where a row explicitly states an already established property. TRUE is not activation authorization. Development evidence is historical unless marked source-inspected.

| Capability / Dependency | Current owner and source | Development evidence | Production requirement | Start Fresh dependency? | Status TRUE/FALSE/UNKNOWN | Smallest next evidence or change | STOP gate |
|---|---|---|---|---|---|---|---|
| Eligibility / inactive selector | production eligibility + activation policy; main:322 | Response 86, current tests inspect exact admitted identities | Keep admission and activation distinct | No | TRUE for inactive seam; FALSE for enabled composition | Preserve disabled seam through characterization | Any runtime/setting-based accidental activation |
| Data Update | DataUpdateController:26; executor:34 | Historical live update/restart PASS (R85 census) | Signed identity restart, production checkpoint/worker/preservation qualification | No | FALSE | Production-shaped update and failure/lifecycle fixtures | Implicit alternate updater, lost provenance or preservation failure |
| Source Access Repair | source-access controller:40, :75, :141 | Historical development FDA OFF/ON PASS | Production-specific instructions, TCC/FDA and exact restart | No | FALSE | Staged identity-bound human rehearsal later | Wrong bundle, permission-state inference or in-process handoff |
| Attachment Archive Repair | controller + feature factory:27 | Historical human-confirmed bounded development batch | Preserve batch/generation/writable-root contracts; qualify production external media | No | UNKNOWN | Disposable binding/volume-failure coverage, then approved staged run | Adoption broadening, unknown scope, payload overwrite |
| Onboarding | controller:67; build executor | Historical isolated development PASS | Virgin/current-empty production fixtures, Contacts/FDA, construction and restart | No | UNKNOWN | Empty-scope admission/partial-failure tests | Historical/protected data classified empty |
| Local Data Repair | controller:32; safety reader:75; executor:70 | Historical four-fixture development matrix | Exact existing partial/empty-graph safety, production checkpoint/restart | No; distinct operation | UNKNOWN | Requalify unchanged preconditions on production-shaped fixtures | Consequential graph or non-live material allowed |
| Diagnostic Review | diagnostic controller/screen, harness:115 | Historical revised bounded PASS; genuine source UNKNOWN not human exercised | Frozen nonmutating report, exact production restart/Quit and support | No | FALSE | Lifecycle/identity plus honest unsupported-state UX | Repair/reset fallback or retry loop |
| Operating Session | session controller:16; app:23/:43 | Historical admitted shell/currentness qualification; source-inspected | Neutral production branding, root overrides, sole currentness, feature closure | No | FALSE | Composition and command reachability characterization | Journey/legacy monitor construction |
| Reset exclusion | sidebar dispatcher:269; reset service provider:25 | Stage 2C STOP; source UI-only hiding | No callable reset service or startFresh Ball | This is omission | FALSE | Typed/composition admission cut with adversarial tests | Hidden control is the only guard |
| Settings/support/Environment | neutral source seam; diagnostic report:19; environment summary:37 | R88/R89 automated evidence; current neutral imports verified | Preserve feature parity and no legacy branch reads in AppCzar mode | No | TRUE for extracted seams; UNKNOWN for full interaction closure | Targeted reachability and export privacy assertions | Support or stale navigation reconstructs legacy authority |
| Historical workflows | historical workflow panel model; neutral source path:2207/:2566/:3097 | R88 extraction, specialist workflows remain | Preserve registry/identity, independently authorize removals/imports and drain handoffs | No | UNKNOWN | Disposable historical identity and mutation-lifecycle characterization | Removal used as reset workaround |
| Background observers | Operating currentness:67/:776 vs legacy monitor:399 | Historical single-owner tests | AppCzar root never constructs generic App/ambient monitor | No | FALSE until production closure proven | Spy provider construction and active-flight drain tests | Two pollers/writers or stale publication |
| Restart identity | restarter provider:13; MacosDevelopmentProcessRestarter:50 | Development old/new process qualification | Production-admitted exact bundle relaunch, stop/drain, old PID exit, new native/Dart admission | No | FALSE | Separate identity-constrained lifecycle implementation/qualification | Development-only gate, wrong app or same-PID transition |
| Persistent stores / migration | centralized providers:44/:73/:131; schema migrations | Source-inspected; no fresh migration qualification | In-place continuity for ledger/graph/FTS, overlays, Presence and WAL; schema admission before write-open | No | UNKNOWN | Disposable version/sidecar matrix; reject unsupported versions | Unexpected reproject/rebuild, independent-state loss |
| Archive authority / adoption | mutation coordinator:142/:284; repair writer; location admission | Typed tenure/current capability code present | Same admitted scope, protected payload continuity, retain exact adoption gate | No | TRUE for boundary existence; UNKNOWN for production runtime | Verify denied operations, pending journals and capability lifetime | Implicit lease, bypassed checkpoint or adoption gate |
| Signed runtime / release | native claim, identity validator:75, entitlements/config | Source and historical development only | Official signed/notarized install/update, FDA, sandbox/OS behavior | No | UNKNOWN | Future explicitly approved signed/staged rehearsal | Identity mismatch or unverified permissions |
| Backup / rollback | verified checkpoint validation + existing recovery tooling | Existing mechanism, no release-specific restore evidence | Independently verified backup/restore and old/new schema compatibility | No | UNKNOWN | Separate controlled recovery plan and rehearsal | Treating receipt as universal rollback proof |
| Full populated reconstruction witness | test-only comparators/envelope/FTS levels | R105–114 bounded milestones only | Not required when populated reset is absent | Yes, for deferred destructive command | UNKNOWN proof; not relevant to A's critical path | No work under this cutover track | Four finite FTS TRUE dimensions used as exhaustive proof |

## Re-audit of Response 85 blockers

1. **Selector:** R86 implemented and current source verifies official-production eligibility plus unconditionally disabled activation. The old claim “no selector seam exists” is superseded; production composition is still not qualified or enabled.
2. **Lifecycle:** still requires implementation. `app_czar_process_restarter_provider.dart:13` feeds only the development policy to `MacosDevelopmentProcessRestarter`; `restartAndReassess` rejects production. Renaming UI or enabling eligibility cannot fix this. Source-access, Diagnostic, update, repair and Operating escalation all depend on that port.
3. **Shell/sole currentness:** neutral Operating shell exists and avoids generic App/legacy monitor by construction, but root overrides and shared command reachability still need production closure. Do not reuse `App` or `ProductionMacosAppShell` for visual convenience.
4. **Commands/support:** source-neutral Messages evidence (R88), support and Environment adapters (R89) now exist and current consumers use them. Reset exclusion is not complete; historical specialist workflows/navigation/restoration still require lifecycle and interaction qualification. Reset replacement is no longer a mandatory product feature under option A.
5. **Protected databases:** requires in-place admission/migration evidence. Read-only AppCzar store probes require exact versions (`sqlite_app_czar_observation_reader.dart:439`); they can reject older stores before operating, while central writable opens can migrate. A declared supported-version matrix and explicit unsupported route are essential. No automatic “fix by reset” is allowed.
6. **Signing/TCC/install:** requires human qualification. Source config preserves `com.bigbenchsoftware.MessageLens`, product MessageLens, productionRelease; development has its distinct bundle/product. `macos/Runner/Release.entitlements` has app-sandbox false and explicit JIT/library/network/addressbook entitlements. These source facts do not prove installed signature, notarization or FDA continuity. Follow `60-BUILD-CONSIDERATIONS/02-macos-fda-grant-continuity.md`; do not change signing identity/bundle to ease testing.
7. **Recovery:** requires independent backup/restore and release-specific rollback qualification. Lower production checkpoint validation is necessary but not proof that an older binary can read migrated state. Keep recovery separate from in-process legacy fallback.
8. **Data diversity:** unavailable proof for actual roots; requires production-shaped current/historical/retired/corrupt/sidecar/pending-journal/external-archive fixtures and later authorized human evidence. This audit grants no data-root inspection.

Additional R85 items remain explicit: genuine source-UNKNOWN human gap, startup/large attachment scan latency and cancellation bounds, privacy/support completeness, neutral navigation/session restoration, OS/external-volume edge cases and process-exit evidence quality. Current neutral support projection omits paths/identifiers and uses completed assessment facts; full signed-runtime behavior is still unqualified.

## Options and dependency count

Counts below are **planning groups**, not estimated time or a claim to have counted every transitive provider. The eight common non-destructive closure groups are: (1) production shell/selected-composition wiring; (2) reset capability exclusion; (3) production process lifecycle; (4) in-place schema/data continuity; (5) seven-jurisdiction/worker qualification; (6) signed runtime/permissions; (7) backup/rollback; (8) conformance, performance/privacy/UX and release authorization.

| Option | Executable feasibility and blockers | Preservation risk and qualification | Dependency count / releasable result |
|---|---|---|---|
| **A: non-destructive cutover, populated reset permanently absent** | Feasible design; none of normal admission, currentness or jurisdiction selection calls populated reset. Current code still blocked by eight groups above | Avoids deliberate teardown, but migrations/updates/partial repair still need preservation tests; unsupported cases may remain unavailable in Diagnostic | Eight common groups. No AppCzar-enabled production release is authorized now; after all gates, normal supported operation and exact scoped jurisdictions may ship with reset absent |
| **B: wait for complete populated reconstruction witness** | Adds a proof dependency that no present Operating predicate requires; exhaustive FTS and production-scale replay remain unavailable | Stronger reset proof would not establish signing, migration, human permissions or rollback; all A blockers remain | Eight common groups plus two major deferred families: complete bound populated reconstruction/FTS/protected-state proof, and safe reset execution/consent/lifecycle qualification. No earlier safe release benefit demonstrated |
| **C: staged capability-gated production** | Possible only with one AppCzar evaluator, explicit unavailable abilities and no legacy fallback; current code has no qualified general production ability configuration | Selected auto-start controllers can mutate on construction, so merely hiding buttons/gating screens is unsafe. Gating a selected coordinator must yield an honest nonexecuting state, not quietly reclassify or navigate into legacy | Eight common groups plus capability-matrix/admission/nonexecution qualification. Useful as a later staged rollout technique, not a shortcut around A's critical blockers |

**Recommend A.** Use staged rehearsals within A; do not implement C's additional runtime policy merely to bypass unqualified jurisdictions. If a future staged release truly needs per-ability withholding, review that explicit single-owner design separately. Keep B off this critical path while retaining the permanent prohibition on populated reset; missing witness proof must not be weakened to rescue reset later.

## Minimal ordered qualification plan

1. **Source/disposable composition characterization:** prove current dependency edges, root overrides, provider construction and reset back doors without activating production. PASS means exact reachable effects documented and tests attributable; STOP on live-path/native dependencies or extra-file needs.
2. **Capability-absent reset composition:** separately implement the smallest command/service/lower-operation denial cut. Adversarial stale spec, direct intent, direct provider and direct startFresh Ball requests must fail before legacy service construction or mutation. LocalDataRepair must retain exactly its existing scope. STOP on fallback, permission-by-consent or an eighth jurisdiction.
3. **In-place admission and continuity:** supported schema matrix and disposable current/historical/non-live fixtures, overlays/Presence/attachment references, sidecars and pending operation evidence. No rebuild of a populated store as a precondition. STOP on lost identity, unsupported migration or unverified rollback compatibility.
4. **Production identity-constrained handoffs and shell closure:** admit exact official identity, stop/drain, old PID termination, replacement PID, fresh native/Dart root admission and neutral reassessment. No in-process transition or development-only restarter in production. Confirm no legacy ambient monitor or reset providers.
5. **Signed/staged qualification with future explicit human approval:** same release identity/signing/FDA invariants, supported OS/volume/permission cases and seven jurisdictions, with no access to actual user data absent separate approval. Development PASS is not substituted.
6. **Independent conformance, release/recovery and actual user go/no-go:** verified backup/restore, schema rollback matrix, performance/privacy/UX, checks and human authorization. Activation stays OFF until this separate decision. A production eligibility test or audit YES is insufficient.

These milestones need their own scopes and PASS/STOP gates. No build or rehearsal is authorized here.

## Exactly one proposed Prompt 116

**Test-only characterization of non-destructive Operating composition and reset reachability, before any service change.**

Proposed exact new source scope: one file,
`test/essentials/app_czar/application/non_destructive_operating_composition_characterization_test.dart`, plus its separately authorized Prompt/Response 116 documentation. No other helper, production edit or activation change.

Characterize current behavior with existing injectable policies/provider overrides and inert spies:

- official production can be eligible but selector remains legacy because activation is closed;
- neutral Operating workspace excludes generic App, legacy overlays and ambient monitor;
- current root reset/restoration overrides are development-keyed;
- a hidden reset menu does not itself block dispatcher resolution of the legacy action (capture provider access only, never run real StartFreshService);
- no ordinary Operating admission or currentness contract requires reset/reconstruction proof;
- selected automatic controllers are identified distinctly from explicit commands, with all side-effecting ports replaced by inert test doubles.

Tests must describe the existing missing exclusion honestly rather than assert an unimplemented safety property as PASS. No fake production activation value, full native main launch, live DB opener, mutation Ball or production policy is permitted. Existing APIs may be reused only if they allow isolation without additional files; otherwise STOP and report the precise seam gap. Validate focused characterization, relevant existing selector/Operating/sidebar tests, architecture, full analyzer, format/diff and conformance; preserve all unrelated material. The result should identify a reviewable minimal later denial cut, not implement it or resume FTS binding. This is a narrow executable dependency check, not another populated-witness milestone.

## Audit/design conformance and final integrity

Reviewed against: repository `AGENTS.md`; shared global `agent-guardrails.md`; project README/architecture and database/overlay/preservation rules; the canonical Feature 34 `MESSAGELENS-PROJECT-CONFORMANCE-AUDIT-STANDARD.md`; production FDA continuity instructions; Prompt 115; current source and historical Responses 85–92 and 113–114.

Audit scope findings: **BLOCKER 0; SHOULD FIX 0**. This is not a zero-blocker production-readiness claim. All remaining production blockers are enumerated above. Reuse, single semantic owner, lower capability separation, seven jurisdictions, no record/payload deletion, no fabricated runtime evidence and no proof-level promotion are preserved. UI/implementation conformance is not claimed for unimplemented designs.

No tests, analyzer, generation, build, app, migration, import, reset, repair, SQL, real-root listing, source/archive probe, permissions operation or cloud backup ran. Search command path/glob misses were ordinary source-discovery misses and supplied no runtime evidence. Historical test counts were not presented as new results. Only source/Git reads and this authorized audit document write occurred during resumed audit; the earlier navigation repair was separately user-authorized and is explicitly excluded from the checkpoint.

All resumed-baseline tracked and untracked bytes are verified unchanged except new Response 115. Prompt 115 and this response alone form the documentation checkpoint; its actual hash and final 0/0 synchronization are reported after Git creates it. The navigation index and 48 other pre-existing untracked files remain preserved and unstaged. No archival moves are committed. No implementation checkpoint is created.

PROMPT 114 OBSERVATION CORRECTION CHECKPOINTED: YES

NON-DESTRUCTIVE PRODUCTION APPCZAR CUTOVER FEASIBLE WITHOUT POPULATED START FRESH: YES

POPULATED OPERATING START FRESH ENABLED OR AUTHORIZED: NO

PRODUCTION APPCZAR ACTIVATED: NO

SEVEN APPCZAR JURISDICTIONS UNCHANGED: YES

COMPLETE POPULATED RECONSTRUCTION WITNESS REQUIRED ON CRITICAL PATH: NO

REMAINING PRODUCTION BLOCKERS INVENTORIED: YES

PROJECT CONFORMANCE (AUDIT/DESIGN): PASS

READY FOR ONE NARROW PROMPT 116: YES
