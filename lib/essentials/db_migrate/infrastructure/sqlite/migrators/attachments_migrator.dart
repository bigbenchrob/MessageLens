import 'package:sqflite/sqflite.dart' show Database;

import '../../../application/services/base_table_migrator.dart';
import '../migration_context_sqlite.dart';

class AttachmentsMigrator extends BaseTableMigrator {
  const AttachmentsMigrator();

  static const _attachAlias = 'import_attachments';

  @override
  String get name => 'attachments';

  @override
  List<String> get dependsOn => const ['messages'];

  @override
  Future<void> validatePrereqs(MigrationContext ctx) async {
    final joinable = await _countJoinableAttachments(ctx);
    ctx.log('[attachments] joinable import count = $joinable');

    if (joinable == 0) {
      ctx.log('[attachments] no joinable rows; skipping copy');
      return;
    }

    final projectedMessages = await count(ctx.workingDb, 'messages');
    await expectTrueOrThrow(
      projectedMessages > 0,
      'ATTACHMENTS_REQUIRES_MESSAGES',
      'attachments: import has $joinable rows but working database has no messages',
    );
  }

  @override
  Future<void> copy(MigrationContext ctx) async {
    if (ctx.dryRun) {
      ctx.log('[attachments] dry run – skipping copy');
      return;
    }

    final inserted = await _withAttachedImport(ctx, () async {
      final missingMessages = await ctx.workingDb
          .customSelect('''
        SELECT COUNT(*) AS c
        FROM $_attachAlias.message_attachments ma
        LEFT JOIN messages wm ON wm.id = ma.message_id
        WHERE wm.id IS NULL
      ''')
          .get();
      final missingMessagesCount = _extractCount(missingMessages, 'c');
      if (missingMessagesCount > 0) {
        ctx.log('[attachments] skipping $missingMessagesCount attachment link(s); message not projected');
      }

      await ctx.workingDb.customStatement('''
        INSERT INTO attachments (
          message_guid,
          import_attachment_id,
          local_path,
          mime_type,
          uti,
          transfer_name,
          size_bytes,
          is_sticker,
          thumb_path,
          created_at_utc,
          is_outgoing,
          sha256_hex,
          batch_id
        )
        SELECT
          wm.guid AS message_guid,
          a.id AS import_attachment_id,
          a.local_path,
          a.mime_type,
          a.uti,
          a.transfer_name,
          a.total_bytes,
          COALESCE(a.is_sticker, 0) AS is_sticker,
          NULL AS thumb_path,
          a.created_at_utc,
          CASE
            WHEN a.is_outgoing IS NULL THEN 0
            WHEN a.is_outgoing = 1 THEN 1
            ELSE 0
          END AS is_outgoing,
          a.sha256_hex,
          a.batch_id
        FROM $_attachAlias.message_attachments ma
        JOIN $_attachAlias.attachments a ON a.id = ma.attachment_id
        JOIN messages wm ON wm.id = ma.message_id
        WHERE wm.guid IS NOT NULL AND LENGTH(TRIM(wm.guid)) > 0;
      ''');

      final rows = await ctx.workingDb
          .customSelect('SELECT changes() AS c')
          .get();
      return _extractCount(rows, 'c');
    });

    ctx.log('[attachments] inserted $inserted rows');
  }

  @override
  Future<void> postValidate(MigrationContext ctx) async {
    final expected = await _countJoinableAttachments(ctx);
    final projected = await count(ctx.workingDb, 'attachments');
    ctx.log('[attachments] expected=$expected projected=$projected');

    if (expected == 0) {
      await expectTrueOrThrow(
        projected == 0,
        'ATTACHMENTS_UNEXPECTED_ROWS',
        'attachments: working has $projected rows but import had none',
      );
      return;
    }

    await expectTrueOrThrow(
      projected == expected,
      'ATTACHMENTS_ROW_MISMATCH',
      'attachments: working has $projected rows but expected $expected',
    );
  }

  Future<int> _countJoinableAttachments(MigrationContext ctx) async {
    final Database importSqlite = await ctx.importDb.database;
    final rows = await importSqlite.rawQuery(
      'SELECT COUNT(*) AS c '
      'FROM message_attachments ma '
      'JOIN attachments a ON a.id = ma.attachment_id '
      'JOIN messages m ON m.id = ma.message_id '
      "WHERE m.guid IS NOT NULL AND LENGTH(TRIM(m.guid)) > 0",
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
    final Database importSqlite = await ctx.importDb.database;
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
