import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../config/theme/colors/theme_colors.dart';
import '../../../config/theme/theme_typography.dart';
import '../application/advanced_start_fresh_action_provider.dart';
import '../application/advanced_start_fresh_presentation_provider.dart';
import '../application/onboarding_journey_coordinator_provider.dart';
import '../domain/advanced_start_fresh_presentation.dart';
import '../domain/onboarding_journey_state.dart';

class AdvancedStartFreshOverlayHost extends ConsumerWidget {
  const AdvancedStartFreshOverlayHost({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presentation = ref.watch(
      advancedStartFreshPresentationControllerProvider,
    );
    if (!presentation.isVisible) {
      return const SizedBox.shrink();
    }

    final onboardingJourney = ref.watch(onboardingJourneyCoordinatorProvider);
    final onboardingOwnsPresentation =
        onboardingJourney is! OnboardingNormalApplication;
    if (presentation.phase ==
            AdvancedStartFreshPresentationPhase.verifiedVirgin &&
        onboardingOwnsPresentation) {
      // Keep the operation surface for the ownership-reconciliation frame.
      // The normal sidebar closes in that frame's post-frame callback, so
      // revealing Onboarding immediately would expose the old open sidebar.
      // The occurrence guard prevents an old callback from clearing a newer
      // Start Fresh presentation.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(advancedStartFreshPresentationControllerProvider.notifier)
            .dismiss(expectedOccurrence: presentation.occurrence);
      });
      return Positioned.fill(
        child: AdvancedStartFreshOverlay(presentation: presentation),
      );
    }

    return Positioned.fill(
      child: AdvancedStartFreshOverlay(presentation: presentation),
    );
  }
}

class AdvancedStartFreshOverlay extends ConsumerWidget {
  const AdvancedStartFreshOverlay({required this.presentation, super.key});

  static const surfaceKey = Key('advanced-start-fresh-operation-surface');
  static const retryButtonKey = Key('advanced-start-fresh-retry-button');
  static const dismissButtonKey = Key('advanced-start-fresh-dismiss-button');

  final AdvancedStartFreshPresentation presentation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final failure = presentation.failure;
    final isFailure =
        presentation.phase == AdvancedStartFreshPresentationPhase.failed;
    final title = switch (presentation.phase) {
      AdvancedStartFreshPresentationPhase.preparing =>
        'Preparing a fresh start',
      AdvancedStartFreshPresentationPhase.verifiedVirgin =>
        'Starting Onboarding',
      AdvancedStartFreshPresentationPhase.failed =>
        failure?.kind == AdvancedStartFreshFailureKind.installationIneligible ||
                failure?.kind ==
                    AdvancedStartFreshFailureKind.installationStateUnavailable
            ? 'Reset Message Data is unavailable'
            : "MessageLens couldn't start fresh",
      AdvancedStartFreshPresentationPhase.idle => '',
    };
    final body = switch (presentation.phase) {
      AdvancedStartFreshPresentationPhase.preparing =>
        'MessageLens is resetting only its rebuildable message and '
            'conversation data. Your preserved data remains in place.',
      AdvancedStartFreshPresentationPhase.verifiedVirgin =>
        'The clean installation state has been verified. Onboarding is '
            'starting now.',
      AdvancedStartFreshPresentationPhase.failed =>
        failure?.summary ?? 'MessageLens could not finish starting fresh.',
      AdvancedStartFreshPresentationPhase.idle => '',
    };

    return ColoredBox(
      key: surfaceKey,
      color: colors.surfaces.canvas,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isFailure)
                  Icon(
                    Icons.error_outline,
                    size: 42,
                    color: colors.status.error,
                  )
                else
                  const SizedBox.square(
                    dimension: 40,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: typography.title1.copyWith(
                    color: colors.content.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  body,
                  style: typography.body.copyWith(
                    color: colors.content.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (isFailure) ...[
                  const SizedBox(height: 28),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      if (failure?.canRetry == true)
                        FilledButton(
                          key: retryButtonKey,
                          onPressed: () async {
                            await ref
                                .read(advancedStartFreshActionProvider)
                                .retry(occurrence: presentation.occurrence);
                          },
                          child: const Text('Try Again'),
                        ),
                      OutlinedButton(
                        key: dismissButtonKey,
                        onPressed: () {
                          ref
                              .read(advancedStartFreshActionProvider)
                              .dismissFailure(
                                occurrence: presentation.occurrence,
                              );
                        },
                        child: const Text('Return to Settings'),
                      ),
                    ],
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
