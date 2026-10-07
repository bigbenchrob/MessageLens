import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/onboarding/infrastructure/persistence/filesystem_derived_message_data_file_store.dart';

void main() {
  group('FilesystemDerivedMessageDataFileStore', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'filesystem_derived_message_data_file_store_test',
      );
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('deletes rebuildable database files while preserving archive payloads '
        'and durable stores', () async {
      final store = FilesystemDerivedMessageDataFileStore(
        databaseDirectory: tempDir.path,
      );

      const rebuildableBaseNames = <String>[
        'macos_import_ss.db',
        'working_ss.db',
        'macos_import.db',
        'working.db',
      ];
      final rebuildableFiles = <File>[
        for (final baseName in rebuildableBaseNames)
          for (final suffix in const <String>['', '-wal', '-shm'])
            File(path.join(tempDir.path, '$baseName$suffix')),
      ];
      for (final file in rebuildableFiles) {
        await file.writeAsString('rebuildable:${path.basename(file.path)}');
      }

      final archiveDir = Directory(
        path.join(tempDir.path, 'attachment_archive'),
      );
      final archivedPayload = File(
        path.join(archiveDir.path, 'a1', 'a1-preserved-payload.jpg'),
      );
      await archivedPayload.parent.create(recursive: true);
      const archivedPayloadContents = <int>[0, 1, 2, 127, 128, 254, 255];
      await archivedPayload.writeAsBytes(archivedPayloadContents, flush: true);

      final overlayFile = File(path.join(tempDir.path, 'user_overlays.db'));
      final presenceFile = File(path.join(tempDir.path, 'presence.db'));
      final preferencesFile = File(
        path.join(tempDir.path, 'preferences-preserved.json'),
      );
      await overlayFile.writeAsString('overlay-preserved');
      await presenceFile.writeAsString('presence-preserved');
      await preferencesFile.writeAsString('preferences-preserved');

      final deleted = await store.deleteDatabaseBaseFiles(rebuildableBaseNames);

      expect(deleted.toSet(), {for (final file in rebuildableFiles) file.path});
      for (final file in rebuildableFiles) {
        expect(file.existsSync(), isFalse, reason: file.path);
      }
      expect(archiveDir.existsSync(), isTrue);
      expect(archivedPayload.existsSync(), isTrue);
      expect(await archivedPayload.readAsBytes(), archivedPayloadContents);
      expect(await overlayFile.readAsString(), 'overlay-preserved');
      expect(await presenceFile.readAsString(), 'presence-preserved');
      expect(await preferencesFile.readAsString(), 'preferences-preserved');
    });

    test('rejects path-like database base names', () async {
      final store = FilesystemDerivedMessageDataFileStore(
        databaseDirectory: tempDir.path,
      );

      expect(
        () => store.databaseBaseFileExists('../attachment_archive'),
        throwsArgumentError,
      );
      await expectLater(
        store.deleteDatabaseBaseFiles(['../attachment_archive']),
        throwsArgumentError,
      );
      await expectLater(
        store.deleteDatabaseBaseFiles(['/tmp/working_ss.db']),
        throwsArgumentError,
      );
      await expectLater(
        store.deleteDatabaseBaseFiles([r'..\working_ss.db']),
        throwsArgumentError,
      );
    });

    test(
      'local repair postcondition proves the exact active footprint',
      () async {
        final store = FilesystemDerivedMessageDataFileStore(
          databaseDirectory: tempDir.path,
        );
        const active = <String>['macos_import_ss.db', 'working_ss.db'];
        for (final baseName in active) {
          for (final suffix in const <String>['', '-wal', '-shm']) {
            await File(
              path.join(tempDir.path, '$baseName$suffix'),
            ).writeAsString('derived:$baseName$suffix');
          }
        }
        final overlay = File(path.join(tempDir.path, 'user_overlays.db'));
        final presence = File(path.join(tempDir.path, 'presence.db'));
        final marker = File(
          path.join(tempDir.path, '.messagelens-archive.json'),
        );
        final retired = File(path.join(tempDir.path, 'macos_import.db'));
        final configuration = File(
          path.join(tempDir.path, 'attachment-location-settings.json'),
        );
        final sentinel = File(path.join(tempDir.path, 'unrelated.txt'));
        final archivePayload = File(
          path.join(tempDir.path, 'attachment_archive', 'ab', 'payload.bin'),
        );
        await overlay.writeAsString('overlay');
        await presence.writeAsString('presence');
        await marker.writeAsString('marker');
        await retired.writeAsString('retired-preserved');
        await configuration.writeAsString('configuration');
        await sentinel.writeAsString('sentinel');
        await archivePayload.parent.create(recursive: true);
        await archivePayload.writeAsBytes(<int>[0, 1, 2, 255]);

        final before = await store.captureLocalDataRepairSnapshot(active);
        await store.deleteDatabaseBaseFiles(active);
        await store.requireLocalDataRepairPostcondition(
          before: before,
          resetBaseNames: active,
        );

        expect(await overlay.readAsString(), 'overlay');
        expect(await presence.readAsString(), 'presence');
        expect(await marker.readAsString(), 'marker');
        expect(await retired.readAsString(), 'retired-preserved');
        expect(await configuration.readAsString(), 'configuration');
        expect(await sentinel.readAsString(), 'sentinel');
        expect(await archivePayload.readAsBytes(), <int>[0, 1, 2, 255]);
        for (final baseName in active) {
          for (final suffix in const <String>['', '-wal', '-shm']) {
            expect(
              File(path.join(tempDir.path, '$baseName$suffix')).existsSync(),
              isFalse,
            );
          }
        }
      },
    );

    test('local repair postcondition rejects a surviving target', () async {
      final store = FilesystemDerivedMessageDataFileStore(
        databaseDirectory: tempDir.path,
      );
      const active = <String>['working_ss.db'];
      await File(path.join(tempDir.path, 'working_ss.db')).writeAsString('x');
      final before = await store.captureLocalDataRepairSnapshot(active);

      await expectLater(
        store.requireLocalDataRepairPostcondition(
          before: before,
          resetBaseNames: active,
        ),
        throwsStateError,
      );
    });

    test('local repair postcondition rejects collateral changes', () async {
      final store = FilesystemDerivedMessageDataFileStore(
        databaseDirectory: tempDir.path,
      );
      const active = <String>['working_ss.db'];
      await File(path.join(tempDir.path, 'working_ss.db')).writeAsString('x');
      final overlay = File(path.join(tempDir.path, 'user_overlays.db'));
      await overlay.writeAsString('before');
      final before = await store.captureLocalDataRepairSnapshot(active);
      await store.deleteDatabaseBaseFiles(active);
      await overlay.writeAsString('after');

      await expectLater(
        store.requireLocalDataRepairPostcondition(
          before: before,
          resetBaseNames: active,
        ),
        throwsStateError,
      );
    });

    test(
      'local repair postcondition detects same-size preserved changes',
      () async {
        final store = FilesystemDerivedMessageDataFileStore(
          databaseDirectory: tempDir.path,
        );
        const active = <String>['working_ss.db'];
        await File(path.join(tempDir.path, 'working_ss.db')).writeAsString('x');
        final overlay = File(path.join(tempDir.path, 'user_overlays.db'));
        await overlay.writeAsString('before');
        final before = await store.captureLocalDataRepairSnapshot(active);
        await store.deleteDatabaseBaseFiles(active);
        await overlay.writeAsString('after!');

        await expectLater(
          store.requireLocalDataRepairPostcondition(
            before: before,
            resetBaseNames: active,
          ),
          throwsStateError,
        );
      },
    );

    test('leaves external source and donor fingerprints unchanged', () async {
      final externalSources = await Directory.systemTemp.createTemp(
        'start_fresh_external_sources_test',
      );
      addTearDown(() async {
        if (externalSources.existsSync()) {
          await externalSources.delete(recursive: true);
        }
      });
      final sourceFiles = <File>[
        File(path.join(externalSources.path, 'chat.db')),
        File(path.join(externalSources.path, 'AddressBook-v22.abcddb')),
        File(path.join(externalSources.path, 'historical-donor-chat.db')),
      ];
      for (var index = 0; index < sourceFiles.length; index += 1) {
        await sourceFiles[index].writeAsBytes(<int>[index, 17, 93, 201, 255]);
      }
      final fingerprintsBefore = <String, String>{
        for (final file in sourceFiles)
          file.path: sha256.convert(await file.readAsBytes()).toString(),
      };
      final rebuildable = File(path.join(tempDir.path, 'working_ss.db'));
      await rebuildable.writeAsString('discard me');
      final store = FilesystemDerivedMessageDataFileStore(
        databaseDirectory: tempDir.path,
      );

      await store.deleteDatabaseBaseFiles(const <String>['working_ss.db']);

      expect(rebuildable.existsSync(), isFalse);
      for (final file in sourceFiles) {
        expect(file.existsSync(), isTrue);
        expect(
          sha256.convert(await file.readAsBytes()).toString(),
          fingerprintsBefore[file.path],
        );
      }
    });

    test(
      'ignores symlinked database base files during reset cleanup',
      () async {
        final store = FilesystemDerivedMessageDataFileStore(
          databaseDirectory: tempDir.path,
        );
        final outsideFile = File(path.join(tempDir.path, 'outside.db'));
        await outsideFile.writeAsString('do not delete');
        final dbLink = Link(path.join(tempDir.path, 'working_ss.db'));
        await dbLink.create(outsideFile.path);

        expect(store.databaseBaseFileExists('working_ss.db'), isFalse);

        final deleted = await store.deleteDatabaseBaseFiles(['working_ss.db']);

        expect(deleted, isEmpty);
        expect(dbLink.existsSync(), isTrue);
        expect(await outsideFile.readAsString(), 'do not delete');
      },
    );
  });
}
