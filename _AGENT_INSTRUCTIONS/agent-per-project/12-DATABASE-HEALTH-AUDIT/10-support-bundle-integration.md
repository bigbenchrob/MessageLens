---
tier: project
scope: database-health-audit
owner: agent-per-project
last_reviewed: 2026-09-12
source_of_truth: code
links:
  - ./README.md
  - ./00-overview.md
  - ./05-startup-database-validation.md
  - ./06-interpreting-startup-database-logs.md
  - ../25-ONBOARDING-AND-ARCHIVE/00-overview.md
tests:
  - ../../../test/essentials/logging/infrastructure/support_bundle_export_service_test.dart
  - ../../../test/essentials/onboarding/application/startup_validation_telemetry_test.dart
  - ../../../test/architecture/startup_validation_telemetry_privacy_test.dart
  - ../../../test/essentials/logging/application/diagnostic_report_actions_test.dart
  - ../../../test/essentials/db/application/database_health_audit/database_health_audit_service_test.dart
---

# Support Bundle Integration

This document describes the implemented diagnostic export path and its limits.
The support bundle is diagnostic evidence; it is not a startup admission token.

## Orchestration

`diagnosticReportExporterProvider` resolves the persistent app logger,
`databaseHealthAuditServiceProvider`, admitted archive authority, and the
process-lifetime startup-validation telemetry buffer. It builds:

```text
SupportBundleDiagnosticReportExporter
  -> LogExportService
    -> SupportBundleExportService
      -> StartupValidationTelemetrySnapshotSource.snapshot()
      -> DatabaseHealthAuditService.writePhase1Report()
```

The database-health provider awaits normal persistent providers for
`macos_import_ss.db`, `working_ss.db`, and `user_overlays.db`. Its Phase 1
queries are read-only, but provider construction can create/open/migrate those
active databases according to their normal lifecycle. Retired
`macos_import.db` and `working.db` are inspected through one-off read-only file
layers and are not created by the audit.

There is currently **no special startup-safe exporter** that constructs the
health audit solely from independent read-only connections.

## Trigger Points

The normal diagnostic exporter is reached from:

- startup attention dialog `Export Logs`;
- sidebar `SendLogsRequested`;
- Contacts settings `Send Logs…`;
- onboarding failure `Send Report To Developer`;
- Environment Readiness failure reporting;
- pipeline-incident reporting.

The startup classification-failure surface used for blocked/provider-error
states displays text only; it does not currently expose the startup dialog's
export button.

## Bundle Construction

Bundles are written under the persistent logger directory as:

```text
support_bundle_<YYYY-MM-DD_HHMMSS>/
```

Always written after export begins successfully:

- `diagnostic_report.log`
- `startup_validation.json`

Copied when present and accepted as ordinary files:

- `import_log` — retired import audit history;
- `migrate_log` — retired projection audit history;
- `pipeline_incident_log` — current pipeline incident report.

Generated when the Phase 1 audit succeeds:

- `database_health.json`

Generated instead when report writing throws or the returned report path is not
a safe bundle-local diagnostic file:

- `database_health_error.json`

Raw `.db`, `.db-wal`, and `.db-shm` files are rejected as attachments. The
database-health report must resolve inside the bundle directory.

## `diagnostic_report.log`

The file contains:

- a support-bundle header with macOS/export time and caller-supplied context;
- current-session application log;
- previous-session application log;
- available pipeline audit logs, also copied as individual attachments.

Onboarding and pipeline-incident actions add structured header lines such as
observed state, blocker or stage, and summarized probe/failure facts. The
generic startup dialog uses `exportDiagnosticReport`; it does not add startup
validation state to the header, but the application log now contains the
flushed `StartupValidation` events and the dedicated JSON file contains the
same typed snapshot.

Pre-`runApp` `debugPrint`/native `NSLog` output—archive admission failures,
legacy-journal diagnostics, Rust initialization, and startup flags—is not
guaranteed to appear in this persistent log because the app logger is created
only after classification. These paths are outside the buffered post-`runApp`
startup-validation event sequence.

## `startup_validation.json`

This small JSON artifact records the exact post-`runApp` validation sequence.
Its top level contains `telemetry_schema_version`,
`validation_policy_version`, and `events`. Depending on the path, events cover:

- validation start with safe archive environment/build identity;
- one bounded completion for each of overlay, import, graph, and Presence;
- the explicit integrity decision, triggers, grouped trigger categories, and
  selected targets;
- per-target deep-check start/completion with normalized outcome and duration;
- final installation classification, reason code, admission basis, outcome,
  and total duration.

It contains allow-listed status facts only. It does not contain archive paths,
message/contact/URL/attachment data, raw database rows, raw `quick_check`
results, or freeform exception messages. It complements rather than duplicates
`database_health.json`: startup telemetry explains the admission decision,
while Phase 1 health describes broader aggregate structure and relationships.

## `database_health.json`

This is the Phase 1 aggregate structural report documented in
[`00-overview.md`](00-overview.md#interpreting-database_healthjson). It can help
diagnose table population and curated relationships after a startup warning,
but it does not reproduce the startup validator's exact evidence or decision.
Notably:

- it includes active import, graph, and overlay plus retired cleanup detail;
- it does not include `presence.db`;
- it does not run `quick_check`;
- it does not include startup escalation triggers or admission basis.

## `database_health_error.json`

When `SupportBundleExportService.export()` has already been constructed and
Phase 1 report generation fails, export continues and writes a small JSON file
containing:

- generation timestamp;
- intended artifact name;
- `status: failed`;
- error message;
- stack trace when available;
- notes that export continued and no raw database copies were exported.

This fallback does **not** cover every startup-restricted failure. The exporter
provider awaits `databaseHealthAuditServiceProvider.future` before constructing
`SupportBundleExportService`. If normal persistent database providers fail at
that point, export can fail before a bundle exists and therefore before
`database_health_error.json` can be written. The startup dialog also does not
wrap exporter-provider resolution in its own error conversion. Treat this as a
current implementation limitation, not as guaranteed fallback behavior.

The telemetry buffer does not remove that limitation. In particular,
`StartupValidationBlocked` (for bounded/deep contention) does not run persistent
post-classification initialization, and its classification-failure surface has
no export button. The blocked event remains available only in process memory.
Adding a standalone read-only exporter reachable from that screen would require
a separate, broader startup-export design.

## Privacy and Preservation

The startup-validation artifact is content-free by construction, and the Phase
1 report exports aggregate metadata while explicitly omitting sensitive row
values. No raw database or row sample is copied. The bundle's other application
and pipeline logs can still contain operational paths, error text, and stack
traces, while `database_health_error.json` deliberately includes a stack trace
when one is available. Handle the bundle as private diagnostic material.

Export is not authorization to mutate or reset any store. A report failure must
not trigger deletion, rebuilding, or repair. `attachment_archive/` is never a
bundle input or reset target.

## Reading a Bundle After Startup Failure

1. Read `startup_validation.json` for bounded results, escalation, selected
   deep targets, and final admission.
2. Correlate its event names with source `StartupValidation` in
   `diagnostic_report.log`, then read current/previous session boundaries and
   `Resolved startup flags`.
3. Check whether `database_health.json` exists; if so, read active summary and
   detailed checks separately.
4. If only `database_health_error.json` exists, diagnose provider/audit failure
   without treating it as proof of corruption.
5. Correlate import/migrate logs only as historical pipeline evidence; they are
   not the current source-scoped graph health authority.
6. Use `pipeline_incident_log` for current pipeline-stage failures.
7. Apply the log sequence and safety warnings in
   [`06-interpreting-startup-database-logs.md`](06-interpreting-startup-database-logs.md).

User-facing labels such as “Send Logs” and “Diagnostic Report” remain current
terminology even though the service-layer output is a multi-file support
bundle.
