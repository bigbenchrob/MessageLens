# MessageLens Feature 34
## 47 — Repeat Direct-Launch Fair-Witness OFF/ON Experiment

Response 46 corrected the AppCzar testimony so that it no longer claims to know
the macOS Full Disk Access setting merely from source readability, and it no
longer treats every FALSE fact as a visual error.

This task is a **human experiment only**.

Do NOT modify source or tests.
Do NOT stage, commit, or push.
Do NOT launch production MessageLens.
Do NOT run any coordinator.
Do NOT mutate MessageLens data.

Use the exact Response 46 development build.

## 1. Build under test

Verified bundle:

`/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app`

Verified identity:

- version/build: `0.2.130+148`
- bundle ID: `com.bigbenchsoftware.MessageLens.development`
- build identity: `developmentDebug`
- executable SHA-256:
  `6cf31b1df781adb8f35c3915417e81ccdda3d9c92c5e1cc7937846f61d8a3c21`
- App.framework SHA-256:
  `5a38064b6c9d5ec0b8be8d1457d700588974c16745a836ad1e63d45d5329e6ee`

Before testing, quit any currently running `MessageLens Development` instance
normally so LaunchServices cannot reactivate an old in-memory process.

## 2. Set the development-root environment

Run:

```bash
launchctl setenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT "/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development"
```

Do not use VS Code or `flutter run` for either launch.

## 3. Experiment A — visible FDA toggle OFF

In System Settings, ensure the visible `MessageLens Development` Full Disk Access
toggle is OFF.

Double-click the verified bundle in Finder.

Record exactly what AppCzar shows for:

- Messages database;
- source readability;
- source count/high-water if shown;
- source sample stability;
- import data;
- conversation data;
- source-versus-local comparison;
- new messages;
- Diagnosis;
- Coordinator that would be called.

Also open `Assessment details` and record the source-readability provenance.

Expected Fair-Witness behavior:

- no `Full Disk Access` row or claim;
- if source access is conclusively denied, `Messages database` says it cannot
  currently be read;
- no source count/high-water is fabricated;
- dependent source-comparison facts are UNKNOWN;
- Diagnosis describes inability to inspect the current Messages source;
- virtual coordinator is `Source Access Repair`;
- no coordinator actually starts.

If the source probe instead returns UNKNOWN/inconclusive rather than a conclusive
access denial, record that separately. Do not reinterpret UNKNOWN as proof that
source access is broken.

Quit the app normally.

## 4. Experiment B — visible FDA toggle ON

Turn the visible `MessageLens Development` Full Disk Access toggle ON.

Double-click the exact same bundle in Finder again.

Record the same rows and `Assessment details`.

Expected Fair-Witness behavior if current evidence agrees:

- no FDA claim;
- Messages database readable;
- current source count/high-water shown;
- source sample stable;
- source/local comparison known;
- `New messages` shown as a value, not a red FALSE condition;
- healthy-current diagnosis;
- virtual coordinator `Operating Session`;
- no coordinator actually starts.

Quit normally.

## 5. Clean up the temporary launch environment

Run:

```bash
launchctl unsetenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT
```

Verify:

```bash
launchctl getenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT
```

returns empty.

## 6. Important Fair-Witness review point

Response 46 currently states that both conclusively unreadable **and
inconclusive/UNKNOWN** source evidence select the display-only
`Source Access Repair` coordinator.

Do not change code during this experiment, but record whether the human run ever
hits the inconclusive path.

For later architecture review:

> UNKNOWN source readability must not be silently treated as a proven source
> access defect.

If the observation is genuinely inconclusive, the eventual AppCzar disposition
may need to be diagnostic/indeterminate rather than source-access repair.

This is a review note, not an instruction to patch during Prompt 47.

## 7. Required response

Create Response 47 containing:

1. exact bundle identity confirmed;
2. confirmation no stale process was reused;
3. OFF experiment observations;
4. OFF Assessment-details provenance;
5. OFF diagnosis;
6. OFF virtual coordinator;
7. whether OFF result was conclusive FALSE or UNKNOWN;
8. ON experiment observations;
9. ON Assessment-details provenance;
10. ON diagnosis;
11. ON virtual coordinator;
12. `New messages` presentation result;
13. confirmation no FDA assertion appeared in either run;
14. confirmation no coordinator executed;
15. confirmation no MessageLens data was mutated;
16. launchctl cleanup result;
17. Fair-Witness verdict;
18. whether UNKNOWN→Source Access Repair requires a later correction.

Conclude exactly:

`DIRECT-LAUNCH FAIR-WITNESS OFF/ON EXPERIMENT: PASS / FAIL / AMBIGUOUS`

`UNSUPPORTED FDA TESTIMONY OBSERVED: YES / NO`

`OFF AND ON RESULTS WERE EXPLAINED ENTIRELY BY CURRENT EVIDENCE: YES / NO / PARTIAL`

`UNKNOWN SOURCE-READABILITY PATH OBSERVED: YES / NO`

Then STOP.
