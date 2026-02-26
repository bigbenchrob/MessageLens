import '../../domain/base_table_migrator.dart';
import '../../infrastructure/sqlite/migration_context_sqlite.dart';

class ChatsMigrator extends BaseTableMigrator {
  const ChatsMigrator();

  static const _attachAlias = 'import_chats';

  @override
  String get name => 'chats';

  @override
  List<String> get dependsOn => const ['handles'];

  @override
  Future<void> validatePrereqs(MigrationContext ctx) async {
    final importCount = await _countImportRowsWithGuid(ctx);
    ctx.log('[chats] import count = $importCount');
    await expectTrueOrThrow(
      ok: importCount > 0,
      errorCode: 'CHATS_NO_SOURCE_ROWS',
      message: 'chats: import database returned zero rows',
    );
  }

  @override
  Future<void> copy(MigrationContext ctx) async {
    if (ctx.dryRun) {
      ctx.log('[chats] dry run – skipping copy');
      return;
    }

    final importSqlite = await ctx.importDb.database;
    final importPath = importSqlite.path.replaceAll("'", "''");

    await ctx.workingDb.customStatement(
      "ATTACH DATABASE '$importPath' AS $_attachAlias",
    );

    try {
      // Use INSERT OR IGNORE in incremental mode to avoid expensive REPLACE
      // on existing rows with foreign key constraints (messages reference chats)
      final insertClause = ctx.incrementalMode
          ? 'INSERT OR IGNORE'
          : 'INSERT OR REPLACE';

      await ctx.workingDb.customStatement('''
        $insertClause INTO chats (
          id,
          guid,
          service,
          is_group,
          created_at_utc,
          updated_at_utc,
          is_ignored
        )
        SELECT
          c.id,
          c.guid,
          COALESCE(c.service, 'Unknown') AS service,
          c.is_group,
          c.created_at_utc,
          c.updated_at_utc,
          c.is_ignored
        FROM $_attachAlias.chats c
        WHERE c.guid IS NOT NULL AND LENGTH(TRIM(c.guid)) > 0;
      ''');
    } finally {
      await ctx.workingDb.customStatement('DETACH DATABASE $_attachAlias');
    }
  }

  @override
  Future<void> postValidate(MigrationContext ctx) async {
    final src = await _countImportRowsWithGuid(ctx);
    final dst = await count(ctx.workingDb, 'chats');
    ctx.log('[chats] src=$src dst=$dst');

    if (ctx.incrementalMode) {
      // In incremental mode, dst should be >= src (existing + new rows)
      await expectTrueOrThrow(
        ok: dst >= src,
        errorCode: 'CHATS_INCREMENTAL_UNDERCOUNT',
        message:
            'chats: working has $dst rows but import has $src (expected dst >= src)',
      );
    } else {
      // In full mode, counts must match exactly
      await expectTrueOrThrow(
        ok: dst == src,
        errorCode: 'CHATS_ROW_MISMATCH',
        message: 'chats: working has $dst rows but import has $src',
      );
    }
  }

  Future<int> _countImportRowsWithGuid(MigrationContext ctx) async {
    final importSqlite = await ctx.importDb.database;
    final rows = await importSqlite.rawQuery(
      'SELECT COUNT(*) AS c FROM chats '
      'WHERE guid IS NOT NULL AND LENGTH(TRIM(guid)) > 0',
    );
    final value = rows.isEmpty ? null : rows.first['c'];
    if (value == null) {
      return 0;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.parse(value.toString());
  }
}
