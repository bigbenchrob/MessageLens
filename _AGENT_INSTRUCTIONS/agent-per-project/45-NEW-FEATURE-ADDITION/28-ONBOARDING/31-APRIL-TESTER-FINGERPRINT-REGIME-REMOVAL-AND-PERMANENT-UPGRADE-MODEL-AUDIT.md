# April Tester Fingerprint Regime Removal and Permanent Upgrade Model Audit

## Status

- Audit date: 2026-09-05
- Governing request: `prompts/31-REMOVAL-AUDIT.md`
- Branch audited: `Ftr.archive-recovery`
- Scope: read-only repository audit plus this documentation artifact
- Application code, schemas, databases, and user archive data changed: none

## Executive conclusion

The April 2026 tester-install compatibility regime can be removed without
weakening the permanent archive-upgrade model.

That regime is a separable branch in startup admission. It recognizes one
exact historical database fingerprint, grants a special
`legacyTesterInstallDetected` authority, presents a dedicated deletion-only
surface, and invokes the whole-install erase machinery. No current database
migration depends on that fingerprint or authority.

The permanent model should be:

1. Prove that the selected Application Support root belongs to this
   MessageLens environment using the archive marker and native build claim.
2. Open each owned database through that database's current authority.
3. Read the database's own schema version.
4. Apply a known, sequential migration when required.
5. Verify database integrity and installation-level coherence.
6. Refuse unknown, corrupt, foreign, or unsupported state without deleting it.

Application release versions are not database schema versions. An installation
must not be classified by matching its entire collection of databases to a
release-era fingerprint.

The archive marker remains necessary. It identifies ownership, environment,
and archive instance identity; it is not an April tester fingerprint. Its role
should be retained and described in those narrower terms.

The user-facing Complete Erase feature is already absent from the intended
product surface. Once the April deletion path is removed, the remaining
whole-root replacement implementation has no required product caller and can
be removed in a separate, explicit slice. `Start Fresh` / message-data reset is
database-level current-install recovery and must remain. Attachment archive
preservation remains inviolable.

No audit stop condition was encountered:

- Current installs do not require the April exact fingerprint.
- Production startup does not depend on the special legacy authority.
- Root ownership can be separated from historical fingerprint recognition.
- All four live stores own independent schema-version and migration paths.
- The proposed removal does not require a broad database redesign.

## Decision table

| Concern | Classification | Decision |
| --- | --- | --- |
| Exact April database/table/version fingerprint | A — April-only | Remove |
| `legacyTesterInstallDetected` authority mode | A — April-only | Remove |
| Legacy tester deletion service, action, and view | A — April-only | Remove |
| Archive marker and archive instance UUID | B — current ownership/safety | Keep, simplify descriptions |
| Native archive/build claim validation | B — current ownership/safety | Keep |
| Non-empty unmarked-root rejection | B — current ownership/safety | Keep |
| Per-store `user_version` and migrations | C — schema evolution | Keep |
| Current installation evidence and integrity checks | D — current preservation/recovery | Keep |
| `Start Fresh` / message-data reset | D — current preservation/recovery | Keep |
| Attachment archive | D — preservation data | Keep; never erase during reset/recovery |
| Whole-root Complete Erase machinery | E — unrelated residual product cruft after A | Remove separately after caller proof |
| Historical prompts and responses | Historical record | Retain, but mark superseded in active indexes |

## Existing architecture

### Startup sequence

`main.dart` currently performs the following high-level sequence:

1. Obtain the native archive claim and canonical Application Support root.
2. Resume an interrupted Complete Erase transaction, if one exists.
3. Construct `ArchiveAdmissionService` with
   `ReadOnlySqliteLegacyTesterInstallInspector`.
4. Admit or reject the root.
5. Initialize persistent resources only after admission.
6. Route one of three authority modes:
   - `full` to the normal application,
   - `completeEraseOnly` to an erase-only startup surface,
   - `legacyTesterInstallDetected` to a tester-deletion surface.

The third path is the April compatibility regime. The first path is the
permanent normal path. The second path belongs to whole-root erase recovery and
is not needed to recognize current installations.

### Current April fingerprint path

For a production, non-bootstrap, non-empty root with no marker,
`ArchiveAdmissionService` calls `LegacyTesterInstallInspector`.

The SQLite implementation accepts only an exact historical arrangement:

- retired `macos_import.db` at `PRAGMA user_version = 4`,
- retired `working.db` at `PRAGMA user_version = 3`,
- `user_overlays.db` at `PRAGMA user_version = 3`,
- exact expected table sets for each database,
- no marker,
- no current-only `macos_import_ss.db`, `working_ss.db`, or `presence.db`.

An exact match returns `ArchiveAccessMode.legacyTesterInstallDetected`. A
non-match is rejected as `nonEmptyUnmarkedArchive`; an inspection failure is
reported as `legacyTesterInspectionFailed`.

The dedicated deletion service then:

1. Requires the special legacy mode.
2. Acquires the archive mutation operation
   `legacyTesterInstallDeletion`.
3. Confirms that persistent resources have not been opened.
4. Reuses `FileSystemCompleteInstallationEraseStore` to erase owned state.
5. Installs a virgin marker.
6. Verifies the result.
7. Relaunches the application.

This is a closed compatibility island. It does not participate in ordinary
database opening or migration.

## Dependency graph

```text
main.dart
  -> ArchiveAdmissionService
       -> LegacyTesterInstallInspector (April-only)
            -> retired/current filename and exact SQLite fingerprint checks
       -> ArchiveMarkerStore (permanent ownership)
       -> ArchiveIdentityValidator (permanent ownership/environment safety)
  -> ArchiveAccessAuthority
       -> full (permanent)
       -> completeEraseOnly (whole-root erase machinery)
       -> legacyTesterInstallDetected (April-only)
  -> LegacyTesterInstallDetectedView (April-only)
       -> deletion action/provider/presentation/service (April-only)
            -> ArchiveMutationCoordinator
            -> FileSystemCompleteInstallationEraseStore
            -> virgin verifier and relaunch

normal admitted startup
  -> persistent database providers
       -> macos_import_ss.db migration authority
       -> working_ss.db migration authority
       -> user_overlays.db migration authority
       -> presence.db migration authority
  -> current installation evidence reader/classifier
       -> per-store version/integrity/coherence evidence
```

The only bridge from the April island to current code is through shared
admission/authority types and reused whole-root erase infrastructure. Those
bridges are narrow and can be pruned without changing database migration code.

## A — April-only implementation to remove

### Delete complete files

#### Archive environment

- `lib/essentials/archive_environment/application/legacy_tester_install_inspector.dart`
- `lib/essentials/archive_environment/domain/legacy_tester_install_inspection.dart`
- `lib/essentials/archive_environment/infrastructure/read_only_sqlite_legacy_tester_install_inspector.dart`

#### Onboarding application and domain

- `lib/essentials/onboarding/application/legacy_tester_install_deletion_action.dart`
- `lib/essentials/onboarding/application/legacy_tester_install_deletion_action_provider.dart`
- `lib/essentials/onboarding/application/legacy_tester_install_deletion_action_provider.g.dart`
- `lib/essentials/onboarding/application/legacy_tester_install_deletion_presentation_provider.dart`
- `lib/essentials/onboarding/application/legacy_tester_install_deletion_presentation_provider.g.dart`
- `lib/essentials/onboarding/application/legacy_tester_install_deletion_service.dart`
- `lib/essentials/onboarding/application/legacy_tester_install_deletion_service_provider.dart`
- `lib/essentials/onboarding/application/legacy_tester_install_deletion_service_provider.g.dart`
- `lib/essentials/onboarding/domain/legacy_tester_install_deletion_presentation.dart`
- `lib/essentials/onboarding/presentation/legacy_tester_install_detected_view.dart`

### Delete dedicated tests and fixtures

- `test/architecture/legacy_tester_install_inspection_boundary_test.dart`
- `test/essentials/archive_environment/infrastructure/read_only_sqlite_legacy_tester_install_inspector_test.dart`
- `test/essentials/onboarding/application/legacy_tester_install_deletion_action_test.dart`
- `test/essentials/onboarding/application/legacy_tester_install_deletion_integration_test.dart`
- `test/essentials/onboarding/application/legacy_tester_install_deletion_service_test.dart`
- `test/essentials/onboarding/presentation/legacy_tester_install_detected_view_test.dart`
- `test/test_support/legacy_tester_install_fixture.dart`

### Edit mixed-use files

- `lib/main.dart`
  - stop constructing the legacy inspector,
  - remove legacy-view routing,
  - retain the normal admission path and current safety failures.
- `lib/essentials/archive_environment/application/archive_admission_service.dart`
  - remove the inspector dependency and exact-match branch,
  - continue to reject a non-empty unmarked root,
  - continue to create/read and validate markers for valid current roots.
- `lib/essentials/archive_environment/domain/archive_access_authority.dart`
  - remove `legacyTesterInstallDetected`.
- `lib/essentials/archive_environment/domain/archive_admission_exception.dart`
  - remove `legacyTesterInspectionFailed`,
  - remove the currently unused `missingMarker` member if no new caller is
    introduced,
  - retain current ownership/environment/root-safety failures, including
    `nonEmptyUnmarkedArchive`.
- `lib/essentials/archive_environment/domain/archive_mutation_operation.dart`
  - remove `legacyTesterInstallDeletion` and its reopen-blocking branch.
- `lib/essentials/archive_environment/application/archive_mutation_coordinator_provider.dart`
  - remove special legacy authority handling.
- `lib/essentials/archive_environment/infrastructure/file_system_complete_installation_erase_store.dart`
  - remove the legacy-mode allowance if this store survives until the separate
    Complete Erase slice.
- `lib/essentials/archive_environment/application.dart`
- `lib/essentials/archive_environment/domain.dart`
- `lib/essentials/archive_environment/infrastructure.dart`
  - prune legacy exports.
- `test/startup_installation_state_surface_test.dart`
  - remove only the legacy recognition surface case and its legacy imports;
    retain current startup-state coverage.
- `test/essentials/archive_environment/application/archive_admission_service_test.dart`
  - remove exact-legacy and inspection-failure cases,
  - retain marker, identity, bootstrap, and unmarked-root rejection cases.
- `test/essentials/archive_environment/application/archive_mutation_coordinator_provider_test.dart`
  - remove legacy-operation cases; retain current coordinator coverage while
    current mutation operations remain.
- `test/essentials/archive_environment/infrastructure/file_system_complete_installation_erase_store_test.dart`
  - remove the legacy-authority case; otherwise defer this test to the
    whole-root erase slice.
- `test/architecture/forbidden_imports_test.dart`
  - remove legacy inspector/deletion files from allowed-file sets,
  - remove the April-specific legacy terminology allowance after checking that
    no valid current symbol still requires it,
  - retain unrelated architectural boundaries.

## Exception-surface audit

| Exception/failure | Current role | Decision |
| --- | --- | --- |
| `legacyTesterInspectionFailed` | Reports failure of the April exact-fingerprint probe | Remove |
| `missingMarker` | Defined but no live caller was found | Remove as dead state |
| `nonEmptyUnmarkedArchive` | Prevents silently adopting arbitrary existing content as owned MessageLens state | Keep |
| Marker format/environment mismatch | Prevents opening foreign or incompatible owned roots | Keep |
| Native claim, bundle, signature, canonical-root, or test-safety mismatch | Production environment safety | Keep |
| Unknown/unsupported per-store schema | Prevents unsafe migration/opening | Keep and report through store/current-install diagnostics |
| SQLite integrity failure | Current-install preservation/recovery evidence | Keep |

After the April inspector is removed, an unmarked, non-empty historical tester
root follows the ordinary safety path: it is rejected as an unowned root. The
tester remedy is the newly documented manual deletion of the old MessageLens
Application Support folder. Startup should not attempt to identify or delete
that state.

## B — Archive marker and archive instance UUID

### Verdict: keep, but simplify the explanation and call sites

The marker is not an application-release fingerprint. Its current fields
identify:

- marker format version,
- environment,
- archive instance UUID,
- creation time.

That is valid permanent ownership metadata. It answers “does MessageLens own
this root, for this environment?” before persistent stores are opened. It does
not answer “which app release created every database?” and should never be used
for that purpose.

The archive instance UUID is likewise useful as stable identity for one owned
archive root. It must not be compared with a hard-coded tester UUID and must
not replace each database's own schema version.

Required simplification after removal:

- describe marker validation as root ownership/environment validation,
- remove language suggesting that absence of a marker should initiate
  historical release detection,
- preserve refusal to claim a non-empty unmarked root,
- preserve native claim and marker coherence checks,
- preserve lock-file/bootstrap handling for a valid virgin startup.

## C — Per-database schema evolution

All live stores already have independent version authorities and migration
paths. None consults the April fingerprint inspector.

| Store | Current file | Current schema version | Migration authority | Audit result |
| --- | --- | ---: | --- | --- |
| Source-scoped import | `macos_import_ss.db` | 10 | sqflite open callback with ordered `< version` migrations through contacts, semantic source fields, attachments, projection indexes, and self-identity | Keep |
| Conversation graph | `working_ss.db` | 2 | Drift migration strategy; create/upgrade path builds idempotent schema and adds missing columns | Keep; strengthen explicit future version steps rather than infer releases |
| User overlay | `user_overlays.db` | 8 | Drift sequential migrations from earlier user versions through archived attachments, tags/flags, graph intent, conversation tags, and visibility policy | Keep |
| Presence | `presence.db` | 9 | Drift sequential migrations through fixed destinations, FDA tests, execution trace, settings actions, readiness, generic test grammar, activation, and choices | Keep |

The retired `macos_import.db` and `working.db` filenames have no current
persistent database providers. They should remain retired-artifact diagnostics
only until the relevant current-install cleanup policy is separately reviewed;
they must not be used to classify a release generation.

### Permanent migration rules

For each live store:

1. The store declares one current schema version.
2. The store reads its own on-disk version when opened.
3. Every supported older version has an ordered, tested migration path.
4. A version newer than the application understands is rejected without
   mutation.
5. An older version without a known path is rejected without mutation.
6. Integrity is checked after migration before the store becomes authoritative.
7. User intent remains only in `user_overlays.db`; projection rebuilds do not
   copy it into derived stores.
8. Attachment archive payloads are never part of a rebuildable-store deletion.

Existing migration coverage must remain, including:

- conversation graph opening of user versions 0 and 1,
- overlay migrations from user versions 1, 5, 6, and 7,
- presence version 5, 7, and 9 migration scenarios plus related older-schema
  routing tests,
- import-database migration tests appropriate to each future schema change.

One follow-up improvement is advisable but is not required for April removal:
centralize the maximum supported version constants consumed by current
installation evidence so they cannot drift from the database declarations.
That is a focused maintainability change, not a combined release fingerprint.

## D — Current installation evidence, preservation, and recovery

The current installation evidence reader/classifier is conceptually different
from the April fingerprint inspector and must remain.

`SqliteMessageLensInstallationEvidenceReader` collects current facts such as:

- presence and usability of each live database,
- per-store `PRAGMA user_version`,
- required current tables,
- `quick_check` integrity,
- import and graph row/topology coherence,
- historical import-source presence,
- retired-artifact presence,
- current operation snapshot from the overlay store.

`MessageLensInstallationStateClassifier` uses those facts to classify current
onboarding/recovery state as virgin, resumable, completed, abandoned, or
remediation-required. This is evidence-based recovery for current supported
schemas. It does not require an exact multi-database release fingerprint.

Keep:

- the current evidence reader and classifier,
- current per-store usability and integrity checks,
- interrupted-operation recovery,
- database-level `Start Fresh` / message-data reset,
- overlay and presence preservation rules,
- source-scoped archive and attachment preservation,
- refusal to continue when facts disagree with a supposedly completed state.

The permanent startup model should use two clearly separated gates:

```text
Gate 1: root ownership and environment
  native claim + canonical path + marker
  -> owned/current root, virgin bootstrap, or safe refusal

Gate 2: store compatibility and installation coherence
  each store's user_version + known migration + integrity
  -> usable, resumable, recoverable, or safe refusal
```

Neither gate needs to identify a named app release.

## E — Whole-root replacement and Complete Erase residue

The root-replacement machinery currently has three categories of caller:

1. the April legacy deletion path,
2. Complete Erase UI/action/service code,
3. startup recovery of an interrupted Complete Erase transaction.

No independent current archive-upgrade or database-migration caller was found.
The user-facing Complete Erase operation is no longer part of the intended
product. Therefore, after removing the April path, a separate removal slice
should delete the residual whole-root feature rather than retaining a dormant
authority capable of permanently deleting the Application Support root.

Candidate removal set includes:

- complete-installation erase authorization dialog and overlay,
- presentation model, action/provider, service/provider, and virgin verifier,
- complete erase transaction and store interfaces,
- `FileSystemCompleteInstallationEraseStore`,
- `completeEraseOnly` authority,
- `completeInstallationErase` mutation operation,
- startup transaction recovery and erase-only startup surface,
- sidebar action intent/dispatcher reachability,
- dedicated Complete Erase tests and architecture boundary test,
- generated provider files.

Before that slice deletes anything, perform one final caller search and preserve
any generic lock/transaction primitive that has acquired a separate current
caller. Do not conflate this removal with `Start Fresh`.

## Documentation audit

### Active/canonical documentation to revise during implementation

- `28-ONBOARDING/README.md`
  - replace the exact tester-generation status with the permanent two-gate
    model,
  - label the April responses as historical/superseded,
  - link this audit and the eventual implementation record.
- `25-ONBOARDING-AND-ARCHIVE/10-onboarding-gate.md`
  - remove legacy-install and Complete Erase product guidance,
  - document marker ownership followed by per-store migration/integrity.
- `50-ENVIRONMENT-SAFETY/00-overview.md`
  - remove erase-only and root-replacement authority from the current model,
  - retain marker/native-claim environment safety.
- `10-DATABASES/00-all-databases-accessed.md`
  - remove the statement that whole-install erase is a current exception,
  - retain the live/retired database inventory and provider ownership rules.
- project documentation indexes and start-here pages
  - point to the permanent upgrade model rather than an April compatibility
    response.

### Historical records

Earlier prompts and responses document why the compatibility regime existed.
They need not be erased. Keep them as historical decision records, but ensure
their enclosing README/index labels them superseded so an agent does not treat
them as current implementation instructions.

## Test and architecture-tripwire audit

### Remove with April code

Delete the dedicated inspector, deletion action/service/integration, view, and
boundary tests listed in section A.

### Edit rather than delete

- startup surface tests: retain current state and normal application tests;
  remove the legacy surface case only,
- admission tests: retain marker and root-safety behavior,
- mutation coordinator tests: retain any operation still current after each
  removal slice,
- filesystem erase tests: remove with the later whole-root erase slice except
  for any generic primitive still used elsewhere,
- forbidden-import tests: remove obsolete allowlist entries while preserving
  all unrelated dependency boundaries.

### Add or strengthen during implementation

- an admission test proving a non-empty unmarked root is safely refused without
  invoking a historical inspector,
- a virgin/bootstrap admission test proving marker creation still works,
- marker mismatch tests proving foreign/current-root safety remains,
- per-store upgrade tests for every supported predecessor version,
- newer-than-supported and unknown-version refusal tests,
- current installation evidence tests proving version/integrity failures route
  to remediation without deletion,
- a repository tripwire forbidding reintroduction of exact cross-store release
  fingerprints into startup admission.

## Concrete removal plan

The following slices are deliberately ordered so each can be reviewed and
tested independently.

### Slice A — Remove April recognition and deletion

1. Delete the legacy inspector, inspection model, deletion action/service/view,
   providers, generated providers, fixture, and dedicated tests.
2. Remove the inspector branch from admission.
3. Remove `legacyTesterInstallDetected`,
   `legacyTesterInstallDeletion`, and `legacyTesterInspectionFailed`.
4. Remove the legacy startup surface from `main.dart`.
5. Make non-empty unmarked state take the existing safe-refusal path directly.
6. Prune barrels, architecture allowlists, and mixed-use tests.
7. Verify analyzer, architecture tests, targeted admission/startup tests, then
   full Flutter tests.

Expected user-visible result: old tester roots are no longer recognized or
deleted by MessageLens. Remaining testers follow the manual Application Support
deletion instructions. Current marked installs continue normally.

### Slice B — Establish and document the permanent upgrade model

1. Make the two startup gates explicit in names, comments, and canonical docs.
2. Keep marker/native claim as ownership authority only.
3. Keep per-store schema versions and migrations as compatibility authority.
4. Ensure unknown/newer/corrupt stores fail safely without root mutation.
5. Centralize supported-version values used by evidence readers where feasible
   without coupling the databases.
6. Add the permanent tripwire and missing failure-path tests.

Expected result: future upgrades are designed and tested per database, with no
release-era archive fingerprint.

### Slice C — Remove residual whole-root Complete Erase machinery

1. Re-run a repository-wide caller search.
2. Remove UI/action/service/transaction/store code and generated providers.
3. Remove `completeEraseOnly` and `completeInstallationErase` branches.
4. Remove startup transaction recovery and erase-only surface.
5. Remove sidebar reachability and dedicated tests.
6. Retain `Start Fresh`, message-data reset, marker admission, archive locks,
   and attachment preservation.
7. Verify no remaining runtime path recursively deletes the owned archive root.

Expected result: no dormant in-app whole-root deletion authority remains.

### Slice D — Reconcile canonical documentation and release guidance

1. Update the active documents listed above.
2. Mark April prompts/responses as historical/superseded in indexes.
3. Update tester guidance to say that affected testers manually delete the old
   Application Support folder before installing the current build.
4. Record analyzer, targeted-test, full-test, and manual-startup verification.
5. Include release metadata if the implementation is tester/user-facing under
   the repository's release rules.

## Risks and controls

| Risk | Control |
| --- | --- |
| Accidentally weakening current-root ownership | Retain marker/native claim and non-empty unmarked refusal; add direct tests |
| Confusing `Start Fresh` with Complete Erase | Treat them as separate services and remove only whole-root callers |
| Deleting preservation data | Preserve `attachment_archive/` invariant and avoid broad-root deletion entirely |
| Losing user overlay intent during migration/rebuild | Keep overlay independent; never dual-write or restore it into projection stores |
| Version constants drifting between databases and evidence reader | Derive or centralize maximum supported versions without combining store identities |
| Historical docs misleading future agents | Preserve records but mark them superseded in active indexes |
| Generated Riverpod files left stale | Regenerate after provider deletion; never hand-edit generated files |

## Approval boundary for implementation

This audit does not authorize code deletion. Each implementation slice should
be approved before mutation, should preserve unrelated dirty worktree changes,
and should stop if a current production caller or migration dependency appears
that contradicts this audit.

The recommended next approval is Slice A only. Slice C should remain separate
because it removes a broader destructive capability even though the caller
audit presently indicates that capability is residual.

## Verification performed for this audit

- Traced startup admission and all archive authority modes.
- Traced the exact SQLite fingerprint classifier and dedicated deletion path.
- Audited exception declarations and call sites.
- Audited marker and archive instance UUID responsibilities.
- Audited live filenames, schema versions, and migration authorities for all
  four current databases.
- Audited current installation evidence and state classification.
- Audited Complete Erase and root-replacement callers.
- Inventoried dedicated and mixed-use tests.
- Inventoried canonical and historical documentation references.
- Made no application-code, schema, database, or archive-data changes.
