# Onboarding Authority Forensic Audit

Date: 2026-09-24

## Executive conclusion

The earlier Prompt 03 stop gate was resolved by the explicit human decision in
Prompt 04: **Journey-only presentation governs**. The obsolete direct-snapshot
sentence in the canonical import/migration document has been corrected, and the
forensic audit is now complete.

The current implementation has one literal writer of `OnboardingJourneyState`:
`OnboardingJourneyCoordinator`. That is not sufficient to make it the sole
effective authority. Production onboarding presentation currently obtains
user-visible semantics from four independently state-bearing sources:

1. `OnboardingJourneyCoordinator` / `OnboardingJourneyState` — legitimate;
2. `OnboardingEnvironmentReport` — direct presentation side door;
3. `ConversationGraphBuildController` — direct presentation side door; and
4. `OnboardingOperationSnapshot` — direct presentation side door.

Thus the exact result is **four Journey-semantic state influencers, of which
three are presentation side doors**. Forwarders and renderers that retain no
independent semantic state are not double-counted.

The observed stuck modal was caused by two related defects:

- a long-lived asynchronous command continued using the coordinator's `ref`
  after a watched dependency changed, so the failure path could not publish a
  Journey failure state; and
- presentation combined the stranded `buildingGraph` Journey state with stale
  graph-build success and operation-progress evidence obtained beside the
  Journey.

The snapshot controller has good operation-local identity checks. The Journey
and presentation do not carry or validate that identity end to end. Therefore
the system does **not** mechanically prevent evidence from operation A from
being combined with Journey occurrence B.

No production code, test, generated file, real database, or attachment archive
was accessed or changed for this audit.

## 1. Repository baseline

The clean baseline was reconfirmed before the documentation correction:

- branch: `fix/onboarding-import-stuck-state`;
- HEAD: `fe14793bbee8622b08829c4973a1e6ae218e8bb2`;
- local `main`: the same commit;
- `origin/main`: the same commit;
- tracked worktree and index: clean before the two approved canonical-document
  edits;
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- canonical Feature 34 records 07 and 09: present at their tracked root
  locations;
- qualification prompts/responses and known unrelated artifacts: untracked;
  and
- preserved WIP patch: present outside the worktree at
  `/private/tmp/messagelens-onboarding-import-stuck-state-wip-fe14793-20260924.patch`,
  21,137 bytes, SHA-256
  `43399bc44441e80fa65308ba4cf0d5bbea884b7c8a4501ad40eb6f10752e2b07`;
  `git apply --check` succeeds and the patch remains unapplied.

## 2. Intended Journey architecture

### Current production Onboarding terminology

Current canonical Onboarding uses a sealed `OnboardingJourneyState` with typed
Episodes. `OnboardingJourneyCoordinator` is the sole component allowed to:

- select the active Episode;
- interpret coherent prerequisite and operation evidence;
- accept typed human intent;
- authorize operation transitions;
- publish failure, retry, completion, and normal-application state; and
- decide what happens next.

`OnboardingGate` is a read-only compatibility projection of the coordinator's
state. It forwards actions but cannot assign Journey state.

The governing flow is:

```text
operations, probes, durable records, and user intent
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

The explicit canonical invariant is now:

> **Evidence may be distributed. Journey authority may not be.** Only
> `OnboardingJourneyCoordinator` determines user-visible Onboarding state and
> what happens next. Durable operation snapshots and other providers supply
> evidence to the coordinator; presentation consumes the coordinator-owned
> Journey projection.

### Journey / Trip / Step model

The generic Presence architecture defines a Journey as the durable authority
for one undertaking. A Trip contains an ordered definition of Steps. A Step
performs or obtains one bounded result and does not select the next Step or
Trip. Step order comes from the Trip definition. The scheduler/coordinator:

- advances to the next Step in the fixed Trip order;
- interprets a terminal Step's bounded result;
- checkpoints the completed Trip occurrence;
- selects the routed next Trip;
- begins that Trip at its first Step; and
- rejects stale interactions using schedule-run, Trip-occurrence, Step-ID,
  position, and private activation identity.

Branches, loops, retries, leaving for FDA, return, and restart are therefore
coordinator decisions over current evidence and durable Journey identity. “What
is the next step?” means: what single current interaction or operation does the
coordinator authorize for the current Journey occurrence?

### Discrepancy with the “sticks and balls” reconstruction

The user's “sticks and balls” model accurately describes the original generic
Presence Schedule/Trip/Step design and its determinism requirement. Current
production Onboarding no longer runs that literal Presence schedule. The
`requiredSourcesReadinessSchedulerProvider` is explicitly a retired laboratory
composition. Production uses typed Onboarding Episodes and coordinator
transition policy instead of literal Trip and Step instances.

That is a terminology/runtime discrepancy, not an authority-policy
disagreement. Both models require one coordinator to decide semantic position
and what happens next. The existing Presence schedule tests cannot, however,
prove that the current typed Onboarding coordinator follows that contract.

## 3. Exact observed failure sequence

### Verified facts

The previously captured qualification log established this order:

1. The user pressed **Import My Messages** while the Journey was
   `OnboardingReadyToImport`.
2. At `2026-09-23T20:46:10.043607Z`, readiness/import state began clearing.
3. At `20:46:10.044650Z`, the app logged the start of the fresh onboarding
   graph build.
4. At `20:46:10.060317Z`, the compatibility status resolved to
   `buildingGraph`.
5. The durable operation record was created for the initial import and reached
   `messageDataBuild`.
6. At `20:46:10.073767Z`, Riverpod raised:

   ```text
   'package:riverpod/src/framework/element.dart': Failed assertion:
   line 675 pos 7: '!_didChangeDependency': Cannot use ref functions after
   the dependency of a provider changed but before the provider rebuilt
   ```

   The captured stack included `ProviderElementBase._assertNotOutdated`,
   `ProviderElementBase.read`,
   `OnboardingJourneyCoordinator._enterPreparationFailure` at the current
   source's failure-publication path, and
   `startVirginImportAndGraphBuild`.
7. The durable operation snapshot was persisted as `failed` at approximately
   `20:46:10.069Z`, with current stage `messageDataBuild`, the assertion in its
   bounded failure summary, and no numeric progress payload.
8. The Journey remained in the `buildingGraph` compatibility phase.
9. The app shell kept the overlay mounted, and its `ModalBarrier` was
   non-dismissible.
10. The progress content read a graph-build state reporting `succeeded`, so it
    displayed **Browsing data ready** and used the fallback progress value
    `1.0`. There was no Journey failure Episode and therefore no retry/error
    action.

### Source-proven mechanism

`OnboardingJourneyCoordinator.build()` watches
`onboardingEnvironmentReportProvider`. Starting the archive mutation changes
the mutation-lock input watched by that environment provider. The same notifier
then continues its asynchronous command and calls `ref.read(...)` before the
coordinator has rebuilt. Riverpod correctly rejects use of that outdated
provider element.

The error handler is not independent of that lifecycle. In
`_enterPreparationFailure`, it reads `appLoggerProvider` before calling
`_setWorkflowOverride(preparationFailed)`. The stale-`ref` assertion therefore
prevents the actual Journey failure publication.

The contradictory UI is then mechanically explainable:

- modal visibility came from the stranded Journey-derived gate status;
- dismissibility was hard-coded false;
- **Browsing data ready** came directly from
  `ConversationGraphBuildController`'s stale `succeeded` state;
- fallback 100% also came from that graph state because the failed operation
  snapshot had no numeric progress; and
- snapshot stage/count copy, when present, came directly from the snapshot
  stream without matching its operation ID to the Journey.

### Strongly supported inference

The graph controller's successful value belonged to an earlier completed graph
build or a prior provider occurrence. Its lack of a Journey-owned operation ID,
combined with the direct widget read, made it eligible for the current
presentation. The exact earlier build that produced that value was not encoded
in the retained state and therefore cannot be identified from source alone.

## 4. Production authority inventory

“Can influence Journey meaning?” distinguishes semantic state selection from
pure execution/evidence. “Via coordinator” is lawful; “direct” is a side door.

| Component | Layer | State owned | Durable / ephemeral | Writers | Readers | Can influence Journey meaning? | Can outlive operation? | Operation-ID / generation bound? |
|---|---|---|---|---|---|---|---|---|
| `OnboardingJourneyCoordinator` | application | active typed Journey Episode, occurrence, workflow override, accepted local history, last failure | process-ephemeral, keep-alive | coordinator methods only | gate, readiness surface, overlay, diagnostics | Yes; canonical authority | Process lifetime, not restart | Journey occurrence exists; active operation ID does not |
| `OnboardingGate` | application compatibility seam | compatibility status derived from Journey | ephemeral | derived build only | shell, navigation sync, actions, legacy presentation | No independent authority | No | Inherits Journey only |
| `OnboardingEnvironmentReport` provider/evaluator | application evidence aggregation | one coherent readiness classification plus source, DB, lock, failure, graph, archive, and operation facts | ephemeral/reconstructable | evaluator | coordinator, overlay, reconciliation, dev panel | Yes via coordinator; also **direct side door** in overlay | Reconstructs after operation | Evidence revision added only after coordinator; no operation match at presentation |
| FDA, Contacts, message-history and DB probe providers | infrastructure/application evidence | external-source/readiness facts | external or ephemeral | OS/probe readers | environment report | Via coordinator only | Yes as external conditions | No operation identity; freshness belongs to report occurrence |
| attachment location and live update monitor | feature evidence | archive availability and monitor state | mixed | feature controllers | environment report | Via report/coordinator only | Yes | Their own identities/policies, not Onboarding operation ID |
| archive mutation and DB-maintenance locks | application safety authority | current mutation admission/maintenance occupancy | ephemeral | lock coordinators | environment report, Journey coordinator, graph build | Via coordinator; also invalidates its watched dependency | No | Owner labels/operation kind, not Journey operation ID |
| onboarding failure store | persistence evidence | import/graph failure records | durable | import/graph failure paths | environment evaluator | Via report/coordinator | Yes | Batch/failure evidence; not bound to Journey occurrence |
| `OnboardingOperationSnapshotController` and store | operation evidence | operation ID/session/kind/status/stage/progress/failure/completion | durable overlay setting plus in-memory stream | admitted executors/controller methods/reconciliation | environment report, coordinator diagnostics, overlay | Via report/coordinator; also **direct side door** in overlay | Yes, until next begin/reset | Yes internally; not bound end to end to Journey/presentation |
| operation reconciliation provider | startup evidence reconciliation | no independent state; reconciles interrupted snapshot from report evidence | ephemeral side effect | startup provider | operation controller/store | Can change evidence consumed by coordinator | Runs after restart | Uses persisted current snapshot ID internally |
| `VirginOnboardingImportExecutor` | operation execution | no retained semantic state | per invocation | coordinator invokes | snapshot controller and graph-build callback | No; publishes evidence/results | No | Creates operation ID internally after Journey entered build phase |
| `ConversationGraphBuildController` | feature operation execution/state | idle/running/succeeded/failed, owner, timestamps, report/error | process-ephemeral keep-alive | graph controller | coordinator, environment report, status surfaces, overlay | Yes via coordinator; also **direct side door** in overlay | State survives completed invocation for provider lifetime | Owner label only; no unique Onboarding operation ID |
| reset service and durable completion verifier | operation specialists | no retained Journey state | per call | coordinator/executors | coordinator/snapshot controller | Via coordinator only | No | Receive operation context indirectly; verifier result is supplied with ID at snapshot completion |
| typed Onboarding action providers | application intent seams | action loading state only | ephemeral | widgets | gate/coordinator | No; forward intent | No | Coordinator checks current Episode, not caller generation |
| app shell and navigation sync | presentation/routing | overlay visibility and center/sidebar routing derived from gate | ephemeral | framework/build | user | Yes as projection only; no independent semantic source | No | Inherits Journey compatibility status |
| Environment Readiness surface/view | application projection/presentation | view model derived from Journey and `journey.evidence.report` | ephemeral | resolver | panel view | No side door; lawful Journey projection | No | Journey occurrence/evidence revision available |
| `OnboardingOverlay` / `_ProgressContent` | presentation | combines gate, Journey, report, graph state, and snapshot into copy/progress/controls | widget-ephemeral | build logic | user | **Yes; combines four semantic sources** | Rebuildable | Does not check operation ID or Journey occurrence for side inputs |
| advanced Start Fresh controller/overlay | separate bounded workflow | its own phase and occurrence | ephemeral | Start Fresh action | dedicated overlay | Separate workflow; hands off to Onboarding explicitly | No | Yes, occurrence-guarded |
| Onboarding dev overrides/panel | development diagnostic seam | simulated readiness/failure facts | ephemeral | dev controls | environment report/dev panel | Only in development diagnostics; excluded from production count | Process lifetime | No |
| retired required-sources Presence scheduler | historical/laboratory | durable Schedule/Trip/Step run | durable Presence DB | Presence scheduler | laboratory runner/tests | Not consumed by production Onboarding | Yes | Yes: run, Trip occurrence, Step ID/position |

### Exact semantic-source count

There are exactly **four state-bearing sources** from which current production
Onboarding presentation can derive user-visible Journey semantics. One is the
coordinator-owned Journey; three bypass it. Read-only forwarding seams, action
dispatchers, renderers, and individual evidence producers are inventoried but
not double-counted as independent semantic sources.

## 5. Journey write-path inventory

There is exactly one assignment site for production Journey state:
`_publishJourneyState` validates the compatibility transition and executes
`state = next`. `build()` also returns the reconstructed initial/current state.
All mutation methods belong to the same coordinator. The effective weakness is
not a second writer; it is that evidence lifecycles and presentation can bypass
or prevent this writer.

| Path | Trigger and precondition | Async/late risk | Currentness/identity check | Finding |
|---|---|---|---|---|
| `build` -> `_journeyStateFor` | environment report/provider reconstruction | asynchronous report can rebuild provider | coherent report receives a new evidence revision | Sole constructor, but watched dependency can invalidate an in-flight command |
| `refreshEnvironment` | recheck intent | invalidates report and self | no caller occurrence token | Rebuild-based transition; safe intent, but identity is implicit |
| `acceptLocalMessageHistory` | only `OnboardingNeedsLocalHistoryConfirmation` | synchronous | exact runtime state type | Correct Episode gate; acceptance is process-local |
| `startVirginImportAndGraphBuild` | only `OnboardingReadyToImport`; FDA rechecked | several frame waits and long operation | state/FDA checked before start; operation ID created later inside executor | Journey build state is not bound to returned operation ID |
| `_runAdmittedVirginImport` | archive mutation admitted | provider dependencies change during await | no provider-occurrence guard | Observed stale-`ref` failure path |
| `retryFailedOperation` | only `OnboardingOperationFailed` | awaits fresh report | state checked only at entry | No expected Journey occurrence across await |
| `startReimport` / `_startReimport` | only `OnboardingNormalApplication` | long reset/build/verify chain | operation ID used inside evidence controller | archive admission and `begin` errors are not uniformly converted to Journey failure |
| automatic recovery | report says derived reset is required | scheduled post-frame and long mutation | local in-flight/suppression flags; operation ID after admission | provider reconstruction can discard local flags; failure path uses same `ref` |
| `_verifyAndCompleteInstallation` | operation reached durable verification | async verifier and persistence | snapshot ID checked; Journey has no stored matching ID | snapshot persistence failure can prevent Journey failure publication |
| `dismiss` | terminal acknowledgement UI | deferred one frame | no expected occurrence supplied | A stale callback could dismiss a newer compatible terminal occurrence |

Answer: there is one logical transition owner in code, but it is **not yet one
effective semantic authority** because three state sources can independently
change presentation meaning, and failure publication depends on the lifecycle
of watched evidence.

## 6. Presentation side doors

`OnboardingOverlay` observes five provider expressions, but two belong to the
same authority:

- `onboardingJourneyCoordinatorProvider` — canonical Journey;
- `onboardingGateProvider` — read-only compatibility projection of that Journey;
- `onboardingEnvironmentReportProvider` — side door 1;
- `conversationGraphBuildControllerProvider` — side door 2; and
- `onboardingOperationSnapshotProvider` — side door 3.

The exact direct side-door routes are:

1. **Environment report -> overlay.** `_WelcomeContent` and FDA/awaiting content
   receive the directly watched report for copy, detailed evidence, and action
   availability. Those branches are normally reached through Journey-derived
   routing, but their facts are from a separately reconstructing provider rather
   than `journey.evidence.report`.
2. **Graph controller -> `_ProgressContent`.** Its status independently selects
   building/success/failure copy and the 100% fallback. It has no unique
   Onboarding operation ID and can retain a prior terminal value.
3. **Operation snapshot stream -> `_ProgressContent`.** Its progress and
   substage independently select progress value and copy. The widget does not
   compare `operationId`, `processSessionId`, kind, revision, or stage with the
   current Journey because the Journey carries none of those identities.

`OnboardingGate` is not counted as a side door because it is mechanically
derived from Journey state. The Environment Readiness center-panel surface is a
positive example: it watches the Journey and uses `journey.evidence.report`, not
an independently watched report.

## 7. `OnboardingOperationSnapshot` audit

### Purpose, persistence, and lifecycle

The snapshot was introduced to durably record admitted long-running work:
identity, session, typed stage/substage, bounded measured progress, anomaly
counts, interruption, failure, and completion. It is stored as version-1 JSON
under one overlay setting. Its controller loads the record at startup, converts
a `running` record from a different process session to `interrupted`, and emits
the current record plus later changes. A terminal record remains until a later
`begin` replaces it or authorized reset calls `resetToIdle`.

Writers are the operation controller, admitted first-import/reimport/recovery
executors, and startup reconciliation. Readers are the environment report,
coordinator diagnostics, reconciliation, and—incorrectly—presentation.

### Field classification

| Classification | Fields / members | Conclusion |
|---|---|---|
| A — legitimate durable operation evidence | `operationId`, `processSessionId`, `kind`, operation `status`, `currentStage`, `currentSubstage`, `completedStages`, `startedAtUtc`, `stageStartedAtUtc`, `lastProgressObservedAtUtc`, `progress`, `progressRevision`, `sourceAnomalyCounts`, failure category/time/summary, `finishedAtUtc` | These truthfully describe one operation attempt and may remain durable. |
| B — evidence requiring Journey projection before presentation | operation `status`, stage/substage, completed stages, progress/revision/counts, failure details, finish/completion evidence | They may inform UI only after the coordinator validates identity/currentness and projects them into current Journey state. |
| C — Journey-semantic state that must not live here | None of the persisted fields is inherently Journey state if its vocabulary remains explicitly operation-scoped. | The defect is consumption/interpretation, not necessarily persisted shape. |
| D — obsolete/duplicated | `OnboardingOperationPresenceState` and the computed `presenceState` getter | Repository search finds only their definition; they duplicate status-to-presentation vocabulary and appear unused. The legacy unnormalized-count JSON key is compatibility data, not proven obsolete. |
| E — design decision | `recoveryDisposition`; policy for retaining completed snapshots after verified Journey handoff | The record may state an operation recovery capability/fact, but the coordinator must decide retryability. Human policy must decide restart adoption/retention. |

The snapshot's `completed`, `failed`, and `interrupted` words overlap Journey
vocabulary, but they can remain lawful when explicitly scoped to operation X.
They become competing authority only when a widget treats them—or related graph
state—as an answer to “what is Onboarding doing now?”

No schema migration is clearly required to restore authority. Existing version-1
records can remain readable and be interpreted only through the coordinator.

## 8. Operation identity and stale-result protection

### What is protected

The operation controller creates a UUID for every `begin`, records a process
session UUID, and calls `_requireCurrent(operationId)` for stage, progress,
failure, and completion mutation. It rejects stale IDs and rejects mutation of a
terminal record. Startup converts a running record from another process to
`interrupted`. These are sound protections inside the durable evidence store.

### What is not protected

- First-run Journey state moves to `buildingGraph` before the executor creates
  and returns an operation ID.
- No `OnboardingJourneyState` running/failure/completion type carries the active
  operation ID or evidence revision.
- The coordinator does not subscribe to the snapshot stream as a current
  operation projection. The environment report reads `controller.current` while
  constructing a report, but controller stream changes do not themselves bind
  or advance the Journey.
- `_ProgressContent` accepts whichever snapshot the provider emits and whichever
  graph state the graph provider retains.
- `ConversationGraphBuildState` has an owner label and timestamps but no unique
  operation/generation identity tied to the Journey.
- completion/failure callbacks check snapshot identity in some paths, but not a
  stored Journey identity after every asynchronous gap.

Therefore the architecture does not mechanically prevent:

- stale success after retry — graph success can remain directly visible;
- stale progress after failure — terminal snapshot progress can remain and is
  directly visible;
- stale failure after a new Journey occurrence — direct report/snapshot facts
  have no Journey match;
- provider reconstruction replaying prior completion — terminal snapshot is
  intentionally loaded and graph state may persist for process lifetime;
- delayed callbacks after Journey moved — most action callbacks have no expected
  occurrence; and
- prior-session evidence becoming current Journey meaning — reconciliation can
  lawfully use it, but the Journey lacks an identity-binding decision reflected
  to presentation.

Operation identity is locally strong and end-to-end incomplete.

## 9. Failure ownership

The required property—failure of an evidence producer cannot prevent the
Journey from reaching failure/retry state—is currently violated or weakened in
these paths:

1. `OnboardingOperationSnapshotController.runStage` awaits durable `fail()` in
   its catch before rethrowing. A store-save failure can replace or mask the
   original operation error.
2. First-run graph failure awaits `_recordConversationGraphBuildFailure` before
   `_finishFirstRunWithFailure`. Failure-store persistence can prevent the
   Journey transition.
3. `_finishFirstRunWithFailure` and `_finishReimportWithFailure` read logging and
   invalidate the report before publishing the fallback Journey state.
4. `_enterPreparationFailure` reads the logger before publishing
   `preparationFailed`; this is the path that failed in the observed run.
5. Durable-verification catch awaits snapshot `fail()` before calling
   `_enterPreparationFailure`. Snapshot persistence failure can prevent Journey
   failure publication.
6. Reimport mutation admission and operation `begin` are not enclosed by one
   outer conversion to Journey failure.
7. Automatic recovery has an outer admission catch, but its final conversion
   still relies on `_enterPreparationFailure` and the current notifier `ref`.

The operation controller records useful failure evidence, but Journey failure
publication is not failure-independent. It must become the first non-fallible
semantic action in every catch path; logging/persistence should follow or be
best-effort evidence work.

## 10. Deterministic behavior and tests

### What current tests prove

- coordinator tests prove classification of coherent reports, guarded local
  history acceptance, ignored import intent outside `readyToImport`, selected
  transition policy, and protection against an older environment-provider
  occurrence replacing a newer report;
- operation-controller tests prove typed stage/progress persistence, failure
  recording, process interruption, completion proof compatibility, bounded
  progress cadence, and rejection of a stale operation ID inside the controller;
- retired required-sources Presence tests prove exact Schedule/Trip/Step
  branches, loops, FDA return, retries, and restart checkpoints for the old
  laboratory scheduler; and
- generic Presence tests prove run/Trip/Step currentness and stale choice
  rejection.

### Missing production proof

There is no current typed-Onboarding replay test that drives one complete
sequence through:

```text
FDA absent -> leave app -> FDA restored -> local history decision -> Contacts
-> ready -> import -> operation failure -> retry -> success -> verification
-> acknowledgement -> restart
```

There is also no hostile replay that injects stale progress, success, failure,
provider reconstruction, or a delayed callback from operation A after operation
B/current Journey occurrence has begun.

### Tests and tripwires encoding the violation

- `onboarding_overlay_progress_test.dart` overrides the Journey, graph state,
  snapshot, and environment report independently.
- Its “active first-run success keeps its existing presentation” test requires
  `buildingGraph` plus graph-controller `succeeded` to render **Browsing data
  ready** and progress `1.0`. That is the exact observed contradiction.
- Other progress tests require direct snapshot substage/count rendering.
- `forbidden_imports_test.dart`, in “Onboarding progress remains typed and
  service-owned,” explicitly requires `onboarding_overlay.dart` to contain
  `onboardingOperationSnapshotProvider`.
- `onboarding_operation_snapshot_architecture_test.dart` forbids presentation
  from mutating the snapshot controller/store, but does not forbid semantic
  reads.
- No architecture test prohibits presentation imports of the snapshot,
  environment report, or graph controller; requires progress to be present on
  Journey-owned state; or checks end-to-end operation-ID binding.

Passing tests therefore protect both valid local behavior and the invalid
cross-authority composition.

## 11. Required state-flow graph

```text
FDA / Contacts / DB / archive / lock evidence
feature operation observations
operation execution
        |
        v
durable operation evidence (operation ID + revision)
        |
        v
OnboardingJourneyCoordinator
  - owns current Journey occurrence
  - binds one current operation ID
  - rejects stale/non-monotonic evidence
  - publishes failure even if evidence persistence/logging fails
        |
        v
OnboardingJourneyState
  - Episode
  - Journey-owned current-operation projection
  - progress/failure/actions already interpreted
        |
        +--------------------+
        v                    v
read-only gate/navigation    readiness/overlay presentation
                             (no raw evidence reads)
```

## 12. Actual state-flow graph

```text
FDA / Contacts / DB / archive / locks / failures / graph / snapshot
        |
        v
OnboardingEnvironmentReport ------------------------------+
        |                                                   |
        v                                                   v
OnboardingJourneyCoordinator -> OnboardingJourneyState -> OnboardingOverlay
        |                            |                      ^       ^
        v                            v                      |       |
OnboardingGate ----------------> shell/modal visibility    |       |
                                                            |       |
OnboardingEnvironmentReport --------------------------------+       |
                      [VIOLATION: direct report]                     |
                                                                    |
ConversationGraphBuildController -----------------------------------+
        |             [VIOLATION: ready/failure copy and 100%]
        +-> EnvironmentReport / coordinator evidence

operation execution -> snapshot controller/store -> snapshot stream ------+
        |                    |                                             |
        |                    +-> EnvironmentReport/reconciliation           |
        +-- unique ID inside controller                                    |
                                                                           v
                                                              OnboardingOverlay
                                                    [VIOLATION: direct progress]

archive mutation lock -> EnvironmentReport invalidation -> coordinator
                                                       in-flight stale `ref`
                                                       -> failure publication
                                                          can be prevented
```

There is no second component assigning `OnboardingJourneyState`; the violations
are direct semantic presentation paths and a coordinator lifetime boundary that
allows evidence invalidation to disable the authority itself.

## 13. Historical drift chronology

### VERIFIED HISTORY

1. **2026-06-09 — `105a03dc...`, “whole bunch of Codex slices”.** The overlay
   already directly watched `ConversationGraphBuildController`. It used graph
   `succeeded`/`failed` to select copy and used success as a 100% fallback. The
   graph side door therefore predates the durable snapshot.
2. **2026-08-23 11:09 -0700 — `057230261e2e...`, “add durable onboarding
   operation snapshot”.** This introduced the typed durable snapshot,
   operation/process UUIDs, controller/store, interruption reconciliation,
   completion proofs, and architecture tests. The snapshot was legitimate
   operation evidence at introduction; the overlay did not yet read it.
3. **2026-08-23 12:33 -0700 — `b0995e665842...`, “instrument onboarding
   progress”.** This atomically added real bounded progress observations, direct
   overlay consumption of `onboardingOperationSnapshotProvider`, widget tests,
   an architecture-test expectation for that dependency, and the canonical
   sentence “Presentation consumes `OnboardingOperationSnapshot`.” Repository
   history cannot order code before documentation within one commit; they
   entered together.
4. The local problem visibly solved by that commit was truthful detailed
   substage/count progress without inspecting repositories or fabricating timer
   progress. That purpose is shown by the commit title, source changes, tests,
   and Progress Reporting text.
5. **2026-08-26 10:11 -0700 — `15dafa6f3715...`, “centralize onboarding journey
   authority”.** This introduced the typed `OnboardingJourneyCoordinator`,
   sealed Episodes, and canonical sole-authority wording. It left direct graph
   and snapshot presentation paths and the conflicting import/migration sentence
   intact. The contradiction was therefore visible in the repository at the
   moment Journey-only authority was centralized.
6. **2026-08-26 12:23 -0700 — `a9cfb2397ba5...`, “add live onboarding journey
   path”.** The overlay began watching Journey state while retaining gate,
   environment report, graph controller, and snapshot reads. Tests likewise
   supplied those states independently. This made the split authority explicit
   in one widget.
7. **2026-09-13 — `d976e9a309c1...`, “feat(onboarding): expose interrupted
   import stage”.** Interrupted-operation evidence gained more user-facing
   meaning through the environment report/coordinator and overlay details. This
   mostly used the proper evidence route, but it increased the importance of a
   snapshot whose direct presentation path still existed.
8. **2026-09-23.** Clean-slate qualification exposed the split: stranded
   Journey state combined with stale graph success and operation evidence.

### STRONGLY SUPPORTED INFERENCE

- Direct snapshot reading was chosen as the shortest route from new durable
  progress instrumentation to an existing overlay. It solved a real progress
  problem locally while bypassing a Journey progress projection that did not
  yet exist.
- Later Journey centralization focused on transition ownership and did not
  inventory every provider capable of changing user-visible semantics. That is
  why a single notifier coexisted with several effective presentation
  authorities.

### UNKNOWN

- Whether the direct-snapshot sentence was consciously intended as an exception
  to future Journey-only presentation. No commit evidence establishes that
  intent.
- Whether provider reconstruction was an explicit reason for direct snapshot
  consumption, beyond the general durable/restart requirements documented when
  the snapshot was introduced.
- Which specific earlier graph operation supplied the stale `succeeded` state in
  the observed run; the state lacks a unique operation identity.

## 14. Project-wide analogous patterns

### Positive pattern: Presence scheduler

`PresenceScheduler` and its repository provide the clearest existing pattern:

- one scheduler owns current run/Trip/Step;
- repository writes require expected schedule-run ID, Trip occurrence, Step
  definition ID, and Step position;
- choice callbacks are bound to a private activation token and expected Step;
- stale/duplicate interactions are rejected; and
- `PresenceRunner` renders the scheduler's current Step rather than recombining
  independent operational sources.

The retired onboarding required-sources tests demonstrate branches, loops,
FDA remediation, retry, and restart under that identity model.

### Positive adjacent pattern: advanced Start Fresh

`AdvancedStartFreshPresentationController` owns a separate bounded workflow
and increments an occurrence. Its action checks that occurrence before applying
success/failure, and the host explicitly arbitrates the handoff to Onboarding.
It is not a replacement for durable operation identity, but it demonstrates
late-result rejection at a presentation boundary.

### No second confirmed defect

A bounded comparison found diagnostic surfaces that directly observe their own
subsystem state (for example the graph status sheet), but those surfaces are not
coordinating a Journey. No second confirmed production workflow with the exact
coordinator + durable snapshot + presentation split was found within this
audit's scope. The architecture blind spot is nevertheless reusable because
current tripwires check mutation ownership more strongly than semantic read
ownership.

## 15. Exact correction boundary

The correction must change these boundaries and no broader product behavior:

- `OnboardingJourneyCoordinator` remains the sole Journey-semantic authority.
- Environment report, graph controller, operation snapshot/controller,
  reconciliation, probes, locks, failure stores, reset service, and completion
  verifier remain evidence/execution specialists.
- Running Journey states gain a coordinator-owned operation projection carrying
  the current operation ID/generation, stage/substage, bounded progress revision,
  and interpreted failure/action state.
- The coordinator must own or bind the operation ID before publishing the
  corresponding running Episode. Executors should receive that bound identity
  rather than create an unobservable identity after presentation has advanced.
- Only matching operation ID and monotonic evidence revision may update the
  current projection; late evidence is ignored or recorded diagnostically.
- Overlay and other production presentation watch Journey state (or read-only
  projections derived solely from it). They stop importing the raw environment
  report, graph controller, and operation snapshot for semantic decisions.
- Every catch path publishes a valid Journey failure/retry destination before
  fallible logging or evidence persistence, or uses a lifetime-independent
  command authority that cannot be invalidated by its own evidence changes.
- Terminal/non-running states cannot render a blocking active-work modal.

The attachment archive preservation invariant and all archive mutation
admission boundaries remain unchanged.

## 16. Recommended implementation phases

1. **Tests and tripwires first.** Add a failing architecture test prohibiting
   presentation dependencies on raw report/snapshot/graph state; add deterministic
   replay tests for the observed error, stale evidence, retry, restart, and FDA
   return.
2. **Stabilize the authority lifetime.** Separate the coordinator's durable
   command/state owner from reconstructing evidence dependencies. A dependency
   change caused by the command must not invalidate the object required to
   finish or fail that command.
3. **Bind operation identity.** Make the coordinator obtain/own the operation ID
   before publishing running state, carry it in Journey projection, and accept
   only matching monotonic evidence.
4. **Project progress through Journey.** Add typed operation progress/failure to
   the current Journey Episode and cut presentation over to that projection.
5. **Remove side doors.** Delete raw report, graph-controller, and snapshot
   semantic reads from the overlay; update tests that currently require them.
6. **Harden failure order.** Publish failure/retry state independently, then
   persist/log evidence best-effort without masking the original error.
7. **Clean obsolete vocabulary.** After use-search confirmation, remove the
   unused operation `presenceState`; retain version-1 snapshot decoding unless a
   separately justified migration is needed.
8. **Full deterministic qualification.** Run analyzer, focused/unit/widget/
   architecture tests, full tests, and a separately authorized development-only
   rehearsal.

The work can be staged internally, but no intermediate checkpoint may expose two
user-visible authorities. The Journey projection and tests must exist before,
or in the same atomic slice as, removal of each direct presentation read.

## 17. Tests and architecture tripwires required

Replace tests that independently inject graph/snapshot success into an active
Journey with Journey-projection tests. Add tripwires that:

- prohibit onboarding presentation imports/references to
  `onboardingEnvironmentReportProvider`,
  `conversationGraphBuildControllerProvider`, and
  `onboardingOperationSnapshotProvider`;
- require running Journey states to carry a bound current operation identity;
- require evidence updates to match identity and monotonic revision;
- prove stale operation A success/progress/failure cannot affect operation B;
- prove every executor/persistence/logging failure produces a Journey
  failure/retry state; and
- replay exact Episode sequences for FDA return, branches, loops, retry,
  restart, success, and delayed callbacks.

## 18. Open human decisions

1. Define whether `recoveryDisposition` is purely an operation capability/fact
   or includes coordinator retry policy. The latter must move to Journey
   interpretation.
2. Define restart adoption: under what verified conditions may interrupted
   evidence be bound to a new process's current Journey occurrence, and is the
   result automatic resume or explicit retry?
3. Decide whether dormant legacy awaiting-content branches and the development
   panel remain after Journey-only presentation, or are separately retired.
4. Decide whether active work remains non-dismissible. This is compatible with
   the architecture only while the Journey proves matching work is active;
   failure/interruption must always expose an action.

No decision about persisted snapshot schema is required merely to restore sole
authority.

## 19. Project Conformance Standard recommendation

Proposed mandatory audit question:

> For every changed stateful workflow, enumerate every component capable of
> advancing, completing, failing, retrying, cancelling, dismissing, or changing
> user-visible workflow state. Is exactly one component authoritative, and are
> all durable or asynchronous evidence sources operation-identity-bound inputs
> to that authority rather than direct presentation inputs?

After the correction is implemented and proven, place this question in the
Project Conformance Audit Standard's stateful-workflow section and mirror the
invariant in generic Presence Journey coordination/feature-integration rules.
The corrected Onboarding documents should remain the concrete exemplar.

## Final determinations

- Canonical authority set after Prompt 04 correction: consistent; no second
  material contradiction found.
- Exact Journey-semantic state influencers: **4**.
- Exact direct presentation side doors: **3**.
- Operation identity prevents stale evidence end to end: **No**.
- Failure handling is Journey-independent: **No**.
- Existing tests encode the violation: **Yes**.
- Persisted snapshot migration required to restore authority: **No**.
- New Prompt 03 stop gate encountered: **No**.
- Safe to proceed to a separately reviewed correction design: **Yes**.

ONBOARDING AUTHORITY FORENSIC AUDIT COMPLETE: YES

SAFE TO DESIGN ONBOARDING AUTHORITY CORRECTION: YES
