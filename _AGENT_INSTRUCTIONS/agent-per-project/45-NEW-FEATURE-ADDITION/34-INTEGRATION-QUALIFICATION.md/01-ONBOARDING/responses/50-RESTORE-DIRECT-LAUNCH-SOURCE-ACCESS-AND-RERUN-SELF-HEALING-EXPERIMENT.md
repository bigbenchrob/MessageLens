# MessageLens Feature 34
## Response 50 — Restore Direct-Launch Source Access and Rerun Self-Healing Data Update

Date: 2026-10-02

Direct-launch source access was restored for the exact qualified development
bundle. AppCzar then naturally selected Data Update for 59 newer Messages
records. The bounded worker imported and projected those records, preserved 13
attachments with zero failures, released the old process, and crossed a real
LaunchServices restart boundary. The new process independently assessed a
healthy current installation and kept Operating Session virtual.

## 1. Exact bundle and hash verification

Bundle:

`/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app`

- product: `MessageLens Development`
- version/build: `0.2.131+149`
- bundle identifier: `com.bigbenchsoftware.MessageLens.development`
- build identity: `developmentDebug`
- executable SHA-256:
  `faf6d1f58550bb6eecfc9d72bd7a9130c84265baeb3c4762d092b84ee659f7c2`
- App.framework SHA-256:
  `418be669ccbd5022d123d03c347338fb07a6569bff5caa88041f665f3a78d98a`
- Info.plist SHA-256:
  `44b734147fdd29e945eecc093af11cf4a21ee83f567c452dbbd4cf6a9695e116`
- top-level signing: ad hoc Debug
- top-level CDHash: `d3a54d33e7f8a6c0d5068533ea068085c926bdd4`
- TeamIdentifier: absent, as expected for this ad hoc Debug artifact

The required executable and App.framework hashes matched Response 48 exactly.
No MessageLens Development process existed before launch. Production
MessageLens remained running separately as PID `801` and was not signalled or
accessed for application data.

## 2. macOS permission state and restoration

The human inspected:

**System Settings → Privacy & Security → Full Disk Access**

Initial visible state for the exact current `MessageLens Development.app`:

`OFF`

Action taken:

`The existing exact entry was turned ON.`

No production MessageLens permission was changed. The setting was not treated
as proof by itself; the subsequent fresh AppCzar observation supplied the
qualification evidence.

## 3. Fresh direct launch

The development-root launch environment was set to:

`/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development`

LaunchServices started the exact qualified executable as:

- initial PID: `5455`
- PPID: `1`
- start time: `2026-10-02 10:00:14 -0700`

No stale process was reused, and neither VS Code nor `flutter run` was used.

## 4. Fresh source-readability result and provenance

The fresh launch passed the source-readability gate. The evidence later
reconfirmed independently by the restarted AppCzar process was:

- Messages database: **Readable — 138,882 messages**
- current source high-water: `155058`
- source sample: **Stable**
- provenance: `The current Messages source was opened read-only.`
- bounded-sample provenance: `Two bounded current samples agreed.`

There was no claim about the macOS Full Disk Access toggle. AppCzar testified
only to its direct source-readability evidence.

## 5. Initial source/local disposition

The initial AppCzar/Data Update transition completed too quickly for a
pre-update screenshot. Its material evidence is bounded by the pre-update
local state, the worker's exact logs/source range, and the fresh post-restart
assessment:

- source count: `138882`
- source high-water: `155058`
- initial import count: `138823`
- initial graph count: `138823`
- initial local high-water: `154999`
- naturally applicable new-message count: `59`

Initial diagnosis:

`The Messages source currently contains newer local data.`

Initial selected coordinator:

`Data Update`

Data Update was therefore naturally applicable. No Messages were manufactured
and no assessment was manually rerun.

## 6. Data Update progress and result

Data Update started automatically exactly once. The old process existed for
approximately 17 seconds before the restart boundary.

The development application log records:

- message-import stage: `59 / 59` completed in one bounded page;
- rich-text stage: `48 / 48` completed in one bounded page;
- source-row range: `154999-155058`;
- post-update import count: `138882`;
- post-update graph count: `138882`.

The literal log evidence was:

```text
Source message import page completed
pageRowCount=59 cumulativeCompletedCount=59 totalWorkCount=59

Rich-text decoder page completed
pageRowCount=48 cumulativeCompletedCount=48 totalWorkCount=48
```

No literal worker warning or failure appeared. The dedicated Data Update
screen elapsed before an exact-window screenshot could be taken; only factual
log and process-boundary evidence is reported for its live progress.

## 7. Attachment result

The existing attachment-preservation path reported:

```text
Attachment archive graph source range 154999-155058:
13 new, 0 skipped, 0 failed out of 13 attachment(s)
```

The restarted AppCzar independently reported the configured
`Toshiba_manual_bu` attachment archive as available.

## 8. Mutation-authority result

The PID watcher observed only one initial Data Update process. On completion:

1. PID `5455` disappeared;
2. there was an observed no-development-process boundary; and
3. LaunchServices created PID `5921` against the same admitted development
   root.

The new process could acquire the same archive-scoped application authority
only after the old process released it. No overlapping development process,
duplicate coordinator occurrence, authority error, or attachment failure was
observed.

## 9. Real restart proof

- old PID: `5455`
- old-process start: `2026-10-02 10:00:14 -0700`
- old-process disappearance: `2026-10-02 10:00:31 -0700`
- new PID: `5921`
- new-process start: `2026-10-02 10:00:31 -0700`
- new PPID: `1`

The monitor explicitly observed `NO_DEVELOPMENT_PROCESS` between those PID
records. This was a real process boundary, not Riverpod invalidation or
in-process navigation.

## 10. Fresh post-restart AppCzar assessment

The new PID began on the AppCzar assessment surface. It did not show Data
Update progress, a remembered operation result, legacy startup UI, or normal
application UI.

Fresh evidence:

- admitted development root:
  `/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development`
- source count: `138882`
- source high-water: `155058`
- source opened read-only: yes
- two bounded source samples agreed: yes
- import count: `138882`
- import schema: `10`
- graph count: `138882`
- graph schema: `3`
- graph chat count: `246`
- graph chat-message edge count: `118117`
- overlay: healthy at schema `8`
- attachment archive: available, `Toshiba_manual_bu`
- local live-import count: `138882`
- local high-water: `155058`
- new-message count: `0`
- source/local count comparison: equal
- source/local high-water comparison: equal

Fresh diagnosis:

`This appears to be a healthy current MessageLens installation.`

Fresh virtual coordinator:

`Operating Session`

The screen explicitly stated:

`Diagnostic only. No coordinator has been started.`

Screenshots were preserved at:

- `/private/tmp/messagelens-prompt50-post-restart-expanded.png`
- `/private/tmp/messagelens-prompt50-post-restart-details.png`
- `/private/tmp/messagelens-prompt50-post-restart-details-lower.png`

## 11. No in-process Operating declaration

Operating was not declared by PID `5455`. The old process terminated after the
bounded update. Only PID `5921` displayed the healthy/current diagnosis after
performing a fresh assessment. `Operating Session` remained virtual, and the
normal Conversations UI was never entered.

No stale Data Update progress or pre-restart AppCzar fact was displayed by the
new process.

## 12. Fair-Witness verdict

**PASS.**

- Source access was proven by a read-only source open, not inferred from the
  visible FDA setting.
- Stable source evidence came from two bounded agreeing samples.
- Data Update ran only because current source evidence was ahead.
- The worker did not claim Operating in-process.
- The old process terminated and a new PID reassessed independently.
- Counts and high-waters reconciled to the same current values.
- Operating Session remained diagnostic-only.
- No historical success, resume state, or old progress appeared.

## 13. Errors and warnings

No AppCzar, Data Update, mutation-authority, import, graph, attachment, restart,
or reassessment error appeared.

Two operational diagnostics did not affect the result:

1. Deep strict `codesign` verification reported the existing
   `attributed_string_decoder.framework` resource/signature inconsistency.
   The required qualified artifact hashes and top-level ad hoc signature/CDHash
   were unchanged, and the exact FDA entry restored direct source access.
2. The AppleScript normal-quit request returned `User canceled (-128)` while
   PID `5921` was terminating. The PID watcher then observed the process exit,
   and no development process remained.

## 14. Cleanup

After recording the final AppCzar evidence:

1. PID `5921` exited at `2026-10-02 10:06:49 -0700`;
2. no MessageLens Development process remained;
3. production MessageLens PID `801` remained present and untouched;
4. `launchctl unsetenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT` completed; and
5. `launchctl getenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT` returned empty.

The newly enabled development FDA entry was retained as Prompt 50 directed.

## 15. Recommendation

Treat the live Data Update coordinator as qualified and do not repeat this
mutation experiment merely for additional evidence. Preserve the development
FDA entry. Before another coordinator is made executable, checkpoint/review
this result and approve that coordinator's architecture independently. The
already observed access-denied disposition makes Source Access Repair a
reasonable next bounded design candidate, but it must remain virtual until a
separate approved implementation and qualification plan exists.

No source or test file was modified, and nothing was staged, committed, or
pushed by this experiment.

`DIRECT-LAUNCH SOURCE ACCESS RESTORED: YES`

`DATA UPDATE NATURALLY SELECTED: YES`

`LIVE DATA UPDATE SELF-HEALING LOOP QUALIFIED: YES`

`FRESH APPCZAR REASSESSMENT AFTER RESTART: PASS`
