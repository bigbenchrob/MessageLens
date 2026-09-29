# MessageLens Feature 34 / Feature 35
## 15 — Merge Integrated Main into Frozen Onboarding Without Rebase

Date: 2026-09-27

## Executive result

The merge was **not attempted** because the mandatory path-overlap preflight
found one frozen untracked path that integrated `main` would create as a
tracked file:

`_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/35-EXCLUSIVE-AUTHORITY-TENURE/prompts/01-FREEZE-ONBOARDING-AND-EXCLUSIVE-AUTHORITY-AUDIT.md`

The worktree copy and the `main` blob are byte-identical (16,832 bytes,
SHA-256 `c9db5a397e0e4fd5298c2796fb380d5cad963e20e47a1a1dc6d6368eb90c0549`).
That does not make the merge safe under Prompt 14: the merge would still
reinterpret a frozen untracked worktree path as committed tracked content, and
Git may refuse to overwrite it. Prompt 14 expressly requires a stop before
`git merge` in this situation.

No frozen byte was changed, removed, staged, stashed, reset, cleaned,
restored, committed, or merged. No implementation correction was begun.

## 1. Initial topology

Remote refs were fetched with `git fetch --prune origin` before the preflight.

- local `main`:
  `b67bfafc3ad4f4f0c15792f0245bfecf5e45f43f`
- `origin/main`:
  `b67bfafc3ad4f4f0c15792f0245bfecf5e45f43f`
- `fix/onboarding-import-stuck-state`:
  `622a4d25842f15817ec93f2dc5866627189a68ad`
- merge base:
  `fe14793bbee8622b08829c4973a1e6ae218e8bb2`

Relevant worktrees:

| Worktree | Branch | HEAD |
| --- | --- | --- |
| `/Users/rob/Development/FlutterProjects/remember_every_text` | `fix/onboarding-import-stuck-state` | `622a4d25842f15817ec93f2dc5866627189a68ad` |
| `/Users/rob/Development/FlutterProjects/remember_every_text-feature-35` | `feature/exclusive-authority-tenure` | `09b1c767cc01410da5799273206e2ab2a4d3b283` |
| `/Users/rob/Development/FlutterProjects/remember_every_text-main` | `main` | `b67bfafc3ad4f4f0c15792f0245bfecf5e45f43f` |
| `/Users/rob/Development/FlutterProjects/remember_every_text.worktrees/gradle-fix-flutter-projects` | `agents/gradle-fix-flutter-projects` | `4f3e4fcc4eed2bd69eb237ae0aa328c917bbce37` |

## 2. Frozen Onboarding pre-check

All required preconditions matched before the safety census:

- branch: `fix/onboarding-import-stuck-state`;
- HEAD: `622a4d25842f15817ec93f2dc5866627189a68ad`;
- index: empty;
- tracked delta: 47 modified and 2 deleted files;
- untracked inventory: 76 fully enumerated paths;
- shared submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- `git diff --check`: passed.

## 3. Original preservation-hash verification

All five required hashes matched exactly:

| Artifact | Verified SHA-256 |
| --- | --- |
| parked patch | `43399bc44441e80fa65308ba4cf0d5bbea884b7c8a4501ad40eb6f10752e2b07` |
| tracked frozen delta | `d1a5db501b91b46f83a8c77d5bd10dc40853d8d8a955eda331bcd0084d149b2c` |
| Journey projection | `85a99027d0f48715845b5d8dde1fc280198d66b3b6e797e9842e050605658ef` |
| Journey architecture test | `7355f8510a130db6abe28264d0f9612ce36cbc2c3108a1433a3958597db4245b` |
| prior preservation manifest | `c7299bdbc8e41f52aa65ba9cb10b70fbfa11a93661d834bccc466dcfdf7461ef` |

## 4. New complete preservation manifest

The complete pre-merge record is at:

`/private/tmp/messagelens-onboarding-premerge.YsJztx`

Its manifest is:

`/private/tmp/messagelens-onboarding-premerge.YsJztx/MANIFEST.json`

Manifest SHA-256:

`bec7508c4a0a848ce82750d6477ec030cd99fd96fb66c6c9ce8c05c50e2ba02b`

The record contains the branch/HEAD and index evidence, all 49 tracked dirty
path states and per-file hashes/absence markers, all 76 untracked path
types/hashes, submodule state, `git diff --binary --full-index`, and
`git status --porcelain=v2 --untracked-files=all`.

The newly captured old-base tracked delta also has the expected SHA-256
`d1a5db501b91b46f83a8c77d5bd10dc40853d8d8a955eda331bcd0084d149b2c`.

## 5. Main-changed path census

The required direct comparison
`622a4d25842f15817ec93f2dc5866627189a68ad..b67bfafc3ad4f4f0c15792f0245bfecf5e45f43f`
contains 40 paths:

- 2 modified canonical Onboarding documents whose committed versions differ
  between the frozen branch and `main`;
- 24 added Feature 35 prompt/response records;
- 14 Feature 35 production/generated/test paths (including the adapted
  archive coordinator, the exclusive-authority module, its architecture test,
  and focused registry/coordinator tests).

For actual three-way merge mechanics, the `main` side changes 38 paths from
the common merge base; the frozen Onboarding committed side changes the two
canonical Onboarding documents. This distinction does not remove the
untracked collision, which is in the actual 38-path `main` merge side.

## 6. Tracked dirty-path intersection

Result: **none**.

Neither the required 40-path direct comparison nor the 38-path actual `main`
merge side intersects any of the 49 dirty/deleted tracked Onboarding paths.

The shared-submodule pointer is also absent from both changed sets.

## 7. Untracked-path intersection

Result: **one exact collision**.

Integrated `main` adds:

`_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/35-EXCLUSIVE-AUTHORITY-TENURE/prompts/01-FREEZE-ONBOARDING-AND-EXCLUSIVE-AUTHORITY-AUDIT.md`

The frozen worktree already contains that exact path as an untracked regular
file. Both byte streams currently have SHA-256
`c9db5a397e0e4fd5298c2796fb380d5cad963e20e47a1a1dc6d6368eb90c0549`,
but their Git classifications differ. No other exact or ancestor/descendant
collision was found among the 76 untracked paths.

## 8. Merge safety verdict

**NOT SAFE TO ATTEMPT UNDER PROMPT 14.**

Even byte-identical content would be reinterpreted from frozen untracked
content to a tracked `main` path. This meets the prompt's explicit stop
condition for a path that may be overwritten, replaced, or reinterpreted.

## 9. Merge command/method

The authorized method would have been:

`git merge --no-ff main`

with subject `merge: bring exclusive authority tenure into onboarding repair`.

The command was **not run**. No merge, rebase, squash, cherry-pick, stash,
autostash, temporary commit, reset, clean, or restore was attempted.

## 10. Merge commit SHA/subject

Not applicable. No merge commit exists because the safety gate failed before
merge invocation.

## 11. Resulting topology

Topology is unchanged:

- Onboarding remains at
  `622a4d25842f15817ec93f2dc5866627189a68ad`;
- `main` and `origin/main` remain at
  `b67bfafc3ad4f4f0c15792f0245bfecf5e45f43f`;
- merge base remains
  `fe14793bbee8622b08829c4973a1e6ae218e8bb2`;
- no rewrite and no new parent relationship occurred.

## 12. Byte-for-byte tracked working-delta verification

Before writing this required response, the new manifest verifier rechecked all
49 tracked entries. Every modified tracked file retained its recorded
size/type/SHA-256 and both tracked deletions remained absent.

Result: **49 of 49 matched; no errors**.

## 13. Byte-for-byte untracked verification

Before writing this required response, the verifier rechecked every one of the
76 pre-existing untracked entries and the complete untracked path inventory.

Result: **76 of 76 matched; no errors**.

This response is the sole intentionally new 77th untracked path created after
that proof. None of the 76 recorded paths was altered or absorbed.

## 14. Shared-submodule verification

The parent pointer and submodule HEAD remain
`95326f515ef4719f155ce6e223990398daad6311`, and the submodule worktree remains
clean. There was no submodule-pointer intersection.

## 15. Feature 35 availability verification

Feature 35 is present on integrated `main`, but it was not made available in
the frozen Onboarding branch because the merge was not permitted to run.

Consequently the frozen branch HEAD does not yet contain the reviewed
`ExclusiveAuthorityRegistry`, `ExclusiveAuthorityKey.archiveMutation`,
`ExclusiveAuthorityTenure`, generic registry provider, adapted coordinator,
private archive Zone bridge, or Feature 35 architecture tests. No attempt was
made to import or use them from the dirty Onboarding implementation.

## 16. Narrow Feature 35 test results

Not run. Prompt 14 orders an immediate stop before merge when a collision is
found. Running post-merge foundation tests without a merge would not satisfy
the requested proof and could not authorize bypassing the stop gate.

## 17. `git diff --check`

Passed before the census and passed again after the stopped preflight, before
this response was written.

## 18. Original preservation hashes after the stopped merge attempt

There was no merge attempt. All five original artifacts remained unchanged at
the hashes reported in section 3; the parked patch remains unapplied.

## 19. New full-worktree manifest comparison

The verifier reported:

- manifest SHA-256:
  `bec7508c4a0a848ce82750d6477ec030cd99fd96fb66c6c9ce8c05c50e2ba02b`;
- current HEAD:
  `622a4d25842f15817ec93f2dc5866627189a68ad`;
- tracked entries checked: 49;
- untracked entries checked: 76;
- byte/type match: `true`;
- errors: none.

That complete comparison occurred after the collision census and before this
required response was added. The response does not replace or alter any
manifested path.

## 20. Exact final Git status

- branch/HEAD: `fix/onboarding-import-stuck-state` /
  `622a4d25842f15817ec93f2dc5866627189a68ad`;
- index: empty;
- tracked worktree: the same 47 modified and 2 deleted paths;
- untracked worktree: the same manifested 76 paths plus this response (77);
- shared submodule: clean and unchanged at
  `95326f515ef4719f155ce6e223990398daad6311`;
- no merge state, conflict state, stash, commit, or push.

## 21. Stop gates encountered

One mandatory stop gate was encountered: an actual `main`-side tracked
addition collides with a frozen untracked path. The next prompt must choose a
reconstruction strategy. Per Prompt 14, no attempt was made to solve the
collision in this task.

MessageLens Development was not launched. No real database, attachment
archive, application configuration, or parked operation was accessed or
modified.

## 22. Readiness for minimal Onboarding tenure-correction design

**NO.** Integrated `main` has not yet been merged into the frozen Onboarding
branch, so the required Feature 35 API is not established in that branch.
The collision must first be handled by a separately authorized reconstruction
strategy that preserves the frozen worktree evidence.

`INTEGRATED MAIN MERGED INTO FROZEN ONBOARDING BRANCH: NO`
