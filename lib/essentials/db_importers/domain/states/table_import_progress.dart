/// High-level phases each table importer reports while running inside the
/// [ImportOrchestrator].
enum TableImportPhase { validatePrereqs, copy, postValidate }

/// Status emitted for a [TableImportPhase].
enum TableImportStatus {
  /// Phase has started but not yet emitted row-level progress.
  started,

  /// Phase is in progress with row-level updates available.
  inProgress,

  /// Phase completed successfully.
  succeeded,

  /// Phase failed with an error.
  failed,
}

/// Event describing progress for an individual table importer.
class TableImportProgressEvent {
  const TableImportProgressEvent({
    required this.importerName,
    required this.displayName,
    required this.phase,
    required this.status,
    this.message,
    this.rowsProcessed,
    this.totalRows,
    this.currentItem,
  });

  final String importerName;
  final String displayName;
  final TableImportPhase phase;
  final TableImportStatus status;
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

typedef TableImportProgressCallback =
    void Function(TableImportProgressEvent event);
