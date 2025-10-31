# Database Schema Overview

> Start here before touching any import or migration code. This overview captures the live schema contracts that the import ledger and the working projection must satisfy. The related orchestration guides build on these foundations:
>
> - [Integration Pipelines](../40-integration/pipelines.md)
> - [Import Orchestrator](../40-integration/import-orchestrator.md)
> - [Migration Orchestrator](../20-migrations/migration-orchestrator.md)
- [Rust Message Extractor](../40-integration/rust-message-extractor.md)

## File Layout

```
macos_import.db  → immutable ingest ledger (a.k.a. import database)
working.db       → Drift-backed projection consumed by the UI
```

Both files live under `~/sqlite_rmc/remember_every_text/` during development. **Never** open them with ad-hoc `sqlite3` sessions while the app is running—SQLite will take an exclusive lock and stall the orchestrators.

## Layer 1 – Import Ledger (`macos_import.db`)

The ledger mirrors what macOS delivered. It preserves all source identifiers so that migrations can run deterministically.

| Table | Purpose | Key Columns |
| ----- | ------- | ----------- |
| `handles` | Raw `chat.db` handles exactly as found | `id`, `raw_identifier`, `normalized_identifier`, `service`, `batch_id` |
| `chats` | Conversations from `chat.db` | `id`, `guid`, `style`, `batch_id` |
| `chat_to_handle` | Bridge between chats and handles | `chat_id`, `handle_id`, `role`, `batch_id` |
| `messages` | All message rows, including reactions, stickers, system | `id`, `chat_id`, `sender_handle_id`, `item_type`, `text`, `payload_json`, `batch_id` |
| `message_attachments` | Join table linking `messages` to `attachments` | `message_id`, `attachment_id` |
| `attachments` | Metadata for attachment files | `id`, `filename`, `mime_type`, `total_bytes`, `batch_id` |
| `contacts` | AddressBook `ZABCDRECORD` projection | `z_pk`, `given_name`, `family_name`, `organization`, `display_name`, `batch_id` |
| `contact_phone_email` | Unified phone/email values | `zowner`, `kind`, `value`, `normalized_value`, `batch_id` |
| `contact_to_chat_handle` | AddressBook ↔ handle linkages | `contact_z_pk`, `chat_handle_id`, `confidence`, `batch_id` |
| `import_batches` | Provenance for every ingest pass | `id`, `source_paths_json`, `started_at_utc`, `completed_at_utc`, `error_message` |

### Ledger Design Rules

- **Immutable batches.** Rows are never deleted; new imports append new batches. Ignore flags (`is_ignored`) mark data that should not project forward.
- **Original identifiers first.** `id` columns mirror Apple ROWIDs. AddressBook tables retain Core Data column names (`Z_PK`, `ZOWNER`, etc.) to keep reasoning straightforward.
- **Minimal transformation.** Only conversions that unblock projection happen here (e.g., timestamp → ISO8601, phone/email normalization for matching, attributed body extraction via the Rust helper).

## Layer 2 – Working Projection (`working.db`)

This schema is declared in `lib/essentials/db/infrastructure/data_sources/local/working/working_database.dart`. Projection migrators populate it from ledger batches.

| Table | Purpose | Key Columns |
| ----- | ------- | ----------- |
| `handles` | Canonical messaging identities | `id`, `raw_identifier`, `display_name`, `compound_identifier`, `service`, `is_ignored`, `is_visible`, `is_blacklisted`, `batch_id` |
| `handle_canonical_map` | Alias/coalescing metadata for handles | `source_handle_id`, `canonical_handle_id`, `normalized_identifier`, `alias_kind`, `service` |
| `participants` | AddressBook contacts that appear in conversations | `id`, `display_name`, `short_name`, `is_organization`, `avatar_ref`, `given_name`, `family_name` |
| `handle_to_participant` | Confidence-scored linking of handles ↔ participants | `id`, `handle_id`, `participant_id`, `confidence`, `source` |
| `chats` | Conversations ready for UI rendering | `id`, `guid`, `service`, `is_group`, `last_message_at_utc`, `last_sender_handle_id`, `last_message_preview`, `unread_count` |
| `messages` | Fully normalized message timeline | `id`, `guid`, `chat_id`, `sender_handle_id`, `is_from_me`, `sent_at_utc`, `payload_json`, `item_type`, `reaction_carrier`, `has_attachments`, `reply_to_guid`, `batch_id` |
| `attachments` | Attachment metadata in projection space | `id`, `message_guid`, `local_path`, `mime_type`, `sha256_hex`, `is_outgoing`, `batch_id` |
| `reactions` | Parsed reactions joined to canonical handles | `id`, `message_guid`, `reactor_handle_id`, `kind`, `action`, `carrier_message_id`, `parse_confidence` |
| `projection_state` | Singleton housekeeping row for incremental projection | `id`, `last_import_batch_id`, `last_projected_at_utc`, `last_projected_message_id`, `last_projected_attachment_id` |
| `supabase_sync_*` | Outbound sync bookkeeping | `last_batch_id`, `last_synced_guid`, `updated_at` |

### Projection Design Rules

- **Idempotent population.** Migrators always use `INSERT OR REPLACE` or `INSERT OR IGNORE` paired with deterministic selects from the attached ledger.
- **Atomic batches.** Each migrator encloses its work in a single transaction so partial writes never leak if an exception is thrown.
- **Alias-first identity handling.** Consumer code must use `handle_canonical_map` to resolve a single “view” of a person while preserving raw variants for debugging and analytics.
- **UI guarantees.** Columns like `last_message_at_utc`, `last_message_preview`, and `reaction_summary_json` are maintained after message insertion so downstream widgets can render without extra queries.

## Canonical Handle and Alias Expectations

Handle canonicalization is the lynchpin for both import and migration flows:

- `working.handles.compound_identifier` stores the canonical fingerprint produced during migration. It combines normalized number/email plus service so the UI can group variants.
- `working.handle_canonical_map` retains every historical variant that pointed to the canonical handle. The migrators populate it whenever they observe duplicates or collision groups.
- `working.handle_to_participant` links canonical handles to participants with an explicit confidence score.
- During import we also build `contact_to_chat_handle` inside the ledger. It records every AddressBook → handle match so migration can reproduce links without recomputation.

Always update both the ledger-side alias tables and the projection-side alias tables when adding new normalization rules. The orchestrator documentation above spells out the transactional guarantees required to keep these structures in sync.

## Verification Checklist

Before landing a schema change or a new migrator:

1. **Update this overview** so future contributors understand the new invariants.
2. **Extend the ledger schema** via `sqflite_import_database.dart` and bump the version.
3. **Extend the working schema** via `working_database.dart`, respecting the Drift lint rules documented in `_AGENT_CONTEXT/00-code-standards.md`.
4. **Add prereq checks** to the relevant migrator so bad data is caught before copy.
5. **Document the behavior** in the orchestrator note that corresponds to your change (import vs. migration).

When in doubt, walk the data flow: macOS sources → ledger tables → migrators → working tables. The orchestrators enforce that contract; these tables define it.
