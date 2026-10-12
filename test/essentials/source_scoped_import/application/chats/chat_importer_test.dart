import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/core/util/date_converter.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/chats/chat_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/source_import_work_progress.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/ports/source_database_port.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/essentials/source_scoped_import/infrastructure/import_database_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory tempDir;
  late ImportDatabase importDatabase;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('chat_importer_test_');
    importDatabase = await ImportDatabase.open(
      databaseDirectory: tempDir.path,
      databaseName: 'macos_import_ss_test.db',
    );
  });

  tearDown(() async {
    await importDatabase.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('characterizes complete ordered chat rows, anomalies, duplicates, '
      'progress, and reruns before extraction', () async {
    final oldAppleSeconds = DateConverter.apple2CoreTS(
      DateConverter.dateString2Apple('2012-07-25'),
    );
    final modernAppleNanoseconds = DateConverter.dateString2Apple('2026-08-16');
    final sourceDatabase = _SyntheticChatSourceDatabase(
      rows: <Map<String, Object?>>[
        <String, Object?>{
          'source_rowid': 1,
          'guid': 'chat-1',
          'service_name': 'iMessage',
          'service': 'SMS',
          'group_id': 'group-1',
          'original_group_id': 'original-1',
          'last_read_message_timestamp': oldAppleSeconds,
        },
        <String, Object?>{
          'source_rowid': 2.4,
          'guid': '   ',
          'service_name': '',
          'service': '  RCS  ',
          'group_id': '',
          'original_group_id': '   ',
          'last_read_message_timestamp': modernAppleNanoseconds,
        },
        <String, Object?>{
          'source_rowid': 3,
          'guid': '会話 💬',
          'service_name': null,
          'service': '',
          'group_id': null,
          'original_group_id': '',
          'last_read_message_timestamp': 0,
        },
        <String, Object?>{
          'source_rowid': 4,
          'guid': 'chat-1',
          'service_name': 'Satellite',
          'service': 'fallback-not-used',
          'group_id': 'duplicate-guid-group',
          'original_group_id': null,
          'last_read_message_timestamp': null,
        },
        <String, Object?>{
          'source_rowid': 4,
          'guid': 'same-source-rowid-is-ignored',
          'service_name': 'SMS',
          'service': null,
          'group_id': 'ignored-group',
          'original_group_id': 'ignored-original',
          'last_read_message_timestamp': modernAppleNanoseconds,
        },
      ],
    );
    final firstProgress = <SourceImportWorkProgress>[];
    final importer = ChatImporter(
      chatDbPath: 'synthetic-chat.db',
      importLedger: importDatabase,
      sourceDatabaseOpener: _SyntheticChatSourceDatabaseOpener(sourceDatabase),
    );

    final firstResult = await importer.importChats(
      onProgress: firstProgress.add,
    );

    expect(firstResult.examinedChatCount, 5);
    expect(firstResult.insertedChatCount, 4);
    expect(sourceDatabase.closeCount, 1);
    expect(sourceDatabase.observedQueries, <String>[_chatSourceQuery]);
    expect(await _readChats(importDatabase), <Map<String, Object?>>[
      _expectedChat(
        sourceRowId: 1,
        guid: 'chat-1',
        service: 'iMessage',
        groupId: 'group-1',
        originalGroupId: 'original-1',
        lastReadMessageAtUtc: DateConverter.appleToIsoString(oldAppleSeconds),
      ),
      _expectedChat(
        sourceRowId: 2,
        guid: '   ',
        service: '  RCS  ',
        groupId: null,
        originalGroupId: '   ',
        lastReadMessageAtUtc: DateConverter.appleToIsoString(
          modernAppleNanoseconds,
        ),
      ),
      _expectedChat(
        sourceRowId: 3,
        guid: '会話 💬',
        service: null,
        groupId: null,
        originalGroupId: null,
        lastReadMessageAtUtc: null,
      ),
      _expectedChat(
        sourceRowId: 4,
        guid: 'chat-1',
        service: 'Satellite',
        groupId: 'duplicate-guid-group',
        originalGroupId: null,
        lastReadMessageAtUtc: null,
      ),
    ]);
    expect(
      firstProgress.map(_progressCharacterization).toList(),
      <Map<String, Object?>>[
        _expectedProgress(completed: 0, total: 5),
        _expectedProgress(completed: 5, total: 5, lastSourceRowId: 4),
      ],
    );

    sourceDatabase.observedQueries.clear();
    final secondProgress = <SourceImportWorkProgress>[];
    final secondResult = await importer.importChats(
      onProgress: secondProgress.add,
    );

    expect(secondResult.examinedChatCount, 5);
    expect(secondResult.insertedChatCount, 0);
    expect(sourceDatabase.closeCount, 2);
    expect(sourceDatabase.observedQueries, <String>[_chatSourceQuery]);
    expect(
      secondProgress.map(_progressCharacterization).toList(),
      <Map<String, Object?>>[
        _expectedProgress(completed: 0, total: 5),
        _expectedProgress(completed: 5, total: 5, lastSourceRowId: 4),
      ],
    );
    expect(await _readChats(importDatabase), hasLength(4));
    final batches = await importDatabase.database.query(
      'import_batches',
      orderBy: 'batch_id ASC',
    );
    expect(batches, hasLength(2));
    expect(batches.map((row) => row['source_id']).toList(), <Object?>[
      liveChatDbSourceId,
      liveChatDbSourceId,
    ]);
    expect(batches.every((row) => row['finished_at_utc'] == null), isTrue);
    expect(batches.every((row) => row['notes'] == null), isTrue);
  });

  test('characterizes empty source behavior', () async {
    final sourceDatabase = _SyntheticChatSourceDatabase(
      rows: const <Map<String, Object?>>[],
    );
    final progress = <SourceImportWorkProgress>[];

    final result = await ChatImporter(
      chatDbPath: 'synthetic-chat.db',
      importLedger: importDatabase,
      sourceDatabaseOpener: _SyntheticChatSourceDatabaseOpener(sourceDatabase),
    ).importChats(onProgress: progress.add);

    expect(result.examinedChatCount, 0);
    expect(result.insertedChatCount, 0);
    expect(sourceDatabase.closeCount, 1);
    expect(await importDatabase.database.query('chats'), isEmpty);
    expect(await importDatabase.database.query('import_batches'), hasLength(1));
    expect(
      progress.map(_progressCharacterization).toList(),
      <Map<String, Object?>>[_expectedProgress(completed: 0, total: 0)],
    );
  });

  test('wraps malformed source facts, rolls back chat rows, and retains batch '
      'and already-published progress', () async {
    final sourceDatabase = _SyntheticChatSourceDatabase(
      rows: <Map<String, Object?>>[
        <String, Object?>{
          'source_rowid': 21,
          'guid': 'valid-chat',
          'service_name': 'iMessage',
        },
        <String, Object?>{
          'source_rowid': 22,
          'guid': '',
          'service_name': 'SMS',
        },
      ],
    );
    final progress = <SourceImportWorkProgress>[];

    await expectLater(
      ChatImporter(
        chatDbPath: 'synthetic-chat.db',
        importLedger: importDatabase,
        sourceDatabaseOpener: _SyntheticChatSourceDatabaseOpener(
          sourceDatabase,
        ),
      ).importChats(onProgress: progress.add),
      throwsA(
        isA<SourceImportRecordException>()
            .having((error) => error.unit, 'unit', SourceImportWorkUnit.chats)
            .having((error) => error.sourceRowId, 'sourceRowId', 22)
            .having((error) => error.reason, 'reason', 'chat.guid is required'),
      ),
    );

    expect(sourceDatabase.closeCount, 1);
    expect(await importDatabase.database.query('chats'), isEmpty);
    expect(await importDatabase.database.query('import_batches'), hasLength(1));
    expect(
      progress.map(_progressCharacterization).toList(),
      <Map<String, Object?>>[_expectedProgress(completed: 0, total: 2)],
    );
  });

  test('retains null row context when source identity is malformed', () async {
    final sourceDatabase = _SyntheticChatSourceDatabase(
      rows: <Map<String, Object?>>[
        <String, Object?>{'source_rowid': null, 'guid': 'chat-without-rowid'},
      ],
    );

    await expectLater(
      ChatImporter(
        chatDbPath: 'synthetic-chat.db',
        importLedger: importDatabase,
        sourceDatabaseOpener: _SyntheticChatSourceDatabaseOpener(
          sourceDatabase,
        ),
      ).importChats(),
      throwsA(
        isA<SourceImportRecordException>()
            .having((error) => error.sourceRowId, 'sourceRowId', isNull)
            .having(
              (error) => error.reason,
              'reason',
              'chat.source_rowid is required',
            ),
      ),
    );

    expect(sourceDatabase.closeCount, 1);
    expect(await importDatabase.database.query('chats'), isEmpty);
  });

  test(
    'closes source and propagates query failure before batch creation',
    () async {
      final sourceDatabase = _SyntheticChatSourceDatabase(
        rows: const <Map<String, Object?>>[],
        queryError: StateError('synthetic chat query failed'),
      );

      await expectLater(
        ChatImporter(
          chatDbPath: 'synthetic-chat.db',
          importLedger: importDatabase,
          sourceDatabaseOpener: _SyntheticChatSourceDatabaseOpener(
            sourceDatabase,
          ),
        ).importChats(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'synthetic chat query failed',
          ),
        ),
      );

      expect(sourceDatabase.closeCount, 1);
      expect(await importDatabase.database.query('chats'), isEmpty);
      expect(await importDatabase.database.query('import_batches'), isEmpty);
    },
  );
}

const _chatSourceQuery =
    'SELECT ROWID AS source_rowid, * FROM chat ORDER BY ROWID ASC';

Map<String, Object?> _expectedChat({
  required int sourceRowId,
  required String guid,
  required String? service,
  required String? groupId,
  required String? originalGroupId,
  required String? lastReadMessageAtUtc,
}) {
  return <String, Object?>{
    'ss_id': SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: sourceRowId,
    ),
    'source_id': liveChatDbSourceId,
    'source_rowid': sourceRowId,
    'guid': guid,
    'service': service,
    'group_id': groupId,
    'original_group_id': originalGroupId,
    'last_read_message_at_utc': lastReadMessageAtUtc,
    'batch_id': 1,
  };
}

Map<String, Object?> _progressCharacterization(
  SourceImportWorkProgress progress,
) {
  return <String, Object?>{
    'unit': progress.unit,
    'completed': progress.completedWorkCount,
    'total': progress.totalWorkCount,
    'last_source_rowid': progress.lastCompletedSourceRowId,
  };
}

Map<String, Object?> _expectedProgress({
  required int completed,
  required int total,
  int? lastSourceRowId,
}) {
  return <String, Object?>{
    'unit': SourceImportWorkUnit.chats,
    'completed': completed,
    'total': total,
    'last_source_rowid': lastSourceRowId,
  };
}

Future<List<Map<String, Object?>>> _readChats(ImportDatabase importDatabase) {
  return importDatabase.database.query('chats', orderBy: 'source_rowid ASC');
}

final class _SyntheticChatSourceDatabaseOpener implements SourceDatabaseOpener {
  const _SyntheticChatSourceDatabaseOpener(this.database);

  final _SyntheticChatSourceDatabase database;

  @override
  Future<ReadOnlySourceDatabase> openReadOnly(String databasePath) async {
    return database;
  }
}

final class _SyntheticChatSourceDatabase implements ReadOnlySourceDatabase {
  _SyntheticChatSourceDatabase({required this.rows, this.queryError});

  final List<Map<String, Object?>> rows;
  final Object? queryError;
  final List<String> observedQueries = <String>[];
  int closeCount = 0;

  @override
  Future<void> close() async {
    closeCount += 1;
  }

  @override
  Future<Set<String>> findExistingMessageGuids(Set<String> targetGuids) {
    throw UnsupportedError('Chat importer does not read message GUIDs');
  }

  @override
  Future<SourceMessageImportWindow> messageImportWindowAfter(int sourceRowId) {
    throw UnsupportedError('Chat importer does not use message paging');
  }

  @override
  Future<List<Map<String, Object?>>> query(String table, {String? orderBy}) {
    throw UnsupportedError('Chat importer uses one bounded raw query');
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    observedQueries.add(sql);
    expect(sql, _chatSourceQuery);
    expect(arguments, isNull);
    if (queryError != null) {
      throw queryError!;
    }
    return rows;
  }

  @override
  Future<List<Map<String, Object?>>> readMessageImportPage({
    required int afterSourceRowId,
    required int throughSourceRowId,
    required int limit,
  }) {
    throw UnsupportedError('Chat importer does not read message pages');
  }
}
