---
tier: project
scope: data-import-migration
owner: agent-per-project
last_reviewed: 2026-09-15
source_of_truth: code
links:
  - ./01-overview.md
  - ./10-import-orchestrator.md
  - ./15-table-importers.md
  - ./20-migration-orchestrator.md
  - ../10-DATABASES/10-group-import-working.md
tests: []
---

# Retired Legacy Incremental Mode Flag

This document explains the historical `incrementalMode` contract in the deleted
`db_migrate` projection system. It is not the production live-sync mechanism
for ordinary app data, archive import, or recovery.

## TL;DR

- `incrementalMode: true` meant the retired import/migration projection preserved existing `working.db` rows and skipped the orchestrator table-truncation step.
- `incrementalMode: false` meant full retired projection rebuild: migrator target tables were cleared, then rebuilt from `macos_import.db`.
- `ChatDbChangeMonitor` no longer runs retired migration for live sync. It runs the source-scoped graph build lifecycle.
- Retired incremental projection must not be restored as an active app path.
- First-run/reimport app setup is graph-owned through the conversation graph build controller; archive/recovery work is source-scoped graph work plus retired-file cleanup.

## Why The Flag Exists

Full retired migration cleared target working tables before rebuilding the
projection. That behavior is historical reference only; graph-era archive,
recovery, and background sync must not revive retired `working.db` projection.

Incremental mode was introduced to avoid:

- slow full-table deletes with foreign-key cascades on large message tables
- unnecessary replacement of stable projection rows
- Drift connection invalidation while UI queries are in flight

## Current Propagation

### Automatic Background Sync

```
ChatDbChangeMonitor
  -> source-scoped graph build lifecycle
  -> attachmentArchiveServiceProvider.archiveGraphMessageSourceRange(...)
  -> graph/message data version bump
```

The monitor does not query the legacy working message count and does not choose a retired migration mode. The automatic path is graph-incremental by source row cursor.

### Full / Manual Paths

Graph onboarding and reimport call the conversation graph build controller.
Historical archive/recovery workflows use source-scoped archive import and
graph projection. Old retired database contents are cleanup/audit evidence
only.

Do not infer manual/full behavior from the monitor path. They are separate entry points with different operational requirements.

## Historical Orchestrator Contract

The retired `MigrationContextSqlite` carried the `incrementalMode` flag.
`MigrationOrchestrator._prepareWorking()` enforced the shared behavior:

- In the old path, `dryRun: true` skipped table truncation and copy writes.
- In the old path, `incrementalMode: true` skipped table truncation.
- In the old path, `incrementalMode: false` cleared each migrator's `targetTables` before phases ran.

Migrators then applied table-appropriate copy and validation behavior. Treat
this as historical retired projection behavior, not current graph guidance.

## Refresh Contract

When this path existed, retired incremental projection had to keep the
existing Drift working database connection open.

Invalidating the retired working database provider remains prohibited if any
future historical diagnostic attempts to touch the old path.

Required pattern:

```dart
ref.read(messageDataVersionProvider.notifier).bump();
```

Why: invalidating the old working database provider could close the Drift
isolate connection and break in-flight readers with "connection was closed"
errors. That provider is now retired; graph streams and explicit graph/message
data-version signals carry refresh.

## Search And Index Rebuilds

`HandlesMigrationService` runs synthetic post-orchestrator steps after the table migrators:

1. rebuild global/per-chat/per-contact message indexes
2. recreate message-index triggers
3. call `searchIndexOrchestrator.rebuildAll()`

This describes retired service behavior. Ordinary graph search now
selects graph `message_ss_id` evidence through the graph search/evidence spine,
not retired working indexes. Do not restore retired projection/index rebuilds
without a reviewed architecture decision.

## Historical Context

Older notes described automatic mode selection by querying `working.db` message counts before migration and invalidating the Drift provider only for full mode. The current monitor path no longer follows that shape:

- it primes and polls from `MAX(ROWID)` against `chat.db`
- it runs the source-scoped graph build lifecycle by high-water marks
- it archives newly imported live graph source ranges
- it bumps graph/message data version providers after success

Treat older count-based or provider-invalidation examples as historical implementation notes, not current guidance.

## Troubleshooting

If new graph messages are not appearing:

1. Check `ChatDbMonitor` logs for MAX(ROWID) detection and graph build errors.
2. Check the Conversation Graph status panel for imported/projected counts and stage timings.
3. Confirm the relevant UI provider observes graph/message data-version signals or Drift graph streams.

If an old log shows retired incremental projection was slow:

1. Confirm the log contains `Incremental mode: skipping table truncation.`
2. Inspect the specific historical migrator that was slow; do not assume all migrators used the same SQL strategy.
3. Check for lingering import database attachments or SQLite locks reported by `ensureImportReady` / `ensureImportClean`.

If a "connection was closed" loop appears:

1. Search the completion path for retired working database provider
   invalidation.
2. Remove it from incremental flows.
3. Use explicit graph/message data-version signals such as
   `messageDataVersionProvider.notifier.bump()` instead.

## Related Reading

- `./01-overview.md` - Source import and graph build overview.
- `./10-import-orchestrator.md` - Current monitor and graph-build orchestration.
- `./15-table-importers.md` - Retired import service behavior.
- `./20-migration-orchestrator.md` - Migrator dependency ordering and post-migration synthetic steps.
- `../10-DATABASES/10-group-import-working.md` - Schema contracts between import and working DBs.
