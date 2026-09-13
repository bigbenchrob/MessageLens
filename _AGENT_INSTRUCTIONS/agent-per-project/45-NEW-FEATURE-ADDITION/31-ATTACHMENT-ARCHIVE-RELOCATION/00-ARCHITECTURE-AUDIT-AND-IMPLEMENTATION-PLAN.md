---
tier: project
scope: attachment-archive-relocation
owner: agent-per-project
last_reviewed: 2026-09-13
source_of_truth: audit
links:
  - ../../25-ONBOARDING-AND-ARCHIVE/ATTACHMENT-PRESERVATION-INVARIANT.md
  - ../../25-ONBOARDING-AND-ARCHIVE/40-attachment-archive.md
  - ../../25-ONBOARDING-AND-ARCHIVE/70-attachments-end-to-end.md
  - ../../10-DATABASES/07-overlay-database-independence.md
---

# Attachment Archive Relocation: Architecture Audit and Implementation Plan

## Status

Audit and implementation planning complete. No production code, database
schema, migration, application behaviour, user database, or attachment payload
was changed during this work.

Baseline inspected:

- branch: `feature/attachment-archive-relocation`;
- commit: `c2f546dc99eb50c66233ef94ddb0e70c7d77990e`;
- audit date: 2026-09-13;
- macOS deployment target: 12.0 for the Flutter application configurations;
- distribution model: non-sandboxed macOS application.

This document is a design constraint for later implementation. It does not
authorize a schema change, a live archive move, deletion of an old archive, or
any mutation of tester data.

## Executive summary

The attachment archive can be made relocatable without migrating attachment
rows or changing the FTS, graph, import, or overlay schemas. The decisive
finding is that `archived_attachments.archive_relative_path` is already stored
relative to the archive root. Absolute archive paths are assembled at runtime
from that relative path and the currently injected root. The archive's present
location is therefore an application-wiring constraint, not a persisted-data
constraint.

The recommended architecture is to leave `ArchiveAccessAuthority` responsible
for the admitted primary MessageLens data root and introduce a separate,
attachment-owned location boundary. That boundary resolves either the current
internal directory or a user-selected external directory and exposes a typed
availability state. It must never silently substitute another root when the
configured external volume is unavailable.

Message lists, message text search, graph queries, and ordinary startup can
remain usable without the payload volume. Attachment resolution, archive
writes, integrity checks, and recovery must first distinguish an unavailable
archive root from a known missing or corrupt file. No recursive archive scan
belongs on startup, search, or ordinary browsing paths.

Moving an existing archive must be a resumable
`select -> preflight -> copy -> verify -> activate -> retain source` operation.
The source stays intact throughout relocation. Removing it is a later,
separately authorized operation. Current content hashes, sizes, compatibility
keys, path-boundary checks, mutation coordination, settings persistence, and
settings presentation can be reused. A location model, macOS bookmark and
volume-event adapter, relocation journal/engine, and typed root-availability
semantics are genuinely new.

The largest architectural risk is not path migration. It is preservation
coverage: production checkpoint/adoption code currently treats
`attachment_archive` as part of the primary data root. Externalizing the
payload directory changes what a whole-root checkpoint protects and must be
made explicit before the relocation feature is released.

## Audit scope and terminology

This document uses the following terms consistently:

- **primary data root**: the admitted MessageLens Application Support root that
  owns databases, markers, locks, and application state;
- **attachment archive root**: the directory against which
  `archive_relative_path` is resolved;
- **default/internal archive**: the current `attachment_archive` child of the
  primary data root;
- **custom/external archive**: an archive root selected by the user outside the
  primary data root, normally on an external volume;
- **archive unavailable**: the configured root cannot presently be resolved or
  accessed, so the state of individual payloads cannot be determined;
- **payload missing**: the archive root is available, but a database-known
  relative path has no regular file;
- **payload corrupt**: the root and file are available, but verified size or
  content does not match authoritative metadata;
- **activation**: committing the new configured archive root after the
  destination has passed verification;
- **retirement**: a later, separately authorized deletion of the old archive.

The audit traced actual provider construction, read and write stores, recovery,
health, onboarding, checkpoint/adoption, settings, render, thumbnail, native
macOS, and test code. It did not open or inspect a user database or payload
archive.

## 1. Current architecture

### 1.1 Primary root and archive-root derivation

`ArchiveAccessAuthority` in
`lib/essentials/archive_environment/domain/archive_access_authority.dart`
represents the admitted primary data root. Its `resolvePath()` method accepts
only bounded relative paths and rejects absolute or escaping paths.

The current physical archive source of truth is
`attachmentArchiveDirectoryProvider`, implemented as
`attachmentArchiveDirectory()` in
`lib/essentials/db/feature_level_providers/persistent_database_providers.dart`.
It resolves the literal child `attachment_archive` through
`archiveAccessAuthorityProvider` and returns a synchronous `String`.

That placement makes the archive look like a database-owned path even though
the payload repository is an attachment feature. More importantly, it makes an
external attachment-only location impossible without either broadening the
primary-root authority or replacing this provider.

`ArchiveAccessAuthority` must not be stretched to admit an unrelated external
root. It is used for database and lock identity, so doing that would either move
latency-sensitive stores with the payloads or give primary-root consumers
authority over the external directory.

### 1.2 Development and production roots

Production uses the Application Support directory for bundle identity
`com.bigbenchsoftware.MessageLens`. Development normally uses the development
root described in `01-PROJECT/03-data-locations.md`. The development-only
`MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT` override can place the entire admitted
root on another volume.

The existing development override proves that MessageLens databases and files
can run from external storage. It does not provide attachment-only
configuration, disconnected-volume semantics, persistent user selection, or a
safe relocation workflow. It must not be reused as the production preference.

### 1.3 Archive writes

The main orchestration boundary is `AttachmentArchiveService` in
`lib/features/attachments/application/attachment_archive_service_provider.dart`.
It uses `ArchiveMutationOperation.attachmentReconciliation`, obtains the
current archive root for each operation, and coordinates:

- source-range ingestion following graph synchronization;
- a bounded periodic sweep;
- on-demand ingestion requested by attachment resolution;
- manual archive-all processing; and
- integrity verification.

`FilesystemAttachmentArchiveFileStore` in
`lib/features/attachments/infrastructure/repositories/filesystem_attachment_archive_file_store.dart`
is the canonical payload installer. It:

- rejects a symlink archive root;
- requires a regular source file;
- hashes the source;
- writes and flushes a temporary file beside the destination;
- re-hashes the temporary copy;
- installs without overwriting an existing payload using POSIX `link(2)`; and
- returns typed installed, already-present, conflict, changed-donor, and
  verification-failure outcomes.

Creating the temporary file in the destination directory is important: the
final installation is same-filesystem even when the archive is external. A
destination preflight must nevertheless prove that the selected filesystem
supports the required file and atomicity semantics.

`OverlayAttachmentArchiveWriteStore` persists the compatibility record after a
successful file install. It stores the relative path, not the injected root.

`OverlayRecoveredAttachmentArchiveWriter` is an older direct-copy path. It
reads and writes payload bytes itself and then writes overlay metadata instead
of using the canonical no-overwrite installer. New MessageLens recovery uses
`MessageLensAttachmentRecoveryInstaller`, but the older writer remains an
important coupling: it must be migrated to the canonical root-aware installer
or proven unreachable before activation of custom roots.

### 1.4 Archive reads and presentation

`OverlayAttachmentArchiveReadStore` receives the root through
`attachmentArchiveReadStoreProvider`. It reads an overlay row, combines the
root with `archive_relative_path`, bounds the result to the root, and reports an
absolute runtime path and whether a regular file exists.

`OverlayArchiveCompatibilityLookup` performs the same root-relative lookup for
graph/chat-summary integration. `SqliteChatSummaryRepository` carries the
result through `GraphAttachmentArchiveRecord.archiveAbsolutePath` into message
evidence. `MessageAttachmentEvidence` prefers an available archived path,
otherwise applies live-path and recovery policy.

`attachmentResolverProvider` is the feature-level display boundary. In
archive-enabled mode it reads the overlay record, returns an archived path when
the file exists, or may trigger on-demand ingestion from the live Messages
file. Presentation reaches `dart:io File` only after this resolution, through
`AttachmentFileAccess` and the attachment render widgets.

The providers already inject an archive directory into most repositories. This
is the natural seam for a configurable root, but the seam must become
availability-aware instead of passing an unconditional `String`.

### 1.5 Background ingestion and recovery

The live Messages monitor begins after the UI is available. It polls for source
changes every 15 seconds and runs its bounded attachment sweep on a five-minute
cadence. A successful incremental graph update requests source-range attachment
archiving. This work is not required before the first Flutter frame.

The MessageLens recovery pipeline already injects the current archive root into
`MessageLensAttachmentRecoveryInstaller` and
`MessageLensAttachmentRecoveryBatchExecutor`. Historical/donor archive readers
such as `MessageLensAttachmentPayloadInspector` and
`MessageLensHistoricalArchivePreflightService` intentionally expect a donor
package to contain an `attachment_archive` child. That is a donor-format
contract, not proof that the active archive must remain under the primary root.

### 1.6 Startup, onboarding, and health

The installation evidence reader and installation-state validator inspect the
required databases and schema evidence. They do not require the attachment
payload directory for a healthy startup. A disconnected external archive
therefore need not become an onboarding or startup gate.

`OnboardingEnvironmentReportProvider` probes the current attachment directory
for existence/readability and includes that evidence in diagnostics, but
onboarding readiness does not depend on it. The environment-readiness surface
currently has only generic exists/readable facts and would not explain an
intentionally disconnected external location.

`GraphHealthRepository.readHealthReport()` reads attachment metadata normally,
but physical payload checks are opt-in through `includeFileAudits` or
`includeRecoveryAudit`. This is the correct default. When an explicit file audit
is requested, it must first obtain root availability and report a deferred or
unavailable audit instead of converting all rows into missing-file failures.

### 1.7 Checkpoint, adoption, and reset

`FileSystemArchiveCheckpointService` inventories, copies, and hashes every file
under the admitted primary root. Because the archive is currently a child of
that root, the payloads are implicitly covered. Once external, they are no
longer part of that checkpoint unless the checkpoint contract is extended with
a second, explicit preservation source.

Production archive adoption and its tests likewise model
`attachment_archive` beneath an adopted root. Historical donor packages may
continue to use that layout, but adopting a primary data root and selecting the
active external payload root must become separate decisions.

`StartFreshArtifactPolicy` explicitly marks `attachment_archive` as preserved,
and architecture tests prohibit ordinary reset paths from deleting it. The
semantic preservation rule remains correct. Later implementation must detach
that rule from a fixed physical child path and ensure reset services acquire no
authority to remove a configured external archive.

## 2. Path/reference model

### 2.1 Persisted overlay record

`ArchivedAttachments` in
`lib/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart`
contains:

| Column | Meaning | Location-dependent? |
| --- | --- | --- |
| `message_guid` | Parent message side of the compatibility key | No |
| `import_attachment_id` | Source `chat.db` attachment ROWID | No |
| `archive_relative_path` | Path below the attachment archive root | No |
| `archived_at_utc` | Audit timestamp | No |
| `file_size_bytes` | Verified payload size | No |
| `content_hash` | Nullable SHA-256 digest and content-addressed filename | No |
| `provenance` | Archive or historical-import origin | No |
| `original_local_path` | Original Apple Messages path for audit | Yes, but it is not archive identity |

The unique key is `(message_guid, import_attachment_id)`. Multiple compatibility
records may legitimately refer to the same content-addressed relative path.
Relocation verification must therefore compare unique relative payload paths,
not overlay row count, when determining physical file count.

### 2.2 Runtime absolute paths

The following absolute paths are runtime transport/display values, not
persisted archive identity:

- `AttachmentArchiveLookupRecord.archiveAbsolutePath`;
- `GraphAttachmentArchiveRecord.archiveAbsolutePath`;
- `ResolvedAttachment.resolvedFilePath`;
- chat-summary attachment `archiveAbsolutePath`; and
- message presentation's final display path.

`ResolvedAttachment` equality includes its runtime resolved path. Switching
roots or reconnecting a volume must therefore invalidate resolver and
attachment-bearing view-model providers; otherwise cached objects can retain a
valid-looking path belonging to the old location.

### 2.3 Source paths and donor paths

Graph attachment `filename`/`local_path` values and
`original_local_path` are volatile Apple source paths. They are recovery and
audit evidence, not archive references. Donor roots use a conventional
`attachment_archive` child because that is part of the donor package format.
Neither requires the active archive root to share the primary data root.

### 2.4 Equality, hashes, indexes, and caches

Payload deduplication is content-addressed. The content hash and derived
relative path remain stable across relocation. No database index contains the
absolute archive root.

`VideoThumbnailCacheService` is an exception at the derived-cache layer. Its
cache key includes the normalized absolute video path, size, modification time,
and requested dimensions. Relocating the source therefore causes cache misses
and may leave redundant thumbnails, but it does not damage attachment identity.
The thumbnail cache itself is correctly kept inside
`derived_media/video_thumbnails` below the primary root. A later optimization
may key archived-video thumbnails by content hash or archive-relative identity,
but that is not required for safe relocation.

### 2.5 Path-migration conclusion

No row migration, lazy path rewrite, or backward-compatibility column is
required. Existing records are already location-independent. Later work should
add a configuration value and change root resolution only. Any proposal to
rewrite `archive_relative_path` to an absolute path would regress the current
architecture.

## 3. Coupling inventory

| Area | Current assumption/coupling | Required disposition |
| --- | --- | --- |
| Primary provider | `attachmentArchiveDirectoryProvider` always resolves a child of `ArchiveAccessAuthority` | Replace at the attachment feature seam; retain primary authority for default-root derivation only |
| Runtime providers | `attachment_archive_runtime_providers.dart` consumes a synchronous path | Make location resolution asynchronous/typed without putting it on first-frame or search paths |
| Store providers | `attachment_archive_store_providers.dart` injects one unconditional root | Inject an available root lease or return root-unavailable outcomes |
| Graph archive providers | `graph_attachment_archive_providers.dart` injects the same root | Route through the new attachment location boundary |
| Archive service | Assumes a root can be ensured before writes | Require available+writable admission; never create at an unresolved custom mount path |
| Read store | File absence is represented by `archiveFileExists == false` | Distinguish unavailable root, absent record, missing file, and available file |
| Resolver | Existing availability enum has no archive-unavailable case | Add a root-specific reason/state and preserve live-source policy intentionally |
| Chat summaries | Runtime absolute paths are hydrated and may be statted per attachment | Resolve lazily and invalidate when the root generation changes |
| Stats | Recursively lists every regular file to calculate bytes | Remove from normal location/status probes; cache or compute only on explicit demand |
| Integrity | Explicit audits can classify inaccessible files as missing | Short-circuit with `archiveUnavailable`; never emit per-file corruption conclusions without an accessible root |
| Onboarding report | Probes a fixed child directory | Report configured location state but do not make it installation readiness |
| Startup validation | Correctly validates databases rather than payload directory | Keep unchanged in principle; no custom-root resolution before `runApp` |
| Checkpoint | Whole-root inventory implicitly includes internal payloads | Define explicit external-archive coverage or truthful exclusion before release |
| Production adoption | Test fixtures and services expect the payload child in the donor/adopted root | Preserve donor-format interpretation; separate it from active-root selection |
| Start Fresh | Policy identifies `attachment_archive` as a preserved primary-root child | Preserve the semantic invariant while removing physical-path authority |
| Historical recovery | Donor readers append `attachment_archive` to donor root | Keep as donor-format contract; destination still comes from active-root resolver |
| Legacy recovered writer | Copies directly to injected directory | Migrate/retire before enabling a custom root |
| Export helper | Recursively copies the directory without resumable verification | Do not use for relocation |
| Clear archive | Deletes the current directory and overlay records under checkpoint-gated mutation | Do not extend to external retirement; a distinct, explicitly authorized design is required |
| Thumbnail cache | Absolute input path is part of derived cache key | Accept initial cache misses; consider content identity later |
| Settings | Attachment cassette payload exists, but the normal settings menu exposes no attachment-archive action | Extend the spec/resolver/payload/rendering system rather than adding widget-local callbacks |
| Folder choice | Historical archive chooser returns a raw selected path using `file_selector` | Generalize for destination selection; add native bookmark persistence separately |
| Native layer | Development root claim handles only a whole-root environment override | Do not repurpose it; add a narrow attachment-location bridge |
| Tests/tripwires | Many fixtures hard-code `root/attachment_archive` | Retain default-root cases and add custom/unavailable cases; update only assumptions about the active root |

Direct-root architecture tripwires in
`test/architecture/forbidden_imports_test.dart` are useful. Later work should
tighten them so feature consumers cannot reconstruct a root from
`ArchiveAccessAuthority` or a literal `attachment_archive` path outside the
single location resolver.

## 4. macOS access findings

### 4.1 Current security model

Both `macos/Runner/DebugProfile.entitlements` and
`macos/Runner/Release.entitlements` set `com.apple.security.app-sandbox` to
false. The repository has no user-selected file entitlement and no existing
security-scoped bookmark or `startAccessingSecurityScopedResource()` lifecycle.

Current directory selection uses the `file_selector` package. For example,
`FileSelectorHistoricalArchiveFolderChooser` calls
`getDirectoryPathWithOptions()` and returns the raw selected path. That is
reusable for the selection UI but not sufficient identity for a removable
volume across rename and mount-path change.

Full Disk Access is needed for protected Apple Messages source data. It does not
provide stable identity for, or replace access selection of, a user-chosen
external archive.

### 4.2 Bookmark recommendation

Because the current application is not sandboxed, a security-scoped bookmark
is not required for persistent access today. The app should nevertheless store
a normal Foundation URL bookmark as the durable external-location identity,
plus a last-known path for display and diagnostics. Bookmark resolution should
be authoritative; the raw path must not silently override a failed bookmark or
redirect the archive to an unrelated directory.

If MessageLens becomes sandboxed later, the same native abstraction can evolve
to create a security-scoped bookmark and hold a balanced access lease around
filesystem operations. That later change would also require the
`com.apple.security.files.user-selected.read-write` entitlement. Apple documents
the entitlement at
<https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.security.files.user-selected.read-write>
and security-scoped bookmark access at
<https://developer.apple.com/documentation/professional-video-applications/enabling-security-scoped-bookmark-and-url-access>.

The versioned configuration should be stored through the existing overlay
settings abstraction as one logical record containing:

- mode (`defaultInternal` or `customExternal`);
- bookmark bytes encoded for storage;
- last-known path;
- configuration version; and
- optional display metadata such as volume name.

This is machine-specific configuration even though it resides in the local
overlay settings database. Restoring that database on another Mac may yield an
unresolvable bookmark. The correct result is a custom-archive-unavailable state
and a request to locate the archive, never silent fallback to the internal
directory.

### 4.3 Disconnect, reconnect, and rename

The repository contains no existing mount-event bridge. A new macOS adapter is
therefore justified. It should observe `NSWorkspace`'s workspace notification
center for mount, unmount, and volume-rename notifications, then notify Dart to
re-resolve the bookmark and publish a new location generation. Relevant Apple
references are:

- <https://developer.apple.com/documentation/appkit/nsworkspace/didmountnotification>;
- <https://developer.apple.com/documentation/appkit/nsworkspace/didunmountnotification>;
- <https://developer.apple.com/documentation/appkit/nsworkspace/didrenamevolumenotification>.

Application activation can perform a cheap re-resolution as a fallback. No
recursive payload scan or fixed high-frequency polling is required.

Bookmark resolution may identify a renamed or remounted volume when it is
available. While disconnected it can fail; that failure is expected state, not
configuration corruption. Deprecated file-ID preference flags should not be
used as a substitute for current URL bookmark behaviour.

### 4.4 Capacity and privacy declarations

Destination preflight should ask the selected volume for capacity suitable for
important usage and compare it with the source archive's physical byte total
plus a conservative margin. Apple's relevant URL resource key is documented at
<https://developer.apple.com/documentation/foundation/urlresourcekey/volumeavailablecapacityforimportantusagekey>.

Use of that API must be checked against Apple's current required-reason/privacy
manifest rules during implementation. The app currently has no app-owned
`PrivacyInfo.xcprivacy`, so the implementation phase must not add the API
without also completing that declaration analysis.

## 5. Failure-state analysis

### 5.1 Current behaviour

Today the archive path cannot be configured independently. If its directory
disappears while the databases remain:

- installation validation can still succeed;
- message text and graph data remain queryable;
- the stats reader reports zero physical bytes when the root is absent;
- archive lookups reduce a database-known payload to
  `archiveFileExists == false`;
- the attachment resolver may classify the item as awaiting recovery or fall
  through to live-source policy;
- an explicit integrity audit can report many or all files as missing;
- cached runtime absolute paths may remain in existing view models;
- no mount/unmount event invalidates those values; and
- a writer that ensures the configured directory could attempt to create it.

The last point is dangerous for removable volumes. A missing `/Volumes/...`
path must not be interpreted as permission to create a replacement directory
on another filesystem or under an unexpected mount state.

### 5.2 Required root-level state

The distinction belongs in the attachment application/domain boundary, before
repositories perform per-file interpretation. A suggested root-state model is:

| State | Meaning | Read policy | Write policy |
| --- | --- | --- | --- |
| `defaultAvailable` | Internal root resolved and accessible | Normal | Normal |
| `customAvailable` | Bookmark resolved; directory is readable and writable | Normal | Normal |
| `customReadOnly` | Bookmark resolved; directory readable but not writable | Normal | Reject/defer with actionable status |
| `customUnavailable` | Volume/bookmark cannot currently resolve | Do not inspect individual files | Reject/defer; never create root |
| `permissionDenied` | Location resolves but access is denied | Do not classify files | Reject; prompt for renewed selection/access |
| `configuredDirectoryMissing` | Correct volume is available but selected archive directory is absent | Do not call every payload missing | Reject; offer Locate/repair workflow |
| `configurationInvalid` | Stored configuration cannot be decoded or violates path policy | Fail closed | Reject; require user correction |

The exact enum names may change during implementation, but these semantics must
remain distinct. Availability should carry the resolved root only in states
that have positively established it. Writers should receive an explicit
available+writable lease rather than a nullable or last-known string.

Per-file lookup can then distinguish:

1. no metadata record;
2. root unavailable, so file state is unknown;
3. root available and regular file present;
4. root available and path absent;
5. root available but entry is the wrong filesystem type; and
6. root available but size/hash verification failed.

### 5.3 Required scenario behaviour

| Scenario | Required behaviour |
| --- | --- |
| Drive absent at launch | Render normal message/search UI; publish archive unavailable; do not scan, repair, create, or gate startup |
| Drive disconnected while running | Invalidate the location generation; stop new archive writes safely; existing file loads may fail gracefully; do not mark payloads missing |
| Drive reconnected while app remains open | Re-resolve bookmark on mount event; republish availability; invalidate attachment resolution; resume eligible deferred ingestion |
| Configured directory deleted on an available volume | Report configured directory missing; require Locate, Restore, or explicit re-creation workflow; do not infer payload deletion record-by-record |
| Volume mounts under a changed path or is renamed | Resolve bookmark to the new URL and refresh the last-known display path |
| Filesystem permission revoked | Report permission denied; keep messages/search available; allow user to reselect the directory |
| One payload absent on an accessible archive | Report that payload missing and retain recovery metadata; do not degrade the whole root |
| Archive readable but not writable | Display archived files normally; pause/reject ingestion and relocation activation with a clear read-only status |
| Destination lacks space during copy | Stop before activation, retain source and resumable partial destination, report required/available space |

No unavailable-root state should trigger Start Fresh, onboarding recovery,
database remediation, row deletion, archive cleanup, or a switch to an empty
internal archive.

## 6. Reuse inventory

### 6.1 Reuse unchanged in principle

- `ArchivedAttachments` compatibility key, relative path, size, hash, and
  provenance model;
- `ArchiveCompatibilityKey` for mapping message/attachment records;
- `FilesystemAttachmentArchiveFileStore`'s bounded, verified, no-overwrite
  destination installation algorithm;
- `OverlayAttachmentArchiveWriteStore` relative-path persistence;
- `AttachmentArchiveFileStore`, `AttachmentArchiveReadStore`, and
  `AttachmentArchiveWriteStore` interfaces as conceptual seams;
- `ArchiveMutationCoordinator` serialization and denial model;
- current database/opening providers and `ArchiveAccessAuthority` for the
  primary root;
- `AttachmentFileAccess` as the final filesystem boundary;
- existing logger, support-bundle, and notification infrastructure; and
- the spec/resolver/payload/rendering architecture for settings surfaces.

### 6.2 Extend rather than replace

- `OverlayAttachmentArchiveSettingsStore`: persist one versioned location
  record in the existing key-value store;
- attachment runtime/store providers: consume typed location state;
- `OverlayAttachmentArchiveReadStore` and graph lookup: return root-unavailable
  separately from missing-file evidence;
- `AttachmentArchiveService`: require a writable location lease and publish
  deferred status rather than ensuring an unresolved custom root;
- `AttachmentResolver`/`ResolvedAttachment`: carry archive-unavailable meaning
  through presentation;
- `GraphHealthRepository` and onboarding diagnostics: report location status
  without manufacturing corruption findings;
- `ArchiveMutationOperation`: add a relocation operation and, only if later
  approved, a distinct old-location-retirement operation;
- `FileSelectorHistoricalArchiveFolderChooser`: generalize its directory
  selection capability behind an attachment-specific interface;
- attachment settings cassette/coordinator/resolver/payload/rendering types:
  expose current location, status, and typed actions;
- production checkpoint/adoption documentation and services: represent the
  external preservation component truthfully; and
- architecture tests: enforce single-source root resolution and preserve reset
  prohibitions.

### 6.3 Do not reuse for relocation

- `FilesystemAttachmentArchiveFileOperations.exportArchiveDirectory()` is an
  unverified recursive copy without a resumable journal or transactional
  switch;
- `resetArchiveDirectory()` is destructive and coupled to clearing overlay
  records;
- the whole-development-root environment override is not a user preference;
- donor package `attachment_archive` path derivation is not the active-root
  resolver; and
- the stats repository's recursive scan is not an availability monitor.

### 6.4 Genuinely new components

The audit found no existing implementation for the following, so new narrow
components are justified:

- immutable `AttachmentArchiveLocationConfiguration` and typed
  `AttachmentArchiveLocationState` models;
- attachment-owned location repository/controller and provider generation;
- a macOS URL-bookmark adapter and volume-event stream;
- a writable-root admission/lease abstraction;
- a resumable relocation journal and copy/verification engine;
- relocation progress and outcome models; and
- explicit archive-unavailable presentation semantics.

These components should remain inside the attachment feature except for the
narrow native bridge and any cross-cutting mutation/checkpoint contract.

## 7. Recommended architecture

### 7.1 Ownership boundaries

The desired dependency direction is:

```text
ArchiveAccessAuthority (primary root)
               |
               | derives default location only
               v
AttachmentArchiveLocationController <--- overlay location setting
               ^
               |
        macOS bookmark adapter
               |
               v
AttachmentArchiveLocationState / writable lease
               |
     +---------+----------+----------------+
     |                    |                |
 read/lookup stores   archive service   relocation engine
     |                    |                |
 resolver/evidence    file installer   progress + activation
     |
 presentation
```

`attachmentArchiveDirectoryProvider` should cease being a public physical-path
source from the database layer. During migration it may temporarily delegate to
the new controller for compatibility, but new consumers must depend on the
attachment-owned location state or an operation-specific lease.

### 7.2 Configuration and resolution

Use a single versioned configuration record in overlay settings. The default
configuration contains no external bookmark and derives its root from
`ArchiveAccessAuthority.resolvePath('attachment_archive')`. A custom
configuration contains the bookmark and last-known display metadata.

Location resolution should be lazy. It may await overlay settings and native
bookmark resolution when an attachment feature is needed, but it must not be
awaited before `runApp`, by installation classification, or by message-text
search providers.

The controller publishes a monotonically changing location generation. Mount,
unmount, rename, configuration change, and access renewal update that
generation. Consumers whose values contain absolute paths key themselves to or
invalidate on the generation.

### 7.3 Read and write contracts

Read operations should receive a snapshot that says either:

- the root is available and contains a canonical resolved path; or
- the root is unavailable with a typed reason.

Write operations require the stronger available+writable lease. The lease must
capture the resolved location identity/generation so a mid-operation unmount or
configuration switch becomes a controlled failure. It must never be constructed
from the last-known path alone.

File repositories retain path-boundary and no-symlink checks after root
resolution. An available custom root must itself be a real directory rather
than a symlink. Relative payload paths must remain bounded below it.

### 7.4 Availability and recovery

The app should subscribe to the native volume-event stream only after normal
startup. On a relevant event it cheaply re-resolves the configured bookmark.
When a root returns:

1. publish available/read-only status;
2. invalidate archived attachment lookup/resolver providers;
3. refresh visible attachment-bearing views;
4. resume bounded ingestion that was deferred solely because the root was
   unavailable; and
5. do not automatically start a full integrity scan.

When a root disappears, new writes are rejected or paused. Existing database
reads and text search continue. A file open that races with disconnection must
fail through the normal attachment unavailable surface, not crash or rewrite
metadata.

### 7.5 Performance boundary

Archive-location status must be O(1)-style filesystem work: resolve bookmark,
inspect root type, and probe requested access. It must not recurse through the
archive.

| Application path | Current/future payload I/O policy |
| --- | --- |
| Process startup and first frame | None; location resolution is not a gate |
| Installation classification | Database evidence only |
| Message text search | No archive file access |
| Conversation list | Avoid root scans; attachment-bearing rows may perform bounded per-file resolution only when needed |
| Timeline construction | No full scan; resolve only attachments represented in the requested page |
| Attachment display | Resolve and stat/open the selected payload |
| Attachment ingestion | Hash/copy only candidate payloads |
| Explicit archive statistics | May scan, but must be user-initiated/background, cancellable, and cached |
| Explicit integrity check | May verify metadata-known files; unavailable root yields deferred status |
| Relocation | Full inventory/copy/verification with progress and resumability |

`ArchiveSettings.build()` currently awaits
`AttachmentArchiveStatsRepository.readStats()`, which recursively lists all
archive files before returning. `AttachmentResolver` awaits
`archiveSettingsProvider.future`. This creates a potential large-tree scan on
the first settings/resolution path and must be separated during implementation:
enabled/location state should load cheaply; expensive statistics should be a
separate on-demand asynchronous value.

`OverlayArchiveCompatibilityLookup` and chat-summary hydration can also perform
per-attachment stats. Implementation tests should ensure search and
non-attachment browsing do not accidentally fan out into payload I/O.

### 7.6 Checkpoint and backup semantics

Before release, MessageLens must state and implement one of two truthful
policies:

1. production checkpoints explicitly include both primary-root state and the
   configured attachment archive as separate verified components; or
2. checkpoints explicitly cover primary state only and the UI/documentation
   states that externally stored payloads require separate preservation.

Silently retaining the current “whole root” wording after externalization is
not acceptable. A checkpoint must never follow an arbitrary symlink or discover
an external root by recursively escaping the primary authority.

The preferred long-term policy is a multi-component preservation manifest with
separate roots and identities. That work can be staged after safe relocation
but must be complete before presenting checkpoint status as coverage of the
external attachment archive.

## 8. Migration strategy

### 8.1 Preconditions

Relocation begins only after the user selects an existing destination parent.
MessageLens creates or selects a managed archive directory beneath that parent
and records the exact destination identity. Preflight must establish:

- the source root is available and readable;
- the destination is not the same directory or nested inside the source;
- neither root nor managed destination is a symlink;
- the destination is a real directory on the intended resolved volume;
- required read/write/create/rename/link semantics work using a disposable
  probe inside the managed staging area;
- free capacity exceeds the source physical byte total plus a margin;
- no incompatible completed archive already occupies the destination; and
- no other archive mutation owns the coordinator.

The selected parent and managed child distinction prevents MessageLens from
treating unrelated files in a user-selected folder as archive contents.

### 8.2 Relocation journal

Create a versioned relocation journal in the internal primary data root, not in
a user database schema. The journal should include:

- operation identifier and state;
- source root identity and normalized path;
- destination bookmark/identity and staging path;
- source inventory generation/timestamp;
- expected unique payload paths, sizes, and known hashes;
- physical files not referenced by overlay rows;
- completed and verified copy entries;
- activation configuration before and after switch; and
- failure/interruption information.

The journal is operational state, not attachment metadata. It allows a restart
or temporary destination disconnect to resume verified work. Startup may
recognize the journal cheaply, but must not synchronously resume a 39 GB copy
before rendering the application.

### 8.3 Source snapshot and inventory

Acquire a new relocation mutation operation through
`ArchiveMutationCoordinator`. It should block attachment reconciliation and
other archive writes while allowing ordinary database reads and message search.
The active source snapshot must remain stable from final inventory through
activation.

Inventory two sets:

1. unique metadata-known `archive_relative_path` values with recorded size and
   optional hash; and
2. every regular physical file under the source root, including unreferenced
   preservation payloads.

Overlay row count is reported separately because multiple rows may share one
content-addressed file. Temporary installer artifacts such as
`.messagelens-install-*` are operational debris, not canonical payloads; the
relocation journal must classify them explicitly rather than counting them as
verified archived files or deleting them casually.

### 8.4 Copy and verification

Copy into a destination staging directory such as a uniquely identified
`.messagelens-attachment-relocation-<operation-id>` beneath the selected
destination. Preserve relative paths and never modify source payloads.

For metadata-known files:

- verify destination size against `file_size_bytes`;
- verify SHA-256 against non-null `content_hash`;
- where the stored hash is null, compute source and destination hashes during
  relocation and record the comparison in the journal without requiring a
  database-row update; and
- deduplicate verification by relative physical path.

For physical files without overlay metadata, compare source and destination
size and hash. This is necessary because attachment payloads are preservation
data; lack of a current database reference is not deletion authority.

The existing file store's hashing, verification, path-boundary, and
no-overwrite techniques should be extracted/reused where interfaces allow.
The existing export helper is not an acceptable substitute.

At the end, compare:

- unique regular-file count;
- physical byte total;
- every expected relative path;
- every expected size; and
- every known or relocation-computed hash.

If the source changes despite coordination, abort final verification and
refresh/restart the affected snapshot. Do not activate a best-effort copy.

### 8.5 Activation and rollback

After successful verification:

1. atomically rename the staging directory to its final managed name on the
   destination filesystem;
2. create/refresh the bookmark for that final URL;
3. persist the new versioned configuration while retaining the old
   configuration in the relocation journal;
4. resolve the newly persisted configuration through the normal controller;
5. verify representative and then complete manifest resolution at the new
   root;
6. publish the new location generation and invalidate path-bearing providers;
7. mark relocation activated; and
8. retain the source directory unchanged.

If post-switch resolution fails, restore the prior configuration, republish its
location generation, and leave both copies intact. Activation must not update
any `archived_attachments` row because relative identity has not changed.

### 8.6 Source retirement

The old archive becomes only **eligible** for retirement after verified
activation. It is not automatically removed.

A later user action should display the exact old path and verified size, explain
that deletion is irreversible, re-confirm that the active root still passes
manifest verification, and acquire a separately named destructive mutation.
The operation must have explicit authority over that exact old directory and
must not call broad primary-root deletion code.

Restoring the default internal location uses the same copy/verify/activate
workflow in reverse. “Restore Default Location” must never mean changing the
setting before the payloads have returned safely.

## 9. UI proposal

### 9.1 Placement and architecture

Use the existing settings spec system. The repository already contains
`SettingsCassetteSpec.attachmentArchive`,
`AttachmentArchiveSettingsCassettePayload`, an attachment archive resolver,
and a rendering branch. The current normal settings menu does not expose a
corresponding `SettingsMenuActionId`, and the payload is static. Extend these
types with a persistent settings context and typed actions; do not put file
selection, provider mutation, or relocation logic directly in widgets.

The default cassette should show:

```text
Attachment archive
Internal — ~/Library/Application Support/.../attachment_archive
Available · 39 GB

[Move…] [Reveal in Finder]
```

The custom available state should show the resolved current path and volume:

```text
Attachment archive
External — /Volumes/MessageLens Data/MessageLens/attachment_archive
Available · Writable

[Move…] [Reveal in Finder] [Restore Default Location…]
```

### 9.2 Unavailable presentation

An unavailable external archive must not become a startup modal or replace the
normal message UI. The settings cassette and any relevant attachment surface
should say, calmly and truthfully:

```text
Attachment archive unavailable
The external volume containing your attachment archive is not currently
available. Messages and search remain available.

[Locate Archive…]
```

If the app is merely waiting for the known volume to reconnect, “Locate” can be
secondary. If bookmark resolution is stale or permission is denied, make it the
primary recovery action. Do not offer “create empty archive” as an automatic
repair.

Individual attachments should identify that their archive is unavailable,
rather than claiming that the file is missing or permanently unrecoverable.
Normal textual message content remains visible.

### 9.3 Relocation progress

Use existing MessageLens progress and notification patterns. The progress model
should report:

- preflight status;
- files and bytes copied/verified;
- current phase;
- paused/unavailable destination state;
- resumability after restart;
- activation result; and
- old-location retention status.

Cancellation before activation leaves the source active and intact. The UI may
offer Resume or Remove Incomplete Copy only after the incomplete staging
directory is positively identified by its relocation journal. Removal of an
incomplete destination is not permission to remove the source.

After activation, present the old archive as retained and provide a separate
“Review Old Copy…” action. Do not combine the final delete confirmation with
the move button.

## 10. Risks and edge cases

| Risk/edge case | Mitigation or required decision |
| --- | --- |
| Volume absent at expected `/Volumes/...` path | Resolve bookmark/identity first; never create from last-known path |
| Another volume reuses the same mount path | Bookmark resolution and destination identity must win over raw path |
| Drive rename or mount-path change | Refresh bookmark resolution on workspace events; update display metadata |
| Bookmark stale or configuration restored to another Mac | Publish unavailable/configuration-needs-location; require user reselection |
| Permission revoked | Typed permission-denied status; no per-file missing conclusions |
| Mid-read disconnect | Catch filesystem failure at attachment boundary and invalidate location state |
| Mid-write disconnect | Fail operation, retain source/live metadata, remove only proven temporary destination artifact when safe |
| Mid-copy restart | Resume from versioned journal after revalidating source/destination identity and completed hashes |
| Read-only destination | Permit reads if it is active; reject relocation/ingestion writes |
| Insufficient capacity | Fail preflight or pause copy before activation; retain source |
| Source changes during relocation | Serialize attachment mutations; repeat final inventory if generation changed |
| Duplicate overlay rows for one payload | Verify/count unique relative physical paths, not row count |
| Physical orphan files | Copy and verify them; absence of metadata is not deletion authority |
| Symlink root or symlink entry | Reject according to current preservation boundary; never follow outside root |
| Unsupported external filesystem semantics | Execute a disposable preflight of required create/link/rename/fsync behaviour |
| Hash is null in old metadata | Hash source and destination during relocation only; record in journal |
| Absolute paths cached in providers | Publish location generation and invalidate every path-bearing provider |
| Thumbnail cache includes old absolute path | Accept safe cache misses initially; optional later content-key migration |
| Integrity audit runs while unavailable | Report audit deferred/unavailable, never mass missing/corrupt |
| Stats scan becomes a status check | Split cheap availability from expensive inventory/statistics |
| On-demand writer sees unavailable custom root | Defer; do not create or fall back to internal root |
| Legacy writer bypasses canonical installer | Migrate or remove before custom-root activation |
| Production checkpoint loses payload coverage | Implement multi-component coverage or make exclusion explicit before release |
| Restore Default selected without enough internal space | Use the full preflight/copy/verify workflow in reverse |
| User deletes old source too early outside MessageLens | Warn that external deletion is outside rollback guarantees; active verified copy remains authoritative |

The filesystem cannot provide a transaction across two volumes and an SQLite
settings write. Safety comes from ordering, durable journal state, immutable
source retention, atomic destination-local finalization, and reversible
configuration activation.

## 11. Implementation phases

Each phase is intended to be independently reviewable and testable. No phase
should combine schema changes with filesystem migration because no schema
change is required.

### Phase 1 — Location model and default compatibility

- Add immutable configuration and availability models.
- Add the attachment-owned location repository/controller.
- Read/write a versioned default configuration through overlay settings.
- Derive the internal default from `ArchiveAccessAuthority`.
- Adapt providers while preserving identical internal-root behaviour.
- Add architecture tripwires preventing direct root reconstruction.

Exit criterion: all current tests pass with the default root and no payload or
schema change.

### Phase 2 — macOS selection, bookmark, and volume events

- Generalize the existing folder chooser for destination selection.
- Add native bookmark create/resolve/refresh methods.
- Add mount/unmount/rename event delivery.
- Complete required-reason/privacy manifest analysis for capacity APIs.
- Add app-activation re-resolution fallback.

Exit criterion: a temporary test directory/volume identity survives relaunch
and rename simulations; unavailable resolution is typed and non-destructive.

### Phase 3 — Availability-aware reads and diagnostics

- Update archive read/lookup contracts.
- Carry archive-unavailable semantics through resolver, evidence, and UI.
- Separate cheap settings/location state from recursive stats.
- Update onboarding/environment and graph-health reporting.
- Invalidate path-bearing providers on location generation changes.

Exit criterion: message browsing/search works with the custom archive absent,
and no missing/corrupt payload findings are produced for an unavailable root.

### Phase 4 — Write admission and automatic recovery

- Require an available+writable root lease for ingestion/recovery.
- Prevent directory creation at unresolved custom paths.
- Migrate or retire the legacy direct writer.
- Defer bounded ingestion while unavailable and resume after reconnection.
- Verify no automatic full scan runs on reconnection.

Exit criterion: disconnect/reconnect cannot redirect writes, lose metadata, or
require an app restart.

### Phase 5 — Relocation engine

- Add relocation mutation operation and journal.
- Implement destination preflight, inventory, resumable copy, and verification.
- Implement reversible activation and provider invalidation.
- Retain the source and expose its eligibility state.
- Exercise large sparse fixtures and forced interruption points.

Exit criterion: simulated interruption at every phase leaves either the old
root active or a verified new root active, never an unverified active root.

### Phase 6 — Settings and progress UI

- Expose the attachment archive in the existing settings navigation.
- Add Move, Reveal, Locate, and Restore Default typed actions.
- Add calm available, read-only, unavailable, and progress states.
- Add a separate old-copy review/retirement entry point, without implementing
  broad deletion authority.

Exit criterion: all user-visible states are driven by typed application state
and the normal message/search UI remains available.

### Phase 7 — Preservation/checkpoint integration and retirement

- Decide and implement truthful external-payload checkpoint coverage.
- Update adoption and reset policy without granting reset external deletion
  authority.
- Implement separately authorized old-copy retirement only if approved.
- Update durable documentation, release metadata, support telemetry, and manual
  recovery instructions.

Exit criterion: preservation claims, checkpoint manifests, support artifacts,
and deletion authority all match the physical split-root architecture.

## 12. Testing plan

### 12.1 Unit tests

- configuration serialization/version rejection and default migration;
- bookmark-resolution result mapping;
- location-state transitions and generation increments;
- root/path boundary checks, including traversal and symlink rejection;
- available, unavailable, read-only, permission-denied, and missing-directory
  states;
- archive lookup distinction between absent record, unavailable root, missing
  file, and available file;
- unique-path verification with duplicate overlay compatibility rows;
- relocation manifest encoding, validation, and state transitions;
- size/hash verification, including null stored hashes;
- rollback selection after activation verification failure; and
- resolver/provider invalidation when the root generation changes.

### 12.2 Filesystem integration tests

Use temporary roots only. Cover:

- default-to-custom and custom-to-default relocation;
- large and nested content-addressed fixtures;
- unreferenced regular files preserved by physical inventory;
- pre-existing identical and conflicting destination files;
- partial destination and resume;
- insufficient capacity via an injected capacity reader;
- read-only destination;
- source or destination disappearance at every copy/verify/activate boundary;
- filesystem type/atomic-operation preflight failure;
- symlink root and symlink payload rejection;
- no source deletion after success, failure, cancellation, or restart; and
- exact file/byte/hash equality after activation.

Tests should inject failure points rather than unplugging a real volume during
automated runs. No test may point at the production Application Support root or
the user's archive.

### 12.3 Provider and application integration tests

- default configuration reproduces the existing provider graph;
- overlay/database providers stay on the primary root when attachment payloads
  are external;
- startup and `messageLensInstallationStateProvider.future` do not wait for the
  external archive;
- message text search performs no archive directory scan/stat fan-out;
- conversation lists without displayed attachments perform no payload access;
- visible attachment rows resolve only their bounded paths;
- unavailable root does not trigger onboarding remediation or Start Fresh;
- explicit health audit reports root unavailable rather than N missing files;
- reconnection invalidates cached absolute paths and restores display;
- ingestion is deferred while unavailable and resumes after availability;
- recursive stats are not awaited by cheap archive settings/status; and
- normal graph/FTS/import schemas remain unchanged.

### 12.4 macOS-specific tests

- native bookmark round-trip for a selected directory;
- stale bookmark refresh;
- simulated mount, unmount, and volume-rename event delivery;
- app-activation re-resolution;
- raw last-known path cannot override a failed identity resolution;
- balanced security-scope lease tests if sandbox support is later enabled;
- entitlements remain consistent with the chosen distribution model; and
- required-reason privacy declarations cover any capacity API used.

Where CI cannot create removable volumes, isolate native Foundation APIs behind
an adapter and test event and resolution contracts with fakes. Perform a manual
release-build exercise on a removable volume before tester distribution.

### 12.5 Relocation state-machine tests

For each durable state—selected, preflighted, inventory complete, copying,
verifying, destination finalized, configuration switched, activated, rollback,
and source retained—terminate and recreate the controller. Assert that restart:

- never chooses an unverified destination;
- never deletes source or overlay rows;
- resumes only after identities and journal content validate;
- pauses cleanly when either volume is unavailable;
- restores old configuration when activation is incomplete; and
- never blocks the first usable UI on copy resumption.

### 12.6 Preservation and architecture tests

Extend architecture tripwires to prove:

- only the location controller derives the active root;
- no feature concatenates `/Volumes`, the primary root, or
  `attachment_archive` to bypass it;
- Start Fresh and message-data reset cannot delete either active or retained
  external payloads;
- projection/import never reads overlay location settings;
- overlay remains the sole owner of archive metadata and user configuration;
- no absolute active-root path is persisted in attachment rows;
- checkpoint coverage is explicit and does not follow symlinks; and
- settings renderers dispatch typed intents rather than performing filesystem
  work.

### 12.7 Manual acceptance matrix

Before tester release, exercise a production-signed build with:

- external drive absent at launch;
- disconnect while browsing text messages;
- disconnect during attachment display;
- disconnect during ingestion;
- disconnect during relocation copy and verification;
- reconnect without restarting MessageLens;
- volume rename;
- read-only volume;
- location reselection after permission/access failure;
- app relaunch and Mac restart;
- search across a large database while the archive is absent; and
- verified move followed by deliberate retention and later reviewed retirement
  of the old copy.

Confirm bundle identity and signing remain consistent with
`60-BUILD-CONSIDERATIONS/02-macos-fda-grant-continuity.md` so unrelated Full
Disk Access continuity is not regressed.

## Repository assumptions contradicted or clarified by the audit

The investigation corrected several plausible assumptions from the feature
prompt:

1. Archive records do **not** persist the active root as an absolute path.
   They already use archive-relative paths, so there is no row migration.
2. MessageLensDevelopment's external root is a whole-application-root override,
   not reusable attachment-only configuration.
3. The repository has a directory chooser but no persisted bookmark or
   security-scope implementation.
4. The application is currently unsandboxed, so security-scoped access is not
   presently required. Bookmark-based identity is still recommended.
5. There is an attachment settings cassette implementation, but it is not
   currently exposed as an actionable normal settings entry.
6. Search itself does not depend on payload files, but attachment-aware summary
   hydration and settings statistics can still perform filesystem work.
7. Current checkpoint coverage includes payloads only because they are beneath
   the primary root. Relocation changes that guarantee even though database
   metadata remains valid.

## Decision record for the implementation prompt

The next implementation prompt should treat the following as settled unless a
new audit disproves them:

- keep primary databases and state at the admitted primary root;
- keep persisted attachment paths root-relative;
- introduce an attachment-owned configurable-root boundary;
- store versioned machine-specific configuration through overlay settings;
- use a normal Foundation bookmark now, with a security-scoped-compatible
  native abstraction for any future sandboxed build;
- model archive-root availability before per-file availability;
- keep startup, browsing, and text search independent of payload availability;
- use the existing mutation coordinator, content hashes, and verified installer
  mechanics;
- relocate by resumable copy, complete verification, reversible activation,
  and source retention;
- require separate authorization for old-copy retirement;
- do not use symlinks, the export helper, or a raw `/Volumes/...` path as the
  permanent architecture; and
- resolve checkpoint/backup coverage before tester release.

## Documentation and data-change record

This audit created only
`31-ATTACHMENT-ARCHIVE-RELOCATION/00-ARCHITECTURE-AUDIT-AND-IMPLEMENTATION-PLAN.md`.
It made no production-code, test, schema, migration, database, Feature Index,
archive-payload, or deliberately untracked-file change.
