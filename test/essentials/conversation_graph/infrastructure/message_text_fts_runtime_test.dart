import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';

void main() {
  late ConversationGraphDatabase database;

  setUp(() async {
    database = ConversationGraphDatabase(NativeDatabase.memory());
    await database.customSelect('SELECT 1').get();
    await database.executeSql('''
      CREATE VIRTUAL TABLE runtime_message_text_fts USING fts5(
        text,
        tokenize='unicode61 remove_diacritics 2',
        prefix='2 3 4'
      )
    ''');
  });

  tearDown(() async {
    await database.close();
  });

  test('MessageLens Drift runtime provides FTS5', () async {
    final rows = await database.selectRows('''
      SELECT name
      FROM sqlite_master
      WHERE type = 'table' AND name = 'runtime_message_text_fts'
    ''');

    expect(rows, hasLength(1));
  });

  test(
    'unicode61 tokenizes representative message text consistently',
    () async {
      const fixtures = <int, String>{
        1: 'post',
        2: 'POST',
        3: 'café',
        4: 'cafe',
        5: 'post.',
        6: 'post,',
        7: 'post?',
        8: '(post)',
        9: 'post\tsecond\nline',
        10: "don't",
        11: 'post-master',
        12: 'under_score',
        13: 'crosspost',
        14: '👩‍💻post',
        15: 'postmaster',
        16: 'p',
        17: 'Привет мир',
      };
      for (final entry in fixtures.entries) {
        await database.executeSql(
          'INSERT INTO runtime_message_text_fts(rowid, text) VALUES (?, ?)',
          <Object?>[entry.key, entry.value],
        );
      }

      expect(await _matchingRowIds(database, '"post"'), <int>[
        1,
        2,
        5,
        6,
        7,
        8,
        9,
        11,
        14,
      ]);
      expect(await _matchingRowIds(database, '"post"*'), <int>[
        1,
        2,
        5,
        6,
        7,
        8,
        9,
        11,
        14,
        15,
      ]);
      expect(await _matchingRowIds(database, '"crosspost"'), <int>[13]);
      expect(await _matchingRowIds(database, '"p"'), <int>[16]);
      expect(await _matchingRowIds(database, '"cafe"'), <int>[3, 4]);
      expect(await _matchingRowIds(database, '"second"'), <int>[9]);
      expect(await _matchingRowIds(database, '"line"'), <int>[9]);
      expect(await _matchingRowIds(database, '"don"'), <int>[10]);
      expect(await _matchingRowIds(database, '"dont"'), isEmpty);
      expect(await _matchingRowIds(database, '"master"'), <int>[11]);
      expect(await _matchingRowIds(database, '"under"'), <int>[12]);
      expect(await _matchingRowIds(database, '"score"'), <int>[12]);
      expect(await _matchingRowIds(database, '"ПРИВЕТ"'), <int>[17]);
    },
  );
}

Future<List<int>> _matchingRowIds(
  ConversationGraphDatabase database,
  String expression,
) async {
  final rows = await database.selectRows(
    '''
    SELECT rowid
    FROM runtime_message_text_fts
    WHERE runtime_message_text_fts MATCH ?
    ORDER BY rowid
    ''',
    <Object?>[expression],
  );
  return <int>[for (final row in rows) row['rowid']! as int];
}
