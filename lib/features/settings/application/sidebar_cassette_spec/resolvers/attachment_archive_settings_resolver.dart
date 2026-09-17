import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/domain/sidebar_action_intent.dart';
import '../../../../attachments/feature_level_providers.dart'
    show
        AttachmentArchiveLocationAvailability,
        AttachmentArchiveLocationState,
        AttachmentArchiveRelocationDeferredReason,
        AttachmentArchiveRelocationProgress,
        AttachmentArchiveRelocationStage;
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
    required AttachmentArchiveRelocationProgress? relocation,
    required bool relocationEnabled,
  }) {
    if (relocation != null) {
      return _resolveRelocation(
        cassetteIndex: cassetteIndex,
        location: location,
        relocation: relocation,
        relocationEnabled: relocationEnabled,
      );
    }
    return _resolveCurrentLocation(
      cassetteIndex: cassetteIndex,
      location: location,
      relocationEnabled: relocationEnabled,
    );
  }

  AttachmentArchiveSettingsCassettePayload _resolveCurrentLocation({
    required int cassetteIndex,
    required AttachmentArchiveLocationState location,
    required bool relocationEnabled,
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
    return AttachmentArchiveSettingsCassettePayload(
      cassetteIndex: cassetteIndex,
      bodyText: [
        status,
        if (location.configuration?.volumeName case final volumeName?)
          'Volume: $volumeName',
        if (displayPath != null && displayPath.isNotEmpty)
          'Location: $displayPath',
        if (issue != null && issue.isNotEmpty) 'Status detail: $issue',
      ].join('\n\n'),
      statusLines: [
        AttachmentArchiveSettingsStatusLine(
          label: 'Location',
          value: isInternal ? 'Internal' : 'External',
        ),
        AttachmentArchiveSettingsStatusLine(
          label: 'Availability',
          value: _availabilityLabel(location.availability),
        ),
      ],
      actions: isInternal
          ? [
              SidebarActionDescriptor(
                label: 'Move…',
                intent: const AttachmentArchiveMoveRequested(),
                tone: SidebarActionTone.primary,
                isEnabled: relocationEnabled,
              ),
            ]
          : const [],
      footnote: !isInternal
          ? 'The external archive remains authoritative when available. '
                'MessageLens does not silently fall back to a retained internal copy.'
          : relocationEnabled
          ? 'Choose a destination parent. MessageLens creates and manages the '
                'archive folder beneath it.'
          : 'Archive relocation remains disabled until the production '
                'acceptance matrix is reviewed and explicitly authorized.',
    );
  }

  AttachmentArchiveSettingsCassettePayload _resolveRelocation({
    required int cassetteIndex,
    required AttachmentArchiveLocationState location,
    required AttachmentArchiveRelocationProgress relocation,
    required bool relocationEnabled,
  }) {
    final destinationPath = path.join(
      relocation.destinationParentPath,
      relocation.destinationArchiveDirectoryName,
    );
    final commonStatus = <AttachmentArchiveSettingsStatusLine>[
      AttachmentArchiveSettingsStatusLine(
        label: 'Current archive',
        value: relocation.sourceRootPath,
      ),
      AttachmentArchiveSettingsStatusLine(
        label: 'Destination',
        value: destinationPath,
      ),
      if (relocation.destinationVolumeName case final volumeName?)
        AttachmentArchiveSettingsStatusLine(label: 'Volume', value: volumeName),
    ];
    final progressStatus = <AttachmentArchiveSettingsStatusLine>[
      ...commonStatus,
      AttachmentArchiveSettingsStatusLine(
        label: 'Files copied',
        value: '${relocation.filesCopied} of ${relocation.expectedFiles}',
      ),
      AttachmentArchiveSettingsStatusLine(
        label: 'Data copied',
        value:
            '${_formatBytes(relocation.bytesCopied)} of ${_formatBytes(relocation.expectedBytes)}',
      ),
      AttachmentArchiveSettingsStatusLine(
        label: 'Files verified',
        value: '${relocation.filesVerified} of ${relocation.expectedFiles}',
      ),
      AttachmentArchiveSettingsStatusLine(
        label: 'Data verified',
        value:
            '${_formatBytes(relocation.bytesVerified)} of ${_formatBytes(relocation.expectedBytes)}',
      ),
      AttachmentArchiveSettingsStatusLine(
        label: 'Destination availability',
        value: switch (relocation.deferredReason) {
          AttachmentArchiveRelocationDeferredReason.destinationUnavailable =>
            'Unavailable',
          AttachmentArchiveRelocationDeferredReason.destinationReadOnly =>
            'Read-only',
          _ when relocation.stage == AttachmentArchiveRelocationStage.paused =>
            'Deferred',
          _ => 'Available at the last journal update',
        },
      ),
    ];

    switch (relocation.stage) {
      case AttachmentArchiveRelocationStage.selected ||
          AttachmentArchiveRelocationStage.preflighting ||
          AttachmentArchiveRelocationStage.preflighted ||
          AttachmentArchiveRelocationStage.inventorying:
        return AttachmentArchiveSettingsCassettePayload(
          workflowView: AttachmentArchiveSettingsWorkflowView.preparingReview,
          cassetteIndex: cassetteIndex,
          title: 'Preparing Archive Move',
          bodyText:
              'MessageLens is checking the destination and inventorying the '
              'current archive. No payloads are being copied yet, and the '
              'current archive remains authoritative.',
          statusLines: commonStatus,
        );
      case AttachmentArchiveRelocationStage.inventoryComplete:
        return AttachmentArchiveSettingsCassettePayload(
          workflowView: AttachmentArchiveSettingsWorkflowView.preflightReview,
          cassetteIndex: cassetteIndex,
          title: 'Review Archive Move',
          bodyText:
              'MessageLens will copy and verify your attachment archive before '
              'switching to the new location. The existing archive will not be '
              'deleted. The current source remains authoritative until '
              'verification and activation are complete.',
          statusLines: [
            ...commonStatus,
            AttachmentArchiveSettingsStatusLine(
              label: 'Archive size',
              value: _formatBytes(relocation.expectedBytes),
            ),
            AttachmentArchiveSettingsStatusLine(
              label: 'Required capacity',
              value: _formatNullableBytes(relocation.requiredCapacityBytes),
            ),
            AttachmentArchiveSettingsStatusLine(
              label: 'Available capacity',
              value: _formatNullableBytes(relocation.availableCapacityBytes),
            ),
            const AttachmentArchiveSettingsStatusLine(
              label: 'Filesystem safety checks',
              value: 'Passed',
            ),
          ],
          actions: [
            SidebarActionDescriptor(
              label: 'Begin Relocation',
              intent: AttachmentArchiveBeginRelocationRequested(
                operationId: relocation.operationId,
              ),
              tone: SidebarActionTone.primary,
              isEnabled: relocationEnabled,
            ),
            ..._chooseAnotherAndCancelActions(relocation, relocationEnabled),
          ],
          footnote:
              'After activation, the original archive will remain on the '
              'internal drive. Disk-space reclamation is a separate later step.',
        );
      case AttachmentArchiveRelocationStage.copying:
        return _progressPayload(
          cassetteIndex: cassetteIndex,
          relocation: relocation,
          view: AttachmentArchiveSettingsWorkflowView.copying,
          title: 'Copying Attachment Archive',
          bodyText:
              'The current archive remains authoritative. Verified destination '
              'work is recorded so the move can resume safely.',
          statusLines: progressStatus,
          actions: [
            SidebarActionDescriptor(
              label: 'Pause',
              intent: AttachmentArchivePauseRelocationRequested(
                operationId: relocation.operationId,
              ),
              isEnabled: relocationEnabled && relocation.canPause,
            ),
          ],
        );
      case AttachmentArchiveRelocationStage.verifying:
        return _progressPayload(
          cassetteIndex: cassetteIndex,
          relocation: relocation,
          view: AttachmentArchiveSettingsWorkflowView.verifying,
          title: 'Verifying Attachment Archive',
          bodyText:
              'MessageLens is confirming the complete copy before switching '
              'archive locations. Copy completion alone is not treated as success.',
          statusLines: progressStatus,
        );
      case AttachmentArchiveRelocationStage.destinationFinalizing ||
          AttachmentArchiveRelocationStage.destinationFinalized:
        return _progressPayload(
          cassetteIndex: cassetteIndex,
          relocation: relocation,
          view: AttachmentArchiveSettingsWorkflowView.finalizing,
          title: 'Finalizing Attachment Archive',
          bodyText:
              'The verified destination is being finalized. The source archive '
              'is still retained and no source payload is being deleted.',
          statusLines: progressStatus,
        );
      case AttachmentArchiveRelocationStage.configurationSwitching ||
          AttachmentArchiveRelocationStage.activated:
        return _progressPayload(
          cassetteIndex: cassetteIndex,
          relocation: relocation,
          view: AttachmentArchiveSettingsWorkflowView.activating,
          title: 'Activating Attachment Archive',
          bodyText:
              'MessageLens is validating the new archive through the verified '
              'activation transaction. The move is not complete yet.',
          statusLines: progressStatus,
        );
      case AttachmentArchiveRelocationStage.paused:
        return _pausedPayload(
          cassetteIndex: cassetteIndex,
          relocation: relocation,
          relocationEnabled: relocationEnabled,
          progressStatus: progressStatus,
        );
      case AttachmentArchiveRelocationStage.cancelled:
        return AttachmentArchiveSettingsCassettePayload(
          workflowView: AttachmentArchiveSettingsWorkflowView.cancelled,
          cassetteIndex: cassetteIndex,
          title: 'Archive Move Cancelled',
          bodyText:
              'The source archive remains authoritative and untouched. '
              'MessageLens may retain the operation-owned incomplete copy and '
              'journal; cancellation does not claim that destination data was deleted.',
          statusLines: progressStatus,
          actions: _moveAction(relocationEnabled, location),
        );
      case AttachmentArchiveRelocationStage.failed:
        return AttachmentArchiveSettingsCassettePayload(
          workflowView: AttachmentArchiveSettingsWorkflowView.failed,
          cassetteIndex: cassetteIndex,
          title: 'Archive Move Could Not Continue',
          bodyText:
              'The source archive remains authoritative. MessageLens did not '
              'activate an unverified destination.',
          statusLines: [
            ...progressStatus,
            if (relocation.failure case final failure?)
              AttachmentArchiveSettingsStatusLine(
                label: 'Status detail',
                value: failure,
              ),
          ],
          actions: _moveAction(relocationEnabled, location),
        );
      case AttachmentArchiveRelocationStage.rollbackRestoredOldConfiguration:
        return AttachmentArchiveSettingsCassettePayload(
          workflowView: AttachmentArchiveSettingsWorkflowView.failed,
          cassetteIndex: cassetteIndex,
          title: 'Archive Activation Rolled Back',
          bodyText:
              'MessageLens restored the original archive configuration. The '
              'old source remains authoritative, and both copies remain retained.',
          statusLines: progressStatus,
          actions: _moveAction(relocationEnabled, location),
        );
      case AttachmentArchiveRelocationStage.sourceRetained:
        if (!relocation.isSuccessful) {
          return AttachmentArchiveSettingsCassettePayload(
            workflowView: AttachmentArchiveSettingsWorkflowView.failed,
            cassetteIndex: cassetteIndex,
            title: 'Archive Completion Could Not Be Verified',
            bodyText:
                'The relocation journal does not contain complete activation '
                'and retained-source evidence. MessageLens will not present '
                'this operation as successful.',
            statusLines: progressStatus,
          );
        }
        final available = location.isAvailable;
        return AttachmentArchiveSettingsCassettePayload(
          workflowView: AttachmentArchiveSettingsWorkflowView.completed,
          cassetteIndex: cassetteIndex,
          title: available
              ? 'Attachment Archive Moved Successfully'
              : 'External Attachment Archive Unavailable',
          bodyText: available
              ? 'The verified external archive is active. The original archive '
                    'is still stored at ${relocation.sourceRootPath}. '
                    'MessageLens has not deleted the original copy.'
              : 'The configured external archive is not currently available. '
                    'Messages and search remain usable. MessageLens will not '
                    'silently fall back to the retained internal copy.',
          statusLines: [
            AttachmentArchiveSettingsStatusLine(
              label: 'Active archive',
              value: location.archiveRootPath ?? destinationPath,
            ),
            AttachmentArchiveSettingsStatusLine(
              label: 'Availability',
              value: _availabilityLabel(location.availability),
            ),
            AttachmentArchiveSettingsStatusLine(
              label: 'Original archive retained at',
              value: relocation.sourceRootPath,
            ),
            AttachmentArchiveSettingsStatusLine(
              label: 'Verified size',
              value: _formatBytes(relocation.expectedBytes),
            ),
            AttachmentArchiveSettingsStatusLine(
              label: 'Relocation operation',
              value: relocation.operationId,
            ),
          ],
          footnote:
              'Removing the retained source and reclaiming disk space are not '
              'part of this move and are not available here.',
        );
    }
  }

  AttachmentArchiveSettingsCassettePayload _pausedPayload({
    required int cassetteIndex,
    required AttachmentArchiveRelocationProgress relocation,
    required bool relocationEnabled,
    required List<AttachmentArchiveSettingsStatusLine> progressStatus,
  }) {
    final reason = relocation.deferredReason;
    final resumeStage = relocation.resumeStage;
    final isPreflightFailure =
        resumeStage != null &&
        resumeStage.index <=
            AttachmentArchiveRelocationStage.inventoryComplete.index;
    final bodyText = _pausedExplanation(reason);
    final actions = <SidebarActionDescriptor>[
      if (isPreflightFailure)
        SidebarActionDescriptor(
          label: 'Retry Preflight',
          intent: AttachmentArchiveRetryPreflightRequested(
            operationId: relocation.operationId,
          ),
          isEnabled: relocationEnabled,
        )
      else
        SidebarActionDescriptor(
          label: 'Resume',
          intent: AttachmentArchiveResumeRelocationRequested(
            operationId: relocation.operationId,
          ),
          tone: SidebarActionTone.primary,
          isEnabled: relocationEnabled,
        ),
      ..._chooseAnotherAndCancelActions(relocation, relocationEnabled),
    ];
    return AttachmentArchiveSettingsCassettePayload(
      workflowView: isPreflightFailure
          ? AttachmentArchiveSettingsWorkflowView.preflightFailure
          : AttachmentArchiveSettingsWorkflowView.paused,
      cassetteIndex: cassetteIndex,
      title: isPreflightFailure
          ? 'Archive Move Needs Attention'
          : 'Attachment Archive Move Paused',
      bodyText: bodyText,
      statusLines: [
        ...progressStatus,
        if (relocation.failure case final failure?)
          AttachmentArchiveSettingsStatusLine(
            label: 'Status detail',
            value: failure,
          ),
      ],
      actions: actions,
      footnote:
          'Verified work remains recorded in the durable relocation journal. '
          'The source archive remains authoritative.',
    );
  }

  AttachmentArchiveSettingsCassettePayload _progressPayload({
    required int cassetteIndex,
    required AttachmentArchiveRelocationProgress relocation,
    required AttachmentArchiveSettingsWorkflowView view,
    required String title,
    required String bodyText,
    required List<AttachmentArchiveSettingsStatusLine> statusLines,
    List<SidebarActionDescriptor> actions = const [],
  }) {
    return AttachmentArchiveSettingsCassettePayload(
      workflowView: view,
      cassetteIndex: cassetteIndex,
      title: title,
      bodyText: bodyText,
      statusLines: statusLines,
      actions: actions,
      footnote:
          'You can continue using Messages and search while this operation '
          'runs. Completion time is not estimated.',
    );
  }

  List<SidebarActionDescriptor> _cancelActions(
    AttachmentArchiveRelocationProgress relocation,
    bool enabled,
  ) {
    if (!relocation.canCancel) {
      return const [];
    }
    return [
      SidebarActionDescriptor(
        label: 'Cancel',
        intent: AttachmentArchiveCancelRelocationRequested(
          operationId: relocation.operationId,
        ),
        isEnabled: enabled,
      ),
    ];
  }

  List<SidebarActionDescriptor> _chooseAnotherAndCancelActions(
    AttachmentArchiveRelocationProgress relocation,
    bool enabled,
  ) {
    return [
      SidebarActionDescriptor(
        label: 'Choose Another Location…',
        intent: AttachmentArchiveChooseAnotherLocationRequested(
          operationId: relocation.operationId,
        ),
        isEnabled: enabled && relocation.canCancel,
      ),
      ..._cancelActions(relocation, enabled),
    ];
  }

  List<SidebarActionDescriptor> _moveAction(
    bool enabled,
    AttachmentArchiveLocationState location,
  ) {
    return [
      SidebarActionDescriptor(
        label: 'Move…',
        intent: const AttachmentArchiveMoveRequested(),
        tone: SidebarActionTone.primary,
        isEnabled:
            enabled &&
            location.availability ==
                AttachmentArchiveLocationAvailability.defaultAvailable,
      ),
    ];
  }

  String _pausedExplanation(AttachmentArchiveRelocationDeferredReason? reason) {
    return switch (reason) {
      AttachmentArchiveRelocationDeferredReason.insufficientCapacity =>
        'The destination does not currently have enough available capacity. '
            'Nothing has been activated or deleted.',
      AttachmentArchiveRelocationDeferredReason.destinationUnavailable =>
        'The destination is unavailable. Reconnect the known destination and '
            'choose Resume when you are ready; verified progress is preserved.',
      AttachmentArchiveRelocationDeferredReason.destinationReadOnly =>
        'The destination is read-only. Choose a writable destination or '
            'correct its permissions, then retry preflight.',
      AttachmentArchiveRelocationDeferredReason.unsupportedFilesystem =>
        'The destination filesystem does not provide the safe file operations '
            'required for a verified archive move.',
      AttachmentArchiveRelocationDeferredReason.sourceUnavailable =>
        'The current source archive is unavailable. Restore its availability '
            'before resuming.',
      AttachmentArchiveRelocationDeferredReason.unsafeLocation =>
        'The selected location is unsafe because it overlaps the source or '
            'violates the archive path boundary.',
      AttachmentArchiveRelocationDeferredReason.conflictingDestination =>
        'A conflicting managed destination already exists. MessageLens will '
            'not replace it.',
      AttachmentArchiveRelocationDeferredReason.userPaused =>
        'The move is paused at a safe file boundary. Verified destination work '
            'and the resumable journal have been preserved.',
      AttachmentArchiveRelocationDeferredReason.mutationUnavailable =>
        'Another protected archive operation is in progress. Try Resume after '
            'that operation finishes.',
      null =>
        'The move is paused. The source archive remains authoritative and '
            'verified destination work is preserved.',
    };
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

  String _formatNullableBytes(int? bytes) {
    return bytes == null ? 'Unavailable' : _formatBytes(bytes);
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }
    const units = ['KB', 'MB', 'GB', 'TB'];
    var value = bytes / 1024;
    var unitIndex = 0;
    while (value >= 1024 && unitIndex < units.length - 1) {
      value /= 1024;
      unitIndex++;
    }
    final precision = value >= 10 ? 1 : 2;
    return '${value.toStringAsFixed(precision)} ${units[unitIndex]}';
  }
}
