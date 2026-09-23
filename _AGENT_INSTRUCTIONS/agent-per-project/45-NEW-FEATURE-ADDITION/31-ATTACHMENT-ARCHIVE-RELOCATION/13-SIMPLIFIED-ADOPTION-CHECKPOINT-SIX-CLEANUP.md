# Simplified Archive Adoption — Checkpoint Six Cleanup

## Status and checkpoint boundary

Checkpoint Six removes the obsolete MessageLens-owned relocation/mover runtime
superseded by `08-SIMPLIFIED-ARCHIVE-ADOPTION-DESIGN.md`. It preserves the
Phase One–Four location, availability, mutation-authority, and writable-root
architecture together with the completed candidate-verification and adoption
workflow.

Checkpoint Five was reviewed and committed before this cleanup began:

```text
6af755487b4bc679489e2c6d2cc8e1ee6ff10666
feat(attachments): add existing archive adoption workflow
```

Checkpoint Six remains entirely unstaged and uncommitted. It does not enable
production adoption and does not begin the development rehearsal.

## Deleted production files

The following mover-only production files are deleted:

- `attachment_archive_relocation_activation_gate.dart`;
- `attachment_archive_relocation_enablement_provider.dart` and generated
  provider;
- `attachment_archive_relocation_file_system.dart`;
- `attachment_archive_relocation_journal_store.dart`;
- `attachment_archive_relocation_metadata_reader.dart`;
- `attachment_archive_relocation_progress_monitor.dart`;
- `attachment_archive_relocation_provider.dart` and generated provider;
- `attachment_archive_relocation_service.dart`;
- `attachment_archive_relocation.dart`;
- `darwin_exclusive_directory_finalizer.dart`;
- `filesystem_attachment_archive_relocation_file_system.dart`;
- `filesystem_attachment_archive_relocation_journal_store.dart`;
- `overlay_attachment_archive_relocation_metadata_reader.dart`;
- `attachment_archive_relocation_actions_provider.dart` and generated
  provider; and
- `macos/Runner/PrivacyInfo.xcprivacy`.

This removes the durable mover state machine, journal discovery and recovery,
inventory/copy receipts, staging, capacity and filesystem-semantics preflight,
copy/install loop, pause/resume, progress polling, exclusive finalization,
managed destination, mover activation permit, and mover-specific Settings
composition.

## Adapted production files

The following production files are adapted rather than deleted:

- `attachment_archive_location_controller.dart` removes relocation permits
  and activation/rollback entry points;
- `attachment_archive_location_provider.dart` and its generated provider
  remove relocation composition and use adoption terminology;
- `attachment_archive_location_native_adapter.dart` retains only bookmark and
  location capabilities;
- `method_channel_attachment_archive_location_native_adapter.dart` removes
  destination-capacity decoding;
- `AttachmentArchiveLocationBridge.swift` removes the Disk Space method,
  implementation, and error vocabulary while retaining bookmark resolution
  and location events;
- `attachment_archive_location_configuration.dart` uses
  `readOnlyUntilVerifiedAdoption` while continuing to parse the historical
  serialized relocation value;
- `archive_mutation_operation.dart` removes the unused relocation coordinator
  operation while retaining the adoption and ordinary archive operations;
- `macos/Runner.xcodeproj/project.pbxproj` removes the obsolete privacy
  resource; and
- `CHANGELOG.md` and `pubspec.yaml` describe release `0.2.121+139` as verified
  adoption rather than a MessageLens-owned move.

No signing setting, entitlement, bundle identifier, certificate, bookmark
bridge, or location-event bridge changed.

## Reusable code retained

The cleanup retains the code required by the simplified product:

- admitted archive-access authority and Phase One–Four location resolution;
- bookmark persistence, native availability observation, and no-fallback
  location behavior;
- the archive mutation coordinator and typed internal mutation authority;
- candidate verification, safe deterministic traversal, preservation
  classification, streaming SHA-256, Unicode NFC collision checks, exact path
  handling, and grouped metadata evidence;
- approval revalidation without approval-time rehashing;
- adoption transaction storage, startup recovery, exact rollback, and
  configuration-conflict handling;
- the Phase Four writable-root lease and external recursive-reset denial;
- the attachments-owned adoption workflow and exact fail-closed development
  qualification gate; and
- generic Settings cassette rendering and typed action dispatch.

Candidate verification remains read-only. Only adoption-owned authority can
persist `activeArchive`, and ordinary location persistence cannot construct or
accept that authority.

## Journal and parked-artifact isolation

The application has no relocation journal interface or implementation and no
runtime lookup for `.attachment_archive_relocations`, `current.json`,
`manifest.ndjson`, or `copy_receipts.ndjson`. Startup, Settings, adoption,
providers, and cleanup tasks cannot discover or execute the old mover.

Architecture tests prove this from repository source and disposable roots.
They do not open the real parked operation.

Historical operation `5c20c87a-c6d6-4489-8887-ae629301884f`, its journal,
operation directory, manifest, qualification evidence, and Toshiba staging
directory were not discovered, read, resumed, cancelled, migrated, changed,
or deleted.

## Capacity and privacy cleanup

Repository, app-native, Xcode dependency, and cached Swift/Objective-C privacy
searches found no remaining use of the Disk Space required-reason API after
the mover capacity method was removed. The app privacy manifest contained only
the mover's `E174.1` declaration and no unrelated declaration that needed to
remain. Dependency privacy-resource bundles are independent of that app
manifest.

The capacity contract, method-channel branch, Swift implementation and error
types, Dart decoding coverage, and focused native capacity test are therefore
removed. The now-empty app privacy manifest and its Xcode resource registration
are also removed.

## Settings, intents, and public seams

The legacy relocation Settings action provider is deleted. Existing typed
Settings intents and dispatcher branches remain adoption-only:

- **Use Existing Archive…**;
- **Choose Another Folder**;
- **Check Again**;
- **Use This Archive**; and
- **Cancel**.

No callable Move, destination, preflight, begin-relocation, copy, pause,
resume, finalization, or relocation-cancellation route remains. Production
provider/public seams do not export the deleted mover.

## Dependencies and generation

No package was proven mover-only, so no dependency was removed.
`unorm_dart` remains required by the candidate verifier's NFC collision
checks. `volume_controller` is an unrelated media dependency and is retained.
`flutter pub get --enforce-lockfile` completed successfully with no lockfile
change.

Riverpod code generation completed successfully. The only required generated
production adaptation is the location provider output after removal of its
relocation entry points.

## Test migration and architecture

Nine mover-only Dart test files are deleted:

- relocation authority and legacy-mover-unreachable architecture tests;
- relocation enablement, end-to-end, and workflow-provider tests;
- relocation filesystem and journal-store tests;
- relocation metadata-reader tests; and
- relocation Settings action-provider tests.

The native capacity test is removed from `RunnerTests.swift`. Relevant
invariants remain covered by candidate-verifier, approval-revalidation,
adoption transaction/recovery, Settings workflow, location, and writable-root
lease tests.

The old unreachable test is replaced with
`attachment_archive_legacy_mover_absence_test.dart`. It proves the production
files are physically absent, runtime source has no mover/journal/staging/copy/
finalizer/capacity/privacy symbols, and Settings has only adoption actions.
The adoption architecture test additionally proves that only adoption creates
active external configuration and ordinary persistence cannot accept a
relocation-style permit.

## Actual cleanup size

Measured from the Checkpoint Five commit, excluding release documentation:

- production: 3,769 lines removed, 16 lines added, net reduction 3,753 lines;
- tests: 2,259 lines removed and 229 lines added (including the new untracked
  124-line absence test), net reduction 2,030 lines;
- production files: 18 deleted and 9 adapted;
- test files: 9 deleted, 8 adapted, and 1 added.

The production reduction is larger than the directional design estimate
because complete mover composition, native support, and generated seams were
all removable without weakening shared safety code.

## Disposable acceptance and validation

The disposable Settings acceptance test uses a temporary admitted archive, an
in-memory overlay database, a manually constructed candidate copy, the real
filesystem verifier, typed Settings intents/dispatcher/resolver, and the real
adoption transaction. Its three scenarios prove:

1. a complete copy is reviewed;
2. a source change makes approval refuse and require **Check Again**;
3. an externally updated candidate verifies complete and is explicitly
   adopted;
4. the candidate becomes the active location and writable lease root;
5. source and candidate bytes remain unchanged and recursive reset is denied;
6. an injected transaction failure restores the previous location exactly;
7. candidate unavailability is reported without changing location; and
8. no legacy relocation directory is created.

Validation results:

- attachment-feature regressions: 321 passed;
- focused Settings disposable acceptance: 3 passed;
- complete architecture suite: 468 passed;
- complete repository suite: 2,507 passed, 1 intentional skip;
- `flutter analyze`: no issues;
- `git diff --check`: clean;
- dependency lockfile validation and Riverpod generation: passed.

The complete macOS XCTest suite reported 16 executed, 16 passed, and 0
failures against a fresh disposable development root. Xcode then reproduced
the known post-test result-bundle finalization stall and was interrupted after
the successful XCTest result, so the shell command ended with interruption
status 75. An earlier bootstrap attempt without the disposable development
marker exited before connecting to XCTest and ran no assertions; adding the
marker to that temporary root allowed the complete suite to execute.

No real archive, application database, bookmark setting, mounted external
archive, or parked relocation artifact was accessed by implementation or
validation.

## Remaining compatibility and debt

The old serialized value `read_only_until_verified_relocation` remains only as
a backward-compatible parser input and normalizes to adoption terminology when
persisted again. Historical implementation records and changelog entries keep
their relocation language as evidence. The separate onboarding Complete Erase
journal compatibility is unrelated to the attachment mover and remains intact.

The Xcode result-bundle finalization stall remains an infrastructure issue; it
did not prevent XCTest from reporting the complete passing native result.

No mandatory stop-and-report gate was encountered.

## Exact development-rehearsal starting point

After Checkpoint Six is reviewed and checkpointed, the next authorized work is
practical rather than another implementation phase:

1. manually copy the fresh MessageLensDevelopment `attachment_archive` to a
   new folder on Toshiba;
2. launch MessageLensDevelopment;
3. choose **Use Existing Archive…** and select that copy;
4. review verifier output; and
5. if the source changed during the manual copy, update the copy and choose
   **Check Again** before explicit adoption.

That rehearsal has not begun in this checkpoint.
