# MessageLens Feature 34 / Feature 35
## 16 — Resolve the Identical Feature-Record Collision and Merge Integrated Main

The previous merge preflight correctly stopped before touching the frozen
Onboarding worktree.

Exactly one collision exists:

`_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/35-EXCLUSIVE-AUTHORITY-TENURE/prompts/01-FREEZE-ONBOARDING-AND-EXCLUSIVE-AUTHORITY-AUDIT.md`

Current state:

- the frozen Onboarding worktree contains that path as an **untracked** file;
- integrated `main` contains that same path as a **tracked** file;
- the two byte streams are identical;
- size: 16,832 bytes;
- SHA-256:
  `c9db5a397e0e4fd5298c2796fb380d5cad963e20e47a1a1dc6d6368eb90c0549`;
- there are no tracked dirty-path intersections with the `main` merge side;
- there are no other untracked-path or ancestor/descendant collisions;
- the merge itself has not yet been attempted.

This task authorizes one controlled reconstruction:

> Preserve the colliding untracked file outside the repository, remove only that
> exact untracked worktree copy, merge integrated `main`, and prove that the
> resulting tracked file has exactly the same bytes.

This is an intentional **classification transition only**:

```text
before merge:
    path exists as frozen untracked file

after merge:
    same path exists as tracked main content
    exact same bytes
```

No Onboarding implementation byte may change.

Do NOT stash.
Do NOT create a WIP commit.
Do NOT stage the frozen implementation.
Do NOT reset or clean the worktree.
Do NOT rebase.
Do NOT modify any other frozen path.
Do NOT implement the Onboarding tenure correction yet.
Do NOT launch MessageLens Development.
Do NOT access real databases or attachment archives.
Do NOT push the Onboarding branch in this task.

---

# 1. Read the governing records

Read in full:

- the response to the previous stopped merge:
  `15-MERGE-INTEGRATED-MAIN-INTO-FROZEN-ONBOARDING.md`;
- Feature 35 integration response:
  `13-INTEGRATE-EXCLUSIVE-AUTHORITY-TENURE-INTO-MAIN.md`;
- the original Onboarding forensic/correction records;
- repository Git/worktree instructions.

The governing invariants remain:

> **Evidence may be distributed. Journey authority may not be.**

and:

> **The Ball proves exclusive tenure. Domain capability proves what the current
> owner may do while holding that Ball. Diagnostics prove neither.**

This task changes neither invariant.

---

# 2. Re-establish topology

Fetch refs read-only.

Require:

- local `main` =
  `b67bfafc3ad4f4f0c15792f0245bfecf5e45f43f`;
- `origin/main` =
  `b67bfafc3ad4f4f0c15792f0245bfecf5e45f43f`;
- frozen Onboarding branch =
  `fix/onboarding-import-stuck-state`;
- frozen Onboarding HEAD =
  `622a4d25842f15817ec93f2dc5866627189a68ad`.

If any ref differs, STOP AND REPORT.

---

# 3. Re-verify frozen Onboarding before controlled reconstruction

Worktree:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Require:

- index empty;
- tracked delta still exactly 47 modified and 2 deleted files;
- shared submodule clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- `git diff --check` passes;
- parked patch remains present and unapplied;
- all original preservation hashes still match.

The previous full-worktree preservation directory was:

`/private/tmp/messagelens-onboarding-premerge.YsJztx`

with manifest SHA-256:

`bec7508c4a0a848ce82750d6477ec030cd99fd96fb66c6c9ce8c05c50e2ba02b`

Verify it remains present and unchanged.

Because additional prompt/response control records may now exist, create a fresh
current-state manifest outside the repository before altering the collision.

Record every tracked dirty/deleted path and every current untracked path with
type and SHA-256.

---

# 4. Re-prove that the collision is singular and byte-identical

Repeat the changed-path/intersection census.

Require:

- zero intersections with the 49 tracked dirty/deleted Onboarding paths;
- zero submodule-pointer intersections;
- exactly one incoming tracked-vs-current-untracked collision;
- that collision is the exact Feature 35 Prompt 01 path above;
- no ancestor/descendant path collision;
- current untracked copy SHA-256 =
  `c9db5a397e0e4fd5298c2796fb380d5cad963e20e47a1a1dc6d6368eb90c0549`;
- integrated `main` blob for that path has the same SHA-256 and size.

If there is any additional collision or byte mismatch, STOP AND REPORT.

---

# 5. Create an explicit collision backup

Create a new unique directory under `/private/tmp/`.

Copy the colliding untracked file into it without modifying the source first.

Record:

- backup path;
- source SHA-256;
- backup SHA-256;
- source size;
- backup size.

Require byte identity.

Also save the Git blob from integrated `main` for the same path into the
preservation directory and verify all three byte streams are identical:

```text
frozen untracked copy
== temporary backup
== integrated-main tracked blob
```

Only after this three-way proof may the worktree copy be removed.

---

# 6. Remove only the colliding untracked worktree file

Remove exactly:

`_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/35-EXCLUSIVE-AUTHORITY-TENURE/prompts/01-FREEZE-ONBOARDING-AND-EXCLUSIVE-AUTHORITY-AUDIT.md`

Do not remove its parent directory.
Do not remove any sibling Feature 35 record.
Do not run `git clean`.
Do not use wildcard deletion.

Immediately verify:

- every tracked dirty/deleted Onboarding path still matches the current
  preservation manifest;
- every other pre-existing untracked path still matches;
- the only expected manifest mismatch is the deliberate temporary absence of
  this one collision path.

If anything else differs, restore the removed path from the backup and STOP.

---

# 7. Merge integrated main

Run in the frozen Onboarding worktree:

```text
git merge --no-ff main
```

Use repository-conventional subject:

`merge: bring exclusive authority tenure into onboarding repair`

Do not use autostash.

If Git refuses the merge or reports any conflict:

1. do not resolve it;
2. if a merge state exists, abort with `git merge --abort`;
3. restore the collision file from the verified backup if it is untracked/absent
   after abort;
4. re-run the current-state manifest verification;
5. STOP AND REPORT.

---

# 8. Verify the classification transition

After a successful merge, the collision path must now be tracked from `main`.

Verify:

- `git ls-files --error-unmatch <path>` succeeds;
- worktree file exists;
- worktree SHA-256 =
  `c9db5a397e0e4fd5298c2796fb380d5cad963e20e47a1a1dc6d6368eb90c0549`;
- tracked blob SHA-256 matches;
- temporary backup SHA-256 matches;
- file size remains 16,832 bytes;
- there is no worktree modification at that tracked path.

Do **not** copy the backup back over the tracked file; it should already contain
the exact bytes.

This one path is allowed to change Git classification from untracked to tracked.
Its content is not allowed to change.

---

# 9. Prove the entire frozen Onboarding implementation survived

Compare against the fresh pre-reconstruction manifest.

Require:

- all 49 tracked dirty/deleted Onboarding entries retain exact byte/type state;
- both tracked deletions remain absent;
- every pre-existing untracked path other than the collision remains exact;
- no other untracked path was absorbed, replaced, or removed;
- only the collision path changed classification;
- its bytes remain exact;
- shared submodule remains unchanged;
- index is empty after the merge commit.

Report the result explicitly as:

```text
Onboarding implementation byte changes caused by merge: 0
Controlled classification transitions: 1
```

If any other path differs, STOP AND REPORT.

---

# 10. Verify topology

Record:

- new Onboarding branch HEAD;
- merge commit SHA and subject;
- first parent =
  `622a4d25842f15817ec93f2dc5866627189a68ad`;
- second-parent ancestry contains integrated `main`
  `b67bfafc3ad4f4f0c15792f0245bfecf5e45f43f`;
- compact graph.

Require no rebase/rewrite.

Do not push.

---

# 11. Verify Feature 35 availability

Read-only verify that the merged Onboarding branch now contains:

- `ExclusiveAuthorityRegistry`;
- `ExclusiveAuthorityKey.archiveMutation`;
- `ExclusiveAuthorityTenure`;
- generic registry provider;
- adapted `ArchiveMutationCoordinator`;
- private archive Zone bridge;
- Feature 35 architecture tests.

Do not change Onboarding to use them yet.

---

# 12. Narrow foundation validation

Run only:

- `git diff --check`;
- Feature 35 architecture test;
- generic exclusive-authority registry tests;
- archive mutation coordinator tests.

Record exact results.

Do not run the complete repository suite yet. The existing dirty Onboarding
implementation still awaits its next architectural correction.

---

# 13. Preservation verification after merge

Recheck all original preservation artifacts.

Important distinction:

- the old-base `git diff --binary --full-index` artifact remains preserved as
  historical recovery evidence;
- its hash is not required to equal a newly generated post-merge diff because
  HEAD changed;
- per-file/content manifests are the authority for proving working-state
  preservation.

Recheck:

- parked patch hash;
- original preservation bundle;
- Journey projection hash;
- Journey architecture-test hash;
- old preservation manifest;
- fresh pre-reconstruction manifest;
- collision backup.

Keep all temporary preservation material until Onboarding reaches a new
checkpoint.

---

# 14. Do not implement the tenure correction

STOP after successful merge and verification.

Do NOT yet:

- edit Journey command predicates;
- edit Environment Readiness;
- alter maintenance reporting;
- add tenure/proof fields to Journey state;
- change presentation;
- change `ArchiveMutationCoordinator`;
- stage or commit the dirty Onboarding implementation;
- push the Onboarding branch.

The next prompt will inspect the current frozen implementation against Feature
35 and design the minimal self-maintenance correction.

---

# 15. Required response

Create the next sequential response in the existing Feature 34 Onboarding
responses folder.

Report:

1. initial topology;
2. frozen-state verification;
3. fresh preservation-manifest path/hash;
4. repeated overlap census;
5. three-way collision-byte proof;
6. collision backup path/hash;
7. controlled removal result;
8. merge command/result;
9. merge commit SHA/subject;
10. classification-transition proof;
11. tracked frozen-delta byte verification;
12. remaining-untracked byte verification;
13. shared-submodule verification;
14. resulting topology;
15. Feature 35 availability;
16. narrow validation results;
17. `git diff --check`;
18. original preservation-artifact verification;
19. fresh manifest comparison;
20. exact post-merge Git status;
21. stop gates encountered;
22. readiness for minimal Onboarding tenure-correction design.

Conclude exactly:

`INTEGRATED MAIN MERGED INTO FROZEN ONBOARDING BRANCH: YES / NO`

If YES, also conclude:

`ONBOARDING IMPLEMENTATION BYTES PRESERVED: YES / NO`

If YES, also conclude:

`ONLY CONTROLLED UNTRACKED-TO-TRACKED CLASSIFICATION TRANSITION: YES / NO`

If YES, also conclude:

`READY TO DESIGN MINIMAL ONBOARDING TENURE CORRECTION: YES / NO`

Then STOP.
