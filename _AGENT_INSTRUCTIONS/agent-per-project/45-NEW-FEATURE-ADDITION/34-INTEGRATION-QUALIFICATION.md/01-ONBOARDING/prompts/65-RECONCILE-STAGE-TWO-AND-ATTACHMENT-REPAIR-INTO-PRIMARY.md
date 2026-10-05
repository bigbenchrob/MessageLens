# MessageLens Feature 34
## 65 — Reconcile Operating Stage Two and Attachment Archive Repair into the Primary Worktree

Response 64 reached the correct stop gate.

The situation is now known exactly:

### Primary worktree

`/Users/rob/Development/FlutterProjects/remember_every_text`

contains the complete, unstaged Prompt 60 Operating Stage Two implementation:

- branch: `fix/onboarding-import-stuck-state`
- HEAD/upstream: `ac56ea84bd2e301b592b3ca2ae20b8297523cf7e`
- 18 tracked Stage Two modifications
- 14 new Stage Two source/generated/test paths
- index empty
- tracked Stage Two diff SHA-256:
  `9430b7970bf251826dd3f58d78abf6a7c92ffe8475925b4fe167f90ab0d2103c`

### Isolated repair worktree

`/private/tmp/messagelens-appczar-attachment-archive-repair`

contains a complete, substantive, unique Prompt 63 Attachment Archive Repair implementation:

- branch: `feature/appczar-attachment-archive-repair`
- HEAD/base: `ac56ea84bd2e301b592b3ca2ae20b8297523cf7e`
- 12 tracked modifications
- 27 untracked files
- index empty
- complete porcelain SHA-256:
  `acaff2f1766da622cdd1011ef06daa21c5a66a00a1fb4a126c9c9d94b8b32870`
- tracked ordinary/binary diff SHA-256:
  `68e90926f85b8b02790a913e70a46fa3d08bce90a8953eead86f70ba80003e57`

The two implementations share the same committed base. Five tracked paths overlap and therefore require semantic reconciliation; a wholesale patch from the repair tree into the primary tree is explicitly unsafe.

The goal of this task is:

> **Preserve each implementation as an ordinary Git checkpoint, merge their histories, semantically reconcile the overlapping AppCzar surfaces, fully validate the combined architecture, push one primary recovery anchor, and retire the temporary worktree.**

This is an integration/checkpoint task. It is **not** a human qualification task.

Do NOT mutate the real attachment archive.
Do NOT mutate real MessageLens databases.
Do NOT launch production MessageLens.
Do NOT claim Prompt 61 passed.
Do NOT claim Attachment Archive Repair is human-qualified.

---

# 1. Verify both preserved trees before changing anything

Verify the primary tree against Response 64:

- branch/HEAD/upstream;
- 18 tracked Stage Two modified paths;
- 14 new Stage Two code/test/generated paths;
- index empty;
- tracked diff SHA exactly `9430b7970bf251826dd3f58d78abf6a7c92ffe8475925b4fe167f90ab0d2103c`;
- all Prompt 60 file hashes match the preserved manifest;
- shared-instructions submodule clean at `95326f515ef4719f155ce6e223990398daad6311`.

Verify the isolated repair tree against Response 64:

- branch `feature/appczar-attachment-archive-repair`;
- HEAD `ac56ea84bd2e301b592b3ca2ae20b8297523cf7e`;
- 12 tracked modifications;
- 27 untracked files;
- index empty;
- complete porcelain SHA exactly `acaff2f1766da622cdd1011ef06daa21c5a66a00a1fb4a126c9c9d94b8b32870`;
- tracked ordinary/binary diff SHA exactly `68e90926f85b8b02790a913e70a46fa3d08bce90a8953eead86f70ba80003e57`;
- shared submodule at the same required commit.

Also verify the external Prompt 64 preservation bundle exists and validates.

If either live tree differs from the recorded state, STOP AND REPORT.

---

# 2. Enumerate the exact overlap before integration

Before staging either implementation, compute and report:

- primary-only changed paths;
- repair-only changed paths;
- exact overlapping changed paths;
- for every overlapping path, a semantic summary of:
  - what Stage Two changed;
  - what Attachment Archive Repair changed;
  - what the combined file must preserve.

Do not begin integration until this inventory is explicit.

The merge must preserve **both** architectures, not choose one side mechanically.

---

# 3. Revalidate the primary Prompt 60 tree

Run the Prompt 60 validation matrix in the primary worktree before checkpointing.

At minimum:

1. focused Operating Session tests;
2. worker/coverage/mutation regressions;
3. Stage One startup/Operating regressions;
4. Data Update regressions;
5. Source Access Repair regressions;
6. architecture suite;
7. analyzer;
8. full deterministic Flutter suite;
9. formatting/generated consistency;
10. `git diff --check`;
11. debug macOS development build.

Do not launch the app.

Expected historical evidence from Response 60 was:

- Operating: 47/47;
- worker/coverage/mutation: 105/105;
- Stage One: 13/13;
- Data Update: 11/11;
- Source Access Repair: 7/7;
- architecture: 579/579;
- analyzer clean;
- full suite: 2,915 passed + 1 intentional skip;
- build: `0.2.135 (153)`.

Current results govern.

If Prompt 60 no longer validates, STOP AND REPORT.

---

# 4. Checkpoint Prompt 60 in the primary branch

Create a narrow implementation commit containing only Prompt 60 Stage Two source/test/generated/release-metadata changes.

Recommended subject:

`feat(startup): add operating-owned live currentness`

Do not use `git add .`.

Then create a narrow documentation commit containing the appropriate Feature 34 records through Response 64 that belong in the primary history.

The documentation must preserve exactly:

```text
Operating-owned live currentness:
    IMPLEMENTED: YES
    AUTOMATED VALIDATION: PASS
    HUMAN LIVE QUALIFICATION: NOT REACHED / PENDING
```

Reason:

```text
fresh AppCzar correctly blocked Operating because
attachment coverage was conclusively FALSE
```

Prompt 61 remains AMBIGUOUS / NOT REACHED, not PASS.

Push the primary branch normally after these checkpoint commits so there is a remote recovery anchor before repair reconciliation.

Report both commit IDs and the pushed recovery anchor.

---

# 5. Revalidate the isolated Prompt 63 implementation

In the isolated repair worktree, rerun the Prompt 63 validation necessary to confirm the preserved tree still represents the implementation recorded in Response 63.

At minimum:

1. shared required-attachment evidence-reader tests;
2. repair predicate/controller tests;
3. callback-local writer/executor/scope tests;
4. repair drain/lifecycle tests;
5. Prompt 59 coverage regressions;
6. Data Update regressions;
7. Source Access Repair regressions;
8. Stage One Operating regressions available on that branch;
9. architecture suite;
10. analyzer;
11. full deterministic Flutter suite;
12. formatting/generated consistency;
13. `git diff --check`;
14. debug macOS development build.

Do not launch.

Response 64 preserves historical Prompt 63 evidence of:

- focused final-source matrix: 198 passing;
- architecture: 587/587;
- repeated conformance: 419/419;
- no repair-code analyzer errors/warnings, apart from two known vendored informational diagnostics;
- full suite: 2,946 passed + 1 intentional skip.

Current results govern.

If the preserved repair implementation no longer validates, STOP AND REPORT.

---

# 6. Checkpoint Prompt 63 on its repair branch

Checkpoint the isolated implementation before merging it.

Create a narrow implementation commit containing the complete Prompt 63 repair source/test/generated/release-metadata change set.

Recommended subject:

`feat(startup): add attachment archive repair coordinator`

Then create a narrow documentation commit containing Response 63 and any Prompt 63 documentation that belongs with that implementation.

Do not claim human qualification.

Record:

```text
Attachment Archive Repair:
    IMPLEMENTED: YES
    AUTOMATED VALIDATION: PASS
    HUMAN LIVE QUALIFICATION: PENDING
```

Do not push a separate remote repair branch unless required by existing project practice. The primary branch will become the durable remote integration anchor.

The repair worktree must be clean after its checkpoint commits.

---

# 7. Merge the repair branch into the primary branch

Return to the primary worktree.

Verify:

- primary tree is clean;
- Stage Two checkpoint is pushed;
- repair branch contains the exact Prompt 63 checkpoint;
- both histories descend from `ac56ea84bd2e301b592b3ca2ae20b8297523cf7e`.

Perform a normal history-preserving merge of `feature/appczar-attachment-archive-repair` into `fix/onboarding-import-stuck-state`.

Prefer a non-squashed merge.

Do not use a wholesale patch application.

Do not resolve overlapping files with `ours` or `theirs` wholesale.

Each overlapping file must be reconciled semantically.

---

# 8. Combined architecture that conflict resolution must preserve

The combined source must preserve all of the following simultaneously.

## Fresh AppCzar executable authorities

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

No generic enum dispatcher.

## Operating Session Stage Two

Operating retains:

- neutral fresh entry;
- Operating-owned 15-second currentness observer;
- no old ambient ChatDbChangeMonitor;
- bounded ordinary source-ahead live update;
- existing one-Ball mutation authority;
- post-worker fresh attachment-coverage verification;
- same-PID/same-navigation continuation only on valid postconditions;
- `stopAndDrain()` before Operating termination/restart;
- no in-process coordinator chaining.

## Attachment Archive Repair

Repair retains:

- execution only for coherent archive-available + coverage FALSE evidence;
- one shared required-attachment evidence definition with startup coverage;
- authoritative fresh source-path classification;
- callback-local existing archive writer;
- no nested Ball;
- payload-before-record durability;
- bounded batching;
- source-absent/UNKNOWN/manual factual classes;
- natural recomputation instead of durable semantic cursor;
- no restart loop when no automatic repair is possible;
- `stopAndDrain()` before repair termination/restart;
- no in-process handoff to Operating/Data Update/Source Access Repair.

## Fresh-process authority

A jurisdiction change still requires:

```text
stop
-> drain
-> real process restart
-> fresh AppCzar reassessment
```

Routine bounded internal work may remain in-process when the current jurisdiction's postconditions remain valid.

---

# 9. Attachment coverage remains the gate

Do not weaken Prompt 59 to make integration easier.

Still required:

```text
Operating
    implies
attachmentCoverageComplete == TRUE
```

Archive availability and archive coverage remain distinct.

Coverage FALSE with archive available selects Attachment Archive Repair.

Coverage UNKNOWN remains Diagnostic Review.

Archive unavailable must not accidentally execute Attachment Archive Repair unless separately and explicitly designed.

---

# 10. Shared evidence reader remains one source of truth

The combined tree must contain exactly one canonical definition of the conventional required attachment universe.

Both AppCzar startup coverage and Attachment Archive Repair must consume that same typed definition.

Do not preserve an older private copy from one branch during conflict resolution.

Architecture tests must make future drift difficult.

---

# 11. Reconcile mutation authority carefully

The combined tree contains two consumers of archive mutation authority:

1. Operating's bounded internal live-update path;
2. Attachment Archive Repair's bounded reconciliation path.

They must both use the existing shared mutation/Ball authority without creating parallel authority.

Required:

- no nested Ball;
- capability callback-local;
- generation-bound writable lease;
- exact operation type;
- no capability retained after callback;
- observer/read paths acquire no Ball.

If an enum/capability file changed independently in each branch, merge the operation cases rather than selecting one branch's version.

---

# 12. Reconcile lifecycle ownership

Both long-lived executable jurisdictions now have drain semantics.

Verify the combined app can distinguish and correctly drain:

- Operating currentness observation/update;
- Attachment Archive Repair observation/writer.

No lifecycle owner may be accidentally dropped from architecture inventories during merge conflict resolution.

If there are shared macOS exit hooks, ensure the currently admitted jurisdiction owns the exact drain being awaited.

Do not create two competing global exit listeners if a single routed lifecycle boundary is the project idiom.

---

# 13. Reconcile AppCzar host composition

The development startup host must select exactly one executable path from one fresh assessment.

Conceptually:

```text
assessment
    -> Data Update
    -> Source Access Repair
    -> Attachment Archive Repair
    -> Operating Session
    -> otherwise virtual presentation
```

Ordering must come from the evaluator's already-defined disposition, not independent ad hoc precedence checks.

Do not let Operating Stage Two start before exact Operating admission.

Do not let repair start merely because the enum name matches archive-root unavailability.

---

# 14. Release metadata

Reconcile `pubspec.yaml` and `CHANGELOG.md` deliberately.

Both branches were built as `0.2.135 (153)` from parallel trees.

The combined artifact must have one new, unique development build identity.

Follow the project's sequential version/build convention.

If the current committed version is still `0.2.135 (153)` and no newer version exists in the integrated history, the expected next combined development build is `0.2.136 (154)`.

Verify rather than blindly assuming this value.

Do not retain duplicate/conflicting changelog entries from both branches.

---

# 15. Combined regression tests

Add or adjust only the tests necessary to prove the integrated architecture.

At minimum prove:

1. exact top-level executable census is now Data Update coordinator, Source Access Repair coordinator, Attachment Archive Repair coordinator, and Operating admitted session;
2. Onboarding/Local Repair/Diagnostic Review remain virtual;
3. archive unavailable does not execute coverage repair;
4. coverage UNKNOWN does not execute coverage repair;
5. coverage FALSE + archive available does execute repair;
6. coverage TRUE may admit Operating when all other facts agree;
7. Operating currentness remains internal, not an AppCzar disposition;
8. Operating cannot invoke repair in-process;
9. repair cannot invoke Operating in-process;
10. both jurisdiction changes use real restart;
11. Operating `stopAndDrain()` still waits for active Ball release;
12. repair `stopAndDrain()` still waits for active writer/Ball release;
13. shared required-attachment evidence definition is singular;
14. post-live-update coverage TRUE is still required for Operating continuation;
15. successful Operating live update preserves same-session navigation;
16. repair successful object records disappear from a fresh uncovered set;
17. production startup remains unchanged.

---

# 16. Full combined validation

On the fully reconciled primary tree, run:

1. Operating currentness focused tests;
2. Attachment Archive Repair focused tests;
3. shared attachment evidence-reader tests;
4. Prompt 59 coverage regressions;
5. LiveGraphUpdateWorker regressions;
6. archive mutation/Ball regressions;
7. drain/lifecycle regressions for both jurisdictions;
8. Stage One Operating regressions;
9. Data Update regressions;
10. Source Access Repair regressions;
11. AppCzar host/disposition tests;
12. complete architecture suite;
13. analyzer;
14. full deterministic Flutter suite;
15. `git diff --check`;
16. formatting/generated consistency;
17. debug macOS development build.

Do not launch the app.

Require:

`PROJECT CONFORMANCE: PASS`

with:

- BLOCKER: 0
- SHOULD FIX: 0

If combined validation exposes a semantic conflict between Stage Two and repair, fix it in the combined primary tree and document the exact reason.

Do not weaken tests merely to complete the merge.

---

# 17. Commit the reconciliation

If the combined tree passes:

- complete the merge commit if using a no-commit merge workflow;
- create a narrow follow-up integration-fix commit only if semantic conflict resolution required changes beyond the merge itself;
- create/update the Feature 34 documentation checkpoint including Prompt 65 and Response 65;
- push the primary branch normally.

The pushed primary branch becomes the one remote recovery anchor containing both Stage Two and Attachment Archive Repair histories.

No force push, rebase, or squash.

---

# 18. Retire the isolated worktree only after remote preservation

After the combined primary branch is pushed:

1. verify the repair implementation commits are ancestors of primary HEAD;
2. verify primary upstream contains the combined history;
3. verify the isolated repair worktree is clean;
4. remove `/private/tmp/messagelens-appczar-attachment-archive-repair` using normal Git worktree removal;
5. delete local branch `feature/appczar-attachment-archive-repair` only after confirming it is fully merged;
6. do not touch unrelated worktrees.

The external Prompt 64 preservation bundle may remain as redundant recovery evidence; it does not need to be loaded into VS Code.

---

# 19. Human qualification status after integration

Do not overclaim.

The intended final status is:

```text
Operating Stage Two:
    implemented
    automated validation PASS
    human live qualification PENDING

Attachment Archive Repair:
    implemented
    automated validation PASS
    human live qualification PENDING
```

Prompt 61 still cannot be rerun until real attachment coverage is legitimately improved enough for fresh AppCzar to admit Operating.

The next task after this integration should be a **bounded human qualification of Attachment Archive Repair**, beginning with current factual partitioning before authorizing real archive mutation.

---

# 20. Build but do not launch

Produce the exact combined development artifact.

Report:

- bundle path;
- product;
- bundle identifier;
- version/build;
- executable SHA-256;
- App.framework SHA-256.

Do not launch it.

Do not mutate the real archive.

---

# 21. Stop gates

STOP AND REPORT if:

- either preserved tree fails its pre-integration hash verification;
- either implementation fails revalidation before checkpoint;
- the repair worktree cannot be cleanly checkpointed;
- overlap cannot be reconciled without weakening either architecture;
- combined source introduces a second required-attachment definition;
- combined source introduces nested/parallel mutation authority;
- AppCzar host can execute more than one top-level jurisdiction from one assessment;
- production startup behavior must change;
- combined tests cannot reach Project Conformance PASS.

Do not delete the isolated worktree until the combined implementation is committed, pushed, and proven to contain its history.

---

# 22. Required response

Create Response 65 and report:

1. primary pre-integration verification;
2. isolated pre-integration verification;
3. exact overlap inventory;
4. semantic requirement for every overlapping path;
5. Prompt 60 revalidation results;
6. Stage Two implementation checkpoint commit;
7. Stage Two documentation checkpoint commit;
8. Stage Two remote recovery anchor;
9. Prompt 63 revalidation results;
10. repair implementation checkpoint commit;
11. repair documentation checkpoint commit;
12. exact merge command/strategy;
13. merge conflicts encountered;
14. semantic resolution for every conflict;
15. combined AppCzar execution census;
16. combined host selection behavior;
17. Operating Stage Two preservation result;
18. Attachment Archive Repair preservation result;
19. shared required-evidence definition result;
20. combined mutation-authority result;
21. combined lifecycle/drain result;
22. attachment-coverage gate result;
23. release metadata/version result;
24. combined focused test results;
25. architecture result;
26. analyzer result;
27. full Flutter-suite result;
28. diff/format/generated hygiene;
29. Project Conformance verdict;
30. BLOCKER findings;
31. SHOULD FIX findings;
32. merge/integration commit IDs;
33. final pushed primary recovery anchor;
34. isolated-worktree retirement result;
35. local repair-branch retirement result;
36. exact combined build identity/path/hashes;
37. final primary Git/worktree/index/submodule state;
38. confirmation only one active Feature 34 development worktree remains;
39. Operating Stage Two human qualification status;
40. Attachment Archive Repair human qualification status;
41. readiness for bounded real Attachment Archive Repair qualification;
42. readiness to rerun Prompt 61 afterward.

Conclude exactly:

`OPERATING STAGE TWO CHECKPOINTED AND PRESERVED: YES / NO`

`ATTACHMENT ARCHIVE REPAIR CHECKPOINTED AND PRESERVED: YES / NO`

`COMBINED PRIMARY TREE PASSES PROJECT CONFORMANCE: YES / NO`

`ISOLATED REPAIR WORKTREE RETIRED: YES / NO`

`FEATURE 34 IS BACK TO ONE PRIMARY DEVELOPMENT WORKTREE: YES / NO`

`OPERATING STAGE TWO HUMAN LIVE QUALIFICATION: PENDING / PASS / FAIL`

`ATTACHMENT ARCHIVE REPAIR HUMAN LIVE QUALIFICATION: PENDING / PASS / FAIL`

`READY FOR BOUNDED REAL REPAIR QUALIFICATION: YES / NO`

Then STOP.
