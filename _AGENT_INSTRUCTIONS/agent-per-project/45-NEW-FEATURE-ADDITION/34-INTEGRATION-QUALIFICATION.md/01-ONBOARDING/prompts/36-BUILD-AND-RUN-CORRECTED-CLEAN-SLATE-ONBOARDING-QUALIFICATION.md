# MessageLens Feature 34
## 36 — Build and Run Corrected Clean-Slate Onboarding Qualification

Response 35 reports that the accumulated Prompt 32 + Prompt 35 correction is complete, fully validated, and remains unstaged.

Current repository state:

- branch: `fix/onboarding-import-stuck-state`
- HEAD: `9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`
- Prompt 32 + Prompt 35 correction: present and unstaged
- index: empty
- shared-instructions submodule: clean at `95326f515ef4719f155ce6e223990398daad6311`

Current development data state is already the desired clean-slate qualification state:

- installation: `virgin`
- operation snapshot: idle
- import database: absent
- Conversation Graph: valid and empty
- graph counts: zero
- Claire and Rusung favourite intents preserved
- Toshiba development attachment archive configuration preserved

Response 35 reports:

- complete architecture: 556 / 556
- full Flutter suite: 2,762 passed / 0 failed / 1 existing skip
- analyzer: clean
- Project Conformance: PASS
- BLOCKER: 0
- SHOULD FIX: 0

This task performs the real human clean-slate Onboarding qualification using the correct main-worktree build containing the unstaged Prompt 32 + Prompt 35 correction.

This is a qualification task, not another architecture review.

Do NOT modify source.
Do NOT modify tests.
Do NOT stage, commit, or push.
Do NOT run Start Fresh before qualification: the development installation is already virgin.
Do NOT delete or reset databases manually.
Do NOT launch production MessageLens.
Do NOT access production data.
Do NOT drive the GUI automatically.

The human operator drives the GUI.

---

# 1. Verify the exact source state before building

Require:

- worktree: `/Users/rob/Development/FlutterProjects/remember_every_text`
- branch: `fix/onboarding-import-stuck-state`
- HEAD: `9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`
- Prompt 32 + Prompt 35 accumulated diff present
- index empty
- `git diff --check`: PASS
- shared submodule clean.

Read Responses 34 and 35 before proceeding.

Create a fresh external pre-build manifest/fingerprint of the intended source state.

If the accumulated correction differs from Response 35, STOP AND REPORT.

---

# 2. Reconfirm the virgin development state read-only

Before launch, perform only the minimum read-only checks needed to confirm the Response 35 qualification starting point remains intact:

- operation snapshot idle
- import database absent
- graph database valid and empty
- no failure evidence
- archive configuration still points to the expected Toshiba development archive
- archive identity unchanged.

Do not perform a broad database audit.
Do not use write-capable helpers.

If the installation is no longer virgin, STOP AND REPORT. Do not run Start Fresh automatically.

---

# 3. Eliminate wrong-worktree risk

Before building:

- confirm no `MessageLens Development` process is running
- if one is running, record executable path and working directory.

If a development instance from another worktree is running, ask the human to quit it normally before continuing.

Do not rely on version/build alone.

---

# 4. Build the corrected app from the main worktree

Use the established MessageLens Development build procedure from:

`/Users/rob/Development/FlutterProjects/remember_every_text`

The build must include the unstaged Prompt 32 + Prompt 35 correction.

After build, report:

- exact bundle path
- exact executable path
- version/build
- bundle identifier
- build identity
- executable SHA-256
- App framework SHA-256
- modification timestamps
- branch/HEAD
- source/diff fingerprint proving the build corresponds to the current unstaged correction.

Verify no unexpected tracked/generated churn remains.

Do not launch the app yourself.

---

# 5. Human launch handoff

STOP automated work once the build is verified.

The human launches the app using the repository's:

`MessageLens Development (Debug)`

configuration or the exact verified bundle.

The launch target must resolve to the main `remember_every_text` worktree build.

Do not drive the GUI.

---

# 6. Human clean-slate Onboarding qualification

Because the installation is already virgin, **do not run Start Fresh first**.

The human should:

1. launch the verified corrected development app
2. observe the initial Onboarding entry
3. proceed normally through prerequisite steps
4. reach **Import My Messages**
5. click it once
6. observe the message import/progress sequence
7. allow import, rich-text work, graph build, durable verification, and Journey handoff to complete
8. stop if any contradictory or stranded state appears.

The exact original defect to watch for remains:

```text
Import My Messages
-> command owns archive-mutation tenure
-> aggregate Environment may report maintenance
-> command must not deny itself
-> fresh evidence remains current
-> Journey advances coherently
-> presentation reflects Journey only
```

The old failure must not recur:

- stuck `buildingGraph`-type state
- non-dismissible modal with no progress
- apparent 100% / Browsing-ready while Journey still building
- no retry/failure after a real error
- indefinite contradictory state.

---

# 7. Progress/feedback observations to record

The user previously observed:

- indeterminate progress before denominator appears
- a pause at `Saving message text 0 / N`
- long rich-text candidate-window / first-page latency.

Do not treat those as failures unless work actually stalls or errors.

Record:

- approximate duration of each visible phase
- whether phase text makes sense
- whether counts advance
- whether the UI remains responsive
- whether any phase looks dead enough to encourage repeated clicking.

Do not change UI during qualification.

---

# 8. Favourites observation

Do not add/remove favourites during qualification.

After Onboarding completes and Contacts/graph are available, record whether the currently preserved favourite intents resolve visibly:

- Claire
- Rusung.

Do not infer anything about the user's mother from this run; her historical intent remains unresolved from prior evidence.

This is observational only and must not derail the Onboarding qualification.

---

# 9. Post-Onboarding reset UX smoke check without destroying the new import

After a successful clean-slate Onboarding run, perform a **non-destructive** smoke check of the Prompt 35 reset interaction:

1. open `Settings -> Reset message data…` once
2. confirm the menu closes and stays closed
3. click the red `Reset message data…` action once
4. observe whether immediate hover/pressed/busy/checking feedback appears
5. confirm only one authorization dialog appears
6. **cancel** the authorization.

Do NOT confirm Start Fresh in this post-qualification smoke check.

Expected:

- immediate acknowledgement
- `Checking reset availability…` or equivalent visible checking state
- action disabled while current-state classification runs
- exactly one confirmation route
- cancel returns cleanly to idle
- no reset occurs
- imported data remains intact.

Do not intentionally hammer the button. Automated deterministic race tests already cover duplicate input.

---

# 10. Logs if qualification fails

If the clean-slate Onboarding flow or reset smoke check fails, stop at the first reproducible failure and inspect only the relevant development log interval.

Record:

- exact human action
- exact visible state
- current Journey state if available
- operation snapshot evidence
- relevant errors/warnings
- whether waiting changes anything
- whether a modal/overlay is blocking progress.

Do not implement a fix in this task.

---

# 11. Qualification success criteria

The human clean-slate qualification passes this phase only if:

1. correct main-worktree build is under test
2. qualification starts from verified virgin state
3. Import My Messages begins normally
4. import/graph/durable verification complete
5. Journey reaches the expected normal application state coherently
6. the original stuck/contradictory defect does not recur
7. no new authority/currentness exception occurs
8. post-Onboarding reset smoke check gives immediate feedback and one authorization route
9. cancelling reset leaves the imported installation intact.

---

# 12. Required response

Create the next sequential Response 36 record.

Report:

1. source/diff baseline verification
2. virgin-state verification
3. wrong-worktree/process verification
4. exact corrected build identity/path/hashes
5. human launch target
6. initial Onboarding state
7. prerequisite flow result
8. Import My Messages start result
9. visible import/progress observations
10. rich-text/graph/durable verification observations
11. Journey completion result
12. whether the original stuck/contradictory defect recurred
13. relevant log errors/warnings, if any
14. Claire/Rusung favourites observation after completion
15. reset Settings-menu smoke-check result
16. red-action immediate-feedback result
17. authorization single-route result
18. cancel result and confirmation no reset occurred
19. imported-data preservation after cancel
20. tracked worktree/index/submodule state
21. bounded clean-slate qualification verdict
22. recommended next step.

Do not modify the correction during this task.

Conclude exactly:

`CORRECTED CLEAN-SLATE ONBOARDING QUALIFICATION: PASS / FAIL / AMBIGUOUS`

Then give exactly:

`ORIGINAL STUCK-ONBOARDING DEFECT REPRODUCED: YES / NO / AMBIGUOUS`

`PROMPT 35 RESET SINGLE-FLIGHT HUMAN SMOKE CHECK: PASS / FAIL / NOT RUN`

If the clean-slate qualification and reset smoke check both PASS, also conclude:

`PROMPT 32 + PROMPT 35 CORRECTION READY TO CHECKPOINT: YES / NO`

Then STOP.
