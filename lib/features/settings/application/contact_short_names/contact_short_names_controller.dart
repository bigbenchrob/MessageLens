import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart';

part 'contact_short_names_controller.g.dart';

@riverpod
class ContactShortNames extends _$ContactShortNames {
  @override
  Future<Map<String, String>> build() async {
    final overlayDb = await ref.watch(overlayDatabaseProvider.future);
    return overlayDb.getAllNicknamesByKey();
  }

  Future<void> setShortName({
    required String contactKey,
    required String? shortName,
  }) async {
    final overlayDb = await ref.watch(overlayDatabaseProvider.future);
    final trimmed = shortName?.trim();

    // Extract participantId from contactKey (format: "participant:123")
    if (!contactKey.startsWith('participant:')) {
      throw ArgumentError(
        'contactKey must start with "participant:", got: $contactKey',
      );
    }

    final participantIdStr = contactKey.substring('participant:'.length);
    final participantId = int.tryParse(participantIdStr);

    if (participantId == null) {
      throw ArgumentError('Invalid participantId in contactKey: $contactKey');
    }

    // Save to overlay database
    if (trimmed == null || trimmed.isEmpty) {
      await overlayDb.deleteParticipantOverride(participantId);
    } else {
      await overlayDb.setParticipantNickname(participantId, trimmed);
    }

    // Reload state from database
    final updated = await overlayDb.getAllNicknamesByKey();
    state = AsyncData(updated);
  }

  Future<void> refresh() async {
    final overlayDb = await ref.watch(overlayDatabaseProvider.future);
    state = const AsyncLoading<Map<String, String>>().copyWithPrevious(state);
    final latest = await overlayDb.getAllNicknamesByKey();
    state = AsyncData(latest);
  }
}
