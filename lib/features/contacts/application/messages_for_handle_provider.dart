import 'package:drift/drift.dart' as drift;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/db/feature_level_providers.dart';

part 'messages_for_handle_provider.freezed.dart';
part 'messages_for_handle_provider.g.dart';

@freezed
abstract class MessageWithChatContext with _$MessageWithChatContext {
  const factory MessageWithChatContext({
    required int messageId,
    required String messageGuid,
    required int chatId,
    required String chatGuid,
    required String? chatDisplayName,
    required String text,
    required bool isFromMe,
    required DateTime sentAt,
    required String? senderHandleRaw,
    required String? senderHandleDisplay,
  }) = _MessageWithChatContext;
}

@riverpod
Future<List<MessageWithChatContext>> messagesForHandle(
  Ref ref, {
  required int handleId,
}) async {
  final db = await ref.watch(driftWorkingDatabaseProvider.future);

  // Query messages where this handle is either:
  // 1. The sender (sender_handle_id = handleId)
  // 2. The primary handle of a chat (via chat_to_handle)

  // First, get all messages sent by this handle
  final sentMessagesQuery =
      db.select(db.workingMessages).join([
          drift.innerJoin(
            db.workingChats,
            db.workingChats.id.equalsExp(db.workingMessages.chatId),
          ),
          drift.leftOuterJoin(
            db.workingHandles,
            db.workingHandles.id.equalsExp(db.workingMessages.senderHandleId),
          ),
        ])
        ..where(db.workingMessages.senderHandleId.equals(handleId))
        ..orderBy([
          drift.OrderingTerm(
            expression: db.workingMessages.sentAtUtc,
            mode: drift.OrderingMode.asc,
          ),
        ]);

  final sentMessageRows = await sentMessagesQuery.get();

  // Second, get all messages in chats where this handle is involved
  final chatIdsQuery = db.selectOnly(db.chatToHandle)
    ..addColumns([db.chatToHandle.chatId])
    ..where(db.chatToHandle.handleId.equals(handleId));

  final chatIdRows = await chatIdsQuery.get();
  final chatIds = chatIdRows
      .map((row) => row.read(db.chatToHandle.chatId))
      .whereType<int>()
      .toList();

  final chatMessagesQuery =
      db.select(db.workingMessages).join([
          drift.innerJoin(
            db.workingChats,
            db.workingChats.id.equalsExp(db.workingMessages.chatId),
          ),
          drift.leftOuterJoin(
            db.workingHandles,
            db.workingHandles.id.equalsExp(db.workingMessages.senderHandleId),
          ),
        ])
        ..where(db.workingMessages.chatId.isIn(chatIds))
        ..orderBy([
          drift.OrderingTerm(
            expression: db.workingMessages.sentAtUtc,
            mode: drift.OrderingMode.asc,
          ),
        ]);

  final chatMessageRows = await chatMessagesQuery.get();

  // Combine and deduplicate messages
  final allRows = [...sentMessageRows, ...chatMessageRows];
  final seenMessageIds = <int>{};
  final uniqueRows = allRows.where((row) {
    final message = row.readTable(db.workingMessages);
    if (seenMessageIds.contains(message.id)) {
      return false;
    }
    seenMessageIds.add(message.id);
    return true;
  }).toList();

  // Sort by sent time
  uniqueRows.sort((a, b) {
    final aMessage = a.readTable(db.workingMessages);
    final bMessage = b.readTable(db.workingMessages);
    final aTime = aMessage.sentAtUtc ?? '';
    final bTime = bMessage.sentAtUtc ?? '';
    return aTime.compareTo(bTime);
  });

  // Build result list
  final results = <MessageWithChatContext>[];

  for (final row in uniqueRows) {
    final message = row.readTable(db.workingMessages);
    final chat = row.readTable(db.workingChats);
    final senderHandle = row.readTableOrNull(db.workingHandles);

    // Parse sent date
    DateTime? sentAt;
    if (message.sentAtUtc != null && message.sentAtUtc!.isNotEmpty) {
      final parsed = DateTime.tryParse(message.sentAtUtc!);
      sentAt = parsed?.toLocal();
    }

    if (sentAt == null) {
      continue; // Skip messages without valid timestamps
    }

    // Build chat display name
    String? chatDisplayName;
    if (chat.guid.isNotEmpty) {
      // Try to get participants for this chat
      final chatHandlesQuery = db.select(db.workingHandles).join([
        drift.innerJoin(
          db.chatToHandle,
          db.chatToHandle.handleId.equalsExp(db.workingHandles.id),
        ),
      ])..where(db.chatToHandle.chatId.equals(chat.id));

      final chatHandleRows = await chatHandlesQuery.get();
      final chatHandles = chatHandleRows
          .map((r) => r.readTable(db.workingHandles))
          .toList();

      if (chatHandles.isNotEmpty) {
        chatDisplayName = chatHandles
            .map(
              (h) => h.displayName.isNotEmpty ? h.displayName : h.rawIdentifier,
            )
            .join(', ');
      } else {
        chatDisplayName = chat.guid;
      }
    }

    results.add(
      MessageWithChatContext(
        messageId: message.id,
        messageGuid: message.guid,
        chatId: chat.id,
        chatGuid: chat.guid,
        chatDisplayName: chatDisplayName,
        text: message.textContent ?? '',
        isFromMe: message.isFromMe,
        sentAt: sentAt,
        senderHandleRaw: senderHandle?.rawIdentifier,
        senderHandleDisplay: senderHandle?.displayName.isNotEmpty == true
            ? senderHandle!.displayName
            : null,
      ),
    );
  }

  return results;
}
