import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';

/// The visual state of a phase row in the onboarding stepper.
enum PhaseRowState {
  /// Phase has not yet been reached
  pending,

  /// Phase is currently active (with spinner)
  active,

  /// Phase completed successfully
  completed,

  /// Phase encountered an error
  error,
}

/// A single row in the onboarding stepper showing a phase's status.
class DbOnboardingPhaseRow extends ConsumerWidget {
  const DbOnboardingPhaseRow({
    required this.label,
    required this.state,
    super.key,
  });

  /// The human-readable label for this phase.
  final String label;

  /// The current state of this phase.
  final PhaseRowState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _buildIcon(colors),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: _textColor(colors),
                fontWeight: state == PhaseRowState.active
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(ThemeColors colors) {
    const iconSize = 20.0;

    return switch (state) {
      PhaseRowState.pending => Icon(
          CupertinoIcons.circle,
          size: iconSize,
          color: colors.content.textTertiary,
        ),
      PhaseRowState.active => SizedBox(
          width: iconSize,
          height: iconSize,
          child: CupertinoActivityIndicator(
            radius: iconSize / 2 - 2,
            color: colors.accents.primary,
          ),
        ),
      PhaseRowState.completed => const Icon(
          CupertinoIcons.checkmark_circle_fill,
          size: iconSize,
          color: Color(0xFF34C759), // System green
        ),
      PhaseRowState.error => const Icon(
          CupertinoIcons.exclamationmark_circle_fill,
          size: iconSize,
          color: Color(0xFFFF3B30), // System red
        ),
    };
  }

  Color _textColor(ThemeColors colors) {
    return switch (state) {
      PhaseRowState.pending => colors.content.textTertiary,
      PhaseRowState.active => colors.content.textPrimary,
      PhaseRowState.completed => colors.content.textSecondary,
      PhaseRowState.error => const Color(0xFFFF3B30), // System red
    };
  }
}
