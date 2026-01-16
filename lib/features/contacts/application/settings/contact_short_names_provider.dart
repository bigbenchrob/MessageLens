import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart';

part 'contact_short_names_provider.g.dart';

/// Controller for managing contact short names (nicknames) that override
/// the default display name for participants.
///
/// This stores user-defined nicknames in the overlay database, keyed by
/// 'participant:{id}'. These nicknames persist across re-imports and are
/// displayed throughout the app when the user has set the name mode to
/// "nickname".
@riverpod
class ContactShortNames extends _$ContactShortNames {
  @override
  Future<Map<String, String>> build() async {
    final overlayDb = await ref.watch(overlayDatabaseProvider.future);
    return overlayDb.getAllNicknamesByKey();
  }

  /// Set or clear a short name for a participant.
  ///
  /// Pass null or empty string to clear the nickname.
  Future<void> setShortName({
    required int participantId,
    required String? shortName,
  }) async {
    final overlayDb = await ref.watch(overlayDatabaseProvider.future);
    final trimmed = shortName?.trim();
    await overlayDb.setParticipantNickname(
      participantId,
      (trimmed == null || trimmed.isEmpty) ? null : trimmed,
    );

    // Refresh our state
    ref.invalidateSelf();
  }

  /// Clear the short name for a participant.
  Future<void> clearShortName(int participantId) async {
    await setShortName(participantId: participantId, shortName: null);
  }
}
