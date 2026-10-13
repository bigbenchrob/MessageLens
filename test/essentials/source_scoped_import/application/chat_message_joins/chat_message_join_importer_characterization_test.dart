import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/chat_message_joins/chat_message_join_importer.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/source_import_work_progress.dart';
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
      'chat_message_join_importer_characterization_',
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
    'characterizes seven ledger fields, identity, coercion, omissions, '
    'duplicates, progress, and insert-ignore reruns before extraction',
    () async {
      const sourceId = 42;
      final sourceDatabase = _SyntheticRelationshipSourceDatabase(
        rows: <Map<String, Object?>>[
          _row(sourceRowId: 1, chatRowId: 10, messageRowId: 20),
          _row(sourceRowId: 2.4, chatRowId: 11.6, messageRowId: 21.4),
          _row(sourceRowId: 3, chatRowId: 10, messageRowId: 20),
          _row(
            sourceRowId: 4,
            chatRowId: 12,
            messageRowId: 22,
            existingChatRowId: null,
          ),
          _row(
            sourceRowId: 5,
            chatRowId: 13,
            messageRowId: 23,
            existingMessageRowId: null,
          ),
          _row(
            sourceRowId: 6,
            chatRowId: 'malformed-endpoint',
            messageRowId: 24,
          ),
        ],
      );
      final opener = _SyntheticRelationshipSourceDatabaseOpener(sourceDatabase);
      final firstProgress = <SourceImportWorkProgress>[];
      final importer = ChatMessageJoinImporter(
        chatDbPath: 'synthetic-chat.db',
        importLedger: importDatabase,
        sourceDatabaseOpener: opener,
        sourceId: sourceId,
      );

      final firstResult = await importer.importJoins(
        onProgress: firstProgress.add,
      );

      expect(firstResult.examinedJoinCount, 6);
      expect(firstResult.insertedJoinCount, 3);
      expect(firstResult.omittedJoinCount, 3);
      expect(opener.openedPaths, <String>['synthetic-chat.db']);
      expect(sourceDatabase.closeCount, 1);
      expect(sourceDatabase.observedQueries, <_ObservedQuery>[
        const _ObservedQuery(_fullRelationshipQuery, <Object?>[]),
      ]);
      final storedRows = await _readRelationships(importDatabase);
      expect(storedRows, hasLength(3));
      expect(storedRows.first.keys.toList(), <String>[
        'ss_id',
        'source_id',
        'source_rowid',
        'source_chat_rowid',
        'source_message_rowid',
        'chat_ss_id',
        'message_ss_id',
      ]);
      expect(storedRows, <Map<String, Object?>>[
        _expectedRelationship(
          sourceId: sourceId,
          sourceRowId: 1,
          sourceChatRowId: 10,
          sourceMessageRowId: 20,
        ),
        _expectedRelationship(
          sourceId: sourceId,
          sourceRowId: 2,
          sourceChatRowId: 12,
          sourceMessageRowId: 21,
        ),
        _expectedRelationship(
          sourceId: sourceId,
          sourceRowId: 3,
          sourceChatRowId: 10,
          sourceMessageRowId: 20,
        ),
      ]);
      expect(
        firstProgress.map(_characterizeProgress).toList(),
        <Map<String, Object?>>[
          _expectedProgress(completed: 0, total: 6, omitted: 0),
          _expectedProgress(
            completed: 6,
            total: 6,
            lastSourceRowId: 6,
            omitted: 3,
          ),
        ],
      );

      sourceDatabase.observedQueries.clear();
      final secondProgress = <SourceImportWorkProgress>[];
      final secondResult = await importer.importJoins(
        onProgress: secondProgress.add,
      );

      expect(secondResult.examinedJoinCount, 6);
      expect(secondResult.insertedJoinCount, 0);
      expect(secondResult.omittedJoinCount, 3);
      expect(sourceDatabase.closeCount, 2);
      expect(await _readRelationships(importDatabase), storedRows);
      expect(
        secondProgress.map(_characterizeProgress).toList(),
        <Map<String, Object?>>[
          _expectedProgress(completed: 0, total: 6, omitted: 0),
          _expectedProgress(
            completed: 6,
            total: 6,
            lastSourceRowId: 6,
            omitted: 3,
          ),
        ],
      );
    },
  );

  test('characterizes empty source behavior and lifecycle', () async {
    final sourceDatabase = _SyntheticRelationshipSourceDatabase(
      rows: const <Map<String, Object?>>[],
    );
    final progress = <SourceImportWorkProgress>[];

    final result = await ChatMessageJoinImporter(
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
    expect(progress.map(_characterizeProgress).toList(), <Map<String, Object?>>[
      _expectedProgress(completed: 0, total: 0, omitted: 0),
    ]);
  });

  test('characterizes the source-message incremental boundary', () async {
    final sourceDatabase = _SyntheticRelationshipSourceDatabase(
      rows: <Map<String, Object?>>[
        _row(sourceRowId: 31, chatRowId: 41, messageRowId: 51),
      ],
    );

    final result = await ChatMessageJoinImporter(
      chatDbPath: 'incremental-chat.db',
      importLedger: importDatabase,
      sourceDatabaseOpener: _SyntheticRelationshipSourceDatabaseOpener(
        sourceDatabase,
      ),
    ).importJoinsAfterSourceMessageRowId(startedAfterSourceRowId: 50);

    expect(result.examinedJoinCount, 1);
    expect(result.insertedJoinCount, 1);
    expect(sourceDatabase.observedQueries, <_ObservedQuery>[
      const _ObservedQuery(_incrementalRelationshipQuery, <Object?>[50]),
    ]);
    expect(sourceDatabase.closeCount, 1);
  });

  test(
    'malformed required identity rolls back an earlier admitted row',
    () async {
      final sourceDatabase = _SyntheticRelationshipSourceDatabase(
        rows: <Map<String, Object?>>[
          _row(sourceRowId: 61, chatRowId: 71, messageRowId: 81),
          _row(
            sourceRowId: 'malformed-source-rowid',
            chatRowId: 72,
            messageRowId: 82,
          ),
        ],
      );

      await expectLater(
        ChatMessageJoinImporter(
          chatDbPath: 'malformed-chat.db',
          importLedger: importDatabase,
          sourceDatabaseOpener: _SyntheticRelationshipSourceDatabaseOpener(
            sourceDatabase,
          ),
        ).importJoins(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'chat_message_join.source_rowid is required',
          ),
        ),
      );

      expect(sourceDatabase.closeCount, 1);
      expect(await _readRelationships(importDatabase), isEmpty);
    },
  );

  test(
    'a later ledger write failure rolls back the actual transaction',
    () async {
      final sourceDatabase = _SyntheticRelationshipSourceDatabase(
        rows: <Map<String, Object?>>[
          _row(sourceRowId: 91, chatRowId: 101, messageRowId: 111),
          _row(sourceRowId: 92, chatRowId: 102, messageRowId: 112),
        ],
      );

      await expectLater(
        ChatMessageJoinImporter(
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
    },
  );

  test('source query failure is propagated and the source is closed', () async {
    final sourceDatabase = _SyntheticRelationshipSourceDatabase(
      rows: const <Map<String, Object?>>[],
      queryError: StateError('synthetic relationship query failed'),
    );

    await expectLater(
      ChatMessageJoinImporter(
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
    expect(await _readRelationships(importDatabase), isEmpty);
  });

  test(
    'source-open failure is propagated without a fabricated lifecycle',
    () async {
      final opener = _FailingSourceDatabaseOpener();

      await expectLater(
        ChatMessageJoinImporter(
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
      expect(await _readRelationships(importDatabase), isEmpty);
    },
  );

  test('initial progress observer failure closes before any write', () async {
    final sourceDatabase = _SyntheticRelationshipSourceDatabase(
      rows: <Map<String, Object?>>[
        _row(sourceRowId: 121, chatRowId: 131, messageRowId: 141),
      ],
    );

    await expectLater(
      ChatMessageJoinImporter(
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
  });

  test(
    'terminal progress observer failure rolls back the admitted row',
    () async {
      final sourceDatabase = _SyntheticRelationshipSourceDatabase(
        rows: <Map<String, Object?>>[
          _row(sourceRowId: 151, chatRowId: 161, messageRowId: 171),
        ],
      );
      var observationCount = 0;

      await expectLater(
        ChatMessageJoinImporter(
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
    },
  );
}

const _fullRelationshipQuery =
    'SELECT cmj.ROWID AS source_rowid, cmj.chat_id, cmj.message_id, '
    'c.ROWID AS existing_chat_rowid, '
    'm.ROWID AS existing_message_rowid '
    'FROM chat_message_join cmj '
    'LEFT JOIN chat c ON c.ROWID = cmj.chat_id '
    'LEFT JOIN message m ON m.ROWID = cmj.message_id '
    ' '
    'ORDER BY cmj.ROWID ASC';

const _incrementalRelationshipQuery =
    'SELECT cmj.ROWID AS source_rowid, cmj.chat_id, cmj.message_id, '
    'c.ROWID AS existing_chat_rowid, '
    'm.ROWID AS existing_message_rowid '
    'FROM chat_message_join cmj '
    'LEFT JOIN chat c ON c.ROWID = cmj.chat_id '
    'LEFT JOIN message m ON m.ROWID = cmj.message_id '
    'WHERE cmj.message_id > ? '
    'ORDER BY cmj.ROWID ASC';

Map<String, Object?> _row({
  required Object? sourceRowId,
  required Object? chatRowId,
  required Object? messageRowId,
  Object? existingChatRowId = _useEndpointValue,
  Object? existingMessageRowId = _useEndpointValue,
}) {
  return <String, Object?>{
    'source_rowid': sourceRowId,
    'chat_id': chatRowId,
    'message_id': messageRowId,
    'existing_chat_rowid': identical(existingChatRowId, _useEndpointValue)
        ? chatRowId
        : existingChatRowId,
    'existing_message_rowid': identical(existingMessageRowId, _useEndpointValue)
        ? messageRowId
        : existingMessageRowId,
  };
}

const _useEndpointValue = Object();

Map<String, Object?> _expectedRelationship({
  required int sourceId,
  required int sourceRowId,
  required int sourceChatRowId,
  required int sourceMessageRowId,
}) {
  return <String, Object?>{
    'ss_id': SourceScopedRowKey.pack(
      sourceId: sourceId,
      sourceRowId: sourceRowId,
    ),
    'source_id': sourceId,
    'source_rowid': sourceRowId,
    'source_chat_rowid': sourceChatRowId,
    'source_message_rowid': sourceMessageRowId,
    'chat_ss_id': SourceScopedRowKey.pack(
      sourceId: sourceId,
      sourceRowId: sourceChatRowId,
    ),
    'message_ss_id': SourceScopedRowKey.pack(
      sourceId: sourceId,
      sourceRowId: sourceMessageRowId,
    ),
  };
}

Map<String, Object?> _characterizeProgress(SourceImportWorkProgress progress) {
  return <String, Object?>{
    'unit': progress.unit,
    'completed': progress.completedWorkCount,
    'total': progress.totalWorkCount,
    'last_source_rowid': progress.lastCompletedSourceRowId,
    'omitted': progress.anomalyCounts.omittedChatMessageRelationshipCount,
  };
}

Map<String, Object?> _expectedProgress({
  required int completed,
  required int total,
  required int omitted,
  int? lastSourceRowId,
}) {
  return <String, Object?>{
    'unit': SourceImportWorkUnit.chatMessageRelationships,
    'completed': completed,
    'total': total,
    'last_source_rowid': lastSourceRowId,
    'omitted': omitted,
  };
}

Future<List<Map<String, Object?>>> _readRelationships(ImportDatabase database) {
  return database.database.query(
    'chat_to_message',
    orderBy: 'source_rowid ASC',
  );
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
    final observedArguments = List<Object?>.of(arguments ?? const <Object?>[]);
    observedQueries.add(_ObservedQuery(sql, observedArguments));
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

final class _FailingInsertImportLedger implements ImportLedger {
  _FailingInsertImportLedger(this.delegate, {required this.failOnAttempt});

  final ImportDatabase delegate;
  final int failOnAttempt;

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
