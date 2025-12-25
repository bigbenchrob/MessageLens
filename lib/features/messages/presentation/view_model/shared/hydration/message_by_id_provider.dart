import 'package:drift/drift.dart' as drift;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../../essentials/db/feature_level_providers.dart';
import '../../../../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'attachment_info.dart';
import 'attachment_info_loader.dart';
import 'messages_for_handle_provider.dart';

part 'message_by_id_provider.g.dart';

@riverpod
Future<MessageListItem> messageById(
  MessageByIdRef ref, {
  required int messageId,
}) async {
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
          drift.leftOuterJoin(
            db.handlesCanonical,
            db.handlesCanonical.id.equalsExp(db.workingMessages.senderHandleId),
          ),
          drift.leftOuterJoin(
            db.handleToParticipant,
            db.handleToParticipant.handleId.equalsExp(db.handlesCanonical.id),
          ),
          drift.leftOuterJoin(
            db.workingParticipants,
            db.workingParticipants.id.equalsExp(
              db.handleToParticipant.participantId,
            ),
          ),
        ])
        ..where(db.workingMessages.id.equals(messageId))
        ..limit(1);

  final row = await query.getSingleOrNull();
  if (row == null) {
    throw StateError('Message $messageId not found');
  }

  final message = row.readTable(db.workingMessages);
  final participant = row.readTableOrNull(db.workingParticipants);

  final attachments = message.hasAttachments
      ? await loadAttachmentsForMessage(db, message.guid)
      : <AttachmentInfo>[];

  return MessageListItem(
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
  );
}
