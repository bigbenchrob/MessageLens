import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../config/theme/colors/theme_colors.dart';
import '../../../config/theme/spacing/app_spacing.dart';
import '../../../config/theme/theme_typography.dart';
import '../application/app_czar_source_access_controller.dart';
import '../domain/app_czar_source_access_state.dart';

class AppCzarSourceAccessScreen extends ConsumerWidget {
  const AppCzarSourceAccessScreen({super.key});

  static const screenKey = Key('app-czar-source-access-screen');
  static const reasonKey = Key('app-czar-source-access-reason');
  static const settingsKey = Key('app-czar-source-access-settings');
  static const checkAgainKey = Key('app-czar-source-access-check-again');
  static const restartKey = Key('app-czar-source-access-restart');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final state = ref.watch(appCzarSourceAccessControllerProvider);
    final controller = ref.read(appCzarSourceAccessControllerProvider.notifier);

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
                    'Messages access needs attention',
                    style: typography.title1.copyWith(
                      color: colors.content.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'MessageLens Development cannot currently read the '
                    'Messages database.',
                    style: typography.body.copyWith(
                      color: colors.content.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _SourceAccessCard(
                    state: state,
                    colors: colors,
                    typography: typography,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _SourceAccessActions(
                    state: state,
                    colors: colors,
                    typography: typography,
                    onOpenSettings: controller.openSystemSettings,
                    onCheckAgain: controller.checkAgain,
                    onRestart: controller.restartAndReassess,
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

class _SourceAccessCard extends StatelessWidget {
  const _SourceAccessCard({
    required this.state,
    required this.colors,
    required this.typography,
  });

  final AppCzarSourceAccessState state;
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
              _statusHeading(state.phase),
              style: typography.title3.copyWith(
                color: _statusColor(state.phase, colors),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              key: AppCzarSourceAccessScreen.reasonKey,
              state.sourceReason ??
                  'No source-readability result is available.',
              style: typography.body.copyWith(
                color: colors.content.textPrimary,
              ),
            ),
            if (state.phase == AppCzarSourceAccessPhase.waitingForHuman) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                'MessageLens cannot determine from this evidence whether '
                'Full Disk Access is enabled or disabled.',
                style: typography.body.copyWith(
                  color: colors.content.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'A common repair is to review System Settings → Privacy & '
                'Security → Full Disk Access for '
                'com.bigbenchsoftware.MessageLens.development.',
                style: typography.body.copyWith(
                  color: colors.content.textSecondary,
                ),
              ),
            ],
            if (state.settingsFailure case final failure?) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                failure,
                style: typography.body.copyWith(color: colors.status.error),
              ),
            ],
            if (state.restartFailure case final failure?) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                failure,
                style: typography.body.copyWith(color: colors.status.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SourceAccessActions extends StatelessWidget {
  const _SourceAccessActions({
    required this.state,
    required this.colors,
    required this.typography,
    required this.onOpenSettings,
    required this.onCheckAgain,
    required this.onRestart,
  });

  final AppCzarSourceAccessState state;
  final ThemeColors colors;
  final ThemeTypography typography;
  final Future<void> Function() onOpenSettings;
  final Future<void> Function() onCheckAgain;
  final Future<void> Function() onRestart;

  @override
  Widget build(BuildContext context) {
    if (state.phase == AppCzarSourceAccessPhase.checking ||
        state.phase == AppCzarSourceAccessPhase.restartRequested) {
      return Row(
        children: [
          const ProgressCircle(radius: AppSpacing.sm),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              state.phase == AppCzarSourceAccessPhase.checking
                  ? 'Checking the Messages source once…'
                  : 'Restarting MessageLens for a fresh assessment…',
              style: typography.body.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
          ),
        ],
      );
    }

    if (state.canRestartAndReassess) {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          key: AppCzarSourceAccessScreen.restartKey,
          onPressed: () async {
            await onRestart();
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

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      children: [
        TextButton.icon(
          key: AppCzarSourceAccessScreen.settingsKey,
          onPressed: () async {
            await onOpenSettings();
          },
          icon: const Icon(Icons.settings_outlined, size: 16),
          label: const Text('Open System Settings'),
          style: TextButton.styleFrom(
            foregroundColor: colors.content.textSecondary,
            textStyle: typography.controlValue,
          ),
        ),
        TextButton.icon(
          key: AppCzarSourceAccessScreen.checkAgainKey,
          onPressed: state.canCheckAgain
              ? () async {
                  await onCheckAgain();
                }
              : null,
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Check Again'),
          style: TextButton.styleFrom(
            foregroundColor: colors.accents.primary,
            textStyle: typography.controlValue,
          ),
        ),
      ],
    );
  }
}

String _statusHeading(AppCzarSourceAccessPhase phase) {
  return switch (phase) {
    AppCzarSourceAccessPhase.dormant => 'Waiting for an assessment',
    AppCzarSourceAccessPhase.waitingForHuman =>
      'Current read-only check failed',
    AppCzarSourceAccessPhase.checking => 'Checking again',
    AppCzarSourceAccessPhase.inconclusive => 'Current result is inconclusive',
    AppCzarSourceAccessPhase.restartRequested =>
      'Current read-only check succeeded',
    AppCzarSourceAccessPhase.restartFailed => 'Restart did not complete',
  };
}

Color _statusColor(AppCzarSourceAccessPhase phase, ThemeColors colors) {
  return switch (phase) {
    AppCzarSourceAccessPhase.waitingForHuman ||
    AppCzarSourceAccessPhase.restartFailed => colors.status.error,
    AppCzarSourceAccessPhase.inconclusive => colors.status.warning,
    AppCzarSourceAccessPhase.restartRequested => colors.status.success,
    AppCzarSourceAccessPhase.dormant ||
    AppCzarSourceAccessPhase.checking => colors.content.textPrimary,
  };
}
