import 'package:drift/drift.dart' as drift;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/db/feature_level_providers.dart';
import '../../../essentials/navigation/domain/entities/features/contacts_list_spec.dart';

part 'contacts_list_provider.freezed.dart';
part 'contacts_list_provider.g.dart';

@freezed
abstract class ContactSummary with _$ContactSummary {
  const factory ContactSummary({
    required int participantId,
    required String displayName,
    required String shortName,
    required int totalChats,
    required int totalMessages,
    DateTime? lastMessageDate,
  }) = _ContactSummary;
}

@riverpod
Future<List<ContactSummary>> contactsList(
  Ref ref, {
  required ContactsListSpec spec,
}) async {
  final db = await ref.watch(driftWorkingDatabaseProvider.future);

  // Query participants who have at least one handle
  // Join chain: participants → handle_to_participant → handles → chat_to_handle → chats

  final participantsQuery = db.select(db.workingParticipants)
    ..where(
      (tbl) => drift.existsQuery(
        db.select(db.handleToParticipant)
          ..where((h2p) => h2p.participantId.equalsExp(tbl.id)),
      ),
    );

  // Apply ordering based on spec variant
  spec.when(
    all: () {
      // Default ordering by last message date
      // Note: This requires a subquery, for now use display name
      participantsQuery.orderBy([
        (tbl) => drift.OrderingTerm(expression: tbl.displayName),
      ]);
    },
    alphabetical: () {
      // Alphabetical ordering
      participantsQuery.orderBy([
        (tbl) => drift.OrderingTerm(expression: tbl.displayName),
      ]);
    },
    favorites: () {
      // TODO: Filter by favorite status once implemented in database
      // For now, just show all contacts alphabetically
      participantsQuery.orderBy([
        (tbl) => drift.OrderingTerm(expression: tbl.displayName),
      ]);
    },
  );

  final participants = await participantsQuery.get();

  final results = <ContactSummary>[];

  for (final participant in participants) {
    // Get all handles for this participant
    final handlesQuery = db.select(db.workingHandles).join([
      drift.innerJoin(
        db.handleToParticipant,
        db.handleToParticipant.handleId.equalsExp(db.workingHandles.id),
      ),
    ])..where(db.handleToParticipant.participantId.equals(participant.id));

    final handleRows = await handlesQuery.get();
    final handleIds = handleRows
        .map((row) => row.readTable(db.workingHandles).id)
        .toList();

    if (handleIds.isEmpty) {
      continue;
    }

    // Count chats involving these handles
    final chatsQuery = db.selectOnly(db.chatToHandle)
      ..addColumns([db.chatToHandle.chatId.count()])
      ..where(db.chatToHandle.handleId.isIn(handleIds));

    final chatCountRow = await chatsQuery.getSingleOrNull();
    final totalChats = chatCountRow?.read(db.chatToHandle.chatId.count()) ?? 0;

    // Count total messages across all chats involving these handles
    final messagesQuery =
        db.selectOnly(db.workingMessages).join([
            drift.innerJoin(
              db.chatToHandle,
              db.chatToHandle.chatId.equalsExp(db.workingMessages.chatId),
            ),
          ])
          ..addColumns([db.workingMessages.id.count()])
          ..where(db.chatToHandle.handleId.isIn(handleIds));

    final messageCountRow = await messagesQuery.getSingleOrNull();
    final totalMessages =
        messageCountRow?.read(db.workingMessages.id.count()) ?? 0;

    // Get last message date
    final lastMessageQuery =
        db.selectOnly(db.workingMessages).join([
            drift.innerJoin(
              db.chatToHandle,
              db.chatToHandle.chatId.equalsExp(db.workingMessages.chatId),
            ),
          ])
          ..addColumns([db.workingMessages.sentAtUtc.max()])
          ..where(db.chatToHandle.handleId.isIn(handleIds));

    final lastMessageRow = await lastMessageQuery.getSingleOrNull();
    final lastMessageUtc = lastMessageRow?.read(
      db.workingMessages.sentAtUtc.max(),
    );

    DateTime? lastMessageDate;
    if (lastMessageUtc != null && lastMessageUtc.isNotEmpty) {
      final parsed = DateTime.tryParse(lastMessageUtc);
      lastMessageDate = parsed?.toLocal();
    }

    results.add(
      ContactSummary(
        participantId: participant.id,
        displayName: participant.displayName,
        shortName: participant.shortName,
        totalChats: totalChats,
        totalMessages: totalMessages,
        lastMessageDate: lastMessageDate,
      ),
    );
  }

  return results;
}
