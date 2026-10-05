# MessageLens Feature 34
## 69 — Separate Attachment Coverage Debt from Operating Admission and Live-Update Success

Response 68 passed the bounded real Attachment Archive Repair qualification.

The real development installation now proves this current state:

```text
required attachment payloads     18,281
covered                            4,446
uncovered                         13,835

available from Messages                0
source currently absent           13,835
source UNKNOWN                         0
record-backed recovery needed          0
unsafe/conflicting                      0
```

Exactly six currently available payloads were human-authorized and preserved.
Fresh-process reconstruction proved that those six durable facts survived
process death. The remaining 13,835 are currently source-absent.

This exposes an architectural distinction that the original Prompt 59 coverage
gate intentionally did not yet make:

> **Attachment coverage completeness and MessageLens operability are not the
> same proposition.**

`attachmentCoverageComplete == FALSE` is still literally true and must remain
visible.

But when every uncovered item is conclusively classified as **currently
source-absent**, there is no automatic repair work MessageLens can perform.
Keeping the normal application permanently inaccessible does not preserve any
additional bytes and does not make the coverage fact more true.

The same issue applies to Operating Stage Two. Its current post-live-update
success rule requires global coverage TRUE. With 13,835 known source-absent
historical deficits, that condition can never become TRUE, so every otherwise
successful ordinary live update would eventually fail the Operating
postcondition.

The correction is:

> **Keep coverage completeness as a factual preservation metric, but derive
> top-level jurisdiction from current repair actionability and evidence quality,
> not completeness alone.**

No attachment is to be declared covered merely because it is absent from
Messages.

No obligation disappears.

No historical success/failure state is introduced.

---

# 1. Baseline

Primary worktree:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Require:

- branch:
  `fix/onboarding-import-stuck-state`
- HEAD/upstream:
  `cb0de75389962ec339ac14ba9a980b01526568a6`
- ahead/behind `0/0`;
- tracked worktree clean;
- index clean;
- shared-instructions submodule clean at:
  `95326f515ef4719f155ce6e223990398daad6311`;
- one active Feature 34 development worktree.

Read:

- Response 59;
- Response 62;
- Response 65;
- Response 67;
- Response 68;
- current AppCzar evaluator/controller;
- current Attachment Archive Repair partition/evidence implementation;
- current Operating currentness post-update coverage logic;
- canonical Project Conformance standard.

Create a fresh external baseline manifest.

---

# 2. Checkpoint Response 68 qualification evidence first

Response 68 made no source/test change but is important qualification evidence.

Create a narrow Feature 34 documentation checkpoint containing the appropriate
Prompt 68 / Response 68 records if they are not already committed.

Record exactly:

```text
Attachment Archive Repair human live qualification: PASS

Real qualified mutation:
    one explicit six-item plan
    2,212,781 bytes
    six newly covered
    zero failed
    no second automatic batch

Fresh reconstructed state:
    required 18,281
    covered 4,446
    uncovered 13,835
    available from Messages 0
    source currently absent 13,835
    UNKNOWN 0
```

Do not describe the 13,835 as lost.

Push the documentation checkpoint normally before source edits.

---

# 3. Audit every place where global coverage TRUE is currently treated as an operability prerequisite

Before editing, enumerate all production/test locations where any of the
following currently occurs:

```text
attachmentCoverageComplete == FALSE
    -> Attachment Archive Repair

attachmentCoverageComplete != TRUE
    -> Operating denied

post-live-update coverage != TRUE
    -> Operating failure/restart
```

At minimum audit:

- `AppCzarEvaluator`;
- `AppCzarOperatingSessionController`;
- startup host selection predicates;
- `AppCzarOperatingCurrentnessController`;
- post-worker coverage verification;
- Attachment Archive Repair selection predicate;
- AppCzar presentation rows;
- architecture tests.

Report the exact current semantics before changing them.

---

# 4. Preserve the coverage fact unchanged

Do NOT weaken or redefine:

`attachmentCoverageComplete`

Its truth remains:

```text
TRUE
    every required conventional attachment has valid durable archive evidence

FALSE
    one or more required conventional attachments conclusively lack coverage

UNKNOWN
    completeness cannot be established safely
```

For the qualified real development state:

```text
attachmentCoverageComplete == FALSE
```

must remain true after this task.

Do not exclude currently absent source payloads from the required universe.

Do not introduce a date/policy cutoff.

Do not mark source-absent items covered.

---

# 5. Introduce current repair-actionability evidence

Reuse the already qualified shared repair partition.

Do not create a second attachment-universe query.

Expose the smallest read-only current evidence needed by AppCzar and Operating
to distinguish:

```text
coveredCount

uncoveredSourceAvailableCount
uncoveredSourceAbsentCount
uncoveredSourceUnknownCount

recordBackedRecoveryNeededCount
unsafeOrConflictingCount
```

Use existing project terminology where possible.

The evidence must be:

- current;
- read-only;
- derived from the canonical `RequiredAttachmentEvidenceReader`;
- based on authoritative current source evidence;
- archive-scope/generation bound;
- independent of previous repair/update outcomes.

Do not persist it as semantic status.

---

# 6. Derive a factual "repair opportunity now" proposition

Introduce the smallest derived fact necessary, conceptually:

```text
attachmentRepairOpportunityPresent
```

Truth:

```text
TRUE
    one or more exact uncovered required payloads are currently proven
    source-available and automatically repairable

FALSE
    coverage may be incomplete, but zero currently automatically repairable
    payloads are proven and all relevant evidence is conclusive

UNKNOWN
    current repairability cannot be established safely
```

Do not use this proposition as a synonym for coverage completeness.

The real qualified state should evaluate:

```text
attachmentCoverageComplete         FALSE
attachmentRepairOpportunityPresent FALSE
sourceAbsentCount                   13,835
sourceUnknownCount                  0
```

provided a fresh process observes the same current facts.

---

# 7. Define operating-safe attachment evidence narrowly

Operating may coexist with **known preservation debt** only when the debt is
fully classified and non-actionable now.

Required conceptual predicate:

```text
attachmentEvidencePermitsOperating =
    archive available/coherent
    AND repairability evidence conclusive
    AND uncoveredSourceAvailableCount == 0
    AND uncoveredSourceUnknownCount == 0
    AND recordBackedRecoveryNeededCount == 0
    AND unsafeOrConflictingCount == 0
```

`uncoveredSourceAbsentCount` may be greater than zero.

This does NOT mean those items are covered.

It means:

> MessageLens knows they are not covered, knows they are not currently
> available to preserve, and has no immediate automatic repair operation to
> perform.

If source-absent status itself cannot be proven, fail closed to UNKNOWN.

---

# 8. Fresh AppCzar disposition rules

Refine startup selection to:

```text
archive unavailable
    -> existing archive-unavailable virtual diagnosis
       (do not accidentally execute coverage repair)

coverage UNKNOWN
or repairability UNKNOWN
or unsafe/conflicting evidence
    -> Diagnostic Review

coverage FALSE
and uncovered source-available repair work > 0
    -> executable Attachment Archive Repair

coverage FALSE
and source-available == 0
and source-unknown == 0
and record-backed recovery needed == 0
and unsafe/conflicting == 0
    -> Operating Session may be admitted if all non-attachment Operating facts
       are otherwise satisfied

coverage TRUE
    -> continue ordinary Operating evaluation
```

Do not add a new top-level coordinator.

Do not add a "degraded operating" coordinator enum.

Operating is still Operating.

---

# 9. Operating must display the preservation debt truthfully

When Operating is admitted with known incomplete/non-actionable attachment
coverage, preserve the fact in normal UI.

Use a compact, non-blocking factual status/attention surface, for example:

```text
Attachment archive
13,835 required payloads are not preserved.
None are currently available from Messages.
```

Use actual product style and terminology.

Do not say:

- lost;
- safe;
- repaired;
- complete.

Do not make the warning modal or replace the workspace.

The user must still be able to browse normally.

If the existing Environment/Attachment Archive settings surface is the proper
home, reuse it rather than inventing a new global banner, but ensure the debt is
not silently hidden.

---

# 10. Repair jurisdiction remains actionable

Attachment Archive Repair should execute only when current evidence gives it
work it can actually perform automatically, or when an existing repair-specific
manual integrity condition requires its surface.

For the ordinary no-record deficit:

```text
source available > 0
    -> Repair coordinator

source available == 0
source absent > 0
unknown == 0
    -> no automatic Repair coordinator at startup
```

Do not start Repair merely to display 13,835 source-absent items and block the
normal application forever.

The same repair UI remains available through the appropriate Settings /
maintenance surface if that is an existing product path, and a future
redownload can become actionable on a fresh reassessment.

---

# 11. Correct Operating Stage Two post-update semantics

The current Stage Two rule:

```text
worker returns
-> global attachment coverage TRUE required
-> success
```

is no longer valid in the presence of known source-absent historical debt.

Replace it with a fresh current attachment-actionability/postcondition check.

After the live worker settles and releases the Ball:

```text
fresh shared attachment evidence
```

Operating may continue in-process only when:

```text
uncoveredSourceAvailableCount == 0
uncoveredSourceUnknownCount == 0
recordBackedRecoveryNeededCount == 0
unsafeOrConflictingCount == 0
archive scope/generation remains coherent
```

Global `attachmentCoverageComplete` may remain FALSE because of known
source-absent debt.

Do not publish `coverage complete`.

Do not erase or hide the debt count.

---

# 12. Live-update failure/action cases

After an ordinary Operating live update:

## New/current repair opportunity appears

If fresh evidence has:

```text
uncoveredSourceAvailableCount > 0
```

then the live update is not fully settled from the preservation perspective.

Required:

```text
Operating stops accepting currentness work
-> stopAndDrain()
-> real restart
-> fresh AppCzar
-> Attachment Archive Repair
```

No in-process repair handoff.

## Attachment evidence becomes UNKNOWN/conflicting

```text
stop/drain
-> restart
-> fresh Diagnostic Review
```

## Only known source-absent debt remains

```text
same PID
same Operating occurrence
same navigation
update status returns to idle
preservation-debt count may update factually
```

No restart.

---

# 13. Crash/restart safety analysis

Explicitly revisit the Prompt 59 motivating sequence:

```text
graph/import commits
-> attachment preservation fails
-> source payload remains available
-> process dies
```

Fresh process must see:

```text
uncovered source-available > 0
-> Repair
```

Also analyze:

```text
graph/import commits
-> preservation cannot occur
-> source payload is no longer locally available
-> process dies
```

Fresh process may see:

```text
coverage FALSE
source-available 0
source-absent +1
-> Operating with truthful preservation debt
```

This is acceptable only because:

- the missing preservation fact remains visible;
- no false coverage claim exists;
- no automatic repair is possible from current evidence;
- blocking normal browsing cannot recover the bytes.

Document this architectural decision explicitly.

---

# 14. No historical baseline comparison

Do not implement:

```text
"debt count did not increase"
"same deficit as launch"
"known old deficit"
"grandfathered missing items"
```

as authority.

Those are historical comparisons.

The permission to operate must be derived only from **current classification**:

```text
currently covered
currently source-available uncovered
currently source-absent uncovered
currently unknown/conflicting
```

A source-absent item is not allowed because it is "old."

It is allowed to coexist with Operating because its **current facts are
conclusive and non-actionable**.

---

# 15. Performance

Do not make healthy startup unnecessarily expensive.

Audit the existing repair partition cost.

Prefer conditional evaluation:

```text
coverage TRUE
    -> no full repairability partition needed

coverage FALSE
    -> compute repairability partition to choose Repair vs Operating vs
       Diagnostic
```

Reuse bounded pagination and existing source-reader work.

Measure fixture/current expected cost.

Do not scan payload bytes.

---

# 16. Tests

Use fixtures/temp stores only.

At minimum prove:

1. coverage TRUE still permits ordinary Operating evaluation;
2. coverage FALSE + source-available >0 selects Attachment Archive Repair;
3. coverage FALSE + source-available 0 + source-absent >0 + UNKNOWN 0 can admit
   Operating when every other Operating fact is valid;
4. that Operating state still reports coverage FALSE;
5. source-absent items are not removed from required count;
6. coverage FALSE + source UNKNOWN selects diagnostics, not Operating;
7. unsafe/conflicting evidence does not admit Operating;
8. record-backed recovery-needed evidence does not silently admit Operating;
9. archive unavailable does not execute coverage Repair by accident;
10. real-state-shaped fixture `18,281 / 4,446 / 13,835 / 0 available / 0 unknown`
    admits Operating if all other facts are valid;
11. Operating UI presents preservation debt factually;
12. debt presentation does not block navigation;
13. no "lost", "complete", or "repaired" overclaim appears;
14. post-live-update global coverage FALSE can still return Operating to idle
    when all uncovered items are currently source-absent and evidence is
    conclusive;
15. post-live-update source-available uncovered item triggers drain/restart;
16. post-live-update UNKNOWN triggers drain/restart;
17. successful same-session text-only update preserves navigation despite
    source-absent debt;
18. successful same-session attachment update preserves its new payload and
    may remain Operating even though unrelated source-absent debt remains;
19. no debt-baseline/history comparison participates in authority;
20. no durable waiver/exemption flag exists;
21. shared required-evidence reader remains singular;
22. Attachment Archive Repair bounded-consent regressions pass;
23. Operating stopAndDrain regressions pass;
24. Data Update regressions pass;
25. Source Access Repair regressions pass;
26. AppCzar execution census remains three top-level coordinators plus Operating
    admitted session;
27. production startup remains unchanged.

---

# 17. Qualification semantics

Update architecture/documentation language so these concepts are distinct:

```text
Attachment coverage complete
    preservation completeness fact

Attachment repair opportunity present
    current actionable-maintenance fact

Operating admissible
    normal-workspace jurisdiction decision
```

Do not use the word "healthy" as a shortcut if it conflates these propositions.

The Fair-Witness law remains:

> Every statement about current state must be literally true and no stronger
> than current evidence supports.

---

# 18. Validation

Run:

1. AppCzar evaluator/fact tests;
2. attachment repairability-partition tests;
3. startup host/admission tests;
4. Operating controller tests;
5. Operating currentness/post-update tests;
6. Attachment Archive Repair regressions;
7. shared attachment evidence-reader tests;
8. Prompt 59 coverage regressions;
9. mutation/Ball regressions;
10. Data Update regressions;
11. Source Access Repair regressions;
12. architecture suite;
13. analyzer;
14. full deterministic Flutter suite;
15. `git diff --check`;
16. formatting/generated consistency;
17. debug macOS development build.

Do not launch production.

Require:

`PROJECT CONFORMANCE: PASS`

with:

- BLOCKER: 0
- SHOULD FIX: 0

---

# 19. Checkpoint implementation after validation

If validation passes:

1. create a narrow implementation commit;
2. create/update the Feature 34 documentation checkpoint including Prompt 69 /
   Response 69;
3. push the primary branch normally.

Recommended subject:

`fix(startup): separate attachment debt from operating admission`

Record accurately:

```text
Attachment Archive Repair human qualification: PASS

Operating Stage Two human qualification:
    still PENDING until rerun after this admission correction
```

No force push, rebase, squash, or unrelated staging.

---

# 20. Build but do not launch

Produce the exact combined development artifact.

Advance version/build sequentially if required by project convention.

Report:

- bundle path;
- product;
- bundle identifier;
- version/build;
- executable SHA-256;
- App.framework SHA-256.

Do not launch it.

---

# 21. Next human qualification

If this task passes, the next task should direct-launch the exact artifact
against the real current state.

Expected fresh path, if current facts still resemble Response 68:

```text
coverage FALSE
source-available 0
source-absent 13,835
UNKNOWN 0
-> Operating admitted with truthful non-blocking preservation debt
```

Then rerun the original Operating Stage Two live-currentness experiment:

```text
select conversation
-> receive/send one ordinary text
-> same PID internal update
-> navigation preserved
-> fresh attachment actionability remains clear
```

Do not perform that live experiment in Prompt 69.

---

# 22. Stop gates

STOP AND REPORT if:

- current repair partition cannot be reused without duplicating required-set
  logic;
- source-absent vs UNKNOWN cannot be established reliably enough for startup;
- admitting Operating would require marking uncovered items covered;
- implementation requires a historical debt baseline/waiver;
- live-update continuation cannot distinguish actionable vs source-absent debt;
- production startup behavior must change;
- architecture cannot reach Project Conformance PASS.

---

# 23. Required response

Create Response 69 and report:

1. baseline verification;
2. Response 68 documentation checkpoint;
3. audit of every global-coverage operability gate;
4. preserved coverage-complete semantics;
5. repair-actionability evidence model;
6. source-available/source-absent/UNKNOWN definitions;
7. derived repair-opportunity proposition;
8. operating-safe attachment-evidence predicate;
9. exact fresh AppCzar disposition rules;
10. real-state-shaped `18,281/4,446/13,835` evaluator result;
11. Operating debt presentation;
12. Attachment Archive Repair selection change;
13. Operating admission-controller change;
14. Stage Two post-live-update semantic change;
15. post-update source-available behavior;
16. post-update source-absent-only behavior;
17. post-update UNKNOWN/conflict behavior;
18. crash/restart safety analysis;
19. proof no historical debt baseline is used;
20. performance/conditional-evaluation result;
21. AppCzar evaluator tests;
22. repairability-partition tests;
23. Operating admission tests;
24. Operating currentness tests;
25. Repair regressions;
26. Prompt 59 coverage regressions;
27. Data Update regressions;
28. Source Access Repair regressions;
29. architecture result;
30. analyzer result;
31. full Flutter-suite result;
32. diff/format/generated hygiene;
33. Project Conformance verdict;
34. BLOCKER findings;
35. SHOULD FIX findings;
36. implementation checkpoint commit;
37. documentation checkpoint commit;
38. pushed recovery anchor;
39. exact build identity/path/hashes;
40. final Git/worktree/index/submodule state;
41. readiness to rerun Operating Stage Two human qualification.

Conclude exactly:

`ATTACHMENT COVERAGE COMPLETENESS REMAINS A LITERAL FACT: YES / NO`

`KNOWN SOURCE-ABSENT COVERAGE DEBT CAN COEXIST WITH OPERATING: YES / NO`

`CURRENT SOURCE-AVAILABLE UNCOVERED PAYLOADS SELECT REPAIR: YES / NO`

`UNKNOWN OR CONFLICTING ATTACHMENT EVIDENCE FAILS CLOSED: YES / NO`

`OPERATING LIVE UPDATE NO LONGER REQUIRES GLOBAL COVERAGE TRUE: YES / NO`

`OPERATING AUTHORITY USES HISTORICAL DEBT/WAIVER STATE: YES / NO`

`PROJECT CONFORMANCE: PASS / FAIL`

`READY TO RERUN OPERATING STAGE TWO HUMAN QUALIFICATION: YES / NO`

Then STOP.
