import 'package:drift/drift.dart';
import 'package:sqflite/sqflite.dart' show DatabaseException;

import '../../../db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import '../../../db/infrastructure/data_sources/local/working/working_database.dart';
import '../../domain/failures/migration_exception.dart';
import '../../domain/ports/migration_context.dart';
import '../../domain/value_objects/canonical_handle_info.dart';

export '../../domain/ports/migration_context.dart';
export '../../domain/value_objects/canonical_handle_info.dart';

/// SQLite implementation of [IMigrationContext].
class MigrationContextSqlite implements IMigrationContext {
  @override
  final SqfliteImportDatabase importDb;

  @override
  final WorkingDatabase workingDb;

  @override
  final bool dryRun;

  @override
  final bool incrementalMode;

  final void Function(String msg) _log;

  @override
  final Map<int, int> handleIdCanonicalMap;

  @override
  final Map<int, CanonicalHandleInfo> canonicalHandleInfo;

  MigrationContextSqlite({
    required this.importDb,
    required this.workingDb,
    this.dryRun = false,
    this.incrementalMode = false,
    required void Function(String msg) log,
    Map<int, int>? handleIdCanonicalMap,
    Map<int, CanonicalHandleInfo>? canonicalHandleInfo,
  }) : _log = log,
       handleIdCanonicalMap = handleIdCanonicalMap ?? <int, int>{},
       canonicalHandleInfo =
           canonicalHandleInfo ?? <int, CanonicalHandleInfo>{};

  @override
  void log(String message) => _log(message);

  @override
  Future<void> ensureImportReady(String stageLabel) async {
    await _clearLingeringImportAttachments(stageLabel);
    await _verifyImportAttachable(stageLabel);
  }

  @override
  Future<void> ensureImportClean(String stageLabel) async {
    await _clearLingeringImportAttachments(stageLabel);
    await _verifyImportAttachable(stageLabel);
  }

  Future<void> _clearLingeringImportAttachments(String stageLabel) async {
    final rows = await workingDb.customSelect('PRAGMA database_list').get();
    final attachments = <String>[];
    for (final row in rows.cast<QueryRow>()) {
      final data = row.data;
      final name = data['name'] as String?;
      if (name == null) {
        continue;
      }
      if (name == 'main' || name == 'temp') {
        continue;
      }
      if (!name.startsWith('import_')) {
        continue;
      }
      attachments.add(name);
    }

    if (attachments.isEmpty) {
      return;
    }

    for (final alias in attachments) {
      try {
        await workingDb.customStatement('DETACH DATABASE $alias');
      } catch (error) {
        throw MigrationException(
          code: 'IMPORT_DB_LOCKED',
          message:
              '$stageLabel: failed to detach attached import database "$alias" ($error)',
        );
      }
    }
  }

  Future<void> _verifyImportAttachable(String stageLabel) async {
    final importSqlite = await importDb.database;
    try {
      final probe = await importSqlite.rawQuery('SELECT 1');
      if (probe.isEmpty) {
        throw MigrationException(
          code: 'IMPORT_DB_LOCKED',
          message: '$stageLabel: import database probe query returned no rows',
        );
      }
    } on DatabaseException catch (error) {
      throw MigrationException(
        code: 'IMPORT_DB_LOCKED',
        message: '$stageLabel: import database is not accessible ($error)',
      );
    }

    final escapedPath = importSqlite.path.replaceAll("'", "''");
    const preflightAlias = 'import_preflight';
    var attached = false;
    MigrationException? pendingError;
    try {
      await workingDb.customStatement(
        "ATTACH DATABASE '$escapedPath' AS $preflightAlias",
      );
      attached = true;
      final verification = await workingDb
          .customSelect(
            'SELECT 1 AS ok FROM $preflightAlias.sqlite_master LIMIT 1',
          )
          .get();
      if (verification.isEmpty) {
        pendingError = MigrationException(
          code: 'IMPORT_DB_LOCKED',
          message: '$stageLabel: attached import database returned no metadata',
        );
      }
    } catch (error) {
      pendingError = MigrationException(
        code: 'IMPORT_DB_LOCKED',
        message:
            '$stageLabel: failed to attach import database for verification ($error)',
      );
    } finally {
      if (attached) {
        try {
          await workingDb.customStatement('DETACH DATABASE $preflightAlias');
        } catch (error) {
          throw MigrationException(
            code: 'IMPORT_DB_LOCKED',
            message:
                '$stageLabel: failed to detach import database after verification ($error)',
          );
        }
      }
    }

    if (pendingError != null) {
      throw pendingError;
    }
  }
}
