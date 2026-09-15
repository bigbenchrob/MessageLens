import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart'
    show admittedArchiveAccessAuthorityProvider;
import 'package:remember_this_text/features/attachments/application/archive_settings_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_file_operations.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_file_store.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_location_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_runtime_providers.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_service_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_settings_store.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_settings_store_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_stats_reader.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_store_providers.dart';
import 'package:remember_this_text/features/attachments/application/deterministic_recovery_runtime_providers.dart';
import 'package:remember_this_text/features/attachments/application/message_lens_attachment_recovery_batch_executor_provider.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_configuration.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_state.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_stats.dart';

import '../../../test_support/test_archive_fixture.dart';

void main() {
  group('Phase Two internal-only attachment mutation authority', () {
    late TestArchiveFixture archiveFixture;
    late AttachmentArchiveLocationState customLocation;

    setUp(() async {
      archiveFixture = await TestArchiveFixture.create(
        prefix: 'attachment_archive_mutation_authority_test_',
      );
      final configuration =
          AttachmentArchiveLocationConfiguration.customExternal(
            bookmarkDataBase64: 'AQ==',
            lastKnownPath: '/Volumes/Remembered/Archive',
          );
      customLocation = AttachmentArchiveLocationState.customAvailable(
        configuration: configuration,
        archiveRootPath: '/Volumes/Resolved/Archive',
      );
    });

    tearDown(() => archiveFixture.dispose());

    test(
      'archive service cannot create or write a custom external root',
      () async {
        final fileStore = _RecordingAttachmentArchiveFileStore();
        final container = ProviderContainer(
          overrides: [
            admittedArchiveAccessAuthorityProvider.overrideWithValue(
              archiveFixture.authority,
            ),
            attachmentArchiveLocationProvider.overrideWith(
              () => _FixedAttachmentArchiveLocation(customLocation),
            ),
            attachmentArchiveFileStoreProvider.overrideWith((ref) => fileStore),
          ],
        );
        addTearDown(container.dispose);

        await expectLater(
          container
              .read(attachmentArchiveServiceProvider.notifier)
              .archiveAttachment(
                archiveKey: const ArchiveCompatibilityKey(
                  messageGuid: 'custom-root-denied',
                  importAttachmentId: 101,
                ),
                resolvedLocalPath: '/tmp/disposable-source',
                mimeType: 'application/octet-stream',
                sha256Hex: null,
              ),
          throwsStateError,
        );

        expect(fileStore.ensureCalls, 0);
        expect(fileStore.writeCalls, 0);
        expect(fileStore.installCalls, 0);
      },
    );

    test(
      'clearArchive cannot delete or recreate a custom external root',
      () async {
        final settingsStore = _RecordingArchiveSettingsStore();
        final fileOperations = _RecordingArchiveFileOperations();
        final container = ProviderContainer(
          overrides: [
            admittedArchiveAccessAuthorityProvider.overrideWithValue(
              archiveFixture.authority,
            ),
            attachmentArchiveLocationProvider.overrideWith(
              () => _FixedAttachmentArchiveLocation(customLocation),
            ),
            attachmentArchiveSettingsStoreProvider.overrideWith(
              (ref) async => settingsStore,
            ),
            attachmentArchiveStatsReaderProvider.overrideWith(
              (ref) async => const _ZeroArchiveStatsReader(),
            ),
            attachmentArchiveFileOperationsProvider.overrideWith(
              (ref) => fileOperations,
            ),
          ],
        );
        addTearDown(container.dispose);
        await container.read(archiveSettingsProvider.future);

        await expectLater(
          container.read(archiveSettingsProvider.notifier).clearArchive(),
          throwsStateError,
        );

        expect(fileOperations.resetPaths, isEmpty);
        expect(settingsStore.clearCalls, 0);
      },
    );

    test(
      'direct deterministic recovery writer cannot target custom root',
      () async {
        final container = ProviderContainer(
          overrides: [
            attachmentArchiveLocationProvider.overrideWith(
              () => _FixedAttachmentArchiveLocation(customLocation),
            ),
          ],
        );
        addTearDown(container.dispose);

        await expectLater(
          container.read(recoveredAttachmentArchiveWriterProvider.future),
          throwsStateError,
        );
      },
    );

    test('batch recovery installer cannot target custom root', () async {
      final container = ProviderContainer(
        overrides: [
          attachmentArchiveLocationProvider.overrideWith(
            () => _FixedAttachmentArchiveLocation(customLocation),
          ),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(
          messageLensAttachmentRecoveryBatchExecutorProvider(
            donorArchiveRoot: '/tmp/disposable-donor',
          ).future,
        ),
        throwsStateError,
      );
    });
  });
}

final class _FixedAttachmentArchiveLocation extends AttachmentArchiveLocation {
  _FixedAttachmentArchiveLocation(this.location);

  final AttachmentArchiveLocationState location;

  @override
  Future<AttachmentArchiveLocationState> build() async => location;
}

final class _RecordingAttachmentArchiveFileStore
    implements AttachmentArchiveFileStore {
  var ensureCalls = 0;
  var writeCalls = 0;
  var installCalls = 0;

  @override
  Future<ArchiveIntegrityFileCheck> checkIntegrity({
    required String archiveDirectoryPath,
    required String relativePath,
    required String? storedHash,
  }) {
    throw StateError('Integrity reads are not expected.');
  }

  @override
  Future<void> ensureArchiveDirectory(String archiveDirectoryPath) async {
    ensureCalls += 1;
  }

  @override
  String expandHomePath(String rawPath) => rawPath;

  @override
  bool fileExists(String path) => true;

  @override
  Future<AttachmentArchiveFileInstall> installVerifiedArchiveEntry({
    required String archiveDirectoryPath,
    required Stream<List<int>> sourceBytes,
    required String sourceExtension,
    required int expectedSizeBytes,
    required String expectedSha256,
  }) async {
    installCalls += 1;
    return AttachmentArchiveFileInstall(
      status: AttachmentArchiveFileInstallStatus.installed,
      relativePath: 'unexpected',
      fileSizeBytes: expectedSizeBytes,
      contentHash: expectedSha256,
    );
  }

  @override
  Future<ArchivedAttachmentFileWrite?> writeArchiveEntry({
    required String archiveDirectoryPath,
    required String sourcePath,
    required ArchiveCompatibilityKey archiveKey,
    required String? sha256Hex,
  }) async {
    writeCalls += 1;
    return null;
  }
}

final class _RecordingArchiveSettingsStore
    implements AttachmentArchiveSettingsStore {
  var clearCalls = 0;
  final settings = <String, String>{};

  @override
  Future<void> clearArchivedAttachmentRecords() async {
    clearCalls += 1;
  }

  @override
  Future<String?> readSetting(String key) async => settings[key];

  @override
  Future<void> writeSetting({
    required String key,
    required String value,
  }) async {
    settings[key] = value;
  }
}

final class _ZeroArchiveStatsReader implements AttachmentArchiveStatsReader {
  const _ZeroArchiveStatsReader();

  @override
  Future<AttachmentArchiveStats> readStats() async {
    return const AttachmentArchiveStats(recordCount: 0, sizeBytes: 0);
  }
}

final class _RecordingArchiveFileOperations
    implements AttachmentArchiveFileOperations {
  final resetPaths = <String>[];

  @override
  Future<int?> exportArchiveDirectory(String archiveDirectoryPath) async => 0;

  @override
  Future<void> resetArchiveDirectory(String archiveDirectoryPath) async {
    resetPaths.add(archiveDirectoryPath);
  }
}
