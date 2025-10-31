# Data Import and Migration Strategy

## 📋 Document Overview

This document provides a comprehensive overview of the data import and migration architecture used in **remember_every_text** for importing macOS Messages (`chat.db`) and AddressBook data into the application's working database.

**Last Updated:** October 2, 2025  
**Architecture Version:** Two-Phase (Import Ledger → Working Database)

---

## 🎯 High-Level Strategy

### The Two-Database Architecture

The application uses a **two-phase import strategy** with separate databases:

1. **Import Database (Ledger)** - `macos_import.db` or `import.db`

   - Immutable ingest ledger
   - Faithful snapshot of macOS data sources
   - Preserves provenance and batch tracking
   - Minimal normalization

2. **Working Database** - `working.db`
   - Application's operational database
   - Fully normalized for query performance
   - DDD-compliant schema (Drift-based)
   - Optimized for UI rendering

### Why Two Databases?

| Benefit                         | Description                                       |
| ------------------------------- | ------------------------------------------------- |
| **Deterministic Re-projection** | Can rebuild working.db from ledger at any time    |
| **Audit Trail**                 | Preserve original Apple data structures           |
| **Batch Tracking**              | Know exactly what data came from which import run |
| **Incremental Imports**         | Only import changes, not full re-imports          |
| **Data Recovery**               | If working.db corrupts, regenerate from ledger    |
| **Testing**                     | Test transformations without touching source data |

---

## 📦 Phase 1: Import (macOS → Ledger)

### Purpose

Extract data from macOS system databases into an immutable ingest ledger that preserves:

- Source database row IDs (`source_rowid`)
- Apple's global unique identifiers (`guid`)
- Batch provenance (`batch_id`)
- Raw binary data (e.g., `attributed_body_blob`)

### Data Sources

#### 1. Messages Database

**Location:** `~/Library/Messages/chat.db`

**Tables Imported:**

- `handle` → `handles` (phone numbers, email addresses)
- `chat` → `chats` (conversations)
- `chat_handle_join` → `chat_participants` (who's in which chat)
- `message` → `messages` (all messages including system, reactions, stickers)
- `attachment` → `attachments` (files, images, videos)
- `message_attachment_join` → `message_attachments` (which files belong to which messages)

**Key Transformations:**

- Convert Apple epoch timestamps to UTC ISO8601
- Store `attributedBody` as raw blob for later extraction
- Parse reaction messages (`associated_message_guid`) into normalized `reactions` table
- Normalize phone numbers to E.164 format
- Normalize email addresses to lowercase

#### 2. AddressBook Database

**Location:** Discovered via `getFolderAggregateEitherProvider`  
**Critical:** Must use correct path resolution (see `01-addressbook-database-resolution.md`)

**Tables Imported:**

- `ZABCDRECORD` → `contacts` (contact records)
- `ZABCDEMAILADDRESS` → `contact_channels` (kind='email')
- `ZABCDPHONENUMBER` → `contact_channels` (kind='phone')
- `ZIMAGEDATA` → contact images (stored as blobs)

### Import Stages

The import process follows these sequential stages:

| Stage                       | Progress | Description                  | Key Operations                       |
| --------------------------- | -------- | ---------------------------- | ------------------------------------ |
| **preparingSources**        | 0-5%     | Validate source files exist  | Check file access, get counts        |
| **clearingLedger**          | 5-10%    | Clear previous ledger data   | Truncate tables, preserve schema     |
| **importingHandles**        | 10-20%   | Import message identities    | Extract handles, normalize addresses |
| **importingChats**          | 20-30%   | Import conversations         | Extract chats, preserve GUIDs        |
| **importingParticipants**   | 30-35%   | Link chats to handles        | Create chat_participants joins       |
| **importingMessages**       | 35-55%   | Import all messages          | Store text, preserve timestamps      |
| **extractingRichContent**   | 55-65%   | Decode attributed bodies     | Call Rust extractor for rich text    |
| **importingAttachments**    | 65-75%   | Import file attachments      | Store file paths, metadata           |
| **linkingMessageArtifacts** | 75-78%   | Link attachments to messages | Create message_attachments joins     |
| **importingAddressBook**    | 78-85%   | Import contacts              | Extract contacts, emails, phones     |
| **linkingContactChannels**  | 85-95%   | Link contacts to handles     | Match by normalized address          |
| **indexingData**            | 95-98%   | Create database indexes      | Optimize query performance           |
| **verifyingIntegrity**      | 98-100%  | Validate import              | Check counts, referential integrity  |

### Batch Tracking

Every import run creates a record in `import_batches`:

```sql
CREATE TABLE import_batches (
  id INTEGER PRIMARY KEY,
  started_at_utc TEXT NOT NULL,
  completed_at_utc TEXT,
  messages_db_path TEXT NOT NULL,
  addressbook_db_path TEXT,
  status TEXT CHECK(status IN ('running','completed','failed')),
  error_message TEXT
);
```

All imported rows reference their `batch_id` for traceability.

### Rich Content Extraction

**Challenge:** 90% of message text is stored in Apple's proprietary `NSAttributedString` binary format.

**Solution:** Rust binary extractor (`extract_messages_limited`)

```bash
# Location
rust/rust/attributed-string-decoder/target/release/extract_messages_limited

# Usage
./extract_messages_limited <blob_file> <output_json>
```

**Process:**

1. Scan messages for non-null `attributed_body`
2. Export blobs to temporary files
3. Call Rust extractor in batch
4. Parse JSON results
5. Update message records with extracted text

**Performance:** ~100-200 messages/second on modern hardware

---

## 🔄 Phase 2: Migration (Ledger → Working Database)

### Purpose

Transform the import ledger into the application's working database with:

- Full normalization for DDD architecture
- Drift-generated schema
- Query-optimized structure
- FTS (Full-Text Search) indexes

### Migration Stages

| Stage                    | Progress | Description                |
| ------------------------ | -------- | -------------------------- |
| **preparingMigration**   | 0-5%     | Validate ledger data       |
| **migratingContacts**    | 5-15%    | Create Contacts entities   |
| **migratingHandles**     | 15-25%   | Create Handle entities     |
| **migratingChats**       | 25-40%   | Create Chat entities       |
| **migratingMessages**    | 40-75%   | Create Message entities    |
| **migratingAttachments** | 75-85%   | Create Attachment entities |
| **buildingIndexes**      | 85-95%   | Create FTS indexes         |
| **finalizingMigration**  | 95-100%  | Verify integrity           |

### Data Transformations

#### Contacts

**Ledger:**

```sql
-- import.db
contacts(id, first, last, company, nickname)
contact_channels(contact_id, kind, value, label)
```

**Working:**

```sql
-- working.db (Drift)
contacts(
  id, display_name, avatar_path,
  first_seen, last_seen, total_messages,
  is_group, import_source_id
)
```

**Transformation Logic:**

- Concatenate first + last → display_name
- Count messages → total_messages
- Extract earliest message timestamp → first_seen
- Extract latest message timestamp → last_seen

#### Messages

**Ledger:**

```sql
-- import.db
messages(
  guid, chat_id, handle_id,
  text, attributed_body_blob,
  date, is_from_me, service,
  associated_message_guid
)
```

**Working:**

```sql
-- working.db (Drift)
messages(
  id, chat_id, sender_handle_id,
  timestamp, content, is_from_me,
  has_attachments, quoted_message_id
)
```

**Transformation Logic:**

- Use extracted rich text as `content`
- Convert date to Unix timestamp
- Resolve `quoted_message_id` from `associated_message_guid`
- Set `has_attachments` flag based on attachment count

#### Attachments

**Ledger:**

```sql
-- import.db
attachments(guid, filename, mime_type, total_bytes)
message_attachments(message_id, attachment_id)
```

**Working:**

```sql
-- working.db (Drift)
attachments(
  id, message_id, file_path,
  mime_type, file_size, thumbnail_path
)
```

**Transformation Logic:**

- Flatten join table into direct foreign key
- Expand tilde (`~`) in file paths
- Generate thumbnail paths for images

### Full-Text Search Setup

After migration, create FTS5 indexes:

```sql
CREATE VIRTUAL TABLE messages_fts USING fts5(
  content,
  content=messages,
  content_rowid=id
);

-- Populate FTS
INSERT INTO messages_fts(rowid, content)
SELECT id, content FROM messages;
```

---

## 🔧 Implementation Details

### Service Classes

#### 1. OrchestratedLedgerImportService

**Location:** `lib/essentials/db_importers/application/services/orchestrated_ledger_import_service.dart`

**Responsibilities:**

- Orchestrate Phase 1 (macOS → Ledger)
- Manage batch tracking
- Call Rust extractor
- Emit progress events
- Handle errors gracefully

**Key Methods:**

```dart
Future<DbImportResult> importFromSources({
  required String messagesDbPath,
  required String addressBookPath,
  required void Function(DbImportProgress) onProgress,
});
```

#### 2. LedgerMigrationService

**Location:** `lib/essentials/db_migrate/application/ledger_migration_service.dart`

**Responsibilities:**

- Orchestrate Phase 2 (Ledger → Working)
- Transform data structures
- Build FTS indexes
- Verify integrity
- Emit progress events

**Key Methods:**

```dart
Future<DbMigrationResult> migrateFromLedger({
  required void Function(DbMigrationProgress) onProgress,
});
```

### Progress Reporting

Both services emit typed progress events:

```dart
class DbImportProgress {
  final DbImportStage stage;
  final double overallProgress;  // 0.0 to 1.0
  final String message;
  final double? stageProgress;   // Progress within current stage
  final int? stageCurrent;       // Items processed
  final int? stageTotal;         // Total items
}
```

**UI Integration:**

```dart
// In view model
await importService.importFromSources(
  messagesDbPath: messagesPath,
  addressBookPath: addressBookPath,
  onProgress: (progress) {
    state = state.copyWith(
      currentStage: progress.stage,
      progress: progress.overallProgress,
      statusMessage: progress.message,
    );
  },
);
```

### Database Providers

**Critical:** Use centralized database providers to prevent SQLite locking:

```dart
// From essentials/databases/feature_level_providers.dart

@riverpod
ImportDatabase importDatabase(ImportDatabaseRef ref) {
  // Singleton instance
  return ImportDatabase(/* ... */);
}

@riverpod
DriftDb workingDatabase(WorkingDatabaseRef ref) {
  // Singleton instance
  return DriftDb(/* ... */);
}
```

**❌ NEVER:**

```dart
// This causes SQLite locking!
final db = ImportDatabase(/* ... */);
```

**✅ ALWAYS:**

```dart
// Use provider
final db = ref.watch(importDatabaseProvider);
```

---

## 🧪 Testing Strategy

### Unit Tests

Test individual transformation functions:

```dart
test('normalizePhoneNumber converts to E.164', () {
  expect(normalizePhoneNumber('+1 (555) 123-4567'), '+15551234567');
});

test('extractDisplayName concatenates correctly', () {
  final name = extractDisplayName(first: 'John', last: 'Doe');
  expect(name, 'John Doe');
});
```

### Integration Tests

Test full import/migration pipeline:

```dart
testWidgets('import completes successfully', (tester) async {
  final service = OrchestratedLedgerImportService(/* ... */);
  final result = await service.runImport(/* ... */);

  expect(result.success, true);
  expect(result.messagesImported, greaterThan(0));
});
```

### Test Databases

Use small sample databases for testing:

```
test/fixtures/
├── sample_chat.db        # 10 messages, 3 chats
├── sample_addressbook.db # 5 contacts
└── expected_output.json  # Expected transformation results
```

---

## ⚡ Performance Considerations

### Batch Processing

**Problem:** Inserting millions of messages one-by-one is slow.

**Solution:** Use batch inserts:

```dart
await db.batch((batch) {
  for (final message in messages) {
    batch.insert(
      db.messages,
      MessagesCompanion(/* ... */),
    );
  }
});
```

**Performance:** ~10x faster than individual inserts

### Indexing Strategy

**During Import:** Disable indexes

```sql
-- Before import
DROP INDEX IF EXISTS idx_messages_chat_id;
DROP INDEX IF EXISTS idx_messages_timestamp;

-- After import
CREATE INDEX idx_messages_chat_id ON messages(chat_id);
CREATE INDEX idx_messages_timestamp ON messages(timestamp);
```

**Performance:** ~3-5x faster import

### Rich Text Extraction

**Problem:** Rust extractor is fast, but calling it per-message is slow.

**Solution:** Batch extraction

```dart
// Collect 1000 messages
final batchSize = 1000;
for (var i = 0; i < totalMessages; i += batchSize) {
  final batch = messages.skip(i).take(batchSize);
  await extractRichTextBatch(batch);
}
```

**Performance:** ~100-200 messages/second

---

## 🔒 Error Handling

### Graceful Degradation

Import should continue even if some operations fail:

```dart
try {
  await importAttachments();
} catch (e) {
  result.warnings.add('Failed to import some attachments: $e');
  // Continue with other stages
}
```

### Rollback Strategy

If critical stage fails, rollback the entire batch:

```dart
await db.transaction((txn) async {
  try {
    await importHandles(txn);
    await importChats(txn);
    await importMessages(txn);
  } catch (e) {
    // Transaction automatically rolls back
    throw ImportException('Import failed: $e');
  }
});
```

### User Feedback

Provide clear error messages:

```dart
if (result.success == false) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Import Failed'),
      content: Text(result.error ?? 'Unknown error'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
}
```

---

## 📊 Monitoring & Instrumentation

### Progress Tracking

Track granular progress for each stage:

```dart
void Function(String stage, String substage, String event, {int? itemCount})?
  onInstrument;

// Usage
onInstrument?.call('importingMessages', 'batchInsert', 'start');
// ... perform operation ...
onInstrument?.call(
  'importingMessages',
  'batchInsert',
  'end',
  itemCount: messages.length,
);
```

### Telemetry

Log import statistics:

```dart
final stats = {
  'duration_seconds': duration.inSeconds,
  'messages_imported': result.messagesImported,
  'messages_per_second': result.messagesImported / duration.inSeconds,
  'attachments_imported': result.attachmentsImported,
  'contacts_imported': result.contactsImported,
};

analytics.logEvent('import_completed', stats);
```

---

## 🚀 Incremental Import Strategy

### Concept

Instead of re-importing everything, only import changes since last import.

### Implementation

**Track Last Import:**

```dart
await importDb.setMetadata(
  key: 'last_import_max_message_rowid',
  value: maxRowId.toString(),
);
```

**Next Import:**

```dart
final lastMaxRowId = int.parse(
  await importDb.getMetadata('last_import_max_message_rowid') ?? '0',
);

final newMessages = await messagesDb.query(
  'message',
  where: 'ROWID > ?',
  whereArgs: [lastMaxRowId],
);
```

**Benefits:**

- Much faster for large databases
- Lower memory usage
- Can run more frequently

**Current Status:** 🚧 Not yet implemented (future enhancement)

---

## 🎓 Best Practices

### 1. Always Validate Sources

```dart
Future<void> _validateAddressBookDatabase(Database db, String path) async {
  final result = await db.query('ZABCDRECORD');
  final contactCount = result.length;

  if (contactCount < 1) {
    throw Exception(
      'AddressBook database validation failed: Found only $contactCount contacts.'
    );
  }
}
```

### 2. Preserve Provenance

Always keep `source_rowid` and `guid`:

```dart
await db.insert('messages', {
  'guid': appleGuid,
  'source_rowid': appleRowId,
  'batch_id': currentBatchId,
  // ... other fields
});
```

### 3. Use Transactions

Group related operations:

```dart
await db.transaction((txn) async {
  await insertMessages(txn);
  await updateCounts(txn);
  await rebuildIndexes(txn);
});
```

### 4. Report Progress

Keep UI responsive:

```dart
for (var i = 0; i < total; i++) {
  if (i % 100 == 0) {
    onProgress(
      stage: currentStage,
      progress: i / total,
      message: 'Processing item $i of $total...',
    );
  }
  await processItem(items[i]);
}
```

### 5. Handle Edge Cases

```dart
// Empty messages
if (text == null || text.isEmpty) {
  text = '(no content)';
}

// Missing timestamps
final timestamp = date ?? DateTime.now().millisecondsSinceEpoch;

// Invalid attachments
if (!File(attachmentPath).existsSync()) {
  result.warnings.add('Attachment not found: $attachmentPath');
  continue;
}
```

---

## 📁 File Locations Reference

### Source Databases

```
~/Library/Messages/chat.db
~/Library/Application Support/AddressBook/Sources/[UUID]/AddressBook-v22.abcddb
```

### Application Databases

```
/Users/rob/sqlite_rmc/remember_every_text/macos_import.db  # Import ledger
/Users/rob/sqlite_rmc/remember_every_text/working.db      # Working database
```

### Code Locations

```
lib/essentials/db_importers/             # Import system
├── application/
│   └── import/
│       └── ledger_import_service.dart   # Main import service
├── domain/
│   ├── entities/
│   │   └── db_import_result.dart        # Result DTOs
│   └── ports/
│       └── import_database_port.dart    # Database interface
└── infrastructure/
    └── adapters/
        └── sqflite_import_database.dart # SQLite implementation

lib/essentials/db_migrate/               # Migration system
├── application/
│   └── ledger_migration_service.dart    # Main migration service
└── domain/
    └── entities/
        └── db_migration_result.dart     # Result DTOs

lib/essentials/databases/                # Database providers
└── feature_level_providers.dart         # Centralized DB access

rust/rust/attributed-string-decoder/     # Rust extractor
└── target/release/
    └── extract_messages_limited         # Binary
```

---

## 🔗 Related Documentation

- **Database Schema**: `10-database-schema-reference.md`
- **AddressBook Resolution**: `01-addressbook-database-resolution.md`
- **Rust Message Extractor**: `08-rust-message-extractor.md`
- **Import DB Notes**: `_DATABASE_DOCUMENTATION/1-IMPORT_DB_NOTES.md`
- **Working DB Notes**: `_DATABASE_DOCUMENTATION/3-WORKING_DB_NOTES.md`

---

## ❓ FAQ

### Q: Why not import directly to working.db?

**A:** The two-phase approach provides:

- Audit trail of source data
- Deterministic rebuilds
- Testing without affecting working data
- Recovery from corruption

### Q: How long does a full import take?

**A:** Depends on database size:

- Small (< 10K messages): 10-30 seconds
- Medium (10K-100K messages): 1-5 minutes
- Large (> 100K messages): 5-15 minutes

### Q: Can I run import while app is running?

**A:** Yes, but working database will be locked during migration phase. Consider:

- Showing blocking progress dialog
- Running migration in background
- Using read-only mode during migration

### Q: What if import fails mid-way?

**A:** The import uses transactions and batch tracking:

- Incomplete batches are marked as 'failed'
- Can restart import (will create new batch)
- Previous batch data remains for debugging

### Q: How do I debug import issues?

**A:**

1. Check `import_logs` table for detailed errors
2. Enable instrumentation callbacks
3. Run with smaller dataset first
4. Use SQLite CLI to inspect intermediate state

---

## 🔄 Version History

| Version | Date        | Changes                             |
| ------- | ----------- | ----------------------------------- |
| 1.0     | Oct 2, 2025 | Initial comprehensive documentation |

---

**Document Status:** ✅ **COMPLETE AND CURRENT**

This document reflects the actual implementation as of October 2, 2025. For updates or corrections, modify this file and update the version history.
