import 'package:sqflite/sqflite.dart';

import '../../domain/base_table_importer.dart';
import '../../infrastructure/sqlite/import_context_sqlite.dart';

class ChatToHandleImporter extends BaseTableImporter {
  ChatToHandleImporter();

  @override
  String get name => 'chat_to_handle';

  @override
  List<String> get dependsOn => const <String>['handles', 'chats'];

  @override
  Future<void> validatePrereqs(IImportContext ctx) async {
    if (ctx.hasExistingLedgerData) {
      return;
    }
    final existingCount = await count(ctx.importDb, name);
    await expectZeroOrThrow(
      existingCount,
      'chat-to-handle-not-empty',
      'Chat-to-handle table must be empty before first ledger import.',
    );
  }

  @override
  Future<void> copy(IImportContext ctx) async {
    final rows = await ctx.messagesDb.query('chat_handle_join');
    if (rows.isEmpty) {
      ctx.info('ChatToHandleImporter: no chat memberships detected.');
      ctx.writeScratch('chatMemberships.inserted', 0);
      return;
    }

    // Collect valid pairs, then batch-insert.
    // PK (chat_id, handle_id) with REPLACE handles duplicates.
    final pairs = <Map<String, Object?>>[];
    for (final row in rows) {
      final chatId = row['chat_id'] as int?;
      final handleId = row['handle_id'] as int?;
      if (chatId != null && handleId != null) {
        pairs.add(<String, Object?>{'chat_id': chatId, 'handle_id': handleId});
      }
    }

    final db = await ctx.importDb.database;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final pair in pairs) {
        batch.insert(
          'chat_to_handle',
          pair,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });

    ctx.info(
      'ChatToHandleImporter: inserted ${pairs.length} memberships '
      '(batched, from ${rows.length} source rows).',
    );
    ctx.writeScratch('chatMemberships.inserted', pairs.length);
  }

  @override
  Future<void> postValidate(IImportContext ctx) async {
    final total = await count(ctx.importDb, name);
    await expectTrueOrThrow(
      ok: total > 0,
      errorCode: 'chat-to-handle-empty',
      message: 'Chat-to-handle table should contain rows after import.',
    );
  }
}
