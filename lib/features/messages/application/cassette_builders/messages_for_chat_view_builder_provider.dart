import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../presentation/view/messages_for_chat_view.dart';

part 'messages_for_chat_view_builder_provider.g.dart';

/// Resolves the widget used to display messages for a specific chat.
@riverpod
Widget messagesForChatViewBuilder(
  MessagesForChatViewBuilderRef ref,
  int chatId, {
  DateTime? scrollToDate,
}) {
  return MessagesForChatView(chatId: chatId, scrollToDate: scrollToDate);
}
