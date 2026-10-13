import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/chat_handle_joins/chat_handle_join_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/source_import_work_progress.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/known_sources.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/ports/import_ledger_port.dart';
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
    tempDir = await Directory.systemTemp.createTemp(
      'chat_handle_join_importer_characterization_',
    );
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

  test(
    'characterizes exact query, six ledger fields, endpoint identity, '
    'coercion, omissions, duplicates, batches, progress, and reruns',
    () async {
      final sourceId = await importDatabase.getOrCreateSource(
        sourceKey: 'characterization-archive',
        sourceKind: 'historical-chat-db',
      );
      final sourceDatabase = _SyntheticRelationshipSourceDatabase(
        rows: <Map<String, Object?>>[
          _row(sourceRowId: 1, chatRowId: 10, handleRowId: 20),
          _row(sourceRowId: 2.4, chatRowId: 11.6, handleRowId: 21.4),
          _row(sourceRowId: 3, chatRowId: 10, handleRowId: 20),
          _row(sourceRowId: 4, chatRowId: 10, handleRowId: 22),
          _row(
            sourceRowId: 5,
            chatRowId: 13,
            handleRowId: 23,
            existingChatRowId: null,
          ),
          _row(
            sourceRowId: 6,
            chatRowId: 14,
            handleRowId: 24,
            existingHandleRowId: null,
          ),
          _row(sourceRowId: 7, chatRowId: 'malformed-chat', handleRowId: 25),
          _row(sourceRowId: 8, chatRowId: 15, handleRowId: 'malformed-handle'),
        ],
      );
      final opener = _SyntheticRelationshipSourceDatabaseOpener(sourceDatabase);
      final importer = ChatHandleJoinImporter(
        chatDbPath: 'synthetic-chat.db',
        importLedger: importDatabase,
        sourceDatabaseOpener: opener,
        sourceId: sourceId,
      );
      final firstProgress = <SourceImportWorkProgress>[];
      final earliestStart = DateTime.now().toUtc();

      final firstResult = await importer.importJoins(
        onProgress: firstProgress.add,
      );
      final latestStart = DateTime.now().toUtc();

      expect(firstResult.examinedJoinCount, 8);
      expect(firstResult.insertedJoinCount, 3);
      expect(firstResult.omittedJoinCount, 4);
      expect(opener.openedPaths, <String>['synthetic-chat.db']);
      expect(sourceDatabase.closeCount, 1);
      expect(sourceDatabase.observedQueries, <_ObservedQuery>[
        const _ObservedQuery(_fullRelationshipQuery, <Object?>[]),
      ]);

      final firstBatch = (await _readBatches(importDatabase)).single;
      expect(firstBatch['source_id'], sourceId);
      expect(firstBatch['finished_at_utc'], isNull);
      expect(firstBatch['notes'], isNull);
      final startedAt = DateTime.parse(firstBatch['started_at_utc']! as String);
      expect(startedAt.isBefore(earliestStart), isFalse);
      expect(startedAt.isAfter(latestStart), isFalse);
      final firstBatchId = firstBatch['batch_id']! as int;

      final storedRows = await _readRelationships(importDatabase);
      expect(storedRows, <Map<String, Object?>>[
        _expectedRelationship(
          sourceId: sourceId,
          sourceChatRowId: 10,
          sourceHandleRowId: 20,
          batchId: firstBatchId,
        ),
        _expectedRelationship(
          sourceId: sourceId,
          sourceChatRowId: 12,
          sourceHandleRowId: 21,
          batchId: firstBatchId,
        ),
        _expectedRelationship(
          sourceId: sourceId,
          sourceChatRowId: 10,
          sourceHandleRowId: 22,
          batchId: firstBatchId,
        ),
      ]);
      expect(storedRows.first.keys.toList(), <String>[
        'source_id',
        'source_chat_rowid',
        'source_handle_rowid',
        'chat_ss_id',
        'handle_ss_id',
        'batch_id',
      ]);
      expect(
        firstProgress.map(_characterizeProgress).toList(),
        <Map<String, Object?>>[
          _expectedProgress(completed: 0, total: 8, omitted: 0),
          _expectedProgress(
            completed: 8,
            total: 8,
            lastSourceRowId: 8,
            omitted: 4,
          ),
        ],
      );

      sourceDatabase.observedQueries.clear();
      final secondProgress = <SourceImportWorkProgress>[];
      final secondResult = await importer.importJoins(
        onProgress: secondProgress.add,
      );

      expect(secondResult.examinedJoinCount, 8);
      expect(secondResult.insertedJoinCount, 0);
      expect(secondResult.omittedJoinCount, 4);
      expect(sourceDatabase.closeCount, 2);
      expect(sourceDatabase.observedQueries, <_ObservedQuery>[
        const _ObservedQuery(_fullRelationshipQuery, <Object?>[]),
      ]);
      expect(await _readRelationships(importDatabase), storedRows);
      expect(await _readBatches(importDatabase), hasLength(2));
      expect(
        secondProgress.map(_characterizeProgress).toList(),
        <Map<String, Object?>>[
          _expectedProgress(completed: 0, total: 8, omitted: 0),
          _expectedProgress(
            completed: 8,
            total: 8,
            lastSourceRowId: 8,
            omitted: 4,
          ),
        ],
      );
    },
  );

  test('characterizes live source packed endpoint identity', () async {
    final sourceDatabase = _SyntheticRelationshipSourceDatabase(
      rows: <Map<String, Object?>>[
        _row(sourceRowId: 1, chatRowId: 31, handleRowId: 41),
      ],
    );

    final result = await ChatHandleJoinImporter(
      chatDbPath: 'live-chat.db',
      importLedger: importDatabase,
      sourceDatabaseOpener: _SyntheticRelationshipSourceDatabaseOpener(
        sourceDatabase,
      ),
    ).importJoins();

    expect(result.insertedJoinCount, 1);
    final batchId =
        (await _readBatches(importDatabase)).single['batch_id']! as int;
    expect(await _readRelationships(importDatabase), <Map<String, Object?>>[
      _expectedRelationship(
        sourceId: liveChatDbSourceId,
        sourceChatRowId: 31,
        sourceHandleRowId: 41,
        batchId: batchId,
      ),
    ]);
    expect(sourceDatabase.closeCount, 1);
  });

  test('characterizes empty source batch, progress, and lifecycle', () async {
    final sourceDatabase = _SyntheticRelationshipSourceDatabase(
      rows: const <Map<String, Object?>>[],
    );
    final progress = <SourceImportWorkProgress>[];

    final result = await ChatHandleJoinImporter(
      chatDbPath: 'empty-chat.db',
      importLedger: importDatabase,
      sourceDatabaseOpener: _SyntheticRelationshipSourceDatabaseOpener(
        sourceDatabase,
      ),
    ).importJoins(onProgress: progress.add);

    expect(result.examinedJoinCount, 0);
    expect(result.insertedJoinCount, 0);
    expect(result.omittedJoinCount, 0);
    expect(sourceDatabase.closeCount, 1);
    expect(await _readRelationships(importDatabase), isEmpty);
    expect(await _readBatches(importDatabase), hasLength(1));
    expect(progress.map(_characterizeProgress).toList(), <Map<String, Object?>>[
      _expectedProgress(completed: 0, total: 0, omitted: 0),
    ]);
  });

  test(
    'malformed raw join identity rolls back an earlier row and retains batch',
    () async {
      final sourceDatabase = _SyntheticRelationshipSourceDatabase(
        rows: <Map<String, Object?>>[
          _row(sourceRowId: 51, chatRowId: 61, handleRowId: 71),
          _row(
            sourceRowId: 'malformed-source-rowid',
            chatRowId: 62,
            handleRowId: 72,
          ),
        ],
      );
      final progress = <SourceImportWorkProgress>[];

      await expectLater(
        ChatHandleJoinImporter(
          chatDbPath: 'malformed-chat.db',
          importLedger: importDatabase,
          sourceDatabaseOpener: _SyntheticRelationshipSourceDatabaseOpener(
            sourceDatabase,
          ),
        ).importJoins(onProgress: progress.add),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'chat_handle_join.source_rowid is required',
          ),
        ),
      );

      expect(sourceDatabase.closeCount, 1);
      expect(await _readRelationships(importDatabase), isEmpty);
      expect(await _readBatches(importDatabase), hasLength(1));
      expect(
        progress.map(_characterizeProgress).toList(),
        <Map<String, Object?>>[
          _expectedProgress(completed: 0, total: 2, omitted: 0),
        ],
      );
    },
  );

  test('batch failure precedes source opening', () async {
    final opener = _SyntheticRelationshipSourceDatabaseOpener(
      _SyntheticRelationshipSourceDatabase(
        rows: const <Map<String, Object?>>[],
      ),
    );

    await expectLater(
      ChatHandleJoinImporter(
        chatDbPath: 'batch-failure-chat.db',
        importLedger: _FailingBatchImportLedger(importDatabase),
        sourceDatabaseOpener: opener,
      ).importJoins(),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          'synthetic batch creation failed',
        ),
      ),
    );

    expect(opener.openedPaths, isEmpty);
    expect(await _readBatches(importDatabase), isEmpty);
  });

  test('source-open failure retains the already-created batch', () async {
    final opener = _FailingSourceDatabaseOpener();

    await expectLater(
      ChatHandleJoinImporter(
        chatDbPath: 'open-failure-chat.db',
        importLedger: importDatabase,
        sourceDatabaseOpener: opener,
      ).importJoins(),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          'synthetic relationship open failed',
        ),
      ),
    );

    expect(opener.openCount, 1);
    expect(await _readBatches(importDatabase), hasLength(1));
    expect(await _readRelationships(importDatabase), isEmpty);
  });

  test('query failure closes source and retains the batch', () async {
    final sourceDatabase = _SyntheticRelationshipSourceDatabase(
      rows: const <Map<String, Object?>>[],
      queryError: StateError('synthetic relationship query failed'),
    );

    await expectLater(
      ChatHandleJoinImporter(
        chatDbPath: 'query-failure-chat.db',
        importLedger: importDatabase,
        sourceDatabaseOpener: _SyntheticRelationshipSourceDatabaseOpener(
          sourceDatabase,
        ),
      ).importJoins(),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          'synthetic relationship query failed',
        ),
      ),
    );

    expect(sourceDatabase.closeCount, 1);
    expect(await _readBatches(importDatabase), hasLength(1));
    expect(await _readRelationships(importDatabase), isEmpty);
  });

  test(
    'write failure rolls back rows, closes source, and retains batch',
    () async {
      final sourceDatabase = _SyntheticRelationshipSourceDatabase(
        rows: <Map<String, Object?>>[
          _row(sourceRowId: 81, chatRowId: 91, handleRowId: 101),
          _row(sourceRowId: 82, chatRowId: 92, handleRowId: 102),
        ],
      );

      await expectLater(
        ChatHandleJoinImporter(
          chatDbPath: 'write-failure-chat.db',
          importLedger: _FailingInsertImportLedger(
            importDatabase,
            failOnAttempt: 2,
          ),
          sourceDatabaseOpener: _SyntheticRelationshipSourceDatabaseOpener(
            sourceDatabase,
          ),
        ).importJoins(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'synthetic relationship write failed',
          ),
        ),
      );

      expect(sourceDatabase.closeCount, 1);
      expect(await _readRelationships(importDatabase), isEmpty);
      expect(await _readBatches(importDatabase), hasLength(1));
    },
  );

  test(
    'initial progress failure closes before writes and retains batch',
    () async {
      final sourceDatabase = _SyntheticRelationshipSourceDatabase(
        rows: <Map<String, Object?>>[
          _row(sourceRowId: 111, chatRowId: 121, handleRowId: 131),
        ],
      );

      await expectLater(
        ChatHandleJoinImporter(
          chatDbPath: 'progress-failure-chat.db',
          importLedger: importDatabase,
          sourceDatabaseOpener: _SyntheticRelationshipSourceDatabaseOpener(
            sourceDatabase,
          ),
        ).importJoins(
          onProgress: (_) {
            throw StateError('synthetic initial progress failed');
          },
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'synthetic initial progress failed',
          ),
        ),
      );

      expect(sourceDatabase.closeCount, 1);
      expect(await _readRelationships(importDatabase), isEmpty);
      expect(await _readBatches(importDatabase), hasLength(1));
    },
  );

  test(
    'terminal progress failure rolls back admitted row and retains batch',
    () async {
      final sourceDatabase = _SyntheticRelationshipSourceDatabase(
        rows: <Map<String, Object?>>[
          _row(sourceRowId: 141, chatRowId: 151, handleRowId: 161),
        ],
      );
      var observationCount = 0;

      await expectLater(
        ChatHandleJoinImporter(
          chatDbPath: 'terminal-progress-failure-chat.db',
          importLedger: importDatabase,
          sourceDatabaseOpener: _SyntheticRelationshipSourceDatabaseOpener(
            sourceDatabase,
          ),
        ).importJoins(
          onProgress: (_) {
            observationCount += 1;
            if (observationCount == 2) {
              throw StateError('synthetic terminal progress failed');
            }
          },
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'synthetic terminal progress failed',
          ),
        ),
      );

      expect(observationCount, 2);
      expect(sourceDatabase.closeCount, 1);
      expect(await _readRelationships(importDatabase), isEmpty);
      expect(await _readBatches(importDatabase), hasLength(1));
    },
  );
}

const _fullRelationshipQuery =
    'SELECT chj.ROWID AS source_rowid, chj.chat_id, chj.handle_id, '
    'c.ROWID AS existing_chat_rowid, h.ROWID AS existing_handle_rowid '
    'FROM chat_handle_join chj '
    'LEFT JOIN chat c ON c.ROWID = chj.chat_id '
    'LEFT JOIN handle h ON h.ROWID = chj.handle_id '
    'ORDER BY chj.ROWID ASC';

Map<String, Object?> _row({
  required Object? sourceRowId,
  required Object? chatRowId,
  required Object? handleRowId,
  Object? existingChatRowId = _useEndpointValue,
  Object? existingHandleRowId = _useEndpointValue,
}) {
  return <String, Object?>{
    'source_rowid': sourceRowId,
    'chat_id': chatRowId,
    'handle_id': handleRowId,
    'existing_chat_rowid': identical(existingChatRowId, _useEndpointValue)
        ? chatRowId
        : existingChatRowId,
    'existing_handle_rowid': identical(existingHandleRowId, _useEndpointValue)
        ? handleRowId
        : existingHandleRowId,
  };
}

const _useEndpointValue = Object();

Map<String, Object?> _expectedRelationship({
  required int sourceId,
  required int sourceChatRowId,
  required int sourceHandleRowId,
  required int batchId,
}) {
  return <String, Object?>{
    'source_id': sourceId,
    'source_chat_rowid': sourceChatRowId,
    'source_handle_rowid': sourceHandleRowId,
    'chat_ss_id': SourceScopedRowKey.pack(
      sourceId: sourceId,
      sourceRowId: sourceChatRowId,
    ),
    'handle_ss_id': SourceScopedRowKey.pack(
      sourceId: sourceId,
      sourceRowId: sourceHandleRowId,
    ),
    'batch_id': batchId,
  };
}

Map<String, Object?> _characterizeProgress(SourceImportWorkProgress progress) {
  return <String, Object?>{
    'unit': progress.unit,
    'completed': progress.completedWorkCount,
    'total': progress.totalWorkCount,
    'last_source_rowid': progress.lastCompletedSourceRowId,
    'omitted': progress.anomalyCounts.omittedChatHandleRelationshipCount,
  };
}

Map<String, Object?> _expectedProgress({
  required int completed,
  required int total,
  required int omitted,
  int? lastSourceRowId,
}) {
  return <String, Object?>{
    'unit': SourceImportWorkUnit.chatHandleRelationships,
    'completed': completed,
    'total': total,
    'last_source_rowid': lastSourceRowId,
    'omitted': omitted,
  };
}

Future<List<Map<String, Object?>>> _readRelationships(ImportDatabase database) {
  return database.database.query(
    'chat_to_handle',
    columns: <String>[
      'source_id',
      'source_chat_rowid',
      'source_handle_rowid',
      'chat_ss_id',
      'handle_ss_id',
      'batch_id',
    ],
    orderBy: 'rowid ASC',
  );
}

Future<List<Map<String, Object?>>> _readBatches(ImportDatabase database) {
  return database.database.query('import_batches', orderBy: 'batch_id ASC');
}

@immutable
final class _ObservedQuery {
  const _ObservedQuery(this.sql, this.arguments);

  final String sql;
  final List<Object?> arguments;

  @override
  bool operator ==(Object other) {
    return other is _ObservedQuery &&
        other.sql == sql &&
        _listsEqual(other.arguments, arguments);
  }

  @override
  int get hashCode => Object.hash(sql, Object.hashAll(arguments));

  @override
  String toString() => '_ObservedQuery($sql, $arguments)';
}

bool _listsEqual(List<Object?> left, List<Object?> right) {
  if (left.length != right.length) {
    return false;
  }
  for (var index = 0; index < left.length; index += 1) {
    if (left[index] != right[index]) {
      return false;
    }
  }
  return true;
}

final class _SyntheticRelationshipSourceDatabaseOpener
    implements SourceDatabaseOpener {
  const _SyntheticRelationshipSourceDatabaseOpener(this.database);

  final _SyntheticRelationshipSourceDatabase database;
  List<String> get openedPaths => database.openedPaths;

  @override
  Future<ReadOnlySourceDatabase> openReadOnly(String databasePath) async {
    database.openedPaths.add(databasePath);
    return database;
  }
}

final class _FailingSourceDatabaseOpener implements SourceDatabaseOpener {
  int openCount = 0;

  @override
  Future<ReadOnlySourceDatabase> openReadOnly(String databasePath) async {
    openCount += 1;
    throw StateError('synthetic relationship open failed');
  }
}

final class _SyntheticRelationshipSourceDatabase
    implements ReadOnlySourceDatabase {
  _SyntheticRelationshipSourceDatabase({required this.rows, this.queryError});

  final List<Map<String, Object?>> rows;
  final Object? queryError;
  final List<String> openedPaths = <String>[];
  final List<_ObservedQuery> observedQueries = <_ObservedQuery>[];
  int closeCount = 0;

  @override
  Future<void> close() async {
    closeCount += 1;
  }

  @override
  Future<Set<String>> findExistingMessageGuids(Set<String> targetGuids) {
    throw UnsupportedError('Relationship importer does not read GUIDs');
  }

  @override
  Future<SourceMessageImportWindow> messageImportWindowAfter(int sourceRowId) {
    throw UnsupportedError('Relationship importer does not page messages');
  }

  @override
  Future<List<Map<String, Object?>>> query(String table, {String? orderBy}) {
    throw UnsupportedError('Relationship importer uses one bounded raw query');
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    observedQueries.add(
      _ObservedQuery(sql, List<Object?>.of(arguments ?? const <Object?>[])),
    );
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
    throw UnsupportedError('Relationship importer does not page messages');
  }
}

final class _FailingBatchImportLedger implements ImportLedger {
  const _FailingBatchImportLedger(this.delegate);

  final ImportDatabase delegate;

  @override
  Future<int> insertImportBatch({
    required int sourceId,
    required String startedAtUtc,
  }) {
    throw StateError('synthetic batch creation failed');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

final class _FailingInsertImportLedger implements ImportLedger {
  const _FailingInsertImportLedger(
    this.delegate, {
    required this.failOnAttempt,
  });

  final ImportDatabase delegate;
  final int failOnAttempt;

  @override
  Future<int> insertImportBatch({
    required int sourceId,
    required String startedAtUtc,
  }) {
    return delegate.insertImportBatch(
      sourceId: sourceId,
      startedAtUtc: startedAtUtc,
    );
  }

  @override
  Future<T> writeTransaction<T>(
    Future<T> Function(ImportLedgerWriteTransaction txn) action,
  ) {
    return delegate.writeTransaction((txn) {
      return action(
        _FailingInsertTransaction(txn, failOnAttempt: failOnAttempt),
      );
    });
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

final class _FailingInsertTransaction implements ImportLedgerWriteTransaction {
  _FailingInsertTransaction(this.delegate, {required this.failOnAttempt});

  final ImportLedgerWriteTransaction delegate;
  final int failOnAttempt;
  int attemptCount = 0;

  @override
  Future<int> insertIgnore(String table, Map<String, Object?> values) {
    attemptCount += 1;
    if (attemptCount == failOnAttempt) {
      throw StateError('synthetic relationship write failed');
    }
    return delegate.insertIgnore(table, values);
  }

  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
  }) {
    return delegate.update(table, values, where: where, whereArgs: whereArgs);
  }
}
