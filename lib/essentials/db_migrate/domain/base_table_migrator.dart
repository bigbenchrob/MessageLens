// ignore_for_file: avoid_positional_boolean_parameters

import 'package:sqflite/sqflite.dart';

import '../../db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import '../../db/infrastructure/data_sources/local/working/working_database.dart';
import 'failures/migration_exception.dart';
import 'i_migrators.dart/table_migrator.dart';
import 'ports/migration_context.dart';

/// A small base that gives you handy helpers.
abstract class BaseTableMigrator implements TableMigrator {
  const BaseTableMigrator();

  /// Default display label derived from [name]. Override when needed.
  String get displayName => _humanizeName(name);

  /// Tables that should be truncated before this migrator executes.
  ///
  /// By default this is just `[name]`, but complex migrators can override.
  List<String> get targetTables => <String>[name];

  @override
  Future<void> validatePrereqs(IMigrationContext ctx);

  @override
  Future<void> copy(IMigrationContext ctx);

  @override
  Future<void> postValidate(IMigrationContext ctx);

  Future<int> count(Object database, String table) async {
    final safeTable = table.replaceAll('"', '""');
    final sql = 'SELECT COUNT(*) AS c FROM "$safeTable"';

    Object? value;
    if (database is WorkingDatabase) {
      final rows = await database.customSelect(sql).get();
      value = rows.isEmpty ? null : rows.first.data['c'];
    } else if (database is SqfliteImportDatabase) {
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

  Future<void> expectZeroOrThrow(
    int n,
    String errorCode,
    String message,
  ) async {
    if (n != 0) {
      throw MigrationException(code: errorCode, message: message);
    }
  }

  Future<void> expectTrueOrThrow({
    required bool ok,
    required String errorCode,
    required String message,
  }) async {
    if (!ok) {
      throw MigrationException(code: errorCode, message: message);
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
