import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../infrastructure/repositories/messages_for_handle_provider.dart';

/// Displays ALL messages from a specific handle across all chats chronologically
class MessagesForHandleView extends HookConsumerWidget {
  const MessagesForHandleView({required this.handleId, super.key});

  final int handleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMessages = ref.watch(
      messagesForHandleProvider(handleId: handleId),
    );

    return MacosScaffold(
      toolBar: ToolBar(
        title: const Text('Messages from Handle'),
        actions: [
          ToolBarIconButton(
            icon: const MacosIcon(CupertinoIcons.search),
            label: 'Search',
            onPressed: () {
              // TODO: Implement search
            },
            showLabel: false,
          ),
        ],
      ),
      children: [
        ContentArea(
          builder: (context, scrollController) {
            return asyncMessages.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const MacosIcon(CupertinoIcons.chat_bubble_2, size: 64),
                        const SizedBox(height: 16),
                        Text(
                          'No messages found for this handle',
                          style: MacosTheme.of(context).typography.headline,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _MessageWithChatContextCard(message: message);
                  },
                );
              },
              loading: () => const Center(child: ProgressCircle()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const MacosIcon(
                      CupertinoIcons.exclamationmark_triangle,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading messages',
                      style: MacosTheme.of(context).typography.headline,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: MacosTheme.of(context).typography.body,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _MessageWithChatContextCard extends StatelessWidget {
  const _MessageWithChatContextCard({required this.message});

  final MessageWithChatContext message;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    final dateFormatter = DateFormat('MMM d, yyyy h:mm a');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.canvasColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chat context header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      CupertinoIcons.chat_bubble_2_fill,
                      size: 12,
                      color: CupertinoColors.systemBlue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      message.chatDisplayName ?? 'Chat ${message.chatId}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: theme.typography.body.color,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                dateFormatter.format(message.sentAt),
                style: TextStyle(
                  fontSize: 11,
                  color: theme.typography.body.color?.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Message sender
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: message.isFromMe
                      ? CupertinoColors.systemGreen.withValues(alpha: 0.2)
                      : CupertinoColors.systemGrey.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  message.isFromMe
                      ? CupertinoIcons.arrow_up_right
                      : CupertinoIcons.arrow_down_left,
                  size: 12,
                  color: message.isFromMe
                      ? CupertinoColors.systemGreen
                      : CupertinoColors.systemGrey,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                message.isFromMe
                    ? 'You'
                    : (message.senderHandleDisplay ??
                          message.senderHandleRaw ??
                          'Unknown'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.typography.body.color?.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Message content
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: message.isFromMe
                  ? CupertinoColors.systemBlue.withValues(alpha: 0.1)
                  : theme.dividerColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              message.text.isEmpty ? '(No text content)' : message.text,
              style: TextStyle(
                fontSize: 13,
                color: theme.typography.body.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
