import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../db/infrastructure/data_sources/local/working/working_database.dart';
import 'attachment_payload.dart';
import 'chat_payload.dart';
import 'message_payload.dart';

class SupabasePayloadBuilder {
  const SupabasePayloadBuilder({
    required this.database,
    required this.ownerUserId,
  });

  final WorkingDatabase database;
  final String ownerUserId;

  static const int defaultBatchSize = 500;

  Future<List<SupabaseChatPayload>> buildChats({
    int? afterRowId,
    int limit = defaultBatchSize,
  }) async {
    final query = database.select(database.workingChats)
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.id)])
      ..limit(limit);

    if (afterRowId != null) {
      query.where((tbl) => tbl.id.isBiggerThanValue(afterRowId));
    }

    final rows = await query.get();
    return rows.map<SupabaseChatPayload>(_mapChatRow).toList(growable: false);
  }

  Future<List<SupabaseMessagePayload>> buildMessages({
    int? afterRowId,
    int limit = defaultBatchSize,
  }) async {
    final query = database.select(database.workingMessages)
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.id)])
      ..limit(limit);

    if (afterRowId != null) {
      query.where((tbl) => tbl.id.isBiggerThanValue(afterRowId));
    }

    final rows = await query.get();
    return rows
        .map<SupabaseMessagePayload>(_mapMessageRow)
        .toList(growable: false);
  }

  Future<List<SupabaseAttachmentPayload>> buildAttachments({
    int? afterRowId,
    int limit = defaultBatchSize,
  }) async {
    final query = database.select(database.workingAttachments)
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.id)])
      ..limit(limit);

    if (afterRowId != null) {
      query.where((tbl) => tbl.id.isBiggerThanValue(afterRowId));
    }

    final rows = await query.get();
    return rows
        .map<SupabaseAttachmentPayload>(_mapAttachmentRow)
        .toList(growable: false);
  }

  SupabaseChatPayload _mapChatRow(WorkingChat row) {
    return SupabaseChatPayload(
      ownerUserId: ownerUserId,
      guid: row.guid,
      service: row.service,
      isGroup: row.isGroup,
      lastMessageAtUtc: _parseUtcString(row.lastMessageAtUtc),
      lastSenderIdentityId: row.lastSenderHandleId,
      lastMessagePreview: row.lastMessagePreview,
      unreadCount: row.unreadCount,
      pinned: row.pinned,
      archived: row.archived,
      mutedUntilUtc: _parseUtcString(row.mutedUntilUtc),
      favourite: row.favourite,
      createdAtUtc: _parseUtcString(row.createdAtUtc),
      updatedAtUtc: _parseUtcString(row.updatedAtUtc),
    );
  }

  SupabaseMessagePayload _mapMessageRow(WorkingMessage row) {
    final reactionSummary = _decodeReactionSummary(row.reactionSummaryJson);

    return SupabaseMessagePayload(
      ownerUserId: ownerUserId,
      guid: row.guid,
      chatId: row.chatId,
      isFromMe: row.isFromMe,
      senderIdentityId: row.senderHandleId,
      sentAtUtc: _parseUtcString(row.sentAtUtc),
      deliveredAtUtc: _parseUtcString(row.deliveredAtUtc),
      readAtUtc: _parseUtcString(row.readAtUtc),
      status: row.status,
      text: row.textContent,
      hasAttachments: row.hasAttachments,
      replyToGuid: row.replyToGuid,
      systemType: row.systemType,
      reactionCarrier: row.reactionCarrier,
      balloonBundleId: row.balloonBundleId,
      reactionSummaryJson: reactionSummary,
      isStarred: row.isStarred,
      isDeletedLocal: row.isDeletedLocal,
      updatedAtUtc: _parseUtcString(row.updatedAtUtc),
    );
  }

  SupabaseAttachmentPayload _mapAttachmentRow(WorkingAttachment row) {
    return SupabaseAttachmentPayload(
      ownerUserId: ownerUserId,
      messageGuid: row.messageGuid,
      importAttachmentId: row.importAttachmentId,
      localPath: row.localPath,
      mimeType: row.mimeType,
      uti: row.uti,
      transferName: row.transferName,
      sizeBytes: row.sizeBytes,
      isSticker: row.isSticker,
      thumbPath: row.thumbPath,
      createdAtUtc: _parseUtcString(row.createdAtUtc),
    );
  }

  DateTime? _parseUtcString(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value)?.toUtc();
  }

  Map<String, dynamic>? _decodeReactionSummary(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}
