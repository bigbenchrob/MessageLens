import '../value_objects/db_import_stage.dart';

/// High-level phases each table importer reports while running inside the
/// [ImportOrchestrator].
enum TableImportPhase { validatePrereqs, copy, postValidate }

/// Status emitted for a [TableImportPhase].
enum TableImportStatus { started, succeeded, failed }

/// Event describing progress for an individual table importer.
class TableImportProgressEvent {
  const TableImportProgressEvent({
    required this.importerName,
    required this.displayName,
    required this.phase,
    required this.status,
    this.message,
    this.stage,
  });

  final String importerName;
  final String displayName;
  final TableImportPhase phase;
  final TableImportStatus status;
  final String? message;
  final DbImportStage? stage;
}

typedef TableImportProgressCallback =
    void Function(TableImportProgressEvent event);
