import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import '../../../../essentials/navigation/domain/entities/features/messages_spec.dart';
import '../../../../essentials/navigation/domain/entities/view_spec.dart';
import '../../../../essentials/navigation/domain/navigation_constants.dart';
import '../../../../essentials/navigation/feature_level_providers.dart';
import '../view_model/chats_for_contact_provider.dart';

/// UI component showing all chats with a specific contact.
///
/// This implements the "Show all chats with Danny" feature by:
/// - Querying all handles linked to the participant
/// - Displaying all conversations across different communication methods
/// - Allowing users to navigate to any specific chat
class ChatsForContactView extends HookConsumerWidget {
  const ChatsForContactView({required this.participantId, super.key});

  final int participantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    final participantAsync = ref.watch(
      participantInfoProvider(participantId: participantId),
    );
    final chatsAsync = ref.watch(
      chatsForContactProvider(participantId: participantId),
    );
    final dateFormatter = DateFormat('MMM d, yyyy • h:mm a');

    return ColoredBox(
      color: const Color(0xFFF4F5F8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with participant name
            participantAsync.when(
              data: (WorkingParticipant? participant) {
                final displayName =
                    participant?.displayName ?? 'Unknown Contact';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'All conversations with',
                      style: MacosTheme.of(context).typography.title3.copyWith(
                        color: const Color(0xFF6B6B70),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayName,
                      style: MacosTheme.of(context).typography.headline
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                );
              },
              loading: () => const _HeaderLoading(),
              error: (error, _) => Text('Error loading contact: $error'),
            ),
            const SizedBox(height: 20),

            // Chat list
            Expanded(
              child: chatsAsync.when(
                data: (List<ContactChatSummary> chats) {
                  if (chats.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MacosIcon(
                            CupertinoIcons.chat_bubble,
                            size: 48,
                            color: Color(0xFFBDBDBD),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No conversations found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF767680),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "This contact hasn't been part of any imported conversations yet.",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF999999),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return MacosScrollbar(
                    controller: scrollController,
                    thumbVisibility: true,
                    child: ListView.separated(
                      controller: scrollController,
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      itemCount: chats.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final chat = chats[index];
                        return _ContactChatCard(
                          chat: chat,
                          dateFormatter: dateFormatter,
                          onTap: () {
                            // Navigate to the specific chat
                            final spec = ViewSpec.messages(
                              MessagesSpec.forChat(chatId: chat.chatId),
                            );

                            ref
                                .read(panelsViewStateProvider.notifier)
                                .show(panel: WindowPanel.center, spec: spec);
                          },
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 32),
                    child: ProgressCircle(radius: 12),
                  ),
                ),
                error: (error, stackTrace) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const MacosIcon(
                        CupertinoIcons.exclamationmark_triangle,
                        size: 48,
                        color: Color(0xFFD14343),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load conversations',
                        style: MacosTheme.of(context).typography.title3,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$error',
                        style: const TextStyle(color: Color(0xFF999999)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderLoading extends StatelessWidget {
  const _HeaderLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All conversations with',
          style: MacosTheme.of(
            context,
          ).typography.title3.copyWith(color: const Color(0xFF6B6B70)),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const ProgressCircle(radius: 8),
            const SizedBox(width: 12),
            Text(
              'Loading...',
              style: MacosTheme.of(
                context,
              ).typography.headline.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}

class _ContactChatCard extends StatelessWidget {
  const _ContactChatCard({
    required this.chat,
    required this.dateFormatter,
    required this.onTap,
  });

  final ContactChatSummary chat;
  final DateFormat dateFormatter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    final typography = theme.typography;

    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF2C2C33)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E2EA)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chat title and message count
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chat.title,
                          style: typography.title2.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${chat.messageCount} message${chat.messageCount == 1 ? '' : 's'}',
                          style: typography.caption1.copyWith(
                            color: const Color(0xFF6B6B70),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Service badge
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: _getServiceColor(
                        chat.service,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Text(
                        chat.service,
                        style: typography.caption1.copyWith(
                          color: _getServiceColor(chat.service),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Handle and last message date
              Row(
                children: [
                  Expanded(
                    child: Text(
                      chat.handle,
                      style: typography.caption1.copyWith(
                        color: const Color(0xFF999999),
                        fontFamily: 'SF Mono', // Monospace for handles
                      ),
                    ),
                  ),
                  if (chat.lastMessageDate != null) ...[
                    const SizedBox(width: 16),
                    Text(
                      dateFormatter.format(chat.lastMessageDate!),
                      style: typography.caption1.copyWith(
                        color: const Color(0xFF999999),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getServiceColor(String service) {
    switch (service.toLowerCase()) {
      case 'imessage':
        return const Color(0xFF007AFF); // iOS blue
      case 'sms':
        return const Color(0xFF34C759); // iOS green
      case 'rcs':
        return const Color(0xFFFF9500); // iOS orange
      default:
        return const Color(0xFF8E8E93); // iOS gray
    }
  }
}
