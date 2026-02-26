import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../application/db_onboarding_state_provider.dart';
import '../../domain/db_onboarding_phase.dart';
import '../../domain/db_onboarding_state.dart';
import '../widgets/db_onboarding_stepper.dart';
import '../widgets/fda_instructions_card.dart';

/// Main panel view for database onboarding.
///
/// Shows a friendly setup UI with progress stepper while the app
/// locates and imports local macOS databases.
class DbOnboardingPanel extends ConsumerStatefulWidget {
  const DbOnboardingPanel({super.key});

  @override
  ConsumerState<DbOnboardingPanel> createState() => _DbOnboardingPanelState();
}

class _DbOnboardingPanelState extends ConsumerState<DbOnboardingPanel> {
  @override
  void initState() {
    super.initState();
    // Start onboarding automatically when panel is shown,
    // but only if not already in dev mode (dev panel handles its own flow)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentState = ref.read(dbOnboardingStateNotifierProvider);
      if (!currentState.devMode) {
        ref.read(dbOnboardingStateNotifierProvider.notifier).startOnboarding();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final state = ref.watch(dbOnboardingStateNotifierProvider);

    return ColoredBox(
      color: colors.surfaces.canvas,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(colors),
                const SizedBox(height: 32),
                _buildContent(colors, state),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              CupertinoIcons.bubble_left_bubble_right,
              size: 32,
              color: colors.accents.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Setting Up Your Messages',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colors.content.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          "We're importing your messages from macOS. "
          'This only needs to happen once.',
          style: TextStyle(
            fontSize: 15,
            color: colors.content.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(ThemeColors colors, DbOnboardingState state) {
    // Show FDA instructions if permission check failed
    if (state.currentPhase == DbOnboardingPhase.checkingPermissions &&
        !state.fdaGranted) {
      return FdaInstructionsCard(
        onRetry: () {
          ref.read(dbOnboardingStateNotifierProvider.notifier).retryFdaCheck();
        },
      );
    }

    // Show error state
    if (state.currentPhase == DbOnboardingPhase.error) {
      return _buildErrorCard(colors, state);
    }

    // Show stepper for all other states
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaces.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.lines.border),
      ),
      child: DbOnboardingStepper(state: state),
    );
  }

  Widget _buildErrorCard(ThemeColors colors, DbOnboardingState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaces.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF3B30).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.exclamationmark_triangle,
                size: 24,
                color: Color(0xFFFF3B30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Setup Error',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: colors.content.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          if (state.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              state.errorMessage!,
              style: TextStyle(
                fontSize: 14,
                color: colors.content.textSecondary,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 20),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: colors.accents.primary,
            borderRadius: BorderRadius.circular(8),
            onPressed: () {
              ref.read(dbOnboardingStateNotifierProvider.notifier).retry();
            },
            child: const Text(
              'Try Again',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
