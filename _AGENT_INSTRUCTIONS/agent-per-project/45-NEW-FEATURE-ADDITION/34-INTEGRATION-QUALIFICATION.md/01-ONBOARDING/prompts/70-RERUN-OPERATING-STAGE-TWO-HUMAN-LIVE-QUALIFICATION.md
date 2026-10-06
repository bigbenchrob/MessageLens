# MessageLens Feature 34
## 70 — Rerun Operating Stage Two Human Live Qualification

Response 69 completed the admission correction that Prompt 61 exposed.

The architecture now distinguishes:

```text
attachmentCoverageComplete
    literal preservation-completeness fact

attachmentRepairOpportunityPresent
    current actionable-maintenance fact

Operating admission
    top-level jurisdiction decision
```

The real qualified development state after Response 68 was:

```text
required        18,281
covered          4,446
uncovered       13,835

source available     0
source absent   13,835
source UNKNOWN       0
record recovery      0
conflict/unsafe      0
```

Coverage therefore remains literally FALSE, but current repair opportunity is
FALSE and the debt is conclusively source-absent. Response 69 now permits that
truthful preservation debt to coexist with the normal Operating session.

This task reruns the previously blocked Operating Stage Two human experiment
against the exact Response 69 artifact.

This is a qualification task only.

Do NOT modify source/tests.
Do NOT stage, commit, push, merge, or rebase.
Do NOT launch production MessageLens.
Do NOT manually invoke AppCzar coordinators.
Do NOT manipulate the real attachment archive by hand.

---

# 1. Exact repository and artifact preflight

Primary worktree:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Require:

- branch:
  `fix/onboarding-import-stuck-state`;
- clean tracked worktree and index;
- branch/upstream ahead/behind `0/0`;
- one active Feature 34 worktree;
- shared-instructions submodule clean at:
  `95326f515ef4719f155ce6e223990398daad6311`.

Response 69 implementation commit:

`05651d0c61115b0eda2e294a349d48fe848096a5`

Verify it is an ancestor of current HEAD.

Response 69 says the documentation checkpoint containing Prompt 69/Response 69
was pushed after the implementation commit but cannot embed its own SHA in its
body. Resolve the actual current HEAD from Git and report it. Do not infer it.

Use exactly:

`/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app`

Expected artifact identity:

- product: `MessageLens Development`
- bundle identifier: `com.bigbenchsoftware.MessageLens.development`
- environment/build identity: `development / developmentDebug`
- version/build: `0.2.138 (156)`
- executable SHA-256:
  `cb1c42fb711fb58a0c42f80a8cddfc63d89b48cdf2be34d74f115f6790122e02`
- `Contents/Frameworks/App.framework/App` SHA-256:
  `defb7399ca9378688fc90acb240bc943d6f0af3b157811ae43edeb81109092ba`

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
4. the human-visible macOS Full Disk Access pane shows the development app
   enabled.

Record the visible FDA state only as configuration, not as proof of source
readability.

Previous qualifications have shown that the human-visible FDA toggle may say ON
while the first actual Messages read is denied. If that occurs again, use the
already-qualified Source Access Repair path and record the evidence literally.

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

This is development-root admission only.

---

# 4. Direct-launch and follow fresh AppCzar authority

Launch exactly:

```bash
/usr/bin/open -n "/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app"
```

Record PID.

Allow fresh AppCzar to classify current reality.

Legitimate transient startup jurisdictions include:

```text
Source Access Repair
Data Update
Attachment Archive Repair
```

only if current evidence actually selects them.

Do not bypass any disposition.

If Source Access Repair appears, restore source access through the existing
qualified flow and allow its real restart.

If Data Update appears because source is ahead, allow it to complete and restart.

If Attachment Archive Repair appears because current source-available uncovered
payloads have reappeared since Response 68, STOP AND REPORT the fresh partition
rather than repairing within this Operating qualification.

The intended qualification continues only when a fresh process independently
admits Operating.

---

# 5. Verify Operating admission with known attachment debt

On Operating entry, record:

- PID;
- current attachment required count;
- covered count;
- uncovered/source-absent debt count;
- source-available uncovered count;
- source UNKNOWN/conflicting count;
- exact nonblocking debt copy actually visible;
- whether the normal Conversations workspace is available;
- whether entry is semantically neutral:
  - Conversations selected;
  - no prior conversation/contact restored;
  - neutral center/right state.

Expected if current facts still resemble Response 68:

```text
coverage FALSE
repair opportunity FALSE
source available 0
source absent > 0
UNKNOWN/conflict 0
-> Operating
```

The UI must not call coverage complete or repaired.

---

# 6. Establish a known navigation witness

Select a known conversation that can safely receive a test message.

Record:

- selected contact/conversation;
- visible timeline position/anchor where practical;
- center-panel state;
- right-panel state if meaningful;
- current PID.

Do not navigate away while testing the first live update.

---

# 7. Ordinary text-message live update

Using normal Apple Messages behavior, create exactly one ordinary new text
message in the selected conversation.

Do not modify `chat.db` directly.

Record approximate send/receive time.

Then do nothing in MessageLens.

Allow up to 45 seconds for the 15-second Operating currentness observer plus the
bounded internal update and fresh attachment-actionability check.

Expected:

```text
same Operating PID
-> observer sees source ahead
-> one internal LiveGraphUpdateWorker occurrence
-> graph/import update
-> fresh attachment evidence
-> historical source-absent debt still conclusive/non-actionable
-> same Operating occurrence returns idle
```

There must be:

- no startup Data Update screen inside the same process;
- no Attachment Archive Repair handoff;
- no process restart;
- no navigation reset.

---

# 8. Verify same-session text update result

Record after settlement:

- PID;
- selected conversation/contact;
- center/right semantic view;
- whether the new text message appeared;
- whether any click/navigation/reload was needed;
- visible transient update status actually observed;
- current preservation-debt counts/status after the update.

Qualification requires:

```text
PID unchanged
navigation preserved
new message appears automatically
coverage debt remains truthful
no repair opportunity remains
```

Do not infer transient status wording that was not actually seen.

---

# 9. Verify display identity refresh

Inspect visible contact/conversation identities after the update.

Confirm:

- no `contact <id>` fallback appears;
- no identity requires navigation to refresh;
- no stale resolver state is visible.

If no identity changed in this test, report that identity rendering remained
correct rather than claiming a changed identity was tested.

---

# 10. Strong optional subtest — one attachment-bearing live message

If convenient and low-risk, send one small ordinary attachment through Apple
Messages in the same selected conversation.

This is strongly useful because it qualifies the new post-update semantics:

```text
historical debt remains FALSE coverage
+
new attachment is currently source-available
-> live worker preserves the new payload
-> fresh evidence sees no remaining source-available uncovered work
-> same PID Operating may continue
```

Do not manually alter archive files.

Record:

- PID before/after;
- selected conversation before/after;
- any visible attachment-preservation status;
- whether the new attachment-bearing message appears;
- covered/uncovered/source-available counts before/after if visible;
- whether Operating remains in the same PID.

If the new payload remains uncovered and source-available after the worker,
expected behavior is instead:

```text
stop/drain
-> real restart
-> fresh AppCzar
-> Attachment Archive Repair
```

That is not automatically a failure; it must be interpreted from the current
evidence.

If no attachment-bearing message is convenient, record `NOT EXERCISED`.

---

# 11. Fresh-process reconstruction after successful live update

After the text update (and optional attachment update) settles:

1. record current PID and debt counts;
2. quit MessageLens Development normally;
3. confirm the PID disappears;
4. direct-launch the exact same bundle again with the launchd environment still
   set.

Fresh AppCzar must reconstruct attachment facts from current durable evidence.

Expected if only source-absent debt remains:

```text
coverage FALSE
repair opportunity FALSE
-> Operating
```

Record:

- new PID;
- fresh debt counts;
- whether Attachment Archive Repair appears;
- whether Diagnostic Review appears;
- whether Operating is admitted;
- whether fresh Operating entry is semantically neutral.

This proves no in-memory debt waiver is required.

---

# 12. Re-establish navigation for source-access-loss qualification

In the fresh Operating session:

1. select a known conversation;
2. record PID and navigation state;
3. wait until no currentness update is active.

Do not create another source delta.

---

# 13. Qualify source-access loss during Operating

While Operating remains active, use normal macOS System Settings to turn the
human-visible `MessageLens Development` Full Disk Access entry OFF.

Do not manually restart MessageLens.

Do not treat the toggle itself as MessageLens evidence.

Wait for the next Operating currentness observation.

Expected:

```text
current source read conclusively fails
-> factual source-unreadable issue
-> stop accepting currentness work
-> stopAndDrain()
-> real process restart
-> fresh AppCzar
-> Source Access Repair if current source still unreadable
```

Record:

- old Operating PID;
- factual issue/status actually observed;
- old PID disappearance;
- any observable no-process interval;
- replacement PID;
- fresh Source Access Repair presentation.

There must be no in-process Source Access Repair handoff.

---

# 14. Restore source access and return to Operating

Once fresh Source Access Repair is visible:

1. restore the development FDA entry;
2. return to the same repair process;
3. press `Check Again` exactly once;
4. allow its real restart;
5. allow any natural Data Update if source changed while access was unavailable;
6. allow fresh AppCzar to reassess attachment debt.

Expected when source remains conclusive/non-actionable:

```text
fresh AppCzar
-> Operating with truthful debt
```

Record PID boundaries and final disposition.

---

# 15. stopAndDrain real-process corroboration

The source-loss path is the human corroboration for the Operating drain
boundary.

Record evidence that:

- no later currentness observation starts in the old occurrence after source
  loss;
- old PID disappears before the replacement process owns AppCzar authority;
- no stale update/progress from the old occurrence appears in the new process.

Do not deliberately interrupt an active archive write.

Deterministic tests remain the proof of mid-mutation drain behavior.

---

# 16. Fair-Witness review

Across the whole qualification confirm:

- coverage remains FALSE while debt exists;
- source-absent debt is not called covered;
- source-absent debt is not called lost;
- repair opportunity FALSE is not described as coverage complete;
- Operating admission does not rely on a remembered baseline or waiver;
- source readability is not inferred from the FDA toggle;
- new source-available uncovered work does not get silently ignored;
- UNKNOWN/conflicting evidence does not get treated as source-absent;
- top-level jurisdiction changes happen only across real process boundaries.

---

# 17. Stop gates

STOP AND REPORT if:

- source-absent-only debt still blocks Operating;
- Operating admission changes coverage FALSE to TRUE;
- repair opportunity is inferred from historical counts;
- the ordinary text update causes a restart despite conclusive source-absent-only
  debt;
- successful text update resets navigation;
- the new message does not appear after bounded update completion;
- source-available uncovered attachment evidence is ignored;
- UNKNOWN/conflicting attachment evidence returns Operating to idle;
- source loss invokes Source Access Repair in-process;
- legacy Journey/readiness UI appears.

Preserve evidence before further action.

---

# 18. Cleanup

At the end:

1. leave development FDA enabled;
2. quit any remaining MessageLens Development process normally;
3. confirm no development process remains;
4. run:

```bash
launchctl unsetenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT
```

5. verify the value is empty;
6. do not modify/stage/commit source or tests.

---

# 19. Qualification verdict

A full PASS requires:

```text
fresh source-absent-only debt admits Operating truthfully

ordinary text delta updates in same PID

navigation is preserved

new text appears automatically

fresh process reconstructs debt and still admits Operating

source-access loss drains and crosses a real process boundary

fresh AppCzar owns Source Access Repair

source restoration returns through fresh AppCzar authority
```

The optional attachment-bearing subtest strengthens the evidence but is not
required for the text/currentness qualification.

---

# 20. Required response

Create Response 70 and report:

1. exact Git HEAD/upstream state;
2. Response 69 implementation ancestry;
3. exact artifact/hash verification;
4. human-visible FDA preflight;
5. launchd development-root value;
6. initial PID/path;
7. any Source Access Repair/Data Update startup path;
8. fresh Operating admission evidence;
9. fresh coverage/repair-opportunity/debt state;
10. exact nonblocking debt presentation;
11. neutral Operating entry result;
12. navigation witness before text delta;
13. text delta creation method/time;
14. live currentness timing/status actually observed;
15. PID after text update;
16. navigation preservation result;
17. new-message automatic appearance result;
18. display-identity result;
19. post-text attachment-actionability/debt result;
20. attachment-bearing subtest result or NOT EXERCISED;
21. fresh-process PID after normal quit/relaunch;
22. fresh reconstructed coverage/repair-opportunity/debt state;
23. fresh Operating admission/neutrality result;
24. source-loss starting PID/navigation state;
25. source-loss issue/status;
26. source-loss old/new PID boundary;
27. fresh Source Access Repair result;
28. source-restoration sequence;
29. final fresh AppCzar disposition;
30. stopAndDrain real-process corroboration;
31. Fair-Witness verdict;
32. errors/warnings/evidence limitations;
33. cleanup result;
34. overall Operating Stage Two qualification verdict;
35. recommendation for Feature 34 checkpoint/next milestone.

Conclude exactly:

`SOURCE-ABSENT ATTACHMENT DEBT COEXISTED WITH OPERATING: YES / NO / NOT REACHED`

`OPERATING-OWNED LIVE CURRENTNESS HUMAN QUALIFICATION: PASS / FAIL / AMBIGUOUS`

`ORDINARY TEXT UPDATE COMPLETED IN THE SAME PID: YES / NO / NOT REACHED`

`SUCCESSFUL LIVE UPDATE PRESERVED SAME-SESSION NAVIGATION: YES / NO / NOT REACHED`

`NEW MESSAGE APPEARED WITHOUT NAVIGATION OR RESTART: YES / NO / NOT REACHED`

`FRESH PROCESS RECONSTRUCTED DEBT WITHOUT A WAIVER AND ADMITTED OPERATING: YES / NO / NOT REACHED`

`SOURCE ACCESS LOSS ENDED OPERATING AT A REAL PROCESS BOUNDARY: YES / NO / NOT REACHED`

`FRESH APPCZAR OWNED THE POST-RESTART SOURCE-ACCESS DISPOSITION: YES / NO / NOT REACHED`

`READY TO CHECKPOINT OPERATING STAGE TWO HUMAN QUALIFICATION: YES / NO`

Then STOP.
