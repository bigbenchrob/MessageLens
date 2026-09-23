import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/archive_environment/domain.dart';
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_location_provider.dart';
import 'package:remember_this_text/features/attachments/application/cross_snapshot_mapping.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/filesystem_attachment_archive_file_store.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/overlay_attachment_archive_write_store.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/overlay_recovered_attachment_archive_writer.dart';

import '../../../../test_support/test_archive_fixture.dart';

void main() {
  late Directory tempDir;
  late Directory archiveDir;
  late OverlayDatabase overlayDatabase;
  late OverlayRecoveredAttachmentArchiveWriter writer;
  late TestArchiveFixture archiveFixture;
  late ProviderContainer providerContainer;
  late ArchiveMutationCoordinator mutationCoordinator;
  late AttachmentArchiveWritableRootLease writableRootLease;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'overlay_recovered_attachment_archive_writer_test_',
    );
    archiveFixture = await TestArchiveFixture.create(
      prefix: 'recovered_attachment_writer_authority_test_',
    );
    providerContainer = ProviderContainer(
      overrides: [
        admittedArchiveAccessAuthorityProvider.overrideWithValue(
          archiveFixture.authority,
        ),
      ],
    );
    mutationCoordinator = providerContainer.read(
      archiveMutationCoordinatorProvider.notifier,
    );
    writableRootLease = (await providerContainer.read(
      attachmentArchiveWritableRootAdmissionProvider.future,
    )).lease!;
    archiveDir = Directory(writableRootLease.archiveRootPath);
    overlayDatabase = OverlayDatabase(NativeDatabase.memory());
    writer = OverlayRecoveredAttachmentArchiveWriter(
      fileStore: const FilesystemAttachmentArchiveFileStore(),
      writeStore: OverlayAttachmentArchiveWriteStore(
        overlayDatabase: overlayDatabase,
      ),
    );
  });

  tearDown(() async {
    await overlayDatabase.close();
    providerContainer.dispose();
    await archiveFixture.dispose();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('archives mapped historical file into overlay archive', () async {
    final sourceFile = File(path.join(tempDir.path, 'historical', 'Photo.JPG'));
    await sourceFile.parent.create(recursive: true);
    await sourceFile.writeAsString('historical image');
    final sourceBytes = await sourceFile.readAsBytes();
    final expectedHash = sha256.convert(sourceBytes).toString();

    final size = await _archiveWithAuthority(
      writer,
      mutationCoordinator,
      writableRootLease,
      _record(
        resolvedFilePath: sourceFile.path,
        histLocalPath: '~/Historical/Messages/Attachments/Photo.JPG',
      ),
    );

    expect(size, sourceBytes.length);

    final archivedRows = await overlayDatabase
        .select(overlayDatabase.archivedAttachments)
        .get();
    expect(archivedRows, hasLength(1));
    final archivedRow = archivedRows.single;
    expect(archivedRow.messageGuid, 'current-message-guid');
    expect(archivedRow.importAttachmentId, 200);
    expect(
      archivedRow.archiveRelativePath,
      '${expectedHash.substring(0, 2)}/$expectedHash.jpg',
    );
    expect(archivedRow.fileSizeBytes, sourceBytes.length);
    expect(archivedRow.contentHash, expectedHash);
    expect(archivedRow.provenance, 'imported_historical_snapshot');
    expect(
      archivedRow.originalLocalPath,
      '~/Historical/Messages/Attachments/Photo.JPG',
    );
    expect(
      File(
        path.join(archiveDir.path, archivedRow.archiveRelativePath),
      ).readAsBytesSync(),
      sourceBytes,
    );
  });

  test(
    'returns null and does not rewrite when archive row already exists',
    () async {
      final sourceFile = File(
        path.join(tempDir.path, 'historical', 'photo.jpg'),
      );
      await sourceFile.parent.create(recursive: true);
      await sourceFile.writeAsString('historical image');
      await overlayDatabase.customStatement(
        '''
      INSERT INTO archived_attachments (
        message_guid,
        import_attachment_id,
        archive_relative_path,
        archived_at_utc,
        file_size_bytes,
        content_hash,
        provenance
      ) VALUES (?, ?, ?, ?, ?, ?, ?)
      ''',
        <Object?>[
          'current-message-guid',
          200,
          'aa/existing.jpg',
          '2026-06-19T10:00:00.000Z',
          5,
          'existing-hash',
          'archived',
        ],
      );

      final size = await _archiveWithAuthority(
        writer,
        mutationCoordinator,
        writableRootLease,
        _record(resolvedFilePath: sourceFile.path),
      );

      expect(size, isNull);
      final archivedRows = await overlayDatabase
          .select(overlayDatabase.archivedAttachments)
          .get();
      expect(archivedRows, hasLength(1));
      expect(archivedRows.single.archiveRelativePath, 'aa/existing.jpg');
    },
  );

  test('rejects symlinked archive directory', () async {
    await overlayDatabase.close();
    if (archiveDir.existsSync()) {
      await archiveDir.delete(recursive: true);
    }
    final outsideArchive = Directory(path.join(tempDir.path, 'outside_archive'))
      ..createSync();
    final archiveLink = Link(archiveDir.path);
    await archiveLink.create(outsideArchive.path);
    overlayDatabase = OverlayDatabase(NativeDatabase.memory());
    writer = OverlayRecoveredAttachmentArchiveWriter(
      fileStore: const FilesystemAttachmentArchiveFileStore(),
      writeStore: OverlayAttachmentArchiveWriteStore(
        overlayDatabase: overlayDatabase,
      ),
    );
    final sourceFile = File(path.join(tempDir.path, 'historical', 'photo.jpg'));
    await sourceFile.parent.create(recursive: true);
    await sourceFile.writeAsString('historical image');

    await expectLater(
      _archiveWithAuthority(
        writer,
        mutationCoordinator,
        writableRootLease,
        _record(resolvedFilePath: sourceFile.path),
      ),
      throwsStateError,
    );
  });

  test('rejects symlinked recovered source file', () async {
    final outsideFile = File(path.join(tempDir.path, 'outside.jpg'));
    await outsideFile.writeAsString('outside image');
    final sourceLink = Link(path.join(tempDir.path, 'linked.jpg'));
    await sourceLink.create(outsideFile.path);

    await expectLater(
      _archiveWithAuthority(
        writer,
        mutationCoordinator,
        writableRootLease,
        _record(resolvedFilePath: sourceLink.path),
      ),
      throwsStateError,
    );

    final archivedRows = await overlayDatabase
        .select(overlayDatabase.archivedAttachments)
        .get();
    expect(archivedRows, isEmpty);
  });

  test('rejects symlinked recovered archive destination', () async {
    final sourceFile = File(path.join(tempDir.path, 'historical', 'photo.jpg'));
    await sourceFile.parent.create(recursive: true);
    await sourceFile.writeAsString('historical image');
    final sourceBytes = await sourceFile.readAsBytes();
    final expectedHash = sha256.convert(sourceBytes).toString();
    final outsideFile = File(path.join(tempDir.path, 'outside.jpg'));
    await outsideFile.writeAsString('outside');
    final destinationParent = Directory(
      path.join(archiveDir.path, expectedHash.substring(0, 2)),
    );
    await destinationParent.create(recursive: true);
    final destinationLink = Link(
      path.join(destinationParent.path, '$expectedHash.jpg'),
    );
    await destinationLink.create(outsideFile.path);

    await expectLater(
      _archiveWithAuthority(
        writer,
        mutationCoordinator,
        writableRootLease,
        _record(resolvedFilePath: sourceFile.path),
      ),
      throwsStateError,
    );

    expect(outsideFile.readAsStringSync(), 'outside');
    final archivedRows = await overlayDatabase
        .select(overlayDatabase.archivedAttachments)
        .get();
    expect(archivedRows, isEmpty);
  });
}

Future<int?> _archiveWithAuthority(
  OverlayRecoveredAttachmentArchiveWriter writer,
  ArchiveMutationCoordinator mutationCoordinator,
  AttachmentArchiveWritableRootLease writableRootLease,
  MappedAttachmentRecord record,
) {
  return mutationCoordinator.runWithCapability<int?>(
    operation: ArchiveMutationOperation.automaticRecovery,
    ownerLabel: 'recovered-attachment-writer-test',
    action: (mutationCapability) => writer.archive(
      record: record,
      writableRootLease: writableRootLease,
      mutationCapability: mutationCapability,
    ),
  );
}

MappedAttachmentRecord _record({
  required String resolvedFilePath,
  String? histLocalPath,
}) {
  return MappedAttachmentRecord(
    histMessageGuid: 'historical-message-guid',
    currentMessageGuid: 'current-message-guid',
    currentAttachmentSourceRowId: 200,
    resolvedFilePath: resolvedFilePath,
    matchMethod: MatchMethod.guidMatch,
    histAttachmentGuid: 'historical-attachment-guid',
    histLocalPath: histLocalPath,
    currentMessageSsId: 100,
    currentAttachmentSsId: 200,
  );
}
