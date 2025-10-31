# Working Database Schema Reference

> 🚨 **Critical:** Review `lib/essentials/db/infrastructure/data_sources/local/working/working_database.dart` for the definitive Drift declarations. Use this note as a field-by-field quick reference when writing SQL or Drift queries against `working.db`.
>
> 🕰️ **Schema drift:** The working projection evolves frequently. If you discover new columns or renamed tables, update this document immediately after modifying `working_database.dart`.

## Database Location

```
/Users/rob/sqlite_rmc/remember_every_text/working.db
```

## Table Cheat Sheet

- [`handles` and `handles_canonical`](#handles-and-handles_canonical)
- [`handles_canonical_to_alias`](#handles_canonical_to_alias)
- [`participants`](#participants)
- [`handle_to_participant`](#handle_to_participant)
- [`chats`](#chats)
- [`chat_to_handle`](#chat_to_handle)
- [`messages`](#messages)
- [`attachments`](#attachments)
- [`reactions` and `reaction_counts`](#reactions-and-reaction_counts)
- [`read_state` and `message_read_marks`](#read_state-and-message_read_marks)

### `handles` and `handles_canonical`

Both tables share the same column shape; `handles_canonical` is the future-facing table for canonicalised identities while `handles` retains the historical projection.

| Column | Type | Constraints | Notes |
| --- | --- | --- | --- |
| `id` | INTEGER | PRIMARY KEY | Preserves Apple ROWID (no autoincrement) |
| `raw_identifier` | TEXT | NOT NULL | Original phone/email/string |
| `display_name` | TEXT | NOT NULL | Best-known label for UI |
| `compound_identifier` | TEXT | UNIQUE | Normalised fingerprint (service + identifier) |
| `service` | TEXT | DEFAULT `Unknown` with enum check | `iMessage`, `SMS`, `RCS`, etc. |
| `is_ignored` | BOOLEAN | DEFAULT `false` | Set by spam filters |
| `is_visible` | BOOLEAN | DEFAULT `true` | UI visibility toggle |
| `is_blacklisted` | BOOLEAN | DEFAULT `false` | For suppressing content |
| `country` | TEXT | NULLABLE | ISO country code |
| `last_seen_utc` | TEXT | NULLABLE | Last observed message timestamp |
| `batch_id` | INTEGER | NULLABLE | Import provenance |

**Unique keys:** `{compound_identifier}` and `{raw_identifier, service}` guarantee identity uniqueness.

### `handles_canonical_to_alias`

| Column | Type | Constraints | Description |
| --- | --- | --- | --- |
| `source_handle_id` | INTEGER | PRIMARY KEY | Points at legacy/raw handle variant |
| `canonical_handle_id` | INTEGER | REFERENCES `handles_canonical(id)` | Canonical pointer |
| `raw_identifier` | TEXT | NOT NULL | Raw value used during import |
| `compound_identifier` | TEXT | NOT NULL | Derived canonical fingerprint |
| `normalized_identifier` | TEXT | NOT NULL | Cleaned identifier value |
| `service` | TEXT | NOT NULL | Same enum constraint as handles |
| `alias_kind` | TEXT | DEFAULT `variant` | Classifies alias relationship |

### `participants`

| Column | Type | Constraints | Description |
| --- | --- | --- | --- |
| `id` | INTEGER | PRIMARY KEY | Preserves AddressBook `Z_PK` |
| `original_name` | TEXT | NOT NULL | Raw AddressBook display name |
| `display_name` | TEXT | NOT NULL | Resolved UI name |
| `short_name` | TEXT | NOT NULL | Preferred short label |
| `avatar_ref` | TEXT | NULLABLE | Asset reference |
| `given_name` | TEXT | NULLABLE | First name |
| `family_name` | TEXT | NULLABLE | Last name |
| `organization` | TEXT | NULLABLE | Company/organisation |
| `is_organization` | BOOLEAN | DEFAULT `false` | Flag for org entries |
| `created_at_utc` | TEXT | NULLABLE | Projection timestamp |
| `updated_at_utc` | TEXT | NULLABLE | Last touch timestamp |
| `source_record_id` | INTEGER | NULLABLE | Original AddressBook row reference |

### `handle_to_participant`

| Column | Type | Constraints | Description |
| --- | --- | --- | --- |
| `id` | INTEGER | PRIMARY KEY AUTOINCREMENT | Join row |
| `handle_id` | INTEGER | REFERENCES `handles_canonical(id)` | Canonical handle |
| `participant_id` | INTEGER | REFERENCES `participants(id)` | Participant |
| `confidence` | REAL | DEFAULT `1.0` | Confidence rating |
| `source` | TEXT | DEFAULT `'addressbook'` | Provenance |

**Unique key:** `{handle_id, participant_id}` prevents duplicates.

### `chats`

| Column | Type | Constraints | Description |
| --- | --- | --- | --- |
| `id` | INTEGER | PRIMARY KEY AUTOINCREMENT | Projection chat identifier |
| `guid` | TEXT | UNIQUE NOT NULL | Apple chat GUID |
| `service` | TEXT | DEFAULT `Unknown` enum | iMessage/SMS/etc |
| `is_group` | BOOLEAN | DEFAULT `false` | Group marker |
| `last_message_at_utc` | TEXT | NULLABLE | Last activity timestamp |
| `last_sender_handle_id` | INTEGER | REFERENCES `handles_canonical(id)` | Last sender |
| `last_message_preview` | TEXT | NULLABLE | Cached snippet |
| `unread_count` | INTEGER | DEFAULT `0` | Unread badge |
| `pinned` | BOOLEAN | DEFAULT `false` | Pin state |
| `archived` | BOOLEAN | DEFAULT `false` | Archive toggle |
| `muted_until_utc` | TEXT | NULLABLE | Mute expiry |
| `favourite` | BOOLEAN | DEFAULT `false` | Favourite flag |
| `created_at_utc` | TEXT | NULLABLE | Created timestamp |
| `updated_at_utc` | TEXT | NULLABLE | Updated timestamp |
| `is_ignored` | BOOLEAN | DEFAULT `false` | Suppressed chats |

### `chat_to_handle`

| Column | Type | Constraints | Description |
| --- | --- | --- | --- |
| `id` | INTEGER | PRIMARY KEY AUTOINCREMENT | Join row |
| `chat_id` | INTEGER | REFERENCES `chats(id)` | Chat |
| `handle_id` | INTEGER | REFERENCES `handles_canonical(id)` | Participant handle |
| `role` | TEXT | DEFAULT `member` | Member role |
| `added_at_utc` | TEXT | NULLABLE | Join timestamp |
| `is_ignored` | BOOLEAN | DEFAULT `false` | Participation suppressed |

**Unique key:** `{chat_id, handle_id}`.

### `messages`

| Column | Type | Constraints | Description |
| --- | --- | --- | --- |
| `id` | INTEGER | PRIMARY KEY AUTOINCREMENT | Projection message id |
| `guid` | TEXT | UNIQUE NOT NULL | Apple message GUID |
| `chat_id` | INTEGER | REFERENCES `chats(id)` | Parent chat |
| `sender_handle_id` | INTEGER | REFERENCES `handles_canonical(id)` | Canonical sender |
| `is_from_me` | BOOLEAN | DEFAULT `false` | Outgoing flag |
| `sent_at_utc` | TEXT | NULLABLE | When sent |
| `delivered_at_utc` | TEXT | NULLABLE | Delivery timestamp |
| `read_at_utc` | TEXT | NULLABLE | Read timestamp |
| `status` | TEXT | DEFAULT `unknown` enum | Delivery status |
| `text` | TEXT | NULLABLE | Plaintext body |
| `item_type` | TEXT | NULLABLE enum | Text, attachment-only, sticker, etc. |
| `is_system_message` | BOOLEAN | DEFAULT `false` | System marker |
| `error_code` | INTEGER | NULLABLE | Delivery error |
| `has_attachments` | BOOLEAN | DEFAULT `false` | Attachment flag |
| `reply_to_guid` | TEXT | NULLABLE | Reply target |
| `associated_message_guid` | TEXT | NULLABLE | Associated message |
| `thread_originator_guid` | TEXT | NULLABLE | Tapback/source thread |
| `system_type` | TEXT | NULLABLE | System payload type |
| `reaction_carrier` | BOOLEAN | DEFAULT `false` | Reaction container |
| `balloon_bundle_id` | TEXT | NULLABLE | iMessage effect bundle |
| `payload_json` | TEXT | NULLABLE | Rich payload |
| `reaction_summary_json` | TEXT | NULLABLE | Aggregated reactions |
| `is_starred` | BOOLEAN | DEFAULT `false` | Overlay projection state |
| `is_deleted_local` | BOOLEAN | DEFAULT `false` | Local deletion flag |
| `updated_at_utc` | TEXT | NULLABLE | Mutation timestamp |
| `batch_id` | INTEGER | NULLABLE | Import provenance |

### `attachments`

| Column | Type | Constraints | Description |
| --- | --- | --- | --- |
| `id` | INTEGER | PRIMARY KEY AUTOINCREMENT | Attachment id |
| `message_guid` | TEXT | NOT NULL | Links to `messages.guid` |
| `import_attachment_id` | INTEGER | NULLABLE | Ledger attachment pointer |
| `local_path` | TEXT | NULLABLE | Cached file path |
| `mime_type` | TEXT | NULLABLE | MIME type |
| `uti` | TEXT | NULLABLE | Apple UTI |
| `transfer_name` | TEXT | NULLABLE | Original filename |
| `size_bytes` | INTEGER | NULLABLE | Size in bytes |
| `is_sticker` | BOOLEAN | DEFAULT `false` | Sticker flag |
| `thumb_path` | TEXT | NULLABLE | Thumbnail |
| `created_at_utc` | TEXT | NULLABLE | Attachment timestamp |
| `is_outgoing` | BOOLEAN | DEFAULT `false` | Direction |
| `sha256_hex` | TEXT | NULLABLE | Hash for dedupe |
| `batch_id` | INTEGER | NULLABLE | Import provenance |

### `reactions` and `reaction_counts`

- `reactions` stores individual tapbacks with `message_guid`, `reactor_handle_id`, `kind`, `action`, `parse_confidence`, etc.
- `reaction_counts` aggregates reactions per `message_guid` with integer counts per reaction type.

### `read_state` and `message_read_marks`

- `read_state` tracks the latest read state per chat (`chat_id`, `last_read_at_utc`).
- `message_read_marks` tracks per-message read timestamps keyed by `message_guid`.

## Common Query Patterns

```sql
-- Messages with attachments for a chat (join on GUID)
SELECT
  m.id,
  m.guid,
  m.text,
  m.sent_at_utc,
  m.is_from_me,
  a.transfer_name,
  a.mime_type
FROM messages m
LEFT JOIN attachments a ON a.message_guid = m.guid
WHERE m.chat_id = ?
ORDER BY m.sent_at_utc DESC NULLS LAST;
```

```sql
-- Chat with canonical participants
SELECT
  c.guid,
  c.service,
  c.last_message_at_utc,
  ch.role,
  hc.display_name,
  hc.raw_identifier
FROM chats c
LEFT JOIN chat_to_handle ch ON ch.chat_id = c.id
LEFT JOIN handles_canonical hc ON hc.id = ch.handle_id
WHERE c.id = ?;
```

```sql
-- Message list with attachment counts and sender name
SELECT
  m.guid,
  m.text,
  m.sent_at_utc,
  hc.display_name AS sender_display,
  COUNT(a.id) AS attachment_count
FROM messages m
LEFT JOIN handles_canonical hc ON hc.id = m.sender_handle_id
LEFT JOIN attachments a ON a.message_guid = m.guid
WHERE m.chat_id = ?
GROUP BY m.guid
ORDER BY m.sent_at_utc DESC NULLS LAST;
```

## Drift Access Tips

```dart
// Generated query builders (note the working* getters)
final rows = await db.select(db.workingMessages)
  .join([
    leftOuterJoin(
      db.workingAttachments,
      db.workingAttachments.messageGuid.equalsExp(db.workingMessages.guid),
    ),
  ])
  .where(db.workingMessages.chatId.equals(chatId))
  .get();
```

```dart
// Custom SQL with drift
final results = await db.customSelect(
  'SELECT m.guid, m.text, a.transfer_name '
  'FROM messages m '
  'LEFT JOIN attachments a ON a.message_guid = m.guid '
  'WHERE m.chat_id = ?',
  variables: [Variable.withInt(chatId)],
  readsFrom: {db.workingMessages, db.workingAttachments},
).get();
```

## Anti-Patterns to Avoid

```sql
-- Wrong table name (missing plural)
SELECT * FROM message WHERE id = 1;

-- Wrong join key (should use message GUID)
JOIN attachments a ON a.message_id = m.id;

-- Hard-coded application-support path (wrong location)
/Users/rob/Library/Application Support/remember_every_text/working.db;
```

Always go through the documented providers (`feature_level_providers.dart`) and prefer joins on `message_guid` for attachment/reaction lookups.

## Field Name Quick Map

| Wrong | Correct | Notes |
| --- | --- | --- |
| `message` | `messages` | Table names are plural |
| `timestamp` | `sent_at_utc` | Message event timestamps are stored as strings |
| `message_id` (join key) | `message_guid` | Attachments/reactions link by GUID |
| `file_name` | `transfer_name` | Attachment original filename |
| `normalized_identifier` (handles) | `compound_identifier` | Canonical fingerprint |

## Verification Playbook

1. Inspect the Drift definition in `working_database.dart` after every schema change.
2. Use `sqlite3 working.db ".schema messages"` to confirm the deployed schema.
3. Update this document immediately when columns change.
4. Run `dart run build_runner build --delete-conflicting-outputs` so generated DAOs match the schema.

---

**Last reviewed:** October 30, 2025 (update this date when making changes).
