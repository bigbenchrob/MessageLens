import 'package:sqflite/sqflite.dart';

import '../../domain/base_table_importer.dart';
import '../../infrastructure/sqlite/import_context_sqlite.dart';

class MessageAttachmentsImporter extends BaseTableImporter {
  const MessageAttachmentsImporter();

  @override
  String get name => 'message_attachments';

  @override
  List<String> get dependsOn => const <String>['attachments'];

  @override
  Future<void> validatePrereqs(ImportContext ctx) async {
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
  Future<void> copy(ImportContext ctx) async {
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

    var processed = 0;
    var linked = 0;

    for (final pair in joinPairs) {
      final result = await ctx.importDb.insertMessageAttachment(
        messageId: pair.messageId,
        attachmentId: pair.attachmentId,
        sourceRowid: pair.attachmentId,
      );
      if (result != -1) {
        linked += 1;
      }

      processed += 1;
      if (processed % 200 == 0 || processed == joinPairs.length) {
        ctx.info(
          'MessageAttachmentsImporter: processed $processed/${joinPairs.length} '
          'pairs (linked $linked)',
        );
      }
    }

    ctx.writeScratch('messageAttachments.inserted', linked);
  }

  @override
  Future<void> postValidate(ImportContext ctx) async {
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

List<int> _readIntList(ImportContext ctx, String key) {
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
