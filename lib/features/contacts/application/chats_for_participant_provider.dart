import 'package:drift/drift.dart' as drift;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/db/feature_level_providers.dart';
import '../../chats/application/chat_timeline_calculator.dart';
import '../../chats/domain/chat_timeline_data.dart';
import '../../chats/presentation/view_model/recent_chats_provider.dart';

part 'chats_for_participant_provider.g.dart';

@riverpod
Future<List<RecentChatSummary>> chatsForParticipant(
  Ref ref, {
  required int participantId,
}) async {
  final db = await ref.watch(driftWorkingDatabaseProvider.future);

  // Get all handles for this participant
  final handlesQuery = db.select(db.workingHandles).join([
    drift.innerJoin(
      db.handleToParticipant,
      db.handleToParticipant.handleId.equalsExp(db.workingHandles.id),
    ),
  ])..where(db.handleToParticipant.participantId.equals(participantId));

  final handleRows = await handlesQuery.get();
  final handleIds = handleRows
      .map((row) => row.readTable(db.workingHandles).id)
      .toList();

  if (handleIds.isEmpty) {
    return [];
  }

  // Get all chats involving these handles
  final chatsQuery =
      db.select(db.workingChats).join([
          drift.innerJoin(
            db.chatToHandle,
            db.chatToHandle.chatId.equalsExp(db.workingChats.id),
          ),
        ])
        ..where(db.chatToHandle.handleId.isIn(handleIds))
        ..orderBy([
          drift.OrderingTerm(
            expression: db.workingChats.lastMessageAtUtc,
            mode: drift.OrderingMode.desc,
          ),
        ]);

  final chatRows = await chatsQuery.get();
  final chats = chatRows.map((row) => row.readTable(db.workingChats)).toList();

  // Build RecentChatSummary for each chat
  final results = <RecentChatSummary>[];

  for (final chat in chats) {
    // Get message statistics (count, first sent, last sent)
    final messageCountExpression = db.workingMessages.id.count();
    final firstSentExpression = db.workingMessages.sentAtUtc.min();
    final lastSentExpression = db.workingMessages.sentAtUtc.max();

    final messageStatsQuery = db.selectOnly(db.workingMessages)
      ..addColumns([
        messageCountExpression,
        firstSentExpression,
        lastSentExpression,
      ])
      ..where(db.workingMessages.chatId.equals(chat.id));

    final messageStatsRow = await messageStatsQuery.getSingleOrNull();
    final messageCount = messageStatsRow?.read(messageCountExpression) ?? 0;
    final firstSentUtc = messageStatsRow?.read(firstSentExpression);
    final lastSentUtc = messageStatsRow?.read(lastSentExpression);

    // Get all handles in this chat with their participants
    final chatHandlesQuery = db.select(db.workingHandles).join([
      drift.innerJoin(
        db.chatToHandle,
        db.chatToHandle.handleId.equalsExp(db.workingHandles.id),
      ),
      drift.leftOuterJoin(
        db.handleToParticipant,
        db.handleToParticipant.handleId.equalsExp(db.workingHandles.id),
      ),
      drift.leftOuterJoin(
        db.workingParticipants,
        db.workingParticipants.id.equalsExp(
          db.handleToParticipant.participantId,
        ),
      ),
    ])..where(db.chatToHandle.chatId.equals(chat.id));

    final chatHandleRows = await chatHandlesQuery.get();

    // Build participants list with short names and handles list
    final participantNames = <String>[];
    final handleIdentifiers = <String>[];
    for (final row in chatHandleRows) {
      final handle = row.readTable(db.workingHandles);
      final participant = row.readTableOrNull(db.workingParticipants);

      // Store the display name (formatted phone number or email)
      handleIdentifiers.add(handle.displayName);

      if (participant != null && participant.shortName.isNotEmpty) {
        // Use short_name from participant
        participantNames.add(participant.shortName);
      } else if (handle.displayName.isNotEmpty) {
        // Fallback to handle's display name
        participantNames.add(handle.displayName);
      } else {
        // Last resort: raw identifier
        participantNames.add(handle.rawIdentifier);
      }
    }

    // Format title based on participant count
    String title;
    if (participantNames.isEmpty) {
      title = chat.guid;
    } else if (participantNames.length == 1) {
      title = participantNames.first;
    } else if (participantNames.length == 2) {
      title = '${participantNames[0]} & ${participantNames[1]}';
    } else {
      // For 3+: "Name1, Name2 & Name3"
      final lastParticipant = participantNames.last;
      final otherParticipants = participantNames.sublist(
        0,
        participantNames.length - 1,
      );
      title = '${otherParticipants.join(', ')} & $lastParticipant';
    }

    // Parse dates from actual message timestamps
    DateTime? parseUtc(String? value) {
      if (value == null || value.isEmpty) {
        return null;
      }
      final parsed = DateTime.tryParse(value);
      return parsed?.toLocal();
    }

    final firstMessageDate = parseUtc(firstSentUtc);
    final lastMessageDate = parseUtc(lastSentUtc ?? chat.lastMessageAtUtc);

    // Calculate recency
    final recency = lastMessageDate != null
        ? ChatRecency.fromDateTime(lastMessageDate)
        : null;

    // Calculate timeline data if we have date range
    ChatTimelineData? timelineData;
    if (firstMessageDate != null && lastMessageDate != null) {
      timelineData = await calculateChatTimeline(
        db,
        chat.id,
        firstMessageDate,
        lastMessageDate,
      );
    }

    results.add(
      RecentChatSummary(
        chatId: chat.id,
        title: title,
        messageCount: messageCount,
        firstMessageDate: firstMessageDate,
        lastMessageDate: lastMessageDate,
        isGroup: chat.isGroup,
        participants: participantNames,
        handles: handleIdentifiers,
        recency: recency,
        timelineData: timelineData,
      ),
    );
  }

  return results;
}
