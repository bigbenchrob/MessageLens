import 'package:drift/drift.dart' as drift;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../../essentials/db/feature_level_providers.dart';
import '../../../../domain/message_timeline_scope_extensions.dart';
import '../../../../domain/value_objects/message_timeline_scope.dart';
import '../../shared/hydration/messages_for_handle_provider.dart';
import '../../shared/message_row_mapper.dart';

part 'message_by_ordinal_provider.g.dart';

/// Unified provider to load a message by its ordinal position within a scope.
///
/// Works for all scopes (global, contact, chat) using the strategy pattern.
/// Returns null if ordinal is out of range.
/// Uses auto-dispose for memory efficiency.
@riverpod
Future<MessageListItem?> messageByTimelineOrdinal(
  MessageByTimelineOrdinalRef ref, {
  required MessageTimelineScope scope,
  required int ordinal,
}) async {
  final db = await ref.watch(driftWorkingDatabaseProvider.future);
  final strategy = scope.toOrdinalStrategy(db);

  // Get message ID from the appropriate index
  final messageId = await strategy.getMessageIdByOrdinal(ordinal);
  if (messageId == null) {
    return null;
  }

  // Shared query to get full message data with participant info
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

  final mapper = MessageRowMapper(db);
  final messages = await mapper.mapRows([row]);

  return messages.isEmpty ? null : messages.first;
}
