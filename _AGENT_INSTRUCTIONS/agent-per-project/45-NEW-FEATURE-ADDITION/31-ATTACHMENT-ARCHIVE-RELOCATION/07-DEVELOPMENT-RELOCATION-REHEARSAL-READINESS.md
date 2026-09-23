# Development Attachment-Archive Relocation Rehearsal Readiness

## Decision

**DEVELOPMENT REHEARSAL READY FOR EXPLICIT AUTHORIZATION: YES**

The audited development source and Toshiba destination match the proposed
topology, the development overlay is compatible with the Phase Five metadata
reader, the destination has ample capacity, and the existing admitted archive
identity provides a clean fail-closed development-only authorization boundary.

This is readiness to make a later, explicit code authorization and then use the
normal Phase Five/Six workflow. It is not authorization to relocate now. The
real preflight must still create and remove its disposable probe to prove the
required hard-link/no-overwrite and exclusive-rename behavior on this mounted
Toshiba volume. The authoritative inventory and capacity decision also remain
future workflow steps.

No relocation was enabled or begun during this audit. No journal, probe,
staging directory, managed archive, bookmark, configuration change, database
write, source hash inventory, copy, move, deletion, or production-data access
occurred.

## Phase Six checkpoint

Phase Six was reviewed against
`06-PHASE-SIX-IMPLEMENTATION-RECORD.md`. Only the intended Phase Six production
code, tests, generated files, documentation, `pubspec.yaml`, and `CHANGELOG.md`
were staged. `git diff --cached --check` passed before commit.

- Branch: `feature/attachment-archive-relocation`
- Commit: `37e531e9dc87877d116db5382e5dc8bc03982569`
- Subject: `feat(attachments): add archive relocation settings workflow`
- Push: not performed
- Shared-instructions submodule: unchanged at
  `95326f515ef4719f155ce6e223990398daad6311`

## Read-only audit method

The audit was limited to the two explicitly authorized paths and repository
code. Filesystem evidence came from `stat`, `diskutil info`, `df`, `du`, `find`,
and directory listings. The development archive marker was read directly. The
development overlay was opened with SQLite in read-only, immutable mode with
`PRAGMA query_only=ON`; no migrations were run. Payload contents were not read
or hashed.

Production MessageLens data under Application Support was not inspected.

## Actual development topology

### Admitted primary root

The development primary root is:

```text
/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development
```

Evidence:

- it is an existing real directory on the mounted `WD_ELEMENTS` volume;
- it contains the active development databases, instance lock, application
  logs, archive, and archive identity marker;
- `.messagelens-archive.json` identifies environment `development` and archive
  instance `e9310d3f-8dc8-4436-a48e-c4fb7cf8d4a5`;
- the native archive-claim resolver accepts a development root override only
  for a development build, canonicalizes it, resolves symlinks, and rejects the
  same override for production;
- the development build identity is separately constrained to bundle
  `com.bigbenchsoftware.MessageLens.development` and product
  `MessageLens Development`.

### Active attachment archive

The active development attachment archive is:

```text
/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development/attachment_archive
```

The development overlay contains no `attachment_archive_location` setting.
`AttachmentArchiveLocationController` therefore resolves the configuration as
`defaultInternal`, whose archive root is `attachment_archive` below the
admitted primary root. The proposed source is consequently the current active
development archive.

### Development overlay

The active development overlay is:

```text
/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development/user_overlays.db
```

This follows the central database filename and the admitted root used by the
persistent overlay provider. It was inspected read-only only.

### Relocation journal

No `.attachment_archive_relocations` directory exists below the development
primary root. There is therefore no existing Phase Five operation directory or
`current.json` pointer and no pending relocation journal.

### Production isolation

Production and development are isolated by the already-admitted native and
Dart archive identity:

- production requires environment `production`, build identity
  `productionRelease`, bundle `com.bigbenchsoftware.MessageLens`, product
  `MessageLens`, and the approved production signature;
- development requires a development build identity, bundle
  `com.bigbenchsoftware.MessageLens.development`, and product
  `MessageLens Development`;
- the external development-root override is rejected for production;
- without that override, the native resolver derives the production root from
  Application Support and the production bundle identifier;
- all persistent database and archive paths flow from the single admitted
  root authority.

The qualification can therefore be bound to the exact development authority
without inspecting or weakening production. Production's actual files were not
opened to make this determination.

## Source and destination volume separation

| Role | Mount | Device identity | Filesystem | Volume UUID |
| --- | --- | --- | --- | --- |
| Development source | `/Volumes/WD_ELEMENTS` | APFS volume `disk11s1`, container `disk11`, physical store `disk10s2` | APFS | `A841DF7B-27A0-44F7-882E-528BDC9AD35D` |
| Rehearsal destination | `/Volumes/Toshiba_manual_bu` | partition `disk12s2`, whole disk `disk12` | Journaled HFS+ | `E0DD8906-3B97-3521-9CD0-335260A82857` |

The device, whole-disk, mount, filesystem, and volume identities are distinct.
Both volumes reported mounted and not read-only.

Journaled HFS+ is not clearly incompatible with the Phase Five requirements:
it supports the hard-link primitive used by the Darwin atomic no-overwrite
installer, and the finalizer uses Darwin's exclusive `renamex_np` operation
within the destination filesystem. Static volume metadata cannot prove the
exact mounted-volume behavior expected by the engine, so the final status is:

```text
Toshiba filesystem semantics: compatible in principle; requires preflight probe
```

The normal Phase Five probe, run only after explicit authorization, is the
deciding test. A probe failure must defer the operation as
`unsupportedFilesystem`; it must not be bypassed.

## Destination parent

The selected parent is:

```text
/Volumes/Toshiba_manual_bu/ML_ARCHIVE_RELOCATION
```

It exists as a real directory, not a symbolic link. At audit time it was empty.
It contains no pre-existing Phase Five staging child, finalized managed archive,
or other conflicting data.

The chooser must return this path as the **parent**. The engine—not the user—will
create operation-owned children named from the operation UUID:

```text
.messagelens-attachment-relocation-<operation-id>
MessageLens Attachment Archive <operation-id>
```

The first is staging; the second is the finalized managed archive.

## Development source characterization

The source exists as a real directory, not a symbolic link.

- Allocated size from `du`: 3,465,584,640 bytes
  (3,384,360 KiB, approximately 3.23 GiB / 3.47 GB).
- Apparent size from `du -A`: 3,458,596,864 bytes
  (3,377,536 KiB, approximately 3.22 GiB / 3.46 GB).
- File count from a metadata-only traversal: 4,037.
- Symbolic-link count: 0.
- Top level: exactly 256 lowercase hexadecimal prefix directories (`00` through
  `ff`); no obvious unexpected top-level entries were found.

The overlay's distinct-path size total is 3,457,342,872 bytes, which closely
matches the filesystem apparent size once directory metadata is excluded.

The prior Phase Six record's generic reference to a real 39-GB relocation is
not the size of this audited development source. The development source is
approximately 3.46 GB. This is a corrected capacity expectation, not a topology
mismatch: source path, active configuration, physical files, and overlay
metadata all agree.

No source payload was hashed. These are approximate metadata-tool results, not
the Phase Five authoritative inventory.

## Overlay metadata compatibility

The read-only overlay inspection found schema user version 8 and the expected
`archived_attachments` columns, including non-null
`archive_relative_path` and `file_size_bytes`, plus nullable `content_hash`.
This is the schema consumed by
`OverlayAttachmentArchiveRelocationMetadataReader`.

Bounded aggregate results:

| Measure | Result |
| --- | ---: |
| Archived-attachment rows | 4,321 |
| Distinct archive-relative paths | 4,037 |
| Physical source files | 4,037 |
| Additional metadata references to shared paths | 284 |
| Distinct-path metadata bytes | 3,457,342,872 |
| Empty relative paths | 0 |
| Negative sizes | 0 |
| Rows with a content hash | 4,321 |
| Invalid hash shapes | 0 |
| Paths with conflicting size/hash variants | 0 |

The distinct metadata path count exactly matches the physical file count. No
schema change or migration is needed for the rehearsal. The Phase Five
authoritative inventory must still validate every path and metadata association
before review.

## Capacity expectation

Toshiba reported:

- total: 882,027,479,040 bytes;
- free: 625,383,006,208 bytes (approximately 582.43 GiB / 625.38 GB).

Using the distinct-path logical byte estimate, the Phase Five formula gives:

```text
source bytes                                  3,457,342,872
5 percent                                       172,867,143
minimum margin                                1,073,741,824
applicable margin                             1,073,741,824
approximate required capacity                 4,531,084,696
```

That is approximately 4.22 GiB. The reported destination free space is about
138 times this estimate. Using the slightly larger `du -A` figure changes the
estimate only to 4,532,338,688 bytes.

This is not the authoritative capacity decision. Phase Five will inventory the
source and query important-usage capacity again before allowing copy.

## Recommended development-only authorization

Use one compile-time, code-reviewed execution gate derived from the already
admitted `ArchiveAccessAuthority`. Do not add a preference, environment
variable, command-line switch, persisted setting, alternate service, or second
relocation implementation.

For clarity, rename the current semantically production-named provider to an
execution gate, for example
`attachmentArchiveRelocationExecutionEnabledProvider`, and have both the
Settings presentation and `AttachmentArchiveRelocationActions` continue to
consume that single provider. It should return `true` only when every field of
the admitted identity matches this qualification target:

- environment is `ArchiveEnvironment.development`;
- build identity is one of `developmentDebug`, `developmentProfile`, or
  `developmentRelease` (explicitly excluding `fdaExperiment`, `testHarness`,
  and `productionRelease`);
- bundle identifier is
  `com.bigbenchsoftware.MessageLens.development`;
- product name is `MessageLens Development`;
- canonical root is exactly
  `/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development`;
- archive instance ID is exactly
  `e9310d3f-8dc8-4436-a48e-c4fb7cf8d4a5`.

Before archive admission, or on any mismatch, the provider must return `false`.
Tests should prove that changing any one field fails closed and that every
production identity remains disabled. Existing disposable workflow tests may
continue to override the provider explicitly.

This is narrower than an environment-only check: it authorizes one development
bundle, one canonical root, and one archive instance. It uses the exact Phase
Five engine and Phase Six UI/action boundary, is obvious in review, cannot be
enabled by runtime user data, and can be removed after qualification or remain
harmlessly scoped to this development archive. Production stays disabled even
if the same binary source includes the qualification code.

Do not implement this recommendation until the user explicitly authorizes the
rehearsal-enablement change.

## Exact future rehearsal workflow

After the development-only gate is separately implemented, reviewed, and
explicitly authorized:

1. Attach both drives and launch `MessageLens Development` with the exact
   admitted WD root above.
2. Open **Settings → Attachment Archive** and select **Move**.
3. In the system chooser, select
   `/Volumes/Toshiba_manual_bu/ML_ARCHIVE_RELOCATION` as the destination parent.
4. The normal workflow creates its operation journal below the WD primary root.
5. Phase Five creates its UUID-named staging child below the Toshiba parent.
6. Preflight writes only disposable probe artifacts inside that staging child,
   proves atomic no-overwrite hard-link installation and exclusive directory
   finalization, removes the probe, and reads destination capacity.
7. Phase Five performs its authoritative source/metadata inventory and records
   the durable manifest below the WD primary root.
8. The workflow stops at `inventoryComplete` and presents the review. No
   payload copy or activation occurs before explicit **Begin Relocation**.
9. The user compares source, destination, filesystem checks, file/byte totals,
   and capacity, then explicitly begins.
10. Phase Five copies each payload to operation-owned staging, verifies it,
    records durable receipts, verifies complete destination coverage, and
    exclusively finalizes the managed archive child.
11. The private activation permit switches the development archive
    configuration to the Toshiba managed child only after all verification and
    finalization gates pass.
12. Development attachment reads and new archive writes use Toshiba. The
    databases, journal, logs, derived media, and every other part of the
    MessageLens Development primary root remain on WD.
13. The original WD `attachment_archive` remains intact and is not reclaimed,
    deleted, renamed, or used as a silent fallback.

## Interruption and recovery implications

### Toshiba disconnects

Before activation, WD remains authoritative. A destination I/O failure defers
or pauses relocation, while durable journal/manifest/receipt state remains on
WD. Reconnecting Toshiba does not automatically resume; the user chooses
Resume, and Phase Five revalidates the destination and reconciles receipts.

After activation, ordinary development databases and text features remain on
WD, but archived payloads report unavailable while Toshiba is absent. The app
does not silently fall back to the retained WD archive. Reconnection allows the
bookmark-backed location to become available again.

### WD disconnects

This removes the admitted development primary root, including graph/import/
overlay databases, the active source before activation, and the relocation
journal. The development app cannot safely continue or reconstruct/resume the
operation until WD is remounted at the admitted path. Toshiba alone is not a
complete MessageLens Development installation.

### MessageLens Development quits

Durable journal, manifest, and completed copy receipts remain on WD; verified
destination work remains on Toshiba. Relaunch reconstructs the workflow from
the journal. It does not infer completion from directory appearance and does
not automatically resume copy.

### Mac restarts

With both volumes mounted at the expected identities/paths, restart behavior is
equivalent to an application relaunch: pending state reconstructs and requires
explicit resume. If Toshiba is absent, the source remains authoritative before
activation; after activation the custom archive is unavailable without WD
fallback. If WD is absent, the development primary root and journal are both
unavailable, so the app cannot resume even if Toshiba is present.

### Fidelity relative to production

This rehearsal faithfully exercises:

- the exact Phase Five preflight, inventory, journal, copy, verification,
  finalization, activation, rollback, and retained-source behavior;
- the exact Phase Six chooser, review, progress, pause/resume, reconnect, and
  status presentation;
- cross-volume APFS-to-HFS+ copying to a removable USB destination;
- external-archive availability behavior after activation.

It does not faithfully reproduce production's primary-root topology. The
development databases and journal are themselves on removable WD storage,
whereas production's primary root and journal will remain on the internal SSD.
Losing WD therefore disables the whole development installation; losing a
production destination should leave the internal production databases and
journal available. The rehearsal is also about 3.46 GB, so it does not reproduce
the duration, thermal behavior, or long-copy exposure of a roughly 39-GB
production source.

## Post-rehearsal acceptance matrix

These checks are proposed for after successful development activation. None was
performed in this audit.

| Check | Expected acceptance evidence |
| --- | --- |
| Relaunch with both drives connected | Development admits the same WD primary root; Settings reports the Toshiba managed archive available and active. |
| Ordinary conversation browsing | Conversation lists and message timelines load normally from the WD databases. |
| Text search | Representative searches return expected messages without depending on attachment availability. |
| Archived image | Multiple old images open from paths resolved beneath the Toshiba managed archive. |
| Archived video | Representative videos open/play from Toshiba. |
| Archived document/other payload | Representative documents and non-media attachments open from Toshiba. |
| Resolution provenance | Diagnostic/path evidence confirms archived payloads resolve from Toshiba, not the retained WD source. |
| New attachment ingestion | A newly eligible payload is archived under the active Toshiba managed root and its overlay metadata remains relative. |
| Disconnect Toshiba while running | Messages and text search remain usable; archived payloads and Settings show unavailable; no WD archive fallback occurs. |
| Reconnect without restart | Availability returns through the bookmark-backed location and representative payloads open again. |
| Restart with Toshiba connected | The external configuration resolves and archived payloads are available without manual repair. |
| Restart with Toshiba absent | WD primary databases remain usable; Settings truthfully reports external archive unavailable; no fallback or configuration rewrite occurs. |
| Reconnect after absent launch | Toshiba becomes available again and payload resolution recovers without reconfiguration. |
| Settings status | Location, volume, availability, retained-source statement, operation ID, and completion state are accurate. |
| Graph/database health | Existing health/integrity surfaces remain healthy; no graph, import, overlay, or presence database moved from WD. |
| Retained-source preservation | A pre-begin read-only relative-path/size/SHA-256 baseline of the WD source matches a post-activation baseline byte-for-byte. No extra, missing, or changed WD payload exists. |
| Destination equivalence | Final Toshiba relative paths, sizes, and SHA-256 values match the authoritative Phase Five manifest/receipts and expected source coverage. |
| Journal/result evidence | Terminal state is `sourceRetained`; activation and source-retention evidence are present; no rollback or incomplete staging state is presented as success. |

For the byte-for-byte retained-source check, capture the independent read-only
baseline only after explicit authorization and before pressing Begin. The
present audit deliberately did not hash source payloads.

## Stop-gate assessment

No mandatory stop-and-report gate was encountered:

- the actual development root and active source match the proposed topology;
- production/development isolation is strong and can be made exact at the gate;
- no pending journal exists;
- Toshiba is a distinct mounted volume and is not clearly incompatible;
- the remaining filesystem proof is correctly deferred to the real preflight
  probe;
- the destination parent is empty and contains no managed conflict;
- a clean development-only authorization mechanism exists;
- no source modification/deletion, schema migration, production access, or
  preservation-invariant weakening is required.

The corrected approximately 3.46-GB development source size and the required
future preflight probe are qualifications, not stop gates.

## Repository state at handoff

This readiness report is intentionally unstaged. The unrelated untracked files
that predated the audit remain untouched. Phase Six is committed, the branch is
five commits ahead of its remote tracking branch, and nothing was pushed.
