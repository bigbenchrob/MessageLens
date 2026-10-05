# MessageLens Feature 34
## 68 — Rerun Bounded Real Attachment Archive Repair Qualification

Response 67 removed the exact safety blocker discovered by Response 66.

The repair authorization boundary is now:

```text
fresh repair evidence
-> derive one exact memory-only RepairBatchPlan
-> at most 75 exact attachment compatibility keys
-> display exact item count
-> display exact aggregate bytes when trustworthy
-> human confirms that exact displayed plan
-> process only those exact keys
-> stop mutation
-> fresh coverage / partition
-> require another human click for any later batch
```

The old behavior is gone:

```text
one click
-> authorize complete availableFromMessagesCount
-> automatically chain 75-item pages
```

Response 67 also closed the stale-rendered-control race: the UI passes the exact
authorization handle it displayed, and the controller/executor require identity
with the still-current unconsumed plan.

This task now reruns the **bounded real human qualification** that Prompt 66
could not safely reach.

This is a two-stage human-gated experiment.

Do NOT treat starting this prompt as authorization to mutate the real archive.

---

# 1. Repository and exact artifact preflight

Primary worktree:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Require:

- branch:
  `fix/onboarding-import-stuck-state`
- clean tracked worktree;
- clean index;
- branch/upstream ahead/behind `0/0`;
- one active Feature 34 worktree;
- shared-instructions submodule clean at:
  `95326f515ef4719f155ce6e223990398daad6311`.

First record the exact current HEAD and verify that the Prompt 67 implementation
commit is an ancestor:

`0356c59f03625c73875ed0a1b1e5f16a43723078`

Response 67 says a subsequent documentation checkpoint was pushed but does not
embed its own resulting SHA in the response body. Resolve the actual current
HEAD from Git and report it. Do not infer it.

Use the exact Response 67 development artifact:

`/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app`

Expected:

- product: `MessageLens Development`
- bundle identifier: `com.bigbenchsoftware.MessageLens.development`
- version/build: `0.2.137 (155)`
- executable SHA-256:
  `131eca2de56810191d5ae8fc98c6417a52ba284ed5ff72547f6b3329c676eda8`
- `App.framework/App` SHA-256:
  `0dfd24d6e7d5bf352982b3c609d543f073274d1d42ca7be5f33605c090b6ca2f`

If either hash differs, STOP AND REPORT.

Do not rebuild before qualification.

---

# 2. Human-visible environment preflight

Before launch, verify:

1. WD development root exists:
   `/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development`
2. Toshiba active archive exists:
   `/Volumes/Toshiba_manual_bu/ML_ADOPTION_TEST/attachment_archive`
3. no `MessageLens Development` process is running;
4. the human-visible macOS Full Disk Access pane shows the exact development app
   enabled.

Record the visible FDA toggle state only as human-visible configuration. Do not
convert it into MessageLens evidence.

If the FDA entry has again unexpectedly switched OFF, report that before
launch; the human may restore it so the qualification can proceed.

---

# 3. Set the exact development AppCzar launch contract

Run:

```bash
launchctl setenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT "/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development"
```

Verify:

```bash
launchctl getenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT
```

returns exactly:

```text
/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development
```

This is only development-root admission.

---

# 4. Reconfirm the bounded consent contract from source

Before launch, perform a short source audit to reconfirm the exact production
control that will be exercised.

Require:

```text
maximum items per displayed/authorized plan = 75
```

and verify:

- plan contains exact ordered compatibility keys;
- plan is memory-only;
- exact displayed handle is passed back on click;
- one click cannot admit item 76;
- executor makes exactly one authorized batch mutation call;
- no second page/batch is fetched automatically;
- after the batch, fresh evidence creates a distinct new plan requiring another
  click;
- stale plan cannot refill/substitute newly discovered items;
- unknown aggregate byte scope suppresses automatic mutation action.

If any of those statements is no longer true, STOP BEFORE LAUNCH.

---

# 5. Direct-launch the exact artifact

Launch:

```bash
/usr/bin/open -n "/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app"
```

Record initial PID.

Allow fresh AppCzar to classify current reality without interference.

Legitimate startup paths include:

```text
Source Access Repair
Data Update
Attachment Archive Repair
```

If Source Access Repair appears, restore source access using the already
qualified flow and allow the required real restart.

If Data Update appears, allow it to complete and restart normally.

Continue only when a **fresh process** independently selects Attachment Archive
Repair for:

```text
archive available
AND attachment coverage FALSE
```

Do not manually invoke repair.

---

# 6. Stage A — read-only live qualification

On first arrival at Attachment Archive Repair:

**DO NOT CLICK THE REPAIR ACTION.**

Allow the current read-only classification and displayed batch plan to settle.

Record:

- PID;
- required count;
- covered count;
- uncovered / need-attention count;
- Available from Messages count;
- source currently absent count;
- source evidence unavailable/UNKNOWN count;
- record-backed recovery count if present;
- unsafe/conflicting count if present;
- exact next repair-batch item count;
- exact displayed aggregate bytes or literal unknown-size message;
- exact repair button text;
- archive label/scope if shown.

Expected:

- next repair batch count is between 1 and 75 if automatic work is available;
- repair button names the exact count;
- no archive mutation begins automatically;
- no mutation action is shown if trustworthy batch byte scope cannot be
  established under the implemented policy.

If mutation begins before explicit human action, STOP and report FAIL.

---

# 7. Compare current reality with the old forensic baseline

Previous forensic baseline:

```text
required      18,281
covered        4,440
uncovered     13,841
```

Do not expect exact equality.

Report only current observed facts and explain differences from current
evidence.

Do not call absent source payloads lost.

Do not infer Apple eviction from UNKNOWN evidence.

---

# 8. HARD HUMAN STOP

At this point STOP and report the Stage A evidence to the human.

Ask exactly:

> `Authorize the displayed real repair batch of N attachments totaling S?`

where:

- `N` is the exact count currently displayed;
- `S` is the exact displayed aggregate size.

If the UI displays an unknown-size condition and therefore no mutation action,
do not ask for authorization; report the fail-closed state.

**Do not continue until the human explicitly authorizes that exact displayed
batch.**

The user's instruction to execute Prompt 68 is not itself mutation consent.

---

# 9. Stage B — one explicitly authorized real batch

Only after explicit human authorization of the exact Stage A plan:

1. re-record PID;
2. re-record the displayed plan identity information available to the human
   (count and aggregate size; do not expose private keys);
3. click the normal product action exactly once;
4. do not click another repair action during this task;
5. allow the exact admitted batch to settle;
6. do not manually alter Messages or archive files.

Record factual progress actually observed.

At minimum report:

- authorized item count;
- authorized aggregate bytes;
- items examined;
- items attempted;
- newly preserved;
- skipped/refused due to changed evidence;
- failed;
- whether any plan invalidation occurred;
- whether a second batch began automatically.

A second automatic batch without another click is an immediate FAIL.

---

# 10. Verify the exact-consent invariant live

The first real batch must demonstrate:

```text
authorization count <= 75
```

and:

```text
one click
-> at most those exact displayed items
-> no refill
-> no item 76
-> no second mutation batch
```

If one or more authorized items became stale, acceptable behavior is:

```text
skip/refuse stale exact item
```

not:

```text
substitute a new uncovered item
```

Record any visible stale-plan or reclassification behavior literally.

---

# 11. Fresh durable verification after the batch

After the batch settles, require the product's fresh coverage/partition read.

Record before vs after:

```text
required
covered
uncovered
available from Messages
source absent
UNKNOWN/unverifiable
```

For newly preserved items, verify through the product's normal factual
observation that:

- durable object evidence exists;
- archive payload is represented as safe/regular/exact-size;
- those successful keys no longer contribute to uncovered coverage.

Do not use the worker result alone.

Do not recursively hash the archive.

---

# 12. Expected coverage-FALSE behavior

The likely result after one batch is still coverage FALSE.

Expected:

```text
coverage FALSE
-> remain on Attachment Archive Repair
-> fresh partition
-> new exact next batch plan, if source-available work remains
-> new button requiring a new human click
-> NO automatic second batch
-> NO automatic restart
-> NO Operating admission
```

This is a successful qualification outcome.

Do not authorize the newly displayed second batch in Prompt 68.

---

# 13. Coverage-TRUE edge case

If the one real batch unexpectedly makes coverage TRUE:

```text
coverage TRUE
-> stopAndDrain()
-> real process restart
-> fresh AppCzar
```

Record old/new PID boundary.

Do not begin the Operating Stage Two Prompt 61 experiment in this task.

---

# 14. Coverage UNKNOWN or source-access change

If post-batch coverage becomes UNKNOWN:

- do not call it incomplete;
- drain/restart;
- fresh AppCzar owns Diagnostic Review.

If source becomes conclusively unreadable:

- stop new repair work;
- drain admitted batch;
- restart;
- fresh AppCzar may select Source Access Repair.

No in-process coordinator handoff.

---

# 15. Confirm fresh second plan requires new consent

If coverage remains FALSE and automatic work remains, inspect the newly rendered
second plan without clicking it.

Record:

- new item count;
- new aggregate bytes;
- action wording;
- proof it is a distinct fresh plan;
- proof no mutation starts while it is merely displayed.

This is the live proof that natural recomputation replaced automatic page
chaining.

---

# 16. Normal quit and drain corroboration

When no mutation is active:

1. request normal quit;
2. confirm PID disappears;
3. confirm no repair status continues afterward.

Do not intentionally interrupt a live payload write during this first real
qualification.

Deterministic tests remain the proof of mid-write drain behavior.

---

# 17. Fresh-process reconstruction

Direct-launch the same exact artifact again with the launchd environment still
set.

Fresh AppCzar must reconstruct reality from durable facts only.

If coverage remains FALSE, expected:

```text
fresh AppCzar
-> Attachment Archive Repair
-> improved covered/uncovered counts
-> no durable semantic repair cursor
-> already repaired items remain covered
-> a freshly derived next plan
```

Record new PID and current counts.

Do not authorize another repair batch.

Then quit normally.

---

# 18. Fair-Witness checks

Confirm:

- no uncovered item is called lost;
- absent != UNKNOWN;
- source readability is not equated with human-visible FDA state;
- archive availability != coverage;
- batch worker completion != coverage proof;
- coverage FALSE is not called repaired/current;
- no Operating admission while coverage FALSE;
- no coordinator handoff in-process;
- no historical repair-success flag;
- no consent survives process death;
- fresh process derives a new plan from current facts.

---

# 19. Cleanup

At the end:

1. leave development FDA enabled;
2. ensure no MessageLens Development process remains;
3. run:

```bash
launchctl unsetenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT
```

4. verify `launchctl getenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT` is empty;
5. do not modify/stage/commit source or tests.

The deliberately authorized real archive writes from the one batch are expected
qualification effects and must not be manually reverted.

---

# 20. Qualification verdict

A PASS does **not** require complete attachment coverage.

A PASS requires:

```text
fresh AppCzar selected repair from current facts

read-only Stage A showed exact bounded plan

explicit human consent named exact count and aggregate size

one click admitted only that exact <=75-key plan

no automatic second batch

fresh durable evidence showed the resulting repair effect

coverage FALSE, if remaining, stayed factual and stable

fresh process reconstructed the improvement without semantic resume state
```

---

# 21. Required response

Create Response 68 and report:

1. exact repository HEAD/upstream state;
2. Prompt 67 implementation ancestry verification;
3. exact artifact/hash verification;
4. human-visible FDA preflight state;
5. launchd development-root value;
6. bounded-consent source re-audit result;
7. initial launch PID/path;
8. any startup Source Access Repair/Data Update path;
9. fresh Attachment Archive Repair selection evidence;
10. Stage A PID;
11. Stage A required/covered/uncovered counts;
12. Stage A source-available/source-absent/UNKNOWN partition;
13. displayed next-batch item count;
14. displayed aggregate byte scope;
15. exact repair action wording;
16. proof no mutation occurred before human consent;
17. exact authorization question presented to human;
18. exact human authorization received;
19. Stage B starting PID;
20. exact authorized count/bytes;
21. progress actually observed;
22. attempted/newly preserved/skipped/failed counts;
23. proof no second batch auto-started;
24. exact stale/refill behavior if encountered;
25. fresh post-batch coverage counts;
26. durable object/payload verification result;
27. coverage FALSE/TRUE/UNKNOWN terminal behavior;
28. fresh second-plan count/bytes/action if applicable;
29. proof second plan did not mutate without another click;
30. quit/drain corroboration;
31. fresh-process PID and reconstructed coverage counts;
32. proof repaired objects remained covered;
33. proof no semantic repair cursor/consent survived restart;
34. Fair-Witness verdict;
35. errors/warnings/evidence limitations;
36. cleanup result;
37. overall human qualification verdict;
38. recommendation on additional bounded repair batches;
39. readiness to rerun Operating Stage Two Prompt 61.

Conclude exactly:

`ATTACHMENT ARCHIVE REPAIR STAGE A READ-ONLY QUALIFICATION: PASS / FAIL / NOT REACHED`

`EXPLICIT HUMAN AUTHORIZATION PRECEDED REAL ARCHIVE MUTATION: YES / NO / NOT REACHED`

`ONE CONFIRMATION ADMITTED ONLY THE EXACT DISPLAYED BOUNDED PLAN: YES / NO / NOT REACHED`

`EXECUTOR AUTO-CHAINED A SECOND REPAIR BATCH: YES / NO / NOT REACHED`

`FRESH COVERAGE RECONSTRUCTED THE REAL REPAIR EFFECTS: YES / NO / NOT REACHED`

`UNRESOLVED COVERAGE REMAINED FACTUAL WITHOUT RESTART LOOP: YES / NO / NOT REACHED`

`FRESH PROCESS RECONSTRUCTED REPAIR STATE WITHOUT A DURABLE CURSOR: YES / NO / NOT REACHED`

`ATTACHMENT ARCHIVE REPAIR HUMAN LIVE QUALIFICATION: PASS / FAIL / AMBIGUOUS`

`READY TO AUTHORIZE ANOTHER BOUNDED REPAIR BATCH: YES / NO`

`READY TO RERUN OPERATING STAGE TWO PROMPT 61: YES / NO`

Then STOP.
