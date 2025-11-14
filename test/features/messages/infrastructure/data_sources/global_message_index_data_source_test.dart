import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'package:remember_this_text/features/messages/infrastructure/data_sources/global_message_index_data_source.dart';

void main() {
  late WorkingDatabase db;
  late GlobalMessageIndexDataSource dataSource;

  setUp(() async {
    db = WorkingDatabase(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');
    dataSource = GlobalMessageIndexDataSource(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedMessages() async {
    final chatA = await db
        .into(db.workingChats)
        .insert(WorkingChatsCompanion.insert(guid: 'chat-a'));
    final chatB = await db
        .into(db.workingChats)
        .insert(WorkingChatsCompanion.insert(guid: 'chat-b'));

    await db
        .into(db.workingMessages)
        .insert(
          WorkingMessagesCompanion.insert(
            guid: 'msg-1',
            chatId: chatA,
            sentAtUtc: const Value('2024-01-01 09:00:00'),
          ),
        );
    await db
        .into(db.workingMessages)
        .insert(
          WorkingMessagesCompanion.insert(
            guid: 'msg-2',
            chatId: chatB,
            sentAtUtc: const Value('2024-01-01 10:00:00'),
          ),
        );
    await db
        .into(db.workingMessages)
        .insert(
          WorkingMessagesCompanion.insert(
            guid: 'msg-3',
            chatId: chatA,
            sentAtUtc: const Value('2024-01-01 11:00:00'),
          ),
        );
    await db
        .into(db.workingMessages)
        .insert(
          WorkingMessagesCompanion.insert(
            guid: 'msg-4',
            chatId: chatB,
            sentAtUtc: const Value('2024-01-01 12:00:00'),
          ),
        );

    await db.rebuildGlobalMessageIndex();
  }

  test('getTotalCount returns number of indexed messages', () async {
    await seedMessages();

    final count = await dataSource.getTotalCount();

    expect(count, 4);
  });

  test('fetchFirstPage returns ordinals in ascending order', () async {
    await seedMessages();

    final entries = await dataSource.fetchFirstPage(2);

    expect(entries.map((e) => e.ordinal), [0, 1]);
    expect(entries.first.chatId != entries.last.chatId, isTrue);
  });

  test('fetchAfterOrdinal returns results after the cursor', () async {
    await seedMessages();

    final entries = await dataSource.fetchAfterOrdinal(
      startExclusiveOrdinal: 1,
      limit: 2,
    );

    expect(entries.map((e) => e.ordinal), [2, 3]);
    expect(entries.length, 2);
  });

  test(
    'fetchBeforeOrdinal returns results before the cursor in ascending order',
    () async {
      await seedMessages();

      final entries = await dataSource.fetchBeforeOrdinal(
        endExclusiveOrdinal: 3,
        limit: 2,
      );

      expect(entries.map((e) => e.ordinal), [1, 2]);
    },
  );

  test('getByOrdinal returns entry with matching metadata', () async {
    await seedMessages();

    final entry = await dataSource.getByOrdinal(2);

    expect(entry, isNotNull);
    expect(entry!.ordinal, 2);
    expect(entry.monthKey, '2024-01');
  });
}
