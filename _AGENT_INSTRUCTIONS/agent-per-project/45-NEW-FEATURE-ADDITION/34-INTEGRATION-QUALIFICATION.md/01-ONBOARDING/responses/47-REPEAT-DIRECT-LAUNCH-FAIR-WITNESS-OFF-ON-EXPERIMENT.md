# MessageLens Feature 34
## Response 47 — Repeat Direct-Launch Fair-Witness OFF/ON Experiment

Date: 2026-10-01

This was a human experiment only. No source or test changes were made, no
coordinator was run, and no MessageLens mutation action was invoked.

## 1. Bundle identity

The exact Response 46 development bundle was used for both launches:

`/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app`

- version/build: `0.2.130+148`
- bundle identifier: `com.bigbenchsoftware.MessageLens.development`
- build identity: `developmentDebug`
- executable SHA-256:
  `6cf31b1df781adb8f35c3915417e81ccdda3d9c92c5e1cc7937846f61d8a3c21`
- App.framework SHA-256:
  `5a38064b6c9d5ec0b8be8d1457d700588974c16745a836ad1e63d45d5329e6ee`

The process that was present during preflight, PID `53393`, was quit normally
before the experiment. Experiment A launched a new process, PID `63159`, at
15:35:02. Experiment B launched another new process, PID `64548`, at 15:39:53.
Both had PPID `1` and the exact executable path above. No stale process was
reused.

The development-root environment was set to:

`/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development`

Both runs displayed that exact root as admitted.

## 2. Experiment A — visible FDA toggle OFF

### Observed facts

- Development data folder: admitted at the required WD development root.
- Messages database: **Cannot currently be read**.
- Readability explanation: `macOS denied access to the Messages database.`
- Current source count/high-water: not shown and not fabricated.
- Messages source sample: **Stability unknown**.
- Sample explanation: a stable sample requires a readable Messages source.
- MessageLens import data: healthy, schema 10, `138823` messages.
- MessageLens conversation data: healthy, schema 3, `138823` messages.
- MessageLens overlay: healthy, schema 8.
- Local message dataset: complete, `138823` messages.
- Local graph chat count: `245`.
- Local graph chat-message edge count: `118060`.
- Attachment archive: available, `Toshiba_manual_bu`.
- New messages: **Unknown**.
- Local live-import count: `138823`.
- Local high-water: `154999`.
- Source-versus-local delta: not available.

### Assessment-details provenance

The expanded details reported:

- `Source-readability result: unavailable.`
- `macOS denied access to the Messages database.`
- `No completed bounded sample comparison is present.`

This was a conclusive access denial, not an inconclusive/UNKNOWN probe result.
The dependent sample and source-versus-local facts were correctly UNKNOWN.

### Diagnosis and virtual coordinator

- Diagnosis: `The current Messages source cannot be inspected with the available access.`
- Coordinator that would be called: `Source Access Repair`
- Execution status: `Diagnostic only. No coordinator has been started.`

No Full Disk Access row or assertion appeared.

## 3. Experiment B — visible FDA toggle ON

### Observed facts

- Development data folder: admitted at the required WD development root.
- Messages database: **Readable — 138,831 messages**.
- Current source high-water: `155007`.
- Messages source sample: **Stable**.
- Sample explanation: two bounded current samples agreed.
- MessageLens import data: healthy, schema 10, `138823` messages.
- MessageLens conversation data: healthy, schema 3, `138823` messages.
- MessageLens overlay: healthy, schema 8.
- Local message dataset: complete, `138823` messages.
- Local graph chat count: `245`.
- Local graph chat-message edge count: `118060`.
- Attachment archive: available, `Toshiba_manual_bu`.
- New messages: **8**.
- Source message count: `138831`.
- Local live-import count: `138823`.
- Source high-water: `155007`.
- Local high-water: `154999`.

### Assessment-details provenance

The expanded details reported:

- `The current Messages source was opened read-only.`
- `Message count: 138831.`
- `High-water: 155007.`
- `Two bounded current samples agreed.`

### Diagnosis and virtual coordinator

- Diagnosis: `The Messages source currently contains newer local data.`
- Coordinator that would be called: `Data Update`
- Execution status: `Diagnostic only. No coordinator has been started.`

`New messages` was displayed as the informational value `8`, in blue. It was
not presented as a red FALSE/error condition. No Full Disk Access row or
assertion appeared.

The zero-delta healthy-current example in Prompt 47 did not apply to the actual
ON evidence: the source contained eight messages beyond the local import and
its high-water was eight beyond the local high-water. The displayed `Data
Update` disposition was therefore explained entirely by current evidence.

## 4. Execution and mutation boundary

Both displays explicitly stated that they were diagnostic only and that no
coordinator had been started. The human did not invoke either displayed
coordinator or any other app action. The harness opened the current Messages
source read-only in the ON run. No MessageLens data mutation was performed by
this experiment.

## 5. Launch-environment cleanup

After the ON app was quit normally:

- no `MessageLens Development` process remained;
- `launchctl unsetenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT` completed; and
- `launchctl getenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT` returned empty.

## 6. Fair-Witness verdict

The presentation stayed within the evidence in both runs:

- OFF made a conclusive source-access-denial statement and left dependent
  source facts unknown;
- ON reported read-only source evidence, a stable sample, and the exact
  source/local delta;
- neither run claimed to know the visible macOS Full Disk Access setting;
- FALSE was not generically rendered as an error; and
- no coordinator was executed.

The inconclusive/UNKNOWN source-readability path was not observed. Consequently
this experiment neither validates nor disproves the current UNKNOWN → `Source
Access Repair` mapping. The Prompt 47 architecture concern remains open for a
later review; any correction should be decided from that review rather than
inferred from these conclusive OFF/ON observations.

DIRECT-LAUNCH FAIR-WITNESS OFF/ON EXPERIMENT: PASS

UNSUPPORTED FDA TESTIMONY OBSERVED: NO

OFF AND ON RESULTS WERE EXPLAINED ENTIRELY BY CURRENT EVIDENCE: YES

UNKNOWN SOURCE-READABILITY PATH OBSERVED: NO
