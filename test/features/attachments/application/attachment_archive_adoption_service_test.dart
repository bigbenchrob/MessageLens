import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/archive_environment/domain/archive_mutation_denied_exception.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_mutation_operation.dart';
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart'
    show
        ArchiveMutationCoordinator,
        admittedArchiveAccessAuthorityProvider,
        archiveMutationCoordinatorProvider;
import 'package:remember_this_text/essentials/db/feature_level_providers.dart'
    show overlayDatabaseProvider;
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_adoption_authority.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_adoption_recovery_service.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_adoption_root_inspector.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_adoption_service.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_approval_revalidator.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_approval_snapshot_reader.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_bookmark_adapter.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_location_controller.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_location_dependencies_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_location_native_adapter.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_location_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_settings_store_provider.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_adoption.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_candidate_verification.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_configuration.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_state.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/filesystem_attachment_archive_adoption_root_inspector.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/filesystem_attachment_archive_adoption_transaction_store.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/filesystem_attachment_archive_candidate_verifier.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/overlay_attachment_archive_verification_metadata_reader.dart';

import '../../../test_support/test_archive_fixture.dart';

void main() {
  group('AttachmentArchiveAdoptionService', () {
    late _Harness harness;

    setUp(() async {
      harness = await _Harness.create();
    });

    tearDown(() => harness.dispose());

    test(
      'adopts through one scope and proves normal writable-root authority',
      () async {
        final complete = await harness.verifyComplete();
        final sourceBefore = await _payloadSnapshot(harness.source);
        final candidateBefore = await _payloadSnapshot(harness.candidate);

        final result = await harness.service().adopt(complete);

        expect(result.outcome, AttachmentArchiveAdoptionOutcome.adopted);
        final location = await harness.readLocation();
        expect(
          location.availability,
          AttachmentArchiveLocationAvailability.customAvailable,
        );
        expect(
          location.configuration!.customWritePolicy,
          AttachmentArchiveCustomWritePolicy.activeArchive,
        );
        expect(
          await Directory(location.archiveRootPath!).resolveSymbolicLinks(),
          await harness.candidate.resolveSymbolicLinks(),
        );
        expect(location.generation, 1);
        expect(await harness.transactionStore.readPending(), isNull);
        expect(harness.coordinatorStateIsLocked, isFalse);
        expect(await _payloadSnapshot(harness.source), sourceBefore);
        expect(await _payloadSnapshot(harness.candidate), candidateBefore);
        expect(
          harness.steps,
          containsAllInOrder(<String>[
            'fresh-structural-revalidation',
            'bookmark-create',
            'bookmark-resolve',
            'activate-configuration',
            'candidate-post-switch-fingerprint',
            'writable-root-admission',
          ]),
        );
        expect(harness.everyCriticalStepWasCoordinated, isTrue);
        expect(
          () => harness.capturedAuthority!.requireRollbackConfiguration(
            const AttachmentArchiveLocationConfiguration.defaultInternal(),
          ),
          throwsA(anything),
          reason: 'The process-local authority expires with its async scope.',
        );
      },
    );

    test(
      'a supported competing mutation is denied between revalidation and switch',
      () async {
        final complete = await harness.verifyComplete();
        final bookmarkEntered = Completer<void>();
        final releaseBookmark = Completer<void>();
        harness.onBookmarkCreate = () async {
          bookmarkEntered.complete();
          await releaseBookmark.future;
        };

        final adoption = harness.service().adopt(complete);
        await bookmarkEntered.future;
        await expectLater(
          harness.coordinator.run<void>(
            operation: ArchiveMutationOperation.attachmentReconciliation,
            ownerLabel: 'competing-supported-ingestion',
            action: () async {},
          ),
          throwsA(isA<ArchiveMutationDeniedException>()),
        );
        releaseBookmark.complete();
        final result = await adoption;

        expect(result.outcome, AttachmentArchiveAdoptionOutcome.adopted);
      },
    );

    test('A: failure before pending write leaves no recovery state', () async {
      final complete = await harness.verifyComplete();
      final before = await harness.payloadSnapshots();
      final result = await harness
          .service(
            injector: _throwAt(
              AttachmentArchiveAdoptionFailurePoint
                  .beforePreparedTransactionWrite,
            ),
          )
          .adopt(complete);

      expect(result.outcome, AttachmentArchiveAdoptionOutcome.failed);
      expect(result.transactionId, isNull);
      await harness.expectDefaultAndNoPending();
      await harness.expectPayloadSnapshots(before);
    });

    for (final entry in <(String, AttachmentArchiveAdoptionFailurePoint)>[
      (
        'B: failure after prepared write',
        AttachmentArchiveAdoptionFailurePoint.afterPreparedTransactionWrite,
      ),
      (
        'C: failure before configuration persistence',
        AttachmentArchiveAdoptionFailurePoint.beforeConfigurationPersistence,
      ),
      (
        'D: failure immediately after configuration persistence',
        AttachmentArchiveAdoptionFailurePoint.afterConfigurationPersistence,
      ),
      (
        'E: failure after configurationPersisted durable state',
        AttachmentArchiveAdoptionFailurePoint.afterConfigurationPersistedWrite,
      ),
      (
        'F: failure during new-location resolution',
        AttachmentArchiveAdoptionFailurePoint.beforeNewLocationResolution,
      ),
      (
        'H: failure before writable-root admission',
        AttachmentArchiveAdoptionFailurePoint.beforeWritableRootAdmission,
      ),
      (
        'I: writable-root validation failure',
        AttachmentArchiveAdoptionFailurePoint.beforeWritableRootValidation,
      ),
    ]) {
      test('${entry.$1} rolls back without touching payloads', () async {
        final complete = await harness.verifyComplete();
        final before = await harness.payloadSnapshots();

        final result = await harness
            .service(injector: _throwAt(entry.$2))
            .adopt(complete);

        expect(
          result.outcome,
          AttachmentArchiveAdoptionOutcome.rollbackRestoredPrevious,
        );
        await harness.expectDefaultAndNoPending();
        await harness.expectPayloadSnapshots(before);
      });
    }

    test(
      'G: candidate change after switch is detected and rolled back',
      () async {
        final complete = await harness.verifyComplete();
        final sourceBefore = await _payloadSnapshot(harness.source);
        final changedCandidate = File(
          path.join(harness.candidate.path, _Harness.relativePayloadPath),
        );

        final result = await harness
            .service(
              injector: (point) async {
                if (point ==
                    AttachmentArchiveAdoptionFailurePoint
                        .beforePostSwitchCandidateFingerprint) {
                  await changedCandidate.writeAsBytes(<int>[
                    9,
                    9,
                    9,
                    9,
                  ], flush: true);
                  await changedCandidate.setLastModified(
                    DateTime.utc(2032, 1, 2, 3, 4, 5),
                  );
                }
              },
            )
            .adopt(complete);

        expect(
          result.outcome,
          AttachmentArchiveAdoptionOutcome.rollbackRestoredPrevious,
        );
        await harness.expectDefaultAndNoPending();
        expect(await _payloadSnapshot(harness.source), sourceBefore);
        expect(await changedCandidate.readAsBytes(), <int>[9, 9, 9, 9]);
        expect(harness.candidate.existsSync(), isTrue);
      },
    );

    test(
      'J: rollback persistence failure retains explicit recovery state',
      () async {
        final complete = await harness.verifyComplete();
        final before = await harness.payloadSnapshots();

        final result = await harness
            .service(
              injector: (point) async {
                if (point ==
                        AttachmentArchiveAdoptionFailurePoint
                            .afterConfigurationPersistence ||
                    point ==
                        AttachmentArchiveAdoptionFailurePoint
                            .beforeRollbackConfigurationPersistence) {
                  throw StateError('injected ${point.name}');
                }
              },
            )
            .adopt(complete);

        expect(result.outcome, AttachmentArchiveAdoptionOutcome.failed);
        expect(result.requiresRecovery, isTrue);
        expect(await harness.transactionStore.readPending(), isNotNull);
        expect(
          (await harness.readLocation()).configuration!.customWritePolicy,
          AttachmentArchiveCustomWritePolicy.activeArchive,
        );
        await harness.expectPayloadSnapshots(before);

        final recovered = await harness.recoveryService().recoverPending();
        expect(
          recovered.outcome,
          AttachmentArchiveAdoptionOutcome.rollbackRestoredPrevious,
        );
        await harness.expectDefaultAndNoPending();
      },
    );

    test(
      'K: unavailable previous source remains pending until retry',
      () async {
        final complete = await harness.verifyComplete();
        final before = await harness.payloadSnapshots();
        final result = await harness
            .service(
              injector: (point) async {
                if (point ==
                    AttachmentArchiveAdoptionFailurePoint
                        .afterConfigurationPersistence) {
                  harness.rootInspector.previousUnavailable = true;
                  throw StateError('force rollback');
                }
              },
            )
            .adopt(complete);

        expect(
          result.outcome,
          AttachmentArchiveAdoptionOutcome.rollbackPendingPreviousUnavailable,
        );
        expect(result.requiresRecovery, isTrue);
        expect(await harness.transactionStore.readPending(), isNotNull);
        expect(
          (await harness.readLocation()).configuration!.customWritePolicy,
          AttachmentArchiveCustomWritePolicy.activeArchive,
        );
        await harness.expectPayloadSnapshots(before);

        harness.rootInspector.previousUnavailable = false;
        final recovered = await harness.recoveryService().recoverPending();
        expect(
          recovered.outcome,
          AttachmentArchiveAdoptionOutcome.rollbackRestoredPrevious,
        );
        await harness.expectDefaultAndNoPending();
      },
    );

    test('L: unrelated configuration during recovery fails closed', () async {
      final complete = await harness.verifyComplete();
      final before = await harness.payloadSnapshots();
      await harness
          .service(
            injector: (point) async {
              if (point ==
                      AttachmentArchiveAdoptionFailurePoint
                          .afterConfigurationPersistence ||
                  point ==
                      AttachmentArchiveAdoptionFailurePoint
                          .beforeRollbackConfigurationPersistence) {
                throw StateError('leave pending');
              }
            },
          )
          .adopt(complete);
      final unrelated = await Directory(
        path.join(harness.fixture.root.path, 'unrelated'),
      ).create();
      harness.nativeAdapter.creationPath = unrelated.path;
      harness.nativeAdapter.resolutionPath = unrelated.path;
      await harness.locationNotifier.configureCustomLocation(
        directoryPath: unrelated.path,
      );

      final result = await harness.recoveryService().recoverPending();

      expect(
        result.outcome,
        AttachmentArchiveAdoptionOutcome.configurationConflict,
      );
      expect(result.requiresRecovery, isTrue);
      expect(await harness.transactionStore.readPending(), isNotNull);
      await harness.expectPayloadSnapshots(before);
    });

    test(
      'prepared transaction with previous configuration is safely abandoned',
      () async {
        final complete = await harness.verifyComplete();
        await harness.writePreparedTransaction(complete);

        final result = await harness.recoveryService().recoverPending();

        expect(
          result.outcome,
          AttachmentArchiveAdoptionOutcome.preparedTransactionAbandoned,
        );
        await harness.expectDefaultAndNoPending();
      },
    );

    test(
      'bookmark read-only result aborts before configuration mutation',
      () async {
        final complete = await harness.verifyComplete();
        harness.nativeAdapter.status =
            AttachmentArchiveBookmarkResolutionStatus.readOnly;

        final result = await harness.service().adopt(complete);

        expect(
          result.outcome,
          AttachmentArchiveAdoptionOutcome.candidateNoLongerWritable,
        );
        await harness.expectDefaultAndNoPending();
      },
    );

    test(
      'ordinary configuration persistence cannot activate a raw bookmark',
      () async {
        final settingsStore = await harness.container.read(
          attachmentArchiveSettingsStoreProvider.future,
        );
        final controller = AttachmentArchiveLocationController(
          archiveAccessAuthority: harness.fixture.authority,
          settingsStore: settingsStore,
          nativeAdapter: harness.nativeAdapter,
        );
        final arbitraryActive =
            AttachmentArchiveLocationConfiguration.customExternal(
              bookmarkDataBase64: base64Encode(
                utf8.encode(harness.candidate.path),
              ),
              lastKnownPath: harness.candidate.path,
              customWritePolicy:
                  AttachmentArchiveCustomWritePolicy.activeArchive,
            );

        await expectLater(
          controller.persistConfiguration(arbitraryActive),
          throwsStateError,
        );
        await harness.expectDefaultAndNoPending();
      },
    );

    test(
      'durable transaction is small, exact, and outside payload root',
      () async {
        final complete = await harness.verifyComplete();
        final sourceBefore = await _payloadSnapshot(harness.source);
        final prepared = harness.preparedTransaction(complete);

        await harness.transactionStore.writePending(prepared);

        final record = File(
          path.join(
            harness.fixture.root.path,
            FilesystemAttachmentArchiveAdoptionTransactionStore.recordFileName,
          ),
        );
        expect(record.existsSync(), isTrue);
        expect(path.isWithin(harness.source.path, record.path), isFalse);
        final serialized = await record.readAsString();
        expect(serialized, isNot(contains('manifest')));
        expect(serialized, isNot(contains('receipt')));
        expect(serialized, isNot(contains('progress')));
        expect(serialized, isNot(contains('staging')));
        expect(await harness.transactionStore.readPending(), isNotNull);

        await harness.transactionStore.writePending(
          prepared.withState(
            AttachmentArchiveAdoptionTransactionState.configurationPersisted,
            updatedAtUtc: _Harness.fixedTime.add(const Duration(seconds: 1)),
          ),
        );
        expect(
          (await harness.transactionStore.readPending())!.state,
          AttachmentArchiveAdoptionTransactionState.configurationPersisted,
        );
        await expectLater(
          harness.transactionStore.writePending(
            harness.preparedTransaction(
              complete,
              id: '22222222-2222-4222-8222-222222222222',
            ),
          ),
          throwsStateError,
        );
        await expectLater(
          harness.transactionStore.clearPending(
            expectedTransactionId: '22222222-2222-4222-8222-222222222222',
          ),
          throwsStateError,
        );
        expect(await _payloadSnapshot(harness.source), sourceBefore);
        await harness.transactionStore.clearPending(
          expectedTransactionId: _Harness.transactionId,
        );
        expect(record.existsSync(), isFalse);
      },
    );
  });
}

AttachmentArchiveAdoptionFailureInjector _throwAt(
  AttachmentArchiveAdoptionFailurePoint selected,
) {
  return (point) async {
    if (point == selected) {
      throw StateError('injected ${point.name}');
    }
  };
}

final class _Harness {
  _Harness._({
    required this.fixture,
    required this.source,
    required this.candidate,
    required this.database,
    required this.nativeAdapter,
    required this.container,
    required this.verifier,
    required this.transactionStore,
    required this.rootInspector,
  });

  static const relativePayloadPath = 'nested/payload.bin';
  static const transactionId = '11111111-1111-4111-8111-111111111111';
  static final fixedTime = DateTime.utc(2026, 9, 18, 12);

  final TestArchiveFixture fixture;
  final Directory source;
  final Directory candidate;
  final OverlayDatabase database;
  final _FakeNativeAdapter nativeAdapter;
  final ProviderContainer container;
  final FilesystemAttachmentArchiveCandidateVerifier verifier;
  final FilesystemAttachmentArchiveAdoptionTransactionStore transactionStore;
  final _ControllableRootInspector rootInspector;
  final List<String> steps = <String>[];
  final List<bool> coordinatedSteps = <bool>[];
  Future<void> Function()? onBookmarkCreate;
  AttachmentArchiveAdoptionConfigurationAuthority? capturedAuthority;

  ArchiveMutationCoordinator get coordinator =>
      container.read(archiveMutationCoordinatorProvider.notifier);

  bool get coordinatorStateIsLocked =>
      container.read(archiveMutationCoordinatorProvider).isLocked;

  bool get everyCriticalStepWasCoordinated =>
      coordinatedSteps.isNotEmpty && coordinatedSteps.every((value) => value);

  AttachmentArchiveLocation get locationNotifier =>
      container.read(attachmentArchiveLocationProvider.notifier);

  static Future<_Harness> create() async {
    final fixture = await TestArchiveFixture.create(
      prefix: 'attachment_adoption_transaction_',
    );
    final source = await Directory(
      fixture.authority.resolvePath('attachment_archive'),
    ).create();
    final candidate = await Directory(
      path.join(fixture.root.path, 'verified-candidate'),
    ).create();
    final bytes = <int>[1, 2, 3, 4];
    await _write(source, relativePayloadPath, bytes);
    await _write(candidate, relativePayloadPath, bytes);

    final database = OverlayDatabase(NativeDatabase.memory());
    await database.customStatement(
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
        'adoption-payload-guid',
        1,
        relativePayloadPath,
        fixedTime.toIso8601String(),
        bytes.length,
        sha256.convert(bytes).toString(),
        'archived',
      ],
    );
    final nativeAdapter = _FakeNativeAdapter(candidate.path);
    final container = ProviderContainer(
      overrides: <Override>[
        admittedArchiveAccessAuthorityProvider.overrideWithValue(
          fixture.authority,
        ),
        overlayDatabaseProvider.overrideWith((ref) async => database),
        attachmentArchiveLocationNativeAdapterProvider.overrideWithValue(
          nativeAdapter,
        ),
      ],
    );
    final verifier = FilesystemAttachmentArchiveCandidateVerifier(
      metadataReader: OverlayAttachmentArchiveVerificationMetadataReader(
        overlayDatabase: database,
      ),
      clock: () => fixedTime,
    );
    final transactionStore =
        FilesystemAttachmentArchiveAdoptionTransactionStore(
          archiveAccessAuthority: fixture.authority,
        );
    final rootInspector = _ControllableRootInspector();
    late _Harness harness;
    harness = _Harness._(
      fixture: fixture,
      source: source,
      candidate: candidate,
      database: database,
      nativeAdapter: nativeAdapter,
      container: container,
      verifier: verifier,
      transactionStore: transactionStore,
      rootInspector: rootInspector,
    );
    nativeAdapter.onCreate = () async {
      harness._recordCoordinatedStep('bookmark-create');
      await harness.onBookmarkCreate?.call();
    };
    nativeAdapter.onResolve = () {
      harness._recordCoordinatedStep('bookmark-resolve');
    };
    await harness.readLocation();
    return harness;
  }

  Future<AttachmentArchiveCandidateComplete> verifyComplete() async {
    final result = await verifier.verify(
      sourceLocation: await readLocation(),
      candidate: AttachmentArchiveCandidateAccess(
        directoryPath: candidate.path,
        isPhysicallyWritable: true,
      ),
    );
    if (result is! AttachmentArchiveCandidateComplete) {
      throw StateError('Expected a complete candidate: ${result.outcome}.');
    }
    return result;
  }

  AttachmentArchiveAdoptionService service({
    AttachmentArchiveAdoptionFailureInjector? injector,
  }) {
    final snapshots = _RecordingSnapshotReader(
      delegate: verifier,
      onRead: () => _recordCoordinatedStep('fresh-structural-revalidation'),
      onCandidateRead: () =>
          _recordCoordinatedStep('candidate-post-switch-fingerprint'),
    );
    return AttachmentArchiveAdoptionService(
      archiveAccessAuthority: fixture.authority,
      mutationCoordinator: coordinator,
      currentLocationReader: _ProviderLocationReader(container),
      snapshotReader: snapshots,
      transactionStore: transactionStore,
      authorityIssuer: AttachmentArchiveAdoptionAuthorityIssuer(
        transactionStore: transactionStore,
      ),
      bookmarkAdapter: nativeAdapter,
      rootInspector: rootInspector,
      readLocation: readLocation,
      activateLocation:
          ({required configuration, required adoptionAuthority}) async {
            _recordCoordinatedStep('activate-configuration');
            capturedAuthority = adoptionAuthority;
            await locationNotifier.activateVerifiedAdoption(
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
      readWritableAdmission: () {
        _recordCoordinatedStep('writable-root-admission');
        return container.read(
          attachmentArchiveWritableRootAdmissionProvider.future,
        );
      },
      newTransactionId: () => transactionId,
      clock: () => fixedTime,
      failureInjector: injector,
    );
  }

  AttachmentArchiveAdoptionRecoveryService recoveryService() {
    return AttachmentArchiveAdoptionRecoveryService(
      archiveAccessAuthority: fixture.authority,
      mutationCoordinator: coordinator,
      transactionStore: transactionStore,
      authorityIssuer: AttachmentArchiveAdoptionAuthorityIssuer(
        transactionStore: transactionStore,
      ),
      bookmarkAdapter: nativeAdapter,
      rootInspector: rootInspector,
      readLocation: readLocation,
      restoreLocation: ({required configuration, required adoptionAuthority}) {
        return locationNotifier.restoreAdoptionConfiguration(
          configuration: configuration,
          adoptionAuthority: adoptionAuthority,
        );
      },
    );
  }

  Future<void> writePreparedTransaction(
    AttachmentArchiveCandidateComplete complete,
  ) async {
    await transactionStore.writePending(preparedTransaction(complete));
  }

  AttachmentArchiveAdoptionTransaction preparedTransaction(
    AttachmentArchiveCandidateComplete complete, {
    String id = transactionId,
  }) {
    final evidence = complete.evidence!;
    final bookmark = base64Encode(utf8.encode(candidate.path));
    return AttachmentArchiveAdoptionTransaction(
      formatVersion: AttachmentArchiveAdoptionTransaction.currentFormatVersion,
      transactionId: id,
      state: AttachmentArchiveAdoptionTransactionState.prepared,
      previousConfiguration:
          const AttachmentArchiveLocationConfiguration.defaultInternal(),
      intendedConfiguration:
          AttachmentArchiveLocationConfiguration.customExternal(
            bookmarkDataBase64: bookmark,
            lastKnownPath: candidate.path,
            customWritePolicy: AttachmentArchiveCustomWritePolicy.activeArchive,
          ),
      sourceCanonicalIdentity: evidence.sourceCanonicalIdentity,
      candidateCanonicalIdentity: evidence.candidateCanonicalIdentity,
      sourceLocationGeneration: evidence.sourceLocationGeneration,
      verificationContentDigest: evidence.contentCoverageDigest,
      sourceStructuralSnapshotFingerprint:
          evidence.sourceStructuralSnapshotFingerprint,
      candidateStructuralSnapshotFingerprint:
          evidence.candidateStructuralSnapshotFingerprint,
      verifiedFileCount: evidence.verifiedFileCount,
      verifiedBytes: evidence.verifiedBytes,
      createdAtUtc: fixedTime,
      updatedAtUtc: fixedTime,
    );
  }

  Future<AttachmentArchiveLocationState> readLocation() {
    return container.read(attachmentArchiveLocationProvider.future);
  }

  Future<(Map<String, String>, Map<String, String>)> payloadSnapshots() async {
    return (await _payloadSnapshot(source), await _payloadSnapshot(candidate));
  }

  Future<void> expectPayloadSnapshots(
    (Map<String, String>, Map<String, String>) before,
  ) async {
    expect(await _payloadSnapshot(source), before.$1);
    expect(await _payloadSnapshot(candidate), before.$2);
    expect(source.existsSync(), isTrue);
    expect(candidate.existsSync(), isTrue);
  }

  Future<void> expectDefaultAndNoPending() async {
    final location = await readLocation();
    expect(
      location.configuration,
      const AttachmentArchiveLocationConfiguration.defaultInternal(),
    );
    expect(await transactionStore.readPending(), isNull);
  }

  void _recordCoordinatedStep(String value) {
    steps.add(value);
    coordinatedSteps.add(coordinatorStateIsLocked);
  }

  Future<void> dispose() async {
    container.dispose();
    await nativeAdapter.dispose();
    await database.close();
    await fixture.dispose();
  }
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

final class _RecordingSnapshotReader
    implements AttachmentArchiveApprovalSnapshotReader {
  const _RecordingSnapshotReader({
    required this.delegate,
    required this.onRead,
    required this.onCandidateRead,
  });

  final AttachmentArchiveApprovalSnapshotReader delegate;
  final void Function() onRead;
  final void Function() onCandidateRead;

  @override
  Future<AttachmentArchiveApprovalStructuralSnapshot> read({
    required AttachmentArchiveLocationState sourceLocation,
    required AttachmentArchiveCandidateAccess candidate,
    required String expectedSourceCanonicalIdentity,
    required String expectedCandidateCanonicalIdentity,
  }) {
    onRead();
    return delegate.read(
      sourceLocation: sourceLocation,
      candidate: candidate,
      expectedSourceCanonicalIdentity: expectedSourceCanonicalIdentity,
      expectedCandidateCanonicalIdentity: expectedCandidateCanonicalIdentity,
    );
  }

  @override
  Future<AttachmentArchiveApprovalCandidateStructuralSnapshot> readCandidate({
    required String sourceCanonicalIdentity,
    required AttachmentArchiveCandidateAccess candidate,
    required String expectedCandidateCanonicalIdentity,
  }) {
    onCandidateRead();
    return delegate.readCandidate(
      sourceCanonicalIdentity: sourceCanonicalIdentity,
      candidate: candidate,
      expectedCandidateCanonicalIdentity: expectedCandidateCanonicalIdentity,
    );
  }
}

final class _ControllableRootInspector
    implements AttachmentArchiveAdoptionRootInspector {
  final _delegate = const FilesystemAttachmentArchiveAdoptionRootInspector();
  bool previousUnavailable = false;

  @override
  Future<AttachmentArchiveAdoptionRootInspection> inspect({
    required String directoryPath,
    required String label,
  }) {
    if (previousUnavailable && label == 'previous attachment archive') {
      throw const FileSystemException('injected previous unavailability');
    }
    return _delegate.inspect(directoryPath: directoryPath, label: label);
  }
}

final class _FakeNativeAdapter
    implements AttachmentArchiveLocationNativeAdapter {
  _FakeNativeAdapter(String candidatePath)
    : creationPath = candidatePath,
      resolutionPath = candidatePath;

  final StreamController<AttachmentArchiveLocationEvent> _events =
      StreamController<AttachmentArchiveLocationEvent>.broadcast();
  String creationPath;
  String resolutionPath;
  AttachmentArchiveBookmarkResolutionStatus status =
      AttachmentArchiveBookmarkResolutionStatus.available;
  Future<void> Function()? onCreate;
  void Function()? onResolve;

  @override
  Future<int> availableCapacityForImportantUsage(String directoryPath) async {
    throw UnsupportedError('Adoption must not request capacity.');
  }

  @override
  Future<AttachmentArchiveBookmarkCreation> createBookmark({
    required String directoryPath,
  }) async {
    await onCreate?.call();
    return AttachmentArchiveBookmarkCreation(
      bookmarkDataBase64: base64Encode(utf8.encode(creationPath)),
      resolvedPath: creationPath,
      volumeName: 'Disposable',
    );
  }

  @override
  Future<AttachmentArchiveBookmarkResolution> resolveBookmark({
    required String bookmarkDataBase64,
  }) async {
    onResolve?.call();
    return AttachmentArchiveBookmarkResolution(
      status: status,
      resolvedPath: resolutionPath,
      volumeName: 'Disposable',
    );
  }

  @override
  Stream<AttachmentArchiveLocationEvent> get locationEvents => _events.stream;

  Future<void> dispose() => _events.close();
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
      final relativePath = path.relative(entity.path, from: root.path);
      result[relativePath] = sha256
          .convert(await entity.readAsBytes())
          .toString();
    }
  }
  return Map<String, String>.fromEntries(
    result.entries.toList()
      ..sort((left, right) => left.key.compareTo(right.key)),
  );
}
