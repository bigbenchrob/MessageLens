import 'package:drift/drift.dart' as drift;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import '../../../settings/application/contact_short_names/contact_short_names_controller.dart';

part 'recent_chats_provider.g.dart';

/// Lightweight view model describing the data needed for the recent chats list.
class RecentChatSummary {
  const RecentChatSummary({
    required this.chatId,
    required this.title,
    required this.messageCount,
    required this.firstMessageDate,
    required this.lastMessageDate,
    required this.isGroup,
    required this.participants,
  });

  final int chatId;
  final String title;
  final int messageCount;
  final DateTime? firstMessageDate;
  final DateTime? lastMessageDate;
  final bool isGroup;
  final List<String> participants;
}

@riverpod
Future<List<RecentChatSummary>> recentChats(Ref ref, {int limit = 5}) async {
  final db = await ref.watch(driftWorkingDatabaseProvider.future);
  final shortNames = await ref.watch(contactShortNamesProvider.future);

  List<WorkingChat> chatRows;
  final chatsQuery = db.select(db.workingChats)
    ..orderBy([
      (tbl) => drift.OrderingTerm(
        expression: tbl.lastMessageAtUtc,
        mode: drift.OrderingMode.desc,
      ),
      (tbl) => drift.OrderingTerm(
        expression: tbl.updatedAtUtc,
        mode: drift.OrderingMode.desc,
      ),
      (tbl) => drift.OrderingTerm(expression: tbl.id),
    ])
    ..limit(limit);

  chatRows = await chatsQuery.get();

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
    // Since contact_ref is removed, use participant.id directly
    return 'participant:${participant.id}';
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

    // Query participants for this chat:
    // chats.handle_id → handle_to_participant → participants
    final participantsQuery = db.select(db.workingParticipants).join([
      // Join participants → handle_to_participant
      drift.innerJoin(
        db.handleToParticipant,
        db.handleToParticipant.participantId.equalsExp(
          db.workingParticipants.id,
        ),
      ),
      // Join handle_to_participant → handles
      drift.innerJoin(
        db.workingHandles,
        db.workingHandles.id.equalsExp(db.handleToParticipant.handleId),
      ),
    ])..where(db.workingHandles.id.equals(chat.handleId));

    final participantRows = await participantsQuery.get();
    final participantNames = <String>[];
    final seenNames = <String>{};

    for (final row in participantRows) {
      final participant = row.readTable(db.workingParticipants);

      final key = resolveContactKey(participant);
      final trimmedShortName = shortNames[key]?.trim();
      final trimmedParticipantName = participant.displayName.trim();

      var resolvedName = trimmedShortName;
      if (resolvedName == null || resolvedName.isEmpty) {
        resolvedName = trimmedParticipantName;
      }
      if (resolvedName.isEmpty) {
        resolvedName = 'Unknown Contact';
      }

      final normalized = resolvedName.toLowerCase();
      if (seenNames.add(normalized)) {
        participantNames.add(resolvedName);
      }
    }

    if (participantNames.isEmpty) {
      participantNames.add('Unknown Contact');
    }

    results.add(
      RecentChatSummary(
        chatId: chat.id,
        title: deriveTitle(chat, participantNames),
        messageCount: messageCount,
        firstMessageDate: parseUtc(firstSentUtc ?? chat.createdAtUtc),
        lastMessageDate: lastMessageDate,
        isGroup: chat.isGroup,
        participants: participantNames,
      ),
    );
  }

  return results;
}
