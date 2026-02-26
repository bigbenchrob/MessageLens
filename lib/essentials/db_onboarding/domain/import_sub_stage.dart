/// Represents progress for a single import sub-stage in the onboarding UI.
///
/// This is a simplified projection of the internal import pipeline stages,
/// designed for rendering in the onboarding stepper.
class ImportSubStage {
  const ImportSubStage({
    required this.key,
    required this.label,
    required this.sortIndex,
    this.isActive = false,
    this.isComplete = false,
    this.progress,
    this.current,
    this.total,
  });

  /// Stable identifier matching [DbImportStage.key].
  final String key;

  /// Human-readable label for display.
  final String label;

  /// Sort order in the list.
  final int sortIndex;

  /// Whether this sub-stage is currently running.
  final bool isActive;

  /// Whether this sub-stage has completed.
  final bool isComplete;

  /// Progress within the sub-stage (0.0 to 1.0).
  final double? progress;

  /// Current item count (e.g., rows imported).
  final int? current;

  /// Total item count (e.g., total rows to import).
  final int? total;

  /// Whether this sub-stage has granular progress (current/total counts).
  bool get hasGranularProgress =>
      current != null && total != null && total! > 0;

  /// Whether this sub-stage has any progress to display (counts or percentage).
  bool get hasAnyProgress => hasGranularProgress || progress != null;

  ImportSubStage copyWith({
    bool? isActive,
    bool? isComplete,
    double? progress,
    int? current,
    int? total,
  }) {
    return ImportSubStage(
      key: key,
      label: label,
      sortIndex: sortIndex,
      isActive: isActive ?? this.isActive,
      isComplete: isComplete ?? this.isComplete,
      progress: progress ?? this.progress,
      current: current ?? this.current,
      total: total ?? this.total,
    );
  }
}
