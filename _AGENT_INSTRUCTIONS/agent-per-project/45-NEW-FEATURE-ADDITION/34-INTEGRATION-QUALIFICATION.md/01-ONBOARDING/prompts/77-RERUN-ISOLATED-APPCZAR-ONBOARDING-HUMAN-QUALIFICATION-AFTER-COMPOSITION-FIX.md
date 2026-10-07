# MessageLens Feature 34
## 77 — Rerun Isolated AppCzar Onboarding Human Qualification After Composition Fix

Response 76 corrected the startup-composition defect exposed by Prompt 75.

The audit established that Prompt 75 did **not** have simultaneous AppCzar and
Journey authority. Instead, the process never entered the AppCzar composition:

```text
archive admission
-> attachmentArchiveAdoptionExecutionEnabledProvider
-> FALSE for disposable root/UUID
-> StartupApp
-> production MacosAppShell
-> legacy Journey
```

Prompt 76 replaced that misuse with a dedicated development composition policy:

```text
archive admission succeeds
-> immutable ArchiveAccessAuthority exists
-> AppCzarDevelopmentCompositionPolicy
   requires:
     development environment
     recognized development build identity
     exact development bundle identifier
     exact development product name
-> AppCzarStartupHarness
```

The WD-root/UUID-specific attachment-adoption authority remains independently
narrow and unchanged.

Prompt 76 automated validation proves the exact-development AppCzar composition
does not construct or listen to legacy Journey, OnboardingOverlay,
OnboardingCenterPanelSync, Environment Readiness, or the six-node Journey rail.

This task now reruns the full isolated human qualification with fresh disposable
fixtures.

This is a qualification task only.

Do NOT modify source/tests.
Do NOT stage, commit, push, merge, rebase, or rebuild.
Do NOT launch production MessageLens.
Do NOT use the populated WD development root as the qualification root.
Do NOT access or mutate the active Toshiba attachment archive.
Do NOT authorize Attachment Archive Repair if it appears after the disposable
initial build.
Do NOT weaken any archive, AppCzar, or mutation authority gate.

---

# 1. Exact repository and artifact preflight

Primary repository:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Require:

- branch:
  `fix/onboarding-import-stuck-state`;
- tracked worktree clean;
- index clean;
- ahead/behind `0/0`;
- shared-instructions submodule clean at:
  `95326f515ef4719f155ce6e223990398daad6311`;
- exactly one Feature 34 worktree.

Resolve the actual current HEAD/upstream from Git.

Verify these commits are ancestors of HEAD:

- Prompt 75 failed-qualification checkpoint:
  `3785108d05ba222673d5518f275fe1a6e141bf49`
- Prompt 76 implementation:
  `ef867dff28ae13fa1a4e26a07657e974e0864556`

Use exactly:

`/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app`

Expected artifact:

- product/display/executable:
  `MessageLens Development`
- bundle identifier:
  `com.bigbenchsoftware.MessageLens.development`
- environment/build identity:
  `development / developmentDebug`
- version/build:
  `0.2.141 (159)`
- executable SHA-256:
  `5abee4d23602a0e5762834aff06fe191f54103be8cf5e25ad15cf95bf04a48fd`
- `App.framework/App` SHA-256:
  `68723a0e19f37aa3fb7ad1940bd04faccd6d0193cc0289fb39ff9b8bc7a2c048`

If either hash differs, STOP AND REPORT.

Do not rebuild.

Confirm:

- no `MessageLens Development` process is running;
- production MessageLens, if running, is left untouched;
- `launchctl getenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT` is empty before setup.

---

# 2. Reconfirm Prompt 76 composition contract from source

Perform only a narrow source reconfirmation.

Require:

```text
archive admission
-> AppCzarDevelopmentCompositionPolicy
-> any admitted official MessageLens Development build
-> AppCzarStartupHarness
```

and separately:

```text
attachmentArchiveAdoptionExecutionEnabledProvider
-> remains WD-root/UUID specific
-> does NOT select the startup composition
```

Confirm production still fails the development-composition policy and selects
legacy `StartupApp`.

Also confirm the AppCzar development composition does not import/mount:

- `OnboardingJourneyCoordinator`;
- `OnboardingOverlay`;
- `OnboardingCenterPanelSyncObserver`;
- Environment Readiness semantic providers;
- production `MacosAppShell`.

Do not rerun the entire Prompt 76 audit.

---

# 3. Create fresh disposable qualification roots

Do NOT reuse Prompt 73 or Prompt 75 fixtures.

Create a unique new parent, for example:

`/private/tmp/messagelens-appczar-onboarding-qualification-<timestamp>/`

with:

```text
safe-empty/
unsafe-partial/
```

Use the reviewed fixture builder / current project APIs.

Requirements:

- current development archive marker/identity;
- current schema APIs;
- fixture-local attachment archive only;
- no copied real MessageLens database;
- no real archive path;
- no symlink into a real archive;
- distinct archive UUID per fixture.

Record raw and filesystem-canonical paths.

Hard guards:

```text
safe fixture != real WD development root
unsafe fixture != real WD development root
safe attachment archive != Toshiba active archive
unsafe attachment archive != Toshiba active archive
```

Do not list, inspect, or copy the real WD root beyond a simple
existence/path-inequality guard.

---

# 4. SAFE fixture construction

Construct a current development root whose typed initial-construction evidence
is affirmatively safe.

Expected prelaunch shape:

```text
current development marker
fixture-local attachment_archive/
no source-scoped import DB
no conversation graph DB
no consequential partial rows
no non-live/historical material
no retired derived artifacts
no corrupt store
```

Before launch record:

- raw root;
- canonical root;
- archive UUID;
- marker environment/format;
- import-store presence/count;
- graph-store presence/count;
- non-live-source count;
- retired-artifact status;
- expected `safeEmpty` classification.

No manual schema invention.

---

# 5. FDA/source-permission preflight

Record the human-visible Full Disk Access state for the exact development app.

Treat it only as configuration.

Do not assume it proves source readability.

Do not change it unless AppCzar Onboarding naturally reaches the Messages
prerequisite and human action is needed to complete the qualification.

---

# 6. Configure SAFE fixture launch contract

Set:

```bash
launchctl setenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT "<SAFE_FIXTURE_ROOT>"
```

Verify exact readback.

Record raw and canonical values.

Before launch confirm:

- no MessageLens Development process running;
- selected root is the safe fixture;
- selected root is not the WD root;
- fixture attachment archive is not Toshiba.

---

# 7. Experiment A — archive admission and AppCzar composition

Direct-launch the exact artifact:

```bash
/usr/bin/open -n "/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app"
```

Record PID.

First prove both earlier boundary defects are gone:

```text
archive admission succeeds
AND
AppCzar development composition mounts
```

Required negative evidence:

- no `nonCanonicalRoot` alert;
- no `StartupApp` legacy path;
- no Journey rail;
- no `OnboardingOverlay`;
- no Environment Readiness takeover.

If the process reaches legacy Journey UI again, STOP AND REPORT.

---

# 8. Fresh AppCzar must select Onboarding

Allow fresh AppCzar assessment to complete.

Required:

```text
safe initial-construction scope TRUE
no complete local dataset
-> AppCzar Onboarding
```

Record:

- AppCzar assessment facts visible before handoff if observable;
- exact AppCzar Onboarding presentation;
- proof the six-node Journey rail is absent;
- proof Environment Readiness is absent;
- proof no normal Conversations workspace is mounted.

If safe-empty current facts do not select AppCzar Onboarding, STOP AND REPORT.

---

# 9. Messages prerequisite

Record the actual typed branch.

## If Messages readable

Record:

`Messages prerequisite: satisfied`

and continue.

## If conclusively unreadable / accessDenied

This is especially useful because Prompt 75 naturally produced this condition.

Required presentation:

```text
AppCzarOnboardingScreen
-> literal Messages access prerequisite
-> Open System Settings only when current evidence supports it
-> Check Again
```

There must be:

- no Journey rail;
- no legacy `Re-check`;
- no Source Access Repair in-process.

First click `Check Again` once without changing system settings if that is safe
and useful, to prove the action belongs to AppCzar Onboarding.

If the source remains denied and the build cannot proceed, the human may use
ordinary macOS permission repair.

If macOS requires `Quit & Reopen`, record that as an OS process-boundary
constraint. A fresh process must return through AppCzar and, while the fixture
remains safe-empty, independently select Onboarding again.

Do not call FDA ON/OFF from the read result.

## If UNKNOWN

Expected:

```text
Onboarding stop/drain
-> restart
-> fresh AppCzar
-> Diagnostic Review
```

STOP the safe-build experiment and report literally.

---

# 10. Contacts prerequisite

After Messages is readable, record the exact typed Contacts result.

Satisfied:

```text
viableWithContacts
or
viableEmpty
```

If human-remediable:

```text
same AppCzar Onboarding jurisdiction
-> literal Contacts prerequisite
-> Check Again
```

If invalid/corrupt/UNKNOWN/conflicting:

```text
stop/drain
-> restart
-> fresh AppCzar
```

Do not modify Contacts data.

---

# 11. Onboarding self-location and build admission

Once prerequisites are satisfied, observe the AppCzar Onboarding transition.

Expected:

```text
checkingPrerequisites
-> prerequisites satisfied
-> exactly one initial build admitted
```

Record whether the build begins automatically, as Response 72 intended.

No legacy `Ready`, `Import`, or `Start` Journey step may appear.

There must be exactly one build occurrence.

---

# 12. Observe the initial build

Record:

- PID;
- visible current stage;
- import progress;
- Contacts progress if shown;
- rich-text progress if shown;
- graph projection progress if shown;
- any warning/failure.

Execution must remain:

```text
AppCzar Onboarding
-> ConversationGraphBuildController.runOnce()
-> existing graphBuild mutation tenure
-> existing service/orchestrator
-> existing importers/projectors
```

Corroborate from fixture-local logs/read-only evidence if available.

There must be:

- no cleanup/reset;
- no Start Fresh;
- no second importer;
- no Attachment Archive Repair invoked by Onboarding;
- no normal application UI during build.

---

# 13. Build-success process boundary

On successful initial build:

```text
worker completes
-> graphBuild tenure releases
-> Onboarding stopAndDrain
-> old PID disappears
-> fresh PID starts
-> fresh AppCzar reassesses
```

Record:

- old PID;
- last AppCzar Onboarding status;
- old PID disappearance;
- replacement PID;
- any observable no-process interval;
- first fresh AppCzar facts/disposition.

Forbidden:

```text
same PID
-> ReadyToStart
-> Conversations
```

---

# 14. Accept the truthful fresh post-build disposition

Do not require Operating.

Possible fresh dispositions include:

```text
Data Update
Attachment Archive Repair
Operating
Local Data Repair
Diagnostic Review
```

Record exactly what fresh AppCzar selects and the current facts supporting it.

If Attachment Archive Repair appears:

- allow read-only classification/plan to settle;
- record counts;
- DO NOT authorize preservation.

Qualification is about fresh authority, not forcing a final state.

---

# 15. Durable SAFE-fixture verification

Inspect only the disposable safe fixture after the build/restart.

Record:

- `macos_import_ss.db` schema/presence/message count;
- imported live-source count/high-water if useful;
- `working_ss.db` schema/presence/message/chat/edge counts;
- marker/UUID;
- overlay/config stores created as ordinary current consequences;
- attachment metadata/state if present;
- absence of a durable Journey cursor controlling completion/resume.

Do not inspect the real development data root.

---

# 16. Onboarding stopAndDrain live corroboration

Record evidence that:

- no stale Onboarding progress appears in the replacement PID;
- old PID is gone before the replacement owns AppCzar authority;
- no second initial build auto-starts;
- no same-process semantic completion handoff occurred.

Do not deliberately interrupt the initial build.

---

# 17. End SAFE experiment

Quit any remaining development process normally.

Verify none remains.

Unset:

```bash
launchctl unsetenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT
```

Verify empty.

Preserve the safe fixture until Response 77 is written.

---

# 18. Construct CONSEQUENTIAL PARTIAL fixture

Create a fresh isolated unsafe fixture with valid but consequential partial
derived data.

Preferred shape:

```text
current development marker
+ current source-scoped import DB
+ exactly one valid live-source message
+ graph absent
+ no non-live/historical material required
```

Use current schema APIs.

Before launch record:

- raw/canonical root;
- archive UUID;
- import schema version;
- message count;
- live-source count;
- non-live-source count;
- graph presence/count;
- expected `consequentialData` classification;
- SHA-256/fingerprint of import DB.

---

# 19. Configure CONSEQUENTIAL PARTIAL launch contract

Set:

```bash
launchctl setenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT "<UNSAFE_FIXTURE_ROOT>"
```

Verify exact readback and canonical form.

Confirm:

- no development process running;
- fixture != WD root;
- fixture archive != Toshiba;
- before-launch fingerprint/count captured.

---

# 20. Experiment B — AppCzar must refuse Onboarding

Direct-launch the same exact artifact.

Record PID.

Required sequence:

```text
archive admission succeeds
-> AppCzar composition mounts
-> consequential partial scope
-> NOT Onboarding
```

Expected current virtual destination:

```text
Local Data Repair
```

or, if evidence is insufficient/conflicting:

```text
Diagnostic Review
```

Record exact facts and disposition.

If AppCzar Onboarding executes, STOP and report FAIL.

No legacy Journey route is acceptable here either.

---

# 21. Prove no build or cleanup on partial data

Do not click any repair action.

Observe long enough to establish stable disposition.

Verify:

- no AppCzar Onboarding controller;
- no graph-build worker;
- no reset/cleanup;
- no import deletion;
- no graph deletion;
- no Start Fresh;
- no normal workspace.

Quit normally.

After quit, inspect only the unsafe fixture.

Require:

```text
before import SHA == after import SHA
message count unchanged
live-source count unchanged
non-live count unchanged
graph state unchanged
```

If consequential data was automatically deleted or rebuilt, qualification
FAILS.

---

# 22. Optional protected non-live extension

Only if an existing fixture helper makes this trivial and safe, add a third
fixture containing protected non-live/historical imported material.

Expected:

```text
protectedNonLiveData
-> NOT Onboarding
```

Otherwise report:

`NOT EXERCISED`.

---

# 23. Fair-Witness review

Across both required experiments confirm:

- archive admission is distinct from AppCzar composition selection;
- AppCzar composition is distinct from WD-specific mutation authority;
- safe-empty scope is positively proven;
- source denial is not inferred from visible FDA;
- source UNKNOWN is not called denial;
- Contacts zero is not failure;
- build completion is not called Operating;
- fresh process owns post-build jurisdiction;
- partial data is not called empty/disposable;
- no old Journey result/cursor selects current state;
- no legacy UI is misidentified as AppCzar evidence.

---

# 24. Cleanup

At end:

1. quit all MessageLens Development processes;
2. verify none remains;
3. unset `MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT`;
4. verify empty;
5. leave FDA in its intended state;
6. do not modify/stage/commit source/tests;
7. do not touch production MessageLens;
8. preserve fixture roots until Response 77 is written.

No real WD/Toshiba data may be accessed beyond simple path guards.

---

# 25. Qualification verdict

Full PASS requires both:

## A — SAFE EMPTY

```text
archive admission
-> AppCzar composition
-> AppCzar Onboarding
-> current prerequisites
-> existing build pipeline
-> real restart
-> fresh AppCzar
```

## B — CONSEQUENTIAL PARTIAL

```text
archive admission
-> AppCzar composition
-> NOT Onboarding
-> no build
-> no cleanup
-> partial data unchanged
```

Messages/Contacts human-remediation branches may be partially qualified if OS
permission behavior forces a process restart, provided the authority path is
reported literally.

---

# 26. Required response

Create Response 77 and report:

1. exact Git HEAD/upstream state;
2. Prompt 76 implementation ancestry;
3. exact artifact/hash verification;
4. development-composition contract reconfirmation;
5. proof adoption gate remains independently narrow;
6. fresh fixture-construction seam;
7. safe raw/canonical path;
8. safe archive identity;
9. proof safe fixture isolation;
10. FDA preflight;
11. safe launchd value;
12. Experiment A initial PID;
13. archive-admission result;
14. AppCzar-composition selection result;
15. fresh initial-scope facts;
16. AppCzar Onboarding selection result;
17. proof legacy Journey/overlay/Environment Readiness absent;
18. Messages prerequisite result;
19. Messages Check Again result if exercised;
20. any OS permission-restart result;
21. Contacts prerequisite result;
22. Onboarding self-location result;
23. build-admission behavior;
24. visible build stages/progress;
25. proof existing pipeline was used;
26. proof no cleanup/reset occurred;
27. old Onboarding PID terminal behavior;
28. replacement PID;
29. fresh post-build AppCzar disposition;
30. proof no same-process Operating handoff;
31. safe fixture durable import/graph result;
32. proof no durable Journey cursor;
33. stopAndDrain live corroboration;
34. unsafe fixture construction method;
35. unsafe raw/canonical path;
36. unsafe archive identity;
37. exact consequential partial facts;
38. unsafe launchd value;
39. Experiment B PID;
40. unsafe archive-admission result;
41. unsafe AppCzar-composition result;
42. unsafe initial-scope classification;
43. Local Data Repair / Diagnostic Review result;
44. proof Onboarding did not execute;
45. proof graph build did not execute;
46. proof cleanup/reset did not execute;
47. unsafe before/after fingerprint/count result;
48. optional protected-non-live result;
49. Fair-Witness verdict;
50. errors/warnings/evidence limitations;
51. cleanup result;
52. overall AppCzar Onboarding human qualification verdict;
53. recommendation for checkpointing;
54. readiness for Local Data Repair milestone;
55. readiness for Diagnostic Review milestone;
56. readiness for production AppCzar cutover.

Conclude exactly:

`DISPOSABLE DEVELOPMENT ROOT SELECTED APPCZAR COMPOSITION: YES / NO`

`SAFE EMPTY FIXTURE SELECTED APPCZAR ONBOARDING: YES / NO / NOT REACHED`

`LEGACY JOURNEY REMAINED INERT DURING APPCZAR ONBOARDING: YES / NO / NOT REACHED`

`INITIAL BUILD USED THE EXISTING PIPELINE: YES / NO / NOT REACHED`

`INITIAL BUILD ENDED AT A REAL PROCESS BOUNDARY: YES / NO / NOT REACHED`

`FRESH APPCZAR OWNED THE POST-BUILD DISPOSITION: YES / NO / NOT REACHED`

`CONSEQUENTIAL PARTIAL FIXTURE WAS REFUSED BY ONBOARDING: YES / NO / NOT REACHED`

`NO CLEANUP OR BUILD OCCURRED ON CONSEQUENTIAL PARTIAL DATA: YES / NO / NOT REACHED`

`APPCZAR ONBOARDING HUMAN LIVE QUALIFICATION: PASS / FAIL / AMBIGUOUS`

`READY TO CHECKPOINT ONBOARDING HUMAN QUALIFICATION: YES / NO`

`READY FOR LOCAL DATA REPAIR MILESTONE: YES / NO`

`READY FOR PRODUCTION APPCZAR CUTOVER: YES / NO`

Then STOP.
