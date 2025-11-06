---
tier: project
scope: databases
owner: agent-per-project
last_reviewed: 2025-11-06
source_of_truth: doc
links:
       - ./00-all-databases-accessed.md
       - ./01-db-import.md
       - ./02-db-working.md
       - ./03-db-address-book.md
       - ./04-db-chat.md
       - ./05-db-overlay.md
       - ./07-overlay-database-independence.md
       - ./11-contact-to-chat-linking.md
       - ../20-DATA-IMPORT-MIGRATION/20-migration-orchestrator.md
       - ../20-DATA-IMPORT-MIGRATION/10-import-orchestrator.md
tests: []
---

# `group-import-working-db` — Import Ledger ↔ Working Projection Contract

`db-import` and `db-working` operate as a tightly coupled pipeline. This document captures the non-negotiable rules governing how data flows from macOS sources into the app projection.

## 1. Source → Import → Working Flow

```
macOS AddressBook (db-address-book)
            +
 macOS Messages (db-chat)
            ↓  import orchestrator
     db-import (ledger; append-only)
            ↓  migration orchestrator
     db-working (projection for UI)
```

- **Import orchestrator** (`../40-INTEGRATION/import-orchestrator.md`) copies raw data into `db-import`, preserving all source ROWIDs and batch metadata.
- **Migration orchestrator** (`../20-DATA-IMPORT-MIGRATION/20-migration-orchestrator.md`) projects ledger tables into Drift models with UI-friendly indexing.

## 2. ID Preservation Rules (**Do Not Break**)

1. **Contact IDs** (`Z_PK`) from AddressBook become `working_participants.id`. No remapping, no new sequences.
2. **Handle IDs** from the Messages ledger remain the canonical handle IDs in `handles_canonical`.
3. **Chat GUIDs / IDs** from Messages remain identical throughout ledger and projection tables.
4. **Message GUIDs / ROWIDs** propagate untouched into `db-working.messages`.

If a proposed change requires remapping IDs, stop and revisit this contract—remapping introduces data drift and breaks downstream joins. See `./11-contact-to-chat-linking.md` for an end-to-end walkthrough of the contact → chat relationship without ID changes.

## 3. Table Mapping Snapshot

| Working Table | Source Table | Notes |
| --- | --- | --- |
| `handles_canonical` | `db-import.handles` | Canonicalization wraps the raw handles but retains the original IDs. |
| `handles_canonical_to_alias` | Canonical map derived during import | Records every variant pointing to the canonical ID. |
| `working_participants` | `db-import.contacts` | Uses original AddressBook `Z_PK`. |
| `handle_to_participant` | `db-import.contact_to_chat_handle` | Links canonical handles to participants with confidence scores. |
| `chat_to_handle` | `db-import.chat_to_handle` | Rebuilds memberships using the same handle IDs. |
| `messages` | `db-import.messages` | Preserves GUIDs/ROWIDs; adds derived columns only. |

## 4. Lifecycle Expectations

- **Import batches append-only**: Never mutate rows in `db-import`. Corrections happen by rerunning imports, generating new batches.
- **Projection is disposable**: `db-working` may be dropped and rebuilt at any time; migrators re-materialize it from the ledger.
- **Write policy**: Runtime features never mutate `db-import`. `db-working` writes happen only through sanctioned services (e.g., overlay merges) and must respect the overlay independence rules.

## 5. Debugging Checklist

1. Confirm the row exists in `db-import` before suspecting migration bugs.
2. Verify the corresponding row in `db-working` retains the same ID.
3. Check `handle_to_participant` and `chat_to_handle` join paths using the preserved IDs.
4. Re-run the migration orchestrator if the projection is stale or corrupted.
5. If IDs differ at any step, halt—someone attempted to remap during migration.

## 6. Related Documents

- `01-db-import.md` — Ledger details and provider access.
- `02-db-working.md` — Projection schema and usage.
- `./11-contact-to-chat-linking.md` — Deep dive into handle/contact/chat linking.
- `../20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md` — Table-level schema definitions.
