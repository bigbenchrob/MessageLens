---
tier: project
scope: attachment-archive-relocation
owner: agent-per-project
last_reviewed: 2026-09-13
source_of_truth: implementation-record
links:
  - 00-ARCHITECTURE-AUDIT-AND-IMPLEMENTATION-PLAN.md
  - ../../25-ONBOARDING-AND-ARCHIVE/ATTACHMENT-PRESERVATION-INVARIANT.md
  - ../../25-ONBOARDING-AND-ARCHIVE/40-attachment-archive.md
---

# Attachment Archive Relocation: Phase One Implementation Record

## Status

Phase One, location model and default compatibility, is implemented and left
uncommitted for review. The architecture audit was first checkpointed at
`f7b8850bdd1e` with commit message
`docs(attachments): add archive relocation architecture plan`.

The active attachment archive remains the same `attachment_archive` child of
the admitted primary MessageLens data root. This phase did not select or
activate an external directory, move payload bytes, change a database schema,
or migrate an attachment record.

## Architecture introduced

### Versioned configuration

`AttachmentArchiveLocationConfiguration` is an immutable, versioned persisted
configuration. Format version 1 supports the operational `defaultInternal`
mode and reserves the `customExternal` discriminator for the native bookmark
phase. An unsupported version or malformed record fails closed. A
`customExternal` record also fails closed in Phase One because no native
resolution mechanism exists yet.

The setting uses the existing overlay settings abstraction under the logical
key `attachment_archive_location`. Absence or an empty value resolves to the
default without writing a row. The serialized default contains only its format
version and mode; it does not persist an absolute archive path.

### Typed location state

`AttachmentArchiveLocationState` publishes the configuration, resolved root,
availability, issue detail, and a location generation. The default location
uses stable generation 0. The availability vocabulary already distinguishes
the default, custom available, custom read-only, custom unavailable,
permission-denied, configured-directory-missing, and invalid-configuration
states. Phase One emits only `defaultAvailable` and `configurationInvalid`.

Unavailable or invalid state does not yield a path. Existing operations use
`requireArchiveRootPath()` and therefore fail closed rather than silently
falling back to another archive.

### Ownership and provider dependencies

`AttachmentArchiveLocationController` is now the only active-root component
that derives the `attachment_archive` child through `ArchiveAccessAuthority`.
`attachmentArchiveLocationProvider` loads one overlay setting and performs
bounded path derivation only. It does not create, inspect, inventory, or scan
the archive directory.

The database-owned `attachmentArchiveDirectoryProvider` and the attachment
runtime forwarding provider `attachmentArchiveDirectoryPathProvider` were
removed. No compatibility bridge was retained because all consumers could be
adapted within this phase without unrelated churn. Attachment runtime, store,
graph compatibility, recovery, health, onboarding diagnostics, and archive
settings consumers now resolve their root through the attachment-owned
location provider.

The existing recursive statistics path remains separate from location
resolution. `ArchiveSettings.build()` still requests statistics as before;
decoupling settings presentation and attachment resolution from those
statistics remains later diagnostic/UI work rather than a Phase One behaviour
change.

### Architecture enforcement

The architecture suite now enforces that:

- active consumers use `attachmentArchiveLocationProvider`;
- retired archive-directory providers do not return;
- only the location controller derives the active `attachment_archive` child;
- production code does not hard-code `/Volumes/...` as an archive root; and
- donor-package readers retain their independent `attachment_archive` format
  convention without depending on the active location provider.

## Files changed

New production components:

- `lib/features/attachments/domain/entities/attachment_archive_location_configuration.dart`
- `lib/features/attachments/domain/entities/attachment_archive_location_state.dart`
- `lib/features/attachments/application/attachment_archive_location_controller.dart`
- `lib/features/attachments/application/attachment_archive_location_provider.dart`
- `lib/features/attachments/application/attachment_archive_location_provider.g.dart`
- `lib/features/attachments/application/attachment_archive_settings_store_provider.dart`
- `lib/features/attachments/application/attachment_archive_settings_store_provider.g.dart`

Provider and consumer adaptations:

- `lib/essentials/conversation_graph/application/health/graph_health_repository_provider.dart`
- `lib/essentials/db/feature_level_providers/persistent_database_providers.dart`
- `lib/essentials/db/feature_level_providers/persistent_database_providers.g.dart`
- `lib/essentials/onboarding/application/onboarding_environment_report_provider.dart`
- `lib/features/attachments/application/archive_settings_provider.dart`
- `lib/features/attachments/application/attachment_archive_runtime_providers.dart`
- `lib/features/attachments/application/attachment_archive_runtime_providers.g.dart`
- `lib/features/attachments/application/attachment_archive_service_provider.dart`
- `lib/features/attachments/application/attachment_archive_store_providers.dart`
- `lib/features/attachments/application/deterministic_recovery_runtime_providers.dart`
- `lib/features/attachments/application/graph_attachment_archive_providers.dart`
- `lib/features/attachments/application/message_lens_attachment_recovery_batch_executor_provider.dart`
- `lib/features/attachments/feature_level_providers.dart`
- `lib/features/settings/application/message_lens_historical_archive_preflight_provider.dart`

Tests added or adapted:

- `test/features/attachments/application/attachment_archive_location_provider_test.dart`
- `test/features/attachments/application/archive_settings_provider_test.dart`
- `test/features/attachments/application/attachment_archive_service_provider_test.dart`
- `test/features/attachments/application/attachment_resolver_provider_test.dart`
- `test/essentials/archive_environment/application/archive_scoped_persistent_providers_test.dart`
- `test/essentials/archive_environment/integration/production_adoption_preservation_rehearsal_test.dart`
- `test/essentials/onboarding/application/onboarding_environment_report_provider_test.dart`
- `test/architecture/forbidden_imports_test.dart`

## Behaviour and persistence

- Missing configuration resolves to exactly the previous primary-root child.
- Explicit default configuration resolves to the same path.
- Default-on-read performs no initialization write.
- Existing `archive_relative_path`, hashes, compatibility keys, and payload
  storage are unchanged.
- Overlay schema version 8 and conversation graph schema version 3 are
  unchanged.
- Existing write/read, resolver, recovery, adoption, onboarding, startup, and
  donor behaviour continues through the new ownership seam.
- Provider overrides remain deterministic through either the admitted archive
  authority or an explicit typed location-state override.

## Validation

Generation:

```text
dart run build_runner build --delete-conflicting-outputs \
  --build-filter=lib/features/attachments/application/attachment_archive_location_provider.g.dart \
  --build-filter=lib/features/attachments/application/attachment_archive_settings_store_provider.g.dart \
  --build-filter=lib/features/attachments/application/attachment_archive_runtime_providers.g.dart \
  --build-filter=lib/essentials/db/feature_level_providers/persistent_database_providers.g.dart
```

Focused provider/archive/onboarding validation:

```text
flutter test \
  test/features/attachments/application/attachment_archive_location_provider_test.dart \
  test/features/attachments/application/archive_settings_provider_test.dart \
  test/features/attachments/application/attachment_archive_service_provider_test.dart \
  test/features/attachments/application/attachment_resolver_provider_test.dart \
  test/features/attachments/application/message_lens_attachment_recovery_batch_executor_test.dart \
  test/essentials/archive_environment/application/archive_scoped_persistent_providers_test.dart \
  test/essentials/onboarding/application/onboarding_environment_report_provider_test.dart \
  test/essentials/archive_environment/integration/production_adoption_preservation_rehearsal_test.dart \
  --reporter expanded
```

Result: 51 tests passed.

Architecture validation:

```text
flutter test test/architecture/forbidden_imports_test.dart --reporter expanded
```

Result: 386 tests passed.

Full repository validation:

```text
flutter test --reporter compact
```

Result: 2,262 tests passed.

Static and patch validation:

```text
flutter analyze
git diff --check
```

Result: analysis reported no issues and the diff check passed.

All database use in tests was in-memory or temporary fixture data. No user
database or attachment payload archive was opened, modified, moved, scanned,
or reset.

## Audit conformance and Phase Two starting point

No audit assumption was disproved. There was no need for a compatibility
provider. The only retained debt called out by the audit is the pre-existing
coupling of `ArchiveSettings.build()` to recursive statistics; the new
location provider does not inherit that work.

Phase Two should extend configuration version 1 with bookmark-backed custom
location identity and add the macOS resolution boundary. It should publish
real custom availability states and advance the generation monotonically when
the resolved root or its availability changes. It must continue to fail closed
when a configured custom archive cannot be resolved and must not yet relocate
payload bytes.
