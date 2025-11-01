import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/working/working_database.dart';

void main() {
  late WorkingDatabase db;

  setUp(() async {
    // Create in-memory database for testing
    db = WorkingDatabase(NativeDatabase.memory());

    // Run migrations to create schema and triggers
    await db.customStatement('PRAGMA foreign_keys = ON');
  });


  group('message_index triggers', () {
    test('INSERT trigger maintains ordinal sequence', () async {
      // Setup: Create a chat
      final chatId = await db
          .into(db.workingChats)
          .insert(WorkingChatsCompanion.insert(guid: 'test-chat'));

      // Insert messages with specific timestamps
      final msg1Id = await db
          .into(db.workingMessages)
          .insert(
            WorkingMessagesCompanion.insert(
              guid: 'msg-1',
              chatId: chatId,
              sentAtUtc: const Value('2024-01-01 10:00:00'),
              textContent: const Value('First message'),
            ),
          );

      final msg2Id = await db
          .into(db.workingMessages)
          .insert(
            WorkingMessagesCompanion.insert(
              guid: 'msg-2',
              chatId: chatId,
              sentAtUtc: const Value('2024-01-01 12:00:00'),
              textContent: const Value('Third message (chronologically)'),
            ),
          );

      // Insert message between existing ones
      final msg3Id = await db
          .into(db.workingMessages)
          .insert(
            WorkingMessagesCompanion.insert(
              guid: 'msg-3',
              chatId: chatId,
              sentAtUtc: const Value('2024-01-01 11:00:00'),
              textContent: const Value('Second message (inserted last)'),
            ),
          );

      // Verify ordinals are correct
      final indices =
          await (db.select(db.messageIndex)
                ..where((tbl) => tbl.chatId.equals(chatId))
                ..orderBy([(tbl) => OrderingTerm.asc(tbl.ordinal)]))
              .get();

      expect(indices.length, 3);
      expect(indices[0].messageId, msg1Id);
      expect(indices[0].ordinal, 0);
      expect(indices[1].messageId, msg3Id);
      expect(indices[1].ordinal, 1);
      expect(indices[2].messageId, msg2Id);
      expect(indices[2].ordinal, 2);
    });

    test('DELETE trigger reindexes remaining messages', () async {
      // Setup: Create a chat with 3 messages
      final chatId = await db
          .into(db.workingChats)
          .insert(WorkingChatsCompanion.insert(guid: 'test-chat'));

      final msg1Id = await db
          .into(db.workingMessages)
          .insert(
            WorkingMessagesCompanion.insert(
              guid: 'msg-1',
              chatId: chatId,
              sentAtUtc: const Value('2024-01-01 10:00:00'),
              textContent: const Value('Message 1'),
            ),
          );

      final msg2Id = await db
          .into(db.workingMessages)
          .insert(
            WorkingMessagesCompanion.insert(
              guid: 'msg-2',
              chatId: chatId,
              sentAtUtc: const Value('2024-01-01 11:00:00'),
              textContent: const Value('Message 2'),
            ),
          );

      final msg3Id = await db
          .into(db.workingMessages)
          .insert(
            WorkingMessagesCompanion.insert(
              guid: 'msg-3',
              chatId: chatId,
              sentAtUtc: const Value('2024-01-01 12:00:00'),
              textContent: const Value('Message 3'),
            ),
          );

      // Delete the middle message
      await (db.delete(
        db.workingMessages,
      )..where((tbl) => tbl.id.equals(msg2Id))).go();

      // Verify ordinals are reindexed
      final indices =
          await (db.select(db.messageIndex)
                ..where((tbl) => tbl.chatId.equals(chatId))
                ..orderBy([(tbl) => OrderingTerm.asc(tbl.ordinal)]))
              .get();

      expect(indices.length, 2);
      expect(indices[0].messageId, msg1Id);
      expect(indices[0].ordinal, 0);
      expect(indices[1].messageId, msg3Id);
      expect(indices[1].ordinal, 1); // Should be 1, not 2
    });

    test('UPDATE trigger reindexes chat when sent_at changes', () async {
      // Setup: Create a chat with 3 messages
      final chatId = await db
          .into(db.workingChats)
          .insert(WorkingChatsCompanion.insert(guid: 'test-chat'));

      final msg1Id = await db
          .into(db.workingMessages)
          .insert(
            WorkingMessagesCompanion.insert(
              guid: 'msg-1',
              chatId: chatId,
              sentAtUtc: const Value('2024-01-01 10:00:00'),
              textContent: const Value('Message 1'),
            ),
          );

      final msg2Id = await db
          .into(db.workingMessages)
          .insert(
            WorkingMessagesCompanion.insert(
              guid: 'msg-2',
              chatId: chatId,
              sentAtUtc: const Value('2024-01-01 11:00:00'),
              textContent: const Value('Message 2'),
            ),
          );

      final msg3Id = await db
          .into(db.workingMessages)
          .insert(
            WorkingMessagesCompanion.insert(
              guid: 'msg-3',
              chatId: chatId,
              sentAtUtc: const Value('2024-01-01 12:00:00'),
              textContent: const Value('Message 3'),
            ),
          );

      // Update msg3 timestamp to be earliest
      await (db.update(
        db.workingMessages,
      )..where((tbl) => tbl.id.equals(msg3Id))).write(
        const WorkingMessagesCompanion(sentAtUtc: Value('2024-01-01 09:00:00')),
      );

      // Verify ordinals reflect new order
      final indices =
          await (db.select(db.messageIndex)
                ..where((tbl) => tbl.chatId.equals(chatId))
                ..orderBy([(tbl) => OrderingTerm.asc(tbl.ordinal)]))
              .get();

      expect(indices.length, 3);
      expect(indices[0].messageId, msg3Id);
      expect(indices[0].ordinal, 0);
      expect(indices[1].messageId, msg1Id);
      expect(indices[1].ordinal, 1);
      expect(indices[2].messageId, msg2Id);
      expect(indices[2].ordinal, 2);
    });

    test('month_key is calculated correctly', () async {
      final chatId = await db
          .into(db.workingChats)
          .insert(WorkingChatsCompanion.insert(guid: 'test-chat'));

      await db
          .into(db.workingMessages)
          .insert(
            WorkingMessagesCompanion.insert(
              guid: 'msg-1',
              chatId: chatId,
              sentAtUtc: const Value('2023-06-15 10:00:00'),
              textContent: const Value('June message'),
            ),
          );

      final indices = await (db.select(
        db.messageIndex,
      )..where((tbl) => tbl.chatId.equals(chatId))).get();

      expect(indices.length, 1);
      expect(indices[0].monthKey, '2023-06');
    });
  });
}
