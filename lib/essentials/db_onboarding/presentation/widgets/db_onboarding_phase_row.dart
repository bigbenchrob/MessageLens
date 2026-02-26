import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show LinearProgressIndicator;
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../domain/import_sub_stage.dart';

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
///
/// When active, expands to show sub-stages with individual progress bars.
class DbOnboardingPhaseRow extends ConsumerWidget {
  const DbOnboardingPhaseRow({
    required this.label,
    required this.state,
    this.subStages = const [],
    super.key,
  });

  /// The human-readable label for this phase.
  final String label;

  /// The current state of this phase.
  final PhaseRowState state;

  /// Sub-stages to display when this phase is active.
  final List<ImportSubStage> subStages;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main phase row
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              _buildIcon(colors),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        color: _textColor(colors),
                        fontWeight: state == PhaseRowState.active
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    // Show segmented progress bar for active phase with sub-stages
                    if (state == PhaseRowState.active && subStages.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: _buildSegmentedProgressBar(colors),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Show sub-stages for active phase
        if (state == PhaseRowState.active && subStages.isNotEmpty)
          _buildSubStagesList(colors),
      ],
    );
  }

  /// Segmented progress bar showing overall phase progress.
  Widget _buildSegmentedProgressBar(ThemeColors colors) {
    final completedCount = subStages.where((s) => s.isComplete).length;
    final activeStage = subStages.where((s) => s.isActive).firstOrNull;

    // Calculate progress: completed segments + partial progress of active segment
    var progress = completedCount / subStages.length;
    if (activeStage != null && activeStage.progress != null) {
      progress += activeStage.progress! / subStages.length;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: SizedBox(
        height: 4,
        child: LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: colors.surfaces.controlMuted,
          valueColor: AlwaysStoppedAnimation<Color>(colors.accents.primary),
        ),
      ),
    );
  }

  /// List of sub-stages with individual progress.
  Widget _buildSubStagesList(ThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, bottom: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final subStage in subStages) _buildSubStageRow(subStage, colors),
        ],
      ),
    );
  }

  Widget _buildSubStageRow(ImportSubStage subStage, ThemeColors colors) {
    // Skip pending stages that haven't started to reduce clutter
    if (!subStage.isActive && !subStage.isComplete) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildSubStageIcon(subStage, colors),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  subStage.label,
                  style: TextStyle(
                    fontSize: 12,
                    color: subStage.isActive
                        ? colors.content.textPrimary
                        : colors.content.textSecondary,
                    fontWeight: subStage.isActive
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                ),
              ),
              // Show count on the right if available
              if (subStage.isActive && subStage.hasGranularProgress)
                Text(
                  '${_formatNumber(subStage.current!)} / ${_formatNumber(subStage.total!)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.content.textTertiary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
            ],
          ),
          // Progress bar for active sub-stage - show whenever active
          if (subStage.isActive)
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: SizedBox(
                  height: 3,
                  child: LinearProgressIndicator(
                    // Use progress if available, otherwise indeterminate (null)
                    value: subStage.hasAnyProgress
                        ? (subStage.progress ?? 0.0).clamp(0.0, 1.0)
                        : null,
                    backgroundColor: colors.surfaces.controlMuted,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colors.accents.primary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubStageIcon(ImportSubStage subStage, ThemeColors colors) {
    const iconSize = 16.0;

    if (subStage.isComplete) {
      return const Icon(
        CupertinoIcons.checkmark_circle_fill,
        size: iconSize,
        color: Color(0xFF34C759),
      );
    }

    if (subStage.isActive) {
      return SizedBox(
        width: iconSize,
        height: iconSize,
        child: CupertinoActivityIndicator(
          radius: iconSize / 2 - 2,
          color: colors.accents.primary,
        ),
      );
    }

    return Icon(
      CupertinoIcons.circle,
      size: iconSize,
      color: colors.content.textTertiary,
    );
  }

  String _formatNumber(int value) {
    if (value < 1000) {
      return value.toString();
    }
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
