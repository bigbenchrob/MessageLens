import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/navigation/domain/entities/features/messages_spec.dart';
import '../../../../essentials/navigation/domain/entities/view_spec.dart';
import '../../../../essentials/navigation/domain/navigation_constants.dart';
import '../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../essentials/navigation/feature_level_providers.dart';

part 'chats_view_model_provider.g.dart';

/// View model that handles chat-centric user actions like selection.
@riverpod
class ChatsViewModel extends _$ChatsViewModel {
  @override
  void build() {
    // Stateless controller.
  }

  Future<void> selectChat(int chatId) async {
    final notifier = ref.read(
      panelsViewStateProvider(SidebarMode.messages).notifier,
    );
    notifier.show(
      panel: WindowPanel.center,
      spec: ViewSpec.messages(MessagesSpec.forChat(chatId: chatId)),
    );
  }
}
