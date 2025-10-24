import '../../../application/services/base_table_migrator.dart';
import '../migration_context_sqlite.dart';

class ChatToHandleMigrator extends BaseTableMigrator {
  const ChatToHandleMigrator();

  static const _attachAlias = 'import_chat_handles';

  @override
  String get name => 'chat_to_handle';

  @override
  List<String> get dependsOn => const ['chats', 'handles'];

  @override
  Future<void> validatePrereqs(MigrationContext ctx) async {
    final importLinks = await _countImportLinks(ctx);
    ctx.log('[chat_to_handle] import count = $importLinks');

    if (importLinks == 0) {
      return;
    }

    final projectedChats = await count(ctx.workingDb, 'chats');
    await expectTrueOrThrow(
      ok: projectedChats > 0,
      errorCode: 'CHAT_TO_HANDLE_MISSING_CHATS',
      message:
          'chat_to_handle: import has $importLinks rows but working database has no chats',
    );

    final projectedHandles = await count(ctx.workingDb, 'handles_canonical');
    await expectTrueOrThrow(
      ok: projectedHandles > 0,
      errorCode: 'CHAT_TO_HANDLE_MISSING_HANDLES',
      message:
          'chat_to_handle: import has $importLinks rows but working database has no canonical handles',
    );
  }

  @override
  Future<void> copy(MigrationContext ctx) async {
    if (ctx.dryRun) {
      ctx.log('[chat_to_handle] dry run – skipping copy');
      return;
    }

    await _withAttachedImport(ctx, () async {
      final missingChats = await ctx.workingDb.customSelect('''
        SELECT DISTINCT cth.chat_id AS chat_id
        FROM $_attachAlias.chat_to_handle cth
        LEFT JOIN chats c ON c.id = cth.chat_id
        WHERE c.id IS NULL
      ''').get();

      if (missingChats.isNotEmpty) {
        final ids =
            missingChats
                .map((row) => _coerceToNullableInt(row.data['chat_id']))
                .whereType<int>()
                .toList()
              ..sort();
        final preview = ids.take(5).join(', ');
        final suffix = ids.length > 5 ? '…' : '';
        ctx.log(
          '[chat_to_handle] skipping ${ids.length} membership rows; missing chats: $preview$suffix',
        );
      }

      final missingHandles = await ctx.workingDb.customSelect('''
        SELECT DISTINCT cth.handle_id AS handle_id
        FROM $_attachAlias.chat_to_handle cth
        LEFT JOIN handle_canonical_map map
          ON map.source_handle_id = cth.handle_id
        LEFT JOIN handles_canonical h ON h.id = map.canonical_handle_id
        WHERE map.canonical_handle_id IS NULL OR h.id IS NULL
      ''').get();

      if (missingHandles.isNotEmpty) {
        final ids =
            missingHandles
                .map((row) => _coerceToNullableInt(row.data['handle_id']))
                .whereType<int>()
                .toList()
              ..sort();
        final preview = ids.take(5).join(', ');
        final suffix = ids.length > 5 ? '…' : '';
        ctx.log(
          '[chat_to_handle] skipping ${ids.length} membership rows; missing handles: $preview$suffix',
        );
      }

      await ctx.workingDb.customStatement('''
        INSERT OR IGNORE INTO chat_to_handle (
          chat_id,
          handle_id,
          role,
          added_at_utc,
          is_ignored
        )
        SELECT
          cth.chat_id,
          map.canonical_handle_id,
          COALESCE(cth.role, 'member') AS role,
          cth.added_at_utc,
          CASE
            WHEN c.is_ignored = 1 OR h.is_ignored = 1 THEN 1
            ELSE 0
          END AS is_ignored
        FROM $_attachAlias.chat_to_handle cth
        JOIN handle_canonical_map map
          ON map.source_handle_id = cth.handle_id
        JOIN chats c ON c.id = cth.chat_id
        JOIN handles_canonical h ON h.id = map.canonical_handle_id;
      ''');

      final insertedRows = await ctx.workingDb
          .customSelect('SELECT changes() AS c')
          .get();
      final inserted = _extractCount(insertedRows, 'c');
      ctx.log('[chat_to_handle] inserted $inserted rows');
    });
  }

  @override
  Future<void> postValidate(MigrationContext ctx) async {
    final expected = await _withAttachedImport(ctx, () async {
      final rows = await ctx.workingDb.customSelect('''
        SELECT COUNT(*) AS c
        FROM $_attachAlias.chat_to_handle cth
        JOIN handle_canonical_map map
          ON map.source_handle_id = cth.handle_id
        JOIN chats c ON c.id = cth.chat_id
        JOIN handles_canonical h ON h.id = map.canonical_handle_id
      ''').get();
      return _extractCount(rows, 'c');
    });

    final projected = await count(ctx.workingDb, 'chat_to_handle');
    ctx.log('[chat_to_handle] expected=$expected projected=$projected');

    await expectTrueOrThrow(
      ok: projected == expected,
      errorCode: 'CHAT_TO_HANDLE_ROW_MISMATCH',
      message:
          'chat_to_handle: working has $projected rows but expected $expected',
    );
  }

  Future<int> _countImportLinks(MigrationContext ctx) async {
    final importSqlite = await ctx.importDb.database;
    final rows = await importSqlite.rawQuery(
      'SELECT COUNT(*) AS c FROM chat_to_handle',
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
    final nullable = _coerceToNullableInt(value);
    return nullable ?? 0;
  }

  int? _coerceToNullableInt(Object? value) {
    if (value == null) {
      return null;
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
