import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../../essentials/sidebar/application/sidebar_action_dispatcher.dart';
import '../../../../../essentials/sidebar/domain/sidebar_action_intent.dart';

part 'settings_action_list_actions_provider.g.dart';

@riverpod
class SettingsActionListActions extends _$SettingsActionListActions {
  @override
  FutureOr<void> build() {}

  Future<void> Function()? selectActionCallback({
    required SidebarActionDescriptor action,
    required int cassetteIndex,
  }) {
    if (!action.isEnabled) {
      return null;
    }

    return () async {
      await ref
          .read(sidebarActionDispatcherProvider.notifier)
          .dispatch(
            intent: action.intent,
            context: SidebarActionDispatchContext(
              sidebarMode: SidebarMode.settings,
              cassetteIndex: cassetteIndex,
            ),
          );
    };
  }
}
