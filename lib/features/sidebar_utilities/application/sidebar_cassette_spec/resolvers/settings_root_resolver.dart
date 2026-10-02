import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/sidebar_utilities_constants.dart';
import '../payloads/settings_top_menu_cassette_payload.dart';

part 'settings_root_resolver.g.dart';

@riverpod
class SettingsRootResolver extends _$SettingsRootResolver {
  @override
  void build() {
    // Stateless resolver; called by the sidebar utility coordinator.
  }

  Future<SettingsTopMenuCassettePayload> resolve({
    required int cassetteIndex,
    required SettingsMenuActionId? persistentContextActionId,
    required bool hasActiveTransientProjection,
  }) async {
    return buildSettingsTopMenuCassettePayload(
      cassetteIndex: cassetteIndex,
      persistentContextActionId: persistentContextActionId,
      expandInlineMenuWhenUnselected: !hasActiveTransientProjection,
    );
  }
}
