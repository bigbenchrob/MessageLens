import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../config/theme/colors/theme_colors.dart';
import '../../../config/theme/spacing/app_spacing.dart';
import '../../../config/theme/theme_typography.dart';
import '../../app_czar/domain/app_czar_models.dart';
import '../../conversation_graph/presentation/conversation_graph_build_stage_label.dart';
import '../application/app_czar_onboarding_controller.dart';
import '../domain/app_czar_onboarding_state.dart';

class AppCzarOnboardingScreen extends ConsumerWidget {
  const AppCzarOnboardingScreen({super.key});

  static const screenKey = Key('app-czar-onboarding-screen');
  static const checkAgainKey = Key('app-czar-onboarding-check-again');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final state = ref.watch(appCzarOnboardingControllerProvider);
    final controller = ref.read(appCzarOnboardingControllerProvider.notifier);

    return ColoredBox(
      key: screenKey,
      color: colors.surfaces.canvas,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _title(state.phase),
                    style: typography.title1.copyWith(
                      color: colors.content.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _explanation(state),
                    style: typography.body.copyWith(
                      color: colors.content.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.surfaces.surface,
                      border: Border.all(color: colors.lines.borderSubtle),
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_isBusy(state.phase))
                            const ProgressCircle(radius: AppSpacing.sm)
                          else
                            Icon(
                              Icons.info_outline,
                              size: AppSpacing.lg,
                              color: colors.accents.primary,
                            ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _status(state),
                                  style: typography.title3.copyWith(
                                    color: colors.content.textPrimary,
                                  ),
                                ),
                                if (state.issue case final issue?) ...[
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    issue,
                                    style: typography.body.copyWith(
                                      color: colors.content.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (state.canCheckAgain) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Wrap(
                      spacing: AppSpacing.md,
                      children: [
                        if (state.canOpenSystemSettings)
                          TextButton.icon(
                            onPressed: controller.openSystemSettings,
                            icon: const Icon(Icons.settings_outlined, size: 16),
                            label: const Text('Open System Settings'),
                            style: TextButton.styleFrom(
                              foregroundColor: colors.content.textSecondary,
                              textStyle: typography.controlValue,
                            ),
                          ),
                        TextButton.icon(
                          key: checkAgainKey,
                          onPressed: controller.checkAgain,
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Check Again'),
                          style: TextButton.styleFrom(
                            foregroundColor: colors.accents.primary,
                            textStyle: typography.controlValue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

bool _isBusy(AppCzarOnboardingPhase phase) {
  return phase == AppCzarOnboardingPhase.checkingPrerequisites ||
      phase == AppCzarOnboardingPhase.building ||
      phase == AppCzarOnboardingPhase.restarting;
}

String _title(AppCzarOnboardingPhase phase) {
  return switch (phase) {
    AppCzarOnboardingPhase.sourceNeedsHuman =>
      'Messages access needs attention',
    AppCzarOnboardingPhase.contactsNeedHuman =>
      'Contacts access needs attention',
    AppCzarOnboardingPhase.building => 'Building your MessageLens library',
    AppCzarOnboardingPhase.restarting => 'Reassessing MessageLens',
    AppCzarOnboardingPhase.failed => 'MessageLens needs attention',
    AppCzarOnboardingPhase.dormant ||
    AppCzarOnboardingPhase.checkingPrerequisites => 'Preparing MessageLens',
  };
}

String _explanation(AppCzarOnboardingState state) {
  return switch (state.phase) {
    AppCzarOnboardingPhase.sourceNeedsHuman =>
      state.sourceCondition == AppCzarSourceCondition.accessDenied
          ? 'The current read-only Messages check was denied. Review macOS privacy access, then check again.'
          : 'The current Messages database is unavailable. Resolve the condition shown below, then check again.',
    AppCzarOnboardingPhase.contactsNeedHuman =>
      state.contactsCondition ==
              AppCzarContactsPrerequisiteCondition.accessDenied
          ? 'The current read-only Contacts check was denied. Review macOS privacy access, then check again.'
          : 'The current read-only Contacts check found no viable current database. Resolve the condition shown below, then check again.',
    AppCzarOnboardingPhase.building =>
      'The existing graph-build pipeline is constructing the first local browsing dataset.',
    AppCzarOnboardingPhase.restarting =>
      'This onboarding occurrence is complete. MessageLens is restarting for a fresh AppCzar assessment.',
    AppCzarOnboardingPhase.failed =>
      'The process could not complete its required restart.',
    AppCzarOnboardingPhase.dormant ||
    AppCzarOnboardingPhase.checkingPrerequisites =>
      'Checking the current installation, Messages source, Contacts source, and archive configuration.',
  };
}

String _status(AppCzarOnboardingState state) {
  if (state.phase == AppCzarOnboardingPhase.building) {
    final completed = state.completedWorkCount;
    final total = state.totalWorkCount;
    final operation = conversationGraphBuildStageLabel(
      state.suboperation,
      preparingLabel: 'Preparing the initial graph build',
    );
    if (completed != null && total != null) {
      return '$operation — $completed of $total';
    }
    return operation;
  }
  return switch (state.phase) {
    AppCzarOnboardingPhase.sourceNeedsHuman =>
      'Messages source needs a human action',
    AppCzarOnboardingPhase.contactsNeedHuman =>
      'Contacts source needs a human action',
    AppCzarOnboardingPhase.restarting => 'Restarting for fresh evidence',
    AppCzarOnboardingPhase.failed => 'Restart did not complete',
    AppCzarOnboardingPhase.dormant ||
    AppCzarOnboardingPhase.checkingPrerequisites =>
      'Checking current evidence…',
    AppCzarOnboardingPhase.building => 'Building',
  };
}
