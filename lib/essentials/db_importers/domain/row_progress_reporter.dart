/// Callback signature for row-level progress during copy operations.
typedef RowProgressCallback =
    void Function({
      required int processed,
      required int total,
      String? currentItem,
    });

/// Mixin providing row-level progress reporting during copy operations.
///
/// Importers that wish to report row-level progress should mix this in and
/// call [reportRowProgress] periodically during their [copy] method.
///
/// The orchestrator sets up the callback via [setProgressCallback] before
/// invoking the copy phase.
mixin RowProgressReporter {
  RowProgressCallback? _progressCallback;

  /// Sets the callback that receives row-level progress updates.
  /// Called by the orchestrator before running the copy phase.
  void setProgressCallback(RowProgressCallback? callback) {
    _progressCallback = callback;
  }

  /// Clears the progress callback. Called by the orchestrator after
  /// the copy phase completes.
  void clearProgressCallback() {
    _progressCallback = null;
  }

  /// Reports row-level progress to the orchestrator.
  ///
  /// Call this periodically during [copy] to emit progress updates.
  /// The [processed] count should be the number of rows processed so far,
  /// and [total] should be the total number of rows to process.
  ///
  /// Optionally provide [currentItem] to describe the current row being
  /// processed (e.g., a message GUID or handle identifier).
  void reportRowProgress({
    required int processed,
    required int total,
    String? currentItem,
  }) {
    _progressCallback?.call(
      processed: processed,
      total: total,
      currentItem: currentItem,
    );
  }
}
