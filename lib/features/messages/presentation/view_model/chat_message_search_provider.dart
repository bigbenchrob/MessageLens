import 'package:drift/drift.dart' as drift;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart';
import 'chat_message_row_mapper.dart';
import 'messages_for_chat_provider.dart';

part 'chat_message_search_provider.g.dart';

const _searchResultLimit = 100;

@riverpod
Future<List<ChatMessageListItem>> chatMessageSearchResults(
  ChatMessageSearchResultsRef ref, {
  required int chatId,
  required String query,
}) async {
  final trimmed = query.trim();
  if (trimmed.isEmpty) {
    return const [];
  }

  final db = await ref.watch(driftWorkingDatabaseProvider.future);
  final mapper = ChatMessageRowMapper(db);
  final lowerQuery = trimmed.toLowerCase();
  final pattern = '%$lowerQuery%';

  final queryBuilder =
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
        ..where(db.workingMessages.chatId.equals(chatId))
        ..where(db.workingMessages.textContent.isNotNull())
        ..where(db.workingMessages.textContent.lower().like(pattern))
        ..orderBy([
          drift.OrderingTerm(
            expression: db.workingMessages.id,
            mode: drift.OrderingMode.desc,
          ),
        ])
        ..limit(_searchResultLimit);

  final rows = await queryBuilder.get();
  if (rows.isEmpty) {
    return const [];
  }

  return mapper.mapRows(rows);
}
