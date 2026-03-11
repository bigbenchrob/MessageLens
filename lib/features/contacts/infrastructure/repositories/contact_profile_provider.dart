import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart';
import '../../domain/overlay_virtual_contact.dart';
import '../../domain/participant_origin.dart';
import 'virtual_participants_provider.dart';

part 'contact_profile_provider.g.dart';

class ContactProfileSummary {
  const ContactProfileSummary({
    required this.contactId,
    required this.displayName,
    required this.shortName,
    required this.origin,
  });

  final int contactId;
  final String displayName;
  final String shortName;
  final ParticipantOrigin origin;
}

@riverpod
Future<ContactProfileSummary?> contactProfile(
  ContactProfileRef ref, {
  required int contactId,
}) async {
  final workingDb = await ref.watch(driftWorkingDatabaseProvider.future);
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);

  final participantRow = await (workingDb.select(
    workingDb.workingParticipants,
  )..where((tbl) => tbl.id.equals(contactId))).getSingleOrNull();

  if (participantRow != null) {
    final overrideRow = await (overlayDb.select(
      overlayDb.participantOverrides,
    )..where((tbl) => tbl.participantId.equals(contactId))).getSingleOrNull();

    final displayNameOverride = overrideRow?.displayNameOverride?.trim();
    final displayName =
        (displayNameOverride != null && displayNameOverride.isNotEmpty)
        ? displayNameOverride
        : participantRow.displayName;
    final nickname = overrideRow?.nickname?.trim();
    final shortName = (nickname?.isNotEmpty ?? false)
        ? nickname!
        : participantRow.shortName.trim().isEmpty
        ? displayName
        : participantRow.shortName;

    final origin = overrideRow != null
        ? ParticipantOrigin.overlayOverride
        : ParticipantOrigin.working;

    return ContactProfileSummary(
      contactId: contactId,
      displayName: displayName,
      shortName: shortName,
      origin: origin,
    );
  }

  final virtualContacts = await ref.watch(virtualParticipantsProvider.future);
  OverlayVirtualContact? virtual;
  for (final candidate in virtualContacts) {
    if (candidate.id == contactId) {
      virtual = candidate;
      break;
    }
  }

  if (virtual != null) {
    return ContactProfileSummary(
      contactId: contactId,
      displayName: virtual.displayName,
      shortName: virtual.shortName,
      origin: ParticipantOrigin.overlayVirtual,
    );
  }

  return null;
}
