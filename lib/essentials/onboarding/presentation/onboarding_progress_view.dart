import 'package:flutter/material.dart';

import '../../../config/theme/colors/theme_colors.dart';
import '../../../config/theme/theme_typography.dart';
import '../../db_importers/presentation/view_model/db_import_control_provider.dart';

/// Displays the list of import/migration stages with live progress.
///
/// Each stage shows a status icon (pending / active / complete),
/// display name, row count when active, and an inline progress bar.
/// This mirrors the dev pane's stage rendering using the same
/// [UiStageProgress] data.
class OnboardingProgressView extends StatelessWidget {
  const OnboardingProgressView({
    required this.stages,
    required this.colors,
    required this.typography,
    super.key,
  });

  final List<UiStageProgress> stages;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    if (stages.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.accents.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Preparing…',
                style: typography.caption.copyWith(
                  color: colors.content.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: stages.length,
      separatorBuilder: (_, __) => const SizedBox(height: 2),
      itemBuilder: (context, index) {
        final stage = stages[index];
        return _StageRow(stage: stage, colors: colors, typography: typography);
      },
    );
  }
}

class _StageRow extends StatelessWidget {
  const _StageRow({
    required this.stage,
    required this.colors,
    required this.typography,
  });

  final UiStageProgress stage;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color iconColor) = _iconForStage();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        stage.displayName,
                        style: typography.body.copyWith(
                          color: stage.isActive
                              ? colors.content.textPrimary
                              : colors.content.textSecondary,
                        ),
                      ),
                    ),
                    if (stage.isActive &&
                        stage.current != null &&
                        stage.total != null)
                      Text(
                        '${stage.current}/${stage.total}',
                        style: typography.caption.copyWith(
                          color: colors.content.textTertiary,
                        ),
                      ),
                    if (stage.isComplete && stage.duration != null)
                      Text(
                        _formatDuration(stage.duration!),
                        style: typography.caption.copyWith(
                          color: colors.content.textTertiary,
                        ),
                      ),
                  ],
                ),
                if (stage.isActive && stage.progress != null) ...[
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: stage.progress,
                      backgroundColor: colors.lines.borderSubtle,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colors.accents.primary,
                      ),
                      minHeight: 3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  (IconData, Color) _iconForStage() {
    if (stage.isComplete) {
      return (Icons.check_circle, const Color(0xFF4CAF50));
    }
    if (stage.isActive) {
      return (Icons.radio_button_checked, colors.accents.primary);
    }
    return (Icons.radio_button_unchecked, colors.content.textTertiary);
  }

  String _formatDuration(Duration d) {
    if (d.inMinutes > 0) {
      final secs = d.inSeconds % 60;
      return '${d.inMinutes}m ${secs}s';
    }
    if (d.inSeconds > 0) {
      return '${d.inSeconds}s';
    }
    return '${d.inMilliseconds}ms';
  }
}
