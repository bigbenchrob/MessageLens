import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/spacing/app_spacing.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../config/theme/widgets/buttons/app_secondary_button.dart';
import '../../../../config/theme/widgets/theme_widgets.dart';
import '../../../attachments/feature_level_providers.dart'
    show
        AttachmentArchiveAdoptionWorkflowStage,
        AttachmentArchiveAdoptionWorkflowState,
        AttachmentArchiveVerificationPhase,
        attachmentArchiveAdoptionWorkflowProvider,
        attachmentArchiveLocationProvider;

class AttachmentArchivePanel extends ConsumerWidget {
  const AttachmentArchivePanel({super.key});

  static const workflowRegionKey = Key(
    'attachment-archive-center-workflow-region',
  );
  static const chooseButtonKey = Key('attachment-archive-center-choose');
  static const useButtonKey = Key('attachment-archive-center-use');
  static const resumeButtonKey = Key('attachment-archive-center-resume');
  static const progressKey = Key('attachment-archive-center-progress');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final location = ref.watch(attachmentArchiveLocationProvider).valueOrNull;
    final workflow = ref.watch(attachmentArchiveAdoptionWorkflowProvider);
    final actions = ref.read(
      attachmentArchiveAdoptionWorkflowProvider.notifier,
    );

    return ColoredBox(
      color: colors.surfaces.canvas,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl + AppSpacing.sm,
          vertical: AppSpacing.xl,
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Attachment Archive',
                  style: typography.title1.copyWith(
                    color: colors.content.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                if (workflow.stage ==
                    AttachmentArchiveAdoptionWorkflowStage.success)
                  _SuccessView(
                    currentPath:
                        workflow.candidatePath ?? location?.archiveRootPath,
                    currentVolumeName:
                        workflow.candidateVolumeName ??
                        location?.configuration?.volumeName,
                    originalPath: workflow.sourcePath,
                  )
                else ...[
                  _ArchiveLocationCard(
                    eyebrow: 'CURRENT ARCHIVE',
                    path:
                        location?.archiveRootPath ??
                        location?.lastKnownDisplayPath ??
                        workflow.sourcePath,
                    volumeName: location?.configuration?.volumeName,
                    connected: location?.isAvailable ?? false,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    "If you've copied your attachment_archive folder "
                    'somewhere else, MessageLens can check the copy before '
                    'switching to it.\n\nMessageLens will not perform the '
                    'initial bulk copy.',
                    style: typography.body.copyWith(
                      color: colors.content.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    key: workflowRegionKey,
                    child: _WorkflowRegion(
                      state: workflow,
                      onChoose: workflow.executionEnabled
                          ? () async {
                              await actions.chooseExistingArchive();
                            }
                          : null,
                      onChooseAnother: workflow.executionEnabled
                          ? () async {
                              await actions.chooseAnotherFolder();
                            }
                          : null,
                      onCheckAgain: workflow.executionEnabled
                          ? () async {
                              await actions.checkAgain();
                            }
                          : null,
                      onUse: workflow.canUseCandidate
                          ? () async {
                              await actions.useCandidate();
                            }
                          : null,
                      onCancel: () async {
                        await actions.cancelCheck();
                      },
                      onResume: workflow.executionEnabled
                          ? () async {
                              await actions.resumePendingRemediation();
                            }
                          : null,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkflowRegion extends ConsumerWidget {
  const _WorkflowRegion({
    required this.state,
    required this.onChoose,
    required this.onChooseAnother,
    required this.onCheckAgain,
    required this.onUse,
    required this.onCancel,
    required this.onResume,
  });

  final AttachmentArchiveAdoptionWorkflowState state;
  final VoidCallback? onChoose;
  final VoidCallback? onChooseAnother;
  final VoidCallback? onCheckAgain;
  final VoidCallback? onUse;
  final VoidCallback? onCancel;
  final VoidCallback? onResume;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stage = state.stage;
    if (stage == AttachmentArchiveAdoptionWorkflowStage.currentArchive) {
      return Align(
        alignment: Alignment.centerLeft,
        child: _PrimaryAction(
          key: AttachmentArchivePanel.chooseButtonKey,
          label: 'Choose Archive Copy…',
          onPressed: onChoose,
        ),
      );
    }

    final copyCard = _ArchiveLocationCard(
      eyebrow:
          stage == AttachmentArchiveAdoptionWorkflowStage.remediationPending
          ? 'ACTIVE ARCHIVE'
          : 'ARCHIVE COPY',
      path: state.candidatePath,
      volumeName: state.candidateVolumeName,
      connected:
          stage != AttachmentArchiveAdoptionWorkflowStage.candidateUnavailable,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        copyCard,
        const SizedBox(height: AppSpacing.lg),
        switch (stage) {
          AttachmentArchiveAdoptionWorkflowStage.checking => _CheckingView(
            state: state,
            onCancel: onCancel,
          ),
          AttachmentArchiveAdoptionWorkflowStage.candidateComplete =>
            _CompleteView(
              state: state,
              onUse: onUse,
              onChoose: onChooseAnother,
            ),
          AttachmentArchiveAdoptionWorkflowStage.candidateBehind => _BehindView(
            state: state,
            onUse: onUse,
            onChoose: onChooseAnother,
          ),
          AttachmentArchiveAdoptionWorkflowStage.switching => _CheckingView(
            state: state,
            heading: 'Checking the final archive changes…',
          ),
          AttachmentArchiveAdoptionWorkflowStage.remediating =>
            _RemediationView(state: state),
          AttachmentArchiveAdoptionWorkflowStage.remediationPending =>
            _PendingView(state: state, onResume: onResume),
          AttachmentArchiveAdoptionWorkflowStage.archiveChanged => _ErrorView(
            heading: 'The archives changed',
            issue: state.issue,
            onPrimary: onCheckAgain,
            primaryLabel: 'Check Again',
          ),
          AttachmentArchiveAdoptionWorkflowStage.sourceUnavailable =>
            _ErrorView(
              heading: 'Current archive unavailable',
              issue: state.issue,
              onPrimary: onCheckAgain,
              primaryLabel: 'Try Again',
            ),
          AttachmentArchiveAdoptionWorkflowStage.candidateUnavailable =>
            _ErrorView(
              heading: 'Archive copy unavailable',
              issue: state.issue,
              onPrimary: onChooseAnother,
              primaryLabel: 'Choose a Different Copy',
            ),
          AttachmentArchiveAdoptionWorkflowStage.candidateInvalid ||
          AttachmentArchiveAdoptionWorkflowStage.verificationFailed ||
          AttachmentArchiveAdoptionWorkflowStage.verificationEvidenceInvalid ||
          AttachmentArchiveAdoptionWorkflowStage.candidateNoLongerWritable =>
            _ErrorView(
              heading: "This copy can't be used",
              issue: state.issue,
              onPrimary: onChooseAnother,
              primaryLabel: 'Choose a Different Copy',
            ),
          AttachmentArchiveAdoptionWorkflowStage.rollbackRestoredPrevious ||
          AttachmentArchiveAdoptionWorkflowStage
              .rollbackPendingPreviousUnavailable ||
          AttachmentArchiveAdoptionWorkflowStage.configurationConflict ||
          AttachmentArchiveAdoptionWorkflowStage.failed => _ErrorView(
            heading: 'Archive switch could not be completed',
            issue: state.issue,
            onPrimary: onCheckAgain,
            primaryLabel: 'Try Again',
          ),
          AttachmentArchiveAdoptionWorkflowStage.currentArchive ||
          AttachmentArchiveAdoptionWorkflowStage.success =>
            const SizedBox.shrink(),
        },
      ],
    );
  }
}

class _CheckingView extends ConsumerWidget {
  const _CheckingView({this.heading, required this.state, this.onCancel});

  final String? heading;
  final AttachmentArchiveAdoptionWorkflowState state;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = ref.watch(themeTypographyProvider);
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final progress = state.progress;
    final determinate = progress?.isDeterminate ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading ??
              (progress?.phase == AttachmentArchiveVerificationPhase.preparing
                  ? 'Preparing archive check…'
                  : 'Checking archive copy…'),
          style: typography.title2.copyWith(color: colors.content.textPrimary),
        ),
        const SizedBox(height: AppSpacing.md),
        if (determinate) ...[
          _DeterminateProgress(fraction: progress!.fractionComplete ?? 0),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${progress.filesChecked} of ${progress.totalFiles} files checked',
            style: typography.body.copyWith(color: colors.content.textPrimary),
          ),
          Text(
            '${_formatBytes(progress.bytesChecked)} of '
            '${_formatBytes(progress.totalBytes ?? 0)} · '
            '${((progress.fractionComplete ?? 0) * 100).round()}%',
            style: typography.body.copyWith(
              color: colors.content.textSecondary,
            ),
          ),
        ] else
          const CupertinoActivityIndicator(),
        if (onCancel case final cancel?) ...[
          const SizedBox(height: AppSpacing.lg),
          _SecondaryAction(label: 'Cancel', onPressed: cancel),
        ],
      ],
    );
  }
}

class _CompleteView extends ConsumerWidget {
  const _CompleteView({required this.state, this.onUse, this.onChoose});

  final AttachmentArchiveAdoptionWorkflowState state;
  final VoidCallback? onUse;
  final VoidCallback? onChoose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ResultView(
      heading: 'Archive copy verified',
      body:
          'Everything currently stored in the active attachment archive is '
          'present in this copy.',
      actions: [
        _SecondaryAction(label: 'Choose a Different Copy', onPressed: onChoose),
        _PrimaryAction(
          key: AttachmentArchivePanel.useButtonKey,
          label: 'Use This Copy',
          onPressed: onUse,
        ),
      ],
    );
  }
}

class _BehindView extends ConsumerWidget {
  const _BehindView({required this.state, this.onUse, this.onChoose});

  final AttachmentArchiveAdoptionWorkflowState state;
  final VoidCallback? onUse;
  final VoidCallback? onChoose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = state.missingCount ?? 0;
    final bytes = state.missingBytes ?? 0;
    final canUse = state.candidateIsAdoptable;
    return _ResultView(
      heading: canUse
          ? 'This copy is almost up to date'
          : 'This copy is substantially out of date',
      body: canUse
          ? 'Everything already in this copy has been verified. Since the '
                'copy was made, the current archive has received '
                '$count ${_plural(count, 'new attachment')} · '
                '${_formatBytes(bytes)}.\n\nMessageLens can switch to this '
                'copy now so all new attachments go there, then add those '
                'missing attachments. The current archive will remain '
                'unchanged.'
          : 'MessageLens will not perform application-owned catch-up for this '
                'large delta. Recreate or refresh the copy externally.',
      actions: [
        _SecondaryAction(label: 'Choose a Different Copy', onPressed: onChoose),
        if (canUse)
          _PrimaryAction(
            key: AttachmentArchivePanel.useButtonKey,
            label: 'Use This Copy',
            onPressed: onUse,
          ),
      ],
    );
  }
}

class _RemediationView extends ConsumerWidget {
  const _RemediationView({required this.state});

  final AttachmentArchiveAdoptionWorkflowState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = state.remediationProgress;
    final files = progress?.filesCompleted ?? 0;
    final totalFiles = progress?.totalFiles ?? state.missingCount ?? 0;
    final bytes = progress?.bytesCompleted ?? 0;
    final totalBytes = progress?.totalBytes ?? state.missingBytes ?? 0;
    return _ResultView(
      heading: 'Adding missing attachments',
      body:
          '$files of $totalFiles attachments\n'
          '${_formatBytes(bytes)} of ${_formatBytes(totalBytes)}',
      progress: progress?.fractionComplete ?? 0,
    );
  }
}

class _PendingView extends ConsumerWidget {
  const _PendingView({required this.state, this.onResume});

  final AttachmentArchiveAdoptionWorkflowState state;
  final VoidCallback? onResume;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = state.missingCount ?? 0;
    final bytes = state.missingBytes ?? 0;
    return _ResultView(
      heading: 'Attachment archive switched',
      body:
          'New attachments are being stored in:\n'
          '${state.candidatePath ?? ''}\n\nMessageLens still needs to add '
          '$count older ${_plural(count, 'attachment')} · '
          '${_formatBytes(bytes)} from:\n${state.sourcePath ?? ''}\n\n'
          '${state.issue ?? ''}',
      actions: [
        _PrimaryAction(
          key: AttachmentArchivePanel.resumeButtonKey,
          label: 'Resume Adding Missing Attachments',
          onPressed: onResume,
        ),
      ],
    );
  }
}

class _ErrorView extends ConsumerWidget {
  const _ErrorView({
    required this.heading,
    required this.issue,
    required this.onPrimary,
    required this.primaryLabel,
  });

  final String heading;
  final String? issue;
  final VoidCallback? onPrimary;
  final String primaryLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ResultView(
      heading: heading,
      body:
          '${issue ?? 'The check could not be completed.'}\n\nYour current '
          'archive has not changed.',
      actions: [_PrimaryAction(label: primaryLabel, onPressed: onPrimary)],
    );
  }
}

class _ResultView extends ConsumerWidget {
  const _ResultView({
    required this.heading,
    required this.body,
    this.actions = const [],
    this.progress,
  });

  final String heading;
  final String body;
  final List<Widget> actions;
  final double? progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: typography.title2.copyWith(color: colors.content.textPrimary),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          body,
          style: typography.body.copyWith(color: colors.content.textSecondary),
        ),
        if (progress case final value?) ...[
          const SizedBox(height: AppSpacing.md),
          _DeterminateProgress(fraction: value),
        ],
        if (actions.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: actions,
          ),
        ],
      ],
    );
  }
}

class _ArchiveLocationCard extends ConsumerWidget {
  const _ArchiveLocationCard({
    required this.eyebrow,
    required this.path,
    required this.volumeName,
    required this.connected,
  });

  final String eyebrow;
  final String? path;
  final String? volumeName;
  final bool connected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final displayPath = path ?? 'Archive location unavailable';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaces.control,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.lines.borderSubtle, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eyebrow,
              style: typography.caption1.copyWith(
                color: colors.content.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${volumeName ?? _volumeNameForPath(path) ?? 'Archive volume'} · '
              '${connected ? 'Connected' : 'Unavailable'}',
              style: typography.infoCardTitle.copyWith(
                color: colors.content.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              displayPath,
              style: typography.body.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessView extends ConsumerWidget {
  const _SuccessView({
    required this.currentPath,
    required this.currentVolumeName,
    required this.originalPath,
  });

  final String? currentPath;
  final String? currentVolumeName;
  final String? originalPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Attachment archive switched',
          style: typography.title2.copyWith(color: colors.content.textPrimary),
        ),
        const SizedBox(height: AppSpacing.lg),
        _ArchiveLocationCard(
          eyebrow: 'CURRENT ARCHIVE',
          path: currentPath,
          volumeName: currentVolumeName,
          connected: true,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'All verified attachments are available here.',
          style: typography.body.copyWith(color: colors.content.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xl),
        _ArchiveLocationCard(
          eyebrow: 'ORIGINAL ARCHIVE',
          path: originalPath,
          volumeName: null,
          connected: true,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'MessageLens has not deleted the original archive. Keep it for a '
          'few days while you confirm everything is working normally.',
          style: typography.body.copyWith(color: colors.content.textSecondary),
        ),
      ],
    );
  }
}

class _DeterminateProgress extends ConsumerWidget {
  const _DeterminateProgress({required this.fraction});

  final double fraction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    return Semantics(
      key: AttachmentArchivePanel.progressKey,
      label: '${(fraction.clamp(0, 1) * 100).round()} percent complete',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          height: 6,
          child: ColoredBox(
            color: colors.surfaces.control,
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: fraction.clamp(0, 1),
                child: ColoredBox(color: colors.globals.brand.primary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryAction extends ConsumerWidget {
  const _PrimaryAction({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppThemeWidgets.primaryButton(
      ref: ref,
      label: label,
      onPressed: onPressed,
    );
  }
}

class _SecondaryAction extends ConsumerWidget {
  const _SecondaryAction({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    return AppSecondaryButton(
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Text(
          label,
          style: typography.controlValue.copyWith(
            color: colors.content.textPrimary,
          ),
        ),
      ),
    );
  }
}

String? _volumeNameForPath(String? value) {
  if (value == null) {
    return null;
  }
  final segments = Uri.file(value).pathSegments;
  if (segments.length < 2 || segments.first != 'Volumes') {
    return null;
  }
  return segments[1];
}

String _plural(int count, String noun) => count == 1 ? noun : '${noun}s';

String _formatBytes(int bytes) {
  if (bytes < 1024) {
    return '$bytes B';
  }
  const units = <String>['KB', 'MB', 'GB', 'TB'];
  var value = bytes / 1024;
  var unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  final precision = value >= 100
      ? 0
      : value >= 10
      ? 1
      : 2;
  return '${value.toStringAsFixed(precision)} ${units[unit]}';
}
