# MessageLens Feature 34
## Response 90 — Checkpoint Stage 2B and Audit Operating-Owned Start Fresh (Stage 2C)

Date: 2026-10-11

This was an audit/design-only task. No application source, test, generated file,
release metadata, fixture, archive, database, app, permission, or environment was
changed or exercised.

## 1. Baseline Git and source provenance

The required baseline was established before source tracing:

- repository: `/Users/rob/Development/FlutterProjects/remember_every_text`;
- branch: `fix/onboarding-import-stuck-state`;
- `HEAD`: `0c2ce29c17b44afb36790d675f5e0b364ab5cc2e`;
- upstream: the same commit, ahead/behind `0/0`;
- `HEAD` tree: `02e26c26cc168b42fb9af7e8d8581fe9d8a9b6de`;
- tracked worktree: clean;
- index: clean;
- Stage 2B implementation commit
  `3c5a5774aeea20d32587e00c0b75d046043ba9fb` is the direct parent of `HEAD`;
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- four repository worktrees exist, but only the primary worktree carries the
  Feature 34 branch;
- all pre-existing unrelated untracked files were left untouched.

An external source/Git-only provenance manifest was written at:

`/private/tmp/messagelens-prompt90-baseline-manifest.md`

Its SHA-256 is:

`01f08fb169c780cb10e611e96d7a0620224d5a3202914c7ea079f6c8159da090`

The manifest records branch, commit, upstream, tree, tracked-index manifest,
status, submodule, worktree, and Prompt/Response 89 provenance. It contains no
data-root, database, archive, or application probe.

## 2. Prompt 89 / Response 89 checkpoint

Prompt 89 and Response 89 were already committed and pushed in the narrow
documentation commit:

`0c2ce29c17b44afb36790d675f5e0b364ab5cc2e`

That commit contains only those two documentation paths. Exact repository blob
and content hashes were verified, and upstream is synchronized. They were not
recommitted.

The checkpointed status is:

```text
Stage 2B source-neutral support and Environment evidence: IMPLEMENTED
Existing exporter privacy/behavior: PRESERVED
AppCzar already-completed assessment projection: IMPLEMENTED
Stage 2A neutral Messages-source boundary: UNCHANGED
Production activation: UNCONDITIONALLY DISABLED
Stage 2C Start Fresh authority/lifecycle: NOT YET IMPLEMENTED
Production cutover: NOT AUTHORIZED
```

## 3. Seven-jurisdiction and production-disabled census

The source still has exactly seven intended AppCzar jurisdictions:

1. Data Update;
2. Source Access Repair;
3. Attachment Archive Repair;
4. Onboarding;
5. Local Data Repair;
6. Diagnostic Review;
7. Operating Session.

The composition path remains:

```text
native/Dart archive admission
  -> immutable ArchiveAccessAuthority
  -> official development composition, or
     official production eligibility plus disabled activation
  -> development: AppCzarStartupHarness
  -> production: legacy StartupApp
```

Production AppCzar activation remains an unconditional false gate. The official
production eligibility seam does not activate it. The qualified process
restarter also remains development-only.

Start Fresh is not a currently admitted AppCzar command. In `main.dart`,
`settingsResetMessageDataActionAvailableProvider` is overridden to false for the
AppCzar development composition. The neutral
`AppCzarOperatingSessionApp` mounts `MessageLensWorkspaceShell` and the
Operating currentness status host, but not the legacy Journey-owned
`AdvancedStartFreshOverlayHost`. This is why the AppCzar development path
currently suppresses the action.

Later Stage 2C UI gating should consume the already selected composition/session
identity: an exact current Operating occurrence in the selected AppCzar
composition. It must not infer command authority from a development bundle
name, a stored boolean, or the narrower WD/archive adoption policy. This does
not broaden production activation or attachment-adoption authority.

## 4. Exact Settings reset action and dispatch graph

The current user path is:

```text
Settings action-list resolver
  -> ResetMessageDataRequested
  -> settings action-list action provider
     (one active intent; state set before awaiting dispatch)
  -> SidebarActionDispatcher
  -> advancedStartFreshActionProvider
  -> AdvancedStartFreshAction.request()
```

The Settings row and explanatory panel are normal Settings specification and
dispatch surfaces. The action-list provider already prevents a second Settings
intent while one is active and renders the existing checking/disabled state.
Those normal-user surfaces are reusable.

The authority behind the dispatcher is not reusable in AppCzar: it resolves
`advancedStartFreshActionProvider`, which is explicitly tied to legacy
Onboarding/Journey presentation and completion.

## 5. Exact legacy Start Fresh / Journey dependency inventory

The present `AdvancedStartFreshAction` owns a process-local `_activeRequest`.
Duplicate calls join the exact same Future, fixing the earlier double-submit
incident. It then:

1. reads the current installation state;
2. requires the advanced completed-state entry condition;
3. presents the legacy authorization dialog;
4. starts the legacy Start Fresh presentation;
5. invokes `StartFreshService`;
6. publishes terminal presentation state;
7. waits for Journey-owned overlay dismissal.

The provider graph constructs or reaches:

- the advanced current-state reader;
- the legacy authorization dialog and presentation controller;
- `StartFreshService`;
- Onboarding operation snapshot/failure controllers;
- Presence scheduling state;
- the full installation validator;
- the Onboarding gate/environment refresh path;
- Journey presentation and dismissal state.

`MacosAppShell` mounts Journey and `AdvancedStartFreshOverlayHost`; the neutral
AppCzar Operating shell does not. The legacy overlay's verified-virgin outcome
waits for Onboarding ownership and supports an in-process retry/return-to-
Settings presentation. These are semantic authorities and presentation
dependencies to remove from the AppCzar command, not components to transplant.

Historical operation snapshot, failure, pipeline-incident, Presence, and
support evidence may remain diagnostic records, but none may vote on current
Start Fresh authority.

## 6. `StartFreshService` current eligibility and consent behavior

The advanced action admits the normal Settings command from a completed
installation. `StartFreshService` independently accepts either its legacy
`mayStartFresh` incomplete states or the completed advanced-reset state. The
authorization dialog describes deletion of rebuildable message/conversation
data and promises a return to Onboarding.

After admission, `StartFreshService` currently performs semantic preparation
that is incompatible with Stage 2C's preservation model:

- resets the Onboarding operation snapshot to idle;
- clears the source-import and graph-projection failure records;
- supersedes a Presence run-from-beginning schedule when present;
- invokes the reset with `includeRetired: true`;
- validates a semantic `virgin` installation inside the same process;
- invalidates/refreshes legacy environment and Onboarding gate state;
- hands presentation to Journey rather than ending at a process boundary.

The traced service did not establish a safe current-source membership proof for
every derived message before deletion. Human confirmation is therefore broader
than the positive evidence required by Prompt 90. It cannot be reused as the
Stage 2C authority.

## 7. `MessageDataResetService` exact active/retired deletion footprint

The lower file-store allow-list is exact. It can delete each database base file
and its `-wal` and `-shm` sidecars:

```text
active:
  macos_import_ss.db
  macos_import_ss.db-wal
  macos_import_ss.db-shm
  working_ss.db
  working_ss.db-wal
  working_ss.db-shm

retired when includeRetired == true:
  macos_import.db
  macos_import.db-wal
  macos_import.db-shm
  working.db
  working.db-wal
  working.db-shm
```

The current Start Fresh entry calls the lower worker with retired cleanup
enabled. That inheritance is unsafe for Stage 2C. Retired stores can be unique,
unsupported, or diagnostic evidence and must not be deleted by this command.

The file store rejects path traversal, operates only on expected basenames, and
does not follow a symlink as a regular reset target. Those mechanics are useful.
The current Start Fresh path, however, does not use Local Data Repair's strong
before/after preserved-witness postcondition. It also logs a remaining target
instead of making that condition an unavoidable physical failure at the lower
boundary. Both limitations must be corrected in the narrow extracted Stage 2C
worker.

## 8. Protected file, store, table, and operation-evidence inventory

| Resource | Existing Start Fresh | Rebuildability / unique-data risk | Stage 2C rule and proof |
|---|---|---|---|
| Active `macos_import_ss.db` plus WAL/SHM | Deleted | Derived rows, but includes source registry/provenance and may contain messages absent from current source | Delete only after a fresh, stable, current-source membership and lineage proof shows every affected row belongs to the available live source and is reconstructible; postcondition requires all exact targets absent. |
| Active `working_ss.db` plus WAL/SHM | Deleted | Derived graph, FTS, chat topology, and attachment joins; rebuildability depends on proven import/source evidence | Delete only in the same exact proven plan as the import store; no separate graph-only assumption. |
| Retired `macos_import.db` / `working.db` plus sidecars | Deleted by the current `includeRetired` path | May contain unique/unsupported historical evidence | Preserve. Their presence makes Start Fresh ineligible and routes a later fresh AppCzar assessment to Diagnostic Review. |
| `user_overlays.db` | Base DB is not deleted, but legacy Start Fresh changes Onboarding snapshot/failure/settings evidence within it | Contains favourites, labels, manual links, settings, historical-source registry, archived-attachment evidence, operation/failure/support state | No Stage 2C write. Byte/equivalent witness must remain stable. Any uninspectable or incompatible protected reference refuses the plan. |
| `presence.db` | Base DB is not deleted, but legacy service can supersede schedule state | Contains schedule/run and user records | No Stage 2C write. Preserve and witness. Incompatible or uninspectable Presence evidence refuses the plan; human consent cannot erase it. |
| `.messagelens-archive.json` and archive UUID | Preserved | Admission identity, never rebuildable from derived messages | Preserve exact bytes/identity; revalidate root and UUID immediately before Ball and after reset. |
| Admitted archive root and instance lock | Preserved | Authority/coordination identity | Never delete or relocate; root/scope identity is part of the plan fingerprint. |
| `attachment_archive/` or configured external archive | Preserved by the lower reset | Preservation data, never a cache | No read/write/delete/relocate as reset work; verify configuration/root/generation unchanged and payload sentinel/witness unchanged in fixtures. |
| Attachment location/bookmark configuration | Retained in overlay/settings | Durable binding and access evidence | No write; exact generation/path/binding is plan currentness evidence. |
| Adoption/relocation transaction records, journals, and receipts | Not lower reset targets | Recovery evidence | Preserve. Pending/conflicting transaction evidence refuses the command. |
| Historical-source list `historical_archive_sources/v1` | Preserved in overlay | User-selected sources and protected history | Preserve. Any non-live contributing source or missing provenance refuses the command. |
| Source registry inside active import DB | Deleted with active import DB | May be the only membership/provenance witness | It may be deleted only after its full material facts have been read into the exact process-local plan and independently matched to available authoritative source evidence; no unknown or non-live row permitted. |
| External donor/source files | Not reset targets | May be unique user material | Never mutate. Mere historical availability is not sufficient authority to delete local imports. |
| Saved preferences/navigation/window state | Preserved in overlay/preferences | User intent | No write. The command UI is process-local and does not persist a navigation or resume cursor. |
| Onboarding operation snapshot and prior failures | Reset/cleared today | Recovery/diagnostic evidence | Preserve without vote. A resulting post-restart inconsistency is for fresh AppCzar/Diagnostic Review, not an excuse to erase it. |
| Pipeline incident/support evidence and logs | No direct reset deletion was found in the lower path | Diagnostic/support evidence | Preserve. Do not use as command authority or durable progress. |

The existing `StartFreshArtifactPolicy` description of selective overlay and
Presence reset and retired-derived discard is therefore not the Stage 2C
policy. Stage 2C is strictly narrower.

## 9. Lower reset, Ball, maintenance, and provider lifecycle trace

`StartFreshServiceProvider` invokes
`ArchiveMutationCoordinator.runWithCapability` with
`ArchiveMutationOperation.startFresh`. The coordinator acquires the one
exclusive archive-mutation Ball, binds operation/environment/archive UUID and a
unique scope/tenure, installs callback-local capability in the exact async Zone,
and invalidates that capability at release. Re-entry is permitted only within
the same exact tenure; no independently acquired nested Ball is needed or
allowed.

`MessageDataResetService.resetDerivedDataForStartFresh(capability)` validates
the `startFresh` operation and calls its lower deletion mechanics. Its separate
self-authorizing reset entry must not be used by Stage 2C because it would
acquire a second/different mutation operation.

The lower worker closes the source-import and graph providers, deletes the
allow-listed families, invalidates providers, and advances
`messageDataVersion`. If provider close fails today, the worker logs and can
continue. Stage 2C must instead fail before deletion if every affected provider
cannot be proven closed.

There is no source-grounded need for a new global lock hierarchy. The existing
typed Ball plus Operating currentness admission closure/drain and fail-hard
database close is the required ordering. The mutation resource gate already
blocks incompatible database reopen while `startFresh` owns the Ball.

Local Data Repair supplies the stronger reusable pattern: capture exact reset
entities and all preserved top-level witnesses, perform capability-requiring
active-derived deletion, then require targets absent and every protected
witness equivalent. That boundary should be generalized narrowly for Stage 2C,
not duplicated in presentation code.

## 10. Legacy terminal, handoff, and reset-postcondition semantics

The current legacy terminal proof is semantic: after deletion it asks the full
installation validator to report `virgin`, refreshes environment/gate state,
and enters a Journey presentation that can show success/failure, retry, return
to Settings, or wait for Onboarding dismissal. It does not require a real
process restart.

That is incorrect for AppCzar Stage 2C. A reset changes startup facts, open
provider history, and construction evidence. Stage 2C may claim only its exact
physical postcondition in the old process. It then releases the Ball and ends
through a real process boundary. No old-process Journey, Onboarding gate, or
in-process semantic `virgin` result may choose what happens next.

## 11. Operating-owned command feasibility verdict

**Feasible, with a narrow lower extraction and an Operating-local command
barrier.** The semantic jurisdiction can remain Operating for preparation,
confirmation, drain, mutation, and terminal restart scheduling:

```text
fresh AppCzar assessment
  -> exact Operating occurrence admitted
  -> explicit Reset message data command occurrence
  -> synchronously close currentness admission
  -> drain the current currentness flight
  -> collect fresh bounded facts and exact plan
  -> human confirms that exact plan
  -> revalidate occurrence/scope/generations/fingerprints
  -> one ArchiveMutationOperation.startFresh Ball
  -> capability-requiring active-derived reset
  -> exact physical/preservation postcondition
  -> release Ball
  -> stopAndDrain (idempotent terminal fence)
  -> qualified process restarter
  -> new native/Dart admission and fresh AppCzar assessment
```

No source contradiction requires an eighth jurisdiction. The existing service
is too broad, but the required lower mechanics and lifecycle seams exist.

## 12. Why Start Fresh is not a top-level jurisdiction

Start Fresh does not answer “what state is this installation in?” It is a human
command issued only after AppCzar has already selected Operating. Its temporary
plan, confirmation, progress, and terminal outcome do not compete with the
seven-way evaluator and are never durable semantic state.

The command may not select Onboarding, Local Data Repair, Diagnostic Review, or
any other successor. A new process asks AppCzar again. Making Start Fresh an
eighth disposition would create a second authority over startup truth and a
resume cursor that Prompt 90 explicitly forbids.

## 13. Exact Operating admission and visibility predicate

The Settings row is actionable only when all of these are true:

- the selected composition is AppCzar;
- the current AppCzar disposition is Operating;
- `AppCzarOperatingSessionController` has a current admitted occurrence;
- the action is bound to that occurrence's process sequence, assessment
  generation, admitted archive scope identity, currentness probe generation,
  and resolved archive path;
- the occurrence is accepting commands and is not draining or failed;
- no currentness update, attachment preservation/action, relocation/adoption,
  or archive mutation is admitted after the command barrier closes;
- the host exposes a qualified current process restarter (development only at
  this stage).

These conditions expose only an invitation to prepare a plan. Destructive
eligibility is decided by fresh bounded evidence after currentness drain. The
button must be absent/disabled in the other six jurisdictions even if Settings
state or a stale widget remains mounted.

## 14. Command occurrence and stale action/confirmation contract

One process-local `OperatingStartFreshCommandOccurrence` should capture:

- a new command occurrence ID;
- the exact Operating occurrence identity above;
- the admitted environment/archive UUID/root/location generation;
- source sample identity/high-water and material membership digest;
- active/retired/protected store observations and witness digest;
- current `messageDataVersion` and mutation-release fence;
- exact allow-listed deletion plan;
- confirmation-plan digest and capture time.

The controller claims single flight synchronously before any dialog is opened.
A second click joins or is rejected by the same occurrence; it never creates a
second dialog or reset. Confirmation is valid only for the displayed plan
digest. Any occurrence, archive, source, store, protected-evidence, generation,
or mutation-fence change cancels the plan before Ball. Nothing is persisted.

## 15. Currentness observation/update barrier

`AppCzarOperatingCurrentnessController` currently starts a 15-second cycle. A
cycle can perform bounded source/store observations and can enter
`LiveGraphUpdateWorker` and attachment-preservation work. `stopAndDrain()`
synchronously sets `_acceptingWork` false, cancels the timer, advances the
publication epoch, suppresses restart, publishes stopped state, and then awaits
the exact active flight. Its epoch/currentness checks prevent stale publication
after closure.

Stage 2C needs one small Operating-local barrier API around this existing
behavior:

1. synchronously claim the command and close new currentness admission;
2. await the current active flight;
3. leave currentness suspended while plan/confirmation/mutation is live;
4. resume only if the user cancels or preflight fails before mutation, the same
   Operating occurrence is still current, and no mutation began;
5. never resume after the mutation boundary is crossed.

This is not a new global lock. It is an Operating-session admission state owned
by the existing session/currentness controllers.

## 16. Running-worker drain and no-deadlock proof

The ordering must be:

```text
claim command occurrence
-> close currentness admission synchronously
-> await existing active currentness/live-update/preservation flight
-> fresh destructive preflight and confirmation
-> acquire one startFresh Ball
-> fail-hard close affected providers
-> delete and prove
-> release Ball
-> terminal stopAndDrain fence
-> restart
```

Currentness is drained **before** acquiring the Ball, so a running worker cannot
wait for a resource held by the reset while reset waits for that worker. The
Start Fresh command itself must not be registered as a currentness flight, so
`stopAndDrain()` never awaits its own Future. UI reads of affected providers are
disabled behind the command overlay/barrier and the mutation resource gate
prevents reopen during tenure. Provider close happens only after currentness is
quiescent and fails hard before deletion.

OS Quit before confirmation cancels the command without mutation and follows
the normal Operating exit drain. Once deletion may have begun, Quit is deferred
until the Ball settles; the process then follows the same terminal restart or
fail-closed quit path. No old Journey observer or second monitor is mounted in
the AppCzar root.

## 17. Human consent content and evidence binding

The confirmation must display only facts in the exact process-local plan:

- the active DB families and sidecars to be deleted;
- that overlay/user intent, Presence, retired stores, archive marker/UUID/root,
  bookmarks/location, journals, attachment payloads, external donors,
  preferences, operation/failure/support history, and logs will not be changed;
- the exact currently readable authoritative source from which active message
  and graph data is proven rebuildable;
- whether all affected rows have positive current-source membership;
- known reasons the command is refused, rather than a generic warning;
- that the app will restart and AppCzar will perform a fresh assessment;
- that no particular next screen or coordinator is guaranteed.

The user authorizes only this digest. Consent never converts UNKNOWN, corrupt,
missing, unstable, historical, or conflicting evidence into deletion authority.
There is no “accept possible loss” override in Stage 2C.

## 18. Messages lost from the current source

If a local import row once came from live `chat.db` but cannot now be found in a
fresh stable source witness, Start Fresh must be refused with a literal reason,
for example:

> MessageLens contains message rows that are not present in the current Messages
> source, so this data is not proven rebuildable and will not be reset.

The user may later encounter Diagnostic Review or a specialist workflow only
after a fresh process assessment. Confirm cannot waive the missing fact.

## 19. Protected historical or non-live source case

Any non-live source count, historical source registry contribution, recovery
donor lineage, imported historical row, or unresolved provenance makes the
command ineligible. These records may be the only remaining copy of message
history. Stage 2C preserves the registry and derived data and gives a literal
refusal. It does not borrow Local Data Repair's narrow live-only permission.

## 20. Corrupt, retired, unsupported, or UNKNOWN store case

- A corrupt or uninspectable active affected store is UNKNOWN/unsafe: refuse.
- An unsupported schema is unsafe: refuse.
- Any retired DB or sidecar is protected residual evidence: refuse and preserve.
- A missing source membership/provenance witness is UNKNOWN: refuse.
- An archive/location/marker/UUID mismatch or pending transaction: refuse.
- A changed fact after confirmation: stale plan, no mutation.

These cases remain for a fresh AppCzar Diagnostic Review or specialist result.
The command never deletes retired material to make the installation appear
clean.

## 21. Source-absent attachment debt case

Operating can truthfully admit a dataset with known historical attachment debt
when no current repair opportunity exists. Start Fresh is narrower: deleting
the graph can destroy the joins and metadata needed to relate durable payloads
to messages. Therefore any required attachment reference that is source-absent,
or any attachment/provenance relationship not independently proven
reconstructible, refuses Start Fresh. Existing archive payloads remain intact;
their mere durability does not prove graph rebuildability.

A newly available uncovered attachment also blocks the command because
Attachment Archive Repair has current work. UNKNOWN/conflicting coverage blocks
it as well.

## 22. Overlay, Presence, and attachment archive preservation

Stage 2C performs no write to `user_overlays.db`, `presence.db`, the archive
marker, the archive root, attachment payloads, location/bookmark settings,
adoption/relocation records, or external donors. It does not clear Onboarding
snapshots, failure records, pipeline incidents, or schedules.

Before mutation, all protected top-level witnesses are captured using the
source-grounded physical witness pattern already used by Local Data Repair.
After deletion they must be byte-stable or equivalent under that same sourced
proof. A protected-witness change makes the physical postcondition fail and the
process restart into fresh diagnosis; it is never reported as reset success.

## 23. Post-reset fresh AppCzar taxonomy

The command promises only fresh assessment. Depending on preserved facts, the
new process could truthfully select:

- **Onboarding** if active derived stores are absent and all preserved facts are
  compatible with an initial construction scope;
- **Diagnostic Review** if preserved operation, historical, retired,
  unsupported, inconsistent, or protected reference evidence requires review;
- **Source Access Repair** if the current Messages source is no longer readable;
- **Attachment Archive Repair** if fresh graph/archive evidence establishes a
  current repair opportunity;
- **Local Data Repair**, **Data Update**, or **Operating** if fresh facts, not
  old command intent, select them.

The safe Stage 2C eligibility predicate refuses known protected/retired/source-
missing cases before mutation, reducing but not eliminating the possibility of
a fresh Diagnostic result. Preserved Onboarding operation evidence can itself
make the new installation non-Onboarding-safe; that is not authority to erase
the evidence. It is why confirmation says “fresh assessment,” not “Onboarding
starts next.”

## 24. Exact typed Ball and capability reuse proposal

Reuse:

- `ArchiveMutationOperation.startFresh`;
- `ArchiveMutationCoordinator.runWithCapability`;
- its exact callback-local capability and resource-action gate;
- the active-family deletion/file-store mechanics in
  `MessageDataResetService`;
- Local Data Repair's physical before/after witness model.

Do not reuse:

- `StartFreshService` as semantic authority;
- the reset service's self-authorizing public entry;
- `includeRetired: true`;
- Journey/Onboarding state clearing or handoff;
- Local Data Repair's automatic classification as permission.

The narrow lower interface should be capability-requiring and explicit, for
example:

```text
resetActiveDerivedDataForOperatingStartFresh(
  ArchiveMutationCapability capability,
  ExactOperatingStartFreshResetPlan plan,
)
```

It accepts only a current `startFresh` capability, verifies that the plan names
only the two active families and sidecars, captures/proves protected witnesses,
fails hard on provider close, deletes, invalidates providers/version, and
returns only an exact physical result. It acquires no Ball itself.

## 25. Physical postcondition and mutation failure behavior

Success requires all of the following:

- the six allow-listed active base/WAL/SHM paths are absent as applicable;
- no retired path was touched;
- every protected witness is unchanged/equivalent;
- admitted root, marker bytes, UUID, location generation/path, and configuration
  are unchanged;
- attachment archive/external payload bytes and binding are unchanged;
- the lower worker did not claim semantic virginity, rebuild success, or a next
  coordinator.

There is no rollback fabrication after deletion. If deletion partially fails,
postcondition fails, or a protected witness changes, the Ball is released and
the process remains terminally drained. It requests a real restart so fresh
AppCzar can observe the partial state. There is no in-process retry.

If restart scheduling itself fails after mutation may have begun, the UI shows
a terminal fail-closed message with instructions to quit and manually relaunch.
Currentness remains suppressed; browsing and reset retry remain disabled. The
old process must not resume Operating.

## 26. Restart, Quit, and single-flight contract

- The command controller claims one exact process-local occurrence before UI.
- Duplicate clicks join/reject the same Future and cannot create a second Ball.
- Cancel before mutation releases the command barrier and may resume currentness
  only for the same unchanged Operating occurrence.
- A stale plan cancels without mutation and may be freshly requested; it is not
  silently refreshed under an old confirmation.
- Success or any post-admission failure releases the Ball, leaves currentness
  drained, and schedules exactly one restart.
- The existing AppCzar Operating exit handler's `stopAndDrain()` remains the
  idempotent exit fence.
- Quit before mutation is normal cancellation/exit. Quit after mutation begins
  waits for tenure completion and never kills the worker mid-Ball.
- Restart failure never launches a retry or a second restarter.

## 27. Minimal UI and Settings parity plan

Keep the normal Settings row, description, action specification, and sidebar
dispatch. Add a thin adapter that resolves the AppCzar Operating command only
when the exact current occurrence is eligible; otherwise the row is disabled or
absent by jurisdiction.

Mount one Operating-local host beside the existing currentness status host in
`AppCzarOperatingSessionApp`. It renders in-memory plan collection,
confirmation, mutation progress, terminal restart, and one-shot failure states.
It temporarily blocks ordinary browsing while currentness is suspended or
mutation is possible. Its state is keyed to the command occurrence and is
discarded when that Operating occurrence ends.

Reuse visual primitives and truthful portions of the existing confirmation
layout, but not `AdvancedStartFreshOverlayHost`, Journey completion state, or
the old promise that Onboarding follows.

## 28. Minimal source and test file inventory

Proposed new production files:

- `lib/essentials/app_czar_operating_session/domain/app_czar_operating_start_fresh_models.dart`;
- `lib/essentials/app_czar_operating_session/application/app_czar_operating_start_fresh_controller.dart`;
- generated provider output for that controller;
- `lib/essentials/app_czar_operating_session/presentation/app_czar_operating_start_fresh_host.dart`.

Narrow modifications:

- `app_czar_operating_currentness_controller.dart` for a named suspend/drain/
  pre-mutation-resume barrier;
- `app_czar_operating_session_app.dart` to mount the Operating host;
- `settings_action_list_actions_provider.dart` and
  `sidebar_action_dispatcher.dart` for selected-composition/current-occurrence
  routing while preserving the legacy branch;
- `main.dart` to replace development-policy-only reset visibility with the
  already selected composition identity, without changing the production
  activation predicate;
- `message_data_reset_service.dart` for the capability-requiring active-only
  physical reset extraction and fail-hard postcondition;
- generated Riverpod files produced by the normal generator, never edited by
  hand.

Focused tests should mirror those files, extend
`onboarding_start_fresh_architecture_test.dart`, sidebar/action tests, Operating
session/currentness tests, reset-service tests, and the central forbidden-import
architecture suite. Release metadata should be handled in the later
implementation if the resulting user-facing change meets the repository's
release policy; none is changed by this audit.

## 29. Forbidden-import and reachability plan

Enforce these call edges:

```text
Settings specification/dispatcher
  -> Operating Start Fresh public command seam
  -> Operating-local controller
  -> currentness barrier + fresh plan readers
  -> ArchiveMutationCoordinator(startFresh)
  -> capability-requiring lower reset worker
  -> process restarter
```

Forbidden:

- Operating Start Fresh importing Journey, `StartupApp`, Onboarding gate,
  Onboarding operation controller, startup telemetry, Environment Readiness,
  `chatDbChangeMonitorProvider`, or `advancedStartFreshActionProvider`;
- presentation importing reset file-store or mutation coordinator directly;
- lower reset worker importing AppCzar, Settings, Journey, or presentation;
- source/support/Environment evidence authorizing the command;
- any generic `execute(disposition)` or eighth-disposition dispatcher;
- any persisted command/run/confirmation/resume state.

The legacy Start Fresh branch remains reachable only from legacy production
composition while production AppCzar activation is false.

## 30. Automated qualification plan

Later implementation tests must establish:

1. action available only for the exact current Operating occurrence;
2. other six jurisdictions cannot construct/invoke it;
3. Settings row/dispatch parity and legacy routing remain intact;
4. one command occurrence and one confirmation single flight;
5. Cancel performs no mutation/restart and safely resumes only the same
   occurrence;
6. stale occurrence/confirmation performs no mutation;
7. fresh source/resource/protected observations are revalidated before Ball;
8. UNKNOWN, corrupt, historical, retired, unsupported, source-missing, and loss
   cases fail closed with literal reasons;
9. source-absent attachment debt is neither erased nor waived;
10. one exact callback-local `startFresh` Ball and no nested admission;
11. currentness is synchronously closed and fully drained before database close;
12. no Journey, legacy monitor, or second currentness controller initializes;
13. only authorized active DB families/sidecars are deleted;
14. overlay, Presence, marker/UUID/config/bookmark, journals, retired stores,
    payload sentinels, logs, and recovery evidence are preserved;
15. retired cleanup is impossible through this entry;
16. physical-postcondition failure cannot report success;
17. post-admission failure releases Ball, drains, and requests one restart;
18. success releases Ball, drains, and restarts exactly once;
19. Quit and restart failure are bounded and deadlock-free;
20. only a new process performs semantic reclassification;
21. no eighth disposition or second evaluator exists;
22. legacy Start Fresh remains unchanged while production activation is false;
23. Operating currentness and development AppCzar regression suites pass;
24. disposable fixtures prove protected bytes are never removed;
25. generated code, analyzer, architecture tests, deterministic Flutter suite,
    and Project Conformance pass.

## 31. Future disposable human qualification plan

A separate later prompt should create only disposable roots and qualify:

- a fully proven live-only Operating fixture whose exact plan can be confirmed;
- Cancel with byte-identical before/after inventory and no restart;
- refusal of protected historical/non-live, source-missing, retired, corrupt,
  and UNKNOWN fixtures;
- a currentness cycle in flight when Start Fresh is requested, proving orderly
  drain before deletion;
- exact active-family deletion plus retained sentinels for overlay, Presence,
  marker, journals, retired stores, archive payloads, and preferences;
- one old PID ending, one new PID starting, and a fresh AppCzar assessment;
- disposable failure after partial mutation, followed only by fresh-process
  diagnosis;
- Quit with no unintended relaunch;
- no Journey screen, duplicate importer, second monitor, or hidden production
  activation.

That qualification cannot substitute for a signed production identity/TCC
rehearsal, production backup/rollback plan, or production-safe restarter.

## 32. Production-default-off and development-only restarter proof

The production selector remains guarded by an unconditional disabled activation
predicate. Stage 2A and Stage 2B evidence types are read-only presentation facts
and have no command or mutation call edge. The only current AppCzar process
restarter provider is authorized by the development composition policy and uses
the development bundle relaunch path. No production-compatible restarter is
qualified.

Stage 2C must inject the selected AppCzar host's already qualified current
restarter seam. It must not broaden the provider guard or provide a production
fallback. Production AppCzar therefore remains inactive, and legacy production
Start Fresh behavior remains unchanged.

## 33. Project Conformance audit verdict

The proposed design passes the audit/design conformance standard:

- one current semantic authority: Operating;
- fixed seven-jurisdiction census;
- explicit command distinct from automatic Local Data Repair;
- current source-grounded plan, exact consent, and revalidation;
- protected historical/non-live/user/archive evidence preserved;
- one exact typed Ball only after currentness quiescence;
- no duplicate worker, ambient monitor, Journey, cursor, or old-failure vote;
- physical postcondition followed by real restart and fresh AppCzar;
- no production activation, signing, installer, TCC, archive-admission, marker,
  bookmark, or adoption-policy change;
- Stage 2A/2B presentation evidence remains read-only and non-authorizing.

No tests or analyzer were run because Prompt 90 is audit/design only. This is a
design verdict, not a claim of implementation qualification.

## 34. BLOCKER findings

No unresolved conceptual BLOCKER remains. The current legacy path itself is not
safe to expose in AppCzar, but the source provides a feasible narrower design.
The later implementation must stop if it cannot mechanically prove live-only
reconstructibility, drain currentness, preserve every protected witness, obtain
one exact capability, or schedule the qualified restart. It must also stop
rather than broaden production/restarter authority.

## 35. SHOULD FIX findings

No unresolved audit/design SHOULD FIX remains. The following are mandatory
Stage 2C implementation obligations already incorporated into the plan, not
optional follow-up items:

- replace development-policy UI gating with selected composition plus exact
  Operating occurrence;
- add the one Operating command barrier;
- extract active-only capability-requiring reset mechanics;
- fail hard on database close and physical postcondition;
- preserve retired, overlay, Presence, archive, identity, location, operation,
  failure, and support evidence;
- remove Journey/Onboarding semantic handoff from the AppCzar command;
- restart for fresh assessment after any mutation may have begun.

## 36. Implementation, test, build, and launch status

No Stage 2C implementation occurred. No source, test, generated, pubspec,
CHANGELOG, release, or native file changed. No tests, analyzer, formatter,
generator, build, app launch, process restart, fixture construction, database
probe, data reset, migration, permission check, archive read, or external-drive
operation was performed.

The only new artifacts are the external baseline manifest and this untracked
Response 90.

## 37. Final Git, index, worktree, and submodule state

Final verification after writing this response is recorded in the handoff, but
the intended closure is:

- branch `fix/onboarding-import-stuck-state`;
- `HEAD` and upstream
  `0c2ce29c17b44afb36790d675f5e0b364ab5cc2e`;
- ahead/behind `0/0`;
- tracked worktree clean;
- index clean;
- Prompt 90 and Response 90 untracked/unstaged;
- all known unrelated untracked files untouched;
- shared submodule clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- four repository worktrees, with only the primary carrying Feature 34.

No staging, commit, push, merge, rebase, squash, force operation, or cleanup was
performed for Prompt 90.

## 38. Readiness for Stage 2C implementation

**YES.** The exact authority, eligibility, destructive footprint,
currentness/barrier ordering, single Ball tenure, physical postcondition,
presentation boundary, restart contract, file scope, and qualification matrix
are specified without an unresolved conceptual blocker.

Implementation must remain bounded by the stop gates in Sections 34–35.

## 39. Readiness for Stage 2D production-safe shell construction

**NO.** Stage 2C is not implemented or qualified. Production-safe restarter,
signed identity lifecycle, and later production shell dependencies remain
separate work. This audit authorizes neither Stage 2D construction nor
production selector activation.

## 40. Readiness for production-identity rehearsal and cutover

**NO.** There is no production-compatible restarter qualification, no Stage 2C
implementation/qualification, no signed production identity/TCC rehearsal, and
no production backup/rollback execution plan. Actual production cutover remains
unauthorized.

STAGE 2B SUPPORT AND ENVIRONMENT EVIDENCE CHECKPOINTED: YES

START FRESH IS AN EXPLICIT OPERATING-OWNED COMMAND, NOT AN EIGHTH TOP-LEVEL JURISDICTION: YES

CURRENT START FRESH DELETION FOOTPRINT IS FULLY INVENTORIED: YES

PROTECTED HISTORICAL, USER-INTENT, PRESENCE, AND ATTACHMENT DATA REMAIN OUTSIDE AUTOMATIC RESET: YES

CURRENTNESS CAN BE DRAINED BEFORE START FRESH MUTATION: YES

EXACTLY ONE TYPED START FRESH MUTATION TENURE IS FEASIBLE: YES

POST-RESET AUTHORITY RETURNS THROUGH REAL PROCESS RESTART AND FRESH APPCZAR: YES

NO EIGHTH APPCZAR DISPOSITION IS PROPOSED: YES

PRODUCTION APPCZAR ACTIVATION REMAINS OFF: YES

PROJECT CONFORMANCE: PASS (AUDIT/DESIGN SCOPE)

READY FOR STAGE 2C IMPLEMENTATION: YES

READY FOR STAGED PRODUCTION-IDENTITY REHEARSAL: NO

PRODUCTION APPCZAR CUTOVER AUTHORIZED: NO
