import '../../domain/base_table_migrator.dart';
import '../../infrastructure/sqlite/migration_context_sqlite.dart';

class RecoveredUnlinkedAttachmentsMigrator extends BaseTableMigrator {
  const RecoveredUnlinkedAttachmentsMigrator();

  static const _attachAlias = 'import_recovered_unlinked_attachments';

  @override
  String get name => 'recovered_unlinked_attachments';

  @override
  List<String> get dependsOn => const ['recovered_unlinked_messages'];

  @override
  Future<void> validatePrereqs(IMigrationContext ctx) async {
    final joinable = await _countJoinableAttachments(ctx);
    ctx.log('[recovered_unlinked_attachments] import count = $joinable');
  }

  @override
  Future<void> copy(IMigrationContext ctx) async {
    if (ctx.dryRun) {
      ctx.log('[recovered_unlinked_attachments] dry run – skipping copy');
      return;
    }

    final joinable = await _countJoinableAttachments(ctx);
    if (joinable == 0) {
      ctx.log('[recovered_unlinked_attachments] no rows to project');
      return;
    }

    final inserted = await _withAttachedImport(ctx, () async {
      await ctx.workingDb.customStatement('''
        INSERT INTO recovered_unlinked_attachments (
          message_guid,
          import_attachment_id,
          local_path,
          mime_type,
          uti,
          transfer_name,
          size_bytes,
          is_sticker,
          created_at_utc,
          is_outgoing,
          sha256_hex,
          batch_id
        )
        SELECT
          rum.guid,
          a.id AS import_attachment_id,
          a.local_path,
          a.mime_type,
          a.uti,
          a.transfer_name,
          a.total_bytes,
          COALESCE(a.is_sticker, 0) AS is_sticker,
          a.created_at_utc,
          CASE
            WHEN a.is_outgoing IS NULL THEN 0
            WHEN a.is_outgoing = 1 THEN 1
            ELSE 0
          END AS is_outgoing,
          a.sha256_hex,
          a.batch_id
        FROM $_attachAlias.recovered_unlinked_message_attachments ruma
        JOIN $_attachAlias.attachments a ON a.id = ruma.attachment_id
        JOIN recovered_unlinked_messages rum ON rum.id = ruma.message_id
        WHERE rum.guid IS NOT NULL AND LENGTH(TRIM(rum.guid)) > 0;
      ''');

      final rows = await ctx.workingDb
          .customSelect('SELECT changes() AS c')
          .get();
      return _extractCount(rows, 'c');
    });

    ctx.log('[recovered_unlinked_attachments] inserted $inserted rows');
  }

  @override
  Future<void> postValidate(IMigrationContext ctx) async {
    final expected = await _countJoinableAttachments(ctx);
    final projected = await count(ctx.workingDb, name);
    ctx.log(
      '[recovered_unlinked_attachments] expected=$expected projected=$projected',
    );

    if (ctx.incrementalMode) {
      await expectTrueOrThrow(
        ok: projected >= expected,
        errorCode: 'RECOVERED_UNLINKED_ATTACHMENTS_INCREMENTAL_UNDERCOUNT',
        message:
            'recovered_unlinked_attachments: working has $projected rows but expected >= $expected',
      );
      return;
    }

    await expectTrueOrThrow(
      ok: projected == expected,
      errorCode: 'RECOVERED_UNLINKED_ATTACHMENTS_ROW_MISMATCH',
      message:
          'recovered_unlinked_attachments: working has $projected rows but expected $expected',
    );
  }

  Future<int> _countJoinableAttachments(IMigrationContext ctx) async {
    final importSqlite = await ctx.importDb.database;
    final rows = await importSqlite.rawQuery(
      'SELECT COUNT(*) AS c '
      'FROM recovered_unlinked_message_attachments ruma '
      'JOIN attachments a ON a.id = ruma.attachment_id '
      'JOIN recovered_unlinked_messages rum ON rum.id = ruma.message_id '
      'WHERE rum.guid IS NOT NULL AND LENGTH(TRIM(rum.guid)) > 0',
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
