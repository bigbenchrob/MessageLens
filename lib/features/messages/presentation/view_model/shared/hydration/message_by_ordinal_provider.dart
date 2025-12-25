import 'package:drift/drift.dart' as drift;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../../essentials/db/feature_level_providers.dart';
import '../../../../infrastructure/data_sources/message_index_data_source.dart';
import '../../deprecated/message_row_mapper.dart';
import 'messages_for_handle_provider.dart';

part 'message_by_ordinal_provider.g.dart';

/// Loads a message by its ordinal position within a chat.
/// Returns null if ordinal is out of range.
/// Uses auto-dispose for memory efficiency with large chats.
@riverpod
Future<MessageListItem?> messageByOrdinal(
  MessageByOrdinalRef ref, {
  required int chatId,
  required int ordinal,
}) async {
  final db = await ref.watch(driftWorkingDatabaseProvider.future);
  final indexSource = MessageIndexDataSource(db);

  // Get message ID for this ordinal
  final messageId = await indexSource.getMessageIdByOrdinal(chatId, ordinal);
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

  // Use existing mapper to convert row to MessageListItem
  final mapper = MessageRowMapper(db);
  final messages = await mapper.mapRows([row]);

  return messages.isEmpty ? null : messages.first;
}
