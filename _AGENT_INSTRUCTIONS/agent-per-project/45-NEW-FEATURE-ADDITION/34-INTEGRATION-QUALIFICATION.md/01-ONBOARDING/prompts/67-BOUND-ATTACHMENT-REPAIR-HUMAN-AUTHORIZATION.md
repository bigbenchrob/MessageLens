# MessageLens Feature 34
## 67 — Bound Attachment Archive Repair Human Authorization to One Explicit Batch

Response 66 stopped at exactly the right safety gate.

The current implementation has a **bounded mutation page** but an **unbounded human authorization scope**:

```text
human clicks "Preserve Available Attachments"
-> controller authorizes current availableFromMessagesCount
-> executor processes page 1 (<= 75)
-> executor automatically processes page 2
-> ...
-> continues until the full admitted available population is exhausted
```

The 75-item page protects mutation tenure size. It does **not** define the human-consent boundary.

The governing rule for Attachment Archive Repair is:

> **One human confirmation authorizes exactly one bounded, visible set of attachment identities. It may never silently expand into later pages or substitute newly discovered items.**

After that one batch settles, the coordinator recomputes current reality and, if more automatically repairable items remain, presents a new explicit action for the next bounded batch.

This task changes only the authorization boundary and the UI/state needed to express it.

Do NOT mutate the real archive in this prompt.
Do NOT launch production MessageLens.
Do NOT weaken attachment coverage.
Do NOT add a durable repair cursor.
Do NOT reintroduce automatic multi-page chaining from one confirmation.

---

# 1. Baseline

Primary worktree:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Require:

- branch: `fix/onboarding-import-stuck-state`
- HEAD/upstream at the Response 65 final pushed recovery anchor;
- ahead/behind `0/0`;
- tracked worktree clean;
- index clean;
- shared-instructions submodule clean at `95326f515ef4719f155ce6e223990398daad6311`;
- only one active Feature 34 development worktree.

Read Response 63, Response 65, Response 66, the current Attachment Archive Repair controller/executor/screen, and the canonical Project Conformance standard.

Create a fresh external baseline manifest.

---

# 2. Audit the exact current authorization flow

Before editing, trace the current production code from the visible button to the writer.

Report:

1. how the screen derives `availableFromMessagesCount`;
2. what `startPreservation()` captures;
3. what `preserveAvailable()` authorizes;
4. how `authorizedTotal` is computed;
5. how the page cursor advances;
6. where subsequent pages are admitted without another user action;
7. what current source metadata is available before confirmation, including exact compatibility keys and byte size if trustworthy;
8. whether the first bounded page can be fully enumerated before the user clicks.

Do not implement until the exact consent boundary is understood.

---

# 3. Human authorization unit

Replace the current "authorize all currently available items" behavior with one explicit **repair batch plan**.

Use project terminology, but conceptually the plan must contain:

```text
RepairBatchPlan
    occurrence / assessment generation
    archive scope identity
    archive generation / resolved path binding
    exact ordered compatibility keys
    itemCount
    totalKnownBytes, if source provides trustworthy byte sizes
    source-evidence generation/fingerprint as needed
```

The plan is current, memory-only, derived from fresh read-only evidence, bounded, immutable once presented for confirmation, and invalid if its evidence binding becomes stale.

Do NOT persist it as durable semantic state.

---

# 4. Exact item bound

Use the existing reviewed repair page bound as the human authorization bound unless source audit proves a smaller project-native bound is required.

Expected default:

```text
maximum authorized items per human confirmation = 75
```

A confirmation may authorize fewer than 75 if fewer currently repairable items exist. It must never authorize item 76.

The executor must not automatically fetch a second page under the same user authorization.

---

# 5. Byte-scope audit and presentation

An item count alone may still encompass very large payloads.

Audit whether fresh authoritative source evidence contains a trustworthy current byte size for every item in the proposed batch.

If trustworthy size is available for all proposed items, show the exact bounded batch scope before confirmation, e.g.:

```text
Preserve next 75 available attachments
Total source size: 428 MB
```

If trustworthy size is not available for every item, do not fabricate a total. Use literal copy such as:

```text
Preserve next 75 available attachments
Total size could not be established
```

Then decide whether that evidence is sufficient for safe explicit consent. If unknown byte scope makes real repair unsafe under existing product rules, STOP AND REPORT rather than inventing a number.

---

# 6. Exact-key authorization

The batch action must authorize an exact set of compatibility keys, not merely:

```text
"up to 75 whatever is available when the executor runs"
```

The selected set should be deterministic from current evidence ordering.

At click time, the executor may revalidate those exact keys. It may preserve a still-valid authorized key, skip/refuse an authorized key whose evidence changed, or fail closed on stale/contradictory evidence.

It may NOT replace a now-unavailable authorized key with item 76, append newly discovered keys, refill the batch behind the human's back, or carry authorization into a later batch.

This is the central consent invariant.

---

# 7. Batch execution path

Required conceptual flow:

```text
fresh read-only partition
-> derive exact bounded RepairBatchPlan
-> present count / byte evidence
-> human confirms once
-> synchronously claim single-flight
-> revalidate exact plan binding
-> one admitted mutation occurrence
-> process only plan.keys
-> release writer / Ball
-> fresh coverage + partition read
-> return to repair surface
```

No loop may obtain another page after the plan is exhausted.

A single batch may still stream its authorized items sequentially under the existing bounded mutation design.

Do not restart merely because one batch finished while coverage remains FALSE.

---

# 8. Post-batch behavior

After one authorized batch settles, obtain a fresh coverage / repair partition.

## Coverage FALSE with more source-available items

Remain on Attachment Archive Repair and present a **new** batch plan. A second human click is required.

## Coverage FALSE with no automatically repairable items

Remain on the factual human-action surface. No restart loop.

## Coverage TRUE

Drain and real-restart for fresh AppCzar.

## Coverage UNKNOWN

Drain and restart for fresh Diagnostic Review.

No in-process coordinator chaining.

---

# 9. Button and confirmation copy

Remove ambiguous authorization wording if necessary.

The UI must make the scope visible before mutation.

Good conceptual copy:

```text
Available from Messages: 1,243

Next repair batch
75 attachments
428 MB

[Preserve these 75 attachments]
```

For fewer than the cap:

```text
[Preserve these 18 attachments]
```

Do not use wording such as `Preserve Available Attachments` if it still implies the entire available population.

Do not claim that a batch will complete archive repair.

---

# 10. No automatic continuation

Delete or refactor the current executor loop whose authorization condition is:

```text
processed < authorizedTotal
```

when `authorizedTotal` represents the full available population.

The implementation may loop only over the exact keys inside the already authorized batch plan.

After the last exact key:

```text
STOP MUTATION
-> verify
-> republish fresh repair state
```

Architecture/tests must make accidental reintroduction of multi-page chaining difficult.

---

# 11. Fresh evidence between confirmations

Each subsequent confirmation must be based on a fresh partition.

Do not carry forward old item count, old source-available count, old paths, old batch cursor, or old byte estimate.

Successfully committed object records are current facts and naturally disappear from the uncovered set.

This retains natural resumability without a durable repair cursor.

---

# 12. Source/archive changes while confirmation is pending

If any plan-defining evidence changes before click or during revalidation:

- invalidate the displayed plan;
- do not mutate it;
- recompute a new plan;
- require a new human confirmation.

Examples include archive generation/path changes, material source-evidence changes, coverage-generation changes, exact key no longer belonging to the required set, or source item becoming unreadable/UNKNOWN.

Do not silently reinterpret stale consent.

---

# 13. Stop/drain semantics

Preserve the existing repair `stopAndDrain()` model.

If quit/restart occurs:

- no new batch admission;
- current authorized atomic work drains;
- Ball/lease releases;
- stale completion cannot publish into a replacement occurrence.

No authorization survives process death. A fresh process must derive a fresh plan and require fresh confirmation.

---

# 14. Mutation authority

Do not change the established authority model.

Required:

```text
Attachment Archive Repair
-> exact confirmed RepairBatchPlan
-> existing ArchiveMutationCoordinator
-> exact repair operation
-> callback-local capability
-> generation-bound writable-root lease
-> admitted writer
```

No nested Ball. No direct filesystem write from controller/UI. Payload-before-record durability remains unchanged.

---

# 15. Tests

Use fixtures/temp stores only.

At minimum prove:

1. one confirmation authorizes at most 75 exact keys;
2. fewer than 75 available authorizes only the actual count;
3. 151 available items require three separate human confirmations, not one;
4. after the first confirmation only the first exact batch is mutated;
5. no second batch starts automatically;
6. item 76 is untouched until a second confirmation;
7. a second confirmation uses a fresh partition;
8. successful first-batch records disappear from the second partition;
9. stale displayed plan cannot mutate;
10. changed archive generation invalidates the plan;
11. changed source evidence invalidates or safely skips exact authorized keys;
12. no replacement/refill item is silently substituted;
13. exact-key ordering is deterministic;
14. one confirmation cannot expand when new items arrive;
15. trustworthy aggregate bytes are displayed when available;
16. unknown byte scope is presented literally if allowed;
17. UI button copy contains exact authorized item count;
18. UI does not imply the whole deficit will be repaired;
19. single-flight prevents double-click duplicate mutation;
20. stop/drain waits for the admitted batch writer/Ball;
21. no consent survives process restart;
22. coverage FALSE after a batch remains on repair with a new explicit action;
23. coverage TRUE restarts for fresh AppCzar;
24. coverage UNKNOWN restarts for fresh diagnostics;
25. no historical repair success/failure state is introduced;
26. shared required-attachment evidence definition remains singular;
27. Operating Stage Two regressions pass;
28. Data Update regressions pass;
29. Source Access Repair regressions pass;
30. architecture execution census remains Data Update coordinator, Source Access Repair coordinator, Attachment Archive Repair coordinator, and Operating admitted session.

---

# 16. Validation

Run:

1. focused batch-plan/consent tests;
2. repair controller tests;
3. repair executor/writer tests;
4. repair presentation tests;
5. drain/lifecycle tests;
6. shared evidence-reader tests;
7. Prompt 59 coverage regressions;
8. Operating Stage Two regressions;
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

---

# 17. Project Conformance

Require:

`PROJECT CONFORMANCE: PASS`

with:

- BLOCKER: 0
- SHOULD FIX: 0

Specifically verify:

- human authorization is an exact bounded set;
- one confirmation cannot auto-chain later pages;
- no silent replacement item can enter an authorized batch;
- the plan is current, memory-only, and occurrence-bound;
- mutation authority is unchanged;
- coverage semantics are unchanged;
- no durable semantic cursor/status is added;
- both Operating and repair drain models remain intact;
- production startup is unchanged.

---

# 18. Checkpoint after automated validation

The lesson from earlier worktree complexity remains:

> checkpointing preserves engineering state; qualification is separate evidence.

If validation passes:

1. create a narrow implementation commit;
2. create/update Feature 34 documentation including Prompt 66 / Response 66 / Prompt 67 / Response 67;
3. explicitly record Attachment Archive Repair automated validation PASS and human live qualification still PENDING because Prompt 66 stopped before launch;
4. push the primary branch normally.

Recommended implementation subject:

`fix(attachments): bound repair authorization to one batch`

No force push, rebase, squash, or unrelated staging.

---

# 19. Build identity

Produce but do not launch the exact development artifact.

Advance the development version/build sequentially from the integrated `0.2.136 (154)` state if that is still current.

Report bundle path, product, bundle identifier, version/build, executable SHA-256, and App.framework SHA-256.

---

# 20. Required response

Create Response 67 and report:

1. baseline verification;
2. exact old authorization-flow audit;
3. chosen RepairBatchPlan model;
4. exact item cap;
5. byte-scope evidence/design;
6. deterministic exact-key selection;
7. stale-plan invalidation rules;
8. exact executor loop change;
9. proof no refill/substitution is possible;
10. UI copy/action change;
11. first-batch behavior;
12. fresh second-plan behavior;
13. coverage FALSE post-batch behavior;
14. coverage TRUE behavior;
15. coverage UNKNOWN behavior;
16. source/archive change behavior;
17. stopAndDrain preservation;
18. mutation-authority preservation;
19. focused batch-plan tests;
20. repair controller/executor/writer tests;
21. presentation tests;
22. lifecycle/drain tests;
23. shared evidence/coverage regressions;
24. Operating Stage Two regression result;
25. Data Update regression result;
26. Source Access Repair regression result;
27. architecture result;
28. analyzer result;
29. full Flutter-suite result;
30. diff/format/generated hygiene;
31. Project Conformance verdict;
32. BLOCKER findings;
33. SHOULD FIX findings;
34. implementation checkpoint commit;
35. documentation checkpoint commit;
36. pushed recovery anchor;
37. exact build identity/path/hashes;
38. final Git/worktree/index/submodule state;
39. readiness to rerun Prompt 66;
40. readiness to rerun Prompt 61.

Conclude exactly:

`ONE HUMAN CONFIRMATION AUTHORIZES AT MOST ONE BOUNDED REPAIR BATCH: YES / NO`

`AUTHORIZED REPAIR BATCH CONTAINS AN EXACT FIXED KEY SET: YES / NO`

`EXECUTOR CAN AUTO-CHAIN A SECOND BATCH WITHOUT NEW CONSENT: YES / NO`

`STALE CONSENT CAN SUBSTITUTE NEWLY DISCOVERED ITEMS: YES / NO`

`ATTACHMENT ARCHIVE REPAIR AUTOMATED VALIDATION: PASS / FAIL`

`ATTACHMENT ARCHIVE REPAIR HUMAN LIVE QUALIFICATION: PENDING / PASS / FAIL`

`READY TO RERUN BOUNDED REAL REPAIR PROMPT 66: YES / NO`

Then STOP.
