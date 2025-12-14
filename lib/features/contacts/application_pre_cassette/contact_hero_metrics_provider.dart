import 'package:drift/drift.dart' as drift;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/db/feature_level_providers.dart';

part 'contact_hero_metrics_provider.g.dart';

class ContactHeroMetrics {
  const ContactHeroMetrics({
    required this.contactId,
    required this.totalMessages,
    required this.firstMessageAtUtc,
    required this.lastMessageAtUtc,
  });

  final int contactId;
  final int totalMessages;
  final DateTime? firstMessageAtUtc;
  final DateTime? lastMessageAtUtc;
}

@riverpod
Future<ContactHeroMetrics> contactHeroMetrics(
  Ref ref, {
  required int contactId,
}) async {
  final db = await ref.watch(driftWorkingDatabaseProvider.future);

  final handleIdsQuery = db.selectOnly(db.handleToParticipant)
    ..addColumns([db.handleToParticipant.handleId])
    ..where(db.handleToParticipant.participantId.equals(contactId));

  final handleIdRows = await handleIdsQuery.get();
  final handleIds = <int>[
    for (final row in handleIdRows) row.read(db.handleToParticipant.handleId)!,
  ];

  if (handleIds.isEmpty) {
    return ContactHeroMetrics(
      contactId: contactId,
      totalMessages: 0,
      firstMessageAtUtc: null,
      lastMessageAtUtc: null,
    );
  }

  final chatIdsQuery = db.selectOnly(db.chatToHandle)
    ..addColumns([db.chatToHandle.chatId])
    ..where(db.chatToHandle.handleId.isIn(handleIds));

  final chatIdRows = await chatIdsQuery.get();
  final chatIds = <int>{
    for (final row in chatIdRows) row.read(db.chatToHandle.chatId)!,
  }.toList(growable: false);

  if (chatIds.isEmpty) {
    return ContactHeroMetrics(
      contactId: contactId,
      totalMessages: 0,
      firstMessageAtUtc: null,
      lastMessageAtUtc: null,
    );
  }

  final agg = db.selectOnly(db.workingMessages)
    ..addColumns([
      db.workingMessages.id.count(),
      db.workingMessages.sentAtUtc.min(),
      db.workingMessages.sentAtUtc.max(),
    ])
    ..where(db.workingMessages.chatId.isIn(chatIds));

  final row = await agg.getSingle();

  final count = row.read(db.workingMessages.id.count()) ?? 0;

  final minSentUtc = row.read(db.workingMessages.sentAtUtc.min());
  final maxSentUtc = row.read(db.workingMessages.sentAtUtc.max());

  DateTime? first;
  if (minSentUtc != null && minSentUtc.isNotEmpty) {
    first = DateTime.tryParse(minSentUtc);
  }

  DateTime? last;
  if (maxSentUtc != null && maxSentUtc.isNotEmpty) {
    last = DateTime.tryParse(maxSentUtc);
  }

  return ContactHeroMetrics(
    contactId: contactId,
    totalMessages: count,
    firstMessageAtUtc: first,
    lastMessageAtUtc: last,
  );
}
