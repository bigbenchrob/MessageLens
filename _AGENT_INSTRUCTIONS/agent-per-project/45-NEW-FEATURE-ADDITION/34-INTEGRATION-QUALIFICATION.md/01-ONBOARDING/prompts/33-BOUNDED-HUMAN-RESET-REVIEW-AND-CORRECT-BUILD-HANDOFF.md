# MessageLens Feature 34
## 33 — Bounded Human Reset Review and Correct-Build Handoff

Response 32 reports a bounded correction of the two defects that blocked the canonical clean-slate qualification:

1. Advanced Start Fresh now performs a fresh invocation-time installation classification instead of reusing terminal startup classification.
2. A transient Settings action such as `Reset message data…` now closes the inline top menu in one selection and remains closed while the ephemeral reset panel is active.

Automated validation is green:

- Advanced Start Fresh focused tests: 18 passed;
- Start Fresh service regressions: 5 passed;
- Settings menu/resolver/cassette tests: 25 passed;
- targeted Start Fresh architecture: 8 passed;
- complete architecture: 555 passed;
- full Flutter suite: 2,752 passed / 0 failed / 1 existing skip;
- analyzer: clean;
- Project Conformance: PASS;
- BLOCKER: 0;
- SHOULD FIX: 0.

The correction remains **unstaged and uncommitted** on:

- branch: `fix/onboarding-import-stuck-state`
- HEAD: `9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`

This task is the explicitly bounded **human reset review before checkpoint**.

Do NOT modify source.
Do NOT modify tests.
Do NOT stage, commit, or push.
Do NOT reopen architecture.
Do NOT investigate favourites.
Do NOT investigate Contacts/Scrollbar.
Do NOT investigate rich-text performance.
Do NOT run the full clean-slate import qualification yet.
Do NOT access production MessageLens or production data.

The human operator drives the GUI.

---

# 1. Verify the exact correction state

Verify:

- branch: `fix/onboarding-import-stuck-state`
- HEAD: `9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`
- index: empty
- Prompt 32 correction: present and unstaged
- shared-instructions submodule: clean at `95326f515ef4719f155ce6e223990398daad6311`
- `git diff --check`: PASS.

Read Response 32 in full.

Do not alter any Prompt 32 byte.

---

# 2. Eliminate the wrong-worktree hazard first

Response 31 proved that the previous human run accidentally launched the Feature 35 worktree binary even though its visible version/build matched.

Before building or handing off:

1. determine whether any `MessageLens Development` process is currently running;
2. record its executable path and working directory if so;
3. if it is from any worktree other than `/Users/rob/Development/FlutterProjects/remember_every_text`, report that fact;
4. do not use version/build alone to identify the target.

If a wrong development instance is running, ask the human to quit it normally before proceeding. Do not kill it unless the human explicitly requests that.

Do not touch production.

---

# 3. Build the corrected development app from the right worktree

Using the established development-build procedure, build:

`/Users/rob/Development/FlutterProjects/remember_every_text`

with the unstaged Prompt 32 correction present.

Do not run from the Feature 35 worktree.

After build, record:

- exact app bundle path;
- exact executable path;
- bundle identifier;
- version/build;
- build identity;
- executable SHA-256;
- App framework SHA-256;
- modification timestamps;
- current Git branch/HEAD;
- confirmation that the build consumed the unstaged Prompt 32 source.

Verify no unexpected tracked/generated churn remains after the build.

If build produces unrelated tracked changes, restore only unquestionably tool-generated churn and report it. Otherwise STOP.

---

# 4. Do not launch the app yourself

Once the correct build is verified, STOP automated work.

The human will launch the development app using the repository's correct VS Code `MessageLens Development (Debug)` configuration or the verified app bundle.

The launch target must resolve to the exact build from the main `remember_every_text` worktree.

Do not drive the GUI.

---

# 5. Human review — Settings menu behavior

With MessageLens Development running:

1. open **Settings**;
2. choose **Reset message data…** once.

Expected:

- the action dispatches once;
- the reset panel appears;
- the top Settings menu closes after that one selection;
- it does not immediately reopen merely because no persistent Settings item is selected;
- no second selection is required.

If the menu still reopens, STOP the review there and record it as a failed Prompt 32 claim.

---

# 6. Human review — red Reset Message Data action

On the reset panel:

1. click the red **Reset message data…** button exactly once.

Expected:

- the click is visibly acknowledged through the normal authorization/reset UI;
- it does not appear to do nothing;
- no uncaught error appears;
- one click creates at most one authorization/presentation attempt.

If an authorization confirmation appears, the human may proceed to section 7.

If the red button still produces no visible result, STOP and preserve logs.

---

# 7. Human review — execute Start Fresh

If the reset authorization appears normally, the human may confirm **Start Fresh**.

Do NOT choose Complete Erase.

Expected destructive scope remains unchanged:

- durable onboarding operation evidence resets appropriately;
- bounded import/graph failure evidence clears;
- rebuildable message-data stores reset;
- installation verifies as virgin;
- `user_overlays.db` user intent remains;
- favourites remain;
- archive configuration/identity remains;
- attachment archives remain.

The purpose of executing Start Fresh here is to validate the corrected currentness path end-to-end and establish the canonical virgin state.

---

# 8. Stop after virgin-state establishment

Do **not** press `Import My Messages` in this task.

Once Start Fresh completes:

- record what the UI shows;
- verify normal Onboarding appears;
- verify the installation is virgin using existing development diagnostics or read-only evidence;
- verify active Toshiba development archive and archive identity remain intact;
- verify no unexpected favourites/user-intent loss is newly observed.

Then STOP.

The full clean-slate Onboarding import qualification begins only after the Prompt 32 correction has been human-reviewed and checkpointed.

---

# 9. Logs to inspect only if the human review fails

If either the menu reopens incorrectly, the red button does nothing, authorization fails, or Start Fresh fails, inspect only the relevant development log interval.

Look for:

- `AdvancedStartFresh`;
- `ResetMessageDataRequested`;
- installation classification;
- current-state reader;
- authorization;
- `PlatformDispatcher`;
- `StartFreshService`;
- reset verification.

Do not begin another broad forensic audit.

---

# 10. Success criteria

This bounded human review passes only if:

1. correct worktree/binary is proven by path/hash;
2. one transient Settings selection closes the menu once;
3. one red-button click produces the intended reset authorization/presentation;
4. no stale startup-classification error escapes;
5. confirmed Start Fresh completes;
6. resulting installation is virgin;
7. preserved overlay/archive scope remains intact.

No other feature is under review.

---

# 11. Required response before checkpoint

Create the next sequential Response 33 record.

Report:

1. exact running/build target verification;
2. executable path/hash;
3. confirmation wrong Feature 35 binary is not under test;
4. Settings menu one-selection result;
5. red-button one-click result;
6. authorization result;
7. Start Fresh execution result;
8. post-reset virgin-state verification;
9. overlay/favourites preservation observation;
10. archive configuration/identity preservation observation;
11. relevant error-log evidence if failure occurred;
12. tracked worktree/index/submodule state;
13. bounded human review verdict.

Do not modify the correction during this review.

Conclude exactly:

`BOUNDED HUMAN RESET REVIEW: PASS / FAIL`

If PASS, also conclude:

`PROMPT 32 CORRECTION READY TO CHECKPOINT: YES / NO`

Then STOP.
