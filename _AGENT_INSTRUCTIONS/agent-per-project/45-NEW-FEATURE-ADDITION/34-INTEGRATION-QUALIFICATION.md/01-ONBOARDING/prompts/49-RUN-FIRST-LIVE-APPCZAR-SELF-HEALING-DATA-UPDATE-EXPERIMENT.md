# MessageLens Feature 34
## 49 — Run the First Live AppCzar Self-Healing Data Update Experiment

Response 48 implemented the first executable AppCzar coordinator.

Only the current-source-ahead disposition is live:

```text
AppCzar proves that a complete healthy local dataset exists
and the current Messages source is ahead
    -> Data Update Coordinator
```

Every other AppCzar coordinator remains virtual.

The Data Update coordinator:

- reuses the existing incremental import/graph/attachment machinery;
- acquires the existing typed archive-mutation tenure;
- keeps progress in memory only;
- cannot declare Operating;
- ends successful work by releasing mutation authority and causing a real
  process restart;
- relies on the newly launched AppCzar to determine what is true afterward.

This task is a **human qualification experiment only**.

Do NOT modify source or tests.
Do NOT stage, commit, or push.
Do NOT launch production MessageLens.
Do NOT open normal Conversations/Contacts UI.
Do NOT manually run another coordinator.
Do NOT manually reset data.

---

# 1. Exact build under test

Use this exact bundle:

`/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app`

Verified identity:

- version/build: `0.2.131+149`
- bundle ID: `com.bigbenchsoftware.MessageLens.development`
- build identity: `developmentDebug`
- executable SHA-256:
  `faf6d1f58550bb6eecfc9d72bd7a9130c84265baeb3c4762d092b84ee659f7c2`
- App.framework SHA-256:
  `418be669ccbd5022d123d03c347338fb07a6569bff5caa88041f665f3a78d98a`

Before beginning, confirm no `MessageLens Development` process is running.

---

# 2. Prepare direct-launch environment

Run:

```bash
launchctl setenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT "/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development"
```

Ensure the development app currently has whatever macOS permission state is
needed for the Messages source to be readable in a direct Finder/LaunchServices
launch.

Do not use VS Code or `flutter run` for this experiment.

---

# 3. Launch

Launch exactly:

```bash
/usr/bin/open -n "/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app"
```

or double-click that exact bundle in Finder.

Record the first AppCzar assessment.

In particular record:

- Messages source count/high-water;
- MessageLens import count/high-water;
- graph count;
- new-message count;
- archive status;
- diagnosis;
- selected coordinator.

If AppCzar no longer sees current-source work and selects `Operating Session`,
that is a valid result: ordinary Messages activity may have changed since the
previous experiment. Stop and report; do not manufacture a delta.

If AppCzar selects anything other than `Data Update` or healthy/current
`Operating Session`, stop and report the exact evidence.

---

# 4. If Data Update is selected

Do nothing.

The coordinator should start automatically exactly once.

Observe and record:

- transition from AppCzar assessment to Data Update screen;
- source count;
- local count;
- messages to import;
- live stage text;
- live completed/total units when supplied;
- attachment examined/preserved counts if any;
- any literal warning/failure.

Take a screenshot if practical.

Do not click or launch anything else while the coordinator owns the app.

---

# 5. Observe the restart boundary

On successful completion, the current process should terminate automatically.

A new process should then launch automatically through LaunchServices.

Record, if convenient:

- old PID;
- new PID;
- whether there is a visible process/app disappearance/reappearance;
- whether any stale Data Update progress survives.

The new process must start at AppCzar assessment from zero.

There must be no in-process transition such as:

```text
Data Update complete
-> Operating
```

---

# 6. Observe the fresh AppCzar result

On the restarted process, record the complete AppCzar conclusion.

The desired result is current evidence such as:

```text
Messages source            N
MessageLens import         N
MessageLens graph          N
New messages               0
source/local high-water    equal
```

followed by:

```text
Diagnosis
This appears to be a healthy current MessageLens installation.

Coordinator that would be called
Operating Session
```

`Operating Session` must remain virtual. The screen should stay on AppCzar.

Do not open Conversations.

---

# 7. Fair-Witness review

Check that nothing on either the Data Update screen or restarted AppCzar screen
claims more than the evidence establishes.

Specifically:

- no `Full Disk Access = ...` claim;
- no `Update succeeded therefore Operating` claim;
- no historical statement such as `previous update completed`;
- no old operation/resume state;
- no remembered pre-restart AppCzar facts.

The post-restart healthy conclusion must be independently supported by the new
assessment.

---

# 8. Failure stop gate

If any of the following occurs, stop without retrying:

- Data Update screen does not appear;
- more than one coordinator occurrence appears;
- update stalls with no truthful progress;
- mutation/authority error appears;
- attachment preservation reports failure/defer;
- app quits but does not relaunch;
- app relaunches into legacy startup UI;
- new AppCzar process still shows the old pre-update counts despite current
  source readability;
- normal application UI appears without a fresh AppCzar diagnosis;
- any stale operation/Journey/readiness state appears.

Preserve screenshots/logs and report exactly what happened.

Do not manually relaunch until the failure evidence is recorded.

---

# 9. Cleanup

After the experiment is complete and the final AppCzar screen has been recorded:

1. quit MessageLens Development normally;
2. run:

```bash
launchctl unsetenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT
```

3. verify:

```bash
launchctl getenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT
```

returns empty.

---

# 10. Required response

Create Response 49 containing:

1. exact bundle identity;
2. confirmation no stale process was reused;
3. initial AppCzar observations;
4. initial diagnosis;
5. initial selected coordinator;
6. whether Data Update started automatically;
7. Data Update source/local counts;
8. message import progress;
9. attachment progress/result;
10. mutation/authority observations;
11. old PID;
12. restart behavior;
13. new PID;
14. proof the new process performed a fresh AppCzar assessment;
15. post-restart source/import/graph counts;
16. post-restart high-water comparison;
17. post-restart new-message count;
18. post-restart diagnosis;
19. post-restart virtual coordinator;
20. confirmation Operating was not entered in-process;
21. confirmation no stale pre-restart facts/progress survived;
22. any errors/warnings;
23. Fair-Witness verdict;
24. launchctl cleanup result;
25. recommendation for the next AppCzar coordinator experiment.

Conclude exactly:

`FIRST LIVE APPCZAR SELF-HEALING EXPERIMENT: PASS / FAIL / AMBIGUOUS`

`DATA UPDATE RAN EXACTLY ONCE: YES / NO / AMBIGUOUS`

`SUCCESS CROSSED A REAL PROCESS-RESTART BOUNDARY: YES / NO / AMBIGUOUS`

`FRESH APPCZAR INDEPENDENTLY REASSESSED AFTER RESTART: YES / NO / AMBIGUOUS`

`OPERATING WAS DECLARED ONLY BY FRESH EVIDENCE: YES / NO / NOT REACHED`

Then STOP.
