# MessageLens Feature 34
## 31 — Forensic Audit of Post-Onboarding State, Reset Failure, Favourites, and Recent Logs

The checkpointed Onboarding correction has now been exercised manually far enough to produce valuable runtime evidence.

Checkpoint under qualification:

- branch:
  `fix/onboarding-import-stuck-state`
- checkpoint:
  `9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`
- development build:
  `MessageLens Development 0.2.128+146`

The recent human run produced these observations:

### Onboarding/import

- Message text import initially showed an indeterminate progress bar for roughly
  10–15 seconds.
- It then showed approximately
  `Saving message text 0 / 1XXXXX`
  for roughly another 10 seconds before the count began incrementing.
- After that, the remaining Onboarding flow appeared to proceed normally.
- The original contradictory/stuck state was not observed during this run.

### Start Fresh / Reset message data

The human then attempted to reach Start Fresh:

1. `Settings -> Reset message data…`
2. the top application menu did not close after choosing that item;
3. choosing the same menu item again caused the menu to close;
4. the red `Reset message data…` button was clicked;
5. nothing visibly happened.

**Start Fresh did not execute.**

### Favourites

Before the attempt to investigate, the user expected three favourites:

- Rusung
- Claire
- the user's mother

Observed after Onboarding:

- Messages from Contacts navigated correctly to Rusung;
- returning to the contact/favourites picker showed only Claire as a favourite;
- Rusung and the user's mother were not listed there.

Before this audit was requested, the human **re-added Rusung as a favourite**.

Therefore the current state has been altered in one known way:

> Rusung was manually re-added after the missing-favourite observation.

Do not pretend the current overlay state alone can reconstruct Rusung's exact
pre-add state. Use durable timestamps, logs, row identity, or other existing
evidence only if they genuinely support a conclusion.

The user also specifically requested that the recent application logs be
examined for errors or warnings during the Onboarding sequence.

This task is a **read-only forensic audit**.

Do NOT modify source.
Do NOT modify tests.
Do NOT stage or commit.
Do NOT run Start Fresh.
Do NOT add/remove/edit another favourite.
Do NOT launch production MessageLens.
Do NOT alter development databases.
Do NOT checkpoint, vacuum, migrate, rebuild, compact, or otherwise mutate any
SQLite database.
Do NOT traverse or modify attachment payloads.
Do NOT drive the GUI.

---

# 1. Verify repository and runtime target

Verify:

- branch:
  `fix/onboarding-import-stuck-state`
- HEAD:
  `9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`
- tracked worktree clean;
- index empty;
- shared-instructions submodule clean;
- development build identity still corresponds to `0.2.128+146`.

Do not rebuild unless source inspection proves the current bundle is not the
checkpointed build. This task should not need a rebuild.

---

# 2. Preserve the current evidence before reading databases

Before opening any development SQLite database, record:

- exact file path;
- file size;
- modification timestamp;
- WAL/SHM presence and timestamps if present;
- SHA-256 of the main database file where practical.

Use read-only SQLite access only:

- URI/read-only mode where supported;
- `PRAGMA query_only = ON`;
- no WAL checkpoint;
- no schema write;
- no temp table;
- no vacuum;
- no migration.

This is especially important for:

- the overlay/user-intent database;
- the Onboarding operation/persistence database(s);
- import/graph databases needed only for factual state confirmation.

If the established project helpers offer a safer read-only inspection path,
prefer them.

---

# 3. Audit the recent logs first

Locate the **development** logs produced by the recent run of
MessageLens Development.

Do not inspect production logs.

Establish the relevant time window covering:

- application launch;
- recent Onboarding;
- message text import;
- graph/build completion;
- transition out of Onboarding;
- the attempted `Reset message data…` flow;
- the manual re-add of Rusung, if logged.

Search for, at minimum:

- `ERROR`
- `WARNING`
- `Exception`
- `Assertion`
- `Riverpod`
- `Provider`
- `disposed`
- `invalidated`
- `failed`
- `failure`
- `onboarding`
- `Journey`
- `initialImport`
- `messageDataBuild`
- `graph`
- `maintenance`
- `ArchiveMutation`
- `ExclusiveAuthority`
- `Start Fresh`
- `Reset message data`
- favourite/favorite mutation events if logged.

Do not simply grep for the word `error`; reconstruct the relevant sequence from
timestamps and correlated messages.

Report:

1. all actual errors/exceptions/assertions in the window;
2. all warnings plausibly relevant to Onboarding, reset, overlay persistence, or
   favourites;
3. whether the original Riverpod assertion recurred;
4. whether any failure was caught/recovered silently;
5. whether archive-mutation authority admission/maintenance produced any anomaly;
6. whether the logs show normal completion of import/graph stages;
7. whether the reset-button click generated any log/action at all;
8. whether the Rusung favourite re-add generated a logged mutation.

Preserve exact log timestamps and source/category names.

Do not dump private message/contact content into the response. Summarize
privacy-safely.

---

# 4. Reconstruct the recent Onboarding sequence from durable evidence

Read current development Onboarding operation evidence.

Determine:

- current operation status;
- operation UUID;
- operation kind;
- current/final stage;
- recovery disposition;
- failure field/state;
- whether the original failed operation was replaced, retried, resumed, or
  otherwise superseded;
- whether import and graph completion evidence are internally coherent.

Also inspect relevant import/graph result metadata and row counts sufficient to
answer:

> Did the recent run complete normally from the application's durable point of
> view?

Do not perform a broad data audit.

Correlate this durable state with the logs and the human-observed progress.

---

# 5. Investigate the 10–15 second indeterminate import phases

This is currently a qualification/UX observation, not automatically a defect.

Trace the code and logs around the transition:

```text
indeterminate progress
-> Saving message text 0 / N
-> first count increment
```

Determine:

- what work occurs before the denominator is known;
- what work occurs after `0 / N` appears but before the first progress increment;
- whether those intervals correspond to expected bounded work;
- whether any hidden retry/block/lock occurs;
- whether logs show stalls, errors, or unusually expensive operations.

Classify as one of:

- expected behavior / UX only;
- performance concern;
- evidence of another functional defect;
- insufficient evidence.

Do NOT change progress UI in this task.

If it is merely UX, record a future improvement recommendation such as clearer
phase text rather than treating it as a qualification failure.

---

# 6. Forensic audit of the failed Reset message data flow

Trace the complete production path for:

```text
Settings -> Reset message data…
-> reset settings surface/panel
-> red Reset message data… button
-> confirmation/action, if any
-> Start Fresh eligibility/action
```

Answer separately:

## A. Menu behavior

Why might the macOS application menu remain open after the first selection and
close on the second selection?

Determine whether the menu command:

- fires once;
- fires twice;
- changes navigation state;
- is disabled/blocked by focus/modal state;
- has an action wiring issue;
- is behaving normally for the current command implementation.

Do not infer from appearance alone; inspect action wiring and logs.

## B. Red button behavior

Trace the exact handler for the red `Reset message data…` button.

Determine whether:

- pointer/click reaches the handler;
- handler is null/disabled;
- an overlay/modal intercepts it;
- navigation state prevents presentation;
- confirmation dialog creation fails;
- provider/action eligibility rejects it;
- an exception occurs;
- action fires but produces no visible state;
- another cause is present.

Correlate source with the recent logs.

## C. Start Fresh

Confirm from durable state that Start Fresh did **not** execute.

Report what concrete state would have changed if it had executed and whether
those changes are absent.

Do not invoke it.

---

# 7. Forensic audit of favourites persistence and resolution

This is a read-only diagnosis of the current development state.

Important known limitation:

> Rusung has already been re-added manually after the missing-favourite
> observation.

Therefore distinguish carefully between:

- what current persistence proves;
- what logs/timestamps/history prove about the earlier state;
- what cannot now be reconstructed.

For each of:

- Rusung
- Claire
- the user's mother

determine, where the schema permits:

1. whether a current favourite-intent row exists;
2. row ID / stable identity;
3. creation/update timestamp if stored;
4. contact/person identifier referenced;
5. handle(s) or other resolution identity referenced;
6. whether the referenced identity currently resolves against Contacts;
7. whether it currently resolves against Conversation Graph;
8. number of associated handles/chats/messages if needed only to explain
   eligibility;
9. whether the contact satisfies the current favourite-picker eligibility rule;
10. if excluded, the exact predicate that excludes it.

Do not enumerate unrelated contacts.

---

# 8. Determine whether the overlay database was actually reset or damaged

Inspect the development overlay database read-only.

Determine:

- whether expected non-favourite overlay/user-intent data remains;
- whether Claire's favourite row predates the recent run;
- whether Rusung's current row appears newly created/updated at the time of the
  manual re-add, if timestamps permit;
- whether the mother's favourite row exists;
- whether duplicate/obsolete favourite rows exist;
- whether any overlay schema/version migration ran recently;
- whether logs show clearing/reset/replacement of the overlay DB;
- whether main DB/WAL timestamps indicate unusual write activity during
  Onboarding.

Do **not** conclude “overlay DB was wiped” merely because a picker item is absent.

Classify the favourite anomaly, if possible, as:

- persistence loss;
- identity/canonicalization mismatch;
- current-contact resolution failure;
- Conversation Graph resolution failure;
- eligibility filtering;
- stale provider/cache/UI projection;
- duplicate/conflicting overlay intent;
- another source-proven cause;
- not reconstructable after Rusung was re-added.

---

# 9. Compare Claire, Rusung, and mother as a three-case differential

Use Claire as the surviving favourite control.

Compare the three cases in one small table:

| Case | Favourite row now | Evidence predating re-add | Contacts resolves | Graph resolves | Picker eligible | Best-supported explanation |
|---|---|---|---|---|---|---|

Do not fill a cell with a guess.

This comparison is more useful than a broad favourite census.

---

# 10. Inspect favourite-picker logic

Trace the current picker source-of-truth and eligibility flow.

Identify:

- which provider/store supplies persisted favourites;
- which provider resolves contacts;
- which graph/handle/chat condition determines eligibility;
- whether the picker shows:
  - all persisted favourite intentions;
  - only currently resolvable favourites;
  - only contacts eligible for creation/selection;
  - another subset;
- whether adding a favourite invalidates/rebuilds the relevant providers;
- whether recent Onboarding/import completion should invalidate/rebuild those
  providers.

Look specifically for a mechanism that could explain:

```text
Rusung navigation from Contacts works
BUT
Rusung was absent from the favourites picker
```

That asymmetry is important.

Do not change the logic.

---

# 11. Determine whether recent Onboarding could legitimately touch overlay state

Trace all recent Onboarding/Start Fresh-related code paths for writes to:

- user overlay database;
- favourite intent;
- contact intent;
- archive configuration;
- other preserved user intent.

Answer:

> Did the recent Onboarding sequence have any legitimate path that could remove
> or rewrite favourites?

Distinguish:

- normal import/graph projection;
- Start Fresh;
- Complete Erase;
- migrations;
- contact/identity reconciliation;
- picker projection only.

Remember: Start Fresh did not execute in this run.

If there is no legitimate removal path, say so explicitly.

---

# 12. Qualification status of the original Onboarding defect

Based on:

- human observations;
- recent logs;
- durable operation evidence;

classify the original stuck-Onboarding defect as:

- reproduced;
- not reproduced / repaired scenario behaved normally;
- qualification incomplete;
- ambiguous.

Do not call the whole clean-slate qualification complete, because this run did
not begin from the canonical virgin state.

But separately answer:

> Did the exact original self-denial / contradictory Journey failure recur?

---

# 13. No implementation in this task

Do not fix:

- Reset message data;
- favourites;
- indeterminate progress;
- any log warning.

This task produces evidence and a bounded next-step recommendation.

If one issue is clearly source-proven and small, describe the likely correction
but do not edit.

---

# 14. Required response

Create the next sequential response in the Feature 34 Onboarding responses
folder.

Report:

1. repository/runtime-target verification;
2. read-only database evidence-preservation method;
3. exact log window and log sources inspected;
4. errors/exceptions/assertions found;
5. relevant warnings found;
6. original Riverpod assertion recurrence verdict;
7. reconstructed recent Onboarding operation sequence;
8. durable import/graph completion verdict;
9. indeterminate-progress explanation/classification;
10. Settings menu action trace;
11. red Reset button action trace;
12. Start Fresh non-execution proof;
13. overlay database integrity verdict;
14. Rusung favourite evidence;
15. Claire favourite evidence;
16. mother's favourite evidence;
17. three-case differential table;
18. favourite-picker source-of-truth and eligibility trace;
19. whether recent Onboarding had any legitimate favourite-removal path;
20. best-supported cause of the favourite anomaly;
21. original Onboarding-defect qualification verdict;
22. concrete BLOCKER findings, if any;
23. concrete SHOULD FIX findings, if any;
24. recommended next task;
25. exact Git/worktree state and confirmation that nothing was modified.

Conclude exactly:

`POST-ONBOARDING FORENSIC AUDIT COMPLETE: YES / NO`

Then give exactly these three lines:

`ORIGINAL STUCK-ONBOARDING DEFECT REPRODUCED: YES / NO / AMBIGUOUS`

`RESET MESSAGE DATA DEFECT CONFIRMED: YES / NO / AMBIGUOUS`

`FAVOURITES ANOMALY EXPLAINED: YES / NO / PARTIAL`

Then STOP.
