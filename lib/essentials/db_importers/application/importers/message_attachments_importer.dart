import 'package:sqflite/sqflite.dart';

import '../../domain/base_table_importer.dart';
import '../../domain/row_progress_reporter.dart';
import '../../infrastructure/sqlite/import_context_sqlite.dart';

class MessageAttachmentsImporter extends BaseTableImporter
    with RowProgressReporter {
  MessageAttachmentsImporter();

  @override
  String get name => 'message_attachments';

  @override
  List<String> get dependsOn => const <String>['attachments'];

  @override
  Future<void> validatePrereqs(IImportContext ctx) async {
    if (ctx.hasExistingLedgerData) {
      return;
    }
    final existingCount = await count(ctx.importDb, name);
    await expectZeroOrThrow(
      existingCount,
      'message-attachments-not-empty',
      'Message attachment join table must be empty before first ledger import.',
    );
  }

  @override
  Future<void> copy(IImportContext ctx) async {
    final messageIds = _readIntList(ctx, 'messages.insertedIds');
    final attachmentIds = _readIntList(ctx, 'attachments.insertedIds');
    final joinPairs = await _collectJoinPairs(
      ctx.messagesDb,
      messageIds: messageIds.toSet(),
      attachmentIds: attachmentIds.toSet(),
      minAttachmentSourceRowIdExclusive: ctx.previousMaxMessageAttachmentRowId,
    );

    if (joinPairs.isEmpty) {
      ctx.info('MessageAttachmentsImporter: no join pairs detected.');
      ctx.writeScratch('messageAttachments.inserted', 0);
      return;
    }

    // Bulk-validate: collect IDs that actually exist in the import DB so we
    // don't hit FK violations (messages/attachments may have been filtered).
    final db = await ctx.importDb.database;
    final existingMsgRows = await db.rawQuery('SELECT id FROM messages');
    final existingMsgIds = existingMsgRows
        .map((r) => r['id'])
        .whereType<int>()
        .toSet();
    final existingAttRows = await db.rawQuery('SELECT id FROM attachments');
    final existingAttIds = existingAttRows
        .map((r) => r['id'])
        .whereType<int>()
        .toSet();

    final validPairs = joinPairs
        .where(
          (p) =>
              existingMsgIds.contains(p.messageId) &&
              existingAttIds.contains(p.attachmentId),
        )
        .toList(growable: false);

    final skipped = joinPairs.length - validPairs.length;
    if (skipped > 0) {
      ctx.info(
        'MessageAttachmentsImporter: filtered out $skipped pairs '
        'referencing missing messages/attachments',
      );
    }

    final total = validPairs.length;
    var processed = 0;

    const chunkSize = 500;
    for (var offset = 0; offset < total; offset += chunkSize) {
      final end = (offset + chunkSize > total) ? total : offset + chunkSize;
      final chunkRows = <Map<String, Object?>>[];
      for (var i = offset; i < end; i++) {
        final pair = validPairs[i];
        chunkRows.add(<String, Object?>{
          'message_id': pair.messageId,
          'attachment_id': pair.attachmentId,
          'source_rowid': pair.attachmentId,
        });
      }

      await ctx.importDb.insertMessageAttachmentsBatch(chunkRows);
      processed = end;
      ctx.info('MessageAttachmentsImporter: processed $processed/$total pairs');
      reportRowProgress(processed: processed, total: total);
    }

    ctx.writeScratch('messageAttachments.inserted', total);
  }

  @override
  Future<void> postValidate(IImportContext ctx) async {
    final total = await count(ctx.importDb, name);
    ctx.info(
      'MessageAttachmentsImporter: ledger now tracks $total message/attachment links.',
    );
  }
}

({int messageId, int attachmentId}) _pair(int messageId, int attachmentId) =>
    (messageId: messageId, attachmentId: attachmentId);

Future<Set<({int messageId, int attachmentId})>> _collectJoinPairs(
  Database messagesDb, {
  required Set<int> messageIds,
  required Set<int> attachmentIds,
  int? minAttachmentSourceRowIdExclusive,
}) async {
  final pairs = <({int messageId, int attachmentId})>{};

  Future<void> collectForIds(Set<int> ids, String column) async {
    if (ids.isEmpty) {
      return;
    }
    final ordered = ids.toList()..sort();
    const chunkSize = 200;
    var index = 0;
    while (index < ordered.length) {
      final end = (index + chunkSize > ordered.length)
          ? ordered.length
          : index + chunkSize;
      final chunk = ordered.sublist(index, end);
      final placeholders = List<String>.filled(chunk.length, '?').join(', ');
      final rows = await messagesDb.rawQuery(
        'SELECT message_id, attachment_id FROM message_attachment_join '
        'WHERE $column IN ($placeholders)',
        chunk.map<Object>((id) => id).toList(),
      );
      for (final row in rows) {
        final messageId = row['message_id'] as int?;
        final attachmentId = row['attachment_id'] as int?;
        if (messageId != null && attachmentId != null) {
          pairs.add(_pair(messageId, attachmentId));
        }
      }
      index = end;
    }
  }

  await collectForIds(messageIds, 'message_id');
  await collectForIds(attachmentIds, 'attachment_id');

  if (pairs.isEmpty && minAttachmentSourceRowIdExclusive != null) {
    final fallbackRows = await messagesDb.rawQuery(
      'SELECT message_id, attachment_id FROM message_attachment_join '
      'WHERE attachment_id > ?',
      <Object>[minAttachmentSourceRowIdExclusive],
    );
    for (final row in fallbackRows) {
      final messageId = row['message_id'] as int?;
      final attachmentId = row['attachment_id'] as int?;
      if (messageId != null && attachmentId != null) {
        pairs.add(_pair(messageId, attachmentId));
      }
    }
  }

  return pairs;
}

List<int> _readIntList(IImportContext ctx, String key) {
  final raw = ctx.readScratch<Object?>(key);
  if (raw is List<Object?>) {
    return raw
        .map(
          (value) => value is int
              ? value
              : value is num
              ? value.toInt()
              : int.tryParse('$value'),
        )
        .whereType<int>()
        .toList(growable: false);
  }
  if (raw is List<int>) {
    return List<int>.from(raw);
  }
  return <int>[];
}
