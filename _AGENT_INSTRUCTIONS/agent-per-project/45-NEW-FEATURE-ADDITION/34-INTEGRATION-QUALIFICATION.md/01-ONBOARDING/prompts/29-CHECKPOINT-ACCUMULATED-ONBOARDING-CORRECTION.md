# MessageLens Feature 34 / Feature 35
## 29 — Checkpoint the Accumulated Onboarding Correction

Prompt 28 reports that the accumulated Onboarding correction is ready to checkpoint:

- `PROJECT CONFORMANCE: PASS`
- BLOCKER: 0
- SHOULD FIX: 0
- runtime production and behavioral-test bytes unchanged from the already-reviewed correction
- focused architecture: 25 passed
- related architecture: 66 passed
- complete architecture: 554 passed
- analyzer: clean
- work remains unstaged and uncommitted.

This task is **not another architecture review**.

The purpose is to verify the approved bytes, create one checkpoint commit, push a non-force recovery branch, and stop so human clean-slate qualification can resume.

Do NOT modify implementation.
Do NOT modify tests.
Do NOT regenerate code.
Do NOT re-open architectural questions.
Do NOT run GUI qualification.
Do NOT access production data.
Do NOT access real Messages/Contacts databases or attachment archives.
Do NOT merge to `main`.
Do NOT rebase.
Do NOT squash or rewrite existing history.
Do NOT force-push.

---

# 1. Approved starting point

Worktree:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Require before staging:

- branch: `fix/onboarding-import-stuck-state`
- HEAD: `276fa1b820b07bf14f41fe216192456b5415e290`
- index: empty
- accumulated tracked worktree: 55 modified / 2 deleted
- shared-instructions submodule: clean at `95326f515ef4719f155ce6e223990398daad6311`
- `git diff --check`: PASS

Prompt 28 baseline:

`/private/tmp/messagelens-onboarding-prompt28-baseline.uP28xG/MANIFEST.json`

SHA-256:

`ffbbd316957c07706fcbaea24023a439ce3e0f88fb45e15f83261351cd458577`

Read Response 28 before proceeding.

If the repository no longer matches the approved state except for the expected Prompt 29 input/response records, STOP AND REPORT.

---

# 2. Re-verify preservation artifacts

Verify that all recorded preservation manifests retain their exact hashes:

- Feature 35 collision:
  `194aea987081eadc9f9a687b62829375090eb164a7639f72bd0668e29f5f3b5e`
- pre-merge:
  `bec7508c4a0a848ce82750d6477ec030cd99fd96fb66c6c9ce8c05c50e2ba02b`
- Prompt 18:
  `0996303f8fc409ebb4748cbfc75999c7649e09f57dac202b99dd0fefee92621c`
- Prompt 20:
  `6472a83f43a3d1e6bf621291bdd925aa0fcbbd69af61823f93fa292e14a6f20d`
- Prompt 22:
  `e1520edb5c864ac7118aee582d68379fad6d7e2245bcfbb5d7633cb37a775b0d`
- Prompt 24:
  `062c6740516ccf3974f6a717db3998d5d54d7fea6f312ab3a688140799b6d3cc`
- Prompt 26:
  `1f1de4ce78f0e941571b37219f55f7ffb455c3b2044d430ec7365fae4fc4a6ab`
- reconstruction:
  `ca1acf28c3c5f0393499c1965f4627a95c6b882638204678af1c8c6a1ee104d1`

Do not alter or move those external preservation artifacts.

---

# 3. No new review cycle

Do not perform another speculative architecture audit.

The approved correction already includes:

- sole Journey semantic authority;
- real Feature 35 Ball/tenure adoption;
- owner-aware admitted Environment evidence;
- exact capability/resource admission;
- fail-closed protected I/O across async boundaries;
- coherent bounded evidence sampling;
- real global self-maintenance feedback tests;
- command-specific late semantic guards;
- analyzer-resolved architecture enforcement;
- binding-authentic proof callback, command provenance, and feedback provenance;
- no persistence/schema/restart drift.

Only verify that the approved bytes are still the bytes being checkpointed.

---

# 4. Minimal checkpoint validation

Because Prompt 28 changed only the architecture test and all runtime/behavioral bytes remained unchanged, do **not** rerun the full Flutter behavioral suite.

Run only:

1. focused Onboarding Journey authority architecture test;
2. complete architecture suite;
3. `flutter analyze --no-pub`;
4. `git diff --check`;
5. formatting check on the changed architecture test.

Expected evidence:

- focused architecture: 25 passed;
- complete architecture: 554 passed;
- analyzer: no issues;
- diff check: PASS;
- formatting: PASS.

If any fail, STOP AND REPORT. Do not repair during this checkpoint task.

---

# 5. Build the exact checkpoint census before staging

Before `git add`, produce an exact path census of:

- tracked modified files;
- tracked deleted files;
- untracked files.

Classify every path as one of:

1. accumulated Onboarding correction implementation/test;
2. accumulated Onboarding architecture enforcement;
3. Feature 34 Onboarding prompt/response/design/audit record;
4. unrelated/pre-existing path.

Stage only categories 1–3.

Do not stage category 4.

Use the preservation manifests and sequential Onboarding prompt/response history to classify ambiguous untracked files.

If any path cannot be classified confidently, STOP AND REPORT before staging.

---

# 6. Confirm no prohibited scope is entering the commit

Before staging, mechanically confirm no unintended changes exist in:

- production signing/release metadata;
- `pubspec.yaml`;
- `CHANGELOG.md`;
- native project configuration;
- real data/configuration artifacts;
- external archive artifacts;
- unrelated development branches/worktrees.

The shared-instructions submodule must remain clean and must not be staged as a submodule pointer change.

---

# 7. Stage the approved accumulated correction

Stage exactly the classified Onboarding correction and its repository records.

After staging:

- no intended correction path may remain unstaged;
- no unrelated path may be staged;
- `git diff --cached --check` must pass.

Produce the staged path census and compare it with the approved pre-stage census.

Do not commit until the staged set is exact.

---

# 8. Checkpoint commit

Create one checkpoint commit with this exact subject:

`fix(onboarding): restore journey authority under exclusive tenure`

The commit may include:

- complete accumulated Onboarding runtime correction;
- tests;
- architecture enforcement;
- deleted obsolete Onboarding authority paths;
- Feature 34 Onboarding design/audit/prompt/response records.

Do not include unrelated files.

After commit, report:

- commit SHA;
- parent SHA;
- tree SHA;
- subject;
- file count;
- insertion/deletion summary.

---

# 9. Verify checkpoint integrity

After commit:

- index must be empty;
- shared submodule must remain clean;
- `git diff HEAD^..HEAD --check` must pass.

Verify the checkpoint commit contains the exact staged path set and no additional paths.

Spot-check that these critical runtime files are present at the reviewed bytes:

- `onboarding_environment_report_provider.dart`
- `onboarding_journey_coordinator_provider.dart`
- `onboarding_failure_store.dart`
- `overlay_onboarding_failure_storage.dart`
- `attachment_archive_location_provider.dart`
- `attachment_archive_location_controller.dart`

Also confirm final `onboarding_journey_authority_architecture_test.dart` is present at the Prompt 28-reviewed content.

Do not modify anything if a mismatch is found. STOP AND REPORT.

---

# 10. Push a recovery branch

Push the checkpoint branch without force.

Preferred:

```text
git push -u origin fix/onboarding-import-stuck-state
```

if no upstream exists.

If the branch already has an upstream, use an ordinary non-force push.

Do not merge.
Do not rebase.
Do not force-push.

Report the exact remote branch and checkpoint SHA.

---

# 11. Final repository state

Require:

- current branch: `fix/onboarding-import-stuck-state`
- HEAD: new checkpoint commit
- index: empty
- worktree: clean, except only the required Response 29 record if created after commit
- shared submodule: clean
- remote recovery branch: points to checkpoint commit.

If Response 29 is created after the checkpoint commit, leave it untracked and report that explicitly. Do not amend the checkpoint merely to include the response.

---

# 12. What happens next

Do not perform the next step in this task.

After this checkpoint, the next planned work is to return to **Feature 34 clean-slate Onboarding qualification**, which originally exposed the defect.

The human operator will launch MessageLens Development and resume the clean-slate qualification from the onboarding/import scenario.

No further architecture-enforcement pass is required before that human qualification unless checkpoint verification itself fails.

---

# 13. Required response

Create the next sequential response in the Feature 34 Onboarding responses folder.

Report:

1. approved starting-state verification;
2. preservation-manifest verification;
3. minimal checkpoint validation results;
4. exact pre-stage path census;
5. path classification summary;
6. prohibited-scope verification;
7. exact staged path census;
8. `git diff --cached --check` result;
9. checkpoint commit SHA;
10. parent SHA;
11. tree SHA;
12. commit subject;
13. commit file/insertion/deletion summary;
14. critical-file byte/inclusion spot checks;
15. post-commit worktree/index state;
16. shared-submodule state;
17. remote push result;
18. remote branch and SHA;
19. any path deliberately left uncommitted;
20. readiness to resume human clean-slate qualification.

Conclude exactly:

`ACCUMULATED ONBOARDING CORRECTION CHECKPOINTED: YES / NO`

If YES, also conclude:

`READY TO RESUME FEATURE 34 CLEAN-SLATE ONBOARDING QUALIFICATION: YES / NO`

Then STOP.
