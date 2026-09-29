# Onboarding authority-model reassessment

The existing architecture can support the requested single-authority model without parallel authorities, but the current unstaged implementation does not yet satisfy the tightened invariant.

No further code changes were made during this reassessment. The existing five-file unstaged work remains preserved.

## Current architectural gap

The architecture already has useful foundations:

- `OnboardingJourneyCoordinator` is documented as the sole Journey authority.
- Every non-idle operation record has a unique UUID `OnboardingOperationId`.
- The operation controller rejects mutations carrying a stale operation ID.
- `onboardingGateProvider` is only a read-only compatibility projection of the coordinator.

However, authority currently leaks in several places:

- The overlay reads `onboardingOperationSnapshotProvider` directly.
- At baseline, it also interpreted `conversationGraphBuildControllerProvider` directly.
- The overlay separately watches the environment report.
- Journey states do not carry coordinator-approved operation progress.
- The coordinator does not bind its active Journey to a specific operation ID.
- The first-run executor creates its operation ID internally, so the coordinator cannot establish the binding before progress begins.
- A snapshot marked `completed` or `failed` can currently influence presentation without an explicit identity match against the active Journey.

Therefore the intended flow is not yet fully enforced.

## Revised authority model

The implementation should enforce:

```text
operation execution
        ↓
durable operation evidence
        ↓
OnboardingJourneyCoordinator
        ↓
typed OnboardingJourneyState
        ↓
presentation
```

The durable record may describe an operation as running, interrupted, failed, or completed, but those terms describe operation evidence only. They do not authorize a user-visible Journey outcome.

Only the coordinator may publish:

- the active user-visible phase;
- operation-failure presentation;
- Ready to Import;
- Ready to Start;
- reimport completion;
- normal application state.

## Revised implementation plan

1. Keep the Riverpod lifecycle correction: the coordinator will listen to changing environment and operation evidence without making its own provider lifecycle depend on those reconstructing providers.

2. Add coordinator-owned, immutable operation presentation evidence to active `OnboardingJourneyState` variants. It will contain only the coordinator-accepted operation ID, stage, substage, progress, revision, and relevant failure information.

3. Bind each active Journey operation to its unique `OnboardingOperationId`.

   - Refactor the first-run executor so the coordinator learns and binds the ID immediately after `begin`.
   - Reimport and automatic recovery will use the same binding.
   - Evidence is accepted only when its operation ID matches the coordinator’s active ID.
   - For a matching ID, only monotonically newer `progressRevision` values are accepted.
   - Starting a new operation invalidates all evidence from the previous ID.
   - Persisted interrupted evidence may be adopted only through coordinator-controlled startup reconciliation.

4. Make the overlay consume only `OnboardingJourneyCoordinator`.

   - Remove direct watches of the operation snapshot, graph-build controller, environment-report provider, and compatibility gate from the overlay.
   - Derive the compatibility status and prerequisite report from the published Journey state.
   - Pass coordinator-approved progress into a non-consumer progress widget.
   - Keep terminal success exclusively in coordinator-published terminal Journey variants.

5. Preserve strict terminal ordering.

   - Operation failure evidence is persisted, then the coordinator publishes `OnboardingOperationFailed` before diagnostics or other provider reads.
   - A completed operation record alone cannot produce `OnboardingReadyToStart`.
   - The coordinator publishes success only after durable readiness verification succeeds.
   - Stale success, failure, or progress from another operation is ignored.

6. Tighten the public seam and tests.

   - Remove the operation-evidence provider from any presentation-facing public seam where feasible.
   - Add an architecture test prohibiting onboarding presentation code from importing the operation-evidence or graph-execution providers.
   - Test stale previous-operation evidence, out-of-order revisions, failure publication, retry, and the rule that completed operation evidence cannot independently authorize Journey success.
   - Retain the exact Riverpod invalidation regression reproduction.

The existing `OnboardingOperationSnapshot` type can remain as the persisted data structure to avoid unnecessary migration churn, but it will be described consistently as **durable operation evidence**, never as an authority.

## Gate result

**EXISTING ARCHITECTURE CAN SUPPORT THE SINGLE-AUTHORITY MODEL: YES**

**CURRENT UNSTAGED IMPLEMENTATION SATISFIES IT: NO — it requires the coordinator-bound evidence changes above before implementation can be considered complete.**
