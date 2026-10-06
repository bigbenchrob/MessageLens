import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../config/theme/colors/theme_colors.dart';
import '../../../config/theme/spacing/app_spacing.dart';
import '../../../config/theme/theme_typography.dart';
import '../../conversation_graph/presentation/conversation_graph_build_stage_label.dart';
import '../application/app_czar_data_update_controller.dart';
import '../domain/app_czar_data_update_state.dart';

class AppCzarDataUpdateScreen extends ConsumerWidget {
  const AppCzarDataUpdateScreen({super.key});

  static const screenKey = Key('app-czar-data-update-screen');
  static const stageKey = Key('app-czar-data-update-stage');
  static const failureKey = Key('app-czar-data-update-failure');
  static const restartKey = Key('app-czar-data-update-restart');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final state = ref.watch(appCzarDataUpdateControllerProvider);

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
                    'Updating MessageLens',
                    style: typography.title1.copyWith(
                      color: colors.content.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Using the current Messages source to update the existing '
                    'MessageLens dataset.',
                    style: typography.body.copyWith(
                      color: colors.content.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _UpdateSummaryCard(
                    state: state,
                    colors: colors,
                    typography: typography,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _UpdateStageCard(
                    state: state,
                    colors: colors,
                    typography: typography,
                    onRestart: () {
                      ref
                          .read(appCzarDataUpdateControllerProvider.notifier)
                          .restartAndReassess();
                    },
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

class _UpdateSummaryCard extends StatelessWidget {
  const _UpdateSummaryCard({
    required this.state,
    required this.colors,
    required this.typography,
  });

  final AppCzarDataUpdateState state;
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
          children: [
            _UpdateValueRow(
              label: 'Source messages',
              value: _countLabel(state.sourceMessageCount),
              colors: colors,
              typography: typography,
            ),
            const SizedBox(height: AppSpacing.md),
            Divider(height: 1, color: colors.lines.dividerQuiet),
            const SizedBox(height: AppSpacing.md),
            _UpdateValueRow(
              label: 'MessageLens messages',
              value: _countLabel(state.localMessageCount),
              colors: colors,
              typography: typography,
            ),
            const SizedBox(height: AppSpacing.md),
            Divider(height: 1, color: colors.lines.dividerQuiet),
            const SizedBox(height: AppSpacing.md),
            _UpdateValueRow(
              label: 'Messages to import',
              value: _countLabel(state.messagesToImport),
              colors: colors,
              typography: typography,
            ),
            if (state.attachmentsExamined != null) ...[
              const SizedBox(height: AppSpacing.md),
              Divider(height: 1, color: colors.lines.dividerQuiet),
              const SizedBox(height: AppSpacing.md),
              _UpdateValueRow(
                label: 'Attachments examined',
                value: '${state.attachmentsExamined}',
                colors: colors,
                typography: typography,
              ),
              const SizedBox(height: AppSpacing.sm),
              _UpdateValueRow(
                label: 'New attachments preserved',
                value: '${state.attachmentsPreserved ?? 0}',
                colors: colors,
                typography: typography,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _UpdateValueRow extends StatelessWidget {
  const _UpdateValueRow({
    required this.label,
    required this.value,
    required this.colors,
    required this.typography,
  });

  final String label;
  final String value;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: typography.headline.copyWith(
              color: colors.content.textPrimary,
            ),
          ),
        ),
        Text(
          value,
          style: typography.controlValue.copyWith(
            color: colors.content.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _UpdateStageCard extends StatelessWidget {
  const _UpdateStageCard({
    required this.state,
    required this.colors,
    required this.typography,
    required this.onRestart,
  });

  final AppCzarDataUpdateState state;
  final ThemeColors colors;
  final ThemeTypography typography;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final failed = state.phase == AppCzarDataUpdatePhase.failed;
    final restarting = state.phase == AppCzarDataUpdatePhase.restartRequested;
    final stage = _stageLabel(state);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaces.surfaceRaised,
        border: Border.all(color: colors.lines.border),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!failed && !restarting)
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: ProgressCircle(radius: AppSpacing.sm),
                  )
                else
                  Icon(
                    failed ? Icons.error_outline : Icons.restart_alt,
                    size: AppSpacing.lg,
                    color: failed
                        ? colors.status.error
                        : colors.accents.primary,
                  ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    key: AppCzarDataUpdateScreen.stageKey,
                    stage,
                    style: typography.title3.copyWith(
                      color: colors.content.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            if (state.completedWorkCount != null &&
                state.totalWorkCount != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${state.completedWorkCount} / ${state.totalWorkCount}',
                style: typography.controlValue.copyWith(
                  color: colors.content.textSecondary,
                ),
              ),
            ],
            if (failed) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                key: AppCzarDataUpdateScreen.failureKey,
                state.failure ?? 'Data Update failed without a reason.',
                style: typography.body.copyWith(color: colors.status.error),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextButton.icon(
                key: AppCzarDataUpdateScreen.restartKey,
                onPressed: onRestart,
                icon: const Icon(Icons.restart_alt, size: 16),
                label: const Text('Restart and reassess'),
                style: TextButton.styleFrom(
                  foregroundColor: colors.accents.primary,
                  textStyle: typography.controlValue,
                ),
              ),
            ],
            if (restarting) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'The update work has ended. A fresh process will assess the '
                'environment again from zero.',
                style: typography.body.copyWith(
                  color: colors.content.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _countLabel(int? count) => count == null ? 'Checking…' : '$count';

String _stageLabel(AppCzarDataUpdateState state) {
  return switch (state.phase) {
    AppCzarDataUpdatePhase.dormant => 'Waiting for an assessment',
    AppCzarDataUpdatePhase.preparing => 'Rechecking the current source',
    AppCzarDataUpdatePhase.updating => conversationGraphBuildStageLabel(
      state.suboperation,
      preparingLabel: 'Preparing the supported incremental update',
    ),
    AppCzarDataUpdatePhase.preservingAttachments =>
      state.attachmentsExamined == null
          ? 'Preserving newly referenced attachments'
          : 'Attachment preservation work finished',
    AppCzarDataUpdatePhase.restartRequested => 'Restarting MessageLens',
    AppCzarDataUpdatePhase.failed => 'Data Update could not finish',
  };
}
