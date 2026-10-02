import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../../essentials/sidebar/application/sidebar_action_dispatcher.dart';
import '../../../../../essentials/sidebar/domain/sidebar_action_intent.dart';

part 'settings_action_list_actions_provider.g.dart';

@riverpod
class SettingsActionListActions extends _$SettingsActionListActions {
  @override
  SidebarActionIntent? build() => null;

  Future<void> Function()? selectActionCallback({
    required SidebarActionDescriptor action,
    required int cassetteIndex,
  }) {
    if (!action.isEnabled || state != null) {
      return null;
    }

    return () async {
      if (state != null) {
        return;
      }

      final intent = action.intent;
      final keepAlive = ref.keepAlive();
      state = intent;
      try {
        await ref
            .read(sidebarActionDispatcherProvider.notifier)
            .dispatch(
              intent: intent,
              context: SidebarActionDispatchContext(
                sidebarMode: SidebarMode.settings,
                cassetteIndex: cassetteIndex,
              ),
            );
      } finally {
        if (identical(state, intent)) {
          state = null;
        }
        keepAlive.close();
      }
    };
  }
}
