---
tier: project
scope: database-health-audit
owner: agent-per-project
last_reviewed: 2026-09-12
source_of_truth: code
links:
  - ./00-overview.md
  - ./05-startup-database-validation.md
  - ./06-interpreting-startup-database-logs.md
  - ./10-support-bundle-integration.md
  - ../10-DATABASES/00-all-databases-accessed.md
  - ../20-DATA-IMPORT-MIGRATION/01-overview.md
  - ../25-ONBOARDING-AND-ARCHIVE/README.md
tests:
  - ../../../test/essentials/onboarding/application/message_lens_installation_validation_service_test.dart
  - ../../../test/essentials/onboarding/application/startup_validation_telemetry_test.dart
  - ../../../test/essentials/db/application/database_health_audit/database_health_audit_service_test.dart
  - ../../../test/essentials/logging/infrastructure/support_bundle_export_service_test.dart
---

# Database Health, Startup Admission, and Diagnostics

This directory is the canonical agent-facing map for two related but distinct
systems:

1. **Startup installation/database validation** decides whether MessageLens may
   admit its normal application providers.
2. **`DatabaseHealthAuditService`** builds the broader Phase 1 structural
   diagnostic artifact `database_health.json` for a support bundle.

The Phase 1 audit is not the startup admission mechanism. Startup does not call
`DatabaseHealthAuditService`, and a `database_health.json` status does not by
itself grant or withhold startup admission.

## Choose the Right Document

| Question | Read |
| --- | --- |
| What databases exist, what must be preserved, and how do the two systems relate? | [`00-overview.md`](00-overview.md) |
| Exactly what happens from process launch to admission or remediation? | [`05-startup-database-validation.md`](05-startup-database-validation.md) |
| A user supplied startup logs or reported a startup database warning | [`06-interpreting-startup-database-logs.md`](06-interpreting-startup-database-logs.md) |
| What does `database_health.json` mean? | [`00-overview.md`](00-overview.md#interpreting-database_healthjson) |
| What is exported, and what happens when audit generation fails? | [`10-support-bundle-integration.md`](10-support-bundle-integration.md) |

## Current Implementation at a Glance

- Ordinary startup renders a restricted Flutter shell before app-database
  inspection completes.
- Startup reads app-owned databases through short-lived, read-only SQLite
  connections in an isolate.
- Healthy current schemas are admitted from bounded structural/logical evidence
  without `PRAGMA quick_check(1)`.
- Suspicious evidence can escalate selected existing databases to
  `quick_check(1)`; unsupported schemas and SQLite contention are handled as
  distinct outcomes.
- Startup admission emits privacy-safe typed events into an in-memory buffer,
  flushes them after the persistent logger is ready, and includes the snapshot
  as `startup_validation.json` wherever normal support export succeeds.
- `Start Fresh` and the obsolete Complete Erase journal compatibility seam use
  full validation of every existing app database at their safety boundaries.
- The support-bundle health audit uses normal persistent providers for active
  import, graph, and overlay stores. It is broader than startup validation, but
  it is not independent of normal provider construction.

## Source-of-Truth Code

- Startup composition and restricted shell: `lib/main.dart`
- Startup state stream:
  `lib/essentials/onboarding/application/message_lens_installation_state_provider.dart`
- Bounded reader:
  `lib/essentials/onboarding/infrastructure/persistence/sqlite_message_lens_installation_evidence_reader.dart`
- Classification and escalation policy:
  `lib/essentials/onboarding/application/message_lens_installation_state_classifier.dart`
  and `message_lens_installation_integrity_policy.dart`
- Deep validator:
  `lib/essentials/onboarding/infrastructure/persistence/sqlite_message_lens_installation_integrity_validator.dart`
- Startup-validation telemetry model and buffer:
  `lib/essentials/onboarding/domain/startup_validation_telemetry.dart` and
  `lib/essentials/onboarding/application/startup_validation_telemetry_buffer.dart`
- Phase 1 audit:
  `lib/essentials/db/application/database_health_audit/`
- Support bundle:
  `lib/essentials/logging/infrastructure/support_bundle_export_service.dart`

When documentation and code disagree, code wins. Update these documents in the
same change that alters startup validation, audit report semantics, or support
bundle construction.
