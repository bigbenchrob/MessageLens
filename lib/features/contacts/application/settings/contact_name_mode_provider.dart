import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/domain/overlay_db_constants.dart';
import '../../../../essentials/db/feature_level_providers.dart';

part 'contact_name_mode_provider.g.dart';

/// Key provider for the global default contact name mode.
///
/// Reads the persisted preference from the overlay database and falls back to
/// [ParticipantNameMode.firstNameOnly] when no explicit override exists yet.
@riverpod
Future<ParticipantNameMode> contactNameMode(ContactNameModeRef ref) async {
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  return overlayDb.getDefaultParticipantNameMode();
}

/// Command provider for updating the global contact name mode preference.
///
/// Persists the new mode in the overlay database and invalidates the
/// [contactNameModeProvider] so dependents refresh automatically.
@riverpod
Future<void> setContactNameMode(
  SetContactNameModeRef ref,
  ParticipantNameMode mode,
) async {
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  await overlayDb.setDefaultParticipantNameMode(mode);
  ref.invalidate(contactNameModeProvider);
}
