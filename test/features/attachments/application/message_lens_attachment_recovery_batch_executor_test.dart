import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import 'package:remember_this_text/essentials/archive_environment/domain.dart';
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/messages_lineage_admission.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_location_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_read_store.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_write_store.dart';
import 'package:remember_this_text/features/attachments/application/message_lens_attachment_evidence_reader.dart';
import 'package:remember_this_text/features/attachments/application/message_lens_attachment_recovery_batch_executor.dart';
import 'package:remember_this_text/features/attachments/application/message_lens_attachment_recovery_installer.dart';
import 'package:remember_this_text/features/attachments/application/verified_donor_attachment_payload.dart';
import 'package:remember_this_text/features/attachments/domain/entities/message_lens_attachment_recovery.dart';
import 'package:remember_this_text/features/attachments/domain/entities/message_lens_attachment_recovery_donor.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/filesystem_attachment_archive_file_store.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/overlay_attachment_archive_read_store.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/overlay_attachment_archive_write_store.dart';

import '../../../test_support/test_archive_fixture.dart';

void main() {
  late _BatchHarness harness;

  setUp(() async {
    harness = await _BatchHarness.create();
  });

  tearDown(() async {
    await harness.dispose();
  });

  test(
    'recovers the exact approved set with truthful monotonic progress',
    () async {
      final fixture = harness.fixture(itemCount: 2);
      final progress = <MessageLensAttachmentRecoveryBatchProgress>[];

      final first = await harness.execute(fixture, onProgress: progress.add);

      expect(first.recoveredCount, 2);
      expect(first.recoveredBytes, fixture.totalBytes);
      expect(first.alreadyPresentCount, 0);
      expect(first.couldNotRecoverCount, 0);
      expect(first.terminallyVerifiedCount, 2);
      expect(first.remainingRecoverableCount, 0);
      expect(first.fullyRecovered, isTrue);
      expect(
        first.outcomes.map((outcome) => outcome.status),
        everyElement(MessageLensAttachmentRecoveryItemStatus.installed),
      );
      expect(
        progress.first.stage,
        MessageLensAttachmentRecoveryBatchStage.verifyingDonorPayloads,
      );
      expect(
        progress.last.stage,
        MessageLensAttachmentRecoveryBatchStage.complete,
      );
      expect(progress.last.recoveredAttachments, 2);
      expect(progress.last.copiedBytes, fixture.totalBytes);
      _expectMonotonic(progress.map((value) => value.verifiedBytes));
      _expectMonotonic(progress.map((value) => value.copiedBytes));
      _expectMonotonic(progress.map((value) => value.processedAttachments));

      final second = await harness.execute(fixture);

      expect(second.recoveredCount, 0);
      expect(second.alreadyPresentCount, 2);
      expect(second.couldNotRecoverCount, 0);
      expect(second.terminallyVerifiedCount, 2);
      expect(second.remainingRecoverableCount, 0);
      expect(second.fullyRecovered, isTrue);
      expect(harness.verifier.verifiedInspectionCount, 2);
      expect(
        await harness.overlayDatabase
            .select(harness.overlayDatabase.archivedAttachments)
            .get(),
        hasLength(2),
      );
    },
  );

  test(
    'unavailable writable root returns a typed deferred batch result',
    () async {
      final fixture = harness.fixture(itemCount: 2);
      const runner = DeferredMessageLensAttachmentRecoveryBatchRunner(
        AttachmentArchiveMutationDeferredReason.customArchiveUnavailable,
      );

      final result = await harness.coordinator
          .runWithCapability<MessageLensAttachmentRecoveryBatchResult>(
            operation: ArchiveMutationOperation.attachmentReconciliation,
            ownerLabel: 'deferred-attachment-recovery-batch-test',
            action: (capability) => runner.execute(
              mutationCapability: capability,
              donor: fixture.donor,
              lineageAdmission: fixture.lineageAdmission,
              preflight: fixture.preflight,
              preflightApprovedCandidates: fixture.candidates,
            ),
          );

      expect(result.isDeferred, isTrue);
      expect(
        result.deferredReason,
        AttachmentArchiveMutationDeferredReason.customArchiveUnavailable,
      );
      expect(result.outcomes, isEmpty);
      expect(result.remainingRecoverableCount, 2);
    },
  );

  test(
    'rejects any list that is not the exact preflight recoverable set',
    () async {
      final fixture = harness.fixture(itemCount: 2);

      await expectLater(
        harness.execute(fixture, approved: [fixture.candidates.first]),
        throwsA(isA<StateError>()),
      );

      final outside = _candidate(99, 'outside'.codeUnits);
      await expectLater(
        harness.execute(fixture, approved: [...fixture.candidates, outside]),
        throwsA(isA<StateError>()),
      );
      expect(harness.verifier.verifiedInspectionCount, 0);
    },
  );

  test(
    'records an expected item failure and continues recovering later items',
    () async {
      final fixture = harness.fixture(itemCount: 2);
      harness.verifier.missingPaths.add(
        fixture.candidates.first.donorArchiveRelativePath,
      );

      final result = await harness.execute(fixture);

      expect(result.recoveredCount, 1);
      expect(result.couldNotRecoverCount, 1);
      expect(result.remainingRecoverableCount, 0);
      expect(result.fullyRecovered, isFalse);
      expect(
        result.outcomes.map((outcome) => outcome.status),
        containsAll([
          MessageLensAttachmentRecoveryItemStatus.donorMissing,
          MessageLensAttachmentRecoveryItemStatus.installed,
        ]),
      );
    },
  );

  test('stops before mutation when exhaustive donor integrity fails', () async {
    final fixture = harness.fixture(itemCount: 2);
    harness.donorReader.integrityFailure = StateError('donor integrity failed');

    await expectLater(harness.execute(fixture), throwsA(isA<StateError>()));

    expect(harness.verifier.verifiedInspectionCount, 0);
    expect(
      await harness.overlayDatabase
          .select(harness.overlayDatabase.archivedAttachments)
          .get(),
      isEmpty,
    );
  });

  test(
    'rejects donor bytes changed after preflight without installing them',
    () async {
      final fixture = harness.fixture(itemCount: 1);
      harness.verifier.bytesByPath[fixture
              .candidates
              .single
              .donorArchiveRelativePath] =
          'changed donor bytes'.codeUnits;

      final result = await harness.execute(fixture);

      expect(result.recoveredCount, 0);
      expect(result.couldNotRecoverCount, 1);
      expect(
        result.outcomes.single.status,
        MessageLensAttachmentRecoveryItemStatus.donorChanged,
      );
      expect(
        await harness.overlayDatabase
            .select(harness.overlayDatabase.archivedAttachments)
            .get(),
        isEmpty,
      );
    },
  );

  test('rejects wrong and expired mutation capabilities', () async {
    final fixture = harness.fixture(itemCount: 1);

    await expectLater(
      harness.coordinator.runWithCapability<void>(
        operation: ArchiveMutationOperation.graphBuild,
        ownerLabel: 'wrong-batch-capability',
        action: (capability) async {
          await harness.executor.execute(
            mutationCapability: capability,
            donor: fixture.donor,
            lineageAdmission: fixture.lineageAdmission,
            preflight: fixture.preflight,
            preflightApprovedCandidates: fixture.candidates,
          );
        },
      ),
      throwsA(isA<ArchiveMutationCapabilityDeniedException>()),
    );

    late ArchiveMutationCapability staleCapability;
    await harness.coordinator.runWithCapability<void>(
      operation: ArchiveMutationOperation.attachmentReconciliation,
      ownerLabel: 'capture-stale-batch-capability',
      action: (capability) async {
        staleCapability = capability;
      },
    );
    await expectLater(
      harness.executor.execute(
        mutationCapability: staleCapability,
        donor: fixture.donor,
        lineageAdmission: fixture.lineageAdmission,
        preflight: fixture.preflight,
        preflightApprovedCandidates: fixture.candidates,
      ),
      throwsA(isA<ArchiveMutationCapabilityDeniedException>()),
    );
  });

  test(
    'an interrupted subset converges on retry without duplicate metadata',
    () async {
      final fixture = harness.fixture(itemCount: 2);
      final interrupting = harness.executorWithInstaller(
        _InterruptAfterFirstInstaller(
          delegate: harness.installer,
          writableRootLease: harness.writableRootLease,
        ),
      );

      await expectLater(
        harness.execute(fixture, executor: interrupting),
        throwsA(isA<StateError>()),
      );
      expect(
        await harness.overlayDatabase
            .select(harness.overlayDatabase.archivedAttachments)
            .get(),
        hasLength(1),
      );

      final retry = await harness.execute(fixture);

      expect(retry.recoveredCount, 1);
      expect(retry.alreadyPresentCount, 1);
      expect(retry.couldNotRecoverCount, 0);
      expect(retry.remainingRecoverableCount, 0);
      expect(retry.fullyRecovered, isTrue);
      expect(
        await harness.overlayDatabase
            .select(harness.overlayDatabase.archivedAttachments)
            .get(),
        hasLength(2),
      );
    },
  );
}

void _expectMonotonic(Iterable<int> values) {
  int? previous;
  for (final value in values) {
    if (previous != null) {
      expect(value, greaterThanOrEqualTo(previous));
    }
    previous = value;
  }
}

final class _BatchHarness {
  _BatchHarness._({
    required this.temporaryRoot,
    required this.archiveFixture,
    required this.providerContainer,
    required this.coordinator,
    required this.overlayDatabase,
    required this.archiveDirectory,
    required this.fileStore,
    required this.readStore,
    required this.writeStore,
    required this.writableRootLease,
    required this.donorReader,
    required this.currentReader,
    required this.verifier,
    required this.installer,
  }) : executor = MessageLensAttachmentRecoveryBatchExecutor(
         donorEvidenceReader: donorReader,
         currentEvidenceReader: currentReader,
         payloadVerifier: verifier,
         installer: installer,
         fileStore: fileStore,
         writableRootLease: writableRootLease,
       );

  final Directory temporaryRoot;
  final TestArchiveFixture archiveFixture;
  final ProviderContainer providerContainer;
  final ArchiveMutationCoordinator coordinator;
  final OverlayDatabase overlayDatabase;
  final Directory archiveDirectory;
  final FilesystemAttachmentArchiveFileStore fileStore;
  final OverlayAttachmentArchiveReadStore readStore;
  final OverlayAttachmentArchiveWriteStore writeStore;
  final AttachmentArchiveWritableRootLease writableRootLease;
  final _FakeDonorEvidenceReader donorReader;
  final _FakeCurrentEvidenceReader currentReader;
  final _MemoryPayloadVerifier verifier;
  final MessageLensAttachmentRecoveryInstaller installer;
  final MessageLensAttachmentRecoveryBatchExecutor executor;

  static Future<_BatchHarness> create() async {
    final temporaryRoot = await Directory.systemTemp.createTemp(
      'message_lens_attachment_recovery_batch_test_',
    );
    final archiveFixture = await TestArchiveFixture.create(
      prefix: 'message_lens_attachment_recovery_batch_authority_test_',
    );
    final providerContainer = ProviderContainer(
      overrides: [
        admittedArchiveAccessAuthorityProvider.overrideWithValue(
          archiveFixture.authority,
        ),
      ],
    );
    final overlayDatabase = OverlayDatabase(NativeDatabase.memory());
    final writableRootLease = (await providerContainer.read(
      attachmentArchiveWritableRootAdmissionProvider.future,
    )).lease!;
    final archiveDirectory = Directory(writableRootLease.archiveRootPath);
    const fileStore = FilesystemAttachmentArchiveFileStore();
    final readStore = OverlayAttachmentArchiveReadStore(
      overlayDb: overlayDatabase,
      archiveDirectory: archiveDirectory.path,
    );
    final writeStore = OverlayAttachmentArchiveWriteStore(
      overlayDatabase: overlayDatabase,
    );
    final donorReader = _FakeDonorEvidenceReader();
    final currentReader = _FakeCurrentEvidenceReader(readStore: readStore);
    final verifier = _MemoryPayloadVerifier();
    final installer = MessageLensAttachmentRecoveryInstaller(
      fileStore: fileStore,
      readStore: readStore,
      writeStore: writeStore,
      writableRootLease: writableRootLease,
    );
    return _BatchHarness._(
      temporaryRoot: temporaryRoot,
      archiveFixture: archiveFixture,
      providerContainer: providerContainer,
      coordinator: providerContainer.read(
        archiveMutationCoordinatorProvider.notifier,
      ),
      overlayDatabase: overlayDatabase,
      archiveDirectory: archiveDirectory,
      fileStore: fileStore,
      readStore: readStore,
      writeStore: writeStore,
      writableRootLease: writableRootLease,
      donorReader: donorReader,
      currentReader: currentReader,
      verifier: verifier,
      installer: installer,
    );
  }

  _BatchFixture fixture({required int itemCount}) {
    final candidates = <MessageLensAttachmentRecoveryCandidate>[];
    final relationships = <MessageLensAttachmentRelationshipEvidence>[];
    final claims = <MessageLensArchivedPayloadClaim>[];
    for (var index = 1; index <= itemCount; index++) {
      final bytes = 'attachment payload $index'.codeUnits;
      final candidate = _candidate(index, bytes);
      final relationship = _relationship(index);
      candidates.add(candidate);
      relationships.add(relationship);
      claims.add(
        MessageLensArchivedPayloadClaim(
          archiveCompatibilityKey: candidate.archiveCompatibilityKey,
          payload: MessageLensArchivedPayloadEvidence(
            archiveRelativePath: candidate.donorArchiveRelativePath,
            recordedSizeBytes: bytes.length,
            recordedSha256: candidate.donorPayloadSha256,
          ),
        ),
      );
      verifier.bytesByPath[candidate.donorArchiveRelativePath] = bytes;
    }
    donorReader
      ..relationships = relationships
      ..claims = claims;
    currentReader.relationships = relationships;
    return _BatchFixture(
      donor: const MessageLensAttachmentRecoveryDonor(
        rootPath: '/read-only/donor',
        format: MessageLensAttachmentRecoveryDonorFormat.currentMarkerV1,
        archiveInstanceId: 'donor-instance',
      ),
      lineageAdmission: _sameLineageAdmission(),
      candidates: candidates,
      preflight: _preflight(candidates),
    );
  }

  MessageLensAttachmentRecoveryBatchExecutor executorWithInstaller(
    MessageLensAttachmentRecoveryInstaller selectedInstaller,
  ) {
    return MessageLensAttachmentRecoveryBatchExecutor(
      donorEvidenceReader: donorReader,
      currentEvidenceReader: currentReader,
      payloadVerifier: verifier,
      installer: selectedInstaller,
      fileStore: fileStore,
      writableRootLease: writableRootLease,
    );
  }

  Future<MessageLensAttachmentRecoveryBatchResult> execute(
    _BatchFixture fixture, {
    List<MessageLensAttachmentRecoveryCandidate>? approved,
    MessageLensAttachmentRecoveryBatchExecutor? executor,
    MessageLensAttachmentRecoveryBatchProgressObserver? onProgress,
  }) {
    return coordinator
        .runWithCapability<MessageLensAttachmentRecoveryBatchResult>(
          operation: ArchiveMutationOperation.attachmentReconciliation,
          ownerLabel: 'attachment-recovery-batch-test',
          action: (capability) => (executor ?? this.executor).execute(
            mutationCapability: capability,
            donor: fixture.donor,
            lineageAdmission: fixture.lineageAdmission,
            preflight: fixture.preflight,
            preflightApprovedCandidates: approved ?? fixture.candidates,
            onProgress: onProgress,
          ),
        );
  }

  Future<void> dispose() async {
    providerContainer.dispose();
    await overlayDatabase.close();
    await archiveFixture.dispose();
    if (temporaryRoot.existsSync()) {
      await temporaryRoot.delete(recursive: true);
    }
  }
}

final class _BatchFixture {
  const _BatchFixture({
    required this.donor,
    required this.lineageAdmission,
    required this.candidates,
    required this.preflight,
  });

  final MessageLensAttachmentRecoveryDonor donor;
  final SameMessagesLineageAdmission lineageAdmission;
  final List<MessageLensAttachmentRecoveryCandidate> candidates;
  final MessageLensAttachmentRecoveryPreflight preflight;

  int get totalBytes =>
      candidates.fold(0, (sum, candidate) => sum + candidate.recoverableBytes);
}

final class _FakeDonorEvidenceReader
    implements MessageLensDonorAttachmentEvidenceReader {
  List<MessageLensAttachmentRelationshipEvidence> relationships = [];
  List<MessageLensArchivedPayloadClaim> claims = [];
  Object? integrityFailure;

  @override
  Future<void> validateCompatibility() async {}

  @override
  Future<void> validateExecutionIntegrity() async {
    if (integrityFailure case final failure?) {
      throw failure;
    }
  }

  @override
  Future<List<MessageLensAttachmentRelationshipEvidence>>
  readLiveSourceRelationships() async => relationships;

  @override
  Future<List<MessageLensArchivedPayloadClaim>>
  readArchivedPayloadClaims() async => claims;

  @override
  Future<MessageLensArchivedPayloadEvidence?> readArchivedPayload(
    ArchiveCompatibilityKey archiveKey,
  ) async {
    return claims
        .where((claim) => claim.archiveCompatibilityKey == archiveKey)
        .firstOrNull
        ?.payload;
  }

  @override
  Future<List<MessageLensAttachmentRelationshipEvidence>> readRelationships({
    required int sourceId,
    required int originalMessageRowId,
    required int originalAttachmentRowId,
  }) async {
    return relationships
        .where(
          (relationship) =>
              relationship.originalMessageRowId == originalMessageRowId &&
              relationship.originalAttachmentRowId == originalAttachmentRowId,
        )
        .toList(growable: false);
  }
}

final class _FakeCurrentEvidenceReader
    implements CurrentMessageLensAttachmentEvidenceReader {
  _FakeCurrentEvidenceReader({required AttachmentArchiveReadStore readStore})
    : _readStore = readStore;

  final AttachmentArchiveReadStore _readStore;
  List<MessageLensAttachmentRelationshipEvidence> relationships = [];

  @override
  Future<List<MessageLensAttachmentRelationshipEvidence>>
  readLiveSourceRelationships() async => relationships;

  @override
  Future<Map<ArchiveCompatibilityKey, CurrentAttachmentPayloadStatus>>
  readPayloadStatuses(
    List<ArchiveCompatibilityKey> archiveKeys, {
    void Function(int completed, int total)? onProgress,
  }) async {
    final statuses =
        <ArchiveCompatibilityKey, CurrentAttachmentPayloadStatus>{};
    for (var index = 0; index < archiveKeys.length; index++) {
      final key = archiveKeys[index];
      final record = await _readStore.readArchiveRecord(key);
      statuses[key] = record != null && record.archiveFileExists
          ? CurrentAttachmentPayloadStatus.presentValid
          : CurrentAttachmentPayloadStatus.missing;
      onProgress?.call(index + 1, archiveKeys.length);
    }
    return statuses;
  }

  @override
  Future<List<MessageLensAttachmentRelationshipEvidence>> readRelationships({
    required int sourceId,
    required int originalMessageRowId,
    required int originalAttachmentRowId,
  }) async {
    return relationships
        .where(
          (relationship) =>
              relationship.originalMessageRowId == originalMessageRowId &&
              relationship.originalAttachmentRowId == originalAttachmentRowId,
        )
        .toList(growable: false);
  }
}

final class _MemoryPayloadVerifier
    implements MessageLensAttachmentRecoveryPayloadVerifier {
  final Map<String, List<int>> bytesByPath = {};
  final Set<String> missingPaths = {};
  int verifiedInspectionCount = 0;

  @override
  Future<AttachmentPayloadInspection> inspect({
    required String donorArchiveRoot,
    required MessageLensArchivedPayloadEvidence payload,
  }) async {
    final bytes = bytesByPath[payload.archiveRelativePath];
    if (bytes == null || missingPaths.contains(payload.archiveRelativePath)) {
      return const AttachmentPayloadInspection.missing();
    }
    return AttachmentPayloadInspection(
      status: AttachmentPayloadInspectionStatus.valid,
      actualSizeBytes: bytes.length,
      actualSha256: sha256.convert(bytes).toString(),
    );
  }

  @override
  Future<VerifiedDonorAttachmentPayloadResult> inspectVerified({
    required String donorArchiveRoot,
    required MessageLensArchivedPayloadEvidence payload,
    void Function(int bytesProcessed)? onBytesProcessed,
  }) async {
    verifiedInspectionCount += 1;
    final inspection = await inspect(
      donorArchiveRoot: donorArchiveRoot,
      payload: payload,
    );
    final bytes = bytesByPath[payload.archiveRelativePath];
    if (inspection.status != AttachmentPayloadInspectionStatus.valid ||
        bytes == null) {
      return VerifiedDonorAttachmentPayloadResult(
        inspection: inspection,
        payload: null,
      );
    }
    onBytesProcessed?.call(bytes.length);
    return VerifiedDonorAttachmentPayloadResult(
      inspection: inspection,
      payload: _MemoryVerifiedPayload(
        bytes: bytes,
        archiveRelativePath: payload.archiveRelativePath,
      ),
    );
  }
}

final class _MemoryVerifiedPayload implements VerifiedDonorAttachmentPayload {
  _MemoryVerifiedPayload({
    required this.bytes,
    required this.archiveRelativePath,
  }) : expectedSha256 = sha256.convert(bytes).toString();

  final List<int> bytes;

  @override
  final String archiveRelativePath;

  @override
  int get expectedSizeBytes => bytes.length;

  @override
  final String expectedSha256;

  @override
  String get sourceExtension => '.bin';

  @override
  Stream<List<int>> openRead() => Stream<List<int>>.value(bytes);
}

final class _InterruptAfterFirstInstaller
    extends MessageLensAttachmentRecoveryInstaller {
  _InterruptAfterFirstInstaller({
    required this.delegate,
    required AttachmentArchiveWritableRootLease writableRootLease,
  }) : super(
         fileStore: const FilesystemAttachmentArchiveFileStore(),
         readStore: _NeverReadStore(),
         writeStore: _NeverWriteStore(),
         writableRootLease: writableRootLease,
       );

  final MessageLensAttachmentRecoveryInstaller delegate;
  var _calls = 0;

  @override
  Future<MessageLensAttachmentInstallationResult> install({
    required ArchiveMutationCapability mutationCapability,
    required MessageLensAttachmentRecoveryCandidate candidate,
    required VerifiedDonorAttachmentPayload donorPayload,
    DateTime? installedAtUtc,
  }) async {
    _calls += 1;
    if (_calls > 1) {
      throw StateError('simulated process interruption');
    }
    return delegate.install(
      mutationCapability: mutationCapability,
      candidate: candidate,
      donorPayload: donorPayload,
      installedAtUtc: installedAtUtc,
    );
  }
}

final class _NeverReadStore implements AttachmentArchiveReadStore {
  @override
  Never noSuchMethod(Invocation invocation) => throw StateError('unused');
}

final class _NeverWriteStore implements AttachmentArchiveWriteStore {
  @override
  Never noSuchMethod(Invocation invocation) => throw StateError('unused');
}

MessageLensAttachmentRecoveryCandidate _candidate(int id, List<int> bytes) {
  return MessageLensAttachmentRecoveryCandidate(
    archiveCompatibilityKey: ArchiveCompatibilityKey(
      messageGuid: 'message-guid-$id',
      importAttachmentId: id,
    ),
    classification: MessageLensAttachmentRecoveryClassification.recoverable,
    recoverableBytes: bytes.length,
    donorArchiveRelativePath: 'donor/$id.bin',
    donorPayloadSha256: sha256.convert(bytes).toString(),
  );
}

MessageLensAttachmentRelationshipEvidence _relationship(int id) {
  return MessageLensAttachmentRelationshipEvidence(
    messageSsId: id,
    messageSourceId: 1,
    originalMessageRowId: id,
    messageGuid: 'message-guid-$id',
    attachmentSsId: id,
    attachmentSourceId: 1,
    originalAttachmentRowId: id,
    attachmentGuid: 'attachment-guid-$id',
    relationshipOccurrenceCount: 1,
    sourceScopedIdentityIsCoherent: true,
    totalBytes: 'attachment payload $id'.codeUnits.length,
  );
}

MessageLensAttachmentRecoveryPreflight _preflight(
  List<MessageLensAttachmentRecoveryCandidate> candidates,
) {
  final count = candidates.length;
  return MessageLensAttachmentRecoveryPreflight(
    candidates: candidates,
    funnel: MessageLensAttachmentRecoveryFunnel(
      donorPayloadClaimCount: count,
      donorRelationshipEvidenceCount: count,
      currentRelationshipEvidenceCount: count,
      donorRelationshipUnmatchedCount: 0,
      messageMatchedCount: count,
      attachmentMatchedCount: count,
      donorPayloadPresentCount: count,
      currentPayloadPresentCount: 0,
      duplicateClaimsCollapsedCount: 0,
    ),
    examinedCount: count,
    recoverableCount: count,
    recoverableBytes: candidates.fold(
      0,
      (sum, candidate) => sum + candidate.recoverableBytes,
    ),
    alreadyPresentCount: 0,
    donorMissingCount: 0,
    messageMismatchCount: 0,
    attachmentMismatchCount: 0,
    conflictCount: 0,
    ambiguousCount: 0,
    unsafeDonorPathCount: 0,
  );
}

SameMessagesLineageAdmission _sameLineageAdmission() {
  final admission = MessagesLineageAdmission.fromEvidence(
    const MessagesLineageEvidence(
      candidateRecordCount: 64,
      usableCandidateIdentityCount: 64,
      blankCandidateGuidCount: 0,
      inconsistentCandidateIdentityCount: 0,
      duplicateCandidateRowIdCount: 0,
      currentRowsInCandidateRangeCount: 64,
      comparableCount: 64,
      matchingCount: 64,
      contradictionCount: 0,
      missingCurrentRowCount: 0,
      unusableCurrentGuidCount: 0,
      matchingRowIdBandCount: 3,
      candidateSourceShapeIsCoherent: true,
      currentSourceShapeIsCoherent: true,
    ),
  );
  return admission as SameMessagesLineageAdmission;
}
