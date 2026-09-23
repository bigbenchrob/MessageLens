import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/archive_compatibility/domain/archive_compatibility_key.dart';
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
import 'package:remember_this_text/features/attachments/application/attachment_archive_remediation_authority.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_remediation_source_reader.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_settings_store_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_showcase.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_adoption.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_candidate_verification.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_configuration.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_state.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/filesystem_attachment_archive_adoption_root_inspector.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/filesystem_attachment_archive_adoption_transaction_store.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/filesystem_attachment_archive_candidate_verifier.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/filesystem_attachment_archive_file_store.dart';
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
        final legacyJson = Map<String, Object?>.from(prepared.toJson())
          ..['formatVersion'] = 1
          ..remove('kind')
          ..remove('remediationPayloads');
        final legacy = AttachmentArchiveAdoptionTransaction.fromJson(
          legacyJson,
        );
        expect(legacy.kind, AttachmentArchiveAdoptionTransactionKind.complete);
        expect(legacy.remediationPayloads, isEmpty);

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

    test(
      'verified-behind refreshes an additive review delta, switches first, '
      'and installs the exact five payloads without changing source',
      () async {
        for (var index = 0; index < 3; index++) {
          await harness.addSourcePayload(<int>[10 + index, index]);
        }
        final reviewed = await harness.verifyBehind();
        expect(reviewed.evidence!.missingCount, 3);

        for (var index = 0; index < 2; index++) {
          await harness.addSourcePayload(<int>[20 + index, index, 9]);
        }
        final sourceBefore = await _payloadSnapshot(harness.source);
        final progress = <AttachmentArchiveRemediationProgress>[];

        final result = await harness.service().adopt(
          reviewed,
          onRemediationProgress: progress.add,
        );

        expect(result.outcome, AttachmentArchiveAdoptionOutcome.adopted);
        expect(progress.first.totalFiles, 5);
        expect(progress.last.filesCompleted, 5);
        expect(progress.last.bytesCompleted, progress.last.totalBytes);
        expect(await _payloadSnapshot(harness.source), sourceBefore);
        final finalVerification = await harness.verifier.verify(
          sourceLocation: AttachmentArchiveLocationState.defaultAvailable(
            archiveRootPath: harness.source.path,
          ),
          candidate: AttachmentArchiveCandidateAccess(
            directoryPath: harness.candidate.path,
            isPhysicallyWritable: true,
          ),
        );
        expect(finalVerification, isA<AttachmentArchiveCandidateComplete>());
        expect(await harness.transactionStore.readPending(), isNull);
      },
    );

    test('verified-behind approval hashes zero unchanged source or candidate '
        'payloads', () async {
      await harness.addSourcePayload(<int>[7, 7, 7]);
      final reviewed = await harness.verifyBehind();
      harness.payloadHashStarts.clear();
      int? hashesAtApprovalCompletion;

      final result = await harness.service().adopt(
        reviewed,
        onVerificationProgress: (_) {
          hashesAtApprovalCompletion ??= harness.payloadHashStarts.length;
        },
      );

      expect(result.outcome, AttachmentArchiveAdoptionOutcome.adopted);
      expect(hashesAtApprovalCompletion, 0);
    });

    test(
      'approval structurally scans a thousand-item fixture and hashes exactly '
      'the newly added source payloads',
      () async {
        for (var index = 0; index < 1000; index++) {
          final bytes = <int>[index >> 8, index & 0xff];
          await _write(harness.source, '_by_id/${10000 + index}.bin', bytes);
          await _write(harness.candidate, '_by_id/${10000 + index}.bin', bytes);
        }
        await harness.addSourcePayload(<int>[8, 8, 8]);
        final reviewed = await harness.verifyBehind();
        harness.payloadHashStarts.clear();
        final addedPaths = <String>[];
        for (var index = 0; index < 3; index++) {
          addedPaths.add(
            await harness.addSourcePayload(<int>[90, index, 12, 34]),
          );
        }
        int? hashesAtApprovalCompletion;

        final result = await harness.service().adopt(
          reviewed,
          onVerificationProgress: (_) {
            hashesAtApprovalCompletion ??= harness.payloadHashStarts.length;
          },
        );

        expect(result.outcome, AttachmentArchiveAdoptionOutcome.adopted);
        expect(hashesAtApprovalCompletion, addedPaths.length);
        expect(
          harness.payloadHashStarts.take(hashesAtApprovalCompletion!).toSet(),
          {
            for (final relativePath in addedPaths)
              path.join(harness.source.path, relativePath),
          },
        );
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );

    test(
      'candidate change during review returns Check Again before switching',
      () async {
        final relativePath = await harness.addSourcePayload(<int>[21, 22, 23]);
        final reviewed = await harness.verifyBehind();
        await _write(harness.candidate, relativePath, <int>[21, 22, 23]);

        final result = await harness.service().adopt(reviewed);

        expect(
          result.outcome,
          AttachmentArchiveAdoptionOutcome.candidateChangedCheckAgain,
        );
        await harness.expectDefaultAndNoPending();
      },
    );

    test('source removal after review requires another check', () async {
      final relativePath = await harness.addSourcePayload(<int>[31, 41, 59]);
      final reviewed = await harness.verifyBehind();
      await File(path.join(harness.source.path, relativePath)).delete();

      final result = await harness.service().adopt(reviewed);

      expect(
        result.outcome,
        AttachmentArchiveAdoptionOutcome.sourceChangedCheckAgain,
      );
      await harness.expectDefaultAndNoPending();
    });

    test('source replacement after review requires another check', () async {
      final relativePath = await harness.addSourcePayload(<int>[26, 53, 58]);
      final reviewed = await harness.verifyBehind();
      final sourceFile = File(path.join(harness.source.path, relativePath));
      await sourceFile.writeAsBytes(<int>[9, 9, 9], flush: true);
      await sourceFile.setLastModified(DateTime.utc(2033, 1, 2));

      final result = await harness.service().adopt(reviewed);

      expect(
        result.outcome,
        AttachmentArchiveAdoptionOutcome.sourceChangedCheckAgain,
      );
      await harness.expectDefaultAndNoPending();
    });

    test('existing metadata-reference change requires another check', () async {
      await harness.addSourcePayload(<int>[97, 93, 23]);
      final reviewed = await harness.verifyBehind();
      await harness.database.customStatement(
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
          'second-reference',
          2,
          _Harness.relativePayloadPath,
          _Harness.fixedTime.toIso8601String(),
          4,
          sha256.convert(<int>[1, 2, 3, 4]).toString(),
          'archived',
        ],
      );

      final result = await harness.service().adopt(reviewed);

      expect(
        result.outcome,
        AttachmentArchiveAdoptionOutcome.sourceChangedCheckAgain,
      );
      await harness.expectDefaultAndNoPending();
    });

    test(
      'candidate identity change fails before configuration mutation',
      () async {
        await harness.addSourcePayload(<int>[84, 62, 64]);
        final reviewed = await harness.verifyBehind();
        final unrelated = await Directory(
          path.join(harness.fixture.root.path, 'another-candidate'),
        ).create();
        harness.nativeAdapter.creationPath = unrelated.path;
        harness.nativeAdapter.resolutionPath = unrelated.path;

        final result = await harness.service().adopt(reviewed);

        expect(
          result.outcome,
          AttachmentArchiveAdoptionOutcome.candidateChangedCheckAgain,
        );
        await harness.expectDefaultAndNoPending();
      },
    );

    test(
      'additive delta that exceeds remediation count remains non-adoptable',
      () async {
        for (var index = 0; index < 256; index++) {
          await harness.addSourcePayload(<int>[index, index >> 8, 77]);
        }
        final reviewed = await harness.verifyBehind();
        expect(reviewed.evidence!.missingCount, 256);
        await harness.addSourcePayload(<int>[1, 2, 3, 77]);

        final result = await harness.service().adopt(reviewed);

        expect(
          result.outcome,
          AttachmentArchiveAdoptionOutcome.verificationEvidenceInvalid,
        );
        await harness.expectDefaultAndNoPending();
      },
    );

    test(
      'candidate conflict during final refresh fails closed before switching',
      () async {
        final relativePath = await harness.addSourcePayload(<int>[24, 25, 26]);
        final reviewed = await harness.verifyBehind();
        await _write(harness.candidate, relativePath, <int>[0, 0, 0]);

        final result = await harness.service().adopt(reviewed);

        expect(
          result.outcome,
          AttachmentArchiveAdoptionOutcome.candidateChangedCheckAgain,
        );
        await harness.expectDefaultAndNoPending();
        expect(
          await File(
            path.join(harness.candidate.path, relativePath),
          ).readAsBytes(),
          <int>[0, 0, 0],
        );
      },
    );

    test('successful destination install emits showcase evidence afterward and '
        'a broken consumer cannot affect remediation', () async {
      final relativePath = await harness.addSourcePayload(<int>[
        1,
        4,
        9,
      ], extension: 'png');
      final reviewed = await harness.verifyBehind();
      final events = <AttachmentShowcaseItem>[];
      var destinationExistedAtPublication = false;

      final result = await harness
          .service(
            onShowcaseItem: (item) {
              destinationExistedAtPublication = File(
                item.resolvedPath,
              ).existsSync();
              events.add(item);
              throw StateError('presentation consumer failed');
            },
          )
          .adopt(reviewed);

      expect(result.outcome, AttachmentArchiveAdoptionOutcome.adopted);
      expect(destinationExistedAtPublication, isTrue);
      expect(events, hasLength(1));
      expect(
        events.single.resolvedPath,
        path.join(harness.candidate.path, relativePath),
      );
      expect(events.single.mediaKind, AttachmentShowcaseMediaKind.image);
      expect(events.single.stablePresentationIdentity, isNotEmpty);
    });

    test('remediation result is identical when showcase is absent', () async {
      await harness.addSourcePayload(<int>[1, 5, 12]);
      final reviewed = await harness.verifyBehind();

      final result = await harness.service().adopt(reviewed);

      expect(result.outcome, AttachmentArchiveAdoptionOutcome.adopted);
      expect(await harness.transactionStore.readPending(), isNull);
      final finalVerification = await harness.verifier.verify(
        sourceLocation: AttachmentArchiveLocationState.defaultAvailable(
          archiveRootPath: harness.source.path,
        ),
        candidate: AttachmentArchiveCandidateAccess(
          directoryPath: harness.candidate.path,
          isPhysicallyWritable: true,
        ),
      );
      expect(finalVerification, isA<AttachmentArchiveCandidateComplete>());
    });

    test('failed install publishes no showcase success event', () async {
      await harness.addSourcePayload(<int>[2, 5, 10]);
      final reviewed = await harness.verifyBehind();
      final events = <AttachmentShowcaseItem>[];

      final result = await harness
          .service(
            injector: _throwAt(
              AttachmentArchiveAdoptionFailurePoint.duringRemediation,
            ),
            onShowcaseItem: events.add,
          )
          .adopt(reviewed);

      expect(
        result.outcome,
        AttachmentArchiveAdoptionOutcome.remediationPending,
      );
      expect(events, isEmpty);
    });

    test('final verifier progress is determinate and failure preserves active '
        'candidate recovery state without success', () async {
      final relativePath = await harness.addSourcePayload(<int>[3, 6, 11]);
      final reviewed = await harness.verifyBehind();
      final finalProgress = <AttachmentArchiveVerificationProgress>[];

      final result = await harness.service().adopt(
        reviewed,
        onRemediationProgress: (progress) {
          if (progress.filesCompleted == progress.totalFiles) {
            File(
              path.join(harness.candidate.path, relativePath),
            ).writeAsBytesSync(<int>[0, 0, 0], flush: true);
          }
        },
        onFinalCoverageProgress: finalProgress.add,
      );

      expect(
        result.outcome,
        AttachmentArchiveAdoptionOutcome.remediationPending,
      );
      expect(finalProgress, isNotEmpty);
      expect(
        finalProgress.where((progress) => progress.isDeterminate),
        isNotEmpty,
      );
      expect(await harness.transactionStore.readPending(), isNotNull);
      expect(
        (await harness.readLocation()).configuration,
        (await harness.transactionStore.readPending())!.intendedConfiguration,
      );
    });

    test(
      'post-switch crash keeps candidate active, permits new candidate data, '
      'and resumes the fixed historical set',
      () async {
        for (var index = 0; index < 5; index++) {
          await harness.addSourcePayload(<int>[30 + index, index]);
        }
        final reviewed = await harness.verifyBehind();
        final sourceBefore = await _payloadSnapshot(harness.source);
        var remediationAttempts = 0;

        final interrupted = await harness
            .service(
              injector: (point) async {
                if (point ==
                    AttachmentArchiveAdoptionFailurePoint.duringRemediation) {
                  remediationAttempts++;
                  if (remediationAttempts == 3) {
                    throw StateError('simulated termination');
                  }
                }
              },
            )
            .adopt(reviewed);

        expect(
          interrupted.outcome,
          AttachmentArchiveAdoptionOutcome.remediationPending,
        );
        final pending = await harness.transactionStore.readPending();
        expect(
          pending!.state,
          AttachmentArchiveAdoptionTransactionState.activeRemediationPending,
        );
        expect((await harness.readLocation()).archiveRootPath, isNotNull);
        expect(
          (await harness.recoveryService().recoverPending()).outcome,
          AttachmentArchiveAdoptionOutcome.remediationPending,
        );

        final ordinarySource = await _write(
          harness.fixture.root,
          'ordinary-new-source.bin',
          <int>[99, 98, 97],
        );
        final admission = await harness.container.read(
          attachmentArchiveWritableRootAdmissionProvider.future,
        );
        final ordinaryInstall =
            await const FilesystemAttachmentArchiveFileStore()
                .writeArchiveEntry(
                  archiveDirectoryPath: admission.lease!.archiveRootPath,
                  sourcePath: ordinarySource.path,
                  archiveKey: const ArchiveCompatibilityKey(
                    messageGuid: 'post-switch-ordinary-write',
                    importAttachmentId: 42,
                  ),
                  sha256Hex: null,
                  validateMutation: (boundary) => admission.lease!.requireValid(
                    operation:
                        ArchiveMutationOperation.attachmentReconciliation,
                    boundary: boundary,
                  ),
                );
        expect(
          await Directory(
            admission.lease!.archiveRootPath,
          ).resolveSymbolicLinks(),
          await harness.candidate.resolveSymbolicLinks(),
        );
        expect(ordinaryInstall, isNotNull);
        final resumed = await harness.service().resumePendingRemediation();

        expect(
          resumed.outcome,
          AttachmentArchiveAdoptionOutcome.remediationComplete,
        );
        expect(
          File(
            path.join(harness.candidate.path, ordinaryInstall!.relativePath),
          ).existsSync(),
          isTrue,
        );
        expect(await harness.transactionStore.readPending(), isNull);
        expect(await _payloadSnapshot(harness.source), sourceBefore);
      },
    );

    test('matching concurrent destination is accepted and conflicting bytes '
        'remain untouched with active remediation pending', () async {
      final matchingPath = await harness.addSourcePayload(<int>[41, 42, 43]);
      final matching = await harness.verifyBehind();
      var injected = false;
      final matchingResult = await harness
          .service(
            injector: (point) async {
              if (!injected &&
                  point ==
                      AttachmentArchiveAdoptionFailurePoint.duringRemediation) {
                injected = true;
                await File(
                  path.join(harness.candidate.path, matchingPath),
                ).create(recursive: true);
                await File(
                  path.join(harness.candidate.path, matchingPath),
                ).writeAsBytes(<int>[41, 42, 43], flush: true);
              }
            },
          )
          .adopt(matching);
      expect(matchingResult.outcome, AttachmentArchiveAdoptionOutcome.adopted);

      // A fresh harness keeps this conflict scenario independent of the
      // already-adopted configuration above.
      await harness.dispose();
      harness = await _Harness.create();
      final conflictPath = await harness.addSourcePayload(<int>[51, 52, 53]);
      final conflicting = await harness.verifyBehind();
      final conflictingFile = File(
        path.join(harness.candidate.path, conflictPath),
      );
      final conflictResult = await harness
          .service(
            injector: (point) async {
              if (point ==
                  AttachmentArchiveAdoptionFailurePoint.duringRemediation) {
                await conflictingFile.create(recursive: true);
                await conflictingFile.writeAsBytes(<int>[0, 0, 0], flush: true);
              }
            },
          )
          .adopt(conflicting);
      expect(
        conflictResult.outcome,
        AttachmentArchiveAdoptionOutcome.remediationPending,
      );
      expect(await conflictingFile.readAsBytes(), <int>[0, 0, 0]);
      expect(
        (await harness.readLocation()).configuration,
        (await harness.transactionStore.readPending())!.intendedConfiguration,
      );
    });

    test('retained source unavailable after switch leaves candidate active and '
        'resumes after the source returns', () async {
      await harness.addSourcePayload(<int>[61, 62, 63]);
      final reviewed = await harness.verifyBehind();
      final offlinePath = '${harness.source.path}.offline';
      var moved = false;
      final result = await harness
          .service(
            injector: (point) async {
              if (!moved &&
                  point ==
                      AttachmentArchiveAdoptionFailurePoint
                          .afterActiveRemediationBoundary) {
                moved = true;
                await harness.source.rename(offlinePath);
              }
            },
          )
          .adopt(reviewed);

      expect(
        result.outcome,
        AttachmentArchiveAdoptionOutcome.remediationPending,
      );
      expect(
        (await harness.readLocation()).configuration,
        (await harness.transactionStore.readPending())!.intendedConfiguration,
      );
      await Directory(offlinePath).rename(harness.source.path);
      expect(
        (await harness.service().resumePendingRemediation()).outcome,
        AttachmentArchiveAdoptionOutcome.remediationComplete,
      );
    });

    test('remediation rejects a symlinked retained source payload', () async {
      final relativePath = await harness.addSourcePayload(<int>[81, 82, 83]);
      final reviewed = await harness.verifyBehind();
      final sourceFile = File(path.join(harness.source.path, relativePath));
      final outside = await _write(
        harness.fixture.root,
        'outside-remediation-source.bin',
        <int>[81, 82, 83],
      );

      final result = await harness
          .service(
            injector: (point) async {
              if (point ==
                  AttachmentArchiveAdoptionFailurePoint
                      .afterActiveRemediationBoundary) {
                await sourceFile.delete();
                await Link(sourceFile.path).create(outside.path);
              }
            },
          )
          .adopt(reviewed);

      expect(
        result.outcome,
        AttachmentArchiveAdoptionOutcome.remediationPending,
      );
      expect(result.issue, contains('not a regular file'));
      expect(await harness.transactionStore.readPending(), isNotNull);
    });

    test('remediation rejects a non-regular retained source payload', () async {
      final relativePath = await harness.addSourcePayload(<int>[84, 85, 86]);
      final reviewed = await harness.verifyBehind();
      final sourceFile = File(path.join(harness.source.path, relativePath));
      var pipeCreated = false;

      final result = await harness
          .service(
            injector: (point) async {
              if (point ==
                  AttachmentArchiveAdoptionFailurePoint
                      .afterActiveRemediationBoundary) {
                await sourceFile.delete();
                final pipe = await Process.run('mkfifo', <String>[
                  sourceFile.path,
                ]);
                pipeCreated = pipe.exitCode == 0;
              }
            },
          )
          .adopt(reviewed);

      if (pipeCreated) {
        expect(
          result.outcome,
          AttachmentArchiveAdoptionOutcome.remediationPending,
        );
        expect(result.issue, contains('not a regular file'));
      }
    });

    test(
      'remediation rejects wrong-size and disappeared source payloads',
      () async {
        final wrongSizePath = await harness.addSourcePayload(<int>[87, 88, 89]);
        final wrongSizeReview = await harness.verifyBehind();
        final wrongSizeResult = await harness
            .service(
              injector: (point) async {
                if (point ==
                    AttachmentArchiveAdoptionFailurePoint
                        .afterActiveRemediationBoundary) {
                  await File(
                    path.join(harness.source.path, wrongSizePath),
                  ).writeAsBytes(<int>[87], flush: true);
                }
              },
            )
            .adopt(wrongSizeReview);
        expect(
          wrongSizeResult.outcome,
          AttachmentArchiveAdoptionOutcome.remediationPending,
        );
        expect(wrongSizeResult.issue, contains('changed'));

        await harness.dispose();
        harness = await _Harness.create();
        final missingPath = await harness.addSourcePayload(<int>[90, 91, 92]);
        final missingReview = await harness.verifyBehind();
        final missingResult = await harness
            .service(
              injector: (point) async {
                if (point ==
                    AttachmentArchiveAdoptionFailurePoint
                        .afterActiveRemediationBoundary) {
                  await File(
                    path.join(harness.source.path, missingPath),
                  ).delete();
                }
              },
            )
            .adopt(missingReview);
        expect(
          missingResult.outcome,
          AttachmentArchiveAdoptionOutcome.remediationPending,
        );
        expect(missingResult.issue, contains('unavailable'));
      },
    );

    test(
      'unreadable remediation source fails through the typed port',
      () async {
        final relativePath = await harness.addSourcePayload(<int>[93, 94, 95]);
        final reviewed = await harness.verifyBehind();
        final sourcePath = path.join(harness.source.path, relativePath);
        var permissionsChanged = false;

        final result = await harness
            .service(
              injector: (point) async {
                if (point ==
                    AttachmentArchiveAdoptionFailurePoint
                        .afterActiveRemediationBoundary) {
                  final chmod = await Process.run('chmod', <String>[
                    '000',
                    sourcePath,
                  ]);
                  permissionsChanged = chmod.exitCode == 0;
                }
              },
            )
            .adopt(reviewed);
        if (permissionsChanged) {
          await Process.run('chmod', <String>['600', sourcePath]);
          expect(
            result.outcome,
            AttachmentArchiveAdoptionOutcome.remediationPending,
          );
          expect(result.issue, contains('could not be read'));
        }
      },
    );

    test('remediation source bytes remain streamed and bounded', () async {
      final bytes = List<int>.generate(
        2 * 1024 * 1024,
        (index) => index % 251,
        growable: false,
      );
      await harness.addSourcePayload(bytes);
      final reviewed = await harness.verifyBehind();
      final reader = _RecordingRemediationSourceReader(harness.verifier);

      final result = await harness
          .service(remediationSourceReader: reader)
          .adopt(reviewed);

      expect(result.outcome, AttachmentArchiveAdoptionOutcome.adopted);
      expect(reader.openCount, 1);
      expect(reader.chunkSizes.length, greaterThan(1));
      expect(reader.chunkSizes.every((size) => size < bytes.length), isTrue);
      expect(
        reader.chunkSizes.fold<int>(0, (sum, size) => sum + size),
        bytes.length,
      );
    });

    test(
      'candidate unavailable after switch is not recreated or rolled back',
      () async {
        await harness.addSourcePayload(<int>[71, 72, 73]);
        final reviewed = await harness.verifyBehind();
        final offlinePath = '${harness.candidate.path}.offline';
        var moved = false;
        final result = await harness
            .service(
              injector: (point) async {
                if (!moved &&
                    point ==
                        AttachmentArchiveAdoptionFailurePoint
                            .duringRemediation) {
                  moved = true;
                  await harness.candidate.rename(offlinePath);
                }
              },
            )
            .adopt(reviewed);

        expect(
          result.outcome,
          AttachmentArchiveAdoptionOutcome.remediationPending,
        );
        expect(harness.candidate.existsSync(), isFalse);
        expect(Directory(offlinePath).existsSync(), isTrue);
        expect(
          (await harness.readLocation()).configuration,
          (await harness.transactionStore.readPending())!.intendedConfiguration,
        );
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
    required this.payloadHashStarts,
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
  final List<String> payloadHashStarts;
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
    final payloadHashStarts = <String>[];
    final verifier = FilesystemAttachmentArchiveCandidateVerifier(
      metadataReader: OverlayAttachmentArchiveVerificationMetadataReader(
        overlayDatabase: database,
      ),
      clock: () => fixedTime,
      onPayloadHashStarted: payloadHashStarts.add,
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
      payloadHashStarts: payloadHashStarts,
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

  Future<String> addSourcePayload(List<int> bytes, {String extension = 'bin'}) {
    return _writeContentAddressed(source, bytes, extension: extension);
  }

  Future<AttachmentArchiveCandidateBehind> verifyBehind() async {
    final result = await verifier.verify(
      sourceLocation: await readLocation(),
      candidate: AttachmentArchiveCandidateAccess(
        directoryPath: candidate.path,
        isPhysicallyWritable: true,
      ),
    );
    if (result is! AttachmentArchiveCandidateBehind) {
      throw StateError('Expected a behind candidate: ${result.outcome}.');
    }
    return result;
  }

  AttachmentArchiveAdoptionService service({
    AttachmentArchiveAdoptionFailureInjector? injector,
    AttachmentShowcaseEventCallback? onShowcaseItem,
    AttachmentArchiveRemediationSourceReader? remediationSourceReader,
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
      addedPayloadReader: verifier,
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
      remediationSourceReader: remediationSourceReader ?? verifier,
      newTransactionId: () => transactionId,
      clock: () => fixedTime,
      failureInjector: injector,
      candidateVerifier: verifier,
      fileStore: const FilesystemAttachmentArchiveFileStore(),
      onShowcaseItem: onShowcaseItem,
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

final class _RecordingRemediationSourceReader
    implements AttachmentArchiveRemediationSourceReader {
  _RecordingRemediationSourceReader(this.delegate);

  final AttachmentArchiveRemediationSourceReader delegate;
  final List<int> chunkSizes = <int>[];
  int openCount = 0;

  @override
  Future<Stream<List<int>>> openVerifiedPayload({
    required String retainedSourceRootPath,
    required AttachmentArchiveRemediationAuthority remediationAuthority,
  }) async {
    openCount++;
    final source = await delegate.openVerifiedPayload(
      retainedSourceRootPath: retainedSourceRootPath,
      remediationAuthority: remediationAuthority,
    );
    return source.map((chunk) {
      chunkSizes.add(chunk.length);
      return chunk;
    });
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

Future<String> _writeContentAddressed(
  Directory root,
  List<int> bytes, {
  String extension = 'bin',
}) async {
  final digest = sha256.convert(bytes).toString();
  final relativePath = '${digest.substring(0, 2)}/$digest.$extension';
  await _write(root, relativePath, bytes);
  return relativePath;
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
