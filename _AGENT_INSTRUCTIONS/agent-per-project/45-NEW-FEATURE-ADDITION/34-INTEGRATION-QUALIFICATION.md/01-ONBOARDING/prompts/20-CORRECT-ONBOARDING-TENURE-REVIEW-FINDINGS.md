# MessageLens Feature 34 / Feature 35
## 20 — Correct Admitted-Evidence Currentness and Prove the Real Self-Maintenance Loop

Prompt 19 completed the human architectural review of the minimal Onboarding
tenure correction.

The review found:

- runtime authority model: still conceptually correct;
- BLOCKER: 2;
- SHOULD FIX: 2;
- checkpoint: not yet safe.

The two blockers are narrow and concrete:

1. the admitted Environment reader does not re-establish capability/resource
   authority around **every material internal evaluator await**, and prerequisite
   inputs can remain snapshotted across those awaits;
2. the critical Journey fixture overrides the global Environment provider and
   therefore removes the real production feedback loop
   `isLocked -> maintenanceInProgress -> _latestReport`.

The SHOULD FIX findings are also bounded:

- architecture enforcement is too source-string/order brittle to guarantee the
  corrected await/proof boundaries;
- two previously identified semantic-census omissions remain:
  `OnboardingStatus`-only semantic consumers and raw conversation-graph evidence.

This task corrects exactly those findings.

Do NOT redesign Journey authority.
Do NOT redesign Feature 35.
Do NOT create another readiness evaluator.
Do NOT add a caller-relative global cache.
Do NOT persist or publish capability/tenure.
Do NOT change presentation.
Do NOT change database/snapshot schemas.
Do NOT stage or commit.
Do NOT push.
Do NOT launch MessageLens Development.
Do NOT access real databases or attachment archives.

Read in full:

- `18-IMPLEMENT-MINIMAL-ONBOARDING-TENURE-CORRECTION.md`
- `19-HUMAN-ARCHITECTURAL-REVIEW-ONBOARDING-TENURE-CORRECTION.md`
- `17-DESIGN-MINIMAL-ONBOARDING-TENURE-CORRECTION.md`
- the current accumulated Onboarding diff;
- Feature 35 authority and architecture records as needed.

Governing invariants remain:

> **Evidence may be distributed. Journey authority may not be.**

> **The Ball proves exclusive tenure. Domain capability proves what the current
> owner may do while holding that Ball. Diagnostics prove neither.**

> **No protected read may occur after authority/resource admission becomes
> stale, and no command may rely on prerequisite facts snapshotted across a
> material await without refreshing or proving their revision current.**

---

# 1. Baseline and preservation gate

Worktree:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Require:

- branch:
  `fix/onboarding-import-stuck-state`;
- HEAD:
  `276fa1b820b07bf14f41fe216192456b5415e290`;
- index empty;
- accumulated tracked delta:
  48 modified / 2 deleted;
- shared submodule clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- `git diff --check` passes.

Verify the Prompt 18 baseline manifest:

`/private/tmp/messagelens-onboarding-prompt18-baseline.yd0I9Y/MANIFEST.json`

SHA-256:

`0996303f8fc409ebb4748cbfc75999c7649e09f57dac202b99dd0fefee92621c`

and the three reconstruction/preservation manifests remain unchanged.

Create a fresh Prompt 20 baseline manifest outside the repository before
editing.

If any unrelated implementation byte has changed since Prompt 19, STOP AND
REPORT.

---

# 2. Strict correction scope

## Production file that MUST change

1. `lib/essentials/onboarding/application/onboarding_environment_report_provider.dart`

## Test files that MUST change

2. `test/essentials/onboarding/application/onboarding_environment_report_provider_test.dart`
3. `test/essentials/onboarding/application/onboarding_journey_coordinator_provider_test.dart`
4. `test/architecture/onboarding_journey_authority_architecture_test.dart`

## MAY change only if mechanically required

5. `test/architecture/forbidden_imports_test.dart`

`onboarding_journey_coordinator_provider.dart` is **not expected to need a
production semantic change**. Its Prompt 18 command ordering/predicates were
reviewed as correct conditional on the admitted-reader fix.

If implementation appears to require changing Journey command semantics,
Feature 35 internals, ArchiveMutationCoordinator, presentation, persistence,
schema, or archive policy, STOP AND REPORT.

Do not perform optional cleanup in this task.

---

# 3. Correct BLOCKER 1 — make the admitted read fail closed around every material await

Inspect the exact current await/probe graph in:

- `readAdmittedOnboardingEnvironmentEvidence`;
- `_readOnboardingEnvironmentInputs`;
- `_OnboardingEnvironmentEvaluator.evaluate`.

The reviewed unsafe sequence is:

```text
authority/resource proof valid
-> await loadSourceImportFailureEntry()
-> authority/resource policy becomes invalid
-> continue to loadGraphProjectionFailureEntry()
-> continue into protected derived-store probes
-> only final outer check notices invalid authority
```

That must become mechanically impossible.

## Required invariant

For the admitted path:

> After every material await, exact capability and required resource admission
> must be re-established **before any subsequent protected read/probe**.

A check only at evaluator entry and evaluator exit is insufficient.

---

# 4. Reuse one evaluator; do not fork readiness policy

Preserve one readiness/reset/reconciliation evaluator.

Choose the smallest refactor that lets the admitted path bracket the evaluator's
internal awaits without copying policy.

Acceptable shapes include:

- evaluator phase hooks/checkpoints supplied by the caller;
- an injected private admission-check callback invoked after each material await
  and before the next protected operation;
- moving async evidence acquisition into a shared input-reading phase that can
  be guarded between awaits, leaving the evaluator synchronous afterward;
- another equivalently narrow structure.

The ordinary global provider must reuse the same evaluator/policy without
gaining owner-relative semantics.

Do NOT:

- duplicate `_OnboardingEnvironmentEvaluator`;
- duplicate reset/readiness classification in Journey;
- introduce a second persistent/current-prerequisites provider;
- store capability in evaluator state beyond the one call.

---

# 5. Define every material await boundary explicitly

At minimum inspect and correctly bracket:

1. attachment-location resolution;
2. Contacts resolution;
3. `loadSourceImportFailureEntry()`;
4. `loadGraphProjectionFailureEntry()`;
5. any additional await currently present in input construction or evaluator
   execution.

For each material await, document in code/tests:

```text
proof/resource valid before the operation
-> await
-> proof/resource revalidated
-> only then may the next protected read occur
```

If a given await is not followed by any protected operation and cannot affect
the returned fact set, explain why rather than adding ceremonial checks.

---

# 6. Make returned prerequisite facts current at return

Prompt 19 also found that the admitted input object snapshots facts such as:

- FDA;
- Contacts aggregate evidence;
- attachment location;
- lifecycle/dev override state;
- maintenance-related inputs;

before evaluator-internal awaits.

A final capability check does not prove those facts stayed current.

Correct this without a retained cache.

Use the smallest source-consistent mechanism, for example:

- capture/read externally changing synchronous prerequisite facts **after the
  final internal async evidence await**;
- or attach revision tokens and re-read/reject if their revisions changed;
- or another exact fresh-read mechanism already used in the project.

## Required result

The admitted report returned to Journey must represent prerequisite truth
current **after the final material await**.

If FDA, Contacts, source availability/history, lifecycle/reset-driving evidence,
or another command-relevant prerequisite changes during an internal await, the
returned report must either:

- reflect the new value; or
- fail closed and require a new read.

It may not silently return the pre-await snapshot.

Do not solve this by caching the last complete report.

---

# 7. Preserve stronger resource policy

The admitted read may ignore only the exact current owner's coarse aggregate
archive lock for the purpose of obtaining complete evidence.

It must continue to honor stronger resource admission such as database-reopen
blocking.

For every protected derived resource the admitted evaluator will inspect:

- exact capability proof is necessary;
- current-caller resource admission is independently necessary.

If either becomes invalid while awaiting, no later protected read may occur.

---

# 8. Strengthen Environment-reader tests to prove zero post-withdrawal probes

The current tests prove eventual rejection but not fail-closed access.

Add deterministic recording probes/counters around the protected reads.

For each relevant internal await:

1. block the await with a `Completer`;
2. revoke capability or install stronger resource denial;
3. release the await;
4. assert:
   - the Future fails;
   - **zero subsequent protected probes/reads occurred** after withdrawal.

At minimum directly prove the boundary after the first failure-store await.

If there are multiple materially distinct internal awaits, cover each distinct
access pattern.

Do not merely assert the final thrown exception.

---

# 9. Add fresh-prerequisite-during-internal-await tests

While an evaluator-internal await is blocked, change at least:

- Contacts availability/evidence; and
- one other command-relevant prerequisite such as FDA/source/lifecycle evidence.

After releasing the await, assert the admitted report reflects the **new**
prerequisite value or fails closed for revision change.

The test must prove no stale pre-await snapshot is returned.

Use deterministic barriers, not sleeps.

---

# 10. Correct BLOCKER 2 — critical Journey tests must use the real global feedback loop

The critical self-maintenance fixture currently overrides:

`onboardingEnvironmentReportProvider`

with a mutable report source that does not observe the real archive lock.

For the end-to-end self-maintenance tests, that override is prohibited.

Build a production-realistic fixture/path in which:

```text
real ArchiveMutationCoordinator acquires Ball
-> real archive state publishes isLocked=true
-> real onboardingEnvironmentReportProvider observes it
-> real evaluator publishes maintenanceInProgress
-> Journey listener ingests maintenance into _latestReport
-> admitted callback uses owner-scoped complete evidence
-> exact command predicate decides begin/resume/reset
```

It is acceptable to override **underlying prerequisite dependencies** such as
FDA/Contacts/source stores with deterministic fakes.

It is not acceptable to override away the global Environment provider itself in
tests claiming to prove the original self-maintenance loop.

---

# 11. Prove the production loop happened inside each critical positive test

For critical positive cases, assert more than eventual success.

The test must establish that, while the command owns the real Ball:

- the real global Environment provider emitted `maintenanceInProgress`;
- Journey ingested or otherwise demonstrably observed that aggregate maintenance
  during the active command;
- the command still reached its exact side-effect boundary because fresh
  admitted evidence remained semantically valid.

At minimum prove this for:

1. initial import;
2. reimport;
3. Continue Setup;
4. automatic recovery.

These tests should fail against the pre-Prompt-18 capability-free command path
because `_latestReport` would become maintenance before its final global-report
predicate.

If practical, add one focused regression assertion demonstrating that the
legacy global-report-only final check would reject under the fixture. Do not
reintroduce production legacy code merely to test it.

---

# 12. Preserve hostile negative tests under the real loop

Under the same production-realistic fixture, retain deterministic proofs that:

- foreign Ball prevents callback;
- FDA withdrawal after admission prevents begin;
- Contacts withdrawal prevents begin/resume;
- semantic supersession blocks initial import/reimport;
- continuation supersession blocks resume;
- automatic reset withdrawal blocks begin/reset;
- wrong/stale capability fails;
- Ball 1 retained callback cannot act while Ball 2 is live.

Do not let the global-provider realism make these tests pass for the wrong
reason.

Each claimed boundary should isolate its intended rejection condition.

---

# 13. Specifically prove retained Ball 1 through the admitted reader

Prompt 19 noted that Feature 35 proves generic stale Ball behavior, but this
Onboarding integration seam should prove it too.

Add or strengthen a test:

```text
Ball 1 admitted
-> retain callback/continuation in Ball 1 Zone
-> Ball 1 releases
-> Ball 2 becomes live
-> old Ball 1 continuation attempts admitted Environment read
-> admitted read fails before protected probe
-> Ball 2 remains unchanged
```

Assert no protected Environment probe occurs under stale Ball 1.

---

# 14. Correct architecture SHOULD FIX 1 — replace brittle order/count claims where material

The architecture test currently remains green while both blockers exist.

Strengthen it so it mechanically protects the corrected structures.

Use analyzer AST / structured source analysis already available in the repo
where practical.

At minimum enforce:

## Admitted reader

- exact capability + typed operation parameters;
- the admitted path cannot call protected async evidence operations without the
  approved admission checkpoint structure;
- material awaits are followed by revalidation before later protected probes;
- current prerequisite inputs are refreshed/revision-checked after the final
  material await.

## Command boundaries

- four protected command paths use `runWithCapability`;
- no capability-free `.run` path for these commands;
- no await between the final command semantic conjunction and
  `begin`/`resume`/`resetDerivedData`.

## Test realism

- critical self-maintenance tests may not override
  `onboardingEnvironmentReportProvider`;
- critical fixtures must use the real archive coordinator/registry;
- critical tests must assert real aggregate maintenance publication.

Do not rely only on counting current literal spellings.

---

# 15. Correct architecture SHOULD FIX 2 — close the accumulated semantic census gaps

Prompt 19 reconfirmed two earlier architecture-test omissions.

Correct both in this task.

## Semantic root discovery

A production source consuming `OnboardingStatus` alone must count as a
user-visible Onboarding semantic consumer/root where the existing Journey-only
side-door policy expects such consumers.

Add a virtual/mutation case proving an `OnboardingStatus`-only consumer is
detected.

## Raw conversation-graph evidence

Include the raw conversation graph controller/barrel in the primary evidence
implementation/side-door census, not only the narrower intent-adapter set.

Add a virtual/mutation dependency path proving presentation/semantic code cannot
reach raw graph evidence outside the approved Journey authority boundary.

Use the same real census/policy helper as the repository audit.

---

# 16. Do not address OPTIONAL cleanup

Do not spend this task on:

- unused `onboardingJourneyAllowsCommandedTransition`;
- unused `_runAutomaticRecovery` report parameter;
- stale canonical Environment Readiness prose.

Leave those OPTIONAL unless one becomes mechanically necessary for the blocker
correction.

---

# 17. Preserve all Prompt 18 command semantics

Prompt 19 found no independent defect in:

- initial-import ordering/predicate;
- reimport ordering/predicate;
- continuation binding/UUID/session semantics;
- automatic recovery's two side-effect boundaries;
- maintenance-to-Journey mapping;
- presentation Journey-only;
- capability lifetime;
- persistence/restart behavior.

Do not redesign those areas.

The expected production correction is primarily within the admitted Environment
read.

If source inspection proves Journey production code must change, STOP AND REPORT
before broadening scope.

---

# 18. Expected file scope

## MUST change

1. `lib/essentials/onboarding/application/onboarding_environment_report_provider.dart`
2. `test/essentials/onboarding/application/onboarding_environment_report_provider_test.dart`
3. `test/essentials/onboarding/application/onboarding_journey_coordinator_provider_test.dart`
4. `test/architecture/onboarding_journey_authority_architecture_test.dart`

## MAY change only if the existing architecture census helper lives there

5. `test/architecture/forbidden_imports_test.dart`

## MUST NOT change

- `onboarding_journey_coordinator_provider.dart` unless a source-proven defect
  forces a stop/review;
- presentation;
- Journey state/action-context/projection/snapshot;
- snapshot codecs/schema;
- Feature 35 runtime;
- ArchiveMutationCoordinator/capability;
- archive policy;
- database schema;
- native locks;
- release metadata;
- unrelated Onboarding code.

---

# 19. Validation sequence

After correction run:

1. focused internal-await fail-closed Environment tests;
2. focused fresh-prerequisite-across-await tests;
3. complete Environment report test file;
4. focused real-global-feedback Journey tests;
5. complete Journey coordinator test file;
6. archive mutation coordinator tests;
7. generic Feature 35 registry tests;
8. Feature 35 architecture tests;
9. Onboarding Journey authority architecture tests;
10. related Onboarding authority/snapshot architecture tests;
11. complete architecture suite;
12. `flutter analyze --no-pub`;
13. complete `flutter test --reporter compact`;
14. `git diff --check`;
15. formatting/generated consistency if applicable.

Record exact counts.

Do not launch GUI qualification.

---

# 20. Project Conformance audit

Audit the complete accumulated Onboarding correction delta again.

Require explicit PASS for:

- one Journey semantic authority;
- Journey-only presentation;
- no raw-evidence side doors;
- admitted reader is evidence only;
- one shared Environment evaluator/policy;
- fail-closed proof/resource checks after every material await;
- current prerequisite truth at admitted-read return;
- real production self-maintenance loop proven by tests;
- no Boolean ownership regression;
- capability remains callback-local;
- command-specific semantics unchanged;
- maintenance cannot manufacture Normal;
- persistence/restart unchanged;
- Feature 35 boundary unchanged;
- semantic-root/evidence census complete;
- no privacy/data-safety regression.

Require:

`PROJECT CONFORMANCE: PASS`

with:

- BLOCKER: 0
- SHOULD FIX: 0

---

# 21. Preserve implementation evidence and scope

Compare against the fresh Prompt 20 baseline manifest.

Report:

- exact changed paths during Prompt 20;
- whether every change is authorized;
- whether any pre-existing unrelated untracked file changed;
- whether any preservation artifact changed;
- shared-submodule state.

Restore only unquestionably tool-generated unrelated churn if needed. Otherwise
STOP AND REPORT on scope drift.

---

# 22. Leave unstaged and uncommitted

Even if all validation passes:

- do not stage;
- do not commit;
- do not push.

Repeat the human architectural review before checkpoint.

---

# 23. Required response

Create the next sequential response in the Feature 34 Onboarding responses
folder.

Report:

1. baseline/preservation verification;
2. exact internal evaluator await graph;
3. admitted-reader proof/resource bracketing correction;
4. fresh-prerequisite/currentness correction;
5. zero-post-withdrawal-probe tests;
6. prerequisite-change-during-await tests;
7. real global-feedback Journey fixture;
8. initial-import real-loop proof;
9. reimport real-loop proof;
10. continuation real-loop proof;
11. automatic-recovery real-loop proof;
12. retained Ball 1 admitted-reader proof;
13. negative race isolation;
14. architecture control-flow enforcement;
15. semantic-root census correction;
16. raw graph evidence census correction;
17. Environment test results;
18. Journey test results;
19. Feature 35/archive regression results;
20. architecture results;
21. analyzer result;
22. full Flutter-suite result;
23. diff/format/generated hygiene;
24. Project Conformance verdict;
25. BLOCKER findings;
26. SHOULD FIX findings;
27. exact Prompt 20 changed-file census;
28. baseline-manifest comparison;
29. preservation-artifact verification;
30. exact Git status;
31. stop gates encountered;
32. readiness for repeated human architectural review.

Conclude exactly:

`ONBOARDING TENURE CORRECTION BLOCKERS RESOLVED: YES / NO`

If YES, also conclude:

`READY TO REPEAT ONBOARDING HUMAN ARCHITECTURAL REVIEW: YES / NO`

Then STOP.
