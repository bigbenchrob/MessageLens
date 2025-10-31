# 13 – Migration Orchestration Flow

This note describes how the **MigrationOrchestrator** projects data from `macos_import.db` into `working.db`. Read it together with:

- [10 – Database Schema Overview](10-database-schema-overview.md)
- [11 – Orchestration Strategy](11-orchestration-strategy.md)
- [12 – Import Orchestration Flow](12-import-orchestration.md)

## Goals

1. Transform the immutable ledger into a UI-ready projection without losing provenance.
2. Collapse handle aliases so the user sees a single identity while we still record every historical variant.
3. Guarantee that every migrator executes atomically and leaves the databases unlocked for the next phase.
4. Fail fast when the ledger contains defects—broken foreign keys, malformed enum values, or mismatched counts.

## Migration Pipeline

The orchestrator constructs a dependency graph over the migrators declared in `lib/essentials/db_migrate/infrastructure/sqlite/migrators`. The core set runs in this order after topological sorting:

1. `HandlesMigrator`
2. `ParticipantsMigrator`
3. `HandleToParticipantMigrator`
4. `ChatsMigrator`
5. `ChatToHandleMigrator`
6. `MessagesMigrator`
7. `AttachmentsMigrator`
8. `ReactionsMigrator`
9. `MessageReadMarksMigrator`
10. `SupabaseSyncStateMigrator`
11. `PostMigrationIndexBuilder`

Additional migrators can slot in by declaring `dependsOn`. For example, `ChatToHandleMigrator` lists `['chats', 'handles']`, so Kahn’s algorithm ensures both are complete before chat membership rows are projected.

Each migrator participates in the three-phase contract (prereq validation, transactional copy, post-validation) described in [11](11-orchestration-strategy.md). The orchestrator calls `ensureImportReady` before a phase and `ensureImportClean` afterward to avoid lingering `ATTACH` statements or locked sqlite handles.

## Handle Canonicalization

`HandlesMigrator` is the foundation for all downstream identity work:

- **Grouping:** All ledger handles are grouped by `compound_identifier` (which already encodes service + normalized value). Each group is reduced to a canonical row following deterministic tie-breakers (preference for explicit compounding, stable sort by ID).
- **Canonical Map:** For every import handle the migrator writes an entry to `working.handle_canonical_map` describing the relationship between the original handle and its canonical representative. Alias types (`canonical`, `scheme_variant`, `format_variant`, `normalized_variant`, `variant`) explain why the merge occurred.
- **In-Memory Maps:** The migrator populates `MigrationContext.handleIdCanonicalMap` and `MigrationContext.canonicalHandleInfo` so later migrators can convert ledger IDs to canonical working IDs without repeated joins.
- **Post-Validation:** Row counts must match exactly: every import handle maps to one canonical handle, and the working table must contain exactly one row per canonical ID.

This canonical map is how we deliver a unified phone number or email address in the UI while preserving the underlying noise in the ledger for debugging and analytics. When new normalization rules are introduced, update the grouping logic and the alias classifier at the same time.

## Participants and Contact Bridges

After canonical handles are ready, `ParticipantsMigrator` copies AddressBook contacts that actually participate in conversations. The migrator:

- Filters out contacts flagged as `is_ignored` in the ledger.
- Preserves key metadata (`display_name`, `short_name`, organization flags) for downstream presentation.
- Maintains a direct mapping between AddressBook `Z_PK` and working participant IDs.

`HandleToParticipantMigrator` then links canonical handles to participants by consuming `MigrationContext.handleIdCanonicalMap` and the ledger’s `contact_to_chat_handle` rows. Confidence scores coming from the import process are copied into `working.handle_to_participant`, allowing future refinement without re-importing.

## Chats and Membership

`ChatsMigrator` and `ChatToHandleMigrator` copy conversation metadata and membership while enforcing referential integrity:

- `validatePrereqs` runs anti-join queries to ensure ledger chat membership rows reference existing chats and handles.
- Copy phases use `INSERT OR REPLACE` (for chats) and `INSERT OR IGNORE` (for membership) inside a single transaction.
- Post-validation confirms there are no orphaned rows inside `working.db` after projection.

## Messages, Attachments, and Reactions

The `MessagesMigrator` performs the heaviest lift:

- **Preflight Checks:** Ensures dependent chats and handles exist and that the ledger contains joinable rows (chat + guid). It also confirms the import database can be attached/detached cleanly before and after the copy.
- **Sender Resolution:** Uses `handle_canonical_map` to translate every ledger `sender_handle_id` into the canonical working ID. Missing handles are logged and inserted as `NULL` senders so the row still loads.
- **Item Type Safety:** Recent fixes map any ledger `item_type` value outside the allowed set (`text`, `attachment-only`, `sticker`, `reaction-carrier`, `system`, `unknown`) to `unknown` to satisfy the working schema’s check constraint.
- **Chat Backfill:** After inserting messages the migrator recomputes `chats.last_message_at_utc`, `last_sender_handle_id`, and `last_message_preview` in a deterministic CTE so the UI picks up accurate summaries.

`AttachmentsMigrator` and `ReactionsMigrator` follow the same pattern: rigorous prereq checks, transactional copy, and count-based post validation. Both rely on canonical handle IDs supplied by the context map.

## Maintaining Database Health

- Every migrator attaches the ledger explicitly and detaches in `finally`; the orchestrator’s `ensureImportReady/ensureImportClean` calls act as guardrails.
- Foreign keys are enabled inside every transactional copy (`PRAGMA foreign_keys = ON`), ensuring we notice orphaned rows immediately.
- `postValidate` stages often compare ledger counts to working counts or run targeted `PRAGMA foreign_key_check` calls. Extend these checks whenever you add new relationships.

## Extending the Pipeline

When introducing a new migrator:

1. Document new columns or tables in [10 – Database Schema Overview](10-database-schema-overview.md).
2. Declare explicit dependencies through `dependsOn`.
3. Reuse the context maps rather than hitting the database repeatedly for canonical lookups.
4. Keep copy logic idempotent (`INSERT OR REPLACE`, `INSERT OR IGNORE`).
5. Update this note with the new agent’s responsibilities and validation logic.

By following these conventions we maintain a migration system that is deterministic, debuggable, and resilient to the edge cases we routinely encounter in real-world iMessage data.

## HandlesMigrationService Entry Point

**Location:** `lib/essentials/db_migrate/application/orchestrator/handles_migration_service.dart`

- **Delegated execution** – The service constructs a `MigrationContext`, wires together all table-level migrators, and hands them to `MigrationOrchestrator`. Apart from reporting progress and restoring user overrides (visibility / blacklist flags), it performs no data reshaping itself.
- **Stable identifiers** – Every migrator copies rows from `macos_import.db` to `working.db` using the original source identifiers (chat IDs, handle IDs, message IDs, AddressBook `Z_PK`). Links between tables are preserved exactly as the import stage recorded them; migration never fabricates new primary keys or relationships.
- **Pre/post validation** – Mirroring the import pipeline, each migrator’s `validatePrereqs` phase checks ledger integrity (duplicate IDs, orphaned FKs, malformed enums). `postValidate` confirms row counts and referential integrity after the transactional `copy` completes. Failures raise `MigrationException` instances, which the orchestrator surfaces while halting downstream work.
- **Progress reporting** – `HandlesMigrationService` translates `TableMigrationProgressEvent`s into high-level `DbMigrationProgress` updates so UI surfaces can display phase-by-phase status, while `MigrationOrchestrator` emits granular table progress events.
- **Preserving user state** – Before truncating working tables, the service snapshots user-managed handle overrides. After the migrators finish, it reapplies those settings so visibility/blacklist choices survive a projection rebuild.
