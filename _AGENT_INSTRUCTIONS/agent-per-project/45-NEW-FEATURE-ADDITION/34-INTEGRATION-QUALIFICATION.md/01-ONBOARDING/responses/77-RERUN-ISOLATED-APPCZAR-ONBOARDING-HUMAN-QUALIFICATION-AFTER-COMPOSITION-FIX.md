# MessageLens Feature 34
## Response 77 — Rerun Isolated AppCzar Onboarding Human Qualification After Composition Fix

Date: 2026-10-07

### 1. Exact Git HEAD/upstream state

The qualification ran in the primary repository:

`/Users/rob/Development/FlutterProjects/remember_every_text`

Baseline and final checks established:

- branch: `fix/onboarding-import-stuck-state`;
- HEAD: `15c1e9787af09223287e842a293a98a53d632ff2`;
- upstream: `15c1e9787af09223287e842a293a98a53d632ff2`;
- ahead/behind: `0/0`;
- tracked worktree and index clean before qualification;
- shared-instructions submodule clean at
  `95326f515ef4719f155ce6e223990398daad6311`; and
- exactly one Feature 34 worktree.

Prompt 77 was the only new Feature 34 prompt at baseline. Known unrelated
untracked files were left untouched.

### 2. Prompt 76 implementation ancestry

Both required checkpoints are ancestors of HEAD:

- Prompt 75 failed-qualification checkpoint:
  `3785108d05ba222673d5518f275fe1a6e141bf49`;
- Prompt 76 startup-composition implementation:
  `ef867dff28ae13fa1a4e26a07657e974e0864556`.

### 3. Exact artifact/hash verification

The qualification used exactly:

`/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app`

Verified identity:

- product/display/executable: `MessageLens Development`;
- bundle identifier: `com.bigbenchsoftware.MessageLens.development`;
- environment/build identity: `development / developmentDebug`;
- version/build: `0.2.141 (159)`;
- executable SHA-256:
  `5abee4d23602a0e5762834aff06fe191f54103be8cf5e25ad15cf95bf04a48fd`;
- `App.framework/App` SHA-256:
  `68723a0e19f37aa3fb7ad1940bd04faccd6d0193cc0289fb39ff9b8bc7a2c048`.

No rebuild occurred.

### 4. Development-composition contract reconfirmation

The narrow source reconfirmation established:

```text
native/Dart archive admission succeeds
-> immutable ArchiveAccessAuthority
-> AppCzarDevelopmentCompositionPolicy
-> admitted official MessageLens Development identity
-> AppCzarStartupHarness
```

The policy requires the admitted development environment, recognized
development build identity, exact development bundle identifier, and exact
development product name. It is evaluated only after archive admission.

Production authority continues to fail this development-only policy and
selects legacy `StartupApp`.

### 5. Proof the adoption gate remains independently narrow

`attachmentArchiveAdoptionExecutionEnabledProvider` remains separately
restricted to the qualified WD development root and qualified archive UUID. It
does not select the startup composition and was not modified or weakened.

The disposable roots therefore received AppCzar composition without receiving
WD-specific attachment-adoption mutation authority.

### 6. Fresh fixture-construction seam

The reviewed external fixture builder at
`/private/tmp/messagelens_prompt73_fixture_builder.dart` was run through the
current Flutter test/runtime APIs. It created fresh current-schema fixtures
under:

`/private/tmp/messagelens-appczar-onboarding-qualification-NBxSJw`

No project source or test file was changed. No real MessageLens database or
archive payload was copied.

### 7. SAFE raw/canonical path

Raw and filesystem-canonical safe root were identical:

`/private/tmp/messagelens-appczar-onboarding-qualification-NBxSJw/safe-empty`

### 8. SAFE archive identity

The current development marker recorded:

- format version: `1`;
- environment: `development`;
- archive UUID: `02dc1994-b790-43d4-ac7d-84bd6ceb6931`.

Before launch the root contained only the marker and its fixture-local empty
`attachment_archive/`.

### 9. Proof SAFE fixture isolation

The safe fixture had:

- no import database;
- no conversation graph;
- no consequential partial rows;
- no non-live/historical material;
- no retired derived artifact;
- no corrupt store; and
- no symlink.

Path guards proved the root differed from the WD development root and its
attachment archive differed from the Toshiba active archive. WD received only
an existence/path-inequality guard. Toshiba received only a path-inequality
guard. Neither real root was listed, inspected, copied, or mutated.

### 10. FDA preflight

The human-visible Full Disk Access toggle for the exact development app was ON
at preflight. It was treated only as configuration, not as proof of source
readability.

The first source observation nevertheless returned `accessDenied`, correctly
demonstrating that the visible toggle was not used as semantic evidence. The
human later toggled the entry ON again when macOS showed it OFF during the
ordinary permission-repair path. FDA was left ON at cleanup.

### 11. SAFE launchd value

The exact configured and read-back value was:

`/private/tmp/messagelens-appczar-onboarding-qualification-NBxSJw/safe-empty`

Raw and canonical values agreed. No development process was running before
launch. The override was empty before setup.

### 12. Experiment A initial PID

Direct launch of the exact artifact produced PID `33887`.

Production MessageLens PID `801`, already running at preflight, was left
untouched.

### 13. SAFE archive-admission result

**PASS.** Archive admission succeeded. No `nonCanonicalRoot` or other archive
admission alert appeared.

### 14. SAFE AppCzar-composition selection result

**PASS.** The process mounted AppCzar composition for the disposable admitted
development root. It did not fall through to `StartupApp`.

### 15. Fresh initial-scope facts

The safe fixture was positively classified as `safeEmpty`: no import store, no
graph store, no non-live data, and no retired derived artifacts existed.

### 16. AppCzar Onboarding selection result

**PASS.** Safe-empty facts with no complete local dataset selected
`AppCzarOnboardingScreen`.

### 17. Proof legacy Journey/overlay/Environment Readiness were absent

The first visible screen was the AppCzar-owned literal Messages prerequisite:

- heading: `Messages access needs attention`;
- evidence: `macOS denied access to the Messages database`;
- actions: `Open System Settings` and `Check Again`.

There was no six-node Journey rail, no legacy `Re-check`, no
`OnboardingOverlay`, no Environment Readiness panel, and no normal
Conversations workspace.

### 18. Messages prerequisite result

The first typed result was conclusively `accessDenied`. After ordinary human
permission repair and a macOS process boundary, a fresh source read succeeded.
The successful read was reported only as current source readability, not as a
claim that FDA itself had been proven.

### 19. Messages `Check Again` result

`Check Again` was exercised once before changing system settings. It reran the
same AppCzar-owned fresh observation and remained on the identical
`accessDenied` prerequisite. No Source Access Repair coordinator or legacy
Journey action ran in-process.

### 20. OS permission-restart result

After the human re-enabled the exact development app, macOS displayed:

`"MessageLens Development.app" will not have full disk access until it is quit.`

The human chose `Quit & Reopen`. PID `33887` disappeared. The fresh process
again entered AppCzar against the still-safe fixture and proceeded only after
fresh source evidence was readable.

### 21. Contacts prerequisite result

The Contacts prerequisite was satisfied and the build proceeded automatically.
The exact enum label was not visible long enough to capture directly. Durable
fixture evidence corroborates the viable-with-contacts branch: the current
pipeline imported `113` contacts and `157` contact channels from the live
Address Book source. No Contacts data was manually changed.

### 22. Onboarding self-location result

**PASS.** The prerequisite flow remained inside AppCzar Onboarding and
self-transitioned from prerequisite checking into initial construction. No
legacy `Ready`, `Import`, or `Start` step appeared.

### 23. Build-admission behavior

Exactly one initial build began automatically once current prerequisites were
satisfied. No separate start command or legacy Journey authorization was
required.

### 24. Visible build stages/progress

Human-visible evidence included:

- `Building your MessageLens library`;
- `Importing messages — 106000 of 139071`;
- `Updating message data — 12000 of 139071`; and
- the subsequent fresh AppCzar assessment.

Fixture-local logs additionally recorded all `139071` source messages imported
and `125688` rich-text work items processed. Durable results record the Contacts
and graph-projection outputs.

### 25. Proof the existing pipeline was used

The UI explicitly described the existing graph-build pipeline. Fixture-local
logs were emitted by the existing `MessageImporter` and
`MessageRichTextEnricher`. The resulting databases are the current centralized
stores with schema versions `10` and `3`. This corroborates:

```text
AppCzar Onboarding
-> ConversationGraphBuildController.runOnce()
-> existing graphBuild mutation tenure
-> existing importer/enricher/projector pipeline
```

No second importer was introduced or observed.

### 26. Proof no cleanup/reset occurred

The fixture began without import or graph stores and gained the current stores
through the admitted build. No cleanup/reset screen, Start Fresh action,
archive deletion, or second build appeared. The fixture-local attachment
archive remained the selected archive; AppCzar Onboarding did not invoke
Attachment Archive Repair.

### 27. Old Onboarding PID terminal behavior

The pre-permission AppCzar Onboarding PID `33887` terminated at the macOS
`Quit & Reopen` boundary. The transient fresh PID that performed the initial
build was not sampled before it completed; this is an evidence limitation, not
an inferred PID.

Human screenshots show the build active at `10:28:43` and `10:29:04`. The
post-build process started later, at `10:29:34`, proving the build did not hand
off to a final disposition in that same process.

### 28. Replacement PID

Fresh post-build AppCzar ran as PID `53761`, with process start time
`Wed Oct 7 10:29:34 2026`.

### 29. Fresh post-build AppCzar disposition

Fresh AppCzar selected **Attachment Archive Repair** and allowed its read-only
classification to settle:

- required payloads: `18326`;
- covered: `0`;
- need attention: `18326`;
- available from Messages: `521`;
- source currently absent: `17805`;
- source evidence unavailable: `0`;
- record-backed recovery needed: `0`;
- unsafe/conflicting evidence: `0`;
- next exact batch: `75` attachments / `25457924` bytes.

The `Preserve these 75 attachments` action was not authorized or clicked.

### 30. Proof no same-process Operating handoff occurred

The build UI existed before `10:29:34`; PID `53761` began at `10:29:34` and
owned the fresh Attachment Archive Repair disposition. No same-PID
`ReadyToStart`, Conversations workspace, or Operating handoff occurred.

### 31. SAFE fixture durable import/graph result

Read-only verification after the restart found:

- `macos_import_ss.db`: present, schema `10`, `139071` messages, `246` chats,
  `118305` chat-message edges, `41035` attachment records;
- live source: `139071` messages, source-row high-water `155247`;
- source registry: current live `chat.db` and live Address Book sources;
- Contacts: `113` contacts, `157` channels, `259` handles;
- `working_ss.db`: present, schema `3`, `139071` messages, `246` chats,
  `118305` chat-message edges, `41035` attachment records;
- `user_overlays.db`: present, schema `8`, ordinary empty overlay state;
- archived-attachment rows: `0`;
- marker UUID remained
  `02dc1994-b790-43d4-ac7d-84bd6ceb6931`.

### 32. Proof no durable Journey cursor exists

The schema-8 `overlay_settings` table contained no rows. No Journey completion,
resume, phase, or cursor value existed in the disposable fixture. Current state
was selected from fresh AppCzar evidence.

### 33. `stopAndDrain` live corroboration

The post-build process displayed no stale Onboarding progress and did not start
a second initial build. A fresh AppCzar assessment appeared before Attachment
Archive Repair. The build UI preceded the `10:29:34` start time of PID `53761`,
corroborating a real stop/drain/restart boundary rather than a same-process
semantic handoff.

### 34. Unsafe fixture construction method

The same reviewed current-schema fixture builder created a separate development
archive containing a current schema-10 source-scoped import database with one
valid live-source message and no graph. It did not copy or derive from a real
MessageLens database.

### 35. Unsafe raw/canonical path

Raw and filesystem-canonical unsafe root were identical:

`/private/tmp/messagelens-appczar-onboarding-qualification-NBxSJw/unsafe-partial`

### 36. Unsafe archive identity

The current development marker recorded:

- format version: `1`;
- environment: `development`;
- archive UUID: `b71b203e-1ab4-4d09-8c62-a837ac4b54b2`.

### 37. Exact consequential-partial facts

Before launch:

- import schema: `10`;
- import messages: `1`;
- live-source messages: `1`;
- live source-row high-water: `1`;
- non-live messages: `0`;
- graph: absent;
- import SHA-256:
  `e4d02dbebc61d6543e097a194ba734a9809493054ad5221991a998b32439804e`;
- expected typed classification: `consequentialData`.

### 38. Unsafe launchd value

The exact configured, read-back, and canonical value was:

`/private/tmp/messagelens-appczar-onboarding-qualification-NBxSJw/unsafe-partial`

### 39. Experiment B PID

Direct launch of the same verified artifact produced PID `55990`, starting at
`Wed Oct 7 10:35:53 2026`.

### 40. Unsafe archive-admission result

**PASS.** The disposable unsafe root was admitted. The assessment displayed
that exact `/private/tmp/.../unsafe-partial` data root and no admission alert.

### 41. Unsafe AppCzar-composition result

**PASS.** The official admitted development identity selected AppCzar
composition. The AppCzar assessment surface appeared; no legacy Journey route
mounted.

### 42. Unsafe initial-scope classification

**PASS.** The visible typed fact was:

`Initial construction scope — Consequential data present`

Assessment details reported import messages `1`, graph messages/chats/edges
`0`, non-live sources `0`, and retired derived artifacts `false`.

### 43. Local Data Repair / Diagnostic Review result

Fresh AppCzar selected the diagnostic virtual destination:

- diagnosis: `Consequential partial local data requires separate repair review.`
- coordinator that would be called: `Local Data Repair`;
- execution state: `Diagnostic only. No coordinator has been started.`

### 44. Proof Onboarding did not execute

No `AppCzarOnboardingScreen`, prerequisite screen, onboarding build UI, Journey
rail, or ordinary workspace appeared. The initial-scope fact immediately
refused Onboarding and selected Local Data Repair review.

### 45. Proof graph build did not execute

The assessment remained stable until normal quit. No graph-build worker or
build progress appeared. After quit, `working_ss.db` was still absent.

### 46. Proof cleanup/reset did not execute

No coordinator was started and no repair action was clicked. There was no
cleanup, reset, import deletion, graph deletion, Start Fresh action, or normal
workspace.

### 47. Unsafe before/after fingerprint/count result

Before and after Experiment B:

- import SHA-256 was identically
  `e4d02dbebc61d6543e097a194ba734a9809493054ad5221991a998b32439804e`;
- message count remained `1`;
- live-source count remained `1`;
- high-water remained `1`;
- non-live count remained `0`;
- graph remained absent.

The consequential partial data was neither deleted nor rebuilt.

### 48. Optional protected-non-live result

`NOT EXERCISED`.

The two required experiments provided the necessary qualification without
broadening fixture scope.

### 49. Fair-Witness verdict

**PASS.** The live evidence preserved all required distinctions:

- archive admission was separate from AppCzar composition;
- AppCzar composition was separate from WD-specific mutation authority;
- safe-empty scope was positively proven rather than inferred from absence of
  UI;
- visible FDA state was not used as source-readability proof;
- source denial came from a current read result;
- Contacts evidence was not converted into a failure;
- build completion was not called Operating;
- a fresh process owned the post-build disposition;
- partial data was classified as consequential, not empty/disposable;
- no Journey cursor selected current state; and
- AppCzar and legacy presentation evidence were not conflated.

### 50. Errors, warnings, and evidence limitations

- The transient post-FDA process that executed the build completed before its
  PID was sampled. Screenshot timing plus replacement PID start time still
  proves the required real post-build process boundary.
- The exact Contacts prerequisite enum was not visible long enough to capture;
  automatic admission plus `113` imported contacts and `157` channels
  corroborate the satisfied viable-with-contacts path.
- Existing rich-text extraction logged bounded warnings for blobs containing no
  recoverable message text. The pipeline retained and projected all `139071`
  records and completed successfully.
- Normal AppleScript quit returned macOS error `User canceled (-128)` after
  each development process had in fact exited. Independent process checks
  confirmed no development process remained.
- No source/test modification, rebuild, staging, commit, push, merge, or rebase
  occurred.

### 51. Cleanup result

Cleanup completed:

- PID `53761` quit after Experiment A;
- PID `55990` quit after Experiment B;
- no MessageLens Development process remains;
- `MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT` is empty;
- FDA was left ON;
- both disposable fixture roots were preserved for this response;
- production MessageLens was not launched, quit, or modified by this task;
- the real WD development root and Toshiba archive were not accessed beyond
  the permitted simple guards; and
- no real archive or database was mutated.

### 52. Overall AppCzar Onboarding human qualification verdict

**PASS.** Both required experiments satisfied their authority and preservation
contracts.

### 53. Recommendation for checkpointing

**YES.** Prompt 77 and this response are ready for a documentation-only
checkpoint. They remain unstaged under the qualification stop rule.

### 54. Readiness for Local Data Repair milestone

**YES.** AppCzar now truthfully detects consequential partial data, refuses
Onboarding, and selects Local Data Repair review without executing it or
changing the partial store.

### 55. Readiness for Diagnostic Review milestone

**NO.** Diagnostic Review remains a separate unqualified milestone. This run
exercised the conclusive Local Data Repair branch rather than an unknown or
conflicting evidence branch.

### 56. Readiness for production AppCzar cutover

**NO.** The development-only Onboarding authority is qualified, but Local Data
Repair execution, Diagnostic Review, and the remaining production-cutover
surface still require their own milestones.

`DISPOSABLE DEVELOPMENT ROOT SELECTED APPCZAR COMPOSITION: YES`

`SAFE EMPTY FIXTURE SELECTED APPCZAR ONBOARDING: YES`

`LEGACY JOURNEY REMAINED INERT DURING APPCZAR ONBOARDING: YES`

`INITIAL BUILD USED THE EXISTING PIPELINE: YES`

`INITIAL BUILD ENDED AT A REAL PROCESS BOUNDARY: YES`

`FRESH APPCZAR OWNED THE POST-BUILD DISPOSITION: YES`

`CONSEQUENTIAL PARTIAL FIXTURE WAS REFUSED BY ONBOARDING: YES`

`NO CLEANUP OR BUILD OCCURRED ON CONSEQUENTIAL PARTIAL DATA: YES`

`APPCZAR ONBOARDING HUMAN LIVE QUALIFICATION: PASS`

`READY TO CHECKPOINT ONBOARDING HUMAN QUALIFICATION: YES`

`READY FOR LOCAL DATA REPAIR MILESTONE: YES`

`READY FOR PRODUCTION APPCZAR CUTOVER: NO`
