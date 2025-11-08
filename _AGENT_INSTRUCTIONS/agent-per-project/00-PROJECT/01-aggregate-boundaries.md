---
tier: project
scope: architecture
owner: agent-per-project
last_reviewed: 2025-10-30
source_of_truth: doc
links:
  - ../_shared/30-architecture/ddd-app-structure.md
  - ../10-DATABASES/11-contact-to-chat-linking.md
  - ../20-DATA-IMPORT-MIGRATION/20-migration-orchestrator.md
  - ../20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md
tests: []
---

# Aggregate Boundaries & Domain Contracts

## Status: ✅ Established

**Last Updated**: October 30, 2025

## Overview

This document establishes the foundational domain language and aggregate boundaries for Remember This Text. The application models digital message exchange from Apple's Messages ecosystem with separate identity management from AddressBook.

## Decision Summary

- **Aggregates**: `Chat` (aggregate root) and `Message` (aggregate root)
- **Non-aggregate**: `Contact` (reference/projection data; separate bounded context)
- **Rationale**: Different invariants, lifecycles, and read/write patterns. Keeps transactions small, prevents hot aggregates, and decouples the core model from external AddressBook data.

## Ubiquitous Language

### Core Domain Concepts

**Message Exchange Context**: The fundamental domain revolves around digital message exchange, primarily from Apple's Messages ecosystem, with contact relationship management.

### Key Terms & Definitions

| Term | Definition | Domain Significance |
| --- | --- | --- |
| **Chat** | A conversation context containing one or more participants | Aggregate Root - represents conversational boundary |
| **Message** | A discrete communication unit within a chat context | Aggregate Root - represents atomic communication |
| **Contact** | A person or entity that can send/receive messages | Reference Entity - identity from external bounded context |
| **Handle** | A communication endpoint (phone, email, etc.) for a contact | Value Object - technical addressing |
| **Participant** | A contact's role within a specific chat context | Value Object - chat-scoped relationship |
| **Attachment** | Media or file content associated with a message | Entity - content with lifecycle |
| **Service** | The communication protocol/platform (iMessage, SMS, etc.) | Value Object - technical classification |
| **Thread** | Synonym for Chat - maintains Apple terminology compatibility | Domain Alias |

### Temporal Concepts

| Term | Definition | Technical Notes |
| --- | --- | --- |
| **Message Timestamp** | When a message was sent/received | Apple nanoseconds → Unix seconds conversion |
| **Chat Start Date** | When the first message in chat occurred | Derived from earliest message |
| **Chat End Date** | When the most recent message occurred | Derived from latest message |
| **Import Timestamp** | When data was last synchronized from source | ETL tracking - not domain concept |

### Identity & Equality Concepts

| Term | Definition | Implementation Strategy |
| --- | --- | --- |
| **Chat Identity** | Unique identifier for chat aggregate | GUID from Apple + fallback generation |
| **Message Identity** | Unique identifier for message aggregate | Apple message ID + source tracking |
| **Contact Identity** | Stable identifier for person/entity | AddressBook Z_PK preserved |
| **Handle Identity** | Unique identifier for communication endpoint | Compound identifier (service + normalized address) |

## Why Two Aggregates

### Transaction Scopes
Aggregate boundaries define what must change atomically:
- **Message**: Each message has its own lifecycle—arrival, delivery/read status changes, edits/retractions, attachments
- **Chat**: Manages conversation metadata, membership, and derived counters independently from individual messages

### Avoid Hot Aggregates
Modeling Chat → Messages as one aggregate would:
- Balloon the root with thousands of child entities
- Force every message write to contend on the Chat root
- Create bottlenecks and lock contention in high-traffic chats

### Write Isolation
- Append/mutate a Message without locking or loading an entire Chat
- Update Chat metadata separately and incrementally
- Each aggregate can evolve independently

## Chat Aggregate

### Aggregate Root
- **Entity**: `Chat` in `working.db` (`../20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md`)
- **Identity**: Stable `ChatId` (GUID from Apple)

### Aggregate Contents
- Chat metadata (service, group flag, preferences)
- Membership rows in `chat_to_handle` (canonical handle IDs)
- Derived UI columns: `last_message_at_utc`, `last_message_preview`, `unread_count`
- User preferences: `pinned`, `archived`, `muted_until_utc`, `favourite`
- Optional per-participant unread counters (device-specific), maintained incrementally

### Key Invariants
1. Stable ChatId must be preserved across imports
2. Participant set must have unique canonical handles
3. DM/group rules (e.g., DM ⇒ 2 participants; group ⇒ ≥ 3)
4. `lastMessageId`/`lastTimestamp` mirrors the newest visible message (derived, maintained incrementally)
5. Every membership must reference an existing canonical handle created earlier in migration
6. Date consistency (start_date ≤ end_date)

### Boundaries
- ✅ **Inside**: Chat metadata, participant management, conversation-level aggregations, derived counters
- ❌ **Outside**: Individual message content, contact details, attachment data, handle canonicalization

### Write Patterns
**Infrequent**: Membership changes, title updates, pin/mute toggles, counter maintenance

### Repository
`ChatRepository` handles:
- List chats with summaries
- Get chat headers
- Update metadata/membership
- Maintain derived fields incrementally

### Validation Rules
- GUID format compliance for Apple-sourced chats
- Display name length limits (1-200 characters)
- Participant count limits (1-100 participants)
- Date consistency enforcement

### Data Flow
- Importers copy `chats` and `chat_to_handle` from macOS sources into `macos_import.db` without altering ROWIDs (`../20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md`)
- Migration runs chat migrators after handle canonicalization so foreign keys resolve cleanly (`20-DATA-IMPORT-MIGRATION/20-migration-orchestrator.md`)
- Mutation policy: Chat data changes only during migration batches or sanctioned overlay adjustments (pin/archive)

## Message Aggregate

### Aggregate Root
- **Entity**: `Message` keyed by GUID in `working.db`
- **Identity**: Apple message ID with source tracking

### Aggregate Contents
- Belongs to exactly one `ChatId`
- Message content (text, formatting, system type)
- Attachments as subordinate entities joined by `message_guid`
- Reactions as subordinate entities (not separate aggregates)
- Read markers and delivery states
- Derived flags: `has_attachments`, `reaction_summary_json`, `is_starred`, `is_deleted_local`
- Temporal data: `sent_at_utc`, `delivered_at_utc`, `read_at_utc`, `status`

### Key Invariants
1. Message must reference valid chat and sender handle
2. Sender must be a participant at send time (unless system messages)
3. Content OR attachments required (not both empty)
4. Content is immutable after ingest; edits recorded as revision events or replacements with provenance preserved
5. Timestamp must be valid and within reasonable bounds (2000-2100)
6. Message direction (incoming/outgoing) must be deterministic
7. Reaction counts stay synchronized with reaction events
8. Attachment flags reflect actual attachment presence

### Boundaries
- ✅ **Inside**: Message content, attachments, delivery metadata, formatting, reactions, read states
- ❌ **Outside**: Chat context details, contact management, handle management, participant resolution

### Write Patterns
**Frequent**: Message append, delivery/read flips, reaction add/remove, attachment processing

### Repository
`MessageRepository` handles:
- Paginate by chat + time window
- Append/import messages
- Mutate reactions/read states
- Maintain derived flags

### Validation Rules
- Content length limits (text: 10MB, attachments: per-type)
- Timestamp within reasonable bounds
- Sender handle must exist in system
- Content validation for required fields

### Data Flow
- Ledger tables retain full message fidelity including attachments and reaction carriers (`../20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md`)
- Migrators insert messages after chats/handles to guarantee foreign keys, using idempotent `INSERT OR REPLACE` (`20-DATA-IMPORT-MIGRATION/20-migration-orchestrator.md`)
- Mutation policy: Runtime features never mutate message rows directly; overlays (starring, annotations) live in `user_overlays.db` (`../10-DATABASES/05-db-overlay.md`)

## Contacts: Non-Aggregate Reference Model

### Bounded Context Separation

Contacts represent a separate "Identity/AddressBook" bounded context:
- **External source**: Contacts originate in macOS AddressBook and change outside our domain
- **Role**: Rendering aid and linkage to handles; not required for core Chat/Message invariants
- **Import/sync**: Happens independently through `contact_to_chat_handle` ledger table
- **Projection**: Exposed as read-only data in `working_participants`

### Not an Aggregate Root

Contacts are **not** modeled as aggregates within the Chat/Message domain because:
1. They have no invariants that Chat/Message must enforce
2. Changes happen externally (in macOS AddressBook)
3. They serve purely as display/search enhancement
4. Missing contacts never block chat/message ingestion

### In-Domain Representation

Use lightweight value objects for participants/handles:

```dart
// Conceptual participant reference
Participant {
  handleId            // stable key from source
  service             // iMessage/SMS
  normalizedAddress   // e164 / email
  displayName?        // optional projection from Contacts
  contactId?          // optional linkage; not required for invariants
}
```

### Query/Presentation Layer

- Chat/Message repositories return entities referencing only `HandleId`/`ContactId` (optional)
- No embedded contact data in aggregate roots
- Name/avatar resolution happens at presentation layer by joining against contacts projection
- Graceful fallback to normalized handle when contact missing
- Consistency is eventual: AddressBook changes may temporarily diverge until next projection refresh

### Reference Integrity Expectations

1. A contact should have at least one handle or a display name
2. Handle-to-contact mapping should be unambiguous within service contexts
3. Display name derivation follows consistent priority rules
4. Contact merging/splitting maintains handle consistency where possible

### Data Flow

- Importers load AddressBook structures into `macos_import.db` (`../20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md`) while preserving original identifiers
- Migrators populate participants first, then resolve handle links, enabling deterministic chat linkage (`../10-DATABASES/11-contact-to-chat-linking.md`)
- Overlay metadata (short names, notes) stored in `user_overlays.db` so source projection stays pristine
- This decoupling lets us re-project UI safely without touching chat/message rows and swap contact sources in the future

## Cross-Aggregate Relationships

```
Chat ──references──> Message (by ID)
Chat ──has participants from──> Contact (by Handle ID)
Message ──sent by──> Contact (by Handle ID)
Message ──sent via──> Handle (canonical)
Contact ──owns──> Handle (via handle_to_participant)
Handle ──used in──> Chat (via chat_to_handle)
```

### Design Principles

1. **Reference by ID**: No direct object references across aggregate boundaries
2. **Eventual Consistency**: Cross-aggregate updates use domain events or projection updates
3. **Bounded Contexts**: Each aggregate maintains its own invariants independently
4. Aggregates communicate strictly through canonical identifiers
5. A participant discovers chats via `handle_to_participant → chat_to_handle` join
6. Chats resolve participants through the same path (`../10-DATABASES/11-contact-to-chat-linking.md`)

## Consistency Strategy

### Within Aggregate
**Strong consistency** via single transaction:
- Update Chat membership atomically
- Message with attachments inserted together
- Reaction counts updated with reaction events

### Across Aggregates
**Eventual consistency**:
- Append Message then update `Chat.lastMessageId` and unread counts as follow-up step
- If updates lag, UI still renders acceptably using available data
- Domain events coordinate cross-aggregate updates
- Projection updates maintain derived Chat fields from Message events

## Read/Write Patterns

### Writes
- **Chat**: Infrequent—membership/title changes, pin/mute toggles, derived pointer/counter updates
- **Message**: Frequent—append, delivery/read flips, reactions add/remove, attachment processing

### Reads
- **Chat list**: Needs chat summary + last message + unread count; not the entire message set
- **Conversation view**: Pages messages by ChatId + time window
- **Contact resolution**: Separate query joining handles to participants projection

## Practical Mapping to Apple Data

### Chat Aggregate
- ChatId: `chat.guid` (stable)
- Participants: `import_chat_handle_join` → normalize into Participant VOs
- Derived: `lastMessageId`, `lastTimestamp`, unread counters, `pinned`, `muted`

### Message Aggregate
- MessageId: `message.ROWID` or `message.guid` if present
- Belongs-to: `import_chat_message_join`
- Payload: `attributedBody` → text, attachments, tapbacks/reactions, timestamps, delivery/read states

### Contacts
- Separate import pipeline from AddressBook; maintain `contactId ↔ handle` joins
- UI joins against a projection to render names/avatars; re-project when AddressBook changes

## Schema/Technical Implications

### Indexes
- `messages(chat_id, timestamp)` composite index for paging
- `chats(last_message_timestamp)` for chat lists
- Separate tables for reactions/attachments keyed to `message_id`

### Import Pipeline
- Stage messages independently from chats; link via `chat_message_join`
- Maintain derived chat fields (last message, counts) incrementally
- Import and migration orchestrators are the only components allowed to span aggregates transactionally

### Events/Consumers
- Domain events per aggregate: `MessageAppended`, `MessageDeliveryUpdated`, `ChatMembershipChanged`
- Lightweight projector updates chat summaries after message events

### APIs/Use Cases
- Chat-facing use cases never load entire message collections
- Message-facing use cases require only the target message and minimal chat context (for invariants)

## Domain Events

### Chat Events
- `ChatCreated` - New conversation started
- `ChatParticipantAdded` - Participant joined conversation
- `ChatParticipantRemoved` - Participant left conversation
- `ChatDisplayNameChanged` - Chat name/title updated
- `ChatMembershipChanged` - General membership modification

### Message Events
- `MessageReceived` - New message arrived
- `MessageSent` - Message sent successfully
- `MessageDelivered` - Delivery confirmation received
- `MessageRead` - Read receipt received
- `MessageAppended` - Message added to chat
- `MessageDeliveryUpdated` - Delivery status changed

### Contact Events (External Context)
- `ContactCreated` - New contact identified
- `ContactMerged` - Duplicate contacts combined
- `ContactHandleAdded` - New communication method added
- `ContactHandleRemoved` - Communication method removed

## Error Handling Strategy

### Domain Errors

```dart
abstract class DomainError extends Error {
  final String message;
  const DomainError(this.message);
}

class ChatInvariantViolation extends DomainError { ... }
class MessageValidationError extends DomainError { ... }
class ContactIdentityError extends DomainError { ... }
```

### Error Categories

1. **Invariant Violations**: Core business rule breaches (e.g., invalid participant count)
2. **Validation Errors**: Input data format/constraint issues (e.g., timestamp out of range)
3. **Identity Conflicts**: Duplicate or inconsistent identity assignments (e.g., GUID collision)
4. **Temporal Inconsistencies**: Date/time ordering violations (e.g., end_date < start_date)

## Benefits of This Design

### Performance
- No mega-aggregate locks; natural pagination
- Message writes don't block Chat metadata updates
- Efficient chat list queries without loading messages

### Robustness
- Contact sync decoupled; broken contacts never block chat/message ingestion
- Aggregate boundaries prevent cascading failures
- Clear transactional boundaries

### Replaceability
- Swap contact sources without touching core aggregates
- External identity provider integration possible
- Migration between storage systems simplified

### Clarity
- Clean separation of concerns: Chat vs. Message repositories and use cases
- Bounded contexts make responsibilities explicit
- Ubiquitous language reduces ambiguity

## Non-Goals / Out of Scope

- Modeling AddressBook changes as domain events in Chat/Message domain
- Forcing contacts to exist for messages/chats to be valid
- Over-normalizing reactions/attachments as top-level aggregates
- Runtime mutation of aggregates outside migration pipelines

## Cross-Reference

Related documentation:
- Database schema: `../20-DATA-IMPORT-MIGRATION/02-import-migration-schema-reference.md`
- Contact linking: `../10-DATABASES/11-contact-to-chat-linking.md`
- Migration flow: `20-DATA-IMPORT-MIGRATION/20-migration-orchestrator.md`
- Import flow: `40-INTEGRATION/import-orchestrator.md`
- Shared DDD patterns: `../_shared/30-architecture/ddd-app-structure.md`

---

**Exit Criteria**:
- ✅ Ubiquitous language defined
- ✅ Aggregate boundaries established
- ✅ Domain invariants documented
- ✅ Cross-aggregate relationships mapped
- ⏳ Freezed entity definitions (in progress)
- ⏳ Domain invariant tests (in progress)
