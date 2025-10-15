import 'package:drift/drift.dart' as drift;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import '../../../../features/settings/application/contact_short_names/contact_short_names_controller.dart';

part 'chats_for_contact_provider.g.dart';

class ContactChatSummary {
  const ContactChatSummary({
    required this.chatId,
    required this.handle,
    required this.service,
    required this.title,
    required this.messageCount,
    required this.lastMessageDate,
  });

  final int chatId;
  final String handle;
  final String service;
  final String title;
  final int messageCount;
  final DateTime? lastMessageDate;
}

/// Provider that finds all chats involving a specific participant.
///
/// This enables the "Show all chats with Danny" feature by:
/// 1. Finding all handles linked to the participant via handle_to_participant
/// 2. Finding all chats using those handles
/// 3. Grouping by chat with handle/service details
@riverpod
Future<List<ContactChatSummary>> chatsForContact(
  Ref ref, {
  required int participantId,
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

  // Query: Find all chats for handles linked to this participant
  final query =
      db.select(db.workingChats).join([
          // Join chats → chat_to_handle → handles
          drift.innerJoin(
            db.chatToHandle,
            db.chatToHandle.chatId.equalsExp(db.workingChats.id),
          ),
          drift.innerJoin(
            db.workingHandles,
            db.workingHandles.id.equalsExp(db.chatToHandle.handleId),
          ),
          // Join handles → handle_to_participant
          drift.innerJoin(
            db.handleToParticipant,
            db.handleToParticipant.handleId.equalsExp(db.workingHandles.id),
          ),
          // Join handle_to_participant → participants
          drift.innerJoin(
            db.workingParticipants,
            db.workingParticipants.id.equalsExp(
              db.handleToParticipant.participantId,
            ),
          ),
        ])
        ..where(db.handleToParticipant.participantId.equals(participantId))
        ..orderBy([drift.OrderingTerm.desc(db.workingChats.lastMessageAtUtc)]);

  final rows = await query.get();
  final results = <ContactChatSummary>[];

  for (final row in rows) {
    final chat = row.readTable(db.workingChats);
    final handle = row.readTable(db.workingHandles);
    final participant = row.readTable(db.workingParticipants);

    // Get participant display name (with short name override if available)
    final participantKey = 'participant:${participant.id}';
    final shortName = shortNames[participantKey];
    final displayName = shortName?.isNotEmpty == true
        ? shortName!
        : participant.displayName;

    // Count messages in this chat
    final messageCount =
        await (db.selectOnly(db.workingMessages)
              ..addColumns([db.workingMessages.id.count()])
              ..where(db.workingMessages.chatId.equals(chat.id)))
            .getSingle()
            .then((row) => row.read(db.workingMessages.id.count()) ?? 0);

    final handleDisplay = handle.compoundIdentifier;

    // Create chat title based on whether it's a group or individual chat
    String chatTitle;
    if (chat.isGroup) {
      // For groups, use service info to distinguish conversations
      chatTitle = '$displayName (${handle.service} group)';
    } else {
      // For individual chats, use the handle to distinguish different conversations
      chatTitle = '$displayName ($handleDisplay)';
    }

    results.add(
      ContactChatSummary(
        chatId: chat.id,
        handle: handleDisplay,
        service: handle.service,
        title: chatTitle,
        messageCount: messageCount,
        lastMessageDate: parseUtc(chat.lastMessageAtUtc),
      ),
    );
  }

  return results;
}

/// Provider that gets participant info for display purposes
@riverpod
Future<WorkingParticipant?> participantInfo(
  Ref ref, {
  required int participantId,
}) async {
  final db = await ref.watch(driftWorkingDatabaseProvider.future);

  return (db.select(
    db.workingParticipants,
  )..where((p) => p.id.equals(participantId))).getSingleOrNull();
}
