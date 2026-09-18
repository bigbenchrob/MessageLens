import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/archive_environment/domain/archive_mutation_capability_denied_exception.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_mutation_denied_exception.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_mutation_operation.dart';
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart'
    show
        ArchiveMutationCoordinator,
        ArchiveMutationCoordinatorState,
        admittedArchiveAccessAuthorityProvider,
        archiveMutationCoordinatorProvider;
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_approval_revalidator.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_approval_snapshot_reader.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_approval_revalidation.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_candidate_verification.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_configuration.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_state.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/filesystem_attachment_archive_candidate_verifier.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/overlay_attachment_archive_verification_metadata_reader.dart';

import '../../../test_support/test_archive_fixture.dart';

void main() {
  group('AttachmentArchiveApprovalRevalidator', () {
    late _Harness harness;

    setUp(() async {
      harness = await _Harness.create();
      await harness.writeMetadataPayload(
        relativePath: 'nested/initial.bin',
        bytes: <int>[1, 2, 3, 4],
        attachmentId: 1,
      );
    });

    tearDown(() => harness.dispose());

    test('unchanged complete verification becomes approvalReady', () async {
      final complete = await harness.verifyComplete();
      final result = await harness.revalidator.revalidate(complete);

      expect(
        result.outcome,
        AttachmentArchiveApprovalRevalidationOutcome.approvalReady,
      );
      expect(result.readyEvidence, isNotNull);
      expect(result.readyEvidence!.verification, same(complete));
      expect(
        result.readyEvidence!.contentCoverageDigest,
        complete.evidence!.contentCoverageDigest,
      );
      expect(harness.coordinatorState.isLocked, isFalse);
    });

    test(
      'four-second rehearsal race refuses changed source then accepts a fresh copy',
      () async {
        final firstComplete = await harness.verifyComplete();
        final locationBefore = harness.locationReader.state;

        // This is the supported mutation that occurred during the human review
        // interval in the development rehearsal.
        await harness.coordinator.run<void>(
          operation: ArchiveMutationOperation.attachmentReconciliation,
          ownerLabel: 'test-normal-attachment-ingestion',
          action: () => harness.writeMetadataPayload(
            relativePath: 'later/new-payload.bin',
            bytes: <int>[9, 8, 7, 6],
            attachmentId: 2,
            includeCandidate: false,
          ),
        );

        final refused = await harness.revalidator.revalidate(firstComplete);

        expect(
          refused.outcome,
          AttachmentArchiveApprovalRevalidationOutcome.sourceChanged,
        );
        expect(harness.locationReader.state, same(locationBefore));
        expect(harness.coordinatorState.isLocked, isFalse);

        await harness.copyRelative('later/new-payload.bin');
        final freshComplete = await harness.verifyComplete();
        final accepted = await harness.revalidator.revalidate(freshComplete);

        expect(
          accepted.outcome,
          AttachmentArchiveApprovalRevalidationOutcome.approvalReady,
        );
        expect(accepted.readyEvidence!.verification, same(freshComplete));
        expect(harness.locationReader.state, same(locationBefore));
      },
    );

    group('source changes', () {
      test('added payload requires Check Again', () async {
        final complete = await harness.verifyComplete();
        await harness.writeMetadataPayload(
          relativePath: 'new/added.bin',
          bytes: <int>[5],
          attachmentId: 2,
          includeCandidate: false,
        );

        expect(
          (await harness.revalidator.revalidate(complete)).outcome,
          AttachmentArchiveApprovalRevalidationOutcome.sourceChanged,
        );
      });

      test('removed payload requires Check Again', () async {
        final complete = await harness.verifyComplete();
        await File(
          path.join(harness.source.path, 'nested/initial.bin'),
        ).delete();

        expect(
          (await harness.revalidator.revalidate(complete)).outcome,
          AttachmentArchiveApprovalRevalidationOutcome.sourceChanged,
        );
      });

      test(
        'same-size replacement with changed time requires Check Again',
        () async {
          final complete = await harness.verifyComplete();
          final file = File(
            path.join(harness.source.path, 'nested/initial.bin'),
          );
          await file.writeAsBytes(<int>[4, 3, 2, 1], flush: true);
          await file.setLastModified(DateTime.utc(2031, 1, 2, 3, 4, 5));

          expect(
            (await harness.revalidator.revalidate(complete)).outcome,
            AttachmentArchiveApprovalRevalidationOutcome.sourceChanged,
          );
        },
      );

      test('metadata reference group change requires Check Again', () async {
        final complete = await harness.verifyComplete();
        await harness.insertMetadata(
          guid: 'second-reference',
          attachmentId: 2,
          relativePath: 'nested/initial.bin',
          bytes: <int>[1, 2, 3, 4],
        );

        expect(
          (await harness.revalidator.revalidate(complete)).outcome,
          AttachmentArchiveApprovalRevalidationOutcome.sourceChanged,
        );
      });

      test(
        'configuration change requires Check Again before traversal',
        () async {
          final complete = await harness.verifyComplete();
          final customConfiguration =
              AttachmentArchiveLocationConfiguration.customExternal(
                bookmarkDataBase64: 'AQ==',
                lastKnownPath: harness.source.path,
              );
          harness.locationReader.state =
              AttachmentArchiveLocationState.customAvailable(
                configuration: customConfiguration,
                archiveRootPath: harness.source.path,
                generation: 7,
              );

          expect(
            (await harness.revalidator.revalidate(complete)).outcome,
            AttachmentArchiveApprovalRevalidationOutcome.sourceChanged,
          );
        },
      );

      test('generation change requires Check Again before traversal', () async {
        final complete = await harness.verifyComplete();
        harness.locationReader.state =
            AttachmentArchiveLocationState.defaultAvailable(
              archiveRootPath: harness.source.path,
              generation: 8,
            );

        expect(
          (await harness.revalidator.revalidate(complete)).outcome,
          AttachmentArchiveApprovalRevalidationOutcome.sourceChanged,
        );
      });

      test(
        'canonical root change rejects evidence from another source',
        () async {
          final complete = await harness.verifyComplete();
          final otherSource = await Directory(
            path.join(harness.temporaryRoot.path, 'other-source'),
          ).create();
          harness.locationReader.state =
              AttachmentArchiveLocationState.defaultAvailable(
                archiveRootPath: otherSource.path,
                generation: 7,
              );

          expect(
            (await harness.revalidator.revalidate(complete)).outcome,
            AttachmentArchiveApprovalRevalidationOutcome.sourceChanged,
          );
        },
      );

      test('unavailable source returns sourceUnavailable', () async {
        final complete = await harness.verifyComplete();
        harness
            .locationReader
            .state = AttachmentArchiveLocationState.configurationInvalid(
          issue: 'test source disconnected',
          generation: 7,
          configuration:
              const AttachmentArchiveLocationConfiguration.defaultInternal(),
        );

        expect(
          (await harness.revalidator.revalidate(complete)).outcome,
          AttachmentArchiveApprovalRevalidationOutcome.sourceUnavailable,
        );
      });
    });

    group('candidate changes', () {
      test('added valid extra requires Check Again', () async {
        final complete = await harness.verifyComplete();
        await harness.writeContentAddressedExtra(<int>[8, 8, 8]);

        expect(
          (await harness.revalidator.revalidate(complete)).outcome,
          AttachmentArchiveApprovalRevalidationOutcome.candidateChanged,
        );
      });

      test('removed payload requires Check Again', () async {
        final complete = await harness.verifyComplete();
        await File(
          path.join(harness.candidate.path, 'nested/initial.bin'),
        ).delete();

        expect(
          (await harness.revalidator.revalidate(complete)).outcome,
          AttachmentArchiveApprovalRevalidationOutcome.candidateChanged,
        );
      });

      test(
        'same-size replacement with changed time requires Check Again',
        () async {
          final complete = await harness.verifyComplete();
          final file = File(
            path.join(harness.candidate.path, 'nested/initial.bin'),
          );
          await file.writeAsBytes(<int>[4, 3, 2, 1], flush: true);
          await file.setLastModified(DateTime.utc(2032, 2, 3, 4, 5, 6));

          expect(
            (await harness.revalidator.revalidate(complete)).outcome,
            AttachmentArchiveApprovalRevalidationOutcome.candidateChanged,
          );
        },
      );

      test('new candidate symlink requires Check Again', () async {
        final complete = await harness.verifyComplete();
        await Link(
          path.join(harness.candidate.path, 'unexpected-link'),
        ).create(path.join(harness.source.path, 'nested/initial.bin'));

        expect(
          (await harness.revalidator.revalidate(complete)).outcome,
          AttachmentArchiveApprovalRevalidationOutcome.candidateChanged,
        );
      });

      test('unavailable candidate returns candidateUnavailable', () async {
        final complete = await harness.verifyComplete();
        harness.candidateReader.issue = 'test candidate disconnected';

        expect(
          (await harness.revalidator.revalidate(complete)).outcome,
          AttachmentArchiveApprovalRevalidationOutcome.candidateUnavailable,
        );
      });

      test('candidate becoming read-only denies approval', () async {
        final complete = await harness.verifyComplete();
        harness.candidateReader.access = AttachmentArchiveCandidateAccess(
          directoryPath: harness.candidate.path,
          isPhysicallyWritable: false,
        );

        expect(
          (await harness.revalidator.revalidate(complete)).outcome,
          AttachmentArchiveApprovalRevalidationOutcome
              .candidateNoLongerWritable,
        );
      });

      test(
        'canonical root change rejects evidence from another candidate',
        () async {
          final complete = await harness.verifyComplete();
          final otherCandidate = await Directory(
            path.join(harness.temporaryRoot.path, 'other-candidate'),
          ).create();
          harness.candidateReader.access = AttachmentArchiveCandidateAccess(
            directoryPath: otherCandidate.path,
            isPhysicallyWritable: true,
          );

          expect(
            (await harness.revalidator.revalidate(complete)).outcome,
            AttachmentArchiveApprovalRevalidationOutcome.candidateChanged,
          );
        },
      );
    });

    test('approval revalidation performs zero payload hash reads', () async {
      final complete = await harness.verifyComplete();
      expect(harness.payloadHashStarts, greaterThan(0));
      harness.payloadHashStarts = 0;

      final result = await harness.revalidator.revalidate(complete);

      expect(
        result.outcome,
        AttachmentArchiveApprovalRevalidationOutcome.approvalReady,
      );
      expect(harness.payloadHashStarts, 0);
    });

    test(
      'scope excludes competing MessageLens mutation and releases afterward',
      () async {
        final complete = await harness.verifyComplete();
        final readStarted = Completer<void>();
        final releaseRead = Completer<void>();
        harness.snapshotReader.beforeRead = () async {
          expect(
            harness.coordinatorState.operation,
            ArchiveMutationOperation.attachmentArchiveAdoption,
          );
          readStarted.complete();
          await releaseRead.future;
        };

        final pending = harness.revalidator.revalidate(complete);
        await readStarted.future;
        await expectLater(
          harness.coordinator.run<void>(
            operation: ArchiveMutationOperation.attachmentReconciliation,
            ownerLabel: 'competing-ingestion',
            action: () async {},
          ),
          throwsA(isA<ArchiveMutationDeniedException>()),
        );
        releaseRead.complete();

        expect(
          (await pending).outcome,
          AttachmentArchiveApprovalRevalidationOutcome.approvalReady,
        );
        expect(harness.coordinatorState.isLocked, isFalse);
      },
    );

    test('future adoption can keep one continuous coordinator scope', () async {
      final complete = await harness.verifyComplete();

      await harness.coordinator.runWithCapability<void>(
        operation: ArchiveMutationOperation.attachmentArchiveAdoption,
        ownerLabel: 'future-checkpoint-four-adoption',
        action: (capability) async {
          final result = await harness.revalidator
              .revalidateWithinApprovalScope(
                verification: complete,
                capability: capability,
              );
          expect(
            result.outcome,
            AttachmentArchiveApprovalRevalidationOutcome.approvalReady,
          );
          expect(harness.coordinatorState.isLocked, isTrue);
          expect(
            harness.coordinatorState.operation,
            ArchiveMutationOperation.attachmentArchiveAdoption,
          );
        },
      );

      expect(harness.coordinatorState.isLocked, isFalse);
    });

    test(
      'wrong operation capability cannot perform approval revalidation',
      () async {
        final complete = await harness.verifyComplete();

        await expectLater(
          harness.coordinator
              .runWithCapability<AttachmentArchiveApprovalRevalidationResult>(
                operation: ArchiveMutationOperation.attachmentReconciliation,
                ownerLabel: 'wrong-operation',
                action: (capability) =>
                    harness.revalidator.revalidateWithinApprovalScope(
                      verification: complete,
                      capability: capability,
                    ),
              ),
          throwsA(isA<ArchiveMutationCapabilityDeniedException>()),
        );
        expect(harness.coordinatorState.isLocked, isFalse);
      },
    );

    test(
      'malformed complete evidence is rejected before filesystem reads',
      () async {
        final complete = await harness.verifyComplete();
        final malformed = AttachmentArchiveCandidateComplete(
          context: complete.context,
          evidence: _copyEvidence(
            complete.evidence!,
            contentCoverageDigest: 'not-a-sha-256-digest',
          ),
        );
        final readsBefore = harness.snapshotReader.readCount;

        final result = await harness.revalidator.revalidate(malformed);

        expect(
          result.outcome,
          AttachmentArchiveApprovalRevalidationOutcome
              .verificationEvidenceInvalid,
        );
        expect(harness.snapshotReader.readCount, readsBefore);
      },
    );

    test(
      'unexpected structural failure returns failed and releases scope',
      () async {
        final complete = await harness.verifyComplete();
        harness.snapshotReader.beforeRead = () async {
          throw StateError('synthetic structural reader failure');
        };

        final result = await harness.revalidator.revalidate(complete);

        expect(
          result.outcome,
          AttachmentArchiveApprovalRevalidationOutcome.failed,
        );
        expect(harness.coordinatorState.isLocked, isFalse);
      },
    );

    test(
      'a reconstructed service rechecks complete evidence, not old ready evidence',
      () async {
        final complete = await harness.verifyComplete();
        final first = await harness.revalidator.revalidate(complete);
        expect(first.isApprovalReady, isTrue);

        final rebuiltReader = _RecordingSnapshotReader(harness.verifier);
        final rebuilt = AttachmentArchiveApprovalRevalidator(
          mutationCoordinator: harness.coordinator,
          currentLocationReader: harness.locationReader,
          candidateAccessReader: harness.candidateReader,
          snapshotReader: rebuiltReader,
        );
        final second = await rebuilt.revalidate(complete);

        expect(second.isApprovalReady, isTrue);
        expect(rebuiltReader.readCount, 1);
        expect(
          first.readyEvidence,
          isNot(isA<AttachmentArchiveCandidateComplete>()),
        );
      },
    );
  });
}

final class _Harness {
  _Harness._({
    required this.temporaryRoot,
    required this.source,
    required this.candidate,
    required this.database,
    required this.archiveFixture,
    required this.container,
    required this.locationReader,
    required this.candidateReader,
    required this.verifier,
    required this.snapshotReader,
    required this.revalidator,
  });

  final Directory temporaryRoot;
  final Directory source;
  final Directory candidate;
  final OverlayDatabase database;
  final TestArchiveFixture archiveFixture;
  final ProviderContainer container;
  final _MutableCurrentLocationReader locationReader;
  final _MutableCandidateAccessReader candidateReader;
  final FilesystemAttachmentArchiveCandidateVerifier verifier;
  final _RecordingSnapshotReader snapshotReader;
  final AttachmentArchiveApprovalRevalidator revalidator;
  int payloadHashStarts = 0;

  ArchiveMutationCoordinator get coordinator =>
      container.read(archiveMutationCoordinatorProvider.notifier);

  ArchiveMutationCoordinatorState get coordinatorState =>
      container.read(archiveMutationCoordinatorProvider);

  static Future<_Harness> create() async {
    final temporaryRoot = await Directory.systemTemp.createTemp(
      'attachment-approval-revalidation-',
    );
    final source = await Directory(
      path.join(temporaryRoot.path, 'source'),
    ).create();
    final candidate = await Directory(
      path.join(temporaryRoot.path, 'candidate'),
    ).create();
    final database = OverlayDatabase(NativeDatabase.memory());
    final metadataReader = OverlayAttachmentArchiveVerificationMetadataReader(
      overlayDatabase: database,
    );
    final archiveFixture = await TestArchiveFixture.create(
      prefix: 'attachment_approval_coordinator_',
    );
    final container = ProviderContainer(
      overrides: <Override>[
        admittedArchiveAccessAuthorityProvider.overrideWithValue(
          archiveFixture.authority,
        ),
      ],
    );
    final locationReader = _MutableCurrentLocationReader(
      AttachmentArchiveLocationState.defaultAvailable(
        archiveRootPath: source.path,
        generation: 7,
      ),
    );
    final candidateReader = _MutableCandidateAccessReader(
      AttachmentArchiveCandidateAccess(
        directoryPath: candidate.path,
        isPhysicallyWritable: true,
      ),
    );
    late _Harness harness;
    final verifier = FilesystemAttachmentArchiveCandidateVerifier(
      metadataReader: metadataReader,
      onPayloadHashStarted: (_) {
        harness.payloadHashStarts++;
      },
      clock: () => DateTime.utc(2026, 9, 18, 12),
    );
    final snapshotReader = _RecordingSnapshotReader(verifier);
    final revalidator = AttachmentArchiveApprovalRevalidator(
      mutationCoordinator: container.read(
        archiveMutationCoordinatorProvider.notifier,
      ),
      currentLocationReader: locationReader,
      candidateAccessReader: candidateReader,
      snapshotReader: snapshotReader,
      clock: () => DateTime.utc(2026, 9, 18, 12, 0, 4),
    );
    harness = _Harness._(
      temporaryRoot: temporaryRoot,
      source: source,
      candidate: candidate,
      database: database,
      archiveFixture: archiveFixture,
      container: container,
      locationReader: locationReader,
      candidateReader: candidateReader,
      verifier: verifier,
      snapshotReader: snapshotReader,
      revalidator: revalidator,
    );
    return harness;
  }

  Future<AttachmentArchiveCandidateComplete> verifyComplete() async {
    final result = await verifier.verify(
      sourceLocation: locationReader.state,
      candidate: candidateReader.access,
    );
    if (result is! AttachmentArchiveCandidateComplete) {
      throw StateError('Expected complete test archive: ${result.outcome}.');
    }
    return result;
  }

  Future<void> writeMetadataPayload({
    required String relativePath,
    required List<int> bytes,
    required int attachmentId,
    bool includeCandidate = true,
  }) async {
    await _write(source, relativePath, bytes);
    if (includeCandidate) {
      await _write(candidate, relativePath, bytes);
    }
    await insertMetadata(
      guid: 'guid-$attachmentId-$relativePath',
      attachmentId: attachmentId,
      relativePath: relativePath,
      bytes: bytes,
    );
  }

  Future<void> insertMetadata({
    required String guid,
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
        guid,
        attachmentId,
        relativePath,
        '2026-09-18T00:00:00.000Z',
        bytes.length,
        sha256.convert(bytes).toString(),
        'archived',
      ],
    );
  }

  Future<void> copyRelative(String relativePath) async {
    await _write(
      candidate,
      relativePath,
      await File(path.join(source.path, relativePath)).readAsBytes(),
    );
  }

  Future<void> writeContentAddressedExtra(List<int> bytes) async {
    final digest = sha256.convert(bytes).toString();
    await _write(candidate, '${digest.substring(0, 2)}/$digest.bin', bytes);
  }

  Future<void> dispose() async {
    container.dispose();
    await database.close();
    await archiveFixture.dispose();
    if (temporaryRoot.existsSync()) {
      await temporaryRoot.delete(recursive: true);
    }
  }
}

final class _MutableCurrentLocationReader
    implements AttachmentArchiveApprovalCurrentLocationReader {
  _MutableCurrentLocationReader(this.state);

  AttachmentArchiveLocationState state;

  @override
  Future<AttachmentArchiveLocationState> readCurrentLocation() async => state;
}

final class _MutableCandidateAccessReader
    implements AttachmentArchiveApprovalCandidateAccessReader {
  _MutableCandidateAccessReader(this.access);

  AttachmentArchiveCandidateAccess access;
  String? issue;

  @override
  Future<AttachmentArchiveApprovalCandidateAccessResult> readCurrentAccess(
    AttachmentArchiveCandidateComplete verification,
  ) async {
    final currentIssue = issue;
    if (currentIssue != null) {
      return AttachmentArchiveApprovalCandidateUnavailable(currentIssue);
    }
    return AttachmentArchiveApprovalCandidateAvailable(access);
  }
}

final class _RecordingSnapshotReader
    implements AttachmentArchiveApprovalSnapshotReader {
  _RecordingSnapshotReader(this.delegate);

  final AttachmentArchiveApprovalSnapshotReader delegate;
  Future<void> Function()? beforeRead;
  int readCount = 0;

  @override
  Future<AttachmentArchiveApprovalStructuralSnapshot> read({
    required AttachmentArchiveLocationState sourceLocation,
    required AttachmentArchiveCandidateAccess candidate,
    required String expectedSourceCanonicalIdentity,
    required String expectedCandidateCanonicalIdentity,
  }) async {
    readCount++;
    await beforeRead?.call();
    return delegate.read(
      sourceLocation: sourceLocation,
      candidate: candidate,
      expectedSourceCanonicalIdentity: expectedSourceCanonicalIdentity,
      expectedCandidateCanonicalIdentity: expectedCandidateCanonicalIdentity,
    );
  }
}

Future<File> _write(
  Directory root,
  String relativePath,
  List<int> bytes,
) async {
  final file = File(path.join(root.path, relativePath));
  await file.parent.create(recursive: true);
  return file.writeAsBytes(bytes, flush: true);
}

AttachmentArchiveCandidateVerificationEvidence _copyEvidence(
  AttachmentArchiveCandidateVerificationEvidence source, {
  required String contentCoverageDigest,
}) {
  return AttachmentArchiveCandidateVerificationEvidence(
    sourceCanonicalIdentity: source.sourceCanonicalIdentity,
    candidateCanonicalIdentity: source.candidateCanonicalIdentity,
    sourceLocationConfiguration: source.sourceLocationConfiguration,
    sourceLocationGeneration: source.sourceLocationGeneration,
    verifiedAtUtc: source.verifiedAtUtc,
    candidateWasPhysicallyWritable: source.candidateWasPhysicallyWritable,
    requiredSourcePhysicalFileCount: source.requiredSourcePhysicalFileCount,
    requiredSourceBytes: source.requiredSourceBytes,
    verifiedFileCount: source.verifiedFileCount,
    verifiedBytes: source.verifiedBytes,
    metadataReferenceCount: source.metadataReferenceCount,
    unreferencedPreservationCount: source.unreferencedPreservationCount,
    sourceOperationalDebrisCount: source.sourceOperationalDebrisCount,
    candidateOperationalDebrisCount: source.candidateOperationalDebrisCount,
    allowedCandidateExtraCount: source.allowedCandidateExtraCount,
    allowedCandidateExtraBytes: source.allowedCandidateExtraBytes,
    missingCount: source.missingCount,
    missingBytes: source.missingBytes,
    contentCoverageDigest: contentCoverageDigest,
    sourceStructuralSnapshotFingerprint:
        source.sourceStructuralSnapshotFingerprint,
    candidateStructuralSnapshotFingerprint:
        source.candidateStructuralSnapshotFingerprint,
    diagnostics: source.diagnostics,
  );
}
