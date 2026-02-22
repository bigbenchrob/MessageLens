import 'package:drift/drift.dart' as drift;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart';
import '../../domain/utilities/handle_normalizer.dart';

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

    /// Heuristic score indicating likelihood of junk/spam (higher = more likely).
    /// Used to filter candidates for Spam/One-off mode.
    @Default(0) int junkScore,

    /// Whether this handle is a short code (3-8 digits, no country code).
    @Default(false) bool isShortCode,
  }) = _StrayHandleSummary;
}

/// Returns all handles that are truly "stray": no participant link in the
/// working DB AND no linked override (participant or virtual participant) in
/// the overlay DB.
///
/// Handles with an overlay row that has only `reviewed_at` set (both
/// participant IDs null) are still included — they are reviewed but unlinked.
///
/// **Excludes dismissed handles** — those are only visible in the Dismissed
/// escape hatch view via [dismissedHandlesProvider].
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

  // 2. Get all dismissed handles (keyed by normalized value).
  final dismissedHandles = await overlayDb.getAllDismissedHandles();

  // 3. Query working-DB handles that have no working-DB participant link.
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

    // Skip dismissed handles.
    final normalized = normalizeHandleIdentifier(handle.rawIdentifier);
    if (dismissedHandles.contains(normalized)) {
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

    // Calculate junk score for sorting/filtering.
    final handleIsShortCode = isShortCode(handle.rawIdentifier);
    var junkScore = 0;
    if (handleIsShortCode) {
      junkScore += 3;
    }
    if (totalMessages == 1) {
      junkScore += 2;
    } else if (totalMessages <= 3) {
      junkScore += 1;
    }
    // Note: Additional keyword scoring requires message content, deferred to
    // spamCandidateHandlesProvider for performance.

    results.add(
      StrayHandleSummary(
        handleId: handle.id,
        handleValue: handle.rawIdentifier,
        serviceType: handle.service,
        totalMessages: totalMessages,
        reviewedAt: reviewedAtByHandle[handle.id],
        lastMessageDate: lastMessageDate,
        junkScore: junkScore,
        isShortCode: handleIsShortCode,
      ),
    );
  }

  // Sort by message count descending (most messages first).
  results.sort((a, b) => b.totalMessages.compareTo(a.totalMessages));

  return results;
}

/// Returns only stray handles that match junk-like heuristics (junkScore >= 3).
///
/// Used for the "Spam / One-off" blitz-dismiss mode. Sorted by junk score
/// descending (most likely junk first).
@riverpod
Future<List<StrayHandleSummary>> spamCandidateHandles(Ref ref) async {
  final allStrays = await ref.watch(strayHandlesProvider.future);

  // Filter to handles with junkScore >= 3.
  final candidates = allStrays.where((h) => h.junkScore >= 3).toList();

  // Sort by junk score descending (most likely spam first).
  candidates.sort((a, b) => b.junkScore.compareTo(a.junkScore));

  return candidates;
}

/// Returns only dismissed handles for the escape hatch view.
///
/// Note: This returns metadata about dismissed handles by looking them up
/// in the working database using their normalized values.
@riverpod
Future<List<StrayHandleSummary>> dismissedHandles(Ref ref) async {
  final workingDb = await ref.watch(driftWorkingDatabaseProvider.future);
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);

  // Get all dismissed normalized handles.
  final dismissedNormalized = await overlayDb.getAllDismissedHandles();
  if (dismissedNormalized.isEmpty) {
    return [];
  }

  // Query all handles from working DB.
  final handles = await workingDb.select(workingDb.handlesCanonical).get();

  final results = <StrayHandleSummary>[];

  for (final handle in handles) {
    final normalized = normalizeHandleIdentifier(handle.rawIdentifier);
    if (!dismissedNormalized.contains(normalized)) {
      continue;
    }

    // Count messages where this handle is the sender.
    final messagesQuery = workingDb.selectOnly(workingDb.workingMessages)
      ..addColumns([workingDb.workingMessages.id.count()])
      ..where(workingDb.workingMessages.senderHandleId.equals(handle.id));

    final messageCountRow = await messagesQuery.getSingleOrNull();
    final totalMessages =
        messageCountRow?.read(workingDb.workingMessages.id.count()) ?? 0;

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
        lastMessageDate: lastMessageDate,
        isShortCode: isShortCode(handle.rawIdentifier),
      ),
    );
  }

  // Sort by message count descending.
  results.sort((a, b) => b.totalMessages.compareTo(a.totalMessages));

  return results;
}
