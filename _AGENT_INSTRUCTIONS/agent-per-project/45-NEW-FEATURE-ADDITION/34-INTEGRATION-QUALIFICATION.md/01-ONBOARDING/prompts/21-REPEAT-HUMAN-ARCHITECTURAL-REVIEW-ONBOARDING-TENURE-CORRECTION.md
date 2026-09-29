# MessageLens Feature 34 / Feature 35
## 21 — Repeat Human Architectural Review of Onboarding Tenure Correction

Prompt 20 reports that both Prompt 19 BLOCKER findings and both SHOULD FIX findings are resolved.

This task is a **read-only repeated architectural review before checkpoint**.

Do NOT modify production code.
Do NOT modify tests.
Do NOT regenerate code.
Do NOT stage or commit.
Do NOT push.
Do NOT launch MessageLens Development.
Do NOT access real databases or attachment archives.

Review the actual current accumulated Onboarding diff.

Governing invariants:

> **Evidence may be distributed. Journey authority may not be.**

> **The Ball proves exclusive tenure. Domain capability proves what the current owner may do while holding that Ball. Diagnostics prove neither.**

> **No protected read may occur after capability/resource authority becomes stale, and returned admitted Environment facts must be current after the final material await.**

---

# 1. Read the governing records

Read in full:

- `19-HUMAN-ARCHITECTURAL-REVIEW-ONBOARDING-TENURE-CORRECTION.md`
- `20-CORRECT-ONBOARDING-TENURE-REVIEW-FINDINGS.md`
- `18-IMPLEMENT-MINIMAL-ONBOARDING-TENURE-CORRECTION.md`
- `17-DESIGN-MINIMAL-ONBOARDING-TENURE-CORRECTION.md`
- the complete current accumulated Onboarding implementation delta;
- relevant Feature 35 authority/audit records.

Inspect especially:

- `onboarding_environment_report_provider.dart`
- `onboarding_environment_report_provider_test.dart`
- `onboarding_journey_coordinator_provider_test.dart`
- `onboarding_journey_authority_architecture_test.dart`

Also spot-check `onboarding_journey_coordinator_provider.dart` to confirm Prompt 20 did not alter its previously accepted production command semantics.

---

# 2. Baseline and preservation gate

Verify:

- branch: `fix/onboarding-import-stuck-state`;
- HEAD: `276fa1b820b07bf14f41fe216192456b5415e290`;
- index: empty;
- accumulated tracked delta: 48 modified / 2 deleted;
- shared submodule clean at `95326f515ef4719f155ce6e223990398daad6311`;
- `git diff --check` passes.

Verify Prompt 20 changed only:

1. `lib/essentials/onboarding/application/onboarding_environment_report_provider.dart`
2. `test/essentials/onboarding/application/onboarding_environment_report_provider_test.dart`
3. `test/essentials/onboarding/application/onboarding_journey_coordinator_provider_test.dart`
4. `test/architecture/onboarding_journey_authority_architecture_test.dart`
5. the Prompt 20 response record.

Recheck the Prompt 20 baseline manifest:

`/private/tmp/messagelens-onboarding-prompt20-baseline.Mipyuy/MANIFEST.json`

SHA-256:

`6472a83f43a3d1e6bf621291bdd925aa0fcbbd69af61823f93fa292e14a6f20d`

and the prior preservation manifests.

If unrelated bytes changed, STOP AND REPORT.

---

# 3. Re-review the admitted Environment read await graph

Inspect the exact current implementation.

Confirm async evidence acquisition is separated from synchronous evaluation.

Enumerate every material await in the admitted path.

At minimum inspect:

- attachment-location resolution;
- Contacts resolution;
- source-import failure read;
- graph-projection failure read;
- any other awaited evidence acquisition.

For each await, prove mechanically:

```text
admission current
-> start/read awaited evidence
-> await completes
-> admission revalidated
-> only then may any next protected read/probe occur
```

There must be no path where:

```text
proof/resource becomes invalid
-> await completes
-> later protected read/probe executes
-> rejection occurs only afterward
```

Any such path is a BLOCKER.

---

# 4. Review `_readMaterialOnboardingEvidence`

Inspect this helper closely.

Confirm:

- the admission callback is invoked before the supplied material read;
- the supplied read does not perform hidden unguarded protected follow-up work after returning;
- admission is invoked immediately after the await;
- exceptions preserve fail-closed behavior;
- no next protected read can start until the post-await admission check succeeds.

Check whether the helper can be bypassed by any admitted-path async evidence read.

If another material await exists outside it, classify whether that is safe and why.

---

# 5. Review failure-store reads specifically

Prompt 19's concrete unsafe boundary was:

```text
await source failure read
-> authority withdrawn
-> graph failure read/probes still execute
```

Trace the corrected path and confirm:

- source failure read is guarded;
- post-source-read authority/resource revalidation occurs;
- graph failure read cannot start if that revalidation fails;
- graph failure read is separately guarded;
- no protected derived-store probe starts after either failed post-await check.

This exact sequence must now be mechanically impossible.

---

# 6. Review current prerequisite freshness at return

Prompt 20 reports that mutable prerequisite facts are read after all material async evidence has settled.

Inspect exactly when these facts are read:

- FDA;
- Contacts current state/aggregate evidence;
- attachment location;
- source paths/data root;
- maintenance;
- dev overrides;
- graph/live-update state;
- probe reader;
- any command-relevant source/history/reset-driving values.

Confirm the admitted report cannot return a value captured before the last material await for a fact that can change during that await.

If any such fact remains snapshotted early without a revision check, classify it as a BLOCKER.

---

# 7. Review shared evaluator reuse

Confirm there is still exactly one readiness/reset/reconciliation evaluator.

The ordinary global path and the admitted path must share:

- the same input model;
- the same synchronous classification/evaluation policy.

No second policy evaluator may have appeared.

Confirm the evaluator is now synchronous for the admitted/currentness boundary claimed by Prompt 20.

If hidden awaits remain inside evaluation, inspect them under sections 3–5.

---

# 8. Review capability and resource admission as independent proof

Confirm the admission callback still independently proves:

- exact `ArchiveMutationCapability.requireOperation(expectedOperation)`;
- current-caller conversation-graph connection admission;
- current-caller persistent archive-store admission.

No diagnostic Boolean may substitute for capability.

No capability may substitute for resource policy.

No resource `unrestricted` result may substitute for exact ownership.

Any collapse is a BLOCKER.

---

# 9. Review zero-post-withdrawal-probe tests

Inspect the new deterministic recording tests.

Confirm they prove more than eventual exception.

For capability withdrawal during the first failure-store await:

- block the await;
- withdraw/release capability;
- release barrier;
- assert the Future fails;
- assert graph-failure read count remains zero;
- assert every later protected database/probe count remains zero.

For stronger resource denial during that await:

- same structure;
- assert zero later protected reads/probes.

The recording assertions must correspond to the actual production probe points, not a fake layer that can stay zero while production code still reads.

---

# 10. Review fresh-prerequisite-during-await tests

Inspect the Contacts and FDA tests.

Confirm:

- the internal await is genuinely in progress;
- the prerequisite changes while suspended;
- the post-await report reflects the new current value;
- no cached pre-await report/value is reused.

If the test changes a fake that is not the same source the production admitted reader re-reads, it is insufficient.

---

# 11. Review retained Ball 1 admitted-reader proof

Trace the integration test:

```text
Ball 1 admitted
-> retained callback/Zone
-> Ball 1 releases
-> Ball 2 acquired/live
-> old Ball 1 continuation calls admitted Environment read
```

Confirm:

- admitted read fails before any protected probe;
- Ball 2 identity/hold count/operation remain unchanged;
- failure is caused by stale Ball 1 proof, not a different unrelated blocker.

This should prove the Onboarding admitted-read seam, not merely restate Feature 35's generic primitive test.

---

# 12. Review the production-realistic global Environment fixture

Inspect the critical Journey fixture mode.

Confirm it does **not** override `onboardingEnvironmentReportProvider`.

It may override deterministic underlying evidence dependencies, but the path must remain:

```text
real ArchiveMutationCoordinator
-> real isLocked publication
-> real onboardingEnvironmentReportProvider
-> real maintenanceInProgress report
-> Journey listener
-> _latestReport
```

Confirm no test-only bypass supplies maintenance directly to Journey.

---

# 13. Review real-loop positive proofs for all four commands

For each of:

1. initial import;
2. reimport;
3. Continue Setup;
4. automatic recovery;

confirm the test proves all three:

A. real Ball became live;

B. real global Environment provider emitted `maintenanceInProgress` while that Ball was live;

C. command still reached its exact allowed side-effect boundary only because the admitted fresh report satisfied the command-specific predicate.

The test should demonstrate the original self-denial condition exists in the fixture.

If success would also occur without global maintenance ever reaching Journey, the test is not sufficient.

---

# 14. Review whether the tests would catch regression to the pre-Prompt-18 command path

Determine whether the critical real-loop tests would fail if the four commands were reverted to:

- capability-free `ArchiveMutationCoordinator.run`;
- final semantic check against aggregate `_latestReport`.

They should fail because `_latestReport` becomes maintenance before the final boundary.

If the fixture/test scheduling would allow the command to reach `begin` before maintenance is delivered, the test is not deterministic enough.

---

# 15. Review negative races under the real loop

Confirm the production-realistic fixture also isolates the intended reasons for:

- foreign Ball denial;
- FDA withdrawal;
- Contacts withdrawal;
- initial-import supersession;
- reimport supersession;
- continuation supersession;
- automatic reset withdrawal before begin;
- automatic reset withdrawal before reset side effect;
- wrong/stale capability;
- Ball 1 under Ball 2.

Look for tests passing due to aggregate maintenance alone instead of the intended negative condition.

---

# 16. Review architecture enforcement around admitted awaits

Inspect the new analyzer-AST enforcement.

Confirm it mechanically protects the actual corrected structure rather than only counting identifiers.

At minimum verify:

- all material async evidence reads in the admitted path are classified;
- each is structurally guarded by the approved admission helper/checkpoint;
- prerequisite current reads occur after the final material await;
- shared evaluator contains no hidden async boundary;
- a new unguarded material await would fail architecture validation.

Add no implementation in this review; report any concrete evasion.

---

# 17. Review command boundary AST enforcement

Confirm architecture tests prove:

- exactly four protected Journey command paths use `runWithCapability`;
- no capability-free `.run` reappears for those operations;
- final semantic conjunction is adjacent to `begin`, `resume`, or `resetDerivedData`;
- there is no intervening await.

Check whether harmless formatting/refactor would fail while an equivalent unsafe control-flow shape could pass.

Report only material brittleness.

---

# 18. Review critical-test realism architecture rule

Confirm the architecture test now prevents critical self-maintenance tests from:

- overriding `onboardingEnvironmentReportProvider`;
- replacing/subclassing the real archive coordinator/registry;
- omitting the asserted aggregate maintenance observation.

This rule must apply to the specific test group relied upon for the production loop proof.

A global prohibition that accidentally blocks unrelated legitimate unit fakes is not required.

---

# 19. Review semantic-root census correction

Inspect the corrected semantic consumer discovery.

Confirm a production source that consumes only `OnboardingStatus` is classified as an Onboarding semantic root/consumer where required.

Inspect the virtual mutation case and verify it uses the same census helper as the real repository audit.

The previous gap should be mechanically closed.

---

# 20. Review raw conversation-graph evidence census correction

Confirm the primary evidence/side-door census now includes:

- raw conversation graph controller;
- relevant barrel/export path.

Inspect the virtual mutation dependency path.

Confirm presentation or semantic code cannot reach raw graph evidence outside the approved Journey authority boundary without architecture failure.

---

# 21. Reconfirm Prompt 18 production semantics were not changed

Prompt 20 should not have modified `onboarding_journey_coordinator_provider.dart`.

Spot-check that the previously accepted command behavior still holds:

- pre-admission exact global predicate;
- capability admission;
- fresh admitted report;
- exact late command-specific predicate;
- immediate side-effect boundary;
- maintenance cannot manufacture Normal;
- no automatic resume.

Do not reopen already accepted design unless Prompt 20 unexpectedly changed it.

---

# 22. Accumulated delta / reuse / dead-code review

Audit the complete accumulated Onboarding correction delta again.

Look for:

- duplicated readiness policy;
- duplicate authority;
- obsolete pre-Feature-35 maintenance workaround;
- critical tests still using the old immediate fake;
- stale helpers/imports created by Prompt 20 refactor;
- unreachable async branches;
- documentation or architecture tests contradicting current mechanics.

Do not perform aesthetic cleanup.

Classify concrete findings only.

---

# 23. Persistence / migration / restart

Reconfirm:

- schema migration: none;
- persisted snapshot migration: none;
- existing operation records readable;
- startup reconciliation unchanged;
- ordinary interrupted import remains explicit Continue Setup;
- no capability/tenure serialization;
- no presentation changes.

---

# 24. Validation evidence

Prompt 20 reports:

- internal-await fail-closed: 2 passed;
- fresh-prerequisite-across-await: 2 passed;
- retained Ball 1 admitted-reader: 1 passed;
- complete Environment report: 22 passed;
- real-global-feedback Journey positive group: 4 passed;
- complete Journey coordinator: 60 passed;
- archive coordinator: 17 passed;
- generic Feature 35 registry: 23 passed;
- Feature 35 architecture: 42 passed;
- Onboarding Journey authority architecture: 24 passed;
- related architecture: 11 + 6 + 7 passed;
- complete architecture: 553 passed;
- analyzer: clean;
- full Flutter suite: 2,729 passed / 0 failed / 1 skip;
- `git diff --check`: PASS;
- Project Conformance: PASS;
- BLOCKER: 0;
- SHOULD FIX: 0.

Do not rerun the full suite for ceremony.

Run narrow tests only if source inspection exposes a specific unresolved question.

---

# 25. Required response

Create the next sequential response in the Feature 34 Onboarding responses folder.

Report:

1. baseline/preservation verdict;
2. material-await graph verdict;
3. `_readMaterialOnboardingEvidence` verdict;
4. failure-store fail-closed verdict;
5. prerequisite-freshness verdict;
6. shared-evaluator verdict;
7. capability/resource-proof verdict;
8. zero-post-withdrawal-probe test verdict;
9. prerequisite-change-during-await test verdict;
10. retained Ball 1 admitted-reader verdict;
11. real global-feedback fixture verdict;
12. initial-import real-loop verdict;
13. reimport real-loop verdict;
14. continuation real-loop verdict;
15. automatic-recovery real-loop verdict;
16. negative-race isolation verdict;
17. admitted-await architecture verdict;
18. command-boundary architecture verdict;
19. test-realism architecture verdict;
20. semantic-root census verdict;
21. raw graph evidence census verdict;
22. Prompt 18 production-semantics regression verdict;
23. accumulated-delta/reuse/dead-code verdict;
24. persistence/migration/restart verdict;
25. concrete BLOCKER findings;
26. concrete SHOULD FIX findings;
27. OPTIONAL findings;
28. narrow tests rerun, if any;
29. exact Git status;
30. preservation-artifact verification;
31. checkpoint recommendation.

Use:

- BLOCKER
- SHOULD FIX
- OPTIONAL
- NO ISSUE

Do not modify implementation.

Conclude exactly:

`REPEATED ONBOARDING TENURE CORRECTION HUMAN REVIEW: PASS / FAIL`

If PASS, also conclude:

`SAFE TO CHECKPOINT ONBOARDING TENURE CORRECTION: YES / NO`

Then STOP.
