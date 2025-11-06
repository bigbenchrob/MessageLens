---
tier: project
scope: databases
owner: agent-per-project
last_reviewed: 2025-11-05
source_of_truth: This file
links:
  - ./00-all-databases-accessed.md
  - ./01-db-import.md
  - ./02-db-working.md
  - ./03-db-address-book.md
  - ./04-db-chat.md
  - ./10-group-import-working.md
  - ./06-addressbook-path-resolution.md
  - ./07-overlay-database-independence.md
  - ../20-MIGRATIONS/migration-orchestrator.md
  - ../40-INTEGRATION/import-orchestrator.md
  - ../20-MIGRATIONS/schema-reference.md
tests: []
---

# Contact → Chat Linking Walkthrough

This walkthrough captures the end-to-end path a macOS AddressBook contact takes to appear in `db-working` chat views. Use it to double-check the import and migration contract whenever you touch handle/contact logic.

## 1. Resolve the Live AddressBook Bundle

- Always obtain AddressBook paths through `getFolderAggregateEitherProvider` (see `06-addressbook-path-resolution.md`). The provider inspects the `Sources/` subdirectories and returns the active bundle so importers never attach stale SQLite files.

## 2. Import Phase (Ledger Population)

- `ImportOrchestrator` runs table importers for AddressBook and Messages data (`../40-INTEGRATION/import-orchestrator.md`).
- Contacts land in `db-import` tables:
  - `contacts` – preserves `Z_PK`, display names, organisation flags.
  - `contact_phone_email` – normalised phone/email rows keyed by `ZOWNER`.
  - `contact_to_chat_handle` – matches between AddressBook contacts and chat handles, including confidence scores and batch IDs.
- Chat handles import into ledger `handles` and membership rows populate `chat_to_handle`.
- All ledger tables retain original ROWIDs and append-only batches (`../20-MIGRATIONS/schema-reference.md`).

## 3. Migration Phase (Projection Population)

- `HandlesMigrationService` invokes `MigrationOrchestrator` to copy ledger data into `db-working` (`../20-MIGRATIONS/migration-orchestrator.md`).
- Migrators run in dependency order (handles → chats → memberships → participants → messages) using canonical maps supplied by `MigrationContext`.

### Key Migrator Outputs

| Working Table | Source | Purpose |
| --- | --- | --- |
| `handles_canonical` | `db-import.handles` | Canonicalise handles and preserve ROWIDs. |
| `handles_canonical_to_alias` | Ledger canonical map | Record every raw/normalised variant pointing to the canonical handle. |
| `working_participants` | `db-import.contacts` | Project AddressBook contacts, keeping `Z_PK` as the participant ID. |
| `handle_to_participant` | `db-import.contact_to_chat_handle` | Materialise confidence-scored links between canonical handles and participants. |
| `chat_to_handle` | Ledger `chat_to_handle` | Rebuild chat membership using canonical handle IDs. |

## 4. Resulting Relationship in `db-working`

When migrators complete:

1. Each AddressBook contact has a row in `working_participants` (ID == original `Z_PK`).
2. Every handle variant observed during import is canonicalised and linked via `handles_canonical_to_alias`.
3. `handle_to_participant` ties canonical handles back to the participant.
4. `chat_to_handle` stores chat membership referencing the same canonical handle IDs.

Joining `working_participants → handle_to_participant → chat_to_handle → chats` yields all chats associated with that AddressBook contact. No runtime recomputation is required; the projection enforces the relationship during migration.

Keep this walkthrough handy when implementing importers, migrators, or UI flows that depend on contact-to-chat linkage. It outlines the canonical path and identifies the tables responsible for every step.
