// ignore_for_file: avoid_positional_boolean_parameters

import 'package:sqflite/sqflite.dart';

import '../../../db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import '../../../db/infrastructure/data_sources/local/working/working_database.dart';
import '../../domain/failures/migration_exception.dart';
import '../../infrastructure/sqlite/migration_context_sqlite.dart';

/// A small base that gives you handy helpers.
abstract class BaseTableMigrator {
  const BaseTableMigrator();

  String get name;
  List<String> get dependsOn;

  Future<void> validatePrereqs(MigrationContext ctx);
  Future<void> copy(MigrationContext ctx);
  Future<void> postValidate(MigrationContext ctx);

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

  Future<void> expectTrueOrThrow(
    bool ok,
    String errorCode,
    String message,
  ) async {
    if (!ok) {
      throw MigrationException(code: errorCode, message: message);
    }
  }
}
