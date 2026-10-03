import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/sidebar_utilities_constants.dart';
import '../payloads/settings_top_menu_cassette_payload.dart';
import '../resolver_tools/settings_reset_message_data_action_availability_provider.dart';

part 'settings_root_resolver.g.dart';

@riverpod
class SettingsRootResolver extends _$SettingsRootResolver {
  late bool _resetMessageDataActionAvailable;

  @override
  void build() {
    _resetMessageDataActionAvailable = ref.watch(
      settingsResetMessageDataActionAvailableProvider,
    );
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
      resetMessageDataActionAvailable: _resetMessageDataActionAvailable,
    );
  }
}
