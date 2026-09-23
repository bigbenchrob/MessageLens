# Attachment Archive Relocation: Phase Five Implementation Record

## Status and baseline

Phase Five implements a disabled/internal relocation engine for safe,
resumable attachment-archive copy, complete verification, reversible
activation, and source retention. The implementation is complete against
disposable data and remains intentionally unstaged for review.

Phase Four was committed locally on `feature/attachment-archive-relocation` as
`0824de5bc1958e210e6612c78d9b10629334d786` with subject
`feat(attachments): add generation-bound archive write authority`. That commit
is the current `HEAD` and has not been pushed by this work.

The shared-instructions submodule remains unchanged at
`95326f515ef4719f155ce6e223990398daad6311`.

Phase Five has no production UI entry point. The internal Riverpod composition
is deliberately absent from the attachments public seam. Nothing in this phase
can initiate Rob's real archive relocation.

## State machine and progress

`AttachmentArchiveRelocationStage` is a versioned durable state machine with:

- `selected`;
- `preflighting` and `preflighted`;
- `inventorying` and `inventoryComplete`;
- `copying` and `verifying`;
- `destinationFinalizing` and `destinationFinalized`;
- `configurationSwitching` and `activated`;
- `rollbackRestoredOldConfiguration` and `sourceRetained`;
- `paused`, `cancelled`, and `failed`.

The explicit in-progress states close the crash windows before preflight,
inventory, final rename, and configuration persistence. Restart behavior is
driven by the persisted stage. Filesystem appearance alone never advances the
operation.

`AttachmentArchiveRelocationProgress` projects the durable phase, copied and
verified file/byte counts, expected totals, typed deferred reason,
resumability, activation status, and retained-source status. Reading progress
reads the journal only; it does not inventory or hash payloads.

## Journal format and location

The format is currently version 1. Operational state lives beneath the
admitted internal primary MessageLens root at:

```text
<primary-root>/.attachment_archive_relocations/
  current.json
  <operation-id>/
    journal.json
    manifest.ndjson
    copy_receipts.ndjson
```

`journal.json` is atomically replaced through a flushed `.pending` file. The
manifest and copy receipts are append-only, flushed NDJSON streams so one
object per physical payload is processed without materializing the archive or
all compatibility rows. The manifest's SHA-256 is persisted and rechecked by
the activation gate. The store scans journal headers cheaply when
`current.json` publication was interrupted and fails closed if it discovers
more than one unfinished operation.

The journal records the operation and admitted archive identities, canonical
source path and source location generation, source and previous
configuration, destination-parent bookmark and display metadata, managed
staging/final names, inventory timestamp and totals, manifest digest,
metadata-row and unreferenced-payload counts, copy/verification progress,
capacity evidence, intended activation configuration, activation/source
retention flags, resume stage, typed deferral, and failure evidence.

## Destination layout and preflight

The user-selected directory is a parent only. Each operation owns:

```text
<selected-parent>/.messagelens-attachment-relocation-<operation-id>/
<selected-parent>/MessageLens Attachment Archive <operation-id>/
```

The hidden child is staging. The visible managed child is the final archive.
Neither may replace an existing filesystem entry.

Preflight positively establishes that:

- source and destination parent are existing real directories, not symlinks;
- the resolved paths are neither equal nor nested in either direction;
- the destination is writable;
- the managed staging state is new or an unambiguous interrupted preflight;
- the final managed name is unused;
- a destination-local probe can create, stream, flush, hard-link without
  overwrite, and exclusively rename a directory;
- capacity reporting succeeds and is non-negative;
- the caller owns an exact `attachmentRelocation` mutation capability.

Only exact operation-owned probe and temporary-copy artifacts are cleaned.
The source and any unrelated destination entry are never removed.

The atomic payload installer uses Darwin `link(2)`. Finalization uses
`renamex_np(..., RENAME_EXCL)` on the same destination volume. A filesystem
that cannot demonstrate either semantic fails closed.

## Capacity and privacy decision

The native bridge reads Foundation
`URLResourceValues.volumeAvailableCapacityForImportantUsage` through
`URLResourceKey.volumeAvailableCapacityForImportantUsageKey`. This value is
appropriate for deciding whether an important user-data write may begin. The
copy requires physical source bytes plus the greater of five percent or one
GiB. Capacity is injected in Dart tests; no disk-filling test is used.

Apple classifies this as the Disk Space required-reason API category. The app
now bundles `PrivacyInfo.xcprivacy` with reason `E174.1`, which covers checking
available disk space before writing files. The manifest declares no collected
data and no tracking. This resource changes neither the bundle identifier,
entitlements, nor signing model.

Primary Apple references:

- https://developer.apple.com/documentation/foundation/urlresourcevalues/volumeavailablecapacityforimportantusage
- https://developer.apple.com/documentation/foundation/urlresourcekey/volumeavailablecapacityforimportantusagekey
- https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api
- https://developer.apple.com/documentation/bundleresources/privacy-manifest-files

## Inventory and preservation semantics

The metadata reader pages stable, grouped `archive_relative_path` results from
the overlay database. Duplicate compatibility rows therefore contribute one
physical manifest entry while their row count remains diagnostic evidence.
Conflicting size or non-null hash evidence fails closed.

The filesystem inventory streams every source entry without following links.
For metadata-known payloads it confirms the recorded physical size. It then
pages all metadata paths to prove every row group names a real regular file.
Known canonical content-addressed payloads without metadata are classified as
`unreferencedPreservationPayload` and preserved. Recognized canonical
installer temporaries are counted as operational debris but neither copied nor
deleted. Symlinks, special entries, traversal, missing metadata payloads,
unknown filenames, and size conflicts abort the operation rather than silently
dropping preservation data.

No attachment row, `archive_relative_path`, hash, content-addressed identity,
database schema, Drift migration, FTS schema, import schema, or graph schema is
changed.

## Copy, verification, and bounded work

Copy uses one manifest entry at a time and one-MiB chunks. Each source payload
is size-checked and SHA-256 hashed. A stored hash, when present, must match.
The payload is streamed to a same-directory temporary file, flushed, hashed,
and installed with atomic no-overwrite semantics. An existing partial file is
accepted only after exact size and hash equality. Each completed physical file
gets a durable ordered receipt before journal counts advance.

Resume reconciles receipt order and totals against the streamed manifest. A
receipt ahead of the JSON count repairs the count; a JSON count ahead of
durable receipts fails closed. Already receipted payloads are not recopied.

Final verification reacquires relocation mutation scope, revalidates the
authoritative source and destination bookmark, repeats the complete current
source inventory, and streams manifest and receipt pairs. Every source and
destination file must match expected path, size, receipt hash, and any stored
metadata hash. The final count and byte total must equal the journal. This
also covers null stored hashes and unreferenced payloads without writing
relocation-computed hashes back to metadata.

If verification itself is interrupted, the current conservative design
restarts the complete streaming verification. That repeats I/O but not memory
materialization and is required to prove that a source exposed across a
process gap has not changed. Copy receipts still prevent duplicate copy work.
A future optimization would require a stronger durable source-snapshot
primitive; trusting timestamps or an old per-file result would weaken the
activation proof.

All directory enumeration, SQLite paging, copy, hashing, manifest parsing,
receipt reconciliation, and verification are bounded/streaming. The engine
does not load a payload, a 39-GB archive, or all metadata rows into memory.

## Source stability and interruption

Every select, run, resume, and cancel action requires the shared archive
mutation coordinator's typed `attachmentRelocation` capability. The scope
excludes competing attachment and archive mutation for the complete admitted
run while ordinary UI/database reads remain available because this operation
does not block database reopen.

No process lock can survive termination, so every resumed run revalidates
source configuration/root/generation authority and destination bookmark
identity. The final source re-inventory plus complete source/destination hash
verification is the bounded reconciliation step that closes an offline gap.
Missing source or destination paths pause with distinct typed reasons.
Insufficient capacity and user-requested interruption are also resumable typed
pauses.

Pending relocation discovery is journal-only and is not wired into startup or
the production UI, so it does not block first usable UI.

## Finalization, activation, and rollback

After complete staging verification, the service durably enters
`destinationFinalizing` and performs destination-local exclusive rename. On a
restart in that state, exactly one of staging or final must exist. If final
exists, the service performs complete verification again; it never infers
success from the directory name.

The activation sequence is:

1. create/refresh a bookmark for the verified final managed directory;
2. build an intended `customExternal(activeArchive)` configuration;
3. persist `configurationSwitching` and the intended/previous configurations;
4. ask the internal activation gate for an unforgeable permit;
5. atomically persist through the existing settings abstraction;
6. resolve the new configuration through the normal location provider;
7. prove final-root canonical identity and complete manifest resolution;
8. prove Phase Four issues a valid generation-bound writable-root lease;
9. persist `activated`, then prove and record `sourceRetained`.

The gate issues a permit only for a `configurationSwitching` journal whose
manifest digest, expected/copy/verification totals, and ordered receipts are
complete. Ordinary configuration persistence rejects `activeArchive`, folder
selection produces read-only policy, the relocation provider is internal, and
the architecture tripwire proves the relocation service is the only code that
constructs an active custom configuration.

Any failure in the switching/validation transaction restores the previous
configuration through the same permit, republishes normal location state,
proves the old canonical source authoritative, and records
`rollbackRestoredOldConfiguration`. The verified destination and source both
remain intact. Tests inject failure before persistence, immediately after
persistence, and before writable-lease validation.

Successful Phase Five ends only at:

```text
verified new archive active + old source retained
```

There is no source-retirement or general deletion authority. Restore Default
also refuses to flip an active external archive back to internal without a
future reverse copy/verify/activate workflow.

## Files and tests

Production changes add the relocation domain/journal/progress model,
application contracts, service, activation gate, internal providers,
filesystem/journal/metadata repositories, Darwin exclusive finalizer,
capacity bridge, privacy manifest, Xcode resource registration, and the exact
relocation mutation operation. Location persistence is hardened around the
permit. Release metadata advances to `0.2.114+132`.

New or extended tests cover:

- journal JSON round-trip for every durable state, manifest/receipt streaming,
  future-version rejection, interrupted current-pointer recovery, and partial
  verification denial;
- grouped metadata deduplication, null/known hashes, conflicts, and stable
  paging;
- both unsafe nesting directions, symlink/conflicting roots, required
  filesystem semantics, deliberately weak no-overwrite semantics, known and
  unreferenced inventory, recognized debris, unknown/symlink/mismatch failure,
  verified partial reuse, conflicting partials, missing/size/hash failures,
  and traversal rejection;
- disposable interruption/resume, capacity deferral, cancellation,
  source/destination disconnect, verified activation, writable-lease
  transition, unchanged metadata, byte-for-byte source retention, and
  rollback at three activation boundaries;
- unverified and partially verified activation denial plus architecture
  enforcement of the private activation path;
- method-channel capacity decoding/failure and native Foundation capacity.

## Validation

Code generation:

```text
dart run build_runner build --delete-conflicting-outputs
```

Result: completed successfully. Only Phase Five's relocation provider and the
intentionally changed location provider generated artifacts remain in the
diff; one unrelated regenerated hash was restored to `HEAD`.

Focused Phase Five tests:

```text
flutter test <six relocation, filesystem, journal, metadata, adapter, and
architecture test files> --reporter expanded
```

Result: all 33 focused tests passed.

Phase One-Four attachment/location regression matrix:

```text
flutter test <23 Phase One-Four regression test files> --reporter compact
```

Result: all 182 regression tests passed.

Architecture tripwires:

```text
flutter test test/architecture/attachment_archive_relocation_authority_test.dart \
  test/architecture/forbidden_imports_test.dart --reporter silent
```

Result: all relocation authority tests and all 388 repository architecture
tripwires passed.

Native validation:

```text
env MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT=/private/tmp/messagelens-phase-five-native-tests-20260917 \
  xcodebuild test -workspace macos/Runner.xcworkspace -scheme Runner \
  -configuration Debug -destination 'platform=macOS' \
  -parallel-testing-enabled NO \
  -only-testing:RunnerTests/RunnerTests/testAttachmentArchiveImportantUsageCapacityIsAvailable
```

Result: the focused native capacity test passed and Xcode reported
`** TEST SUCCEEDED **`. A preceding full native run reported all 17 native
tests passed but Xcode stalled while finalizing its result bundle; that runner
was interrupted after the successful test results and the focused clean-exit
run was used for the definitive capacity result.

Complete repository validation:

```text
flutter test --reporter expanded
flutter analyze
git diff --check
```

At the time this record was written, the complete suite passed 2,379 tests
with the existing one intentional skip. Final analysis and diff/link checks
are recorded after the final diff review.

The disposable end-to-end acceptance exercise used two independently created
temporary roots, an in-memory overlay database, four unique physical payloads,
duplicate compatibility rows for one path, stored and null hashes, an
unreferenced canonical payload, and a nested valid payload. It interrupted
after two verified copies, reconstructed the service, resumed, finalized,
activated, resolved the new root, obtained a writable lease, compared every
source/destination byte, proved all metadata rows unchanged, and separately
proved rollback with both copies retained.

No production database or real attachment archive was opened, scanned,
inventoried, hashed, copied, moved, created, reset, modified, or deleted. All
filesystem exercise used disposable temporary roots.

## Gates, audit conformance, and remaining work

No stop-and-report gate A-M was encountered. The capacity/privacy and
filesystem-semantics questions were resolved before making those operations
part of the engine. No architecture-audit assumption was disproved. The
source-stability implementation makes the audit's reconciliation requirement
concrete through full final inventory and hash verification.

Phase Six should begin by designing the production Settings workflow around
the typed progress/journal API without adding a direct configuration shortcut.
It must include explicit destination selection, preflight disclosure,
pause/resume/cancel behavior, unavailable-volume recovery, and retained-source
review. Production enablement should remain gated on a reviewed acceptance
matrix. Source retirement, deletion/reclamation, and reverse restore-default
relocation remain separately authorized Phase Seven work.
