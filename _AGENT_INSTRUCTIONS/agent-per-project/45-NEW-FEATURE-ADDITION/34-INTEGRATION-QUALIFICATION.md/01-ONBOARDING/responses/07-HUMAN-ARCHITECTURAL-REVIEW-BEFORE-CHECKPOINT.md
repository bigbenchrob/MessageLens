# MessageLens Clean-Slate Integrated Qualification
## 07 — Human Architectural Review Before Onboarding Authority Checkpoint

Date: 2026-09-24

## Executive verdict

The Prompt 06 implementation removes the original Riverpod owner-lifetime
failure and the three direct production presentation side doors. It also
establishes a single UUID chain for new attempts, a Journey-owned immutable
operation projection, and failure-first publication before fallible secondary
work.

The implementation is **not safe to checkpoint**, however. The special
prerequisite-precedence check in Prompt 07 found the prohibited case in both
production code and its test:

- a persisted failed operation is made the visible Journey Episode before the
  current environment report is allowed to select an FDA/Messages/history/
  Contacts prerequisite Episode; and
- once failed or interrupted operation evidence is bound, later prerequisite
  reports are ignored, so a newly current blocker cannot replace the stale
  operation presentation or invalidate **Continue Setup**.

That is not merely retention of durable failure evidence. It is an old
operation failure visibly overriding current prerequisite truth. The existing
test named `persisted manual-inspection failure remains authoritative`
explicitly canonizes that contradiction.

The review also found an end-to-end currentness gap for unbound snapshot
emissions and two test-quality deficiencies. No implementation file was
modified, staged, or committed.

## 1. Baseline and diff identity — NO ISSUE

- Branch: `fix/onboarding-import-stuck-state`
- HEAD: `622a4d25842f15817ec93f2dc5866627189a68ad`
- HEAD subject: `docs(onboarding): restore journey-only authority`
- Index: empty
- Tracked implementation delta: 46 modified files and 2 deleted files
- New implementation files:
  - `lib/essentials/onboarding/domain/onboarding_journey_operation_projection.dart`
  - `test/architecture/onboarding_journey_authority_architecture_test.dart`
- Deleted files:
  - `lib/essentials/onboarding/application/onboarding_operation_reconciliation_provider.dart`
  - its generated sibling
- Shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`
- Parked patch: present outside the worktree, unapplied, 21,137 bytes, SHA-256
  `43399bc44441e80fa65308ba4cf0d5bbea884b7c8a4501ad40eb6f10752e2b07`

The complete tracked diff agrees with the Prompt 06 file inventory: stable
coordinator/listener ingestion, operation binding/projection, presentation
cutover, reconciliation-provider removal, typed action plumbing, generated
Riverpod hashes, and corresponding tests. No unrelated tracked change is
mixed in. No attachment/archive implementation, database schema, archive
authority, or data-location code is changed.

The parked patch's content hash and size are unchanged. It is not applicable
on top of the current unstaged implementation because the implementation now
occupies the same hunks; that is overlap, not evidence that the patch was
applied.

## 2. Coordinator lifetime verdict — NO ISSUE

`OnboardingJourneyCoordinator` remains the only production writer of
`OnboardingJourneyState`. Its generated provider is a keep-alive
`NotifierProvider`.

The actual source mechanism that prevents recurrence of the original
Riverpod `!_didChangeDependency` failure is:

1. `build()` installs `ref.listen` subscriptions for environment evidence,
   operation evidence, and the archive-mutation lock;
2. `build()` uses `ref.read` only for initial values and has no changing
   `ref.watch` dependency;
3. report refresh invalidates only evidence providers, never the Journey
   provider or itself;
4. no production source invalidates
   `onboardingJourneyCoordinatorProvider`; and
5. Riverpod owns listener disposal/replacement with the provider element, so
   a legitimate rebuild cannot accumulate old registrations. Normal container
   teardown remains the owner-disposal boundary.

An archive-lock/report change therefore delivers evidence to the same live
notifier instance instead of marking the element outdated while its command
still needs `ref`.

## 3. Operation identity-chain verdict — BLOCKER

### Correct new-attempt chain

For a first import, the actual chain is:

```text
startVirginImportAndGraphBuild(actionContext)
-> _claimCommand
-> ArchiveMutationCoordinator.run
-> OnboardingOperationSnapshotController.begin
-> one new OnboardingOperationId
-> _bindNewOperation(controller.current)
-> OnboardingBuildingLocalData with that projection
-> VirginOnboardingImportExecutor.run(operationId: same ID)
-> OnboardingProgressReporter(operationId: same ID)
-> durable verification
-> controller.complete(operationId: same ID)
-> OnboardingReadyToStart for the same binding
```

There is no executor-created second ID. Reimport follows the same begin/bind/
execute/verify chain. Retry calls `begin` and obtains a new UUID. Explicit
Continue Setup calls `resume` and retains the interrupted logical UUID while
changing to the current process session.

While a binding exists, evidence acceptance checks Journey occurrence,
operation ID, kind, process session, status, stage/substage legality, progress
revision, and progress bounds.

### End-to-end gap

`_ingestOperationEvidence` does not restrict unbound failed/interrupted
adoption to the one startup-reconciliation window. Whenever
`_operationBinding == null` and no command is awaiting its `begin`, any failed
snapshot is bound and any apparently resumable interrupted snapshot may create
a new Journey occurrence. This includes normal application after terminal
acknowledgement, where the binding has deliberately been cleared.

The comment that an unbound callback must never invent an operation-backed
Journey occurrence is therefore stronger than the code at
`onboarding_journey_coordinator_provider.dart:176-210`. A delayed/replayed
operation-A emission can be accepted after operation A's binding has been
retired because there is no startup-adoption token or current Journey
occurrence check in that branch.

Smallest correction: make unbound durable-evidence adoption an explicit,
one-shot startup reconciliation phase. Outside that phase, retain unbound
failed/interrupted evidence for diagnostics only. Add a hostile-noise test
that delivers old failed and interrupted evidence after terminal
acknowledgement/normal application and proves the Journey is unchanged.

## 4. Semantic side-door verdict — NO ISSUE

Production Onboarding presentation and shell/readiness surfaces no longer
watch or select Journey meaning from:

- `onboardingEnvironmentReportProvider`;
- `conversationGraphBuildControllerProvider`; or
- `onboardingOperationSnapshotProvider`.

`OnboardingOverlay`, `MacosAppShell`, center-panel synchronization, advanced
Start Fresh, Environment Readiness, and the pipeline-incident panel consume
`OnboardingJourneyState`. Where report details are rendered, they come from
`journey.evidence.report`, the report occurrence already accepted by the
coordinator. No wrapper/read-model replacement was found that combines raw
evidence beside the Journey.

`OnboardingDevPanel` remains the explicit exception. It is an unreferenced
development diagnostic ViewSpec surface and its source labels raw report and
graph facts nonauthoritative. It does not select production overlay/shell
Episodes. This is a legitimate diagnostic distinction, not a production side
door.

The actual production result is semantically:

> Journey state in, widgets out.

## 5. Journey operation projection verdict — NO ISSUE

`OnboardingJourneyOperationProjection` is immutable/data-only and exposes only:

- operation ID and kind;
- coordinator-interpreted phase;
- stage/substage;
- progress revision and optional bounded numeric progress;
- bounded failure detail; and
- an unmodifiable Journey-owned action set.

It exposes no provider, controller, store, process session, timestamps,
database/filesystem capability, snapshot history, or mutation authority. Raw
`recoveryDisposition` is not exposed; the coordinator interprets it when
constructing `availableActions`.

Unknown or zero-total progress becomes null and renders indeterminate. No
elapsed-time, graph-terminal, or `1.0` fallback remains. Operation-backed
active/interrupted/terminal Episodes require a projection. Admission/begin
failure before UUID creation uses a typed `OnboardingOperationFailed` with no
fabricated projection.

## 6. Failure-publication ordering verdict — NO ISSUE in production source

The changed operation catch paths converge on
`_publishFailureBeforeSideEffects`. It constructs and publishes the Journey
failure synchronously before it:

1. asks the snapshot controller to persist failure;
2. persists graph/import failure evidence;
3. logs diagnostics; or
4. invalidates environment evidence.

Each secondary action has its own containment boundary. `runStage` now
propagates the original error instead of trying to persist a competing failure
first. Graph/import execution, durable verification, admission/begin,
reimport, continuation, automatic recovery, and completion-persistence errors
all reach the same failure-first path. A secondary error cannot strand or
replace the already-published Journey failure or mask the primary error.

Currentness is structurally held by the exclusive command token and current
operation binding while these catches execute. There is no fallible provider
read before publication. The narrower test-proof deficiency is recorded below.

## 7. Action provenance/currentness verdict — BLOCKER through prerequisite drift

The callbacks for Import, Retry, Continue Setup, Reimport, terminal
acknowledgement, and dismissal carry `OnboardingJourneyActionContext`.
Occurrence, Episode, prerequisite evidence revision, and operation ID are
checked at the coordinator boundary. Admission paths recheck their captured
context after asynchronous admission/provider acquisition; terminal dismissal
rechecks inside the post-frame callback. Stale callbacks from an older
compatible-looking Episode are rejected.

However, a bound failed or interrupted operation causes
`_ingestEnvironmentReport` to discard every later environment report. Thus the
visible action context's prerequisite revision never changes when FDA,
Messages, history, or Contacts becomes newly blocked. `Continue Setup` can
remain visible and current, and `continueInterruptedOperation` revalidates only
the old Journey context/controller record before `resume`; it does not
revalidate the latest prerequisite report. Retry has the same stale-prerequisite
problem.

The action token is mechanically current relative to stale Journey state, but
the Journey state is no longer current relative to external prerequisites.
That does not satisfy provenance/currentness.

## 8. Restart and reconciliation verdict — FAIL / BLOCKER

Conforming parts:

- prior-process `running` becomes durable `interrupted` evidence;
- ordinary user import does not auto-resume;
- exact safe-boundary continuation is exposed through coordinator-owned
  **Continue Setup**;
- an interruption already accompanied by an incompatible prerequisite report
  initially shows the prerequisite Episode and is retained privately;
- completed unbound snapshots are treated as historical rather than terminal
  UI authority; and
- the shell-owned reconciliation provider is removed.

Nonconforming parts:

- persisted `failed` evidence is bound before the current report can select an
  external prerequisite Episode;
- later prerequisite reports are ignored while failed/interrupted evidence is
  bound; and
- unbound failed/interrupted evidence can be adopted outside startup without a
  startup/currentness token.

Consequently, restart/currentness semantics are not yet deterministic under
changed prerequisites or delayed evidence.

## 9. Prerequisite-vs-persisted-failure precedence — BLOCKER

The canonical rule in `25-ONBOARDING-AND-ARCHIVE/10-onboarding-gate.md` places
Messages/FDA, local Messages/history, and Contacts prerequisites ahead of
app-owned import/graph readiness. Prompt 05 also requires an interrupted
operation with changed prerequisites to show the prerequisite Episode and
retain operation evidence privately.

In actual code:

- `_reconstructInitialJourney` at lines 114-119 immediately returns
  `_bindReconstructedOperation(...)` for any failed snapshot, before
  `_journeyFromEnvironment(...)` can select the current prerequisite;
- `_ingestOperationEvidence` at lines 187-195 repeats that unconditional
  unbound failed-evidence binding; and
- `_ingestEnvironmentReport` at lines 143-146 ignores every report while an
  operation binding or unbound command failure is active.

The test at
`onboarding_journey_coordinator_provider_test.dart:401-429` constructs missing
FDA plus a persisted manual-inspection failure and requires
`OnboardingOperationFailed`. It therefore enforces the prohibited precedence.

Accordingly, Prompt 06's phrase “persisted failure is authoritative even if
prerequisites also changed” currently means the old failure is **visible
Journey authority**, not merely retained durable evidence. That is the exact
architectural contradiction identified by Prompt 07's special stop gate.

Smallest correction:

1. apply the canonical external-prerequisite classification before publishing
   a persisted operation failure;
2. retain that failure as private/durable evidence while the prerequisite
   Episode is visible;
3. reassess it only after a fresh compatible report;
4. apply the same rule to later prerequisite changes while a failed or
   interrupted operation is bound; and
5. invert the quoted test and add FDA/history/Contacts variants plus a
   post-publication prerequisite-change test.

## 10. Specialist-boundary verdict — NO ISSUE

The coordinator has grown substantially, but its added responsibilities remain
Journey responsibilities: occurrence, Episode, operation binding/currentness,
evidence interpretation, action policy, orchestration order, and next-state
selection.

It delegates mutation admission, durable snapshot storage, reset mechanics,
graph construction, source import, FDA probing, and durable completion proof to
their existing specialists. It contains no SQL, database construction,
filesystem/archive mutation, Contacts probing, or completion-proof mechanics.
No dependency-direction regression was found.

## 11. Test and tripwire quality verdict — SHOULD FIX

Positive coverage includes deterministic prerequisite cases, one-UUID first
import, retry with a new UUID, explicit resume with the same UUID, wrong-ID/
old-session/equal-revision/illegal-stage noise, terminal callback currentness,
indeterminate progress, and secondary persistence failures. The old
`buildingGraph + graph succeeded -> ready/100%` widget expectation has been
removed rather than preserved.

Two deficiencies remain:

1. The new architecture test mostly scans a fixed list of files for three
   provider names and exact private source spellings. It would not detect a new
   wrapper/read-model that consumes raw evidence and republishes Journey
   semantics, and several assertions lock in constructor/source text rather
   than the authority principle. The tripwire should census all production
   Onboarding presentation/resolver dependencies or otherwise enforce that
   their semantic root is Journey state, while permitting an equivalent
   conforming refactor.
2. Failure-injection tests prove the final Journey failure survives secondary
   persistence errors, but do not observe the state at the moment the
   secondary store/logger is invoked. They therefore do not mechanically prove
   publication precedes the secondary action, and no logger acquisition/write
   failure is injected. A callback/spy should assert that the Journey is
   already failed inside each secondary boundary.

Most importantly, the persisted-failure test protects the architecture
violation described in section 9 and must be inverted before checkpointing.

## 12. Deletion and compatibility verdict — NO ISSUE

- Removing the reconciliation provider leaves no production reference or
  startup dependency; pure reconciliation remains coordinator-owned.
- Removing the operation snapshot from `OnboardingEnvironmentReport` does not
  break legitimate diagnostics. Diagnostic export now receives the
  Journey-approved projection separately.
- `OnboardingOperationPresenceState`/`presenceState` had no consumer and was
  safely removed.
- `OnboardingGate` is a read-only compatibility projection and typed-intent
  forwarder; it cannot assign Journey state.
- The diagnostic development panel is explicitly nonauthoritative.
- No dormant production path still references the deleted reconciliation
  provider or removed direct state.

## 13. Concrete BLOCKER findings

### BLOCKER 1 — Persisted failure overrides current prerequisite truth

- **Files/symbols:** `_reconstructInitialJourney`,
  `_ingestEnvironmentReport`, `_ingestOperationEvidence`, and the test
  `persisted manual-inspection failure remains authoritative`.
- **Rule:** external prerequisite blockers precede app-owned import/graph
  readiness; durable operation evidence does not independently select visible
  Journey state.
- **Impact:** an old failure can hide missing FDA/Messages/history/Contacts,
  remain visible after prerequisites change, and keep stale Retry/Continue
  actions current.
- **Required correction:** apply the smallest correction listed in section 9
  and invert the contradictory test.

### BLOCKER 2 — Unbound snapshot adoption is not scoped to startup

- **File/symbol:** `_ingestOperationEvidence`'s `binding == null` branch.
- **Rule:** every operation snapshot must be scoped to its unique operation/
  generation and stale evidence cannot combine with a new Journey occurrence.
- **Impact:** delayed/replayed failed or interrupted evidence can invent an
  operation-backed Journey after its binding was retired.
- **Required correction:** add an explicit one-shot startup adoption context;
  ignore/diagnose unbound operation evidence outside it; add post-acknowledgement
  hostile-noise tests.

## 14. Concrete SHOULD FIX findings

### SHOULD FIX 1 — Semantic-side-door tripwire is name-based and incomplete

Broaden the architecture rule beyond three literal provider names in six
files, and avoid requiring unnecessary private source spelling where an
equivalent conforming refactor should remain possible.

### SHOULD FIX 2 — Failure-order tests do not observe ordering

Add secondary-boundary spies, including logger failure, that assert the
Journey failure is already published when each boundary runs.

### SHOULD FIX 3 — UUID-less retry loses the failed command kind

An admission/begin failure truthfully carries no fabricated operation
projection, but `retryFailedOperation` treats every UUID-less failure alike and
only refreshes environment evidence. For a Settings reimport admission/begin
failure, the visible **Try Again** action therefore does not retry reimport; it
normally returns to the application. Preserve coordinator-owned failed-command
intent separately from operation projection, or change the action/copy so it
truthfully describes re-evaluation rather than retry.

## 15. OPTIONAL findings

- `_latestOperationEvidence` is retained as a field but is only needed to read
  the initial snapshot; later assignments are unused.
- `onboardingJourneyAllowsCommandedTransition` has no remaining production or
  test consumer after the typed coordinator cutover.

These are bounded cleanup items and are not reasons to broaden the correction
while the blockers are being fixed.

## 16. Narrow tests rerun

None. Source inspection and the existing test at lines 401-429 conclusively
establish the precedence blocker; rerunning a test that explicitly expects the
contradiction would only reconfirm that the incorrect expectation passes.

Prompt 06's reported validation remains recorded as:

- focused: 281 passed;
- architecture: 493 passed;
- full Flutter: 2,597 passed / 1 skipped;
- analyzer: clean;
- generation: successful;
- `git diff --check`: passed; and
- Project Conformance: reported PASS.

Those results do not supersede the architectural contradiction in the actual
source and test.

## 17. Exact Git status after this review

- Branch/HEAD: `fix/onboarding-import-stuck-state` /
  `622a4d25842f15817ec93f2dc5866627189a68ad`
- Index: empty
- Tracked worktree: 46 modified files and 2 deleted files, all in the Prompt 06
  implementation inventory
- Untracked after creating this response: 61 files
  - 56 previously known unrelated prompts/responses and `.vscode` artifacts;
  - current Prompt 07;
  - Prompt 06 response;
  - the two intended new implementation/test files; and
  - this Prompt 07 response
- Shared-instructions submodule: clean and unchanged at
  `95326f515ef4719f155ce6e223990398daad6311`
- Parked WIP patch: unchanged and unapplied
- Staging/commit/push/merge: none

No MessageLens Development process was launched. No real database, attachment
archive, archive configuration, or production application state was accessed
or modified.

## 18. Checkpoint recommendation

Do **not** checkpoint the Onboarding authority correction yet. Correct both
BLOCKER findings and the SHOULD FIX test/action gaps, rerun the affected narrow
and architecture tests, then repeat this architectural gate against the new
unstaged diff.

HUMAN ARCHITECTURAL REVIEW: FAIL
