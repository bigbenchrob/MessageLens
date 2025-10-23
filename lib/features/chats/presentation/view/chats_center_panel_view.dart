import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../essentials/navigation/domain/entities/features/chats_spec.dart';
import '../../../../essentials/navigation/domain/entities/features/messages_spec.dart';
import '../../../../essentials/navigation/domain/entities/view_spec.dart';
import '../../../../essentials/navigation/domain/navigation_constants.dart';
import '../../../../essentials/navigation/feature_level_providers.dart';
import '../../../contacts/application/chats_for_participant_provider.dart';
import '../widgets/enhanced_chat_card.dart';

/// Center panel view for displaying chats (e.g., chats for a specific participant)
class ChatsCenterPanelView extends ConsumerWidget {
  const ChatsCenterPanelView({required this.spec, super.key});

  final ChatsSpec spec;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only handle forParticipant for now
    final participantId = spec.maybeWhen(
      forParticipant: (id) => id,
      orElse: () => null,
    );

    if (participantId == null) {
      return _buildEmptyState('Unsupported chat view');
    }

    final asyncChats = ref.watch(
      chatsForParticipantProvider(participantId: participantId),
    );

    return MacosScaffold(
      toolBar: ToolBar(height: 40, title: const Text('Chats for Contact')),
      children: [
        ContentArea(
          builder: (context, scrollController) {
            return asyncChats.when(
              data: (chats) {
                if (chats.isEmpty) {
                  return _buildEmptyState('No chats found');
                }

                return ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: chats.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    return EnhancedChatCard(
                      chat: chat,
                      onTap: () {
                        // Navigate to messages for this chat
                        ref
                            .read(panelsViewStateProvider.notifier)
                            .show(
                              panel: WindowPanel.center,
                              spec: ViewSpec.messages(
                                MessagesSpec.forChat(chatId: chat.chatId),
                              ),
                            );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CupertinoActivityIndicator()),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        CupertinoIcons.exclamationmark_triangle,
                        size: 48,
                        color: Color(0xFFFF3B30),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Error Loading Chats',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.chat_bubble_2,
            size: 48,
            color: Color(0xFFCCCCCC),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
          ),
        ],
      ),
    );
  }
}
