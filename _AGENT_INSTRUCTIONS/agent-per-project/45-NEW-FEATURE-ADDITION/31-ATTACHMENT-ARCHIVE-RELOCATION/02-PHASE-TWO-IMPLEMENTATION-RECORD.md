---
tier: project
scope: attachment-archive-relocation
owner: agent-per-project
last_reviewed: 2026-09-15
source_of_truth: implementation-record
links:
  - 00-ARCHITECTURE-AUDIT-AND-IMPLEMENTATION-PLAN.md
  - 01-PHASE-ONE-IMPLEMENTATION-RECORD.md
  - ../../25-ONBOARDING-AND-ARCHIVE/ATTACHMENT-PRESERVATION-INVARIANT.md
  - ../../25-ONBOARDING-AND-ARCHIVE/40-attachment-archive.md
  - ../../60-BUILD-CONSIDERATIONS/02-macos-fda-grant-continuity.md
---

# Attachment Archive Relocation: Phase Two Implementation Record

## Status and baseline

Phase Two implements safe bookmark-backed external archive identity and volume
availability. It remains unstaged for review.

Work began on `feature/attachment-archive-relocation` at
`413f644e2d347c4d80b7ddc2179101fb7086ace7`, three commits ahead and zero
behind `main` / `origin/main` at
`7e8e6ea959ef1a3e078ee049159489d1ac3b6b8f`. Relevant history is:

- `413f644e` — `merge: integrate tester archive import remediation`
- `bf7ddc29` — `feat(attachments): implement archive relocation phase one`
- `f7b8850b` — `docs(attachments): add archive relocation architecture plan`

The shared-instructions submodule remained unchanged at
`95326f515ef4719f155ce6e223990398daad6311`.

## Phase 2A: internal-only mutation authority

Phase 2A was completed and tested before custom bookmark resolution was made
operational.

`AttachmentArchiveMutationRoot` is an unforgeable typed capability with a
private constructor. `AttachmentArchiveLocationState` can issue it only when
the resolved state is both `defaultAvailable` and configured as
`defaultInternal`. `attachmentArchiveMutationRootProvider` is the single
provider seam that performs that validation. Physical writability reported by
bookmark resolution is deliberately separate from mutation authority.

The following existing paths now acquire that capability before they can
mutate a root:

- single-attachment and bulk ingestion through
  `AttachmentArchiveService`;
- archive-directory creation and payload writes orchestrated by that service;
- `ArchiveSettings.clearArchive()`, before recursive reset or metadata clear;
- deterministic recovery writer construction; and
- MessageLens recovery installer/batch-executor construction.

Integrity verification remains a read operation and uses the readable location
state. Architecture tests enumerate the approved high-level mutation consumers
and low-level ensure/write/install/reset and recovery-constructor call sites.
They also prove that only the location state can construct the capability and
that callers cannot bypass its provider.

Consequently, a resolved custom root can be read or displayed, but none of the
existing ingestion, recovery, root-creation, or destructive reset paths can
receive it. A remembered path never grants either read or mutation authority.
The later generation-bound writable-root lease and deferred-ingestion policy
remain Phase Four work.

## Phase 2B: bookmark-backed custom identity

### Persisted configuration

Version 1 of `AttachmentArchiveLocationConfiguration` now supports
`customExternal` with:

- `mode`;
- Foundation bookmark bytes encoded as base64;
- `lastKnownPath` for display/debugging only; and
- optional `volumeName` display metadata.

The existing overlay setting key remains `attachment_archive_location`.
Configuration validates the version, mode, bookmark encoding, and required
display path. The active root is never stored in `archived_attachments`, and
no schema or attachment-record field changed.

Custom resolution uses only bookmark bytes. Failure never falls back to
`lastKnownPath`, and a state without positive bookmark resolution exposes no
usable root path.

### Dart and macOS boundaries

The attachment application layer owns narrow folder-chooser and native-bookmark
interfaces. The production chooser reuses `file_selector` directory selection;
no widget performs selection or bookmark creation.

`AttachmentArchiveLocationBridge.swift` provides method and event channels for:

- validating an existing selected directory and creating a normal Foundation
  URL bookmark;
- resolving the bookmark with UI suppressed;
- reporting stale-bookmark refresh data;
- returning typed availability/failure payloads; and
- delivering mount, unmount, volume-rename, and application-activation events.

MessageLens is unsandboxed, so this phase uses normal Foundation bookmarks. It
does not add App Sandbox or user-selected entitlements and does not claim
security-scoped access. Creation requires an existing, non-symlink, readable
directory and never creates one. Resolution likewise checks the bookmarked
object without creating it; an absent `/Volumes/<volume>` root is classified as
unavailable, while a missing directory on an available volume is classified as
configured-directory-missing.

Folder selection means only “remember and resolve this location.” There is no
production Move Archive action and no payload movement.

## Phase 2C: availability, events, and generation

Operational state distinguishes:

- `defaultAvailable`;
- `customAvailable`;
- `customReadOnly`;
- `customUnavailable`;
- `permissionDenied`;
- `configuredDirectoryMissing`; and
- `configurationInvalid`.

Only default, custom-available, and custom-read-only states expose resolved
roots for reads. Custom writable/read-only physical status never grants Phase
Two mutation authority.

The keep-alive location notifier maintains a process-local monotonic generation.
Its effective-location equality is explicitly the combination of availability,
configuration mode, and resolved root path. Generation advances on mode,
availability, or resolved-path change and on explicit custom reselection. A
repeated observation of the same state remains stable. Default startup remains
generation 0, performs no bookmark work, and writes no initialization setting.

Native events are observed only while a custom location is active. Mount,
unmount, rename, and application activation trigger one cheap bookmark
re-resolution. The event path performs no recursive traversal, statistics,
integrity check, inventory, or hashing, and it is not a first-frame startup
gate. Concurrent resolutions use a serial so stale results cannot overwrite a
newer selection.

When successful resolution provides a refreshed stale bookmark, changed mount
path, or volume metadata, the configuration is refreshed in the overlay
setting. Invalid configuration remains correctable by selecting a new custom
location or returning to default.

## Narrow supporting refactor

`ArchiveSettings.build()` now reads rather than watches its pre-existing
recursive stats provider. This prevents location invalidation from recursively
rebuilding settings/statistics while preserving the existing explicit refresh
and post-clear invalidation behavior. Full separation of cheap location state
from archive diagnostics remains Phase Three work.

## Files changed

Production Dart additions and changes:

- `lib/features/attachments/domain/entities/attachment_archive_location_configuration.dart`
- `lib/features/attachments/domain/entities/attachment_archive_location_state.dart`
- `lib/features/attachments/application/attachment_archive_location_controller.dart`
- `lib/features/attachments/application/attachment_archive_location_provider.dart`
- `lib/features/attachments/application/attachment_archive_location_native_adapter.dart`
- `lib/features/attachments/application/attachment_archive_location_folder_chooser.dart`
- `lib/features/attachments/application/attachment_archive_location_dependencies_provider.dart`
- generated attachment application-provider files affected by those providers
- `lib/features/attachments/application/archive_settings_provider.dart`
- `lib/features/attachments/application/attachment_archive_service_provider.dart`
- `lib/features/attachments/application/deterministic_recovery_runtime_providers.dart`
- `lib/features/attachments/application/message_lens_attachment_recovery_batch_executor_provider.dart`
- `lib/features/attachments/infrastructure/repositories/file_selector_attachment_archive_location_folder_chooser.dart`
- `lib/features/attachments/infrastructure/repositories/method_channel_attachment_archive_location_native_adapter.dart`

Native additions and changes:

- `macos/Runner/AttachmentArchiveLocationBridge.swift`
- `macos/Runner/AppDelegate.swift`
- `macos/Runner.xcodeproj/project.pbxproj`
- `macos/RunnerTests/RunnerTests.swift`

Tests and documentation:

- `test/features/attachments/application/attachment_archive_location_provider_test.dart`
- `test/features/attachments/application/attachment_archive_mutation_authority_test.dart`
- `test/features/attachments/infrastructure/repositories/method_channel_attachment_archive_location_native_adapter_test.dart`
- existing Phase One attachment/onboarding/adoption provider tests adapted to
  the async notifier seam
- `test/architecture/forbidden_imports_test.dart`
- this record and the factual Phase One status correction

## Validation

Provider generation:

```text
dart run build_runner build --delete-conflicting-outputs \
  --build-filter=lib/features/attachments/application/attachment_archive_location_dependencies_provider.g.dart \
  --build-filter=lib/features/attachments/application/attachment_archive_location_provider.g.dart \
  --build-filter=lib/features/attachments/application/archive_settings_provider.g.dart \
  --build-filter=lib/features/attachments/application/attachment_archive_service_provider.g.dart \
  --build-filter=lib/features/attachments/application/deterministic_recovery_runtime_providers.g.dart \
  --build-filter=lib/features/attachments/application/message_lens_attachment_recovery_batch_executor_provider.g.dart
```

Focused configuration, location, adapter, safety, and Phase One regression
tests:

```text
flutter test \
  test/features/attachments/application/attachment_archive_location_provider_test.dart \
  test/features/attachments/application/attachment_archive_mutation_authority_test.dart \
  test/features/attachments/infrastructure/repositories/method_channel_attachment_archive_location_native_adapter_test.dart \
  test/features/attachments/application/archive_settings_provider_test.dart \
  test/features/attachments/application/attachment_archive_service_provider_test.dart \
  test/features/attachments/application/attachment_resolver_provider_test.dart \
  test/features/attachments/application/message_lens_attachment_recovery_batch_executor_test.dart \
  test/essentials/archive_environment/application/archive_scoped_persistent_providers_test.dart \
  test/essentials/onboarding/application/onboarding_environment_report_provider_test.dart \
  test/essentials/archive_environment/integration/production_adoption_preservation_rehearsal_test.dart \
  --reporter expanded
```

Result: 71 tests passed.

Architecture validation:

```text
flutter test test/architecture/forbidden_imports_test.dart --reporter expanded
```

Result: 388 architecture tests passed.

Native bridge validation used a disposable development archive root so the
test host could run independently of any live MessageLens instance:

```text
env MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT=/private/tmp/messagelens-phase-two-native-tests-20260915 \
  xcodebuild test \
  -workspace macos/Runner.xcworkspace \
  -scheme Runner \
  -configuration Debug \
  -destination 'platform=macOS'
```

All 16 native tests passed, including three new bookmark tests: temporary
directory round-trip, invalid bookmark failure, and deleted-directory
resolution without recreation.

Full repository and static validation:

```text
flutter test --reporter expanded
flutter analyze
git diff --check
```

Result: the complete repository suite passed 2,313 tests with one explicitly
skipped qualification harness; analysis reported no issues; and the diff check
passed. Documentation links in the architecture plan and both implementation
records were validated locally.

All automated filesystem tests used temporary directories. No user database
or real attachment payload archive was opened, scanned, copied, moved, created,
reset, or deleted.

## Capacity, privacy, and release metadata

Phase Two does not call `volumeAvailableCapacityForImportantUsage` or any other
capacity API. Capacity belongs to later relocation preflight, so associated
required-reason API analysis and any `PrivacyInfo.xcprivacy` change remain
deferred until that API is actually selected. No privacy manifest was added
speculatively.

No production relocation UX exists yet, so this internal capability phase does
not bump `pubspec.yaml` or add a changelog entry.

## Audit conformance and remaining work

One architecture-audit assumption was corrected before implementation: making
custom roots operational could not safely precede write admission because
existing writers and `clearArchive()` accepted any active root. The revised
Phase 2A internal-only capability is the smallest prerequisite that closes that
cross-phase hazard. It does not implement the full Phase Four writable lease.

No other audit assumption was disproved. No schema version changed, no
migration was added, and no FTS, import, graph, attachment row, relative path,
or hash representation changed. No payload copy, inventory, relocation journal,
staging area, activation, or source deletion was introduced.

Remaining debt is intentional:

- Phase Three must make reads, evidence, onboarding/health diagnostics, and UI
  availability-aware so an unavailable root is not misreported as missing or
  corrupt per-file payloads.
- Phase Three should finish separating cheap settings/location state from
  recursive archive statistics and invalidate path-bearing caches on location
  generation changes.
- Phase Four must introduce generation-bound writable-root admission, deferred
  ingestion/recovery behavior, and reconnect safety before any custom root may
  be mutated.
- Relocation, capacity preflight, progress UI, activation, and retained-source
  retirement remain later phases.

The proposed Phase Three starting point is the read/lookup contract: propagate
root availability and generation through resolver/evidence results first, then
adapt onboarding, graph health, attachment surfaces, and settings diagnostics
without adding any write authority or relocation behavior.
