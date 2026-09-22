import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/app_database_files.dart';
import 'package:remember_this_text/essentials/db/app_database_schema_versions.dart';

void main() {
  group('app database files', () {
    test('centralizes active and retired database filenames', () {
      final activeDatabaseFiles = <AppDatabaseFile>{
        AppDatabaseFile.sourceScopedImport,
        AppDatabaseFile.conversationGraph,
        AppDatabaseFile.overlay,
        AppDatabaseFile.presence,
      };
      final retiredCleanupFiles = <AppDatabaseFile>{
        AppDatabaseFile.retiredMacosImport,
        AppDatabaseFile.retiredWorking,
      };

      expect(
        activeDatabaseFiles.intersection(retiredCleanupFiles),
        isEmpty,
        reason:
            'Retired cleanup files must remain distinct from active app '
            'databases.',
      );
      expect(
        appDatabaseFileNames(activeDatabaseFiles).toSet(),
        equals(<String>{
          'macos_import_ss.db',
          'working_ss.db',
          'user_overlays.db',
          'presence.db',
        }),
      );
      expect(
        appDatabaseFileNames(retiredCleanupFiles).toSet(),
        equals(<String>{'macos_import.db', 'working.db'}),
      );
    });

    test('constructs physical paths through the central helper', () {
      expect(
        appDatabasePath(
          AppDatabaseFile.conversationGraph,
          databaseDirectory: '/tmp/messagelens',
        ),
        equals('/tmp/messagelens/working_ss.db'),
      );
      expect(
        appDatabasePath(
          AppDatabaseFile.retiredWorking,
          databaseDirectory: '/tmp/messagelens',
        ),
        equals('/tmp/messagelens/working.db'),
      );
    });

    test('centralizes every active expected schema version', () {
      expect(sourceScopedImportSchemaVersion, 10);
      expect(conversationGraphSchemaVersion, 3);
      expect(overlaySchemaVersion, 8);
      expect(presenceSchemaVersion, 9);
    });
  });
}
