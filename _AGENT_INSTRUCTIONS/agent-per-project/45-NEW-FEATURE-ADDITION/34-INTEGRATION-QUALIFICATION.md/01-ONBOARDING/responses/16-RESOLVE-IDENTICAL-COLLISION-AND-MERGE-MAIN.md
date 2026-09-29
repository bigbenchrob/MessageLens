# MessageLens Feature 34 / Feature 35
## 16 — Resolve the Identical Feature-Record Collision and Merge Integrated Main

Date: 2026-09-27

## Executive result

The single Feature 35 record collision was preserved, removed, and
reconstructed through the authorized merge. Integrated `main` is now merged
into the frozen Onboarding branch without rebase and without changing any
Onboarding implementation byte.

The colliding path changed from an untracked regular file to the reviewed
tracked `main` file. Its source, backup, `main` blob, post-merge worktree file,
and post-merge tracked blob all have the same 16,832 bytes and SHA-256:

`c9db5a397e0e4fd5298c2796fb380d5cad963e20e47a1a1dc6d6368eb90c0549`

Onboarding implementation byte changes caused by merge: **0**

Controlled classification transitions: **1**

## 1. Initial topology

After `git fetch --prune origin`:

- local `main`:
  `b67bfafc3ad4f4f0c15792f0245bfecf5e45f43f`;
- `origin/main`:
  `b67bfafc3ad4f4f0c15792f0245bfecf5e45f43f`;
- frozen Onboarding branch:
  `fix/onboarding-import-stuck-state`;
- frozen Onboarding HEAD:
  `622a4d25842f15817ec93f2dc5866627189a68ad`;
- merge base:
  `fe14793bbee8622b08829c4973a1e6ae218e8bb2`.

Relevant worktrees remained:

| Worktree | Branch | Initial HEAD |
| --- | --- | --- |
| `/Users/rob/Development/FlutterProjects/remember_every_text` | `fix/onboarding-import-stuck-state` | `622a4d25842f15817ec93f2dc5866627189a68ad` |
| `/Users/rob/Development/FlutterProjects/remember_every_text-feature-35` | `feature/exclusive-authority-tenure` | `09b1c767cc01410da5799273206e2ab2a4d3b283` |
| `/Users/rob/Development/FlutterProjects/remember_every_text-main` | `main` | `b67bfafc3ad4f4f0c15792f0245bfecf5e45f43f` |
| `/Users/rob/Development/FlutterProjects/remember_every_text.worktrees/gradle-fix-flutter-projects` | `agents/gradle-fix-flutter-projects` | `4f3e4fcc4eed2bd69eb237ae0aa328c917bbce37` |

## 2. Frozen-state verification

Before controlled reconstruction:

- index: empty;
- tracked worktree: exactly 47 modified and 2 deleted paths;
- untracked worktree: 78 fully enumerated paths (the prior 76 plus Response 15
  and Prompt 16);
- shared submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- `git diff --check`: passed;
- parked patch: present, unchanged, and unapplied;
- all five original preservation hashes: exact match;
- prior full-worktree manifest: present and unchanged at SHA-256
  `bec7508c4a0a848ce82750d6477ec030cd99fd96fb66c6c9ce8c05c50e2ba02b`.

The prior manifest rechecked all 49 tracked entries and all 76 originally
recorded untracked entries successfully. Response 15 and Prompt 16 were the
only two expected additional paths.

## 3. Fresh preservation manifest

Fresh current-state preservation directory:

`/private/tmp/messagelens-onboarding-reconstruction.rDjAiX`

Manifest:

`/private/tmp/messagelens-onboarding-reconstruction.rDjAiX/MANIFEST.json`

Manifest SHA-256:

`ca1acf28c3c5f0393499c1965f4627a95c6b882638204678af1c8c6a1ee104d1`

It records every one of the 49 dirty/deleted tracked paths and all 78 current
untracked paths with type/content evidence, plus index, submodule,
`git diff --binary --full-index`, and porcelain-v2 status evidence. It
self-verified exactly before any collision operation.

## 4. Repeated overlap census

The direct frozen-HEAD-to-`main` census contained 40 changed paths. The actual
`main` side of the three-way merge contained 38 paths from the common base.

- dirty/deleted tracked paths: 49;
- tracked-path intersections: 0;
- submodule-pointer intersections: 0;
- current untracked paths: 78;
- exact or ancestor/descendant collisions: exactly 1;
- additional collisions: 0.

The sole collision was:

`_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/35-EXCLUSIVE-AUTHORITY-TENURE/prompts/01-FREEZE-ONBOARDING-AND-EXCLUSIVE-AUTHORITY-AUDIT.md`

## 5. Three-way collision-byte proof

Before removal, all three byte streams were independently captured and
verified:

| Stream | Size | SHA-256 |
| --- | ---: | --- |
| frozen untracked worktree file | 16,832 | `c9db5a397e0e4fd5298c2796fb380d5cad963e20e47a1a1dc6d6368eb90c0549` |
| temporary backup | 16,832 | `c9db5a397e0e4fd5298c2796fb380d5cad963e20e47a1a1dc6d6368eb90c0549` |
| integrated-`main` tracked blob | 16,832 | `c9db5a397e0e4fd5298c2796fb380d5cad963e20e47a1a1dc6d6368eb90c0549` |

Result: **three-way byte identity proved**.

## 6. Collision backup

Backup directory:

`/private/tmp/messagelens-feature35-collision-backup.uXvI4e`

Backup file:

`/private/tmp/messagelens-feature35-collision-backup.uXvI4e/frozen-untracked-copy.md`

Saved integrated-`main` blob:

`/private/tmp/messagelens-feature35-collision-backup.uXvI4e/integrated-main-tracked-blob.md`

Backup manifest SHA-256:

`194aea987081eadc9f9a687b62829375090eb164a7639f72bd0668e29f5f3b5e`

Both saved byte streams retain SHA-256 `c9db5a397e...` and size 16,832.

## 7. Controlled removal result

Only the exact colliding untracked file was removed. Its parent directory and
all siblings remained in place.

The immediate `collision-absent` verification reported:

- all 49 tracked entries exact;
- all other 77 untracked entries exact;
- current untracked count: 77;
- the collision was the sole expected absence;
- index empty;
- submodule unchanged;
- errors: none.

No wildcard, `git clean`, stash, reset, restore, or temporary commit was used.

## 8. Merge command and result

Command:

`git merge --no-ff --no-autostash main -m "merge: bring exclusive authority tenure into onboarding repair"`

Result: **success using the `ort` strategy, with no conflict or refusal**.

No merge abort or backup restoration was required.

## 9. Merge commit

- SHA: `276fa1b820b07bf14f41fe216192456b5415e290`;
- subject: `merge: bring exclusive authority tenure into onboarding repair`;
- tree: `b5452c73f26a0dc188818aefe845ee4f34ae6d4c`.

## 10. Classification-transition proof

After merge:

- `git ls-files --error-unmatch` succeeds for the collision path;
- the worktree file exists as a regular tracked file;
- worktree size: 16,832 bytes;
- worktree SHA-256: `c9db5a397e...`;
- tracked `HEAD` blob SHA-256: `c9db5a397e...`;
- temporary backup SHA-256: `c9db5a397e...`;
- saved integrated-`main` blob SHA-256: `c9db5a397e...`;
- `git diff -- <collision-path>` is empty.

The original untracked file had filesystem mode `0600`. The reviewed tracked
Git entry is `100644`, so checkout materialized it as `0644`. This is the
expected tracked-file mode supplied by `main`; the file remains a regular
file, its bytes are exact, and it has no worktree modification. The backup was
not copied over the tracked file.

Result: **one controlled untracked-to-tracked transition, with exact content**.

## 11. Tracked frozen-delta byte verification

The post-merge verifier checked every one of the 49 pre-merge tracked entries:

- 47 modified files retained exact type, size, and SHA-256;
- both tracked deletions remained absent;
- implementation byte mismatches: 0.

`Onboarding implementation byte changes caused by merge: 0`

## 12. Remaining-untracked byte verification

Every pre-existing untracked path other than the controlled collision retained
its exact recorded type, size, and SHA-256. No other untracked path was
absorbed, replaced, removed, or changed.

- manifest untracked entries: 78;
- controlled path transitioned to tracked: 1;
- remaining untracked immediately after merge: 77;
- mismatches among remaining paths: 0.

`Controlled classification transitions: 1`

## 13. Shared-submodule verification

The parent pointer and submodule HEAD remain
`95326f515ef4719f155ce6e223990398daad6311`. The shared-instructions submodule
worktree remains clean.

## 14. Resulting topology

The new Onboarding branch HEAD is merge commit
`276fa1b820b07bf14f41fe216192456b5415e290`.

- first parent:
  `622a4d25842f15817ec93f2dc5866627189a68ad`;
- second parent:
  `b67bfafc3ad4f4f0c15792f0245bfecf5e45f43f`;
- the first-parent ancestry contains the frozen Onboarding checkpoint;
- the second parent is exactly integrated `main`;
- no rebase, squash, cherry-pick, or rewrite occurred;
- `main` and `origin/main` remain at `b67bfafc...`;
- the Onboarding branch was not pushed.

Compact graph:

```text
*   276fa1b8 (fix/onboarding-import-stuck-state) merge: bring exclusive authority tenure into onboarding repair
|\
| *   b67bfafc (main, origin/main) merge: integrate exclusive authority tenure
| |\
| | * 09b1c767 (feature/exclusive-authority-tenure) feat(architecture): add exclusive authority tenure
| |/
* / 622a4d25 docs(onboarding): restore journey-only authority
|/
* fe14793b docs(integration): record main qualification
```

## 15. Feature 35 availability

Read-only source verification confirms the merged Onboarding branch contains:

- `ExclusiveAuthorityRegistry`;
- `ExclusiveAuthorityKey.archiveMutation`;
- `ExclusiveAuthorityTenure`;
- the generic registry provider and generated provider;
- the adapted `ArchiveMutationCoordinator`;
- its private archive Zone bridge;
- the reviewed Feature 35 architecture tests.

The frozen Onboarding code was not changed to import or use these APIs.

## 16. Narrow validation results

| Scope | Result |
| --- | ---: |
| Feature 35 architecture test | **42 passed, 0 failed** |
| Generic exclusive-authority registry tests | **23 passed, 0 failed** |
| Archive mutation coordinator tests | **17 passed, 0 failed** |

The shell initially lacked `flutter` on `PATH`; that invocation did not start
a test. The exact tests were rerun with the configured SDK at
`/Users/rob/Development/flutter/bin/flutter`, and all passed.

No complete repository suite was run.

## 17. `git diff --check`

Passed after merge and again after the narrow validation.

## 18. Original preservation artifacts

All original artifacts remain present and unchanged:

| Artifact | Verified SHA-256 |
| --- | --- |
| parked patch | `43399bc44441e80fa65308ba4cf0d5bbea884b7c8a4501ad40eb6f10752e2b07` |
| historical old-base tracked delta | `d1a5db501b91b46f83a8c77d5bd10dc40853d8d8a955eda331bcd0084d149b2c` |
| Journey projection | `85a99027d0f48715845b5d8dde1fc280198d66b3b6e797e9842e050605658ef` |
| Journey architecture test | `7355f8510a130db6abe28264d0f9612ce36cbc2c3108a1433a3958597db4245b` |
| original preservation manifest | `c7299bdbc8e41f52aa65ba9cb10b70fbfa11a93661d834bccc466dcfdf7461ef` |
| Prompt 14 full-worktree manifest | `bec7508c4a0a848ce82750d6477ec030cd99fd96fb66c6c9ce8c05c50e2ba02b` |
| fresh Prompt 16 manifest | `ca1acf28c3c5f0393499c1965f4627a95c6b882638204678af1c8c6a1ee104d1` |
| collision-backup manifest | `194aea987081eadc9f9a687b62829375090eb164a7639f72bd0668e29f5f3b5e` |

The parked patch remains unapplied. The historical old-base delta remains
preserved as recovery evidence and was not compared to a newly based diff.

## 19. Fresh manifest comparison

After merge and after all narrow tests, the fresh verifier reported:

- manifest SHA-256: `ca1acf28...`;
- current HEAD: `276fa1b820b07bf14f41fe216192456b5415e290`;
- tracked entries checked: 49;
- recorded untracked entries: 78;
- current untracked entries: 77;
- controlled collision bytes/type: exact;
- all other recorded untracked entries: exact;
- index: empty;
- shared submodule: clean and unchanged;
- errors: none.

The collision's filesystem mode normalization is reported in section 10 and
is the reviewed tracked `100644` mode, not an implementation-content change.

## 20. Exact post-merge Git status

After this required response is created:

- branch/HEAD: `fix/onboarding-import-stuck-state` /
  `276fa1b820b07bf14f41fe216192456b5415e290`;
- index: empty;
- tracked worktree: the same 47 modified and 2 deleted Onboarding paths;
- untracked worktree: 78 paths (the 77 preserved post-transition paths plus
  this Response 16);
- collision path: tracked and clean;
- shared submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- merge/conflict state: none;
- stash/reset/clean/rebase: none;
- push: none.

## 21. Stop gates encountered

No terminal stop gate was encountered.

The immediate verifier initially reported the collision entry because the
untracked source was mode `0600` while the tracked `main` entry is `100644`.
Inspection proved that file type, size, and every byte were exact and that the
path had no worktree diff; the verifier was narrowed to Prompt 16's explicit
collision requirements rather than treating the expected tracked mode as a
byte mismatch.

The first Flutter command also lacked a PATH entry, but no test started and no
repository change resulted. All required tests then passed with the configured
SDK.

MessageLens Development was not launched. No real database, attachment
archive, application configuration, or parked operation was accessed or
modified.

## 22. Readiness for minimal Onboarding tenure-correction design

**YES.** Integrated Feature 35 is now available in the frozen Onboarding
branch, every Onboarding implementation byte remains preserved, and the only
controlled worktree transition was the reviewed Feature 35 record becoming
tracked with exact content.

No Onboarding behavior, Journey command predicate, Environment Readiness
logic, maintenance reporting, presentation, or archive coordinator code was
changed in this task.

`INTEGRATED MAIN MERGED INTO FROZEN ONBOARDING BRANCH: YES`

`ONBOARDING IMPLEMENTATION BYTES PRESERVED: YES`

`ONLY CONTROLLED UNTRACKED-TO-TRACKED CLASSIFICATION TRANSITION: YES`

`READY TO DESIGN MINIMAL ONBOARDING TENURE CORRECTION: YES`
