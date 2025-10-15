import '../../../application/services/base_table_migrator.dart';
import '../migration_context_sqlite.dart';

class ParticipantsMigrator extends BaseTableMigrator {
  const ParticipantsMigrator();

  static const _attachAlias = 'import_contacts';

  @override
  String get name => 'participants';

  @override
  List<String> get dependsOn => const ['handles'];

  @override
  Future<void> validatePrereqs(MigrationContext ctx) async {
    final importCount = await _countImportContacts(ctx);
    ctx.log('[participants] import count = $importCount');
    if (importCount == 0) {
      ctx.log(
        '[participants] no non-ignored contacts found in import database',
      );
      return;
    }

    final handlesProjected = await count(ctx.workingDb, 'handles');
    await expectTrueOrThrow(
      ok: handlesProjected > 0,
      errorCode: 'PARTICIPANTS_REQUIRES_HANDLES',
      message:
          'participants: import has $importCount rows but working database has no handles',
    );
  }

  @override
  Future<void> copy(MigrationContext ctx) async {
    if (ctx.dryRun) {
      ctx.log('[participants] dry run – skipping copy');
      return;
    }

    final inserted = await _withAttachedImport(ctx, () async {
      await ctx.workingDb.customStatement('''
        INSERT OR REPLACE INTO participants (
          id,
          original_name,
          display_name,
          short_name,
          avatar_ref,
          given_name,
          family_name,
          organization,
          is_organization,
          created_at_utc,
          updated_at_utc,
          source_record_id
        )
        SELECT
          c.Z_PK AS id,
          COALESCE(NULLIF(TRIM(c.display_name), ''), 'Unknown Contact') AS original_name,
          COALESCE(NULLIF(TRIM(c.display_name), ''), 'Unknown Contact') AS display_name,
          COALESCE(
            NULLIF(TRIM(c.short_name), ''),
            COALESCE(NULLIF(TRIM(c.display_name), ''), 'Unknown Contact')
          ) AS short_name,
          NULL AS avatar_ref,
          NULLIF(TRIM(c.first_name), '') AS given_name,
          NULLIF(TRIM(c.last_name), '') AS family_name,
          NULLIF(TRIM(c.organization), '') AS organization,
          CASE
            WHEN NULLIF(TRIM(c.organization), '') IS NOT NULL
              AND NULLIF(TRIM(c.first_name), '') IS NULL
            THEN 1
            ELSE 0
          END AS is_organization,
          c.created_at_utc,
          NULL AS updated_at_utc,
          c.id AS source_record_id
        FROM $_attachAlias.contacts c
        WHERE c.is_ignored = 0 AND c.Z_PK IS NOT NULL;
      ''');

      final rows = await ctx.workingDb
          .customSelect('SELECT changes() AS c')
          .get();
      return _extractCount(rows, 'c');
    });

    ctx.log('[participants] inserted $inserted rows');
  }

  @override
  Future<void> postValidate(MigrationContext ctx) async {
    final expected = await _countImportContacts(ctx);
    final projected = await count(ctx.workingDb, 'participants');
    ctx.log('[participants] expected=$expected projected=$projected');

    if (expected == 0) {
      await expectTrueOrThrow(
        ok: projected == 0,
        errorCode: 'PARTICIPANTS_UNEXPECTED_ROWS',
        message:
            'participants: working has $projected rows but import had none',
      );
      return;
    }

    await expectTrueOrThrow(
      ok: projected == expected,
      errorCode: 'PARTICIPANTS_ROW_MISMATCH',
      message:
          'participants: working has $projected rows but expected $expected',
    );
  }

  Future<int> _countImportContacts(MigrationContext ctx) async {
    final importSqlite = await ctx.importDb.database;
    final rows = await importSqlite.rawQuery(
      'SELECT COUNT(*) AS c FROM contacts WHERE is_ignored = 0 AND Z_PK IS NOT NULL',
    );
    if (rows.isEmpty) {
      return 0;
    }
    return _coerceToInt(rows.first['c']);
  }

  Future<T> _withAttachedImport<T>(
    MigrationContext ctx,
    Future<T> Function() run,
  ) async {
    final importSqlite = await ctx.importDb.database;
    final escapedPath = importSqlite.path.replaceAll("'", "''");
    await ctx.workingDb.customStatement(
      "ATTACH DATABASE '$escapedPath' AS $_attachAlias",
    );
    try {
      return await run();
    } finally {
      await ctx.workingDb.customStatement('DETACH DATABASE $_attachAlias');
    }
  }

  int _extractCount(List<dynamic> rows, String key) {
    if (rows.isEmpty) {
      return 0;
    }
    final first = rows.first;
    if (first is Map<String, Object?>) {
      return _coerceToInt(first[key]);
    }
    final data = (first as dynamic).data as Map<String, Object?>;
    return _coerceToInt(data[key]);
  }

  int _coerceToInt(Object? value) {
    if (value == null) {
      return 0;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is BigInt) {
      return value.toInt();
    }
    return int.parse(value.toString());
  }
}
