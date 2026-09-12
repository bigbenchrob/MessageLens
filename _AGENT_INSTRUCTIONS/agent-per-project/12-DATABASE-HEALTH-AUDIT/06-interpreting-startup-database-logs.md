---
tier: project
scope: startup-database-troubleshooting
owner: agent-per-project
last_reviewed: 2026-09-12
source_of_truth: code
links:
  - ./README.md
  - ./05-startup-database-validation.md
  - ./10-support-bundle-integration.md
  - ../50-ENVIRONMENT-SAFETY/00-overview.md
tests:
  - ../../../test/startup_installation_state_surface_test.dart
  - ../../../test/essentials/onboarding/application/message_lens_installation_validation_service_test.dart
  - ../../../test/essentials/onboarding/application/startup_validation_telemetry_test.dart
  - ../../../test/essentials/onboarding/infrastructure/persistence/sqlite_message_lens_installation_evidence_reader_test.dart
  - ../../../test/essentials/onboarding/infrastructure/persistence/sqlite_message_lens_installation_integrity_validator_test.dart
  - ../../../test/essentials/logging/infrastructure/support_bundle_export_service_test.dart
  - ../../../test/architecture/startup_validation_telemetry_privacy_test.dart
---

# Interpreting Startup Database Logs

Use this guide when a user reports that MessageLens would not admit an
installation or showed a database warning. Begin read-only. Never infer that a
reset is safe from a single error string.

## Investigation Order

1. Did native and Dart archive/environment admission succeed?
2. Is the evidence from the tooling console, `diagnostic_report.log`,
   `startup_validation.json`, or a `database_health.json` generated later?
3. Which app database was implicated: overlay, import, graph, or Presence?
4. Was the problem path/file access, SQLite open, schema, required object,
   targeted read, logical reconciliation, `quick_check`, contention, or durable
   onboarding state?
5. Did startup request deep validation, and for which target(s)?
6. Did deep validation pass, fail, or encounter contention?
7. Was admission granted, withheld, or blocked?
8. Did the UI offer remediation, Start Fresh, log export, or only a failure
   message?
9. Was a support bundle actually created, and does it contain
   `startup_validation.json` plus `database_health.json` or
   `database_health_error.json`?

## Actual Markers Emitted Today

The table below lists exact event/marker strings in current source. Structured
startup-validation events use persistent source `StartupValidation` after the
pre-logger buffer is flushed.

| Marker | Channel and meaning | What should normally follow |
| --- | --- | --- |
| `MessageLens archive identity admission failed: ...` | Native `NSLog`; native build/archive or single-instance bootstrap failed before Dart admission. | Native alert or termination. Persistent app logging is not available. |
| `Archive admission failed: ...` | Dart `debugPrint`; claim/root/marker admission or legacy-journal compatibility failed before `runApp`. | Native archive-failure presentation; no normal Flutter app admission. |
| `Could not present archive admission failure: ...` | Dart `debugPrint`; reporting the original archive failure also failed. | Use console output; no persistent support bundle exists from this path. |
| `Legacy Complete Erase journal disposition: <name>; <diagnostics>` | Dart `debugPrint`; a legacy journal existed and was safely classified/removed. It is not printed when no journal exists. | Continued startup after `removedStalePreEraseJournal` or `removedStalePostInstallJournal`. A thrown `Legacy Complete Erase journal blocked startup [<code>]` instead means fail-closed admission. |
| `Startup flags: optionLaunchResetRequested=...` | Dart `debugPrint`; pre-`runApp` startup flags were read. | Restricted Flutter startup shell and database inspection. |
| `startup_validation_started` | Buffered structured event. Includes `validation_id`, telemetry/policy versions, and safe archive environment/build identity. | Four `startup_bounded_inspection_completed` events in overlay/import/graph/Presence order. |
| `startup_bounded_inspection_completed` | One buffered structured event per app database. Includes stable database key, existence, observed/current schema when known, schema disposition, bounded result, typed failure/contention category and SQLite code when present, and `duration_microseconds`. | Three more bounded events, then `startup_integrity_decision`. |
| `startup_integrity_decision` | Explicit policy outcome: `notRequired`, `required`, `rejectedUnsupportedSchema`, `rejectedNoExistingTarget`, or `blockedByContention`. Required decisions also include stable triggers, grouped trigger categories, and selected targets. | Final admission for no-deep/rejected/blocked paths, or per-target integrity events. |
| `startup_integrity_check_started` | A selected database is about to run the existing deep `quick_check(1)` path. | Matching completion for the same `validation_id` and database. |
| `startup_integrity_check_completed` | Includes normalized `integrity_result`, typed integrity failure category/SQLite code when present, and duration. It never includes raw `quick_check` row text. | Next target or final admission. |
| `startup_admission_decided` | Final classification, stable reason code, admission basis when applicable, granted/withheld/blocked outcome, and total validation duration. | Persistent initialization for resolved grant/withhold states; restricted failure UI for blocked contention. |
| `App launch` with source `App` | Persistent app logger is ready after classification and buffered validation events have been flushed. | `Resolved startup flags`. |
| `Resolved startup flags` with source `StartupFlags` | Persistent structured context includes `optionLaunchResetRequested`, `installationKind`, and `installationReason`. This is the principal persisted classification evidence. | Normal admission or startup dialog according to kind and flags. |
| `Startup continued` / `Startup stopped by user` | Persistent source `StartupDialog`; records the user's dialog decision. | Normal app or process exit. |
| `Export Logs clicked` | Persistent source `StartupDialog`; export began from the remediation dialog. | `Startup log export succeeded` with `exportPath`, or `Startup log export failed`. |
| `Start Fresh failed: ...` | Persistent source `StartupDialog`; authorized Start Fresh threw. | Dialog remains available; do not infer which database failed without more evidence. |
| `Advanced Start Fresh failed: ...` | Persistent source `AdvancedStartFresh`; advanced reset failed. | Manual diagnosis and preservation review. |
| `Persistent startup initialization failed: ...` | Dart `debugPrint`; logger/window-state initialization failed after classification. | Startup classification-failure surface. |

The UI also exposes non-log evidence:

- `Checking databases…` means bounded inspection/provider resolution is pending.
- `Databases okay` means bounded inspection passed, not necessarily that final
  admission has rendered yet.
- “found something suspicious” and `Checking database N of M` mean policy-driven
  physical integrity validation is running.
- `Physical database check complete…` means selected deep checks passed.
- “couldn't determine whether this installation is safe to open” represents a
  blocked/provider-error state, commonly including contention text.
- “setup needs attention” means admission is withheld for an abandoned,
  remediation, or physical-integrity-failure outcome.

## Structured Startup Validation Telemetry

The post-`runApp` startup validator records typed events in a process-lifetime
memory buffer before the persistent logger is available. Once classification
has a resolved installation state, persistent initialization awaits the log
writer, flushes each not-yet-flushed event as source `StartupValidation`, and
retains the same events for `startup_validation.json`. Repeated flushes do not
duplicate entries.

All fields are allow-listed structural/status facts. The model has no fields for
message text, contact identities, URLs, attachment paths/names, archive paths,
raw rows, raw SQL results, or freeform exception messages. Human-readable
bounded/integrity failures remain in their existing internal models but are not
copied into startup telemetry.

Two pre-persistent limitations remain:

- pre-`runApp` native/Dart archive admission and the exceptional legacy-journal
  `validateFully()` path still rely on console/native diagnostics rather than
  these events;
- bounded or deep contention yields `StartupValidationBlocked`, which has no
  resolved installation state. Its final blocked event remains buffered, but
  the current classification-failure surface has no export action and does not
  initialize the persistent logger.

Do not claim a support artifact exists unless export actually succeeded.

## Common Interpretations

| Evidence | Interpretation | Recommended response |
| --- | --- | --- |
| `startup_admission_decided` has `completed`, `durableStoresReconciled`, and `granted` | Current import and graph message counts/topology reconciled; startup granted admission. | Reassure if UI admitted normally; investigate later issues separately. |
| Bounded event has `schema_disposition: unsupported` | Unsupported schema, not proven corruption. | Do not downgrade or edit `user_version`. Preserve files and escalate to a developer/version-compatibility review. |
| Decision/result is `blockedByContention` or `busyOrLocked` | Contention; the validator deliberately did not call it corruption. | Quit duplicate app/tooling processes, retry once, and ask for more evidence if persistent. Do not reset. |
| `bounded_failure_category: missingRequiredObject` and trigger category `structural` | Structural mismatch; startup requests deep validation for the affected existing database. | Correlate the selected target and deep completion; do not create the object manually. |
| Import/graph message counts differ, or graph has messages without topology | Logical inconsistency, even if SQLite is physically sound. | Request support bundle and inspect Phase 1 relationship evidence. Avoid manual row repair/reset. |
| `Physical database check complete…` | `quick_check(1)` returned `ok` for all selected targets. | Continue interpreting logical classification; physical pass does not force admission. |
| “failed physical integrity validation” | At least one selected `quick_check` did not return exactly `ok`. | Preserve all data, request support evidence, and escalate to developer/manual diagnosis. |
| Onboarding operation is running/interrupted/failed | Startup deep-validates every existing app database before classifying safe resume/attention. | Ask for operation context and bundle; use only the offered recovery path. |
| Legacy journal blocked startup | Pre-`runApp` compatibility proof failed closed. | Capture console/native error and code; do not remove the journal manually. |
| `database_health_error.json` | Phase 1 support audit failed after bundle assembly began. It is not itself the startup failure. | Read its message/stack, retain `diagnostic_report.log`, and escalate if normal providers could not open. |

## Non-Negotiable Safety Warnings

- Do not recommend deleting or resetting databases merely because validation
  failed.
- Do not equate schema mismatch, logical mismatch, or `SQLITE_BUSY` with
  corruption.
- Do not alter `PRAGMA user_version`, create missing tables/triggers manually,
  rebuild FTS, or run SQLite repair commands on user data as a first response.
- Do not remove an archive marker, legacy journal, database, WAL/SHM file, or
  `attachment_archive/` before its preservation role is understood.
- Do not run Start Fresh unless the current UI and documented authorization path
  explicitly permit it.
- Prefer offline/read-only evidence and a verified backup/checkpoint before any
  developer-led mutation.

## What to Request From the User

Ask for, in order:

1. a screenshot or exact startup message;
2. launch console output if failure happened before `App launch`;
3. the generated support bundle, if export succeeded;
4. `startup_validation.json`, `diagnostic_report.log`, and either
   `database_health.json` or `database_health_error.json`;
5. confirmation that no second MessageLens or database tool was open.

Never ask the user to send raw app databases as the routine first diagnostic.
