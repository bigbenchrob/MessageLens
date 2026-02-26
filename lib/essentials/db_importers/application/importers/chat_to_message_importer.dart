import '../../domain/base_table_importer.dart';
import '../../infrastructure/sqlite/import_context_sqlite.dart';

class ChatToMessageImporter extends BaseTableImporter {
  const ChatToMessageImporter();

  @override
  String get name => 'chat_to_message';

  @override
  List<String> get dependsOn => const <String>['messages'];

  @override
  Future<void> validatePrereqs(IImportContext ctx) async {
    if (ctx.hasExistingLedgerData) {
      return;
    }
    final existingCount = await count(ctx.importDb, name);
    await expectZeroOrThrow(
      existingCount,
      'chat-to-message-not-empty',
      'Chat-to-message link table must be empty before first ledger import.',
    );
  }

  @override
  Future<void> copy(IImportContext ctx) async {
    final raw = ctx.readScratch<Object?>('messages.messageToChat');
    final entries = _decodeMessageToChat(raw);
    if (entries.isEmpty) {
      ctx.info('ChatToMessageImporter: no message-to-chat pairs to link.');
      ctx.writeScratch('chatToMessage.inserted', 0);
      return;
    }

    var processed = 0;
    var linked = 0;

    for (final entry in entries.entries) {
      final messageId = entry.key;
      final chatId = entry.value;
      final result = await ctx.importDb.insertChatMessageJoinSource(
        chatId: chatId,
        messageId: messageId,
        sourceRowid: messageId,
      );
      if (result != -1) {
        linked += 1;
      }

      processed += 1;
      if (processed % 200 == 0 || processed == entries.length) {
        ctx.info(
          'ChatToMessageImporter: processed $processed/${entries.length} '
          'links (inserted $linked)',
        );
      }
    }

    ctx.writeScratch('chatToMessage.inserted', linked);
  }

  @override
  Future<void> postValidate(IImportContext ctx) async {
    final total = await count(ctx.importDb, name);
    ctx.info(
      'ChatToMessageImporter: ledger now tracks $total chat/message links.',
    );
  }
}

Map<int, int> _decodeMessageToChat(Object? raw) {
  if (raw is Map<String, Object?>) {
    final result = <int, int>{};
    raw.forEach((key, value) {
      final messageId = int.tryParse(key);
      final chatId = value is int
          ? value
          : value is num
          ? value.toInt()
          : int.tryParse('$value');
      if (messageId != null && chatId != null) {
        result[messageId] = chatId;
      }
    });
    return result;
  }
  if (raw is Map<int, int>) {
    return Map<int, int>.from(raw);
  }
  return <int, int>{};
}
