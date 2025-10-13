import '../../../application/services/base_table_migrator.dart';
import '../migration_context_sqlite.dart';

class HandlesMigrator extends BaseTableMigrator {
  const HandlesMigrator();

  @override
  String get name => 'handles';

  @override
  List<String> get dependsOn => const [];

  static const _attachAlias = 'import_handles';

  @override
  Future<void> validatePrereqs(MigrationContext ctx) async {
    final importCount = await count(ctx.importDb, 'handles');
    ctx.log('[handles] import count = $importCount');
    await expectTrueOrThrow(
      importCount > 0,
      'HANDLES_NO_SOURCE_ROWS',
      'handles: import database returned zero rows',
    );
  }

  @override
  Future<void> copy(MigrationContext ctx) async {
    if (ctx.dryRun) {
      ctx.log('[handles] dry run – skipping copy');
      return;
    }

    final importSqlite = await ctx.importDb.database;
    final importPath = importSqlite.path;
    final escapedPath = importPath.replaceAll("'", "''");

    await ctx.workingDb.customStatement(
      "ATTACH DATABASE '$escapedPath' AS $_attachAlias",
    );

    try {
      await ctx.workingDb.customStatement('''
        INSERT OR REPLACE INTO handles (
          id,
          handle_id,
          normalized_identifier,
          service,
          is_ignored,
          is_valid,
          is_blacklisted,
          country,
          last_seen_utc,
          batch_id
        )
        SELECT
          h.id,
          h.raw_identifier,
          h.normalized_identifier,
          h.service,
          h.is_ignored,
          CASE WHEN h.is_ignored = 1 THEN 0 ELSE 1 END AS is_valid,
          h.is_ignored AS is_blacklisted,
          h.country,
          h.last_seen_utc,
          h.batch_id
        FROM $_attachAlias.handles h;
      ''');
    } finally {
      await ctx.workingDb.customStatement('DETACH DATABASE $_attachAlias');
    }
  }

  @override
  Future<void> postValidate(MigrationContext ctx) async {
    final src = await count(ctx.importDb, 'handles');
    final dst = await count(ctx.workingDb, 'handles');
    ctx.log('[handles] src=$src dst=$dst');
    await expectTrueOrThrow(
      dst == src,
      'HANDLES_ROW_MISMATCH',
      'handles: working has $dst rows but import has $src',
    );
  }
}
