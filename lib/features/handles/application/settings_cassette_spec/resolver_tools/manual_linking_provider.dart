import 'package:drift/drift.dart' as drift;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../../essentials/db/feature_level_providers.dart';
import '../../../../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';

part 'manual_linking_provider.g.dart';

class UnlinkedHandle {
  const UnlinkedHandle({
    required this.id,
    required this.handleId,
    required this.service,
    required this.chatCount,
  });

  final int id;
  final String handleId;
  final String service;
  final int chatCount;
}

class AvailableParticipant {
  const AvailableParticipant({
    required this.id,
    required this.displayName,
    required this.shortName,
    required this.handleCount,
  });

  final int id;
  final String displayName;
  final String shortName;
  final int handleCount;
}

/// Provider that finds handles not linked to any participant.
///
/// A handle is considered linked if it has a working-DB addressbook link OR an
/// overlay manual link (participant or virtual participant). Overlay visibility
/// overrides (blacklisted) are also merged here.
@riverpod
Future<List<UnlinkedHandle>> unlinkedHandles(Ref ref) async {
  final db = await ref.watch(driftWorkingDatabaseProvider.future);
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);

  // Load overlay visibility overrides (overlay wins on conflict).
  final visibilityOverrides = await overlayDb.getAllHandleVisibilities();
  final visibilityMap = {for (final o in visibilityOverrides) o.handleId: o};

  // Load overlay handle→participant overrides to exclude manually linked
  // handles from the "unlinked" list.
  final handleOverrides = await overlayDb.getAllHandleOverrides();
  final overlayLinkedHandleIds = <int>{};
  for (final o in handleOverrides) {
    if (o.participantId != null || o.virtualParticipantId != null) {
      overlayLinkedHandleIds.add(o.handleId);
    }
  }

  // Query handles that don't have any working-DB participant links.
  final query = db.select(db.handlesCanonical).join([
    drift.leftOuterJoin(
      db.handleToParticipant,
      db.handleToParticipant.handleId.equalsExp(db.handlesCanonical.id),
    ),
  ])..where(db.handleToParticipant.handleId.isNull());

  final rows = await query.get();
  final results = <UnlinkedHandle>[];

  for (final row in rows) {
    final handle = row.readTable(db.handlesCanonical);

    // Skip handles that are linked via overlay override.
    if (overlayLinkedHandleIds.contains(handle.id)) {
      continue;
    }

    // Merge overlay: skip blacklisted handles.
    final overlay = visibilityMap[handle.id];
    final isBlacklisted = overlay?.isBlacklisted ?? handle.isBlacklisted;
    if (isBlacklisted) {
      continue;
    }

    // Count chats for this handle via chat_to_handle join.
    final chatCount =
        await (db.selectOnly(db.chatToHandle)
              ..where(db.chatToHandle.handleId.equals(handle.id))
              ..addColumns([db.chatToHandle.chatId]))
            .get()
            .then((rows) => rows.length);

    results.add(
      UnlinkedHandle(
        id: handle.id,
        handleId: handle.compoundIdentifier,
        service: handle.service,
        chatCount: chatCount,
      ),
    );
  }

  // Sort by chat count (most active first) then by handle
  results.sort((a, b) {
    final chatComparison = b.chatCount.compareTo(a.chatCount);
    if (chatComparison != 0) {
      return chatComparison;
    }
    return a.handleId.compareTo(b.handleId);
  });

  return results;
}

/// Provider that gets all available participants for linking.
///
/// Handle counts merge working-DB addressbook links with overlay manual links.
@riverpod
Future<List<AvailableParticipant>> availableParticipants(Ref ref) async {
  final db = await ref.watch(driftWorkingDatabaseProvider.future);
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);

  // Build overlay participant→handle count map.
  final handleOverrides = await overlayDb.getAllHandleOverrides();
  final overlayCountByParticipant = <int, int>{};
  for (final o in handleOverrides) {
    if (o.participantId != null) {
      overlayCountByParticipant[o.participantId!] =
          (overlayCountByParticipant[o.participantId!] ?? 0) + 1;
    }
  }

  final participantRows = await db.select(db.workingParticipants).get();
  final results = <AvailableParticipant>[];

  for (final participant in participantRows) {
    // Count working-DB handle links.
    final handleCountExpr = db.handleToParticipant.handleId.count();
    final workingCount =
        await (db.selectOnly(db.handleToParticipant)
              ..addColumns([handleCountExpr])
              ..where(
                db.handleToParticipant.participantId.equals(participant.id),
              ))
            .getSingle()
            .then((row) => row.read(handleCountExpr) ?? 0);

    // Merge overlay count.
    final overlayCount = overlayCountByParticipant[participant.id] ?? 0;

    results.add(
      AvailableParticipant(
        id: participant.id,
        displayName: participant.displayName,
        shortName: participant.shortName,
        handleCount: workingCount + overlayCount,
      ),
    );
  }

  // Sort by display name
  results.sort((a, b) => a.displayName.compareTo(b.displayName));

  return results;
}

/// Provider for manual linking operations
@riverpod
class ManualLinking extends _$ManualLinking {
  @override
  Future<void> build() async {
    // No initial state needed
  }

  /// Link a handle to a participant manually.
  ///
  /// Writes only to the overlay DB. Merge providers combine overlay links with
  /// working-DB addressbook links at read time (overlay wins on conflict).
  Future<void> linkHandleToParticipant({
    required int handleId,
    required int participantId,
  }) async {
    final overlayDb = await ref.watch(overlayDatabaseProvider.future);

    await overlayDb.setHandleOverride(handleId, participantId);

    ref.invalidate(unlinkedHandlesProvider);
    ref.invalidate(availableParticipantsProvider);
  }

  /// Unlink a handle from a participant.
  ///
  /// Removes the overlay override so the handle reverts to its addressbook
  /// default (linked or unlinked).
  Future<void> unlinkHandle(int handleId) async {
    final overlayDb = await ref.watch(overlayDatabaseProvider.future);

    await overlayDb.deleteHandleOverride(handleId);

    ref.invalidate(unlinkedHandlesProvider);
    ref.invalidate(availableParticipantsProvider);
  }

  /// Create a new participant for a handle (when no existing participant matches).
  ///
  /// The participant record is created in the working DB (the only participant
  /// table). The handle→participant link is stored in overlay so it survives
  /// re-imports.
  Future<void> createParticipantForHandle({
    required int handleId,
    required String displayName,
  }) async {
    final db = await ref.watch(driftWorkingDatabaseProvider.future);
    final overlayDb = await ref.watch(overlayDatabaseProvider.future);

    // Insert new participant in working DB.
    final participantId = await db
        .into(db.workingParticipants)
        .insert(
          WorkingParticipantsCompanion.insert(
            originalName: displayName,
            displayName: displayName,
            shortName: displayName,
          ),
        );

    // Store the link in overlay (survives re-imports).
    await overlayDb.setHandleOverride(handleId, participantId);

    ref.invalidate(unlinkedHandlesProvider);
    ref.invalidate(availableParticipantsProvider);
  }

  /// Get link information for a specific handle.
  ///
  /// Checks overlay first (manual links win), then falls back to working DB.
  Future<HandleLinkInfo?> getHandleLinkInfo(int handleId) async {
    final db = await ref.watch(driftWorkingDatabaseProvider.future);
    final overlayDb = await ref.watch(overlayDatabaseProvider.future);

    // Check overlay first — manual links take precedence.
    final overlayRow = await overlayDb.getHandleOverride(handleId);
    if (overlayRow != null && overlayRow.participantId != null) {
      final participant =
          await (db.select(db.workingParticipants)
                ..where((tbl) => tbl.id.equals(overlayRow.participantId!)))
              .getSingleOrNull();
      if (participant != null) {
        return HandleLinkInfo(
          participantId: participant.id,
          participantName: participant.displayName,
          confidence: 1.0,
          source: 'user_manual',
        );
      }
    }

    // Fall back to working DB addressbook link.
    final query = db.select(db.handleToParticipant).join([
      drift.innerJoin(
        db.workingParticipants,
        db.workingParticipants.id.equalsExp(
          db.handleToParticipant.participantId,
        ),
      ),
    ])..where(db.handleToParticipant.handleId.equals(handleId));

    final row = await query.getSingleOrNull();
    if (row == null) {
      return null;
    }

    final link = row.readTable(db.handleToParticipant);
    final participant = row.readTable(db.workingParticipants);

    return HandleLinkInfo(
      participantId: participant.id,
      participantName: participant.displayName,
      confidence: link.confidence,
      source: link.source,
    );
  }
}

class HandleLinkInfo {
  const HandleLinkInfo({
    required this.participantId,
    required this.participantName,
    required this.confidence,
    required this.source,
  });

  final int participantId;
  final String participantName;
  final double confidence;
  final String source;

  bool get isManualLink => source == 'user_manual' || source == 'user_created';
}
