import 'package:drift/drift.dart' as drift;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/db/feature_level_providers.dart';

part 'participants_for_picker_provider.g.dart';

/// Data model for a participant in the contact picker
class ParticipantForPicker {
  const ParticipantForPicker({
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

/// Provider that fetches participants filtered by search query
///
/// This is used by the ContactPickerDialog to show searchable participants.
/// The search is case-insensitive and matches against display_name and short_name.
@riverpod
Future<List<ParticipantForPicker>> participantsForPicker(
  ParticipantsForPickerRef ref, {
  required String searchQuery,
}) async {
  final db = await ref.watch(driftWorkingDatabaseProvider.future);

  // Build query for participants
  final query = db.select(db.workingParticipants);

  // Apply search filter if provided
  if (searchQuery.isNotEmpty) {
    final searchLower = searchQuery.toLowerCase();
    query.where((tbl) {
      return tbl.displayName.lower().like('%$searchLower%') |
          tbl.shortName.lower().like('%$searchLower%');
    });
  }

  // Order by display name
  query.orderBy([(tbl) => drift.OrderingTerm(expression: tbl.displayName)]);

  final participants = await query.get();

  // Count handles for each participant
  final results = <ParticipantForPicker>[];
  for (final participant in participants) {
    final handleCount =
        await (db.selectOnly(db.handleToParticipant)
              ..addColumns([db.handleToParticipant.handleId.count()])
              ..where(
                db.handleToParticipant.participantId.equals(participant.id),
              ))
            .getSingle()
            .then(
              (row) => row.read(db.handleToParticipant.handleId.count()) ?? 0,
            );

    results.add(
      ParticipantForPicker(
        id: participant.id,
        displayName: participant.displayName,
        shortName: participant.shortName,
        handleCount: handleCount,
      ),
    );
  }

  return results;
}
