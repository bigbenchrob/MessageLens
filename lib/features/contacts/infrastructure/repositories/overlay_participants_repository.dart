import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../domain/overlay_virtual_contact.dart';

class OverlayParticipantsRepository {
  const OverlayParticipantsRepository();

  OverlayVirtualContact mapVirtualParticipant(VirtualParticipant row) {
    return OverlayVirtualContact(
      id: row.id,
      displayName: row.displayName,
      shortName: row.shortName,
      notes: row.notes,
      createdAtUtc: row.createdAtUtc,
      updatedAtUtc: row.updatedAtUtc,
    );
  }

  List<OverlayVirtualContact> mapVirtualParticipants(
    List<VirtualParticipant> rows,
  ) {
    return rows.map(mapVirtualParticipant).toList(growable: false);
  }
}
