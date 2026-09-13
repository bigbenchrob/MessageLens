import 'package:sqflite/sqflite.dart';

import '../../../db/application/read_only_sql_guard.dart';
import '../../domain/ports/source_database_port.dart';

final class SqfliteSourceDatabaseOpener implements SourceDatabaseOpener {
  const SqfliteSourceDatabaseOpener();

  @override
  Future<ReadOnlySourceDatabase> openReadOnly(String databasePath) async {
    final database = await openDatabase(
      databasePath,
      readOnly: true,
      singleInstance: false,
    );
    await database.execute('PRAGMA query_only = ON');
    await database.execute('PRAGMA busy_timeout = 3000');
    return _SqfliteReadOnlySourceDatabase(database);
  }
}

final class _SqfliteReadOnlySourceDatabase implements ReadOnlySourceDatabase {
  _SqfliteReadOnlySourceDatabase(this._database);

  static const int _guidLookupChunkSize = 500;

  final Database _database;
  Future<Set<String>>? _messageColumnNamesCache;

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    assertReadOnlySql(sql, boundary: 'Read-only source database rawQuery');
    return _database.rawQuery(sql, arguments);
  }

  @override
  Future<List<Map<String, Object?>>> query(String table, {String? orderBy}) {
    return _database.query(table, orderBy: orderBy);
  }

  @override
  Future<SourceMessageImportWindow> messageImportWindowAfter(
    int sourceRowId,
  ) async {
    final rows = await _database.rawQuery(
      'SELECT MAX(ROWID) AS high_water_source_rowid, '
      'COUNT(*) AS total_row_count '
      'FROM message WHERE ROWID > ?',
      <Object?>[sourceRowId],
    );
    final row = rows.single;
    return SourceMessageImportWindow(
      highWaterSourceRowId: row['high_water_source_rowid'] as int?,
      totalRowCount: _readInt(row, 'total_row_count'),
    );
  }

  @override
  Future<List<Map<String, Object?>>> readMessageImportPage({
    required int afterSourceRowId,
    required int throughSourceRowId,
    required int limit,
  }) async {
    if (limit <= 0) {
      throw ArgumentError.value(limit, 'limit', 'must be greater than zero');
    }
    final columnNames = await _messageColumnNames();
    final projection = <String>[
      'm.ROWID AS source_rowid',
      _nullableMessageColumn(columnNames, 'attributedBody'),
      _nullableMessageColumn(columnNames, 'date'),
      _nullableMessageColumn(columnNames, 'date_read'),
      _nullableMessageColumn(columnNames, 'date_delivered'),
      _nullableMessageColumn(columnNames, 'guid'),
      _nullableMessageColumn(columnNames, 'handle_id'),
      _nullableMessageColumn(columnNames, 'is_from_me'),
      _nullableMessageColumn(columnNames, 'text'),
      _nullableMessageColumn(columnNames, 'associated_message_guid'),
      _nullableMessageColumn(columnNames, 'item_type'),
      _nullableMessageColumn(columnNames, 'associated_message_type'),
      _nullableMessageColumn(columnNames, 'thread_originator_guid'),
      _nullableMessageColumn(columnNames, 'error'),
      _nullableMessageColumn(columnNames, 'is_system_message'),
      _messageBlobPresenceExpression(
        columnNames,
        'message_summary_info',
        alias: 'has_message_summary_info',
      ),
      _messageBlobPresenceExpression(
        columnNames,
        'payload_data',
        alias: 'has_payload_data_source',
      ),
      'EXISTS(SELECT 1 FROM chat_message_join cmj '
          'WHERE cmj.message_id = m.ROWID) AS has_chat_relationship',
    ].join(', ');
    return _database.rawQuery(
      'SELECT '
      '$projection '
      'FROM message m '
      'WHERE m.ROWID > ? AND m.ROWID <= ? '
      'ORDER BY m.ROWID ASC LIMIT ?',
      <Object?>[afterSourceRowId, throughSourceRowId, limit],
    );
  }

  @override
  Future<Set<String>> findExistingMessageGuids(Set<String> targetGuids) async {
    final targets = targetGuids.toList(growable: false);
    final matches = <String>{};

    for (var start = 0; start < targets.length; start += _guidLookupChunkSize) {
      final chunkEnd = start + _guidLookupChunkSize;
      final end = chunkEnd < targets.length ? chunkEnd : targets.length;
      final chunk = targets.sublist(start, end);
      final placeholders = List<String>.filled(chunk.length, '?').join(', ');
      final rows = await _database.rawQuery(
        'SELECT guid FROM message WHERE guid IN ($placeholders)',
        chunk.cast<Object?>(),
      );
      for (final row in rows) {
        final guid = row['guid'];
        if (guid is String && guid.isNotEmpty) {
          matches.add(guid);
        }
      }
    }

    return matches;
  }

  Future<Set<String>> _messageColumnNames() {
    return _messageColumnNamesCache ??= _readMessageColumnNames();
  }

  Future<Set<String>> _readMessageColumnNames() async {
    final rows = await _database.rawQuery('PRAGMA table_info(message)');
    return <String>{
      for (final row in rows)
        if (row['name'] case final String name) name,
    };
  }

  @override
  Future<void> close() {
    return _database.close();
  }
}

String _nullableMessageColumn(Set<String> columnNames, String columnName) {
  if (columnNames.contains(columnName)) {
    return 'm.$columnName';
  }
  return 'NULL AS $columnName';
}

String _messageBlobPresenceExpression(
  Set<String> columnNames,
  String columnName, {
  required String alias,
}) {
  if (columnNames.contains(columnName)) {
    return '(m.$columnName IS NOT NULL) AS $alias';
  }
  return '0 AS $alias';
}

int _readInt(Map<String, Object?> row, String field) {
  final value = row[field];
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  throw StateError('$field must be an integer');
}
