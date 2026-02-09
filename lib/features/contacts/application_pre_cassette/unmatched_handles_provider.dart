import 'package:drift/drift.dart' as drift;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/db/feature_level_providers.dart';
import '../../../essentials/navigation/domain/entities/features/handles_list_spec.dart';

part 'unmatched_handles_provider.freezed.dart';
part 'unmatched_handles_provider.g.dart';

@freezed
abstract class UnmatchedHandleSummary with _$UnmatchedHandleSummary {
  const factory UnmatchedHandleSummary({
    required int handleId,
    required String handleValue,
    required String serviceType,
    required int totalMessages,
    required bool isProbableSpam,
    DateTime? lastMessageDate,
  }) = _UnmatchedHandleSummary;
}

bool _isProbableSpam(String rawIdentifier, String serviceType) {
  // Skip email addresses - they rarely have spam patterns
  if (serviceType == 'iMessage' && rawIdentifier.contains('@')) {
    return false;
  }

  // Phone number spam heuristics
  if (serviceType == 'SMS' || serviceType == 'iMessage') {
    // Extract digits only
    final digitsOnly = rawIdentifier.replaceAll(RegExp(r'\D'), '');

    // Short codes (5-6 digits) are often spam/marketing
    if (digitsOnly.length >= 5 && digitsOnly.length <= 6) {
      return true;
    }

    // All numeric, no name - possible spam indicator
    // (Real contacts usually have names or non-numeric identifiers)
    if (digitsOnly.length == rawIdentifier.length && digitsOnly.length > 6) {
      return true;
    }
  }

  return false;
}

@riverpod
Future<List<UnmatchedHandleSummary>> unmatchedPhones(
  Ref ref, {
  required PhoneFilterMode filterMode,
}) async {
  final db = await ref.watch(driftWorkingDatabaseProvider.future);
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);

  // Get all handle IDs that already have an overlay override (linked or not).
  final overlayLinkedHandleIds = await overlayDb.getAllOverriddenHandleIds();

  // Query handles WHERE NOT EXISTS (handle_to_participant)
  // Filter for SMS/iMessage services (phone numbers)
  final handlesQuery = db.select(db.handlesCanonical)
    ..where(
      (tbl) =>
          drift.notExistsQuery(
            db.select(db.handleToParticipant)
              ..where((h2p) => h2p.handleId.equalsExp(tbl.id)),
          ) &
          (tbl.service.equals('SMS') | tbl.service.equals('iMessage')),
    )
    ..orderBy([(tbl) => drift.OrderingTerm(expression: tbl.rawIdentifier)]);

  final handles = await handlesQuery.get();

  final results = <UnmatchedHandleSummary>[];

  for (final handle in handles) {
    // Skip handles that have an overlay override (already linked or reviewed)
    if (overlayLinkedHandleIds.contains(handle.id)) {
      continue;
    }

    final isProbableSpam = _isProbableSpam(
      handle.rawIdentifier,
      handle.service,
    );

    // Apply filter mode
    switch (filterMode) {
      case PhoneFilterMode.all:
        break; // Include all
      case PhoneFilterMode.spamCandidates:
        if (!isProbableSpam) {
          continue; // Only show probable spam
        }
    }

    // Count messages from this handle
    final messagesQuery = db.selectOnly(db.workingMessages)
      ..addColumns([db.workingMessages.id.count()])
      ..where(db.workingMessages.senderHandleId.equals(handle.id));

    final messageCountRow = await messagesQuery.getSingleOrNull();
    final totalMessages =
        messageCountRow?.read(db.workingMessages.id.count()) ?? 0;

    if (totalMessages == 0) {
      continue; // Skip handles with no messages
    }

    // Get last message date
    final lastMessageQuery = db.selectOnly(db.workingMessages)
      ..addColumns([db.workingMessages.sentAtUtc.max()])
      ..where(db.workingMessages.senderHandleId.equals(handle.id));

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
      UnmatchedHandleSummary(
        handleId: handle.id,
        handleValue: handle.rawIdentifier,
        serviceType: handle.service,
        totalMessages: totalMessages,
        isProbableSpam: isProbableSpam,
        lastMessageDate: lastMessageDate,
      ),
    );
  }

  return results;
}

@riverpod
Future<List<UnmatchedHandleSummary>> unmatchedEmails(Ref ref) async {
  final db = await ref.watch(driftWorkingDatabaseProvider.future);
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);

  // Get all handle IDs that already have an overlay override.
  final overlayLinkedHandleIds = await overlayDb.getAllOverriddenHandleIds();

  // Query handles WHERE NOT EXISTS (handle_to_participant)
  // Filter for email addresses (contain @)
  final handlesQuery = db.select(db.handlesCanonical)
    ..where(
      (tbl) =>
          drift.notExistsQuery(
            db.select(db.handleToParticipant)
              ..where((h2p) => h2p.handleId.equalsExp(tbl.id)),
          ) &
          tbl.rawIdentifier.contains('@'),
    )
    ..orderBy([(tbl) => drift.OrderingTerm(expression: tbl.rawIdentifier)]);

  final handles = await handlesQuery.get();

  final results = <UnmatchedHandleSummary>[];

  for (final handle in handles) {
    // Skip handles that have an overlay override (already linked or reviewed)
    if (overlayLinkedHandleIds.contains(handle.id)) {
      continue;
    }

    // Count messages from this handle
    final messagesQuery = db.selectOnly(db.workingMessages)
      ..addColumns([db.workingMessages.id.count()])
      ..where(db.workingMessages.senderHandleId.equals(handle.id));

    final messageCountRow = await messagesQuery.getSingleOrNull();
    final totalMessages =
        messageCountRow?.read(db.workingMessages.id.count()) ?? 0;

    if (totalMessages == 0) {
      continue; // Skip handles with no messages
    }

    // Get last message date
    final lastMessageQuery = db.selectOnly(db.workingMessages)
      ..addColumns([db.workingMessages.sentAtUtc.max()])
      ..where(db.workingMessages.senderHandleId.equals(handle.id));

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
      UnmatchedHandleSummary(
        handleId: handle.id,
        handleValue: handle.rawIdentifier,
        serviceType: handle.service,
        totalMessages: totalMessages,
        isProbableSpam: false, // Email spam detection not implemented yet
        lastMessageDate: lastMessageDate,
      ),
    );
  }

  return results;
}
