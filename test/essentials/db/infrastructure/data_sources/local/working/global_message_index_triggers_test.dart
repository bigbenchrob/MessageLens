import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/working/working_database.dart';

void main() {
  late WorkingDatabase db;

  setUp(() async {
    db = WorkingDatabase(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');
    await db.rebuildGlobalMessageIndex();
    await db.rebuildMessageIndex();
    await db.createMessageIndexTriggers();
  });

  tearDown(() async {
    await db.close();
  });

  group('global_message_index triggers', () {
    test('INSERT trigger maintains global ordinal order', () async {
      final chatA = await db
          .into(db.workingChats)
          .insert(WorkingChatsCompanion.insert(guid: 'chat-a'));
      final chatB = await db
          .into(db.workingChats)
          .insert(WorkingChatsCompanion.insert(guid: 'chat-b'));

      final msg1 = await db
          .into(db.workingMessages)
          .insert(
            WorkingMessagesCompanion.insert(
              guid: 'msg-1',
              chatId: chatA,
              sentAtUtc: const Value('2024-01-01 09:00:00'),
            ),
          );
      final msg2 = await db
          .into(db.workingMessages)
          .insert(
            WorkingMessagesCompanion.insert(
              guid: 'msg-2',
              chatId: chatB,
              sentAtUtc: const Value('2024-01-01 10:00:00'),
            ),
          );
      final msg3 = await db
          .into(db.workingMessages)
          .insert(
            WorkingMessagesCompanion.insert(
              guid: 'msg-3',
              chatId: chatA,
              sentAtUtc: const Value('2024-01-01 11:00:00'),
            ),
          );
      final msg4 = await db
          .into(db.workingMessages)
          .insert(
            WorkingMessagesCompanion.insert(
              guid: 'msg-4',
              chatId: chatB,
              sentAtUtc: const Value('2024-01-01 12:00:00'),
            ),
          );

      final rows = await (db.select(
        db.globalMessageIndex,
      )..orderBy([(tbl) => OrderingTerm.asc(tbl.ordinal)])).get();

      expect(rows.map((r) => r.messageId), [msg1, msg2, msg3, msg4]);
      expect(rows.map((r) => r.ordinal), [0, 1, 2, 3]);
    });

    test('DELETE trigger reindexes ordinals', () async {
      final chatId = await db
          .into(db.workingChats)
          .insert(WorkingChatsCompanion.insert(guid: 'chat'));

      final msg1 = await db
          .into(db.workingMessages)
          .insert(
            WorkingMessagesCompanion.insert(
              guid: 'msg-1',
              chatId: chatId,
              sentAtUtc: const Value('2024-01-01 09:00:00'),
            ),
          );
      final msg2 = await db
          .into(db.workingMessages)
          .insert(
            WorkingMessagesCompanion.insert(
              guid: 'msg-2',
              chatId: chatId,
              sentAtUtc: const Value('2024-01-01 10:00:00'),
            ),
          );
      final msg3 = await db
          .into(db.workingMessages)
          .insert(
            WorkingMessagesCompanion.insert(
              guid: 'msg-3',
              chatId: chatId,
              sentAtUtc: const Value('2024-01-01 11:00:00'),
            ),
          );

      await (db.delete(
        db.workingMessages,
      )..where((tbl) => tbl.id.equals(msg2))).go();

      final rows = await (db.select(
        db.globalMessageIndex,
      )..orderBy([(tbl) => OrderingTerm.asc(tbl.ordinal)])).get();

      expect(rows.length, 2);
      expect(rows.map((r) => r.messageId), [msg1, msg3]);
      expect(rows.map((r) => r.ordinal), [0, 1]);
    });

    test('UPDATE trigger reorders by sent_at_utc', () async {
      final chatId = await db
          .into(db.workingChats)
          .insert(WorkingChatsCompanion.insert(guid: 'chat'));

      final early = await db
          .into(db.workingMessages)
          .insert(
            WorkingMessagesCompanion.insert(
              guid: 'msg-early',
              chatId: chatId,
              sentAtUtc: const Value('2024-01-01 09:00:00'),
            ),
          );
      final middle = await db
          .into(db.workingMessages)
          .insert(
            WorkingMessagesCompanion.insert(
              guid: 'msg-middle',
              chatId: chatId,
              sentAtUtc: const Value('2024-01-01 10:00:00'),
            ),
          );
      final late = await db
          .into(db.workingMessages)
          .insert(
            WorkingMessagesCompanion.insert(
              guid: 'msg-late',
              chatId: chatId,
              sentAtUtc: const Value('2024-01-01 11:00:00'),
            ),
          );

      await (db.update(
        db.workingMessages,
      )..where((tbl) => tbl.id.equals(late))).write(
        const WorkingMessagesCompanion(sentAtUtc: Value('2023-12-31 23:59:59')),
      );

      final rows = await (db.select(
        db.globalMessageIndex,
      )..orderBy([(tbl) => OrderingTerm.asc(tbl.ordinal)])).get();

      expect(rows.map((r) => r.messageId), [late, early, middle]);
      expect(rows.map((r) => r.ordinal), [0, 1, 2]);
    });

    test('month_key column uses YYYY-MM format', () async {
      final chatId = await db
          .into(db.workingChats)
          .insert(WorkingChatsCompanion.insert(guid: 'chat'));

      await db
          .into(db.workingMessages)
          .insert(
            WorkingMessagesCompanion.insert(
              guid: 'msg-month',
              chatId: chatId,
              sentAtUtc: const Value('2023-07-04 12:00:00'),
            ),
          );

      final rows = await db.select(db.globalMessageIndex).get();

      expect(rows.length, 1);
      expect(rows.single.monthKey, '2023-07');
    });
  });
}
