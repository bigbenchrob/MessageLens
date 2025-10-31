---
tier: project
scope: integration
owner: @rob
last_reviewed: 2025-10-25
source_of_truth: doc
links: []
tests: []
---

# Pipelines (Import → Migration)

## Import Phase
- Sources: macOS `chat.db` (handles, chats, messages, attachments) and AddressBook sqlite (contacts, phones, emails).
- Orchestrated by `ImportOrchestrator` (`lib/essentials/db_importers/application/orchestrator/import_orchestrator.dart`).
- Pipeline: source databases → table importers → staged ledger (`macos_import.db`).
- Each importer keeps original ROWIDs, performs pre/post validation, and surfaces granular progress via `TableImportProgressEvent`s.

## Migration Phase
- Source: staged ledger (`macos_import.db`). Destination: working projection (`working.db`).
- Orchestrated by `MigrationOrchestrator` (`lib/essentials/db_migrate/application/orchestrator/migration_orchestrator.dart`) invoked from `HandlesMigrationService`.
- Migrators copy rows table-for-table, preserving identifiers established during import and reusing canonical handle maps produced in ledger.
- Pre/post validation mirrors the import contract; failures raise `MigrationException` and halt the run.

## Reference
- Detailed orchestrator behavior: `import-orchestrator.md`, `migration-orchestrator.md` (this folder and `20-migrations/`).
- CLI utilities live under `tool/` for automation and diagnostics.
