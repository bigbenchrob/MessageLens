---
tier: project
scope: database-health-audit
owner: agent-per-project
last_reviewed: 2026-09-12
source_of_truth: code
links:
  - ./README.md
  - ./05-startup-database-validation.md
  - ./06-interpreting-startup-database-logs.md
  - ./10-support-bundle-integration.md
  - ../10-DATABASES/00-all-databases-accessed.md
  - ../10-DATABASES/07-overlay-database-independence.md
  - ../10-DATABASES/14-historical-archive-source-identity.md
  - ../25-ONBOARDING-AND-ARCHIVE/ATTACHMENT-PRESERVATION-INVARIANT.md
tests:
  - ../../../test/essentials/db/application/database_health_audit/database_health_audit_service_test.dart
  - ../../../test/essentials/db/infrastructure/repositories/database_health_audit_queries_test.dart
  - ../../../test/essentials/db/infrastructure/repositories/filesystem_database_health_audit_report_writer_test.dart
---

# Database Health Landscape

MessageLens has a narrow startup-admission system and a broader diagnostic
health audit. They inspect overlapping storage but answer different questions.

## The Two Systems

### Startup installation/database validation

Startup asks: **is there enough trustworthy evidence to admit normal app
operation?** It uses short-lived read-only SQLite connections, schema/object
checks, targeted reads, a small set of cross-store logical facts, and conditional
physical integrity validation. Its result is a typed startup state and an
installation classification: `virgin`, `resumable`, `completed`, `abandoned`,
or `remediationRequired`.

See [`05-startup-database-validation.md`](05-startup-database-validation.md).

### `DatabaseHealthAuditService`

The Phase 1 audit asks: **what structural and relational evidence will help a
developer diagnose this installation?** It inventories tables, evaluates
curated relationship and invariant checks, summarizes active-store health, and
writes `database_health.json` into a support bundle.

It does not perform `quick_check`, produce startup state, or decide admission.

## Store Roles and Preservation Boundaries

| Store | Role | Lifecycle and safety interpretation |
| --- | --- | --- |
| `user_overlays.db` (`db-overlay`) | User intent, archive-source metadata, settings, attachment records, and window state | Durable and preservation-critical. Never treat an inspection failure as permission to reset it. |
| `presence.db` (`db-presence`) | Presence definitions, schedule/run checkpoints, and execution trace | Durable app state. Startup validates a minimal structural subset; the Phase 1 health audit does not currently include it. |
| `macos_import_ss.db` (`db-import-ss`) | Source-scoped import ledger for live and historical sources | Derived from sources, but historically sensitive: non-live source evidence can represent imported archives that are not safely reproducible. Reset only through an explicitly authorized, preservation-aware workflow. |
| `working_ss.db` (`db-graph-working`) | Conversation graph projection and message-text FTS index | Derived and rebuildable from the source-scoped ledger, but never manually delete or mutate it in response to a warning. Rebuild only through the graph lifecycle and archive-mutation authority. |
| `macos_import.db` / `working.db` | Retired cleanup/diagnostic files | Not active stores. Their presence is consequential installation evidence; diagnostics may inspect them read-only and reset may remove only explicitly enumerated retired files. |
| `attachment_archive/` | Archived attachment payloads | Not a database and never a cache. It is preservation data outside every ordinary reset/rebuild boundary. |

Apple's `chat.db` and AddressBook databases are external read-only sources, not
app-owned stores validated by this startup system or included as raw files in
the Phase 1 audit.

For the complete access and ownership map, use
[`10-DATABASES/00-all-databases-accessed.md`](../10-DATABASES/00-all-databases-accessed.md).

## High-Level Flow

```text
native claim + single-instance lock
              |
Dart archive/marker admission
              |
legacy journal absent? -- no --> full integrity safety proof or fail closed
              |
            runApp
              |
restricted startup shell + bounded read-only inspection
              |
        classify installation
              |
      escalation policy decision
        /          |           \
 bounded pass   quick_check   reject/block
      |             |              |
 admit/withhold  pass/fail      restricted UI
              |
support export may later build database_health.json
and always includes startup_validation.json once export begins
```

## Phase 1 Audit Architecture

`DatabaseHealthAuditService` lives in
`lib/essentials/db/application/database_health_audit/`. Its provider resolves:

- the source-scoped import database provider;
- the conversation-graph Drift provider;
- the overlay Drift provider;
- read-only file query layers for retired `macos_import.db` and `working.db`;
- current Full Disk Access and runtime/build metadata.

Active connections are provider-managed. Retired files are opened only through
one-off read-only query layers and are not created as a diagnostic side effect.
The service currently does not audit `presence.db`.

Primary methods:

- `buildPhase1Report()`
- `writePhase1Report({required outputDirectoryPath})`

SQL/query adapters live in
`lib/essentials/db/infrastructure/repositories/database_health_audit_queries.dart`.
They provide file existence, ping, `PRAGMA user_version`, table/column
inventory, row counts, simple integer-primary-key bounds, important-column
summaries, and curated SQL checks.

## Interpreting `database_health.json`

The report format currently declares:

- `schema_version: "1.0.0"`
- `audit_version: "phase1"`

Top-level sections are:

| Section | Meaning |
| --- | --- |
| `app` / `environment` | Build channel, bundle identity, platform, timezone, Full Disk Access, and startup flags. |
| `databases` | Per-store existence/accessibility, read-open result, role, `user_version`, and open error if any. |
| `table_inventory` | Expected plus dynamically discovered tables, existence, row count, simple PK bounds, privacy-safe important-column aggregates, and notes. |
| `relationship_checks` | Parent/child/matched/unmatched counts and percentages for curated joins. |
| `invariant_checks` | Evaluated-row and violation counts for curated structural invariants, including severity. |
| `summary` | Overall status, active-table count, check counts, and up to twelve headline findings. |
| `errors` | Typed database-open, inventory, relationship, or invariant evidence. |

The table-inventory portion of the summary is deliberately **active-store
scoped**. Retired cleanup tables can appear in detailed inventory, but their
absence or emptiness does not add a missing/empty-table finding or inflate the
active `table_count`.

The implementation does not currently filter relationship statuses or collected
errors by active/retired role when computing `overall_status`. Therefore a
failed retired-working relationship check, or a retired-store query error, can
still degrade the overall status. This is narrower than the model comment and
older documentation that described the entire summary as active-health scoped;
agents must follow the actual aggregation code until that discrepancy is
resolved.

### Status meanings

- `pass`: the check found no unmatched/violating rows.
- `warning`: some, but not all, participating rows are unmatched or violating;
  an existing active table with zero rows also contributes a summary warning.
- `fail`: a relationship has zero matches despite participating data, an
  invariant fails for every evaluated row, or an expected active table is
  missing.
- `error`: the audit could not obtain required evidence; this outranks other
  statuses in `overall_status`.
- `not_applicable`: an invariant evaluated zero rows or is explicitly deferred.

Relationship percentages are omitted when their denominator is zero. Invariant
status is deterministic: zero evaluated rows is `not_applicable`, zero
violations is `pass`, all evaluated rows violating is `fail`, and a partial set
is `warning`.

The explicit
`overlay_cross_database_relationship_checks_deferred` invariant remains
`not_applicable`; Phase 1 inventories overlay data but does not join overlay to
graph or retired stores.

## Privacy and Safety

The health report contains aggregate structural evidence only. It does not copy
SQLite files or emit row samples, message text, attributed bodies, contact
identity values, attachment filenames, or archive paths as report data.
Columns designated sensitive are represented by omission notes.

The surrounding support bundle also contains application and pipeline logs.
Those logs are derived diagnostics rather than raw databases, but they can
contain operational paths, error text, and stack traces. Do not describe the
entire bundle as anonymous; review diagnostic handling separately in
[`10-support-bundle-integration.md`](10-support-bundle-integration.md).

## Implemented, Historical, and Deferred

Implemented today:

- startup bounded inspection plus policy-driven integrity escalation;
- privacy-safe buffered startup-validation events, persistent-log flush after
  classification, and `startup_validation.json` support-bundle export;
- Phase 1 structural audit and support-bundle export;
- active-table summary with retired cleanup detail and unfiltered check/error
  aggregation;
- aggregate-only report content.

Deferred:

- Phase 2 failure samples;
- Phase 3 sanitized relational snapshots;
- overlay-to-graph cross-database relationship checks;
- a UI for browsing Phase 1 results;
- a startup-safe support exporter independent of normal persistent providers.

Known code/documentation seams worth reviewing separately from a diagnosis:

- only the graph schema version has a shared dependency-light constant; import,
  overlay, and Presence repeat their ceilings in startup and database code;
- the Phase 1 summary excludes retired tables from table findings but not all
  retired relationship/error statuses, despite an “active health” model comment;
- startup-restricted support export still depends on normal persistent provider
  construction.

Historical proposal documents under
`45-NEW-FEATURE-ADDITION/99-DONE/database-health-audit/` are not current
authority.
