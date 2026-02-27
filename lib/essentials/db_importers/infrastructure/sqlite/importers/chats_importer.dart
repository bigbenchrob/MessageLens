import '../../../../../core/util/date_converter.dart';

import '../../../domain/base_table_importer.dart';
import '../../sqlite/import_context_sqlite.dart';

class ChatsImporter extends BaseTableImporter {
  const ChatsImporter();

  @override
  String get name => 'chats';

  @override
  List<String> get dependsOn => const <String>['handles'];

  @override
  Future<void> validatePrereqs(IImportContext ctx) async {
    if (ctx.hasExistingLedgerData) {
      return;
    }
    final existingCount = await count(ctx.importDb, name);
    await expectZeroOrThrow(
      existingCount,
      'chats-not-empty',
      'Chats table must be empty before first ledger import.',
    );
  }

  @override
  Future<void> copy(IImportContext ctx) async {
    final minRowId = ctx.previousMaxChatRowId;
    final rows = await ctx.messagesDb.query(
      'chat',
      where: minRowId == null ? null : 'ROWID > ?',
      whereArgs: minRowId == null ? null : <Object>[minRowId],
      orderBy: 'ROWID ASC',
    );

    if (rows.isEmpty) {
      ctx.info('ChatsImporter: no new chats detected.');
      ctx.writeScratch('chats.inserted', 0);
      return;
    }

    var processed = 0;
    var inserted = 0;
    for (final row in rows) {
      final sourceRowId = row['ROWID'] as int?;
      final guid = (row['guid'] as String?)?.trim();
      if (sourceRowId == null || guid == null || guid.isEmpty) {
        processed += 1;
        continue;
      }

      final rawService =
          (row['service_name'] as String?) ?? (row['service'] as String?);
      final service = rawService?.trim() ?? 'Unknown';
      final displayName = (row['display_name'] as String?)?.trim();
      final isGroup = (row['is_group'] as int? ?? 0) == 1;
      final created = DateConverter.toIntSafe(row['creation_date']);
      final updated = DateConverter.toIntSafe(
        row['last_read_message_timestamp'],
      );

      await ctx.importDb.insertChat(
        id: sourceRowId,
        sourceRowid: sourceRowId,
        guid: guid,
        service: service,
        displayName: displayName,
        isGroup: isGroup,
        createdAtUtc: DateConverter.appleToIsoString(created),
        updatedAtUtc: DateConverter.appleToIsoString(updated),
        batchId: ctx.batchId,
      );

      inserted += 1;
      processed += 1;
      if (processed % 200 == 0 || processed == rows.length) {
        ctx.info(
          'ChatsImporter: processed $processed/${rows.length} chats from chat.db',
        );
      }
    }

    ctx.writeScratch('chats.inserted', inserted);
    if (rows.isNotEmpty) {
      final lastRowId = rows.last['ROWID'];
      if (lastRowId is int) {
        ctx.writeScratch('chats.lastSourceRowId', lastRowId);
      }
    }
  }

  @override
  Future<void> postValidate(IImportContext ctx) async {
    final total = await count(ctx.importDb, name);
    await expectTrueOrThrow(
      ok: total > 0,
      errorCode: 'chats-empty',
      message: 'Chats table should contain rows after import.',
    );
  }
}
