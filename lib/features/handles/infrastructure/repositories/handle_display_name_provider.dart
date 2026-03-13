import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart';

part 'handle_display_name_provider.g.dart';

/// Resolves the display name for a handle, checking overlay overrides first.
///
/// Priority: virtual participant name > real participant name > raw handle value.
@riverpod
Future<String> handleDisplayName(Ref ref, {required int handleId}) async {
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  final workingDb = await ref.watch(driftWorkingDatabaseProvider.future);

  // Check overlay for a linked virtual or real participant.
  final override = await overlayDb.getHandleOverride(handleId);
  if (override != null) {
    // Virtual participant link?
    if (override.virtualParticipantId != null) {
      final vp = await overlayDb.getVirtualParticipant(
        override.virtualParticipantId!,
      );
      if (vp != null) {
        return vp.displayName;
      }
    }

    // Real participant link?
    if (override.participantId != null) {
      final participant =
          await (workingDb.select(workingDb.workingParticipants)
                ..where((tbl) => tbl.id.equals(override.participantId!)))
              .getSingleOrNull();
      if (participant != null) {
        return participant.displayName;
      }
    }
  }

  // Fall back to the raw handle display name from the working DB.
  final handle = await (workingDb.select(
    workingDb.handlesCanonical,
  )..where((tbl) => tbl.id.equals(handleId))).getSingleOrNull();
  return handle?.displayName ?? 'Handle #$handleId';
}
