import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart';
import '../../domain/overlay_virtual_contact.dart';
import 'overlay_participants_repository.dart';

part 'virtual_participants_provider.g.dart';

/// Provides the list of virtual contacts stored in user_overlays.db.
@riverpod
Future<List<OverlayVirtualContact>> virtualParticipants(
  VirtualParticipantsRef ref,
) async {
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  final rows = await overlayDb.getVirtualParticipants();
  return const OverlayParticipantsRepository().mapVirtualParticipants(rows);
}
