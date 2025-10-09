import '../../infrastructure/sqlite/migration_context_sqlite.dart';

/// What every table-specific migrator must implement.
abstract class TableMigrator {
  String get name; // e.g. "handles", "chats", "chat_to_handle"
  /// Names of other migrators that must finish successfully first.
  List<String> get dependsOn; // e.g. ["handles", "chats"] for join table

  /// Pre-copy checks: existence, counts, FK prerequisites (in source),
  /// and—importantly—presence of referenced parents already in WORKING if needed.
  Future<void> validatePrereqs(MigrationContext ctx);

  /// The actual lift-and-shift (usually INSERT…SELECT).
  /// Should be idempotent (e.g., use INSERT OR REPLACE / ON CONFLICT DO NOTHING).
  Future<void> copy(MigrationContext ctx);

  /// Post-copy validation: FK sanity, counts, and diffs.
  Future<void> postValidate(MigrationContext ctx);
}
