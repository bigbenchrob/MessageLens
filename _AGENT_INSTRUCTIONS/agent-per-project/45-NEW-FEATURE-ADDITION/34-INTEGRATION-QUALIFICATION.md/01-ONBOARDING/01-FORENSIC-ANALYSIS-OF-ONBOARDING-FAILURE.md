# 01 — Forensic Analysis of the Onboarding Failure

## Purpose

This document records the architectural intent behind MessageLens onboarding, the failure observed during the first clean-slate qualification of integrated `main`, and the most likely way the implementation drifted away from the original deterministic design.

It is not a bug-fix recipe. Its purpose is to establish the architectural facts that must be understood before any correction is attempted.

The central question is:

> How did a workflow that was deliberately designed around one deterministic authority acquire a second source of state capable of overruling or contradicting it?

## 1. Original design intent

Onboarding was one of the first places where MessageLens explicitly recognized that a complex user workflow could become unstable if individual components were allowed to decide independently what should happen next.

A real installation can begin in many different conditions: Full Disk Access granted or not granted; databases present, absent, partial, stale, or needing rebuild; current Messages available or not; Contacts available or not; the user leaving MessageLens to change a macOS permission and later returning; a step succeeding, failing, requiring retry, or causing the Journey to branch.

A collection of independent widgets, providers, callbacks, or “smart steps” could easily create contradictory or non-deterministic behavior.

The design therefore adopted a single organizing question:

> **What is the next step?**

Everything else was subordinate to that question.

## 2. The Journey / Trip / Step model

The intended model was deliberately simple.

A Journey consists of an ordered set of Trips.

A Trip consists of an ordered batting order of Steps.

A Step does one bounded piece of work and returns an outcome.

The Step does **not** choose what happens next.

Within a Trip, the next Step is normally the next Step in that Trip's fixed order.

The final Step of a Trip may return nothing, a Boolean, a typed value, or another bounded result needed by the coordinator.

The Journey Coordinator then interprets that result and decides which Trip comes next. That next Trip begins at its first Step.

The design permits branches, loops, retries, leaving the application and returning, and condition-dependent Trip selection, but it does not permit individual Steps to own their own navigation.

## 3. The “sticks and balls” model

The design was exercised conceptually as a series of sticks and balls.

A Trip is a stick. Its Steps are balls arranged in a fixed order. At any point in the Journey, exactly one ball is the current ball.

Given the same initial conditions, the same continuing external conditions, the same user choices, and the same Step outcomes, the same sequence of balls should be highlighted.

Even when the Journey branches or loops, the transition remains deterministic.

This was the practical meaning of the architectural requirement:

> **Given the same evidence and the same user actions, onboarding must produce the same Journey.**

The model was intentionally designed so that the user could leave MessageLens to complete something such as Full Disk Access configuration and later return to the same logical place.

That was the “I've got you” property.

The user should never have to reconstruct for the application what had already happened or where the process had reached.

## 4. Why sole authority mattered

The Journey Coordinator was intended to be the sole production authority answering:

- What Trip are we in?
- What Step are we in?
- Did this Step succeed?
- Did it fail?
- Is it retryable?
- What happens next?
- Is onboarding complete?

Other components could produce facts. They could not decide Journey state.

Examples of legitimate evidence producers include FDA state, database readiness, import progress, import completion, Contacts availability, operation failure, recovery evidence, and persistent operation records.

Those facts were supposed to flow **into** the Journey Coordinator.

The Journey Coordinator would then decide what Journey state followed.

The intended direction was:

```text
external conditions / user actions / operation evidence
                         |
                         v
              OnboardingJourneyCoordinator
                         |
                         v
             authoritative Journey state
                         |
                         v
                    presentation
```

This is the core architecture.

## 5. What failed in practice

During the first clean-slate qualification of integrated `main`, the user pressed **Import My Messages**.

The result was not an ordinary import failure screen.

Instead the UI became trapped in a contradictory state:

- onboarding remained in a `buildingGraph`-type Journey phase;
- a modal remained non-dismissible;
- the progress bar appeared complete;
- presentation said **Browsing data ready**;
- no progress advanced;
- no failure state appeared;
- no retry action appeared;
- waiting did not help.

Runtime diagnosis found that the import had failed immediately with a Riverpod lifecycle assertion.

The failure path then encountered the same stale-provider/lifecycle problem before it could publish the expected error/retry state.

The result was a state that should have been impossible under the intended Journey model.

One part of the system still said:

> We are building the graph.

Another part effectively said:

> The operation has completed successfully; browsing data is ready.

Presentation rendered both realities at once.

## 6. The architectural violation

The defect is more serious than a bad progress bar or a stale widget.

The Journey Coordinator no longer had exclusive control over user-visible onboarding state.

A second stateful mechanism had acquired enough semantic authority to influence presentation independently.

Current terminology identified:

- `OnboardingJourneyCoordinator`
- `OnboardingOperationSnapshot`

There is nothing inherently wrong with having both.

The problem is **authority overlap**.

The Journey Coordinator should answer:

> What is the onboarding Journey doing now?

An operation snapshot may legitimately answer:

> What durable facts do we know about operation X?

Those are different questions.

The failure occurs when the second answer is allowed to become an independent answer to the first.

## 7. The dangerous architecture

The system appears to have drifted toward something structurally similar to:

```text
              OnboardingJourneyCoordinator
                         |
                         +---------------------> presentation
                         |
operation ---> OnboardingOperationSnapshot ----+
```

Presentation now has two sources capable of influencing onboarding meaning.

This creates a state-composition problem.

The Journey may be current. The operation evidence may be stale. Both may be individually valid in isolation.

But their combination can describe a state that never existed in the Journey.

That is what the clean-slate qualification exposed.

## 8. Why this defeats determinism

The original sticks-and-balls model depends on one authoritative highlighted ball.

If presentation can independently observe another stateful object and use it to decide success, completion, progress state, retryability, or modal state, then there is no longer one highlighted ball.

There are effectively two overlays.

One can say:

> current Step = building graph

while another says:

> operation complete

The rendered UI becomes the accidental combination of two asynchronous authorities.

At that point the Journey Coordinator may still be logically deterministic internally, but the product is not deterministic because presentation can be overruled from the side.

This is equivalent to reintroducing the earlier rejected idea that individual Steps or subsystems can partly own their own Journey.

## 9. What probably happened over time

The current violation most likely did not come from one explicit decision to abandon the Journey architecture.

It probably accumulated through a series of locally reasonable choices.

### First: a durable operation record was needed

Long-running onboarding work such as import and graph construction has legitimate operational needs: progress, interruption recovery, restart reconstruction, diagnostics, durable failure evidence, and possible resumability.

A durable operation snapshot was therefore reasonable.

At this stage there is no architecture violation.

### Then: progress needed to be displayed

A UI component needed to show operation progress.

The snapshot already contained progress.

Watching it directly was convenient.

Again, this may have looked harmless because the Journey Coordinator still appeared to own routing.

### Then: completion state was also available there

The operation snapshot could say that work had succeeded.

That made it convenient to display 100% progress, completed state, and “Browsing data ready.”

The snapshot now contained semantics that overlapped with Journey semantics.

### Then: provider reconstruction/lifecycle behavior mattered

Riverpod providers can dispose, reconstruct, invalidate, and replay values.

A durable or cached operation snapshot became attractive as a source from which presentation could reconstruct itself.

The more presentation depended on it directly, the more it became a second state machine.

### Then: failure handling also depended on the same mechanism

When the real operation failed, the failure path attempted to publish state through infrastructure that was already stale or invalid.

The Journey therefore could not cleanly transition presentation to failure/retry.

Meanwhile the old operation-success/progress evidence remained visible.

The system had reached the exact split-brain condition the original Journey design was intended to prevent.

## 10. Why each local decision could look reasonable

Architectural rot usually does not enter through obviously bad code.

Each step can be defended locally:

- “The snapshot already contains progress.”
- “The widget only needs to display it.”
- “The Journey still owns navigation.”
- “This provider already knows whether the operation completed.”
- “This makes restart reconstruction easier.”
- “This avoids duplicating state.”
- “This is only presentation.”

The violation becomes visible only when the system is considered as a whole.

The key mistake is assuming that **navigation authority** is narrower than **state authority**.

If a second provider can tell the UI that onboarding is complete, failed, ready, retryable, blocked, or still running, then it is participating in Journey authority even if it never explicitly selects a Trip.

## 11. Why the failure handler matters

A particularly revealing detail is that the failure handler itself could not publish the expected error state.

A healthy architecture should allow this sequence:

```text
operation throws
      |
      v
Journey receives failure evidence
      |
      v
Journey marks current Step failed/retryable
      |
      v
presentation renders Retry
```

The failure of the operation subsystem must not prevent the Journey Coordinator from expressing a valid Journey state.

If a broken or disposed evidence producer can strand the Journey in an indeterminate state, then the Journey does not truly own the process.

This exposes a second architectural requirement:

> The loss, disposal, failure, or reconstruction of an evidence producer must never prevent the Journey authority from publishing a valid Journey state.

## 12. Why existing tests did not protect us

The repository had extensive behavioral tests.

That did not prevent this defect.

This is because local tests can validate components while missing authority overlap.

A test may correctly prove operation snapshot persistence, progress publication, Journey transitions, provider reconstruction, widget rendering, and restart behavior.

All of those can pass independently.

The architectural violation exists in the relationship between them.

Worse, a test can accidentally preserve the violation.

If a widget test explicitly expects presentation to read operation success directly from the operation snapshot, that test becomes an enforcement mechanism for the wrong architecture.

Therefore test coverage alone is insufficient.

Authority itself must be audited.

## 13. The deeper failure

The immediate bug is a Riverpod lifecycle assertion.

The deeper failure is that the architecture allowed a provider lifecycle defect to create contradictory Journey meaning.

The product should have had only one answer to:

> Where are we?

Instead it had multiple stateful participants capable of answering that question.

That is the actual failure.

## 14. Forensic conclusion

The onboarding system was originally designed around a strong deterministic principle:

> One Journey authority decides what happens next.

Over time, operational persistence/progress machinery appears to have gained semantic influence over presentation.

The Journey Coordinator remained present, but no longer had exclusive ownership of user-visible onboarding state.

The first clean-slate qualification immediately exposed the consequence:

- Journey state said one thing;
- stale operation state said another;
- presentation combined both;
- failure handling could not restore consistency;
- the user became trapped.

This should be treated as an architectural regression, not merely a one-line lifecycle bug.

The next task should therefore begin with a full **Onboarding Authority Forensic Audit** before implementing a narrow repair.

The goal is not only to fix the observed assertion.

The goal is to identify every side channel by which something other than the Journey Coordinator can currently influence onboarding state, and remove the class of violation.
