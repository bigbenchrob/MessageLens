# MessageLens Feature 34
## 56 — Qualify AppCzar Operating Session Stage One: Neutral Shell

Response 55 implemented Operating Session Stage One.

The exact development AppCzar route can now admit the real MessageLens workspace
only after a fresh healthy/current assessment, with these deliberate Stage One
properties:

```text
fresh AppCzar
-> Operating Session
-> normal workspace
-> neutral Conversations state
-> no restored contact/conversation selection
-> no Journey/readiness authority
-> no ambient ChatDbChangeMonitor
```

This task is a **human qualification experiment only**.

Do NOT modify source or tests.
Do NOT stage, commit, push, merge, or rebase.
Do NOT launch production MessageLens.
Do NOT use VS Code or `flutter run`.
Do NOT set `MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT`.
Do NOT test incoming-message live updates in this milestone.
Do NOT manually manufacture a source delta.

The purpose is to prove the fresh-evidence-to-normal-shell handoff and to prove
that a later process does not restore historical semantic navigation.

---

# 1. Exact build under test

Use the exact Response 55 artifact:

`/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app`

Expected identity:

- bundle identifier:
  `com.bigbenchsoftware.MessageLens.development`
- product:
  `MessageLens Development`
- version/build:
  `0.2.133 (151)`
- executable SHA-256:
  `b3d06d0711084d16f7594856e0432b7163c92c7c5f672d8fdf595ce567b142a4`
- App.framework SHA-256:
  `3b5f513c45e22fea3c8ba837589375e2bca6809ce9a848bbc0f1383612782028`

Before launch:

1. verify the hashes;
2. confirm no `MessageLens Development` process is running;
3. confirm the qualified WD development data folder and
   `Toshiba_manual_bu` attachment archive are connected;
4. confirm the exact development app bundle is enabled under
   **System Settings → Privacy & Security → Full Disk Access**;
5. confirm:

```bash
launchctl getenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT
```

returns empty.

If the artifact differs, STOP AND REPORT.

---

# 2. First direct launch

Launch exactly:

```bash
/usr/bin/open -n "/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app"
```

Record the initial PID.

Observe the fresh AppCzar assessment.

There are two valid initial paths.

## Path A — Operating immediately

If current source/import/graph evidence already agrees, AppCzar should select:

`Operating Session`

and admit the normal workspace.

Continue to Section 3.

## Path B — natural Data Update first

If ordinary Messages activity has created a real source delta since the build,
AppCzar may select the already-qualified `Data Update`.

Do not interfere.

Allow Data Update to finish and cross its real restart boundary.

Record old/new PIDs.

The new process must perform a fresh AppCzar assessment and may then select
Operating Session if the current evidence reconciles.

Continue only after fresh AppCzar admits Operating.

Do not manufacture or suppress a natural delta.

If AppCzar selects any other disposition, STOP AND REPORT the exact evidence.

---

# 3. Qualify the first Operating frame

As soon as the normal workspace appears, before clicking anything, record the
visible state.

Required neutral semantic state:

- sidebar mode: Messages;
- top branch: Conversations;
- selected conversation: none;
- selected contact: none;
- selected handle: none;
- no Settings context;
- center panel empty/neutral;
- right panel empty;
- no Environment Readiness panel;
- no Onboarding panel;
- no pipeline-incident takeover.

Take a screenshot before interacting if practical.

This must be prevention of restoration, not a visible flash of old content that
is then cleared.

If a prior contact/conversation appears even briefly as startup semantic state,
STOP AND REPORT.

---

# 4. Confirm Contacts identity is correct on first use

Open Contacts.

Before selecting any contact, inspect the visible contact list.

Confirm:

- normal contact names are present immediately;
- there are no fallback labels such as `contact <id>`;
- no click/navigation/provider recreation is required to repair names.

If fallback IDs appear and then repair after selecting something, STOP AND
REPORT.

Record the result.

---

# 5. Confirm ordinary same-session navigation

Within this admitted Operating occurrence:

1. select a contact;
2. navigate to one of that contact's conversations if convenient;
3. navigate back to Conversations;
4. select a conversation.

Confirm normal feature resolution and panel behavior work after admission.

This same-session navigation is legitimate Operating state.

Do not invoke Advanced Start Fresh.
Do not test live incoming-message updates.

Record the final semantic selection before quitting, because that gives us a
known historical navigation value to challenge on the next launch.

---

# 6. Normal quit

Quit `MessageLens Development` normally.

Record the PID disappearance.

Do not clear navigation preferences or modify overlay state manually.

The purpose is to leave whatever normal same-session preference persistence the
existing UI writes, then prove that the next fresh Operating occurrence ignores
it for startup semantics.

---

# 7. Second direct launch

Run the exact same command again:

```bash
/usr/bin/open -n "/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app"
```

Record the new PID.

A fresh AppCzar assessment must occur again.

As before, a natural Data Update is allowed if current evidence requires it.
If so, allow its restart and wait for the subsequent fresh Operating admission.

Do not manually rerun assessment or restore navigation.

---

# 8. Qualify neutral state after historical navigation exists

When the second Operating workspace appears, inspect it before clicking.

It must again begin:

```text
Messages
-> Conversations
-> no selected conversation
-> no selected contact
-> neutral/empty center and right panels
```

The prior session's selected contact/conversation must **not** become the current
startup state.

The durable preference may still exist on disk. This experiment is about
semantic non-consumption at fresh Operating entry, not deletion of history.

Record the result and screenshot if practical.

---

# 9. Legacy-authority absence review

Across both Operating occurrences, confirm no visible evidence that the old
semantic authorities regained control:

- no `Checking databases…`;
- no Environment Readiness;
- no Journey/onboarding modal;
- no readiness-owned center content;
- no pipeline-incident startup takeover;
- no old completion/recovery UI;
- no restored selected entity at startup.

Also confirm there is no live-updating/currentness claim. Ambient live update is
intentionally absent in Stage One.

---

# 10. Advanced Start Fresh visibility

Open Settings far enough to inspect whether Advanced Start Fresh is available
in the AppCzar Operating route.

Expected Stage One behavior:

- Advanced Start Fresh is hidden/disabled in this exact development Operating
  composition;
- no Journey-owned reset overlay is mounted.

Do not execute any reset action.

Record only whether the control is absent/disabled as designed.

---

# 11. Window restoration check

If practical, distinguish visual restoration from semantic restoration.

It is acceptable for the second launch to restore visual state such as:

- window size;
- window position;
- appearance/theme.

It must not restore semantic state such as:

- selected contact;
- selected conversation;
- center/right content;
- readiness/onboarding panel.

Record any visual restoration observed.

---

# 12. Stage One limitation

Do not test incoming Messages during this experiment.

`ChatDbChangeMonitor` and Operating-owned live currentness are deliberately
disabled in Stage One.

A source delta that happens naturally before a fresh AppCzar assessment is fine
and may invoke startup Data Update.

A source delta that occurs after Operating admission is outside this milestone
and should not be used to judge Stage One.

---

# 13. Failure stop gates

STOP without retrying if any of the following occurs:

- Operating admits from a non-Operating AppCzar disposition;
- old contact/conversation content appears during first shell construction;
- a prior semantic selection restores on the second launch;
- Contacts initially show fallback `contact <id>` identities;
- names repair only after clicking/selecting;
- Environment Readiness or Journey UI appears;
- legacy center-panel takeover occurs;
- ambient `ChatDbChangeMonitor` behavior is visibly active;
- Advanced Start Fresh invokes old Journey authority;
- normal shell is mounted before fresh AppCzar admission.

Preserve screenshots/logs and report exactly what happened.

---

# 14. Cleanup

After recording the second neutral Operating state:

1. quit `MessageLens Development` normally;
2. confirm no development process remains;
3. leave the development FDA entry enabled;
4. verify:

```bash
launchctl getenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT
```

is still empty.

No launch environment cleanup command should be necessary because none was set
for this experiment.

---

# 15. Required response

Create Response 56 and report:

1. exact bundle/hash verification;
2. initial process state and PID;
3. first fresh AppCzar evidence/disposition;
4. whether a natural Data Update occurred first;
5. any restart PID evidence before first Operating admission;
6. first Operating admission result;
7. first-frame sidebar/top-branch state;
8. first-frame selected conversation/contact/handle state;
9. first-frame center/right panel state;
10. absence/presence of readiness/onboarding/pipeline takeover;
11. Contacts identity result before any contact selection;
12. whether any fallback `contact <id>` labels appeared;
13. same-session navigation result;
14. known final selection before first quit;
15. first quit result;
16. second-launch PID;
17. second fresh AppCzar evidence/disposition;
18. any natural Data Update/restart before second Operating admission;
19. second Operating first-frame state;
20. whether historical semantic navigation restored;
21. Settings / Advanced Start Fresh visibility result;
22. visual window restoration observations;
23. confirmation ambient live currentness was not tested;
24. any errors/warnings;
25. cleanup result;
26. qualification verdict;
27. recommendation for the next Operating live-currentness milestone.

Conclude exactly:

`APPCZAR OPERATING SESSION STAGE ONE LIVE QUALIFICATION: PASS / FAIL / AMBIGUOUS`

`FIRST OPERATING FRAME WAS SEMANTICALLY NEUTRAL: YES / NO / AMBIGUOUS`

`CONTACT IDENTITIES WERE CORRECT ON FIRST USE: YES / NO / AMBIGUOUS`

`SECOND LAUNCH RESTORED PRIOR SEMANTIC NAVIGATION: YES / NO / AMBIGUOUS`

`LEGACY JOURNEY/READINESS UI APPEARED IN OPERATING: YES / NO / AMBIGUOUS`

`READY TO DESIGN OPERATING-OWNED LIVE CURRENTNESS: YES / NO`

Then STOP.
