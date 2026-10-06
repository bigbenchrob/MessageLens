# MessageLens Feature 34
## Response 73 — Isolated AppCzar Onboarding Human Qualification

Date: 2026-10-06

### 1. Exact Git HEAD/upstream state

The qualification began and ended on `fix/onboarding-import-stuck-state` at `ed84400ef3440b5485e77313cad01fa5bc1bb618`, synchronized `0/0` with its upstream. The tracked worktree and index were clean before the experiment and remain clean. The shared-instructions submodule remains clean at `95326f515ef4719f155ce6e223990398daad6311`.

### 2. Response 72 implementation ancestry

`5435e803b55ba0362a5c8f1e08cfac2bbc43ea72` is an ancestor of the current HEAD. Its ancestry check returned success.

### 3. Exact artifact/hash verification

No rebuild occurred. The exact existing artifact was:

- `/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app`
- product/display/executable: `MessageLens Development`
- bundle identifier: `com.bigbenchsoftware.MessageLens.development`
- version/build: `0.2.139 (157)`
- executable SHA-256: `dc457ebd321a5962ea3e42dc733cc9aae7a08ba644dc7104eff0592ab5fcd26e`
- `App.framework/App` SHA-256: `ae6b311a95fccd76c1b8734e16def9c50dac3857f43ecd5b0a53a726c5972f8c`

### 4. Fixture-construction seam audit

The source audit rejected the test-only `TestArchiveFixture` because it marks `ArchiveEnvironment.test`. A small external qualification harness in `/private/tmp` instead used current project APIs: `ArchiveAdmissionService`, `FileSystemArchiveMarkerStore`, a development `NativeArchiveClaim`, `ExactCanonicalArchiveRootPolicy`, and the current `ImportDatabase` schema seam. It ran under `flutter test` because the current database seam depends on Flutter `dart:ui`; no project source or test file was changed. The harness created current-format development markers with distinct UUIDs and used the normal source-scoped import schema for the unsafe witness.

This construction proved valid fixture-local marker/schema formation. It did not and could not override the independently assembled canonical-root policy inside the already-built application.

### 5. Safe fixture absolute path/identity/configuration

- resolved root: `/private/tmp/messagelens-appczar-onboarding-qualification-NbWi58/safe-empty`
- environment: `development`
- archive instance UUID: `d5aac030-bb14-4f58-8d5d-e898896e5034`
- marker: current format version 1
- attachment mode by absent overlay configuration: default internal
- fixture attachment path: `/private/tmp/messagelens-appczar-onboarding-qualification-NbWi58/safe-empty/attachment_archive`
- prelaunch contents: marker plus an empty `attachment_archive/`; no import, graph, overlay, retired, historical, or non-live store/material

### 6. Proof the safe fixture is isolated from real roots/archives

The safe and unsafe paths resolve beneath the unique `/private/tmp/messagelens-appczar-onboarding-qualification-NbWi58` parent. Neither equals nor is nested within `/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development`. Neither fixture archive equals `/Volumes/Toshiba_manual_bu/ML_ADOPTION_TEST/attachment_archive`. A recursive symlink check returned no symlinks. The WD root received only the required existence guard; neither the WD root nor Toshiba archive was listed, read, or mutated.

### 7. Human-visible source-permission preflight

Before launch, the human confirmed that Full Disk Access for the exact `MessageLens Development.app` entry was visibly **ON**. It was not changed during the experiment.

### 8. Safe-fixture launchd value

The authoritative macOS user launch context read back exactly:

`/private/tmp/messagelens-appczar-onboarding-qualification-NbWi58/safe-empty`

### 9. Experiment A initial PID

The exact artifact launched as PID `40031`.

### 10. Fresh AppCzar safe-scope facts

**NOT REACHED.** Startup failed during archive admission before AppCzar could gather or publish the fixture's current fact DAG.

### 11. Onboarding selection result

**NO.** Instead of selecting Onboarding, startup displayed:

`MessageLens could not open its archive`

with:

`ArchiveAdmissionException(ArchiveAdmissionFailure.nonCanonicalRoot): Archive root is not canonical for development.`

Prompt 73 required an immediate stop when the safe-empty fixture did not select Onboarding. No attempt was made to relax the canonical-root gate, substitute the real WD root, or continue with a different fixture.

### 12. Messages prerequisite result

**NOT REACHED.** Although FDA was visibly ON, Onboarding never obtained jurisdiction and no Messages prerequisite UI or worker observation was reached.

### 13. Contacts prerequisite result

**NOT REACHED.** No Contacts prerequisite was evaluated or presented.

### 14. Onboarding self-location result

**NOT REACHED.** Onboarding was never instantiated.

### 15. Initial-build admission result

**NOT REACHED.** No build was admitted.

### 16. Visible build progress/stages

**NOT REACHED.** No import, Contacts, rich-text, graph, or other build stage appeared.

### 17. Proof the existing worker pipeline was used

**NOT REACHED.** The archive admission failure preceded worker admission.

### 18. Proof no cleanup/reset occurred

No cleanup/reset action was offered or invoked. The app stopped at archive admission. The safe fixture retained its marker and empty attachment directory, with no derived databases created. Bootstrap created one expected zero-byte fixture-local `MessageLens.instance.lock` file at launch; no preservation or data-store content was written.

### 19. Old Onboarding PID and terminal behavior

There was no Onboarding PID. PID `40031` was the failed startup process. The human used the alert's `Quit` button after an Apple-event quit was refused by the modal, and the process then disappeared.

### 20. New PID after build

**NOT REACHED.** There was no build and no replacement PID.

### 21. Fresh post-build AppCzar disposition

**NOT REACHED.** No post-build process existed.

### 22. Proof no same-process Operating handoff occurred

No Operating or Conversations UI appeared. The stronger required post-build boundary proof is **NOT REACHED** because the build never began.

### 23. Safe fixture durable import/graph result

After the stopped launch, the safe fixture still contained no source-scoped import database and no conversation graph database. No build facts were written. Its only new filesystem artifact was the zero-byte fixture-local `MessageLens.instance.lock` created before admission failed.

### 24. Proof no durable Journey cursor was used

No Journey cursor was present before launch and no database was created in which one could be stored. Onboarding was not reached. This corroborates absence for this failed launch but does not qualify a completed Onboarding occurrence.

### 25. Onboarding stopAndDrain corroboration

**NOT REACHED.** The process was terminated through the archive-error alert, not through Onboarding build-success `stopAndDrain`.

### 26. Unsafe fixture construction method

The same typed development admission/marker seam created the unsafe fixture, then current `ImportDatabase.open` schema construction and `writeTransaction.insertIgnore` inserted one live-source message. No manual schema SQL, graph store, overlay store, historical source, or archive payload was used.

### 27. Unsafe fixture absolute path/identity/configuration

- resolved root: `/private/tmp/messagelens-appczar-onboarding-qualification-NbWi58/unsafe-partial`
- environment: `development`
- archive instance UUID: `511b3e42-490b-4874-9376-f5aff97c89f4`
- marker: current format version 1
- attachment mode by absent overlay configuration: default internal
- fixture attachment path: `/private/tmp/messagelens-appczar-onboarding-qualification-NbWi58/unsafe-partial/attachment_archive`

### 28. Exact consequential partial facts before launch

The current source-scoped import database `macos_import_ss.db` existed at schema/user version 10 with exactly one message, exactly one live-source (`source_id = 1`) message, and zero non-live messages. Its GUID was `prompt-73-consequential-partial-message`; the graph was absent. Its pre-experiment SHA-256 was `63b15c41528811193eced88df93b5271754d2c1fd0e722466cdcd1cc7e3698d3`.

### 29. Unsafe-fixture launchd value

**NOT REACHED.** The stop gate prohibited configuring Experiment B.

### 30. Experiment B PID

**NOT REACHED.** The unsafe fixture was not launched.

### 31. Unsafe initial-scope classification

**NOT REACHED live.** Source design and automated coverage predict `consequentialData`, but this response does not substitute that prediction for the required human live observation.

### 32. Local Data Repair / Diagnostic Review disposition

**NOT REACHED.** Neither disposition was presented for the unsafe fixture.

### 33. Proof Onboarding did not execute

For Experiment B this is **NOT REACHED**, because the fixture was not launched. No claim is made from absence of execution alone.

### 34. Proof no graph build executed

For Experiment B this is **NOT REACHED live**. The unsafe fixture was never launched, and its graph remains absent.

### 35. Proof no cleanup/reset executed

For Experiment B this is **NOT REACHED live**. The fixture was not exposed to the app; no cleanup/reset command was run.

### 36. Before/after fixture data preservation result

The unsafe fixture was never launched. Its post-stop SHA-256 remains `63b15c41528811193eced88df93b5271754d2c1fd0e722466cdcd1cc7e3698d3`, schema remains 10, and counts remain one live message and zero non-live messages. This proves preservation during the stopped qualification, not refusal by a live Local Data Repair/Diagnostic disposition.

### 37. Optional protected-non-live subtest result

**NOT EXERCISED.** Prompt 73 did not require it and Experiment A stopped before Experiment B.

### 38. Fair-Witness verdict

The qualification itself remained Fair-Witness: the archive-admission failure was reported literally; it was not relabeled as an AppCzar or FDA result; absent downstream observations are recorded as **NOT REACHED**; and predicted unsafe classification is not claimed as human live evidence. The AppCzar Onboarding Fair-Witness behavior remains unqualified live.

### 39. Errors/warnings/evidence limitations

The blocking contradiction is between the Prompt 73 isolated-root launch contract and the exact artifact's runtime archive admission. Native bootstrap consumed the override sufficiently to produce a development archive claim, but Dart admission rejected that claim as noncanonical before AppCzar ran. Source shows that native bootstrap and Dart admission are intended to consume `MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT` independently and agree on one exact root. The error UI did not expose both compared canonical strings, so this stopped run cannot prove which side produced the divergent value. The fixture builder's local exact-root policy proves marker construction only; it does not make the built app's independently assembled policy accept the root.

Two harmless harness invocation failures preceded fixture creation: standalone Dart first lacked the project package map, then correctly resolved packages but could not supply Flutter `dart:ui`. The reviewed external harness was then run successfully under Flutter's test runtime. Neither failed attempt created a fixture or changed the repository.

### 40. Cleanup result

PID `40031` is gone. No MessageLens Development process remains. `MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT` was unset and authoritative readback is empty. FDA remains in its pre-test intended ON state. No source/test file was changed, staged, or committed. Both disposable fixtures are preserved under their unique `/private/tmp` parent pending human review; the safe fixture retains its zero-byte instance-lock artifact as literal launch evidence. Neither real archive was accessed beyond the WD existence guard.

### 41. Overall Onboarding Stage One human qualification verdict

**FAIL.** The required safe-empty fixture did not select AppCzar Onboarding. This is a qualification failure at the archive-admission boundary, not evidence that Onboarding itself selected the wrong disposition.

### 42. Recommendation for checkpointing qualification

Do not checkpoint Onboarding human qualification as complete. Preserve this failed qualification record and diagnose/correct the development override versus canonical-root admission contract in a separate reviewed step before rerunning Prompt 73.

### 43. Readiness for Local Data Repair milestone

**NO.** The prerequisite live proof that safe empty enters Onboarding and consequential partial data is refused was not completed.

### 44. Readiness for Diagnostic Review milestone

**NO.** The isolated launch contract must be made internally coherent and Prompt 73 rerun first.

### 45. Readiness for production AppCzar cutover

**NO.** Production was not launched or modified. The development-only Onboarding human qualification failed before AppCzar execution, and the later AppCzar milestones remain unqualified.

SAFE EMPTY FIXTURE SELECTED APPCZAR ONBOARDING: NO

INITIAL BUILD USED THE EXISTING PIPELINE: NOT REACHED

INITIAL BUILD ENDED AT A REAL PROCESS BOUNDARY: NOT REACHED

FRESH APPCZAR OWNED THE POST-BUILD DISPOSITION: NOT REACHED

CONSEQUENTIAL PARTIAL FIXTURE WAS REFUSED BY ONBOARDING: NOT REACHED

NO CLEANUP OR BUILD OCCURRED ON CONSEQUENTIAL PARTIAL DATA: NOT REACHED

APPCZAR ONBOARDING HUMAN LIVE QUALIFICATION: FAIL

READY TO CHECKPOINT ONBOARDING HUMAN QUALIFICATION: NO

READY FOR LOCAL DATA REPAIR MILESTONE: NO

READY FOR PRODUCTION APPCZAR CUTOVER: NO
