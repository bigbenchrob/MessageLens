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
import 'package:remember_this_text/features/attachments/application/attachment_archive_remediation_authority.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_runtime_providers.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_service_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_settings_store.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_settings_store_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_stats_reader.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_store_providers.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_write_store.dart';
import 'package:remember_this_text/features/attachments/application/deterministic_recovery_provider.dart';
import 'package:remember_this_text/features/attachments/application/message_lens_attachment_recovery_batch_executor.dart';
import 'package:remember_this_text/features/attachments/application/message_lens_attachment_recovery_batch_executor_provider.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_configuration.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_state.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_stats.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_recovery_metadata.dart';

import '../../../test_support/test_archive_fixture.dart';

void main() {
  group('Phase Four writable-root mutation authority', () {
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

        final outcome = await container
            .read(attachmentArchiveServiceProvider.notifier)
            .archiveAttachment(
              archiveKey: const ArchiveCompatibilityKey(
                messageGuid: 'custom-root-denied',
                importAttachmentId: 101,
              ),
              resolvedLocalPath: '/tmp/disposable-source',
              mimeType: 'application/octet-stream',
              sha256Hex: null,
            );

        expect(outcome.status, AttachmentArchiveIngestionStatus.deferred);
        expect(
          outcome.deferredReason,
          AttachmentArchiveMutationDeferredReason.customArchiveNotActivated,
        );

        expect(fileStore.ensureCalls, 0);
        expect(fileStore.writeCalls, 0);
        expect(fileStore.installCalls, 0);
      },
    );

    test(
      'read-only and unavailable custom roots defer without fallback',
      () async {
        final configuration = customLocation.configuration!;
        final cases =
            <
              (
                AttachmentArchiveLocationState,
                AttachmentArchiveMutationDeferredReason,
              )
            >[
              (
                AttachmentArchiveLocationState.customReadOnly(
                  configuration: configuration,
                  archiveRootPath: '/Volumes/Resolved/Archive',
                ),
                AttachmentArchiveMutationDeferredReason.customArchiveReadOnly,
              ),
              (
                AttachmentArchiveLocationState.customUnavailable(
                  configuration: configuration,
                  issue: 'Disconnected.',
                ),
                AttachmentArchiveMutationDeferredReason
                    .customArchiveUnavailable,
              ),
            ];

        for (final testCase in cases) {
          final fileStore = _RecordingAttachmentArchiveFileStore();
          final container = ProviderContainer(
            overrides: [
              admittedArchiveAccessAuthorityProvider.overrideWithValue(
                archiveFixture.authority,
              ),
              attachmentArchiveLocationProvider.overrideWith(
                () => _FixedAttachmentArchiveLocation(testCase.$1),
              ),
              attachmentArchiveFileStoreProvider.overrideWith(
                (ref) => fileStore,
              ),
            ],
          );
          final outcome = await container
              .read(attachmentArchiveServiceProvider.notifier)
              .archiveAttachment(
                archiveKey: const ArchiveCompatibilityKey(
                  messageGuid: 'deferred-custom-root',
                  importAttachmentId: 102,
                ),
                resolvedLocalPath: '/tmp/disposable-source',
                mimeType: 'application/octet-stream',
                sha256Hex: null,
              );

          expect(outcome.status, AttachmentArchiveIngestionStatus.deferred);
          expect(outcome.deferredReason, testCase.$2);
          final sweep = await container
              .read(attachmentArchiveServiceProvider.notifier)
              .archiveNextGraphSweepChunk(limit: 10);
          expect(sweep.isDeferred, isTrue);
          expect(sweep.deferredReason, testCase.$2);
          expect(sweep.totalScanned, 0);
          expect(fileStore.writeCalls, 0);
          container.dispose();
        }
      },
    );

    test(
      'explicitly activated custom root admits ordinary ingestion',
      () async {
        final activeConfiguration = customLocation.configuration!
            .withCustomWritePolicy(
              AttachmentArchiveCustomWritePolicy.activeArchive,
            );
        final activeLocation = AttachmentArchiveLocationState.customAvailable(
          configuration: activeConfiguration,
          archiveRootPath: '/Volumes/Resolved/Archive',
        );
        final fileStore = _RecordingAttachmentArchiveFileStore(
          writeResult: const ArchivedAttachmentFileWrite(
            sourcePath: '/tmp/disposable-source',
            relativePath: 'aa/payload.bin',
            fileSizeBytes: 7,
            contentHash: 'hash',
          ),
        );
        final writeStore = _RecordingAttachmentArchiveWriteStore();
        final container = ProviderContainer(
          overrides: [
            admittedArchiveAccessAuthorityProvider.overrideWithValue(
              archiveFixture.authority,
            ),
            attachmentArchiveLocationProvider.overrideWith(
              () => _FixedAttachmentArchiveLocation(activeLocation),
            ),
            attachmentArchiveFileStoreProvider.overrideWith((ref) => fileStore),
            attachmentArchiveWriteStoreProvider.overrideWith(
              (ref) async => writeStore,
            ),
          ],
        );
        addTearDown(container.dispose);

        final outcome = await container
            .read(attachmentArchiveServiceProvider.notifier)
            .archiveAttachment(
              archiveKey: const ArchiveCompatibilityKey(
                messageGuid: 'active-custom-root',
                importAttachmentId: 103,
              ),
              resolvedLocalPath: '/tmp/disposable-source',
              mimeType: 'application/octet-stream',
              sha256Hex: null,
            );

        expect(outcome.status, AttachmentArchiveIngestionStatus.archived);
        expect(fileStore.writePaths, <String>['/Volumes/Resolved/Archive']);
        expect(writeStore.archiveRecords, hasLength(1));
      },
    );

    test(
      'generation loss before install or metadata commit defers safely',
      () async {
        for (final invalidateBeforeBoundary in <bool>[true, false]) {
          final initialLocation =
              AttachmentArchiveLocationState.defaultAvailable(
                archiveRootPath: '/internal/attachment_archive',
              );
          late ProviderContainer container;
          final writeStore = _RecordingAttachmentArchiveWriteStore();
          final fileStore = _RecordingAttachmentArchiveFileStore(
            writeResult: const ArchivedAttachmentFileWrite(
              sourcePath: '/tmp/disposable-source',
              relativePath: 'aa/payload.bin',
              fileSizeBytes: 7,
              contentHash: 'hash',
            ),
            beforeValidation: (boundary) {
              if (invalidateBeforeBoundary &&
                  boundary ==
                      AttachmentArchiveMutationBoundary.beforeFinalInstall) {
                _replaceLocation(container, initialLocation.withGeneration(1));
              }
            },
            afterValidation: (boundary) {
              if (!invalidateBeforeBoundary &&
                  boundary ==
                      AttachmentArchiveMutationBoundary.afterFinalInstall) {
                _replaceLocation(container, initialLocation.withGeneration(1));
              }
            },
          );
          container = ProviderContainer(
            overrides: [
              admittedArchiveAccessAuthorityProvider.overrideWithValue(
                archiveFixture.authority,
              ),
              attachmentArchiveLocationProvider.overrideWith(
                () => _MutableAttachmentArchiveLocation(initialLocation),
              ),
              attachmentArchiveFileStoreProvider.overrideWith(
                (ref) => fileStore,
              ),
              attachmentArchiveWriteStoreProvider.overrideWith(
                (ref) async => writeStore,
              ),
            ],
          );

          final outcome = await container
              .read(attachmentArchiveServiceProvider.notifier)
              .archiveAttachment(
                archiveKey: ArchiveCompatibilityKey(
                  messageGuid: invalidateBeforeBoundary
                      ? 'stale-before-install'
                      : 'stale-before-metadata',
                  importAttachmentId: invalidateBeforeBoundary ? 104 : 105,
                ),
                resolvedLocalPath: '/tmp/disposable-source',
                mimeType: 'application/octet-stream',
                sha256Hex: null,
              );

          expect(outcome.status, AttachmentArchiveIngestionStatus.deferred);
          expect(
            outcome.deferredReason,
            AttachmentArchiveMutationDeferredReason.staleGeneration,
          );
          expect(writeStore.archiveRecords, isEmpty);
          container.dispose();
        }
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
          throwsA(isA<AttachmentArchiveMutationDeferredException>()),
        );

        expect(fileOperations.resetPaths, isEmpty);
        expect(settingsStore.clearCalls, 0);
      },
    );

    test('activated custom root still denies destructive clear', () async {
      final activeLocation = AttachmentArchiveLocationState.customAvailable(
        configuration: customLocation.configuration!.withCustomWritePolicy(
          AttachmentArchiveCustomWritePolicy.activeArchive,
        ),
        archiveRootPath: '/Volumes/Resolved/Archive',
      );
      final settingsStore = _RecordingArchiveSettingsStore();
      final fileOperations = _RecordingArchiveFileOperations();
      final container = ProviderContainer(
        overrides: [
          admittedArchiveAccessAuthorityProvider.overrideWithValue(
            archiveFixture.authority,
          ),
          attachmentArchiveLocationProvider.overrideWith(
            () => _FixedAttachmentArchiveLocation(activeLocation),
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
        throwsA(
          isA<AttachmentArchiveMutationDeferredException>().having(
            (error) => error.reason,
            'reason',
            AttachmentArchiveMutationDeferredReason
                .destructiveResetNotPermitted,
          ),
        ),
      );

      expect(fileOperations.resetPaths, isEmpty);
      expect(settingsStore.clearCalls, 0);
    });

    test(
      'direct deterministic recovery cannot acquire custom authority',
      () async {
        final container = ProviderContainer(
          overrides: [
            attachmentArchiveLocationProvider.overrideWith(
              () => _FixedAttachmentArchiveLocation(customLocation),
            ),
          ],
        );
        addTearDown(container.dispose);

        final admission = await container.read(
          attachmentArchiveWritableRootAdmissionProvider.future,
        );

        expect(admission.isAdmitted, isFalse);
      },
    );

    test(
      'deterministic recovery publishes typed deferral before donor reads',
      () async {
        final unavailable = AttachmentArchiveLocationState.customUnavailable(
          configuration: customLocation.configuration!,
          issue: 'External volume disconnected.',
        );
        final container = ProviderContainer(
          overrides: [
            admittedArchiveAccessAuthorityProvider.overrideWithValue(
              archiveFixture.authority,
            ),
            attachmentArchiveLocationProvider.overrideWith(
              () => _FixedAttachmentArchiveLocation(unavailable),
            ),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(deterministicRecoveryProvider.notifier)
            .recover(
              chatDbPath: '/must-not-be-read/chat.db',
              attachmentsFolderPath: '/must-not-be-read/Attachments',
            );
        final state = container.read(deterministicRecoveryProvider);

        expect(state.phase, DeterministicRecoveryPhase.deferred);
        expect(
          state.deferredReason,
          AttachmentArchiveMutationDeferredReason.customArchiveUnavailable,
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

      final runner = await container.read(
        messageLensAttachmentRecoveryBatchExecutorProvider(
          donorArchiveRoot: '/tmp/disposable-donor',
        ).future,
      );
      expect(runner, isA<DeferredMessageLensAttachmentRecoveryBatchRunner>());
    });
  });
}

final class _FixedAttachmentArchiveLocation extends AttachmentArchiveLocation {
  _FixedAttachmentArchiveLocation(this.location);

  final AttachmentArchiveLocationState location;

  @override
  Future<AttachmentArchiveLocationState> build() async => location;
}

final class _MutableAttachmentArchiveLocation
    extends AttachmentArchiveLocation {
  _MutableAttachmentArchiveLocation(this.location);

  final AttachmentArchiveLocationState location;

  @override
  Future<AttachmentArchiveLocationState> build() async => location;

  void replace(AttachmentArchiveLocationState next) {
    state = AsyncData(next);
  }
}

void _replaceLocation(
  ProviderContainer container,
  AttachmentArchiveLocationState location,
) {
  final notifier = container.read(attachmentArchiveLocationProvider.notifier);
  (notifier as _MutableAttachmentArchiveLocation).replace(location);
}

final class _RecordingAttachmentArchiveFileStore
    implements AttachmentArchiveFileStore {
  _RecordingAttachmentArchiveFileStore({
    this.writeResult,
    this.beforeValidation,
    this.afterValidation,
  });

  final ArchivedAttachmentFileWrite? writeResult;
  final void Function(AttachmentArchiveMutationBoundary boundary)?
  beforeValidation;
  final void Function(AttachmentArchiveMutationBoundary boundary)?
  afterValidation;
  var ensureCalls = 0;
  var writeCalls = 0;
  var installCalls = 0;
  final writePaths = <String>[];

  @override
  Future<ArchiveIntegrityFileCheck> checkIntegrity({
    required String archiveDirectoryPath,
    required String relativePath,
    required String? storedHash,
  }) {
    throw StateError('Integrity reads are not expected.');
  }

  @override
  Future<void> ensureArchiveDirectory(
    String archiveDirectoryPath, {
    Future<void> Function(AttachmentArchiveMutationBoundary boundary)?
    validateMutation,
  }) async {
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
    Future<void> Function(AttachmentArchiveMutationBoundary boundary)?
    validateMutation,
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
  Future<AttachmentArchiveFileInstall> installVerifiedArchiveEntryAtPath({
    required String archiveDirectoryPath,
    required Stream<List<int>> sourceBytes,
    required AttachmentArchiveRemediationAuthority remediationAuthority,
  }) {
    throw StateError('Remediation installs are not expected.');
  }

  @override
  Future<ArchivedAttachmentFileWrite?> writeArchiveEntry({
    required String archiveDirectoryPath,
    required String sourcePath,
    required ArchiveCompatibilityKey archiveKey,
    required String? sha256Hex,
    Future<void> Function(AttachmentArchiveMutationBoundary boundary)?
    validateMutation,
  }) async {
    writeCalls += 1;
    writePaths.add(archiveDirectoryPath);
    for (final boundary in <AttachmentArchiveMutationBoundary>[
      AttachmentArchiveMutationBoundary.beforeSourceRead,
      AttachmentArchiveMutationBoundary.afterSourceHash,
      AttachmentArchiveMutationBoundary.beforeFinalInstall,
      AttachmentArchiveMutationBoundary.afterFinalInstall,
    ]) {
      beforeValidation?.call(boundary);
      await validateMutation?.call(boundary);
      afterValidation?.call(boundary);
    }
    return writeResult;
  }
}

final class _RecordingAttachmentArchiveWriteStore
    implements AttachmentArchiveWriteStore {
  final archiveRecords = <ArchivedAttachmentWrite>[];

  @override
  Future<void> clearRecoveryHint(ArchiveCompatibilityKey archiveKey) async {}

  @override
  Future<bool> hasArchiveRecord(ArchiveCompatibilityKey archiveKey) async {
    return false;
  }

  @override
  Future<AttachmentRecoveryMetadata?> readRecoveryHint(
    ArchiveCompatibilityKey archiveKey,
  ) async {
    return null;
  }

  @override
  Future<List<ArchiveIntegrityEntry>> readIntegrityEntries() async => const [];

  @override
  Future<void> reconcileArchiveRecord(ArchivedAttachmentWrite record) async {
    archiveRecords.add(record);
  }

  @override
  Future<void> writeArchiveRecord(ArchivedAttachmentWrite record) async {
    archiveRecords.add(record);
  }

  @override
  Future<void> writeRecoveryHint({
    required ArchiveCompatibilityKey archiveKey,
    required AttachmentRecoveryMetadata metadata,
  }) async {}
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
