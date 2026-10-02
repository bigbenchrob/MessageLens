# MessageLens Feature 34
## 45 — Build Direct-Launch AppCzar FDA Experiment

This is a bounded human experiment.

The purpose is to determine whether the current AppCzar source-access observation
changes when MessageLens Development is launched directly by macOS rather than
as a VS Code / `flutter run` child.

Current human observation:

- Full Disk Access for `MessageLens Development` was turned OFF in System
  Settings;
- when launched under VS Code, AppCzar still reported that the Messages source
  could be opened and therefore currently displayed `Full Disk Access = TRUE`;
- this exposed an important Fair-Witness issue: source readability and the FDA
  setting are not the same proposition.

We now want a clean direct-launch experiment.

Do NOT change AppCzar logic in this task.
Do NOT change the FDA wording yet.
Do NOT modify source or tests.
Do NOT stage, commit, or push.
Do NOT launch the app yourself.
Do NOT touch production.

---

# 1. Baseline

Worktree:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Require:

- branch `fix/onboarding-import-stuck-state`;
- HEAD/upstream `9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`;
- Prompt 32 + Prompt 35 + Prompt 44 accumulated development changes present;
- index empty;
- shared-instructions submodule clean;
- no additional source drift.

Read Response 44 before building.

---

# 2. Stop any currently running development instance

Determine whether any `MessageLens Development` process is running.

If one is running, report its executable path and parent process.

Do not kill it.

Ask the human to quit the current development app normally before the direct
launch experiment if necessary.

The new test must not accidentally reuse an already-running VS Code-launched
process.

---

# 3. Build the exact current development artifact

Using the current main worktree, build the existing Debug development target.

Do not alter build identity.

After build, record:

- bundle path;
- executable path;
- bundle identifier;
- version/build;
- build identity;
- executable SHA-256;
- App.framework SHA-256;
- build timestamps;
- branch/HEAD;
- accumulated tracked diff SHA-256.

Do not launch it.

---

# 4. Preserve the AppCzar development gate without VS Code parentage

Response 44 established that the AppCzar development harness depends on the
existing launch environment:

`MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT`

A plain Finder launch without that environment is expected to miss the exact
development gate and therefore would not test the intended AppCzar harness.

For the human experiment, do NOT modify the bundle or source.

Instead, provide the exact temporary per-user launchd environment command:

```bash
launchctl setenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT "/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development"
```

Then the human will launch the built `.app` directly from Finder by double-clicking
the verified bundle.

This is intentional:

- the app is launched by macOS/LaunchServices, not VS Code;
- the required development-root environment remains available;
- no source/build change is required merely to make the diagnostic harness
  reachable.

After the experiment, provide the cleanup command:

```bash
launchctl unsetenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT
```

Do not execute either command yourself unless the human explicitly requests it.
This task is a build/handoff only.

---

# 5. Human experiment

The human will:

1. confirm `MessageLens Development` FDA remains OFF in System Settings;
2. run the `launchctl setenv ...` command above;
3. double-click the verified `MessageLens Development.app` in Finder;
4. observe the AppCzar screen;
5. record:
   - the FDA row;
   - Messages source readability;
   - source count/high-water if present;
   - diagnosis;
   - virtual coordinator;
6. quit the app normally;
7. run the `launchctl unsetenv ...` cleanup command.

Do not use VS Code or `flutter run` for this launch.

Do not run any coordinator.

---

# 6. Interpretation rules

This experiment is about direct observation.

Possible result A:

```text
Messages source unreadable
```

This would support the hypothesis that the VS Code/debug responsibility chain
was granting effective source access while the app's own FDA toggle was OFF.

Possible result B:

```text
Messages source readable
```

This would show that even a direct LaunchServices launch can currently read the
source despite the visible FDA toggle being OFF.

Either result is useful.

Do NOT infer more than the experiment proves.

In particular, do not conclude:

- “FDA is definitely inherited from VS Code” unless the direct-launch contrast
  establishes it;
- “FDA is enabled” merely because `chat.db` is readable;
- “FDA is disabled for the process” merely because the System Settings toggle is
  OFF.

The Fair-Witness fact we can always trust is:

> `Messages source is currently readable / unreadable from this process.`

---

# 7. No implementation response

Do not fix the FDA/AppCzar fact naming in this task.

This task ends after build verification and handoff.

---

# 8. Required response

Create Response 45 and report:

1. baseline verification;
2. whether a development process was already running;
3. exact build path;
4. exact build identity/hashes;
5. confirmation source/tests were unchanged;
6. confirmation app was not launched;
7. exact `launchctl setenv` command;
8. exact Finder bundle the human should double-click;
9. exact `launchctl unsetenv` cleanup command;
10. interpretation of the two possible direct-launch outcomes;
11. exact Git/worktree/index/submodule state.

Conclude exactly:

`DIRECT-LAUNCH APPCZAR FDA EXPERIMENT BUILD READY: YES / NO`

Then STOP.
