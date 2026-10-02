# MessageLens Feature 34
## 50 — Restore Direct-Launch Source Access and Rerun the Self-Healing Data Update Experiment

Response 49 did **not** expose an AppCzar defect.

The exact qualified development bundle launched as a fresh LaunchServices process, but that process could not read the Messages source. AppCzar therefore truthfully selected the still-virtual `Source Access Repair` coordinator and stopped. No mutation authority was acquired and no Data Update work ran.

This task has two purposes only:

1. restore direct-launch Messages-source access for the exact current development bundle without changing MessageLens code; and
2. rerun the exact self-healing Data Update experiment once that access is independently proven.

Do NOT modify source or tests.
Do NOT stage, commit, or push.
Do NOT relax AppCzar evidence rules.
Do NOT make Source Access Repair executable.
Do NOT use VS Code or `flutter run` for the qualification launch.
Do NOT touch production MessageLens.

---

# 1. Exact build under test

Use the existing Response 48 bundle unchanged:

`/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app`

Expected identity:

- version/build: `0.2.131+149`
- bundle ID: `com.bigbenchsoftware.MessageLens.development`
- executable SHA-256:
  `faf6d1f58550bb6eecfc9d72bd7a9130c84265baeb3c4762d092b84ee659f7c2`
- App.framework SHA-256:
  `418be669ccbd5022d123d03c347338fb07a6569bff5caa88041f665f3a78d98a`

Before doing anything, verify those hashes and confirm no `MessageLens Development` process is running.

If the artifact differs, STOP AND REPORT.

---

# 2. Restore direct-launch source access manually

This is a human macOS permission step, not an AppCzar or code change.

The human should open:

**System Settings → Privacy & Security → Full Disk Access**

and ensure the entry corresponding to the exact current:

`MessageLens Development.app`

is enabled.

If the visible entry is already enabled but the exact direct-launch bundle still cannot read the Messages source:

1. toggle that entry OFF;
2. toggle it ON again;
3. if macOS still denies the exact direct-launch bundle, remove the stale entry and add the exact current bundle from the path above, then enable it.

Do not change production MessageLens permission.

Do not infer that the setting is effective merely because the toggle is visible. The qualification criterion is the next AppCzar direct observation:

> `Messages database — Readable ...`

---

# 3. Set the development-root launch environment

Run:

```bash
launchctl setenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT "/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development"
```

Do not use VS Code.

---

# 4. Permission-verification launch

Direct-launch the exact bundle:

```bash
/usr/bin/open -n "/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app"
```

AppCzar must freshly assess.

## If Messages source is still unreadable

STOP.

Record:

- AppCzar Messages-database row;
- source-readability provenance from Assessment Details;
- diagnosis;
- virtual coordinator;
- exact visible macOS permission state.

Do not toggle repeatedly inside the same experiment and do not manufacture Data Update preconditions.

## If Messages source is readable

Continue.

Record source count/high-water, local count/high-water, graph count, new-message count, diagnosis, and selected coordinator.

---

# 5. Branch A — source is readable but there is no update work

If fresh AppCzar now selects:

`Operating Session`

because source/local evidence already reconciles, this is a valid qualification result.

Do not fabricate new Messages merely to force Data Update.

Record the healthy-current evidence and stop. The live Data Update path remains unexercised and can be qualified later when a natural source delta exists.

---

# 6. Branch B — AppCzar selects Data Update

If fresh current evidence selects `Data Update`, do nothing.

The coordinator should start automatically exactly once.

Observe and record:

- source count;
- local/import count;
- messages to import;
- graph/update stage;
- real completed/total progress if available;
- attachment examined/preserved counts;
- any literal warning or failure.

Do not interact while the coordinator owns the app.

---

# 7. Restart boundary

On successful Data Update completion:

- the mutation tenure must be released;
- the current development process must terminate;
- LaunchServices must create a new PID;
- the new process must begin a fresh AppCzar assessment from zero.

There must be no in-process:

```text
Data Update complete -> Operating
```

Record old PID and new PID if practical.

---

# 8. Fresh post-restart assessment

Record:

- source count/high-water;
- import count/high-water;
- graph count;
- new-message count;
- source/local comparison;
- diagnosis;
- virtual coordinator.

The desired outcome, if current evidence supports it, is:

```text
This appears to be a healthy current MessageLens installation.
Coordinator that would be called: Operating Session
```

`Operating Session` must remain virtual.

Do not enter Conversations.

---

# 9. Fair-Witness stop gates

Stop immediately if:

- source access remains unavailable;
- AppCzar claims FDA state rather than source readability;
- Data Update starts when AppCzar did not select it;
- more than one coordinator starts;
- any worker claims Operating/ready in-process;
- app exits but does not relaunch;
- new process reuses old AppCzar facts/progress;
- legacy startup UI appears;
- normal app UI appears before fresh reassessment;
- mutation or attachment preservation fails.

Preserve the exact evidence. Do not retry around the failure.

---

# 10. Cleanup

After the experiment:

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

Do not remove/revoke the development app's FDA permission after the experiment unless the human specifically wants another access experiment.

---

# 11. Required response

Create Response 50 and report:

1. exact bundle/hash verification;
2. initial macOS permission state;
3. permission-restoration action taken;
4. fresh direct-launch PID;
5. fresh AppCzar source-readability result;
6. source-readability provenance;
7. source/local counts and high-waters;
8. initial diagnosis;
9. initial selected coordinator;
10. whether Data Update was naturally applicable;
11. if applicable, Data Update progress/result;
12. if applicable, attachment result;
13. mutation-authority result;
14. old PID/new PID restart proof;
15. fresh post-restart AppCzar result;
16. proof no in-process Operating declaration occurred;
17. Fair-Witness verdict;
18. errors/warnings;
19. launchctl cleanup result;
20. recommendation for next AppCzar qualification.

Conclude exactly:

`DIRECT-LAUNCH SOURCE ACCESS RESTORED: YES / NO / AMBIGUOUS`

`DATA UPDATE NATURALLY SELECTED: YES / NO`

`LIVE DATA UPDATE SELF-HEALING LOOP QUALIFIED: YES / NO / NOT EXERCISED`

`FRESH APPCZAR REASSESSMENT AFTER RESTART: PASS / FAIL / NOT REACHED`

Then STOP.
