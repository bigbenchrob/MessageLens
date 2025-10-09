/// Infrastructure-level exception used to signal fatal or recoverable
/// problems encountered during table or data migration.
///
/// These should *not* be shown directly to end users.
/// The application layer is responsible for catching them and
/// converting them into domain Failures or a user-friendly MigrationReport.
class MigrationException implements Exception {
  /// Short, machine-readable code suitable for mapping to a Failure type.
  final String code;

  /// Human-readable explanation for logs or debugging.
  final String message;

  /// Optional: which migrator or table raised this.
  final String? table;

  /// Optional: a more detailed context — e.g. offending ID, SQL, counts.
  final Map<String, Object?>? details;

  /// Optional: a lower-level cause (e.g. SQLiteException).
  final Object? cause;

  /// Stack trace for debugging (captured automatically when thrown).
  final StackTrace? stackTrace;

  const MigrationException({
    required this.code,
    required this.message,
    this.table,
    this.details,
    this.cause,
    this.stackTrace,
  });

  @override
  String toString() {
    final buf = StringBuffer('MigrationException[$code]');
    if (table != null) {
      buf.write(' on table "$table"');
    }
    buf.write(': $message');
    if (details != null && details!.isNotEmpty) {
      buf.write('\n  Details: ${_formatDetails(details!)}');
    }
    if (cause != null) {
      buf.write('\n  Cause: $cause');
    }
    return buf.toString();
  }

  static String _formatDetails(Map<String, Object?> d) =>
      d.entries.map((e) => '${e.key}=${e.value}').join(', ');

  /// Helper for creating from another exception.
  factory MigrationException.from(
    Object error,
    StackTrace stack, {
    String? code,
    String? table,
  }) {
    if (error is MigrationException) {
      return error;
    }
    return MigrationException(
      code: code ?? 'UNKNOWN',
      message: error.toString(),
      table: table,
      cause: error,
      stackTrace: stack,
    );
  }
}
