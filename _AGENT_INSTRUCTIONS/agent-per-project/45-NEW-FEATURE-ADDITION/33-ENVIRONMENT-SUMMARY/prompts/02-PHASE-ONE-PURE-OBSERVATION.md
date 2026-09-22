# Feature 33 — Environment Summary
## Phase One — Pure Observation and Read Model

**Numbering correction:** Environment Summary was initially created as `32-ENVIRONMENT-SUMMARY`, but that number conflicted with an existing feature folder. Codex has renamed it to `33-ENVIRONMENT-SUMMARY` and updated internal references. All references below use Feature 33.

Read in full:

`_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/33-ENVIRONMENT-SUMMARY/00-ARCHITECTURE-AUDIT-AND-DESIGN.md`

Treat its decision record and V1 scope as authoritative. Do not begin Settings UI implementation yet.

## Step 0 — checkpoint the approved audit

Expected branch: `feature/environment-summary`
Expected pre-audit-commit HEAD: `2c8bbaae5da30300dda8d4e9e3eaef57e353cea4`

1. Inspect the renamed Feature 33 audit and Prompt 01.
2. Verify all internal references use `33-ENVIRONMENT-SUMMARY`.
3. Stage only those intended Feature 33 documentation files.
4. Leave unrelated untracked files untouched.
5. Run `git diff --cached --check`.
6. Commit as `docs(environment): add environment summary architecture audit`.

Do not push. Report the commit hash.

## Objective

Implement only the non-UI foundation:

1. pure attachment-location observation seam;
2. typed Environment read model;
3. narrow package/build evidence;
4. read-only/query-only DB/provenance evidence;
5. progressive section aggregation;
6. pure plain-text Environment Summary formatter;
7. purity/performance/architecture tests.

Do NOT add the Settings Environment page, Clipboard invocation, Reveal in Finder, schemas, or migrations.

## 1. Pure attachment-location observation seam

The audit found that `AttachmentArchiveLocationController._availableCustomState` may persist refreshed bookmark/path/volume metadata while resolving a custom location. Feature 33 must not initialize/watch that mutation-capable path and claim to be read-only.

Feature 31 must remain sole owner of location resolution/persistence. Feature 33 may observe only a presentation-safe typed snapshot without initiating bookmark resolution/refresh/persistence, generation changes, adoption, reset/delete, writable-root authority, or duplicate location policy.

Choose the smallest safe architecture: preferably an already-live Feature 31 snapshot, or a clean separation between pure observation and Feature-31-owned refresh persistence. Do not add startup work solely for Environment.

If current attachment state cannot be obtained without Environment initiating mutation-capable resolution: **STOP AND REPORT**.

The snapshot may contain mode, display/last-known path, canonical path when resolved, volume name, typed availability, physical writability, generation, issue, and write policy. It must not contain bookmark bytes, writable leases, adoption/mutation authority, controllers, persistence callbacks, native adapters, reset/delete capability.

Tests must cover default, active external, read-only, disconnected, permission denied, missing folder, invalid configuration, and stale/refreshed bookmark. Prove Environment observation performs zero overlay writes, bookmark persistence, generation changes, archive traversal, and payload I/O.

Do not achieve purity by disabling legitimate Feature 31 persistence globally. Add regressions proving normal Feature 31 refresh/reconnect/generation/writable-lease/adoption/reset/delete/gate behavior remains intact.

## 2. Typed read model

Implement immutable presentation-evidence types equivalent to:

`EnvironmentSummary`, `EnvironmentInstallationSummary`, `EnvironmentDataRootSummary`, `EnvironmentAttachmentArchiveSummary`, `EnvironmentMessageDataSummary`, `EnvironmentMessageSourceSummary`, `EnvironmentContactsDataSummary`, `EnvironmentTechnicalSummary`, `EnvironmentDatabaseSummary`.

Use narrow enums equivalent to `EnvironmentAvailability`, `EnvironmentSectionStatus`, `EnvironmentDatabaseRole`, `EnvironmentMessageSourceKind`.

Section states must distinguish `ready`, `loading`, `unavailable`, `notRetained`, `failed`.

No provider objects, DB handles, filesystem entities, bookmark bytes, leases, mutation authority, controllers, or service references may enter these types.

## 3. Installation and primary-root evidence

Use admitted `ArchiveAccessAuthority` for product name, environment, build identity, bundle ID, archive UUID, and canonical primary root. Add a narrow `PackageInfo` seam for semantic version/build number. Do not watch Database Health Audit merely for PackageInfo and do not add a native bridge.

Do not infer whether the development override was applied; the admitted root is the evidence.

For the data root, use bounded exact-root metadata only. `/Volumes/<name>/...` may yield the volume display name; otherwise use `This Mac` where appropriate. Do not invent filesystem type, device node, volume UUID, or writability. No recursive root inspection.

## 4. Read-only database evidence

Create a narrow Feature 33 repository opening exact paths read-only/query-only. Do not use persistent app DB providers that can create files/directories, migrate, write PRAGMAs, or initialize state.

Inspect only current V1 stores: `macos_import_ss.db`, `working_ss.db`, `user_overlays.db`, and `presence.db` if present. No WAL/SHM listing and no retired DBs in V1.

For each: path, exists, readable, size, actual `PRAGMA user_version`, expected schema version, typed issue. Missing DBs must remain missing. Reuse authoritative schema-version constants; make only minimal constant extraction if necessary. No schema/migration changes.

Every Feature 33 SQL statement must pass the repository's canonical read-only SQL assertion. No INSERT/UPDATE/DELETE/CREATE/DROP/ALTER/VACUUM/REINDEX or write PRAGMAs.

## 5. Message provenance and aggregates

Use `source_registry` plus current graph membership via packed source-scoped IDs. Do not use Historical Archives overlay metadata as graph-membership authority.

For current contributors support source ID/key/kind, optional registry label, Current Mac Messages vs historical archive classification, projected Message count, and optionally independently loading earliest/latest dates. Omit registry sources with zero current projected Messages.

Historical canonical `chat.db` identity may be retained in detail evidence because the registry proves it, but do not claim current availability unless separately observed. Optional workflow-completion metadata may enrich details but must never be called original import date/first import/complete import history.

Add read-only aggregate queries for Messages in MessageLens, Conversations, attachment references if retained, FTS rows, and per-source counts. Do not materialize Message rows in Dart and do not call totals “unique messages.”

Add packed-ID tests for live/multiple historical sources, duplicate Apple GUIDs across source scopes, zero-current-row registry entries, and range boundaries.

## 6. Contacts, FTS, startup evidence

Contacts are aggregate-only: Current Mac Contacts, projected contact count, linked-handle count, imported-channel count where cheap. Explicitly encode that physical source identity is not retained. Do not present the currently discoverable AddressBook path as provenance.

FTS is embedded in `working_ss.db`: observe presence/row count read-only; never rebuild/repair/integrity-check it.

Reuse only already-live in-memory startup admission/basis and maintenance-active evidence. Do not invoke Database Health Audit, graph health, integrity validation, recovery audits, attachment physical audits, imports, or maintenance.

## 7. Progressive aggregation and isolation

Do not make one giant future wait for everything.

Immediate evidence: installation authority, canonical data root, already-resolved pure attachment snapshot where available.

Independent async evidence: PackageInfo, exact-root metadata, DB metadata/schema, Message sources/counts, Contacts counts, FTS count, per-source date ranges.

One failed section must not fail the whole Environment model. No startup prefetch or global keep-alive cache solely for Environment.

## 8. Pure clipboard formatter

Implement the formatter now, but not the Clipboard action. It accepts only the Environment read model and performs no provider reads, filesystem/DB I/O, `BuildContext`, or Clipboard calls.

Stable sections: `Installation`, `Data folder`, `Attachment archive`, `Data`, `Technical`.

Absolute primary/attachment/database paths are allowed for explicit support output. Exclude Message/contact content, phone/email values, conversation titles, attachment filenames, historical custom labels/paths by default, bookmark bytes, device nodes, logs, tokens/secrets. Preserve `Unknown`, `Unavailable`, and `Not retained` distinctions.

Add golden/privacy tests for production/development fixtures and architecture tests preventing provider/filesystem/DB/Clipboard imports in the formatter.

## 9. Purity/performance instrumentation

Using disposable spies/fakes prove Feature 33 observation performs zero archive `Directory.list`, attachment payload opens, hashes, DB writes, overlay writes, bookmark persistence, generation changes, import/recovery/maintenance/adoption actions, missing-DB creation, migrations, and startup dependencies.

Do not rely on timing alone.

## 10. Explicit non-invention rules

Do not add the retained WD attachment archive to the product read model. The successful Feature 31 transaction retired the only durable previous-path record; personal knowledge, logs and docs are not product state.

Do not present the currently discoverable AddressBook path as the source of already-projected Contacts.

Cover both limitations in tests.

## 11. Architecture tripwires

Prove Feature 33 defines no root policy/strings, performs no bookmark decoding, imports no native attachment adapter or mutation/adoption/reset/delete authority, imports no import/recovery/maintenance action services, performs no archive traversal/hash/statistics, uses only read-only DB inspection seams, does not use persistent DB providers as inspection seams, has a formatter consuming only the read model, has no startup/main/onboarding dependency, uses one model shape for production/development, and contains no retained previous attachment path or physical Contacts provenance field.

## 12. Documentation

Save this prompt as:

`_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/33-ENVIRONMENT-SUMMARY/prompts/02-PHASE-ONE-PURE-OBSERVATION.md`

Create:

`_AGENT_INSTRUCTIONS/agent-per-project/45-NEW-FEATURE-ADDITION/33-ENVIRONMENT-SUMMARY/01-PHASE-ONE-PURE-OBSERVATION-AND-READ-MODEL.md`

Document the audit checkpoint, observation-seam ownership, Feature 31 changes, purity proof, read model, installation/root evidence, DB repository/SQL safety, schema-version ownership, Message provenance/count semantics, Contacts limitation, FTS/startup evidence, progressive aggregation, formatter/privacy, instrumentation, tripwires, files changed, validation, and Phase Two handoff.

## 13. Mandatory stop-and-report gates

STOP AND REPORT if:

- attachment state cannot be observed without Environment initiating mutation-capable resolution;
- purity requires disabling legitimate Feature 31 persistence globally;
- a V1 field requires archive payload traversal/hashing;
- an aggregate requires unbounded Dart materialization;
- read-only evidence requires creating/migrating a DB;
- truthful Message provenance cannot be obtained from registry + graph;
- basic V1 requires schema/migration changes;
- production/development require divergent model architecture;
- startup coupling is required;
- real production data access or real WD/Toshiba archive mutation is required.

Do not solve through a stop gate. Report and wait.

## 14. Validation

Run at minimum:

1. pure attachment snapshot tests;
2. affected Feature 31 location regressions;
3. Environment read-model tests;
4. installation/root evidence tests;
5. DB metadata/read-only SQL tests;
6. Message provenance/packed-range/aggregate tests;
7. Contacts aggregate/limitation tests;
8. FTS evidence tests;
9. formatter/golden privacy tests;
10. section error-isolation tests;
11. purity/performance instrumentation;
12. Feature 33 architecture tripwires;
13. broader architecture suite;
14. relevant attachment regressions;
15. code generation if used;
16. `flutter analyze`;
17. full repository suite if production changes are substantial, otherwise justify the regression ladder;
18. `git diff --check`;
19. documentation/reference validation.

Native tests only if native code changes; native changes are not expected. All filesystem/DB tests use disposable fixtures.

## Completion state

Leave Phase One entirely **unstaged** for review. Do not commit Phase One, push, begin Phase Two UI work, add the Settings Environment route, or add Clipboard invocation.

Report:

- audit checkpoint commit;
- branch/current HEAD;
- pure attachment observation architecture;
- exact Feature 31 changes;
- proof of zero Environment-triggered bookmark persistence;
- read-model structure;
- DB evidence design;
- Message provenance result;
- Contacts limitation;
- progressive aggregation design;
- formatter/privacy result;
- schema-version ownership changes;
- files changed;
- tests/results;
- architecture/analyze/full-suite results;
- any stop gate;
- complete Git status.

Explicitly confirm Feature 33 owns no environment authority; performs no archive payload I/O or DB/overlay mutation; persists no bookmark refresh; changes no attachment generation; triggers no import/recovery/maintenance/adoption; adds no startup work; invents neither retained WD nor Contacts physical provenance; and does not access/modify real production data or the real WD/Toshiba archives.

Then STOP. Do not begin Phase Two.
