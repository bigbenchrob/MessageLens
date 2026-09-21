import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/domain/sidebar_action_intent.dart';
import '../../../../attachments/feature_level_providers.dart'
    show
        AttachmentArchiveAdoptionOutcome,
        AttachmentArchiveAdoptionResult,
        AttachmentArchiveAdoptionWorkflowStage,
        AttachmentArchiveAdoptionWorkflowState,
        AttachmentArchiveLocationAvailability,
        AttachmentArchiveLocationState,
        AttachmentArchiveVerificationPhase,
        AttachmentArchiveVerificationProgress;
import '../payloads/attachment_archive_settings_cassette_payload.dart';

part 'attachment_archive_settings_resolver.g.dart';

@riverpod
class AttachmentArchiveSettingsResolver
    extends _$AttachmentArchiveSettingsResolver {
  static const _checkingExplanation =
      'MessageLens is automatically checking the current archive and the '
      'selected copy. Neither archive is being changed.';
  static const _currentUnavailableExplanation =
      'MessageLens cannot check the selected copy until the current archive '
      'is available.';
  static const _archiveChangedExplanation =
      'MessageLens did not switch archives. Check the copy again before '
      'using it.';
  static const _readOnlyCopyExplanation =
      'MessageLens can read this archive copy, but cannot use it as the active '
      'archive because it is not writable.';
  static const _rollbackRestoredExplanation =
      'MessageLens restored the previous archive location. Both archive '
      'folders remain untouched.';
  static const _recoveryPendingExplanation =
      'MessageLens has not reported success and has not fallen back to another '
      'archive.';
  static const _configurationConflictExplanation =
      'MessageLens did not guess which archive should be authoritative. Both '
      'archive folders remain untouched.';
  static const _copySelectionExplanation =
      'If you’ve copied your attachment_archive folder somewhere else, '
      'MessageLens can check the copy before switching to it. Select the '
      'copied attachment_archive folder itself. MessageLens will not copy or '
      'move it.';

  @override
  void build() {}

  AttachmentArchiveSettingsCassettePayload resolve({
    required int cassetteIndex,
    required AttachmentArchiveLocationState location,
    required AttachmentArchiveAdoptionWorkflowState workflow,
    AttachmentArchiveAdoptionResult? recovery,
  }) {
    final stableBodyText = _stableContextText(
      location: location,
      workflow: workflow,
    );
    if (workflow.stage ==
        AttachmentArchiveAdoptionWorkflowStage.currentArchive) {
      final recoveryPayload = _resolveRecovery(
        cassetteIndex: cassetteIndex,
        location: location,
        recovery: recovery,
        stableBodyText: stableBodyText,
      );
      if (recoveryPayload != null) {
        return recoveryPayload;
      }
    }

    return switch (workflow.stage) {
      AttachmentArchiveAdoptionWorkflowStage.currentArchive => _resolveCurrent(
        cassetteIndex: cassetteIndex,
        location: location,
        workflow: workflow,
        stableBodyText: stableBodyText,
      ),
      AttachmentArchiveAdoptionWorkflowStage.checking => _payload(
        cassetteIndex: cassetteIndex,
        workflowView: AttachmentArchiveSettingsWorkflowView.checking,
        stableBodyText: stableBodyText,
        workflowTitle: 'Checking archive copy…',
        workflowBodyText: [
          _checkingExplanation,
          if (workflow.progress case final progress?) _progressLabel(progress),
        ].join('\n\n'),
        statusLines: [..._copyLines(workflow)],
        actions: const [
          SidebarActionDescriptor(
            label: 'Cancel',
            intent: AttachmentArchiveCancelCheckRequested(),
          ),
        ],
      ),
      AttachmentArchiveAdoptionWorkflowStage.candidateComplete =>
        _resolveComplete(
          cassetteIndex: cassetteIndex,
          workflow: workflow,
          stableBodyText: stableBodyText,
        ),
      AttachmentArchiveAdoptionWorkflowStage.candidateBehind => _resolveBehind(
        cassetteIndex: cassetteIndex,
        workflow: workflow,
        stableBodyText: stableBodyText,
      ),
      AttachmentArchiveAdoptionWorkflowStage.candidateInvalid => _payload(
        cassetteIndex: cassetteIndex,
        workflowView: AttachmentArchiveSettingsWorkflowView.candidateInvalid,
        stableBodyText: stableBodyText,
        workflowTitle: 'This copy couldn’t be verified',
        workflowBodyText: [
          'MessageLens checked the archive copy you selected but found:',
          _userFacingIssue(
            workflow.issue,
            fallback: 'The selected folder is not a valid archive copy.',
          ),
          _unchangedMessage(workflow),
        ].join('\n\n'),
        statusLines: _copyLines(workflow),
        actions: const [
          SidebarActionDescriptor(
            label: 'Choose a Different Copy',
            intent: AttachmentArchiveChooseAnotherFolderRequested(),
          ),
        ],
      ),
      AttachmentArchiveAdoptionWorkflowStage.sourceUnavailable => _payload(
        cassetteIndex: cassetteIndex,
        workflowView: AttachmentArchiveSettingsWorkflowView.sourceUnavailable,
        stableBodyText: stableBodyText,
        workflowTitle: 'Current archive unavailable',
        workflowBodyText: [
          _currentUnavailableExplanation,
          if (workflow.issue case final issue?) _userFacingIssue(issue),
          _unchangedMessage(workflow),
        ].join('\n\n'),
        statusLines: _copyLines(workflow),
        actions: const [
          SidebarActionDescriptor(
            label: 'Try Again',
            intent: AttachmentArchiveCheckAgainRequested(),
            tone: SidebarActionTone.primary,
          ),
        ],
      ),
      AttachmentArchiveAdoptionWorkflowStage.candidateUnavailable => _payload(
        cassetteIndex: cassetteIndex,
        workflowView:
            AttachmentArchiveSettingsWorkflowView.candidateUnavailable,
        stableBodyText: stableBodyText,
        workflowTitle: 'Selected copy unavailable',
        workflowBodyText: [
          'MessageLens could not read the archive copy you selected.',
          if (workflow.issue case final issue?) _userFacingIssue(issue),
          _unchangedMessage(workflow),
        ].join('\n\n'),
        statusLines: _copyLines(workflow, connection: 'Unavailable'),
        actions: const [
          SidebarActionDescriptor(
            label: 'Choose a Different Copy',
            intent: AttachmentArchiveChooseAnotherFolderRequested(),
          ),
          SidebarActionDescriptor(
            label: 'Try Again',
            intent: AttachmentArchiveCheckAgainRequested(),
            tone: SidebarActionTone.primary,
          ),
        ],
      ),
      AttachmentArchiveAdoptionWorkflowStage.verificationFailed ||
      AttachmentArchiveAdoptionWorkflowStage
          .verificationEvidenceInvalid => _payload(
        cassetteIndex: cassetteIndex,
        workflowView: AttachmentArchiveSettingsWorkflowView.verificationFailed,
        stableBodyText: stableBodyText,
        workflowTitle: 'This copy couldn’t be verified',
        workflowBodyText: [
          'MessageLens checked the archive copy you selected but found:',
          _userFacingIssue(
            workflow.issue,
            fallback: 'The verification evidence is no longer valid.',
          ),
          _unchangedMessage(workflow),
        ].join('\n\n'),
        statusLines: _copyLines(workflow),
        actions: const [
          SidebarActionDescriptor(
            label: 'Choose a Different Copy',
            intent: AttachmentArchiveChooseAnotherFolderRequested(),
          ),
          SidebarActionDescriptor(
            label: 'Try Again',
            intent: AttachmentArchiveCheckAgainRequested(),
            tone: SidebarActionTone.primary,
          ),
        ],
      ),
      AttachmentArchiveAdoptionWorkflowStage.archiveChanged => _payload(
        cassetteIndex: cassetteIndex,
        workflowView: AttachmentArchiveSettingsWorkflowView.archiveChanged,
        stableBodyText: stableBodyText,
        workflowTitle: 'The archive changed since it was checked',
        workflowBodyText: [
          _archiveChangedExplanation,
          if (workflow.issue case final issue?) _userFacingIssue(issue),
          _unchangedMessage(workflow),
        ].join('\n\n'),
        statusLines: _copyLines(workflow),
        actions: const [
          SidebarActionDescriptor(
            label: 'Check Again',
            intent: AttachmentArchiveCheckAgainRequested(),
            tone: SidebarActionTone.primary,
          ),
        ],
      ),
      AttachmentArchiveAdoptionWorkflowStage.candidateNoLongerWritable =>
        _payload(
          cassetteIndex: cassetteIndex,
          workflowView:
              AttachmentArchiveSettingsWorkflowView.candidateNoLongerWritable,
          stableBodyText: stableBodyText,
          workflowTitle: 'This copy can’t be used',
          workflowBodyText: [
            _readOnlyCopyExplanation,
            if (workflow.issue case final issue?) _userFacingIssue(issue),
            _unchangedMessage(workflow),
          ].join('\n\n'),
          statusLines: _copyLines(workflow, connection: 'Read-only'),
          actions: const [
            SidebarActionDescriptor(
              label: 'Choose a Different Copy',
              intent: AttachmentArchiveChooseAnotherFolderRequested(),
            ),
          ],
        ),
      AttachmentArchiveAdoptionWorkflowStage.switching => _payload(
        cassetteIndex: cassetteIndex,
        workflowView: AttachmentArchiveSettingsWorkflowView.switching,
        stableBodyText: stableBodyText,
        workflowTitle: 'Switching to archive copy…',
        workflowBodyText:
            'MessageLens is validating the new active location. No attachment '
            'payloads are being copied, moved, or deleted.',
        statusLines: _copyLines(workflow),
      ),
      AttachmentArchiveAdoptionWorkflowStage.remediating => _payload(
        cassetteIndex: cassetteIndex,
        workflowView: AttachmentArchiveSettingsWorkflowView.switching,
        stableBodyText: stableBodyText,
        workflowTitle: 'Adding missing attachments…',
        workflowBodyText:
            'The new archive is active while its finite '
            'historical payload set is installed.',
        statusLines: _copyLines(workflow),
      ),
      AttachmentArchiveAdoptionWorkflowStage.remediationPending => _payload(
        cassetteIndex: cassetteIndex,
        workflowView: AttachmentArchiveSettingsWorkflowView.failed,
        stableBodyText: stableBodyText,
        workflowTitle: 'Historical attachments still need to be added',
        workflowBodyText:
            workflow.issue ??
            'The new archive remains active. Resume from Settings.',
        statusLines: _copyLines(workflow),
      ),
      AttachmentArchiveAdoptionWorkflowStage.success => _payload(
        cassetteIndex: cassetteIndex,
        workflowView: AttachmentArchiveSettingsWorkflowView.success,
        stableBodyText: stableBodyText,
        workflowTitle: 'Attachment archive switched',
        workflowBodyText:
            'MessageLens is now using:\n'
            '${workflow.candidatePath ?? location.archiveRootPath ?? ''}\n\n'
            '${workflow.candidateVolumeName ?? _volumeNameForPath(workflow.candidatePath) ?? 'Archive volume'} · Connected\n\n'
            'Your original archive is still at:\n'
            '${workflow.sourcePath ?? ''}\n\n'
            'Keep the original for a few days while you make sure everything '
            'is working normally.\n\nMessageLens has not deleted it.',
      ),
      AttachmentArchiveAdoptionWorkflowStage.rollbackRestoredPrevious =>
        _rollbackRestoredPayload(
          cassetteIndex: cassetteIndex,
          workflow: workflow,
          stableBodyText: stableBodyText,
        ),
      AttachmentArchiveAdoptionWorkflowStage
          .rollbackPendingPreviousUnavailable =>
        _recoveryPendingPayload(
          cassetteIndex: cassetteIndex,
          issue: workflow.issue,
          stableBodyText: stableBodyText,
        ),
      AttachmentArchiveAdoptionWorkflowStage.configurationConflict =>
        _configurationConflictPayload(
          cassetteIndex: cassetteIndex,
          issue: workflow.issue,
          stableBodyText: stableBodyText,
        ),
      AttachmentArchiveAdoptionWorkflowStage.failed => _payload(
        cassetteIndex: cassetteIndex,
        workflowView: AttachmentArchiveSettingsWorkflowView.failed,
        stableBodyText: stableBodyText,
        workflowTitle: 'Archive location was not changed',
        workflowBodyText: [
          'MessageLens could not complete the archive-location switch.',
          if (workflow.issue case final issue?) _userFacingIssue(issue),
          _unchangedMessage(workflow),
        ].join('\n\n'),
        statusLines: _copyLines(workflow),
      ),
    };
  }

  AttachmentArchiveSettingsCassettePayload _resolveCurrent({
    required int cassetteIndex,
    required AttachmentArchiveLocationState location,
    required AttachmentArchiveAdoptionWorkflowState workflow,
    required String stableBodyText,
  }) {
    final canStart = workflow.executionEnabled && location.isAvailable;
    return AttachmentArchiveSettingsCassettePayload(
      cassetteIndex: cassetteIndex,
      bodyText: stableBodyText,
      actions: workflow.executionEnabled
          ? [
              SidebarActionDescriptor(
                label: 'Choose Archive Copy…',
                intent: const AttachmentArchiveUseExistingRequested(),
                tone: SidebarActionTone.primary,
                isEnabled: canStart,
              ),
            ]
          : const [],
    );
  }

  AttachmentArchiveSettingsCassettePayload _resolveComplete({
    required int cassetteIndex,
    required AttachmentArchiveAdoptionWorkflowState workflow,
    required String stableBodyText,
  }) {
    final verifiedFileCount = workflow.verifiedFileCount ?? 0;
    final verifiedBytes = workflow.verifiedBytes ?? 0;
    final extras = workflow.allowedExtraCount ?? 0;
    const coverageExplanation =
        'Everything currently stored in the active attachment archive is '
        'present in this copy.';
    final extrasExplanation =
        'The selected copy also contains $extras additional preserved '
        '${_plural(extras, 'attachment')}.';
    final verifiedSummary =
        '$verifiedFileCount ${_plural(verifiedFileCount, 'file')} · '
        '${_formatBytes(verifiedBytes)} verified';
    return _payload(
      cassetteIndex: cassetteIndex,
      workflowView: AttachmentArchiveSettingsWorkflowView.candidateComplete,
      stableBodyText: stableBodyText,
      workflowTitle: workflow.candidateIsAdoptable
          ? 'Archive copy verified'
          : 'This copy can’t be used',
      workflowBodyText: [
        verifiedSummary,
        coverageExplanation,
        if (extras > 0) extrasExplanation,
        if (!workflow.candidateIsAdoptable) _readOnlyCopyExplanation,
        _unchangedMessage(workflow),
      ].join('\n\n'),
      statusLines: _copyLines(
        workflow,
        connection: workflow.candidateIsAdoptable ? 'Connected' : 'Read-only',
      ),
      actions: workflow.candidateIsAdoptable
          ? const [
              SidebarActionDescriptor(
                label: 'Cancel',
                intent: AttachmentArchiveCancelCheckRequested(),
              ),
              SidebarActionDescriptor(
                label: 'Use This Copy',
                intent: AttachmentArchiveUseCandidateRequested(),
                tone: SidebarActionTone.primary,
              ),
            ]
          : const [
              SidebarActionDescriptor(
                label: 'Choose a Different Copy',
                intent: AttachmentArchiveChooseAnotherFolderRequested(),
              ),
            ],
    );
  }

  AttachmentArchiveSettingsCassettePayload _resolveBehind({
    required int cassetteIndex,
    required AttachmentArchiveAdoptionWorkflowState workflow,
    required String stableBodyText,
  }) {
    final missingCount = workflow.missingCount ?? 0;
    final missingBytes = workflow.missingBytes ?? 0;
    return _payload(
      cassetteIndex: cassetteIndex,
      workflowView: AttachmentArchiveSettingsWorkflowView.candidateBehind,
      stableBodyText: stableBodyText,
      workflowTitle: 'This copy is not up to date',
      workflowBodyText:
          'MessageLens checked the copy and found:\n\n'
          '$missingCount ${_plural(missingCount, 'attachment')} '
          '(${_formatBytes(missingBytes)}) in the current archive that '
          '${missingCount == 1 ? 'is' : 'are'} not in the copy.\n\n'
          '${_unchangedMessage(workflow)}\n\n'
          'Update the copied folder, then check it again.',
      statusLines: _copyLines(workflow),
      actions: const [
        SidebarActionDescriptor(
          label: 'Check Again',
          intent: AttachmentArchiveCheckAgainRequested(),
          tone: SidebarActionTone.primary,
        ),
      ],
    );
  }

  AttachmentArchiveSettingsCassettePayload? _resolveRecovery({
    required int cassetteIndex,
    required AttachmentArchiveLocationState location,
    required AttachmentArchiveAdoptionResult? recovery,
    required String stableBodyText,
  }) {
    if (recovery == null || recovery.transactionId == null) {
      return null;
    }
    return switch (recovery.outcome) {
      AttachmentArchiveAdoptionOutcome.rollbackRestoredPrevious =>
        _rollbackRestoredPayload(
          cassetteIndex: cassetteIndex,
          workflow: AttachmentArchiveAdoptionWorkflowState(
            stage:
                AttachmentArchiveAdoptionWorkflowStage.rollbackRestoredPrevious,
            executionEnabled: false,
            sourcePath:
                location.archiveRootPath ?? location.lastKnownDisplayPath,
            issue: recovery.issue,
          ),
          stableBodyText: stableBodyText,
        ),
      AttachmentArchiveAdoptionOutcome.rollbackPendingPreviousUnavailable ||
      AttachmentArchiveAdoptionOutcome.failed => _recoveryPendingPayload(
        cassetteIndex: cassetteIndex,
        issue: recovery.issue,
        stableBodyText: stableBodyText,
      ),
      AttachmentArchiveAdoptionOutcome.configurationConflict =>
        _configurationConflictPayload(
          cassetteIndex: cassetteIndex,
          issue: recovery.issue,
          stableBodyText: stableBodyText,
        ),
      _ => null,
    };
  }

  AttachmentArchiveSettingsCassettePayload _rollbackRestoredPayload({
    required int cassetteIndex,
    required AttachmentArchiveAdoptionWorkflowState workflow,
    required String stableBodyText,
  }) {
    return _payload(
      cassetteIndex: cassetteIndex,
      workflowView:
          AttachmentArchiveSettingsWorkflowView.rollbackRestoredPrevious,
      stableBodyText: stableBodyText,
      workflowTitle: 'Archive location was not changed',
      workflowBodyText: [
        _rollbackRestoredExplanation,
        if (workflow.issue case final issue?) _userFacingIssue(issue),
      ].join('\n\n'),
      statusLines: _copyLines(workflow),
    );
  }

  AttachmentArchiveSettingsCassettePayload _recoveryPendingPayload({
    required int cassetteIndex,
    required String? issue,
    required String stableBodyText,
  }) {
    return _payload(
      cassetteIndex: cassetteIndex,
      workflowView: AttachmentArchiveSettingsWorkflowView
          .rollbackPendingPreviousUnavailable,
      stableBodyText: stableBodyText,
      workflowTitle:
          'Archive location recovery is waiting for the previous archive',
      workflowBodyText: [
        _recoveryPendingExplanation,
        if (issue != null) _userFacingIssue(issue),
      ].join('\n\n'),
    );
  }

  AttachmentArchiveSettingsCassettePayload _configurationConflictPayload({
    required int cassetteIndex,
    required String? issue,
    required String stableBodyText,
  }) {
    return _payload(
      cassetteIndex: cassetteIndex,
      workflowView: AttachmentArchiveSettingsWorkflowView.configurationConflict,
      stableBodyText: stableBodyText,
      workflowTitle: 'Archive location changed unexpectedly',
      workflowBodyText: [
        _configurationConflictExplanation,
        if (issue != null) _userFacingIssue(issue),
      ].join('\n\n'),
    );
  }

  AttachmentArchiveSettingsCassettePayload _payload({
    required int cassetteIndex,
    required AttachmentArchiveSettingsWorkflowView workflowView,
    required String stableBodyText,
    required String workflowTitle,
    String? workflowBodyText,
    List<AttachmentArchiveSettingsStatusLine> statusLines = const [],
    List<SidebarActionDescriptor> actions = const [],
  }) {
    return AttachmentArchiveSettingsCassettePayload(
      cassetteIndex: cassetteIndex,
      workflowView: workflowView,
      bodyText: stableBodyText,
      workflowTitle: workflowTitle,
      workflowBodyText: workflowBodyText,
      statusLines: statusLines,
      actions: actions,
    );
  }

  List<AttachmentArchiveSettingsStatusLine> _copyLines(
    AttachmentArchiveAdoptionWorkflowState workflow, {
    String connection = 'Connected',
  }) {
    return [
      if (workflow.candidatePath case final candidatePath?)
        AttachmentArchiveSettingsStatusLine(
          label: 'Selected copy',
          value: candidatePath,
        ),
      if (workflow.candidatePath != null ||
          workflow.candidateVolumeName != null)
        AttachmentArchiveSettingsStatusLine(
          label: 'Status',
          value:
              '${workflow.candidateVolumeName ?? _volumeNameForPath(workflow.candidatePath) ?? 'Archive volume'} · $connection',
        ),
    ];
  }

  String _stableContextText({
    required AttachmentArchiveLocationState location,
    required AttachmentArchiveAdoptionWorkflowState workflow,
  }) {
    final switched =
        workflow.stage == AttachmentArchiveAdoptionWorkflowStage.success;
    final currentPath = switched
        ? workflow.candidatePath ?? location.archiveRootPath
        : location.archiveRootPath ??
              location.lastKnownDisplayPath ??
              workflow.sourcePath;
    final volumeName = switched
        ? workflow.candidateVolumeName ?? _volumeNameForPath(currentPath)
        : location.configuration?.volumeName ??
              _volumeNameForPath(currentPath) ??
              'This Mac';
    final connection = switched
        ? 'Connected'
        : _connectionLabel(location.availability);
    final locationIssue = switched ? null : location.issue;
    final availabilityExplanation = switch (location.availability) {
      AttachmentArchiveLocationAvailability.customUnavailable =>
        'Archived attachments are unavailable until this volume reconnects. '
            'Message browsing and search remain available.',
      AttachmentArchiveLocationAvailability.permissionDenied =>
        'MessageLens needs permission to read archived attachments at this '
            'location. Message browsing and search remain available.',
      AttachmentArchiveLocationAvailability.configuredDirectoryMissing =>
        'The configured attachment_archive folder is missing. Message '
            'browsing and search remain available.',
      AttachmentArchiveLocationAvailability.configurationInvalid =>
        'The saved archive location cannot be read. Message browsing and '
            'search remain available.',
      _ => null,
    };

    return [
      'Current archive',
      currentPath ?? 'Location unavailable',
      '$volumeName · $connection',
      if (availabilityExplanation != null) availabilityExplanation,
      if (locationIssue case final issue?) issue,
      _copySelectionExplanation,
    ].join('\n\n');
  }

  String _connectionLabel(AttachmentArchiveLocationAvailability availability) {
    return switch (availability) {
      AttachmentArchiveLocationAvailability.defaultAvailable ||
      AttachmentArchiveLocationAvailability.customAvailable => 'Connected',
      AttachmentArchiveLocationAvailability.customReadOnly =>
        'Connected · Read-only',
      AttachmentArchiveLocationAvailability.customUnavailable =>
        'Not connected',
      AttachmentArchiveLocationAvailability.permissionDenied =>
        'Permission needed',
      AttachmentArchiveLocationAvailability.configuredDirectoryMissing =>
        'Folder missing',
      AttachmentArchiveLocationAvailability.configurationInvalid =>
        'Configuration problem',
    };
  }

  String? _volumeNameForPath(String? archivePath) {
    if (archivePath == null) {
      return null;
    }
    final segments = Uri.file(archivePath).pathSegments;
    if (segments.length < 2 || segments.first != 'Volumes') {
      return null;
    }
    return segments[1];
  }

  String _unchangedMessage(AttachmentArchiveAdoptionWorkflowState workflow) {
    final sourcePath = workflow.sourcePath;
    return [
      'Your archive location has not changed.',
      if (sourcePath != null) 'MessageLens is still using:\n$sourcePath',
    ].join('\n\n');
  }

  String _userFacingIssue(
    String? issue, {
    String fallback = 'The check could not be completed.',
  }) {
    return (issue ?? fallback)
        .replaceAll('The candidate', 'The selected copy')
        .replaceAll('the candidate', 'the selected copy')
        .replaceAll('Candidate', 'Selected copy')
        .replaceAll('candidate', 'selected copy')
        .replaceAll('authoritative archive', 'current archive');
  }

  String _phaseLabel(AttachmentArchiveVerificationPhase phase) {
    return switch (phase) {
      AttachmentArchiveVerificationPhase.preparing => 'Preparing archive check',
      AttachmentArchiveVerificationPhase.metadata => 'Reading metadata',
      AttachmentArchiveVerificationPhase.sourceCoverage =>
        'Checking current archive',
      AttachmentArchiveVerificationPhase.candidateExtras =>
        'Checking archive copy',
    };
  }

  String _progressLabel(AttachmentArchiveVerificationProgress progress) {
    final totalFiles = progress.totalFiles;
    final totalBytes = progress.totalBytes;
    if (totalFiles == null || totalBytes == null) {
      return '${_phaseLabel(progress.phase)}…';
    }
    final percent = ((progress.fractionComplete ?? 0) * 100).round();
    return '${_phaseLabel(progress.phase)} · '
        '${progress.filesChecked} of $totalFiles files · '
        '${_formatBytes(progress.bytesChecked)} of ${_formatBytes(totalBytes)} · '
        '$percent%';
  }

  String _plural(int count, String noun) => count == 1 ? noun : '${noun}s';

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
