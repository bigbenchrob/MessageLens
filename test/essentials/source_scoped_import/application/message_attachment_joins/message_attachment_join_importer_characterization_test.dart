import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/message_attachment_joins/message_attachment_join_importer.dart';
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
      'message_attachment_join_importer_characterization_',
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
    'characterizes exact query, seven ledger fields, endpoint identity, '
    'coercion, omissions, duplicates, batches, progress, and reruns',
    () async {
      final sourceId = await importDatabase.getOrCreateSource(
        sourceKey: 'characterization-archive',
        sourceKind: 'historical-chat-db',
      );
      final sourceDatabase = _SyntheticRelationshipSourceDatabase(
        rows: <Map<String, Object?>>[
          _row(sourceRowId: 1, messageRowId: 10, attachmentRowId: 20),
          _row(sourceRowId: 2.4, messageRowId: 11.6, attachmentRowId: 21.4),
          _row(sourceRowId: 3, messageRowId: 10, attachmentRowId: 20),
          _row(sourceRowId: 4, messageRowId: 10, attachmentRowId: 22),
          _row(
            sourceRowId: 5,
            messageRowId: 13,
            attachmentRowId: 23,
            existingMessageRowId: null,
          ),
          _row(
            sourceRowId: 6,
            messageRowId: 14,
            attachmentRowId: 24,
            existingAttachmentRowId: null,
          ),
          _row(
            sourceRowId: 7,
            messageRowId: 'malformed-message',
            attachmentRowId: 25,
          ),
          _row(
            sourceRowId: 8,
            messageRowId: 15,
            attachmentRowId: 'malformed-attachment',
          ),
        ],
      );
      final opener = _SyntheticRelationshipSourceDatabaseOpener(sourceDatabase);
      final importer = MessageAttachmentJoinImporter(
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
          sourceMessageRowId: 10,
          sourceAttachmentRowId: 20,
          batchId: firstBatchId,
        ),
        _expectedRelationship(
          sourceId: sourceId,
          sourceMessageRowId: 12,
          sourceAttachmentRowId: 21,
          batchId: firstBatchId,
        ),
        _expectedRelationship(
          sourceId: sourceId,
          sourceMessageRowId: 10,
          sourceAttachmentRowId: 22,
          batchId: firstBatchId,
        ),
      ]);
      expect(storedRows.first.keys.toList(), <String>[
        'message_source_id',
        'attachment_source_id',
        'source_message_rowid',
        'source_attachment_rowid',
        'message_ss_id',
        'attachment_ss_id',
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

  test('characterizes exact incremental cursor query and arguments', () async {
    final sourceDatabase = _SyntheticRelationshipSourceDatabase(
      rows: <Map<String, Object?>>[
        _row(sourceRowId: 31, messageRowId: 41, attachmentRowId: 51),
      ],
    );

    final result = await MessageAttachmentJoinImporter(
      chatDbPath: 'incremental-chat.db',
      importLedger: importDatabase,
      sourceDatabaseOpener: _SyntheticRelationshipSourceDatabaseOpener(
        sourceDatabase,
      ),
    ).importJoinsAfterSourceMessageRowId(startedAfterSourceRowId: 40);

    expect(result.examinedJoinCount, 1);
    expect(result.insertedJoinCount, 1);
    expect(sourceDatabase.observedQueries, <_ObservedQuery>[
      const _ObservedQuery(_incrementalRelationshipQuery, <Object?>[40]),
    ]);
    expect(sourceDatabase.closeCount, 1);
  });

  test(
    'empty selection creates no batch and publishes zero progress',
    () async {
      final sourceDatabase = _SyntheticRelationshipSourceDatabase(
        rows: const <Map<String, Object?>>[],
      );
      final progress = <SourceImportWorkProgress>[];

      final result = await MessageAttachmentJoinImporter(
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
      expect(await _readBatches(importDatabase), isEmpty);
      expect(
        progress.map(_characterizeProgress).toList(),
        <Map<String, Object?>>[
          _expectedProgress(completed: 0, total: 0, omitted: 0),
        ],
      );
    },
  );

  test(
    'malformed raw join identity rolls back an earlier row and retains batch',
    () async {
      final sourceDatabase = _SyntheticRelationshipSourceDatabase(
        rows: <Map<String, Object?>>[
          _row(sourceRowId: 61, messageRowId: 71, attachmentRowId: 81),
          _row(
            sourceRowId: 'malformed-source-rowid',
            messageRowId: 72,
            attachmentRowId: 82,
          ),
        ],
      );
      final progress = <SourceImportWorkProgress>[];

      await expectLater(
        MessageAttachmentJoinImporter(
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
            'message_attachment_join.source_rowid is required',
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

  test('source-open failure creates no batch', () async {
    final opener = _FailingSourceDatabaseOpener();

    await expectLater(
      MessageAttachmentJoinImporter(
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
    expect(await _readBatches(importDatabase), isEmpty);
  });

  test('query failure closes source and creates no batch', () async {
    final sourceDatabase = _SyntheticRelationshipSourceDatabase(
      rows: const <Map<String, Object?>>[],
      queryError: StateError('synthetic relationship query failed'),
    );

    await expectLater(
      MessageAttachmentJoinImporter(
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
    expect(await _readBatches(importDatabase), isEmpty);
  });

  test('batch failure occurs after query and closes source', () async {
    final sourceDatabase = _SyntheticRelationshipSourceDatabase(
      rows: <Map<String, Object?>>[
        _row(sourceRowId: 91, messageRowId: 101, attachmentRowId: 111),
      ],
    );

    await expectLater(
      MessageAttachmentJoinImporter(
        chatDbPath: 'batch-failure-chat.db',
        importLedger: const _FailingBatchImportLedger(),
        sourceDatabaseOpener: _SyntheticRelationshipSourceDatabaseOpener(
          sourceDatabase,
        ),
      ).importJoins(),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          'synthetic batch creation failed',
        ),
      ),
    );

    expect(sourceDatabase.observedQueries, hasLength(1));
    expect(sourceDatabase.closeCount, 1);
    expect(await _readBatches(importDatabase), isEmpty);
  });

  test(
    'write failure rolls back rows, closes source, and retains batch',
    () async {
      final sourceDatabase = _SyntheticRelationshipSourceDatabase(
        rows: <Map<String, Object?>>[
          _row(sourceRowId: 121, messageRowId: 131, attachmentRowId: 141),
          _row(sourceRowId: 122, messageRowId: 132, attachmentRowId: 142),
        ],
      );

      await expectLater(
        MessageAttachmentJoinImporter(
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

  test('initial progress failure retains batch but writes no row', () async {
    final sourceDatabase = _SyntheticRelationshipSourceDatabase(
      rows: <Map<String, Object?>>[
        _row(sourceRowId: 151, messageRowId: 161, attachmentRowId: 171),
      ],
    );

    await expectLater(
      MessageAttachmentJoinImporter(
        chatDbPath: 'initial-progress-failure-chat.db',
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
  });

  test('terminal progress failure rolls back row and retains batch', () async {
    final sourceDatabase = _SyntheticRelationshipSourceDatabase(
      rows: <Map<String, Object?>>[
        _row(sourceRowId: 181, messageRowId: 191, attachmentRowId: 201),
      ],
    );
    var observationCount = 0;

    await expectLater(
      MessageAttachmentJoinImporter(
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
  });

  test(
    'source-close failure propagates after committed row and batch',
    () async {
      final sourceDatabase = _SyntheticRelationshipSourceDatabase(
        rows: <Map<String, Object?>>[
          _row(sourceRowId: 211, messageRowId: 221, attachmentRowId: 231),
        ],
        closeError: StateError('synthetic relationship close failed'),
      );

      await expectLater(
        MessageAttachmentJoinImporter(
          chatDbPath: 'close-failure-chat.db',
          importLedger: importDatabase,
          sourceDatabaseOpener: _SyntheticRelationshipSourceDatabaseOpener(
            sourceDatabase,
          ),
        ).importJoins(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'synthetic relationship close failed',
          ),
        ),
      );

      expect(sourceDatabase.closeCount, 1);
      expect(await _readRelationships(importDatabase), hasLength(1));
      expect(await _readBatches(importDatabase), hasLength(1));
    },
  );
}

const _fullRelationshipQuery =
    'SELECT maj.ROWID AS source_rowid, maj.message_id, '
    'maj.attachment_id, m.ROWID AS existing_message_rowid, '
    'a.ROWID AS existing_attachment_rowid '
    'FROM message_attachment_join maj '
    'LEFT JOIN message m ON m.ROWID = maj.message_id '
    'LEFT JOIN attachment a ON a.ROWID = maj.attachment_id '
    ' ORDER BY message_id ASC, attachment_id ASC';

const _incrementalRelationshipQuery =
    'SELECT maj.ROWID AS source_rowid, maj.message_id, '
    'maj.attachment_id, m.ROWID AS existing_message_rowid, '
    'a.ROWID AS existing_attachment_rowid '
    'FROM message_attachment_join maj '
    'LEFT JOIN message m ON m.ROWID = maj.message_id '
    'LEFT JOIN attachment a ON a.ROWID = maj.attachment_id '
    'WHERE maj.message_id > ? '
    'ORDER BY message_id ASC, attachment_id ASC';

Map<String, Object?> _row({
  required Object? sourceRowId,
  required Object? messageRowId,
  required Object? attachmentRowId,
  Object? existingMessageRowId = _useEndpointValue,
  Object? existingAttachmentRowId = _useEndpointValue,
}) {
  return <String, Object?>{
    'source_rowid': sourceRowId,
    'message_id': messageRowId,
    'attachment_id': attachmentRowId,
    'existing_message_rowid': identical(existingMessageRowId, _useEndpointValue)
        ? messageRowId
        : existingMessageRowId,
    'existing_attachment_rowid':
        identical(existingAttachmentRowId, _useEndpointValue)
        ? attachmentRowId
        : existingAttachmentRowId,
  };
}

const _useEndpointValue = Object();

Map<String, Object?> _expectedRelationship({
  required int sourceId,
  required int sourceMessageRowId,
  required int sourceAttachmentRowId,
  required int batchId,
}) {
  return <String, Object?>{
    'message_source_id': sourceId,
    'attachment_source_id': sourceId,
    'source_message_rowid': sourceMessageRowId,
    'source_attachment_rowid': sourceAttachmentRowId,
    'message_ss_id': SourceScopedRowKey.pack(
      sourceId: sourceId,
      sourceRowId: sourceMessageRowId,
    ),
    'attachment_ss_id': SourceScopedRowKey.pack(
      sourceId: sourceId,
      sourceRowId: sourceAttachmentRowId,
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
    'omitted': progress.anomalyCounts.omittedMessageAttachmentRelationshipCount,
  };
}

Map<String, Object?> _expectedProgress({
  required int completed,
  required int total,
  required int omitted,
  int? lastSourceRowId,
}) {
  return <String, Object?>{
    'unit': SourceImportWorkUnit.messageAttachmentRelationships,
    'completed': completed,
    'total': total,
    'last_source_rowid': lastSourceRowId,
    'omitted': omitted,
  };
}

Future<List<Map<String, Object?>>> _readRelationships(ImportDatabase database) {
  return database.database.query(
    'message_to_attachment',
    columns: <String>[
      'message_source_id',
      'attachment_source_id',
      'source_message_rowid',
      'source_attachment_rowid',
      'message_ss_id',
      'attachment_ss_id',
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
  _SyntheticRelationshipSourceDatabase({
    required this.rows,
    this.queryError,
    this.closeError,
  });

  final List<Map<String, Object?>> rows;
  final Object? queryError;
  final Object? closeError;
  final List<String> openedPaths = <String>[];
  final List<_ObservedQuery> observedQueries = <_ObservedQuery>[];
  int closeCount = 0;

  @override
  Future<void> close() async {
    closeCount += 1;
    if (closeError != null) {
      throw closeError!;
    }
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
  const _FailingBatchImportLedger();

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
