import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/app_czar/application/app_czar_observation_reader.dart';
import 'package:remember_this_text/essentials/app_czar/domain/app_czar_models.dart';
import 'package:remember_this_text/essentials/app_czar/infrastructure/sqlite_app_czar_observation_reader.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('missing stores are observed without being created', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'app_czar_read_only_test_',
    );
    addTearDown(() => tempDirectory.delete(recursive: true));
    final sourcePath = path.join(tempDirectory.path, 'missing_chat.db');
    final reader = SqliteAppCzarObservationReader(
      archiveRootPath: tempDirectory.path,
      messagesDatabasePath: sourcePath,
      attachmentArchiveProbe: const _ArchiveProbe(),
    );

    final importStore = await reader.readImportStore();
    final graphStore = await reader.readGraphStore();
    final overlay = await reader.readOverlay();
    final source = await reader.readSource();

    expect(importStore.condition, AppCzarDatabaseCondition.absent);
    expect(graphStore.condition, AppCzarDatabaseCondition.absent);
    expect(overlay.condition, AppCzarDatabaseCondition.absent);
    expect(source.condition, AppCzarSourceCondition.unavailable);
    expect(File(sourcePath).existsSync(), isFalse);
    expect(
      tempDirectory.listSync(followLinks: false),
      isEmpty,
      reason: 'Read-only AppCzar inspection must not create a database.',
    );
  });

  test(
    'source evidence counts every message record without filtering',
    () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'app_czar_source_fidelity_test_',
      );
      addTearDown(() => tempDirectory.delete(recursive: true));
      final sourcePath = path.join(tempDirectory.path, 'chat.db');
      final database = sqlite3.open(sourcePath);
      database.execute('CREATE TABLE message (guid TEXT)');
      database.execute('INSERT INTO message (guid) VALUES (?), (?)', <Object?>[
        'message-guid',
        null,
      ]);
      database.dispose();
      final reader = SqliteAppCzarObservationReader(
        archiveRootPath: tempDirectory.path,
        messagesDatabasePath: sourcePath,
        attachmentArchiveProbe: const _ArchiveProbe(),
      );

      final source = await reader.readSource();

      expect(source.condition, AppCzarSourceCondition.readable);
      expect(source.messageCount, 2);
      expect(source.maxRowId, 2);
      expect(source.sampleStable, isTrue);
    },
  );
}

final class _ArchiveProbe implements AppCzarAttachmentArchiveProbe {
  const _ArchiveProbe();

  @override
  Future<AppCzarArchiveObservation> readCurrent() async {
    return const AppCzarArchiveObservation(
      condition: AppCzarArchiveCondition.notCreated,
      label: 'Default attachment archive',
    );
  }
}
