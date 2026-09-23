# Environment Summary — Architecture Audit and Design

## 1. Executive summary

MessageLens can add a useful read-only `Settings → Environment` center-panel
page without a database schema change. The page must aggregate the authority
that already admitted the process, the attachment-location state already owned
by Feature 31, package metadata, and bounded read-only database evidence. It
must not independently choose roots, infer archive authority from strings, or
run any archive inventory.

The durable Messages model is stronger than expected. `source_registry`
retains a typed live/historical source record, historical source keys retain
the canonical `chat.db` path even after a drive is disconnected, and packed
source-scoped graph IDs retain the exact source ID in the projected graph.
Individual Message source cards are therefore supportable when their counts
and ranges are computed from current graph rows. Import completion time is
only optional workflow metadata and must be labelled as such.

Contacts provenance is weaker. Contact rows are imported under the single
`live-address-book` source ID. The physical AddressBook database path selected
for a run is not retained with imported rows, and multiple physical Contacts
sources cannot be reconstructed later. V1 should show aggregate projected
Contacts facts and say that physical source identity is not retained.

The active attachment archive can be shown authoritatively from
`AttachmentArchiveLocationState`. The retained pre-adoption archive cannot be
shown after a successful transaction is retired: its only durable path lived
in the pending transaction, which is deliberately deleted on success.

One mandatory stop-and-report gate was found. Loading a custom attachment
location can persist refreshed bookmark metadata in
`AttachmentArchiveLocationController._availableCustomState`. Feature 33 must
not merely start watching that provider and claim that opening Environment is
mutation-free. Before UI implementation, the project must establish an
explicit pure observation seam (or prove and enforce that Environment only
consumes the already-live snapshot without initiating resolution). No schema
change is needed for that correction.

Decision summary:

| Question | Answer |
|---|---|
| CAN ENVIRONMENT V1 SHIP WITHOUT SCHEMA CHANGES | **YES** |
| CAN MESSAGE SOURCES BE SHOWN INDIVIDUALLY AND TRUTHFULLY | **YES**, with only the fields proved below |
| CAN CONTACT SOURCES BE SHOWN INDIVIDUALLY AND TRUTHFULLY | **NO** — physical source identity is collapsed into one live source |
| CAN ACTIVE ATTACHMENT LOCATION BE SHOWN AUTHORITATIVELY | **YES** |
| CAN RETAINED PREVIOUS ATTACHMENT LOCATION BE SHOWN AFTER RELAUNCH | **NO** |
| CAN COPY ENVIRONMENT SUMMARY USE THE SAME READ MODEL AS THE UI | **YES** |
| DOES OPENING ENVIRONMENT REQUIRE ANY ARCHIVE PAYLOAD I/O | **NO** |
| DOES OPENING ENVIRONMENT REQUIRE ANY DATABASE MUTATION | **NO** |
| DOES FEATURE 33 REQUIRE ANY STARTUP WORK | **NO** |
| ENVIRONMENT SUMMARY READY TO IMPLEMENT | **NO** — approve and establish the pure attachment observation seam first |

## 2. Product goal

Answer one question directly:

> What MessageLens environment am I looking at, and where did its data come
> from?

The first screenful should have diagnosed the stale-build/wrong-root incident
without a screenshot: product/version, environment/build identity, admitted
primary root, archive instance UUID, and active attachment location.

## 3. Explicit non-goals

Feature 33 is not:

- an environment selector or development-root editor;
- attachment archive adoption, relocation, fallback, deletion, or repair;
- an import manager or source-removal UI;
- database repair, integrity execution, maintenance, or recovery;
- a general diagnostics framework or raw debug dump;
- a second root, build, location, or provenance authority;
- Attachment Showcase onboarding integration.

Permitted conveniences are presentation-only: copy the shared summary, select
text, and perhaps reveal an already-available path in Finder in a later phase.

## 4. Repository and branch starting state

- Branch created directly from the completed Feature 31 HEAD:
  `feature/environment-summary`.
- Starting HEAD: `2c8bbaae5da30300dda8d4e9e3eaef57e353cea4`.
- Starting subject: `feat(attachments): polish archive adoption and add attachment showcase`.
- The tracked worktree and index were clean.
- Shared-instructions submodule was clean at
  `95326f515ef4719f155ce6e223990398daad6311`.
- Known unrelated untracked `.vscode`, Feature 26, Feature 30, and Feature 31
  prompt/response artifacts were left untouched.
- This prompt is saved as `prompts/01-ARCHITECTURE-AUDIT.md`.
- This document and the prompt remain unstaged.

No Feature 31 code, archive configuration, real archive, or real database was
accessed or changed during this audit.

## 5. Existing Settings architecture and reuse plan

The proposed location is architecturally correct.

Existing flow:

1. `SettingsMenuActionId` supplies stable Settings menu identity.
2. `SettingsTopMenuCassettePayload` renders the stable sidebar menu.
3. `SidebarFlowState.projectedSettingsCenterSpec` maps a persistent Settings
   context to `ViewSpec.settings(...)`.
4. `SettingsViewSpec` is the sealed center-panel contract.
5. the Settings `ViewSpecCoordinator` dispatches to a narrow resolver;
6. the resolver returns the center-panel widget.

Feature 33 should add one persistent `environment` menu action under
**Support**, one `SettingsViewSpec.environmentSummary()` case, one resolver,
and one center-panel view. `resolveSidebarUtilityChild` should return `null`
for Environment, keeping the sidebar as navigation rather than content.

Reusable presentation architecture:

- use the existing ViewSpec coordinator/resolver route;
- follow the center-pane composition conventions in
  `CenterPanelReportLayout`, `AppSpacing`, `themeColorsProvider`, and
  `themeTypographyProvider`;
- follow Feature 31's path/volume/status visual vocabulary without importing
  its private `_ArchiveLocationCard`;
- use section-local loading/error states like the coverage report rather than
  blocking the whole panel;
- use a collapsed disclosure patterned after existing Settings disclosures.

No new Settings subsystem, independent panel stack, sidebar report body, or
custom navigation mechanism is warranted.

## 6. Installation and build identity inventory

| Field | Authoritative source | Dart availability | Recommendation |
|---|---|---|---|
| Product name | `ArchiveAccessAuthority.identity.productName`, validated from native `CFBundleDisplayName` | synchronous | ordinary UI and clipboard |
| Environment | `ArchiveAccessAuthority.identity.environment` | synchronous | ordinary UI and clipboard |
| Build identity | `ArchiveAccessAuthority.identity.buildIdentity` | synchronous | ordinary UI and clipboard |
| Bundle identifier | `ArchiveAccessAuthority.identity.bundleIdentifier` | synchronous | Technical Details and clipboard |
| Archive instance UUID | `ArchiveAccessAuthority.identity.archiveInstanceId` | synchronous | Technical Details and clipboard |
| Canonical admitted root | `ArchiveAccessAuthority.rootPath` | synchronous | ordinary UI and clipboard |
| Semantic version | `PackageInfo.version` | asynchronous platform metadata | ordinary UI and clipboard |
| Build number | `PackageInfo.buildNumber` | asynchronous platform metadata | ordinary UI and clipboard |
| Runtime debug/profile/release | Flutter compile-mode constants | synchronous | Technical Details only |

Native `MessageLensNativeArchiveClaimResolver` reads environment/build
identity from the app bundle, validates the product/bundle pair, resolves the
canonical root, and returns the claim over the existing archive-admission
channel. Dart admission validates the same claim and produces the immutable
authority. A second native bridge is unnecessary.

`databaseHealthAuditServiceProvider` already uses `PackageInfo`, but it also
opens application databases and constructs a broader diagnostic service. It
must not be watched merely to obtain version metadata. Feature 33 should use a
narrow package-info provider.

Runtime environment and build identity are distinct and should both be
retained in the read model. For example, `development` is the environment;
`developmentDebug`, `developmentProfile`, or `developmentRelease` is the
build identity.

The current authority does not retain a typed “development override applied”
bit. The override is read from the process variable
`MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT` independently by native bootstrap and
Dart admission. V1 must not infer that bit from the path. The exact root still
diagnoses the stale-launch incident; typed override provenance is a deferred
gap.

## 7. Primary data-root authority

`ArchiveAccessAuthority` is the sole admitted primary-root capability. Its
identity is immutable for the process lifetime and contains the canonical
root, environment, build identity, bundle/product identity, and archive
instance UUID. `resolvePath` is the only normal way to derive archive-owned
paths.

Root selection is:

- default: the app-specific Application Support directory derived by native
  bootstrap and `path_provider`;
- development override: the canonicalized absolute directory from
  `MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT`;
- FDA experiment: the override is mandatory;
- production: a development override is rejected.

The marker `.messagelens-archive.json` binds the root to an environment and
archive instance. Its UUID is already carried in the admitted authority, so
Environment must not reread the marker.

User-facing vocabulary must separate physical placement from configuration:

- use **Data folder** for the root;
- use a real external volume segment such as `WD_ELEMENTS` when the canonical
  path is below `/Volumes/<name>`;
- use **This Mac** for an Application Support path when no authoritative
  physical volume label is available;
- never label the root “Internal” merely because it is the default;
- show **Admitted** or **Connected** only from a bounded exact-root probe, not
  from string shape alone.

Current architecture has no general typed volume UUID/filesystem probe and no
current writability state for the primary root. V1 should not show filesystem
type, device node, stable volume UUID, or “read/write” for this section.

## 8. Attachment-archive authority

Feature 31 already owns the required typed state:

- `AttachmentArchiveLocationConfiguration` supplies mode, last-known path,
  stored volume name, and custom write policy;
- `AttachmentArchiveLocationState` supplies resolved root, availability,
  physical writability, generation, and issue;
- the native bookmark adapter distinguishes available, read-only,
  unavailable, permission denied, missing directory, and invalid bookmark;
- the writable-root lease remains mutation authority and must never enter the
  Environment read model.

The reviewed Feature 31 development state is:

- admitted primary root:
  `/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development`;
- active attachment archive:
  `/Volumes/Toshiba_manual_bu/ML_ADOPTION_TEST/attachment_archive`;
- physically retained prior archive:
  `/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development/attachment_archive`.

This audit uses only source and reviewed documentation for that context. It did
not probe either volume. The retained WD archive is not fallback authority.

The active page may show:

- canonical resolved path when available, otherwise the last-known display
  path;
- volume name;
- connected/read-only/disconnected/permission-required/missing/invalid;
- default versus external in plain product language;
- location generation, configuration mode, write policy, and exact typed
  state only in Technical Details.

Bookmark bytes must never enter the read model or clipboard. Bookmark stale
state is not durably exposed after resolution: a stale bookmark may be
refreshed and persisted, but the published state has no `isStale` field.
Therefore V1 must not display a stale/non-stale claim.

### Mandatory observation-seam finding

`AttachmentArchiveLocationController._availableCustomState` calls
`_persistConfigurationUnchecked` when resolution returns refreshed bookmark,
path, or volume metadata. Thus provider initialization/refresh can write
`user_overlays.db`. Environment must not cause that path merely by opening.

Recommended prerequisite: make Feature 31 expose a typed, already-resolved
snapshot whose observation performs no persistence, or separate bookmark
refresh persistence from observation and assign it to an existing lifecycle
owner. The Environment aggregator should consume only the pure snapshot. It
must not reimplement bookmark resolution or location policy.

## 9. Message provenance architecture

The durable path is:

```text
live chat.db or selected historical chat.db
  → source_registry + source-scoped import tables in macos_import_ss.db
  → packed SourceScopedRowKey identifiers
  → projected tables in working_ss.db
  → current read models
```

`source_registry` retains:

- integer `source_id`;
- stable `source_key`;
- `source_kind`;
- optional label;
- registry creation timestamp.

Built-in sources are `live-chat-db`/`live_chat_db` and
`live-address-book`/`live_address_book`. Historical Messages sources use
`historical-messages-archive:<canonical chat.db path>` and
`historical_messages_archive`.

Every imported message receives a packed `ss_id`. The high 20 bits preserve
`source_id`; the low 43 bits preserve source-local row ID. The graph projects
that same `ss_id`, so source identity survives projection exactly even though
the graph table has no explicit `source_id` column. Indexed primary-key ranges
can recover graph counts per source without reading message content.

Historical source identity remains meaningful when the drive is gone because
the canonical source path is retained in the source key. It is identity, not
live availability.

`HistoricalArchiveSourcesRepository` also stores workflow presentation
metadata in `user_overlays.db`: label, path, preflight counts/ranges, and last
recorded workflow completion. This is useful corroboration but is not the
source of graph membership. Source cards must join registry identity to
current projected rows and treat overlay metadata as optional.

There is no durable MessageLens import-package UUID or general package
descriptor. A MessageLens data folder selected through Historical Archives is
ultimately represented as a historical `chat.db` source, not as a durable
package object.

## 10. Message provenance A–E field classification

Classification: A = already authoritative; B = cheaply derivable; C =
derivable but moderate/expensive; D = not retained; E = ambiguous/unsafe.

| Candidate field | Class | Reason / safe label |
|---|---:|---|
| Source ID, key, and kind | A | durable `source_registry` |
| Live versus historical distinction | A | `source_kind` |
| Historical canonical `chat.db` identity path | A | encoded in the validated source key |
| Current live Messages path | A | current `pathsHelperProvider.chatDBPath`; label as current source path, not persisted import identity |
| Source label | A | registry label; optional workflow label may enrich presentation |
| Projected messages by source | B | count graph PK range derived from packed source ID |
| Projected chats by source | B | packed chat ID range |
| Projected attachments by source | B | packed attachment ID range |
| Earliest/latest projected message by source | C | bounded to a source PK range but scans its rows because `date_utc` is not indexed |
| Last recorded successful historical workflow completion | A/PARTIAL | authoritative only when matching overlay metadata exists; label exactly, never “original import time” |
| Complete import timestamp/history | D | `import_batches.finished_at_utc` is never populated; registry creation is not import completion |
| Historical source available now | B | exact path probe is cheap, but optional and not needed to describe contribution |
| Source volume UUID/filesystem/device | D | not retained |
| Import/archive package UUID | D | no durable package model |
| Complete history of removed sources | E | registry entries can outlive removed rows; they are not current contributors |

### Message source presentation decision

**Decision A: present individual source cards now.** Current contributors can
be proved by joining source registry records to current graph rows through the
packed source ID. Cards should include kind/label, current projected count,
and optionally an asynchronously derived date range. Historical path and last
recorded successful workflow completion belong in per-source details, not the
headline.

Do not present overlay metadata alone as a complete import history, and omit
registered historical sources with zero current projected messages from the
ordinary “contributing sources” list.

## 11. Message aggregate and count semantics

Recommended labels:

- **Messages in MessageLens** = `COUNT(*)` of graph `messages`; this includes
  every projected record from live and historical sources, including sparse,
  system, reaction, and recovered records retained by the fidelity contract.
- **Conversations** = graph `chats`, not unique people.
- **Attachment references** = graph `message_to_attachment` edges; do not call
  this “archived files.”
- **Attachment records** = graph `attachments`; this is source metadata, not
  physical payload count.
- **FTS rows** = rows in embedded `message_text_fts`; this is an index row
  count, not the number of messages containing searchable words.

Graph totals and source totals count source-scoped records. The same Apple GUID
in two different imported sources remains two distinct source records; calling
the total “unique messages” would be misleading.

`COUNT(*)` and date aggregates do not materialize Dart rows, but SQLite still
scans the applicable table/range. Treat graph total, FTS total, and per-source
date ranges as progressive moderate SQL, not first-paint dependencies. No
attachment archive scan is necessary.

## 12. Contacts provenance architecture

Contact import discovers viable AddressBook databases, selects the most recent
aggregate path, and imports records under the fixed
`liveAddressBookSourceId == 2`. Contact and channel rows retain that source ID
in the import ledger; projected `contact_id` remains the packed source-scoped
ID.

What is not retained is decisive: the selected AddressBook database path is
not stored in `source_registry`, in each import batch, or in projected contact
rows. A later discovery pass can identify the database MessageLens would use
now, but it cannot prove that this is the physical database that contributed
each existing contact row. Historical Messages archive import does not import
Contacts.

## 13. Contacts provenance A–E field classification

| Candidate field | Class | Reason / safe label |
|---|---:|---|
| Logical source kind “Current Mac Contacts” | A | fixed live AddressBook registry source |
| Projected contact count | B | graph count or packed source range |
| Imported channel count | B | read-only count of `contact_channels` |
| Contact-to-handle link count | B | graph `contact_to_handle` count |
| Current viable AddressBook path | B | discovery can derive it now, but it is not provenance of existing rows |
| Physical contributing AddressBook path | E | current candidate can differ from the historical contributor |
| Multiple physical Contacts source identities | D | collapsed into source ID 2 |
| Contacts import completion time | E | batch starts exist; completion is not recorded |
| Historical Contacts sources | D | no such registrar/import model exists |

### Contact source presentation decision

**Decision B: present aggregate Contacts data only.** Use a single card named
**Current Mac Contacts**, show projected contacts and linked handles/channels,
and add the quiet note **Physical source identity is not retained**. Do not
show the currently discovered AddressBook path as the path that contributed
the graph.

## 14. Application database inventory

All meaningful database paths derive from `ArchiveAccessAuthority.rootPath`
plus `appDatabasePath`; no filename should be re-declared in Feature 33.

| Role | File | Owner | Current schema | V1 treatment |
|---|---|---|---:|---|
| Source-scoped import ledger | `macos_import_ss.db` | source-scoped import | 10 | Technical Details |
| Conversation graph + embedded FTS | `working_ss.db` | conversation graph | 3 | Technical Details |
| User intent and durable settings | `user_overlays.db` | overlay database | 8 | Technical Details |
| Presence experiment state | `presence.db` | Presence | 9 | show only if present, Technical Details |
| Retired import cleanup artifact | `macos_import.db` | none/current cleanup only | n/a | omit |
| Retired graph cleanup artifact | `working.db` | none/current cleanup only | n/a | omit |

Attachment-location configuration is the
`attachment_archive_location` value in overlay `overlay_settings`. Historical
source presentation metadata is `historical_archive_sources/v1` in that same
table. The archive marker is a root metadata file, not a database. FTS is
embedded in `working_ss.db`, not a separate file.

For the four relevant database summaries, use exact derived path, existence,
readability, file size, actual `PRAGMA user_version`, and expected version.
Use a one-off `sqlite3` read-only/query-only connection and close it. Do not
watch a persistent provider that can create directories, create a database,
run migrations, or write PRAGMAs merely to populate Environment.

WAL/SHM files should not be listed.

## 15. Existing health and validation evidence

Useful existing evidence:

- the keep-alive startup installation-state stream records whether admission
  was granted/withheld and whether bounded inspection or integrity validation
  was the basis;
- the bounded installation reader already demonstrates safe read-only SQLite
  inspection with `OpenMode.readOnly`, `PRAGMA query_only`, schema inventory,
  counts, and FTS probing;
- conversation-graph readiness and FTS table/trigger evidence exist;
- the maintenance lock and archive-mutation coordinator expose current
  availability without running maintenance;
- graph-build state has transient progress/error information.

V1 should show only:

- startup admission state/basis if already available in memory;
- actual/expected database schema versions;
- FTS present and row count;
- maintenance temporarily active only when it explains unavailable data.

Do not invoke the full Database Health Audit, graph health report, integrity
check, physical attachment audit, or recovery audit. Those are broader and can
perform many queries or payload I/O. Last successful graph/import times are not
coherently durable enough for V1.

## 16. Import and archive-history audit

Durable history currently consists of:

- `source_registry` identities and creation times;
- current import facts and their source IDs;
- import batch start rows (not completed sessions);
- optional Historical Archives workflow metadata in the overlay;
- current onboarding operation snapshot/failure evidence;
- an active attachment-adoption transaction while remediation is pending.

Logs and Feature 31 rehearsal documents contain richer historical detail, but
they are not product state and must not feed Environment.

The attachment adoption transaction is deliberately cleared only after final
verification. Its `previousConfiguration` and source canonical identity vanish
with it. The workflow's terminal success state is in-memory presentation state
and does not survive provider reconstruction/relaunch.

Therefore the retained WD archive is physically present according to Feature
31's reviewed record, but Feature 33 cannot claim its location after relaunch.
It is not fallback authority and must not be inferred from docs, logs, or the
known development root.

## 17. Provenance gaps

| Desired field | Why useful | Reconstructable? | Cost/change | V1 impact |
|---|---|---|---|---|
| Typed primary-root admission origin (default vs development override) | directly explains stale launches | not safely from current authority | extend native claim/resolved identity; no schema | page ships without it; root path diagnoses incident |
| Durable attachment adoption receipt/retained source | shows retained original after relaunch | no after transaction retirement | new persistence/schema or bounded receipt file | omit from V1; not misleading |
| Completed import sessions | trustworthy imported-on history | not from unfinished batch rows | schema/persistence change | omit general import history |
| Physical Contacts source identity | answers which AddressBook DB contributed | no | source registry/import schema change for future imports; old rows remain partial | ordinary Contacts must state limitation |
| Source volume UUID/filesystem | stable physical identity | no | native/filesystem infrastructure and retention | omit |
| Message import package UUID/type | distinguish packages beyond chat DB | no | new provenance model | omit |
| Central constants for import/overlay/presence schema versions | avoids duplicated expected versions | source has hard-coded values in owners/readers | small code refactor, no on-disk schema | desirable in Phase One, not blocking |

The page would be misleading without the Contacts limitation and without
omitting retained attachment source. Every other gap is deferrable.

## 18. Proposed Environment read model

The model is a presentation snapshot, never authority:

```dart
final class EnvironmentSummary {
  const EnvironmentSummary({
    required this.installation,
    required this.dataRoot,
    required this.attachmentArchive,
    required this.messages,
    required this.contacts,
    required this.technical,
  });

  final EnvironmentInstallationSummary installation;
  final EnvironmentDataRootSummary dataRoot;
  final EnvironmentAttachmentArchiveSummary attachmentArchive;
  final EnvironmentMessageDataSummary messages;
  final EnvironmentContactsDataSummary contacts;
  final EnvironmentTechnicalSummary technical;
}

enum EnvironmentAvailability {
  connected,
  readOnly,
  permissionRequired,
  disconnected,
  missing,
  invalid,
  unknown,
}

final class EnvironmentInstallationSummary {
  final String productName;
  final String? semanticVersion;
  final String? buildNumber;
  final ArchiveEnvironment environment;
  final ArchiveBuildIdentity buildIdentity;
  final String bundleIdentifier;
  final String archiveInstanceId;
  final String runtimeMode;
}

final class EnvironmentDataRootSummary {
  final String canonicalPath;
  final String displayVolumeName;
  final EnvironmentAvailability availability;
  final String? issue;
}

final class EnvironmentAttachmentArchiveSummary {
  final String? canonicalPath;
  final String? displayPath;
  final String? volumeName;
  final EnvironmentAvailability availability;
  final AttachmentArchiveLocationMode? configurationMode;
  final AttachmentArchiveCustomWritePolicy? customWritePolicy;
  final bool isReadable;
  final bool isPhysicallyWritable;
  final int locationGeneration;
  final String? issue;
}

final class EnvironmentMessageDataSummary {
  final EnvironmentSectionStatus status;
  final int? projectedMessageCount;
  final int? conversationCount;
  final int? attachmentReferenceCount;
  final DateTime? earliestMessageUtc;
  final DateTime? latestMessageUtc;
  final List<EnvironmentMessageSourceSummary> sources;
  final String? issue;
}

final class EnvironmentMessageSourceSummary {
  final int sourceId;
  final EnvironmentMessageSourceKind kind;
  final String displayLabel;
  final String? canonicalSourcePath;
  final int projectedMessageCount;
  final DateTime? earliestMessageUtc;
  final DateTime? latestMessageUtc;
  final DateTime? lastRecordedSuccessfulImportUtc;
}

final class EnvironmentContactsDataSummary {
  final EnvironmentSectionStatus status;
  final int? projectedContactCount;
  final int? linkedHandleCount;
  final int? importedChannelCount;
  final bool physicalSourceIdentityRetained; // always false in v1
  final String? issue;
}

final class EnvironmentTechnicalSummary {
  final EnvironmentSectionStatus status;
  final StartupAdmissionBasis? startupAdmissionBasis;
  final MessageLensInstallationStateKind? installationState;
  final bool maintenanceActive;
  final bool? ftsAvailable;
  final int? ftsRowCount;
  final List<EnvironmentDatabaseSummary> databases;
  final String? issue;
}

enum EnvironmentDatabaseRole {
  sourceImport,
  conversationGraph,
  userOverlay,
  presence,
}

final class EnvironmentDatabaseSummary {
  final EnvironmentDatabaseRole role;
  final String path;
  final bool exists;
  final bool readable;
  final int? sizeBytes;
  final int? userVersion;
  final int expectedVersion;
  final String? issue;
}
```

`EnvironmentSectionStatus` should be the narrow enum `ready`, `loading`,
`unavailable`, `notRetained`, `failed`. Do not put provider objects, database
handles, bookmark data, filesystem entities, exceptions, or writable leases
in these types.

The clipboard formatter accepts `EnvironmentSummary`; it does not query
providers itself.

## 19. Field-by-field source, cost, nullability, and presentation matrix

| Field | Source/derivation | Cost | Null/unavailable semantics | UI | Clipboard |
|---|---|---|---|---|---|
| Product/environment/build identity/bundle | admitted authority | memory | never null after admission | installation/technical | yes |
| Version/build number | package info | bounded platform call | `Unknown` on failure | installation | yes |
| Archive instance UUID | admitted authority | memory | never null | technical | yes |
| Primary canonical root | admitted authority | memory | never null | data folder | yes |
| Primary volume label | `/Volumes/<name>` derivation, else `This Mac` | memory | `This Mac`, not guessed disk name | data folder | yes |
| Primary availability | exact-root stat/probe | bounded filesystem metadata | typed unavailable/permission/unknown | data folder | yes |
| Attachment state/path/generation | pure Feature 31 snapshot | memory once resolved | typed state; last-known path only for unavailable | attachment | selected fields |
| Attachment volume | typed config/resolution | memory | `Unknown volume` | attachment | yes |
| Attachment mode/policy | typed config | memory | null only invalid config | technical | no mode internals by default |
| Message source registry | read-only import DB query | cheap indexed SQL | section unavailable if DB absent | sources | source count only |
| Graph totals | read-only `COUNT(*)` | moderate SQL | loading/unknown, never zero on error | messages | yes when ready |
| Per-source graph count | packed PK range | indexed range aggregate/moderate | omit zero contributors | source cards | no per-source detail |
| Per-source date range | graph PK range + MIN/MAX | moderate SQL | `Date range unavailable` | source cards | no |
| Historical recorded import completion | matched overlay metadata | cheap indexed setting read + decode | `Not retained`/omit | source detail | no |
| Contacts aggregates | read-only graph/import counts | moderate SQL | loading/unavailable | contacts | projected count only |
| Contacts physical source | unavailable | none | explicit `Not retained` | note | yes as limitation |
| DB path/existence/size | authority + `appDatabasePath` + stat | bounded filesystem metadata | typed missing/unreadable | technical | yes |
| DB user version | read-only/query-only PRAGMA | cheap SQL | unknown if missing/busy | technical | yes |
| FTS presence/count | sqlite master + FTS count | cheap inventory + moderate count | unavailable/unknown | technical | yes when ready |
| Startup admission | already-live startup state | memory | omit while unresolved | technical | concise status only |

## 20. Proposed ordinary-user center-panel layout

Top-to-bottom:

1. **Environment** title and one-line explanation.
2. **This installation** — product, version/build, Production/Development.
3. **Data folder** — volume/status headline and wrapping canonical path.
4. **Attachment archive** — volume/status, path, and `Read/write` or
   `Read-only` only when the typed state proves it.
5. **Message data** — aggregate projected Messages/Conversations, followed by
   one card per current contributing source.
6. **Contacts data** — `Current Mac Contacts`, aggregate count, and the
   provenance limitation.
7. collapsed **Technical Details**.
8. **Copy Environment Summary**.

Installation, data folder, and attachment archive form the first diagnostic
screenful. Message/Contacts aggregates may fill progressively below them.

## 21. Proposed Technical Details disclosure

Default-collapsed exact content:

- Environment — distinguishes production/development/test authority.
- Build identity — distinguishes debug/profile/release/FDA/test identity.
- Bundle identifier — catches the wrong installed product.
- Archive instance UUID — distinguishes two roots with similar names.
- Canonical primary root — catches wrong-root launch.
- Active attachment canonical/display root — catches wrong archive.
- Attachment location state and generation — explains stale/disconnected
  snapshots.
- Attachment configuration mode and write policy — explains default versus
  activated external behavior; label as technical architecture terms.
- Startup admission state/basis — confirms what validation admitted the app.
- Graph/overlay/import/presence paths, existence, size, and schema versions —
  identifies actual application stores.
- FTS presence and row count — confirms the embedded search index belongs to
  the shown graph.
- Maintenance-active state only when true — explains temporary unavailable
  evidence.

Exclude raw bookmark data, device nodes, logs, payload lists, attachment
filenames, conversation/contact content, full graph-health findings, and the
non-durable retained WD path.

## 22. Exact Copy Environment Summary format

Use stable plain text, not JSON:

```text
MessageLens Environment Summary

Installation
  Product: <product name>
  Version: <semantic version>+<build number>
  Environment: <production|development|test>
  Build identity: <build identity>
  Bundle identifier: <bundle identifier>

Data folder
  Status: <Connected|Permission required|Unavailable|Unknown>
  Volume: <volume name|This Mac|Unknown>
  Path: <absolute canonical path>

Attachment archive
  Status: <Connected · read/write|Connected · read-only|Disconnected|Permission required|Missing|Invalid>
  Volume: <volume name|Unknown>
  Path: <resolved or last-known absolute path|Unavailable>

Data
  Messages in MessageLens: <count|Unknown>
  Message sources: <count|Unknown> (<live count> current, <historical count> historical)
  Conversations: <count|Unknown>
  Contacts in MessageLens: <count|Unknown>
  Contacts provenance: Current Mac Contacts; physical source identity not retained

Technical
  Archive instance UUID: <uuid>
  Startup admission: <state and basis|Unknown>
  Import database: <path> · schema <actual>/<expected> · <size|Unknown>
  Graph database: <path> · schema <actual>/<expected> · <size|Unknown>
  Overlay database: <path> · schema <actual>/<expected> · <size|Unknown>
  Presence database: <path|Not present> · schema <actual>/<expected|Unknown>
  FTS rows: <count|Unavailable|Unknown>
```

Absolute primary, attachment, and database paths are justified because this is
an explicit user-invoked support action and those paths are what diagnose a
wrong-root incident. The UI should note that copied text contains local file
paths. Do not include historical source paths/labels by default because folder
names can contain personal information and are unnecessary for the motivating
diagnosis.

Exclude message/contact content, phone/email values, attachment filenames,
conversation titles, bookmark bytes, tokens, raw logs, and device identifiers.

## 23. Path, copy, and Reveal in Finder recommendations

- Show full paths with wrapping, never ellipsis-only truncation.
- Use `SelectableText` in normal body typography; a monospaced font is not
  needed for ordinary users.
- Make selection the consistent individual-copy interaction. Do not add a copy
  icon to every row in V1.
- Provide one prominent **Copy Environment Summary** button using Flutter's
  existing `Clipboard.setData` API and the shared formatter.
- Omit **Reveal in Finder** from V1. Existing Finder reveal code is tied to
  exported support files and is not a reusable path-navigation abstraction.
  Adding a new process/native seam is not justified for the core feature.

## 24. Availability vocabulary

Map typed evidence as follows:

| Evidence | User wording |
|---|---|
| exact path available/readable | `<Volume> · Connected` |
| attachment custom read-only | `<Volume> · Connected · Read-only` |
| external volume unavailable | `<Volume> · Disconnected` |
| bookmark permission denied | `<Volume> · Permission required` |
| configured directory missing on connected volume | `<Volume> · Folder missing` |
| invalid config/bookmark | `Attachment location invalid` |
| evidence not resolved | `Status unknown` |

Do not collapse permission, missing, disconnected, read-only, and invalid into
“Unavailable.” Do not claim “Read/write” for the primary data root because no
current typed writability evidence exists.

## 25. Partial, error, empty, and loading states

- **None**: an authoritative collection is empty, such as zero historical
  Message sources.
- **Unknown**: evidence could not determine a value.
- **Unavailable**: the owning store/path cannot currently be read.
- **Not retained**: architecture never persisted the fact (Contacts physical
  source, retired attachment source).
- **Loading**: an asynchronous aggregate is still in progress.
- **Failed**: bounded observation failed; show a short issue and retry only the
  affected section.

Installation and root identity must remain visible if Messages, Contacts, or
technical evidence fails. Attachment disconnection must not blank database
facts. A loading count should use a reserved placeholder and eventually settle
to a value or a typed unavailable state—never an indefinite whole-page
spinner.

## 26. Progressive loading strategy

First paint:

- product/environment/build identity from authority;
- admitted primary root;
- the already-resolved pure attachment snapshot if present;
- section skeletons for version and aggregates.

Then independent bounded tasks:

- package metadata;
- primary-root metadata;
- attachment state if still resolving;
- database file/schema inventory;
- Message source inventory and aggregates;
- Contacts aggregates;
- FTS count.

Each task publishes a section result. Do not await one monolithic future or
hold the panel behind Contacts/date-range work. The clipboard button may copy
the current snapshot with explicit `Unknown` values; it should not start new
work.

## 27. Performance budget

| Category | Fields |
|---|---|
| Already in memory/provider state | authority identity/root; startup state; maintenance state; pure attachment snapshot |
| Cheap bounded filesystem metadata | root existence/readability; database existence/size |
| Cheap indexed SQL | source registry; schema inventory; PRAGMA versions |
| Moderate SQL aggregate | graph/FTS/contact counts; per-source counts and date ranges |
| Expensive/unbounded | attachment payload traversal, hashes, integrity checks, source archive scans — forbidden |

Target first meaningful render: one UI frame and under 100 ms after routing
using memory state only. Target bounded metadata/version completion: under 250
ms under normal local conditions. Moderate counts load independently and must
not block interaction. Add no startup prefetch.

## 28. Read-only and purity guarantees

Opening Environment must:

- perform no overlay/database writes or schema migration;
- create no directory or database;
- persist no bookmark refresh;
- change no attachment location generation;
- trigger no import, projection, recovery, maintenance, adoption, or reset;
- read no attachment payload, filename inventory, hash, or recursive tree;
- perform no source Messages/Contacts database scan merely for provenance;
- derive all paths from admitted authority and canonical path helpers;
- use read-only/query-only SQLite connections for on-demand evidence;
- close every one-off connection;
- add no startup dependency or watcher.

The read model may carry presentation values only. It cannot issue writable
leases or expose mutation services.

## 29. Production versus Development behavior

One read model serves both.

Development typically shows `MessageLens Development`, a development build
identity, the admitted development archive UUID, the exact configured/root
path, and the active external attachment archive if configured.

Production shows `MessageLens`, production build identity, production archive
UUID, the admitted Application Support root, and either default or active
external attachment state.

FDA experiment/test identities remain representable through the same enums and
model. The page must not expose archive adoption merely because an identity is
development, and must not relax any Feature 31 production gate.

## 30. Support-diagnostic scenario analysis

The stale-build/wrong-root incident would have been diagnosed by the first
screenful and copied summary:

- product and version identify whether the binary is current;
- build identity and bundle ID identify the installation;
- canonical admitted root shows Application Support instead of the expected
  WD path;
- archive instance UUID distinguishes installations;
- attachment archive path shows which payload root is active;
- primary/attachment volume labels expose physical placement.

Typed override state would be convenient but is not required to reach the
correct conclusion. The admitted path is direct evidence; an inferred
“override failed” label would be weaker.

## 31. Architecture tripwire plan

Add focused architecture tests that prove:

- Environment feature files do not define canonical root strings, attachment
  root policy, bookmark decoding, or archive-instance creation;
- aggregation imports authority/location public seams, not native adapters or
  settings stores;
- no Environment file imports adoption, writable lease, mutation coordinator
  actions, import orchestrators, recovery services, or maintenance actions;
- no `Directory.list`, recursive walk, hash, attachment payload store, or
  archive statistics provider is reachable from the feature;
- evidence SQL is accepted by `assertReadOnlySql`, connections are read-only,
  and no persistent provider is first-opened for inspection;
- the clipboard formatter accepts the same `EnvironmentSummary` used by UI;
- Environment is absent from startup/main/onboarding dependency graphs;
- `SettingsMenuActionId → SidebarFlowState → SettingsViewSpec → coordinator →
  resolver` is the only navigation route;
- production and development authorities construct the same model shape;
- static privacy assertions reject bookmark keys, message/contact text,
  channel values, and attachment filenames from clipboard formatting;
- the pure attachment observation seam records zero setting writes and zero
  generation changes.

## 32. Test strategy

### Read model

- production, development, FDA/test identities;
- default and configured development primary roots;
- default, external, read-only, disconnected, denied, missing, and invalid
  attachment states;
- live and multiple historical Message sources with packed graph IDs;
- registered-but-removed historical source omitted from contributors;
- optional historical workflow metadata present/absent;
- aggregate Contacts with explicit non-retained provenance;
- independent section failures.

### Purity

- snapshot build leaves disposable DB hashes/mtimes and row counts unchanged;
- no overlay setting write;
- stale bookmark fake returns refreshed bytes but Environment persists nothing;
- no location-generation change;
- recording filesystem sees only exact root/database metadata, no archive
  child enumeration;
- recording services see no import, recovery, maintenance, adoption, hashing,
  or archive payload calls;
- missing DB files remain missing after observation.

### Settings and presentation

- stable Environment menu row and persistent context;
- exact center-panel ViewSpec dispatch;
- sidebar remains navigation-only;
- immediate first paint and independent progressive sections;
- long selectable/wrapping paths;
- Technical Details defaults collapsed;
- all typed unavailable states and section-level retry;
- light/dark semantic theme tokens.

### Clipboard

- exact stable format above;
- same model instance as UI;
- absolute diagnostic paths included only after explicit action;
- no message/contact content, historical custom labels/paths, attachment
  filenames, bookmark bytes, secrets, or logs;
- `Unknown`, `Unavailable`, and `Not retained` remain distinct;
- production/development fixtures.

### Performance

- first-paint aggregation performs no I/O;
- SQL returns aggregate rows only and uses packed PK ranges;
- no source or attachment archive scan;
- no startup references;
- large disposable fixtures complete within a documented moderate async
  budget without blocking first paint.

## 33. Risks and mitigations

| Risk | Mitigation |
|---|---|
| inferred provenance presented as fact | join registry to current graph; use exact labels; omit unsupported fields |
| physical volume confused with configuration mode | separate volume/status from Technical Details mode/policy |
| observing attachment provider persists refreshed bookmark | establish pure snapshot seam before UI implementation |
| persistent DB provider creates/migrates a store | use exact-path read-only/query-only evidence reader |
| large counts delay page | progressive sections; no whole-page wait; no Dart materialization |
| duplicate sources distort “unique” totals | label projected/source-scoped records, never unique Messages |
| Contacts path presented as historical contributor | aggregate only and state physical source is not retained |
| support copy leaks content | whitelist fields; exclude historical labels/paths and all user records |
| stale last-known attachment path shown as active | pair with disconnected/missing state; never call it canonical when unresolved |
| technical detail overwhelms users | collapsed disclosure and ordinary-language first screenful |
| second environment source of truth | read model accepts existing typed evidence and owns no decisions |
| retained WD inferred from rehearsal docs | omit after transaction retirement |

## 34. Proposed implementation phases

### Phase One — pure evidence and read model

1. Resolve the stop gate by approving and implementing the pure Feature 31
   attachment snapshot seam.
2. Add typed Environment read-model classes and pure formatter.
3. Add a narrow package-info provider.
4. Add a read-only/query-only environment evidence repository for source
   inventory, graph/contact/FTS aggregates, DB metadata, and schema versions.
5. Add purity/architecture/read-model tests.

Checkpoint Phase One before UI work because the no-write boundary is the
highest-risk contract.

### Phase Two — Settings center panel

1. Add stable Settings action, ViewSpec, coordinator/resolver route, and
   navigation tests.
2. Build progressive center-panel sections and collapsed Technical Details.
3. Add presentation, long-path, unavailable, and dark-mode tests.

### Phase Three — copy and qualification

1. Add the pure plain-text formatter and explicit Clipboard action.
2. Add privacy/golden-string tests and large disposable-fixture performance
   qualification.
3. Verify production/development fixtures and update release metadata only
   when implementation is approved and complete.

Reveal in Finder and schema/provenance additions are not part of these phases.

## 35. Recommended V1 scope

Ship:

- Settings → Environment center panel;
- installation/version/environment identity;
- admitted data root and bounded availability;
- authoritative active attachment location/status;
- aggregate Message facts and truthful contributing Message source cards;
- aggregate Contacts facts with the provenance limitation;
- collapsed database/schema/FTS/startup details;
- one privacy-conscious Copy Environment Summary action;
- progressive section isolation and strict purity tests.

Do not ship retained attachment source, Contacts physical path, generic import
history, volume UUID/filesystem type, archive stats, integrity controls,
individual copy buttons, or Reveal in Finder in V1.

## 36. Deferred and future opportunities

- typed root-admission origin in `ResolvedArchiveIdentity`;
- future import-session persistence with completion/outcome;
- future physical Contacts source identity for new imports;
- optional non-authoritative attachment adoption receipt if product approves
  durable retained-source history;
- Attachment Showcase/import provenance after its separate onboarding design;
- reusable path reveal abstraction;
- stable volume UUID/filesystem detail if a real support need emerges.

Do not build a generic metadata framework in anticipation of these.

## 37. Decision record

1. **Settings center panel accepted.** It reuses the established persistent
   Settings context and ViewSpec route; sidebar remains navigation.
2. **One read model for UI and clipboard.** Formatter has no providers/I/O.
3. **Authority is reused, never reconstructed.** Primary root and installation
   identity come from `ArchiveAccessAuthority`.
4. **Attachment active state is authoritative; retained source is omitted.**
5. **Message sources are shown individually.** Registry plus packed graph IDs
   proves current contributors.
6. **Contacts are aggregate-only.** Physical contributor identity was not
   retained.
7. **All database evidence is read-only and on-demand.** Persistent providers
   that can create/migrate are not inspection seams.
8. **No archive payload I/O, mutation, or startup work.** This is enforced by
   architecture and behavior tests.
9. **Absolute support paths are copied only on explicit user action.** User
   content and historical custom source paths are excluded.
10. **Implementation waits on the observation-seam gate.** The current custom
    attachment resolution path may persist refreshed metadata; the pure seam
    requires review before Feature 33 code begins.

Final explicit answers:

- **CAN ENVIRONMENT V1 SHIP WITHOUT SCHEMA CHANGES: YES.**
- **CAN MESSAGE SOURCES BE SHOWN INDIVIDUALLY AND TRUTHFULLY: YES.** Show only
  registry-backed current contributors and graph-derived facts.
- **CAN CONTACT SOURCES BE SHOWN INDIVIDUALLY AND TRUTHFULLY: NO.** A single
  logical live source remains, while physical AddressBook identity is not
  retained.
- **CAN ACTIVE ATTACHMENT LOCATION BE SHOWN AUTHORITATIVELY: YES.** Use the
  typed Feature 31 snapshot after the pure observation boundary is settled.
- **CAN RETAINED PREVIOUS ATTACHMENT LOCATION BE SHOWN AFTER RELAUNCH: NO.**
  Successful transaction retirement deletes the only durable previous-path
  record.
- **CAN COPY ENVIRONMENT SUMMARY USE THE SAME READ MODEL AS THE UI: YES.**
- **DOES OPENING ENVIRONMENT REQUIRE ANY ARCHIVE PAYLOAD I/O: NO.**
- **DOES OPENING ENVIRONMENT REQUIRE ANY DATABASE MUTATION: NO.**
- **DOES FEATURE 33 REQUIRE ANY STARTUP WORK: NO.**
- **ENVIRONMENT SUMMARY READY TO IMPLEMENT: NO.** Review and approve the pure
  attachment observation seam first; all remaining V1 work is otherwise
  supportable without schema changes.
