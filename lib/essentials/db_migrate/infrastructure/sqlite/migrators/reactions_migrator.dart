import '../../../domain/base_table_migrator.dart';
import '../migration_context_sqlite.dart';

class ReactionsMigrator extends BaseTableMigrator {
  const ReactionsMigrator();

  static const _attachAlias = 'import_reactions';

  @override
  String get name => 'reactions';

  @override
  List<String> get dependsOn => const ['messages', 'handles'];

  @override
  Future<void> validatePrereqs(IMigrationContext ctx) async {
    final joinable = await _countJoinableReactions(ctx);
    ctx.log('[reactions] joinable import count = $joinable');

    if (joinable == 0) {
      ctx.log(
        '[reactions] no reactions with projected carriers; skipping copy',
      );
      return;
    }

    final projectedMessages = await count(ctx.workingDb, 'messages');
    await expectTrueOrThrow(
      ok: projectedMessages > 0,
      errorCode: 'REACTIONS_REQUIRES_MESSAGES',
      message:
          'reactions: import has $joinable rows but working database has no messages',
    );

    final projectedHandles = await count(ctx.workingDb, 'handles');
    await expectTrueOrThrow(
      ok: projectedHandles > 0,
      errorCode: 'REACTIONS_REQUIRES_HANDLES',
      message:
          'reactions: import has $joinable rows but working database has no handles',
    );
  }

  @override
  Future<void> copy(IMigrationContext ctx) async {
    if (ctx.dryRun) {
      ctx.log('[reactions] dry run – skipping copy');
      return;
    }

    final inserted = await _withAttachedImport(ctx, () async {
      final missingHandlesRows = await ctx.workingDb.customSelect('''
        SELECT COUNT(*) AS c
        FROM $_attachAlias.reactions r
        WHERE r.reactor_handle_id IS NOT NULL
          AND NOT EXISTS (
            SELECT 1 FROM handles_canonical_to_alias map
            WHERE map.source_handle_id = r.reactor_handle_id
          )
      ''').get();
      final missingHandleCount = _extractCount(missingHandlesRows, 'c');
      if (missingHandleCount > 0) {
        ctx.log(
          '[reactions] $missingHandleCount reaction(s) reference missing handles; reactor_handle_id will be null',
        );
      }

      // Use INSERT OR IGNORE in incremental mode to avoid expensive REPLACE
      final insertClause = ctx.incrementalMode
          ? 'INSERT OR IGNORE'
          : 'INSERT OR REPLACE';

      await ctx.workingDb.customStatement('''
        $insertClause INTO reactions (
          id,
          message_guid,
          kind,
          reactor_handle_id,
          action,
          reacted_at_utc,
          carrier_message_id,
          target_message_guid,
          parse_confidence
        )
        SELECT
          r.id,
          wm.guid AS message_guid,
          r.kind,
          CASE
            WHEN map.canonical_handle_id IS NULL THEN NULL
            ELSE map.canonical_handle_id
          END AS reactor_handle_id,
          r.action,
          r.reacted_at_utc,
          r.carrier_message_id,
          r.target_message_guid,
          COALESCE(r.parse_confidence, 1.0)
        FROM $_attachAlias.reactions r
        JOIN $_attachAlias.messages carrier ON carrier.id = r.carrier_message_id
        JOIN messages wm ON wm.id = carrier.id
        LEFT JOIN handles_canonical_to_alias map
          ON map.source_handle_id = r.reactor_handle_id
        LEFT JOIN handles rh ON rh.id = map.canonical_handle_id
        WHERE wm.guid IS NOT NULL AND LENGTH(TRIM(wm.guid)) > 0;
      ''');

      final rows = await ctx.workingDb
          .customSelect('SELECT changes() AS c')
          .get();
      return _extractCount(rows, 'c');
    });

    ctx.log('[reactions] inserted $inserted rows');
  }

  @override
  Future<void> postValidate(IMigrationContext ctx) async {
    final expected = await _countJoinableReactions(ctx);
    final projected = await count(ctx.workingDb, 'reactions');
    ctx.log('[reactions] expected=$expected projected=$projected');

    if (expected == 0) {
      await expectTrueOrThrow(
        ok: projected == 0,
        errorCode: 'REACTIONS_UNEXPECTED_ROWS',
        message: 'reactions: working has $projected rows but import had none',
      );
      return;
    }

    if (ctx.incrementalMode) {
      // In incremental mode, projected should be >= expected
      await expectTrueOrThrow(
        ok: projected >= expected,
        errorCode: 'REACTIONS_INCREMENTAL_UNDERCOUNT',
        message:
            'reactions: working has $projected rows but expected >= $expected',
      );
    } else {
      // In full mode, counts must match exactly
      await expectTrueOrThrow(
        ok: projected == expected,
        errorCode: 'REACTIONS_ROW_MISMATCH',
        message:
            'reactions: working has $projected rows but expected $expected',
      );
    }
  }

  Future<int> _countJoinableReactions(IMigrationContext ctx) async {
    final importSqlite = await ctx.importDb.database;
    final rows = await importSqlite.rawQuery(
      'SELECT COUNT(*) AS c '
      'FROM reactions r '
      'JOIN messages carrier ON carrier.id = r.carrier_message_id '
      'WHERE carrier.guid IS NOT NULL AND LENGTH(TRIM(carrier.guid)) > 0',
    );
    if (rows.isEmpty) {
      return 0;
    }
    return _coerceToInt(rows.first['c']);
  }

  Future<T> _withAttachedImport<T>(
    IMigrationContext ctx,
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
