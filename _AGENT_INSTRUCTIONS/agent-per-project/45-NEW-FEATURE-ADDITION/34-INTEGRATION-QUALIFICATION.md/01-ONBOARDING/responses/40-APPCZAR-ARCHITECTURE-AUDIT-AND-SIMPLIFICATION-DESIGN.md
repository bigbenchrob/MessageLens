# MessageLens Feature 34
## Response 40 — AppCzar Architecture Audit and Simplification Design

Date: 2026-10-01

## 1. Executive summary in plain language

Yes, the proposed simplification is viable.

MessageLens can start every process with no remembered answer to “what state is
the app in?” It can inspect the current Mac, the admitted MessageLens data root,
the databases, and the attachment archive; reduce those observations to exactly
one present condition; and give control to exactly one coordinator.

The whiteboard model is:

```text
launch
  -> AppCzar observes current reality
  -> exactly one condition
  -> exactly one coordinator
  -> coordinator either continues within its jurisdiction or requests restart
  -> only a new AppCzar assessment may declare Operating
```

The current architecture contains good low-level readers, integrity checks,
reset allow-lists, import/projector workers, attachment-preservation boundaries,
and exclusive mutation tenure. Those should survive. The excess complexity is
mainly the set of persisted and recomputed conclusions around them:

- `MessageLensInstallationState` plus its historical operation interpretation;
- `OnboardingEnvironmentReport` as a second semantic classifier;
- durable Onboarding operation snapshots, resume disposition, and restart
  reconciliation;
- Journey episodes for completed/normal/reimport states outside Onboarding's
  jurisdiction;
- compatibility gates and center-panel synchronization;
- persisted sidebar/contact/conversation selection restored as current state.

Those mechanisms can be deleted or absorbed. Onboarding does not need a durable
cursor. Initial live-source import, graph build, and rich-text enrichment do not
need cross-session resume. If that work is interrupted, the next process can
observe incomplete live-source derived stores, remove only the enumerated
rebuildable stores, and rebuild from the beginning.

There is one essential limit: “disposable” applies only to data proven
reconstructible from sources still available. It never applies to archived
attachment payloads, overlay user intent, Presence definitions/history, archive
configuration/identity, or potentially irreplaceable historical-source imports.
Those remain protected durable facts.

The target has one top-level semantic authority: AppCzar. Journey owns only the
meaning and position of the Onboarding experience while AppCzar has selected the
Onboarding jurisdiction. Feature 35's Ball remains the separate, narrow authority
for who may mutate protected resources.

## 2. Proposed final AppCzar laws

1. Every process launch starts in `ASSESSING`; no previous app classification is
   loaded.
2. AppCzar classifies only from a complete, coherent set of present observations.
3. The classification predicates are total and pairwise exclusive. Exactly one
   must match. Zero or multiple matches produce `CANNOT_DETERMINE`, not a guess.
4. A completed classification names exactly one coordinator type. AppCzar does
   not expose a menu of coordinators.
5. AppCzar chooses jurisdiction, not a coordinator's internal step.
6. The selected coordinator is the sole semantic authority while it governs.
   Its workers report facts and progress; they do not publish competing app
   states.
7. Onboarding starts by rerunning its current prerequisite tests. It has no
   durable Trip/Step cursor.
8. Progress belongs to one live execution and dies with that execution.
9. An incomplete live-source derived build is discarded and rebuilt. It is not
   resumed.
10. A coordinator may acquire typed Ball tenure, but tenure does not classify the
    application.
11. A coordinator never selects another coordinator and never declares the next
    AppCzar condition.
12. A coordinator ends only with `OK` when its jurisdiction remains valid, or
    `RESTART` when its work may have changed the jurisdiction.
13. Only a new process and a fresh AppCzar assessment can create an Operating
    session.
14. The operational sidebar and center are constructed only after the Operating
    classification. They begin from a fixed empty navigation state.
15. Durable facts may be observed; persisted conclusions may not control the
    classification or presentation.
16. All deletion is allow-listed. AppCzar simplification cannot weaken overlay,
    Presence, historical-source, archive-metadata, or attachment-payload
    preservation.

## 3. Evidence AppCzar observes

AppCzar should consume observations, not today's aggregate reports. The low-level
readers may remain separate specialists, but their results form one immutable
assessment sample.

| Evidence | How observed | Nature | Needed by AppCzar? | Launch-assessment decision |
|---|---|---|---|---|
| Admitted root identity, environment, build identity, canonical root | Existing archive admission/marker/root policy, read before opening app databases | Present safety fact plus irreducible configured identity | Yes | Retain the low-level admission as a bootstrap safety boundary; feed its factual result to AppCzar. Do not treat admission as an app-state classifier. |
| FDA | Fresh native/source access evaluation | Present fact | Yes | Observe directly on every launch. Do not persist it in SQLite. |
| `chat.db` existence/readability | Named read-only source probe | Present fact | Yes | Needed to distinguish Onboarding/source remediation/Updating/Operating. |
| Current live-source count and high-water identity | Read-only guarded query of importable rows and `MAX(ROWID)` or the canonical source cursor evidence | Present fact | Yes | Needed for source-versus-derived currentness. Gross counts alone are insufficient. |
| Contacts source reachability | Current AddressBook folder resolution and read-only probe | Present fact | Not normally | Remove it from top-level classification unless a product decision makes Contacts mandatory for Operating. Onboarding and Updating should test it when their work needs it. It may still be displayed as coordinator evidence. |
| Source-scoped import store schema/readability/count/source inventory/cursor | Existing bounded read-only database evidence | Present materialized fact | Yes | Retain. Non-live source inventory is essential to prevent unsafe disposal. |
| Conversation Graph schema/readability/count/topology/FTS | Existing bounded read and conditional integrity validation | Present materialized fact | Yes | Retain. Replace “completed snapshot” interpretation with direct coherence predicates. |
| Overlay schema/readability | Bounded read and conditional integrity validation | Present preservation-store health | Yes | Retain health only. AppCzar must not inspect UI preference values as classification evidence. |
| Presence schema/readability | Bounded read and conditional integrity validation | Present preservation-store health | Yes if the store exists | Retain health because Presence contains durable definitions/checkpoints. Absence is not an Onboarding conclusion. |
| Attachment archive configured root, mode, instance UUID, bookmark/identity, volume availability, read/write state | Existing attachment-location and archive-identity readers, read-only | Present availability plus irreducible configuration | Yes | Retain. A missing configured external archive is remediation, not a reason to silently fall back. |
| Archive adoption transaction/journal | Specialist read-only transaction inspection | Irreducible crash-safety fact for preservation/configuration mutation | Only as “specialist remediation required” | Retain behind archive specialist. AppCzar may observe that remediation is required but must not execute recovery while assessing. |
| Source/import/graph coverage delta | Derived inside the one AppCzar assessment from coherent source and store observations | Present calculation, not persisted fact | Yes | Retain as an ephemeral calculation. |
| Pending attachment preservation work | Read-only comparison of current source attachment evidence with archived metadata/payload eligibility | Present calculation | Yes if launch-time catch-up is a jurisdiction | Retain as ephemeral evidence for `UPDATING`. |
| Retired `macos_import.db` / `working.db` files | File inventory | Historical artifact | No | Remove from normal classification. Report diagnostically or clean only through an explicitly admitted cleanup worker. |
| Current Ball tenure | Process-local registry | Present execution fact | No at launch | There should be no prior-process tenure. It remains a mutation admission concern, not AppCzar evidence. |
| Startup command such as option-launch reset | Current launch request | Current user/operator intent, not environment reality | No for classification | Assess first. If Operating is admitted, the Operating coordinator may execute the explicit reset command and then require restart. |

Observation must be coherent. AppCzar should build one immutable evidence object
with a revision/fingerprint for each mutable source. If a required source changes
during assessment, take one bounded second sample. If it changes again, classify
`CANNOT_DETERMINE`; do not combine facts from different revisions or loop forever.

### Durable-record classification

| Current durable record | Category | Target treatment |
|---|---:|---|
| Apple source data and current filesystem/volume reality | A | Observe directly; do not copy its availability conclusion into app state. |
| Source/import/graph row counts, schemas, and topology | A | Observe from the stores; never persist a second “ready” answer. |
| Source-scoped/graph data produced solely from still-available live sources | A | Materialized data may remain durable, but incomplete instances are disposable. |
| Overlay user intent, favourites, tags, manual links, archive metadata | B | Preserve. Only store health influences AppCzar. |
| Attachment payloads, archive identity/configuration/bookmark | B | Preserve. Never reset or recreate as derived data. |
| Historical-source registry/data whose donor may no longer be available | B | Preserve or route to specialist remediation; never auto-discard. |
| Presence definitions, composition, run history/checkpoints | B | Preserve; do not use an old readiness run as current FDA/source proof. |
| Archive-adoption transaction evidence | B | Retain because the underlying preservation/configuration mutation is not safely disposable. |
| Window size, theme, and other harmless user preferences | B | Retain as preferences; never classify the app. |
| Consecutive initial-build attempt count | B | Add only if the repeated-failure policy is adopted; it controls retry policy, not state. |
| Logs and startup validation telemetry | C | Retain for diagnosis with zero authority. |
| Persisted last import/graph failure details | C | Prefer ordinary logs; if retained, remove all classification/Journey authority. |
| Last sidebar/contact/conversation selection | D | Delete from current-state persistence. Optional history may remain only if never restored automatically. |
| Durable operation status/stage/substage/progress | D | Delete. |
| Resume disposition/safe-boundary conclusion | D | Delete. |
| “Installation completed/ready” conclusion | D | Delete. Current stores prove or disprove health. |
| Prior Journey Trip/Step/waiting state | D | Delete or never introduce. |
| Prior AppCzar/Environment classification | D | Never persist. |

## 4. Evidence AppCzar must never trust

The enforceable blacklist is:

- last rendered screen or panel;
- last sidebar mode;
- last selected contact, conversation, handle, search, or scroll position;
- previous Journey Trip, Step, Episode, action occurrence, or FDA-wait state;
- previous AppCzar or installation classification;
- previous `OnboardingEnvironmentState` or “ready” conclusion;
- durable operation status, stage, substage, progress, process session, resume
  disposition, or success flag;
- a worker success callback, completion callback, or `transitionToOperating`
  request;
- UI progress models or a generic “maintenance in progress” Boolean;
- Ball owner ID, `ownerLabel`, active operation name, or other diagnostic tenure
  metadata as semantic proof;
- old import/graph failure rows as a current failure;
- a Presence schedule's old “required sources accepted” result;
- retired database existence as proof of installation state;
- cached provider output whose source generation is not part of its dependency;
- any historical fact whose claimed current condition can be observed directly.

Architecture enforcement should prohibit the AppCzar package from importing
operation-snapshot, Journey-state, sidebar-flow, panel-state, presentation,
failure-store, and mutation-diagnostic domains.

## 5. Minimum AppCzar state table

`ASSESSING` is the launch phase before classification. The other five values are
the complete classification set. The predicates below must be encoded as
pairwise-exclusive values, not ordered `if` statements whose overlap is hidden.

| Condition | Observable predicate | Chosen coordinator | Terminal | Allowed UI | Mechanically impossible UI |
|---|---|---|---|---|---|
| `ASSESSING` | Required evidence is still being collected or coherently resampled | AppCzar itself; no domain coordinator yet | Not applicable | Factual assessment surface only | Operational shell, sidebar, center, Journey, Settings |
| `ONBOARDING` | Preservation/configuration stores are safe; no complete coherent local message dataset exists; derived data is absent/empty or is a provably disposable incomplete live-source build; source prerequisites may still be unavailable | Onboarding Journey | `OK` only while remaining in Onboarding for current user choice; `RESTART` after reset/build changes classification facts | Self-contained Onboarding UI and its current work/progress | Operational sidebar/center; remediation or update UI |
| `UPDATING` | A complete healthy baseline and all preservation stores exist; required sources/archive are reachable; current source or eligible attachment evidence is ahead of the baseline | Data Update coordinator | Normally `RESTART` after catch-up; no transition to Operating in-process | Factual update progress, cancel/quit where safe | Operational navigation and Onboarding UI |
| `REMEDIATING` | A preservation/configuration problem, required dependency loss on an established installation, corrupt/unsupported store, unsafe mismatch, unavailable configured archive, or incomplete non-live-source state exists | Remediation coordinator, which delegates to the relevant specialist | `RESTART` after any repair; `OK` only for no-change choices such as export logs/quit | One reason-specific remediation surface | Operational navigation, Onboarding, another remediation coordinator |
| `OPERATING` | All required stores and dependencies are healthy and coherent; current source/import/graph/archive facts have no launch-time work requiring another jurisdiction | Operating session coordinator | `OK`; it constructs the user session. Fundamental change or explicit reset returns `RESTART` | Fresh normal app session | Startup/Journey/remediation/update surfaces |
| `CANNOT_DETERMINE` | Inspection failed, remained unstable, or the full evidence set matches zero or more than one valid predicate | Diagnostic coordinator | `OK` for export/quit; `RESTART` for a new assessment | Exact observations, contradiction, retry/relaunch, logs | Normal app, destructive repair, guessed fallback |

“Established installation” is not a persisted flag. It means a currently
readable and internally coherent import/graph baseline with valid topology.
Likewise, “incomplete live-source build” must be proven by the current source
inventory and store contents; non-live historical-source material excludes the
automatic-disposal path.

## 6. Exactly-one-coordinator rule

The classification should be a sealed value whose constructor contains exactly
one coordinator factory. The app root switches exhaustively on that value and
mounts only that coordinator's host. There is no independent provider that can
also decide to show Onboarding, Environment Readiness, a pipeline incident, or
normal application content.

```text
AppCzarCondition
  = OnboardingCondition -> OnboardingJourney
  | UpdatingCondition   -> DataUpdateCoordinator
  | RemediationCondition-> RemediationCoordinator
  | OperatingCondition  -> OperatingSessionCoordinator
  | CannotDetermine     -> DiagnosticCoordinator
```

A coordinator may call workers and specialists. A worker is not a coordinator:
it cannot select presentation, classify the app, or invoke another coordinator.
The coordinator identity remains unchanged while a Journey waits for the user.
`USER` describes who currently has attention, not a second semantic authority.

## 7. Coordinator `OK` versus `RESTART` rule

`OK` means: the completed action did not invalidate the predicate that selected
this coordinator. The coordinator may keep showing its own jurisdiction or, for
Operating, yield attention to the user.

`RESTART` means: work changed, or may have changed, any fact used by AppCzar to
choose jurisdiction. The coordinator stops; it does not calculate the next
condition. The process relaunches and a new AppCzar observes from zero.

Examples:

- opening System Settings or waiting for FDA stays inside the Onboarding
  Journey; its fresh prerequisite test may advance Journey position because
  jurisdiction is still Onboarding;
- completing the initial build is `RESTART`, never “ready to start” followed by
  normal app content;
- completing launch-time catch-up is `RESTART`, never “update succeeded, so now
  Operating”;
- completing Start Fresh is `RESTART`;
- repairing archive configuration or restoring FDA for an established
  installation is `RESTART`;
- exporting logs or declining a retry is `OK` because no classification fact
  changed;
- a bounded live update that begins after an already admitted Operating session
  may finish `OK` if it is ordinary work within that jurisdiction. Failure or a
  fundamental dependency change requests `RESTART`.

## 8. Journey self-location rule

When selected, Onboarding begins at “checking current prerequisites,” not at a
restored episode. It reruns fresh tests for Messages access, source history, and
Contacts; then derives its current Trip/Step in memory. It may remember answers
only for the lifetime of that Journey occurrence.

Journey owns user-visible Onboarding meaning. Workers return typed evidence and
live progress. Presentation projects Journey state. Neither an operation record,
Environment report, nor UI component may independently select an Onboarding
episode.

Onboarding's target state set should stop at work, failure, user choice, and
`RESTART`. `normalApplication`, `reimportReady`, and other post-jurisdiction
episodes should be removed.

## 9. Durable Journey position can be deleted

Yes. No legitimate current Journey position requires persistence.

The current `OnboardingJourneyState` is process-local, but the durable operation
snapshot and reconciliation machinery effectively reconstruct a cross-session
cursor. That reconstruction can be deleted. Waiting for FDA is rediscovered by a
fresh source test. Ready-to-import is rediscovered from current prerequisites.
Interrupted build is rediscovered from incomplete derived stores. Completion is
rediscovered from coherent healthy stores.

What breaks when AppCzar stops consulting the old cursor: automatic resume from
the previous page/stage and exact restoration of a prior Onboarding screen. Both
are intentionally removed. Correctness does not break.

## 10. Durable import resume state can be deleted

Yes, for initial live-source build, graph projection, and rich-text enrichment.

Page, batch, high-water, and anomaly progress may exist in memory while the live
worker runs. Database transactions may commit bounded pages for safety, but no
next process resumes them. An interruption leaves observable partial derived
stores. The next Onboarding occurrence deletes only the enumerated rebuildable
database files and starts a new generation from the beginning.

The same applies to graph projection and rich-text enrichment. Their current
outputs are derived. A fresh build is simpler than validating a durable cursor
against every source/store revision.

Three constraints are non-negotiable:

1. attachment archival during a replay must be idempotent and must never delete,
   replace, or corrupt already preserved payloads;
2. automatic disposal is forbidden when the import inventory contains non-live
   historical sources whose donors may be unavailable;
3. reset remains an explicit filename allow-list and must not reach overlay,
   Presence, archive configuration, or `attachment_archive/`.

## 11. Minimum durable execution/failure facts still required

For disposable Onboarding work, the minimum is:

- one integer `consecutive_initial_build_attempts` in preserved storage;
- ordinary append-only diagnostic logs.

No operation UUID, process session ID, status, stage, substage, completed-stage
set, resume boundary, progress counters, recovery disposition, or completion
proof is required across processes.

Separate specialist transaction evidence remains legitimate where the mutation
itself is not disposable. The attachment archive adoption journal is the clearest
example. That journal protects a preservation/configuration transaction; it is
not an Onboarding cursor and may not declare the app ready.

## 12. Repeated-failure policy

Use the integer counter rather than an append-only attempt ledger. A ledger adds
identity, retention, pruning, and interpretation rules without improving the
policy decision; detailed history already belongs in logs.

Protocol:

1. Immediately before an admitted fresh initial-build mutation begins,
   atomically increment `consecutive_initial_build_attempts`.
2. Do not decrement it from a worker success callback.
3. On a later launch, only when fresh AppCzar evidence classifies `OPERATING`,
   reset the counter to zero.
4. If AppCzar classifies `ONBOARDING` with incomplete/absent derived stores and
   the counter is greater than three, it still selects Onboarding. The counter
   changes only the Journey's retry policy: automatic rebuild is withheld and a
   repeated-failure choice is shown.
5. The choice explains repeated preparation failure, offers package/send logs,
   and may offer an explicit retry. Explicit retry increments the counter again.
6. If the counter cannot be read, it cannot change the classification. Record a
   diagnostic and use the conservative explicit-retry path.

The counter counts started attempts that did not result in a later independently
verified Operating launch. It does not claim why an attempt ended.

## 13. Startup assessment UI model

Before AppCzar completes, the operational app widget tree does not exist.
AppCzar renders a factual list whose rows move from “checking” to the actual
observation:

```text
Checking MessageLens…

✓ Data folder admitted       WD_ELEMENTS / MessageLens Development
✓ Full Disk Access
✓ Messages database          138,832 messages
✓ MessageLens graph          138,822 messages; integrity okay
  New messages                    10
  Attachments waiting              2
✓ Overlay                    integrity okay
✓ Attachment archive         Toshiba_manual_bu; connected; read/write
  Checking final consistency…
```

Rules:

- no percentage or spinner implies progress that is not measured;
- each displayed check is backed by the exact current observation;
- failures stay visible with the failed evidence;
- classification waits for the complete required set;
- one bounded resample handles changing evidence; repeated change becomes
  `CANNOT_DETERMINE`;
- previous session/navigation facts may appear only in a clearly labelled
  diagnostic/history section and never alter navigation or classification.

Reuse the existing bounded inspection, integrity-result, attachment-location,
source-probe, and telemetry presentation pieces. Replace `StartupApp`'s generic
“Checking databases”/admission dialog and remove the Environment Readiness panel
as an independent startup semantic surface.

## 14. Coordinator work UI model

The selected coordinator publishes one in-memory work model. Workers report
typed progress into it. Presentation does not watch the graph builder, snapshot,
failure store, maintenance lock, and Journey separately to infer what is
happening.

Example:

```text
Updating MessageLens…

Importing messages            6 / 10
Preserving attachments         1 / 2
IMG_4821.HEIC
```

Onboarding may continue to show its path, FDA instructions, choices, and errors,
but all come from its in-memory Journey state. A reset action can show exact
allow-listed reset phases from its live worker. The durable operation snapshot,
Journey operation projection from persisted evidence, generic pipeline incident
panel, and center-panel sync controller become unnecessary.

## 15. Fresh Operating session model

Each newly admitted Operating session begins as:

```text
sidebar mode             = Messages
top choice               = Conversations
selected conversation    = null
selected contact         = null
selected handle/search   = null
center                    = null
right panel               = null
```

`SidebarFlow` remains the in-memory semantic authority for navigation during the
Operating session. The center remains a pure derivation of the current flow plus
explicit sidebar-independent actions initiated in that same session.

Delete automatic loading/writing of `sidebar_flow_navigation` and
`sidebar_contact_context`. Window geometry and theme may still restore because
they do not select app content. If “resume where I left off” is later desired,
design it as an explicit user-invoked history feature that validates current
entities before applying a choice; it is not launch state.

This directly prevents the Prompt 38 stale-contact center. It also reduces the
display-identity problem's impact: no pre-build contact surface can mount. The
resolver must still watch `messageDataVersionProvider` (or be rebuilt with the
Operating generation) so identity caches cannot survive a graph generation
change inside a live session.

## 16. Ongoing FDA/remediation model

AppCzar distinguishes the same missing dependency by current surrounding facts:

```text
FDA absent + no complete local dataset
  -> ONBOARDING

FDA absent + complete established dataset
  -> REMEDIATING (lost-FDA reason)
```

Other examples:

- source DB unreadable with no complete baseline -> Onboarding source step;
- source DB unreadable with a complete baseline -> Remediation, not silent
  Operating;
- source ahead of a healthy graph -> Updating;
- import and graph coherent but source is behind them -> Remediation because
  automatic deletion could lose history;
- graph missing/empty and no historical-source material -> Onboarding;
- readable partial live-only import/graph -> Onboarding, allow-listed cleanup,
  full rebuild;
- graph corruption, unsupported schema, or impossible topology -> Remediation;
- configured external archive unavailable or identity invalid -> Remediation;
- overlay corrupt/unsupported -> Remediation because user intent is protected;
- Presence corrupt/unsupported -> Remediation because it is durable state;
- archive-adoption transaction incomplete -> Remediation delegated to the
  archive specialist;
- incompatible facts or repeated assessment instability -> Cannot Determine.

This requires no old workflow state. The reason is carried as current evidence
inside the selected condition, not as another top-level state authority.

## 17. Ball/track relationship

The relationship remains deliberately orthogonal:

```text
AppCzar: What condition exists, and which coordinator has jurisdiction?
Ball:    Which exact live scope may mutate which protected resource now?
```

AppCzar never owns the Ball and never classifies from Ball tenure. A selected
coordinator may acquire the Ball through `ArchiveMutationCoordinator`, pass the
opaque callback-local capability to admitted workers, and release it when the
scope ends. Feature 35's exclusive tenure registry remains the sole process-local
mutation authority.

The future clarity rename from `ownerLabel` to `diagnosticOwnerLabel` remains
appropriate. The label is diagnostic metadata, never proof and never AppCzar
evidence.

## 18. Current semantic-authority census

The table groups generated providers with their annotated source and closely
coupled domain object. “Authority” here means semantic state authority, not
database ownership or typed mutation tenure.

| Current production mechanism | Current influence | Target classification |
|---|---|---|
| `_admitArchive`, `ArchiveAccessAuthority`, root marker/policy | Chooses and admits the physical root before app startup | **DEMOTE TO EVIDENCE** as bootstrap safety/admission; not app classification |
| `StartupFlagsService.optionLaunchResetRequested` | Forces startup reset dialog | **KEEP AS EVIDENCE** of current command intent; execute only under selected coordinator |
| `messageLensInstallationStateProvider` | Publishes startup admission/classification | **MERGE INTO APPCZAR** |
| `MessageLensInstallationValidationService` | Orchestrates bounded/deep startup inspection and semantic admission | Split: **KEEP AS WORKER** for inspection; **MERGE INTO APPCZAR** for classification/admission |
| `MessageLensInstallationStateClassifier` / `MessageLensInstallationState` | Decides virgin/resumable/completed/abandoned/remediation | **DELETE** after predicates are replaced by AppCzar; resumable/completed conclusions do not survive |
| `MessageLensInstallationIntegrityPolicy` | Decides when deep validation is required from current and snapshot facts | **MERGE INTO APPCZAR**, removing operation-snapshot triggers |
| SQLite installation evidence reader/integrity validator | Reads current store schema/count/topology/integrity | **KEEP AS WORKER / DEMOTE TO EVIDENCE** |
| `StartupInstallationValidationState` and startup telemetry buffer | Drives startup UI and records diagnostics | Simplify; **KEEP AS PRESENTATION** facts and diagnostic telemetry, not admission authority |
| `StartupApp`, restricted startup shell, reset/admission dialogs | Gates normal `App` and maps current classifier result to UI | **MERGE INTO APPCZAR** host/presentation; delete current semantic branching |
| automatic attachment-adoption recovery in persistent startup | Mutates/reconciles after “completed” classification | **DELETE** from startup; route current incomplete transaction to Remediation specialist |
| `OnboardingEnvironmentReport` / evaluator/provider | Independently classifies permission/source/failure/maintenance/ready | Split low-level probes; **MERGE INTO APPCZAR** for launch facts and **MERGE INTO JOURNEY** for prerequisite facts; delete global semantic enum |
| Onboarding database probe reader, FDA/source/history/Contacts agents | Supply current observations | **KEEP AS WORKER / DEMOTE TO EVIDENCE** |
| retired Presence required-source schedule/providers | Historical laboratory readiness acceptance | **DELETE** from production composition; old run completion must never prove current readiness |
| `OnboardingJourneyCoordinator` | Sole current Onboarding semantic authority, but also adopts snapshots/reimport/normal-app states | **MERGE INTO JOURNEY** and simplify to one in-memory Onboarding occurrence |
| `OnboardingJourneyState` | Onboarding episodes plus normal/reimport semantic states | **MERGE INTO JOURNEY**; remove post-Onboarding episodes |
| `OnboardingGate` / `OnboardingStatus` | Compatibility projection and forwarding API | **DELETE** |
| overlay/readiness action providers | Forward presentation actions to Journey | **KEEP AS PRESENTATION** only if a thin command seam remains; otherwise absorb into Journey host |
| operation snapshot domain/controller/provider/overlay store | Durable operation status, identity, phase, progress, failure, resume | **DELETE** |
| operation reconciliation and Journey operation projection | Converts snapshot/report into resumable/completed Journey meaning | **DELETE**; replace only live progress with an in-memory worker model |
| persisted Onboarding failure store/storage | Old failures influence Environment/Journey | **DELETE** as authority; prefer logs. Any retained detail is diagnostic-only |
| durable completion verifier | Worker claims install readiness after build | **KEEP AS WORKER** only for a final consistency check before `RESTART`; its proof cannot create Operating |
| `VirginOnboardingImportExecutor` | Wraps build in durable snapshot grammar | **KEEP AS WORKER** after removing snapshot grammar; it starts a full live generation |
| graph build/import/rich-text projectors and progress reporters | Perform derived work | **KEEP AS WORKER**, progress in memory only |
| `MessageDataResetService`, `StartFreshService`, advanced Start Fresh action | Allow-listed derived-store reset and reset presentation | **KEEP AS WORKER / PRESENTATION**; remove completion handoff; finish `RESTART` |
| advanced Start Fresh presentation controller | Independently publishes reset phases/success | **KEEP AS PRESENTATION** only while owned by Operating/Journey; success requests restart, not Onboarding transition |
| `ArchiveMutationCoordinator`, `ExclusiveAuthorityRegistry`, capability/resource admission | Sole protected-resource mutation tenure | **KEEP AS AUTHORITY** for mutation only; never app semantics |
| `dbMaintenanceLockProvider` and archive `isLocked` projections | Suppress readers; currently leak into Environment semantics | **KEEP AS WORKER** compatibility/resource-safety signal; remove from AppCzar/Journey meaning |
| attachment archive location/configuration/adoption controllers and transaction store | Own archive configuration and crash-safe adoption facts | **KEEP AS WORKER** plus irreducible durable facts; location evidence feeds AppCzar |
| `ChatDbChangeMonitor` | Startup/in-session delta detection, graph update, attachment sweep | Split launch probe into **DEMOTE TO EVIDENCE** for AppCzar; **KEEP AS WORKER** under Operating for later changes |
| graph health/readiness/status providers | Report current graph state | **DEMOTE TO EVIDENCE**; no competing ready state |
| `messageDataVersionProvider` | In-process graph generation invalidation | **KEEP AS AUTHORITY** only for cache currentness inside Operating, never top-level state |
| `displayIdentityResolverProvider` and readers that capture it | Resolve graph/overlay identities; currently may outlive graph generation | **KEEP AS WORKER**; bind to message-data generation or Operating occurrence |
| `SidebarFlow` / `SidebarFlowState` | Current sidebar and projected center authority | **KEEP AS AUTHORITY** only inside an Operating occurrence, initialized fresh |
| SidebarFlow preference store and overlay navigation keys | Restore/persist selected content across processes | **DELETE** |
| `CassetteRackState`, ephemeral cassette projection, sidebar dispatcher | Projects/handles current Operating navigation | **KEEP AS PRESENTATION / WORKER** under fresh SidebarFlow |
| `PanelsViewState`, effective center/right providers, panel coordinator | Holds transient panel stack and combines it with SidebarFlow | Simplify; **KEEP AS PRESENTATION** for session-local independent panels; center content remains derived from current Operating state |
| `OnboardingCenterPanelSyncController` and observer | Imperatively installs/clears readiness/incident center panels | **DELETE** |
| active sidebar mode | Chooses Messages/Settings in normal app | **KEEP AS AUTHORITY** only in Operating, initialized to Messages |
| window-state service | Restores size/placement after completed classification | **KEEP AS WORKER** for geometry only; remove content/navigation authority |

After migration, the semantic authorities are only:

1. AppCzar for top-level jurisdiction;
2. the one selected coordinator within that jurisdiction;
3. SidebarFlow for navigation only inside an Operating session;
4. Feature 35 tenure for mutation authority, which is deliberately not semantic
   app state.

## 19. Deletion/demotion map

| Major mechanism | Target |
|---|---|
| Installation classifier | **Absorb** current read-only evidence and deep validation into AppCzar; **delete** current five-state historical classifier |
| Environment Readiness | **Split and absorb** probes; **delete** global readiness classifier and center-panel feature as startup authority |
| Durable operation snapshot | **Delete** domain, provider, controller, overlay persistence, generated code, and architecture dedicated to resume semantics |
| Restart reconciliation / resume disposition | **Delete** |
| Durable Journey state | **Delete/not introduce**; Journey is in-memory |
| Live Journey/import progress | **Make in-memory only** |
| Persisted failure rows | **Make diagnostic-only or delete** in favor of logs |
| Consecutive-attempt fact | **Add one integer**, policy-only |
| SidebarFlow current navigation persistence | **Delete** reads/writes/keys/store/provider |
| SidebarFlow itself | **Retain and simplify** as Operating-session authority |
| Stored center-panel state | **Retain only session-local explicit panels**; delete startup/readiness synchronization and never persist content selection |
| Display identity currentness | **Retain resolver but bind it to graph generation/Operating occurrence**; no startup role |
| Maintenance lock projected into app semantics | **Delete projection**; retain only I/O suppression/resource safety |
| Startup splash/restricted shell | **Replace** with factual AppCzar assessment host |
| Reset/onboarding completion handoffs | **Delete**; terminal is `RESTART` |
| `normalApplication` Journey episode | **Delete** |
| automatic startup adoption recovery | **Move** to Remediation coordinator specialist |
| Graph/import/reset/archive workers | **Retain** beneath coordinators |
| Feature 35 Ball/track | **Retain unchanged** except future diagnostic label rename |

## 20. Mechanical Impossibility rules

1. When AppCzar is Assessing, the operational application widget tree is not
   constructed.
2. A final AppCzar condition contains exactly one coordinator factory.
3. When Onboarding governs, operational sidebar, center, Settings, monitors, and
   normal graph consumers are not constructed.
4. When Updating or Remediation governs, neither Onboarding nor operational
   navigation is constructed.
5. When Operating governs, installation/Journey/update/remediation presentation
   is not constructed.
6. Non-Operating condition types cannot contain conversation/contact/handle or
   panel-selection fields.
7. Operating construction always creates the fixed fresh navigation state.
8. Center content is a pure projection of the current Operating occurrence's
   SidebarFlow or an explicit same-session independent panel action.
9. Persisted navigation values are not imported by AppCzar, coordinators, or
   Operating navigation.
10. A coordinator cannot import another coordinator's public composition seam
    or construct another coordinator.
11. Workers return evidence/progress/results only; result types cannot contain an
    AppCzar condition or coordinator selection.
12. A coordinator that changes a classification predicate can return only
    `RESTART`.
13. Only AppCzar's fresh assessment constructor can create `OperatingCondition`.
14. Persisted facts cannot directly construct presentation state.
15. AppCzar cannot import snapshot, Journey, sidebar, panel, failure-history, or
    Ball diagnostic types.
16. Ball capability remains callback-local and cannot be retained in AppCzar or
    presentation.
17. Derived-store cleanup accepts only the existing enumerated basenames; the
    archive, overlay, and Presence types are unrepresentable as reset targets.
18. A build containing non-live source inventory cannot enter automatic disposal.
19. Every assessment must prove exactly one predicate; an assertion plus a
    production check routes zero/multiple matches to `CANNOT_DETERMINE`.
20. No worker success path may call `show App`, set `ready=true`, or publish
    `normalApplication`.

## 21. Sixteen-scenario walkthrough

### 1. First launch, no FDA

```text
no FDA; source unreadable; preservation stores safe; no complete graph
-> ONBOARDING
-> Onboarding Journey shows Messages-access step
-> OK while waiting/choosing, or quit
-> next launch reruns the same observations
```

### 2. FDA granted during Onboarding

```text
Onboarding's fresh source test becomes readable
-> jurisdiction remains ONBOARDING
-> same Journey self-locates at the next prerequisite/import step
-> OK while choosing; RESTART only after derived build completes
-> next launch is freshly classified
```

### 3. Quit while waiting for FDA

```text
no build; no durable Journey cursor
-> current process exits from ONBOARDING
-> no semantic terminal handoff
-> next launch observes FDA again and chooses the appropriate jurisdiction
```

### 4. Killed halfway through initial import

```text
partial live-only import/graph; no complete coherent baseline; preservation safe
-> ONBOARDING
-> Journey increments attempt policy, allow-list deletes derived stores, rebuilds from zero
-> RESTART after final consistency check
-> fresh launch may classify OPERATING
```

### 5. Killed after import completed but before an old success flag

```text
source/import/graph/archive observations are complete, healthy, coherent, current
-> OPERATING (the absent old success flag is irrelevant)
-> Operating session coordinator
-> OK; attempt counter resets because fresh AppCzar verified Operating
```

### 6. Import fails more than three times

```text
incomplete live-only derived stores; attempt count > 3
-> ONBOARDING (counter does not classify)
-> Journey withholds automatic retry and offers logs plus explicit retry
-> OK for export/quit; explicit rebuild eventually ends RESTART
-> next launch reassesses reality
```

### 7. Healthy launch, no new messages

```text
all preservation/dependency/store checks pass; no source/archive delta
-> OPERATING
-> Operating session coordinator constructs fresh empty navigation
-> OK
```

### 8. Healthy launch, 10 new messages and 2 attachments

```text
healthy coherent baseline; source ahead by 10; 2 eligible payloads pending
-> UPDATING
-> Data Update coordinator shows exact live progress under Ball tenure
-> RESTART after committed catch-up
-> fresh launch may classify OPERATING
```

### 9. Healthy app loses FDA between sessions

```text
FDA/source unreadable; established coherent graph remains
-> REMEDIATING (lost-FDA reason)
-> Remediation coordinator shows current access instructions
-> RESTART after access is restored
-> fresh launch reassesses
```

### 10. Graph integrity failure

```text
graph exists but bounded/deep integrity or required topology fails
-> REMEDIATING
-> graph remediation specialist; no normal reads
-> RESTART after an explicitly safe repair/rebuild
-> fresh launch reassesses
```

### 11. External archive missing

```text
configured custom archive identity exists; volume/root unavailable
-> REMEDIATING
-> archive-location remediation; no fallback and no payload mutation
-> RESTART after availability/configuration changes
-> fresh launch reassesses
```

### 12. Start Fresh completes

```text
Operating user explicitly authorizes allow-listed derived reset
-> current jurisdiction remains owned by Operating coordinator during worker action
-> same coordinator returns RESTART; it does not invoke Onboarding
-> fresh launch sees no complete graph and chooses ONBOARDING
```

### 13. User quits during reset/rebuild

```text
next launch observes absent/partial live-only derived stores; preservation intact
-> ONBOARDING
-> full allow-listed cleanup/rebuild, subject to attempt policy
-> RESTART after completion
-> fresh launch reassesses
```

### 14. Graph/source counts disagree

```text
if source is provably ahead of a coherent baseline
-> UPDATING -> Data Update coordinator -> RESTART

if graph/import is ahead of source, internally inconsistent, corrupt, or contains non-live sources
-> REMEDIATING -> reason-specific specialist -> RESTART after safe action

if it is a provably partial live-only build with no coherent baseline
-> ONBOARDING -> discard/rebuild -> RESTART
```

### 15. Stale previous contact/conversation navigation exists

```text
old overlay keys may physically exist during migration but are blacklisted
-> classification depends only on current environment/store facts
-> chosen coordinator is unaffected
-> OPERATING starts Conversations with no selection and empty center
```

### 16. Contradictory evidence fits no valid classification

```text
complete sample matches zero or multiple predicates, or remains revision-incoherent
-> CANNOT_DETERMINE
-> Diagnostic coordinator shows the exact contradiction and offers logs/relaunch
-> OK for export/quit or RESTART for a new assessment
-> never guess Operating or mutate data
```

## 22. Existing architecture pieces that can be deleted

- `MessageLensInstallationStateKind`'s virgin/resumable/completed/abandoned
  semantic model and the classifier that interprets snapshots;
- operation-snapshot fields, controller, provider, store, generated provider,
  reconciliation, resume disposition, process-session identity, and snapshot
  architecture built around cross-session progress;
- persisted source-import/graph failure rows as semantic inputs;
- `OnboardingEnvironmentState` as a global readiness authority;
- `OnboardingGate` and `OnboardingStatus` compatibility projection;
- Journey startup adoption/reconciliation of historical snapshots;
- Journey episodes for normal application and completed reimport handoff;
- generic Environment Readiness and pipeline-incident center authority;
- `OnboardingCenterPanelSyncController` and its observer;
- SidebarFlow navigation/contact preference persistence, serializers, overlay
  store/provider, and automatic restore tests;
- automatic attachment-adoption recovery during “completed” startup;
- retired Presence required-source readiness composition from production;
- reset/import completion callbacks that select or expose normal application;
- startup UI branches whose only purpose is the old admission model.

Generated files and tests dedicated solely to those contracts should disappear
with them rather than be adapted to preserve obsolete concepts.

## 23. Existing architecture pieces worth retaining

- archive root/environment/build/instance admission and canonical-path safety;
- bounded read-only database evidence readers and guarded source probes;
- conditional full integrity validators and truthful contention handling;
- source-scoped import and graph topology/provenance readers;
- the central database providers and overlay/graph separation;
- the source import, rich-text enrichment, graph projection, and attachment
  preservation workers;
- the existing allow-listed `MessageDataResetService` and preservation tests;
- overlay user intent, Presence data, historical-source material, archive
  metadata/configuration, adoption journal, and attachment payloads;
- Feature 35 `ExclusiveAuthorityRegistry`, `ArchiveMutationCoordinator`, typed
  operations, exact resource admission, and callback-local capability;
- live progress reporters, converted to one coordinator-owned in-memory model;
- Journey's source-readiness specialists and FDA instructions;
- SidebarFlow's same-session invariants and pure center projection;
- `messageDataVersionProvider` as a same-process cache generation, with the
  identity resolver made dependent on it;
- logging, diagnostic packaging, and startup telemetry with zero semantic
  authority;
- window geometry/theme restoration, separated from content navigation.

## 24. Migration risks

1. **Attachment preservation replay.** Before deleting resume state, prove that a
   full replay is idempotent with respect to already archived payloads and never
   replaces the only preserved copy.
2. **Historical sources.** Do not classify all import/graph stores as disposable.
   Non-live source inventory must mechanically block automatic deletion unless
   its donor is proven available and a separately reviewed rebuild plan exists.
3. **AppCzar observation cost.** Full integrity checks on every healthy launch may
   be too slow. Keep bounded probes every launch and invoke deep integrity only
   from current anomalies/schema triggers; do not solve latency by trusting an
   old ready flag.
4. **Coherent source sampling.** `chat.db` can change during assessment. Counts,
   high-water identity, ledger cursor, and pending attachments need a bounded
   coherence rule.
5. **Root-admission ordering.** Some safe root/marker admission must precede
   opening app databases. Keep it as a non-semantic bootstrap boundary rather
   than pretending AppCzar can inspect an unadmitted root.
6. **Presence policy.** Presence is preserved. Confirm whether a corrupt Presence
   store should block the whole app or only the Presence feature before fixing
   its final AppCzar predicate.
7. **Contacts policy.** Confirm whether loss of live Contacts should block an
   established Operating session. The minimal design says no; Onboarding/Update
   tests it when needed.
8. **Launch-time update threshold.** Decide whether every detected delta uses
   `UPDATING`, or whether a tiny delta may be owned by Operating after admission.
   The state model supports either, but there must be one rule.
9. **Restart implementation.** Relaunch must be reliable on macOS and testable
   without a coordinator directly constructing the next app state.
10. **Reset command during Operating.** Keep the explicit authorization and exact
    typed Ball tenure; remove only the semantic handoff.
11. **Provider lifecycle.** Ensure non-Operating composition cannot eagerly create
    graph readers, monitors, SidebarFlow, or panel providers.
12. **Migration from old overlay keys.** Stop reading immediately. Deleting old
    keys can be a bounded maintenance step, but their physical presence is safe
    if permanently ignored.
13. **Diagnostics after snapshot deletion.** Ensure logs capture operation start,
    progress milestones, failure, and attempt count without becoming an implicit
    recovery protocol.
14. **Test replacement.** Existing tests encode resume/admission semantics. Delete
    them with the feature and add property/architecture tests for exclusivity,
    blacklist imports, and all scenario predicates.

## 25. Migration sequencing recommendation

Implement deletion-first in reviewable gates:

1. **Freeze predicates in tests.** Define the immutable evidence object, the six
   conditions including Assessing, and property tests proving exactly one final
   predicate or Cannot Determine for the scenario matrix. No UI change yet.
2. **Build AppCzar from existing readers.** Reuse bounded probes/integrity
   workers, add coherent source/archive sampling, and keep its package unable to
   import all blacklisted types.
3. **Introduce the root host.** Make the app root construct only AppCzar's factual
   assessment UI and then exactly one coordinator host. Do not retain StartupApp
   as a parallel gate.
4. **Simplify Onboarding.** Remove snapshot adoption/reconciliation, normal-app
   episodes, reimport completion handoff, and cross-session resume. Add the
   in-memory work model and the attempt counter.
5. **Prove full-rebuild preservation.** Qualify interrupted import, graph, rich
   text, and attachment replay in isolated fixtures before enabling automatic
   partial-build deletion.
6. **Create Updating and Remediation coordinators by absorption.** Move existing
   monitor/recovery/settings specialists beneath them. Do not create new semantic
   report providers.
7. **Replace terminal handoffs with restart.** Initial import, launch update,
   repair, and Start Fresh all stop and relaunch.
8. **Delete old semantic machinery.** Remove installation classifier, snapshot,
   reconciliation, failure authority, Environment semantic state, gate/status,
   readiness/incident center sync, and automatic startup recovery.
9. **Make Operating fresh.** Remove SidebarFlow persistence/restore, set the fixed
   initial state, and bind identity caches to the Operating graph generation.
10. **Close architecture boundaries.** Add AST enforcement for one AppCzar
    constructor seam, one coordinator mapping, forbidden imports, callback-only
    Ball capability, no worker-to-condition result, and no persisted-navigation
    consumer.
11. **Run clean-slate and remediation qualification.** Exercise all 16 scenarios
    with isolated fixture roots before any real development archive rehearsal.

At each gate, remove superseded code in the same change. Do not leave the new
AppCzar layered over the old classifiers “temporarily” beyond that gate.

## 26. Estimated net change in conceptual/state complexity

The current top-level control vocabulary includes at least:

- five installation kinds;
- seven Environment states;
- fourteen Journey episodes;
- five operation statuses, four stages, multiple substages and recovery
  dispositions;
- compatibility Onboarding statuses;
- startup validation/admission states;
- readiness/incident panel synchronization;
- persisted SidebarFlow/current-center interactions.

The target top-level vocabulary is:

- one transient phase: Assessing;
- five final jurisdictions: Onboarding, Updating, Remediating, Operating,
  Cannot Determine;
- two coordinator terminals: OK and Restart;
- three foreground attention modes: Assessing, Coordinator Running, User.

Journey retains only its own prerequisite/work/user-choice steps. Ball retains
only mutation tenure. SidebarFlow retains only same-session Operating
navigation. This should delete several domain enums, multiple overlay records,
two compatibility layers, and the most complicated portion of the Journey
coordinator. The expected net result is substantially fewer files/providers and
roughly an order-of-magnitude fewer cross-product state combinations at startup.

## 27. Unresolved product decisions

Only four decisions remain before implementation design can be finalized:

1. Is live Contacts reachability mandatory for an already-established Operating
   session, or only for Onboarding/Update work? Recommendation: only for work
   that consumes Contacts.
2. Does a corrupt Presence store block all Operating, or produce a Presence-only
   remediation while the rest of the app remains usable? Preservation requires
   no silent recreation either way.
3. Must every launch-time message/attachment delta use the foreground Updating
   coordinator, or is there a small-delta threshold that Operating may absorb?
   Recommendation: foreground Updating at first for deterministic qualification.
4. What exact explicit user action is offered after more than three attempts:
   retry immediately, package logs, contact developer, or all three?

None requires retaining a durable Journey cursor, operation snapshot, navigation
restore, or competing readiness authority.

## 28. Prompt 39 remains superseded

Yes. Prompt 39 remains superseded. The two local Response 38 fixes were not
implemented in this task and should not be implemented independently before the
AppCzar design is reviewed. The target architecture deletes hidden navigation
restoration outright and separately makes identity resolution generation-aware
inside a fresh Operating occurrence.

## 29. Exact Git/worktree/index/submodule state

At audit start and again before writing this response:

- worktree: `/Users/rob/Development/FlutterProjects/remember_every_text`;
- branch: `fix/onboarding-import-stuck-state`;
- HEAD/upstream:
  `9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`;
- index: empty;
- tracked worktree: the 29 accumulated Prompt 32 + Prompt 35 modified files,
  unchanged by this audit;
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- Prompt 39 implementation: absent;
- tracked `git diff --check`: passed before and after Response 40 was created;
- Response 40 standalone whitespace check: passed;
- untracked paths: 65 total, consisting of the previously known unrelated
  prompt/response and local files, Prompt 40, and this new Response 40. The only
  untracked path added by this audit is Response 40.

## 30. Confirmation nothing was modified

No source file, test, generated file, database, archive configuration, attachment
payload, real archive, production data, build artifact, index entry, commit, or
branch was modified. MessageLens Development was not launched. Start Fresh and
import were not run. No Prompt 39 implementation occurred.

The only filesystem change made for Prompt 40 is this Response 40 architecture
document in the requested `responses/` folder.

`APPCZAR SIMPLIFICATION DESIGN COMPLETE: YES`

`TARGET CONTROL MODEL HAS ONE TOP-LEVEL SEMANTIC AUTHORITY: YES`

`DURABLE JOURNEY CURSOR REQUIRED: NO`

`INTERRUPTED INITIAL IMPORT RESUME REQUIRED: NO`

`READY FOR HUMAN ARCHITECTURE REVIEW BEFORE IMPLEMENTATION: YES`
