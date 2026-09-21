import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_adoption_enablement_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_adoption_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_adoption_workflow.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_adoption_workflow_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_bookmark_adapter.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_candidate_verifier.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_location_folder_chooser.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_adoption.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_candidate_verification.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_configuration.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_state.dart';

void main() {
  group('AttachmentArchiveAdoptionWorkflow', () {
    test(
      'chooser cancel retains current archive and performs no work',
      () async {
        final harness = _Harness(chooserPath: null);
        addTearDown(harness.dispose);

        await harness.notifier.chooseExistingArchive();

        expect(harness.state.stage, _Stage.currentArchive);
        expect(harness.bookmarks.createCount, 0);
        expect(harness.verifier.verifyCount, 0);
        expect(harness.executor.adoptCount, 0);
      },
    );

    test(
      'selection resolves a bookmark then begins read-only checking',
      () async {
        final harness = _Harness();
        addTearDown(harness.dispose);

        await harness.notifier.chooseExistingArchive();

        expect(harness.chooser.chooseCount, 1);
        expect(harness.bookmarks.createCount, 1);
        expect(harness.bookmarks.resolveCount, 1);
        expect(harness.verifier.verifyCount, 1);
        expect(harness.executor.adoptCount, 0);
        expect(harness.state.stage, _Stage.candidateComplete);
        expect(harness.state.sourcePath, _sourcePath);
        expect(harness.state.candidatePath, _candidatePath);
      },
    );

    test('checking publishes ephemeral progress and cancels cleanly', () async {
      final blocker = Completer<void>();
      final harness = _Harness()..verifier.blocker = blocker;
      addTearDown(harness.dispose);

      final checking = harness.notifier.chooseExistingArchive();
      await _flushAsync();

      expect(harness.state.stage, _Stage.checking);
      expect(harness.state.progress?.filesChecked, 7);
      expect(harness.state.progress?.bytesChecked, 4096);

      await harness.notifier.cancelCheck();
      expect(harness.state.stage, _Stage.currentArchive);

      blocker.complete();
      await checking;
      expect(harness.state.stage, _Stage.currentArchive);
      expect(harness.executor.adoptCount, 0);
    });

    test(
      'complete retains exact totals and adopts only on explicit use',
      () async {
        final harness = _Harness();
        addTearDown(harness.dispose);

        await harness.notifier.chooseExistingArchive();
        expect(harness.state.verifiedFileCount, 4);
        expect(harness.state.verifiedBytes, 3461);
        expect(harness.state.allowedExtraCount, 3);
        expect(harness.state.canUseCandidate, isTrue);
        expect(harness.executor.adoptCount, 0);

        await harness.notifier.useCandidate();

        expect(harness.executor.adoptCount, 1);
        expect(harness.state.stage, _Stage.success);
        expect(harness.state.sourcePath, _sourcePath);
        expect(harness.state.candidatePath, _candidatePath);
      },
    );

    test(
      'read-only complete cannot begin adoption and can be checked again',
      () async {
        final harness = _Harness()
          ..bookmarks.status =
              AttachmentArchiveBookmarkResolutionStatus.readOnly;
        addTearDown(harness.dispose);

        await harness.notifier.chooseExistingArchive();

        expect(harness.state.stage, _Stage.candidateComplete);
        expect(harness.state.candidateIsAdoptable, isFalse);
        expect(harness.state.canUseCandidate, isFalse);
        await harness.notifier.useCandidate();
        expect(harness.executor.adoptCount, 0);

        harness.bookmarks.status =
            AttachmentArchiveBookmarkResolutionStatus.available;
        await harness.notifier.checkAgain();
        expect(harness.state.canUseCandidate, isTrue);
        expect(harness.verifier.verifyCount, 2);
      },
    );

    test(
      'bounded exact behind offers use but never starts automatically',
      () async {
        final harness = _Harness()
          ..verifier.resultBuilder = (access) => _behind(access);
        addTearDown(harness.dispose);

        await harness.notifier.chooseExistingArchive();

        expect(harness.state.stage, _Stage.candidateBehind);
        expect(harness.state.missingCount, 1);
        expect(harness.state.missingBytes, 3100);
        expect(harness.state.canUseCandidate, isTrue);
        expect(harness.executor.adoptCount, 0);
        await harness.notifier.useCandidate();
        expect(harness.executor.adoptCount, 1);
        expect(harness.state.stage, _Stage.success);
      },
    );

    test('large or inexact behind delta cannot be adopted', () async {
      final tooMany = _Harness()
        ..verifier.resultBuilder = (access) =>
            _behind(access, missingCount: 257, missingBytes: 257);
      addTearDown(tooMany.dispose);
      await tooMany.notifier.chooseExistingArchive();
      expect(tooMany.state.canUseCandidate, isFalse);

      final tooLarge = _Harness()
        ..verifier.resultBuilder = (access) => _behind(
          access,
          missingCount: 1,
          missingBytes:
              AttachmentArchiveAdoptionTransaction.maximumRemediationBytes + 1,
        );
      addTearDown(tooLarge.dispose);
      await tooLarge.notifier.chooseExistingArchive();
      expect(tooLarge.state.canUseCandidate, isFalse);
    });

    test(
      'invalid candidate exposes its typed reason and cannot adopt',
      () async {
        final harness = _Harness()
          ..verifier.resultBuilder = (access) => _invalid(access);
        addTearDown(harness.dispose);

        await harness.notifier.chooseExistingArchive();

        expect(harness.state.stage, _Stage.candidateInvalid);
        expect(harness.state.issue, contains('symbolic link'));
        await harness.notifier.useCandidate();
        expect(harness.executor.adoptCount, 0);
      },
    );

    test('source and candidate unavailability remain distinct', () async {
      final sourceHarness = _Harness()
        ..verifier.resultBuilder = (access) => _sourceUnavailable(access);
      addTearDown(sourceHarness.dispose);
      await sourceHarness.notifier.chooseExistingArchive();
      expect(sourceHarness.state.stage, _Stage.sourceUnavailable);

      final candidateHarness = _Harness()
        ..bookmarks.status =
            AttachmentArchiveBookmarkResolutionStatus.unavailable;
      addTearDown(candidateHarness.dispose);
      await candidateHarness.notifier.chooseExistingArchive();
      expect(candidateHarness.state.stage, _Stage.candidateUnavailable);
      expect(candidateHarness.verifier.verifyCount, 0);
    });

    for (final entry in <(AttachmentArchiveAdoptionOutcome, _Stage)>[
      (
        AttachmentArchiveAdoptionOutcome.sourceChangedCheckAgain,
        _Stage.archiveChanged,
      ),
      (
        AttachmentArchiveAdoptionOutcome.candidateChangedCheckAgain,
        _Stage.archiveChanged,
      ),
      (
        AttachmentArchiveAdoptionOutcome.sourceUnavailable,
        _Stage.sourceUnavailable,
      ),
      (
        AttachmentArchiveAdoptionOutcome.candidateUnavailable,
        _Stage.candidateUnavailable,
      ),
      (
        AttachmentArchiveAdoptionOutcome.candidateNoLongerWritable,
        _Stage.candidateNoLongerWritable,
      ),
      (
        AttachmentArchiveAdoptionOutcome.verificationEvidenceInvalid,
        _Stage.verificationEvidenceInvalid,
      ),
      (
        AttachmentArchiveAdoptionOutcome.rollbackRestoredPrevious,
        _Stage.rollbackRestoredPrevious,
      ),
      (
        AttachmentArchiveAdoptionOutcome.rollbackPendingPreviousUnavailable,
        _Stage.rollbackPendingPreviousUnavailable,
      ),
      (
        AttachmentArchiveAdoptionOutcome.configurationConflict,
        _Stage.configurationConflict,
      ),
    ]) {
      test('maps adoption ${entry.$1.name} without false success', () async {
        final harness = _Harness()
          ..executor.result = AttachmentArchiveAdoptionResult(
            outcome: entry.$1,
            issue: 'typed ${entry.$1.name}',
          );
        addTearDown(harness.dispose);

        await harness.notifier.chooseExistingArchive();
        await harness.notifier.useCandidate();

        expect(harness.state.stage, entry.$2);
        expect(harness.state.stage, isNot(_Stage.success));
        expect(harness.state.issue, 'typed ${entry.$1.name}');
      });
    }

    test('switching state remains visible until transaction success', () async {
      final adoption = Completer<AttachmentArchiveAdoptionResult>();
      final harness = _Harness()..executor.blocker = adoption;
      addTearDown(harness.dispose);
      await harness.notifier.chooseExistingArchive();

      final switching = harness.notifier.useCandidate();
      await _flushAsync();
      expect(harness.state.stage, _Stage.switching);

      adoption.complete(
        const AttachmentArchiveAdoptionResult(
          outcome: AttachmentArchiveAdoptionOutcome.adopted,
        ),
      );
      await switching;
      expect(harness.state.stage, _Stage.success);
    });

    test(
      'remediation completion transitions through determinate final coverage '
      'and cannot publish success before executor completion',
      () async {
        final adoption = Completer<AttachmentArchiveAdoptionResult>();
        final harness = _Harness();
        harness.verifier.resultBuilder = (access) => _behind(access);
        harness.executor.blocker = adoption;
        addTearDown(harness.dispose);
        await harness.notifier.chooseExistingArchive();

        final running = harness.notifier.useCandidate();
        await _flushAsync();
        harness.executor.emitFinalCoverage(
          const AttachmentArchiveVerificationProgress(
            phase: AttachmentArchiveVerificationPhase.sourceCoverage,
            filesChecked: 20,
            bytesChecked: 200,
            totalFiles: 40,
            totalBytes: 400,
          ),
        );
        await _flushAsync();

        expect(harness.state.stage, _Stage.verifyingFinalCoverage);
        expect(harness.state.progress?.fractionComplete, 0.5);
        expect(harness.state.stage, isNot(_Stage.success));
        adoption.complete(
          const AttachmentArchiveAdoptionResult(
            outcome: AttachmentArchiveAdoptionOutcome.adopted,
          ),
        );
        await running;
        expect(harness.state.stage, _Stage.success);
      },
    );

    test(
      'stale pending cache emission cannot overwrite stable success',
      () async {
        final harness = _Harness();
        addTearDown(harness.dispose);
        await harness.notifier.chooseExistingArchive();
        await harness.notifier.useCandidate();
        expect(harness.state.stage, _Stage.success);

        harness.pendingStore.current = _pendingTransaction();
        harness.container.invalidate(
          attachmentArchivePendingAdoptionTransactionProvider,
        );
        expect(
          await harness.container.read(
            attachmentArchivePendingAdoptionTransactionProvider.future,
          ),
          isNotNull,
        );
        await _flushAsync();

        expect(harness.state.stage, _Stage.success);
        expect(harness.state.candidatePath, _candidatePath);
      },
    );

    test('deliberate dismissal clears stable terminal success', () async {
      final harness = _Harness();
      addTearDown(harness.dispose);
      await harness.notifier.chooseExistingArchive();
      await harness.notifier.useCandidate();
      expect(harness.state.stage, _Stage.success);

      await harness.notifier.cancelCheck();

      expect(harness.state.stage, _Stage.currentArchive);
    });

    test(
      'pending provider lifecycle resolves absent to active to absent',
      () async {
        final harness = _Harness();
        addTearDown(harness.dispose);
        expect(harness.state.stage, _Stage.currentArchive);
        expect(
          await harness.container.read(
            attachmentArchivePendingAdoptionTransactionProvider.future,
          ),
          isNull,
        );

        harness.pendingStore.current = _pendingTransaction();
        harness.container.invalidate(
          attachmentArchivePendingAdoptionTransactionProvider,
        );
        expect(
          await harness.container.read(
            attachmentArchivePendingAdoptionTransactionProvider.future,
          ),
          isNotNull,
        );
        await _flushAsync();
        expect(harness.state.stage, _Stage.remediationPending);

        harness.executor.result = const AttachmentArchiveAdoptionResult(
          outcome: AttachmentArchiveAdoptionOutcome.remediationComplete,
        );
        await harness.notifier.resumePendingRemediation();

        expect(
          await harness.container.read(
            attachmentArchivePendingAdoptionTransactionProvider.future,
          ),
          isNull,
        );
        expect(harness.state.stage, _Stage.success);
      },
    );

    test('provider reconstruction discards a ready verification', () async {
      final first = _Harness();
      await first.notifier.chooseExistingArchive();
      expect(first.state.stage, _Stage.candidateComplete);
      first.dispose();

      final second = _Harness();
      addTearDown(second.dispose);
      expect(second.state.stage, _Stage.currentArchive);
      expect(second.state.canUseCandidate, isFalse);
    });

    test(
      'restart reconstructs pending remediation and resume preserves paths',
      () async {
        final harness = _Harness(pendingAdoption: _pendingTransaction());
        addTearDown(harness.dispose);
        harness.executor.result = const AttachmentArchiveAdoptionResult(
          outcome: AttachmentArchiveAdoptionOutcome.remediationComplete,
        );
        expect(harness.state.stage, _Stage.currentArchive);
        await _flushAsync();

        expect(harness.state.stage, _Stage.remediationPending);
        expect(harness.state.sourcePath, _sourcePath);
        expect(harness.state.candidatePath, _candidatePath);

        await harness.notifier.resumePendingRemediation();

        expect(harness.executor.resumeCount, 1);
        expect(harness.state.stage, _Stage.success);
        expect(harness.state.sourcePath, _sourcePath);
        expect(harness.state.candidatePath, _candidatePath);
      },
    );

    test('disabled execution gate cannot open chooser or verify', () async {
      final harness = _Harness(executionEnabled: false);
      addTearDown(harness.dispose);

      await harness.notifier.chooseExistingArchive();

      expect(harness.state.executionEnabled, isFalse);
      expect(harness.chooser.chooseCount, 0);
      expect(harness.verifier.verifyCount, 0);
    });
  });
}

typedef _Stage = AttachmentArchiveAdoptionWorkflowStage;

const _sourcePath = '/tmp/source/attachment_archive';
const _candidatePath = '/tmp/copy/attachment_archive';

final class _Harness {
  _Harness({
    String? chooserPath = _candidatePath,
    bool executionEnabled = true,
    AttachmentArchiveAdoptionTransaction? pendingAdoption,
  }) : chooser = _FakeChooser(chooserPath),
       bookmarks = _FakeBookmarks(),
       verifier = _FakeVerifier(),
       pendingStore = _PendingStore(pendingAdoption) {
    executor = _FakeExecutor(onSuccessfulRetirement: pendingStore.clear);
    container = ProviderContainer(
      overrides: [
        attachmentArchiveAdoptionExecutionEnabledProvider.overrideWith(
          (ref) => executionEnabled,
        ),
        attachmentArchiveAdoptionFolderChooserProvider.overrideWithValue(
          chooser,
        ),
        attachmentArchiveAdoptionBookmarkAdapterProvider.overrideWithValue(
          bookmarks,
        ),
        attachmentArchiveAdoptionCandidateVerifierProvider.overrideWith(
          (ref) async => verifier,
        ),
        attachmentArchiveAdoptionExecutorProvider.overrideWith(
          (ref) async => executor,
        ),
        attachmentArchiveAdoptionSourceLocationProvider.overrideWith(
          (ref) async => AttachmentArchiveLocationState.defaultAvailable(
            archiveRootPath: _sourcePath,
            generation: 4,
          ),
        ),
        attachmentArchivePendingAdoptionTransactionProvider.overrideWith(
          (ref) async => pendingStore.current,
        ),
      ],
    );
  }

  final _FakeChooser chooser;
  final _FakeBookmarks bookmarks;
  final _FakeVerifier verifier;
  final _PendingStore pendingStore;
  late final _FakeExecutor executor;
  late final ProviderContainer container;

  AttachmentArchiveAdoptionWorkflow get notifier =>
      container.read(attachmentArchiveAdoptionWorkflowProvider.notifier);

  AttachmentArchiveAdoptionWorkflowState get state =>
      container.read(attachmentArchiveAdoptionWorkflowProvider);

  void dispose() => container.dispose();
}

final class _FakeChooser implements AttachmentArchiveLocationFolderChooser {
  _FakeChooser(this.selectedPath);

  final String? selectedPath;
  int chooseCount = 0;

  @override
  Future<String?> chooseArchiveDirectory() async {
    chooseCount++;
    return selectedPath;
  }
}

final class _FakeBookmarks implements AttachmentArchiveBookmarkAdapter {
  int createCount = 0;
  int resolveCount = 0;
  AttachmentArchiveBookmarkResolutionStatus status =
      AttachmentArchiveBookmarkResolutionStatus.available;

  @override
  Future<AttachmentArchiveBookmarkCreation> createBookmark({
    required String directoryPath,
  }) async {
    createCount++;
    return const AttachmentArchiveBookmarkCreation(
      bookmarkDataBase64: 'AQID',
      resolvedPath: _candidatePath,
      volumeName: 'Disposable',
    );
  }

  @override
  Future<AttachmentArchiveBookmarkResolution> resolveBookmark({
    required String bookmarkDataBase64,
  }) async {
    resolveCount++;
    return AttachmentArchiveBookmarkResolution(
      status: status,
      resolvedPath:
          status == AttachmentArchiveBookmarkResolutionStatus.available ||
              status == AttachmentArchiveBookmarkResolutionStatus.readOnly
          ? _candidatePath
          : null,
      volumeName: 'Disposable',
      issue: status == AttachmentArchiveBookmarkResolutionStatus.unavailable
          ? 'Candidate disconnected.'
          : null,
    );
  }

  @override
  Stream<AttachmentArchiveLocationEvent> get locationEvents =>
      const Stream.empty();
}

final class _FakeVerifier implements AttachmentArchiveCandidateVerifier {
  int verifyCount = 0;
  Completer<void>? blocker;
  AttachmentArchiveCandidateVerificationResult Function(
    AttachmentArchiveCandidateAccess access,
  )
  resultBuilder = _complete;

  @override
  Future<AttachmentArchiveCandidateVerificationResult> verify({
    required AttachmentArchiveLocationState sourceLocation,
    required AttachmentArchiveCandidateAccess candidate,
    AttachmentArchiveVerificationProgressCallback? onProgress,
    bool Function()? isCancelled,
  }) async {
    verifyCount++;
    onProgress?.call(
      const AttachmentArchiveVerificationProgress(
        phase: AttachmentArchiveVerificationPhase.sourceCoverage,
        filesChecked: 7,
        bytesChecked: 4096,
      ),
    );
    await blocker?.future;
    if (isCancelled?.call() ?? false) {
      throw const AttachmentArchiveCandidateVerificationCancelled();
    }
    return resultBuilder(candidate);
  }
}

final class _FakeExecutor implements AttachmentArchiveAdoptionExecutor {
  _FakeExecutor({required this.onSuccessfulRetirement});

  final void Function() onSuccessfulRetirement;
  int adoptCount = 0;
  int resumeCount = 0;
  AttachmentArchiveAdoptionResult result =
      const AttachmentArchiveAdoptionResult(
        outcome: AttachmentArchiveAdoptionOutcome.adopted,
      );
  Completer<AttachmentArchiveAdoptionResult>? blocker;
  AttachmentArchiveVerificationProgressCallback? _onFinalCoverageProgress;

  @override
  Future<AttachmentArchiveAdoptionResult> adopt(
    AttachmentArchiveCandidateVerificationResult verification, {
    AttachmentArchiveVerificationProgressCallback? onVerificationProgress,
    AttachmentArchiveRemediationProgressCallback? onRemediationProgress,
    AttachmentArchiveVerificationProgressCallback? onFinalCoverageProgress,
  }) async {
    adoptCount++;
    _onFinalCoverageProgress = onFinalCoverageProgress;
    final completed = blocker == null ? result : await blocker!.future;
    if (_isSuccessful(completed)) {
      onSuccessfulRetirement();
    }
    return completed;
  }

  @override
  Future<AttachmentArchiveAdoptionResult> resumePendingRemediation({
    AttachmentArchiveRemediationProgressCallback? onRemediationProgress,
    AttachmentArchiveVerificationProgressCallback? onFinalCoverageProgress,
  }) async {
    resumeCount++;
    _onFinalCoverageProgress = onFinalCoverageProgress;
    if (_isSuccessful(result)) {
      onSuccessfulRetirement();
    }
    return result;
  }

  static bool _isSuccessful(AttachmentArchiveAdoptionResult value) {
    return value.outcome == AttachmentArchiveAdoptionOutcome.adopted ||
        value.outcome == AttachmentArchiveAdoptionOutcome.remediationComplete;
  }

  void emitFinalCoverage(AttachmentArchiveVerificationProgress progress) {
    _onFinalCoverageProgress?.call(progress);
  }
}

final class _PendingStore {
  _PendingStore(this.current);

  AttachmentArchiveAdoptionTransaction? current;

  void clear() {
    current = null;
  }
}

AttachmentArchiveAdoptionTransaction _pendingTransaction() {
  final intended = AttachmentArchiveLocationConfiguration.customExternal(
    bookmarkDataBase64: 'AQID',
    lastKnownPath: _candidatePath,
    customWritePolicy: AttachmentArchiveCustomWritePolicy.activeArchive,
  );
  return AttachmentArchiveAdoptionTransaction(
    formatVersion: AttachmentArchiveAdoptionTransaction.currentFormatVersion,
    transactionId: '11111111-1111-4111-8111-111111111111',
    state: AttachmentArchiveAdoptionTransactionState.activeRemediationPending,
    kind: AttachmentArchiveAdoptionTransactionKind.verifiedBehind,
    previousConfiguration:
        const AttachmentArchiveLocationConfiguration.defaultInternal(),
    intendedConfiguration: intended,
    sourceCanonicalIdentity: _sourcePath,
    candidateCanonicalIdentity: _candidatePath,
    sourceLocationGeneration: 4,
    verificationContentDigest: 'a' * 64,
    sourceStructuralSnapshotFingerprint: 'b' * 64,
    candidateStructuralSnapshotFingerprint: 'c' * 64,
    verifiedFileCount: 4,
    verifiedBytes: 3461,
    remediationPayloads: const [
      AttachmentArchiveRemediationPayload(
        relativePath: '_by_id/100.bin',
        expectedSizeBytes: 3100,
        expectedSha256:
            'dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd',
      ),
    ],
    createdAtUtc: DateTime.utc(2026, 9, 20),
    updatedAtUtc: DateTime.utc(2026, 9, 20),
  );
}

AttachmentArchiveCandidateComplete _complete(
  AttachmentArchiveCandidateAccess access,
) {
  return AttachmentArchiveCandidateComplete(
    context: _context(access),
    evidence: _evidence(access: access),
  );
}

AttachmentArchiveCandidateBehind _behind(
  AttachmentArchiveCandidateAccess access, {
  int missingCount = 1,
  int missingBytes = 3100,
}) {
  return AttachmentArchiveCandidateBehind(
    context: _context(access),
    evidence: _evidence(
      access: access,
      requiredFileCount: 4 + missingCount,
      requiredBytes: 3461 + missingBytes,
      missingCount: missingCount,
      missingBytes: missingBytes,
    ),
  );
}

AttachmentArchiveCandidateInvalid _invalid(
  AttachmentArchiveCandidateAccess access,
) {
  return AttachmentArchiveCandidateInvalid(
    context: _context(access),
    issue: 'The candidate contains a symbolic link.',
  );
}

AttachmentArchiveVerificationSourceUnavailable _sourceUnavailable(
  AttachmentArchiveCandidateAccess access,
) {
  return AttachmentArchiveVerificationSourceUnavailable(
    context: _context(access),
    issue: 'The current archive is disconnected.',
  );
}

AttachmentArchiveCandidateVerificationContext _context(
  AttachmentArchiveCandidateAccess access,
) {
  return AttachmentArchiveCandidateVerificationContext(
    sourceLocationConfiguration:
        const AttachmentArchiveLocationConfiguration.defaultInternal(),
    sourceLocationGeneration: 4,
    requestedSourcePath: _sourcePath,
    requestedCandidatePath: access.directoryPath,
    verifiedAtUtc: DateTime.utc(2026, 9, 19),
    candidateWasPhysicallyWritable: access.isPhysicallyWritable,
    sourceCanonicalIdentity: _sourcePath,
    candidateCanonicalIdentity: _candidatePath,
  );
}

AttachmentArchiveCandidateVerificationEvidence _evidence({
  required AttachmentArchiveCandidateAccess access,
  int requiredFileCount = 4,
  int requiredBytes = 3461,
  int missingCount = 0,
  int missingBytes = 0,
}) {
  return AttachmentArchiveCandidateVerificationEvidence(
    sourceCanonicalIdentity: _sourcePath,
    candidateCanonicalIdentity: _candidatePath,
    sourceLocationConfiguration:
        const AttachmentArchiveLocationConfiguration.defaultInternal(),
    sourceLocationGeneration: 4,
    verifiedAtUtc: DateTime.utc(2026, 9, 19),
    candidateWasPhysicallyWritable: access.isPhysicallyWritable,
    requiredSourcePhysicalFileCount: requiredFileCount,
    requiredSourceBytes: requiredBytes,
    verifiedFileCount: requiredFileCount - missingCount,
    verifiedBytes: requiredBytes - missingBytes,
    metadataReferenceCount: requiredFileCount,
    unreferencedPreservationCount: 0,
    sourceOperationalDebrisCount: 0,
    candidateOperationalDebrisCount: 0,
    allowedCandidateExtraCount: 3,
    allowedCandidateExtraBytes: 300,
    missingCount: missingCount,
    missingBytes: missingBytes,
    missingPayloads: List<AttachmentArchiveVerifiedMissingPayload>.generate(
      missingCount,
      (index) => AttachmentArchiveVerifiedMissingPayload(
        relativePath: '_by_id/${index + 100}.bin',
        expectedSizeBytes: missingCount == 0 ? 0 : missingBytes ~/ missingCount,
        expectedSha256: 'd' * 64,
      ),
    ),
    contentCoverageDigest: 'a' * 64,
    sourceStructuralSnapshotFingerprint: 'b' * 64,
    candidateStructuralSnapshotFingerprint: 'c' * 64,
    diagnostics: const AttachmentArchiveVerificationDiagnostics(
      missingPathExamples: [],
      conflictingPathExamples: [],
      allowedExtraPathExamples: [],
      operationalDebrisPathExamples: [],
      sourceAnomalyPathExamples: [],
    ),
  );
}

Future<void> _flushAsync() async {
  for (var index = 0; index < 8; index++) {
    await Future<void>.delayed(Duration.zero);
  }
}
