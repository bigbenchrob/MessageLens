import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../view_model/message_by_ordinal_provider.dart';
import '../view_model/messages_for_chat_provider.dart';

/// Renders a message at a specific ordinal position within a chat.
/// Shows loading skeleton while fetching, then full message when loaded.
class OrdinalMessageRow extends ConsumerWidget {
  const OrdinalMessageRow({
    required this.chatId,
    required this.ordinal,
    required this.buildMessage,
    super.key,
  });

  final int chatId;
  final int ordinal;
  final Widget Function(ChatMessageListItem message) buildMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageAsync = ref.watch(
      messageByOrdinalProvider(chatId: chatId, ordinal: ordinal),
    );

    return messageAsync.when(
      data: (message) {
        if (message == null) {
          return const SizedBox.shrink();
        }
        return buildMessage(message);
      },
      loading: () => const SizedBox(
        height: 60.0,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (error, stack) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            'Error loading message: $error',
            style: TextStyle(color: Colors.red[300], fontSize: 12),
          ),
        );
      },
    );
  }
}
