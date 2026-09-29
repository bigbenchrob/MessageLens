# MessageLens Feature 34 / Feature 35
## 17 — Design the Minimal Onboarding Tenure Correction

Integrated Feature 35 is now present on the Onboarding branch.

Current Onboarding branch state:

- branch:
  `fix/onboarding-import-stuck-state`
- HEAD:
  `276fa1b820b07bf14f41fe216192456b5415e290`
- first parent:
  `622a4d25842f15817ec93f2dc5866627189a68ad`
- second parent:
  integrated `main`
  `b67bfafc3ad4f4f0c15792f0245bfecf5e45f43f`
- existing Onboarding implementation delta remains unstaged:
  47 modified and 2 deleted tracked paths;
- Feature 35 is now available without changing any Onboarding implementation
  byte.

The failure to correct is the self-induced maintenance/currentness loop already
identified by the prior Onboarding architectural reviews:

```text
Onboarding command is eligible
-> ArchiveMutationCoordinator admits it
-> archive mutation lock becomes occupied
-> Environment Readiness observes maintenanceInProgress
-> Journey receives the maintenance report
-> post-await exact-command currentness check consults that report
-> the admitted command can deny itself because it owns the maintenance
```

The architectural requirement is mechanical:

> **A process holding the Ball cannot be denied the protected track merely
> because the track is occupied by that same Ball.**

At the same time:

> **Holding the Ball does not excuse stale or withdrawn external prerequisites.**

This task is **design only**.

Do NOT modify production code.
Do NOT modify tests.
Do NOT regenerate code.
Do NOT stage or commit.
Do NOT push.
Do NOT launch MessageLens Development.
Do NOT access real databases or attachment archives.

The purpose is to identify the smallest correct Onboarding change now that
Feature 35 provides exact tenure proof.

---

# 1. Read the governing records

Read in full:

## Onboarding authority / failure records

- `01-FORENSIC-ANALYSIS-OF-ONBOARDING-FAILURE.md`
- `02-NECESSARY-CORRECTIONS-TO-ONBOARDING.md`
- the Prompt 03 authority forensic audit;
- the Prompt 05 authority correction design;
- the Prompt 11 and Prompt 13 human-review responses;
- the Prompt 12 correction response;
- all later Onboarding records leading to the self-induced maintenance finding.

## Feature 35 records

Read at minimum:

- `35-EXCLUSIVE-AUTHORITY-TENURE/responses/01-EXCLUSIVE-AUTHORITY-ARCHITECTURE-AUDIT.md`
- `35-EXCLUSIVE-AUTHORITY-TENURE/responses/12-FINAL-VALIDATION-AND-CHECKPOINT.md`
- `35-EXCLUSIVE-AUTHORITY-TENURE/responses/13-INTEGRATE-EXCLUSIVE-AUTHORITY-TENURE-INTO-MAIN.md`

Also inspect the current source for:

- `OnboardingJourneyCoordinator`;
- its exact command-currentness predicates;
- action-context types;
- Environment Readiness reporting/evaluation;
- `ArchiveMutationCoordinator`;
- `ExclusiveAuthorityRegistry`;
- `ExclusiveAuthorityTenure`;
- `ArchiveMutationCapability`;
- archive mutation resource-admission APIs;
- any existing owner-aware/current-caller admission helper.

The two governing invariants are:

> **Evidence may be distributed. Journey authority may not be.**

and:

> **The Ball proves exclusive tenure. Domain capability proves what the current
> owner may do while holding that Ball. Diagnostics prove neither.**

---

# 2. Re-establish the current frozen implementation state

Verify before analysis:

- branch:
  `fix/onboarding-import-stuck-state`;
- HEAD:
  `276fa1b820b07bf14f41fe216192456b5415e290`;
- index empty;
- tracked implementation delta still exactly 47 modified / 2 deleted;
- shared submodule clean;
- `git diff --check` passes.

Do not require the old pre-merge patch hash to describe the new HEAD-relative
diff. Use the existing preservation manifests and per-file hashes only to
confirm no implementation byte changed since the controlled merge.

If the current working delta differs from the preserved post-merge state, STOP
AND REPORT.

---

# 3. Trace the exact current command paths

For each Journey command below, trace the current production call path from user
or coordinator intent through archive admission and the final command-start
decision:

1. initial import;
2. explicit reimport;
3. Continue Setup / interrupted-operation continuation;
4. automatic recovery/reset path.

For each, identify:

- the Journey state/action entry point;
- every `await` before protected work begins;
- where `ArchiveMutationCoordinator` admits the caller;
- when the archive maintenance/lock state changes;
- when Environment Readiness republishes;
- what updates `_latestReport`;
- every post-await prerequisite/currentness check;
- the exact predicate that can reject;
- whether the check executes inside the admitted archive Zone/tenure lineage;
- what exact proof is available at that point.

Produce a compact sequence diagram for each materially distinct path.

Do not assume all four commands need the same correction.

---

# 4. Reproduce the self-denial mechanically from source

Prove or disprove this precise sequence for the current implementation:

```text
latest report positively authorizes command C
-> Journey starts command C
-> ArchiveMutationCoordinator acquires archiveMutation tenure T
-> private archive Zone carries T
-> maintenance state changes because T is live
-> Environment Readiness emits maintenanceInProgress
-> Journey ingests that report
-> final positive predicate for C consults maintenanceInProgress
-> predicate rejects C
```

Identify the exact source statements for each transition.

Determine whether this can happen:

- deterministically;
- only under a provider scheduling race;
- only for some command kinds;
- or no longer at all after Feature 35 integration.

Do not design a correction until this trace is explicit.

---

# 5. Separate three different questions that must not be conflated

The correction must preserve a strict separation between:

## A. Exclusive tenure

Question:

> Does this caller hold the exact current archive-mutation Ball?

Authority:

- `ExclusiveAuthorityRegistry`;
- exact `ExclusiveAuthorityTenure`;
- archive private Zone translation.

## B. Archive-domain permission

Question:

> While holding that Ball, is this exact archive operation/scope permitted?

Authority:

- `ArchiveMutationCoordinator`;
- `ArchiveMutationOperation`;
- `ArchiveMutationCapability`;
- archive resource-admission policy.

## C. Onboarding command prerequisites

Question:

> Is command C still semantically appropriate given the latest external
> prerequisites and Journey occurrence?

Authority:

- `OnboardingJourneyCoordinator`;
- current Journey occurrence/action context;
- latest prerequisite evidence.

The design must not make any one of these stand in for another.

In particular:

- Ball ownership does not prove FDA/Contacts/import prerequisites;
- Environment Readiness maintenance diagnostics do not prove Ball ownership;
- Journey command eligibility does not grant archive authority.

---

# 6. Determine what `maintenanceInProgress` actually means today

Inspect the Environment Readiness evaluator and report model.

Answer precisely:

1. Is `maintenanceInProgress` produced from a coarse Boolean such as
   `dbMaintenanceLockProvider` / `.isLocked`?
2. Does the evaluator short-circuit when maintenance is active?
3. While maintenance is active, are FDA/Messages/Contacts/reset/import
   prerequisites still evaluated and represented somewhere?
4. Does a maintenance report preserve the last known underlying prerequisite
   truth, or does it replace/mask it?
5. Can external prerequisites genuinely change while self-owned maintenance is
   active?
6. If they change, can Journey observe those changes before starting protected
   work?

This is critical.

Do **not** solve self-denial by simply retaining the last pre-maintenance report
if maintenance masks newer external truth.

A cached report is acceptable only if source mechanics prove it cannot become
stale for the prerequisite being relied upon.

---

# 7. Inventory existing owner-aware APIs before inventing anything

Feature 35 was introduced specifically to avoid collapsing owner provenance to a
Boolean.

Inspect whether existing code already provides an owner-aware mechanism such as:

- `ArchiveMutationCoordinator.resourceAdmissionForCurrentCaller(...)`;
- exact current capability validation;
- current-tenure validation within the private Zone;
- another existing owner-aware admission query.

Determine whether Onboarding can reuse an existing API rather than adding:

- a new lock owner model;
- a second tenure state;
- a public ambient `currentBall`;
- a Journey-owned copy of tenure truth;
- a new Environment maintenance authority.

Prefer reuse.

---

# 8. Evaluate the candidate correction shapes

Evaluate at least the following approaches against current source.

Do not select one merely because it is listed here.

## Candidate A — Ignore self-owned maintenance in the final command check

Concept:

```text
if latest report says maintenance
and exact current caller proves it owns the archive tenure
then maintenance itself is not a command-withdrawal reason
```

Question:

Can this still detect changed FDA/Contacts/reset prerequisites while maintenance
is active?

If maintenance masks those facts, Candidate A alone is insufficient.

## Candidate B — Owner-aware Environment Readiness evaluation

Concept:

```text
Environment evaluation for current caller:
    foreign maintenance -> maintenanceInProgress
    same exact archive tenure -> continue evaluating real prerequisites
```

This preserves latest external truth while making self-maintenance mechanically
non-blocking.

Question:

Can this be done through an existing current-caller/archive admission seam
without making Environment Readiness an authority owner?

## Candidate C — Split maintenance occupancy from prerequisite truth

Concept:

Keep maintenance as truthful observable evidence, but provide Journey with a
separate latest prerequisite projection that is not overwritten by the
maintenance presentation state.

Question:

Would this create another semantic authority or stale-cache risk?

## Candidate D — Move the final semantic currentness check before archive
admission

Question:

Is there any `await` or externally changing prerequisite after that check and
before protected work begins?

If yes, this reintroduces the exact post-await currentness bug the prior reviews
were designed to eliminate.

## Candidate E — Bind an exact archive proof into the existing typed Journey
action context

Question:

Would this merely carry proof needed by the final check, or would it duplicate
authority/lifetime state inside Journey?

Determine whether the existing action context already has an appropriate place
for a non-serializable, occurrence-bound proof or whether proof should remain
ephemeral inside the admitted callback.

---

# 9. Select the smallest mechanically correct design

Choose the design that satisfies all of these simultaneously:

1. a command cannot reject itself solely because it owns the archive mutation
   tenure;
2. foreign maintenance still blocks it;
3. stale/released tenure cannot excuse maintenance;
4. external prerequisite withdrawal after any earlier await still blocks the
   command;
5. exact command-specific semantics remain:
   - initial import;
   - reimport;
   - continuation;
   - automatic recovery;
6. Journey remains sole publisher of user-visible Onboarding semantics;
7. presentation remains Journey-only;
8. Environment Readiness remains evidence, not Journey authority;
9. generic tenure registry remains domain-ignorant;
10. ArchiveMutationCoordinator remains archive-domain authority;
11. no public ambient Ball lookup is introduced;
12. no diagnostic label/occurrence/isHeld value becomes proof;
13. no persisted schema change is required unless source proves otherwise;
14. restart reconciliation semantics remain unchanged;
15. no automatic resume is introduced.

State the selected design as a small set of explicit invariants.

---

# 10. Define the exact proof/currentness rule

Write the intended decision rule in pseudocode.

It should be precise enough that an implementation agent cannot collapse
ownership back to a Boolean.

For example, if source analysis supports it, the rule may resemble:

```text
before command C begins protected work:

    require Journey occurrence/action context still current

    evaluate latest command-C external prerequisites

    if maintenance is foreign:
        reject

    if maintenance is caused by the exact current archive tenure T
       held by this admitted callback:
        maintenance itself is not a rejection reason

    require all non-maintenance prerequisites for C still positively hold

    proceed
```

But use the exact current APIs and semantics discovered in source.

Specify what happens when proof is:

- missing;
- stale;
- wrong registry;
- wrong operation;
- outside the expected Zone;
- coordinator disposed.

All must fail closed.

---

# 11. Determine whether Environment Readiness must change

Give a categorical answer:

- **NO Environment Readiness production change required**, or
- **YES — one narrowly defined owner-aware evidence change is required**.

If YES, specify:

- exact file/type;
- exact new input or query;
- why this is evidence rather than authority;
- why it cannot create a presentation side door;
- why it preserves truthful foreign-maintenance reporting;
- how external prerequisite changes remain visible during self-owned
  maintenance.

Do not redesign the entire evaluator.

---

# 12. Determine whether Journey state/action context must change

Give a categorical answer for each:

- `OnboardingJourneyState`;
- immutable Journey operation projection;
- typed Journey action context;
- persisted operation snapshot.

Prefer **no state/schema change** if proof can remain scoped to the admitted
callback.

If any type must change, explain the minimal field and lifecycle.

Never serialize `ExclusiveAuthorityTenure` or archive capability.

---

# 13. Define the hostile-race test matrix

Design deterministic tests using Completers/barriers, not sleeps.

At minimum cover:

1. initial import acquires its own tenure; self-maintenance report arrives before
   final check; import still begins if all external prerequisites remain valid;
2. same sequence but foreign maintenance owns the Ball; command does not begin;
3. self-owned tenure is stale/released before final check; command does not
   begin;
4. FDA prerequisite withdraws after archive admission; command does not begin;
5. Contacts prerequisite withdraws after archive admission where applicable;
6. command-specific readiness changes from authorized to a different semantic
   state while self-maintenance is active; command does not begin;
7. continuation becomes superseded by ready/new-state evidence; it does not
   resume;
8. automatic recovery loses `shouldResetAppDatabasesBeforeImport`; it does not
   start;
9. same-owner proof cannot authorize a different archive operation if operation
   proof matters;
10. foreign/stale callback retaining old Ball 1 while Ball 2 is live fails;
11. presentation still renders solely from Journey state despite hostile raw
    environment/graph/snapshot noise;
12. restart behavior remains explicit Continue Setup for ordinary interrupted
    import.

Tests must exercise the real ArchiveMutationCoordinator/Feature 35 ownership
mechanism, not the old `_ImmediateArchiveMutationCoordinator` fake that does not
publish lock state.

If a lightweight fake is retained for unrelated tests, add a real-owner harness
for these races.

---

# 14. Define the architecture tripwires

Specify architecture-test changes needed to prevent regression.

At minimum the architecture suite should reject:

- Onboarding authorization from maintenance `isLocked`/diagnostic Boolean alone;
- direct use of generic tenure diagnostics as proof;
- presentation importing raw maintenance/registry proof;
- a public ambient current-tenure lookup;
- Journey serialization/persistence of tenure;
- a second Onboarding authority source;
- bypass of exact current-caller archive proof in the corrected final command
  path.

Prefer structural allowlists/censuses over fragile identifier-name checks where
practical.

---

# 15. Scope the implementation diff

Produce an expected file list divided into:

## Must change

Only files required by the selected design.

## May change

Tests/architecture helpers/generated output that are mechanically required.

## Must not change

At minimum:

- presentation widgets;
- Feature 35 generic registry internals;
- archive relocation/adoption domain policy unless source proves an existing
  owner-aware API defect;
- database schema;
- persisted operation snapshot schema;
- native lock;
- attachment archive configuration;
- production data;
- unrelated Onboarding Trips/Steps.

If the design appears to require a broad Feature 35 redesign, STOP and explain
why. The expected outcome is a narrow Onboarding correction.

---

# 16. Migration / persistence / restart analysis

Explicitly answer:

- schema migration required: YES / NO;
- persisted snapshot migration required: YES / NO;
- existing interrupted-operation records remain readable: YES / NO;
- startup reconciliation semantics change: YES / NO;
- automatic resume introduced: YES / NO.

Any YES requires source-backed justification.

---

# 17. Validation plan

Design the implementation validation sequence.

At minimum:

1. focused self-maintenance race tests;
2. existing Journey authority/currentness tests;
3. archive mutation coordinator tests;
4. Feature 35 architecture tests;
5. Onboarding architecture tests;
6. complete architecture suite;
7. analyzer;
8. full Flutter suite;
9. diff check;
10. Project Conformance audit;
11. human architectural review before checkpoint.

Do not include GUI qualification yet.

GUI clean-slate qualification resumes only after the corrected Onboarding
architecture earns a checkpoint.

---

# 18. Do not implement

This prompt ends with a correction design.

Do NOT modify code or tests.
Do NOT stage or commit.
Do NOT push.

---

# 19. Required response

Create the next sequential response in the Feature 34 Onboarding responses
folder.

Report:

1. baseline verification;
2. exact current command-path traces;
3. source-proven self-denial sequence;
4. tenure/archive/Journey authority separation;
5. maintenance-report semantics;
6. existing owner-aware API inventory;
7. Candidate A assessment;
8. Candidate B assessment;
9. Candidate C assessment;
10. Candidate D assessment;
11. Candidate E assessment;
12. selected minimal design;
13. exact proof/currentness pseudocode;
14. Environment Readiness change verdict;
15. Journey state/action-context change verdict;
16. persistence/migration verdict;
17. hostile-race test matrix;
18. architecture-tripwire plan;
19. exact expected implementation file scope;
20. validation plan;
21. Project Conformance risks;
22. stop gates;
23. readiness for implementation.

Conclude exactly:

`MINIMAL ONBOARDING TENURE CORRECTION DESIGN COMPLETE: YES / NO`

If YES, also conclude:

`READY TO IMPLEMENT MINIMAL ONBOARDING TENURE CORRECTION: YES / NO`

Then STOP.
