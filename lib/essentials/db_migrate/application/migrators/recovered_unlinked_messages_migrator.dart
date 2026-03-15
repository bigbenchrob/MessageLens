import '../../domain/base_table_migrator.dart';
import '../../infrastructure/sqlite/migration_context_sqlite.dart';

class RecoveredUnlinkedMessagesMigrator extends BaseTableMigrator {
  const RecoveredUnlinkedMessagesMigrator();

  static const _attachAlias = 'import_recovered_unlinked_messages';

  @override
  String get name => 'recovered_unlinked_messages';

  @override
  List<String> get dependsOn => const ['handles'];

  @override
  Future<void> validatePrereqs(IMigrationContext ctx) async {
    final recoverable = await _countRecoverableMessages(ctx);
    ctx.log('[recovered_unlinked_messages] import count = $recoverable');
  }

  @override
  Future<void> copy(IMigrationContext ctx) async {
    if (ctx.dryRun) {
      ctx.log('[recovered_unlinked_messages] dry run – skipping copy');
      return;
    }

    final recoverable = await _countRecoverableMessages(ctx);
    if (recoverable == 0) {
      ctx.log('[recovered_unlinked_messages] no rows to project');
      return;
    }

    final inserted = await _withAttachedImport(ctx, () async {
      const insertClause = 'INSERT OR REPLACE';

      await ctx.workingDb.customStatement('''
        $insertClause INTO recovered_unlinked_messages (
          id,
          guid,
          sender_handle_id,
          sender_address,
          service,
          is_from_me,
          sent_at_utc,
          delivered_at_utc,
          read_at_utc,
          text,
          raw_item_type,
          raw_associated_message_type,
          semantic_kind,
          is_sparse_artifact,
          has_attributed_body_source,
          has_message_summary_info,
          has_payload_data_source,
          item_type,
          is_system_message,
          error_code,
          has_attachments,
          associated_message_guid,
          thread_originator_guid,
          balloon_bundle_id,
          payload_json,
          batch_id
        )
        SELECT
          m.id,
          m.guid,
          map.canonical_handle_id,
          h.raw_identifier,
          COALESCE(m.service, 'Unknown'),
          m.is_from_me,
          m.date_utc,
          m.date_delivered_utc,
          m.date_read_utc,
          m.text,
          m.raw_item_type,
          m.raw_associated_message_type,
          CASE
            WHEN COALESCE(m.is_system_message, 0) = 1 OR m.item_type = 'system' THEN 'system'
            WHEN COALESCE(m.has_message_summary_info, 0) = 1 THEN 'edited-or-unsent'
            WHEN m.item_type = 'reaction-carrier'
              OR m.associated_message_guid IS NOT NULL
              OR COALESCE(m.raw_associated_message_type, 0) != 0 THEN 'associated'
            WHEN m.item_type = 'balloon'
              OR COALESCE(m.has_payload_data_source, 0) = 1
              OR COALESCE(LENGTH(TRIM(m.balloon_bundle_id)), 0) > 0 THEN 'balloon-or-app'
            WHEN m.item_type = 'attachment-only' THEN 'attachment-only'
            WHEN COALESCE(m.has_attributed_body_source, 0) = 1 THEN 'rich-text'
            WHEN COALESCE(LENGTH(TRIM(m.text)), 0) > 0 THEN 'plain-text'
            WHEN COALESCE(m.raw_item_type, -1) >= 0 THEN 'sparse-artifact'
            ELSE 'unknown-variant'
          END AS semantic_kind,
          CASE
            WHEN COALESCE(LENGTH(TRIM(m.text)), 0) = 0
              AND COALESCE(m.has_attributed_body_source, 0) = 0
              AND COALESCE(m.has_message_summary_info, 0) = 0
              AND COALESCE(m.has_payload_data_source, 0) = 0
              AND NOT EXISTS (
                SELECT 1 FROM $_attachAlias.recovered_unlinked_message_attachments ma
                WHERE ma.message_id = m.id
              )
            THEN 1 ELSE 0
          END AS is_sparse_artifact,
          COALESCE(m.has_attributed_body_source, 0),
          COALESCE(m.has_message_summary_info, 0),
          COALESCE(m.has_payload_data_source, 0),
          CASE m.item_type
            WHEN 'text' THEN 'text'
            WHEN 'attachment-only' THEN 'attachment-only'
            WHEN 'sticker' THEN 'sticker'
            WHEN 'reaction-carrier' THEN 'reaction-carrier'
            WHEN 'system' THEN 'system'
            WHEN 'unknown' THEN 'unknown'
            WHEN 'balloon' THEN 'balloon'
            ELSE 'unknown'
          END AS item_type,
          COALESCE(m.is_system_message, 0),
          m.error_code,
          CASE
            WHEN EXISTS (
              SELECT 1 FROM $_attachAlias.recovered_unlinked_message_attachments ma
              WHERE ma.message_id = m.id
            ) THEN 1 ELSE 0
          END AS has_attachments,
          m.associated_message_guid,
          m.thread_originator_guid,
          m.balloon_bundle_id,
          m.payload_json,
          m.batch_id
        FROM $_attachAlias.recovered_unlinked_messages m
        LEFT JOIN $_attachAlias.handles h ON h.id = m.sender_handle_id
        LEFT JOIN handles_canonical_to_alias map
          ON map.source_handle_id = m.sender_handle_id
        WHERE m.guid IS NOT NULL AND LENGTH(TRIM(m.guid)) > 0;
      ''');

      final rows = await ctx.workingDb
          .customSelect('SELECT changes() AS c')
          .get();
      return _extractCount(rows, 'c');
    });

    ctx.log('[recovered_unlinked_messages] inserted $inserted rows');
  }

  @override
  Future<void> postValidate(IMigrationContext ctx) async {
    final expected = await _countRecoverableMessages(ctx);
    final projected = await count(ctx.workingDb, name);
    ctx.log(
      '[recovered_unlinked_messages] expected=$expected projected=$projected',
    );

    if (ctx.incrementalMode) {
      await expectTrueOrThrow(
        ok: projected >= expected,
        errorCode: 'RECOVERED_UNLINKED_MESSAGES_INCREMENTAL_UNDERCOUNT',
        message:
            'recovered_unlinked_messages: working has $projected rows but expected >= $expected',
      );
      return;
    }

    await expectTrueOrThrow(
      ok: projected == expected,
      errorCode: 'RECOVERED_UNLINKED_MESSAGES_ROW_MISMATCH',
      message:
          'recovered_unlinked_messages: working has $projected rows but expected $expected',
    );
  }

  Future<int> _countRecoverableMessages(IMigrationContext ctx) async {
    final importSqlite = await ctx.importDb.database;
    final rows = await importSqlite.rawQuery(
      'SELECT COUNT(*) AS c '
      'FROM recovered_unlinked_messages '
      'WHERE guid IS NOT NULL AND LENGTH(TRIM(guid)) > 0',
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
