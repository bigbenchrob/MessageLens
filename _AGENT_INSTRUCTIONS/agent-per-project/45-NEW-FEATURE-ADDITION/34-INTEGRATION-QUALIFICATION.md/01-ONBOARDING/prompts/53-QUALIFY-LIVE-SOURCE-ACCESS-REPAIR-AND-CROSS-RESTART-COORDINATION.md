# MessageLens Feature 34
## 53 — Qualify Live Source Access Repair and Cross-Restart Coordination

Response 52 implemented `Source Access Repair` as the second live AppCzar coordinator.

Exactly two AppCzar coordinators are now executable:

```text
Data Update
Source Access Repair
```

All other dispositions remain virtual.

This task is a **human qualification experiment only**.

Do NOT modify source or tests.
Do NOT stage, commit, push, merge, or rebase.
Do NOT launch production MessageLens.
Do NOT use VS Code or `flutter run`.
Do NOT manually start Data Update.
Do NOT manually rerun AppCzar.
Do NOT manipulate TCC except through normal System Settings UI.

The purpose is to qualify:

```text
fresh AppCzar
-> source unreadable
-> Source Access Repair
-> human restores access
-> Check Again proves current source readability
-> RESTART

fresh AppCzar
-> independently observes current world
-> may select Data Update if source is ahead
-> if so, Data Update runs
-> RESTART

fresh AppCzar
-> independently reassesses again
-> ideally selects virtual Operating Session
```

Coordinators must never chain to each other in-process.

---

# 1. Exact build under test

Use:

`/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app`

Expected identity:

- version/build: `0.2.132+150`
- bundle identifier: `com.bigbenchsoftware.MessageLens.development`
- build identity: `developmentDebug`
- executable SHA-256:
  `83fcf0367af2459fcf5431d446b0b9cd1bbb8492fab3815c6d5c190699178209`
- App.framework SHA-256:
  `72ba6af1aff877267dd7b2841d1c5b4d3eb6d068c95ffb3e46bdb09cbc9cd18e`

Before launch:

1. verify those hashes;
2. confirm no `MessageLens Development` process exists;
3. leave production MessageLens untouched.

If artifact identity differs, STOP AND REPORT.

---

# 2. Prepare launch environment

Run:

```bash
launchctl setenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT "/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development"
```

Verify the variable is present.

---

# 3. Establish conclusive source-access failure

In:

**System Settings → Privacy & Security → Full Disk Access**

turn the visible `MessageLens Development` entry OFF.

Do not treat the visible toggle as AppCzar evidence.

Its purpose is only to create the real direct-launch condition previously shown to make the development process unable to read `chat.db`.

---

# 4. Direct-launch exact bundle

Launch:

```bash
/usr/bin/open -n "/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app"
```

Record the initial PID.

Expected fresh AppCzar evidence:

```text
Messages database
Cannot currently be read
```

with the current literal source-readability reason.

Expected disposition:

```text
Source Access Repair
```

The Source Access Repair screen should replace the AppCzar assessment automatically exactly once.

Stop immediately if:

- source readability is UNKNOWN rather than conclusively unreadable;
- Diagnostic Review is selected from a conclusive denial;
- Source Access Repair does not appear;
- another coordinator also starts;
- any FDA ON/OFF assertion appears.

---

# 5. Inspect Source Access Repair before changing anything

Record:

- heading;
- literal current failure reason;
- statement explaining that MessageLens cannot determine the FDA toggle state from this evidence;
- `Open System Settings`;
- `Check Again`;
- any other visible action.

Confirm the screen does **not** say:

- Full Disk Access is OFF;
- Full Disk Access is disabled;
- permission is missing;
- repair has succeeded;
- Data Update will run next.

---

# 6. Exercise System Settings navigation

Use `Open System Settings`.

Observe whether the expected Privacy & Security / Full Disk Access destination opens.

Return to MessageLens without changing permission yet.

The Source Access Repair screen must still show the same current source-read evidence.

Opening settings alone must not:

- trigger a probe;
- change the result;
- restart the app;
- mark anything repaired.

Record this.

---

# 7. Restore access

In System Settings, enable the visible `MessageLens Development` entry.

Return to the same still-running Source Access Repair process.

Do not relaunch manually.

Do not infer success from the toggle.

The screen should retain its prior observed evidence until the human explicitly requests a new observation.

---

# 8. Press Check Again exactly once

Press:

`Check Again`

once.

Observe the control during the check. It should be single-flight/unavailable for duplicate submission while the fresh probe is pending.

Expected successful result:

```text
The current read-only Messages source check succeeded.
```

or the exact implemented equivalent.

It must not say:

```text
Full Disk Access enabled
Permission repaired
Source Access Repair succeeded, starting Data Update
```

Successful source readability should end this coordinator's jurisdiction and request a real restart.

Do not click anything else.

---

# 9. Observe first restart boundary

Record:

- Source Access Repair PID;
- its disappearance;
- any observed interval with no development process;
- next development PID;
- next process start time.

The new process must begin with a fresh AppCzar assessment.

No Source Access Repair result/progress should survive.

If the old process does not terminate or the new process does not launch, STOP AND REPORT.

---

# 10. Observe fresh AppCzar after Source Access Repair

Record:

- Messages source readability;
- source count/high-water;
- source sample stability;
- import count/high-water;
- graph count;
- archive status;
- new-message count;
- diagnosis;
- selected coordinator.

There are two valid branches.

## Branch A — current

If source/local evidence agrees:

```text
Operating Session
```

should remain virtual.

Stop there.

## Branch B — source ahead

If source is ahead:

```text
Data Update
```

may now start automatically.

This is allowed **only because the new process independently selected it**.

Record the evidence that selected Data Update.

---

# 11. If Data Update runs, observe second restart boundary

Do not interact.

Record:

- source/local counts;
- messages imported;
- graph update;
- attachment result;
- old PID disappearance;
- new PID.

Data Update must still end in a real restart.

The new process must again begin with fresh AppCzar assessment.

No Data Update state may survive.

---

# 12. Final AppCzar assessment

Record the final fresh evidence.

If all current values reconcile, expected result:

```text
This appears to be a healthy current MessageLens installation.

Coordinator that would be called
Operating Session
```

Operating Session must remain virtual.

Do not enter Conversations.

---

# 13. Qualification invariants

The experiment passes only if:

1. conclusive source unreadability selected Source Access Repair;
2. no FDA state was asserted;
3. opening System Settings did not count as repair;
4. no polling occurred;
5. Check Again was explicit and single-flight;
6. Check Again used a fresh read-only source observation;
7. proven readability caused restart, not an in-process disposition transition;
8. no Ball/mutation work occurred in Source Access Repair;
9. fresh AppCzar after restart chose the next disposition;
10. any Data Update execution began only in a new process;
11. Data Update, if selected, still used its own restart boundary;
12. final Operating disposition, if reached, came only from fresh AppCzar evidence;
13. no coordinator result payload or historical intent crossed restarts.

---

# 14. Failure stop gates

Stop without retrying if:

- source unreadability is UNKNOWN rather than conclusive FALSE;
- Source Access Repair claims FDA state;
- `Open System Settings` changes semantic state;
- hidden polling/retry appears;
- duplicate Check Again work occurs;
- Source Access Repair acquires mutation authority;
- Source Access Repair directly invokes Data Update;
- Source Access Repair directly declares Operating;
- app fails to restart;
- stale coordinator state survives restart;
- legacy startup UI appears;
- normal app UI appears before fresh AppCzar disposition.

Preserve evidence before doing anything else.

---

# 15. Cleanup

After the final AppCzar screen is recorded:

1. quit `MessageLens Development` normally;
2. leave the development FDA entry enabled unless another permission experiment is specifically planned;
3. run:

```bash
launchctl unsetenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT
```

4. verify:

```bash
launchctl getenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT
```

returns empty.

---

# 16. Required response

Create Response 53 and report:

1. exact bundle/hash verification;
2. initial PID;
3. initial source-readability evidence;
4. initial diagnosis;
5. Source Access Repair selection;
6. Source Access Repair screen copy;
7. proof no FDA-state assertion appeared;
8. System Settings navigation result;
9. proof settings navigation alone caused no semantic change;
10. human permission action;
11. Check Again single-flight behavior;
12. fresh retest result;
13. proof no coordinator chaining occurred;
14. first restart old/new PID evidence;
15. fresh AppCzar evidence after Source Access Repair;
16. whether Operating or Data Update was selected;
17. if Data Update ran, its source/local/import/attachment result;
18. if Data Update ran, second restart old/new PID evidence;
19. final AppCzar evidence;
20. final virtual coordinator;
21. proof all Operating conclusions came only from fresh AppCzar evidence;
22. proof no stale coordinator state crossed a restart;
23. Fair-Witness verdict;
24. any errors/warnings;
25. cleanup result;
26. recommendation for the next AppCzar milestone.

Conclude exactly:

`LIVE SOURCE ACCESS REPAIR QUALIFIED: YES / NO / AMBIGUOUS`

`SOURCE ACCESS REPAIR MADE NO FDA-STATE CLAIM: YES / NO`

`SOURCE ACCESS REPAIR ENDED AT A REAL PROCESS BOUNDARY: YES / NO / NOT REACHED`

`ANY FOLLOW-ON DATA UPDATE WAS SELECTED ONLY BY FRESH APPCZAR: YES / NO / NOT APPLICABLE`

`FINAL OPERATING DISPOSITION CAME ONLY FROM FRESH EVIDENCE: YES / NO / NOT REACHED`

Then STOP.
