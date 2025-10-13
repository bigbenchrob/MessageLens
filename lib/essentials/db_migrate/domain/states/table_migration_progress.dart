import '../value_objects/db_migration_stage.dart';

/// High-level phases each table migrator reports while running inside the
/// [MigrationOrchestrator].
enum TableMigrationPhase { validatePrereqs, copy, postValidate }

/// Status emitted for a [TableMigrationPhase].
enum TableMigrationStatus { started, succeeded, failed }

/// Event describing progress for an individual table migrator.
class TableMigrationProgressEvent {
  const TableMigrationProgressEvent({
    required this.tableName,
    required this.displayName,
    required this.phase,
    required this.status,
    this.message,
    this.stage,
  });

  /// Identifier of the migrator emitting the event (usually the table name).
  final String tableName;

  /// Human friendly display label for this table.
  final String displayName;

  final TableMigrationPhase phase;
  final TableMigrationStatus status;

  /// Optional descriptive message (typically only set for failures).
  final String? message;

  /// Optional overall migration stage that best represents this table phase.
  final DbMigrationStage? stage;
}

typedef TableMigrationProgressCallback =
    void Function(TableMigrationProgressEvent event);
