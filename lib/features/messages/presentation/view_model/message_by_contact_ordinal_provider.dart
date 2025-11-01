import 'package:drift/drift.dart' as drift;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart';
import '../../infrastructure/data_sources/contact_message_index_data_source.dart';
import 'chat_message_row_mapper.dart';
import 'messages_for_chat_provider.dart';

part 'message_by_contact_ordinal_provider.g.dart';

/// Loads a message by its ordinal position within a contact's message history.
/// This shows messages across all chats/handles with the contact.
/// Returns null if ordinal is out of range.
/// Uses auto-dispose for memory efficiency.
@riverpod
Future<ChatMessageListItem?> messageByContactOrdinal(
  MessageByContactOrdinalRef ref, {
  required int contactId,
  required int ordinal,
}) async {
  final db = await ref.watch(driftWorkingDatabaseProvider.future);
  final indexSource = ContactMessageIndexDataSource(db);

  // Get message ID for this ordinal
  final messageId = await indexSource.getMessageIdByOrdinal(contactId, ordinal);
  if (messageId == null) {
    return null;
  }

  // Build query with standard joins for sender/participant/attachments
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
    return null;
  }

  // Use existing mapper to convert row to ChatMessageListItem
  final mapper = ChatMessageRowMapper(db);
  final messages = await mapper.mapRows([row]);

  return messages.isEmpty ? null : messages.first;
}
