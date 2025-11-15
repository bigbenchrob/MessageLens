import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'package:remember_this_text/features/search/indexing/fts_multi_term_indexer.dart';
import 'package:remember_this_text/features/search/indexing/search_indexer.dart';

void main() {
  late WorkingDatabase db;
  late SearchIndexContext context;
  late FtsMultiTermIndexer indexer;

  SearchIndexContext buildContext() {
    return SearchIndexContext(
      db: db,
      infoLogger: (_, {context = const {}}) {},
      errorLogger: (_, {context = const {}}) {},
    );
  }

  setUp(() {
    db = WorkingDatabase(NativeDatabase.memory());
    indexer = FtsMultiTermIndexer(batchSize: 16);
    context = buildContext();
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> countFtsRows() async {
    final row = await db.customSelect(
      'SELECT COUNT(*) AS c FROM messages_fts',
    ).getSingle();
    return (row.data['c'] as int?) ?? 0;
  }

  group('FtsMultiTermIndexer', () {
    test('rebuildAll populates messages_fts', () async {
      final chatId = await db
          .into(db.workingChats)
          .insert(const WorkingChatsCompanion(guid: Value('chat-fts')));
      await db.into(db.workingMessages).insert(
            WorkingMessagesCompanion.insert(
              guid: 'fts-msg-1',
              chatId: chatId,
              textContent: const Value('hello modular search'),
              sentAtUtc: const Value('2024-01-01T00:00:00Z'),
            ),
          );
      await db.into(db.workingMessages).insert(
            WorkingMessagesCompanion.insert(
              guid: 'fts-msg-2',
              chatId: chatId,
              textContent: const Value('hello world'),
              sentAtUtc: const Value('2024-01-02T00:00:00Z'),
            ),
          );

      await indexer.rebuildAll(context);

      expect(await countFtsRows(), 2);
      final rows = await db.customSelect(
        "SELECT rowid FROM messages_fts WHERE messages_fts MATCH 'hello*'",
      ).get();
      expect(rows, isNotEmpty);
    });

    test('rebuildForMessages refreshes updated rows', () async {
      final chatId = await db
          .into(db.workingChats)
          .insert(const WorkingChatsCompanion(guid: Value('chat-fts-2')));
      final messageId = await db.into(db.workingMessages).insert(
            WorkingMessagesCompanion.insert(
              guid: 'fts-msg-3',
              chatId: chatId,
              textContent: const Value('initial text'),
              sentAtUtc: const Value('2024-01-03T00:00:00Z'),
            ),
          );

      await indexer.rebuildAll(context);
      expect(await countFtsRows(), 1);

      await (db.update(db.workingMessages)
            ..where((tbl) => tbl.id.equals(messageId)))
          .write(
            const WorkingMessagesCompanion(
              textContent: Value('updated modular term'),
            ),
          );

      await indexer.rebuildForMessages(context, [messageId]);

      final rows = await db.customSelect(
        "SELECT rowid FROM messages_fts WHERE messages_fts MATCH 'modular*'",
      ).get();
      expect(rows.map((row) => row.data['rowid']), contains(messageId));
    });
  });
}
