import 'dart:convert';
import 'dart:typed_data';

import '../../../../../core/util/date_converter.dart';
import '../../domain/base_table_importer.dart';
import '../../domain/row_progress_reporter.dart';
import '../../infrastructure/sqlite/import_context_sqlite.dart';

class MessagesImporter extends BaseTableImporter with RowProgressReporter {
  MessagesImporter();

  @override
  String get name => 'messages';

  @override
  List<String> get dependsOn => const <String>['chat_to_handle'];

  @override
  Future<void> validatePrereqs(IImportContext ctx) async {
    if (ctx.hasExistingLedgerData) {
      return;
    }
    final existingCount = await count(ctx.importDb, name);
    await expectZeroOrThrow(
      existingCount,
      'messages-not-empty',
      'Messages table must be empty before first ledger import.',
    );
  }

  @override
  Future<void> copy(IImportContext ctx) async {
    final minRowId = ctx.previousMaxMessageRowId;
    final rows = await ctx.messagesDb.query(
      'message',
      where: minRowId == null ? null : 'ROWID > ?',
      whereArgs: minRowId == null ? null : <Object>[minRowId],
      orderBy: 'ROWID ASC',
    );

    if (rows.isEmpty) {
      ctx.info('MessagesImporter: no new messages detected.');
      ctx.writeScratch('messages.inserted', 0);
      ctx.writeScratch('messages.insertedIds', <int>[]);
      ctx.writeScratch('messages.extractionCandidates', <int>[]);
      ctx.writeScratch('messages.messageToChat', <String, int>{});
      return;
    }

    // Pre-load all chat_message_join mappings to avoid per-row queries.
    final chatJoinRows = await ctx.messagesDb.query(
      'chat_message_join',
      columns: <String>['message_id', 'chat_id'],
    );
    final chatIdByMessage = <int, int>{};
    for (final jr in chatJoinRows) {
      final msgId = jr['message_id'];
      final chatId = jr['chat_id'];
      if (msgId is int && chatId is int) {
        chatIdByMessage[msgId] = chatId;
      }
    }

    final insertedIds = <int>[];
    final extractionCandidates = <int>{};
    final messageToChat = <int, int>{};

    var processed = 0;
    var inserted = 0;

    for (final row in rows) {
      final sourceRowId = row['ROWID'] as int?;
      final guid = row['guid'] as String?;
      if (sourceRowId == null || guid == null || guid.isEmpty) {
        processed += 1;
        continue;
      }

      final chatId = chatIdByMessage[sourceRowId];
      if (chatId == null) {
        processed += 1;
        continue;
      }

      final text = row['text'] as String?;
      final attributed = row['attributedBody'] as Uint8List?;
      final resolvedText = (text == null || text.isEmpty) ? null : text;
      final needsExtraction =
          (resolvedText == null || resolvedText.isEmpty) && attributed != null;
      if (needsExtraction) {
        extractionCandidates.add(sourceRowId);
      }

      final insertedId = await ctx.importDb.insertMessage(
        id: sourceRowId,
        sourceRowid: sourceRowId,
        guid: guid,
        chatId: chatId,
        senderHandleId: row['handle_id'] as int?,
        service: (row['service'] as String?)?.trim() ?? 'Unknown',
        isFromMe: (row['is_from_me'] as int? ?? 0) == 1,
        dateUtc: DateConverter.appleToIsoString(row['date']),
        dateReadUtc: DateConverter.appleToIsoString(row['date_read']),
        dateDeliveredUtc: DateConverter.appleToIsoString(row['date_delivered']),
        subject: (row['subject'] as String?)?.trim(),
        text: resolvedText,
        attributedBodyBlob: attributed,
        itemType: _inferItemType(row),
        errorCode: row['error'] as int?,
        isSystemMessage: (row['is_system_message'] as int? ?? 0) == 1,
        threadOriginatorGuid: row['thread_originator_guid'] as String?,
        associatedMessageGuid: row['associated_message_guid'] as String?,
        balloonBundleId: row['balloon_bundle_id'] as String?,
        payloadJson: _decodeOptionalBlob(row['payload_data']),
        batchId: ctx.batchId,
      );

      if (insertedId > 0) {
        inserted += 1;
        insertedIds.add(sourceRowId);
        messageToChat[sourceRowId] = chatId;
      }

      processed += 1;
      if (processed % 500 == 0 || processed == rows.length) {
        ctx.info(
          'MessagesImporter: processed $processed/${rows.length} messages '
          '(inserted $inserted)',
        );
        reportRowProgress(processed: processed, total: rows.length);
      }
    }

    ctx.writeScratch('messages.inserted', inserted);
    ctx.writeScratch('messages.insertedIds', insertedIds);
    ctx.writeScratch(
      'messages.extractionCandidates',
      extractionCandidates.toList(),
    );
    ctx.writeScratch(
      'messages.messageToChat',
      messageToChat.map((key, value) => MapEntry(key.toString(), value)),
    );

    if (rows.isNotEmpty) {
      final lastRowId = rows.last['ROWID'];
      if (lastRowId is int) {
        ctx.writeScratch('messages.lastSourceRowId', lastRowId);
      }
    }
  }

  @override
  Future<void> postValidate(IImportContext ctx) async {
    final total = await count(ctx.importDb, name);
    ctx.info('MessagesImporter: ledger now tracks $total messages.');
  }
}

String _inferItemType(Map<String, Object?> row) {
  final text = row['text'] as String?;
  final associated = row['associated_message_guid'] as String?;
  final balloonId = row['balloon_bundle_id'] as String?;
  final payloadBlob = row['payload_data'];
  final itemType = row['item_type'] as int?;

  if (itemType == 6 || (associated != null && associated.isNotEmpty)) {
    return 'reaction-carrier';
  }
  if (itemType == 8) {
    return 'sticker';
  }
  if (itemType == 0 && (text == null || text.isEmpty)) {
    if (balloonId != null && balloonId.isNotEmpty) {
      return 'balloon';
    }
    if (payloadBlob is Uint8List && payloadBlob.isNotEmpty) {
      return 'unknown';
    }
    return 'attachment-only';
  }
  if (itemType == 10) {
    return 'system';
  }
  return 'text';
}

String? _decodeOptionalBlob(Object? blob) {
  if (blob is Uint8List) {
    try {
      return utf8.decode(blob, allowMalformed: true);
    } catch (_) {
      return null;
    }
  }
  return null;
}
