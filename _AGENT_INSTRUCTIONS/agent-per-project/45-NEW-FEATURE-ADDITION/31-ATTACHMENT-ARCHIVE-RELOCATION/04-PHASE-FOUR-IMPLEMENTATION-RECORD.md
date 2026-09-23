---
tier: project
scope: attachment-archive-relocation
owner: agent-per-project
last_reviewed: 2026-09-16
source_of_truth: implementation-record
links:
  - 00-ARCHITECTURE-AUDIT-AND-IMPLEMENTATION-PLAN.md
  - 01-PHASE-ONE-IMPLEMENTATION-RECORD.md
  - 02-PHASE-TWO-IMPLEMENTATION-RECORD.md
  - 03-PHASE-THREE-IMPLEMENTATION-RECORD.md
  - ../../25-ONBOARDING-AND-ARCHIVE/ATTACHMENT-PRESERVATION-INVARIANT.md
  - ../../25-ONBOARDING-AND-ARCHIVE/40-attachment-archive.md
---

# Attachment Archive Relocation: Phase Four Implementation Record

## Status and baseline

Phase Four implements generation-bound writable-root admission, typed deferred
ingestion and recovery, bounded reconnect eligibility, and interruption-safe
mutation boundaries. It is complete and intentionally unstaged for review.

Phase Three was committed locally on `feature/attachment-archive-relocation` as
`a49cf2b435d5ceb758895b9a99b759614ad15b09` with subject
`feat(attachments): make external archive reads availability aware`. That
commit remains the current `HEAD`; Phase Four has not been committed or pushed.

The shared-instructions submodule remained unchanged at
`95326f515ef4719f155ce6e223990398daad6311`.

## One mutation-authority model

Phase Four retires the temporary Phase Two `AttachmentArchiveMutationRoot` and
replaces it with `AttachmentArchiveWritableRootLease`. There are not two
overlapping root capabilities.

The lease has a private constructor in the location provider module and binds:

- the canonical resolved root;
- the location generation;
- the complete active location-configuration identity;
- internal or custom mode;
- whether destructive reset is permitted; and
- a private validator connected to the current location notifier.

Each issued lease also carries a private revocation token registered with the
issuing location notifier. Rebuilding or disposing that authority revokes its
leases even if an old notifier object still contains a cached state snapshot.

A path, remembered display path, bookmark string, filesystem writability bit,
or arbitrary location-state object cannot directly construct the lease. The
location provider is the sole issuer. Application mutation entry points obtain
or receive the lease; low-level filesystem repositories may receive its
canonical path only after orchestration has proved authority. The file-store
boundary accepts an injected lease-validation callback so long-running hash,
temporary-copy, verification, and install work can revalidate without turning
a raw path into permanent authority.

`ArchiveMutationCoordinator` remains the independent operation-level authority.
Ingestion and deterministic recovery enter the coordinator before taking their
location snapshot. MessageLens recovery may construct its runner first, but it
validates the captured lease after entering the coordinator. Filesystem writes
therefore require both the correct coordinator scope and a current writable
root lease.

The low-level file-store mutation methods require the validation callback;
omitting it is not an accepted API call. Tests may supply an explicit inert
callback when exercising the filesystem primitive in isolation, while all
production callers bind it to both the coordinator capability and lease.

## Admission and custom activation

The available default/internal root continues to receive a writable lease at
generation zero without bookmark resolution, directory creation, inventory,
or recursion. Its lease alone permits `attachmentClearing`.

A custom root receives a normal-write lease only when all of the following are
true:

1. its bookmark-backed configuration is the current active configuration;
2. native resolution positively classified the bookmark target as an existing,
   readable, writable, non-symlink directory;
3. location state is `customAvailable`;
4. the resolved canonical root and generation match; and
5. configuration carries the explicit `activeArchive` custom-write policy.

`AttachmentArchiveCustomWritePolicy` defaults to
`readOnlyUntilVerifiedRelocation`, including when older version-1 configuration
has no policy field. Folder selection always persists that conservative value.
Phase Four exposes no production operation that changes it to `activeArchive`.
This prevents selecting an arbitrary empty directory from becoming an unsafe
archive replacement. Phase Five may persist activation only after its copy and
verification transaction succeeds.

`customReadOnly`, unavailable, permission-denied, missing-directory, invalid,
and non-activated custom states return exact typed deferral reasons and never
fall back to the internal root or create a remembered external path.

## Validation and interruption semantics

Lease validation is O(1)-style work against the current cached location state;
it does not resolve every payload, inventory the archive, hash the root, or
traverse directories. The native bookmark resolution that produced
`customAvailable` already performed the real-directory, symlink, readability,
and writability checks.

Validation occurs at these boundaries as applicable:

- coordinated operation start;
- before archive-root creation;
- before source read and after source hashing;
- before temporary copy;
- after temporary copy and before payload verification;
- after verification and before atomic final installation;
- immediately after final installation; and
- immediately before overlay archive-metadata publication.

Generation, configuration identity, resolved root, availability, activation
policy, and destructive permission are compared each time. A disconnect or
identity change raises/returns a typed deferred reason. Temporary files are
removed by the existing installer. If authority changes immediately after the
atomic no-overwrite link, the valid payload may remain as a safe unclaimed
orphan, but overlay metadata is not published. A later idempotent retry can
reconcile it. Metadata never claims archival before successful installation
under valid authority.

Destination I/O failures are followed by another lease validation so an
observed disconnect becomes a deferral rather than a false corrupt/missing
conclusion. Donor/source failures under still-valid authority retain their
existing item-failure semantics.

## Ingestion and recovery deferral

Single ingestion returns `AttachmentArchiveIngestionOutcome`, including a
typed deferred status. Bulk/source-range/sweep operations return
`AttachmentArchiveResult` with a deferral reason and stop the current bounded
unit when authority is lost. A sweep deferred before or during work does not
advance past the deferred selection.

No persistent duplicate queue was added. The graph/source database already
identifies unarchived candidates, source-range ingestion covers new imports,
and the existing five-minute cursor sweep revisits delayed candidates. This
confirmed the audit assumption that reconnect can request bounded
reconsideration rather than enqueueing every attachment separately.

Deterministic recovery acquires its lease before validating or reading the
historical donor. It publishes `DeterministicRecoveryPhase.deferred` and a
typed reason if authority is unavailable or becomes stale. Its former direct
copy writer now delegates to the canonical content-addressed installer and
validates again before metadata reconciliation.

MessageLens recovery providers return a deferred batch runner instead of
failing construction when no lease is available. Batch results and individual
installation results carry typed deferral reasons. The installer validates at
operation start, throughout canonical installation, and before metadata
reconciliation.

## Reconnect behavior and destructive reset

The chat database monitor observes location-state edges. Only a transition
from non-writable to writable for an explicitly activated custom archive asks
the existing service for one bounded cursor sweep. Repeated events that resolve
to the same writable state do not schedule duplicate work, and the monitor and
service retain their existing in-flight guards. Reconnect does not run an
integrity check, full scan, recursive statistics, or synchronous UI work.

`clearArchive()` remains intentionally asymmetric. A default/internal lease
validates before recursive reset and again before clearing overlay archive
records. Every custom lease has `permitsDestructiveReset == false`, including
an activated writable custom archive. External retirement/deletion remains a
separately authorized later concern.

## Main files changed

Mutation authority, activation, and scheduling:

- `lib/features/attachments/domain/entities/attachment_archive_location_configuration.dart`
- `lib/features/attachments/domain/entities/attachment_archive_location_state.dart`
- `lib/features/attachments/application/attachment_archive_location_provider.dart`
- `lib/features/attachments/application/attachment_archive_reconnect_policy.dart`
- `lib/essentials/conversation_graph/application/monitor/chat_db_change_monitor_provider.dart`

Ingestion, clearing, and canonical filesystem boundaries:

- `lib/features/attachments/application/attachment_archive_service_provider.dart`
- `lib/features/attachments/application/archive_settings_provider.dart`
- `lib/features/attachments/application/attachment_archive_file_store.dart`
- `lib/features/attachments/infrastructure/repositories/filesystem_attachment_archive_file_store.dart`
- `lib/features/attachments/application/attachment_resolver_provider.dart`

Recovery:

- `lib/features/attachments/application/deterministic_recovery_provider.dart`
- `lib/features/attachments/application/deterministic_recovery_runtime_providers.dart`
- `lib/features/attachments/application/recovered_attachment_archive_writer.dart`
- `lib/features/attachments/infrastructure/repositories/overlay_recovered_attachment_archive_writer.dart`
- `lib/features/attachments/application/message_lens_attachment_recovery_batch_executor.dart`
- `lib/features/attachments/application/message_lens_attachment_recovery_batch_executor_provider.dart`
- `lib/features/attachments/application/message_lens_attachment_recovery_installer.dart`

The corresponding Riverpod outputs, architecture tripwires, focused tests,
`pubspec.yaml`, and `CHANGELOG.md` changed with those sources.

## Tests and validation

Provider/model generation:

```text
dart run build_runner build --delete-conflicting-outputs
```

Focused tests cover default and custom lease admission, every denial taxonomy,
custom activation gating, stale generation/configuration, raw-path construction
tripwires, normal internal and explicitly activated custom ingestion, typed
deferred ingestion/recovery, no internal fallback, internal/custom clear
asymmetry, reconnect deduplication, canonical recovery, and interruption before
source read, after hash, during temporary copy, before verification, before
atomic install, after install, and before metadata commit.

```text
flutter test <10 focused Phase Four and regression test files> \
  --reporter compact
```

Result: all 90 focused tests passed.

The 19-file Phase One/Two/Three attachment, location, read, resolver, evidence,
health, onboarding, settings, statistics, mutation, and adoption regression
matrix also passed:

```text
flutter test <19 focused Phase One/Two/Three regression files> \
  --reporter compact
```

Result: all 145 regression tests passed.

Architecture validation:

```text
flutter test test/architecture/forbidden_imports_test.dart --reporter compact
```

Result: all 388 architecture tests passed.

Full repository and static validation:

```text
flutter test --reporter expanded
flutter analyze
git diff --check
```

Result: the complete repository suite passed 2,350 tests with the existing one
intentional qualification-harness skip; analysis reported no issues; and the
diff check passed. The implementation-record links were validated locally.

No native files changed in Phase Four, so native tests were not required.

## Audit conformance and Phase Five starting point

The audit assumption about existing bounded retry sources was confirmed. One
implementation detail was stronger than the audit baseline implied: the legacy
deterministic recovery writer still owned a separate direct copy/hash path.
Phase Four removed that duplication and routed it through the canonical safe
installer rather than adding lease checks to a second installer.

No database schema or migration changed. No relocation journal, inventory,
capacity preflight, archive copy, copied-payload verification, staging root,
activation transaction, source-retention workflow, retirement/deletion, Move
Archive UI, or split-root checkpoint redesign was added.

Phase Five should start from the explicit custom activation gate. It can add a
resumable relocation journal and bounded inventory, preflight destination
capacity, copy and verify every preserved payload into a staging destination,
then atomically persist the verified custom configuration with
`activeArchive`. Only after activation verification may it address source
retention; source deletion remains separately authorized. The existing 39 GB
archive must remain untouched until that workflow is deliberately executed.

All implementation and tests used disposable temporary directories, test
fixtures, fake adapters, and in-memory/test databases. No user database or real
attachment archive was opened, scanned, copied, moved, created, reset, or
deleted.
