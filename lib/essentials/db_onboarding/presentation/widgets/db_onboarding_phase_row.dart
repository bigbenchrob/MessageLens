import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show LinearProgressIndicator;
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

/// Progress data for an active phase.
class PhaseProgress {
  const PhaseProgress({
    this.current,
    this.total,
    this.percent,
    this.statusMessage,
  });

  /// Current count (e.g., messages imported so far).
  final int? current;

  /// Total count (e.g., total messages to import).
  final int? total;

  /// Progress percentage (0.0 to 1.0).
  final double? percent;

  /// Human-readable status message.
  final String? statusMessage;

  /// Whether we have meaningful progress data to display.
  bool get hasProgress => current != null || percent != null;
}

/// A single row in the onboarding stepper showing a phase's status.
class DbOnboardingPhaseRow extends ConsumerWidget {
  const DbOnboardingPhaseRow({
    required this.label,
    required this.state,
    this.progress,
    super.key,
  });

  /// The human-readable label for this phase.
  final String label;

  /// The current state of this phase.
  final PhaseRowState state;

  /// Optional progress data for active phases.
  final PhaseProgress? progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
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
        ),
        // Show expanded progress for active phase with data
        if (state == PhaseRowState.active && progress != null && progress!.hasProgress)
          _buildProgressExpansion(colors),
      ],
    );
  }

  Widget _buildProgressExpansion(ThemeColors colors) {
    final p = progress!;
    final percent = p.percent ?? 0.0;

    return Padding(
      padding: const EdgeInsets.only(left: 32, bottom: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress text: "142,567 / 1,234,567" or status message
          if (p.current != null && p.total != null)
            Text(
              '${_formatNumber(p.current!)} / ${_formatNumber(p.total!)}',
              style: TextStyle(
                fontSize: 12,
                color: colors.content.textSecondary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            )
          else if (p.statusMessage != null)
            Text(
              p.statusMessage!,
              style: TextStyle(
                fontSize: 12,
                color: colors.content.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: 6,
              child: LinearProgressIndicator(
                value: percent.clamp(0.0, 1.0),
                backgroundColor: colors.surfaces.controlMuted,
                valueColor: AlwaysStoppedAnimation<Color>(colors.accents.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int value) {
    if (value < 1000) {
      return value.toString();
    }
    // Add thousand separators
    final str = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
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
