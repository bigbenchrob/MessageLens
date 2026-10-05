# MessageLens Feature 34
## 61 — Qualify Operating-Owned Live Currentness

Response 60 implemented Operating Session Stage Two and left it entirely
unstaged for human qualification.

The qualified architecture is now:

```text
fresh AppCzar
-> Operating Session admitted
-> normal workspace

Operating-owned currentness service
-> one bounded observation every 15 seconds
-> no delta: silence
-> ordinary source-ahead:
     one internal live-update occurrence
     -> one existing Ball tenure
     -> LiveGraphUpdateWorker
     -> attachment preservation
     -> fresh attachment-coverage verification
     -> same PID
     -> same Operating occurrence
     -> same navigation
```

The service is internal to Operating. It is not a fourth AppCzar disposition and
does not call the startup Data Update coordinator.

This task is a **human qualification experiment only**.

Do NOT modify source or tests.
Do NOT stage, commit, push, merge, or rebase.
Do NOT launch production MessageLens.
Do NOT use VS Code or `flutter run`.
Do NOT manually invoke Data Update or AppCzar reassessment.
Do NOT delete/move a real archived attachment to manufacture a failure.

The goals are to qualify:

1. ordinary same-session live update in the same PID;
2. preservation of current navigation during that update;
3. automatic data/identity refresh without a click or restart;
4. attachment preservation/coverage if a practical attachment-bearing message
   is available;
5. source-access loss as an Operating-ending event that drains and restarts into
   fresh AppCzar authority.

---

# 1. Exact Stage Two artifact

Use the exact Response 60 development artifact:

`/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app`

Expected identity:

- product: `MessageLens Development`
- bundle identifier: `com.bigbenchsoftware.MessageLens.development`
- version/build: `0.2.135 (153)`
- executable SHA-256:
  `47f2358cd6dbe4aab1581e95ed466a4dac1c13b51dca73a4a3abd072f8ca12a6`
- App.framework executable SHA-256:
  `ab1a92c090ff168f736ab0e9dde17979449fecff2630f971fc2fe259e0ad1c12`

Before launch:

1. verify both hashes;
2. confirm no `MessageLens Development` process is running;
3. confirm the WD development data folder is connected;
4. confirm the Toshiba attachment archive is connected;
5. confirm the exact development app is enabled in the human-visible macOS Full
   Disk Access settings.

If artifact identity differs, STOP AND REPORT.

---

# 2. Set the exact development AppCzar launch contract

Run in the host user launchd domain:

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

This value is root admission only. It is not source-readability or FDA
testimony.

---

# 3. Direct launch and reach Operating

Launch exactly:

```bash
/usr/bin/open -n "/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app"
```

Record the PID.

Fresh AppCzar may naturally choose an already-qualified startup coordinator
before Operating:

- Source Access Repair, if source is conclusively unreadable;
- Data Update, if the current source is ahead.

Allow those existing qualified coordinator/restart paths to complete without
interference.

Continue only when a fresh process independently admits Operating Session.

Record the final Operating PID. This is the PID that Stage Two should preserve
during successful ordinary live updates.

---

# 4. Establish a known navigation state

Inside Operating:

1. select a known conversation that can safely receive a test message;
2. ensure its message timeline is visible;
3. record the selected conversation/contact and any meaningful current center/
   right-panel state;
4. record the current Operating PID immediately before creating a source delta.

Do not navigate away during the live-update test.

The selected navigation state is the primary preservation witness.

---

# 5. Qualify one ordinary text-message live update

Create exactly one ordinary new Messages record in the selected conversation by
normal human use of Apple Messages or another normal device/account path.

Do not modify `chat.db` directly.

Record the approximate creation time.

Then do nothing in MessageLens.

The Operating-owned currentness service should discover the source delta on its
normal 15-second cadence.

Allow up to 45 seconds for:

```text
observation
-> bounded internal update
-> graph refresh
-> post-update coverage verification
```

Observe any compact Stage Two status surface.

Expected successful behavior:

- same MessageLens Development PID throughout;
- no AppCzar restart;
- no Data Update coordinator screen;
- no Source Access Repair screen;
- selected conversation remains selected;
- current timeline remains the active view;
- the new message becomes visible without navigation, click-to-refresh, or
  process restart;
- contact/conversation identity remains correct;
- compact update status clears after completion.

If the status surface is too transient to read completely, report only the
parts directly observed. Do not infer unobserved wording.

---

# 6. Verify same-session navigation preservation explicitly

After the new message becomes visible, compare with the state recorded in
Section 4.

Confirm:

- PID unchanged;
- selected contact unchanged, if one was selected;
- selected conversation unchanged;
- center/right semantic view unchanged except for normal data refresh;
- no neutral-startup reset occurred;
- no historical restoration logic reran.

A successful graph/message-generation update must refresh data **inside** the
current session rather than recreating the session.

---

# 7. Verify identity refresh behavior

Inspect visible contact/conversation names after the live update.

Confirm:

- no fallback `contact <id>` label appears;
- no name becomes stale until navigation;
- no click or contact selection is required to refresh identity;
- normal message/conversation rendering remains correct.

If a new identity naturally appears in the test delta, record whether it
resolves automatically. Do not manufacture a new contact solely for this test.

---

# 8. Optional but strongly useful: attachment-bearing live update

If convenient and low-risk, create one ordinary attachment-bearing Messages
record in the same selected conversation using a small locally available image
or other ordinary attachment.

Do not modify archive files directly.

Again remain in MessageLens and wait through the normal cadence.

Record:

- PID before and after;
- selected conversation before and after;
- any visible `Preserving attachments…` or `Verifying attachment coverage…`
  status;
- whether the new attachment-bearing message appears normally;
- whether the Stage Two status returns to quiet idle without a restart or
  failure.

If attachment behavior naturally defers/fails, STOP after preserving the
evidence. Do not retry around it or manipulate the archive.

If no practical attachment-bearing message is available, record this subtest as
`NOT EXERCISED`, not a failure.

---

# 9. Fresh-process coverage confirmation after successful live update

After the ordinary live-update test(s) have settled successfully:

1. record the current navigation state;
2. quit MessageLens Development normally;
3. confirm the PID disappears;
4. direct-launch the exact same bundle again while keeping the development-root
   launch environment set.

Fresh AppCzar must independently reassess.

If all durable facts are healthy, it should be able to prove attachment
coverage complete and admit Operating.

Record:

- whether any Attachment Archive Repair / Diagnostic Review disposition appears;
- whether Operating is admitted;
- any visible Attachment coverage row if the assessment can be captured;
- the new PID.

This confirms that successful same-session mutation left independently
reconstructible durable facts rather than relying on the old process's live
status.

Do not use this fresh launch to judge navigation preservation; fresh Operating
is still expected to start semantically neutral.

---

# 10. Re-establish a known Operating view for source-loss qualification

In the freshly admitted Operating session:

1. select a known conversation;
2. record PID and selected semantic state;
3. wait until no update status is active.

Do not manufacture a source delta during the source-loss test.

---

# 11. Qualify source-access loss during Operating

While MessageLens remains in Operating, use normal macOS System Settings to turn
the human-visible `MessageLens Development` Full Disk Access entry OFF.

Do not manually restart the app.

Do not treat the toggle itself as MessageLens evidence.

Wait for the next Operating currentness observation.

Expected behavior:

```text
Operating observer gets conclusive source unreadability
-> bounded source-unreadable issue is presented
-> scheduling stops
-> stopAndDrain()
-> real process restart
-> fresh AppCzar
-> Source Access Repair if source is still conclusively unreadable
```

Record:

- old Operating PID;
- any factual issue/status visible before restart;
- old PID disappearance;
- any observed no-development-process interval;
- new PID;
- fresh AppCzar / Source Access Repair screen.

There must be no in-process Source Access Repair handoff.

---

# 12. Restore source access and return to a healthy state

Once the fresh process has selected Source Access Repair:

1. use its System Settings navigation or manually return to the FDA pane;
2. enable the development app entry;
3. return to the same Source Access Repair process;
4. press `Check Again` once;
5. allow its already-qualified restart boundary;
6. allow any natural startup Data Update if fresh AppCzar discovers a source
   delta;
7. end at fresh Operating if current evidence permits.

This cleanup also verifies that Stage Two source-loss handling hands authority
back to the already-qualified AppCzar repair loop correctly.

Record the PID boundaries.

---

# 13. `stopAndDrain()` evidence

The source-loss path in Sections 11–12 proves the live restart uses the
Operating shutdown boundary.

Record any evidence available that:

- no second currentness observation starts after source loss;
- no stale update status appears in the replacement PID;
- old PID is gone before the replacement process owns AppCzar authority;
- no mutation/attachment progress from the old occurrence appears after restart.

Do not intentionally try to catch an active Ball mid-write on the real archive.

The deterministic lifecycle tests remain the governing proof that
`stopAndDrain()` waits for an admitted active mutation tenure. The human test is
only a real-process corroboration of the shutdown/restart boundary.

---

# 14. Fair-Witness review

Across the experiment, confirm MessageLens never claims more than current
evidence supports.

Specifically:

- no FDA ON/OFF claim from source readability;
- no `Current` conclusion merely because a worker Future returned;
- no successful live-update conclusion before post-worker attachment coverage
  is verified;
- no historical operation-success flag appears;
- no coordinator is selected in-process by Operating;
- fresh AppCzar owns every top-level disposition after a restart.

---

# 15. Failure stop gates

STOP without retrying if:

- the ordinary text update causes a process restart;
- startup Data Update appears inside the existing Operating PID;
- navigation resets during successful live update;
- the new message does not appear after bounded update completion;
- identity becomes stale until navigation;
- Stage Two silently reports success after attachment coverage FALSE/UNKNOWN;
- source loss invokes Source Access Repair without a process restart;
- old currentness/progress state appears in a replacement PID;
- legacy Journey/readiness UI appears;
- the development AppCzar route is not selected despite the exact launch
  environment.

Preserve screenshots/logs/process evidence before any further action.

---

# 16. Cleanup

At the end:

1. leave the development FDA entry enabled;
2. quit any remaining MessageLens Development process normally;
3. confirm no development process remains;
4. run:

```bash
launchctl unsetenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT
```

5. verify:

```bash
launchctl getenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT
```

returns empty.

Do not stage, commit, or alter the Prompt 60 implementation.

---

# 17. Required response

Create Response 61 and report:

1. exact artifact/hash verification;
2. exact launchd development-root value;
3. startup AppCzar/coordinator path to Operating;
4. Operating PID before live update;
5. selected navigation state before live update;
6. source delta creation method and time;
7. currentness observation/update timing;
8. compact progress/status actually observed;
9. PID after successful text update;
10. whether selected navigation was preserved exactly;
11. whether the new message appeared without navigation/restart;
12. identity behavior after update;
13. attachment-bearing subtest result or NOT EXERCISED;
14. post-update fresh-process attachment-coverage result;
15. fresh Operating admission after durable recheck;
16. source-loss test starting PID/navigation state;
17. source-loss issue/status actually observed;
18. source-loss restart old/new PID evidence;
19. fresh AppCzar/Source Access Repair result;
20. proof no in-process coordinator chaining occurred;
21. source-access restoration sequence;
22. final restart/update path back to healthy Operating;
23. `stopAndDrain()` real-process corroboration;
24. Fair-Witness verdict;
25. any errors/warnings/evidence limitations;
26. cleanup result;
27. qualification verdict;
28. recommendation for checkpointing Stage Two and the next AppCzar milestone.

Conclude exactly:

`OPERATING-OWNED LIVE CURRENTNESS LIVE QUALIFICATION: PASS / FAIL / AMBIGUOUS`

`ORDINARY LIVE UPDATE COMPLETED IN THE SAME PID: YES / NO / NOT REACHED`

`SUCCESSFUL LIVE UPDATE PRESERVED SAME-SESSION NAVIGATION: YES / NO / NOT REACHED`

`NEW MESSAGE APPEARED WITHOUT NAVIGATION OR RESTART: YES / NO / NOT REACHED`

`POST-UPDATE FRESH APPCZAR PROVED ATTACHMENT COVERAGE: YES / NO / NOT REACHED`

`SOURCE ACCESS LOSS ENDED OPERATING AT A REAL PROCESS BOUNDARY: YES / NO / NOT REACHED`

`FRESH APPCZAR OWNED THE POST-RESTART DISPOSITION: YES / NO / NOT REACHED`

Then STOP.
