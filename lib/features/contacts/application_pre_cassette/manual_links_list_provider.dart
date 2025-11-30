import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/db/feature_level_providers.dart';
import '../domain/manual_handle_link.dart';

part 'manual_links_list_provider.g.dart';

/// Provider that fetches all manual handle-to-participant links
///
/// This joins overlay database overrides with working database to provide
/// enriched display information (handle identifiers, participant names).
@riverpod
Future<List<ManualHandleLink>> manualLinksList(ManualLinksListRef ref) async {
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  final workingDb = await ref.watch(driftWorkingDatabaseProvider.future);

  // Fetch all manual overrides from overlay DB
  final overrides = await overlayDb.getAllHandleOverrides();

  final results = <ManualHandleLink>[];

  for (final override in overrides) {
    // Get handle details from working DB
    final handleQuery = workingDb.select(workingDb.handlesCanonical)
      ..where((tbl) => tbl.id.equals(override.handleId));

    final handle = await handleQuery.getSingleOrNull();

    if (handle == null) {
      continue; // Handle no longer exists in working DB
    }

    // Get participant details from working DB
    final participantQuery = workingDb.select(workingDb.workingParticipants)
      ..where((tbl) => tbl.id.equals(override.participantId));

    final participant = await participantQuery.getSingleOrNull();

    if (participant == null) {
      continue; // Participant no longer exists in working DB
    }

    results.add(
      ManualHandleLink(
        handleId: override.handleId,
        handleIdentifier: handle.rawIdentifier,
        participantId: override.participantId,
        participantName: participant.displayName,
        createdAt: DateTime.parse(override.createdAtUtc).toLocal(),
      ),
    );
  }

  // Sort by creation date (newest first)
  results.sort((a, b) => b.createdAt.compareTo(a.createdAt));

  return results;
}
