import 'package:drift/drift.dart' as drift;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../../essentials/db/feature_level_providers.dart';
import '../../../../infrastructure/data_sources/global_message_index_data_source.dart';
import '../../shared/message_row_mapper.dart';
import '../../shared/hydration/messages_for_handle_provider.dart';

part 'message_by_global_ordinal_provider.g.dart';

/// Loads a message by its ordinal position within the global message timeline.
/// Returns null if ordinal is out of range.
@riverpod
Future<MessageListItem?> messageByGlobalOrdinal(
  MessageByGlobalOrdinalRef ref, {
  required int ordinal,
}) async {
  final db = await ref.watch(driftWorkingDatabaseProvider.future);
  final indexSource = GlobalMessageIndexDataSource(db);

  final entry = await indexSource.getByOrdinal(ordinal);
  if (entry == null) {
    return null;
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
        ..where(db.workingMessages.id.equals(entry.messageId))
        ..limit(1);

  final row = await query.getSingleOrNull();
  if (row == null) {
    return null;
  }

  final mapper = MessageRowMapper(db);
  final messages = await mapper.mapRows([row]);

  if (messages.isEmpty) {
    return null;
  }

  // TODO(Ftr.global): ensure global timeline row shows a prominent correspondent
  // label (name + handle) even when chats are mixed. This will likely be done
  // by wrapping MessageListItem in a global-specific UI model.
  return messages.first;
}
