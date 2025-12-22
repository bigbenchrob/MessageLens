import 'package:drift/drift.dart' as drift;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import '../../../../essentials/navigation/domain/entities/features/contacts_list_spec.dart';
import '../../application_pre_cassette/participant_merge_utils.dart';
import '../../application_pre_cassette/virtual_participants_provider.dart';
import '../../domain/participant_origin.dart';

part 'contacts_list_repository.freezed.dart';
part 'contacts_list_repository.g.dart';

@freezed
abstract class ContactSummary with _$ContactSummary {
  const factory ContactSummary({
    required int participantId,
    required String displayName,
    required String shortName,
    required int totalChats,
    required int totalMessages,
    DateTime? lastMessageDate,
    required ParticipantOrigin origin,
    required int handleCount,
  }) = _ContactSummary;

  const ContactSummary._();

  bool get isVirtual => origin == ParticipantOrigin.overlayVirtual;
}

@riverpod
Future<List<ContactSummary>> contactsListRepository(
  Ref ref, {
  required ContactsListSpec spec,
}) async {
  final workingDb = await ref.watch(driftWorkingDatabaseProvider.future);
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  final virtualContacts = await ref.watch(virtualParticipantsProvider.future);

  final overlayHandlesByParticipant = await overlayHandleIdsByParticipant(
    overlayDb,
  );
  final participantOverrides = await participantOverridesById(overlayDb);
  final overlayHandleCounts = await overlayHandleCountsByParticipant(overlayDb);

  final participantsQuery = workingDb.select(workingDb.workingParticipants)
    ..where(
      (tbl) => drift.existsQuery(
        workingDb.select(workingDb.handleToParticipant)
          ..where((h2p) => h2p.participantId.equalsExp(tbl.id)),
      ),
    );

  spec.when(
    all: () {
      participantsQuery.orderBy([
        (tbl) => drift.OrderingTerm(expression: tbl.displayName),
      ]);
    },
    alphabetical: () {
      participantsQuery.orderBy([
        (tbl) => drift.OrderingTerm(expression: tbl.displayName),
      ]);
    },
    favorites: () {
      participantsQuery.orderBy([
        (tbl) => drift.OrderingTerm(expression: tbl.displayName),
      ]);
    },
  );

  final participants = (await participantsQuery.get())
      .where(
        (participant) => !isPlaceholderDisplayName(participant.displayName),
      )
      .toList(growable: false);

  final workingSummaries = <ContactSummary>[];

  for (final participant in participants) {
    final handlesQuery =
        workingDb.select(workingDb.handlesCanonical).join([
          drift.innerJoin(
            workingDb.handleToParticipant,
            workingDb.handleToParticipant.handleId.equalsExp(
              workingDb.handlesCanonical.id,
            ),
          ),
        ])..where(
          workingDb.handleToParticipant.participantId.equals(participant.id),
        );

    final handleRows = await handlesQuery.get();
    final handleIds = <int>{
      for (final row in handleRows)
        row.readTable(workingDb.handlesCanonical).id,
    };

    final overlayHandleIds = overlayHandlesByParticipant[participant.id];

    if (overlayHandleIds != null && overlayHandleIds.isNotEmpty) {
      handleIds.addAll(overlayHandleIds);
    }

    if (handleIds.isEmpty) {
      continue;
    }

    final metrics = await _calculateMetrics(
      workingDb,
      handleIds.toList(growable: false),
    );

    final override = participantOverrides[participant.id];

    final origin =
        override != null ||
            (overlayHandleIds != null && overlayHandleIds.isNotEmpty)
        ? ParticipantOrigin.overlayOverride
        : ParticipantOrigin.working;

    workingSummaries.add(
      ContactSummary(
        participantId: participant.id,
        displayName: participant.displayName,
        shortName: override?.shortName ?? participant.shortName,
        totalChats: metrics.totalChats,
        totalMessages: metrics.totalMessages,
        lastMessageDate: metrics.lastMessageDate,
        origin: origin,
        handleCount: handleIds.length,
      ),
    );
  }

  workingSummaries.sort((a, b) => a.displayName.compareTo(b.displayName));

  final virtualSummaries = <ContactSummary>[];

  for (final contact in virtualContacts) {
    if (isPlaceholderDisplayName(contact.displayName)) {
      continue;
    }
    final handleIds = overlayHandlesByParticipant[contact.id] ?? const <int>{};

    final metrics = await _calculateMetrics(
      workingDb,
      handleIds.toList(growable: false),
    );

    virtualSummaries.add(
      ContactSummary(
        participantId: contact.id,
        displayName: contact.displayName,
        shortName: contact.shortName,
        totalChats: metrics.totalChats,
        totalMessages: metrics.totalMessages,
        lastMessageDate: metrics.lastMessageDate,
        origin: ParticipantOrigin.overlayVirtual,
        handleCount: overlayHandleCounts[contact.id] ?? handleIds.length,
      ),
    );
  }

  virtualSummaries.sort((a, b) => a.displayName.compareTo(b.displayName));

  return [...workingSummaries, ...virtualSummaries];
}

Future<_ParticipantMetrics> _calculateMetrics(
  WorkingDatabase db,
  List<int> handleIds,
) async {
  if (handleIds.isEmpty) {
    return const _ParticipantMetrics(
      totalChats: 0,
      totalMessages: 0,
      lastMessageDate: null,
    );
  }

  final chatCountRow =
      await (db.selectOnly(db.chatToHandle)
            ..addColumns([db.chatToHandle.chatId.count()])
            ..where(db.chatToHandle.handleId.isIn(handleIds)))
          .getSingleOrNull();

  final totalChats = chatCountRow?.read(db.chatToHandle.chatId.count()) ?? 0;

  final messageCountRow =
      await (db.selectOnly(db.workingMessages).join([
              drift.innerJoin(
                db.chatToHandle,
                db.chatToHandle.chatId.equalsExp(db.workingMessages.chatId),
              ),
            ])
            ..addColumns([db.workingMessages.id.count()])
            ..where(db.chatToHandle.handleId.isIn(handleIds)))
          .getSingleOrNull();

  final totalMessages =
      messageCountRow?.read(db.workingMessages.id.count()) ?? 0;

  final lastMessageRow =
      await (db.selectOnly(db.workingMessages).join([
              drift.innerJoin(
                db.chatToHandle,
                db.chatToHandle.chatId.equalsExp(db.workingMessages.chatId),
              ),
            ])
            ..addColumns([db.workingMessages.sentAtUtc.max()])
            ..where(db.chatToHandle.handleId.isIn(handleIds)))
          .getSingleOrNull();

  final lastMessageUtc = lastMessageRow?.read(
    db.workingMessages.sentAtUtc.max(),
  );

  final lastMessageDate = switch (lastMessageUtc) {
    null => null,
    '' => null,
    final String value => DateTime.tryParse(value)?.toLocal(),
  };

  return _ParticipantMetrics(
    totalChats: totalChats,
    totalMessages: totalMessages,
    lastMessageDate: lastMessageDate,
  );
}

class _ParticipantMetrics {
  const _ParticipantMetrics({
    required this.totalChats,
    required this.totalMessages,
    required this.lastMessageDate,
  });

  final int totalChats;
  final int totalMessages;
  final DateTime? lastMessageDate;
}
