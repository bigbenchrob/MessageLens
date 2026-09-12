import 'dart:io';
import 'dart:isolate';

import 'package:sqlite3/sqlite3.dart';

import '../../../db/app_database_files.dart';
import '../../../db/application/read_only_sql_guard.dart';
import '../../application/message_lens_installation_integrity_validator.dart';
import '../../domain/startup_installation_validation.dart';

final class SqliteMessageLensInstallationIntegrityValidator
    implements MessageLensInstallationIntegrityValidator {
  const SqliteMessageLensInstallationIntegrityValidator();

  @override
  Future<InstallationDatabaseIntegrityValidation> validateDatabase({
    required String archiveRootPath,
    required InstallationDatabaseKey database,
  }) {
    return Isolate.run(
      () => _validateSynchronously(
        archiveRootPath: archiveRootPath,
        databaseKey: database,
      ),
    );
  }

  InstallationDatabaseIntegrityValidation _validateSynchronously({
    required String archiveRootPath,
    required InstallationDatabaseKey databaseKey,
  }) {
    final databasePath = appDatabasePath(
      _databaseFile(databaseKey),
      databaseDirectory: archiveRootPath,
    );
    final file = File(databasePath);
    if (!file.existsSync() || file.lengthSync() == 0) {
      return InstallationDatabaseIntegrityValidation(
        database: databaseKey,
        status: InstallationIntegrityValidationStatus.failed,
        failure: 'The database file is absent or empty.',
        failureKind: InstallationIntegrityValidationFailureKind.missingOrEmpty,
      );
    }

    try {
      final database = sqlite3.open(databasePath, mode: OpenMode.readOnly);
      try {
        database.execute('PRAGMA query_only = ON;');
        database.execute('PRAGMA busy_timeout = 3000;');
        const sql = 'PRAGMA quick_check(1)';
        assertReadOnlySql(
          sql,
          boundary: 'Escalated installation integrity validation',
        );
        final rows = database.select(sql);
        final passed =
            rows.length == 1 && rows.single.values.singleOrNull == 'ok';
        return InstallationDatabaseIntegrityValidation(
          database: databaseKey,
          status: passed
              ? InstallationIntegrityValidationStatus.passed
              : InstallationIntegrityValidationStatus.failed,
          failure: passed
              ? null
              : rows.map((row) => row.values.join(', ')).join('; '),
          failureKind: passed
              ? null
              : InstallationIntegrityValidationFailureKind.integrityFailure,
        );
      } finally {
        database.dispose();
      }
    } on SqliteException catch (error) {
      final contention =
          error.resultCode == SqlError.SQLITE_BUSY ||
          error.resultCode == SqlError.SQLITE_LOCKED;
      return InstallationDatabaseIntegrityValidation(
        database: databaseKey,
        status: contention
            ? InstallationIntegrityValidationStatus.contention
            : InstallationIntegrityValidationStatus.failed,
        failure: '$error',
        failureKind: contention
            ? null
            : switch (error.resultCode) {
                SqlError.SQLITE_IOERR || SqlError.SQLITE_CANTOPEN =>
                  InstallationIntegrityValidationFailureKind.ioFailure,
                _ => InstallationIntegrityValidationFailureKind.sqliteFailure,
              },
        sqliteResultCode: error.resultCode,
      );
    } on Object catch (error) {
      return InstallationDatabaseIntegrityValidation(
        database: databaseKey,
        status: InstallationIntegrityValidationStatus.failed,
        failure: '$error',
        failureKind:
            InstallationIntegrityValidationFailureKind.unexpectedFailure,
      );
    }
  }

  AppDatabaseFile _databaseFile(InstallationDatabaseKey database) {
    return switch (database) {
      InstallationDatabaseKey.sourceScopedImport =>
        AppDatabaseFile.sourceScopedImport,
      InstallationDatabaseKey.conversationGraph =>
        AppDatabaseFile.conversationGraph,
      InstallationDatabaseKey.overlay => AppDatabaseFile.overlay,
      InstallationDatabaseKey.presence => AppDatabaseFile.presence,
    };
  }
}
