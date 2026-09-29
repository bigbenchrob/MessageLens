# MessageLens Feature 34 / Feature 35
## 18 — Implement the Minimal Onboarding Tenure Correction

Prompt 17 completed the source-level design of the remaining Onboarding
self-maintenance defect.

The design established that the defect is still real:

```text
command positively authorized
-> ArchiveMutationCoordinator admits it
-> exact archiveMutation tenure becomes live
-> archive coordinator publishes isLocked=true
-> global Environment report becomes maintenanceInProgress
-> Journey ingests that report into _latestReport
-> post-await exact command predicate consults the masked maintenance report
-> admitted command can deny itself before begin/resume/reset
```

Feature 35 already supplies the exact proof mechanics. The correction is a
narrow Onboarding integration, not a redesign.

The selected design is:

> **Use `ArchiveMutationCoordinator.runWithCapability` for the four protected
> Onboarding commands. Inside the admitted callback, obtain a fresh,
> non-publishing owner-scoped Environment report through the exact current
> capability and current-caller resource policy. Journey then applies its
> existing command-specific positive predicate to that complete evidence.**

The global Environment provider remains owner-agnostic and continues to report
aggregate maintenance truthfully.

This task implements that design.

Do NOT redesign Feature 35.
Do NOT add a second authority model.
Do NOT add a public ambient current-tenure lookup.
Do NOT persist or publish capability/tenure.
Do NOT change presentation.
Do NOT change database or snapshot schemas.
Do NOT change archive relocation/adoption policy.
Do NOT launch MessageLens Development.
Do NOT access real databases or real attachment archives.
Do NOT stage or commit.
Do NOT push.

---

# 1. Read the governing design and authority records

Read in full before editing:

- the response to Prompt 17:
  `17-DESIGN-MINIMAL-ONBOARDING-TENURE-CORRECTION.md`;
- Onboarding:
  - `01-FORENSIC-ANALYSIS-OF-ONBOARDING-FAILURE.md`;
  - `02-NECESSARY-CORRECTIONS-TO-ONBOARDING.md`;
  - the latest Journey-authority human-review/correction records;
- Feature 35:
  - `responses/01-EXCLUSIVE-AUTHORITY-ARCHITECTURE-AUDIT.md`;
  - `responses/12-FINAL-VALIDATION-AND-CHECKPOINT.md`;
  - `responses/13-INTEGRATE-EXCLUSIVE-AUTHORITY-TENURE-INTO-MAIN.md`;
- Project Conformance Audit Standard;
- current repository instructions.

Governing invariants:

> **Evidence may be distributed. Journey authority may not be.**

> **The Ball proves exclusive tenure. Domain capability proves what the current
> owner may do while holding that Ball. Diagnostics prove neither.**

And the crucial conjunction:

> **Self-owned maintenance is not itself a reason to reject the owner, but Ball
> ownership never substitutes for fresh FDA/Messages/Contacts/reset/import/
> reconciliation prerequisites.**

---

# 2. Verify the current implementation baseline

Worktree:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Require:

- branch:
  `fix/onboarding-import-stuck-state`;
- HEAD:
  `276fa1b820b07bf14f41fe216192456b5415e290`;
- index empty;
- existing tracked implementation delta:
  exactly 47 modified and 2 deleted paths;
- shared submodule clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- `git diff --check` passes.

Verify the controlled-reconstruction preservation material from Prompts 14–16
still exists and that the 49 preserved tracked entries still match their
post-merge bytes before this implementation begins.

Create a fresh implementation-baseline manifest outside the repository that
records:

- all current modified/deleted tracked paths;
- all current untracked paths;
- SHA-256/type evidence;
- branch/HEAD/index;
- shared-submodule state.

This manifest is for detecting scope creep during Prompt 18.

Do not require the old pre-merge HEAD-relative patch hash to describe the new
branch base.

If the preserved implementation state differs before authorized edits begin,
STOP AND REPORT.

---

# 3. Strict implementation scope

The approved production scope is intentionally small.

## Production files that MUST change

1. `lib/essentials/onboarding/application/onboarding_environment_report_provider.dart`
2. `lib/essentials/onboarding/application/onboarding_journey_coordinator_provider.dart`

## Test files that MUST change

3. `test/essentials/onboarding/application/onboarding_environment_report_provider_test.dart`
4. `test/essentials/onboarding/application/onboarding_journey_coordinator_provider_test.dart`
5. `test/architecture/onboarding_journey_authority_architecture_test.dart`

## MAY change only if mechanically required

- `test/architecture/forbidden_imports_test.dart`
- `lib/essentials/onboarding/application/onboarding_environment_report_provider.g.dart`
  only if an annotated generated symbol is genuinely unavoidable.

Prefer a plain internal evidence reader so no new generated provider is needed.

## MUST NOT change

- presentation widgets/panels;
- `OnboardingJourneyState`;
- `OnboardingJourneyActionContext`;
- immutable Journey operation projection;
- `OnboardingOperationSnapshot`;
- snapshot codecs;
- database schemas;
- Feature 35 generic registry internals;
- `ExclusiveAuthorityRegistry`;
- `ExclusiveAuthorityTenure`;
- `ArchiveMutationCoordinator`;
- `ArchiveMutationCapability`;
- archive relocation/adoption policy;
- native locks;
- attachment archive configuration;
- unrelated Onboarding Trips/Steps;
- production data;
- release metadata.

If implementation appears to require a MUST-NOT-CHANGE file, STOP AND REPORT
before editing it.

---

# 4. Implement one internal admitted-caller Environment evidence read

In `onboarding_environment_report_provider.dart`, reuse the existing Environment
input/evaluator construction.

Add one **internal, non-publishing** read path for use by
`OnboardingJourneyCoordinator` while already inside an admitted archive
operation.

The read must require:

- exact `ArchiveMutationCapability`;
- exact expected `ArchiveMutationOperation`.

The API must not be exported through the public Onboarding feature barrel.

Do not create a second provider-held “latest prerequisites” cache.

Do not add owner identity to the global Environment report.

Do not store capability in provider state.

---

# 5. Preserve the ordinary global Environment provider semantics

The existing global `onboardingEnvironmentReportProvider` remains:

- owner-agnostic;
- aggregate;
- truthful for unrelated observers;
- maintenance-aware.

It must continue to treat any live archive mutation as aggregate maintenance for
the ordinary read model.

Do not make the global provider caller-relative.

Do not suppress global `maintenanceInProgress` merely because some current
caller elsewhere owns the Ball.

---

# 6. Define the admitted evidence read mechanically

The admitted read must perform this pattern:

```text
readAdmittedEnvironmentEvidence(
    capability,
    expectedOperation,
):
    capability.requireOperation(expectedOperation)

    require current-caller resource admission
        for every derived resource the evaluator will probe

    await/recompute the same Environment facts using
        the existing evaluator/input policy,
        while not treating this exact current archive scope's coarse
        archive isLocked observation as foreign maintenance

    still honor any stronger database-reopen/resource policy

    capability.requireOperation(expectedOperation)

    re-require current-caller resource admission

    return complete current report
```

Important:

- capability proof is mandatory;
- `resourceAdmissionForCurrentCaller(...).unrestricted` or any other diagnostic
  result is not ownership proof by itself;
- `.isLocked`, owner label, occurrence, and generic diagnostics are never proof;
- proof must be revalidated after the read's awaits;
- resource admission must be revalidated after the read's awaits.

If exact capability or resource policy is invalid at either edge, fail closed.

---

# 7. Reuse the existing Environment evaluator; do not duplicate policy

The admitted read must share the same:

- FDA/Messages/Contacts evidence;
- source availability/history logic;
- import-ledger/graph/reset logic;
- reconciliation semantics;
- readiness classification rules

used by the ordinary Environment report.

Do not copy command readiness/reset rules into Journey.

Do not create a second evaluator with subtly different policy.

The only caller-relative distinction is whether the current archive scope's own
coarse maintenance observation is allowed to mask app-owned derived probes.

External prerequisites must be freshly re-read.

---

# 8. Convert all four protected Journey commands to `runWithCapability`

In `OnboardingJourneyCoordinator`, convert exactly these command paths:

1. initial import;
2. explicit reimport;
3. Continue Setup / interrupted continuation;
4. automatic recovery/reset.

Use `ArchiveMutationCoordinator.runWithCapability`, with the existing correct
typed archive operation for each path.

Do not expose the capability outside the admitted callback.

Do not retain it in a field.

Do not put it in:

- Journey state;
- action context;
- operation projection;
- operation snapshot;
- persistence;
- presentation.

It is callback-local, ephemeral proof.

---

# 9. Preserve a positive pre-admission handoff check

Immediately before archive admission, require:

- exact current Journey Episode/action context;
- current command token eligibility;
- latest **complete global report**;
- the unchanged command-specific positive predicate.

Then call `runWithCapability` with **no intervening await**.

Do this for all four command types.

This pre-admission check is a valid handoff requirement, but it does not replace
the late check.

---

# 10. Initial import — exact late boundary

Inside the admitted `onboardingImport` capability callback:

1. preserve current command/action checks;
2. preserve the direct FDA safety check if currently present;
3. acquire the operation controller as today;
4. after that await, obtain fresh admitted Environment evidence;
5. revalidate:
   - capability/operation;
   - command token;
   - original action context;
   - any current command-specific binding;
6. apply the unchanged `_latestReportAllowsInitialImport` semantics to the fresh
   admitted report rather than the aggregate maintenance report;
7. invoke `controller.begin(initialImport)` immediately after the conjunction,
   with no intervening await.

Do not weaken the exact initial-import predicate.

---

# 11. Reimport — exact late boundary

Use the same proof/evidence pattern for reimport.

After controller acquisition:

- fresh admitted Environment evidence;
- capability revalidation;
- command/action-currentness;
- unchanged exact reimport predicate;
- immediate `controller.begin(reimport)`.

A current self-owned Ball must not let reimport proceed if current evidence is
no longer `ready` under the existing reimport policy.

---

# 12. Continue Setup — exact UUID/session/status boundary

Preserve the existing positive pre-admission continuation check.

Inside the admitted callback:

1. acquire controller;
2. revalidate:
   - action context;
   - exact operation UUID;
   - process session;
   - interrupted status;
3. obtain fresh admitted Environment evidence;
4. revalidate capability and binding after its awaits;
5. apply the unchanged continuation/resumability predicate to the current
   operation/report;
6. call `controller.resume(operationId)` immediately, with no intervening await.

A `ready`/superseding state must still prevent resume.

No automatic resume is introduced.

---

# 13. Automatic recovery — preserve both late boundaries

Automatic recovery has more than one meaningful late boundary.

Implement owner-scoped fresh evidence at least:

## Before `controller.begin(automaticRecovery)`

After controller acquisition:

- capability current;
- action/token current;
- fresh admitted report;
- unchanged exact automatic-recovery predicate;
- immediate `begin`.

## Immediately before `resetDerivedData()`

After stage/progress persistence awaits:

- bound operation still current;
- capability current;
- fresh admitted Environment evidence;
- current-caller resource policy permits the required probe/reset boundary;
- exact `shouldResetAppDatabasesBeforeImport == true` semantics still hold;
- immediate reset invocation with no intervening await.

If reset is no longer required, do not reset.

Do not infer continuing reset need from the fact that automatic recovery already
started.

---

# 14. Do not use `_latestReport` as the admitted final proof

The global listener may still replace `_latestReport` with
`maintenanceInProgress` during the active command.

That is expected aggregate evidence.

The final in-capability decision must use the fresh report returned by the
admitted evidence read.

Do not overwrite `_latestReport` with that caller-relative report.

Do not publish that report through the global Environment provider.

Do not make it visible to presentation.

It is one-shot evidence for the admitted command.

---

# 15. Correct the `maintenanceInProgress` Journey mapping

The current ownerless global `maintenanceInProgress` report must not
independently manufacture `OnboardingNormalApplication`.

Implement the narrow Prompt 17 rule:

- while a command is active, retain the already-authorized Journey Episode;
- when an already-established semantic Journey state exists, aggregate
  maintenance alone must not invent a different semantic Journey outcome;
- during cold reconstruction with only maintenance evidence, remain in checking
  rather than treating maintenance as proof of Normal Application;
- after maintenance releases and complete global evidence arrives, Journey may
  transition normally from that complete evidence.

Do not add a Maintenance Episode.

Do not make presentation read maintenance directly.

Do not make Journey ignore hard external blockers that the ordinary evaluator
still reports ahead of maintenance.

---

# 16. Preserve command-specific semantics

Do not replace the four exact predicates with a generic:

```text
selfMaintenanceAllowed == true
```

or equivalent Boolean.

Continue to use the current distinct semantics for:

- `_latestReportAllowsInitialImport`;
- `_latestReportAllowsReimport`;
- `_latestReportAllowsInterruptedContinuation`;
- `_latestReportAllowsAutomaticRecovery`.

It is acceptable to refactor them to accept an explicit report argument if that
is the smallest way to apply them to admitted evidence.

If so:

- preserve their exact semantics;
- avoid hidden dependence on mutable `_latestReport`;
- use `_latestReport` only where the global current report is actually intended.

A helper that turns the predicates into pure `report -> bool` checks is
preferred if it reduces ambiguity without broad refactoring.

---

# 17. Build the real-owner hostile-race harness

The critical new tests must exercise:

- real `ExclusiveAuthorityRegistry`;
- real `ArchiveMutationCoordinator`;
- real lock-state publication;
- real private Zone/capability behavior.

Do not use `_ImmediateArchiveMutationCoordinator` for tests intended to prove
the self-maintenance race.

That lightweight fake may remain in unrelated legacy tests.

Use deterministic `Completer`/barrier ordering.

No timing sleeps.

---

# 18. Required hostile-race tests

Implement at minimum the Prompt 17 matrix:

1. initial import + self-owned maintenance + unchanged valid prerequisites ->
   exactly one `begin`;
2. foreign Ball -> admitted callback / `begin` never executes;
3. stale/released proof -> no `begin`;
4. FDA withdraws after admission -> no `begin`;
5. Contacts withdraws after admission where applicable -> no begin/resume;
6. initial import becomes semantically `ready` -> no initial begin;
7. reimport becomes semantically `readyToImport`/otherwise unauthorized -> no
   reimport begin;
8. continuation becomes superseded by ready/new-state evidence -> no resume;
9. automatic recovery loses reset requirement before `begin` -> no begin;
10. automatic recovery loses reset requirement after stage/progress await -> no
    `resetDerivedData`;
11. wrong operation capability -> typed denial/no work;
12. retained Ball 1 callback while Ball 2 is live -> no admitted evidence/work;
13. self-owned reimport with current valid evidence -> exactly one reimport begin;
14. self-owned continuation with complete resumable evidence -> same UUID resumes
    exactly once;
15. self-owned automatic recovery with current reset evidence -> reset exactly
    once;
16. capability/resource policy changes during admitted evidence reader await ->
    post-await revalidation fails closed;
17. presentation remains Journey-only under hostile raw maintenance/graph/
    snapshot noise;
18. restart remains explicit Continue Setup for ordinary interrupted import.

Where several assertions can share one deterministic fixture without obscuring
the boundary, reuse the fixture.

---

# 19. Environment-report tests

Add focused proof that:

- ordinary global provider still reports aggregate `maintenanceInProgress`;
- admitted read with exact current capability returns complete current evidence
  when current-caller resource policy permits it;
- admitted read does not use cached pre-maintenance evidence;
- FDA/Messages/Contacts changes during self-maintenance are reflected;
- reset/import/graph facts are freshly evaluated;
- wrong/stale capability fails;
- wrong operation fails;
- outside-Zone use fails;
- resource admission denial fails before protected probes;
- capability/resource admission is rechecked after internal awaits;
- admitted report is not published globally.

---

# 20. Architecture tripwires

Strengthen `onboarding_journey_authority_architecture_test.dart` to enforce
structurally, preferably with AST/census rules where practical:

1. all four protected commands use `runWithCapability`;
2. no protected command uses capability-free `.run` for these paths;
3. admitted Environment evidence requires
   `ArchiveMutationCapability` + typed expected operation;
4. capability is validated before and after admitted-reader awaits;
5. current-caller resource admission is checked before and after;
6. only `OnboardingJourneyCoordinator` consumes the admitted evidence seam;
7. the ordinary global Environment provider remains owner-agnostic;
8. the admitted seam is not exported from the public Onboarding barrel;
9. presentation imports no Environment proof/capability/registry/maintenance
   authority;
10. Journey state/action context/projection/snapshot contain no tenure or
    capability;
11. no ambient current-Ball lookup exists;
12. generic diagnostics / `.isLocked` / labels / occurrences are not used as
    Onboarding authorization proof;
13. `maintenanceInProgress` cannot independently construct
    `OnboardingNormalApplication`;
14. the exact command-specific semantic predicate is the last semantic check
    before each `begin`, `resume`, or reset boundary.

Do not make architecture enforcement depend only on current identifier spelling
if a semantic allowlist/census is practical.

---

# 21. Preserve persistence and restart behavior

There must be:

- no schema migration;
- no persisted snapshot migration;
- no operation snapshot codec change;
- no automatic resume of ordinary interrupted import;
- no startup reconciliation semantic change.

Existing interrupted records must remain readable.

---

# 22. Validation sequence

After implementation, run:

1. focused admitted-evidence tests;
2. focused real-owner self-maintenance race tests;
3. complete
   `onboarding_journey_coordinator_provider_test.dart`;
4. complete
   `onboarding_environment_report_provider_test.dart`;
5. archive mutation coordinator tests;
6. generic Feature 35 registry tests;
7. Feature 35 architecture tests;
8. Onboarding Journey authority architecture tests;
9. other Onboarding snapshot/authority architecture tests affected by the diff;
10. complete architecture suite;
11. `flutter analyze --no-pub`;
12. complete `flutter test --reporter compact`;
13. `git diff --check`;
14. formatting/generated consistency if applicable.

Record exact pass/fail/skip counts.

Do not launch GUI qualification.

---

# 23. Project Conformance audit

Audit the complete accumulated Onboarding correction delta, not only Prompt 18.

Explicitly inspect:

- sole Journey authority;
- presentation Journey-only;
- no raw evidence side doors;
- exact current command semantics;
- exact archive capability proof;
- no Boolean ownership regression;
- no duplicate readiness evaluator/policy;
- no caller-relative global cache;
- no capability escape;
- no resource-policy bypass;
- late checks after relevant awaits;
- no persistence/schema drift;
- restart semantics unchanged;
- Feature 35 generic/domain boundary unchanged;
- privacy/data safety;
- dead code;
- test-fake realism.

Require:

`PROJECT CONFORMANCE: PASS`

with:

- BLOCKER: 0
- SHOULD FIX: 0

Do not perform aesthetic refactoring merely to empty the findings list.

---

# 24. Verify authorized diff scope

At completion compare against the Prompt 18 implementation-baseline manifest.

Report:

- which pre-existing tracked files changed during Prompt 18;
- whether every change is in the approved file scope;
- whether any pre-existing unrelated untracked file changed;
- whether the shared submodule changed.

No preservation artifact should be modified.

If any unauthorized path changed, restore only tool-generated unrelated churn
when unquestionably safe; otherwise STOP AND REPORT.

---

# 25. Leave implementation unstaged and uncommitted

Even if all validation passes:

- do not stage;
- do not commit;
- do not push.

The next step is a human architectural review before checkpoint.

---

# 26. Required response

Create the next sequential response in the Feature 34 Onboarding responses
folder.

Report:

1. baseline/preservation verification;
2. admitted Environment evidence implementation;
3. proof/resource revalidation behavior;
4. global Environment semantics;
5. initial-import correction;
6. reimport correction;
7. continuation correction;
8. automatic-recovery correction;
9. maintenance-to-Journey mapping correction;
10. Journey state/action-context/persistence non-changes;
11. hostile-race test harness;
12. hostile-race results;
13. Environment-report test results;
14. Journey coordinator test result;
15. archive/Feature 35 regression results;
16. architecture-tripwire implementation;
17. architecture results;
18. analyzer result;
19. full Flutter-suite result;
20. generation/format/diff hygiene;
21. Project Conformance verdict;
22. BLOCKER findings;
23. SHOULD FIX findings;
24. exact changed-file census;
25. implementation-baseline manifest comparison;
26. frozen preservation-artifact verification;
27. exact Git status;
28. stop gates encountered;
29. readiness for human architectural review.

Conclude exactly:

`MINIMAL ONBOARDING TENURE CORRECTION IMPLEMENTED: YES / NO`

If YES, also conclude:

`READY FOR ONBOARDING HUMAN ARCHITECTURAL REVIEW BEFORE CHECKPOINT: YES / NO`

Then STOP.
