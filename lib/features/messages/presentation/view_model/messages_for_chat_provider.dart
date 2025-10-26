import 'package:drift/drift.dart' as drift;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'attachment_info.dart';
import 'attachment_info_loader.dart';

part 'messages_for_chat_provider.g.dart';

/// Lightweight view model representing a message row rendered in the UI.
class ChatMessageListItem {
  const ChatMessageListItem({
    required this.id,
    required this.guid,
    required this.isFromMe,
    required this.senderName,
    required this.text,
    required this.sentAt,
    required this.hasAttachments,
    this.attachments = const [],
  });

  final int id;
  final String guid;
  final bool isFromMe;
  final String senderName;
  final String text;
  final DateTime? sentAt;
  final bool hasAttachments;
  final List<AttachmentInfo> attachments;
}

@riverpod
Stream<List<ChatMessageListItem>> messagesForChat(
  MessagesForChatRef ref, {
  required int chatId,
}) async* {
  final db = await ref.watch(driftWorkingDatabaseProvider.future);

  DateTime? parseUtc(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final parsed = DateTime.tryParse(value);
    return parsed?.toLocal();
  }

  String senderNameForMessage({
    required bool isFromMe,
    required WorkingParticipant? participant,
  }) {
    if (isFromMe) {
      return 'You';
    }
    if (participant == null) {
      return 'Unknown sender';
    }
    return participant.displayName;
  }

  final query =
      db.select(db.workingMessages).join([
          // Join messages → handles
          drift.leftOuterJoin(
            db.handlesCanonical,
            db.handlesCanonical.id.equalsExp(db.workingMessages.senderHandleId),
          ),
          // Join handles → handle_to_participant
          drift.leftOuterJoin(
            db.handleToParticipant,
            db.handleToParticipant.handleId.equalsExp(db.handlesCanonical.id),
          ),
          // Join handle_to_participant → participants
          drift.leftOuterJoin(
            db.workingParticipants,
            db.workingParticipants.id.equalsExp(
              db.handleToParticipant.participantId,
            ),
          ),
        ])
        ..where(db.workingMessages.chatId.equals(chatId))
        ..orderBy([
          drift.OrderingTerm(
            expression: db.workingMessages.id,
            mode: drift.OrderingMode.asc,
          ),
        ]);

  yield* query.watch().asyncMap((rows) async {
    final items = <ChatMessageListItem>[];

    for (final row in rows) {
      final message = row.readTable(db.workingMessages);
      final participant = row.readTableOrNull(db.workingParticipants);

      // Fetch attachments for this message if it has any
      final attachments = message.hasAttachments
          ? await loadAttachmentsForMessage(db, message.guid)
          : <AttachmentInfo>[];

      items.add(
        ChatMessageListItem(
          id: message.id,
          guid: message.guid,
          isFromMe: message.isFromMe,
          senderName: senderNameForMessage(
            participant: participant,
            isFromMe: message.isFromMe,
          ),
          text: message.textContent ?? '[No text content]',
          sentAt: parseUtc(message.sentAtUtc),
          hasAttachments: message.hasAttachments,
          attachments: attachments,
        ),
      );
    }

    return items;
  });
}
