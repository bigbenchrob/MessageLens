# Overlay Database: Extension Possibilities

The overlay database (`user_overlays.db`) stores user-specific annotations, preferences, and metadata without mutating imported source data in `working.db`. This architecture enables rich extensions while keeping ledger and projection tables pristine.

## Core Principle

- **Working database** – Read-only projection of Messages/AddressBook data.
- **Overlay database** – User’s layer of intelligence, organisation, and customisation.

## Current Implementation (Phase 1)

- **ParticipantOverrides** – Short names, mute status, notes per contact.
- **ChatOverrides** – Custom chat names, colours, notes.

## High-Value Extensions

### 1. Message Annotations (Recommended)

```dart
class MessageAnnotations extends Table {
  IntColumn get messageId => integer()();
  TextColumn get tags => text().nullable()();
  BoolColumn get isStarred => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  TextColumn get userNotes => text().nullable()();
  IntColumn get priority => integer().nullable()();
  TextColumn get remindAt => text().nullable()();
  TextColumn get createdAtUtc => text()();
  TextColumn get updatedAtUtc => text()();

  @override
  Set<Column> get primaryKey => {messageId};
}
```

Use cases: starred messages, tagging (`#receipt`, `#todo`), personal notes, reminders.

### 2. Smart Collections / Saved Searches

```dart
class SmartCollections extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get query => text()();
  TextColumn get icon => text().nullable()();
  IntColumn get sortOrder => integer()();
  TextColumn get createdAtUtc => text()();
  TextColumn get updatedAtUtc => text()();
}
```

Use cases: receipts with attachments, family messages containing addresses, starred messages from last 30 days.

### 3. Message Relationships / Threads

```dart
class MessageRelationships extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sourceMessageId => integer()();
  IntColumn get targetMessageId => integer()();
  TextColumn get relationshipType => text()();
  TextColumn get createdAtUtc => text()();

  @override
  Set<Column> get primaryKey => {sourceMessageId, targetMessageId, relationshipType};
}
```

Use cases: manual threading, cross-chat references, follow-up tracking.

### 4. Participant Groups

```dart
class ParticipantGroups extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get color => text().nullable()();
  TextColumn get icon => text().nullable()();
  TextColumn get createdAtUtc => text()();
}

class ParticipantGroupMembers extends Table {
  IntColumn get groupId => integer().references(ParticipantGroups, #id)();
  IntColumn get participantId => integer()();
  TextColumn get createdAtUtc => text()();

  @override
  Set<Column> get primaryKey => {groupId, participantId};
}
```

Use cases: filtering chats by group, colour-coding messages, analytics (“family versus work”).

### 5. Custom Chat Folders

```dart
class ChatFolders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get color => text().nullable()();
  IntColumn get sortOrder => integer()();
  TextColumn get createdAtUtc => text()();
}

class ChatFolderMembership extends Table {
  IntColumn get folderId => integer().references(ChatFolders, #id)();
  IntColumn get chatId => integer()();
  TextColumn get addedAtUtc => text()();

  @override
  Set<Column> get primaryKey => {folderId, chatId};
}
```

Use cases: triage (“Urgent”, “Waiting”), project folders, lightweight archiving.

### 6. Reading State Tracking

```dart
class ReadingState extends Table {
  IntColumn get chatId => integer()();
  IntColumn get lastReadMessageId => integer().nullable()();
  IntColumn get unreadCount => integer().withDefault(const Constant(0))();
  TextColumn get lastViewedAtUtc => text()();
  TextColumn get updatedAtUtc => text()();

  @override
  Set<Column> get primaryKey => {chatId};
}
```

Use cases: accurate unread counts, resume-from-last-read, analytics on reading behaviour.

### 7. Message Bookmarks / Pins

```dart
class MessageBookmarks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get messageId => integer()();
  TextColumn get label => text().nullable()();
  IntColumn get sortOrder => integer()();
  TextColumn get createdAtUtc => text()();

  @override
  Set<Column> get primaryKey => {messageId};
}
```

Use cases: pinning critical messages, quick access lists.

### 8. Export History

```dart
class ExportHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get exportType => text()();
  TextColumn get filters => text()();
  TextColumn get filePath => text()();
  IntColumn get messageCount => integer()();
  TextColumn get exportedAtUtc => text()();
}
```

Use cases: audit trail for exports, easy re-runs with identical filters.

### 9. AI / ML Metadata

```dart
class MessageAiMetadata extends Table {
  IntColumn get messageId => integer()();
  TextColumn get sentiment => text().nullable()();
  RealColumn get sentimentScore => real().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get entities => text().nullable()();
  TextColumn get summary => text().nullable()();
  TextColumn get computedAtUtc => text()();

  @override
  Set<Column> get primaryKey => {messageId};
}
```

Use cases: automatic categorisation, sentiment analysis, entity extraction, AI summaries.

### 10. Flexible Key-Value Metadata

```dart
class MessageMetadata extends Table {
  IntColumn get messageId => integer()();
  TextColumn get key => text()();
  TextColumn get value => text()();
  TextColumn get createdAtUtc => text()();

  @override
  Set<Column> get primaryKey => {messageId, key};
}
```

Use cases: extensible metadata without schema churn, experimentation, plugin hooks.

## Architectural Benefits

- **Data integrity** – `working.db` stays pristine; overlay data can be reset without touching the projection.
- **Performance** – Overlay tables can be indexed independently for fast searches.
- **Privacy** – User annotations stay local and can be encrypted or backed up separately.
- **Flexibility** – Features can ship incrementally; deleting `user_overlays.db` reverts to a clean state.
- **Portability** – Overlay data is lightweight and suitable for sync (e.g., Supabase) once matured.

## Sample Queries

```dart
// Tagged receipts over $100
final rows = await database.customSelect('''
  SELECT m.id, m.text, m.date, ma.tags, ma.user_notes
  FROM working.messages m
  INNER JOIN user_overlays.message_annotations ma
          ON m.id = ma.message_id
  WHERE ma.tags LIKE '%receipt%'
    AND m.text LIKE '%$%'
  ORDER BY m.date DESC
''').get();
```

```dart
// Unread messages from the "Family" participant group
final results = await database.customSelect('''
  SELECT m.id, m.text, m.date,
         p.full_name, po.short_name
  FROM working.messages m
  INNER JOIN working.participants p ON m.sender_participant_id = p.id
  INNER JOIN user_overlays.participant_group_members pgm
          ON p.id = pgm.participant_id
  INNER JOIN user_overlays.participant_groups pg
          ON pgm.group_id = pg.id
  LEFT JOIN user_overlays.participant_overrides po
         ON p.id = po.participant_id
  LEFT JOIN user_overlays.reading_state rs
         ON m.chat_id = rs.chat_id
  WHERE pg.name = 'Family'
    AND (rs.last_read_message_id IS NULL
      OR m.id > rs.last_read_message_id)
  ORDER BY m.date DESC
''').get();
```

```dart
// Important unfinished business collection
final results = await database.customSelect('''
  SELECT m.id, m.text, m.date,
         ma.priority, ma.tags, ma.remind_at
  FROM working.messages m
  INNER JOIN user_overlays.message_annotations ma
          ON m.id = ma.message_id
  WHERE (ma.is_starred = 1 OR ma.priority >= 4)
    AND (ma.is_archived = 0 OR ma.is_archived IS NULL)
    AND ma.remind_at IS NOT NULL
  ORDER BY ma.priority DESC, m.date DESC
''').get();
```

## Supabase Sync Potential

Once overlays mature, consider syncing them to Supabase for multi-device support, cloud backup, or server-side processing. Overlay data remains small compared to the working projection, making synchronisation practical.

## Next Steps

1. Prioritise `MessageAnnotations` and `ReadingState` for immediate UX wins.
2. Design overlay migrations alongside `working.db` so user customisations survive upgrades.
3. Keep overlay providers under `lib/essentials/db/feature_level_providers.dart` to align with the single-connection rule.
