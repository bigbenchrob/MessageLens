import 'package:freezed_annotation/freezed_annotation.dart';
import './migration_exception.dart';

part 'migration_failure.freezed.dart';

@freezed
sealed class MigrationFailure with _$MigrationFailure {
  const factory MigrationFailure.foreignKeyViolation({
    required String table,
    required String details,
  }) = _ForeignKeyViolation;

  const factory MigrationFailure.validation({
    required String table,
    required String details,
  }) = _Validation;

  const factory MigrationFailure.database({required String message}) =
      _Database;

  const factory MigrationFailure.unknown({required String message}) = _Unknown;

  // Helper to translate infra exceptions → domain failures
  factory MigrationFailure.fromException(MigrationException e) {
    switch (e.code) {
      case 'FK_VIOLATION':
        return MigrationFailure.foreignKeyViolation(
          table: e.table ?? 'unknown',
          details: e.message,
        );
      case 'VALIDATION_ERROR':
        return MigrationFailure.validation(
          table: e.table ?? 'unknown',
          details: e.message,
        );
      case 'DB_ERROR':
        return MigrationFailure.database(message: e.message);
      default:
        return MigrationFailure.unknown(message: e.toString());
    }
  }

  // Optional: a user-friendly string for status boxes
  String toUserString() => when(
    foreignKeyViolation: (table, details) =>
        'Foreign key problem in "$table": $details',
    validation: (table, details) => 'Validation failed in "$table": $details',
    database: (message) => 'Database error: $message',
    unknown: (message) => 'Unexpected error: $message',
  );
}
