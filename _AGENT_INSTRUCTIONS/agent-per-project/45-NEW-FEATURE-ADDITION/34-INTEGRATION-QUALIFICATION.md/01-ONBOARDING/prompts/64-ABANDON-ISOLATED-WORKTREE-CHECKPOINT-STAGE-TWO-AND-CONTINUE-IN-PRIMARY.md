# MessageLens Feature 34
## 64 — Abandon Isolated Repair Worktree, Checkpoint Operating Stage Two, and Continue in the Primary Worktree

The isolated `/private/tmp` Attachment Archive Repair worktree was a process mistake.

Its purpose was to preserve the exact Prompt 60 Operating Stage Two tree while
that implementation remained human-unqualified. In practice it adds unnecessary
friction:

- VS Code does not naturally show the worktree;
- it produces workspace-trust warnings;
- Feature 34 is split across two development roots;
- the repair branch starts from an older committed base and will eventually need
  reconciliation with Prompt 60 anyway.

Git already provides the correct preservation mechanism.

A commit may preserve an implementation that has passed automated validation
while its live human qualification remains pending. Qualification status belongs
in the evidence/documentation, not in whether the implementation remains
unstaged.

Therefore:

> **Return Feature 34 development to the primary worktree. Safely checkpoint
> Prompt 60 Operating Stage Two as "implemented and automated-test qualified;
> human live qualification not reached", abandon the isolated repair-worktree
> strategy, then continue Attachment Archive Repair in the primary worktree.**

Do not misrepresent Prompt 61 as a PASS.

Prompt 61 was **NOT REACHED / AMBIGUOUS** because fresh AppCzar correctly refused
Operating when real attachment coverage was FALSE.

---

# 1. Primary worktree

Primary worktree:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Expected committed base:

`ac56ea84bd2e301b592b3ca2ae20b8297523cf7e`

Expected Prompt 60 state:

- 18 tracked Stage Two modified files;
- 14 new Stage Two source/generated/test files;
- index empty;
- tracked Prompt 60 diff SHA-256:
  `9430b7970bf251826dd3f58d78abf6a7c92ffe8475925b4fe167f90ab0d2103c`;
- shared-instructions submodule clean at:
  `95326f515ef4719f155ce6e223990398daad6311`.

First verify this exact state.

Also verify that Prompt 62 itself made no production/test changes and that the
Stage Two tree remains byte-for-byte intact.

If the primary Prompt 60 implementation has changed, STOP AND REPORT.

---

# 2. Inspect the isolated repair worktree before abandoning it

Expected isolated worktree:

`/private/tmp/messagelens-appczar-attachment-archive-repair`

Expected branch:

`feature/appczar-attachment-archive-repair`

Do not assume whether Prompt 63 made edits.

Inspect and report:

- branch;
- HEAD;
- tracked modifications;
- untracked files;
- staged changes;
- commits created;
- whether any implementation work exists that is not already represented in the
  primary tree.

If the isolated worktree contains substantive Prompt 63 implementation edits,
DO NOT delete or discard it yet.

Instead:

1. create a complete manifest;
2. preserve its diff externally;
3. report exactly what exists;
4. STOP before removing the worktree.

If the isolated worktree contains only planning/documentation/no substantive
implementation, it may be safely removed after the primary Stage Two checkpoint
is complete.

Do not ask the human to add the `/private/tmp` worktree to VS Code.

---

# 3. Revalidate Prompt 60 Stage Two before checkpointing

Prompt 60 automated validation was previously:

- focused Operating Session tests: 47/47;
- worker/coverage/mutation regressions: 105/105;
- Stage One startup/Operating matrix: 13/13;
- Data Update: 11/11;
- Source Access Repair: 7/7;
- architecture: 579/579;
- analyzer: clean;
- complete deterministic Flutter suite:
  2,915 passed + 1 intentional skip;
- debug build:
  `0.2.135 (153)`.

Before committing, rerun the appropriate validation against the exact current
primary Stage Two tree.

At minimum:

1. focused Operating Session tests;
2. attachment coverage regressions;
3. mutation/Ball regressions;
4. Data Update regressions;
5. Source Access Repair regressions;
6. architecture suite;
7. analyzer;
8. full deterministic Flutter suite;
9. `git diff --check`;
10. formatting/generated consistency;
11. debug macOS development build.

Do not launch the app.

If the tree no longer reproduces Prompt 60's passing validation, STOP AND
REPORT.

---

# 4. Checkpoint Operating Stage Two

Create a narrow implementation commit containing only Prompt 60 Stage Two
source/test/generated/release-metadata changes.

Recommended subject:

`feat(startup): add operating-owned live currentness`

Do not use `git add .`.

Then create a documentation checkpoint containing the relevant Feature 34
records since the last documentation anchor, including:

- Prompt 60;
- Response 60;
- Prompt 61;
- Response 61;
- Prompt 62;
- Response 62;
- this Prompt 64.

Use the existing Feature 34 documentation convention.

The documentation must explicitly preserve this status:

```text
Operating-owned live currentness:
    IMPLEMENTED: YES
    AUTOMATED VALIDATION: PASS
    HUMAN LIVE QUALIFICATION: NOT REACHED / PENDING
```

and the reason:

```text
fresh AppCzar correctly blocked Operating because
attachment coverage was conclusively FALSE
```

Do not rewrite Prompt 61 into a successful qualification.

Push the branch normally as a recovery anchor.

No force push, rebase, merge, or PR merge.

---

# 5. New governing interpretation of checkpoint vs qualification

Record explicitly:

> A checkpoint preserves a known implementation state.
> A qualification establishes empirical confidence in that state.
> Checkpointing does not imply qualification.

This allows Feature 34 to proceed without keeping valid code indefinitely
unstaged.

---

# 6. Return Attachment Archive Repair development to the primary worktree

After the Stage Two checkpoint/push:

- primary branch remains the active Feature 34 development branch;
- Attachment Archive Repair work proceeds on top of the committed Stage Two
  code;
- do not create another repair worktree unless a future conflict genuinely
  requires one.

If the isolated worktree was confirmed empty of substantive implementation:

- remove the isolated worktree cleanly;
- delete its local branch only if safe and unneeded;
- verify no unrelated worktree was touched.

If substantive implementation exists there, STOP after preserving/reporting it
so that a separate reconciliation prompt can be written.

---

# 7. Continue with Attachment Archive Repair only if safe

If and only if:

- Prompt 60 Stage Two is checkpointed/pushed;
- primary tree is clean;
- isolated repair worktree contains no substantive unique implementation;

then begin Attachment Archive Repair directly in the primary worktree using the
Response 62 design.

The implementation requirements remain:

1. one shared typed required-attachment evidence reader;
2. exact coverage-incomplete execution predicate;
3. fresh authoritative source-path evidence;
4. callback-local archive writer seam;
5. existing Ball/mutation authority;
6. no nested Ball;
7. payload-before-record ordering;
8. bounded keyset repair batches;
9. natural recomputation instead of durable repair cursor;
10. source-absent / UNKNOWN / manual classes remain factual;
11. no automatic restart loop when nothing can be repaired;
12. fresh AppCzar owns the post-repair top-level decision.

Do not mutate the real archive in this prompt unless this task explicitly
reaches a separately authorized human qualification phase. By default, use
fixtures/temp stores only.

---

# 8. Preserve the refined AppCzar rule

Use this refined architecture rule:

> **No top-level coordinator may hand off semantic authority to another
> coordinator in-process. A coordinator may perform bounded internal work that
> leaves its own jurisdiction valid.**

Examples:

```text
Operating
-> ordinary small source delta
-> bounded internal update
-> postconditions TRUE
-> remain Operating
```

versus:

```text
repair/source/archive condition changes jurisdiction
-> stop/drain
-> real process restart
-> fresh AppCzar
```

Attachment Archive Repair itself remains a top-level coordinator.

---

# 9. No source-of-truth regression

Do not let this process change weaken any Prompt 59/62 invariant.

Still true:

- archive availability != archive coverage;
- coverage FALSE blocks Operating;
- coverage UNKNOWN is not FALSE;
- missing source bytes do not erase the preservation obligation;
- 13,841 uncovered keys are not automatically "lost";
- operation counters are not semantic authority;
- fresh current evidence governs coordinator selection.

---

# 10. Final repository state before repair implementation

Before beginning any repair edits, report:

- Stage Two implementation commit;
- Stage Two documentation commit;
- pushed recovery anchor;
- branch/upstream state;
- clean primary worktree/index;
- isolated-worktree disposition.

Then continue repair only if Section 7's conditions are satisfied.

---

# 11. Validation after repair implementation

If repair implementation proceeds in this same prompt, run the complete
validation appropriate to that code:

1. shared evidence-reader tests;
2. repair predicate/controller tests;
3. callback-local writer tests;
4. repair drain/lifecycle tests;
5. Prompt 59 coverage regressions;
6. Operating Stage Two regressions;
7. Data Update regressions;
8. Source Access Repair regressions;
9. mutation/Ball regressions;
10. architecture suite;
11. analyzer;
12. full deterministic Flutter suite;
13. diff/format/generated hygiene;
14. debug macOS development build.

Do not launch production.

Leave the repair implementation unstaged for human qualification.

---

# 12. Stop gates

STOP AND REPORT if:

- primary Prompt 60 tree does not match the preserved Stage Two state;
- Prompt 60 automated validation no longer passes;
- isolated worktree contains substantive unique Prompt 63 implementation;
- Stage Two checkpoint would accidentally include unrelated files;
- repair requires weakening attachment coverage;
- repair requires a second required-set definition;
- repair requires nested mutation authority;
- repair requires historical semantic state;
- repair requires changing production startup behavior.

---

# 13. Required response

Create Response 64 and report:

1. primary Stage Two integrity verification;
2. isolated repair-worktree audit;
3. whether isolated worktree contained substantive unique implementation;
4. Prompt 60 revalidation results;
5. exact Stage Two implementation diff inventory;
6. Stage Two implementation checkpoint commit;
7. documentation checkpoint commit;
8. pushed recovery anchor;
9. explicit qualification-status wording;
10. branch/upstream state after checkpoint;
11. isolated worktree disposition;
12. proof primary worktree is back to normal single-tree development;
13. whether Attachment Archive Repair implementation proceeded;
14. if yes, exact repair architecture implemented;
15. if yes, repair focused-test results;
16. if yes, architecture/analyzer/full-suite results;
17. if yes, exact build identity/path/hashes;
18. final Git/worktree/index/submodule state;
19. readiness for Attachment Archive Repair human qualification;
20. readiness to rerun Prompt 61 after real coverage is legitimately repaired.

Conclude exactly:

`OPERATING STAGE TWO CHECKPOINTED: YES / NO`

`OPERATING STAGE TWO HUMAN LIVE QUALIFICATION STATUS: PENDING / PASS / FAIL`

`ISOLATED REPAIR WORKTREE SAFELY RETIRED: YES / NO / NOT YET`

`FEATURE 34 DEVELOPMENT RETURNED TO PRIMARY WORKTREE: YES / NO`

`ATTACHMENT ARCHIVE REPAIR IMPLEMENTATION PROCEEDED: YES / NO`

`READY FOR NEXT HUMAN QUALIFICATION: YES / NO`

Then STOP.
