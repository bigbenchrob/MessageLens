import 'package:drift/drift.dart' as drift;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../../essentials/db/feature_level_providers.dart';
import '../../../../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import '../../../../../contacts/infrastructure/repositories/participant_merge_utils.dart';
import 'attachment_info.dart';
import 'attachment_info_loader.dart';

part 'messages_for_handle_provider.g.dart';

/// Lightweight view model representing a message row rendered in the UI.
/// Export this class so it can be used throughout the codebase.
class MessageListItem {
  const MessageListItem({
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
Stream<List<MessageListItem>> messagesForHandle(
  MessagesForHandleRef ref, {
  required int handleId,
}) async* {
  final db = await ref.watch(driftWorkingDatabaseProvider.future);
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  final nameOverrides = await displayNameOverridesMap(overlayDb);

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
    final override = nameOverrides[participant.id];
    if (override != null) {
      return override;
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
        ..where(db.workingMessages.chatId.equals(handleId))
        ..orderBy([
          drift.OrderingTerm(
            expression: db.workingMessages.id,
            mode: drift.OrderingMode.asc,
          ),
        ]);

  yield* query.watch().asyncMap((rows) async {
    final items = <MessageListItem>[];

    for (final row in rows) {
      final message = row.readTable(db.workingMessages);
      final participant = row.readTableOrNull(db.workingParticipants);

      // Fetch attachments for this message if it has any
      final attachments = message.hasAttachments
          ? await loadAttachmentsForMessage(db, message.guid)
          : <AttachmentInfo>[];

      items.add(
        MessageListItem(
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
