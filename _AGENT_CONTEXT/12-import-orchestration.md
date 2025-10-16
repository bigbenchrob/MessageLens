# 12 – Import Orchestration Flow

This document explains how the **ImportOrchestrator** ingests macOS Messages (`chat.db`) and AddressBook data into `macos_import.db`. It extends the shared contract described in [11 – Orchestration Strategy](11-orchestration-strategy.md) and assumes the schema guarantees listed in [10 – Database Schema Overview](10-database-schema-overview.md).

## High-Level Objectives

1. **Mirror source data with fidelity.** Every Apple ROWID, GUID, and timestamp must be preserved.
2. **Record provenance.** Each ingest batch is tracked in `import_batches`; all downstream tables reference the batch that populated them.
3. **Prepare collision-resistant identities.** Handles, contacts, and the bridge tables must survive normalization clashes so that the migration phase can build canonical views safely.
4. **Stay idempotent.** A failed import can be rerun after fixes without corrupting existing batches.

## Orchestrator Lifecycle

The import orchestrator walks through the following ordered agents (actual classes live under `lib/essentials/db_importers/...`):

1. `PreparationImporter` – verifies source file access, checks free disk space, and records the batch stub.
2. `ClearLedgerImporter` – truncates ledger tables while leaving schema intact unless `dryRun` is enabled.
3. `HandlesImporter`
4. `ChatsImporter`
5. `ChatParticipantsImporter`
6. `MessagesImporter`
7. `RichContentExtractor` (Rust bridge) – see [08 – Rust Message Extractor](08-rust-message-extractor.md).
8. `AttachmentsImporter`
9. `MessageAttachmentJoinImporter`
10. `AddressBookContactsImporter`
11. `ContactChannelsImporter`
12. `ContactToChatHandleImporter`
13. `IndexBuilder`
14. `IntegrityVerifier`

Each importer declares `dependsOn` so the orchestrator runs a single topological sort at startup and then executes the agents in sequence. Phases (`validatePrereqs`, `copy`, `postValidate`) follow the shared contract. Any failure halts the pipeline and leaves the currently running agent rolled back.

## Contact ↔ Handle Linking Strategy

The `ContactHandleLinker` agent is responsible for stitching AddressBook contacts to chat handles. The process runs in a single transaction:

1. **Phone Number Matching**
   - Values in `contact_phone_email` with `kind = 'phone'` are normalized to E.164.
   - We compare them with both `handles.raw_identifier` and `handles.normalized_identifier`.
   - Matches insert rows into `contact_to_chat_handle` with a confidence weight (default `1.0`).

2. **Email Matching**
   - Emails are lowercased and trimmed before matching against the same handle columns.
   - Duplicate matches are collapsed through `ON CONFLICT(contact_z_pk, chat_handle_id) DO NOTHING` to keep the join table stable.

3. **Alias & Merge Safeguards**
   - Normalization often collapses different inputs to the same canonical value (e.g., `+1 (778) 990-8506` vs `tel:+17789908506`).
   - The importer keeps an in-memory map from normalized identifier to **all** handle IDs that match. When a contact channel resolves to a normalized key, the importer inserts a link for every matching handle (SMS, iMessage, URI variants, etc.).
   - These many-to-one mappings are preserved for migration so the `handle_canonical_map` table can present a unified view while still exposing the distinct raw identifiers.

4. **Ignored Contacts**
   - After linking, contacts in the active batch without any matches are flagged with `is_ignored = 1`. Contacts that gained matches reset the flag to `0`.
   - This keeps the ledger immutable (no deletes) while letting migration skip unused contacts by default.

All of the above happens within a transaction. If the alias grouping or linking encounters a constraint violation (e.g., unexpected duplicate GUID), the transaction aborts and leaves the ledger untouched.

## Handling Normalization Collisions

A recurring issue is that multiple chat handles collapse to the same normalized value. The current mitigation steps are:

- **Ledger handle records** retain both `raw_identifier` and `normalized_identifier`, making it possible to trace every variant that fed into an alias group.
- **Importer linking** connects a contact to every colliding handle. This keeps historical service distinctions intact while avoiding data loss when multiple handles normalize to the same fingerprint.
- **Migration integration** converts those collision groups into `working.handle_canonical_map` entries so the UI shows one person while analytics can still inspect the original variants.

Developers must update both the ledger alias logic and the migration alias projection whenever new normalization rules are introduced.

## Rust Attributed Body Extraction

Messages with rich formatting keep their `attributed_body_blob` in the ledger. The orchestrator hands these blobs to the Rust extractor (`rust/rust/attributed-string-decoder`) in batch mode. See [08 – Rust Message Extractor](08-rust-message-extractor.md) for usage and troubleshooting. The extractor outputs JSON payloads that the importer stores back into `messages.payload_json`, ready for migration.

## Integrity Verification

The final agent executes:

- `PRAGMA integrity_check;`
- `PRAGMA foreign_key_check;`
- Consistency counts comparing ledger totals to the original source enumerations (handles, chats, messages).

Failures here surface as `ImportException` with detailed sample rows. Because the entire agent runs inside a transaction, the ledger remains consistent even when a constraint check fails.

## Adding New Importers

1. Document new tables/columns in [10 – Database Schema Overview](10-database-schema-overview.md).
2. Implement the importer with explicit dependencies.
3. Keep attachment usage symmetrical: attach once, detach before returning.
4. Update this note with the new agent ordering and any special-case collision handling.
