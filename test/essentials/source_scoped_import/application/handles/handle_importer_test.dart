import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/shared/handle_identifier_utils.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/handles/handle_importer.dart';
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
    tempDir = await Directory.systemTemp.createTemp('handle_importer_test_');
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

  test('characterizes complete ordered handle rows, anomalies, progress, and '
      'reruns before extraction', () async {
    final sourceDatabase = _SyntheticHandleSourceDatabase(
      handleRows: <Map<String, Object?>>[
        <String, Object?>{
          'source_rowid': 1,
          'id': ' +1 (604) 555-0100 ',
          'service': 'iMessage',
        },
        <String, Object?>{
          'source_rowid': 2,
          'id': 'User@Example.COM',
          'service': null,
        },
        <String, Object?>{'source_rowid': 3, 'id': '💬 handle', 'service': ''},
        <String, Object?>{'source_rowid': 4, 'id': '   ', 'service': '   '},
        <String, Object?>{
          'source_rowid': 5,
          'id': 'typed failure',
          'service': 'SMS',
        },
        <String, Object?>{
          'source_rowid': 6,
          'id': 'User@Example.COM',
          'service': 'iMessage',
        },
        <String, Object?>{
          'source_rowid': 7,
          'id': 'mailto:Another@Example.COM',
          'service': 'RCS',
        },
      ],
      chatColumns: const <String>{'account_login'},
      messageColumns: const <String>{'destination_caller_id', 'is_from_me'},
      accountLoginRows: <Map<String, Object?>>[
        <String, Object?>{'account_login': 'P:+16045550100'},
        <String, Object?>{'account_login': 'P:+16045550100'},
      ],
      destinationCallerRows: <Map<String, Object?>>[
        <String, Object?>{'destination_caller_id': 'E:user@example.com'},
        <String, Object?>{'destination_caller_id': 'E:user@example.com'},
      ],
    );
    final firstProgress = <SourceImportWorkProgress>[];
    final importer = HandleImporter(
      chatDbPath: 'synthetic-chat.db',
      importLedger: importDatabase,
      sourceDatabaseOpener: _SyntheticHandleSourceDatabaseOpener(
        sourceDatabase,
      ),
      handleIdentifierInterpreter: _characterizationInterpreter,
    );

    final firstResult = await importer.importNewHandles(
      onProgress: firstProgress.add,
    );

    expect(firstResult.startedAfterSourceRowId, 0);
    expect(firstResult.examinedHandleCount, 7);
    expect(firstResult.insertedHandleCount, 7);
    expect(firstResult.lastImportedSourceRowId, 7);
    expect(firstResult.normalizedHandleCount, 4);
    expect(firstResult.preservedUnnormalizedHandleCount, 3);
    expect(sourceDatabase.closeCount, 1);
    expect(sourceDatabase.observedQueries, <String>[
      _handleSourceQuery,
      'PRAGMA table_info(chat)',
      _accountLoginQuery,
      'PRAGMA table_info(message)',
      _destinationCallerQuery,
    ]);

    final rows = await importDatabase.database.rawQuery('''
        SELECT
          ss_id,
          source_id,
          source_rowid,
          id,
          service,
          is_me,
          batch_id
        FROM handles
        ORDER BY source_rowid ASC
      ''');
    expect(rows, <Map<String, Object?>>[
      _expectedHandle(
        sourceRowId: 1,
        identifier: ' +1 (604) 555-0100 ',
        service: 'iMessage',
        isMe: true,
      ),
      _expectedHandle(
        sourceRowId: 2,
        identifier: 'User@Example.COM',
        service: null,
        isMe: true,
      ),
      _expectedHandle(sourceRowId: 3, identifier: '💬 handle', service: null),
      _expectedHandle(sourceRowId: 4, identifier: '   ', service: '   '),
      _expectedHandle(
        sourceRowId: 5,
        identifier: 'typed failure',
        service: 'SMS',
      ),
      _expectedHandle(
        sourceRowId: 6,
        identifier: 'User@Example.COM',
        service: 'iMessage',
        isMe: true,
      ),
      _expectedHandle(
        sourceRowId: 7,
        identifier: 'mailto:Another@Example.COM',
        service: 'RCS',
      ),
    ]);
    expect(
      firstProgress.map(_progressCharacterization).toList(),
      <Map<String, Object?>>[
        _expectedProgress(completed: 0, total: 7),
        _expectedProgress(
          completed: 7,
          total: 7,
          lastSourceRowId: 7,
          preservedUnnormalizedCount: 3,
        ),
      ],
    );

    sourceDatabase.observedQueries.clear();
    final secondProgress = <SourceImportWorkProgress>[];
    final secondResult = await importer.importNewHandles(
      onProgress: secondProgress.add,
    );

    expect(secondResult.startedAfterSourceRowId, 7);
    expect(secondResult.examinedHandleCount, 7);
    expect(secondResult.insertedHandleCount, 0);
    expect(secondResult.lastImportedSourceRowId, isNull);
    expect(secondResult.normalizedHandleCount, 4);
    expect(secondResult.preservedUnnormalizedHandleCount, 3);
    expect(sourceDatabase.closeCount, 2);
    expect(sourceDatabase.observedQueries, <String>[
      _handleSourceQuery,
      'PRAGMA table_info(chat)',
      _accountLoginQuery,
    ]);
    expect(
      secondProgress.map(_progressCharacterization).toList(),
      <Map<String, Object?>>[
        _expectedProgress(completed: 0, total: 7),
        _expectedProgress(
          completed: 7,
          total: 7,
          lastSourceRowId: 7,
          preservedUnnormalizedCount: 3,
        ),
      ],
    );
    expect(
      await importDatabase.database.query(
        'handles',
        orderBy: 'source_rowid ASC',
      ),
      hasLength(7),
    );
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

  test('characterizes no-account, multiple-account, repeated-account, and '
      'message-fallback reconciliation', () async {
    final sourceDatabase = _SyntheticHandleSourceDatabase(
      handleRows: <Map<String, Object?>>[
        <String, Object?>{
          'source_rowid': 11,
          'id': 'first@example.com',
          'service': 'iMessage',
        },
        <String, Object?>{
          'source_rowid': 12,
          'id': '+1 (604) 555-0112',
          'service': 'SMS',
        },
        <String, Object?>{
          'source_rowid': 13,
          'id': 'not-local@example.com',
          'service': null,
        },
      ],
      chatColumns: const <String>{'account_login'},
      messageColumns: const <String>{'destination_caller_id', 'is_from_me'},
    );
    final importer = HandleImporter(
      chatDbPath: 'synthetic-chat.db',
      importLedger: importDatabase,
      sourceDatabaseOpener: _SyntheticHandleSourceDatabaseOpener(
        sourceDatabase,
      ),
    );

    final importResult = await importer.importNewHandles();
    expect(importResult.insertedHandleCount, 3);
    expect(await _readHandleIdentity(importDatabase), <Map<String, Object?>>[
      <String, Object?>{
        'source_rowid': 11,
        'id': 'first@example.com',
        'is_me': 0,
      },
      <String, Object?>{
        'source_rowid': 12,
        'id': '+1 (604) 555-0112',
        'is_me': 0,
      },
      <String, Object?>{
        'source_rowid': 13,
        'id': 'not-local@example.com',
        'is_me': 0,
      },
    ]);

    sourceDatabase.accountLoginRows.addAll(<Map<String, Object?>>[
      <String, Object?>{'account_login': 'E:first@example.com'},
      <String, Object?>{'account_login': 'E:first@example.com'},
    ]);
    sourceDatabase.destinationCallerRows.addAll(<Map<String, Object?>>[
      <String, Object?>{'destination_caller_id': 'P:+16045550112'},
      <String, Object?>{'destination_caller_id': 'P:+16045550112'},
    ]);

    final reconciliation = await importer.reconcileLocalAccountIdentity();
    expect(reconciliation.examinedHandleCount, 3);
    expect(reconciliation.localAccountHandleCount, 2);
    expect(reconciliation.updatedHandleCount, 2);
    expect(await _readHandleIdentity(importDatabase), <Map<String, Object?>>[
      <String, Object?>{
        'source_rowid': 11,
        'id': 'first@example.com',
        'is_me': 1,
      },
      <String, Object?>{
        'source_rowid': 12,
        'id': '+1 (604) 555-0112',
        'is_me': 1,
      },
      <String, Object?>{
        'source_rowid': 13,
        'id': 'not-local@example.com',
        'is_me': 0,
      },
    ]);

    sourceDatabase.accountLoginRows.clear();
    sourceDatabase.destinationCallerRows.clear();
    final repeatedReconciliation = await importer
        .reconcileLocalAccountIdentity();
    expect(repeatedReconciliation.examinedHandleCount, 3);
    expect(repeatedReconciliation.localAccountHandleCount, 2);
    expect(repeatedReconciliation.updatedHandleCount, 0);
    expect(sourceDatabase.closeCount, 3);
  });

  test(
    'fails closed on structurally invalid source identity and rolls back rows',
    () async {
      final sourceDatabase = _SyntheticHandleSourceDatabase(
        handleRows: <Map<String, Object?>>[
          <String, Object?>{
            'source_rowid': 21,
            'id': 'valid@example.com',
            'service': 'iMessage',
          },
          <String, Object?>{'source_rowid': 22, 'id': '', 'service': 'SMS'},
        ],
      );
      final progress = <SourceImportWorkProgress>[];
      final importer = HandleImporter(
        chatDbPath: 'synthetic-chat.db',
        importLedger: importDatabase,
        sourceDatabaseOpener: _SyntheticHandleSourceDatabaseOpener(
          sourceDatabase,
        ),
      );

      await expectLater(
        importer.importNewHandles(onProgress: progress.add),
        throwsA(
          isA<SourceImportRecordException>()
              .having(
                (error) => error.unit,
                'unit',
                SourceImportWorkUnit.handles,
              )
              .having((error) => error.sourceRowId, 'sourceRowId', 22)
              .having(
                (error) => error.reason,
                'reason',
                'handle.id is required',
              ),
        ),
      );

      expect(await importDatabase.database.query('handles'), isEmpty);
      expect(
        await importDatabase.database.query('import_batches'),
        hasLength(1),
      );
      expect(sourceDatabase.closeCount, 1);
      expect(
        progress.map(_progressCharacterization).toList(),
        <Map<String, Object?>>[_expectedProgress(completed: 0, total: 2)],
      );
    },
  );

  test(
    'closes the source and propagates systemic source-query errors',
    () async {
      final sourceDatabase = _SyntheticHandleSourceDatabase(
        handleRows: const <Map<String, Object?>>[],
        handleQueryError: StateError('synthetic handle query failed'),
      );
      final importer = HandleImporter(
        chatDbPath: 'synthetic-chat.db',
        importLedger: importDatabase,
        sourceDatabaseOpener: _SyntheticHandleSourceDatabaseOpener(
          sourceDatabase,
        ),
      );

      await expectLater(
        importer.importNewHandles(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'synthetic handle query failed',
          ),
        ),
      );

      expect(sourceDatabase.closeCount, 1);
      expect(await importDatabase.database.query('handles'), isEmpty);
      expect(
        await importDatabase.database.query('import_batches'),
        hasLength(1),
      );
    },
  );
}

const _handleSourceQuery =
    'SELECT ROWID AS source_rowid, id, service '
    'FROM handle ORDER BY ROWID ASC';
const _accountLoginQuery =
    'SELECT DISTINCT account_login FROM chat '
    'WHERE account_login IS NOT NULL AND trim(account_login) != ?';
const _destinationCallerQuery =
    'SELECT DISTINCT destination_caller_id FROM message '
    'WHERE is_from_me = 0 '
    'AND destination_caller_id IS NOT NULL '
    'AND trim(destination_caller_id) != ?';

HandleIdentifierInterpretation _characterizationInterpreter(
  String rawIdentifier,
) {
  if (rawIdentifier == 'typed failure') {
    throw const HandleIdentifierNormalizationException(
      'synthetic typed normalization failure',
    );
  }
  return interpretHandleIdentifier(rawIdentifier);
}

Map<String, Object?> _expectedHandle({
  required int sourceRowId,
  required String identifier,
  required String? service,
  bool isMe = false,
}) {
  return <String, Object?>{
    'ss_id': SourceScopedRowKey.pack(
      sourceId: liveChatDbSourceId,
      sourceRowId: sourceRowId,
    ),
    'source_id': liveChatDbSourceId,
    'source_rowid': sourceRowId,
    'id': identifier,
    'service': service,
    'is_me': isMe ? 1 : 0,
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
    'preserved_unnormalized':
        progress.anomalyCounts.preservedUnnormalizedHandleCount,
  };
}

Map<String, Object?> _expectedProgress({
  required int completed,
  required int total,
  int? lastSourceRowId,
  int preservedUnnormalizedCount = 0,
}) {
  return <String, Object?>{
    'unit': SourceImportWorkUnit.handles,
    'completed': completed,
    'total': total,
    'last_source_rowid': lastSourceRowId,
    'preserved_unnormalized': preservedUnnormalizedCount,
  };
}

Future<List<Map<String, Object?>>> _readHandleIdentity(
  ImportDatabase importDatabase,
) {
  return importDatabase.database.rawQuery('''
    SELECT source_rowid, id, is_me
    FROM handles
    ORDER BY source_rowid ASC
  ''');
}

final class _SyntheticHandleSourceDatabaseOpener
    implements SourceDatabaseOpener {
  const _SyntheticHandleSourceDatabaseOpener(this.database);

  final _SyntheticHandleSourceDatabase database;

  @override
  Future<ReadOnlySourceDatabase> openReadOnly(String databasePath) async {
    return database;
  }
}

final class _SyntheticHandleSourceDatabase implements ReadOnlySourceDatabase {
  _SyntheticHandleSourceDatabase({
    required this.handleRows,
    this.chatColumns = const <String>{},
    this.messageColumns = const <String>{},
    List<Map<String, Object?>>? accountLoginRows,
    List<Map<String, Object?>>? destinationCallerRows,
    this.handleQueryError,
  }) : accountLoginRows = accountLoginRows ?? <Map<String, Object?>>[],
       destinationCallerRows =
           destinationCallerRows ?? <Map<String, Object?>>[];

  final List<Map<String, Object?>> handleRows;
  final Set<String> chatColumns;
  final Set<String> messageColumns;
  final List<Map<String, Object?>> accountLoginRows;
  final List<Map<String, Object?>> destinationCallerRows;
  final Object? handleQueryError;
  final List<String> observedQueries = <String>[];
  int closeCount = 0;

  @override
  Future<void> close() async {
    closeCount += 1;
  }

  @override
  Future<Set<String>> findExistingMessageGuids(Set<String> targetGuids) {
    throw UnsupportedError('Handle importer does not read message GUIDs');
  }

  @override
  Future<SourceMessageImportWindow> messageImportWindowAfter(int sourceRowId) {
    throw UnsupportedError('Handle importer does not use message paging');
  }

  @override
  Future<List<Map<String, Object?>>> query(String table, {String? orderBy}) {
    throw UnsupportedError('Handle importer uses bounded raw queries');
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    observedQueries.add(sql);
    if (sql == _handleSourceQuery) {
      if (handleQueryError != null) {
        throw handleQueryError!;
      }
      return handleRows;
    }
    if (sql == 'PRAGMA table_info(chat)') {
      return <Map<String, Object?>>[
        for (final column in chatColumns) <String, Object?>{'name': column},
      ];
    }
    if (sql == _accountLoginQuery) {
      expect(arguments, const <Object?>['']);
      return accountLoginRows;
    }
    if (sql == 'PRAGMA table_info(message)') {
      return <Map<String, Object?>>[
        for (final column in messageColumns) <String, Object?>{'name': column},
      ];
    }
    if (sql == _destinationCallerQuery) {
      expect(arguments, const <Object?>['']);
      return destinationCallerRows;
    }
    throw StateError('Unexpected synthetic query: $sql');
  }

  @override
  Future<List<Map<String, Object?>>> readMessageImportPage({
    required int afterSourceRowId,
    required int throughSourceRowId,
    required int limit,
  }) {
    throw UnsupportedError('Handle importer does not use message paging');
  }
}
