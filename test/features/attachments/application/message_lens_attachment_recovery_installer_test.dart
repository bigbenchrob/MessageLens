import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import 'package:remember_this_text/essentials/archive_environment/domain.dart';
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_location_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_write_store.dart';
import 'package:remember_this_text/features/attachments/application/message_lens_attachment_recovery_installer.dart';
import 'package:remember_this_text/features/attachments/application/verified_donor_attachment_payload.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_recovery_metadata.dart';
import 'package:remember_this_text/features/attachments/domain/entities/message_lens_attachment_recovery.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/filesystem_attachment_archive_file_store.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/overlay_attachment_archive_read_store.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/overlay_attachment_archive_write_store.dart';

import '../../../test_support/test_archive_fixture.dart';

void main() {
  late Directory temporaryRoot;
  late Directory archiveDirectory;
  late TestArchiveFixture archiveFixture;
  late ProviderContainer providerContainer;
  late ArchiveMutationCoordinator mutationCoordinator;
  late OverlayDatabase overlayDatabase;
  late FilesystemAttachmentArchiveFileStore fileStore;
  late OverlayAttachmentArchiveReadStore readStore;
  late OverlayAttachmentArchiveWriteStore writeStore;
  late AttachmentArchiveWritableRootLease writableRootLease;

  setUp(() async {
    temporaryRoot = await Directory.systemTemp.createTemp(
      'message_lens_attachment_recovery_installer_test_',
    );
    archiveFixture = await TestArchiveFixture.create(
      prefix: 'attachment_recovery_mutation_authority_test_',
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
    archiveDirectory = Directory(writableRootLease.archiveRootPath);
    overlayDatabase = OverlayDatabase(NativeDatabase.memory());
    fileStore = const FilesystemAttachmentArchiveFileStore();
    readStore = OverlayAttachmentArchiveReadStore(
      overlayDb: overlayDatabase,
      archiveDirectory: archiveDirectory.path,
    );
    writeStore = OverlayAttachmentArchiveWriteStore(
      overlayDatabase: overlayDatabase,
    );
  });

  tearDown(() async {
    providerContainer.dispose();
    await archiveFixture.dispose();
    await overlayDatabase.close();
    if (temporaryRoot.existsSync()) {
      await temporaryRoot.delete(recursive: true);
    }
  });

  test(
    'installs payload before publishing metadata and retries cleanly',
    () async {
      final payload = _payload('preserved attachment');
      final candidate = _candidate(payload);
      final installer = _installer(
        fileStore: fileStore,
        readStore: readStore,
        writeStore: writeStore,
        archiveDirectory: archiveDirectory,
        writableRootLease: writableRootLease,
      );

      final first = await _installWithAuthority(
        coordinator: mutationCoordinator,
        installer: installer,
        candidate: candidate,
        donorPayload: payload,
        installedAtUtc: DateTime.utc(2026, 8, 21),
      );
      final record = await readStore.readArchiveRecord(_archiveKey);
      final second = await _installWithAuthority(
        coordinator: mutationCoordinator,
        installer: installer,
        candidate: candidate,
        donorPayload: payload,
      );

      expect(first.status, MessageLensAttachmentInstallationStatus.installed);
      expect(first.installedBytes, payload.expectedSizeBytes);
      expect(record, isNotNull);
      expect(record!.archiveFileExists, isTrue);
      expect(record.contentHash, payload.expectedSha256);
      expect(record.provenance, 'recovered_message_lens_archive');
      expect(
        second.status,
        MessageLensAttachmentInstallationStatus.alreadyPresent,
      );
      expect(second.installedBytes, 0);
      expect(
        await overlayDatabase.select(overlayDatabase.archivedAttachments).get(),
        hasLength(1),
      );
    },
  );

  test(
    'metadata failure preserves valid payload and retry reconciles it',
    () async {
      final payload = _payload('payload survives metadata failure');
      final candidate = _candidate(payload);
      final failingStore = _FailOnceWriteStore(writeStore);
      final firstInstaller = _installer(
        fileStore: fileStore,
        readStore: readStore,
        writeStore: failingStore,
        archiveDirectory: archiveDirectory,
        writableRootLease: writableRootLease,
      );

      final first = await _installWithAuthority(
        coordinator: mutationCoordinator,
        installer: firstInstaller,
        candidate: candidate,
        donorPayload: payload,
      );

      expect(
        first.status,
        MessageLensAttachmentInstallationStatus.metadataUpdateFailed,
      );
      expect(
        File(
          path.join(archiveDirectory.path, first.archiveRelativePath),
        ).existsSync(),
        isTrue,
      );
      expect(
        await overlayDatabase.select(overlayDatabase.archivedAttachments).get(),
        isEmpty,
      );

      final retryInstaller = _installer(
        fileStore: fileStore,
        readStore: readStore,
        writeStore: writeStore,
        archiveDirectory: archiveDirectory,
        writableRootLease: writableRootLease,
      );
      final retry = await _installWithAuthority(
        coordinator: mutationCoordinator,
        installer: retryInstaller,
        candidate: candidate,
        donorPayload: payload,
      );

      expect(
        retry.status,
        MessageLensAttachmentInstallationStatus.alreadyPresent,
      );
      expect(
        await overlayDatabase.select(overlayDatabase.archivedAttachments).get(),
        hasLength(1),
      );
    },
  );

  test('rejects non-recoverable candidate without opening payload', () async {
    final payload = _payload('unused');
    final candidate = MessageLensAttachmentRecoveryCandidate(
      archiveCompatibilityKey: _archiveKey,
      classification: MessageLensAttachmentRecoveryClassification.ambiguous,
      recoverableBytes: payload.expectedSizeBytes,
      donorArchiveRelativePath: payload.archiveRelativePath,
      donorPayloadSha256: payload.expectedSha256,
    );

    final installer = _installer(
      fileStore: fileStore,
      readStore: readStore,
      writeStore: writeStore,
      archiveDirectory: archiveDirectory,
      writableRootLease: writableRootLease,
    );
    final result = await _installWithAuthority(
      coordinator: mutationCoordinator,
      installer: installer,
      candidate: candidate,
      donorPayload: payload,
    );

    expect(result.status, MessageLensAttachmentInstallationStatus.unsafeSource);
    expect(payload.openCount, 0);
    expect(archiveDirectory.existsSync(), isFalse);
  });

  test('rejects capability from the wrong mutation operation', () async {
    final payload = _payload('wrong operation must not install');
    final installer = _installer(
      fileStore: fileStore,
      readStore: readStore,
      writeStore: writeStore,
      archiveDirectory: archiveDirectory,
      writableRootLease: writableRootLease,
    );

    await expectLater(
      mutationCoordinator.runWithCapability<void>(
        operation: ArchiveMutationOperation.graphBuild,
        ownerLabel: 'wrong-operation-test',
        action: (capability) async {
          await installer.install(
            mutationCapability: capability,
            candidate: _candidate(payload),
            donorPayload: payload,
          );
        },
      ),
      throwsA(isA<ArchiveMutationCapabilityDeniedException>()),
    );

    expect(payload.openCount, 0);
    expect(archiveDirectory.existsSync(), isFalse);
  });

  test('rejects an attachment capability after its scope ends', () async {
    final payload = _payload('stale capability must not install');
    final installer = _installer(
      fileStore: fileStore,
      readStore: readStore,
      writeStore: writeStore,
      archiveDirectory: archiveDirectory,
      writableRootLease: writableRootLease,
    );
    late ArchiveMutationCapability staleCapability;
    await mutationCoordinator.runWithCapability<void>(
      operation: ArchiveMutationOperation.attachmentReconciliation,
      ownerLabel: 'capture-stale-capability-test',
      action: (capability) async {
        staleCapability = capability;
      },
    );

    await expectLater(
      installer.install(
        mutationCapability: staleCapability,
        candidate: _candidate(payload),
        donorPayload: payload,
      ),
      throwsA(isA<ArchiveMutationCapabilityDeniedException>()),
    );

    expect(payload.openCount, 0);
    expect(archiveDirectory.existsSync(), isFalse);
  });
}

Future<MessageLensAttachmentInstallationResult> _installWithAuthority({
  required ArchiveMutationCoordinator coordinator,
  required MessageLensAttachmentRecoveryInstaller installer,
  required MessageLensAttachmentRecoveryCandidate candidate,
  required VerifiedDonorAttachmentPayload donorPayload,
  DateTime? installedAtUtc,
}) {
  return coordinator.runWithCapability<MessageLensAttachmentInstallationResult>(
    operation: ArchiveMutationOperation.attachmentReconciliation,
    ownerLabel: 'attachment-recovery-installer-test',
    action: (capability) => installer.install(
      mutationCapability: capability,
      candidate: candidate,
      donorPayload: donorPayload,
      installedAtUtc: installedAtUtc,
    ),
  );
}

MessageLensAttachmentRecoveryInstaller _installer({
  required FilesystemAttachmentArchiveFileStore fileStore,
  required OverlayAttachmentArchiveReadStore readStore,
  required AttachmentArchiveWriteStore writeStore,
  required Directory archiveDirectory,
  required AttachmentArchiveWritableRootLease writableRootLease,
}) {
  return MessageLensAttachmentRecoveryInstaller(
    fileStore: fileStore,
    readStore: readStore,
    writeStore: writeStore,
    writableRootLease: writableRootLease,
  );
}

const _archiveKey = ArchiveCompatibilityKey(
  messageGuid: 'message-guid',
  importAttachmentId: 42,
);

_MemoryVerifiedPayload _payload(String contents) {
  return _MemoryVerifiedPayload(contents.codeUnits, '.bin');
}

MessageLensAttachmentRecoveryCandidate _candidate(
  _MemoryVerifiedPayload payload,
) {
  return MessageLensAttachmentRecoveryCandidate(
    archiveCompatibilityKey: _archiveKey,
    classification: MessageLensAttachmentRecoveryClassification.recoverable,
    recoverableBytes: payload.expectedSizeBytes,
    donorArchiveRelativePath: payload.archiveRelativePath,
    donorPayloadSha256: payload.expectedSha256,
  );
}

class _MemoryVerifiedPayload implements VerifiedDonorAttachmentPayload {
  _MemoryVerifiedPayload(this.bytes, this.sourceExtension)
    : expectedSha256 = sha256.convert(bytes).toString();

  final List<int> bytes;
  int openCount = 0;

  @override
  final String sourceExtension;

  @override
  String get archiveRelativePath => 'aa/donor$sourceExtension';

  @override
  int get expectedSizeBytes => bytes.length;

  @override
  final String expectedSha256;

  @override
  Stream<List<int>> openRead() {
    openCount++;
    return Stream<List<int>>.value(bytes);
  }
}

class _FailOnceWriteStore implements AttachmentArchiveWriteStore {
  _FailOnceWriteStore(this.delegate);

  final AttachmentArchiveWriteStore delegate;
  var _shouldFail = true;

  @override
  Future<void> reconcileArchiveRecord(ArchivedAttachmentWrite record) async {
    if (_shouldFail) {
      _shouldFail = false;
      throw StateError('simulated metadata failure');
    }
    await delegate.reconcileArchiveRecord(record);
  }

  @override
  Future<void> clearRecoveryHint(ArchiveCompatibilityKey archiveKey) {
    return delegate.clearRecoveryHint(archiveKey);
  }

  @override
  Future<bool> hasArchiveRecord(ArchiveCompatibilityKey archiveKey) {
    return delegate.hasArchiveRecord(archiveKey);
  }

  @override
  Future<List<ArchiveIntegrityEntry>> readIntegrityEntries() {
    return delegate.readIntegrityEntries();
  }

  @override
  Future<AttachmentRecoveryMetadata?> readRecoveryHint(
    ArchiveCompatibilityKey archiveKey,
  ) {
    return delegate.readRecoveryHint(archiveKey);
  }

  @override
  Future<void> writeArchiveRecord(ArchivedAttachmentWrite record) {
    return delegate.writeArchiveRecord(record);
  }

  @override
  Future<void> writeRecoveryHint({
    required ArchiveCompatibilityKey archiveKey,
    required AttachmentRecoveryMetadata metadata,
  }) {
    return delegate.writeRecoveryHint(
      archiveKey: archiveKey,
      metadata: metadata,
    );
  }
}
