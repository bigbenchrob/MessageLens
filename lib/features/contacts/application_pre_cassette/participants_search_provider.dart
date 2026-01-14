import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/db/feature_level_providers.dart';
import '../domain/participant_origin.dart';
import 'participant_merge_utils.dart';
import 'virtual_participants_provider.dart';

part 'participants_search_provider.g.dart';

class ParticipantSearchResult {
  const ParticipantSearchResult({
    required this.id,
    required this.displayName,
    required this.shortName,
    required this.origin,
    required this.handleCount,
  });

  final int id;
  final String displayName;
  final String shortName;
  final ParticipantOrigin origin;
  final int handleCount;

  bool get isVirtual => origin == ParticipantOrigin.overlayVirtual;
}

@riverpod
Future<List<ParticipantSearchResult>> participantsSearch(
  ParticipantsSearchRef ref, {
  required String query,
}) async {
  final normalizedQuery = query.trim().toLowerCase();

  final workingDb = await ref.watch(driftWorkingDatabaseProvider.future);
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  final virtualContacts = await ref.watch(virtualParticipantsProvider.future);

  final overlayHandlesByParticipant = await overlayHandleIdsByParticipant(
    overlayDb,
  );
  final participantOverrides = await participantOverridesById(overlayDb);
  final workingHandleCounts = await workingHandleCountsByParticipant(workingDb);
  final overlayHandleCounts = await overlayHandleCountsByParticipant(overlayDb);

  final participantsQuery = workingDb.select(workingDb.workingParticipants);

  if (normalizedQuery.isNotEmpty) {
    final pattern = '%$normalizedQuery%';
    participantsQuery.where((tbl) {
      return tbl.displayName.lower().like(pattern) |
          tbl.shortName.lower().like(pattern);
    });
  }

  final workingParticipants = (await participantsQuery.get())
      .where(
        (participant) => !isPlaceholderDisplayName(participant.displayName),
      )
      .toList(growable: false);

  final workingResults =
      workingParticipants
          .map((participant) {
            final override = participantOverrides[participant.id];
            final overlayHandles = overlayHandlesByParticipant[participant.id];
            final displayName = () {
              final custom = override?.displayNameOverride?.trim();
              if (custom != null && custom.isNotEmpty) {
                return custom;
              }
              return participant.displayName;
            }();
            final shortName = () {
              final nickname = override?.nickname?.trim();
              if (nickname != null && nickname.isNotEmpty) {
                return nickname;
              }
              final derived = participant.shortName.trim();
              if (derived.isNotEmpty) {
                return derived;
              }
              return displayName;
            }();

            return ParticipantSearchResult(
              id: participant.id,
              displayName: displayName,
              shortName: shortName,
              origin: override != null || (overlayHandles?.isNotEmpty ?? false)
                  ? ParticipantOrigin.overlayOverride
                  : ParticipantOrigin.working,
              handleCount: workingHandleCounts[participant.id] ?? 0,
            );
          })
          .toList(growable: false)
        ..sort((a, b) => a.displayName.compareTo(b.displayName));

  final virtualResults =
      virtualContacts
          .where((virtual) {
            if (isPlaceholderDisplayName(virtual.displayName)) {
              return false;
            }
            if (normalizedQuery.isEmpty) {
              return true;
            }
            final display = virtual.displayName.toLowerCase();
            final shortName = virtual.shortName.toLowerCase();
            return display.contains(normalizedQuery) ||
                shortName.contains(normalizedQuery);
          })
          .map(
            (virtual) => ParticipantSearchResult(
              id: virtual.id,
              displayName: virtual.displayName,
              shortName: virtual.shortName,
              origin: ParticipantOrigin.overlayVirtual,
              handleCount: overlayHandleCounts[virtual.id] ?? 0,
            ),
          )
          .toList(growable: false)
        ..sort((a, b) => a.displayName.compareTo(b.displayName));

  return [...workingResults, ...virtualResults];
}
