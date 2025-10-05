# Overlay Database: Extension Possibilities

## Core Concept

The overlay database (`user_overlays.db`) is a **separate SQLite database** that stores user-specific annotations, preferences, and metadata **without modifying the imported data** in `working.db`. This architecture enables powerful extensions while keeping the source data pristine.

## Key Principle

**Working Database** = Read-only projection of imported Messages/AddressBook data  
**Overlay Database** = User's layer of intelligence, organization, and customization

---

## Current Implementation (Phase 1)

✅ **ParticipantOverrides**: Short names, mute status, notes per contact  
✅ **ChatOverrides**: Custom chat names, colors, notes

---

## Powerful Extensions to Consider

### 1. Message Annotations 🔥 HIGH VALUE

```dart
class MessageAnnotations extends Table {
  IntColumn get messageId => integer()();  // References working.messages.id
  TextColumn get tags => text().nullable()();  // JSON array: ["important", "todo"]
  BoolColumn get isStarred => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  TextColumn get userNotes => text().nullable()();  // Personal annotation
  IntColumn get priority => integer().nullable()();  // 1-5 priority rating
  TextColumn get remindAt => text().nullable()();  // ISO8601 for reminders
  TextColumn get createdAtUtc => text()();
  TextColumn get updatedAtUtc => text()();

  @override
  Set<Column> get primaryKey => {messageId};
}
```

**Use Cases:**

- ⭐ Star important messages for quick access
- 🏷️ Tag messages: `#work`, `#receipt`, `#address`, `#todo`, `#reference`
- 📝 Add personal notes: "This is where they gave me the wifi password"
- 🔔 Set reminders: "Follow up on this in 2 weeks"
- 📊 Priority ratings: Critical customer complaints vs casual chats
- 🗄️ Archive old conversations without deleting them

**Search Power:**

```dart
// Find all messages tagged #receipt from last year
SELECT m.* FROM working.messages m
JOIN user_overlays.message_annotations ma ON m.id = ma.message_id
WHERE ma.tags LIKE '%receipt%'
  AND m.date BETWEEN '2024-01-01' AND '2024-12-31';
```

---

### 2. Smart Collections / Saved Searches

```dart
class SmartCollections extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();  // "Work Emergencies", "Family Photos"
  TextColumn get description => text().nullable()();
  TextColumn get query => text()();  // JSON query criteria
  TextColumn get icon => text().nullable()();
  IntColumn get sortOrder => integer()();
  TextColumn get createdAtUtc => text()();
  TextColumn get updatedAtUtc => text()();
}
```

**Use Cases:**

- 📁 "All messages with attachments tagged #receipt"
- 👨‍👩‍👧 "Messages from family members containing addresses"
- 🚨 "Starred messages from last 30 days"
- 🔗 "Messages with links tagged #reference"
- 📅 "Messages with dates/times (appointments)"

---

### 3. Message Relationships / Threads

```dart
class MessageRelationships extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sourceMessageId => integer()();
  IntColumn get targetMessageId => integer()();
  TextColumn get relationshipType => text()();  // "reply-to", "relates-to", "follows-up"
  TextColumn get createdAtUtc => text()();

  @override
  Set<Column> get primaryKey => {sourceMessageId, targetMessageId, relationshipType};
}
```

**Use Cases:**

- 🔗 Link related messages across different chats
- 📧 Create manual "thread" connections for context
- ↩️ Track which message answers which question
- 🔄 Build conversation flows for multi-party discussions

---

### 4. Participant Groups (For Filtering/Organization)

```dart
class ParticipantGroups extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();  // "Family", "Work Team", "College Friends"
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

**Use Cases:**

- 👥 Filter chats by group: "Show all messages with Work Team"
- 🎨 Color-code messages from different groups
- 📊 Analytics: "How much do I text family vs work?"
- 🔍 Search: "Find messages from college friends mentioning 'reunion'"

---

### 5. Custom Chat Folders / Organization

```dart
class ChatFolders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();  // "Active", "Archive", "Need Response"
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

**Use Cases:**

- 📂 Organize chats beyond chronological order
- 🚦 Triage system: "Urgent", "Can Wait", "Waiting for Reply"
- 🗄️ Archive completed conversations
- 🎯 Project-based folders: "Home Renovation", "Wedding Planning"

---

### 6. Reading State / Progress Tracking

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

**Use Cases:**

- 📖 Track what you've actually read vs just scrolled past
- 🔢 Accurate unread counts (not just "new since import")
- ⏱️ "Continue reading" feature - return to exact position
- 📊 Analytics: "Which chats do I actually read?"

---

### 7. Bookmarks / Pins

```dart
class MessageBookmarks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get messageId => integer()();
  TextColumn get label => text().nullable()();  // Optional name for bookmark
  IntColumn get sortOrder => integer()();
  TextColumn get createdAtUtc => text()();

  @override
  Set<Column> get primaryKey => {messageId};
}
```

**Use Cases:**

- 📌 Pin critical messages to top of chat
- 🔖 Create bookmark list: "Important info to remember"
- 🗂️ Quick access sidebar: Jump to key messages across all chats

---

### 8. Export Annotations

```dart
class ExportHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get exportType => text()();  // "pdf", "txt", "json"
  TextColumn get filters => text()();  // JSON of what was exported
  TextColumn get filePath => text()();
  IntColumn get messageCount => integer()();
  TextColumn get exportedAtUtc => text()();
}
```

**Use Cases:**

- 📄 Track what you've exported for legal/business purposes
- 🔁 Re-export with same filters
- 📊 Audit trail of data exports

---

### 9. AI/ML Metadata

```dart
class MessageAiMetadata extends Table {
  IntColumn get messageId => integer()();
  TextColumn get sentiment => text().nullable()();  // "positive", "negative", "neutral"
  RealColumn get sentimentScore => real().nullable()();
  TextColumn get category => text().nullable()();  // "question", "appointment", "info"
  TextColumn get entities => text().nullable()();  // JSON: ["Person:John", "Location:NYC"]
  TextColumn get summary => text().nullable()();  // AI-generated summary
  TextColumn get computedAtUtc => text()();

  @override
  Set<Column> get primaryKey => {messageId};
}
```

**Use Cases:**

- 🤖 Automatic message categorization
- 😊 Sentiment analysis: "Find all negative feedback"
- 🏷️ Entity extraction: "All messages mentioning NYC"
- 📝 AI summaries of long messages
- 🔍 Semantic search powered by embeddings

---

### 10. Custom Metadata / Key-Value Store

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

**Use Cases:**

- 🎨 Store ANY custom data per message
- 🔌 Extension point for future features
- 🧪 Experiment with new metadata without schema changes

---

## Architectural Benefits

### ✅ Data Integrity

- Working database stays **pristine** - exactly matches source data
- Can always re-import and overlay data remains valid
- Easy to backup just user customizations

### ✅ Performance

- Indexed overlay tables enable fast searches
- Can add indexes specific to user's usage patterns
- Separate database means no table lock conflicts

### ✅ Privacy

- User annotations are local-only
- Can encrypt overlay database separately from working database
- Easy to share working.db without exposing personal notes

### ✅ Flexibility

- Add new overlay tables without touching import logic
- Experiment with features without risking data integrity
- Easy rollback: just delete overlay database

### ✅ Portability

- Export just overlay database to backup preferences
- Sync overlay across devices (future: Supabase sync)
- Share overlay "themes" with other users

---

## Implementation Priority Recommendations

### 🔥 Immediate High Value (Next Phase)

1. **Message Annotations** - Starring, tagging, notes

   - Massive search/organization power
   - Low complexity
   - High user impact

2. **Reading State** - Track what you've actually read
   - Better UX than "show all"
   - Natural feature users expect
   - Simple schema

### 🌟 Medium-Term Value

3. **Participant Groups** - For filtering/organization
4. **Smart Collections** - Saved searches
5. **Chat Folders** - Custom organization

### 🚀 Advanced Features

6. **Message Relationships** - Thread linking
7. **AI Metadata** - Automatic categorization
8. **Bookmarks/Pins** - Quick access

---

## Query Examples: The Power of Overlays

### Example 1: Tagged Message Search

```dart
// Find all messages tagged "receipt" with amount > $100
final results = await database.customSelect('''
  SELECT
    m.id, m.text, m.date,
    ma.tags, ma.user_notes
  FROM working.messages m
  INNER JOIN user_overlays.message_annotations ma ON m.id = ma.message_id
  WHERE ma.tags LIKE '%receipt%'
    AND m.text LIKE '%$%'
  ORDER BY m.date DESC
''').get();
```

### Example 2: Unread Messages from Family

```dart
// Show unread messages from family group
final results = await database.customSelect('''
  SELECT
    m.id, m.text, m.date,
    p.full_name, po.short_name
  FROM working.messages m
  INNER JOIN working.participants p ON m.sender_participant_id = p.id
  INNER JOIN user_overlays.participant_group_members pgm ON p.id = pgm.participant_id
  INNER JOIN user_overlays.participant_groups pg ON pgm.group_id = pg.id
  LEFT JOIN user_overlays.participant_overrides po ON p.id = po.participant_id
  LEFT JOIN user_overlays.reading_state rs ON m.chat_id = rs.chat_id
  WHERE pg.name = 'Family'
    AND (rs.last_read_message_id IS NULL OR m.id > rs.last_read_message_id)
  ORDER BY m.date DESC
''').get();
```

### Example 3: Smart Collection - "Important Unfinished Business"

```dart
// Messages that are starred OR high priority AND not archived
final results = await database.customSelect('''
  SELECT
    m.id, m.text, m.date,
    ma.priority, ma.tags, ma.remind_at
  FROM working.messages m
  INNER JOIN user_overlays.message_annotations ma ON m.id = ma.message_id
  WHERE (ma.is_starred = 1 OR ma.priority >= 4)
    AND (ma.is_archived = 0 OR ma.is_archived IS NULL)
    AND ma.remind_at IS NOT NULL
  ORDER BY ma.priority DESC, m.date DESC
''').get();
```

---

## Future: Supabase Sync Potential

Once overlays are mature, you could sync them to Supabase for:

- 📱 Multi-device sync
- ☁️ Cloud backup of user annotations
- 👥 Shared smart collections with other users
- 🤖 Server-side AI processing of annotations

**Key insight**: Overlay data is **small** compared to working database. Syncing user preferences/annotations is far more practical than syncing entire message database.

---

## Conclusion

The overlay database pattern transforms your app from a **message viewer** into a **message intelligence system**. Every extension above:

- ✅ Keeps working.db pristine
- ✅ Adds powerful user capabilities
- ✅ Enables advanced search/filtering
- ✅ Improves information retrieval dramatically

**Your intuition is exactly right**: Message tagging alone would be transformational. Combined with the other possibilities, you're building a system that could handle decades of message history with sophisticated organization and retrieval capabilities.

---

## Next Steps

Would you like me to implement:

1. **Message Annotations** (tags, starring, notes) - Highest immediate value
2. **Reading State** tracking - Natural UX improvement
3. **Participant Groups** - Organization/filtering power
4. Something else that excites you?

The beauty of this architecture is we can add features incrementally without risk to your core data.
