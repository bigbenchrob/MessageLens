# MessageLens Feature 34
## 59 — Implement a Fair-Witness Attachment-Coverage Fact

Response 58 correctly stopped Operating Session Stage Two before implementation.

Stage One is now safely checkpointed and pushed at:

- branch: `fix/onboarding-import-stuck-state`
- HEAD/upstream:
  `85dba83aa36a9d92ed74ddd68fe03c5548190c7f`
- Stage One implementation:
  `76357e1e8a4f625290e159bc6f13aea39c97fd34`
- Stage One documentation/recovery anchor:
  `85dba83aa36a9d92ed74ddd68fe03c5548190c7f`

The blocking architectural fact is precise:

```text
graph/import commit
-> messageDataVersion advances
-> attachment preservation runs afterward
```

If attachment preservation then fails, defers, or becomes ambiguous, a later
fresh AppCzar can currently observe:

```text
source current
import current
graph current
archive root available
```

but cannot independently prove whether the attachment payloads required by that
current graph were completely preserved.

A persisted statement such as:

```text
last update failed
```

or:

```text
attachment preservation incomplete
```

would be exactly the historical semantic conclusion the AppCzar architecture is
intended to eliminate.

The required correction is therefore not another operation status flag.

It is a **current, independently reconstructible attachment-coverage fact**.

This task implements that fact and integrates it into AppCzar admission.

Do NOT implement Operating-owned live currentness yet.
Do NOT make Attachment Archive Repair executable yet.
Do NOT add a remembered update-success/failure flag.
Do NOT reorder graph/import mutation speculatively.
Do NOT route production startup through AppCzar.
Do NOT stage, commit, push, merge, or rebase before qualification.

---

# 1. Baseline

Worktree:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Require:

- branch:
  `fix/onboarding-import-stuck-state`
- HEAD/upstream:
  `85dba83aa36a9d92ed74ddd68fe03c5548190c7f`
- tracked worktree clean;
- index clean;
- shared-instructions submodule clean at:
  `95326f515ef4719f155ce6e223990398daad6311`.

Read:

- Response 54;
- Response 55;
- Response 57;
- Response 58;
- the existing attachment archive/adoption/relocation architecture;
- canonical Project Conformance standard.

Create a fresh external baseline manifest.

---

# 2. First establish the exact preservation contract

Before editing, source-trace the current attachment preservation model.

Answer from code, not assumption:

1. What exact attachment universe does `LiveGraphUpdateWorker` attempt to preserve?
2. How is that universe derived from:
   - imported source-row range;
   - graph rows;
   - source attachment metadata;
   - archive-relative paths;
   - archive identity/generation?
3. Which attachments are:
   - preservation-required;
   - already preserved;
   - legitimately not preservation-required;
   - temporarily unavailable/deferred;
   - permanently unresolvable;
   - failed?
4. What durable records currently exist for archived payloads?
5. Can those records be verified against current archive files?
6. What does `skipped` mean in every path that contributes to the aggregate result?
7. Can `skipped` currently conflate:
   - already archived;
   - no metadata;
   - missing source payload;
   - explicit ingestion failure;
   - other conditions?
8. Which of those distinctions are already durable facts and which exist only in one worker result?
9. What exact current graph/source range is the archive expected to cover?
10. Does archive generation/identity already scope those facts sufficiently?

Do not implement until this audit yields an exact definition of:

> **Required attachment coverage for the current admitted local dataset.**

If no exact required set can be derived from current durable/current source facts without inventing historical intent, STOP AND REPORT.

---

# 3. Fair-Witness definition

The new fact must answer only:

> **For the currently admitted local dataset and attachment-archive identity,
> can MessageLens currently prove that every attachment payload which the
> archive contract requires to be preserved is represented by valid durable
> archive evidence?**

This is not:

- “the last attachment job succeeded”;
- “the previous Data Update completed”;
- “there were no attachment errors”;
- “the archive was healthy last time.”

Required truth values:

```text
TRUE
    current required attachment set is known
    and current durable archive evidence covers it completely

FALSE
    current required attachment set is known
    and one or more required items are provably not covered

UNKNOWN
    MessageLens cannot currently establish either complete or incomplete
    coverage from available evidence
```

UNKNOWN must never be silently treated as complete.

---

# 4. Prefer current object-level facts, not operation-level conclusions

Reuse existing durable attachment/archive records if they are sufficient.

If additional durability is required, it may record only **object-level facts**
that can later be independently verified, for example:

- stable attachment/source identity;
- archive-relative destination;
- archive generation/instance identity;
- payload size;
- content hash if already part of the preservation contract;
- another immutable payload identity already used by the archive.

Do NOT persist fields such as:

- updateSucceeded;
- preservationComplete;
- lastRepairSucceeded;
- operationReady;
- current=true;
- needsRepair=true.

A durable object record is acceptable only if a fresh process can verify the
record against current graph/source/archive reality.

Do not add a global status row.

---

# 5. Read-only attachment coverage probe

Implement the narrowest read-only probe necessary.

Conceptual result:

```text
AttachmentCoverageObservation
  condition:
    complete
    incomplete
    unknown

  requiredCount
  coveredCount
  missingCount
  unverifiableCount

  archiveIdentity/generation observed
  bounded diagnostic reason
```

Use actual project terminology if an existing model is more appropriate.

The probe must:

- be read-only;
- use the currently admitted archive identity/generation;
- avoid message/contact content;
- avoid copying payloads;
- avoid modifying archive metadata;
- fail closed on ambiguous evidence;
- be deterministic from the same current inputs;
- be suitable for AppCzar startup.

Do not perform expensive payload hashing on every startup unless the existing
archive contract already requires it and the audit proves it is necessary.

Prefer the cheapest evidence that literally proves the existing preservation
contract.

If proving the contract requires a bounded manifest/index read rather than a
recursive multi-gigabyte filesystem walk, use the existing fact source or
introduce the smallest factual index justified by the audit.

---

# 6. Performance is part of the contract

AppCzar startup must remain fast and visible.

Measure the expected/fixture complexity of the coverage probe.

The probe must not:

- recursively hash a ~39 GB archive at every launch;
- scan payload bytes unnecessarily;
- create startup work proportional to file size;
- silently defer a long verification after AppCzar has already admitted Operating.

Acceptable patterns include:

- indexed required-vs-covered identity comparison;
- metadata/path existence checks if that is the actual archive guarantee;
- versioned manifest lookup with bounded verification;
- incremental factual index maintained by the preservation worker and verified independently.

Any introduced index must contain facts, not semantic conclusions.

Report complexity and expected startup cost.

---

# 7. Integrate coverage into the AppCzar fact DAG

Keep archive **availability** separate from archive **coverage**.

The current fact:

`attachmentArchiveAvailable`

must not be overloaded to mean coverage complete.

Introduce the smallest facts required, conceptually:

```text
attachmentCoverageKnown
attachmentCoverageComplete
```

or one equivalent tri-state proposition if that better fits the current model.

Required selection semantics:

```text
archive unavailable
    -> existing Attachment Archive Repair disposition

archive coverage FALSE
    -> Attachment Archive Repair disposition

archive coverage UNKNOWN
    -> Diagnostic Review / insufficient evidence

archive coverage TRUE
    -> continue evaluating downstream facts
```

Attachment Archive Repair remains **virtual** in this task.

Do not make it executable.

---

# 8. Operating admission must require coverage

A fresh AppCzar may select Operating Session only if current attachment coverage
is conclusively complete.

Required invariant:

```text
Operating
    implies
attachment coverage == TRUE
```

This must hold even when:

- source/import/graph counts are equal;
- source/local high-waters are equal;
- archive root is available;
- a prior worker returned normally;
- a prior worker failed after graph mutation.

No historical operation result may participate.

---

# 9. Data Update post-failure reconstructibility test

Add the critical regression that Response 58 said the current model cannot pass.

Using fixtures/temp archives only:

```text
1. begin from healthy current durable state
2. advance source
3. allow graph/import mutation for the delta to commit
4. cause required attachment preservation to fail or remain incomplete
5. destroy the process/provider container
6. construct a completely fresh AppCzar assessment
   using only durable/current facts
7. expect:
      source/import/graph may be current
      archive root may be available
      attachment coverage != TRUE
      Operating Session is NOT selected
```

This test is the architectural acceptance criterion.

No injected "previous operation failed" value may be supplied to the fresh assessment.

---

# 10. Coverage must recover from reality, not a flag

Add the reciprocal test:

```text
1. begin from the durable incomplete state above
2. supply/restore the required archive payload/evidence through the existing
   supported preservation mechanism or fixture equivalent
3. create another fresh process/container
4. observe current coverage again
5. expect attachment coverage TRUE
6. if all other current facts agree, Operating may be selected
```

No failure flag needs clearing.

This is the self-healing property.

---

# 11. Current archive already healthy

Verify against isolated fixtures that a fully covered archive projects:

```text
Attachment coverage
Complete — N of N required payloads covered
```

or equally literal wording.

For zero required attachments, define and test the exact semantics. Normally:

```text
requiredCount = 0
coveredCount = 0
coverage = TRUE
```

is logically valid if the preservation contract truly has no required items.

Do not assume; establish from code.

---

# 12. Incomplete and UNKNOWN presentation

Use Fair-Witness copy.

Examples:

## Incomplete

```text
Attachment coverage
Incomplete — 2 required payloads are not covered
```

## UNKNOWN

```text
Attachment coverage
Could not be established
```

with a literal bounded reason.

Do not say:

- archive corrupt;
- update failed;
- attachments lost;

unless current evidence literally proves those propositions.

Do not show private filenames by default if that creates unnecessary privacy exposure. Counts and diagnostic-safe identities are sufficient.

---

# 13. Preserve archive mutation authority

The coverage probe is read-only and must not acquire the Ball.

The preservation worker continues to use the existing typed mutation authority.

If a new factual manifest/index is written during preservation, that write must:

- occur under the same admitted archive mutation tenure;
- be scoped to the same archive identity/generation;
- be atomic enough not to claim coverage for an uncommitted/missing payload;
- never outlive the worker's admitted mutation boundary.

Do not create a new mutation authority.

---

# 14. Crash ordering and atomicity

If new durable object-level evidence is introduced, explicitly prove crash-safe ordering.

The invariant must be:

```text
durable coverage evidence may never say "covered"
before the required archive payload is durably in the state that the archive
contract defines as preserved
```

A crash may leave:

- extra payload with no coverage record; or
- incomplete coverage evidence;

if those states are safely reconstructible.

A crash must not leave a false-positive covered record.

Use existing atomic rename/journal/index conventions where available.

Do not invent a global completion transaction spanning Messages DB and an external filesystem unless the existing architecture genuinely supports it.

---

# 15. Archive adoption/relocation compatibility

Audit Feature 31/33 archive identity and relocation semantics.

The coverage fact must remain valid or become safely UNKNOWN when:

- archive root moves;
- bookmark resolves to the same archive instance;
- archive generation changes;
- a new archive is adopted;
- archive is read-only;
- archive becomes temporarily unavailable.

Do not key coverage only by raw path if the project already has a stronger archive identity.

Do not let stale coverage from one archive generation authorize another.

---

# 16. Existing startup Data Update

Do not redesign Data Update in this task except for the minimum necessary to produce/maintain the factual coverage evidence.

Data Update may still:

```text
graph/import
-> attachment preservation
-> restart
```

The important change is that after restart AppCzar can now independently recognize whether attachment coverage is complete.

If Data Update preservation fails and the process remains on its failure screen, keep that behavior.

The new fact protects the subsequent fresh process.

---

# 17. Stage One and other coordinator regressions

Preserve:

- neutral Operating entry;
- no historical semantic restoration;
- display identity currentness;
- exactly three executable top-level dispositions;
- Source Access Repair FALSE/UNKNOWN semantics;
- Data Update isolation/restart semantics;
- production startup unchanged.

Attachment Archive Repair remains virtual.

No new top-level executable coordinator is introduced.

---

# 18. Tests

Use fixtures/temp stores only.

At minimum prove:

1. exact required attachment set is deterministic;
2. complete coverage -> TRUE;
3. known missing required item -> FALSE;
4. ambiguous/unverifiable evidence -> UNKNOWN;
5. UNKNOWN never becomes TRUE from archive availability alone;
6. zero-required-item semantics are correct;
7. coverage observation is read-only;
8. coverage probe acquires no Ball;
9. coverage is scoped to current archive identity/generation;
10. stale generation evidence cannot authorize current generation;
11. archive unavailable remains distinct from coverage incomplete;
12. graph-current/archive-incomplete fresh AppCzar does not select Operating;
13. the critical process-destruction/reconstruction test from Section 9 passes;
14. restoring current coverage allows a later fresh AppCzar to recover without clearing a failure flag;
15. no operation success/failure flag is used by coverage evaluation;
16. coverage evidence cannot be marked covered before payload durability;
17. crash/interruption cannot create a false-positive coverage record;
18. archive move/adoption identity semantics are safe;
19. read-only archive semantics are correctly classified;
20. Data Update regressions pass;
21. Source Access Repair regressions pass;
22. Stage One Operating regressions pass;
23. exactly three executable top-level AppCzar dispositions remain;
24. Attachment Archive Repair remains virtual;
25. production startup route remains unchanged.

---

# 19. Human qualification scope

Build but do not mutate the real archive merely to manufacture an incomplete coverage condition.

The final development artifact may be direct-launched only for a read-only healthy-archive observation if useful.

Do not delete/move a real attachment to prove the FALSE branch.

Fixture/process-reconstruction tests are the governing evidence for the partial failure case.

If the healthy real development archive currently evaluates coverage TRUE, record the visible AppCzar evidence and timing in the response only if the agent is explicitly authorized to launch. Otherwise hand off the build to the human.

---

# 20. Do not resume Stage Two in this prompt

Even after the blocker is corrected, STOP after validating and building the new attachment-coverage model.

Operating-owned live currentness will resume in the next prompt from this new fact foundation.

This separation is intentional:

```text
Prompt 59
make partial preservation independently knowable

next prompt
use that fact to implement safe Operating live currentness
```

---

# 21. Validation

Run:

1. focused attachment-coverage tests;
2. AppCzar evaluator/fact tests;
3. critical fresh-process reconstruction tests;
4. attachment archive service regressions;
5. archive identity/adoption regressions;
6. Data Update regressions;
7. Stage One Operating regressions;
8. Source Access Repair regressions;
9. architecture tests;
10. complete architecture suite;
11. analyzer;
12. full deterministic Flutter suite;
13. `git diff --check`;
14. formatting/generated consistency;
15. debug macOS development build.

Do not launch production.

---

# 22. Project Conformance

Require:

`PROJECT CONFORMANCE: PASS`

with:

- BLOCKER: 0
- SHOULD FIX: 0

Specifically verify:

- current coverage is a fact, not remembered intent;
- graph-current/archive-incomplete is independently classifiable;
- fresh AppCzar cannot admit Operating from incomplete/UNKNOWN coverage;
- no global success/failure flag exists;
- availability and coverage are distinct;
- coverage probe is read-only;
- mutation evidence is crash-safe;
- archive identity/generation scopes evidence;
- Attachment Archive Repair remains virtual;
- exactly three executable top-level dispositions remain;
- production startup unchanged.

If any proposed design still requires "remember that the last operation failed" to keep Operating closed, STOP with a BLOCKER.

---

# 23. Leave implementation unstaged for review

Do not stage, commit, push, merge, or rebase Prompt 59 implementation.

Build the exact development artifact.

Provide:

- bundle path;
- version/build;
- executable SHA-256;
- App.framework SHA-256;
- exact Git/worktree/index/submodule state;
- measured/estimated coverage-probe startup cost;
- readiness to resume Operating-owned live-currentness implementation.

Then STOP.

---

# 24. Required response

Create Response 59 and report:

1. baseline verification;
2. exact existing attachment preservation contract;
3. exact required attachment universe;
4. existing durable attachment evidence;
5. `skipped`/`deferred`/`failed` semantic audit;
6. chosen current coverage proof;
7. whether any new factual index/manifest was required;
8. object-level fact schema if introduced;
9. crash-safe write ordering;
10. read-only coverage probe design;
11. coverage probe performance/complexity;
12. complete/incomplete/UNKNOWN semantics;
13. archive identity/generation scoping;
14. AppCzar fact-DAG integration;
15. exact Operating admission change;
16. Attachment Archive Repair selection behavior;
17. critical graph-current/archive-incomplete fresh-process test;
18. reciprocal self-healing coverage-restoration test;
19. zero-required-item result;
20. healthy coverage presentation;
21. incomplete coverage presentation;
22. UNKNOWN coverage presentation;
23. proof no historical operation flag is used;
24. proof coverage probe acquires no Ball;
25. preservation-side mutation authority result;
26. archive adoption/relocation compatibility;
27. Data Update regression result;
28. Stage One Operating regression result;
29. Source Access Repair regression result;
30. proof exactly three executable top-level AppCzar dispositions remain;
31. focused coverage test results;
32. architecture result;
33. analyzer result;
34. full Flutter-suite result;
35. diff/format/generated hygiene;
36. Project Conformance verdict;
37. BLOCKER findings;
38. SHOULD FIX findings;
39. exact build identity/path/hashes;
40. exact Git/worktree/index/submodule state;
41. readiness to resume Operating-owned live currentness.

Conclude exactly:

`ATTACHMENT COVERAGE IS INDEPENDENTLY RECONSTRUCTIBLE: YES / NO`

`FRESH APPCZAR BLOCKS OPERATING WHEN REQUIRED COVERAGE IS INCOMPLETE: YES / NO`

`ATTACHMENT COVERAGE USES HISTORICAL OPERATION SUCCESS/FAILURE STATE: YES / NO`

`GRAPH-CURRENT/ARCHIVE-INCOMPLETE STATE IS NOW CLASSIFIABLE AFTER RESTART: YES / NO`

`READY TO RESUME OPERATING-OWNED LIVE CURRENTNESS: YES / NO`

Then STOP.
