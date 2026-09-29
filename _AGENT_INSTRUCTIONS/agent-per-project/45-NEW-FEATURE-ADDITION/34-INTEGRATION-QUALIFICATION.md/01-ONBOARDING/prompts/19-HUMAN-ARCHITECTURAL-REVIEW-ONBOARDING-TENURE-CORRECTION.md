# MessageLens Feature 34 / Feature 35
## 19 — Human Architectural Review of Minimal Onboarding Tenure Correction

Prompt 18 reports that the minimal Onboarding tenure correction is implemented,
fully validated, Project-Conformance clean, and still unstaged/uncommitted.

This task is a **read-only human architectural review before checkpoint**.

Do NOT modify production code.
Do NOT modify tests.
Do NOT regenerate code.
Do NOT stage or commit.
Do NOT push.
Do NOT launch MessageLens Development.
Do NOT access real databases or attachment archives.

Review the actual current accumulated Onboarding diff, not only the Prompt 18
summary.

The two governing invariants remain:

> **Evidence may be distributed. Journey authority may not be.**

> **The Ball proves exclusive tenure. Domain capability proves what the current
> owner may do while holding that Ball. Diagnostics prove neither.**

And the critical corrected rule is:

> **Self-owned maintenance may not deny the command solely because that exact
> command owns the Ball, but Ball ownership never substitutes for fresh
> command-specific prerequisite truth.**

---

# 1. Read the governing records

Read in full:

- `17-DESIGN-MINIMAL-ONBOARDING-TENURE-CORRECTION.md`;
- `18-IMPLEMENT-MINIMAL-ONBOARDING-TENURE-CORRECTION.md`;
- `01-FORENSIC-ANALYSIS-OF-ONBOARDING-FAILURE.md`;
- `02-NECESSARY-CORRECTIONS-TO-ONBOARDING.md`;
- the latest prior human architectural reviews of the Onboarding authority
  correction;
- Feature 35 authority audit/final validation records relevant to tenure,
  capability, and current-caller admission;
- the complete current accumulated Onboarding implementation delta.

Inspect especially:

- `onboarding_environment_report_provider.dart`;
- `onboarding_journey_coordinator_provider.dart`;
- their complete tests;
- `onboarding_journey_authority_architecture_test.dart`;
- all current helper types/functions added or refactored by Prompt 18.

---

# 2. Baseline and preservation gate

Verify:

- branch:
  `fix/onboarding-import-stuck-state`;
- HEAD:
  `276fa1b820b07bf14f41fe216192456b5415e290`;
- index:
  empty;
- accumulated tracked delta:
  48 modified / 2 deleted;
- Prompt 18 changed exactly the reported five authorized paths;
- shared-instructions submodule:
  clean at `95326f515ef4719f155ce6e223990398daad6311`;
- `git diff --check` passes.

Recheck the Prompt 18 baseline manifest and the three preserved reconstruction
manifests/hashes.

If unrelated bytes changed after Prompt 18, STOP AND REPORT.

---

# 3. Review the admitted Environment evidence seam as evidence, not authority

Inspect the new admitted-caller reader.

Confirm mechanically that it:

- is a plain internal one-shot read, not a provider-held cache;
- cannot publish Journey state;
- cannot publish or overwrite the global Environment report;
- is not exported through the public Onboarding barrel;
- requires an exact `ArchiveMutationCapability`;
- requires an exact typed `ArchiveMutationOperation`;
- reuses the same evaluator/readiness policy as the ordinary Environment
  provider;
- recomputes current facts rather than replaying a pre-maintenance report.

The seam must answer only:

> **What are the complete current Environment facts for this already-admitted
> caller?**

It must not answer:

> **Should Journey transition?**

That latter decision remains Journey-only.

Report any readiness/reset/reconciliation policy copied into Journey or duplicated
inside the admitted reader.

---

# 4. Review capability proof and resource-policy proof as two separate conjuncts

Trace the admitted reader from entry to return.

Confirm that exact capability proof is required before protected reads and
revalidated after awaits.

Also confirm that current-caller resource admission is checked independently for
every resource whose ordinary global evaluator suppresses under maintenance.

The architecture must preserve:

```text
exact capability
AND
current archive resource admission
AND
fresh Environment facts
AND
current Journey command semantics
```

No one term may substitute for another.

Specifically inspect whether:

- `resourceAdmissionForCurrentCaller(...).unrestricted`;
- `.isLocked`;
- owner labels;
- occurrence numbers;
- registry diagnostics;

can accidentally be treated as ownership proof.

Any such substitution is a BLOCKER.

---

# 5. Review whether the admitted read is genuinely current after every await

Prompt 18 reports checks:

- before work;
- after attachment-location resolution;
- after Contacts resolution;
- after evaluator completion.

Inspect the actual await graph.

Confirm there is no await between the final capability/resource/currentness
revalidation and return that could make the returned report stale before Journey
consumes it.

If the evaluator itself performs multiple awaits, verify the proof/resource
checks bracket the relevant protected operations rather than merely checking at
the beginning and end while an unsafe read happens in between.

Determine whether a capability/resource-policy change during each material await
fails closed.

---

# 6. Review the global Environment provider for semantic drift

Confirm the ordinary `onboardingEnvironmentReportProvider` still:

- remains owner-agnostic;
- reports aggregate maintenance for unrelated observers;
- suppresses protected derived-store reads during aggregate maintenance;
- remains the source of global evidence revision/currentness;
- has not become caller-relative;
- has not acquired a capability/tenure dependency.

The owner-scoped admitted report must never be stored in `_latestReport`.

Inspect for any accidental assignment, provider write, shared cache mutation, or
reuse that could leak the caller-relative result to another consumer.

---

# 7. Review initial-import correction

Trace the exact final initial-import path.

Require:

1. current Journey action/context/token check;
2. complete positive global pre-admission handoff check;
3. no await between that positive handoff and archive admission;
4. `runWithCapability(onboardingImport)`;
5. controller acquisition;
6. fresh admitted Environment read;
7. post-await capability/resource proof;
8. current Journey action/token check;
9. unchanged exact initial-import predicate applied to admitted report;
10. immediate `controller.begin(initialImport)` with no intervening await.

Verify that:

- self-maintenance alone cannot reject;
- `ready`, FDA withdrawal, Contacts/source withdrawal, stale action, or foreign
  Ball still rejects;
- rejected initial import mints no operation UUID.

---

# 8. Review reimport correction

Apply the same analysis to reimport.

Confirm a valid self-owned `ready` state starts exactly one reimport.

Confirm any current state not authorized by the existing reimport predicate
still blocks it even while the command owns the Ball.

Verify no generic “self maintenance allowed” Boolean replaced the exact reimport
semantic predicate.

---

# 9. Review Continue Setup correction

Trace the exact resumed-operation path.

Confirm all of these remain current immediately before `resume`:

- Journey action context;
- active command token;
- exact retained binding;
- exact operation UUID;
- process session;
- interrupted status;
- exact capability;
- current admitted Environment report;
- resumability/reconciliation semantics.

There must be no await after the final semantic/binding conjunction and before
`controller.resume(operationId)`.

Confirm:

- same UUID resumes;
- superseding `ready` state prevents resume;
- Contacts/FDA blocker prevents resume;
- ordinary interrupted import remains explicit Continue Setup;
- no automatic resume path was introduced.

---

# 10. Review automatic recovery at both late boundaries

Automatic recovery is the highest-risk path because it has two distinct
side-effect boundaries.

Inspect separately:

## Before `controller.begin(automaticRecovery)`

Require fresh admitted evidence and exact reset-required semantics immediately
before begin.

## Before `resetDerivedData()`

After stage/progress persistence awaits, require:

- bound operation current;
- action/token current where relevant;
- capability current;
- current-caller resource admission current;
- fresh admitted report;
- `shouldResetAppDatabasesBeforeImport == true`;
- immediate reset with no intervening await.

Confirm that starting automatic recovery does not itself freeze the reset
decision.

If the reset requirement disappears after begin, no reset side effect may occur.

---

# 11. Review maintenance-to-Journey mapping correction

Prompt 18 changed aggregate maintenance semantics so it no longer independently
constructs `OnboardingNormalApplication`.

Inspect the actual mapping.

Confirm:

- cold reconstruction + maintenance-only evidence -> Checking;
- active command -> retain current authorized Episode;
- established semantic state under maintenance-only evidence -> retain that
  semantic state rather than inventing Normal;
- hard blockers that outrank maintenance still transition appropriately;
- complete post-maintenance evidence may transition normally;
- no new Maintenance Episode exists;
- presentation still consumes Journey only.

Check carefully that “retain existing state” cannot preserve a stale command
semantic after a higher-priority external blocker is already known.

---

# 12. Review the four command predicates for semantic identity

Inspect whether Prompt 18 refactored predicates to accept explicit reports.

Confirm the following are still semantically distinct and unchanged except for
their report source:

- initial import;
- reimport;
- interrupted continuation;
- automatic recovery.

No shared helper may collapse them into a weaker aggregate predicate.

If the same helper is reused, inspect its parameters/branches and prove it does
not erase command-specific semantics.

---

# 13. Review Journey authority and presentation isolation

Confirm Prompt 18 did not reopen any of the side doors previously removed.

Production presentation must not consume:

- Environment report;
- archive capability;
- generic tenure;
- graph-controller state;
- operation snapshot raw state;
- maintenance diagnostics;

to choose Onboarding meaning.

Journey remains the sole user-visible semantic publisher.

Check both direct imports and transitive dependencies.

---

# 14. Review capability lifetime / escape

Search the complete production diff.

Confirm no `ArchiveMutationCapability` or `ExclusiveAuthorityTenure` is stored
in:

- a field;
- provider state;
- Journey state;
- action context;
- operation projection;
- operation snapshot;
- persistence;
- closure retained beyond the admitted callback;
- presentation.

The capability should remain callback-local and ephemeral.

If any longer-lived reference exists, inspect whether it can outlive scope
release. Treat unbounded escape as a BLOCKER.

---

# 15. Review real-authority hostile-race tests

Inspect the critical Journey tests.

Confirm they actually use:

- real `ExclusiveAuthorityRegistry`;
- real `ArchiveMutationCoordinator`;
- real lock publication;
- real private Zone/capability;
- deterministic Completer/barrier ordering.

The old immediate fake may exist only in unrelated tests.

Verify the reported self-maintenance tests would fail on the pre-Prompt-18
implementation.

If the test harness manually injects owner-scoped reports without passing
through the actual capability/reader path, the test is insufficient.

---

# 16. Review hostile-race coverage for exact mechanisms

Inspect at minimum these cases and ensure each isolates the claimed boundary:

1. self-owned initial import succeeds;
2. foreign Ball never enters callback;
3. stale capability fails;
4. FDA withdrawal after admission fails;
5. Contacts withdrawal fails;
6. initial-import semantic supersession fails;
7. reimport semantic supersession fails;
8. continuation supersession fails;
9. reset need withdrawn before begin fails;
10. reset need withdrawn after stage/progress fails;
11. wrong operation capability fails;
12. Ball 1 callback under live Ball 2 fails;
13. valid self-owned reimport succeeds once;
14. valid continuation resumes same UUID once;
15. valid automatic reset happens once;
16. proof/resource change during evidence-reader await fails closed;
17. hostile raw evidence cannot displace Journey presentation;
18. restart remains explicit Continue Setup.

Look for tests that pass for multiple reasons at once and therefore do not prove
the intended conjunct.

---

# 17. Review Environment reader tests

Confirm tests prove both sides:

## Global path

- aggregate maintenance remains visible;
- protected derived reads remain suppressed.

## Admitted path

- exact current capability allows complete evidence read;
- external prerequisite changes are freshly reflected;
- no cached report reuse;
- wrong/stale/outside-Zone capability fails;
- resource-policy denial fails;
- post-await proof/resource revalidation fails closed;
- admitted report is not globally published.

---

# 18. Review architecture tripwires for mechanical enforceability

Inspect `onboarding_journey_authority_architecture_test.dart`.

Confirm the new rules are not merely filename/name regexes that can be trivially
evaded.

At minimum mechanically enforce:

- exactly four protected command admissions use `runWithCapability`;
- capability-free `.run` cannot reappear for those commands;
- admitted evidence seam requires capability + typed operation;
- pre/post proof and resource checks exist around awaits;
- only Journey coordinator consumes admitted evidence;
- seam not exported publicly;
- global provider remains owner-agnostic;
- no tenure/capability in persisted/Journey value types;
- no presentation import path;
- no diagnostic/Boolean ownership proof;
- maintenance cannot synthesize Normal;
- last semantic checks remain immediately before begin/resume/reset;
- critical race tests use real Feature 35 infrastructure.

Report any materially brittle enforcement that could permit regression while
tests stay green.

---

# 19. Review file scope and accumulated architecture delta

Prompt 18 reports exactly five authorized changed files.

Confirm this from Git and compare against the Prompt 18 baseline manifest.

Also audit the **complete accumulated Onboarding repair delta**, because this is
the pre-checkpoint architectural gate.

Look for:

- duplicated authority logic;
- stale/dead pre-Feature-35 helpers;
- old immediate fake accidentally used in critical proof;
- obsolete maintenance special cases;
- copied readiness logic;
- unreferenced code;
- imports/dependencies no longer needed;
- documentation contradictions.

Do not perform aesthetic refactoring.

Classify concrete findings only.

---

# 20. Persistence / migration / restart verification

Confirm:

- schema migration: none;
- persisted snapshot migration: none;
- old operation records remain readable;
- startup reconciliation semantics unchanged;
- ordinary interrupted import does not auto-resume;
- no capability/tenure serialization exists.

---

# 21. Validation evidence review

Prompt 18 reports:

- focused late-bound races: 10 passed;
- admitted Environment evidence: 7 passed;
- complete Environment report: 19 passed;
- Journey coordinator: 56 passed;
- archive coordinator: 17 passed;
- generic Feature 35 registry: 23 passed;
- Feature 35 architecture: 42 passed;
- Onboarding Journey authority architecture: 22 passed;
- related Onboarding architecture: 18 passed;
- complete architecture: 551 passed;
- analyzer: 0 issues;
- full Flutter suite: 2,720 passed / 0 failed / 1 skipped;
- `git diff --check`: PASS;
- Project Conformance: PASS;
- BLOCKER: 0;
- SHOULD FIX: 0.

Do not rerun the full suite merely for ceremony.

Run narrow tests only if source inspection exposes a specific unresolved
question.

---

# 22. Required response

Create the next sequential response in the Feature 34 Onboarding responses
folder.

Report:

1. baseline/preservation verdict;
2. admitted Environment evidence verdict;
3. capability/resource-proof verdict;
4. global Environment semantics verdict;
5. initial-import verdict;
6. reimport verdict;
7. continuation verdict;
8. automatic-recovery verdict;
9. maintenance-to-Journey mapping verdict;
10. command-predicate semantic-identity verdict;
11. Journey/presentation authority verdict;
12. capability-lifetime verdict;
13. real-authority test-harness verdict;
14. hostile-race test-quality verdict;
15. Environment-reader test-quality verdict;
16. architecture-tripwire verdict;
17. accumulated-delta/reuse/dead-code verdict;
18. persistence/migration/restart verdict;
19. concrete BLOCKER findings;
20. concrete SHOULD FIX findings;
21. OPTIONAL findings;
22. narrow tests rerun, if any;
23. exact current Git status;
24. preservation-artifact verification;
25. checkpoint recommendation.

Use:

- BLOCKER
- SHOULD FIX
- OPTIONAL
- NO ISSUE

Do not modify implementation.

Conclude exactly:

`ONBOARDING TENURE CORRECTION HUMAN ARCHITECTURAL REVIEW: PASS / FAIL`

If PASS, also conclude:

`SAFE TO CHECKPOINT ONBOARDING TENURE CORRECTION: YES / NO`

Then STOP.
