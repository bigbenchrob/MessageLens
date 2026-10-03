# MessageLens Feature 34
## 57 — Correct the Stage One Launch Contract and Rerun Neutral-Shell Qualification

Response 56 stopped before AppCzar because the exact development AppCzar route
was not selected.

This is not currently evidence of an Operating Session implementation defect.

The qualification procedure itself omitted a previously established requirement:
the exact development AppCzar gate still depends on the admitted development
root supplied through:

`MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT`

Earlier direct-launch qualification deliberately used the launchd environment
for exactly this reason. Prompt 56 incorrectly instructed the human not to set
that environment variable.

The observed legacy Environment Readiness/Journey screen is therefore consistent
with the development AppCzar gate evaluating false before AppCzar ever had a
chance to assess source access or Operating eligibility.

This task is a corrected **human qualification experiment only**.

Do NOT modify source or tests.
Do NOT stage, commit, push, merge, or rebase.
Do NOT launch production MessageLens.
Do NOT use VS Code or `flutter run`.
Do NOT weaken or bypass the exact development gate.
Do NOT manufacture a source delta.

The purpose is to rerun Operating Session Stage One using the correct direct-
launch contract.

---

# 1. Exact build under test

Use the unchanged Response 55 artifact:

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

Verify hashes before launch.

Confirm no `MessageLens Development` process is running.

Confirm both qualified external resources are connected:

- `/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development`
- `/Volumes/Toshiba_manual_bu/ML_ADOPTION_TEST/attachment_archive`

---

# 2. Restore the exact development-gate launch environment

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

This is not an FDA setting and is not a source-access assertion.

It supplies the existing exact development-root admission input used by the
AppCzar development startup gate.

Do not change MessageLens code to avoid this requirement in Prompt 57.

---

# 3. FDA state is not the AppCzar-route selector

Before launch, inspect the visible `MessageLens Development` entry under:

**System Settings → Privacy & Security → Full Disk Access**

If it is enabled, leave it enabled.

If it is disabled, enable it.

However:

- do not treat the visible toggle as proof of source readability;
- do not stop merely because macOS later changes the visible toggle;
- the correct development AppCzar route must still load when the admitted-root
  launch environment is present.

If the source is unreadable after AppCzar starts, the already-qualified live
`Source Access Repair` coordinator is the correct response.

The key distinction is:

```text
development gate
    !=
Messages source readability
```

Prompt 57 is specifically testing that distinction.

---

# 4. First direct launch

Launch exactly:

```bash
/usr/bin/open -n "/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app"
```

Record the PID.

The first visible semantic authority must now be AppCzar or one of its explicit
live coordinator screens.

## Failure gate

STOP if the legacy screen appears again:

`MessageLens needs Full Disk Access`

with the old Journey rail / Environment Readiness presentation.

If that occurs despite the exact launchd development-root value being present,
record the runtime environment and begin a separate gate-forensics task.

Do not continue to Operating qualification.

---

# 5. Allow the already-qualified AppCzar repair chain if naturally required

There are three valid paths.

## Path A — healthy/current

Fresh AppCzar selects Operating Session directly.

Proceed to Section 6.

## Path B — source unreadable

Fresh AppCzar selects live Source Access Repair.

This is valid.

Use the already-qualified flow:

1. review/open System Settings if needed;
2. human restores access;
3. press `Check Again` once;
4. Source Access Repair ends at a real process restart;
5. fresh AppCzar reassesses.

Do not treat FDA toggle state itself as success.

## Path C — source ahead

Fresh AppCzar selects Data Update.

Allow the already-qualified Data Update coordinator to run and restart.

Fresh AppCzar then reassesses.

A chain such as:

```text
Source Access Repair
-> restart
-> Data Update
-> restart
-> Operating Session
```

is valid only because each coordinator is selected by a new AppCzar process.

Record PIDs if either repair coordinator runs.

Continue only after a fresh process independently selects Operating Session.

---

# 6. First Operating frame

As soon as the normal workspace appears, before clicking anything, record:

- sidebar mode;
- top branch;
- selected conversation;
- selected contact;
- selected handle;
- Settings context;
- center panel;
- right panel;
- any readiness/onboarding/pipeline content.

Required state:

```text
Messages
-> Conversations
-> no selected conversation
-> no selected contact
-> no selected handle
-> no Settings context
-> neutral/empty center
-> neutral/empty right
```

There must be no flash of historical contact/conversation content before the
neutral state appears.

There must be no Environment Readiness, Journey, Onboarding, or pipeline-
incident startup takeover.

Take a screenshot before interacting if practical.

---

# 7. Contacts identity on first use

Open Contacts.

Before selecting any contact, verify:

- contact names are resolved immediately;
- no `contact <id>` fallback labels appear;
- no selection/navigation action is required to repair identity.

STOP if identities are stale until a click/provider recreation occurs.

---

# 8. Same-session navigation

Within the admitted Operating occurrence:

1. select a contact;
2. open one of that contact's conversations if convenient;
3. return to Conversations;
4. select a conversation.

Confirm normal same-session navigation works.

Record the final selected contact/conversation state before quitting.

Do not test incoming-message live currentness.
Do not invoke Advanced Start Fresh.

---

# 9. Inspect Advanced Start Fresh Stage One behavior

Open Settings far enough to inspect the relevant action area.

Expected exact-development Operating behavior:

- Advanced Start Fresh is hidden or unavailable;
- no Journey-owned reset overlay is mounted.

Do not execute reset.

Record only visibility/availability.

---

# 10. Quit normally

Quit `MessageLens Development` normally.

Record PID disappearance.

Do not clear overlay/navigation preferences.

Keep the launchd development-root environment set for the second launch.

---

# 11. Second direct launch

Launch the exact same bundle again:

```bash
/usr/bin/open -n "/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app"
```

Record the new PID.

Fresh AppCzar must reassess.

If Source Access Repair or Data Update is naturally selected, allow the already-
qualified restart chain exactly as in Section 5.

Continue only after a fresh process selects Operating Session.

---

# 12. Challenge historical semantic navigation

Before clicking anything in the second Operating occurrence, verify again:

```text
Messages
-> Conversations
-> no selected conversation
-> no selected contact
-> neutral/empty center
-> neutral/empty right
```

The first session's selected contact/conversation must not restore as current
startup state.

Visual window restoration is allowed:

- size;
- position;
- appearance;
- other non-semantic geometry.

Semantic restoration is not.

Record a screenshot if practical.

---

# 13. Stage One live-currentness limitation

Do not intentionally send/receive a new message while Operating.

Do not judge Stage One by source changes occurring after Operating admission.

The ambient monitor is intentionally disabled.

Operating-owned live currentness remains the next milestone after this
qualification passes.

---

# 14. Qualification pass criteria

Stage One passes if:

1. the corrected launch contract selects AppCzar rather than legacy startup;
2. any source-access/data-update work occurs only through existing live AppCzar
   coordinators and restart boundaries;
3. fresh healthy AppCzar admits Operating;
4. first Operating frame is semantically neutral;
5. no legacy Journey/readiness authority appears;
6. Contacts names are correct on first use;
7. same-session navigation works;
8. second fresh Operating occurrence again starts neutral;
9. prior semantic navigation is not restored;
10. Advanced Start Fresh cannot revive Journey authority in Stage One;
11. no ambient live-update behavior is relied upon.

---

# 15. Cleanup

After the second Operating state is recorded:

1. quit `MessageLens Development` normally;
2. confirm no development process remains;
3. leave the development FDA entry enabled;
4. run:

```bash
launchctl unsetenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT
```

5. verify:

```bash
launchctl getenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT
```

returns empty.

---

# 16. Required response

Create Response 57 and report:

1. exact artifact/hash verification;
2. exact launchd development-root value before first launch;
3. first PID;
4. whether AppCzar route or legacy startup route appeared;
5. first AppCzar evidence/disposition;
6. any Source Access Repair sequence and restart PIDs;
7. any Data Update sequence and restart PIDs;
8. first Operating-admission PID;
9. first Operating first-frame semantic state;
10. absence/presence of legacy Journey/readiness UI;
11. Contacts identity result before selection;
12. same-session navigation result;
13. final first-session semantic selection;
14. Advanced Start Fresh visibility result;
15. first quit result;
16. second launch PID;
17. second fresh AppCzar evidence/disposition;
18. any repair/update restart sequence on second launch;
19. second Operating-admission PID;
20. second Operating first-frame semantic state;
21. whether historical semantic navigation restored;
22. visual-only restoration observations;
23. confirmation live currentness was not intentionally tested;
24. errors/warnings;
25. cleanup result;
26. Stage One qualification verdict;
27. recommendation for Operating-owned live currentness.

Conclude exactly:

`CORRECTED DEVELOPMENT APPCZAR LAUNCH CONTRACT VERIFIED: YES / NO`

`APPCZAR OPERATING SESSION STAGE ONE LIVE QUALIFICATION: PASS / FAIL / AMBIGUOUS`

`FIRST OPERATING FRAME WAS SEMANTICALLY NEUTRAL: YES / NO / NOT REACHED`

`CONTACT IDENTITIES WERE CORRECT ON FIRST USE: YES / NO / NOT REACHED`

`SECOND LAUNCH RESTORED PRIOR SEMANTIC NAVIGATION: YES / NO / NOT REACHED`

`LEGACY JOURNEY/READINESS UI APPEARED AFTER APPCZAR ADMISSION: YES / NO / NOT REACHED`

`READY TO DESIGN OPERATING-OWNED LIVE CURRENTNESS: YES / NO`

Then STOP.
