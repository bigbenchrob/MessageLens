import 'package:drift/drift.dart';
import 'package:sqflite/sqflite.dart' show DatabaseException;

import '../../../db/infrastructure/data_sources/local/import/sqflite_import_database.dart';
import '../../../db/infrastructure/data_sources/local/working/working_database.dart';
import '../../domain/failures/migration_exception.dart';

class CanonicalHandleInfo {
  const CanonicalHandleInfo({required this.compound, required this.display});

  final String compound;
  final String display;
}

/// Common context shared by all migrators.
class MigrationContext {
  final SqfliteImportDatabase importDb;
  final WorkingDatabase workingDb;
  final bool dryRun;
  final bool incrementalMode;
  final void Function(String msg) log;
  final Map<int, int> handleIdCanonicalMap;
  final Map<int, CanonicalHandleInfo> canonicalHandleInfo;
  MigrationContext({
    required this.importDb,
    required this.workingDb,
    this.dryRun = false,
    this.incrementalMode = false,
    required this.log,
    Map<int, int>? handleIdCanonicalMap,
    Map<int, CanonicalHandleInfo>? canonicalHandleInfo,
  }) : handleIdCanonicalMap = handleIdCanonicalMap ?? <int, int>{},
       canonicalHandleInfo =
           canonicalHandleInfo ?? <int, CanonicalHandleInfo>{};

  Future<void> ensureImportReady(String stageLabel) async {
    await _clearLingeringImportAttachments(stageLabel);
    await _verifyImportAttachable(stageLabel);
  }

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
