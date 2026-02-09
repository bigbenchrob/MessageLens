import 'package:drift/drift.dart' as drift;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/db/feature_level_providers.dart';

part 'stray_handles_provider.freezed.dart';
part 'stray_handles_provider.g.dart';

/// A handle that has no link to any participant (real or virtual) in either
/// the working or overlay databases.
@freezed
abstract class StrayHandleSummary with _$StrayHandleSummary {
  const factory StrayHandleSummary({
    required int handleId,
    required String handleValue,
    required String serviceType,
    required int totalMessages,

    /// ISO 8601 timestamp of when the user last reviewed this handle, or null
    /// if never reviewed.
    String? reviewedAt,
    DateTime? lastMessageDate,
  }) = _StrayHandleSummary;
}

/// Returns all handles that are truly "stray": no participant link in the
/// working DB AND no linked override (participant or virtual participant) in
/// the overlay DB.
///
/// Handles with an overlay row that has only `reviewed_at` set (both
/// participant IDs null) are still included — they are reviewed but unlinked.
///
/// Sorted by total message count descending (most messages first).
@riverpod
Future<List<StrayHandleSummary>> strayHandles(Ref ref) async {
  final workingDb = await ref.watch(driftWorkingDatabaseProvider.future);
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);

  // 1. Get all overlay overrides so we can check link status per handle.
  final allOverrides = await overlayDb.getAllHandleOverrides();
  final linkedOverrideHandleIds = <int>{};
  final reviewedAtByHandle = <int, String>{};

  for (final override in allOverrides) {
    if (override.participantId != null ||
        override.virtualParticipantId != null) {
      // This handle is linked to a real or virtual participant — not stray.
      linkedOverrideHandleIds.add(override.handleId);
    }
    if (override.reviewedAt != null) {
      reviewedAtByHandle[override.handleId] = override.reviewedAt!;
    }
  }

  // 2. Query working-DB handles that have no working-DB participant link.
  final handlesQuery = workingDb.select(workingDb.handlesCanonical)
    ..where(
      (tbl) => drift.notExistsQuery(
        workingDb.select(workingDb.handleToParticipant)
          ..where((h2p) => h2p.handleId.equalsExp(tbl.id)),
      ),
    );

  final handles = await handlesQuery.get();

  final results = <StrayHandleSummary>[];

  for (final handle in handles) {
    // Skip handles that are linked via overlay override.
    if (linkedOverrideHandleIds.contains(handle.id)) {
      continue;
    }

    // Count messages where this handle is the sender.
    final messagesQuery = workingDb.selectOnly(workingDb.workingMessages)
      ..addColumns([workingDb.workingMessages.id.count()])
      ..where(workingDb.workingMessages.senderHandleId.equals(handle.id));

    final messageCountRow = await messagesQuery.getSingleOrNull();
    final totalMessages =
        messageCountRow?.read(workingDb.workingMessages.id.count()) ?? 0;

    if (totalMessages == 0) {
      continue;
    }

    // Get last message date.
    final lastMessageQuery = workingDb.selectOnly(workingDb.workingMessages)
      ..addColumns([workingDb.workingMessages.sentAtUtc.max()])
      ..where(workingDb.workingMessages.senderHandleId.equals(handle.id));

    final lastMessageRow = await lastMessageQuery.getSingleOrNull();
    final lastMessageUtc = lastMessageRow?.read(
      workingDb.workingMessages.sentAtUtc.max(),
    );

    DateTime? lastMessageDate;
    if (lastMessageUtc != null && lastMessageUtc.isNotEmpty) {
      lastMessageDate = DateTime.tryParse(lastMessageUtc)?.toLocal();
    }

    results.add(
      StrayHandleSummary(
        handleId: handle.id,
        handleValue: handle.rawIdentifier,
        serviceType: handle.service,
        totalMessages: totalMessages,
        reviewedAt: reviewedAtByHandle[handle.id],
        lastMessageDate: lastMessageDate,
      ),
    );
  }

  // Sort by message count descending (most messages first).
  results.sort((a, b) => b.totalMessages.compareTo(a.totalMessages));

  return results;
}
