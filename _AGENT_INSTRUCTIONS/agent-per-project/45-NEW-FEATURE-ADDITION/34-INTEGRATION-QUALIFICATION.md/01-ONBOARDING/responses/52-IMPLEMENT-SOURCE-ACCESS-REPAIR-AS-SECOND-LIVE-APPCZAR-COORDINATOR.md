# MessageLens Feature 34
## Response 52 — Source Access Repair Implemented as the Second Live AppCzar Coordinator

## 1. Baseline verification

Implementation began from the required recovery anchor:

- worktree: `/Users/rob/Development/FlutterProjects/remember_every_text`;
- branch: `fix/onboarding-import-stuck-state`;
- HEAD/upstream: `f013388a3a28809a82dd04d97f1ab6a9fb39ef13`;
- ahead/behind: `0/0`;
- tracked worktree and index: clean;
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- initial untracked paths: 46;
- initial porcelain SHA-256:
  `89fb73b74546382aeb943524bacde8a04ee4752c0c6493a67bde38c60b247b6c`.

The fresh external manifest is:

`/private/tmp/messagelens-prompt-52-baseline-manifest.txt`

After filtering only Prompt 52's new source/test files, the final pre-response
untracked set still has 46 paths and the same SHA-256. Existing unrelated
untracked material was not changed.

## 2. Exact FALSE-versus-UNKNOWN correction

`AppCzarEvaluator` now performs exact source-readability selection:

```text
TRUE     -> continue downstream evaluation
FALSE    -> Source Access Repair
UNKNOWN  -> Diagnostic Review / insufficient evidence
```

The former `truth != TRUE` predicate is gone. The UNKNOWN diagnosis states
only that current evidence does not establish readability and makes no access
or FDA claim.

## 3. Focused evaluator results

Evaluator and assessment-provider qualification passed, including:

- access-denied and unavailable observations become FALSE;
- FALSE selects Source Access Repair;
- UNKNOWN selects Diagnostic Review and not Source Access Repair;
- TRUE does not select Source Access Repair;
- no evaluator diagnosis claims Full Disk Access state;
- reversed asynchronous observation completion order produces the same
  assessment and disposition.

The combined evaluator, observation-order, and initial controller run passed
20 tests.

## 4. Source Access Repair selection contract

`shouldExecuteAppCzarSourceAccessRepair` requires all three current facts:

1. the completed assessment selects exactly `sourceAccessRepair`;
2. `messagesSourceReadable` is exactly FALSE; and
3. the current source observation is exactly `accessDenied` or `unavailable`.

UNKNOWN, missing evidence, prior history, visible System Settings state, and a
previous result cannot start the coordinator. One assessment generation starts
the controller at most once.

## 5. Coordinator jurisdiction

The new memory-only package owns only the bounded source-access interaction:

- explain the literal current source-read failure;
- navigate to System Settings on explicit request;
- perform one fresh read-only source observation on explicit `Check Again`;
- remain when the fresh observation is conclusively unreadable;
- leave jurisdiction through restart when the result is readable or UNKNOWN.

It does not classify the installation, mutate application data, inspect
downstream deltas, publish readiness, or retain historical permission intent.

## 6. Fair-Witness presentation

The screen reports:

- `Messages access needs attention`;
- `MessageLens Development cannot currently read the Messages database`;
- the literal bounded source-observation reason;
- that MessageLens cannot determine from this evidence whether Full Disk
  Access is enabled or disabled;
- the settings location as common human guidance, not testimony.

It contains no `Full Disk Access is on`, `Full Disk Access is off`, or
`Permission repaired` assertion.

## 7. Settings navigation reuse

The controller directly reuses the existing
`realFdaSettingsOpeningAuthorityProvider`. Its authority exposes only
`openSettings()`, which delegates to the established macOS settings helper.

No new wrapper, permission reader, or platform command was introduced.
Successful navigation does not change source state, does not mark success, and
does not initiate a source probe.

The existing adapter delegation/failure test and the new coordinator and
widget navigation tests pass.

## 8. Proof that no TCC mutation exists

The Source Access Repair package contains no `dart:io`, `Process.run`,
`Process.start`, `sqlite3`, `TCC.db`, `tccutil`, private permission API, or
permission-changing command. Architecture enforcement rejects those terms and
allows only the existing settings-opening provider dependency.

## 9. Check Again single-flight design

`Check Again` synchronously claims `_checkInFlight` and publishes `checking`
before its first await. While checking, duplicate invocations return without
performing another read.

Each admitted click calls the existing
`appCzarObservationReaderProvider.readSource()` exactly once. It does not reuse
the original assessment and does not introduce a coordinator-specific
permission test.

The controlled-completer test proves two concurrent button invocations produce
one fresh retest.

## 10. Readable retest

A readable result means only:

`The current read-only Messages source check succeeded.`

The coordinator then calls the existing qualified
`appCzarProcessRestarterProvider` exactly once. It does not inspect source/local
delta, invoke Data Update, declare Operating, or carry a result payload.

## 11. Still-unreadable retest

An `accessDenied` or `unavailable` retest returns to the waiting state with the
new observation's literal reason. The human may explicitly press `Check Again`
again. No restart or automatic polling occurs.

## 12. UNKNOWN retest

An UNKNOWN retest publishes the literal inconclusive reason and removes
`Check Again`, because Source Access Repair no longer has proven jurisdiction.
The only continuing action is `Restart and reassess`.

It does not reinterpret UNKNOWN as denial and does not invoke Diagnostic
Review in-process.

## 13. No polling

There is no timer, periodic task, settings watcher, lifecycle-triggered probe,
or ambient retry in the package. Architecture enforcement rejects
`Timer.periodic`. One human click causes one source observation.

## 14. No Ball

The package contains no archive mutation coordinator, operation, capability,
tenure, or Ball reference. It never calls `runWithCapability` and cannot reach
the Data Update executor. Architecture enforcement mechanically guards these
absences.

## 15. Exact restart path

Both readable success and the explicit UNKNOWN exit use the already-qualified
`AppCzarProcessRestarter`:

```text
controller
-> appCzarProcessRestarterProvider
-> MacosDevelopmentProcessRestarter
-> detached post-exit helper
-> old PID terminates
-> /usr/bin/open -n launches the same bundle
-> fresh AppCzar assessment begins from zero
```

The restart interface accepts no disposition or repair-result payload.

## 16. No coordinator chaining

Source Access Repair imports neither the Data Update controller/executor nor an
Operating implementation. It imports only the shared process-restarter
boundary. Its production code contains no generic coordinator switch or
execute-by-enum mechanism.

Readable and UNKNOWN outcomes end only at the process boundary.

## 17. Exactly two executable coordinators

The development host has two explicit branches:

1. `AppCzarDataUpdateController` / `AppCzarDataUpdateScreen`;
2. `AppCzarSourceAccessController` / `AppCzarSourceAccessScreen`.

Unit and architecture tests prove exactly two `shouldExecuteAppCzar...`
predicates exist. Onboarding, Local Data Repair, Attachment Archive Repair,
Diagnostic Review, and Operating Session remain virtual.

## 18. Data Update regression

All Data Update controller, executor, presentation, mutation-tenure, and
process-restarter tests pass. Data Update remains isolated, releases its
mutation tenure before restart, and cannot invoke Source Access Repair.

## 19. Source Access Repair focused tests

The new focused tests pass for:

- exact mapping and two-coordinator census;
- one start per assessment generation;
- settings navigation without semantic success;
- fresh-read single flight;
- readable one-restart outcome;
- current literal still-unreadable outcome;
- UNKNOWN jurisdiction exit;
- host replacement of the assessment screen;
- Fair-Witness copy and controls.

## 20. Settings-navigation tests

PASS. The established FDA settings adapter test proves delegation and failure
propagation. New controller/widget tests prove opening the pane performs no
probe, restart, or success transition.

## 21. Restart tests

PASS. Existing process-restarter tests still prove:

- exact bundle derivation;
- detached post-exit launch before termination;
- failure outside the exact development gate;
- failure outside macOS.

New tests prove readable evidence and explicit inconclusive exit each request
at most one restart.

## 22. AppCzar mapping and host tests

PASS. The original healthy/pending assessment-host tests, Data Update host
tests, and the new Source Access Repair host test all pass.

## 23. Architecture results

- focused AppCzar architecture test: 13 passed;
- complete architecture suite: 569 passed;
- forbidden-import inventory: passed without expanding the unawaited-future
  allowlist.

The new enforcement covers exact execution predicates, package isolation,
memory-only state, no Ball, no persistence, no polling, no TCC access, narrow
settings/restart seams, no generic dispatch, and Fair-Witness copy.

## 24. Analyzer

`flutter analyze`: PASS, no issues.

## 25. Full Flutter suite

Final deterministic serial run:

- 2,830 passed;
- 1 intentionally skipped archive-memory harness;
- 0 failed.

The first parallel run had one unrelated attachment-service failure while
Drift reported concurrent `OverlayDatabase` instances sharing an executor.
That exact test passed independently, and the complete serial suite passed.
No unrelated test or production code was changed.

## 26. Diff, format, and generated hygiene

- `git diff --check`: PASS;
- untracked source/test whitespace checks: PASS;
- formatter check: 10 intended files, 0 changes;
- build-runner status: PASS;
- tracked diff SHA-256 before/after the final generator run was identical:
  `f2add33e7c4a52ed49b235f56f5ad252a933cb77de46b3d61120810ad255576e`.

## 27. Project Conformance

`PROJECT CONFORMANCE: PASS`

The implementation preserves exact FALSE/UNKNOWN distinction, Fair-Witness
copy, read-only source observation, memory-only coordinator state, no Ball, no
TCC mutation, no coordinator chaining, real process restart, Data Update
isolation, archive preservation, and unchanged production startup composition.

## 28. BLOCKER findings

`BLOCKER: 0`

## 29. SHOULD FIX findings

`SHOULD FIX: 0`

The parallel full-suite Drift collision is pre-existing test isolation
behavior, was independently reproduced as non-feature-related, and did not
survive the deterministic complete serial qualification.

## 30. Exact build identity, path, and hashes

Build command:

```text
/Users/rob/Development/flutter/bin/flutter build macos --debug --no-pub
```

Result: PASS. The app was not launched.

- bundle:
  `/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app`;
- executable:
  `/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app/Contents/MacOS/MessageLens Development`;
- product: `MessageLens Development`;
- bundle identifier: `com.bigbenchsoftware.MessageLens.development`;
- version/build: `0.2.132+150`;
- archive environment: `development`;
- build identity: `developmentDebug`;
- signing: ad hoc Debug, no TeamIdentifier;
- executable timestamp: `2026-10-02 13:06:29 -0700`;
- executable SHA-256:
  `83fcf0367af2459fcf5431d446b0b9cd1bbb8492fab3815c6d5c190699178209`;
- App.framework binary timestamp: `2026-10-02 13:06:27 -0700`;
- App.framework binary SHA-256:
  `72ba6af1aff877267dd7b2841d1c5b4d3eb6d068c95ffb3e46bdb09cbc9cd18e`;
- debug Dart kernel SHA-256:
  `7f2261381e775a50c279a25378d7d2492c989d22cf5f8b7eada15eddec91459e`;
- Info.plist SHA-256:
  `1e7ef667ff714b27fdd2a73f1e68715d11dd244bea8183facd89a460b9513486`.

`tool/verify_macos_archive_identity.sh` reports:

`Archive identity artifact verified: development`

The build retained the existing non-blocking Xcode empty-device-build-number
and `volume_controller` privacy-manifest warnings.

## 31. Exact Git, worktree, index, and submodule state

Before creating this response:

- branch: `fix/onboarding-import-stuck-state`;
- HEAD/upstream: `f013388a3a28809a82dd04d97f1ab6a9fb39ef13`;
- ahead/behind: `0/0`;
- index: empty;
- intended tracked modifications: 6;
- intended new production/generated/test files: 6;
- accumulated tracked-diff SHA-256:
  `f2add33e7c4a52ed49b235f56f5ad252a933cb77de46b3d61120810ad255576e`;
- shared-instructions submodule: clean at
  `95326f515ef4719f155ce6e223990398daad6311`;
- all implementation and this response: unstaged and uncommitted;
- unrelated untracked baseline: byte-for-byte path-list hash unchanged;
- no push, merge, rebase, or commit occurred.

The tracked scope is only evaluator/host wiring, AppCzar architecture and
evaluator tests, release metadata, and the version bump. The untracked task
scope is only the Source Access Repair package, its generated provider, its
focused tests, Prompt 52, and this response.

No production startup file, native runner file, archive configuration, real
MessageLens database, Apple Messages database, real attachment archive, or
abandoned relocation artifact was accessed or modified. The development app
was built but not launched.

## 32. Human Source Access Repair qualification readiness

The exact artifact is ready for Scenario A.

1. Ensure every MessageLens Development process is quit normally.
2. In System Settings, turn the visible MessageLens Development Full Disk
   Access entry OFF.
3. In Terminal, set the admitted root:

   ```bash
   launchctl setenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT "/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development"
   ```

4. Direct-launch this exact bundle:

   ```bash
   /usr/bin/open -n "/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app"
   ```

5. Confirm Source Access Repair appears automatically and no other coordinator
   starts.
6. Use `Open System Settings`, or navigate there manually. Merely opening the
   pane should not change the screen's result.
7. Enable the development app entry, return to the still-running app, and
   press `Check Again` once.
8. Confirm the fresh read-only check succeeds and the old process restarts.
9. Confirm the new PID performs a fresh AppCzar assessment. If the source is
   ahead, Data Update may then be selected independently; otherwise the fresh
   disposition should reflect current evidence.
10. After the experiment, quit normally and clear the launch environment:

    ```bash
    launchctl unsetenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT
    ```

These launch and environment commands were not executed by the agent.

`UNKNOWN SOURCE READABILITY NO LONGER SELECTS SOURCE ACCESS REPAIR: YES`

`SOURCE ACCESS REPAIR IMPLEMENTED AS SECOND LIVE COORDINATOR: YES`

`SOURCE ACCESS REPAIR CAN CLAIM FDA STATE: NO`

`SOURCE ACCESS REPAIR CAN CHAIN DIRECTLY TO DATA UPDATE OR OPERATING: NO`

`READY FOR HUMAN SOURCE ACCESS REPAIR QUALIFICATION: YES`
