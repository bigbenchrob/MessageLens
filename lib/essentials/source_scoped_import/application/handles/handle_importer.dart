import '../../../db/shared/handle_identifier_utils.dart';
import '../../domain/known_sources.dart';
import '../../domain/ports/import_ledger_port.dart';
import '../../domain/ports/source_database_port.dart';
import '../../domain/source_import_anomaly_counts.dart';
import '../source_import_work_progress.dart';
import 'handle_source_projection.dart';

class HandleImportResult {
  const HandleImportResult({
    required this.startedAfterSourceRowId,
    required this.insertedHandleCount,
    required this.lastImportedSourceRowId,
    this.examinedHandleCount = 0,
    this.normalizedHandleCount = 0,
    this.preservedUnnormalizedHandleCount = 0,
  });

  final int startedAfterSourceRowId;
  final int insertedHandleCount;
  final int? lastImportedSourceRowId;
  final int examinedHandleCount;
  final int normalizedHandleCount;
  final int preservedUnnormalizedHandleCount;
}

class HandleIdentityReconciliationResult {
  const HandleIdentityReconciliationResult({
    required this.examinedHandleCount,
    required this.localAccountHandleCount,
    required this.updatedHandleCount,
  });

  final int examinedHandleCount;
  final int localAccountHandleCount;
  final int updatedHandleCount;
}

class HandleImporter {
  const HandleImporter({
    required this.chatDbPath,
    required this.importLedger,
    required this.sourceDatabaseOpener,
    this.sourceId = liveChatDbSourceId,
    this.handleIdentifierInterpreter = interpretHandleIdentifier,
  });

  final String chatDbPath;
  final ImportLedger importLedger;
  final SourceDatabaseOpener sourceDatabaseOpener;
  final int sourceId;
  final HandleIdentifierInterpreter handleIdentifierInterpreter;

  /// Reconciles local-account identity without importing source records.
  ///
  /// This deliberately scans all historical account evidence so aliases used
  /// by older devices remain identifiable even when chat.db has no new rows.
  Future<HandleIdentityReconciliationResult>
  reconcileLocalAccountIdentity() async {
    final sourceDb = await sourceDatabaseOpener.openReadOnly(chatDbPath);
    try {
      final localAccountHandleKeys = await _readLocalAccountHandleKeys(
        sourceDb,
        includeMessageFallback: true,
      );
      final rows = await importLedger.queryTable(
        'handles',
        columns: const <String>['source_rowid', 'id', 'is_me'],
        where: 'source_id = ?',
        whereArgs: <Object?>[sourceId],
      );
      var localAccountHandleCount = 0;
      var updatedHandleCount = 0;

      await importLedger.writeTransaction((txn) async {
        for (final row in rows) {
          final isMe = localAccountHandleKeys.contains(
            _handleGroupingKey(_requiredString(row, 'id')),
          );
          if (isMe) {
            localAccountHandleCount += 1;
          }
          if ((row['is_me'] == 1) == isMe) {
            continue;
          }
          updatedHandleCount += await txn.update(
            'handles',
            <String, Object?>{'is_me': isMe ? 1 : 0},
            where: 'source_id = ? AND source_rowid = ?',
            whereArgs: <Object?>[sourceId, _requiredInt(row, 'source_rowid')],
          );
        }
      });

      return HandleIdentityReconciliationResult(
        examinedHandleCount: rows.length,
        localAccountHandleCount: localAccountHandleCount,
        updatedHandleCount: updatedHandleCount,
      );
    } finally {
      await sourceDb.close();
    }
  }

  Future<HandleImportResult> importNewHandles({
    SourceImportWorkObserver? onProgress,
  }) async {
    final startedAfterSourceRowId =
        await importLedger.maxHandleSourceRowIdForSource(sourceId) ?? 0;
    final batchId = await importLedger.insertImportBatch(
      sourceId: sourceId,
      startedAtUtc: DateTime.now().toUtc().toIso8601String(),
    );
    final sourceDb = await sourceDatabaseOpener.openReadOnly(chatDbPath);

    var insertedHandleCount = 0;
    var normalizedHandleCount = 0;
    var preservedUnnormalizedHandleCount = 0;
    var examinedHandleCount = 0;
    int? lastImportedSourceRowId;
    try {
      final rows = await sourceDb.rawQuery(
        'SELECT ROWID AS source_rowid, id, service '
        'FROM handle ORDER BY ROWID ASC',
      );
      examinedHandleCount = rows.length;
      final hasNewSourceHandles = rows.any((row) {
        return _requiredInt(row, 'source_rowid') > startedAfterSourceRowId;
      });
      final localAccountHandleKeys = await _readLocalAccountHandleKeys(
        sourceDb,
        includeMessageFallback: hasNewSourceHandles,
      );

      var completedHandleCount = 0;
      publishSourceImportProgress(
        observer: onProgress,
        unit: SourceImportWorkUnit.handles,
        completedWorkCount: 0,
        totalWorkCount: rows.length,
      );
      await importLedger.writeTransaction((txn) async {
        for (final row in rows) {
          int? sourceRowId;
          try {
            final input = HandleSourceProjectionInput.fromSourceRow(row);
            sourceRowId = input.requiredSourceRowId;
            if (sourceRowId > startedAfterSourceRowId) {
              lastImportedSourceRowId = sourceRowId;
            }
            final rawIdentifier = input.requiredIdentifier;
            final isMe = localAccountHandleKeys.contains(
              _handleGroupingKey(rawIdentifier),
            );
            final projected = projectSourceHandle(
              input: input,
              sourceId: sourceId,
              batchId: batchId,
              isMe: isMe,
              handleIdentifierInterpreter: handleIdentifierInterpreter,
            );
            switch (projected.identifierInterpretation) {
              case NormalizedHandleIdentifier():
                normalizedHandleCount += 1;
              case PreservedUnnormalizedHandleIdentifier():
                preservedUnnormalizedHandleCount += 1;
            }
            final insertedId = await txn.insertIgnore(
              'handles',
              projected.ledgerValues,
            );

            if (insertedId == 0) {
              await txn.update(
                'handles',
                <String, Object?>{'is_me': isMe ? 1 : 0},
                where: 'source_id = ? AND source_rowid = ?',
                whereArgs: <Object?>[sourceId, sourceRowId],
              );
            }

            if (insertedId != 0) {
              insertedHandleCount += 1;
            }
          } on StateError catch (error) {
            throw SourceImportRecordException(
              unit: SourceImportWorkUnit.handles,
              sourceRowId: sourceRowId,
              reason: error.message,
            );
          }
          completedHandleCount += 1;
          publishSourceImportProgress(
            observer: onProgress,
            unit: SourceImportWorkUnit.handles,
            completedWorkCount: completedHandleCount,
            totalWorkCount: rows.length,
            lastCompletedSourceRowId: sourceRowId,
            anomalyCounts: SourceImportAnomalyCounts(
              preservedUnnormalizedHandleCount:
                  preservedUnnormalizedHandleCount,
            ),
          );
        }
      });
    } finally {
      await sourceDb.close();
    }

    return HandleImportResult(
      startedAfterSourceRowId: startedAfterSourceRowId,
      insertedHandleCount: insertedHandleCount,
      lastImportedSourceRowId: lastImportedSourceRowId,
      examinedHandleCount: examinedHandleCount,
      normalizedHandleCount: normalizedHandleCount,
      preservedUnnormalizedHandleCount: preservedUnnormalizedHandleCount,
    );
  }

  Future<Set<String>> _readLocalAccountHandleKeys(
    ReadOnlySourceDatabase sourceDb, {
    required bool includeMessageFallback,
  }) async {
    final existingRows = await importLedger.queryTable(
      'handles',
      columns: const <String>['id'],
      where: 'source_id = ? AND is_me = 1',
      whereArgs: <Object?>[sourceId],
    );
    final keys = <String>{};
    for (final row in existingRows) {
      final identifier = _nullableString(row, 'id');
      final key = identifier == null ? null : _handleGroupingKey(identifier);
      if (key != null) {
        keys.add(key);
      }
    }
    final needsInitialBackfill = keys.isEmpty;
    final chatColumns = await _columnNames(sourceDb, 'chat');
    if (chatColumns.contains('account_login')) {
      final rows = await sourceDb.rawQuery(
        'SELECT DISTINCT account_login FROM chat '
        'WHERE account_login IS NOT NULL AND trim(account_login) != ?',
        const <Object?>[''],
      );
      for (final row in rows) {
        final value = _nullableString(row, 'account_login');
        final key = value == null ? null : _handleGroupingKey(value);
        if (key != null) {
          keys.add(key);
        }
      }
    }

    final shouldScanMessages = needsInitialBackfill || includeMessageFallback;
    final messageColumns = shouldScanMessages
        ? await _columnNames(sourceDb, 'message')
        : const <String>{};
    if (shouldScanMessages &&
        messageColumns.contains('destination_caller_id') &&
        messageColumns.contains('is_from_me')) {
      final rows = await sourceDb.rawQuery(
        'SELECT DISTINCT destination_caller_id FROM message '
        'WHERE is_from_me = 0 '
        'AND destination_caller_id IS NOT NULL '
        'AND trim(destination_caller_id) != ?',
        const <Object?>[''],
      );
      for (final row in rows) {
        final value = _nullableString(row, 'destination_caller_id');
        final key = value == null ? null : _handleGroupingKey(value);
        if (key != null) {
          keys.add(key);
        }
      }
    }
    return keys;
  }

  Future<Set<String>> _columnNames(
    ReadOnlySourceDatabase sourceDb,
    String table,
  ) async {
    final rows = await sourceDb.rawQuery('PRAGMA table_info($table)');
    return {
      for (final row in rows)
        if (row['name'] case final String name) name,
    };
  }

  static int _requiredInt(Map<String, Object?> row, String field) {
    final value = row[field];
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    throw StateError('handle.$field is required');
  }

  static String _requiredString(Map<String, Object?> row, String field) {
    final value = _nullableString(row, field);
    if (value == null) {
      throw StateError('handle.$field is required');
    }
    return value;
  }

  static String? _nullableString(Map<String, Object?> row, String field) {
    final value = row[field];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    return null;
  }

  static String? _handleGroupingKey(String value) {
    final trimmed = value.trim();
    final withoutAccountKind = RegExp(r'^[eEpP]:').hasMatch(trimmed)
        ? trimmed.substring(2)
        : trimmed;
    return switch (interpretHandleIdentifier(withoutAccountKind)) {
      NormalizedHandleIdentifier(:final normalizedIdentifier) =>
        normalizedIdentifier,
      PreservedUnnormalizedHandleIdentifier() => null,
    };
  }
}
