import 'package:drift/drift.dart' as drift;
import 'package:drift/drift.dart' show Value;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart';
import '../../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';

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

/// Provider that finds handles not linked to any participant
@riverpod
Future<List<UnlinkedHandle>> unlinkedHandles(Ref ref) async {
  final db = await ref.watch(driftWorkingDatabaseProvider.future);

  // Query handles that don't have any participant links
  final query =
      db.select(db.workingHandles).join([
        // Left join to handle_to_participant to find unlinked handles
        drift.leftOuterJoin(
          db.handleToParticipant,
          db.handleToParticipant.handleId.equalsExp(db.workingHandles.id),
        ),
      ])..where(
        // Only handles with no participant links and not blacklisted
        db.handleToParticipant.handleId.isNull() &
            db.workingHandles.isBlacklisted.equals(false),
      );

  final rows = await query.get();
  final results = <UnlinkedHandle>[];

  for (final row in rows) {
    final handle = row.readTable(db.workingHandles);

    // Count chats for this handle
    // Count chats for this handle via chat_to_handle join
    final chatIds =
        await (db.selectOnly(db.chatToHandle)
              ..where(db.chatToHandle.handleId.equals(handle.id))
              ..addColumns([db.chatToHandle.chatId]))
            .get()
            .then(
              (rows) =>
                  rows.map((row) => row.read(db.chatToHandle.chatId)!).toList(),
            );

    final chatCount = chatIds.length;

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

/// Provider that gets all available participants for linking
@riverpod
Future<List<AvailableParticipant>> availableParticipants(Ref ref) async {
  final db = await ref.watch(driftWorkingDatabaseProvider.future);

  // Query all participants with their handle counts
  final participantRows = await db.select(db.workingParticipants).get();
  final results = <AvailableParticipant>[];

  for (final participant in participantRows) {
    // Count existing handle links for this participant
    final handleCountExpr = db.handleToParticipant.handleId.count();
    final handleCount =
        await (db.selectOnly(db.handleToParticipant)
              ..addColumns([handleCountExpr])
              ..where(
                db.handleToParticipant.participantId.equals(participant.id),
              ))
            .getSingle()
            .then((row) => row.read(handleCountExpr) ?? 0);

    results.add(
      AvailableParticipant(
        id: participant.id,
        displayName: participant.displayName,
        shortName: participant.shortName,
        handleCount: handleCount,
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

  /// Link a handle to a participant manually
  Future<void> linkHandleToParticipant({
    required int handleId,
    required int participantId,
  }) async {
    final db = await ref.watch(driftWorkingDatabaseProvider.future);

    // Create the manual link with user_manual source
    await db
        .into(db.handleToParticipant)
        .insert(
          HandleToParticipantCompanion.insert(
            handleId: handleId,
            participantId: participantId,
            confidence: const Value(0.8), // Lower confidence for manual links
            source: const Value('user_manual'),
          ),
        );

    // Refresh the unlinked handles list
    ref.invalidate(unlinkedHandlesProvider);
    ref.invalidate(availableParticipantsProvider);
  }

  /// Unlink a handle from a participant
  Future<void> unlinkHandle(int handleId) async {
    final db = await ref.watch(driftWorkingDatabaseProvider.future);

    await (db.delete(
      db.handleToParticipant,
    )..where((htp) => htp.handleId.equals(handleId))).go();

    // Refresh the lists
    ref.invalidate(unlinkedHandlesProvider);
    ref.invalidate(availableParticipantsProvider);
  }

  /// Create a new participant for a handle (when no existing participant matches)
  Future<void> createParticipantForHandle({
    required int handleId,
    required String displayName,
  }) async {
    final db = await ref.watch(driftWorkingDatabaseProvider.future);

    // Insert new participant (using auto-generated ID since it's not from AddressBook)
    final participantId = await db
        .into(db.workingParticipants)
        .insert(
          WorkingParticipantsCompanion.insert(
            originalName: displayName,
            displayName: displayName,
            shortName: displayName,
          ),
        );

    // Link the handle to the new participant
    await db
        .into(db.handleToParticipant)
        .insert(
          HandleToParticipantCompanion.insert(
            handleId: handleId,
            participantId: participantId,
            confidence: const Value(1.0), // High confidence for user-created
            source: const Value('user_created'),
          ),
        );

    // Refresh the lists
    ref.invalidate(unlinkedHandlesProvider);
    ref.invalidate(availableParticipantsProvider);
  }

  /// Get link information for a specific handle
  Future<HandleLinkInfo?> getHandleLinkInfo(int handleId) async {
    final db = await ref.watch(driftWorkingDatabaseProvider.future);

    // Query the link and participant info
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
