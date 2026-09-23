# Attachment Archive Relocation: Phase Six Implementation Record

## Status and baseline

Phase Six adds the production Settings workflow over the verified Phase Five
relocation engine. The workflow is complete against disposable data and remains
entirely unstaged for review.

Phase Five was reviewed and committed locally on
`feature/attachment-archive-relocation` as
`0eec796b40c30fb055bf7e51743f86cb18deb5ef` with subject
`feat(attachments): add verified archive relocation engine`. That commit is the
current `HEAD` and has not been pushed.

The shared-instructions submodule remains unchanged at
`95326f515ef4719f155ce6e223990398daad6311`.

Production relocation execution remains disabled. Phase Six does not authorize
or perform the real 39-GB relocation, source retirement, deletion, disk-space
reclamation, a Restore Default shortcut, or fallback to the retained source.

## Settings architecture reused

The existing Phase Three Settings architecture remains authoritative. The
implementation extends the existing Settings spec path through:

- `CassetteWidgetCoordinator` for provider composition;
- `SettingsCoordinator` for feature dispatch;
- `AttachmentArchiveSettingsResolver` for typed presentation policy;
- `AttachmentArchiveSettingsCassettePayload` for view state, status lines, and
  action descriptors;
- `SettingsCassetteBodyBuilder` and the existing cassette render router;
- `SettingsActionList` and the existing sidebar action dispatcher.

The coordinator reads the current location, cheap journal-derived relocation
state, and production enablement. It uses the relocation provider's current
`AsyncValue` synchronously instead of awaiting pending discovery, so Settings
and first usable UI are never blocked by relocation reconstruction.

Widgets render typed payloads and dispatch actions. They do not inspect the
filesystem, resolve bookmarks, create journals, persist configuration, or call
copy/finalization primitives.

## Typed intents and action boundaries

Phase Six adds these sidebar intents:

- `AttachmentArchiveMoveRequested`;
- `AttachmentArchiveChooseAnotherLocationRequested`;
- `AttachmentArchiveRetryPreflightRequested`;
- `AttachmentArchiveBeginRelocationRequested`;
- `AttachmentArchivePauseRelocationRequested`;
- `AttachmentArchiveResumeRelocationRequested`;
- `AttachmentArchiveCancelRelocationRequested`.

`SidebarActionDispatcher` routes them to the Settings-owned
`AttachmentArchiveRelocationActions` boundary. That boundary checks the
production gate before delegating to the public workflow provider. The existing
Settings action-list boundary owns enabled-state dispatch and produces no
callback for a disabled action.

No intent or Settings provider can persist `activeArchive`. The private Phase
Five relocation service and activation permit remain the only activation route.

## Destination selection and preflight review

The existing Phase Two chooser now labels its confirmation as
`Choose Destination`. It returns a destination parent only; MessageLens owns the
managed archive child below that directory.

Move performs destination selection followed by engine preflight and inventory.
It stops at `inventoryComplete`. No payload is copied and no configuration is
activated until the review screen's explicit `Begin Relocation` action.
Cancelling the picker leaves the current workflow and journal unchanged.
Choosing another location opens the picker first and cancels the old operation
only after the user supplies a replacement parent.

The review state displays source, managed destination, volume, physical archive
size, required capacity, reported available capacity, and passed filesystem
safety checks. Its explanatory copy states that MessageLens copies and verifies
before switching, that the source remains authoritative during the operation,
and that the old internal archive will remain afterward.

Preflight deferrals preserve typed reasons for insufficient capacity,
destination unavailable, destination read-only, unsupported filesystem, source
unavailable, unsafe/nested location, and a conflicting managed destination.
The UI offers only Retry Preflight, Choose Another Location, and Cancel as
appropriate. It does not offer destructive repair.

## Progress, pause, resume, and cancellation

`AttachmentArchiveRelocationProgress` now exposes the durable source,
destination parent/volume/managed child, timestamps, capacity evidence, failure
detail, resume stage, and safe action predicates in addition to Phase Five's
copy/verification totals.

Settings presents distinct Copying, Verifying, Finalizing, and Activating
states. Copy and verification progress show human-readable file and byte totals
plus destination availability. No completion-time estimate is invented.

An explicit `AttachmentArchiveRelocationProgressMonitor` polls only the durable
journal while a user-owned relocation command is active. It performs no scan or
mutation, reports polling failures through the workflow state, and stops before
publishing a command's final result. Outside an active command, restart
reconstruction is a single cheap journal read.

Pause is exposed only while `canPause` is true. It sets a typed cooperative
request that the engine observes after a durable per-file receipt boundary. The
source stays authoritative and verified destination work remains journaled.

Resume uses the Phase Five journal. It revalidates source and destination,
reconciles durable receipts, and continues without recopying verified payloads.
A reconstructed provider reads the same paused progress without composing the
overlay database, native adapter, or relocation service.

Cancel remains non-destructive. The UI explicitly says that the source is
authoritative and untouched and that an operation-owned incomplete destination
copy and journal may remain. No Phase Six action deletes either copy.

## Disconnect, reconnect, and restart

A disconnected destination produces a typed paused/deferred presentation with
the destination marked unavailable. Verified receipt progress is retained.
Reconnect does not automatically resume work; the user chooses Resume and the
engine revalidates the known destination before continuing.

Pending relocation discovery reads the current journal under the admitted
primary root. It does not infer state from directory appearance, scan the
archive, or block the initial Settings cassette. A pending or paused operation
therefore reappears truthfully after application/provider reconstruction while
ordinary Messages and search remain usable.

## Activation, completion, and retained source

Only `sourceRetained` with both activation and source-retention evidence is
presented as success. Intermediate copy, verification, finalization,
configuration switching, and `activated` states never say the move is complete.
Rollback presents failure and says that the original configuration was
restored and both copies remain.

Successful Settings presentation names the active external path and
availability and explicitly identifies the retained original path, verified
size, and relocation operation ID. It states that MessageLens did not delete
the original. There is no Delete Old Archive, Free Space, Remove Internal Copy,
or Restore Default action.

If the active external archive is later unavailable, Settings remains calm and
explicit: Messages and search remain usable, archived payloads are unavailable,
and MessageLens does not silently fall back to the retained internal copy.
Ordinary external state exposes neither Move nor a configuration-flip shortcut.

## Production enablement gate

`attachmentArchiveRelocationProductionEnabledProvider` is a non-configurable,
default-off provider whose production value is `false`. Tests can
override it for disposable workflow validation. There is no production UI,
setting, environment variable, or persistence path that can turn it on.

The Move action remains visible but disabled for the default/internal archive
so the production workflow can be reviewed without authorizing execution. Every
Settings relocation action also fails closed at its application boundary if
the gate is disabled.

## Accessibility and failure clarity

Progress is expressed as text and semantic label/value pairs, never by animation
alone. Actions have meaningful labels and semantic button/enabled state.
Disabled actions have no tap semantic and use the theme's disabled text token.
Paused, unavailable, rollback, cancellation, and failure states all have
specific text. Destructive styling is not used because Phase Six exposes no
destructive relocation action.

## Files and release metadata

Production changes extend the attachment relocation domain, engine workflow,
filesystem preflight typing, public workflow seam, Settings coordinator,
resolver, payload, renderer, action boundary, typed sidebar intents/dispatcher,
folder chooser label, and generated Riverpod artifacts. Tests extend the
relocation engine, workflow, Settings resolver/widgets/actions, coordinator,
and architecture tripwires.

Release metadata advances to `0.2.115+133`. The `0.2.115` changelog entry
describes the visible review/progress workflow and explicitly states that real
execution is disabled and that the retained source is not deleted or reclaimed.

## Tests and disposable acceptance exercise

Focused tests cover:

- gated and enabled default/internal state without implicit statistics;
- external available/unavailable states with no move, fallback, or restore
  shortcut;
- picker cancellation and journal-only restart reconstruction;
- explicit review before copy and every typed preflight failure;
- distinct copy, verification, finalization, and activation presentation;
- textual/semantic progress and disabled-action accessibility;
- cooperative pause, durable receipts, provider/service reconstruction, and
  resume without recopy;
- destination disconnect, retained progress, explicit reconnect/resume, and
  source disconnect;
- non-destructive cancellation;
- verified activation, retained-source success, and three rollback boundaries;
- private activation authority, public-seam constraints, widget purity, and the
  production gate defaulting off.

The production-style disposable acceptance test uses an independently created
temporary primary root, temporary destination parent, in-memory overlay
database, and four small unique physical payloads. It walks through internal
Settings, Move, selected/preparing state, preflight review, explicit Begin,
copy progress, pause, journal reconstruction, destination disconnect, paused
unavailable presentation, reconnect, resume, verification/finalization/
activation, external Settings success, and retained-source evidence. It proves
the source tree remains byte-for-byte intact and the destination matches it. A
separate injected post-switch failure proves rollback UI never claims success
and both copies remain.

No production database or real attachment archive was opened, scanned,
inventoried, hashed, copied, moved, created, reset, modified, or deleted. All
filesystem exercise used disposable system-temporary roots that test teardown
removed.

## Validation

Code generation:

```text
dart run build_runner build --delete-conflicting-outputs
```

Result: completed successfully in 40 seconds and wrote 1,573 outputs. Only
expected Phase Six generated artifacts remain changed.

Focused Phase Six Settings/relocation matrix:

```text
flutter test <11 Settings, workflow, engine, repository, coordinator, renderer,
and relocation-authority test files> --reporter compact
```

Result: all 78 tests passed.

Complete attachment feature regression suite:

```text
flutter test test/features/attachments --reporter compact
```

Result: all 243 tests passed, including the Phase Three no-implicit-I/O
performance tests and Phase One-Five location/relocation regressions.

Architecture validation:

```text
flutter test test/architecture/forbidden_imports_test.dart \
  test/architecture/attachment_archive_relocation_authority_test.dart \
  --reporter compact
```

Result: all 393 tests passed.

Complete repository validation:

```text
flutter test --reporter expanded
flutter analyze
git diff --check
```

Result: all 2,399 repository tests passed with the existing one intentional
skip; analysis reported `No issues found!`; the final whitespace check passed.
No native code changed in Phase Six, so native tests were not rerun.

Documentation contains no newly introduced relative Markdown links requiring
resolution. The prior implementation records remain present and unchanged.

## Gates, conformance, and deviations

No mandatory stop-and-report gate A-M was encountered. No Phase Five or
architecture-audit assumption was disproved.

Phase Five required three narrow API extensions to support its already planned
production workflow: a review-stop operation after inventory, a cooperative
pause request checked at durable boundaries, and richer journal-derived
progress/preflight reason projection. The Settings workflow also uses a
journal-only progress monitor during an active command. These additions do not
weaken or duplicate activation, change copy/verification/finalization
semantics, infer filesystem state, or add deletion authority; they are not an
engine redesign.

## Exact Phase Seven starting point

Phase Seven must start only after Phase Six is reviewed and checkpointed. The
production acceptance matrix and gate must then be reviewed separately, and the
real relocation remains unauthorized until an explicit instruction enables and
runs it. After a verified real relocation has operated successfully from the
external archive and that result has been reviewed, Phase Seven may design an
exact retained-source checkpoint/preservation and retirement authority.

That later authority must identify only the proven retained source for the
completed operation, revalidate the active verified destination and all
preservation preconditions, present a separate explicit destructive review,
and never broaden into general archive-root deletion. Reverse relocation to the
internal drive remains copy → verify → activate → retain, not a configuration
flip. No Phase Seven implementation or real-data operation begins in Phase Six.
