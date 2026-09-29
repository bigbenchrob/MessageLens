# MessageLens Clean-Slate Integrated Qualification
## 06 — Implement the Onboarding Authority Correction

Prompt 05 produced an approved design for restoring sole Journey authority.

Read in full before editing:

- `01-FORENSIC-ANALYSIS-OF-ONBOARDING-FAILURE.md`
- `02-NECESSARY-CORRECTIONS-TO-ONBOARDING.md`
- `responses/03-ONBOARDING-AUTHORITY-FORENSIC-AUDIT.md`
- `responses/04-RESOLVE-CANONICAL-ONBOARDING-AUTHORITY-CONTRADICTION.md`
- `responses/05-ONBOARDING-AUTHORITY-CORRECTION-DESIGN.md`

Also read the corrected canonical onboarding documents and the project Riverpod,
architecture, testing, and Journey/Presence currentness rules cited by the
design.

The governing invariant is:

> **Evidence may be distributed. Journey authority may not be.**

The approved implementation target is:

```text
operation execution / durable evidence
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

This task implements the approved correction.

Do NOT redesign the correction from scratch.
Do NOT apply the parked WIP patch.
Do NOT launch MessageLens Development.
Do NOT repeat Start Fresh or import with real data.
Do NOT access production MessageLens data.
Do NOT access or mutate real attachment archives.
Do NOT change database schemas or attachment authority.

Leave the completed implementation **unstaged and uncommitted** for human review.

---

# 1. Baseline

Expected current branch:

`fix/onboarding-import-stuck-state`

Expected starting HEAD:

`622a4d25842f15817ec93f2dc5866627189a68ad`

Expected subject:

`docs(onboarding): restore journey-only authority`

Verify:

- tracked worktree clean;
- index clean;
- shared-instructions submodule clean;
- parked WIP patch remains outside the worktree, unchanged and unapplied;
- qualification prompts/responses remain untracked and untouched;
- no MessageLens Development process is running.

STOP if the baseline differs materially.

---

# 2. Use Prompt 05 as the implementation specification

Implement the design in:

`responses/05-ONBOARDING-AUTHORITY-CORRECTION-DESIGN.md`

The following decisions are settled:

- `OnboardingJourneyCoordinator` remains the sole Journey-semantic authority;
- the coordinator becomes a stable keep-alive notifier using listener/event
  ingestion rather than watch-driven self-reconstruction;
- operation UUID is bound before a running Episode is published;
- running/terminal operation Episodes carry a Journey-owned immutable operation
  projection;
- presentation consumes Journey state only;
- the three raw presentation side doors are removed:
  - environment report;
  - graph controller;
  - operation snapshot;
- failure publication occurs before fallible logging/persistence/invalidation;
- user actions that can become stale are bound to Journey occurrence and, where
  applicable, operation ID;
- interrupted user onboarding never auto-resumes merely because a snapshot
  exists;
- version-1 operation snapshots remain compatible;
- specialist services retain their existing responsibilities;
- active work may remain non-dismissible only while Journey proves the matching
  operation is active.

Do not reopen these decisions unless source inspection triggers one of the
explicit stop gates.

---

# 3. Test-first: add the failing authority tripwires

Before changing production behavior, add the architecture tests/tripwires
required by the approved design.

At minimum, create tests that currently fail because production presentation
still references:

- `onboardingEnvironmentReportProvider`;
- `conversationGraphBuildControllerProvider`;
- `onboardingOperationSnapshotProvider`.

Also require:

- active operation Episodes have a bound operation ID/projection;
- the Journey coordinator does not `ref.watch` changing evidence in `build()`;
- the coordinator does not `ref.invalidateSelf()`;
- no production source invalidates
  `onboardingJourneyCoordinatorProvider`;
- shell startup does not independently trigger reconciliation;
- production presentation consumes typed Journey state/projection.

Run these tests and record the expected failures.

Do not stop because the new tests correctly expose the current architecture.

STOP only if the tests cannot express the approved invariant without requiring a
different architecture.

---

# 4. Add deterministic replay fixtures before the cutover

Add focused coordinator/replay test infrastructure for current typed Onboarding
Episodes.

Create failing/partial coverage for:

- FDA absent -> leave app -> FDA restored;
- local-history confirmation;
- Contacts blocker;
- first import success;
- first import failure -> retry -> success;
- interrupted import -> explicit Continue Setup;
- durable verification failure;
- terminal acknowledgement;
- restart reconstruction.

Also add hostile asynchronous noise fixtures capable of injecting:

- late graph success from operation A;
- late snapshot progress from A;
- late failure from A;
- duplicate/regressing evidence revision;
- old process-session running evidence;
- environment-provider reconstruction;
- delayed Retry/Continue/terminal callbacks from a prior Journey occurrence.

These tests may remain failing until the authority tranche is implemented.

---

# 5. Implement the stable Journey owner

Refactor `OnboardingJourneyCoordinator` according to Prompt 05:

- keep it one generated keep-alive notifier;
- remove watched changing evidence from `build()`;
- install listener/event ingestion for environment evidence, operation evidence,
  and other approved changing facts;
- use stable reads only for initial reconstruction;
- remove production self-invalidation;
- make evidence refresh invalidate evidence providers, not the Journey provider;
- keep the same coordinator object/state owner alive through its own long-running
  command.

Do not introduce:

- a second Journey notifier;
- a bridge that derives Journey meaning;
- a global singleton;
- the retired Presence scheduler as production Onboarding runtime.

Add focused regression coverage that changes the environment/mutation-lock
evidence during a running command and proves the prior
`!_didChangeDependency` stale-`ref` assertion cannot occur.

---

# 6. Implement Journey-owned operation identity

Use the existing `OnboardingOperationId` UUID as the operation identity.

For newly started operations:

1. validate current Journey action context;
2. obtain mutation admission;
3. revalidate context/prerequisites;
4. call operation `begin(...)`;
5. obtain/durably publish the operation UUID;
6. bind that UUID to the current Journey occurrence;
7. only then publish a running Episode;
8. pass the exact UUID into the executor.

The executor must no longer allocate a hidden second operation ID.

For retry:

- a new attempt receives a new UUID.

For validated interrupted continuation:

- retain the same logical UUID;
- `resume(...)` moves it to the current process session;
- running presentation appears only after resume persistence succeeds.

Do not publish a running Episode without a bound operation identity.

---

# 7. Implement the Journey-owned operation projection

Add the narrow immutable operation projection defined in Prompt 05 or the
closest project-conforming equivalent.

It must contain only validated presentation evidence such as:

- operation ID;
- operation kind;
- Journey-interpreted phase;
- stage/substage;
- progress revision;
- truthful completed/total units when available;
- bounded failure evidence;
- Journey-owned available actions.

It must not contain:

- providers/controllers/stores;
- process session in presentation;
- raw `recoveryDisposition`;
- database handles;
- filesystem capability;
- mutation authority;
- full raw snapshot history.

Applicable operation-backed Episodes must carry this projection.

When truthful numeric progress does not exist:

- projection progress is null;
- presentation renders indeterminate stage/substage state;
- do not infer 100%;
- do not use elapsed time;
- do not use graph-controller terminal state as a progress substitute.

---

# 8. Implement evidence acceptance/currentness

Implement the private binding/currentness rules from Prompt 05.

An operation emission is accepted only when the current Journey binding matches:

- Journey occurrence;
- operation ID;
- operation kind;
- accepted process session;
- legal status transition;
- legal stage/substage;
- non-regressing progress revision;
- valid progress bounds.

Equal revisions must not permit contradictory evidence.

Use bounded fingerprint/currentness evidence where the persisted v1 format
requires status ordering in addition to `progressRevision`.

Late evidence from operation A must not change operation/Journey B.

Environment reports remain coherent evidence, but they do not replace matching
operation completion/failure with maintenance noise.

---

# 9. Atomic presentation cutover — remove all three side doors

This is a critical implementation boundary.

The first buildable/reviewable state after the authority tranche must not expose
both the new Journey projection and any old semantic presentation side door.

Remove production onboarding presentation dependence on:

- `onboardingEnvironmentReportProvider`;
- `conversationGraphBuildControllerProvider`;
- `onboardingOperationSnapshotProvider`.

Use only:

- the current typed Journey state;
- `journey.evidence.report` where prerequisite details are needed;
- the Journey-owned operation projection for operation progress/failure/actions.

`OnboardingOverlay` must not independently reinterpret graph or snapshot state.

Update shell overlay visibility to Journey-owned state.

Remove shell-owned independent reconciliation initiation as designed.

End-state rule:

> **Journey state in, widgets out.**

---

# 10. Harden failure ordering

Implement the approved failure rule:

> Once the coordinator knows the current operation failed, publishing a valid
> Journey failure/retry state occurs before any fallible evidence/logging work.

Address every forensic finding:

- snapshot `runStage` must not mask the original error by failing while
  persisting failure;
- graph/import failure-store persistence must not precede Journey failure;
- logger/ref reads must not precede failure publication;
- durable-verification failure must publish Journey failure first;
- reimport admission/begin failures must reach a Journey failure even when no
  operation ID exists;
- automatic-recovery failure conversion must not depend on final invalidation or
  logging.

After Journey failure is published, attempt independently contained:

- snapshot failure persistence;
- graph/import failure persistence;
- logging;
- diagnostics;
- evidence refresh/invalidation.

Preserve the original error/stack as the primary diagnostic.

Do not swallow errors to make tests pass.

---

# 11. Implement action/occurrence binding

Add the approved immutable action context or equivalent.

Bind stale-sensitive actions to the current Journey occurrence and, where
applicable, operation ID:

- start import;
- retry;
- Continue Setup;
- reimport;
- terminal acknowledgement.

Revalidate after asynchronous admission/await boundaries before changing state.

Late callbacks from a prior occurrence must become a no-op or typed stale-action
rejection.

Do not create unnecessary tokens for purely synchronous controls without a real
stale-callback risk.

---

# 12. Implement restart/reconciliation cutover

Move restart/interruption interpretation to the stable Journey authority.

The snapshot controller may continue converting a prior-process `running`
snapshot to `interrupted`.

The coordinator then interprets report + snapshot evidence.

Required behavior:

- no snapshot/idle -> derive current Journey from coherent environment facts;
- interrupted exact resumable substage -> coordinator-owned interrupted Episode
  with explicit **Continue Setup**;
- interrupted + incompatible prerequisites -> show prerequisite Episode; do not
  auto-resume;
- non-resumable/inconsistent failure -> coordinator-owned failure Episode;
- unbound completed snapshot at startup -> historical evidence only; rerun
  durable readiness and derive current Journey; do not replay stale terminal UI;
- stale unrelated snapshot -> diagnostic evidence only.

Remove independent shell-owned reconciliation side effects if source/use proof
matches the design.

Do not auto-resume ordinary interrupted user import.

---

# 13. Remove obsolete authority machinery

After the cutover is working and source/use search proves safety, remove only
obsolete code made unnecessary by the correction.

Expected candidates from the design include:

- compatibility workflow override machinery that recreates Journey state from
  status;
- graph-status fallback `1.0`;
- direct graph/snapshot progress interpretation in presentation;
- embedded operation snapshot helpers in environment report;
- shell-owned reconciliation provider if no legitimate non-production consumer
  remains;
- automatic snapshot failure persistence inside `runStage`;
- unused operation `presenceState` vocabulary if still unreferenced;
- architecture/widget tests that explicitly require the old side doors.

Do not broaden into unrelated legacy cleanup.

Development diagnostic surfaces may remain if clearly nonauthoritative.

---

# 14. Make the new test suite authoritative

Replace tests that encode the violation.

Specifically remove expectations equivalent to:

- `buildingGraph` + raw graph `succeeded` -> **Browsing data ready** / 100%;
- raw graph failure selects onboarding failure copy;
- raw snapshot provider directly supplies onboarding progress;
- architecture requires snapshot provider import in overlay.

Add/complete the deterministic replay, hostile-noise, failure-independence,
operation-ID, restart, and stale-action tests described above.

Prove:

- same conditions + same user actions -> same Journey Episode sequence;
- irrelevant late evidence does not alter that sequence;
- operation A evidence cannot affect operation B;
- every operation failure has a valid Journey destination;
- active non-dismissible modal exists only for the matching bound active
  operation.

---

# 15. Generation, formatting, and focused validation

After implementation:

1. run normal Riverpod/Freezed generation;
2. format changed Dart files;
3. inspect generated changes;
4. run focused architecture tests;
5. run focused Journey/coordinator tests;
6. run operation snapshot/controller tests;
7. run reconciliation/restart tests;
8. run overlay/presentation tests;
9. run Environment Readiness/gate/shell tests affected by action-context changes;
10. run the exact stuck-state regression;
11. run deterministic replay and hostile-noise suites;
12. run failure-injection matrix.

All tests use disposable/in-memory fixtures.

Do not launch the real development app.

---

# 16. Project Conformance Audit before final validation

Run the MessageLens Project Conformance Audit Standard against the complete
correction delta from starting commit:

`622a4d25842f15817ec93f2dc5866627189a68ad..WORKTREE`

In addition to the existing standard, explicitly apply this proposed mandatory
stateful-workflow question:

> For every changed stateful workflow, enumerate every component capable of
> advancing, completing, failing, retrying, cancelling, dismissing, or changing
> user-visible workflow state. Is exactly one component authoritative, and are
> all durable or asynchronous evidence sources operation-identity-bound inputs
> to that authority rather than direct presentation inputs?

The audit must enumerate all remaining Onboarding semantic inputs.

Require:

`PROJECT CONFORMANCE: PASS`

with zero unresolved BLOCKER or SHOULD FIX findings.

If another production semantic side door remains, conformance FAILS.

Do not alter the Project Conformance Standard itself in this task.

---

# 17. Full validation

Only after focused validation and conformance PASS, run:

- complete architecture suite;
- `flutter analyze --no-pub`;
- complete repository Flutter suite;
- `git diff --check`;
- generated-file consistency;
- documentation/reference validation where current edited docs are referenced;
- shared-submodule status.

Run native tests only if native code changes unexpectedly.

Do not use production or real-development data during automated validation.

---

# 18. Do not update canonical/conformance documentation yet

Prompt 05 intentionally deferred final documentation proof until implementation
has been reviewed.

Do not yet edit:

- Project Conformance Audit Standard;
- generic Journey/Presence integration rules;
- canonical onboarding docs beyond the already committed authority correction;
- Feature 34 final implementation record.

Instead, report the exact documentation changes now justified by the proven
implementation. They will be handled after human review.

---

# 19. Leave implementation unstaged for review

Even if every test passes:

- do not stage production/test/generated changes;
- do not commit the implementation;
- do not push;
- do not merge;
- do not launch MessageLens Development.

Leave the complete correction unstaged for human architectural review.

Qualification remains paused.

---

# Mandatory stop-and-report gates

STOP AND REPORT if any of the Prompt 05 implementation stop gates occur,
including:

- stable listener ingestion still reconstructs the Journey owner during its
  command;
- another state owner is required;
- operation UUID cannot be bound before running Episode publication;
- any production presentation still requires raw report/graph/snapshot state to
  determine Onboarding meaning;
- wrong UUID/process session/revision/occurrence cannot be rejected;
- Continue Setup requires unsafe/implicit auto-resume;
- failure publication must wait for logging/persistence/invalidation;
- restart cannot distinguish stale evidence from valid resumable interruption;
- version-1 snapshot requires migration;
- archive authority/database schema/production data would need changes;
- a canonical contradiction appears;
- an intermediate reviewable state retains both old and new presentation
  authorities.

Do not solve through a stop gate.

---

# Required response record

Create:

`01-ONBOARDING/responses/06-IMPLEMENT-ONBOARDING-AUTHORITY-CORRECTION.md`

Document:

1. starting branch/HEAD;
2. failing test-first tripwires and their expected pre-fix results;
3. stable coordinator lifetime implementation;
4. operation-ID binding sequence;
5. Journey operation projection;
6. evidence acceptance/currentness;
7. removal of each of the three side doors;
8. failure-publication ordering;
9. action/occurrence binding;
10. restart/reconciliation implementation;
11. obsolete code/tests removed;
12. changed production/test/generated files;
13. focused test results;
14. deterministic replay results;
15. hostile-noise results;
16. failure-injection results;
17. architecture result;
18. analyzer result;
19. full-suite result;
20. `git diff --check`;
21. generation result;
22. Project Conformance verdict;
23. any OPTIONAL findings;
24. documentation changes now justified;
25. any stop gate;
26. complete Git status.

Conclude exactly:

`ONBOARDING AUTHORITY CORRECTION IMPLEMENTED AND VALIDATED: YES / NO`

If YES, also conclude:

`READY FOR HUMAN ARCHITECTURAL REVIEW BEFORE CHECKPOINT: YES`

Then STOP.
