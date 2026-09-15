import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/source_database/sqflite_source_database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory tempDirectory;
  late String databasePath;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'source_message_page_test_',
    );
    databasePath = '${tempDirectory.path}/chat.db';
    final database = await openDatabase(databasePath);
    await database.execute('''
      CREATE TABLE message (
        ROWID INTEGER PRIMARY KEY,
        attributedBody BLOB,
        date INTEGER,
        date_read INTEGER,
        date_delivered INTEGER,
        guid TEXT,
        handle_id INTEGER,
        is_from_me INTEGER,
        text TEXT,
        associated_message_guid TEXT,
        item_type INTEGER,
        associated_message_type INTEGER,
        thread_originator_guid TEXT,
        error INTEGER,
        is_system_message INTEGER,
        message_summary_info BLOB,
        payload_data BLOB
      )
    ''');
    await database.execute('''
      CREATE TABLE chat_message_join (
        chat_id INTEGER,
        message_id INTEGER
      )
    ''');
    for (final rowId in <int>[2, 10, 50]) {
      await database.insert('message', <String, Object?>{
        'ROWID': rowId,
        'attributedBody': Uint8List.fromList(<int>[rowId]),
        'guid': 'message-$rowId',
        'handle_id': 0,
        'is_from_me': 0,
        'message_summary_info': Uint8List(1024),
        'payload_data': Uint8List(2048),
      });
    }
    await database.insert('chat_message_join', <String, Object?>{
      'chat_id': 1,
      'message_id': 2,
    });
    await database.close();
  });

  tearDown(() async {
    await tempDirectory.delete(recursive: true);
  });

  test('freezes a count and high-water over sparse source rows', () async {
    final database = await const SqfliteSourceDatabaseOpener().openReadOnly(
      databasePath,
    );
    try {
      final window = await database.messageImportWindowAfter(2);

      expect(window.totalRowCount, 2);
      expect(window.highWaterSourceRowId, 50);
    } finally {
      await database.close();
    }
  });

  test('source rawQuery accepts only read queries', () async {
    final database = await const SqfliteSourceDatabaseOpener().openReadOnly(
      databasePath,
    );
    addTearDown(database.close);

    expect(
      await database.rawQuery('SELECT ROWID FROM message ORDER BY ROWID'),
      <Map<String, Object?>>[
        <String, Object?>{'ROWID': 2},
        <String, Object?>{'ROWID': 10},
        <String, Object?>{'ROWID': 50},
      ],
    );
    expect(await database.rawQuery('PRAGMA table_info(message)'), isNotEmpty);
    expect(
      await database.rawQuery(
        'WITH rows AS (SELECT ROWID FROM message) '
        'SELECT ROWID FROM rows ORDER BY ROWID',
      ),
      <Map<String, Object?>>[
        <String, Object?>{'ROWID': 2},
        <String, Object?>{'ROWID': 10},
        <String, Object?>{'ROWID': 50},
      ],
    );

    await expectLater(
      database.rawQuery('DELETE FROM message'),
      throwsA(isA<StateError>()),
    );
  });

  test(
    'returns a bounded exact projection with payload presence only',
    () async {
      final database = await const SqfliteSourceDatabaseOpener().openReadOnly(
        databasePath,
      );
      try {
        final rows = await database.readMessageImportPage(
          afterSourceRowId: 0,
          throughSourceRowId: 50,
          limit: 2,
        );

        expect(rows.map((row) => row['source_rowid']), <Object?>[2, 10]);
        expect(rows, hasLength(2));
        expect(rows.first['has_chat_relationship'], 1);
        expect(rows.first['has_message_summary_info'], 1);
        expect(rows.first['has_payload_data_source'], 1);
        expect(rows.first, isNot(contains('message_summary_info')));
        expect(rows.first, isNot(contains('payload_data')));
      } finally {
        await database.close();
      }
    },
  );

  test('projects absent optional columns safely for older archives', () async {
    final legacyPath = '${tempDirectory.path}/legacy.db';
    final legacyDatabase = await openDatabase(legacyPath);
    await legacyDatabase.execute('''
      CREATE TABLE message (
        ROWID INTEGER PRIMARY KEY,
        guid TEXT,
        is_from_me INTEGER
      )
    ''');
    await legacyDatabase.execute('''
      CREATE TABLE chat_message_join (
        chat_id INTEGER,
        message_id INTEGER
      )
    ''');
    await legacyDatabase.insert('message', <String, Object?>{
      'ROWID': 1,
      'guid': 'legacy-message',
      'is_from_me': 0,
    });
    await legacyDatabase.close();
    final database = await const SqfliteSourceDatabaseOpener().openReadOnly(
      legacyPath,
    );
    try {
      final rows = await database.readMessageImportPage(
        afterSourceRowId: 0,
        throughSourceRowId: 1,
        limit: 1,
      );

      expect(rows.single['guid'], 'legacy-message');
      expect(rows.single['attributedBody'], isNull);
      expect(rows.single['thread_originator_guid'], isNull);
      expect(rows.single['has_message_summary_info'], 0);
      expect(rows.single['has_payload_data_source'], 0);
    } finally {
      await database.close();
    }
  });

  test(
    'finds association targets without returning other source data',
    () async {
      final database = await const SqfliteSourceDatabaseOpener().openReadOnly(
        databasePath,
      );
      try {
        final matches = await database.findExistingMessageGuids(<String>{
          'message-10',
          'missing',
          'message-50',
        });

        expect(matches, <String>{'message-10', 'message-50'});
      } finally {
        await database.close();
      }
    },
  );
}
