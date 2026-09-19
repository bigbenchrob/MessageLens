import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/db/feature_level_providers.dart'
    show overlayDatabaseProvider;
import '../domain/entities/attachment_archive_adoption.dart';
import '../domain/entities/attachment_archive_candidate_verification.dart';
import '../domain/entities/attachment_archive_location_state.dart';
import '../infrastructure/repositories/filesystem_attachment_archive_candidate_verifier.dart';
import '../infrastructure/repositories/overlay_attachment_archive_verification_metadata_reader.dart';
import 'attachment_archive_adoption_enablement_provider.dart';
import 'attachment_archive_adoption_provider.dart';
import 'attachment_archive_adoption_workflow.dart';
import 'attachment_archive_bookmark_adapter.dart';
import 'attachment_archive_candidate_verifier.dart';
import 'attachment_archive_location_dependencies_provider.dart';
import 'attachment_archive_location_folder_chooser.dart';
import 'attachment_archive_location_provider.dart';

part 'attachment_archive_adoption_workflow_provider.g.dart';

@riverpod
AttachmentArchiveLocationFolderChooser attachmentArchiveAdoptionFolderChooser(
  Ref ref,
) {
  return ref.watch(attachmentArchiveLocationFolderChooserProvider);
}

@riverpod
AttachmentArchiveBookmarkAdapter attachmentArchiveAdoptionBookmarkAdapter(
  Ref ref,
) {
  return ref.watch(attachmentArchiveLocationNativeAdapterProvider);
}

@riverpod
Future<AttachmentArchiveCandidateVerifier>
attachmentArchiveAdoptionCandidateVerifier(Ref ref) async {
  final overlayDatabase = await ref.watch(overlayDatabaseProvider.future);
  return FilesystemAttachmentArchiveCandidateVerifier(
    metadataReader: OverlayAttachmentArchiveVerificationMetadataReader(
      overlayDatabase: overlayDatabase,
    ),
  );
}

@riverpod
Future<AttachmentArchiveAdoptionExecutor> attachmentArchiveAdoptionExecutor(
  Ref ref,
) async {
  return ref.watch(attachmentArchiveAdoptionServiceProvider.future);
}

@riverpod
Future<AttachmentArchiveLocationState> attachmentArchiveAdoptionSourceLocation(
  Ref ref,
) {
  return ref.watch(attachmentArchiveLocationProvider.future);
}

/// Ephemeral Settings workflow for checking and adopting an existing copy.
///
/// The complete result stays private in this notifier. Reconstructing this
/// provider discards it, so stale ready evidence can never become UI authority.
@Riverpod(keepAlive: true)
class AttachmentArchiveAdoptionWorkflow
    extends _$AttachmentArchiveAdoptionWorkflow {
  int _operationToken = 0;
  String? _selectedDirectoryPath;
  String? _selectedVolumeName;
  AttachmentArchiveCandidateComplete? _readyVerification;

  @override
  AttachmentArchiveAdoptionWorkflowState build() {
    ref.onDispose(() {
      _operationToken++;
      _readyVerification = null;
    });
    return AttachmentArchiveAdoptionWorkflowState.currentArchive(
      executionEnabled: ref.watch(
        attachmentArchiveAdoptionExecutionEnabledProvider,
      ),
    );
  }

  Future<void> chooseExistingArchive() async {
    if (!_executionIsEnabled()) {
      return;
    }
    final previousState = state;
    final token = ++_operationToken;
    final chooser = ref.read(attachmentArchiveAdoptionFolderChooserProvider);
    final String? selectedPath;
    try {
      selectedPath = await chooser.chooseArchiveDirectory();
    } on Object catch (error) {
      if (_isCurrent(token)) {
        state = AttachmentArchiveAdoptionWorkflowState(
          stage: AttachmentArchiveAdoptionWorkflowStage.candidateUnavailable,
          executionEnabled: true,
          issue: 'The archive-copy chooser could not be opened: $error',
        );
      }
      return;
    }
    if (!_isCurrent(token) || selectedPath == null) {
      if (_isCurrent(token)) {
        state = previousState;
      }
      return;
    }
    _selectedDirectoryPath = selectedPath;
    _selectedVolumeName = null;
    _readyVerification = null;
    await _checkSelectedCandidate(token: token);
  }

  Future<void> chooseAnotherFolder() => chooseExistingArchive();

  Future<void> checkAgain() async {
    if (!_executionIsEnabled()) {
      return;
    }
    final selectedPath = _selectedDirectoryPath;
    if (selectedPath == null) {
      await chooseExistingArchive();
      return;
    }
    final token = ++_operationToken;
    _readyVerification = null;
    await _checkSelectedCandidate(token: token);
  }

  Future<void> cancelCheck() async {
    _operationToken++;
    _selectedDirectoryPath = null;
    _selectedVolumeName = null;
    _readyVerification = null;
    state = AttachmentArchiveAdoptionWorkflowState.currentArchive(
      executionEnabled: _executionIsEnabled(),
    );
  }

  Future<void> useCandidate() async {
    if (!_executionIsEnabled() || !state.canUseCandidate) {
      return;
    }
    final verification = _readyVerification;
    if (verification == null) {
      state = _adoptionState(
        stage:
            AttachmentArchiveAdoptionWorkflowStage.verificationEvidenceInvalid,
        issue: 'The archive must be checked again before it can be used.',
      );
      return;
    }

    final token = ++_operationToken;
    state = _adoptionState(
      stage: AttachmentArchiveAdoptionWorkflowStage.switching,
    );
    try {
      final executor = await ref.read(
        attachmentArchiveAdoptionExecutorProvider.future,
      );
      if (!_isCurrent(token)) {
        return;
      }
      final result = await executor.adopt(verification);
      if (!_isCurrent(token)) {
        return;
      }
      _readyVerification = null;
      state = _stateForAdoptionResult(result);
    } on Object catch (error) {
      if (_isCurrent(token)) {
        _readyVerification = null;
        state = _adoptionState(
          stage: AttachmentArchiveAdoptionWorkflowStage.failed,
          issue: 'Archive adoption could not complete: $error',
        );
      }
    }
  }

  Future<void> _checkSelectedCandidate({required int token}) async {
    final selectedPath = _selectedDirectoryPath;
    if (selectedPath == null || !_isCurrent(token)) {
      return;
    }

    state = AttachmentArchiveAdoptionWorkflowState(
      stage: AttachmentArchiveAdoptionWorkflowStage.checking,
      executionEnabled: true,
      candidatePath: selectedPath,
    );

    final resolution = await _resolveCandidate(selectedPath);
    if (!_isCurrent(token)) {
      return;
    }
    final candidateAccess = resolution.access;
    if (candidateAccess == null) {
      state = AttachmentArchiveAdoptionWorkflowState(
        stage: AttachmentArchiveAdoptionWorkflowStage.candidateUnavailable,
        executionEnabled: true,
        candidatePath: selectedPath,
        issue: resolution.issue,
      );
      return;
    }
    _selectedVolumeName = resolution.volumeName;

    try {
      final sourceLocation = await ref.read(
        attachmentArchiveAdoptionSourceLocationProvider.future,
      );
      if (!_isCurrent(token)) {
        return;
      }
      state = AttachmentArchiveAdoptionWorkflowState(
        stage: AttachmentArchiveAdoptionWorkflowStage.checking,
        executionEnabled: true,
        sourcePath:
            sourceLocation.archiveRootPath ??
            sourceLocation.lastKnownDisplayPath,
        candidatePath: candidateAccess.directoryPath,
        candidateVolumeName: resolution.volumeName,
      );

      final verifier = await ref.read(
        attachmentArchiveAdoptionCandidateVerifierProvider.future,
      );
      if (!_isCurrent(token)) {
        return;
      }
      final result = await verifier.verify(
        sourceLocation: sourceLocation,
        candidate: candidateAccess,
        onProgress: (progress) {
          if (!_isCurrent(token)) {
            return;
          }
          state = AttachmentArchiveAdoptionWorkflowState(
            stage: AttachmentArchiveAdoptionWorkflowStage.checking,
            executionEnabled: true,
            sourcePath:
                sourceLocation.archiveRootPath ??
                sourceLocation.lastKnownDisplayPath,
            candidatePath: candidateAccess.directoryPath,
            candidateVolumeName: resolution.volumeName,
            progress: progress,
          );
        },
        isCancelled: () => !_isCurrent(token),
      );
      if (!_isCurrent(token)) {
        return;
      }
      _readyVerification = result is AttachmentArchiveCandidateComplete
          ? result
          : null;
      state = _stateForVerification(result);
    } on AttachmentArchiveCandidateVerificationCancelled {
      if (_isCurrent(token)) {
        await cancelCheck();
      }
    } on Object catch (error) {
      if (_isCurrent(token)) {
        state = AttachmentArchiveAdoptionWorkflowState(
          stage: AttachmentArchiveAdoptionWorkflowStage.verificationFailed,
          executionEnabled: true,
          candidatePath: candidateAccess.directoryPath,
          candidateVolumeName: resolution.volumeName,
          issue: 'Archive verification could not complete: $error',
        );
      }
    }
  }

  Future<_CandidateResolution> _resolveCandidate(String selectedPath) async {
    try {
      final bookmarks = ref.read(
        attachmentArchiveAdoptionBookmarkAdapterProvider,
      );
      final created = await bookmarks.createBookmark(
        directoryPath: selectedPath,
      );
      final resolved = await bookmarks.resolveBookmark(
        bookmarkDataBase64: created.bookmarkDataBase64,
      );
      final resolvedPath = resolved.resolvedPath;
      switch (resolved.status) {
        case AttachmentArchiveBookmarkResolutionStatus.available:
          if (resolvedPath == null || resolvedPath.isEmpty) {
            return const _CandidateResolution.unavailable(
              'The selected archive copy did not resolve to a directory.',
            );
          }
          return _CandidateResolution.available(
            access: AttachmentArchiveCandidateAccess(
              directoryPath: resolvedPath,
              isPhysicallyWritable: true,
            ),
            volumeName: resolved.volumeName ?? created.volumeName,
          );
        case AttachmentArchiveBookmarkResolutionStatus.readOnly:
          if (resolvedPath == null || resolvedPath.isEmpty) {
            return const _CandidateResolution.unavailable(
              'The selected archive copy did not resolve to a directory.',
            );
          }
          return _CandidateResolution.available(
            access: AttachmentArchiveCandidateAccess(
              directoryPath: resolvedPath,
              isPhysicallyWritable: false,
            ),
            volumeName: resolved.volumeName ?? created.volumeName,
          );
        case AttachmentArchiveBookmarkResolutionStatus.unavailable ||
            AttachmentArchiveBookmarkResolutionStatus.permissionDenied ||
            AttachmentArchiveBookmarkResolutionStatus
                .configuredDirectoryMissing ||
            AttachmentArchiveBookmarkResolutionStatus.invalidBookmark:
          return _CandidateResolution.unavailable(
            resolved.issue ?? 'The selected archive copy is unavailable.',
          );
      }
    } on Object catch (error) {
      return _CandidateResolution.unavailable(
        'The selected archive copy is unavailable: $error',
      );
    }
  }

  AttachmentArchiveAdoptionWorkflowState _stateForVerification(
    AttachmentArchiveCandidateVerificationResult result,
  ) {
    final evidence = result.evidence;
    final sourcePath =
        evidence?.sourceCanonicalIdentity ??
        result.context.sourceCanonicalIdentity ??
        result.context.requestedSourcePath;
    final candidatePath =
        evidence?.candidateCanonicalIdentity ??
        result.context.candidateCanonicalIdentity ??
        result.context.requestedCandidatePath;
    final stage = switch (result.outcome) {
      AttachmentArchiveCandidateVerificationOutcome.candidateComplete =>
        AttachmentArchiveAdoptionWorkflowStage.candidateComplete,
      AttachmentArchiveCandidateVerificationOutcome.candidateBehind =>
        AttachmentArchiveAdoptionWorkflowStage.candidateBehind,
      AttachmentArchiveCandidateVerificationOutcome.candidateInvalid =>
        AttachmentArchiveAdoptionWorkflowStage.candidateInvalid,
      AttachmentArchiveCandidateVerificationOutcome.sourceUnavailable =>
        AttachmentArchiveAdoptionWorkflowStage.sourceUnavailable,
      AttachmentArchiveCandidateVerificationOutcome.candidateUnavailable =>
        AttachmentArchiveAdoptionWorkflowStage.candidateUnavailable,
      AttachmentArchiveCandidateVerificationOutcome.verificationFailed =>
        AttachmentArchiveAdoptionWorkflowStage.verificationFailed,
    };
    return AttachmentArchiveAdoptionWorkflowState(
      stage: stage,
      executionEnabled: true,
      sourcePath: sourcePath,
      candidatePath: candidatePath,
      candidateVolumeName: _selectedVolumeName,
      candidateIsAdoptable:
          stage == AttachmentArchiveAdoptionWorkflowStage.candidateComplete &&
          (evidence?.candidateWasPhysicallyWritable ?? false),
      requiredFileCount: evidence?.requiredSourcePhysicalFileCount,
      requiredBytes: evidence?.requiredSourceBytes,
      verifiedFileCount: evidence?.verifiedFileCount,
      verifiedBytes: evidence?.verifiedBytes,
      allowedExtraCount: evidence?.allowedCandidateExtraCount,
      allowedExtraBytes: evidence?.allowedCandidateExtraBytes,
      missingCount: evidence?.missingCount,
      missingBytes: evidence?.missingBytes,
      issue: result.issue,
    );
  }

  AttachmentArchiveAdoptionWorkflowState _stateForAdoptionResult(
    AttachmentArchiveAdoptionResult result,
  ) {
    final stage = switch (result.outcome) {
      AttachmentArchiveAdoptionOutcome.adopted =>
        AttachmentArchiveAdoptionWorkflowStage.success,
      AttachmentArchiveAdoptionOutcome.sourceChangedCheckAgain ||
      AttachmentArchiveAdoptionOutcome.candidateChangedCheckAgain =>
        AttachmentArchiveAdoptionWorkflowStage.archiveChanged,
      AttachmentArchiveAdoptionOutcome.sourceUnavailable =>
        AttachmentArchiveAdoptionWorkflowStage.sourceUnavailable,
      AttachmentArchiveAdoptionOutcome.candidateUnavailable =>
        AttachmentArchiveAdoptionWorkflowStage.candidateUnavailable,
      AttachmentArchiveAdoptionOutcome.candidateNoLongerWritable =>
        AttachmentArchiveAdoptionWorkflowStage.candidateNoLongerWritable,
      AttachmentArchiveAdoptionOutcome.verificationEvidenceInvalid =>
        AttachmentArchiveAdoptionWorkflowStage.verificationEvidenceInvalid,
      AttachmentArchiveAdoptionOutcome.rollbackRestoredPrevious =>
        AttachmentArchiveAdoptionWorkflowStage.rollbackRestoredPrevious,
      AttachmentArchiveAdoptionOutcome.rollbackPendingPreviousUnavailable =>
        AttachmentArchiveAdoptionWorkflowStage
            .rollbackPendingPreviousUnavailable,
      AttachmentArchiveAdoptionOutcome.configurationConflict =>
        AttachmentArchiveAdoptionWorkflowStage.configurationConflict,
      AttachmentArchiveAdoptionOutcome.noPendingRecovery ||
      AttachmentArchiveAdoptionOutcome.preparedTransactionAbandoned ||
      AttachmentArchiveAdoptionOutcome.failed =>
        AttachmentArchiveAdoptionWorkflowStage.failed,
    };
    return _adoptionState(stage: stage, issue: result.issue);
  }

  AttachmentArchiveAdoptionWorkflowState _adoptionState({
    required AttachmentArchiveAdoptionWorkflowStage stage,
    String? issue,
  }) {
    return AttachmentArchiveAdoptionWorkflowState(
      stage: stage,
      executionEnabled: _executionIsEnabled(),
      sourcePath: state.sourcePath,
      candidatePath: state.candidatePath,
      candidateVolumeName: state.candidateVolumeName,
      issue: issue,
    );
  }

  bool _executionIsEnabled() {
    return ref.read(attachmentArchiveAdoptionExecutionEnabledProvider);
  }

  bool _isCurrent(int token) => token == _operationToken;
}

final class _CandidateResolution {
  const _CandidateResolution.available({
    required AttachmentArchiveCandidateAccess this.access,
    required this.volumeName,
  }) : issue = null;

  const _CandidateResolution.unavailable(String this.issue)
    : access = null,
      volumeName = null;

  final AttachmentArchiveCandidateAccess? access;
  final String? volumeName;
  final String? issue;
}
