import 'package:drift/drift.dart' as drift;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/db/feature_level_providers.dart';
import '../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import '../domain/participant_origin.dart';
import 'participant_merge_utils.dart';
import 'virtual_participants_provider.dart';

part 'participants_for_picker_provider.g.dart';

/// Data model for a participant in the contact picker
class ParticipantForPicker {
  const ParticipantForPicker({
    required this.id,
    required this.displayName,
    required this.shortName,
    required this.handleCount,
    required this.origin,
  });

  final int id;
  final String displayName;
  final String shortName;
  final int handleCount;
  final ParticipantOrigin origin;

  bool get isVirtual => origin == ParticipantOrigin.overlayVirtual;
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
  final normalizedQuery = searchQuery.trim().toLowerCase();

  final workingDb = await ref.watch(driftWorkingDatabaseProvider.future);
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  final virtualContacts = await ref.watch(virtualParticipantsProvider.future);

  final workingParticipants = await _queryWorkingParticipants(
    workingDb,
    normalizedQuery: normalizedQuery,
  );

  final sanitizedWorkingParticipants = workingParticipants
      .where(
        (participant) => !isPlaceholderDisplayName(participant.displayName),
      )
      .toList(growable: false);

  final workingHandleCounts = await workingHandleCountsByParticipant(workingDb);
  final overlayHandleCounts = await overlayHandleCountsByParticipant(overlayDb);
  final overlayHandlesByParticipant = await overlayHandleIdsByParticipant(
    overlayDb,
  );
  final participantOverrides = await participantOverridesById(overlayDb);

  final workingEntries = sanitizedWorkingParticipants
      .map(
        (participant) => ParticipantForPicker(
          id: participant.id,
          displayName: participant.displayName,
          shortName:
              participantOverrides[participant.id]?.shortName ??
              participant.shortName,
          handleCount: workingHandleCounts[participant.id] ?? 0,
          origin:
              participantOverrides.containsKey(participant.id) ||
                  (overlayHandlesByParticipant[participant.id]?.isNotEmpty ??
                      false)
              ? ParticipantOrigin.overlayOverride
              : ParticipantOrigin.working,
        ),
      )
      .toList(growable: false);

  final virtualEntries =
      virtualContacts
          .where(
            (contact) =>
                normalizedQuery.isEmpty ||
                contact.displayName.toLowerCase().contains(normalizedQuery) ||
                contact.shortName.toLowerCase().contains(normalizedQuery),
          )
          .map(
            (contact) => ParticipantForPicker(
              id: contact.id,
              displayName: contact.displayName,
              shortName: contact.shortName,
              handleCount: overlayHandleCounts[contact.id] ?? 0,
              origin: ParticipantOrigin.overlayVirtual,
            ),
          )
          .toList(growable: false)
        ..sort((a, b) => a.displayName.compareTo(b.displayName));

  return [...workingEntries, ...virtualEntries];
}

Future<List<WorkingParticipant>> _queryWorkingParticipants(
  WorkingDatabase db, {
  required String normalizedQuery,
}) {
  final query = db.select(db.workingParticipants);

  if (normalizedQuery.isNotEmpty) {
    final pattern = '%$normalizedQuery%';
    query.where((tbl) {
      return tbl.displayName.lower().like(pattern) |
          tbl.shortName.lower().like(pattern);
    });
  }

  query.orderBy([(tbl) => drift.OrderingTerm(expression: tbl.displayName)]);

  return query.get();
}
