import 'package:sqflite/sqflite.dart';

import '../../domain/base_table_importer.dart';
import '../../infrastructure/sqlite/import_context_sqlite.dart';

class ChatToMessageImporter extends BaseTableImporter {
  ChatToMessageImporter();

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

    final db = await ctx.importDb.database;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final entry in entries.entries) {
        batch.insert('chat_to_message', <String, Object?>{
          'chat_id': entry.value,
          'message_id': entry.key,
          'source_rowid': entry.key,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
    });

    ctx.info(
      'ChatToMessageImporter: inserted ${entries.length} links (batched).',
    );
    ctx.writeScratch('chatToMessage.inserted', entries.length);
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
