import 'package:drift/drift.dart' as drift;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import '../../../chats/domain/chat_timeline_data.dart';
import '../../../settings/application/contact_short_names/contact_short_names_controller.dart';

part 'chat_header_info_provider.g.dart';

class ChatHeaderInfo {
  const ChatHeaderInfo({
    required this.chatId,
    required this.title,
    required this.participants,
    required this.handles,
    required this.isGroup,
    required this.messageCount,
    required this.firstMessageDate,
    required this.lastMessageDate,
    required this.recency,
  });

  final int chatId;
  final String title;
  final List<String> participants;
  final List<String> handles;
  final bool isGroup;
  final int messageCount;
  final DateTime? firstMessageDate;
  final DateTime? lastMessageDate;
  final ChatRecency? recency;
}

@riverpod
Future<ChatHeaderInfo> chatHeaderInfo(
  ChatHeaderInfoRef ref, {
  required int chatId,
}) async {
  final db = await ref.watch(driftWorkingDatabaseProvider.future);
  final shortNames = await ref.watch(contactShortNamesProvider.future);

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

  final chatRow = await (db.select(
    db.workingChats,
  )..where((tbl) => tbl.id.equals(chatId))).getSingleOrNull();

  if (chatRow == null) {
    throw StateError('Chat $chatId not found');
  }

  final messageCountExpression = db.workingMessages.id.count();
  final firstSentExpression = db.workingMessages.sentAtUtc.min();
  final lastSentExpression = db.workingMessages.sentAtUtc.max();

  final stats =
      await (db.selectOnly(db.workingMessages)
            ..where(db.workingMessages.chatId.equals(chatId))
            ..addColumns([
              messageCountExpression,
              firstSentExpression,
              lastSentExpression,
            ]))
          .getSingleOrNull();

  final messageCount = stats?.read(messageCountExpression) ?? 0;
  final firstSentUtc = stats?.read(firstSentExpression);
  final lastSentUtc = stats?.read(lastSentExpression);

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
      db.workingParticipants.id.equalsExp(db.handleToParticipant.participantId),
    ),
  ])..where(db.chatToHandle.chatId.equals(chatId));

  final participantRows = await participantsQuery.get();
  final participantNames = <String>[];
  final handleIdentifiers = <String>[];
  final seenNames = <String>{};

  for (final row in participantRows) {
    final handle = row.readTable(db.handlesCanonical);
    final participant = row.readTableOrNull(db.workingParticipants);

    handleIdentifiers.add(_resolveHandleDisplay(handle));

    String resolvedName;
    if (participant != null) {
      resolvedName = resolveParticipantName(participant);
    } else {
      resolvedName = _resolveHandleDisplay(handle);
    }

    final normalized = resolvedName.toLowerCase();
    final isSelfAlias = normalized == 'me';
    if (!isSelfAlias || chatRow.isGroup) {
      if (!seenNames.add(normalized)) {
        continue;
      }
    }

    participantNames.add(resolvedName);
  }

  if (participantNames.isEmpty) {
    participantNames.add('Unknown Contact');
  }

  final lastMessageDate = parseUtc(lastSentUtc ?? chatRow.lastMessageAtUtc);
  final firstMessageDate = parseUtc(firstSentUtc ?? chatRow.createdAtUtc);
  final recency = lastMessageDate != null
      ? ChatRecency.fromDateTime(lastMessageDate)
      : null;

  return ChatHeaderInfo(
    chatId: chatRow.id,
    title: deriveTitle(chatRow, participantNames),
    participants: participantNames,
    handles: handleIdentifiers,
    isGroup: chatRow.isGroup,
    messageCount: messageCount,
    firstMessageDate: firstMessageDate,
    lastMessageDate: lastMessageDate,
    recency: recency,
  );
}

String _resolveHandleDisplay(HandlesCanonicalData handle) {
  final displayName = handle.displayName.trim();
  if (displayName.isNotEmpty) {
    return displayName;
  }
  final rawIdentifier = handle.rawIdentifier.trim();
  if (rawIdentifier.isNotEmpty) {
    return rawIdentifier;
  }
  final compoundIdentifier = handle.compoundIdentifier.trim();
  if (compoundIdentifier.isNotEmpty) {
    return compoundIdentifier;
  }
  return 'Unknown Handle';
}
