# Aggregate Boundaries Decision (Chat, Message, Contact)

## Decision Summary

- Aggregates: `Chat` (aggregate root) and `Message` (aggregate root)
- Non-aggregate: `Contact` (reference/projection data; separate bounded context)
- Rationale: Different invariants, lifecycles, and read/write patterns. Keeps transactions small, prevents hot aggregates, and decouples the core model from external AddressBook data.

## Why Two Aggregates

- Transaction scopes: Aggregate boundaries define what must change atomically.
  - Message: Each message has its own lifecycle: arrival, delivery/read flips, edits/retractions, reactions, attachments.
- Avoid hot aggregates: Modeling Chat → Messages as one aggregate would balloon the root with thousands of children; every write would contend on the Chat root.
- Write isolation: Append/mutate a Message without locking/loading an entire Chat. Update Chat metadata separately and incrementally.

## Distinct Invariants

- Chat
  - Stable ChatId.
  - Participant set must have unique handles; DM/group rules (e.g., DM ⇒ 2 participants max; group ⇒ ≥ 3).
  - lastMessageId/lastTimestamp mirrors the newest visible message (derived, maintained incrementally).
  - Optional per-participant unread counters (device-specific), maintained incrementally.
- Message
  - Belongs to exactly one ChatId.
  - Sender must be a participant at send time (unless system messages).
  - Content is immutable after ingest; edits recorded as revision events or replacements with provenance preserved.
  - Reactions and attachments are subordinate entities (not separate aggregates).

## Read/Write Patterns & Repositories

- Writes
  - Chat: infrequent (membership/title, pin/mute, derived pointers/counters).
  - Message: frequent (append, delivery/read flips, reactions add/remove).
- Reads
  - Chat list: needs chat summary + last message + unread count; not the entire message set.
  - Conversation view: pages messages by ChatId + time.
- Repositories
  - ChatRepository: list chats, get chat header, update metadata/membership.
  - MessageRepository: paginate by chat, append/import, mutate reactions/read states.

## Contacts Are Not an Aggregate Here

- External source: Contacts originate in macOS AddressBook and change outside our domain.
- Role: Rendering aid and linkage to handles; not required for core invariants.
- Bounded context: Treat as a separate “Identity/AddressBook” context with its own import/sync.
- In-domain representation: Use lightweight value objects for participants/handles.

Example participant VO (conceptual):

```
Participant {
  handleId            // stable key from source
  service             // iMessage/SMS
  normalizedAddress   // e164 / email
  displayName?        // optional projection from Contacts
  contactId?          // optional linkage; not required for invariants
}
```

### Contacts Bounded Context & Projections

- Contacts live in an external Identity/AddressBook bounded context. They are imported/synced independently and exposed as projections.
- Chat/Message repositories should return domain entities referencing only `HandleId`/`ContactId` (optional), not embedded contact data.
- Name/avatar resolution happens at the query/presentation layer by joining against the contacts projection (e.g., using a view or provider), with graceful fallback to normalized handle when missing.
- Consistency is eventual: changes in AddressBook may temporarily diverge from rendered chat/message data until the next projection refresh.
- This decoupling lets us re-project UI safely without touching chat/message rows and swap contact sources in the future.

## Practical Mapping to Apple Data

- Chat aggregate
  - ChatId: chat.guid (stable)
  - Participants: import_chat_handle_join → normalize into Participant VOs
  - Derived: lastMessageId, lastTimestamp, unread counters, pinned, muted
- Message aggregate
  - MessageId: message.ROWID or message.guid if present
  - Belongs-to: import_chat_message_join
  - Payload: attributedBody → text, attachments, tapbacks/reactions, timestamps, delivery/read states
- Contacts
  - Separate import pipeline from AddressBook; maintain contactId ↔ handle joins
  - UI joins against a projection to render names/avatars; re-project when AddressBook changes

## Consistency Strategy

- Within aggregate: Strong consistency via single transaction (e.g., update Chat membership).
- Across aggregates: Eventual consistency. E.g., append Message then update Chat.lastMessageId and unread counts as a follow-up step. If it lags, UI still renders acceptably using available data.

## Implications

- Schema/indexes
  - messages(chat_id, timestamp) composite index for paging.
  - chats(last_message_timestamp) for chat lists.
  - Separate tables for reactions/attachments keyed to message_id.
- Import pipeline
  - Stage messages independently from chats; link via chat_message_join.
  - Maintain derived chat fields (last message, counts) incrementally.
- Events/consumers
  - Domain events per aggregate: MessageAppended, MessageDeliveryUpdated, ChatMembershipChanged, etc.
  - A lightweight projector updates chat summaries after message events.
- APIs/use cases
  - Chat-facing use cases never load entire message collections.
  - Message-facing use cases require only the target message and minimal chat context (for invariants).

## Non-Goals / Out of Scope

- Modeling AddressBook changes as domain events in Chat/Message.
- Forcing contacts to exist for messages/chats to be valid.
- Over-normalizing reactions/attachments as top-level aggregates.

## Exit Criteria

- Agree on aggregate roots (Chat, Message) and non-aggregate Contact.
- Lock in repository interfaces aligned to these boundaries.
- Define initial invariants checks and projection flows (chat summaries, unread counts).
- Prepare migration scripts/ETL to populate aggregates and projections from Apple DBs.

## Benefits

- Performance: No mega-aggregate locks; natural pagination.
- Robustness: Contact sync decoupled; broken contacts never block chat/message ingestion.
- Replaceability: Swap contact sources without touching core aggregates.
- Clarity: Clean separation of concerns: Chat vs. Message repositories and use cases.
