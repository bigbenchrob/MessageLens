import '../../infrastructure/sqlite/import_context_sqlite.dart';

/// Contract that every table-specific importer must satisfy.
abstract class TableImporter {
  /// Unique identifier for the importer, typically the target table name.
  String get name;

  /// Names of other importers that must complete successfully first.
  List<String> get dependsOn;

  /// Pre-flight validation before any data movement occurs.
  Future<void> validatePrereqs(ImportContext ctx);

  /// Executes the primary import work (INSERT/SELECT, transforms, etc.).
  Future<void> copy(ImportContext ctx);

  /// Post-import validation and reconciliation.
  Future<void> postValidate(ImportContext ctx);
}
