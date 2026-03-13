import 'package:drift/drift.dart' as drift;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart';

part 'handles_for_contact_provider.freezed.dart';
part 'handles_for_contact_provider.g.dart';

/// A handle linked to a contact, with its display value and link source.
@freezed
abstract class LinkedHandle with _$LinkedHandle {
  const factory LinkedHandle({
    required int handleId,
    required String displayValue,
    required String service,

    /// Whether this link came from an overlay override (manual link)
    /// rather than the working DB (address book auto-link).
    required bool isOverrideLink,
  }) = _LinkedHandle;
}

/// Returns all handles linked to a contact, merging working DB and overlay.
///
/// For working-DB participants, handles come from `handle_to_participant`.
/// For virtual participants (id >= 1,000,000,000), handles come from
/// `handle_to_participant_overrides` in the overlay DB.
/// Overlay links for real participants are also included.
@riverpod
Future<List<LinkedHandle>> handlesForContact(
  Ref ref, {
  required int contactId,
}) async {
  final workingDb = await ref.watch(driftWorkingDatabaseProvider.future);
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);

  final results = <int, LinkedHandle>{};
  const virtualIdFloor = 1000000000;

  // Working DB handles (only for real participants).
  if (contactId < virtualIdFloor) {
    final query = workingDb.select(workingDb.handlesCanonical).join([
      drift.innerJoin(
        workingDb.handleToParticipant,
        workingDb.handleToParticipant.handleId.equalsExp(
          workingDb.handlesCanonical.id,
        ),
      ),
    ])..where(workingDb.handleToParticipant.participantId.equals(contactId));

    for (final row in await query.get()) {
      final handle = row.readTable(workingDb.handlesCanonical);
      results[handle.id] = LinkedHandle(
        handleId: handle.id,
        displayValue: handle.displayName,
        service: handle.service,
        isOverrideLink: false,
      );
    }
  }

  // Overlay overrides — could point to real or virtual participant.
  final overrides = contactId >= virtualIdFloor
      ? await overlayDb.getOverridesForVirtualParticipant(contactId)
      : await overlayDb.getOverridesForParticipant(contactId);

  for (final override in overrides) {
    // Look up the handle's display value from the working DB.
    final handle = await (workingDb.select(
      workingDb.handlesCanonical,
    )..where((tbl) => tbl.id.equals(override.handleId))).getSingleOrNull();

    if (handle != null) {
      results[handle.id] = LinkedHandle(
        handleId: handle.id,
        displayValue: handle.displayName,
        service: handle.service,
        isOverrideLink: true,
      );
    }
  }

  return results.values.toList();
}
