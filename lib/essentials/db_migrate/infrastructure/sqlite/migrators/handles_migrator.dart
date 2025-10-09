import '../../../application/services/base_table_migrator.dart';
import '../migration_context_sqlite.dart';

class HandlesMigrator extends BaseTableMigrator {
  @override
  String get name => 'handles';
  @override
  List<String> get dependsOn => const [];

  @override
  Future<void> validatePrereqs(MigrationContext ctx) async {
    // Basic existence and non-empty source table check (optional)
    final importCount = await count(ctx.importDb, 'handles');
    ctx.log('[handles] import count = $importCount');
  }

  @override
  Future<void> copy(MigrationContext ctx) async {
    if (ctx.dryRun) {
      return;
    }
    // Idempotent copy: prefer ON CONFLICT for stable reruns.
    await ctx.workingDb.customStatement('''
      INSERT INTO handles (handle_id, address, service, /*...*/ )
      SELECT handle_id, address, service, /*...*/
      FROM main.import_handles_view  -- or importDb via ATTACH, see note below
      ON CONFLICT(handle_id) DO UPDATE SET
        address = excluded.address,
        service = excluded.service
        /* ... other mutable columns ... */;
    ''');
  }

  /// Note on FROM main.import_*_view: the cleanest lift-and-shift in SQLite is to
  ///
  ///   ATTACH DATABASE '/path/to/import.db' AS import;
  ///
  /// and then
  ///
  ///   SELECT ... FROM import.table.
  ///
  /// If you can’t attach from Dart, you can materialize the import data into
  /// a temporary staging schema in the working connection. Either way,
  /// keep all copy SQL explicit.

  @override
  Future<void> postValidate(MigrationContext ctx) async {
    // Optional: compare counts for sanity
    final src = await count(ctx.importDb, 'handles');
    final dst = await count(ctx.workingDb, 'handles');
    ctx.log('[handles] src=$src dst=$dst');
    await expectTrueOrThrow(
      dst >= src,
      'POST_VALIDATE_MISSING_ROWS',
      'handles: working has fewer rows ($dst) than import ($src)',
    );
  }
}
