# 02 — Necessary Corrections to the Onboarding Authority Model

## Purpose

This document defines the architectural corrections required in response to the onboarding failure discovered during clean-slate qualification.

These rules are not suggestions.

They are constraints intended to restore the original deterministic Journey architecture and prevent stateful subsystems from gradually acquiring overlapping authority.

The governing principle is:

> **Only the Onboarding Journey may publish user-visible onboarding state. Everything else publishes evidence to the Journey.**

## 1. One authority for Journey state

`OnboardingJourneyCoordinator` must be the sole production authority for:

- current Journey;
- current Trip;
- current Step;
- Step running/waiting state;
- Step success;
- Step failure;
- retryability;
- cancellation/interruption state;
- Journey completion;
- selection of the next Trip;
- selection of the next Step.

No other provider, service, snapshot, widget, lifecycle callback, or persisted record may independently answer those questions.

## 2. Operation snapshots are evidence, not Journey authority

`OnboardingOperationSnapshot` may remain durable and authoritative about operation facts.

Examples of legitimate snapshot data include:

- operation ID;
- operation generation;
- operation phase;
- counts;
- bytes;
- timestamps;
- progress;
- durable recovery evidence;
- interruption evidence;
- operation-level failure details;
- operation-level completion evidence.

It must not independently authorize or publish:

- current Journey phase;
- current Trip;
- current Step;
- onboarding success;
- onboarding failure;
- whether Retry should appear;
- whether onboarding is complete;
- what screen/panel/modal should be shown;
- what happens next.

Use terminology such as:

> durable operation evidence

rather than:

> operation authority

when discussing its relationship to onboarding.

## 3. Required one-way state flow

The permitted direction is:

```text
operation execution
       |
       v
durable operation evidence
       |
       v
OnboardingJourneyCoordinator
       |
       v
authoritative OnboardingJourneyState
       |
       v
presentation
```

The forbidden structure is:

```text
OnboardingJourneyCoordinator ------> presentation
                                      ^
                                      |
OnboardingOperationSnapshot ---------+
```

Presentation must not independently reconcile multiple competing semantic authorities.

## 4. Presentation consumes Journey state

Onboarding presentation should obtain user-visible onboarding meaning from the Journey projection only.

As a default architectural rule:

> Onboarding widgets must not directly observe `OnboardingOperationSnapshot` in order to decide Journey state.

The same principle applies to other stateful evidence producers, including readiness providers, FDA providers, import providers, recovery providers, database state providers, lifecycle providers, and maintenance providers.

These may produce evidence.

The Journey Coordinator interprets that evidence.

The widget renders the Journey's interpretation.

## 5. Progress must be bound to the Journey-owned operation

Progress can remain detailed and live.

But it must be semantically bound to the operation that the current Journey Step owns.

A Journey state may contain or expose a read-only projection such as current operation ID, current operation phase, current progress, current progress label, and current recoverable failure evidence.

The Journey Coordinator must validate that the evidence belongs to its current operation.

## 6. Every asynchronous operation requires identity

Every long-running onboarding operation must carry a unique operation identity or generation.

Evidence is accepted only when it matches the operation currently owned by the Journey.

Conceptually:

```text
Journey current operation = ABC
snapshot operation = ABC
=> evidence may be applied
```

but:

```text
Journey current operation = ABC
snapshot operation = XYZ
=> stale/irrelevant evidence
```

This prevents stale success, stale failure, stale progress, previous retry results, late asynchronous completion, provider reconstruction replay, lifecycle callbacks from an older operation, and state from a prior onboarding attempt.

Operation identity matching must be enforced by code, not developer convention.

## 7. Lower layers must use operation-scoped vocabulary

Subsystem states must describe their own scope.

Prefer names such as:

- `OperationRunning`
- `OperationSucceeded`
- `OperationFailed`
- `ImportOperationProgress`
- `GraphBuildOperationCompleted`

Avoid lower-layer names that imply Journey authority, such as:

- `OnboardingSucceeded`
- `Ready`
- `ImportComplete` when interpreted as Journey completion;
- `BrowsingReady` when that statement has not been accepted by the Journey.

The Journey translates operation outcomes into Journey semantics.

## 8. Failure must always have a Journey destination

Every running Step must define deterministic handling for:

- success;
- failure;
- cancellation;
- interruption;
- provider reconstruction;
- application restart where applicable.

A failing evidence producer must never prevent the Journey Coordinator from publishing a valid Journey state.

The minimum required property is:

```text
operation failure
       |
       v
Journey receives failure evidence or catches failure
       |
       v
Journey enters failed/retryable Step state
       |
       v
presentation exposes an actionable path
```

Failure handling must not depend on the continued validity of the failed producer's presentation provider.

## 9. A non-dismissible modal is allowed only for active work

A non-dismissible onboarding modal is acceptable only while the Journey says a real operation is actively running.

When the operation fails, is cancelled, is interrupted, or becomes retryable:

- the Journey state must change;
- the modal presentation must change;
- an actionable recovery/retry path must be reachable.

A modal must never remain permanently blocking because a secondary provider failed to update.

## 10. Stale progress must never override Journey state

The UI must not show 100% progress, “ready” copy, completion state, or success imagery unless the current Journey state says the current Step has reached that state.

Progress from a prior operation must not be combinable with a current running/failure state.

If Journey state is failed, cancelled, retryable, interrupted, or waiting, stale operation success must be ignored.

## 11. Deterministic replay must be testable

The original sticks-and-balls concept should become an automated test contract.

Given the same initial conditions, external evidence, operation outcomes, and user actions, the Journey must produce the same sequence of Trips, Steps, and user-visible Journey states.

A representative replay may include:

```text
initial conditions
-> FDA required
-> user leaves
-> FDA granted
-> user returns
-> Messages available
-> import starts
-> import fails
-> retry
-> import succeeds
-> next Trip
```

The exact Journey sequence should be asserted.

## 12. Hostile asynchronous noise must not change the Journey

Replay tests should inject irrelevant or stale asynchronous events, such as:

- old operation reports success late;
- old operation reports 100% progress;
- provider reconstructs;
- duplicate FDA signal;
- maintenance signal;
- delayed callback from a previous retry;
- stale snapshot publication.

The Journey sequence must remain identical.

This directly enforces:

> Same conditions and same user decisions produce the same Journey.

## 13. Add an explicit authority map

Every stateful workflow should maintain an authority map.

For onboarding:

| Concern | Sole authority |
|---|---|
| Current Journey | `OnboardingJourneyCoordinator` |
| Current Trip | `OnboardingJourneyCoordinator` |
| Current Step | `OnboardingJourneyCoordinator` |
| Next Trip/Step | `OnboardingJourneyCoordinator` |
| Step success/failure/retryability | `OnboardingJourneyCoordinator` |
| Durable operation facts | operation snapshot/evidence store |
| Operation execution | operation service/controller |
| User-visible onboarding projection | Journey state |
| User intent | typed Journey input/action |

Every new provider must fit into one row.

If a proposed component appears to share a row with an existing authority, that is an architecture finding requiring review.

## 14. Add a no-side-door architecture rule

The repository should explicitly prohibit production onboarding presentation from bypassing the Journey authority.

Architecture tripwires should detect direct presentation dependency on components that can otherwise create a second Journey state path.

At minimum inspect/prohibit direct semantic control from:

- operation snapshots;
- import completion providers;
- graph-build completion providers;
- readiness providers;
- FDA providers;
- lifecycle/recovery providers.

Exceptions must be narrow, explicit, and justified as evidence-only presentation if any are truly necessary.

The default must be:

> Journey state in, widgets out.

## 15. Audit authority, not just dependency direction

Layering tests are not sufficient.

A system can have technically correct imports while still containing two independent state authorities.

The Project Conformance Audit should therefore add a mandatory stateful-workflow question:

> For every changed stateful workflow, enumerate every component capable of advancing, completing, failing, retrying, dismissing, or changing user-visible workflow state. Is exactly one component authoritative?

This should be answered explicitly for onboarding and later for other stateful workflows.

## 16. Tests must not encode violations

Architecture and widget tests must themselves be reviewed for conformance.

A test is not evidence that architecture is correct merely because it passes.

If a test requires a widget to consume a secondary authority directly, the test may be preserving the defect.

Conformance review must ask:

> Is this test protecting the intended architecture, or protecting accidental implementation?

Tests that enshrine authority overlap must be corrected.

## 17. Do not solve this by creating a god object

Restoring one Journey authority does not mean putting all work into one class.

The coordinator should not execute SQL directly, import Messages itself, build the graph itself, manage filesystem operations, own FDA platform APIs, perform Contacts import directly, or become a global service locator.

Specialists remain specialists.

The rule is:

> Many components may perform work. Only one component decides what onboarding means and what happens next.

## 18. Required forensic audit before implementation

Before fixing the observed onboarding bug, perform a dedicated **Onboarding Authority Forensic Audit**.

Enumerate every production component capable of:

- selecting/advancing a Trip;
- selecting/advancing a Step;
- publishing onboarding success;
- publishing onboarding failure;
- publishing import completion;
- controlling modal state;
- controlling progress text/bar;
- causing Retry to appear;
- reconstructing Journey state after restart/provider reconstruction;
- dismissing or replacing onboarding presentation.

For each component identify:

- what state it owns;
- whether that state is durable or ephemeral;
- who consumes it;
- whether presentation consumes it directly;
- whether it can contradict Journey state;
- whether it can outlive its operation;
- whether it is operation-ID/generation bound;
- whether it can influence “what happens next.”

Then draw the actual current state-flow graph.

Compare it with the required graph:

```text
evidence producers
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

Do not begin implementation until the divergence is documented.

## 19. Required correction objective

The correction must remove the **class of violation**, not merely the exact lifecycle assertion observed during qualification.

Success means:

- one Journey authority;
- one current operation identity;
- operation evidence cannot overrule Journey state;
- stale evidence cannot become current;
- failure can always become a valid Journey failure/retry state;
- presentation does not synthesize onboarding meaning from multiple authorities;
- deterministic replay is preserved;
- architecture tests prevent reintroduction.

## 20. Governing principle

The onboarding architecture exists specifically because onboarding is complicated.

Its rules are not optional conventions.

They are what prevents complexity from becoming non-determinism.

The required principle is:

> **Evidence may be distributed. Authority may not be.**

And the operational test remains:

> **Given the same conditions and the same user actions, what is the next Step?**

There must be exactly one component allowed to answer that question.
