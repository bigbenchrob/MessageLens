import '../../../domain/base_table_importer.dart';
import '../../sqlite/import_context_sqlite.dart';

class ChatToHandleImporter extends BaseTableImporter {
  const ChatToHandleImporter();

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

    var processed = 0;
    var inserted = 0;

    for (final row in rows) {
      final chatId = row['chat_id'] as int?;
      final handleId = row['handle_id'] as int?;
      if (chatId == null || handleId == null) {
        processed += 1;
        continue;
      }

      final alreadyLinked = await ctx.importDb.chatParticipantExists(
        chatId: chatId,
        handleId: handleId,
      );
      if (!alreadyLinked) {
        final result = await ctx.importDb.insertChatParticipant(
          chatId: chatId,
          handleId: handleId,
        );
        if (result > 0) {
          inserted += 1;
        }
      }

      processed += 1;
      if (processed % 500 == 0 || processed == rows.length) {
        ctx.info(
          'ChatToHandleImporter: processed $processed/${rows.length} memberships',
        );
      }
    }

    ctx.writeScratch('chatMemberships.inserted', inserted);
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
