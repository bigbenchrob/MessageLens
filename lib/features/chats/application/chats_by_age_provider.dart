import 'package:drift/drift.dart' as drift;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/db/domain/overlay_db_constants.dart';
import '../../../essentials/db/feature_level_providers.dart';
import '../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import '../../contacts/application/settings/contact_name_mode_provider.dart';
import '../../contacts/application/settings/contact_short_names_provider.dart';
import '../../contacts/domain/participant_name_resolver.dart';
import '../domain/chat_timeline_data.dart';
import '../presentation/view_model/recent_chats_provider.dart';
import 'calendar_heatmap_timeline_calculator.dart';

part 'chats_by_age_provider.g.dart';

/// Returns chats ordered by first message date (oldest first).
@riverpod
Future<List<RecentChatSummary>> chatsByAge(Ref ref, {int? limit}) async {
  final db = await ref.watch(driftWorkingDatabaseProvider.future);
  final shortNames = await ref.watch(contactShortNamesProvider.future);
  final nameMode = await ref.watch(contactNameModeProvider.future);

  final chatsQuery = db.select(db.workingChats)
    ..orderBy([
      (tbl) => drift.OrderingTerm(
        expression: tbl.createdAtUtc,
        mode: drift.OrderingMode.asc,
      ),
      (tbl) => drift.OrderingTerm(expression: tbl.id),
    ]);

  if (limit != null) {
    chatsQuery.limit(limit);
  }

  final chatRows = await chatsQuery.get();

  return _buildChatSummaries(
    db: db,
    chatRows: chatRows,
    shortNames: shortNames,
    nameMode: nameMode,
  );
}

/// Returns chats ordered by first message date (newest first).
@riverpod
Future<List<RecentChatSummary>> chatsByAgeRecent(Ref ref, {int? limit}) async {
  final db = await ref.watch(driftWorkingDatabaseProvider.future);
  final shortNames = await ref.watch(contactShortNamesProvider.future);
  final nameMode = await ref.watch(contactNameModeProvider.future);

  final chatsQuery = db.select(db.workingChats)
    ..orderBy([
      (tbl) => drift.OrderingTerm(
        expression: tbl.createdAtUtc,
        mode: drift.OrderingMode.desc,
      ),
      (tbl) => drift.OrderingTerm(expression: tbl.id),
    ]);

  if (limit != null) {
    chatsQuery.limit(limit);
  }

  final chatRows = await chatsQuery.get();

  return _buildChatSummaries(
    db: db,
    chatRows: chatRows,
    shortNames: shortNames,
    nameMode: nameMode,
  );
}

/// Returns chats where the handle has no participant match (unmatched phone numbers/emails).
@riverpod
Future<List<RecentChatSummary>> unmatchedChats(Ref ref, {int? limit}) async {
  final db = await ref.watch(driftWorkingDatabaseProvider.future);
  final shortNames = await ref.watch(contactShortNamesProvider.future);
  final nameMode = await ref.watch(contactNameModeProvider.future);

  // Find chats whose handle_id does NOT appear in handle_to_participant
  final unmatchedHandleIds =
      await (db.selectOnly(db.handlesCanonical)
            ..addColumns([db.handlesCanonical.id])
            ..where(
              drift.notExistsQuery(
                db.select(db.handleToParticipant)..where(
                  (tbl) => tbl.handleId.equalsExp(db.handlesCanonical.id),
                ),
              ),
            ))
          .map((row) => row.read(db.handlesCanonical.id)!)
          .get();

  if (unmatchedHandleIds.isEmpty) {
    return [];
  }

  // Now find chats using those handles
  final chatHandleQuery = db.select(db.chatToHandle)
    ..where((tbl) => tbl.handleId.isIn(unmatchedHandleIds));

  final chatHandleRows = await chatHandleQuery.get();
  final unmatchedChatIds = chatHandleRows
      .map((row) => row.chatId)
      .toSet()
      .toList();

  if (unmatchedChatIds.isEmpty) {
    return [];
  }

  final chatsQuery = db.select(db.workingChats)
    ..where((tbl) => tbl.id.isIn(unmatchedChatIds))
    ..orderBy([
      (tbl) => drift.OrderingTerm(
        expression: tbl.lastMessageAtUtc,
        mode: drift.OrderingMode.desc,
      ),
      (tbl) => drift.OrderingTerm(expression: tbl.id),
    ]);

  if (limit != null) {
    chatsQuery.limit(limit);
  }

  final chatRows = await chatsQuery.get();

  return _buildChatSummaries(
    db: db,
    chatRows: chatRows,
    shortNames: shortNames,
    nameMode: nameMode,
  );
}

/// Shared logic to build RecentChatSummary list from chat rows.
/// Extracted from recentChatsProvider to avoid duplication.
Future<List<RecentChatSummary>> _buildChatSummaries({
  required WorkingDatabase db,
  required List<WorkingChat> chatRows,
  required Map<String, String> shortNames,
  required ParticipantNameMode nameMode,
}) async {
  final messageCountExpression = db.workingMessages.id.count();
  final firstSentExpression = db.workingMessages.sentAtUtc.min();
  final lastSentExpression = db.workingMessages.sentAtUtc.max();

  DateTime? parseUtc(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final parsed = DateTime.tryParse(value);
    return parsed?.toLocal();
  }

  String resolveContactKey(WorkingParticipant participant) {
    return 'participant:${participant.id}';
  }

  String resolveParticipantName(WorkingParticipant participant) {
    final key = resolveContactKey(participant);
    final nickname = shortNames[key];
    return ParticipantNameResolver.resolve(
      participant: participant,
      mode: nameMode,
      nickname: nickname,
    );
  }

  String deriveTitle(WorkingChat chat, List<String> participants) {
    if (participants.isEmpty) {
      return 'Unnamed Conversation';
    }

    if (!chat.isGroup && participants.isNotEmpty) {
      return participants.first;
    }

    if (participants.length == 1) {
      return participants.first;
    }

    if (participants.length == 2) {
      return '${participants[0]} and ${participants[1]}';
    }

    final remainingCount = participants.length - 2;
    return '${participants[0]}, ${participants[1]} + $remainingCount more';
  }

  final results = <RecentChatSummary>[];

  for (final chat in chatRows) {
    final stats =
        await (db.selectOnly(db.workingMessages)
              ..where(db.workingMessages.chatId.equals(chat.id))
              ..addColumns([
                messageCountExpression,
                firstSentExpression,
                lastSentExpression,
              ]))
            .getSingleOrNull();

    final messageCount = stats?.read(messageCountExpression) ?? 0;
    final firstSentUtc = stats?.read(firstSentExpression);
    final lastSentUtc = stats?.read(lastSentExpression);

    final lastMessageDate = parseUtc(lastSentUtc ?? chat.lastMessageAtUtc);

    final participantsQuery = db.select(db.chatToHandle).join([
      drift.innerJoin(
        db.handlesCanonical,
        db.handlesCanonical.id.equalsExp(db.chatToHandle.handleId),
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
    ])..where(db.chatToHandle.chatId.equals(chat.id));

    final participantRows = await participantsQuery.get();
    final participantNames = <String>[];
    final handleIdentifiers = <String>[];
    final seenNames = <String>{};

    for (final row in participantRows) {
      final handle = row.readTable(db.handlesCanonical);
      final participant = row.readTableOrNull(db.workingParticipants);

      // Store the display name (formatted phone number or email)
      handleIdentifiers.add(handle.displayName);

      String resolvedName;
      if (participant != null) {
        resolvedName = resolveParticipantName(participant);
      } else {
        final displayName = handle.displayName.trim();
        final rawIdentifier = handle.rawIdentifier.trim();
        final compoundIdentifier = handle.compoundIdentifier.trim();

        resolvedName = displayName.isNotEmpty
            ? displayName
            : rawIdentifier.isNotEmpty
            ? rawIdentifier
            : compoundIdentifier.isNotEmpty
            ? compoundIdentifier
            : 'Unknown Contact';
      }

      final normalized = resolvedName.toLowerCase();
      final isSelfAlias = normalized == 'me';
      if (!isSelfAlias || chat.isGroup) {
        if (!seenNames.add(normalized)) {
          continue;
        }
      }

      participantNames.add(resolvedName);
    }

    if (participantNames.isEmpty) {
      participantNames.add('Unknown Contact');
    }

    // Calculate recency from last message date
    final recency = lastMessageDate != null
        ? ChatRecency.fromDateTime(lastMessageDate)
        : null;

    // Calculate calendar heatmap timeline data
    final firstMsgDate = parseUtc(firstSentUtc ?? chat.createdAtUtc);
    const ChatTimelineData? timelineData = null; // Old timeline disabled
    final calendarHeatmapTimelineData = await calculateCalendarHeatmapTimeline(
      db,
      chat.id,
      firstMsgDate,
      lastMessageDate,
    );

    results.add(
      RecentChatSummary(
        chatId: chat.id,
        title: deriveTitle(chat, participantNames),
        messageCount: messageCount,
        firstMessageDate: firstMsgDate,
        lastMessageDate: lastMessageDate,
        isGroup: chat.isGroup,
        participants: participantNames,
        handles: handleIdentifiers,
        recency: recency,
        timelineData: timelineData,
        calendarHeatmapTimelineData: calendarHeatmapTimelineData,
      ),
    );
  }

  return results;
}
