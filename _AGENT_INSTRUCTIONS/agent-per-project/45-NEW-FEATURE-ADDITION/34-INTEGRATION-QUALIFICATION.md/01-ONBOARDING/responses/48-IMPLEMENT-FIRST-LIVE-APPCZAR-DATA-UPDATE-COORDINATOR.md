# MessageLens Feature 34
## Response 48 — Implement the First Live AppCzar Coordinator: Data Update

Date: 2026-10-02

## 1. Baseline verification

Implementation began in
`/Users/rob/Development/FlutterProjects/remember_every_text` on
`fix/onboarding-import-stuck-state` at
`9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`, equal to its upstream.
The index was empty, the accumulated Prompt 32 + 35 + 44 + 46 work was
present, and Response 47 had made no source or test change. The tracked status
had 32 entries, 95 untracked files were present, and the shared-instructions
submodule was clean at `95326f515ef4719f155ce6e223990398daad6311`.

An external baseline manifest was recorded at
`/private/tmp/messagelens-prompt48-baseline-20261002.txt` before editing.

## 2. Existing update machinery selected for reuse

The proven update path was separated from `ChatDbChangeMonitor` into
`LiveGraphUpdateWorker`. Both the automatic monitor and AppCzar now call that
same worker. It composes only existing production machinery:

1. `ChatDbSourceProbeReader` reads the current source high-water and importable
   message count.
2. `ImportLedgerProbeReader` reads the live-source import ledger cursor/count.
3. `ConversationGraphBuildController.runOnce` invokes the existing ordered
   `ConversationGraphBuildOrchestrator` and its source-scoped import/projector
   stages.
4. The existing controller bumps `messageDataVersionProvider` after the graph
   build returns.
5. `AttachmentArchiveService.archiveGraphMessageSourceRange` preserves
   attachments for the exact imported source-row range.

The graph build remains a fixed ordered import-and-projection operation. The
message importer retains its existing frozen high-water, bounded-page,
transaction, ledger, and idempotence semantics.

## 3. Proof that no second importer was created

No importer, projector, database implementation, or source query was added to
`app_czar_data_update`. The new package imports the shared worker contract; the
worker delegates to `ConversationGraphBuildController` and
`AttachmentArchiveService`. Existing message-importer, orchestrator,
projection, attachment, and monitor regression suites all pass unchanged.

## 4. Data Update coordinator scope

`AppCzarDataUpdateController` owns only one bounded occurrence:

- accept the exact immutable AppCzar Data Update disposition;
- invoke the admitted shared worker once;
- project factual in-memory progress;
- reject deferred or failed attachment preservation;
- surface literal bounded failure; and
- request process restart after the executor has returned.

It does not classify the installation, invoke AppCzar, publish readiness or
Operating state, publish Onboarding state, restore navigation, persist resume
state, or decide the post-restart disposition.

## 5. AppCzar-to-coordinator execution seam

The private coordinator host in `AppCzarStartupHarness` watches
`AppCzarDataUpdateController`. The controller's executable predicate is one
exact equality:

`assessment.virtualCoordinator == AppCzarVirtualCoordinator.dataUpdate`

On that result it immediately replaces the assessment screen with the Data
Update screen and schedules one microtask. Its recorded assessment generation
prevents another occurrence. While active, the assessment rerun control and
all normal application UI are absent.

## 6. Proof that only Data Update is executable

A table-driven test evaluates every `AppCzarVirtualCoordinator` value and
permits execution only for `dataUpdate`. Architecture checks prohibit generic
virtual-coordinator dispatch and prohibit Onboarding, Source Access Repair, or
Operating Session references in the executable controller. Existing evaluator
and presentation tests continue to represent the other dispositions as data
only.

## 7. Worker prerequisite and currentness checks

Immediately inside the admitted operation, the worker re-reads:

- conversation-graph readiness;
- current source `MAX(ROWID)`;
- current importable source-message count;
- imported live-source ledger cursor; and
- imported live-source message count.

An unready local dataset or unreadable source fails before graph or attachment
mutation. If the source advanced after AppCzar assessed it, the existing graph
builder/importer consumes its own supported current/frozen boundary. If the
worker snapshot is already current, it performs no mutation and the process
still restarts for a fresh semantic assessment.

## 8. Mutation-tenure path

The exact path is:

```text
AppCzar Data Update disposition
-> AppCzarDataUpdateController
-> AdmittedAppCzarDataUpdateExecutor
-> ArchiveMutationCoordinator.runWithCapability(liveGraphUpdate)
-> LiveGraphUpdateWorker
-> ConversationGraphBuildController / existing graphBuild nested scope
-> AttachmentArchiveService / existing attachmentReconciliation nested scope
-> outer capability recheck
-> outer scope return and release
-> process restarter
```

Feature 35's async-zone re-entry carries the same
`ExclusiveAuthorityTenure`; nested typed operations do not create a second
Ball. A combined controller/executor test proves the restarter observes the
archive mutation coordinator unlocked, with hold count zero and a recorded
release time.

The executor provider is explicitly keep-alive because its admitted async
callback retains its provider `Ref` until the worker completes.

## 9. Live progress model

Progress is an in-memory `AppCzarDataUpdateState` only. It shows:

- worker-current source count;
- worker-current MessageLens count;
- their non-negative delta;
- actual `ConversationGraphBuildObservation` stage;
- actual completed/total units when the worker supplies both; and
- final attachment examined/preserved counts.

There is no fabricated percentage, durable operation snapshot, resumability
record, or persisted cursor owned by the coordinator.

## 10. Attachment-preservation behavior

Attachment work starts only after the graph build returns and uses the existing
`archiveGraphMessageSourceRange` operation with the report's
`startedAfterSourceRowId` and `lastImportedSourceRowId`. Existing archive
preservation, lease, collision, source-path, streaming, and deferral semantics
are unchanged. Deferred preservation or any failed payload makes the Data
Update occurrence fail factually instead of claiming success.

## 11. Semantic-success-callback non-use

There is no success, ready, current, Onboarding, navigation, or Operating
callback. A normally returned bounded worker result is used only to request
restart. Neither the controller state nor its presentation contains an
in-process success/Operating phase.

## 12. Exact restart mechanism

No suitable existing process restarter existed. The smallest development-safe
adapter was added behind `AppCzarProcessRestarter`.

`MacosDevelopmentProcessRestarter`:

1. fails closed unless the existing exact development execution gate is true;
2. derives the current `.app` bundle from `Platform.resolvedExecutable`;
3. starts a detached `/bin/sh` helper;
4. the helper waits until `/bin/kill -0 <old-pid>` fails;
5. the helper executes `/usr/bin/open -n <same-bundle>`; and
6. only after the helper is admitted does the current process call `exit(0)`.

The helper script is:

```text
while /bin/kill -0 "$1" 2>/dev/null; do /bin/sleep 0.1; done; exec /usr/bin/open -n "$2"
```

## 13. Proof of a new process boundary

The restart adapter test proves helper launch precedes termination, passes the
old PID and exact derived bundle, waits for the old PID to disappear, and uses
LaunchServices with `-n`. This is not Riverpod invalidation or in-process
navigation. All AppCzar facts, progress, and one-shot controller fields are
memory-only, so termination removes them; the relaunched process constructs a
new provider container and begins AppCzar assessment from generation zero.

## 14. Relaunch environment behavior

Restart code contains no WD path and does not read, write, or replace
`MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT`. The human-qualified direct launch uses
`launchctl setenv`, so the new LaunchServices process receives the same launchd
environment. The exact development gate is re-evaluated by the new process.

The launchd variable was confirmed unset after the final build; this task did
not set it.

## 15. Terminal failure behavior

A worker/prerequisite/preservation/restart failure leaves the dedicated Data
Update screen visible with the literal error. It does not invoke another
coordinator, publish semantic failure for the whole app, resume from durable
state, or enter normal UI. The sole recovery control is **Restart and
reassess**, which requests the same real process boundary without rerunning the
failed worker in-process.

## 16. Coordinator-focused tests

The final focused Data Update/worker/architecture/composition run passed
26/26. The broader AppCzar/Data Update run passed 55/55 before the final
provider-lifetime tightening, and the final complete suite reran all of those
tests successfully.

Coverage includes exact mapping, one occurrence, one worker call, progress,
literal failure, no assessment rerun, no normal UI, one restart, and restart
after executor completion.

## 17. Incremental-worker regressions

The targeted existing monitor, graph controller, graph orchestrator,
source-scoped message importer, and attachment service run passed as part of a
118/118 incremental/mutation regression group. It covers frozen high-water,
bounded pages, idempotence, ordering, projection, source-range attachment
preservation, and existing monitor decision behavior.

## 18. Mutation-authority regressions

`ArchiveMutationCoordinator`, `ExclusiveAuthorityRegistry`, and the complete
Feature 35 architecture enforcement passed. New tests prove one outer typed
tenure remains active through prerequisite, graph, and attachment callbacks,
then is released before restart.

## 19. Restart tests

Four adapter tests pass:

- exact bundle derivation;
- detached helper before exit with exact PID/bundle arguments;
- fail closed outside the exact development gate; and
- fail closed outside macOS.

Controller integration separately proves exactly one restart and tenure release
before that request.

## 20. AppCzar isolation and mapping tests

AppCzar evaluation remains deterministic and read-only. Its existing
Operating, Onboarding, Source Access Repair, Local Data Repair, and Data Update
mapping tests pass. New architecture checks permit only the private coordinator
host to cross into Data Update presentation, permit only one mutation-admission
edge, reject generic disposition dispatch, reject durable/semantic authorities,
and isolate process mechanics to the macOS infrastructure adapter.

## 21. Architecture result

The dedicated complete architecture run passed 565/565. Its first run found
three exact declaration issues: a provider implementation was re-exporting the
new worker contract, and the new infrastructure adapter was absent from the
process-execution and platform-runtime allow-lists. The re-export was removed,
its consumer now imports the worker directly, and only the exact adapter path
was added to the two infrastructure allow-lists. The final full suite reran the
entire architecture set successfully.

## 22. Analyzer result

`flutter analyze`: PASS — no issues found.

## 23. Full Flutter-suite result

Final `flutter test`: PASS — 2,817 tests passed with one existing explicitly
skipped qualification worker (`~1`). No test failed.

## 24. Diff, format, generated, and build hygiene

- `git diff --check`: PASS.
- Targeted `dart format --output=none --set-exit-if-changed`: 21 files checked,
  zero changed.
- `build_runner build --delete-conflicting-outputs`: PASS; final incremental
  run generated the keep-alive executor provider and completed cleanly.
- Final debug macOS build: PASS.
- The final build did not launch MessageLens Development.
- No MessageLens Development process remained after the build.
- No real archive, MessageLens database, Apple Messages database, or archive
  configuration was accessed or modified by implementation, isolated tests, or
  build inspection.

## 25. Project Conformance verdict

`PROJECT CONFORMANCE: PASS`

- Exactly one executable live coordinator mapping: PASS.
- All other mappings virtual: PASS.
- Existing update machinery reused: PASS.
- One exclusive mutation tenure/Ball: PASS.
- No second importer: PASS.
- No semantic success callback: PASS.
- No in-process transition to Operating: PASS.
- Real restart after bounded success and tenure release: PASS.
- Fresh AppCzar assessment after restart: PASS.
- Progress memory-only; no resume snapshot: PASS.
- Fair-Witness copy only: PASS.
- Production startup unchanged: PASS.
- Normal application UI inaccessible in the development harness: PASS.

## 26. BLOCKER findings

`BLOCKER: 0`

## 27. SHOULD FIX findings

`SHOULD FIX: 0`

The build retained the existing non-blocking Xcode toolchain warnings about an
empty device build number and the `volume_controller` privacy manifest rule.
They are unrelated to this implementation and did not affect the artifact.

## 28. Exact build identity, path, and hashes

Build command:

```text
/Users/rob/Development/flutter/bin/flutter build macos --debug --no-pub
```

- Bundle:
  `/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app`
- Executable:
  `/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app/Contents/MacOS/MessageLens Development`
- Product: `MessageLens Development`
- Bundle identifier: `com.bigbenchsoftware.MessageLens.development`
- Version/build: `0.2.131+149`
- Build identity: `developmentDebug`
- Signing: ad hoc Debug; no TeamIdentifier
- Executable timestamp: `2026-10-02 08:29:49 -0700`
- Executable SHA-256:
  `faf6d1f58550bb6eecfc9d72bd7a9130c84265baeb3c4762d092b84ee659f7c2`
- App.framework binary timestamp: `2026-10-02 08:37:22 -0700`
- App.framework binary SHA-256:
  `418be669ccbd5022d123d03c347338fb07a6569bff5caa88041f665f3a78d98a`
- Info.plist SHA-256:
  `44b734147fdd29e945eecc093af11cf4a21ee83f567c452dbbd4cf6a9695e116`

Human direct-launch preparation:

```bash
launchctl setenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT "/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development"
/usr/bin/open -n "/Users/rob/Development/FlutterProjects/remember_every_text/build/macos/Build/Products/Debug/MessageLens Development.app"
```

After the experiment, quit the directly launched app normally and run:

```bash
launchctl unsetenv MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT
```

These launch/cleanup commands were not executed by the agent.

## 29. Exact Git, worktree, index, and submodule state

- Branch: `fix/onboarding-import-stuck-state`
- HEAD: `9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`
- Upstream: `9171c9c2882a19d133b3c09c9383d6cea1b4fbcb`
- Index: empty; nothing staged.
- Tracked status entries: 38 accumulated modifications.
- Untracked status entries: 70, representing 113 individual untracked files
  after adding Response 48.
- Final porcelain-status SHA-256:
  `c6fe9573bc04b1e7f40b4ba8d08970ab468061a5b577684c17809f934cf63a1b`.
- Final accumulated tracked-diff SHA-256:
  `3ce2ec01ca857c72106272632972869941f0f55a5f8fb7a4456c4a52a9ad3ead`.
- Prompt 48 implementation and Response 48: unstaged/untracked as required.
- Accumulated earlier onboarding/AppCzar changes remain unstaged/untracked.
- Known unrelated untracked files remain untouched.
- Shared-instructions submodule: clean and unchanged at
  `95326f515ef4719f155ce6e223990398daad6311`.
- No commit, merge, rebase, checkout, or push was performed.

## 30. Readiness for the human self-healing Data Update experiment

READY. With the launchd development-root environment set and source access
readable, the expected bounded sequence is:

```text
fresh AppCzar assessment selects Data Update
-> one admitted Data Update occurrence
-> existing incremental import/graph/attachment machinery
-> old process exits after tenure release
-> detached helper launches a new PID
-> fresh AppCzar assessment starts from zero
-> Operating Session, if selected, remains virtual on the AppCzar screen
```

The human should record the pre-update Data Update screen, the automatic PID
change, and the post-restart AppCzar screen. Do not open Conversations during
this experiment.

`FIRST LIVE APPCZAR COORDINATOR IMPLEMENTED: YES`

`DATA UPDATE REUSES EXISTING UPDATE MACHINERY: YES`

`DATA UPDATE CAN DECLARE OPERATING IN-PROCESS: NO`

`SUCCESS ENDS IN REAL PROCESS RESTART: YES`

`READY FOR HUMAN SELF-HEALING DATA-UPDATE EXPERIMENT: YES`
