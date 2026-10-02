# MessageLens Feature 34
## Response 44 — Implement the Visible AppCzar Startup Harness

## 1. Baseline verification — PASS

- Worktree: `/Users/rob/Development/FlutterProjects/remember_every_text`.
- Branch: `fix/onboarding-import-stuck-state`.
- HEAD and upstream: `9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`.
- The index was empty and the shared-instructions submodule was clean at
  `95326f515ef4719f155ce6e223990398daad6311`.
- The reviewed Prompt 32 + Prompt 35 tracked diff comprised 29 files and had
  SHA-256
  `88dd2190a8c989fcf7d1bbab5af49ff646b02a132ea423286353c6207c56f5be`.
- The 28 baseline files not intentionally shared with Prompt 44 remain
  byte-identical. The one shared file,
  `test/architecture/forbidden_imports_test.dart`, received only the required
  read-only AppCzar infrastructure allow-list entries.
- Prompt 39 remains superseded/unimplemented. Responses 38, 40, and 41 were
  read in full before implementation.
- The fresh external manifest is
  `/private/tmp/messagelens-prompt44-baseline-20261001.txt`, SHA-256
  `130aafa89de93e57f81aeb59c552dfb7948ee517535ac5626059ba5de5376a42`.

## 2. Exact development-only interception point

`lib/main.dart:308-312` reads the existing exact attachment-archive development
gate after the admitted `ArchiveAccessAuthority` has been composed. At
`lib/main.dart:321-337`, before `StartupApp` can be constructed, that result is
passed to `buildMessageLensStartupPresentation`. The exact-development branch
returns only `AppCzarStartupHarness` at `lib/main.dart:356-358`; all other
identities return the existing `StartupApp` at lines 359-362.

The persistent-startup callback remains available only to `StartupApp`.
`AppCzarStartupHarness` neither receives nor invokes it.

## 3. Source of old `Checking databases…` screen

The old first surface is `_StartupGateState._startupLoadingApp` in
`lib/main.dart:637-650`; the literal is at line 646. `StartupApp` selected that
surface while bounded installation inspection was loading. The development
AppCzar root now intercepts before `StartupApp` exists.

## 4. Source of old `Checking what MessageLens needs` screen

The literal is produced by `_checkingSurface` in
`lib/features/environment_readiness/application/view_spec/resolver_tools/environment_readiness_surface_provider.dart:74-87`.
The legacy onboarding center-panel sync controller installs that Environment
Readiness ViewSpec at
`lib/essentials/navigation/application/onboarding_center_panel_sync_controller.dart:64-82`.
Neither path is constructed by the AppCzar diagnostic root.

## 5. Cause/source of old blank or empty state

When legacy Journey status no longer requires Environment Readiness,
`OnboardingCenterPanelSyncController` clears the center panel at
`lib/essentials/navigation/application/onboarding_center_panel_sync_controller.dart:108-116`.
If no replacement page exists, `PanelCoordinator` supplies
`SizedBox.shrink()` as the empty-stack placeholder at
`lib/essentials/navigation/application/panel_coordinator_provider.dart:71-74`.
That clearing-plus-empty-placeholder sequence explains the observed blank
center pane. AppCzar bypasses the navigation stack entirely; the legacy code was
not deleted.

## 6. Exact AppCzar implementation file scope

New production files:

- `lib/essentials/app_czar/domain/app_czar_models.dart`
- `lib/essentials/app_czar/application/app_czar_observation_reader.dart`
- `lib/essentials/app_czar/application/app_czar_evaluator.dart`
- `lib/essentials/app_czar/application/app_czar_assessment_provider.dart`
- `lib/essentials/app_czar/application/app_czar_assessment_provider.g.dart`
- `lib/essentials/app_czar/infrastructure/sqlite_app_czar_observation_reader.dart`
- `lib/essentials/app_czar/presentation/app_czar_startup_harness.dart`
- `lib/features/attachments/infrastructure/repositories/read_only_app_czar_attachment_archive_probe.dart`

Intentionally modified production/release files:

- `lib/main.dart`
- `pubspec.yaml`
- `CHANGELOG.md`

New tests:

- `test/essentials/app_czar/application/app_czar_evaluator_test.dart`
- `test/essentials/app_czar/application/app_czar_assessment_provider_test.dart`
- `test/essentials/app_czar/infrastructure/sqlite_app_czar_observation_reader_test.dart`
- `test/essentials/app_czar/infrastructure/read_only_app_czar_attachment_archive_probe_test.dart`
- `test/essentials/app_czar/presentation/app_czar_startup_harness_test.dart`
- `test/app_czar_startup_composition_test.dart`
- `test/architecture/app_czar_architecture_test.dart`

`test/architecture/forbidden_imports_test.dart` was extended only to recognize
the two deliberately read-only infrastructure readers at their required
physical-file, SQLite, and platform-environment boundaries.

## 7. Minimum observation set

One fresh generation obtains six bounded observations:

1. exact development-root admission and canonical path;
2. current `chat.db` access plus two bounded count/high-water samples;
3. source-scoped import-store presence, schema, count, live count, and live
   high-water;
4. graph-store presence, schema, message count, chat count, and edge count;
5. overlay presence, schema, required settings-table readability;
6. configured attachment-location mode and current location availability.

These are the minimum observations needed to separate healthy, source-access,
incomplete-local, local-repair, archive-repair, update, and diagnostic states.

## 8. Minimum fact set

The pure evaluator derives eleven facts:

1. development data root admitted;
2. Full Disk Access established by current source-open evidence;
3. Messages source readable;
4. source sample stable;
5. import store healthy;
6. graph store healthy;
7. overlay safe to use;
8. local message dataset complete;
9. attachment archive available;
10. source-versus-local delta known;
11. new source messages present.

No F-number identifiers or historical state appear in the presentation.

## 9. TRUE/FALSE/UNKNOWN implementation

`AppCzarTruth` has exactly `TRUE`, `FALSE`, and `UNKNOWN`. Missing prerequisites
propagate `UNKNOWN`; they are never filled from prior Journey, Environment,
snapshot, failure, UI, monitor, or tenure state. In particular, denied source
access makes Full Disk Access `FALSE` while Messages readability, stability,
and source-delta facts remain `UNKNOWN` rather than being misreported as source
failures. All source records, including anomalous rows, contribute to the
bounded message count.

## 10. Diagnosis selection rule

The evaluator is pure and uses one fixed precedence:

1. inadmissible development root -> Diagnostic Review;
2. unhealthy local store -> Local Data Repair;
3. uninspectable local store -> Diagnostic Review;
4. unavailable archive -> Attachment Archive Repair;
5. unknown archive -> Diagnostic Review;
6. source access unavailable -> Source Access Repair;
7. unstable source sample -> Diagnostic Review;
8. incomplete local dataset -> Onboarding;
9. unknown delta/prerequisite -> Diagnostic Review;
10. contradictory source/local high-water -> Diagnostic Review;
11. source ahead -> Data Update;
12. otherwise -> Operating Session.

Exactly one `_AppCzarSelection` becomes the assessment result.

## 11. Virtual coordinator mapping

The possible display-only values are `Operating Session`, `Onboarding`,
`Source Access Repair`, `Attachment Archive Repair`, `Local Data Repair`,
`Data Update`, and `Diagnostic Review`. They are enum data with a human display
name, not executable objects. Every completed assessment contains exactly one
value.

## 12. Proof no coordinator can run

- The AppCzar package imports no onboarding, Environment Readiness, navigation,
  operation snapshot, monitor, coordinator-provider, or Ball implementation.
- It contains no coordinator constructor or callback seam.
- `AppCzarVirtualCoordinator` is an enum only.
- The diagnostic root does not construct `StartupApp`, so its persistent
  initialization callback cannot run.
- The architecture tests enforce those exclusions and the UI explicitly says
  `Diagnostic only. No coordinator has been started.`

## 13. AppCzar UI structure

The development root is a dedicated themed `MacosApp` containing one calm,
scrollable assessment screen. It shows a MessageLens heading, current-evidence
fact card, diagnosis/coordinator decision card, and a small `Run assessment
again` action. It constructs no sidebar, router, center-panel stack, normal
Conversations/Contacts UI, Environment Readiness surface, or Onboarding UI.

## 14. Pending and UNKNOWN UI behavior

Each observation is started concurrently and updates its own row only when its
current-generation evidence arrives. Genuinely unresolved rows show a spinner,
`CHECKING`, and `Checking current evidence…`. Resolved uncertainty shows `?`,
`UNKNOWN`, and a reason. Failed checks remain visible. No percentage or invented
progress is displayed.

`Run assessment again` is disabled until the assessment completes. A rerun
increments the generation, replaces state with an all-null initial state, and
ignores late results from older generations.

## 15. Bottom diagnosis display

While observations are open, Diagnosis displays `Still assessing…`. Once all
six observations exist, it displays one present-tense Fair-Witness statement
selected by the evaluator. The screen remains in place after completion.

## 16. Bottom virtual-coordinator display

While observations are open, the coordinator field displays `Not selected
yet`. Completion displays exactly one `Coordinator that would be called`, plus
the non-execution disclaimer. No transition follows it.

## 17. Real-development read-only safety proof

- SQLite stores are opened only with `OpenMode.readOnly`, immediately placed in
  `PRAGMA query_only = ON`, queried with guarded read-only SQL, and disposed.
- Missing files are reported as absent; no database is created to inspect them.
- The source is first opened with `FileMode.read`, then sampled twice through a
  read-only SQLite connection.
- Schema and required-table checks do not migrate, checkpoint, vacuum, repair,
  or create anything.
- The attachment probe reads only the location configuration. It does not
  enumerate or open attachment payloads. A refreshed bookmark returned by the
  native resolver is deliberately ignored and never persisted.
- Tests prove missing stores remain missing, overlay bytes/directory entries
  remain identical, and anomalous source records are not filtered.
- Architecture tests reject SQLite mutation verbs from the AppCzar readers.

Implementation and automated validation used temporary test databases only.
No command in this task opened either real archive, a real MessageLens database,
or the production Messages source. No real archive/database/configuration or
abandoned relocation artifact was modified.

## 18. Development-only gate proof

The interception reuses
`attachmentArchiveAdoptionExecutionEnabledProvider`. That existing gate admits
only the exact development environment/build identities, bundle identifier,
product name, canonical WD root, and qualified archive-instance UUID. It does
not use a loose debug flag. The exact-gate suite passed 15/15, and the startup
composition test proves the admitted development identity selects AppCzar.

The canonical WD root continues to enter the development process through the
existing `MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT` launch environment. It was not
embedded as a new bypass.

## 19. Production non-change proof

Every identity for which the exact gate is false returns the pre-existing
`StartupApp` root. The production composition test proves this. The AppCzar
reader override is lazy, so production does not even evaluate AppCzar's macOS
source-path lookup or construct its probe. No production startup implementation
was edited, launched, or inspected for application data.

## 20. Deterministic fact tests

Focused fixtures prove:

- identical observations yield identical facts/diagnosis/coordinator;
- FDA dependency propagates UNKNOWN correctly;
- healthy current -> one Operating Session;
- incomplete local -> one Onboarding;
- inaccessible source -> one Source Access Repair;
- unavailable archive wins the documented tie -> one Attachment Archive
  Repair;
- insufficient or contradictory evidence -> one Diagnostic Review;
- source ahead -> one Data Update;
- unhealthy existing store -> one Local Data Repair;
- an uncreated default archive does not invent a repair;
- a new generation inherits no prior facts;
- virtual coordinator data exposes no constructor seam.

The post-correction focused AppCzar/composition/architecture run passed 23/23.
A final production-laziness-focused subset passed 20/20.

## 21. Observation-order test

Two controlled readers release identical observations in opposite orders. Both
produce the same diagnosis and coordinator. The controller evaluates only after
all six current-generation observations have arrived. PASS.

## 22. Architecture isolation result

The three AppCzar-specific architecture tests passed. The repository forbidden-
imports suite passed all 388 cases. The package has no semantic/execution
authority imports, mutation SQL, or coordinator-construction seam. PASS.

## 23. Focused UI result

Two widget tests passed. They prove the current facts, one diagnosis, and one
virtual coordinator render; the non-execution disclaimer is visible; genuine
pending rows show CHECKING; fake percentage text is absent; and both legacy
startup literals are absent.

## 24. Complete architecture result

The exact final source state passed the complete architecture suite:

`559 passed / 0 failed`.

## 25. Analyzer result

Final `flutter analyze` result:

`No issues found!`

## 26. Full-suite decision and result

Because `main.dart` startup composition changed, the complete Flutter suite was
run. It passed:

`2,784 passed / 0 failed / 1 intentionally skipped qualification harness`.

That broad run preceded two final bounded corrections: removal of a source-count
filter and making AppCzar reader construction lazy outside development. The
affected reader/composition tests, analyzer, and exact final 559-test
architecture suite were rerun afterward and passed. Repeating the entire
four-minute suite would not add distinct coverage beyond those targeted final
checks.

## 27. Diff, format, and generated hygiene

- `dart format --output=none --set-exit-if-changed` checked 16 AppCzar/startup
  implementation and test files with zero changes.
- `git diff --check`: PASS.
- `build_runner build --delete-conflicting-outputs`: PASS; the AppCzar Riverpod
  output is current.
- No unrelated generated drift remains. Pre-existing Prompt 32/35 generated
  files retain their baseline content.
- Current tracked diff SHA-256:
  `953b2c31773d49ce8589497c1ce725b72c0034e9e8f070e7ca6c76b1d75e1ed0`.
- AppCzar production/test directory manifest SHA-256:
  `45d3820d9965aa349681b5de819a2c313b026af66739c1f85a09a17dff0a7338`.

## 28. Project Conformance verdict

`PROJECT CONFORMANCE: PASS`

All Prompt 44 requirements pass: exact-development-only presentation takeover,
unchanged production selection, current factual evidence only, tri-state
semantics, one diagnosis, one virtual coordinator, no invocation/mutation/Ball,
order independence, zero-state rerun, and no new semantic authority outside
AppCzar.

## 29. BLOCKER findings

`BLOCKER: 0`

## 30. SHOULD FIX findings

`SHOULD FIX: 0`

## 31. Exact build identity, path, and hashes

Final build: PASS, not launched by this task.

- Bundle:
  `/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app`
- Executable:
  `/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app/Contents/MacOS/MessageLens Development`
- Product/bundle name: `MessageLens Development`.
- Bundle identifier: `com.bigbenchsoftware.MessageLens.development`.
- Version/build: `0.2.129+147`.
- Archive environment/build identity: `development` / `developmentDebug`.
- Signing: ad hoc Debug; no TeamIdentifier.
- Executable timestamp: `2026-10-01 11:51:36 -0700`.
- Executable SHA-256:
  `58f204347b09102fc48fae7e7b22bd2fd8fb6fddb1022530b8e30b0bb5f6314e`.
- App framework binary timestamp: `2026-10-01 11:56:05 -0700`.
- App framework binary SHA-256:
  `7da6a1244f5ef6129f34b070409c89b29d9961117dbca0bc8b73b82f51d07a52`.
- Final debug Dart kernel timestamp: `2026-10-01 11:56:02 -0700`.
- Final debug Dart kernel SHA-256:
  `bf9d55ce41aa4fb811399a8df5180bcf5a75a72443dedcf99e83ed577896bcad`.
- Info.plist SHA-256:
  `138baf6395904cc1c61c9626b64415962b1f1cc8d92c30aa272478e963655689`.
- Aggregate regular-file bundle SHA-256:
  `d89a26af27d8221f16f5998754b9595a945c0b816ded2e6c73c5859e99450ffa`.

A development `flutter run` process (PID 57712) and app process (PID 57968)
were already running from this exact worktree since 10:57, before the final
11:56 build. They were not launched, signalled, or controlled by this task.
That in-memory process is not proof of the new bundle; it must be quit normally
and relaunched for the human experiment.

## 32. Exact Git/worktree/index/submodule state

- Branch: `fix/onboarding-import-stuck-state`.
- HEAD/upstream:
  `9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`.
- Index: empty.
- Tracked worktree: 32 modified entries — the preserved 29-file Prompt 32/35
  baseline plus Prompt 44 changes to `main.dart`, `pubspec.yaml`, and
  `CHANGELOG.md`; the existing architecture census file contains its additional
  AppCzar allow-list lines.
- Untracked files after this response: 86 — the original 70-file inventory,
  15 new AppCzar production/test files, and this Response 44.
- Shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`.
- Nothing is staged, committed, pushed, merged, or rebased.
- All unrelated untracked prompts, responses, `.vscode` files, and preparation
  artifacts remain untouched.

## 33. Readiness for human AppCzar experimentation

The code and verified bundle are ready. Because the old development process is
still in memory, the human should first stop that VS Code run normally, then
launch the repository's `MessageLens Development (Debug)` configuration. That
configuration supplies the existing exact WD development-root environment; a
plain Finder launch without that required root admission is expected to fail
the exact gate rather than bypass it.

Expected relaunch behavior is now:

`launch -> AppCzar only -> rows populate -> one diagnosis -> one virtual coordinator -> remain on screen`.

No automated GUI launch was performed. No production launch or production-data
access occurred.

VISIBLE APPCZAR DEVELOPMENT HARNESS IMPLEMENTED: YES

LEGACY DEVELOPMENT STARTUP SURFACES BYPASSED: YES

APPCZAR DIAGNOSIS IS READ-ONLY: YES

APPCZAR VIRTUAL COORDINATOR DOES NOT EXECUTE: YES

READY FOR HUMAN APPCZAR ENVIRONMENT EXPERIMENTS: YES
