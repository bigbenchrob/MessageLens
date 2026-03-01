/// High-level phases each table migrator reports while running inside the
/// [MigrationOrchestrator].
enum TableMigrationPhase { validatePrereqs, copy, postValidate }

/// Status emitted for a [TableMigrationPhase].
enum TableMigrationStatus {
  /// Phase has started but not yet emitted row-level progress.
  started,

  /// Phase is in progress with row-level updates available.
  inProgress,

  /// Phase completed successfully.
  succeeded,

  /// Phase failed with an error.
  failed,
}

/// Event describing progress for an individual table migrator.
class TableMigrationProgressEvent {
  const TableMigrationProgressEvent({
    required this.tableName,
    required this.displayName,
    required this.phase,
    required this.status,
    this.message,
    this.rowsProcessed,
    this.totalRows,
    this.currentItem,
  });

  /// Identifier of the migrator emitting the event (usually the table name).
  final String tableName;

  /// Human friendly display label for this table.
  final String displayName;

  final TableMigrationPhase phase;
  final TableMigrationStatus status;

  /// Optional descriptive message (typically only set for failures).
  final String? message;

  /// Number of rows processed so far (only set when status is [inProgress]).
  final int? rowsProcessed;

  /// Total number of rows to process (only set when status is [inProgress]).
  final int? totalRows;

  /// Description of the current item being processed.
  final String? currentItem;

  /// Progress as a fraction 0.0 to 1.0, or null if not determinable.
  double? get progress {
    if (rowsProcessed == null || totalRows == null || totalRows == 0) {
      return null;
    }
    return rowsProcessed! / totalRows!;
  }
}

typedef TableMigrationProgressCallback =
    void Function(TableMigrationProgressEvent event);
