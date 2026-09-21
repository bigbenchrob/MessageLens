import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_mutation_operation.dart';
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart'
    show
        ArchiveMutationCoordinator,
        admittedArchiveAccessAuthorityProvider,
        archiveMutationCoordinatorProvider;
import 'package:remember_this_text/essentials/db/feature_level_providers.dart'
    show overlayDatabaseProvider;
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/navigation/domain/sidebar_mode.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_action_dispatcher.dart';
import 'package:remember_this_text/essentials/sidebar/domain/sidebar_action_intent.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_adoption_authority.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_adoption_enablement_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_adoption_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_adoption_service.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_adoption_workflow.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_adoption_workflow_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_approval_revalidator.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_bookmark_adapter.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_location_dependencies_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_location_folder_chooser.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_location_native_adapter.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_location_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_showcase_source_provider.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_adoption.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_candidate_verification.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_configuration.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_state.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/filesystem_attachment_archive_adoption_root_inspector.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/filesystem_attachment_archive_adoption_transaction_store.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/filesystem_attachment_archive_candidate_verifier.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/filesystem_attachment_archive_file_store.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/overlay_attachment_archive_verification_metadata_reader.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/payloads/attachment_archive_settings_cassette_payload.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/resolvers/attachment_archive_settings_resolver.dart';

import '../../../test_support/test_archive_fixture.dart';

void main() {
  test(
    'disposable Settings flow requires Check Again then adopts retained copy',
    () async {
      final harness = await _SettingsHarness.create();
      addTearDown(harness.dispose);
      final initialSource = await _payloadSnapshot(harness.source);
      final initialCandidate = await _payloadSnapshot(harness.candidate);

      var payload = harness.resolveSettings();
      expect(payload.actions.single.label, 'Choose Archive Copy…');
      await harness.dispatch(payload.actions.single.intent);

      payload = harness.resolveSettings();
      expect(payload.workflowView, _View.candidateComplete);
      expect(payload.actions.last.label, 'Use This Copy');
      expect(await harness.transactionStore.readPending(), isNull);
      expect(await _payloadSnapshot(harness.source), initialSource);
      expect(await _payloadSnapshot(harness.candidate), initialCandidate);

      await harness.addNewSourcePayload();
      final sourceBeforeAdoption = await _payloadSnapshot(harness.source);
      await harness.dispatch(payload.actions.last.intent);

      payload = harness.resolveSettings();
      expect(payload.workflowView, _View.archiveChanged);
      expect(payload.actions.single.label, 'Check Again');
      expect(
        (await harness.readLocation()).configuration?.mode,
        AttachmentArchiveLocationMode.defaultInternal,
      );

      await harness.updateCandidateCopy();
      await harness.dispatch(payload.actions.single.intent);
      payload = harness.resolveSettings();
      expect(payload.workflowView, _View.candidateComplete);
      expect(payload.workflowTitle, 'Archive copy verified');
      final candidateBeforeAdoption = await _payloadSnapshot(harness.candidate);

      await harness.dispatch(payload.actions.last.intent);

      payload = harness.resolveSettings();
      expect(payload.workflowView, _View.success);
      expect(payload.workflowTitle, 'Attachment archive switched');
      expect(
        payload.workflowBodyText,
        contains('Your original archive remains unchanged'),
      );
      final location = await harness.readLocation();
      expect(
        location.availability,
        AttachmentArchiveLocationAvailability.customAvailable,
      );
      expect(
        await Directory(location.archiveRootPath!).resolveSymbolicLinks(),
        await harness.candidate.resolveSymbolicLinks(),
      );
      expect(
        location.configuration?.customWritePolicy,
        AttachmentArchiveCustomWritePolicy.activeArchive,
      );

      final admission = await harness.container.read(
        attachmentArchiveWritableRootAdmissionProvider.future,
      );
      expect(admission.isAdmitted, isTrue);
      final lease = admission.lease;
      if (lease == null) {
        throw StateError('Successful adoption did not issue a writable lease.');
      }
      expect(
        await Directory(lease.archiveRootPath).resolveSymbolicLinks(),
        await harness.candidate.resolveSymbolicLinks(),
      );
      expect(lease.locationMode, AttachmentArchiveLocationMode.customExternal);
      expect(lease.permitsDestructiveReset, isFalse);

      expect(await _payloadSnapshot(harness.source), sourceBeforeAdoption);
      expect(
        await _payloadSnapshot(harness.candidate),
        candidateBeforeAdoption,
      );
      expect(await harness.transactionStore.readPending(), isNull);
      expect(harness.legacyRelocationDirectory.existsSync(), isFalse);
    },
  );

  test(
    'disposable behind flow hashes only additions then reaches stable success',
    () async {
      final harness = await _SettingsHarness.create();
      addTearDown(harness.dispose);
      final historicalPaths = <String>[];
      for (var index = 0; index < 3; index++) {
        historicalPaths.add(
          await harness.addSourcePayload(
            relativePath: '_by_id/${100 + index}.png',
            bytes: <int>[20 + index, index, 7],
            attachmentId: 100 + index,
          ),
        );
      }
      final sourceBeforeReview = await _payloadSnapshot(harness.source);
      final observedStates = <AttachmentArchiveAdoptionWorkflowState>[];
      final subscription = harness.container.listen(
        attachmentArchiveAdoptionWorkflowProvider,
        (previous, next) => observedStates.add(next),
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      var payload = harness.resolveSettings();
      await harness.dispatch(payload.actions.single.intent);
      payload = harness.resolveSettings();
      expect(payload.workflowView, _View.candidateBehind);
      expect(
        harness.container
            .read(attachmentArchiveAdoptionWorkflowProvider)
            .missingCount,
        historicalPaths.length,
      );
      expect(
        observedStates
            .where((state) => state.stage == _Stage.checking)
            .map((state) => state.progress)
            .whereType<AttachmentArchiveVerificationProgress>()
            .any((progress) => progress.isDeterminate),
        isTrue,
      );

      harness.payloadHashStarts.clear();
      final addedPaths = <String>[];
      for (var index = 0; index < 2; index++) {
        addedPaths.add(
          await harness.addSourcePayload(
            relativePath: '_by_id/${200 + index}.png',
            bytes: <int>[40 + index, index, 9],
            attachmentId: 200 + index,
          ),
        );
      }
      final sourceBeforeAdoption = await _payloadSnapshot(harness.source);
      int? approvalHashCount;
      final approvalSubscription = harness.container.listen(
        attachmentArchiveAdoptionWorkflowProvider,
        (previous, next) {
          if (next.stage == _Stage.switching && next.progress != null) {
            approvalHashCount ??= harness.payloadHashStarts.length;
          }
        },
      );
      addTearDown(approvalSubscription.close);

      await harness.workflow.useCandidate();

      expect(approvalHashCount, addedPaths.length);
      expect(harness.payloadHashStarts.take(approvalHashCount!).toSet(), {
        for (final relativePath in addedPaths)
          path.join(harness.source.path, relativePath),
      });
      expect(
        observedStates.any(
          (state) =>
              state.stage == _Stage.remediating &&
              state.remediationProgress?.totalFiles ==
                  historicalPaths.length + addedPaths.length,
        ),
        isTrue,
      );
      expect(
        observedStates.any(
          (state) =>
              state.stage == _Stage.verifyingFinalCoverage &&
              (state.progress?.isDeterminate ?? false),
        ),
        isTrue,
      );
      expect(
        harness.container.read(attachmentArchiveAdoptionWorkflowProvider).stage,
        _Stage.success,
      );
      expect(
        await harness.container.read(
          attachmentArchivePendingAdoptionTransactionProvider.future,
        ),
        isNull,
      );
      final showcase = harness.container.read(attachmentShowcaseSourceProvider);
      expect(showcase, isNotNull);
      expect(showcase!.resolvedPath, startsWith(harness.candidate.path));

      harness.container.invalidate(
        attachmentArchivePendingAdoptionTransactionProvider,
      );
      expect(
        await harness.container.read(
          attachmentArchivePendingAdoptionTransactionProvider.future,
        ),
        isNull,
      );
      await _flushAsync();
      expect(
        harness.container.read(attachmentArchiveAdoptionWorkflowProvider).stage,
        _Stage.success,
      );

      final ordinarySource = await _write(
        harness.fixture.root,
        'ordinary-ingestion.bin',
        <int>[91, 92, 93],
      );
      final admission = await harness.container.read(
        attachmentArchiveWritableRootAdmissionProvider.future,
      );
      final ordinaryWrite = await const FilesystemAttachmentArchiveFileStore()
          .writeArchiveEntry(
            archiveDirectoryPath: admission.lease!.archiveRootPath,
            sourcePath: ordinarySource.path,
            archiveKey: const ArchiveCompatibilityKey(
              messageGuid: 'disposable-post-adoption-write',
              importAttachmentId: 999,
            ),
            sha256Hex: null,
            validateMutation: (boundary) => admission.lease!.requireValid(
              operation: ArchiveMutationOperation.attachmentReconciliation,
              boundary: boundary,
            ),
          );
      expect(
        await Directory(
          admission.lease!.archiveRootPath,
        ).resolveSymbolicLinks(),
        await harness.candidate.resolveSymbolicLinks(),
      );
      expect(ordinaryWrite, isNotNull);
      expect(
        File(
          path.join(harness.candidate.path, ordinaryWrite!.relativePath),
        ).existsSync(),
        isTrue,
      );
      expect(await _payloadSnapshot(harness.source), sourceBeforeAdoption);
      expect(sourceBeforeAdoption.length, sourceBeforeReview.length + 2);
      for (final relativePath in <String>[...historicalPaths, ...addedPaths]) {
        expect(
          File(path.join(harness.candidate.path, relativePath)).existsSync(),
          isTrue,
        );
      }
      expect(harness.legacyRelocationDirectory.existsSync(), isFalse);
    },
  );

  test(
    'disposable Settings transaction failure restores previous location',
    () async {
      final harness = await _SettingsHarness.create(
        failurePoint:
            AttachmentArchiveAdoptionFailurePoint.afterConfigurationPersistence,
      );
      addTearDown(harness.dispose);

      var payload = harness.resolveSettings();
      await harness.dispatch(payload.actions.single.intent);
      payload = harness.resolveSettings();
      expect(payload.workflowView, _View.candidateComplete);
      final sourceBefore = await _payloadSnapshot(harness.source);
      final candidateBefore = await _payloadSnapshot(harness.candidate);

      await harness.dispatch(payload.actions.last.intent);

      payload = harness.resolveSettings();
      expect(payload.workflowView, _View.rollbackRestoredPrevious);
      expect(
        payload.workflowBodyText,
        contains('restored the previous archive'),
      );
      expect(
        payload.workflowTitle,
        isNot(contains('Attachment archive switched')),
      );
      final location = await harness.readLocation();
      expect(
        location.configuration?.mode,
        AttachmentArchiveLocationMode.defaultInternal,
      );
      expect(await harness.transactionStore.readPending(), isNull);
      expect(await _payloadSnapshot(harness.source), sourceBefore);
      expect(await _payloadSnapshot(harness.candidate), candidateBefore);
      expect(harness.legacyRelocationDirectory.existsSync(), isFalse);
    },
  );

  test('disposable Settings flow reports an unavailable candidate', () async {
    final harness = await _SettingsHarness.create();
    addTearDown(harness.dispose);
    harness.nativeAdapter.resolutionStatus =
        AttachmentArchiveBookmarkResolutionStatus.unavailable;

    final initial = harness.resolveSettings();
    await harness.dispatch(initial.actions.single.intent);

    final payload = harness.resolveSettings();
    expect(payload.workflowView, _View.candidateUnavailable);
    expect(payload.workflowTitle, contains('unavailable'));
    expect(
      payload.actions.map((action) => action.label),
      containsAll(<String>['Choose a Different Copy', 'Try Again']),
    );
    expect(
      (await harness.readLocation()).configuration?.mode,
      AttachmentArchiveLocationMode.defaultInternal,
    );
    expect(await harness.transactionStore.readPending(), isNull);
    expect(harness.legacyRelocationDirectory.existsSync(), isFalse);
  });
}

typedef _View = AttachmentArchiveSettingsWorkflowView;

final class _SettingsHarness {
  _SettingsHarness._({
    required this.fixture,
    required this.source,
    required this.candidate,
    required this.database,
    required this.nativeAdapter,
    required this.verifier,
    required this.transactionStore,
    required this.payloadHashStarts,
    required this.container,
    required this.failurePoint,
  });

  static const _initialRelativePath = 'nested/initial.bin';
  static const _newRelativePath = 'nested/new.bin';
  static final _clock = DateTime.utc(2026, 9, 19, 12);

  final TestArchiveFixture fixture;
  final Directory source;
  final Directory candidate;
  final OverlayDatabase database;
  final _FakeNativeAdapter nativeAdapter;
  final FilesystemAttachmentArchiveCandidateVerifier verifier;
  final FilesystemAttachmentArchiveAdoptionTransactionStore transactionStore;
  final List<String> payloadHashStarts;
  final ProviderContainer container;
  final AttachmentArchiveAdoptionFailurePoint? failurePoint;

  Directory get legacyRelocationDirectory => Directory(
    path.join(fixture.root.path, '.attachment_archive_relocations'),
  );

  AttachmentArchiveAdoptionWorkflow get workflow =>
      container.read(attachmentArchiveAdoptionWorkflowProvider.notifier);

  ArchiveMutationCoordinator get coordinator =>
      container.read(archiveMutationCoordinatorProvider.notifier);

  AttachmentArchiveLocation get locationNotifier =>
      container.read(attachmentArchiveLocationProvider.notifier);

  static Future<_SettingsHarness> create({
    AttachmentArchiveAdoptionFailurePoint? failurePoint,
  }) async {
    final fixture = await TestArchiveFixture.create(
      prefix: 'settings_archive_adoption_e2e_',
    );
    final source = await Directory(
      fixture.authority.resolvePath('attachment_archive'),
    ).create();
    final candidate = await Directory(
      path.join(fixture.root.path, 'user-created-archive-copy'),
    ).create();
    const bytes = <int>[1, 2, 3, 4];
    await _write(source, _initialRelativePath, bytes);
    await _write(candidate, _initialRelativePath, bytes);

    final database = OverlayDatabase(NativeDatabase.memory());
    await _insertMetadata(
      database,
      messageGuid: 'initial-guid',
      attachmentId: 1,
      relativePath: _initialRelativePath,
      bytes: bytes,
    );
    final nativeAdapter = _FakeNativeAdapter(candidate.path);
    final payloadHashStarts = <String>[];
    final verifier = FilesystemAttachmentArchiveCandidateVerifier(
      metadataReader: OverlayAttachmentArchiveVerificationMetadataReader(
        overlayDatabase: database,
      ),
      clock: () => _clock,
      onPayloadHashStarted: payloadHashStarts.add,
    );
    final transactionStore =
        FilesystemAttachmentArchiveAdoptionTransactionStore(
          archiveAccessAuthority: fixture.authority,
        );

    late _SettingsHarness harness;
    final container = ProviderContainer(
      overrides: <Override>[
        admittedArchiveAccessAuthorityProvider.overrideWithValue(
          fixture.authority,
        ),
        overlayDatabaseProvider.overrideWith((ref) async => database),
        attachmentArchiveLocationNativeAdapterProvider.overrideWithValue(
          nativeAdapter,
        ),
        attachmentArchiveAdoptionExecutionEnabledProvider.overrideWith(
          (ref) => true,
        ),
        attachmentArchiveAdoptionFolderChooserProvider.overrideWithValue(
          _FakeFolderChooser(candidate.path),
        ),
        attachmentArchiveAdoptionCandidateVerifierProvider.overrideWith(
          (ref) async => verifier,
        ),
        attachmentArchiveAdoptionExecutorProvider.overrideWith(
          (ref) async => harness._adoptionService(),
        ),
      ],
    );
    harness = _SettingsHarness._(
      fixture: fixture,
      source: source,
      candidate: candidate,
      database: database,
      nativeAdapter: nativeAdapter,
      verifier: verifier,
      transactionStore: transactionStore,
      payloadHashStarts: payloadHashStarts,
      container: container,
      failurePoint: failurePoint,
    );
    await harness.readLocation();
    return harness;
  }

  AttachmentArchiveSettingsCassettePayload resolveSettings() {
    final location = container
        .read(attachmentArchiveLocationProvider)
        .valueOrNull;
    if (location == null) {
      throw StateError('Attachment archive location is not resolved.');
    }
    return container
        .read(attachmentArchiveSettingsResolverProvider.notifier)
        .resolve(
          cassetteIndex: 2,
          location: location,
          workflow: container.read(attachmentArchiveAdoptionWorkflowProvider),
        );
  }

  Future<void> dispatch(SidebarActionIntent intent) {
    return container
        .read(sidebarActionDispatcherProvider.notifier)
        .dispatch(
          intent: intent,
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.settings,
            cassetteIndex: 2,
          ),
        );
  }

  Future<void> addNewSourcePayload() async {
    const bytes = <int>[9, 8, 7, 6, 5];
    await _write(source, _newRelativePath, bytes);
    await _insertMetadata(
      database,
      messageGuid: 'new-guid',
      attachmentId: 2,
      relativePath: _newRelativePath,
      bytes: bytes,
    );
  }

  Future<String> addSourcePayload({
    required String relativePath,
    required List<int> bytes,
    required int attachmentId,
  }) async {
    await _write(source, relativePath, bytes);
    await _insertMetadata(
      database,
      messageGuid: 'payload-$attachmentId',
      attachmentId: attachmentId,
      relativePath: relativePath,
      bytes: bytes,
    );
    return relativePath;
  }

  Future<void> updateCandidateCopy() async {
    final bytes = await File(
      path.join(source.path, _newRelativePath),
    ).readAsBytes();
    await _write(candidate, _newRelativePath, bytes);
  }

  AttachmentArchiveAdoptionService _adoptionService() {
    return AttachmentArchiveAdoptionService(
      archiveAccessAuthority: fixture.authority,
      mutationCoordinator: coordinator,
      currentLocationReader: _ProviderLocationReader(container),
      snapshotReader: verifier,
      addedPayloadReader: verifier,
      transactionStore: transactionStore,
      authorityIssuer: AttachmentArchiveAdoptionAuthorityIssuer(
        transactionStore: transactionStore,
      ),
      bookmarkAdapter: nativeAdapter,
      rootInspector: const FilesystemAttachmentArchiveAdoptionRootInspector(),
      readLocation: readLocation,
      activateLocation: ({required configuration, required adoptionAuthority}) {
        return locationNotifier.activateVerifiedAdoption(
          configuration: configuration,
          adoptionAuthority: adoptionAuthority,
        );
      },
      restoreLocation: ({required configuration, required adoptionAuthority}) {
        return locationNotifier.restoreAdoptionConfiguration(
          configuration: configuration,
          adoptionAuthority: adoptionAuthority,
        );
      },
      readWritableAdmission: () =>
          container.read(attachmentArchiveWritableRootAdmissionProvider.future),
      newTransactionId: () => '11111111-1111-4111-8111-111111111111',
      clock: () => _clock,
      failureInjector: (point) async {
        if (point == failurePoint) {
          throw StateError('injected ${point.name}');
        }
      },
      candidateVerifier: verifier,
      fileStore: const FilesystemAttachmentArchiveFileStore(),
      onShowcaseItem: (item) {
        container.read(attachmentShowcaseSourceProvider.notifier).offer(item);
      },
    );
  }

  Future<AttachmentArchiveLocationState> readLocation() {
    return container.read(attachmentArchiveLocationProvider.future);
  }

  Future<void> dispose() async {
    container.dispose();
    await nativeAdapter.dispose();
    await database.close();
    await fixture.dispose();
  }
}

typedef _Stage = AttachmentArchiveAdoptionWorkflowStage;

Future<void> _flushAsync() {
  return Future<void>.delayed(Duration.zero);
}

final class _ProviderLocationReader
    implements AttachmentArchiveApprovalCurrentLocationReader {
  const _ProviderLocationReader(this.container);

  final ProviderContainer container;

  @override
  Future<AttachmentArchiveLocationState> readCurrentLocation() {
    return container.read(attachmentArchiveLocationProvider.future);
  }
}

final class _FakeFolderChooser
    implements AttachmentArchiveLocationFolderChooser {
  const _FakeFolderChooser(this.path);

  final String path;

  @override
  Future<String?> chooseArchiveDirectory() async => path;
}

final class _FakeNativeAdapter
    implements AttachmentArchiveLocationNativeAdapter {
  _FakeNativeAdapter(this.candidatePath);

  final String candidatePath;
  final StreamController<AttachmentArchiveLocationEvent> _events =
      StreamController<AttachmentArchiveLocationEvent>.broadcast();
  AttachmentArchiveBookmarkResolutionStatus resolutionStatus =
      AttachmentArchiveBookmarkResolutionStatus.available;

  @override
  Future<AttachmentArchiveBookmarkCreation> createBookmark({
    required String directoryPath,
  }) async {
    return AttachmentArchiveBookmarkCreation(
      bookmarkDataBase64: base64Encode(utf8.encode(candidatePath)),
      resolvedPath: candidatePath,
      volumeName: 'Disposable',
    );
  }

  @override
  Future<AttachmentArchiveBookmarkResolution> resolveBookmark({
    required String bookmarkDataBase64,
  }) async {
    return AttachmentArchiveBookmarkResolution(
      status: resolutionStatus,
      resolvedPath:
          resolutionStatus ==
              AttachmentArchiveBookmarkResolutionStatus.available
          ? candidatePath
          : null,
      volumeName: 'Disposable',
      issue:
          resolutionStatus ==
              AttachmentArchiveBookmarkResolutionStatus.unavailable
          ? 'The selected archive copy is unavailable.'
          : null,
    );
  }

  @override
  Stream<AttachmentArchiveLocationEvent> get locationEvents => _events.stream;

  Future<void> dispose() => _events.close();
}

Future<void> _insertMetadata(
  OverlayDatabase database, {
  required String messageGuid,
  required int attachmentId,
  required String relativePath,
  required List<int> bytes,
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
      messageGuid,
      attachmentId,
      relativePath,
      _SettingsHarness._clock.toIso8601String(),
      bytes.length,
      sha256.convert(bytes).toString(),
      'archived',
    ],
  );
}

Future<File> _write(
  Directory root,
  String relativePath,
  List<int> bytes,
) async {
  final file = File(path.join(root.path, relativePath));
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes, flush: true);
  return file;
}

Future<Map<String, String>> _payloadSnapshot(Directory root) async {
  final result = <String, String>{};
  await for (final entity in root.list(recursive: true, followLinks: false)) {
    if (entity is File) {
      result[path.relative(entity.path, from: root.path)] = sha256
          .convert(await entity.readAsBytes())
          .toString();
    }
  }
  return Map<String, String>.fromEntries(
    result.entries.toList()
      ..sort((left, right) => left.key.compareTo(right.key)),
  );
}
