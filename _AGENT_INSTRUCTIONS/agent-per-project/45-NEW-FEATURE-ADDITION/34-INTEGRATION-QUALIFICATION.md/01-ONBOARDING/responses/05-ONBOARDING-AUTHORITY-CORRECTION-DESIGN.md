# Onboarding Authority Correction Design

Date: 2026-09-24

## Executive decision

The existing architecture can support the correction without a second Journey
authority, a snapshot-format migration, a database-schema change, or changes to
archive authority. The selected design is a stable, keep-alive
`OnboardingJourneyCoordinator` that ingests evidence with `ref.listen` and
publishes the complete immutable presentation projection through
`OnboardingJourneyState`.

The governing dependency is one-way:

```text
operation execution and durable evidence
                 |
                 v
     OnboardingJourneyCoordinator
                 |
                 v
       OnboardingJourneyState
                 |
                 v
            presentation
```

No presentation surface may reconstruct Onboarding meaning from an environment
report, graph controller, or operation snapshot beside the Journey.

## 1. Documentation checkpoint commit

The two approved canonical corrections were the only tracked changes. They were
staged alone, passed `git diff --cached --check`, and were committed as:

- commit: `622a4d25842f15817ec93f2dc5866627189a68ad`
- subject: `docs(onboarding): restore journey-only authority`
- files:
  - `25-ONBOARDING-AND-ARCHIVE/10-onboarding-gate.md`
  - `25-ONBOARDING-AND-ARCHIVE/30-import-migration-coordination.md`

After the commit, the tracked worktree and index were clean. The shared
instructions submodule was clean. The parked patch remained unapplied at
`/private/tmp/messagelens-onboarding-import-stuck-state-wip-fe14793-20260924.patch`
with unchanged SHA-256
`43399bc44441e80fa65308ba4cf0d5bbea884b7c8a4501ad40eb6f10752e2b07`.

## 2. Final provider and lifetime architecture

### Selected design: stable notifier plus listener ingestion

Keep `OnboardingJourneyCoordinator` as one generated
`@Riverpod(keepAlive: true)` notifier and make its lifecycle independent of the
evidence it consumes:

1. `build()` installs `ref.listen` subscriptions for the environment report,
   operation snapshot, and archive-mutation lock.
2. `build()` uses `ref.read`, not `ref.watch`, to obtain any already-available
   initial evidence and returns one initial/reconstructed Journey state.
3. Later `AsyncValue.data`, error, and operation-snapshot emissions enter typed
   coordinator ingestion methods.
4. Refresh commands invalidate only evidence providers. They never call
   `ref.invalidateSelf()` and no production caller may invalidate the Journey
   provider.
5. The notifier remains alive until normal `ProviderContainer` disposal. That
   lifecycle remains directly testable with provider overrides.

This follows the established stable-listener pattern already used by
`ChatDbChangeMonitor`: the owner is constructed once, reads stable
collaborators, listens to changing facts, and updates its own state explicitly.
The generic Presence scheduler supplies the identity/currentness pattern, not a
replacement runtime for typed Onboarding Episodes.

### Why this cannot reproduce the observed stale-`ref` failure

`ref.watch(onboardingEnvironmentReportProvider)` is the dependency that marks
the current notifier element outdated when the report invalidates. Removing
all watched evidence from `build()` means an archive-lock or report change
notifies the installed listener but does not invalidate/reconstruct the
coordinator. A long-running command therefore continues using the same live
notifier element and the same state owner. Evidence refresh and Journey-owner
reconstruction become different operations.

An architecture test must prohibit:

- `ref.watch` in `OnboardingJourneyCoordinator.build()` for changing evidence;
- `ref.invalidateSelf()` in the coordinator; and
- `ref.invalidate(onboardingJourneyCoordinatorProvider)` outside tests.

Explicit container disposal remains allowed. It is application teardown, not
evidence reactivity.

### Alternatives rejected

| Alternative | Result |
| --- | --- |
| Stable notifier with `ref.listen` | Selected. It is the smallest change, matches a project idiom, preserves generated Riverpod lifecycle, and keeps one state writer. |
| Stable command owner plus an evidence-bridge state owner | Rejected. If the bridge derives workflow meaning, it becomes a second authority; if it only forwards events, it adds indirection without solving more than `ref.listen`. |
| Global singleton/service outside Riverpod | Rejected. It weakens disposal, overrides, startup reconstruction, and test isolation. |
| Retired Presence Schedule/Trip/Step runtime | Rejected. Its currentness principles are reused, but production Onboarding remains the canonical typed-Episode Journey. |

## 3. Final state-flow diagram

```text
FDA / Contacts / source probes ------> OnboardingEnvironmentReport
archive mutation lock -------------->          |
                                                   |
graph observations --> operation controller --> OnboardingOperationSnapshot
                           |                       |
                           | durable v1 evidence   |
                           +-----------------------+
                                                   v
                                 OnboardingJourneyCoordinator
                                 - stable notifier lifetime
                                 - current Journey occurrence
                                 - current operation binding
                                 - evidence currentness cursor
                                 - typed transition policy
                                 - user-visible action policy
                                                   |
                                                   v
                                      OnboardingJourneyState
                                      - prerequisite evidence
                                      - operation projection
                                      - allowed Journey actions
                                                   |
                              +--------------------+--------------------+
                              v                                         v
                    OnboardingGate                              production UI
                    compatibility only                         Journey state only
```

The graph controller and snapshot remain operational authorities in their own
domains. They do not select an Episode, choose Retry/Continue, or supply
presentation directly.

## 4. Exact operation-start sequences

### Common start protocol

Every user-started operation follows this order:

1. Presentation captures an `OnboardingJourneyActionContext` from the rendered
   Journey state.
2. The coordinator verifies the expected Journey occurrence and Episode. For a
   retry/continue it also verifies the expected operation ID.
3. The coordinator records a private current command token. The current
   Journey state may expose that its command is pending, but it does not claim
   that work is running.
4. The archive mutation coordinator grants the named mutation scope.
5. Inside that admitted scope, prerequisites and action context are rechecked.
6. `OnboardingOperationSnapshotController.begin(...)` allocates and durably
   publishes the UUID, or `resume(...)` reactivates the validated interrupted
   UUID.
7. Only after step 6 succeeds does the Journey bind the ID and publish a
   running Episode carrying an operation projection.
8. The executor receives that exact ID. It never allocates a different one.
9. Progress, failure, and completion return as identity-bearing snapshot
   evidence. The coordinator accepts only evidence matching the current
   binding and Journey occurrence.
10. The binding remains through failure or terminal communication. It is
    retired when the Journey leaves that operation occurrence, a new attempt is
    durably begun under a new UUID, or terminal acknowledgement enters normal
    application state.

While archive admission is pending, transient maintenance reports cannot move
the Journey to normal application. The typed pending command belongs to the
coordinator; it is not a claim that an operation is active. Consequential
derived-store work begins only after the durable snapshot exists.

### First import

1. Validate `ReadyToImport` action context and current prerequisite evidence.
2. Obtain `ArchiveMutationOperation.onboardingImport` admission.
3. Recheck FDA and the action context inside the admitted scope.
4. Call `begin(kind: initialImport, initialStage: messageDataBuild)`.
5. Bind the returned UUID and the current process session to the Journey.
6. Publish `OnboardingPreparingImport`, then
   `OnboardingBuildingLocalData`, both carrying that operation projection.
7. Call `VirginOnboardingImportExecutor.run(operationId: ...)`; remove its
   internal `begin` call.
8. Graph observations are written through the ID-bound progress reporter and
   snapshot controller. The Journey listener validates and projects them.
9. Enter `durableReadinessVerification`, publish the verifying Episode, run
   the verifier, persist typed completion evidence, and publish
   `OnboardingReadyToStart` for the still-bound UUID.
10. A current terminal acknowledgement enters normal application and retires
    the binding. Snapshot cleanup is evidence housekeeping, not the transition
    authority.

### Reimport

1. Validate the current normal-application occurrence and Settings request.
2. Obtain `onboardingImport` mutation admission.
3. Begin `reimport` at `environmentPreparation` and bind the UUID before
   showing reimport work.
4. Publish `OnboardingReimporting` with the preparation projection.
5. Run the preservation-safe derived-data reset under that ID.
6. Enter `messageDataBuild`, project the new stage, and pass the same ID to the
   graph executor.
7. Enter durable verification, accept completion only for the same ID, and
   publish `OnboardingReimportReady`.
8. A current acknowledgement returns to normal application and retires the
   binding.

Admission and `begin` failures have no running operation to bind. They publish
an actionable coordinator-owned failure Episode first, with no fabricated
operation projection, then record diagnostics best-effort.

### Explicit continuation of interrupted work

1. Startup converts a prior-process `running` snapshot to `interrupted`.
2. The coordinator validates kind, exact stage/substage, recovery capability,
   current prerequisites, durable-store facts, and Journey compatibility.
3. It creates a new Journey occurrence and binds the interrupted operation as
   evidence, publishing `OnboardingOperationInterrupted` with
   `Continue Setup` when continuation is truthful.
4. `Continue Setup` carries that occurrence and operation ID.
5. After mutation admission, `resume(operationId)` verifies the exact
   interrupted record, installs the current process session, advances its
   evidence revision, and returns the same logical operation ID.
6. The Journey publishes active work only after resume persistence succeeds.
7. A recovery/resume planner owned by the operation layer supplies the exact
   safe stage/substage plan to the executor. The coordinator does not invent a
   checkpoint.

An interrupted user import never resumes merely because the snapshot exists.
An interrupted `automaticRecovery` operation may be restarted automatically
only through the already-authorized automatic-recovery policy after the same
validation and archive admission.

## 5. Journey operation identity model

The existing `OnboardingOperationId` UUID is the operation/generation
identity. No parallel generation number is introduced.

The coordinator keeps a private immutable binding similar to:

```dart
final class OnboardingJourneyOperationBinding {
  final int journeyOccurrence;
  final OnboardingOperationId operationId;
  final OnboardingOperationKind kind;
  final OnboardingProcessSessionId acceptedProcessSessionId;
  final int lastAcceptedProgressRevision;
  final OnboardingOperationStatus lastAcceptedStatus;
  final OnboardingOperationStage lastAcceptedStage;
}
```

The process-session field is coordinator-internal. It distinguishes evidence
from an old process after explicit resume without leaking session mechanics to
widgets. A prior session is accepted only for the one startup-interruption
assessment. After `resume`, only current-session running evidence is accepted.

First import and reimport use a new UUID from `begin`. Retry after failure is a
new attempt and therefore a new UUID. Continue of a validated interrupted
logical operation retains its UUID but moves it to the current process session
through `resume`. This uses the snapshot controller's existing currentness
machinery rather than inventing an unrelated identity system.

## 6. Journey-owned operation projection

Add a small immutable domain model, preferably in
`domain/onboarding_journey_operation_projection.dart`:

```dart
enum OnboardingJourneyOperationPhase {
  active,
  interrupted,
  failed,
  verified,
}

enum OnboardingJourneyOperationAction {
  continueSetup,
  retry,
  acknowledgeCompletion,
}

final class OnboardingJourneyProgress {
  final int completedWorkUnits;
  final int totalWorkUnits;
}

final class OnboardingJourneyOperationFailure {
  final OnboardingOperationFailureCategory category;
  final String summary;
}

final class OnboardingJourneyOperationProjection {
  final OnboardingOperationId operationId;
  final OnboardingOperationKind kind;
  final OnboardingJourneyOperationPhase phase;
  final OnboardingOperationStage stage;
  final OnboardingOperationSubstage? substage;
  final int progressRevision;
  final OnboardingJourneyProgress? progress;
  final OnboardingJourneyOperationFailure? failure;
  final Set<OnboardingJourneyOperationAction> availableActions;
}
```

The concrete implementation must make the action set unmodifiable and validate
progress bounds. It must not carry a controller, provider, store, process
session, timestamps, completed-stage history, source row ID, anomaly aggregate,
or raw `recoveryDisposition`.

Copied after validation:

- operation ID and kind;
- stage/substage;
- snapshot `progressRevision`;
- truthful completed/total units;
- bounded failure category and summary.

Interpreted only by the coordinator:

- `phase`;
- whether a raw failure is recoverable in the current Journey;
- `availableActions`;
- which typed Episode carries the projection.

The projection is required on:

- `OnboardingRecoveringDerivedData`;
- `OnboardingPreparingImport`;
- `OnboardingBuildingLocalData`;
- `OnboardingVerifyingDurableReadiness`;
- new `OnboardingOperationInterrupted`;
- operation-backed `OnboardingOperationFailed`;
- `OnboardingReimporting`;
- `OnboardingReadyToStart`; and
- `OnboardingReimportReady`.

`OnboardingOperationFailed` may have no projection only when admission or
snapshot creation failed before an operation ID existed.

When no numeric numerator/denominator exists, `progress` is null.
Presentation renders an indeterminate indicator and stage/substage text. It
never substitutes elapsed time, row-count inference, graph success, or `1.0`.

## 7. Evidence acceptance and currentness rules

The coordinator accepts an operation emission only when all of these hold:

1. a current binding exists;
2. Journey occurrence matches the binding;
3. operation ID and kind match exactly;
4. process session matches, except during the one explicit prior-session
   interruption assessment;
5. status transition is legal (`running` to terminal/interrupted, or explicit
   `interrupted` to resumed running);
6. stage transition is legal for the operation kind;
7. substage is compatible with the stage;
8. `progressRevision` does not regress;
9. an equal revision is either an exact duplicate, which is ignored, or a
   permitted status-only transition, which is accepted once by fingerprint;
10. completed/total counts satisfy the typed snapshot invariants.

The private acceptance cursor stores the last accepted identity, process
session, revision, status, stage, and a bounded evidence fingerprint. No new
persisted revision is required. Existing version-1 terminal snapshots can have
the same progress revision as their last running snapshot, so status ordering
and duplicate fingerprinting supplement—but do not reinterpret—the persisted
progress revision.

Environment reports retain their provider-occurrence protection. The stable
coordinator assigns its own receipt sequence when it accepts a coherent report.
A report can change prerequisite Episodes, but it cannot overwrite a current
operation Episode with maintenance noise. Operation completion/failure still
requires matching operation evidence.

Graph callbacks never enter the coordinator as free-floating graph state.
They report through `OnboardingProgressReporter`, whose operation ID is checked
by the snapshot controller before publication.

Progress updates preserve the Journey occurrence while the same interaction
obligation remains current. A new occurrence is issued when the Episode's
semantic obligation changes, a new operation begins, restart reconciliation
activates a new-process interaction, or foreground authority is reissued.

## 8. Presentation cutover for the three side doors

| Current side door | Current use | Lawful replacement |
| --- | --- | --- |
| `onboardingEnvironmentReportProvider` | FDA/readiness copy, failure detail, environment summary | `journey.evidence?.report`, which is the exact coherent report accepted for that Journey state. No overlay provider watch. |
| `conversationGraphBuildControllerProvider` | progress headline, raw success/failure, fallback 100% | Typed Journey Episode plus `journey.operation.phase/stage`. Graph success/failure first enters operation evidence and coordinator interpretation. |
| `onboardingOperationSnapshotProvider` | stage, substage, numeric progress | `journey.operation`, after ID/currentness/revision validation. |

`OnboardingOverlay` must watch only
`onboardingJourneyCoordinatorProvider` for workflow semantics and switch on the
typed state, not on `OnboardingStatus`. Its child widgets receive the Journey
state or narrow immutable values as constructor arguments. The app shell should
derive overlay visibility from a Journey-owned property such as
`requiresOperationOverlay`, not from a raw reconciliation provider.

`OnboardingGate` may remain as a read-only compatibility projection for
non-migrated consumers. It is not a second authority. `OnboardingJourneyPath`
already follows the correct pattern.

Development-only diagnostic panels may continue to display explicitly labelled
raw evidence. They must not choose production Episodes or feed their raw state
back into production presentation. No speculative cleanup of those panels is
part of this correction.

End-state rule:

> Journey state in, widgets out.

## 9. Failure-publication ordering

For every caught operation error, the coordinator uses this order:

1. capture the original error, stack, current action context, and operation
   binding in local variables;
2. synchronously verify that the binding is still current;
3. synchronously publish a valid `OnboardingOperationFailed` state whose
   summary is bounded from the original error;
4. independently attempt snapshot failure persistence;
5. independently attempt graph/import failure-store persistence;
6. independently attempt logging and diagnostics;
7. independently request evidence-provider refresh;
8. retain the original error and stack for diagnostic output even if every
   later attempt fails.

Step 3 performs no provider reads, logging, persistence, invalidation, or other
fallible I/O. The typed transition table must guarantee that a current bound
operation always has a valid failure destination. Each later action has its own
containment boundary; failure in one does not suppress the others or replace
the original error.

Specific corrections:

- `OnboardingOperationSnapshotController.runStage` stops automatically calling
  `fail`. It rethrows the original error with its original stack; the
  coordinator publishes Journey failure before requesting evidence
  persistence. The now-redundant `failureCategory` argument is removed.
- Graph failure-store persistence moves after Journey failure publication and
  is best-effort.
- `_enterPreparationFailure` is replaced by a pure synchronous Journey
  transition followed by contained logger acquisition/use.
- Durable-verification catch publishes Journey failure before calling
  `operationController.fail`, failure storage, or invalidation.
- Reimport mutation-admission and `begin` failures receive the same outer
  conversion even when no operation ID was created.
- Automatic-recovery reset, completion, reset-to-idle, and final report refresh
  each have an explicit failure conversion. Final Journey state is published
  before refresh/invalidation work can fail.

Errors are not swallowed. The original error is retained in the Journey's
bounded human-safe failure, passed with its original stack to best-effort
logging/diagnostics, and remains observable to tests. Secondary evidence errors
are recorded separately and never masquerade as the operation's cause.

## 10. Action and occurrence binding

Add an immutable `OnboardingJourneyActionContext` supplied by Journey state:

```dart
final class OnboardingJourneyActionContext {
  final int occurrence;
  final OnboardingJourneyEpisode episode;
  final int? prerequisiteEvidenceRevision;
  final OnboardingOperationId? operationId;
}
```

Presentation closes over this context when constructing a callback. The action
provider forwards it; the coordinator validates it. It is provenance, not a
capability to mutate operational evidence.

Required bindings:

- **Start import:** expected Ready occurrence and prerequisite-evidence
  revision; recheck after mutation admission.
- **Retry:** expected failure occurrence and failed operation ID when one
  exists; a new accepted attempt receives a new UUID.
- **Continue Setup:** expected interrupted occurrence and exact interrupted
  operation ID; recheck before and after admission and before resume.
- **Terminal OK/Done:** expected terminal occurrence and completed operation
  ID. The existing post-frame callback validates again inside the callback.
- **Reimport:** expected normal-application occurrence; any delayed admission
  result is ignored if another occurrence became current.

Coordinator-internal async commands also capture the action context and binding
and revalidate after every await before publishing. Late callbacks from a prior
occurrence become no-ops or typed stale-action rejections.

Synchronous controls that cannot outlive their callback need no unrelated
token. FDA settings opening remains a supporting command, and a synchronous
local-history acknowledgement may continue to validate the current typed
Episode directly; it may also accept the action context for consistency without
creating a second token system.

## 11. Restart and reconciliation policy

Reconciliation is initiated and interpreted by the stable Journey coordinator,
not by a provider watched from `MacosAppShell`.

### Startup sequence

1. Initialize the snapshot controller. A prior-process `running` snapshot is
   durably changed to `interrupted` by its existing process-session check.
2. Load current environment/prerequisite evidence.
3. Feed report plus snapshot to the pure reconciliation specialist.
4. The coordinator validates the result against operation kind, exact
   stage/substage, recovery capability, current prerequisites, and current
   Journey compatibility.
5. The coordinator creates the new-process Journey occurrence and derives the
   one truthful Episode.

### Cases

| Evidence | Coordinator result |
| --- | --- |
| No snapshot/idle | Derive prerequisites, Ready, or Normal Application from the coherent environment report. |
| Prior-process running | Controller marks it interrupted; never show active work until explicit validated resume. |
| Interrupted with exact safe substage | Bind it to a new-process interrupted Episode and offer coordinator-owned `Continue Setup`. |
| Interrupted but prerequisite changed | Show the prerequisite Episode. Retain only a private reconciliation candidate; offer Continue only after fresh evidence restores compatibility. |
| Non-resumable/inconsistent failure | Publish an operation-failure Episode. `recoveryDisposition` is one input; coordinator chooses Retry or another action. |
| Completed snapshot produced by the currently bound command | Require typed durable completion proof, then publish the terminal Episode for that binding. |
| Completed snapshot loaded at startup, including a completion whose old terminal Inform was never acknowledged | Treat it as historical operation evidence, rerun durable readiness, and derive Normal Application when the installation is ready. Do not recreate terminal presentation from an unbound snapshot. |
| Stale/unrelated completed snapshot | It cannot match a current binding and cannot create Start/Done. Current environment facts determine the Journey; the snapshot remains diagnostic evidence. |

The conservative completed-snapshot policy avoids replaying an old Start/Done
screen after every launch. Terminal acknowledgement is an informational
obligation of the live Journey occurrence, not a safety precondition for using
durably verified data. If durable replay of that informational acknowledgement
is later required, it needs coordinator-owned durable Journey state; it must not
be inferred from the operation snapshot.

After a current terminal acknowledgement, the coordinator may clear completed
operation evidence to idle as contained housekeeping. The Journey transition
does not depend on that cleanup succeeding, and restart never treats an unbound
completed snapshot as presentation authority.

`onboardingOperationReconciliationProvider` is removed as an independently
triggered shell side effect. Its pure assessment logic remains a specialist
called by the coordinator. This removes a competing initiator without moving
probing or persistence mechanics into the coordinator.

## 12. Specialist ownership and dependency direction

Ownership remains:

- source-scoped importer: source rows, bounded pages, checkpoints, anomaly
  facts;
- graph builder: graph construction and graph observations;
- operation snapshot controller/store: operation UUID, process session,
  stage/substage, progress, interruption, capability/failure evidence;
- reset service: explicit rebuildable-store reset only;
- durable completion verifier: typed readiness proof;
- archive mutation coordinator: mutation admission and capability;
- FDA/environment/Contacts readers: observation of external prerequisites;
- reconciliation/resume planner: operational compatibility and safe-boundary
  plan;
- `OnboardingJourneyCoordinator`: Journey occurrence, Episode, operation
  binding, evidence interpretation, user-visible actions, and what happens
  next;
- presentation: render supplied state and return typed intent.

The dependency direction is:

```text
readers and operations -> typed evidence/assessment -> Journey coordinator
Journey coordinator -> typed Journey state -> renderer
renderer intent -> action boundary -> Journey coordinator -> admitted operation
```

The coordinator calls specialists; it does not absorb SQL, reset mechanics,
graph construction, progress calculation, or completion proof logic.

## 13. Test-first matrix

### Architecture tripwires written first

1. Production Onboarding presentation cannot import or reference:
   - `onboardingEnvironmentReportProvider`;
   - `conversationGraphBuildControllerProvider`;
   - `onboardingOperationSnapshotProvider`.
2. `OnboardingOverlay` must consume `OnboardingJourneyState` and its operation
   projection.
3. Every active operation Episode constructor requires a projection with a
   non-null operation ID.
4. The coordinator is the only writer of `OnboardingJourneyState` and has no
   watched evidence or self-invalidation.
5. No production source invalidates the Journey provider.
6. Snapshot/controller types remain absent from presentation mutation paths.
7. Shell startup cannot watch an independent reconciliation side-effect
   provider.

The current architecture assertion that requires
`onboardingOperationSnapshotProvider` in `onboarding_overlay.dart` is inverted.

### Deterministic replay tests

| Replay | Required proof |
| --- | --- |
| FDA absent -> leave -> FDA restored | Same authority receives new report and derives the next Episode; stale FDA action cannot act later. |
| Local-history confirmation | Candidate applies only to its current occurrence/evidence revision. |
| Contacts blocker | Contacts evidence changes only through coordinator derivation. |
| First import success | Admission -> durable UUID -> active projection -> verification -> terminal; no running state lacks an ID. |
| First import failure -> retry -> success | Failure is published first; retry obtains a new UUID; old evidence cannot affect it. |
| Interrupted import -> Continue Setup | No auto-resume; exact old ID appears only in the interrupted Episode; explicit resume uses the validated safe boundary. |
| Durable verification failure | Never exposes Start; always reaches actionable failure despite evidence/logging failures. |
| Terminal acknowledgement | Captured occurrence/ID is rechecked in the post-frame callback. |
| Restart | Reconstruct from report plus snapshot without consulting former widget state. |

### Hostile asynchronous noise

For operation A followed by Journey/operation B, inject:

- late graph success from A;
- late snapshot progress from A;
- late failure from A;
- duplicate revision;
- regressing revision;
- old process-session running evidence after explicit resume;
- provider invalidation/reconstruction of environment evidence;
- delayed Retry, Continue, and terminal callbacks from A.

Assert B's occurrence, Episode, operation projection, action set, and terminal
outcome are unchanged.

### Failure independence

Inject failures separately and cumulatively in:

- logger acquisition/write;
- snapshot failure persistence;
- graph/import failure-store persistence;
- report invalidation;
- completion evidence persistence.

In every case, assert the Journey has already entered its defined
failure/retry Episode and the original error remains the primary diagnostic.
Add a focused regression test that changes the mutation lock/environment report
during a running command and proves no `!_didChangeDependency` assertion is
possible.

### Existing test replacements

Rewrite overlay progress/failure tests to construct only typed Journey states.
Delete expectations that raw graph success produces `Browsing data ready`, raw
graph failure selects the headline, or raw snapshot progress is watched by the
widget. Retain operation-controller tests as evidence-layer tests and add
resume/session/currentness cases.

## 14. Compatibility and migration conclusion

No database-schema migration and no snapshot format bump are required.

Existing version-1 snapshots already contain:

- unique operation UUID;
- process-session UUID;
- operation kind;
- exact stage/substage;
- progress revision and counts;
- status;
- failure category and recovery capability.

The coordinator interprets those fields; conceptual ownership does not alter
their persisted representation. `resume` updates existing version-1 fields
(process session, status, timestamps, and revision) and writes the same JSON
shape. An interrupted v1 snapshot with no exact safe substage is not guessed
resumable; it becomes a coordinator-owned failure/retry decision. Completed v1
snapshots loaded without a current Journey binding never directly create
terminal presentation.

Removing `OnboardingOperationSnapshot` from `OnboardingEnvironmentReport` is an
in-memory contract cleanup, not a persistence migration. The installation-state
reader and diagnostic support bundle may continue reading the durable snapshot
through their own non-presentation seams.

## 15. Exact implementation phases

No phase is an approvable checkpoint while both the new projection and an old
presentation side door remain active.

1. **Failing tripwires and replay fixtures.** Add the presentation-import bans,
   ID-required constructors, lifetime guard, stale-evidence fixtures, and
   failure-injection seams. Confirm failures describe the current architecture.
2. **Atomic authority tranche.** In one uncheckpointed implementation tranche:
   - stabilize the coordinator with listener ingestion;
   - add action context, private operation binding, and Journey projection;
   - move UUID begin/resume ahead of running publication;
   - make executors receive the ID;
   - add evidence acceptance/currentness;
   - cut overlay and shell to Journey-only input; and
   - remove all three raw production presentation reads.
   The first buildable/reviewable state after this tranche has one authority.
3. **Failure-order hardening.** Remove snapshot-first failure handling and make
   every operation path publish Journey failure before contained evidence work.
4. **Restart/reconciliation cutover.** Move reconciliation initiation into the
   coordinator, add explicit Continue/resume policy, and remove the shell-owned
   reconciliation provider.
5. **Action provenance.** Bind Retry, Continue, reimport, and terminal
   acknowledgement to occurrence/Episode/operation identity and reject late
   callbacks.
6. **Obsolete-code removal.** Remove watch-driven status override/fallback
   machinery and old tests only after source/use proof. Leave development
   diagnostics unless required for compilation or proven to own production
   semantics.
7. **Validation.** Run generation, formatting, focused tests, architecture
   tests, full analyzer, full Flutter tests, and the approved development-only
   qualification. Do not access production data during automated validation.
8. **Documentation proof.** Only after tests prove the cutover, update the
   deferred canonical and conformance records.

## 16. Files and symbols expected to change

### Production/domain

- `lib/essentials/onboarding/domain/onboarding_journey_state.dart`
  - add projection/action context to applicable Episodes;
  - add interrupted Episode;
  - make occurrence stable across same-obligation evidence updates.
- new
  `lib/essentials/onboarding/domain/onboarding_journey_operation_projection.dart`
  - immutable presentation projection and coordinator-owned action enums.
- `lib/essentials/onboarding/domain/onboarding_environment_report.dart`
  - remove embedded operation snapshot and snapshot-derived presentation
    helpers.
- `lib/essentials/onboarding/application/onboarding_journey_coordinator_provider.dart`
  - listener ingestion, binding/currentness, typed transition policy, ordered
    failure publication, action-context validation, restart reconciliation.
- generated
  `onboarding_journey_coordinator_provider.g.dart` if build-runner output
  changes.
- `lib/essentials/onboarding/application/onboarding_operation_snapshot_controller.dart`
  - explicit resume and original-error-preserving `runStage` behavior.
- `lib/essentials/onboarding/application/virgin_onboarding_import_executor.dart`
  - accept the coordinator-bound operation ID; stop allocating it.
- `lib/essentials/onboarding/application/onboarding_operation_reconciliation.dart`
  - pure report-plus-snapshot assessment and safe resume plan.
- `lib/essentials/onboarding/application/onboarding_operation_reconciliation_provider.dart`
  and generated sibling
  - expected removal after the coordinator owns reconciliation initiation.
- `lib/essentials/onboarding/application/onboarding_environment_report_provider.dart`
  - stop embedding operation-controller state in the report.
- `lib/essentials/onboarding/application/onboarding_overlay_actions_provider.dart`
  - forward typed action context.
- `lib/essentials/onboarding/application/onboarding_gate_provider.dart`
  - forward typed context where compatibility callers remain; remove obsolete
    build-status test seam.
- `lib/essentials/onboarding/feature_level_providers.dart`
  - remove the retired reconciliation-provider export; retain only justified
    diagnostic operation exports.
- `lib/essentials/onboarding/presentation/onboarding_overlay.dart`
  - Journey-only switch, projection progress, Journey-owned copy/actions.
- `lib/essentials/navigation/presentation/view/macos_app_shell.dart`
  - watch Journey-owned overlay visibility; remove reconciliation side effect.
- `lib/features/environment_readiness/application/environment_readiness_actions_provider.dart`
  and affected readiness presentation
  - forward current action context where an async Journey transition can occur.
- `lib/essentials/logging/application/diagnostic_report_actions.dart`
  - stop expecting raw snapshot data inside the environment report; diagnostics
    may receive a separate evidence snapshot outside presentation authority.

Generated files change only through build runner and only when source
annotations/signatures require it.

### Tests

- `test/architecture/onboarding_operation_snapshot_architecture_test.dart`
- `test/architecture/forbidden_imports_test.dart`
- new or expanded Journey-only authority architecture test
- `test/essentials/onboarding/application/onboarding_journey_coordinator_provider_test.dart`
- `test/essentials/onboarding/application/onboarding_operation_snapshot_controller_test.dart`
- `test/essentials/onboarding/application/onboarding_operation_reconciliation_test.dart`
- `test/essentials/onboarding/application/virgin_onboarding_import_executor_test.dart`
- `test/essentials/onboarding/application/onboarding_environment_report_provider_test.dart`
- `test/essentials/onboarding/domain/onboarding_environment_report_test.dart`
- `test/essentials/onboarding/presentation/onboarding_overlay_progress_test.dart`
- `test/essentials/onboarding/presentation/onboarding_overlay_failure_test.dart`
- affected gate, Journey-path, shell, readiness, logging, and diagnostic-report
  tests.

The implementation should use actual compile/test feedback to narrow this list;
it must not edit unrelated files merely because they are nearby.

## 17. Obsolete code and tests expected to be removed

Expected obsolete production code:

- `ref.watch(onboardingEnvironmentReportProvider)` in coordinator `build`;
- coordinator `ref.invalidateSelf()` calls;
- `_workflowOverrideStatus` and status-first reconstruction where direct typed
  Journey state replaces them;
- `_fallbackBuildStatus`, `resolveBuildStatus`, and the Gate's corresponding
  static forwarding seam if no non-test consumer remains;
- `_lastOperationFailure` once failure is carried by the Journey projection;
- `_setWorkflowOverride`/`_clearWorkflowOverride` paths that recreate state
  from compatibility status;
- raw report, graph controller, and snapshot imports/watches in
  `OnboardingOverlay`;
- graph-status fallback `1.0` and `_progressStatusMessage` interpretation of
  `ConversationGraphBuildState`;
- embedded snapshot fields/helpers in `OnboardingEnvironmentReport`;
- shell watch of `onboardingOperationReconciliationProvider` and that provider
  if no diagnostic consumer remains;
- automatic failure persistence inside snapshot `runStage` and its
  `failureCategory` parameter;
- unused `OnboardingOperationPresenceState` if source/use proof remains empty;
- compatibility-status transition tests replaced by typed
  Episode/identity-transition tests.

Expected obsolete tests/expectations:

- the architecture assertion requiring raw snapshot consumption in the
  overlay;
- widget overrides for raw graph/snapshot providers;
- raw graph success -> `Browsing data ready`/100%;
- raw graph failure -> operation headline;
- tests that treat direct report/snapshot rendering as valid architecture.

Dormant awaiting-content branches and the development panel are removed only
if source/use proof shows them unreachable and their deletion follows naturally
from the cutover. Otherwise they are recorded as separate cleanup.

## 18. Documentation deferred until implementation proof

Do not edit these during design. After implementation and validation, update:

1. `25-ONBOARDING-AND-ARCHIVE/10-onboarding-gate.md` with the concrete stable
   listener lifetime, operation binding, action context, interruption, and
   projection types.
2. `25-ONBOARDING-AND-ARCHIVE/30-import-migration-coordination.md` with the
   exact begin/resume/executor and failure ordering.
3. the Project Conformance Audit Standard with the mandatory authority census
   question from Prompt 05.
4. generic Journey/Presence feature-integration rules with the reusable rule
   that durable asynchronous evidence is operation-identity-bound input to the
   Coordinator, never a direct presentation input.
5. the Feature 34 implementation/qualification record with tests, analyzer,
   generation, and development rehearsal evidence.
6. architecture-test documentation/expectations after the tripwires pass.

The conformance standard changes only after this implementation demonstrates
that the rule is practical.

## 19. Open human decisions

None are required to begin test-first implementation.

The design resolves the previously open points as directed:

- `recoveryDisposition` remains operation capability evidence;
- user import interruption produces explicit Continue Setup and never
  auto-resumes;
- separately authorized automatic derived-data recovery may remain automatic;
- development diagnostics remain bounded and nonauthoritative;
- active work is non-dismissible only for a matching bound active operation;
- failure/interruption is always actionable without requiring a generic close;
- an unbound completed snapshot at startup never replays terminal UI.

## 20. Mandatory implementation stop gates

Stop before proceeding or checkpointing if implementation discovers that:

1. stable listener ingestion still reconstructs the Journey owner during its
   command;
2. another component must write or independently select
   `OnboardingJourneyState`;
3. operation UUID cannot be durably obtained/resumed before active Episode
   publication;
4. any production widget still needs raw environment, graph, or snapshot state
   to decide Onboarding meaning;
5. currentness cannot reject wrong UUID, wrong process session, regressing or
   duplicate revision, or prior Journey occurrence;
6. Continue Setup would auto-resume user import or resume without an exact safe
   boundary;
7. failure publication would need to wait for or swallow a logging,
   persistence, invalidation, or diagnostic error;
8. restart cannot distinguish current resumable interruption from stale
   evidence under the stated validation rules;
9. version-1 snapshots cannot support binding/resume without a format or schema
   migration;
10. implementation requires archive-authority changes, attachment-archive
    mutation, database-schema changes, or production-data repair;
11. a new canonical authority contradiction appears; or
12. a proposed checkpoint leaves both Journey projection and an old
    presentation side door active.

No stop gate was encountered during this design task.

ONBOARDING AUTHORITY CORRECTION DESIGN COMPLETE: YES

SAFE TO BEGIN TEST-FIRST ONBOARDING AUTHORITY CORRECTION: YES
