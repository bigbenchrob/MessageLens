# Database Access Guide

> Use this folder whenever you need to touch data stores. It consolidates where the databases live, how they are exposed to Dart, and which schemas govern the ledger (`macos_import.db`) and projection (`working.db`).

## 🚨 CRITICAL: Database Independence Rule

**READ THIS FIRST:** [Overlay Database Independence](overlay-database-independence.md)

The overlay and working databases are **COMPLETELY INDEPENDENT**. They do NOT synchronize. Data merging happens **ONLY at the provider layer**. If you're working with manual user overrides or customizations, read this document IMMEDIATELY.

## Reference Library

- 🚨 **[Overlay Database Independence](overlay-database-independence.md)** - Critical architectural principle
- [Schema Overview](schema-overview.md)
- [Working Database Schema Reference](working-schema-reference.md)
- [Overlay Database: Extension Possibilities](overlay-database-extensions.md)
- [Contact → Chat Linking Walkthrough](contact-to-chat-linking.md)

## 1. macOS Source Databases

| Source | Path / Resolution | Notes |
| --- | --- | --- |
| Messages (`chat.db`) | `~/Library/Messages/chat.db` | Read-only. Copied into the ledger during import. Preserve Apple ROWIDs for handles/chats/messages. |
| AddressBook (`AddressBook-v22.abcddb`, etc.) | Resolve via `getFolderAggregateEitherProvider` (`lib/features/address_book_folders/application/get_folder_aggregate_either_provider.dart`) | **Never hardcode** the path. Always ask the provider—it resolves the most recent valid bundle on the user’s system. |

## 2. Application Databases (~/sqlite_rmc/remember_every_text)

> The application stores all writable databases inside `/Users/rob/sqlite_rmc/remember_every_text/`. This directory is created lazily by the feature-level providers.

| Database | File | Owner | Purpose |
| --- | --- | --- | --- |
| Import ledger | `macos_import.db` | `SqfliteImportDatabase` | Immutable staging copy of Messages + AddressBook. Populated by table importers. |
| Working projection | `working.db` | `WorkingDatabase` (Drift) | UI-facing projection with canonical handles, chats, participants, messages, attachments, reactions, read state. |
| Overlay settings | `user_overlays.db` | `OverlayDatabase` (Drift) | User customisations (themes, preferences, visibility overrides). |

### **Single Source of Truth for Connections**

All Dart code must obtain database connections through `lib/essentials/db/feature_level_providers.dart`:

```dart
@Riverpod(keepAlive: true)
Future<SqfliteImportDatabase> sqfliteImportDatabase(SqfliteImportDatabaseRef ref);

@Riverpod(keepAlive: true)
Future<WorkingDatabase> driftWorkingDatabase(DriftWorkingDatabaseRef ref);

@Riverpod(keepAlive: true)
Future<OverlayDatabase> overlayDatabase(OverlayDatabaseRef ref);
```

- **Never instantiate** `SqfliteImportDatabase`, `WorkingDatabase`, or `OverlayDatabase` directly.
- Do not cache `Database` instances yourself; rely on Riverpod to manage lifecycle.
- Importers/migrators access the providers via `ref.watch(...)` or `ref.read(...)` and pass the connections into orchestrator contexts.

## 3. Implementation Files

| Concern | File | Highlights |
| --- | --- | --- |
| Import ledger (sqflite) | `lib/essentials/db/infrastructure/data_sources/local/import/sqflite_import_database.dart` | Handles schema versioning, WAL settings, and convenience helpers (row counts, truncation). |
| Working database (Drift) | `lib/essentials/db/infrastructure/data_sources/local/working/working_database.dart` | Drift schema declarations (tables, DAOs) used by the application and migrators. |
| Overlay database (Drift) | `lib/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart` | Stores user overlay data independent of import/migration cycles. |
| Provider wiring | `lib/essentials/db/feature_level_providers.dart` | Directory bootstrap, connection caching, and disposal logic. |

## 4. Schemas & Reference Material

- **Ledger schema** (import database): `_AGENT_INSTRUCTIONS/agent-per-project/20-migrations/schema-reference.md` → section *Import Database (macos_import.db)*.
- **Working schema**: same document, section *Working Database (working.db)*.
- **Migration playbook**: `_AGENT_INSTRUCTIONS/agent-per-project/20-migrations/migration-playbook.md` explains how tables move from ledger to working.
- **Participant/Handle architecture**: `_AGENT_CONTEXT/09-participant-handle-architecture.md` (mirror forthcoming) details why canonical handles and participant links exist.

Keep the schema document handy for column names, constraints, and expected indices.

## 5. Access Patterns & Best Practices

1. **Always go through providers** – agree on `ref.watch(sqfliteImportDatabaseProvider)` / `ref.watch(driftWorkingDatabaseProvider)` etc. to avoid multiple sqlite handles and locking issues.
2. **Enable foreign keys** – When running raw SQL you are responsible for issuing `PRAGMA foreign_keys = ON` if the helper didn’t already.
3. **Never mutate the ledger outside orchestrated importers/migrators** – The ledger is append-only and should only be changed by table importers or maintenance utilities.
4. **Respect canonical maps** – Migrators populate `MigrationContext.handleIdCanonicalMap`; downstream code should not recompute handle merges.
5. **Watch for address book availability** – The `getFolderAggregateEitherProvider` will surface errors (e.g., permissions). Handle the `Either` before attempting imports.
6. **Paths differ in production bundles** – When running inside a signed app bundle ensure the `/Users/rob/sqlite_rmc/...` directory exists or is replaced with the user’s home path per deployment configuration.

## 6. Quick Start Checklist for Agents

- [ ] Need Messages data? Read via `ImportContext.messagesDb` (importers) or `SqfliteImportDatabase` (ledger queries).
- [ ] Need AddressBook data? Always request the path through `getFolderAggregateEitherProvider` before opening sqlite.
- [ ] Need working projection? Use `driftWorkingDatabaseProvider` and Drift-generated DAOs.
- [ ] Adding a new table? Update `lib/essentials/db/infrastructure/...` definitions **and** the schema docs in `20-migrations/`.
- [ ] Import/migration code? Review orchestrator docs (`40-integration/import-orchestrator.md`, `20-migrations/migration-orchestrator.md`).

Follow this guide to keep database access consistent, reliable, and free of sqlite locking surprises.
