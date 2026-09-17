import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_mutation_operation.dart';
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_location_dependencies_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_location_native_adapter.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_location_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_relocation_activation_gate.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_relocation_service.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_settings_store_provider.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_configuration.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_relocation.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/filesystem_attachment_archive_relocation_file_system.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/filesystem_attachment_archive_relocation_journal_store.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/overlay_attachment_archive_relocation_metadata_reader.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/overlay_attachment_archive_settings_store.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/payloads/attachment_archive_settings_cassette_payload.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/resolvers/attachment_archive_settings_resolver.dart';

import '../../../test_support/test_archive_fixture.dart';

void main() {
  group('attachment archive relocation disposable end to end', () {
    late TestArchiveFixture archiveFixture;
    late Directory destinationParent;
    late Directory sourceRoot;
    late OverlayDatabase overlayDatabase;
    late _PathBookmarkNativeAdapter nativeAdapter;
    late ProviderContainer container;
    late FilesystemAttachmentArchiveRelocationJournalStore journalStore;

    setUp(() async {
      archiveFixture = await TestArchiveFixture.create(
        prefix: 'attachment_relocation_primary_',
      );
      destinationParent = Directory.systemTemp.createTempSync(
        'attachment_relocation_destination_',
      );
      sourceRoot = Directory('${archiveFixture.root.path}/attachment_archive')
        ..createSync();
      overlayDatabase = OverlayDatabase(NativeDatabase.memory());
      nativeAdapter = _PathBookmarkNativeAdapter();
      container = ProviderContainer(
        overrides: <Override>[
          admittedArchiveAccessAuthorityProvider.overrideWithValue(
            archiveFixture.authority,
          ),
          attachmentArchiveSettingsStoreProvider.overrideWith(
            (ref) async => OverlayAttachmentArchiveSettingsStore(
              overlayDb: overlayDatabase,
            ),
          ),
          attachmentArchiveLocationNativeAdapterProvider.overrideWith(
            (ref) => nativeAdapter,
          ),
        ],
      );
      journalStore = FilesystemAttachmentArchiveRelocationJournalStore(
        primaryArchiveRootPath: archiveFixture.root.path,
      );
    });

    tearDown(() async {
      container.dispose();
      await overlayDatabase.close();
      if (destinationParent.existsSync()) {
        await destinationParent.delete(recursive: true);
      }
      await archiveFixture.dispose();
    });

    AttachmentArchiveRelocationService buildService({
      bool failBeforeConfigurationSwitch = false,
      bool failAfterConfigurationSwitch = false,
      bool failBeforeWritableLeaseValidation = false,
    }) {
      return AttachmentArchiveRelocationService(
        archiveAccessAuthority: archiveFixture.authority,
        journalStore: journalStore,
        metadataReader: OverlayAttachmentArchiveRelocationMetadataReader(
          overlayDatabase: overlayDatabase,
        ),
        fileSystem: FilesystemAttachmentArchiveRelocationFileSystem(
          capacityReader: nativeAdapter,
        ),
        nativeAdapter: nativeAdapter,
        activationGate: AttachmentArchiveRelocationActivationGate(
          journalStore: journalStore,
        ),
        readLocation: () =>
            container.read(attachmentArchiveLocationProvider.future),
        activateLocation:
            ({required configuration, required activationPermit}) async {
              if (failBeforeConfigurationSwitch) {
                throw StateError('Injected pre-switch activation failure.');
              }
              await container
                  .read(attachmentArchiveLocationProvider.notifier)
                  .activateVerifiedRelocation(
                    configuration: configuration,
                    activationPermit: activationPermit,
                  );
              if (failAfterConfigurationSwitch) {
                throw StateError('Injected post-switch validation failure.');
              }
            },
        restoreLocation: ({required configuration, required activationPermit}) {
          return container
              .read(attachmentArchiveLocationProvider.notifier)
              .restoreRelocationConfiguration(
                configuration: configuration,
                activationPermit: activationPermit,
              );
        },
        readWritableAdmission: () {
          if (failBeforeWritableLeaseValidation) {
            throw StateError('Injected writable-lease validation failure.');
          }
          return container.read(
            attachmentArchiveWritableRootAdmissionProvider.future,
          );
        },
      );
    }

    Future<T> withRelocationCapability<T>(
      Future<T> Function(ArchiveMutationCapability capability) action,
    ) {
      return container
          .read(archiveMutationCoordinatorProvider.notifier)
          .runWithCapability(
            operation: ArchiveMutationOperation.attachmentRelocation,
            ownerLabel: 'disposable-relocation-test',
            action: action,
          );
    }

    test(
      'production-style Settings acceptance pauses, reconnects, resumes, activates, and retains source',
      () async {
        final expectedSource = await _createSyntheticArchive(
          sourceRoot: sourceRoot,
          overlayDatabase: overlayDatabase,
        );
        final metadataBefore = await overlayDatabase
            .customSelect('SELECT * FROM archived_attachments ORDER BY id')
            .get();
        final service = buildService();
        final resolver = container.read(
          attachmentArchiveSettingsResolverProvider.notifier,
        );
        final initialLocation = await container.read(
          attachmentArchiveLocationProvider.future,
        );
        final initialUi = resolver.resolve(
          cassetteIndex: 2,
          location: initialLocation,
          relocation: null,
          relocationEnabled: true,
        );
        expect(
          initialUi.workflowView,
          AttachmentArchiveSettingsWorkflowView.currentLocation,
        );
        expect(initialUi.actions.single.label, 'Move…');

        final selection = await withRelocationCapability(
          (capability) => service.selectDestination(
            destinationParentPath: destinationParent.path,
            mutationCapability: capability,
          ),
        );
        final selectedUi = resolver.resolve(
          cassetteIndex: 2,
          location: initialLocation,
          relocation: selection,
          relocationEnabled: true,
        );
        expect(
          selectedUi.workflowView,
          AttachmentArchiveSettingsWorkflowView.preparingReview,
        );
        expect(selectedUi.bodyText, contains('No payloads are being copied'));

        final review = await withRelocationCapability(
          (capability) => service.prepareForReview(
            operationId: selection.operationId,
            mutationCapability: capability,
          ),
        );
        final reviewUi = resolver.resolve(
          cassetteIndex: 2,
          location: initialLocation,
          relocation: review,
          relocationEnabled: true,
        );
        expect(
          reviewUi.workflowView,
          AttachmentArchiveSettingsWorkflowView.preflightReview,
        );
        expect(reviewUi.actions.first.label, 'Begin Relocation');
        expect(review.filesCopied, 0);

        final paused = await withRelocationCapability(
          (capability) => service.run(
            operationId: selection.operationId,
            mutationCapability: capability,
            pauseAfterNewlyCopiedFiles: 2,
          ),
        );
        expect(paused.stage, AttachmentArchiveRelocationStage.paused);
        expect(paused.filesCopied, 2);
        expect(paused.isResumable, isTrue);
        final pausedUi = resolver.resolve(
          cassetteIndex: 2,
          location: initialLocation,
          relocation: paused,
          relocationEnabled: true,
        );
        expect(
          pausedUi.workflowView,
          AttachmentArchiveSettingsWorkflowView.paused,
        );
        expect(
          pausedUi.actions.map((action) => action.label),
          contains('Resume'),
        );
        await _expectTreeUnchanged(sourceRoot, expectedSource);

        final restartedService = buildService();
        final reconstructed = await restartedService.readCurrentProgress();
        expect(reconstructed?.stage, AttachmentArchiveRelocationStage.paused);
        expect(reconstructed?.filesCopied, 2);

        final offlineDestination = Directory(
          '${destinationParent.path}.offline',
        );
        destinationParent.renameSync(offlineDestination.path);
        final destinationPaused = await withRelocationCapability(
          (capability) => restartedService.run(
            operationId: selection.operationId,
            mutationCapability: capability,
          ),
        );
        expect(
          destinationPaused.deferredReason,
          AttachmentArchiveRelocationDeferredReason.destinationUnavailable,
        );
        expect(destinationPaused.filesCopied, 2);
        final unavailableUi = resolver.resolve(
          cassetteIndex: 2,
          location: initialLocation,
          relocation: destinationPaused,
          relocationEnabled: true,
        );
        expect(unavailableUi.bodyText, contains('destination is unavailable'));
        expect(
          unavailableUi.statusLines
              .singleWhere((line) => line.label == 'Destination availability')
              .value,
          'Unavailable',
        );
        offlineDestination.renameSync(destinationParent.path);

        final reconnectedService = buildService();
        final completed = await withRelocationCapability(
          (capability) => reconnectedService.run(
            operationId: selection.operationId,
            mutationCapability: capability,
          ),
        );

        expect(
          completed.stage,
          AttachmentArchiveRelocationStage.sourceRetained,
        );
        expect(completed.filesCopied, 4);
        expect(completed.filesVerified, 4);
        expect(completed.sourceRetained, isTrue);
        await _expectTreeUnchanged(sourceRoot, expectedSource);

        final journal = await journalStore.read(selection.operationId);
        expect(journal.expectedFileCount, 4);
        expect(journal.metadataRowCount, 4);
        expect(journal.unreferencedFileCount, 1);
        expect(journal.activationOccurred, isTrue);
        final finalRoot = Directory(
          '${destinationParent.path}/${journal.finalDirectoryName}',
        );
        expect(finalRoot.existsSync(), isTrue);
        await _expectTreeUnchanged(finalRoot, expectedSource);

        final currentLocation = await container.read(
          attachmentArchiveLocationProvider.future,
        );
        expect(
          currentLocation.configuration?.customWritePolicy,
          AttachmentArchiveCustomWritePolicy.activeArchive,
        );
        expect(
          currentLocation.archiveRootPath,
          finalRoot.resolveSymbolicLinksSync(),
        );
        final completedUi = resolver.resolve(
          cassetteIndex: 2,
          location: currentLocation,
          relocation: completed,
          relocationEnabled: true,
        );
        expect(
          completedUi.workflowView,
          AttachmentArchiveSettingsWorkflowView.completed,
        );
        expect(completedUi.title, contains('Moved Successfully'));
        expect(
          completedUi.bodyText,
          contains('original archive is still stored'),
        );
        expect(completedUi.actions, isEmpty);
        final writableAdmission = await container.read(
          attachmentArchiveWritableRootAdmissionProvider.future,
        );
        expect(writableAdmission.isAdmitted, isTrue);

        final metadataAfter = await overlayDatabase
            .customSelect('SELECT * FROM archived_attachments ORDER BY id')
            .get();
        expect(
          metadataAfter.map((row) => row.data).toList(),
          metadataBefore.map((row) => row.data).toList(),
        );
      },
    );

    test(
      'prepares a truthful review before explicit begin copies any payload',
      () async {
        final expectedSource = await _createSyntheticArchive(
          sourceRoot: sourceRoot,
          overlayDatabase: overlayDatabase,
        );
        final service = buildService();
        final selection = await withRelocationCapability(
          (capability) => service.selectDestination(
            destinationParentPath: destinationParent.path,
            mutationCapability: capability,
          ),
        );

        final review = await withRelocationCapability(
          (capability) => service.prepareForReview(
            operationId: selection.operationId,
            mutationCapability: capability,
          ),
        );

        expect(
          review.stage,
          AttachmentArchiveRelocationStage.inventoryComplete,
        );
        expect(review.filesCopied, 0);
        expect(review.bytesCopied, 0);
        expect(review.expectedFiles, expectedSource.length);
        expect(review.availableCapacityBytes, isNotNull);
        expect(review.requiredCapacityBytes, greaterThan(review.expectedBytes));
        final reviewJournal = await journalStore.read(selection.operationId);
        expect(
          Directory(
            '${destinationParent.path}/${reviewJournal.finalDirectoryName}',
          ).existsSync(),
          isFalse,
        );
        await _expectTreeUnchanged(sourceRoot, expectedSource);

        final completed = await withRelocationCapability(
          (capability) => service.run(
            operationId: selection.operationId,
            mutationCapability: capability,
          ),
        );
        expect(
          completed.stage,
          AttachmentArchiveRelocationStage.sourceRetained,
        );
      },
    );

    test(
      'cooperative pause survives reconstruction and resumes verified receipts',
      () async {
        await _createSyntheticArchive(
          sourceRoot: sourceRoot,
          overlayDatabase: overlayDatabase,
        );
        final service = buildService();
        final selection = await withRelocationCapability(
          (capability) => service.selectDestination(
            destinationParentPath: destinationParent.path,
            mutationCapability: capability,
          ),
        );
        await withRelocationCapability(
          (capability) => service.prepareForReview(
            operationId: selection.operationId,
            mutationCapability: capability,
          ),
        );

        var pauseRequested = true;
        final paused = await withRelocationCapability(
          (capability) => service.run(
            operationId: selection.operationId,
            mutationCapability: capability,
            pauseRequested: () => pauseRequested,
          ),
        );
        expect(paused.stage, AttachmentArchiveRelocationStage.paused);
        expect(
          paused.deferredReason,
          AttachmentArchiveRelocationDeferredReason.userPaused,
        );
        expect(paused.filesCopied, 1);

        final restartedService = buildService();
        final reconstructed = await restartedService.readCurrentProgress();
        expect(reconstructed?.stage, AttachmentArchiveRelocationStage.paused);
        expect(reconstructed?.filesCopied, 1);

        pauseRequested = false;
        final completed = await withRelocationCapability(
          (capability) => restartedService.run(
            operationId: selection.operationId,
            mutationCapability: capability,
          ),
        );
        expect(
          completed.stage,
          AttachmentArchiveRelocationStage.sourceRetained,
        );
        final receipts = await journalStore
            .readCopyReceipts(selection.operationId)
            .toList();
        expect(receipts.map((receipt) => receipt.index), [0, 1, 2, 3]);
      },
    );

    test(
      'post-switch failure restores old configuration and both copies',
      () async {
        final expectedSource = await _createSyntheticArchive(
          sourceRoot: sourceRoot,
          overlayDatabase: overlayDatabase,
        );
        final service = buildService(failAfterConfigurationSwitch: true);
        final selection = await withRelocationCapability(
          (capability) => service.selectDestination(
            destinationParentPath: destinationParent.path,
            mutationCapability: capability,
          ),
        );

        final result = await withRelocationCapability(
          (capability) => service.run(
            operationId: selection.operationId,
            mutationCapability: capability,
          ),
        );

        expect(
          result.stage,
          AttachmentArchiveRelocationStage.rollbackRestoredOldConfiguration,
        );
        final currentLocation = await container.read(
          attachmentArchiveLocationProvider.future,
        );
        expect(
          currentLocation.configuration,
          const AttachmentArchiveLocationConfiguration.defaultInternal(),
        );
        final rollbackUi = container
            .read(attachmentArchiveSettingsResolverProvider.notifier)
            .resolve(
              cassetteIndex: 2,
              location: currentLocation,
              relocation: result,
              relocationEnabled: true,
            );
        expect(
          rollbackUi.workflowView,
          AttachmentArchiveSettingsWorkflowView.failed,
        );
        expect(rollbackUi.title, isNot(contains('Successfully')));
        expect(currentLocation.archiveRootPath, sourceRoot.path);
        await _expectTreeUnchanged(sourceRoot, expectedSource);
        final journal = await journalStore.read(selection.operationId);
        final finalRoot = Directory(
          '${destinationParent.path}/${journal.finalDirectoryName}',
        );
        expect(finalRoot.existsSync(), isTrue);
        await _expectTreeUnchanged(finalRoot, expectedSource);
      },
    );

    for (final failure
        in <({String name, bool beforeSwitch, bool beforeLease})>[
          (
            name: 'immediately before configuration switch',
            beforeSwitch: true,
            beforeLease: false,
          ),
          (
            name: 'before writable-lease validation',
            beforeSwitch: false,
            beforeLease: true,
          ),
        ]) {
      test(
        '${failure.name} failure restores the old root and retains both copies',
        () async {
          final expectedSource = await _createSyntheticArchive(
            sourceRoot: sourceRoot,
            overlayDatabase: overlayDatabase,
          );
          final service = buildService(
            failBeforeConfigurationSwitch: failure.beforeSwitch,
            failBeforeWritableLeaseValidation: failure.beforeLease,
          );
          final selection = await withRelocationCapability(
            (capability) => service.selectDestination(
              destinationParentPath: destinationParent.path,
              mutationCapability: capability,
            ),
          );

          final result = await withRelocationCapability(
            (capability) => service.run(
              operationId: selection.operationId,
              mutationCapability: capability,
            ),
          );

          expect(
            result.stage,
            AttachmentArchiveRelocationStage.rollbackRestoredOldConfiguration,
          );
          final currentLocation = await container.read(
            attachmentArchiveLocationProvider.future,
          );
          expect(
            currentLocation.configuration,
            const AttachmentArchiveLocationConfiguration.defaultInternal(),
          );
          expect(currentLocation.archiveRootPath, sourceRoot.path);
          await _expectTreeUnchanged(sourceRoot, expectedSource);
          final journal = await journalStore.read(selection.operationId);
          await _expectTreeUnchanged(
            Directory(
              '${destinationParent.path}/${journal.finalDirectoryName}',
            ),
            expectedSource,
          );
        },
      );
    }

    test(
      'unverified selected destination cannot mint activation permit',
      () async {
        await _createSyntheticArchive(
          sourceRoot: sourceRoot,
          overlayDatabase: overlayDatabase,
        );
        final service = buildService();
        final selection = await withRelocationCapability(
          (capability) => service.selectDestination(
            destinationParentPath: destinationParent.path,
            mutationCapability: capability,
          ),
        );

        await expectLater(
          AttachmentArchiveRelocationActivationGate(
            journalStore: journalStore,
          ).issuePermit(selection.operationId),
          throwsStateError,
        );
      },
    );

    test(
      'insufficient capacity defers before copying and preserves source',
      () async {
        final expectedSource = await _createSyntheticArchive(
          sourceRoot: sourceRoot,
          overlayDatabase: overlayDatabase,
        );
        nativeAdapter.capacityBytes = 0;
        final service = buildService();
        final selection = await withRelocationCapability(
          (capability) => service.selectDestination(
            destinationParentPath: destinationParent.path,
            mutationCapability: capability,
          ),
        );

        final result = await withRelocationCapability(
          (capability) => service.run(
            operationId: selection.operationId,
            mutationCapability: capability,
          ),
        );

        expect(result.stage, AttachmentArchiveRelocationStage.paused);
        expect(
          result.deferredReason,
          AttachmentArchiveRelocationDeferredReason.insufficientCapacity,
        );
        expect(result.filesCopied, 0);
        await _expectTreeUnchanged(sourceRoot, expectedSource);
      },
    );

    test('cancellation leaves the authoritative source untouched', () async {
      final expectedSource = await _createSyntheticArchive(
        sourceRoot: sourceRoot,
        overlayDatabase: overlayDatabase,
      );
      final service = buildService();
      final selection = await withRelocationCapability(
        (capability) => service.selectDestination(
          destinationParentPath: destinationParent.path,
          mutationCapability: capability,
        ),
      );

      final result = await withRelocationCapability(
        (capability) => service.cancel(
          operationId: selection.operationId,
          mutationCapability: capability,
        ),
      );

      expect(result.stage, AttachmentArchiveRelocationStage.cancelled);
      final currentLocation = await container.read(
        attachmentArchiveLocationProvider.future,
      );
      expect(
        currentLocation.configuration,
        const AttachmentArchiveLocationConfiguration.defaultInternal(),
      );
      await _expectTreeUnchanged(sourceRoot, expectedSource);
    });

    test(
      'source and destination disconnects pause with exact typed reasons',
      () async {
        final expectedSource = await _createSyntheticArchive(
          sourceRoot: sourceRoot,
          overlayDatabase: overlayDatabase,
        );
        final service = buildService();
        final selection = await withRelocationCapability(
          (capability) => service.selectDestination(
            destinationParentPath: destinationParent.path,
            mutationCapability: capability,
          ),
        );
        await withRelocationCapability(
          (capability) => service.run(
            operationId: selection.operationId,
            mutationCapability: capability,
            pauseAfterNewlyCopiedFiles: 1,
          ),
        );

        final offlineDestination = Directory(
          '${destinationParent.path}.offline',
        );
        destinationParent.renameSync(offlineDestination.path);
        final destinationPaused = await withRelocationCapability(
          (capability) => service.run(
            operationId: selection.operationId,
            mutationCapability: capability,
          ),
        );
        expect(
          destinationPaused.deferredReason,
          AttachmentArchiveRelocationDeferredReason.destinationUnavailable,
        );
        offlineDestination.renameSync(destinationParent.path);

        final offlineSource = Directory('${sourceRoot.path}.offline');
        sourceRoot.renameSync(offlineSource.path);
        final sourcePaused = await withRelocationCapability(
          (capability) => service.run(
            operationId: selection.operationId,
            mutationCapability: capability,
          ),
        );
        expect(
          sourcePaused.deferredReason,
          AttachmentArchiveRelocationDeferredReason.sourceUnavailable,
        );
        offlineSource.renameSync(sourceRoot.path);
        await _expectTreeUnchanged(sourceRoot, expectedSource);
      },
    );
  });
}

final class _PathBookmarkNativeAdapter
    implements AttachmentArchiveLocationNativeAdapter {
  var capacityBytes = 20 * 1024 * 1024 * 1024;

  @override
  Future<int> availableCapacityForImportantUsage(String directoryPath) async {
    return capacityBytes;
  }

  @override
  Future<AttachmentArchiveBookmarkCreation> createBookmark({
    required String directoryPath,
  }) async {
    final resolved = Directory(directoryPath).resolveSymbolicLinksSync();
    return AttachmentArchiveBookmarkCreation(
      bookmarkDataBase64: base64Encode(utf8.encode(resolved)),
      resolvedPath: resolved,
      volumeName: 'Disposable',
    );
  }

  @override
  Stream<AttachmentArchiveLocationEvent> get locationEvents =>
      const Stream<AttachmentArchiveLocationEvent>.empty();

  @override
  Future<AttachmentArchiveBookmarkResolution> resolveBookmark({
    required String bookmarkDataBase64,
  }) async {
    final resolved = utf8.decode(base64Decode(bookmarkDataBase64));
    if (!Directory(resolved).existsSync()) {
      return const AttachmentArchiveBookmarkResolution(
        status: AttachmentArchiveBookmarkResolutionStatus.unavailable,
        issue: 'Disposable bookmark target is unavailable.',
      );
    }
    return AttachmentArchiveBookmarkResolution(
      status: AttachmentArchiveBookmarkResolutionStatus.available,
      resolvedPath: Directory(resolved).resolveSymbolicLinksSync(),
      volumeName: 'Disposable',
    );
  }
}

Future<Map<String, List<int>>> _createSyntheticArchive({
  required Directory sourceRoot,
  required OverlayDatabase overlayDatabase,
}) async {
  final hashedBytes = utf8.encode('metadata-known-hashed');
  final hashedDigest = sha256.convert(hashedBytes).toString();
  final nullHashBytes = utf8.encode('metadata-known-null-hash');
  final nullHashName = sha256.convert(nullHashBytes).toString();
  final unreferencedBytes = utf8.encode('unreferenced-preservation-payload');
  final unreferencedDigest = sha256.convert(unreferencedBytes).toString();
  final nestedBytes = utf8.encode('nested-metadata-known');
  final payloads = <String, List<int>>{
    'ab/$hashedDigest.txt': hashedBytes,
    '12/$nullHashName.bin': nullHashBytes,
    'cd/$unreferencedDigest.dat': unreferencedBytes,
    'nested/valid/payload.bin': nestedBytes,
  };
  for (final entry in payloads.entries) {
    final file = File('${sourceRoot.path}/${entry.key}');
    file.parent.createSync(recursive: true);
    file.writeAsBytesSync(entry.value, flush: true);
  }

  await _insertMetadata(
    overlayDatabase,
    guid: 'hashed-one',
    attachmentId: 1,
    relativePath: 'ab/$hashedDigest.txt',
    size: hashedBytes.length,
    hash: hashedDigest,
  );
  await _insertMetadata(
    overlayDatabase,
    guid: 'hashed-two',
    attachmentId: 2,
    relativePath: 'ab/$hashedDigest.txt',
    size: hashedBytes.length,
    hash: hashedDigest,
  );
  await _insertMetadata(
    overlayDatabase,
    guid: 'null-hash',
    attachmentId: 3,
    relativePath: '12/$nullHashName.bin',
    size: nullHashBytes.length,
    hash: null,
  );
  await _insertMetadata(
    overlayDatabase,
    guid: 'nested',
    attachmentId: 4,
    relativePath: 'nested/valid/payload.bin',
    size: nestedBytes.length,
    hash: null,
  );
  return payloads;
}

Future<void> _insertMetadata(
  OverlayDatabase database, {
  required String guid,
  required int attachmentId,
  required String relativePath,
  required int size,
  required String? hash,
}) {
  return database.customStatement(
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
      guid,
      attachmentId,
      relativePath,
      '2026-09-17T00:00:00.000Z',
      size,
      hash,
      'archived',
    ],
  );
}

Future<void> _expectTreeUnchanged(
  Directory root,
  Map<String, List<int>> expected,
) async {
  final actual = <String, List<int>>{};
  await for (final entity in root.list(recursive: true, followLinks: false)) {
    if (entity is File) {
      actual[pathRelative(entity.path, root.path)] = entity.readAsBytesSync();
    }
  }
  expect(actual.keys.toSet(), expected.keys.toSet());
  for (final entry in expected.entries) {
    expect(actual[entry.key], entry.value, reason: entry.key);
  }
}

String pathRelative(String filePath, String rootPath) {
  final prefix = rootPath.endsWith(Platform.pathSeparator)
      ? rootPath
      : '$rootPath${Platform.pathSeparator}';
  if (!filePath.startsWith(prefix)) {
    throw StateError('Disposable payload escaped its expected root.');
  }
  return filePath.substring(prefix.length);
}
