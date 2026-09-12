---
tier: project
scope: startup-database-validation
owner: agent-per-project
last_reviewed: 2026-09-12
source_of_truth: code
links:
  - ./README.md
  - ./00-overview.md
  - ./06-interpreting-startup-database-logs.md
  - ../10-DATABASES/00-all-databases-accessed.md
  - ../25-ONBOARDING-AND-ARCHIVE/README.md
  - ../45-NEW-FEATURE-ADDITION/30-SEARCH-ENHANCEMENT/README.md
tests:
  - ../../../test/essentials/onboarding/application/message_lens_installation_validation_service_test.dart
  - ../../../test/essentials/onboarding/application/startup_validation_telemetry_test.dart
  - ../../../test/essentials/onboarding/infrastructure/persistence/sqlite_message_lens_installation_evidence_reader_test.dart
  - ../../../test/essentials/onboarding/infrastructure/persistence/sqlite_message_lens_installation_integrity_validator_test.dart
  - ../../../test/essentials/onboarding/application/message_lens_installation_state_classifier_test.dart
  - ../../../test/essentials/onboarding/application/message_lens_installation_state_provider_test.dart
  - ../../../test/startup_installation_state_surface_test.dart
  - ../../../test/essentials/onboarding/infrastructure/compatibility/legacy_complete_installation_erase_journal_compatibility_test.dart
  - ../../../test/essentials/onboarding/application/start_fresh_service_test.dart
---

# Startup Database Validation

This document describes implemented behavior at MessageLens `0.2.110+128`.
It is not a proposal for a future validator.

## Startup Sequence and Rendering Boundary

Before `runApp`, `main.dart` performs:

1. native archive identity validation and per-archive single-instance claim;
2. a method-channel read of the immutable native archive claim;
3. Dart validation of build/environment/root identity and archive marker;
4. the legacy Complete Erase journal compatibility check;
5. SQLite FFI initialization, Rust-library initialization, macOS window
   configuration, startup-flags retrieval, MediaKit initialization, and
   provider-container construction.

Ordinary database classification is **not awaited before `runApp`**. After
`runApp`, `StartupApp` watches `messageLensInstallationStateProvider` and renders
a restricted `MacosApp` shell showing `Checking databases…`. The bounded reader
runs in `Isolate.run`, so the UI can paint while inspection proceeds.

One exception is the obsolete Complete Erase journal seam. If that journal is
present, pre-`runApp` archive admission performs ordinary archive admission and
full integrity validation before it may prove the journal stale and remove only
that unchanged journal. It fails closed on ambiguity. With no journal, it adds
no database validation to pre-`runApp` startup.

After validation resolves, persistent logger initialization and eligible window
state restoration run from a post-frame callback. Normal `App` construction—and
therefore `chatDbChangeMonitorProvider`, routing, intake, and normal writable
providers—is withheld until startup admission is granted or an explicitly
allowed user choice continues the flow.

## Bounded Evidence Reader

`SqliteMessageLensInstallationEvidenceReader.readBounded()` inspects each store
sequentially inside an isolate. For an existing file it:

- rejects a zero-byte file;
- opens SQLite with `OpenMode.readOnly`;
- sets `PRAGMA query_only = ON` and `PRAGMA busy_timeout = 3000`;
- reads `PRAGMA user_version`;
- inventories tables and triggers from `sqlite_master`;
- checks required objects;
- issues `SELECT 1 ... LIMIT 1` against required tables;
- reads the small logical facts listed below;
- disposes the connection in `finally`.

The name “bounded” means no full physical-page integrity scan and a three-second
SQLite busy timeout. It is not a formal wall-clock bound: `COUNT(*)` is used for
message/topology reconciliation and can still cost work on a large database.
The reader does not create WAL/SHM companions or migrate schemas.

An absent database is valid evidence, not automatically a failure. It may be
consistent with a virgin installation.

## Per-Database Contract

| Database | Current schema authority used by startup | Required objects and probes | Extra logical evidence |
| --- | --- | --- | --- |
| `user_overlays.db` | Startup-local ceiling `8`; Drift also independently declares `8` | For current schema: `participant_overrides`, `chat_overrides`, `message_annotations`, `message_user_flags`, `message_user_tags`, `handle_to_participant_overrides`, `virtual_participants`, `overlay_settings`, `favorite_contacts`, `dismissed_handles`, `handle_visibility_overrides`, `archived_attachments`, `conversation_tags`, `conversation_tag_assignments`, `message_intent_overlays`, `message_intent_tags`. Older supported schemas require only `overlay_settings`. Each required table receives a limited read. | Reads and decodes the durable onboarding operation snapshot from `overlay_settings`. |
| `macos_import_ss.db` | Startup-local ceiling `10`; `ImportDatabase.open` independently passes version `10` to sqflite | `messages` and `source_registry` for all supported versions; both receive limited reads. | Counts `messages`; checks whether any source is not the live Messages or live AddressBook source. |
| `working_ss.db` | Shared `conversationGraphSchemaVersion = 3` from `app_database_schema_versions.dart`; Drift and startup both consume it | Older supported schemas: `messages`, `chats`, `chat_to_message`. Current schema also requires `message_text_fts` and triggers `message_text_fts_after_insert`, `message_text_fts_after_delete`, and `message_text_fts_after_text_update`. Required tables receive limited reads; current FTS receives `SELECT rowid ... LIMIT 1`. | Counts messages, chats, and chat-to-message edges. |
| `presence.db` | Startup-local ceiling `9`; Drift independently declares `9` | `schedule_definitions` and `schedule_runs` for all supported versions; both receive limited reads. | No additional startup reconciliation facts. |

The graph constant is currently the only shared authoritative schema constant.
Import, overlay, and Presence ceilings intentionally remain duplicated in the
bounded reader and their database implementations. Future schema changes must
update both sites and their tests until those stores gain dependency-light
shared constants.

Schema versions below `1`, unknown values, and versions above the current
ceiling are `unsupportedSchema`. Versions from `1` through current are readable;
an older supported version triggers deep integrity validation before normal
admission. Startup itself does not migrate it. A later normal provider open may
perform that database's declared migration only after admission.

## Classification

The classifier applies these rules in order:

1. malformed onboarding snapshot → `remediationRequired`;
2. unreadable/unsupported overlay or Presence evidence →
   `remediationRequired` because a preserved store is affected;
3. unreadable/unsupported import or graph evidence →
   `remediationRequired`;
4. non-empty import and graph message counts agree, graph has chats and edges,
   and both bounded reads passed → `completed`;
5. snapshot says completed but durable facts do not → `remediationRequired`;
6. incomplete installation has a historical/non-live source →
   `remediationRequired` to preserve it for review;
7. no consequential derived data and idle operation → `virgin`;
8. running/interrupted, or retryable failed, operation → `resumable`;
9. otherwise → `abandoned`.

Retired `macos_import.db` or `working.db` files count as consequential evidence
for virgin/abandoned classification, but startup does not structurally inspect
those retired files.

## Escalation Policy

Ordinary healthy current-schema startup does not run `quick_check`.
`MessageLensInstallationIntegrityPolicy` requests deep validation for existing
target databases when bounded evidence shows:

- zero-byte, invalid SQLite, corrupt, I/O, missing-object, targeted-read, or
  unknown failures;
- a malformed onboarding snapshot (overlay target);
- an older supported schema;
- import/graph message-count mismatch;
- graph messages with no chats or no chat-message edges;
- a running, interrupted, or failed onboarding operation (all existing stores);
- a completed operation snapshot whose durable facts require remediation
  (overlay, import, and graph);
- a non-live source in an installation not classified completed (import and
  graph).

Targets are ordered overlay, import, graph, Presence and filtered to files that
exist. If suspicious triggers exist but no target exists, startup rejects rather
than pretending validation succeeded.

SQLite `BUSY` or `LOCKED` from bounded inspection is **contention**, not
corruption. It yields `StartupValidationBlocked` immediately and does not launch
another competing deep scan. An unsupported schema is also not corruption; it
is rejected without `quick_check` because physical integrity cannot make a
future schema supported.

## Physical Integrity Validation

`SqliteMessageLensInstallationIntegrityValidator` runs each requested database
in a separate `Isolate.run` call. It opens read-only, enables `query_only`, sets
a three-second busy timeout, and executes:

```sql
PRAGMA quick_check(1)
```

`quick_check` scans physical SQLite integrity. The `(1)` limits the number of
reported errors, not the number of pages inspected, so it can be expensive on
large import or graph databases. Success requires exactly one result value,
`ok`. Other results are failure; `BUSY`/`LOCKED` is returned separately as
contention.

Startup deep validation checks only policy-selected existing databases. By
contrast, `validateFully()` checks every existing app database unless bounded
inspection found an unsupported schema or contention, in which case it returns
`fullIntegrityValidated: false` without claiming full proof.

Full validation is currently required at these explicit safety boundaries:

- `StartFreshService` after its authorized derived-data reset, before it accepts
  the resulting installation as virgin;
- the obsolete Complete Erase journal compatibility seam before it removes a
  proven-stale unchanged journal.

## Validation Telemetry Boundary

The ordinary post-`runApp` startup-validation stream records a small typed event
sequence in `StartupValidationTelemetryBuffer`. The buffer exists independently
of writable databases. It records validation start, four per-database bounded
completions, the escalation decision, any selected integrity checks, and the
final classification/admission outcome. Per-database and total durations use
monotonic `Stopwatch` measurements.

After classification resolves, persistent startup initialization awaits the
application log writer, flushes buffered events with source
`StartupValidation`, and retains the immutable event snapshot for support
export as `startup_validation.json`. Event fields are allow-listed enums,
booleans, schema/result codes, database identifiers, safe environment/build
identity, and durations; failure messages and content values are excluded.

The exceptional pre-`runApp` legacy-journal `validateFully()` path is not part
of this event sequence. A blocked contention state also cannot flush or export
under the current classification-failure UI, although its final event remains
buffered in memory until process exit.

## Outcomes and UI

| Outcome | Current behavior |
| --- | --- |
| Bounded checks need no escalation | Emits `StartupBoundedInspectionPassed`, then grants admission for `virgin`, `resumable`, or `completed`; withholds it for `abandoned` or `remediationRequired`. |
| Deep check passes | Briefly shows `Physical database check complete…`, then applies the same classification-based grant/withhold rule. |
| Deep check fails | Produces `remediationRequired`; normal app remains unavailable and the startup attention dialog offers log export and quit. |
| Future/otherwise unsupported schema | Admission is withheld; it is not treated as repairable corruption. |
| Bounded or deep contention | Shows the startup classification-failure surface with the busy/locked reason; no automatic reset or repair occurs. |
| Logical classification fails after physical pass | Admission is still withheld. Physical integrity does not prove import/graph coherence. |
| `abandoned` | Startup dialog may offer preservation-scoped `Start Fresh` after explicit authorization. |
| `remediationRequired` | No Start Fresh button is offered by the startup dialog; export/quit remain the safe actions. |

While unresolved, the shell shows only checking/progress/failure/remediation UI.
It does not build the normal router or start `ChatDbChangeMonitor`.

## Historical Note

Earlier startup code ran `quick_check(1)` on every app database before
`runApp`. Large import/graph stores caused long native white-window intervals.
The current design moved Flutter rendering earlier and split cheap structural
and logical evidence from policy-driven deep physical validation. This is
historical context, not permission to weaken the current escalation policy.
