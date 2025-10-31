import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../db_migrate/domain/entities/db_migration_result.dart';
import '../../domain/entities/db_import_result.dart';
import '../view_model/db_import_control_provider.dart';

class DbImportDetailsPane extends StatelessWidget {
  const DbImportDetailsPane({
    super.key,
    required this.controlState,
    required this.mode,
  });

  final DbImportControlState controlState;
  final DbImportMode mode;

  @override
  Widget build(BuildContext context) {
    return _buildDetailsSection(context, controlState);
  }

  Widget _buildDetailsSection(
    BuildContext context,
    DbImportControlState state,
  ) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Stage Summary',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: state.stages.isEmpty
                ? const Center(
                    child: Text(
                      'Stage metrics will appear here once progress begins.',
                      style: TextStyle(color: Color(0xFF777777)),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.separated(
                    itemCount: state.stages.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final stage = state.stages[index];
                      return _buildStageSummaryTile(stage);
                    },
                  ),
          ),
          const SizedBox(height: 12),
          _buildResultSummary(context),
        ],
      ),
    );
  }

  Widget _buildStageSummaryTile(UiStageProgress stage) {
    final duration = stage.duration;
    final String durationText;
    if (duration != null) {
      durationText = _formatDuration(duration);
    } else if (stage.isComplete) {
      durationText = 'Complete';
    } else {
      durationText = '…';
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  stage.isComplete
                      ? Icons.check_circle
                      : stage.isActive
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 14,
                  color: stage.isComplete
                      ? const Color(0xFF4CAF50)
                      : stage.isActive
                      ? const Color(0xFF2196F3)
                      : const Color(0xFFBDBDBD),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    stage.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: stage.isActive
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: stage.isActive || stage.isComplete
                          ? const Color(0xFF333333)
                          : const Color(0xFF777777),
                    ),
                  ),
                ),
                Text(
                  durationText,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF555555),
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            if (stage.progress != null) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: stage.progress,
                backgroundColor: const Color(0xFFE0E0E0),
                valueColor: AlwaysStoppedAnimation<Color>(
                  stage.isComplete
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFF2196F3),
                ),
              ),
            ],
            if (stage.current != null && stage.total != null) ...[
              const SizedBox(height: 6),
              Text(
                '${stage.current}/${stage.total}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF555555),
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultSummary(BuildContext context) {
    if (mode == DbImportMode.import) {
      return _buildImportSummary(context, controlState.lastImportResult);
    }
    return _buildMigrationSummary(context, controlState.lastMigrationResult);
  }

  Widget _buildImportSummary(BuildContext context, DbImportResult? result) {
    final theme = Theme.of(context);

    if (result == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEDEDED),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFD5D5D5)),
        ),
        child: const Text(
          'Import metrics will appear after a completed run.',
          style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
        ),
      );
    }

    final success = result.success;
    final backgroundColor = success
        ? const Color(0xFFD4EDDA)
        : const Color(0xFFFFF3CD);
    final borderColor = success
        ? const Color(0xFF28A745)
        : const Color(0xFFFFC107);
    final textColor = success
        ? const Color(0xFF155724)
        : const Color(0xFF856404);

    final metrics = <String, Object?>{
      'Handles': result.handlesImported,
      'Chats': result.chatsImported,
      'Participants': result.participantsImported,
      'Messages': result.messagesImported,
      'Attachments': result.attachmentsImported,
      'Message Attachments': result.messageAttachmentsImported,
      'Contacts': result.contactsImported,
      'Contact Channels': result.contactChannelsImported,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            success
                ? 'Last run completed for batch ${result.batchId}'
                : 'Last run failed for batch ${result.batchId}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: metrics.entries
                .map(
                  (entry) => _MetricChip(
                    label: entry.key,
                    value: '${entry.value}',
                    color: textColor,
                  ),
                )
                .toList(growable: false),
          ),
          if (result.error != null) ...[
            const SizedBox(height: 8),
            Text(
              result.error!,
              style: theme.textTheme.bodySmall?.copyWith(color: textColor),
            ),
          ],
          if (result.warnings.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Warnings:',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            for (final warning in result.warnings)
              Text(
                '• $warning',
                style: theme.textTheme.bodySmall?.copyWith(color: textColor),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildMigrationSummary(
    BuildContext context,
    DbMigrationResult? result,
  ) {
    final theme = Theme.of(context);

    if (result == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEDEDED),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFD5D5D5)),
        ),
        child: const Text(
          'Migration metrics will appear after a completed run.',
          style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
        ),
      );
    }

    final success = result.success;
    final backgroundColor = success
        ? const Color(0xFFD4EDDA)
        : const Color(0xFFFFF3CD);
    final borderColor = success
        ? const Color(0xFF28A745)
        : const Color(0xFFFFC107);
    final textColor = success
        ? const Color(0xFF155724)
        : const Color(0xFF856404);

    final metrics = <String, Object?>{
      'Identities': result.identitiesProjected,
      'Identity Handle Links': result.identityHandleLinksProjected,
      'Chats': result.chatsProjected,
      'Participants': result.participantsProjected,
      'Messages': result.messagesProjected,
      'Attachments': result.attachmentsProjected,
      'Reactions': result.reactionsProjected,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            success
                ? 'Last run completed for batch ${result.batchId}'
                : 'Last run failed for batch ${result.batchId}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: metrics.entries
                .map(
                  (entry) => _MetricChip(
                    label: entry.key,
                    value: '${entry.value}',
                    color: textColor,
                  ),
                )
                .toList(growable: false),
          ),
          if (result.error != null) ...[
            const SizedBox(height: 8),
            Text(
              result.error!,
              style: theme.textTheme.bodySmall?.copyWith(color: textColor),
            ),
          ],
          if (result.warnings.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Warnings:',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            for (final warning in result.warnings)
              Text(
                '• $warning',
                style: theme.textTheme.bodySmall?.copyWith(color: textColor),
              ),
          ],
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inMilliseconds < 1000) {
      return '${duration.inMilliseconds}ms';
    }
    final seconds = duration.inMilliseconds / 1000.0;
    if (seconds < 60) {
      return '${seconds.toStringAsFixed(seconds < 10 ? 2 : 1)}s';
    }
    final minutes = duration.inMinutes;
    final remaining = seconds - minutes * 60;
    return '${minutes}m ${remaining.toStringAsFixed(1)}s';
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
