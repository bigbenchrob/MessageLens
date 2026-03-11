import 'package:drift/drift.dart' as drift;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../../essentials/db/feature_level_providers.dart';
import '../../../../../contacts/infrastructure/repositories/participant_merge_utils.dart';
import '../../shared/hydration/messages_for_handle_provider.dart';
import '../../shared/message_row_mapper.dart';

part 'message_by_id_provider.g.dart';

/// Provider to load and hydrate a single message by its ID.
///
/// Used for search results where we have message IDs but need full hydration.
/// Uses auto-dispose for memory efficiency during virtual scrolling.
@riverpod
Future<MessageListItem?> messageById(
  MessageByIdRef ref, {
  required int messageId,
}) async {
  final db = await ref.watch(driftWorkingDatabaseProvider.future);
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  final nameOverrides = await displayNameOverridesMap(overlayDb);

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

  final mapper = MessageRowMapper(db, nameOverrides);
  final messages = await mapper.mapRows([row]);

  return messages.isEmpty ? null : messages.first;
}
