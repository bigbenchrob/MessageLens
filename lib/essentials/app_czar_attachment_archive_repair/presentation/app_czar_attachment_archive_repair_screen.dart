import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../config/theme/colors/theme_colors.dart';
import '../../../config/theme/spacing/app_spacing.dart';
import '../../../config/theme/theme_typography.dart';
import '../application/app_czar_attachment_archive_repair_controller.dart';
import '../domain/app_czar_attachment_archive_repair_models.dart';
import '../domain/app_czar_attachment_archive_repair_state.dart';

class AppCzarAttachmentArchiveRepairScreen extends ConsumerWidget {
  const AppCzarAttachmentArchiveRepairScreen({super.key});

  static const screenKey = Key('app-czar-attachment-archive-repair-screen');
  static const requiredCountKey = Key('attachment-repair-required-count');
  static const coveredCountKey = Key('attachment-repair-covered-count');
  static const attentionCountKey = Key('attachment-repair-attention-count');
  static const nextBatchCountKey = Key('attachment-repair-next-batch-count');
  static const nextBatchBytesKey = Key('attachment-repair-next-batch-bytes');
  static const startKey = Key('attachment-repair-start');
  static const checkAgainKey = Key('attachment-repair-check-again');
  static const retryRestartKey = Key('attachment-repair-retry-restart');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final state = ref.watch(appCzarAttachmentArchiveRepairControllerProvider);
    final controller = ref.read(
      appCzarAttachmentArchiveRepairControllerProvider.notifier,
    );

    return ColoredBox(
      key: screenKey,
      color: colors.surfaces.canvas,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
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
                    'Attachment archive needs attention',
                    style: typography.title1.copyWith(
                      color: colors.content.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'MessageLens is checking current attachment evidence. '
                    'Nothing is preserved without your confirmation.',
                    style: typography.body.copyWith(
                      color: colors.content.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _RepairStatusCard(
                    state: state,
                    colors: colors,
                    typography: typography,
                  ),
                  if (state.snapshot case final snapshot?) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _RepairCountsCard(
                      snapshot: snapshot,
                      colors: colors,
                      typography: typography,
                    ),
                    if (snapshot.nextBatchAuthorization
                        case final authorization?) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _RepairBatchCard(
                        authorization: authorization,
                        colors: colors,
                        typography: typography,
                      ),
                    ],
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  _RepairActions(
                    state: state,
                    colors: colors,
                    typography: typography,
                    onStart: controller.startPreservation,
                    onCheckAgain: controller.checkAgain,
                    onRetryRestart: controller.retryRestart,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RepairBatchCard extends StatelessWidget {
  const _RepairBatchCard({
    required this.authorization,
    required this.colors,
    required this.typography,
  });

  final AppCzarAttachmentArchiveRepairBatchAuthorization authorization;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    final count = authorization.itemCount;
    final bytes = authorization.totalKnownBytes;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaces.surface,
        border: Border.all(color: colors.lines.borderSubtle),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Next repair batch',
              style: typography.title3.copyWith(
                color: colors.content.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              key: AppCzarAttachmentArchiveRepairScreen.nextBatchCountKey,
              '$count ${_attachmentPlural(count)}',
              style: typography.controlValue.copyWith(
                color: colors.content.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              key: AppCzarAttachmentArchiveRepairScreen.nextBatchBytesKey,
              bytes == null
                  ? 'Total size could not be established'
                  : 'Total source size: ${_formatExactBytes(bytes)}',
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

class _RepairStatusCard extends StatelessWidget {
  const _RepairStatusCard({
    required this.state,
    required this.colors,
    required this.typography,
  });

  final AppCzarAttachmentArchiveRepairState state;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaces.surface,
        border: Border.all(color: colors.lines.borderSubtle),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _statusHeading(state),
              style: typography.title3.copyWith(
                color: _statusColor(state.phase, colors),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _statusDetail(state),
              style: typography.body.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
            if (state.phase ==
                AppCzarAttachmentArchiveRepairPhase.preserving) ...[
              const SizedBox(height: AppSpacing.md),
              ProgressBar(value: _progressValue(state)),
            ],
          ],
        ),
      ),
    );
  }
}

class _RepairCountsCard extends StatelessWidget {
  const _RepairCountsCard({
    required this.snapshot,
    required this.colors,
    required this.typography,
  });

  final AppCzarAttachmentArchiveRepairSnapshot snapshot;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    final rows = <({Key? key, String label, int value})>[
      (
        key: AppCzarAttachmentArchiveRepairScreen.requiredCountKey,
        label: 'Required payloads',
        value: snapshot.requiredCount,
      ),
      (
        key: AppCzarAttachmentArchiveRepairScreen.coveredCountKey,
        label: 'Covered',
        value: snapshot.coveredCount,
      ),
      (
        key: AppCzarAttachmentArchiveRepairScreen.attentionCountKey,
        label: 'Need attention',
        value: snapshot.needAttentionCount,
      ),
      (
        key: null,
        label: 'Available from Messages',
        value: snapshot.availableFromMessagesCount,
      ),
      (
        key: null,
        label: 'Source currently absent',
        value: snapshot.sourceAbsentCount,
      ),
      (
        key: null,
        label: 'Source evidence unavailable',
        value: snapshot.sourceUnknownCount,
      ),
      (
        key: null,
        label: 'Record-backed recovery needed',
        value: snapshot.recordBackedRecoveryCount,
      ),
      (
        key: null,
        label: 'Unsafe or conflicting evidence',
        value: snapshot.unsafeOrConflictingCount,
      ),
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaces.surface,
        border: Border.all(color: colors.lines.borderSubtle),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            for (var index = 0; index < rows.length; index++) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      rows[index].label,
                      style: typography.body.copyWith(
                        color: colors.content.textSecondary,
                      ),
                    ),
                  ),
                  Text(
                    key: rows[index].key,
                    '${rows[index].value}',
                    style: typography.controlValue.copyWith(
                      color: colors.content.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              if (index != rows.length - 1)
                const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ),
      ),
    );
  }
}

class _RepairActions extends StatelessWidget {
  const _RepairActions({
    required this.state,
    required this.colors,
    required this.typography,
    required this.onStart,
    required this.onCheckAgain,
    required this.onRetryRestart,
  });

  final AppCzarAttachmentArchiveRepairState state;
  final ThemeColors colors;
  final ThemeTypography typography;
  final Future<void> Function(
    AppCzarAttachmentArchiveRepairBatchAuthorization authorization,
  )
  onStart;
  final Future<void> Function() onCheckAgain;
  final Future<void> Function() onRetryRestart;

  @override
  Widget build(BuildContext context) {
    if (_isBusy(state.phase)) {
      return Row(
        children: [
          const ProgressCircle(radius: AppSpacing.sm),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              _busyLabel(state.phase),
              style: typography.body.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
          ),
        ],
      );
    }

    if (state.canRetryRestart) {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          key: AppCzarAttachmentArchiveRepairScreen.retryRestartKey,
          onPressed: () async {
            await onRetryRestart();
          },
          icon: const Icon(Icons.restart_alt, size: 16),
          label: const Text('Restart and reassess'),
          style: TextButton.styleFrom(
            foregroundColor: colors.accents.primary,
            textStyle: typography.controlValue,
          ),
        ),
      );
    }

    final authorization = state.snapshot?.nextBatchAuthorization;
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      children: [
        if (state.canStartPreservation && authorization != null)
          TextButton.icon(
            key: AppCzarAttachmentArchiveRepairScreen.startKey,
            onPressed: () async {
              await onStart(authorization);
            },
            icon: const Icon(Icons.archive_outlined, size: 16),
            label: Text(
              'Preserve these '
              '${authorization.itemCount} '
              '${_attachmentPlural(authorization.itemCount)}',
            ),
            style: TextButton.styleFrom(
              foregroundColor: colors.accents.primary,
              textStyle: typography.controlValue,
            ),
          ),
        if (state.canCheckAgain)
          TextButton.icon(
            key: AppCzarAttachmentArchiveRepairScreen.checkAgainKey,
            onPressed: () async {
              await onCheckAgain();
            },
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Check Again'),
            style: TextButton.styleFrom(
              foregroundColor: colors.content.textSecondary,
              textStyle: typography.controlValue,
            ),
          ),
      ],
    );
  }
}

bool _isBusy(AppCzarAttachmentArchiveRepairPhase phase) {
  return phase == AppCzarAttachmentArchiveRepairPhase.inspecting ||
      phase == AppCzarAttachmentArchiveRepairPhase.preserving ||
      phase == AppCzarAttachmentArchiveRepairPhase.stopping ||
      phase == AppCzarAttachmentArchiveRepairPhase.restartRequested;
}

String _busyLabel(AppCzarAttachmentArchiveRepairPhase phase) {
  return switch (phase) {
    AppCzarAttachmentArchiveRepairPhase.inspecting =>
      'Checking current attachment coverage…',
    AppCzarAttachmentArchiveRepairPhase.preserving =>
      'Preserving confirmed available payloads…',
    AppCzarAttachmentArchiveRepairPhase.stopping =>
      'Finishing current protected work…',
    AppCzarAttachmentArchiveRepairPhase.restartRequested =>
      'Restarting MessageLens for a fresh assessment…',
    _ => '',
  };
}

String _statusHeading(AppCzarAttachmentArchiveRepairState state) {
  return switch (state.phase) {
    AppCzarAttachmentArchiveRepairPhase.dormant => 'Waiting for an assessment',
    AppCzarAttachmentArchiveRepairPhase.inspecting =>
      'Checking attachment coverage',
    AppCzarAttachmentArchiveRepairPhase.awaitingConfirmation =>
      'One exact repair batch is ready',
    AppCzarAttachmentArchiveRepairPhase.preserving =>
      'Preserving available payloads',
    AppCzarAttachmentArchiveRepairPhase.waitingForHuman =>
      'Some payloads still need attention',
    AppCzarAttachmentArchiveRepairPhase.stopping => 'Finishing protected work',
    AppCzarAttachmentArchiveRepairPhase.restartRequested =>
      'Fresh assessment requested',
    AppCzarAttachmentArchiveRepairPhase.restartFailed =>
      'MessageLens could not restart',
    AppCzarAttachmentArchiveRepairPhase.failed =>
      'Current repair evidence could not be completed',
  };
}

String _statusDetail(AppCzarAttachmentArchiveRepairState state) {
  if (state.phase == AppCzarAttachmentArchiveRepairPhase.failed ||
      state.phase == AppCzarAttachmentArchiveRepairPhase.restartFailed) {
    return switch (state.failureKind) {
      AppCzarAttachmentArchiveRepairFailureKind.inspectionFailed =>
        'The current attachment evidence could not be inspected safely.',
      AppCzarAttachmentArchiveRepairFailureKind.preservationFailed =>
        'The current preservation pass stopped before it could settle.',
      AppCzarAttachmentArchiveRepairFailureKind.incoherentEvidence =>
        'The current attachment evidence was internally inconsistent.',
      AppCzarAttachmentArchiveRepairFailureKind.drainFailed =>
        'MessageLens could not finish the current protected work safely.',
      AppCzarAttachmentArchiveRepairFailureKind.restartFailed =>
        'MessageLens could not restart for a fresh assessment.',
      null => 'The current operation did not complete.',
    };
  }
  return switch (state.phase) {
    AppCzarAttachmentArchiveRepairPhase.dormant =>
      'No repair occurrence is active.',
    AppCzarAttachmentArchiveRepairPhase.inspecting =>
      'Reading bounded current evidence without changing the archive.',
    AppCzarAttachmentArchiveRepairPhase.awaitingConfirmation =>
      'Review the exact next-batch count and source-byte scope. One '
          'confirmation applies only to this displayed batch.',
    AppCzarAttachmentArchiveRepairPhase.preserving =>
      '${state.preservedCount ?? 0} of '
          '${state.preservationTotalCount ?? 0} processed in this pass.',
    AppCzarAttachmentArchiveRepairPhase.waitingForHuman =>
      'Change the external evidence when appropriate, then check again. '
          'MessageLens will not mark unresolved payloads as repaired.',
    AppCzarAttachmentArchiveRepairPhase.stopping =>
      'No new repair work is being admitted.',
    AppCzarAttachmentArchiveRepairPhase.restartRequested =>
      'Fresh AppCzar evidence will decide what happens next.',
    AppCzarAttachmentArchiveRepairPhase.restartFailed ||
    AppCzarAttachmentArchiveRepairPhase.failed => '',
  };
}

Color _statusColor(
  AppCzarAttachmentArchiveRepairPhase phase,
  ThemeColors colors,
) {
  return switch (phase) {
    AppCzarAttachmentArchiveRepairPhase.failed ||
    AppCzarAttachmentArchiveRepairPhase.restartFailed => colors.status.error,
    AppCzarAttachmentArchiveRepairPhase.waitingForHuman ||
    AppCzarAttachmentArchiveRepairPhase.awaitingConfirmation =>
      colors.status.warning,
    AppCzarAttachmentArchiveRepairPhase.dormant ||
    AppCzarAttachmentArchiveRepairPhase.inspecting ||
    AppCzarAttachmentArchiveRepairPhase.preserving ||
    AppCzarAttachmentArchiveRepairPhase.stopping ||
    AppCzarAttachmentArchiveRepairPhase.restartRequested =>
      colors.accents.primary,
  };
}

double _progressValue(AppCzarAttachmentArchiveRepairState state) {
  final completed = state.preservedCount ?? 0;
  final total = state.preservationTotalCount ?? 0;
  if (total <= 0) {
    return 0;
  }
  return completed / total;
}

String _attachmentPlural(int count) {
  return count == 1 ? 'attachment' : 'attachments';
}

String _formatExactBytes(int bytes) {
  if (bytes < 1024) {
    return '$bytes bytes';
  }
  const units = <String>['KB', 'MB', 'GB', 'TB'];
  var value = bytes / 1024;
  var unitIndex = 0;
  while (value >= 1024 && unitIndex < units.length - 1) {
    value /= 1024;
    unitIndex += 1;
  }
  return '${value.toStringAsFixed(1)} ${units[unitIndex]} ($bytes bytes)';
}
