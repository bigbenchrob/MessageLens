# MessageLens Clean-Slate Integrated Qualification
## 09 — Onboarding Authority Forensic Audit

This task precedes any repair of the onboarding import stuck-state failure.

The purpose is not to fix the observed Riverpod assertion yet.

The purpose is to determine whether the current onboarding implementation still
conforms to the deterministic Journey / Trip / Step architecture, identify every
place where authority has drifted, and establish the exact correction boundary
before implementation resumes.

Read these two documents in full before inspecting implementation:

- `01-FORENSIC-ANALYSIS-OF-ONBOARDING-FAILURE.md`
- `02-NECESSARY-CORRECTIONS-TO-ONBOARDING.md`

They live at the top level of:

`_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/34-INTEGRATION-QUALIFICATION.md/01-ONBOARDING/`

Treat them as the governing hypothesis and required architectural constraints
for this audit.

Also read the existing canonical onboarding/Journey architecture and project
rules that originally define Journey, Trip, Step, deterministic routing,
operation persistence, recovery, Riverpod ownership, and presentation
boundaries.

This is a **read-only forensic audit**.

Do NOT change production code.
Do NOT change tests.
Do NOT regenerate code.
Do NOT create a bug-fix implementation branch merely to perform the audit.
Do NOT launch MessageLens Development.
Do NOT repeat Start Fresh.
Do NOT retry import.
Do NOT touch production MessageLens.
Do NOT access or mutate real databases or attachment archives.

---

# 1. Repository baseline

Re-establish the current repository state.

Expected integrated baseline:

`main = origin/main = fe14793bbee8622b08829c4973a1e6ae218e8bb2`

However, there has been documentation organization under:

- `00-PREPARATION/`
- `01-ONBOARDING/`

and the canonical Feature 34 records must remain at their tracked root
locations.

Before continuing, verify:

- current branch and HEAD;
- local/remote `main`;
- tracked worktree;
- index;
- shared-instructions submodule;
- any current onboarding bug-fix branch if one already exists;
- current status of qualification documents.

If tracked documentation moves remain unresolved, STOP AND REPORT rather than
mixing them into the forensic audit.

Untracked qualification prompts/responses are allowed and must remain untouched.

---

# 2. Reconstruct the intended onboarding architecture

From the canonical project/onboarding documentation, reconstruct the intended
model before examining the violation.

Document explicitly:

- the role of `OnboardingJourneyCoordinator`;
- the role of a Journey;
- the role of a Trip;
- the role of a Step;
- how Step order is defined;
- what a Step is allowed to return;
- who interprets the last Step's result;
- who chooses the next Trip;
- who chooses the next Step;
- how retry/branch/loop behavior is intended to work;
- how leaving the app for FDA and returning is intended to work;
- how durable/restart state is intended to support rather than replace Journey
  authority;
- what “What is the next step?” means in the canonical architecture.

Preserve the repository's actual terminology.

Identify any discrepancy between the user's reconstructed “sticks and balls”
model and the written canonical architecture.

Do not silently reconcile discrepancies. Report them.

---

# 3. Reconstruct the observed failure exactly

Using the development log and existing evidence from the failed qualification,
reconstruct the precise sequence from:

- user presses **Import My Messages**;
- Journey state at action time;
- operation creation/start;
- first provider/notifier/ref lifecycle action;
- exact assertion/exception;
- attempted error handling;
- second lifecycle/stale-provider failure if present;
- final Journey state;
- final operation snapshot/progress state;
- final presentation state.

Record exact symbols, providers, notifiers, and call sites.

Explain precisely why the UI could simultaneously show:

- a `buildingGraph`-type Journey state;
- 100% progress;
- **Browsing data ready**;
- no retry/error action;
- non-dismissible modal.

Distinguish verified facts from inference.

---

# 4. Build the complete onboarding authority inventory

Enumerate every production component currently capable of influencing any of
the following:

- current Journey;
- current Trip;
- current Step;
- advancing a Step;
- completing a Step;
- choosing a Trip;
- retrying a Step;
- publishing failure;
- publishing success;
- publishing “ready”;
- import completion;
- graph-build completion;
- modal visibility;
- modal dismissibility;
- progress bar value;
- progress copy/label;
- retry controls;
- continuation controls;
- onboarding completion;
- restart/provider reconstruction;
- FDA return/resume behavior.

Do not limit the inventory to components whose names contain “onboarding.”

Inspect:

- Journey coordinator(s);
- Journey state providers;
- operation snapshot providers;
- import providers;
- graph-build providers;
- readiness providers;
- recovery providers;
- lifecycle callbacks/listeners;
- UI aggregators/read models;
- widgets that watch multiple providers;
- persistence stores;
- restart reconstruction code;
- typed action/intent dispatch;
- any legacy compatibility provider still connected to production.

For each component record:

| Component | Layer | State owned | Durable/ephemeral | Writers | Readers | Can influence Journey meaning? | Can outlive operation? | Operation-ID/generation bound? |

---

# 5. Identify every production write path into Journey state

Starting from the authoritative Journey state object/provider/notifier, find
every production call site capable of mutating it.

For each write path establish:

- caller;
- trigger;
- required preconditions;
- whether it verifies current Trip/Step;
- whether it verifies current operation identity;
- whether it may execute after an asynchronous gap;
- whether it can arrive late;
- whether provider disposal/reconstruction changes behavior;
- whether it can conflict with another write path.

The audit must answer:

> Is there exactly one logical owner of Journey transitions, or are multiple
> producers effectively mutating Journey state?

Do not confuse “one Riverpod notifier object” with “one semantic authority.”

---

# 6. Identify every presentation side door

Starting from onboarding presentation, enumerate every provider/read model it
observes.

For each observed state source answer:

- Is it Journey state?
- Is it operation evidence?
- Is it readiness evidence?
- Is it progress evidence?
- Is it failure evidence?
- Does the widget/read model combine it with Journey state?
- Can it independently cause different copy, progress, controls, or modal
  behavior?
- Could stale evidence remain after Journey transition?
- Could the source reconstruct with an old value?

Produce a specific list of every route by which presentation can acquire
semantic onboarding meaning without going through the Journey Coordinator.

This is one of the most important deliverables.

---

# 7. Audit `OnboardingOperationSnapshot`

Inspect the actual type and all production uses.

Determine:

- why it was originally introduced;
- exact fields;
- persistence scope;
- lifecycle;
- writers;
- readers;
- reconstruction semantics;
- operation identity semantics;
- whether it carries a generation/ID;
- whether its success/failure/progress vocabulary overlaps Journey vocabulary;
- whether widgets consume it directly;
- whether Journey consumes it;
- whether it can survive beyond the operation it describes;
- whether a previous snapshot can be mistaken for current evidence;
- whether clearing/replacing it is atomic with Journey transitions.

Classify every field as one of:

A. legitimate durable operation evidence;

B. evidence that should be projected through the Journey before presentation;

C. Journey-semantic state that should not live in the snapshot;

D. obsolete/duplicated state;

E. unclear — requires design decision.

Do not modify the type during this audit.

---

# 8. Audit operation identity and stale-result protection

For every asynchronous onboarding operation, determine whether there is a unique
operation identity or generation.

Trace that identity through:

- invocation;
- service/controller execution;
- progress;
- durable snapshot;
- completion;
- failure;
- retry;
- cancellation;
- Journey transition;
- presentation.

Determine whether late results from operation A can affect operation B.

Specifically test by source inspection whether the architecture currently
prevents:

- stale success after retry;
- stale progress after failure;
- stale failure after a new operation starts;
- provider reconstruction replaying prior completion;
- delayed callback after Journey moved to another Step;
- operation evidence from a previous app session becoming current Journey state.

If no mechanical identity binding exists, report that explicitly.

---

# 9. Audit failure ownership

For every running/onboarding Step that can fail, trace:

- where failure is caught;
- where operation failure is persisted;
- where Journey failure/retry state is published;
- what happens if the operation provider/ref has disposed;
- what happens if persistence fails;
- what happens if the Journey provider reconstructs;
- what presentation reads after failure.

The required architectural property is:

> Failure of an evidence producer cannot prevent the Journey from reaching a
> valid Journey failure/retry state.

Identify every current path that violates or weakens this property.

---

# 10. Audit deterministic Journey behavior

Locate existing Journey/Trip/Step tests.

Determine whether they truly prove deterministic sequencing or merely test
individual transitions.

Look specifically for tests equivalent to the original “sticks and balls”
exercise.

Establish whether the suite currently proves:

- exact Trip/Step sequence for a fixed condition set;
- branching;
- looping;
- retry;
- FDA leave-and-return;
- operation failure;
- restart reconstruction;
- stale async result rejection.

Identify missing deterministic replay coverage.

Also identify tests that encode or protect secondary authority.

A passing test that requires direct snapshot-to-widget semantics is an
architecture defect, not supporting evidence.

---

# 11. Compare intended and actual state-flow graphs

Produce two explicit diagrams.

## Required architecture

At minimum:

```text
Evidence Producers
        |
        v
OnboardingJourneyCoordinator
        |
        v
OnboardingJourneyState
        |
        v
Presentation
```

with operation execution/persistence shown as evidence-producing specialists.

## Actual architecture

Draw the real current production graph, including all side paths.

Show:

- direct widget observations;
- operation snapshot routes;
- readiness/progress routes;
- reconstruction routes;
- callbacks/listeners;
- any paths that can mutate Journey state outside the intended coordinator
  decision boundary.

Mark every authority violation.

---

# 12. Establish historical drift

Use Git history and implementation records to determine, as far as repository
evidence supports, **when and why** the architecture diverged.

Do not speculate beyond evidence.

For each material divergence identify where possible:

- introducing commit;
- original purpose;
- local problem being solved;
- architectural shortcut introduced;
- tests added at the same time;
- later changes that increased the shortcut's authority;
- whether canonical onboarding rules already prohibited it at the time;
- whether documentation was updated to legitimize the drift;
- whether no rule existed yet to catch it.

The forensic report should attempt to answer:

> What probably happened first, what happened next, and at what point did a
> legitimate evidence mechanism become a competing state authority?

Clearly label:

- VERIFIED HISTORY
- STRONGLY SUPPORTED INFERENCE
- UNKNOWN

---

# 13. Inspect architecture tripwires and allowlists

Audit existing onboarding architecture tests.

Determine whether they protect:

- sole Journey authority;
- no direct presentation snapshot authority;
- dependency direction;
- operation identity;
- deterministic sequencing.

Identify tests that:

- miss the violation;
- are too narrow;
- explicitly encode the violation;
- grandfather legacy state paths;
- use allowlists broad enough to hide authority drift.

Do not modify tests yet.

---

# 14. Project-wide comparison

Without performing a full repository conformance audit, search for analogous
stateful workflow patterns elsewhere in MessageLens.

The goal is not to fix other systems in this task.

The goal is to determine whether onboarding's authority drift is isolated or
reflects a reusable architectural blind spot.

Look for systems with:

- a coordinator plus a separate durable snapshot;
- presentation watching both;
- multiple providers able to publish terminal state;
- asynchronous operations without identity binding.

Report only concrete examples.

Do not broaden into unrelated refactoring.

---

# 15. Required forensic report

Create a new top-level onboarding document:

`03-ONBOARDING-AUTHORITY-FORENSIC-AUDIT.md`

under:

`_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/34-INTEGRATION-QUALIFICATION.md/01-ONBOARDING/`

This is a documentation-only audit record.

It must include:

1. executive conclusion;
2. intended Journey architecture;
3. exact failure sequence;
4. complete authority inventory;
5. Journey write-path inventory;
6. presentation side-door inventory;
7. `OnboardingOperationSnapshot` field/use classification;
8. operation-identity analysis;
9. failure-ownership analysis;
10. deterministic-test analysis;
11. required state-flow graph;
12. actual state-flow graph;
13. authority violations;
14. historical drift chronology;
15. tripwire/test findings;
16. project-wide analogous-pattern findings;
17. exact correction boundary;
18. open questions requiring human decision;
19. recommended next implementation phases.

Do not implement corrections in this task.

---

# 16. Correction-plan requirements

At the end of the forensic report, propose a correction plan consistent with:

`02-NECESSARY-CORRECTIONS-TO-ONBOARDING.md`

The plan must remove the **class of authority violation**, not merely the
observed Riverpod assertion.

It should state explicitly:

- which component remains sole Journey authority;
- which components become evidence-only;
- how operation identity is enforced;
- how presentation becomes Journey-only;
- how failure always reaches a Journey destination;
- which obsolete/duplicate states can be deleted;
- which tests must be replaced;
- which architecture tripwires must be added;
- whether migration of persisted snapshot data is needed;
- whether the change can be staged incrementally without creating two temporary
  authorities.

Do not write code.

---

# 17. Project Conformance Standard update recommendation

Do not edit the Project Conformance Audit Standard yet.

Instead, include exact proposed wording for a new mandatory audit question
covering stateful workflow authority.

The intended substance is:

> For every changed stateful workflow, enumerate every component capable of
> advancing, completing, failing, retrying, dismissing, or changing
> user-visible workflow state. Is exactly one component authoritative?

Also recommend where this rule should eventually live in canonical project
documentation once the onboarding correction is complete.

---

# Stop gates

STOP AND REPORT if:

- canonical Journey documentation materially contradicts
  `01-FORENSIC-ANALYSIS-OF-ONBOARDING-FAILURE.md`;
- more than one coordinator is intentionally documented as Journey authority;
- the actual failure evidence contradicts the current diagnosis;
- a schema migration would clearly be required merely to restore authority;
- production data access would be required;
- the audit cannot distinguish current production paths from dead historical
  code.

Do not resolve these ambiguities silently.

---

# Final response

Report concisely:

1. repository state;
2. canonical architecture agreement/disagreement;
3. exact failure root cause;
4. number of components with Journey-semantic influence;
5. number of presentation side doors;
6. whether operation identity mechanically prevents stale evidence;
7. whether failure handling is Journey-independent;
8. historical origin of drift;
9. whether existing tests encode the violation;
10. analogous state-authority patterns elsewhere;
11. forensic report path;
12. correction-plan summary;
13. open human decisions;
14. any stop gate encountered.

Conclude exactly:

`ONBOARDING AUTHORITY FORENSIC AUDIT COMPLETE: YES / NO`

If YES, also conclude:

`SAFE TO DESIGN ONBOARDING AUTHORITY CORRECTION: YES / NO`

Then STOP.
