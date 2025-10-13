import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../db_migrate/domain/states/table_migration_progress.dart';
import '../view_model/db_import_control_provider.dart';

class DbImportProgressPane extends StatelessWidget {
  const DbImportProgressPane({
    super.key,
    required this.controlState,
    required this.mode,
  });

  final DbImportControlState controlState;
  final DbImportMode mode;

  @override
  Widget build(BuildContext context) {
    final isImport = mode == DbImportMode.import;
    return _buildProgressSection(controlState, isImport: isImport);
  }

  Widget _buildProgressSection(
    DbImportControlState state, {
    required bool isImport,
  }) {
    final stageDurations = <String, Duration?>{
      for (final stage in state.stages) stage.name: stage.duration,
    };
    final aggregateDuration = _aggregateDuration(state.stages);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${isImport ? 'Import' : 'Migration'} Progress',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: state.progress,
            backgroundColor: const Color(0xFFE0E0E0),
            valueColor: AlwaysStoppedAnimation<Color>(
              isImport ? const Color(0xFF4CAF50) : const Color(0xFF2196F3),
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(
            state.statusMessage ?? 'Preparing...',
            style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
          ),
          const SizedBox(height: 16),
          if (aggregateDuration != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: Color(0xFF2E7D32),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Total elapsed time: ${_formatDurationShort(aggregateDuration)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Expanded(
            child: state.stages.isEmpty
                ? Center(
                    child: Text(
                      isImport
                          ? 'Click "Start Import" to begin'
                          : 'Click "Start Migration" to begin',
                      style: const TextStyle(color: Color(0xFF999999)),
                    ),
                  )
                : ListView(
                    children: [
                      ...List<Widget>.generate(state.stages.length, (index) {
                        final stage = state.stages[index];
                        final duration = stageDurations[stage.name];
                        return Padding(
                          padding: EdgeInsets.only(top: index == 0 ? 0 : 8),
                          child: _buildStageItem(stage, duration: duration),
                        );
                      }),
                      if (state.tableProgress.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _TableProgressSection(tables: state.tableProgress),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageItem(UiStageProgress stage, {Duration? duration}) {
    Color iconColor;
    IconData icon;
    var statusText = stage.displayName;

    if (stage.isComplete) {
      iconColor = const Color(0xFF4CAF50);
      icon = Icons.check_circle;
    } else if (stage.isActive) {
      iconColor = const Color(0xFF2196F3);
      icon = Icons.radio_button_checked;
      if (stage.current != null && stage.total != null) {
        statusText += ' (${stage.current}/${stage.total})';
      }
    } else {
      iconColor = const Color(0xFFCCCCCC);
      icon = Icons.radio_button_unchecked;
    }

    Color? accentForStage(String name) {
      if (name == 'extractingRichContent') {
        return const Color(0xFF8E24AA);
      }
      if (name == 'importingMessages') {
        return const Color(0xFF00897B);
      }
      if (name == 'migratingMessages') {
        return const Color(0xFF1976D2);
      }
      return null;
    }

    final accent = accentForStage(stage.name);

    final row = Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 13,
                  color: stage.isActive || stage.isComplete
                      ? const Color(0xFF333333)
                      : const Color(0xFF999999),
                  fontWeight: stage.isActive
                      ? FontWeight.w500
                      : FontWeight.normal,
                ),
              ),
              if ((stage.isActive && stage.progress != null) ||
                  (stage.isComplete && stage.progress != null)) ...[
                const SizedBox(height: 4),
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
            ],
          ),
        ),
        if (stage.isComplete && duration != null)
          Text(
            _formatDurationShort(duration),
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF555555),
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
      ],
    );

    if (accent != null && stage.isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border(
            left: BorderSide(color: accent.withValues(alpha: 0.9), width: 3),
          ),
        ),
        child: row,
      );
    }

    return row;
  }

  Duration? _aggregateDuration(List<UiStageProgress> stages) {
    if (stages.isEmpty || stages.every((stage) => !stage.isComplete)) {
      return null;
    }
    if (stages.any((stage) => !stage.isComplete || stage.duration == null)) {
      return null;
    }

    return stages.fold<Duration>(
      Duration.zero,
      (accumulator, stage) => accumulator + stage.duration!,
    );
  }
}

String _formatDurationShort(Duration duration) {
  if (duration.inMilliseconds < 1000) {
    return '${duration.inMilliseconds}ms';
  }
  if (duration.inSeconds < 60) {
    final seconds = duration.inMilliseconds / 1000.0;
    return '${seconds.toStringAsFixed(seconds < 10 ? 2 : 1)}s';
  }
  final minutes = duration.inMinutes;
  final remainingSeconds = duration.inSeconds - minutes * 60;
  return '${minutes}m ${remainingSeconds}s';
}

class _TableProgressSection extends StatelessWidget {
  const _TableProgressSection({required this.tables});

  final List<UiTableMigrationProgress> tables;

  @override
  Widget build(BuildContext context) {
    if (tables.isEmpty) {
      return const SizedBox.shrink();
    }

    final sorted = List<UiTableMigrationProgress>.of(tables)
      ..sort((a, b) => a.sortIndex.compareTo(b.sortIndex));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Table progress',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        for (var index = 0; index < sorted.length; index++) ...[
          _TableProgressCard(progress: sorted[index]),
          if (index != sorted.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _TableProgressCard extends StatelessWidget {
  const _TableProgressCard({required this.progress});

  final UiTableMigrationProgress progress;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsForOverallStatus(progress.overallStatus);
    final summary = _overallStatusSummary(progress);
    final failureMessage = progress.failureMessage;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _statusIcon(progress.overallStatus),
                size: 16,
                color: colors.accent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  progress.displayName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.accent,
                  ),
                ),
              ),
              Text(
                summary,
                style: TextStyle(
                  fontSize: 11,
                  color: colors.accent,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              for (final phase in TableMigrationPhase.values) ...[
                _TablePhaseRow(
                  phase: phase,
                  status: progress.statusForPhase(phase),
                ),
                if (phase != TableMigrationPhase.values.last)
                  const SizedBox(height: 6),
              ],
            ],
          ),
          if (failureMessage != null && failureMessage.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              failureMessage,
              style: const TextStyle(fontSize: 11, color: Color(0xFFC62828)),
            ),
          ],
        ],
      ),
    );
  }
}

class _TablePhaseRow extends StatelessWidget {
  const _TablePhaseRow({required this.phase, required this.status});

  final TableMigrationPhase phase;
  final UiTableMigrationPhaseStatus? status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status?.status);
    final icon = _statusIcon(status?.status);
    final statusLabel = _phaseStatusLabel(status);
    final message = status?.status == TableMigrationStatus.failed
        ? status?.message
        : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _phaseLabel(phase),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF424242),
                ),
              ),
              Text(statusLabel, style: TextStyle(fontSize: 11, color: color)),
              if (message != null && message.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFC62828),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TableProgressColors {
  const _TableProgressColors({
    required this.background,
    required this.border,
    required this.accent,
  });

  final Color background;
  final Color border;
  final Color accent;
}

_TableProgressColors _colorsForOverallStatus(TableMigrationStatus status) {
  switch (status) {
    case TableMigrationStatus.succeeded:
      return _TableProgressColors(
        background: const Color(0xFFE8F5E9),
        border: const Color(0xFF2E7D32).withValues(alpha: 0.4),
        accent: const Color(0xFF2E7D32),
      );
    case TableMigrationStatus.failed:
      return _TableProgressColors(
        background: const Color(0xFFFFEBEE),
        border: const Color(0xFFC62828).withValues(alpha: 0.4),
        accent: const Color(0xFFC62828),
      );
    case TableMigrationStatus.started:
      return _TableProgressColors(
        background: const Color(0xFFE3F2FD),
        border: const Color(0xFF1565C0).withValues(alpha: 0.4),
        accent: const Color(0xFF1565C0),
      );
  }
}

String _overallStatusSummary(UiTableMigrationProgress progress) {
  switch (progress.overallStatus) {
    case TableMigrationStatus.started:
      return 'In progress';
    case TableMigrationStatus.succeeded:
      final duration = progress.duration;
      if (duration != null) {
        return 'Completed · ${_formatDurationShort(duration)}';
      }
      return 'Completed';
    case TableMigrationStatus.failed:
      return 'Failed';
  }
}

String _phaseLabel(TableMigrationPhase phase) {
  switch (phase) {
    case TableMigrationPhase.validatePrereqs:
      return 'Validate prerequisites';
    case TableMigrationPhase.copy:
      return 'Copy data';
    case TableMigrationPhase.postValidate:
      return 'Post-validate results';
  }
}

String _phaseStatusLabel(UiTableMigrationPhaseStatus? status) {
  if (status == null) {
    return 'Pending';
  }
  switch (status.status) {
    case TableMigrationStatus.started:
      return 'In progress';
    case TableMigrationStatus.succeeded:
      final duration = status.duration;
      if (duration != null) {
        return 'Completed · ${_formatDurationShort(duration)}';
      }
      return 'Completed';
    case TableMigrationStatus.failed:
      return 'Failed';
  }
}

Color _statusColor(TableMigrationStatus? status) {
  switch (status) {
    case TableMigrationStatus.succeeded:
      return const Color(0xFF2E7D32);
    case TableMigrationStatus.failed:
      return const Color(0xFFC62828);
    case TableMigrationStatus.started:
      return const Color(0xFF1565C0);
    case null:
      return const Color(0xFF9E9E9E);
  }
}

IconData _statusIcon(TableMigrationStatus? status) {
  switch (status) {
    case TableMigrationStatus.succeeded:
      return Icons.check_circle;
    case TableMigrationStatus.failed:
      return Icons.error;
    case TableMigrationStatus.started:
      return Icons.radio_button_checked;
    case null:
      return Icons.radio_button_unchecked;
  }
}
