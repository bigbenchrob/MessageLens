import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/app_czar/domain/app_czar_models.dart';
import 'package:remember_this_text/essentials/archive_environment/domain.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_bookmark_adapter.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_location_controller.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_configuration.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/read_only_app_czar_attachment_archive_probe.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('custom archive observation leaves overlay bytes unchanged', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'app_czar_archive_probe_',
    );
    addTearDown(() => tempDirectory.delete(recursive: true));
    final overlayPath = path.join(tempDirectory.path, 'user_overlays.db');
    final database = sqlite3.open(overlayPath);
    database.execute(
      'CREATE TABLE overlay_settings (key TEXT PRIMARY KEY, value TEXT NOT NULL)',
    );
    final configuration = AttachmentArchiveLocationConfiguration.customExternal(
      bookmarkDataBase64: 'AQID',
      lastKnownPath: '/Volumes/OldName/archive',
      volumeName: 'OldName',
      customWritePolicy: AttachmentArchiveCustomWritePolicy.activeArchive,
    );
    database.execute(
      'INSERT INTO overlay_settings (key, value) VALUES (?, ?)',
      <Object?>[
        attachmentArchiveLocationSettingKey,
        configuration.toPersistedValue(),
      ],
    );
    database.dispose();
    final before = File(overlayPath).readAsBytesSync();
    final entriesBefore = tempDirectory
        .listSync(followLinks: false)
        .map((entry) => path.basename(entry.path))
        .toList(growable: false);

    final probe = ReadOnlyAppCzarAttachmentArchiveProbe(
      archiveAccessAuthority: _authority(tempDirectory.path),
      bookmarkAdapter: const _BookmarkAdapter(),
    );
    final observation = await probe.readCurrent();

    expect(observation.condition, AppCzarArchiveCondition.available);
    expect(observation.label, 'Toshiba');
    expect(observation.resolvedPath, '/Volumes/Toshiba/archive');
    expect(File(overlayPath).readAsBytesSync(), orderedEquals(before));
    expect(
      tempDirectory
          .listSync(followLinks: false)
          .map((entry) => path.basename(entry.path)),
      orderedEquals(entriesBefore),
    );
  });
}

ArchiveAccessAuthority _authority(String rootPath) {
  return ArchiveAccessAuthority(
    identity: ResolvedArchiveIdentity(
      environment: ArchiveEnvironment.test,
      buildIdentity: ArchiveBuildIdentity.testHarness,
      archiveInstanceId: ArchiveInstanceId(
        'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
      ),
      canonicalRootPath: rootPath,
      bundleIdentifier: 'com.example.MessageLens.tests',
      productName: 'MessageLens Tests',
    ),
  );
}

final class _BookmarkAdapter implements AttachmentArchiveBookmarkAdapter {
  const _BookmarkAdapter();

  @override
  Future<AttachmentArchiveBookmarkCreation> createBookmark({
    required String directoryPath,
  }) {
    throw UnsupportedError('AppCzar cannot create bookmarks.');
  }

  @override
  Stream<AttachmentArchiveLocationEvent> get locationEvents =>
      const Stream<AttachmentArchiveLocationEvent>.empty();

  @override
  Future<AttachmentArchiveBookmarkResolution> resolveBookmark({
    required String bookmarkDataBase64,
  }) async {
    expect(bookmarkDataBase64, 'AQID');
    return const AttachmentArchiveBookmarkResolution(
      status: AttachmentArchiveBookmarkResolutionStatus.available,
      resolvedPath: '/Volumes/Toshiba/archive',
      refreshedBookmarkDataBase64: 'BAUG',
      volumeName: 'Toshiba',
    );
  }
}
