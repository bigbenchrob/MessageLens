import '../value_objects/db_import_stage.dart';

/// Immutable snapshot describing the current progress of a long-running
/// database import.
class DbImportProgress {
  const DbImportProgress({
    required this.stage,
    required this.overallProgress,
    required this.message,
    this.stageProgress,
    this.stageCurrent,
    this.stageTotal,
  });

  /// Current stage in the pipeline.
  final DbImportStage stage;

  /// Overall completion ratio (0.0-1.0).
  final double overallProgress;

  /// Human readable message describing the current work.
  final String message;

  /// Optional sub-progress within the stage (0.0-1.0).
  final double? stageProgress;

  /// Optional current item index for granular reporting.
  final int? stageCurrent;

  /// Optional total item count for granular reporting.
  final int? stageTotal;

  DbImportProgress copyWith({
    DbImportStage? stage,
    double? overallProgress,
    String? message,
    double? stageProgress,
    int? stageCurrent,
    int? stageTotal,
  }) {
    return DbImportProgress(
      stage: stage ?? this.stage,
      overallProgress: overallProgress ?? this.overallProgress,
      message: message ?? this.message,
      stageProgress: stageProgress ?? this.stageProgress,
      stageCurrent: stageCurrent ?? this.stageCurrent,
      stageTotal: stageTotal ?? this.stageTotal,
    );
  }
}
