import 'package:drift/drift.dart' as drift;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import '../../../contacts/application/settings/contact_short_names_provider.dart';
import '../../application/calendar_heatmap_timeline_calculator.dart';
import '../../domain/calendar_heatmap_timeline_data.dart';
import '../../domain/chat_timeline_data.dart';

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
    required this.handles,
    required this.recency,
    required this.timelineData,
    required this.calendarHeatmapTimelineData,
  });

  final int chatId;
  final String title;
  final int messageCount;
  final DateTime? firstMessageDate;
  final DateTime? lastMessageDate;
  final bool isGroup;
  final List<String> participants;
  final List<String> handles;
  final ChatRecency? recency;
  final ChatTimelineData? timelineData;
  final CalendarHeatmapTimelineData? calendarHeatmapTimelineData;
}

@riverpod
Future<List<RecentChatSummary>> recentChats(Ref ref, {int? limit}) async {
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
    ]);

  if (limit != null) {
    chatsQuery.limit(limit);
  }

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

  print('[CHATS] Processing ${chatRows.length} chats...');

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
    final participantsQuery = db.select(db.chatToHandle).join([
      // Join chat_to_handle → handles
      drift.innerJoin(
        db.handlesCanonical,
        db.handlesCanonical.id.equalsExp(db.chatToHandle.handleId),
      ),
      // Left join handles → handle_to_participant (some handles may be unmatched)
      drift.leftOuterJoin(
        db.handleToParticipant,
        db.handleToParticipant.handleId.equalsExp(db.handlesCanonical.id),
      ),
      // Left join participants for resolved contacts (optional)
      drift.leftOuterJoin(
        db.workingParticipants,
        db.workingParticipants.id.equalsExp(
          db.handleToParticipant.participantId,
        ),
      ),
    ])..where(db.chatToHandle.chatId.equals(chat.id));

    String resolveParticipantName(WorkingParticipant participant) {
      final key = resolveContactKey(participant);
      final trimmedShortName = shortNames[key]?.trim();
      if (trimmedShortName != null && trimmedShortName.isNotEmpty) {
        return trimmedShortName;
      }

      final candidates = <String?>[
        participant.displayName,
        participant.originalName,
        () {
          final given = participant.givenName?.trim();
          final family = participant.familyName?.trim();
          if (given?.isNotEmpty == true && family?.isNotEmpty == true) {
            return '$given $family';
          }
          return given?.isNotEmpty == true ? given : family;
        }(),
        participant.organization,
      ];

      for (final candidate in candidates) {
        if (candidate != null && candidate.trim().isNotEmpty) {
          return candidate.trim();
        }
      }

      return 'Unknown Contact';
    }

    final participantRows = await participantsQuery.get();
    final participantNames = <String>[];
    final handleIdentifiers = <String>[];
    final seenNames = <String>{};

    for (final row in participantRows) {
      final handle = row.readTable(db.handlesCanonical);
      final participant = row.readTableOrNull(db.workingParticipants);

      // Store the display name (formatted phone number or email)
      handleIdentifiers.add(handle.displayName);

      // Debug logging for chat 279
      if (chat.id == 279) {
        print(
          '[DEBUG] Chat 279 - Handle ID: ${handle.id}, Raw: ${handle.rawIdentifier}, Display: ${handle.displayName}',
        );
        print(
          '[DEBUG] Chat 279 - Participant: ${participant?.id}, Display: ${participant?.displayName}',
        );
      }

      String resolvedName;
      if (participant != null) {
        // We have a matched participant (contact) - use their display name
        resolvedName = resolveParticipantName(participant);
        if (chat.id == 279) {
          print(
            '[DEBUG] Chat 279 - Resolved name from participant: $resolvedName',
          );
        }
      } else {
        // No matched participant - fall back to handle identifier
        final displayName = handle.displayName.trim();
        final rawIdentifier = handle.rawIdentifier.trim();
        final compoundIdentifier = handle.compoundIdentifier.trim();

        // Prefer display_name populated during migration for human readable output
        resolvedName = displayName.isNotEmpty
            ? displayName
            : rawIdentifier.isNotEmpty
            ? rawIdentifier
            : compoundIdentifier.isNotEmpty
            ? compoundIdentifier
            : 'Unknown Contact';

        if (chat.id == 279) {
          print(
            '[DEBUG] Chat 279 - No participant, using handle: $resolvedName',
          );
        }
      }

      final normalized = resolvedName.toLowerCase();
      final isSelfAlias = normalized == 'me';
      if (!isSelfAlias || chat.isGroup) {
        if (!seenNames.add(normalized)) {
          if (chat.id == 279) {
            print('[DEBUG] Chat 279 - Skipping duplicate name: $resolvedName');
          }
          continue;
        }
      }

      participantNames.add(resolvedName);
      if (chat.id == 279) {
        print('[DEBUG] Chat 279 - Added participant name: $resolvedName');
      }
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
    const ChatTimelineData? timelineData = null; // Old algorithms disabled

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

  print('[CHATS] Returning ${results.length} chat summaries');
  return results;
}
