# MessageLens Feature 34
## 63 — Implement Attachment Archive Repair in an Isolated Worktree

Response 62 confirmed that the real development archive has a genuine
Fair-Witness coverage deficit under the current preservation contract:

```text
required attachment keys   18,281
covered                      4,440
uncovered                   13,841
unverifiable                     0
```

All 13,841 uncovered keys have **no durable `archived_attachments` record**.
They are not 13,841 proven missing archive files, lost payloads, failed copies,
or automatically repairable items.

The audit also established:

- all 4,440 record-backed required keys are currently represented by valid
  archive payloads;
- the whole-graph Prompt 59 required universe is valid;
- source availability must be determined from fresh authoritative evidence at
  repair time;
- missing source bytes change the **repair class**, not the coverage obligation;
- no global success/failure flag is needed;
- one bounded Attachment Archive Repair coordinator is the correct next
  jurisdiction.

There is an important repository-safety constraint.

Prompt 60's Operating Stage Two implementation is still **unstaged and pending
human qualification** in the primary worktree. Attachment Archive Repair will
touch AppCzar host/architecture surfaces that overlap Stage Two.

Therefore this task MUST NOT layer repair implementation onto that dirty tree.

Instead:

> **Preserve the primary Prompt 60 worktree byte-for-byte and implement
> Attachment Archive Repair in a separate Git worktree created from the last
> committed attachment-coverage recovery anchor.**

Do NOT checkpoint Prompt 60 merely to make this easier.
Do NOT mutate the primary worktree.
Do NOT launch production MessageLens.
Do NOT mutate the real archive or real MessageLens databases in this prompt.
Do NOT stage, commit, push, merge, or rebase the repair implementation before
human qualification.

---

# 1. Primary-worktree preservation

Primary worktree:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Expected:

- branch:
  `fix/onboarding-import-stuck-state`
- HEAD/upstream:
  `ac56ea84bd2e301b592b3ca2ae20b8297523cf7e`
- Prompt 60 Stage Two present and unstaged;
- tracked Prompt 60 diff SHA-256 from Response 62:
  `9430b7970bf251826dd3f58d78abf6a7c92ffe8475925b4fe167f90ab0d2103c`;
- 18 tracked Stage Two modified paths;
- 14 new Stage Two source/generated/test paths with their Response 62 baseline
  hashes;
- index empty;
- shared-instructions submodule clean at:
  `95326f515ef4719f155ce6e223990398daad6311`.

Before doing anything:

1. verify this exact state;
2. capture a fresh external manifest including every Prompt 60 file hash;
3. do not edit, stage, generate, format, build, or otherwise mutate this
   primary worktree for the remainder of Prompt 63.

At the end, verify the same tracked diff SHA and every Stage Two new-file hash.

If any primary-worktree byte changes, STOP AND REPORT.

---

# 2. Create a separate repair worktree

Create a new temporary/sibling Git worktree from the committed recovery anchor:

`ac56ea84bd2e301b592b3ca2ae20b8297523cf7e`

Use a dedicated branch, for example:

`feature/appczar-attachment-archive-repair`

Use an isolated path outside the primary worktree, preferably:

`/private/tmp/messagelens-appczar-attachment-archive-repair`

Do not reuse or disturb any existing unrelated worktree.

Record:

- exact worktree path;
- branch;
- starting commit;
- submodule state.

All Prompt 63 source/test/build work occurs only in this repair worktree.

---

# 3. Reconfirm the repair selection contract

Attachment Archive Repair becomes executable only for **conclusive incomplete
coverage**.

The exact predicate must require one coherent current assessment:

```text
virtualCoordinator == attachmentArchiveRepair

AND diagnosis kind == attachmentArchiveCoverageIncomplete

AND attachmentCoverageComplete == FALSE

AND attachmentArchiveAvailable == TRUE

AND current archive scope identity / generation / resolved path are coherent

AND assessment generation is still current
```

Do NOT execute this coordinator for:

- archive-root unavailable;
- attachment coverage UNKNOWN;
- stale prior coverage;
- remembered deficit count;
- prior repair result.

Coverage UNKNOWN remains Diagnostic Review.

Archive-root unavailability remains its separate virtual diagnosis unless a
future task designs that jurisdiction.

---

# 4. Top-level AppCzar authority after Prompt 63

After this implementation, the development AppCzar route may have exactly:

```text
Data Update
    EXECUTABLE TOP-LEVEL COORDINATOR

Source Access Repair
    EXECUTABLE TOP-LEVEL COORDINATOR

Attachment Archive Repair
    EXECUTABLE TOP-LEVEL COORDINATOR

Operating Session
    EXECUTABLE ADMITTED SESSION
```

Still virtual:

```text
Onboarding
Local Data Repair
Diagnostic Review
```

Do not add a generic enum dispatcher.

Do not let Attachment Archive Repair invoke any other top-level coordinator
in-process.

---

# 5. Establish one shared key-level attachment evidence reader

Response 62 identified this as the first implementation prerequisite.

The current startup coverage probe contains the correct Prompt 59 required-set
definition, but repair must not duplicate its private SQL.

Refactor/extract the narrowest shared typed read-only boundary that can serve:

1. AppCzar attachment coverage;
2. Attachment Archive Repair item classification;
3. future bounded sweep/reconciliation readers where appropriate.

It must expose the exact same compatibility identity:

```text
(message GUID, original live attachment ROWID)
```

and the exact same required-universe filtering:

- live-source message endpoint;
- live-source attachment endpoint;
- nonblank message GUID;
- nonblank filename/path;
- nonblank MIME type.

Use bounded/keyset pagination.

Do not materialize all 18,281 keys in memory merely for convenience.

The reader should expose item-level factual evidence sufficient to classify:

```text
covered and valid

no durable record

record exists / payload absent

record exists / wrong size

record exists / unsafe or unverifiable path

conflicting durable evidence

ambiguous required identity
```

Preserve the existing aggregate coverage probe by making it consume the same
shared evidence semantics rather than maintaining a second definition.

Add architecture/tests proving startup and repair cannot drift to separate
required-set definitions.

---

# 6. Fresh authoritative source-path evidence

Repairability depends on current Messages evidence, not the last-imported path.

For an uncovered exact compatibility key, reuse/extract the production
source-resolution logic that can:

1. identify the exact current live attachment row;
2. observe the current source path;
3. classify the source payload metadata as:
   - available/readable enough for preservation;
   - absent;
   - unreadable;
   - unknown/inconclusive.

Do not treat the retained imported path as authoritative when current
`chat.db` provides newer metadata.

Do not claim a source-absent item is permanently lost.

Do not expose private filenames in ordinary repair UI.

If current source access becomes globally unavailable during repair, do not
continue guessing item repairability. End the coordinator through the normal
drain/restart boundary so fresh AppCzar can select Source Access Repair.

---

# 7. Establish a callback-local repair writer seam

Response 62 identified this as the second implementation prerequisite.

Do not call an existing public archive method that self-acquires a second
mutation tenure from inside the repair coordinator.

Create/reuse the smallest typed writer seam that operates only inside an already
admitted archive-mutation callback.

Required conceptual path:

```text
Attachment Archive Repair occurrence
-> ArchiveMutationCoordinator.runWithCapability(
     attachmentReconciliation)
-> current writable-root lease
-> callback-local repair writer
-> existing verified payload-preservation primitive
```

The capability and lease may not escape the callback.

No nested Ball.

No direct coordinator filesystem write.

The writer must preserve the established ordering:

```text
source identity proved
-> stream source
-> temporary file
-> flush
-> size/hash verify
-> atomic final install/no-overwrite
-> mutation revalidation
-> durable object record
```

For the real current deficit, the primary automatic case is:

```text
no durable record
+ exact current source identity
+ current source payload available
-> preserve normally
```

Do not invent metadata-only coverage when payload identity is not proven.

---

# 8. Record-backed defects

The real audit currently found zero record-backed required defects, but the
coordinator must fail safely if one appears later.

Audit whether the callback-local repair writer can safely repair:

```text
record exists
+ referenced payload absent/wrong
+ current exact source payload available
```

The ordinary ingestion path currently treats an existing record as
`alreadyArchived`, so do not silently reuse that behavior for a defective
record.

Implement an automatic record-backed repair only if:

- exact source identity is proven;
- existing record identity is coherent;
- mutation ordering can replace/reconcile payload and metadata without a false
  positive;
- existing archive invariants remain intact.

Otherwise classify the item as a bounded manual/unverifiable repair class.

Do not weaken archive integrity merely to handle a currently-zero population.

---

# 9. Coordinator jurisdiction

Implement one generation-bound `Attachment Archive Repair` coordinator.

Its jurisdiction is:

> Recompute current incomplete attachment coverage, automatically repair only
> those exact required objects whose current identity and source payload are
> provably available, and present factual human-action requirements for the
> remainder.

It may:

- recompute current coverage;
- page the exact uncovered set;
- classify each item from fresh evidence;
- automatically preserve source-available items;
- verify committed object evidence;
- publish privacy-safe aggregate progress;
- remain visible for unresolved manual/source-absent items;
- restart after bounded mutation work when a fresh-process reassessment is
  appropriate.

It may NOT:

- use the startup `13,841` count as authority;
- treat remembered prior classification as current;
- call Data Update;
- call Source Access Repair;
- admit Operating;
- write a Journey cursor;
- persist a global repair-success flag;
- manufacture attachment identity.

---

# 10. Internal typed sub-operations

Prefer one coordinator with internal bounded steps:

```text
recomputeCoverage
classifyUncovered
preserveAvailableSourcePayloads
verifyCoverage
reportManualRequirements
```

These are not top-level AppCzar coordinators.

Keep state memory-only except for successfully committed object-level archive
facts created by the established writer.

---

# 11. Automatic repair batching

The real population can be large.

Use bounded keyset pages, approximately 50–100 keys unless project idioms
support another reviewed bound.

Requirements:

- no whole uncovered set retained in memory;
- one source payload streamed at a time;
- no unbounded payload-byte buffering;
- one mutation tenure per admitted bounded mutation occurrence, not per entire
  application lifetime;
- no hidden queue of batches after stop begins;
- factual progress throttled by item/time as appropriate.

The coordinator may process sequential batches within the same occurrence while
current evidence remains valid.

Do not restart after every 50 items.

---

# 12. Recompute rather than resume from a cursor

Do not add durable coordinator resume state.

If repair is interrupted:

```text
stop accepting new items
-> drain current writer
-> release Ball/lease
-> exit
```

On the next launch or explicit reassessment:

```text
fresh graph
+ fresh source
+ durable object records
+ archive metadata
-> recompute remaining uncovered set
```

Successfully written object records are facts and naturally disappear from the
uncovered set.

No Journey cursor is needed.

---

# 13. Human/manual classes

For items not automatically repairable, report only privacy-safe aggregate
current facts.

At minimum distinguish where source evidence permits:

```text
source payload currently available
source payload currently absent
source evidence unavailable/unknown
record-backed payload needs recovery
unsafe/conflicting evidence
```

Human-facing actions may include:

- restore Messages source access;
- allow Messages to redownload an attachment;
- reconnect a known historical/donor volume;
- use an existing verified historical-recovery workflow.

Do not add:

- Ignore missing;
- Mark repaired;
- Exempt these attachments;
- Assume lost.

Any future exclusion policy would be a new user-authored fact and requires
separate design.

---

# 14. Avoid pointless restart loops

If no automatic mutation is possible and coverage remains FALSE solely because
current source payloads are absent/manual:

- stay on the bounded Attachment Archive Repair surface;
- do not restart automatically into the same conclusive FALSE;
- allow the human to change external evidence;
- provide an explicit single-flight `Check Again` / `Reassess` action.

That action must recompute from current evidence.

If external evidence changes enough that another top-level jurisdiction is
required, end through a real process restart and let fresh AppCzar decide.

---

# 15. Success semantics

The coordinator does not declare Operating.

After automatic repair work settles, obtain a fresh current coverage
observation.

## Coverage TRUE

```text
bounded repair work settled
-> current coverage TRUE
-> stop/drain
-> real process restart
-> fresh AppCzar
```

Only fresh AppCzar may then admit Operating.

## Coverage FALSE

If remaining items are manual/source-absent:

- remain on the factual repair surface;
- report current categories;
- no restart loop.

If new automatically repairable items remain because evidence changed during
the pass:

- continue another bounded pass only if occurrence identity/authority remains
  valid and no stop was requested.

## Coverage UNKNOWN

Do not call it incomplete.

Stop/drain and restart for fresh Diagnostic Review.

No coordinator chaining.

---

# 16. Progress presentation

Use only current factual counts.

Example structure:

```text
Checking attachment coverage…

Required payloads                    N
Covered                              N
Need attention                       N

Available from Messages              N
Source currently absent              N
Source evidence unavailable          N
Record-backed recovery needed        N

Preserving                       X / Y
Verifying current coverage…
```

Do not expose message text, contact names, or private filenames.

Do not say:

- all attachments safe;
- repair successful;
- attachments lost;

unless current evidence literally establishes the proposition.

---

# 17. Source-access loss during repair

If the coordinator loses current Messages-source access:

- stop admitting new repair items;
- drain the current writer/Ball;
- request a real process restart.

Fresh AppCzar may then select Source Access Repair.

Do not call it in-process.

UNKNOWN source evidence similarly ends through fresh reassessment rather than
being called denial.

---

# 18. Archive identity/generation changes

Bind the repair occurrence to exact:

- archive instance/scope identity;
- location generation;
- resolved path;
- writable-root lease generation.

Revalidate before every mutation batch and protected writer boundary.

If identity/generation changes:

- stop admitting work;
- drain;
- restart for fresh AppCzar.

No mixed-generation repair.

---

# 19. `stopAndDrain()` for repair

Attachment Archive Repair is potentially long-running and must have its own
bounded shutdown/drain contract.

Required:

- stop new item/batch admission synchronously;
- cancel pending scheduled classification work if any;
- await current source observation;
- await current archive writer through payload/object-record terminal boundary;
- await Ball/lease release;
- prevent stale completion from publishing into a replacement occurrence.

Normal user quit and coordinator-requested restart must respect this boundary.

Reuse the proven lifecycle pattern from Operating Stage Two where practical, but
do not import the Operating currentness service itself.

---

# 20. Preserve Prompt 60 Stage Two worktree

Do not touch it.

At the end of Prompt 63, re-open the primary worktree and verify:

- exact Response 62 tracked diff SHA unchanged;
- all 14 Stage Two new-file hashes unchanged;
- index still empty;
- branch/HEAD/upstream unchanged.

The repair worktree is the only worktree allowed to contain Prompt 63 source/test
changes.

---

# 21. Tests

Use isolated fixtures/temp stores only.

At minimum prove:

1. exact repair predicate accepts coverage FALSE + archive available only;
2. archive unavailable does not execute this coordinator;
3. coverage UNKNOWN does not execute this coordinator;
4. stale assessment generation cannot execute;
5. startup coverage and repair use one shared required-key definition;
6. keyset pagination is deterministic and bounded;
7. no-record + exact source available is automatically repairable;
8. no-record + source absent remains uncovered/manual;
9. source UNKNOWN is not called absent;
10. retained imported path cannot override fresh authoritative source metadata;
11. repair writer requires callback-local capability/lease;
12. no nested Ball;
13. no direct coordinator filesystem write;
14. payload durability precedes object-record commit;
15. interruption cannot create false-positive coverage;
16. successful committed object disappears from the next fresh uncovered set;
17. natural recomputation resumes without durable cursor;
18. automatic batching is bounded and single-flight;
19. stop/drain waits for in-flight writer and Ball release;
20. stale callback cannot publish after drain/new occurrence;
21. source-access loss drains/restarts rather than chaining;
22. archive generation change drains/restarts;
23. no-automatic-work remaining stays on human-action surface without restart
    loop;
24. explicit Check Again is fresh and single-flight;
25. coverage TRUE ends in real restart, not Operating handoff;
26. coverage FALSE never declares success;
27. coverage UNKNOWN restarts to fresh diagnostics;
28. no historical operation success/failure flag exists;
29. privacy-safe UI contains no filenames/message/contact content;
30. Data Update regressions pass;
31. Source Access Repair regressions pass;
32. Stage One Operating regressions pass;
33. Prompt 59 coverage regressions pass;
34. production startup remains unchanged;
35. AppCzar top-level execution census becomes exactly:
    - Data Update coordinator
    - Source Access Repair coordinator
    - Attachment Archive Repair coordinator
    - Operating admitted session
    with Onboarding/Local Repair/Diagnostic Review virtual.

---

# 22. Human qualification artifact

Build but do not launch the repair artifact in Prompt 63.

Human qualification will be a separate prompt.

It must use the exact repair-worktree artifact and explicitly authorize real
archive mutation before any automatic preservation occurs.

That future qualification should first observe the coordinator's fresh
partition and current source-available count before allowing bulk work.

Do not automatically repair the real 13,841-item deficit merely because the
coordinator has been implemented.

---

# 23. Validation

Run in the repair worktree:

1. focused shared evidence-reader tests;
2. repair selection/controller tests;
3. callback-local writer tests;
4. drain/lifecycle tests;
5. Prompt 59 coverage regressions;
6. attachment archive service regressions;
7. mutation/Ball regressions;
8. Data Update regressions;
9. Source Access Repair regressions;
10. Stage One Operating regressions;
11. AppCzar host/disposition tests;
12. architecture suite;
13. analyzer;
14. full deterministic Flutter suite;
15. `git diff --check`;
16. formatting/generated consistency;
17. debug macOS development build.

Do not launch production.

---

# 24. Project Conformance

Require:

`PROJECT CONFORMANCE: PASS`

with:

- BLOCKER: 0
- SHOULD FIX: 0

Specifically verify:

- one shared required-set definition;
- exact coverage-incomplete execution predicate;
- no repair on archive-unavailable or UNKNOWN coverage;
- current source evidence governs automatic repair;
- no historical operation state;
- callback-local existing mutation authority;
- no nested Ball;
- payload-before-record ordering;
- natural recomputation/resume;
- no restart loop for manual-only deficits;
- drain before quit/restart;
- no coordinator chaining;
- four live development AppCzar categories exactly as specified;
- production startup unchanged;
- primary Prompt 60 worktree untouched.

If current architecture cannot provide a safe callback-local writer without
bypassing archive invariants, STOP with a BLOCKER rather than writing around it.

---

# 25. Leave repair implementation unstaged

Do not stage, commit, push, merge, or rebase Prompt 63 implementation.

Build the exact repair-worktree development artifact.

Provide:

- repair worktree path;
- repair branch;
- bundle path;
- version/build;
- executable SHA-256;
- App.framework SHA-256;
- repair-worktree Git/index/submodule state;
- primary Prompt 60 worktree integrity proof;
- readiness for a separate human Attachment Archive Repair qualification.

Then STOP.

---

# 26. Required response

Create Response 63 and report:

1. primary-worktree baseline/integrity verification;
2. repair worktree creation/path/branch/base commit;
3. exact repair execution predicate;
4. AppCzar top-level execution census after implementation;
5. shared key-level evidence-reader design;
6. proof startup coverage and repair share one required-set definition;
7. pagination/batching design;
8. authoritative source-evidence reader;
9. no-record automatic repair classification;
10. record-backed defect handling;
11. callback-local writer seam;
12. mutation-tenure path;
13. payload/object-record crash-safe ordering;
14. coordinator jurisdiction;
15. internal sub-operations;
16. automatic batch behavior;
17. natural interruption/resume semantics;
18. manual/source-absent/UNKNOWN behavior;
19. no-restart-loop behavior;
20. Check Again behavior;
21. coverage TRUE terminal behavior;
22. coverage FALSE terminal behavior;
23. coverage UNKNOWN terminal behavior;
24. source-access-loss behavior;
25. archive identity/generation behavior;
26. repair stopAndDrain lifecycle;
27. progress/UI semantics;
28. privacy boundaries;
29. focused shared-reader tests;
30. repair controller tests;
31. writer/mutation tests;
32. drain/lifecycle tests;
33. Prompt 59 coverage regressions;
34. Data Update regressions;
35. Source Access Repair regressions;
36. Stage One Operating regressions;
37. architecture result;
38. analyzer result;
39. full Flutter-suite result;
40. diff/format/generated hygiene;
41. Project Conformance verdict;
42. BLOCKER findings;
43. SHOULD FIX findings;
44. exact repair build identity/path/hashes;
45. repair-worktree Git/worktree/index/submodule state;
46. primary Prompt 60 worktree final integrity proof;
47. readiness for human Attachment Archive Repair qualification.

Conclude exactly:

`ATTACHMENT ARCHIVE REPAIR IMPLEMENTED: YES / NO`

`REPAIR USES ONE SHARED REQUIRED-ATTACHMENT DEFINITION: YES / NO`

`REPAIR AUTOMATICALLY MUTATES ONLY CURRENTLY PROVEN SOURCE-AVAILABLE ITEMS: YES / NO`

`REPAIR USES HISTORICAL OPERATION SUCCESS/FAILURE STATE: YES / NO`

`PRIMARY OPERATING-STAGE-TWO WORKTREE REMAINS BYTE-FOR-BYTE INTACT: YES / NO`

`READY FOR HUMAN ATTACHMENT ARCHIVE REPAIR QUALIFICATION: YES / NO`

Then STOP.
