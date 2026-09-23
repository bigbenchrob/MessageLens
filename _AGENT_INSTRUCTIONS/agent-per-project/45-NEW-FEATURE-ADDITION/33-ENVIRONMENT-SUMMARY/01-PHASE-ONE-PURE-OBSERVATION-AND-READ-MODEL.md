# Environment Summary — Phase One Pure Observation and Read Model

## 1. Outcome

Phase One establishes the non-UI Environment Summary foundation. It provides
one immutable read model, independent progressive evidence providers, a
strictly read-only SQLite repository, a pure text formatter, and a passive
attachment-location observation seam owned by Feature 31.

This phase does not add a Settings route, a center-panel view, a Clipboard
action, Finder actions, startup work, schemas, or migrations. The entire Phase
One implementation remains unstaged for review.

## 2. Audit checkpoint

The approved architecture audit and its initiating prompt were checkpointed
before implementation:

- commit: `84f0d3f0fcea3d3b752a125632254561a270ddae`
- subject: `docs(environment): add environment summary architecture audit`
- branch: `feature/environment-summary`

The Phase One prompt is retained as
`prompts/02-PHASE-ONE-PURE-OBSERVATION.md`. All feature documentation uses the
corrected Feature 33 folder number.

## 3. Attachment observation ownership

Feature 31 remains the only owner of attachment-location resolution,
configuration persistence, generation changes, reconnect behavior, writable
leases, adoption, and mutation policy.

`AttachmentArchiveLocationObservation` is colocated with the existing Feature
31 location owner. It begins as `null` and does not watch or initialize the
location provider. After Feature 31 completes its normal load or refresh work,
the owner publishes an immutable `AttachmentArchiveLocationSnapshot` through a
library-private method.

The snapshot contains only presentation evidence:

- typed availability;
- location generation;
- readable and physical-writability facts;
- configuration mode and custom write policy;
- canonical and last-known display paths;
- volume name and typed issue text.

It deliberately excludes bookmark bytes, writable leases, controllers,
adoption authority, mutation authority, callbacks, native adapters, and
reset/delete capability.

### Feature 31 changes

The Feature 31 delta is intentionally small:

1. add the immutable snapshot entity;
2. add the passive, keep-alive observation provider beside the location owner;
3. publish a snapshot only after the owner's existing load/refresh work has
   completed;
4. export the entity and observation provider through the existing attachment
   feature seam;
5. regenerate the Riverpod output.

Normal Feature 31 refresh behavior is unchanged. If native bookmark resolution
returns refreshed metadata, Feature 31 may still persist that metadata through
its existing controller before publishing the snapshot. Watching the passive
observation provider neither causes that resolution nor adds another write.

Tests prove that observing the snapshot does not initialize the location
owner. A refreshed-bookmark fixture also proves that the legitimate Feature 31
owner persists exactly once, while any number of passive Environment reads add
zero persistence calls, zero resolution calls, and zero generation changes.

## 4. Typed Environment read model

The immutable read model consists of:

- `EnvironmentSummary`;
- `EnvironmentInstallationSummary`;
- `EnvironmentDataRootSummary`;
- `EnvironmentAttachmentArchiveSummary`;
- `EnvironmentMessageDataSummary`;
- `EnvironmentMessageSourceSummary`;
- `EnvironmentContactsDataSummary`;
- `EnvironmentTechnicalSummary`;
- `EnvironmentDatabaseSummary`.

Typed enums cover availability, section status, database role, Message source
kind, and runtime mode. Section state distinguishes `ready`, `loading`,
`unavailable`, `notRetained`, and `failed`.

No provider, database handle, filesystem entity, bookmark, lease, controller,
service, or callback is retained by the model. Production and development use
the same model shape; environment and build identity are data, not divergent
architectures.

## 5. Installation and admitted data-root evidence

The synchronous identity foundation comes from the already-admitted
`ArchiveAccessAuthority`:

- product name;
- environment;
- build identity;
- bundle identifier;
- archive instance UUID;
- canonical primary data-root path.

Feature 33 consumes this authority but does not construct, select, alter, or
own it. The admitted root itself is the evidence; the feature does not infer a
development-override flag from a path.

Semantic version and build number come from a narrow
`EnvironmentPackageInfoReader` seam backed by `PackageInfo`. The feature does
not watch Database Health merely to obtain package metadata and introduces no
native bridge.

Root inspection is bounded to exact-root `FileSystemEntity.typeSync` metadata.
It does not create, enumerate, traverse, or test-write the root. Paths below
`/Volumes/<name>` produce the physical volume display name; other admitted
paths use `This Mac`. The model does not invent filesystem type, device node,
volume UUID, or root writability.

## 6. Database repository and SQL safety

`SqliteEnvironmentEvidenceRepository` inspects only exact current V1 database
paths derived through `appDatabasePath`:

- `macos_import_ss.db`;
- `working_ss.db`;
- `user_overlays.db`;
- `presence.db`, when present.

The repository does not list sidecars or inspect superseded database files. It
checks file existence and size directly, then opens existing databases with
SQLite `OpenMode.readOnly`. Each handle enables connection-local
`query_only`, sets a bounded busy timeout, and is disposed in `finally`.
Production queries run in a background isolate.

Every SQL statement is routed through
`assertEnvironmentSummaryReadOnlySql`. The shared guard rejects mutation
statements, while the Environment guard admits only these PRAGMAs:

- `query_only = ON`;
- `busy_timeout = 3000`;
- `user_version`.

No persistent application database provider is used for inspection. Missing
databases remain missing; no directory, database, table, migration, WAL, or SHM
file can be created by observation.

The repository returns path, existence, readability, file size, actual
`user_version`, expected schema version, and typed issue evidence for each
role. Database failures are section-local rather than fatal to the whole
summary.

## 7. Schema-version ownership

The existing dependency-light
`lib/essentials/db/app_database_schema_versions.dart` now owns all four current
V1 schema-version constants:

- source-scoped import: `10`;
- Conversation Graph: `3`;
- user overlay: `8`;
- Presence: `9`.

The source import, overlay, and Presence database owners now consume these
constants, as does the existing bounded onboarding evidence reader. This is a
constant extraction only: no version changed and no schema or migration was
added. Generated Riverpod hashes affected by the dependency changes were
regenerated.

## 8. Message provenance and count semantics

Message source identity comes from `source_registry` in the source-scoped
import database. Current graph membership comes independently from packed
source-scoped `messages.ss_id` ranges in the Conversation Graph. Historical
keys are parsed through the existing typed
`HistoricalArchiveSourceIdentity` authority.

For each registry source, the repository computes the inclusive packed-ID
range and counts currently projected Message rows in that range. Sources with
zero current projected Messages are omitted. Duplicate Apple GUID values in
different source scopes remain distinct because membership is source-ID based,
not GUID-deduplicated.

The model labels counts as projected Messages, Conversations, and attachment
references. It does not call them unique Messages. Earliest/latest dates are a
separate provider and query so source cards can appear while range evidence is
still loading or failed.

Historical canonical `chat.db` identity may appear because the durable
registry proves it. That identity is not a current-availability claim. Feature
33 does not use Historical Archives overlay labels or paths as membership
authority and does not invent an original-import timestamp.

## 9. Contacts, FTS, startup, and maintenance evidence

Contacts evidence is aggregate-only:

- projected Contact count;
- linked-handle count;
- imported-channel count.

`physicalSourceIdentityRetained` is always false. The currently discoverable
AddressBook path is not retained or presented as provenance for already
projected Contacts.

FTS evidence is limited to checking for the embedded `message_text_fts` table
in `working_ss.db` and counting its rows. It never rebuilds, repairs, or runs an
integrity check.

Startup admission evidence and database-maintenance state are consumed only
when their providers already exist in the active container. Environment does
not initialize either subsystem. If an already-live maintenance lock is
active, database evidence providers return typed unavailable state before
opening a database.

## 10. Progressive aggregation and failure isolation

`environmentSummaryProvider` is a synchronous composition over independent
evidence streams.

Immediate evidence includes admitted installation identity, the canonical
data root, and any already-published attachment snapshot. Independent async
providers load package metadata, exact-root metadata, database metadata,
Message provenance/counts, per-source date ranges, Contacts aggregates, and
FTS evidence.

The provider never awaits one giant future. Each section maps its own loading,
unavailable, and failed state, so one error cannot discard unrelated evidence.
No provider is made globally persistent solely for Environment and there is no
startup prefetch.

## 11. Pure support formatter and privacy boundary

`EnvironmentSummaryFormatter` accepts only `EnvironmentSummary` and emits the
stable sections:

- `Installation`;
- `Data folder`;
- `Attachment archive`;
- `Data`;
- `Technical`.

The formatter imports no Riverpod, filesystem, SQLite, platform, Flutter UI,
or Clipboard API and performs no I/O. It preserves `Unknown`, `Unavailable`,
and `Not retained` distinctions.

Explicit support output may include the active primary, attachment, and
database paths. It excludes Message/contact content, contact values,
conversation titles, attachment filenames, historical custom labels and
paths, bookmark bytes, device nodes, logs, tokens, and secrets. Phase One adds
no Clipboard invocation.

## 12. Purity and performance proof

Disposable fakes and SQLite fixtures provide behavioral proof rather than a
timing assumption:

- passive attachment observation initializes no location owner;
- Environment adds no overlay or bookmark persistence;
- Environment changes no attachment generation;
- no archive directory listing, payload open, or hash API is reachable;
- every SQL statement is observed and accepted by the strict named guard;
- mutation SQL and write-affecting PRAGMAs are rejected;
- database bytes and modification times remain identical after observation;
- absent database paths remain absent;
- packed source ranges include both documented boundaries;
- duplicate GUIDs across source scopes are counted independently;
- zero-row registry sources are omitted;
- maintenance-active evidence suppresses every repository call;
- section failures do not fail the aggregate model.

All filesystem and database behavior tests use disposable temporary fixtures.
No test opens either real archive or the user's real MessageLens databases.

## 13. Architecture enforcement

The dedicated Feature 33 architecture suite enforces that Environment:

- defines no root policy or personal root string;
- owns no bookmark decoding, native attachment adapter, writable lease,
  adoption, reset, delete, import, recovery, or maintenance action;
- performs no attachment archive traversal, hashing, or payload access;
- uses no persistent database provider for evidence;
- has no startup, `main.dart`, onboarding, Settings UI, or Clipboard coupling;
- keeps the formatter dependent only on the read model;
- has one production/development model shape;
- contains no retained previous attachment path;
- contains no physical Contacts provenance field.

The repository-wide architecture inventory explicitly records the new
diagnostic repository as an approved direct read-only SQLite and database-path
consumer. It also inventories the two Environment providers as read-only
consumers of the admitted root authority. The generic SQLite tripwire now
recognizes the stricter Environment SQL guard; it does not relax the query
rules within that guard.

## 14. Files changed

### Feature 31 observation seam

- `lib/features/attachments/domain/entities/attachment_archive_location_snapshot.dart`
- `lib/features/attachments/application/attachment_archive_location_provider.dart`
- `lib/features/attachments/application/attachment_archive_location_provider.g.dart`
- `lib/features/attachments/feature_level_providers.dart`
- `test/features/attachments/application/attachment_archive_location_observation_provider_test.dart`

### Feature 33 foundation

- `lib/features/environment_summary/domain/entities/environment_summary.dart`
- `lib/features/environment_summary/domain/services/environment_summary_formatter.dart`
- `lib/features/environment_summary/application/environment_evidence_repository.dart`
- `lib/features/environment_summary/application/environment_package_info_reader.dart`
- `lib/features/environment_summary/application/environment_evidence_providers.dart`
- `lib/features/environment_summary/application/environment_evidence_providers.g.dart`
- `lib/features/environment_summary/application/environment_summary_provider.dart`
- `lib/features/environment_summary/application/environment_summary_provider.g.dart`
- `lib/features/environment_summary/infrastructure/repositories/platform_environment_package_info_reader.dart`
- `lib/features/environment_summary/infrastructure/repositories/sqlite_environment_evidence_repository.dart`
- `lib/features/environment_summary/feature_level_providers.dart`

### Schema constants and existing consumers

- `lib/essentials/db/app_database_schema_versions.dart`
- `lib/essentials/source_scoped_import/infrastructure/import_database_provider.dart`
- `lib/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart`
- `lib/essentials/presence/infrastructure/data_sources/local/presence_database.dart`
- `lib/essentials/onboarding/infrastructure/persistence/sqlite_message_lens_installation_evidence_reader.dart`
- `lib/essentials/onboarding/application/message_lens_installation_state_provider.g.dart`
- `lib/features/settings/application/sidebar_cassette_spec/resolvers/attachment_archive_settings_resolver.g.dart`
- `test/essentials/db/app_database_files_test.dart`

### Tests, architecture, and documentation

- `test/features/environment_summary/application/environment_evidence_providers_test.dart`
- `test/features/environment_summary/application/environment_summary_provider_test.dart`
- `test/features/environment_summary/domain/services/environment_summary_formatter_test.dart`
- `test/features/environment_summary/infrastructure/repositories/sqlite_environment_evidence_repository_test.dart`
- `test/architecture/environment_summary_architecture_test.dart`
- `test/architecture/forbidden_imports_test.dart`
- `prompts/02-PHASE-ONE-PURE-OBSERVATION.md`
- this decision record.

## 15. Validation

- Riverpod code generation: passed.
- Dart formatting: passed.
- focused Feature 33 and attachment-observation suite: 23 passed.
- affected Feature 31 regression ladder: 153 passed.
- complete architecture suite: 481 passed.
- `flutter analyze --no-pub`: no issues found.
- complete Flutter repository suite: 2,588 passed, 1 skipped, 0 failed.
- native tests: not required; no native source changed.

The final handoff also requires `git diff --check`, documentation-reference
validation, and repository/submodule status inspection.

## 16. Non-invention and stop-gate result

No mandatory stop gate was reached. The passive snapshot made attachment state
observable without Environment initializing the mutation-capable location
path, and all requested aggregates were available through bounded SQL without
schema changes, database creation, or unbounded Dart materialization.

The product model does not contain the physically retained WD archive because
no durable current product state proves a previous attachment location. It
also does not contain a physical Contacts source path because that provenance
is not retained with projected Contacts.

Feature 33 owns no environment authority; performs no archive payload I/O and
no database or overlay mutation; persists no bookmark refresh; changes no
attachment generation; triggers no import, recovery, maintenance, or adoption;
adds no startup work; and does not access real production data or the real
external archives.

## 17. Phase Two handoff

Phase Two may build the approved Settings navigation and center-panel
presentation over `environmentSummaryProvider`, using the same read model and
the pure formatter. It must not bypass the model to read providers directly,
add a second authority, initialize attachment resolution, or turn a support
action into a mutation path.

Phase Two has not begun.
