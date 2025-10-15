import 'package:sqflite/sqflite.dart';

import '../../../db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import '../../domain/i_importers.dart/table_importer.dart';
import '../../infrastructure/sqlite/import_context_sqlite.dart';

/// Convenience base class mirroring the migration pipeline helpers.
abstract class BaseTableImporter implements TableImporter {
  const BaseTableImporter();

  /// Defaults to a human-friendly version of [name]. Override when needed.
  String get displayName => _humanizeName(name);

  /// Tables that should be considered owned by this importer.
  /// Useful when truncating or validating row counts.
  List<String> get targetTables => <String>[name];

  @override
  Future<void> validatePrereqs(ImportContext ctx);

  @override
  Future<void> copy(ImportContext ctx);

  @override
  Future<void> postValidate(ImportContext ctx);

  Future<int> count(Object database, String table) async {
    final safeTable = table.replaceAll('"', '""');
    final sql = 'SELECT COUNT(*) AS c FROM "$safeTable"';

    Object? value;
    if (database is SqfliteImportDatabase) {
      final sqfliteDb = await database.database;
      final rows = await sqfliteDb.rawQuery(sql);
      value = rows.isEmpty ? null : rows.first['c'];
    } else if (database is Database) {
      final rows = await database.rawQuery(sql);
      value = rows.isEmpty ? null : rows.first['c'];
    } else {
      throw ArgumentError(
        'Unsupported database type for count(): ${database.runtimeType}',
      );
    }

    if (value == null) {
      return 0;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is BigInt) {
      return value.toInt();
    }
    return int.parse(value.toString());
  }

  Future<void> expectZeroOrThrow(int n, String errorCode, String message) {
    if (n != 0) {
      throw ImportException(code: errorCode, message: message);
    }
    return Future<void>.value();
  }

  Future<void> expectTrueOrThrow({
    required bool ok,
    required String errorCode,
    required String message,
  }) async {
    if (!ok) {
      throw ImportException(code: errorCode, message: message);
    }
  }
}

String _humanizeName(String raw) {
  if (raw.isEmpty) {
    return raw;
  }
  return raw
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .join(' ');
}

/// Lightweight exception used to signal importer failures with context.
class ImportException implements Exception {
  ImportException({required this.code, required this.message});

  final String code;
  final String message;

  @override
  String toString() => 'ImportException($code, $message)';
}
