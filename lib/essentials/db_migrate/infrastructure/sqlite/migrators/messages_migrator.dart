import '../../../domain/base_table_migrator.dart';
import '../migration_context_sqlite.dart';

class MessagesMigrator extends BaseTableMigrator {
  const MessagesMigrator();

  static const _attachAlias = 'import_messages';
  static const List<String> _allowedItemTypes = <String>[
    'text',
    'attachment-only',
    'sticker',
    'reaction-carrier',
    'system',
    'unknown',
  ];

  @override
  String get name => 'messages';

  @override
  List<String> get dependsOn => const ['chats', 'handles'];

  @override
  Future<void> validatePrereqs(IMigrationContext ctx) async {
    final joinableMessages = await _countJoinableMessages(ctx);
    ctx.log('[messages] joinable import count = $joinableMessages');

    if (joinableMessages == 0) {
      ctx.log(
        '[messages] no messages with matching chats found; skipping copy',
      );
      return;
    }

    final projectedChats = await count(ctx.workingDb, 'chats');
    await expectTrueOrThrow(
      ok: projectedChats > 0,
      errorCode: 'MESSAGES_REQUIRES_CHATS',
      message:
          'messages: import has $joinableMessages rows but working database has no chats',
    );

    final projectedHandles = await count(ctx.workingDb, 'handles_canonical');
    await expectTrueOrThrow(
      ok: projectedHandles > 0,
      errorCode: 'MESSAGES_REQUIRES_HANDLES',
      message:
          'messages: import has $joinableMessages rows but working database has no canonical handles',
    );
  }

  @override
  Future<void> copy(IMigrationContext ctx) async {
    if (ctx.dryRun) {
      ctx.log('[messages] dry run – skipping copy');
      return;
    }

    final inserted = await _withAttachedImport(ctx, () async {
      final unsupportedTypes = await ctx.workingDb.customSelect('''
        SELECT COALESCE(m.item_type, '<<NULL>>') AS item_type, COUNT(*) AS c
        FROM $_attachAlias.messages m
        WHERE m.guid IS NOT NULL
          AND LENGTH(TRIM(m.guid)) > 0
          AND (m.item_type IS NULL OR m.item_type NOT IN (
            ${_allowedItemTypes.map((type) => "'$type'").join(', ')}
          ))
        GROUP BY m.item_type
      ''').get();

      if (unsupportedTypes.isNotEmpty) {
        for (final row in unsupportedTypes) {
          final data = row.data;
          final rawType = data['item_type'] as String?;
          final count = _coerceToInt(data['c']);
          final label = rawType == '<<NULL>>' ? 'NULL' : rawType;
          ctx.log(
            '[messages] mapping unsupported item_type $label for $count messages to "unknown"',
          );
        }
      }

      final missingHandles = await ctx.workingDb.customSelect('''
        SELECT COUNT(*) AS c
        FROM $_attachAlias.messages m
        WHERE m.sender_handle_id IS NOT NULL
          AND NOT EXISTS (
            SELECT 1
            FROM handles_canonical_to_alias map
            JOIN handles_canonical h ON h.id = map.canonical_handle_id
            WHERE map.source_handle_id = m.sender_handle_id
          );
      ''').get();
      final missingHandlesCount = _extractCount(missingHandles, 'c');
      if (missingHandlesCount > 0) {
        ctx.log(
          '[messages] $missingHandlesCount messages reference missing handles; sender_handle_id will be null',
        );
      }

      // Use INSERT OR IGNORE in incremental mode to avoid expensive REPLACE
      // operations on existing rows (which would trigger cascading FK checks)
      final insertClause = ctx.incrementalMode
          ? 'INSERT OR IGNORE'
          : 'INSERT OR REPLACE';

      await ctx.workingDb.customStatement('''
        $insertClause INTO messages (
          id,
          guid,
          chat_id,
          sender_handle_id,
          is_from_me,
          sent_at_utc,
          delivered_at_utc,
          read_at_utc,
          status,
          text,
          item_type,
          is_system_message,
          error_code,
          has_attachments,
          reply_to_guid,
          associated_message_guid,
          thread_originator_guid,
          system_type,
          reaction_carrier,
          balloon_bundle_id,
          payload_json,
          reaction_summary_json,
          is_starred,
          is_deleted_local,
          updated_at_utc,
          batch_id
        )
        SELECT
          m.id,
          m.guid,
          m.chat_id,
          CASE
            WHEN map.canonical_handle_id IS NULL THEN NULL
            ELSE map.canonical_handle_id
          END AS sender_handle_id,
          m.is_from_me,
          m.date_utc,
          m.date_delivered_utc,
          m.date_read_utc,
          'unknown' AS status,
          m.text,
          CASE m.item_type
            WHEN 'text' THEN 'text'
            WHEN 'attachment-only' THEN 'attachment-only'
            WHEN 'sticker' THEN 'sticker'
            WHEN 'reaction-carrier' THEN 'reaction-carrier'
            WHEN 'system' THEN 'system'
            WHEN 'unknown' THEN 'unknown'
            ELSE 'unknown'
          END AS item_type,
          COALESCE(m.is_system_message, 0),
          m.error_code,
          CASE
            WHEN EXISTS (
              SELECT 1 FROM $_attachAlias.message_attachments ma
              WHERE ma.message_id = m.id
            ) THEN 1 ELSE 0
          END AS has_attachments,
          m.associated_message_guid,
          m.associated_message_guid,
          m.thread_originator_guid,
          NULL,
          CASE WHEN m.item_type = 'reaction-carrier' THEN 1 ELSE 0 END,
          m.balloon_bundle_id,
          m.payload_json,
          NULL,
          0,
          0,
          NULL,
          m.batch_id
        FROM $_attachAlias.messages m
        JOIN chats c ON c.id = m.chat_id
        LEFT JOIN handles_canonical_to_alias map
          ON map.source_handle_id = m.sender_handle_id
        WHERE m.guid IS NOT NULL AND LENGTH(TRIM(m.guid)) > 0;
      ''');

      final rows = await ctx.workingDb
          .customSelect('SELECT changes() AS c')
          .get();
      final insertedCount = _extractCount(rows, 'c');

      // Repair missing sender_handle_id for messages that now have a mapping
      // This fixes rows that were skipped by INSERT OR IGNORE in previous runs
      // but had NULL sender_handle_id due to missing mappings at that time.
      await ctx.workingDb.customStatement('''
        UPDATE messages
        SET sender_handle_id = (
          SELECT map.canonical_handle_id
          FROM $_attachAlias.messages m
          JOIN handles_canonical_to_alias map ON map.source_handle_id = m.sender_handle_id
          WHERE m.guid = messages.guid
        )
        WHERE sender_handle_id IS NULL 
          AND is_from_me = 0
          AND EXISTS (
            SELECT 1
            FROM $_attachAlias.messages m
            JOIN handles_canonical_to_alias map ON map.source_handle_id = m.sender_handle_id
            WHERE m.guid = messages.guid
          );
      ''');

      await ctx.workingDb.customStatement('''
        WITH candidate AS (
          SELECT
            m.chat_id,
            m.id,
            m.sender_handle_id,
            COALESCE(
              NULLIF(TRIM(m.sent_at_utc), ''),
              NULLIF(TRIM(m.delivered_at_utc), ''),
              NULLIF(TRIM(m.read_at_utc), '')
            ) AS resolved_timestamp,
            m.text AS preview
          FROM messages m
        ), scored AS (
          SELECT
            chat_id,
            id,
            sender_handle_id,
            resolved_timestamp,
            preview,
            COALESCE(
              strftime(
                '%s',
                REPLACE(REPLACE(resolved_timestamp, 'T', ' '), 'Z', '')
              ),
              id
            ) AS resolved_score
          FROM candidate
        ), ranked AS (
          SELECT
            chat_id,
            sender_handle_id,
            resolved_timestamp,
            preview,
            ROW_NUMBER() OVER (
              PARTITION BY chat_id
              ORDER BY resolved_score DESC, id DESC
            ) AS rn
          FROM scored
        )
        UPDATE chats
        SET
          last_message_at_utc = (
            SELECT CASE
              WHEN r.resolved_timestamp IS NOT NULL AND r.resolved_timestamp != ''
                THEN r.resolved_timestamp
              ELSE NULL
            END
            FROM ranked r
            WHERE r.chat_id = chats.id AND r.rn = 1
          ),
          last_sender_handle_id = (
            SELECT r.sender_handle_id
            FROM ranked r
            WHERE r.chat_id = chats.id AND r.rn = 1
          ),
          last_message_preview = (
            SELECT CASE
              WHEN r.preview IS NULL THEN NULL
              WHEN LENGTH(TRIM(r.preview)) = 0 THEN NULL
              WHEN LENGTH(TRIM(r.preview)) <= 160 THEN TRIM(r.preview)
              ELSE SUBSTR(TRIM(r.preview), 1, 157) || '...'
            END
            FROM ranked r
            WHERE r.chat_id = chats.id AND r.rn = 1
          )
        WHERE EXISTS (
          SELECT 1 FROM ranked r WHERE r.chat_id = chats.id AND r.rn = 1
        );
      ''');

      // Ensure all statements are fully executed before returning
      await ctx.workingDb.customSelect('SELECT changes() AS c').get();

      return insertedCount;
    });

    ctx.log('[messages] inserted $inserted rows');
  }

  @override
  Future<void> postValidate(IMigrationContext ctx) async {
    final expected = await _countJoinableMessages(ctx);
    final projected = await count(ctx.workingDb, 'messages');
    ctx.log('[messages] expected=$expected projected=$projected');

    if (expected == 0) {
      await expectTrueOrThrow(
        ok: projected == 0,
        errorCode: 'MESSAGES_UNEXPECTED_ROWS',
        message: 'messages: working has $projected rows but import had none',
      );
      return;
    }

    if (ctx.incrementalMode) {
      // In incremental mode, projected should be >= expected (existing + new)
      await expectTrueOrThrow(
        ok: projected >= expected,
        errorCode: 'MESSAGES_INCREMENTAL_UNDERCOUNT',
        message:
            'messages: working has $projected rows but expected >= $expected',
      );
    } else {
      // In full mode, counts must match exactly
      await expectTrueOrThrow(
        ok: projected == expected,
        errorCode: 'MESSAGES_ROW_MISMATCH',
        message: 'messages: working has $projected rows but expected $expected',
      );
    }
  }

  Future<int> _countJoinableMessages(IMigrationContext ctx) async {
    final importSqlite = await ctx.importDb.database;
    final rows = await importSqlite.rawQuery(
      'SELECT COUNT(*) AS c '
      'FROM messages m '
      'JOIN chats c ON c.id = m.chat_id '
      'WHERE m.guid IS NOT NULL AND LENGTH(TRIM(m.guid)) > 0',
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
      return await ctx.workingDb.transaction<T>(() => run());
    } finally {
      await _detachImportWithRetry(ctx);
    }
  }

  Future<void> _detachImportWithRetry(IMigrationContext ctx) async {
    const maxAttempts = 5;
    var attempt = 0;
    while (true) {
      attempt += 1;
      try {
        await ctx.workingDb.customStatement('DETACH DATABASE $_attachAlias');
        return;
      } catch (error) {
        final message = error.toString();
        final isLocked =
            message.contains('database is locked') ||
            message.contains('SQLITE_LOCKED') ||
            message.contains('SQLITE_BUSY');
        if (!isLocked || attempt >= maxAttempts) {
          rethrow;
        }
        await Future<void>.delayed(Duration(milliseconds: 150 * attempt));
      }
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
