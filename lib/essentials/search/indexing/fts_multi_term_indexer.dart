import 'package:drift/drift.dart';
import 'search_indexer.dart';

class FtsMultiTermIndexer extends SearchIndexer {
  FtsMultiTermIndexer({this.batchSize = 10000});

  final int batchSize;

  @override
  String get id => 'fts_multi_term';

  @override
  String get description => 'Physical FTS index for multi-term ranked search';

  @override
  bool get supportsPartialRebuild => true;

  @override
  Future<void> rebuildAll(SearchIndexContext context) async {
    await context.db.transaction(() async {
      await context.db.customStatement('DELETE FROM messages_fts');

      var offset = 0;
      while (true) {
        final rows = await context.db
            .customSelect(
              '''
          SELECT id, guid, chat_id, COALESCE(text,'') AS text_value
          FROM messages
          ORDER BY id
          LIMIT ? OFFSET ?
          ''',
              variables: [
                Variable.withInt(batchSize),
                Variable.withInt(offset),
              ],
            )
            .get();

        if (rows.isEmpty) {
          break;
        }

        final inserts = rows
            .map(
              (row) => [
                row.data['id'],
                row.data['guid'],
                row.data['chat_id'],
                row.data['text_value'],
              ],
            )
            .toList(growable: false);

        await context.db.batch((batch) {
          for (final entry in inserts) {
            batch.customStatement(
              'INSERT INTO messages_fts(rowid, guid, chat_id, text) VALUES (?, ?, ?, ?)',
              entry,
            );
          }
        });

        offset += rows.length;
      }
    });
  }

  @override
  Future<void> rebuildForMessages(
    SearchIndexContext context,
    Iterable<int> messageIds,
  ) async {
    final ids = messageIds.toSet().toList();
    if (ids.isEmpty) {
      return;
    }

    await context.db.transaction(() async {
      final placeholders = List.filled(ids.length, '?').join(',');
      await context.db.customStatement(
        'DELETE FROM messages_fts WHERE rowid IN ($placeholders)',
        ids,
      );

      final rows = await context.db
          .customSelect(
            '''
        SELECT id, guid, chat_id, COALESCE(text,'') AS text_value
        FROM messages
        WHERE id IN ($placeholders)
        ''',
            variables: [for (final id in ids) Variable.withInt(id)],
          )
          .get();

      await context.db.batch((batch) {
        for (final row in rows) {
          batch.customStatement(
            'INSERT INTO messages_fts(rowid, guid, chat_id, text) VALUES (?, ?, ?, ?)',
            [
              row.data['id'],
              row.data['guid'],
              row.data['chat_id'],
              row.data['text_value'],
            ],
          );
        }
      });
    });
  }

  @override
  Future<void> validate(SearchIndexContext context) async {
    final totalMessages = await context.db
        .customSelect(
          'SELECT COUNT(*) as c FROM messages WHERE text IS NOT NULL',
        )
        .getSingle();
    final totalFts = await context.db
        .customSelect('SELECT COUNT(*) as c FROM messages_fts')
        .getSingle();

    final expected = totalMessages.data['c'] as int? ?? 0;
    final actual = totalFts.data['c'] as int? ?? 0;

    if (actual < expected) {
      throw StateError(
        'FTS index out of sync: expected >= $expected rows, found $actual',
      );
    }

    // Smoke-test query
    await context.db
        .customSelect(
          "SELECT rowid FROM messages_fts WHERE messages_fts MATCH 'test*' LIMIT 1",
        )
        .get();
  }
}
