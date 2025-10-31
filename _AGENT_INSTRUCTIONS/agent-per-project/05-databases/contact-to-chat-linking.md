# Contact → Chat Linking Walkthrough

This walkthrough captures the end-to-end path a macOS AddressBook contact takes to appear in `working.db` chats. It is excerpted entirely from the `_AGENT_INSTRUCTIONS/agent-per-project` documentation set so agents can double-check their understanding of the import and migration contract.

## 1. Resolve the Live AddressBook Bundle

- Always obtain AddressBook paths through `getFolderAggregateEitherProvider` (`05-databases/README.md`). The provider inspects the `Sources/` subdirectories and returns the active bundle so importers do not attach stale sqlite files.

## 2. Import Phase (Ledger Population)

- `ImportOrchestrator` runs table importers for AddressBook and Messages data (`40-integration/import-orchestrator.md`).
- Contacts land in `macos_import.db` tables:
  - `contacts` – preserves `Z_PK`, display names, organisation flags.
  - `contact_phone_email` – normalised phone/email rows keyed by `ZOWNER`.
  - `contact_to_chat_handle` – matches between AddressBook contacts and chat handles, including confidence scores and batch IDs.
- Chat handles import into ledger `handles` and membership rows populate `chat_to_handle`.
- All ledger tables retain original ROWIDs and append-only batches (`schema-overview.md`).

## 3. Migration Phase (Projection Population)

- `HandlesMigrationService` invokes `MigrationOrchestrator` to copy ledger data into `working.db` (`20-migrations/migration-orchestrator.md`, `40-integration/pipelines.md`).
- Migrators run in dependency order (handles → chats → memberships → participants → messages) using the canonical maps supplied by `MigrationContext`.

### Key Migrator Outputs

| Working Table | Source | Purpose |
| --- | --- | --- |
| `handles_canonical` | `macos_import.db.handles` | Canonicalise handles and preserve ROWIDs (`working-schema-reference.md`). |
| `handles_canonical_to_alias` | Ledger canonical map | Record every raw/normalised variant pointing to the canonical handle. |
| `working_participants` | `macos_import.db.contacts` | Project AddressBook contacts, keeping `Z_PK` as the participant ID. |
| `handle_to_participant` | `contact_to_chat_handle` | Materialise confidence-scored links between canonical handles and participants. |
| `chat_to_handle` | Ledger `chat_to_handle` | Rebuild chat membership using canonical handle IDs. |

## 4. Resulting Relationship in `working.db`

With the migrators complete:

1. Each AddressBook contact has a row in `working_participants`.
2. Every handle variant observed during import is canonicalised and linked via `handles_canonical_to_alias`.
3. `handle_to_participant` ties canonical handles back to the participant (`working_participants.id` == original AddressBook `Z_PK`).
4. `chat_to_handle` stores chat membership referencing the same canonical handle IDs.

Therefore, joining `working_participants → handle_to_participant → chat_to_handle → chats` yields all chats associated with that AddressBook contact. No runtime recomputation is required; the projection enforces the relationship during migration.

Keep this walkthrough handy when implementing importers, migrators, or UI flows that depend on contact-to-chat linkage. It outlines the canonical path and the tables responsible for each step.
