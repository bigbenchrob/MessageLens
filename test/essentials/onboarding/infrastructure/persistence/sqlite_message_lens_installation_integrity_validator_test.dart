import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/app_database_files.dart';
import 'package:remember_this_text/essentials/onboarding/domain/startup_installation_validation.dart';
import 'package:remember_this_text/essentials/onboarding/infrastructure/persistence/sqlite_message_lens_installation_integrity_validator.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('validates only the explicitly requested database', () async {
    final root = Directory.systemTemp.createTempSync(
      'messagelens-integrity-target-',
    );
    addTearDown(() {
      root.deleteSync(recursive: true);
    });
    final importPath = appDatabasePath(
      AppDatabaseFile.sourceScopedImport,
      databaseDirectory: root.path,
    );
    final importDatabase = sqlite3.open(importPath);
    importDatabase.execute('CREATE TABLE messages (id INTEGER PRIMARY KEY);');
    importDatabase.dispose();
    final graphPath = appDatabasePath(
      AppDatabaseFile.conversationGraph,
      databaseDirectory: root.path,
    );
    final graphFile = File(graphPath)..writeAsStringSync('not sqlite');
    final graphBytesBefore = graphFile.readAsBytesSync();

    final result = await const SqliteMessageLensInstallationIntegrityValidator()
        .validateDatabase(
          archiveRootPath: root.path,
          database: InstallationDatabaseKey.sourceScopedImport,
        );

    expect(result.status, InstallationIntegrityValidationStatus.passed);
    expect(graphFile.readAsBytesSync(), graphBytesBefore);
    expect(File('$importPath-wal').existsSync(), isFalse);
    expect(File('$importPath-shm').existsSync(), isFalse);
    expect(File('$graphPath-wal').existsSync(), isFalse);
    expect(File('$graphPath-shm').existsSync(), isFalse);
  });

  test(
    'reports physical failure for the requested malformed database',
    () async {
      final root = Directory.systemTemp.createTempSync(
        'messagelens-integrity-malformed-',
      );
      addTearDown(() {
        root.deleteSync(recursive: true);
      });
      File(
        appDatabasePath(
          AppDatabaseFile.conversationGraph,
          databaseDirectory: root.path,
        ),
      ).writeAsStringSync('not sqlite');

      final result =
          await const SqliteMessageLensInstallationIntegrityValidator()
              .validateDatabase(
                archiveRootPath: root.path,
                database: InstallationDatabaseKey.conversationGraph,
              );

      expect(result.status, InstallationIntegrityValidationStatus.failed);
      expect(result.failure, isNotEmpty);
    },
  );
}
