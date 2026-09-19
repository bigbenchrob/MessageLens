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
        AttachmentArchiveVerificationPhase;
import '../payloads/attachment_archive_settings_cassette_payload.dart';

part 'attachment_archive_settings_resolver.g.dart';

@riverpod
class AttachmentArchiveSettingsResolver
    extends _$AttachmentArchiveSettingsResolver {
  @override
  void build() {}

  AttachmentArchiveSettingsCassettePayload resolve({
    required int cassetteIndex,
    required AttachmentArchiveLocationState location,
    required AttachmentArchiveAdoptionWorkflowState workflow,
    AttachmentArchiveAdoptionResult? recovery,
  }) {
    if (workflow.stage ==
        AttachmentArchiveAdoptionWorkflowStage.currentArchive) {
      final recoveryPayload = _resolveRecovery(
        cassetteIndex: cassetteIndex,
        location: location,
        recovery: recovery,
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
      ),
      AttachmentArchiveAdoptionWorkflowStage.checking => _payload(
        cassetteIndex: cassetteIndex,
        workflowView: AttachmentArchiveSettingsWorkflowView.checking,
        bodyText:
            'Checking archive copy…\n\nMessageLens is reading the current '
            'archive and the selected copy. Neither archive is being changed.',
        statusLines: [
          ..._pathLines(workflow),
          if (workflow.progress case final progress?)
            AttachmentArchiveSettingsStatusLine(
              label: 'Progress',
              value:
                  '${_phaseLabel(progress.phase)} · '
                  '${progress.filesChecked} files · '
                  '${_formatBytes(progress.bytesChecked)}',
            ),
        ],
        actions: const [
          SidebarActionDescriptor(
            label: 'Cancel',
            intent: AttachmentArchiveCancelCheckRequested(),
          ),
        ],
      ),
      AttachmentArchiveAdoptionWorkflowStage.candidateComplete =>
        _resolveComplete(cassetteIndex: cassetteIndex, workflow: workflow),
      AttachmentArchiveAdoptionWorkflowStage.candidateBehind => _resolveBehind(
        cassetteIndex: cassetteIndex,
        workflow: workflow,
      ),
      AttachmentArchiveAdoptionWorkflowStage.candidateInvalid => _payload(
        cassetteIndex: cassetteIndex,
        workflowView: AttachmentArchiveSettingsWorkflowView.candidateInvalid,
        bodyText:
            'Selected folder cannot be used as an attachment archive\n\n'
            '${workflow.issue ?? 'The selected archive structure is invalid.'}',
        statusLines: _pathLines(workflow),
        actions: const [
          SidebarActionDescriptor(
            label: 'Choose Another Folder',
            intent: AttachmentArchiveChooseAnotherFolderRequested(),
          ),
        ],
      ),
      AttachmentArchiveAdoptionWorkflowStage.sourceUnavailable => _payload(
        cassetteIndex: cassetteIndex,
        workflowView: AttachmentArchiveSettingsWorkflowView.sourceUnavailable,
        bodyText:
            'Current archive is unavailable\n\nMessageLens cannot verify '
            'another archive until the current archive is available. No '
            'location was changed.',
        statusLines: _pathLines(workflow),
        footnote: workflow.issue,
        actions: const [
          SidebarActionDescriptor(
            label: 'Check Again',
            intent: AttachmentArchiveCheckAgainRequested(),
          ),
        ],
      ),
      AttachmentArchiveAdoptionWorkflowStage.candidateUnavailable => _payload(
        cassetteIndex: cassetteIndex,
        workflowView:
            AttachmentArchiveSettingsWorkflowView.candidateUnavailable,
        bodyText:
            'The selected archive copy is unavailable. No location was '
            'changed.',
        statusLines: _pathLines(workflow),
        footnote: workflow.issue,
        actions: const [
          SidebarActionDescriptor(
            label: 'Choose Another Folder',
            intent: AttachmentArchiveChooseAnotherFolderRequested(),
          ),
          SidebarActionDescriptor(
            label: 'Check Again',
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
        bodyText: 'The archive must be checked again before it can be used.',
        statusLines: _pathLines(workflow),
        footnote: workflow.issue,
        actions: const [
          SidebarActionDescriptor(
            label: 'Choose Another Folder',
            intent: AttachmentArchiveChooseAnotherFolderRequested(),
          ),
          SidebarActionDescriptor(
            label: 'Check Again',
            intent: AttachmentArchiveCheckAgainRequested(),
            tone: SidebarActionTone.primary,
          ),
        ],
      ),
      AttachmentArchiveAdoptionWorkflowStage.archiveChanged => _payload(
        cassetteIndex: cassetteIndex,
        workflowView: AttachmentArchiveSettingsWorkflowView.archiveChanged,
        bodyText:
            'The archive changed since it was checked\n\nNo location was '
            'changed. Check the copy again before using it.',
        statusLines: _pathLines(workflow),
        footnote: workflow.issue,
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
          bodyText:
              'This archive copy can be read, but MessageLens cannot use it '
              'as the active archive because it is not writable. No location '
              'was changed.',
          statusLines: _pathLines(workflow),
          footnote: workflow.issue,
          actions: const [
            SidebarActionDescriptor(
              label: 'Choose Another Folder',
              intent: AttachmentArchiveChooseAnotherFolderRequested(),
            ),
            SidebarActionDescriptor(
              label: 'Check Again',
              intent: AttachmentArchiveCheckAgainRequested(),
              tone: SidebarActionTone.primary,
            ),
          ],
        ),
      AttachmentArchiveAdoptionWorkflowStage.switching => _payload(
        cassetteIndex: cassetteIndex,
        workflowView: AttachmentArchiveSettingsWorkflowView.switching,
        bodyText:
            'Switching archive location…\n\nMessageLens is validating the '
            'new active location. No attachment payloads are being copied or '
            'moved.',
        statusLines: _pathLines(workflow),
      ),
      AttachmentArchiveAdoptionWorkflowStage.success => _payload(
        cassetteIndex: cassetteIndex,
        workflowView: AttachmentArchiveSettingsWorkflowView.success,
        bodyText:
            'External archive active\n\n'
            '${workflow.candidatePath ?? location.archiveRootPath ?? ''}\n\n'
            'The original archive remains at:\n'
            '${workflow.sourcePath ?? ''}\n\n'
            'Keep the original for a few days while you confirm that '
            'everything is working normally. MessageLens has not deleted it.',
        statusLines: [
          const AttachmentArchiveSettingsStatusLine(
            label: 'Location',
            value: 'External',
          ),
          if (workflow.candidateVolumeName case final volumeName?)
            AttachmentArchiveSettingsStatusLine(
              label: 'Volume',
              value: volumeName,
            ),
          const AttachmentArchiveSettingsStatusLine(
            label: 'Availability',
            value: 'Available',
          ),
        ],
      ),
      AttachmentArchiveAdoptionWorkflowStage.rollbackRestoredPrevious =>
        _rollbackRestoredPayload(
          cassetteIndex: cassetteIndex,
          workflow: workflow,
        ),
      AttachmentArchiveAdoptionWorkflowStage
          .rollbackPendingPreviousUnavailable =>
        _recoveryPendingPayload(
          cassetteIndex: cassetteIndex,
          issue: workflow.issue,
        ),
      AttachmentArchiveAdoptionWorkflowStage.configurationConflict =>
        _configurationConflictPayload(
          cassetteIndex: cassetteIndex,
          issue: workflow.issue,
        ),
      AttachmentArchiveAdoptionWorkflowStage.failed => _payload(
        cassetteIndex: cassetteIndex,
        workflowView: AttachmentArchiveSettingsWorkflowView.failed,
        bodyText:
            'Archive location was not changed\n\nMessageLens could not '
            'complete the archive-location switch.',
        statusLines: _pathLines(workflow),
        footnote: workflow.issue,
      ),
    };
  }

  AttachmentArchiveSettingsCassettePayload _resolveCurrent({
    required int cassetteIndex,
    required AttachmentArchiveLocationState location,
    required AttachmentArchiveAdoptionWorkflowState workflow,
  }) {
    final displayPath =
        location.archiveRootPath ?? location.lastKnownDisplayPath;
    final isInternal =
        location.availability ==
        AttachmentArchiveLocationAvailability.defaultAvailable;
    final status = switch (location.availability) {
      AttachmentArchiveLocationAvailability.defaultAvailable =>
        'The built-in attachment archive is available.',
      AttachmentArchiveLocationAvailability.customAvailable =>
        'The external attachment archive is connected and available for reads.',
      AttachmentArchiveLocationAvailability.customReadOnly =>
        'The external attachment archive is connected in read-only mode.',
      AttachmentArchiveLocationAvailability.customUnavailable =>
        'The external attachment archive is unavailable. Message browsing and '
            'search remain available; reconnect the configured volume to read '
            'archived payloads.',
      AttachmentArchiveLocationAvailability.permissionDenied =>
        'Permission to read the external attachment archive was denied. '
            'Messages and search remain available.',
      AttachmentArchiveLocationAvailability.configuredDirectoryMissing =>
        'The configured attachment archive directory is missing. Messages and '
            'search remain available.',
      AttachmentArchiveLocationAvailability.configurationInvalid =>
        'The external attachment archive configuration is invalid. Messages '
            'and search remain available.',
    };
    final issue = location.issue;
    final canStart = workflow.executionEnabled && location.isAvailable;
    const adoptionExplanation =
        'Already copied your archive? Select the copied attachment_archive '
        'folder and MessageLens will check it. MessageLens will not copy or '
        'move the folder.';
    return AttachmentArchiveSettingsCassettePayload(
      cassetteIndex: cassetteIndex,
      bodyText: [
        status,
        if (location.configuration?.volumeName case final volumeName?)
          'Volume: $volumeName',
        if (displayPath != null && displayPath.isNotEmpty)
          'Location: $displayPath',
        if (issue != null && issue.isNotEmpty) 'Status detail: $issue',
        if (workflow.executionEnabled) adoptionExplanation,
      ].join('\n\n'),
      statusLines: [
        AttachmentArchiveSettingsStatusLine(
          label: 'Location',
          value: isInternal ? 'Internal' : 'External',
        ),
        if (location.configuration?.volumeName case final volumeName?)
          AttachmentArchiveSettingsStatusLine(
            label: 'Volume',
            value: volumeName,
          ),
        AttachmentArchiveSettingsStatusLine(
          label: 'Availability',
          value: _availabilityLabel(location.availability),
        ),
      ],
      actions: workflow.executionEnabled
          ? [
              SidebarActionDescriptor(
                label: 'Use Existing Archive…',
                intent: const AttachmentArchiveUseExistingRequested(),
                tone: SidebarActionTone.primary,
                isEnabled: canStart,
              ),
            ]
          : const [],
      footnote: isInternal
          ? null
          : 'The external archive remains authoritative when available. '
                'MessageLens does not silently fall back to an internal copy.',
    );
  }

  AttachmentArchiveSettingsCassettePayload _resolveComplete({
    required int cassetteIndex,
    required AttachmentArchiveAdoptionWorkflowState workflow,
  }) {
    final verifiedFileCount = workflow.verifiedFileCount ?? 0;
    final verifiedBytes = workflow.verifiedBytes ?? 0;
    final extras = workflow.allowedExtraCount ?? 0;
    final readOnlyExplanation = workflow.candidateIsAdoptable
        ? null
        : 'This archive copy can be read, but MessageLens cannot use it as the '
              'active archive because it is not writable.';
    const coverageExplanation =
        'Everything currently stored in the active attachment archive is '
        'present in this copy.';
    final extrasExplanation =
        'The selected copy also contains $extras additional preserved '
        '${_plural(extras, 'attachment')}.';
    return _payload(
      cassetteIndex: cassetteIndex,
      workflowView: AttachmentArchiveSettingsWorkflowView.candidateComplete,
      bodyText: [
        'Archive copy verified',
        coverageExplanation,
        if (extras > 0) extrasExplanation,
        if (readOnlyExplanation != null) readOnlyExplanation,
      ].join('\n\n'),
      statusLines: [
        ..._pathLines(workflow),
        AttachmentArchiveSettingsStatusLine(
          label: 'Verified',
          value:
              '$verifiedFileCount ${_plural(verifiedFileCount, 'file')} / '
              '${_formatBytes(verifiedBytes)}',
        ),
        if (extras > 0)
          AttachmentArchiveSettingsStatusLine(
            label: 'Additional preserved attachments',
            value: '$extras / ${_formatBytes(workflow.allowedExtraBytes ?? 0)}',
          ),
      ],
      actions: workflow.candidateIsAdoptable
          ? const [
              SidebarActionDescriptor(
                label: 'Cancel',
                intent: AttachmentArchiveCancelCheckRequested(),
              ),
              SidebarActionDescriptor(
                label: 'Use This Archive',
                intent: AttachmentArchiveUseCandidateRequested(),
                tone: SidebarActionTone.primary,
              ),
            ]
          : const [
              SidebarActionDescriptor(
                label: 'Choose Another Folder',
                intent: AttachmentArchiveChooseAnotherFolderRequested(),
              ),
              SidebarActionDescriptor(
                label: 'Check Again',
                intent: AttachmentArchiveCheckAgainRequested(),
                tone: SidebarActionTone.primary,
              ),
            ],
    );
  }

  AttachmentArchiveSettingsCassettePayload _resolveBehind({
    required int cassetteIndex,
    required AttachmentArchiveAdoptionWorkflowState workflow,
  }) {
    final missingCount = workflow.missingCount ?? 0;
    final missingBytes = workflow.missingBytes ?? 0;
    return _payload(
      cassetteIndex: cassetteIndex,
      workflowView: AttachmentArchiveSettingsWorkflowView.candidateBehind,
      bodyText:
          'Archive copy is not up to date\n\nThe active archive contains '
          '$missingCount ${_plural(missingCount, 'attachment')} '
          '(${_formatBytes(missingBytes)}) that '
          '${missingCount == 1 ? 'is' : 'are'} not present in the selected '
          'copy.\n\nUpdate your external copy, then check it again.',
      statusLines: [
        ..._pathLines(workflow),
        AttachmentArchiveSettingsStatusLine(
          label: 'Missing from copy',
          value:
              '$missingCount ${_plural(missingCount, 'attachment')} / '
              '${_formatBytes(missingBytes)}',
        ),
      ],
      actions: const [
        SidebarActionDescriptor(
          label: 'Choose Another Folder',
          intent: AttachmentArchiveChooseAnotherFolderRequested(),
        ),
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
        ),
      AttachmentArchiveAdoptionOutcome.rollbackPendingPreviousUnavailable ||
      AttachmentArchiveAdoptionOutcome.failed => _recoveryPendingPayload(
        cassetteIndex: cassetteIndex,
        issue: recovery.issue,
      ),
      AttachmentArchiveAdoptionOutcome.configurationConflict =>
        _configurationConflictPayload(
          cassetteIndex: cassetteIndex,
          issue: recovery.issue,
        ),
      _ => null,
    };
  }

  AttachmentArchiveSettingsCassettePayload _rollbackRestoredPayload({
    required int cassetteIndex,
    required AttachmentArchiveAdoptionWorkflowState workflow,
  }) {
    return _payload(
      cassetteIndex: cassetteIndex,
      workflowView:
          AttachmentArchiveSettingsWorkflowView.rollbackRestoredPrevious,
      bodyText:
          'Archive location was not changed\n\nMessageLens restored the '
          'previous archive location. Both archive folders remain untouched.',
      statusLines: _pathLines(workflow),
      footnote: workflow.issue,
    );
  }

  AttachmentArchiveSettingsCassettePayload _recoveryPendingPayload({
    required int cassetteIndex,
    required String? issue,
  }) {
    return _payload(
      cassetteIndex: cassetteIndex,
      workflowView: AttachmentArchiveSettingsWorkflowView
          .rollbackPendingPreviousUnavailable,
      bodyText:
          'Archive location recovery is waiting for the previous archive\n\n'
          'MessageLens has not reported success and has not fallen back to '
          'another archive.',
      footnote: issue,
    );
  }

  AttachmentArchiveSettingsCassettePayload _configurationConflictPayload({
    required int cassetteIndex,
    required String? issue,
  }) {
    return _payload(
      cassetteIndex: cassetteIndex,
      workflowView: AttachmentArchiveSettingsWorkflowView.configurationConflict,
      bodyText:
          'Archive location changed unexpectedly\n\nMessageLens did not '
          'guess which archive should be authoritative. Both archive folders '
          'remain untouched.',
      footnote: issue,
    );
  }

  AttachmentArchiveSettingsCassettePayload _payload({
    required int cassetteIndex,
    required AttachmentArchiveSettingsWorkflowView workflowView,
    required String bodyText,
    List<AttachmentArchiveSettingsStatusLine> statusLines = const [],
    List<SidebarActionDescriptor> actions = const [],
    String? footnote,
  }) {
    return AttachmentArchiveSettingsCassettePayload(
      cassetteIndex: cassetteIndex,
      workflowView: workflowView,
      bodyText: bodyText,
      statusLines: statusLines,
      actions: actions,
      footnote: footnote,
    );
  }

  List<AttachmentArchiveSettingsStatusLine> _pathLines(
    AttachmentArchiveAdoptionWorkflowState workflow,
  ) {
    return [
      if (workflow.sourcePath case final sourcePath?)
        AttachmentArchiveSettingsStatusLine(
          label: 'Current archive',
          value: sourcePath,
        ),
      if (workflow.candidatePath case final candidatePath?)
        AttachmentArchiveSettingsStatusLine(
          label: 'Candidate archive',
          value: candidatePath,
        ),
      if (workflow.candidateVolumeName case final volumeName?)
        AttachmentArchiveSettingsStatusLine(
          label: 'Candidate volume',
          value: volumeName,
        ),
    ];
  }

  String _availabilityLabel(
    AttachmentArchiveLocationAvailability availability,
  ) {
    return switch (availability) {
      AttachmentArchiveLocationAvailability.defaultAvailable ||
      AttachmentArchiveLocationAvailability.customAvailable => 'Available',
      AttachmentArchiveLocationAvailability.customReadOnly =>
        'Available (read-only)',
      AttachmentArchiveLocationAvailability.customUnavailable => 'Unavailable',
      AttachmentArchiveLocationAvailability.permissionDenied =>
        'Permission denied',
      AttachmentArchiveLocationAvailability.configuredDirectoryMissing =>
        'Configured directory missing',
      AttachmentArchiveLocationAvailability.configurationInvalid =>
        'Configuration invalid',
    };
  }

  String _phaseLabel(AttachmentArchiveVerificationPhase phase) {
    return switch (phase) {
      AttachmentArchiveVerificationPhase.metadata => 'Reading metadata',
      AttachmentArchiveVerificationPhase.sourceCoverage =>
        'Checking current archive',
      AttachmentArchiveVerificationPhase.candidateExtras =>
        'Checking archive copy',
    };
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
