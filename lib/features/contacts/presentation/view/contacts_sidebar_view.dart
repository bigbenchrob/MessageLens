import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../essentials/navigation/domain/entities/features/chat_view_mode.dart';
import '../../../../essentials/navigation/domain/entities/features/contacts_list_spec.dart';
import '../../../../essentials/navigation/domain/entities/features/handles_list_spec.dart';
import '../../../../essentials/navigation/domain/entities/features/messages_spec.dart';
import '../../../../essentials/navigation/domain/entities/features/sidebar_spec.dart';
import '../../../../essentials/navigation/domain/entities/view_spec.dart';
import '../../../../essentials/navigation/domain/navigation_constants.dart';
import '../../../../essentials/navigation/feature_level_providers.dart';
import '../../../chats/presentation/widgets/calendar_heatmap_timeline_widget.dart';
import '../../../chats/presentation/widgets/enhanced_chat_card.dart';
import '../../application/contact_timeline_provider.dart';
import '../../application/contacts_list_provider.dart';
import '../../application/sorted_chats_for_participant_provider.dart';

class ContactsSidebarView extends HookConsumerWidget {
  const ContactsSidebarView({required this.spec, super.key});

  final SidebarSpec spec;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Extract the current list mode, selected participant, and chat view mode
    final contactsSpec = spec.when(
      contacts: (listMode, selectedParticipantId, chatViewMode) => listMode,
      unmatchedHandles: (_) => throw StateError('Wrong spec type'),
    );

    final selectedParticipantId = spec.when(
      contacts: (_, selectedId, __) => selectedId,
      unmatchedHandles: (_) => null,
    );

    final chatViewMode = spec.when(
      contacts: (_, __, viewMode) => viewMode,
      unmatchedHandles: (_) => ChatViewMode.recentActivity,
    );

    final asyncContacts = ref.watch(contactsListProvider(spec: contactsSpec));

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: MacosTheme.of(context).dividerColor,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              const Text(
                'Show messages from:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MacosPopupButton<String>(
                  value: 'contacts',
                  onChanged: (newMode) {
                    if (newMode == 'unmatched') {
                      // Switch to unmatched handles view
                      ref
                          .read(panelsViewStateProvider.notifier)
                          .show(
                            panel: WindowPanel.left,
                            spec: const ViewSpec.sidebar(
                              SidebarSpec.unmatchedHandles(
                                listMode: HandlesListSpec.phones(
                                  filterMode: PhoneFilterMode.all,
                                ),
                              ),
                            ),
                          );
                    }
                  },
                  items: const [
                    MacosPopupMenuItem(
                      value: 'contacts',
                      child: Text('Contacts'),
                    ),
                    MacosPopupMenuItem(
                      value: 'unmatched',
                      child: Text('Unmatched phone or email'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: MacosScaffold(
            toolBar: ToolBar(
              height: 40,
              title: const Text('Contacts'),
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
                  return asyncContacts.when(
                    data: (contacts) {
                      return Column(
                        children: [
                          // Contact selector dropdown (Menu B)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: MacosTheme.of(context).dividerColor,
                                  width: 0.5,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  'Contact:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: MacosPopupButton<int?>(
                                    value: selectedParticipantId,
                                    onChanged: (participantId) {
                                      if (participantId != null) {
                                        // Update sidebar to show chats for this contact
                                        ref
                                            .read(
                                              panelsViewStateProvider.notifier,
                                            )
                                            .show(
                                              panel: WindowPanel.left,
                                              spec: ViewSpec.sidebar(
                                                SidebarSpec.contacts(
                                                  listMode: contactsSpec,
                                                  selectedParticipantId:
                                                      participantId,
                                                  chatViewMode: chatViewMode,
                                                ),
                                              ),
                                            );

                                        // Clear center panel - it will show content when a chat is clicked
                                        ref
                                            .read(
                                              panelsViewStateProvider.notifier,
                                            )
                                            .clear(panel: WindowPanel.center);
                                      }
                                    },
                                    items: [
                                      const MacosPopupMenuItem<int?>(
                                        value: null,
                                        child: Text('Select a contact...'),
                                      ),
                                      ...contacts.map(
                                        (contact) => MacosPopupMenuItem<int?>(
                                          value: contact.participantId,
                                          child: Text(contact.displayName),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Filter radio buttons
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: MacosTheme.of(context).dividerColor,
                                  width: 0.5,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      const Text('All Contacts'),
                                      const SizedBox(width: 8),
                                      MacosRadioButton<String>(
                                        value: 'all',
                                        groupValue: contactsSpec.when(
                                          all: () => 'all',
                                          alphabetical: () => 'alphabetical',
                                          favorites: () => 'favorites',
                                        ),
                                        onChanged: (value) {
                                          ref
                                              .read(
                                                panelsViewStateProvider
                                                    .notifier,
                                              )
                                              .show(
                                                panel: WindowPanel.left,
                                                spec: ViewSpec.sidebar(
                                                  SidebarSpec.contacts(
                                                    listMode:
                                                        const ContactsListSpec.all(),
                                                    selectedParticipantId:
                                                        selectedParticipantId,
                                                    chatViewMode: chatViewMode,
                                                  ),
                                                ),
                                              );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      const Text('A-Z'),
                                      const SizedBox(width: 8),
                                      MacosRadioButton<String>(
                                        value: 'alphabetical',
                                        groupValue: contactsSpec.when(
                                          all: () => 'all',
                                          alphabetical: () => 'alphabetical',
                                          favorites: () => 'favorites',
                                        ),
                                        onChanged: (value) {
                                          ref
                                              .read(
                                                panelsViewStateProvider
                                                    .notifier,
                                              )
                                              .show(
                                                panel: WindowPanel.left,
                                                spec: ViewSpec.sidebar(
                                                  SidebarSpec.contacts(
                                                    listMode:
                                                        const ContactsListSpec.alphabetical(),
                                                    selectedParticipantId:
                                                        selectedParticipantId,
                                                    chatViewMode: chatViewMode,
                                                  ),
                                                ),
                                              );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      const Text('Favorites'),
                                      const SizedBox(width: 8),
                                      MacosRadioButton<String>(
                                        value: 'favorites',
                                        groupValue: contactsSpec.when(
                                          all: () => 'all',
                                          alphabetical: () => 'alphabetical',
                                          favorites: () => 'favorites',
                                        ),
                                        onChanged: (value) {
                                          ref
                                              .read(
                                                panelsViewStateProvider
                                                    .notifier,
                                              )
                                              .show(
                                                panel: WindowPanel.left,
                                                spec: ViewSpec.sidebar(
                                                  SidebarSpec.contacts(
                                                    listMode:
                                                        const ContactsListSpec.favorites(),
                                                    selectedParticipantId:
                                                        selectedParticipantId,
                                                    chatViewMode: chatViewMode,
                                                  ),
                                                ),
                                              );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Empty state or chats list
                          if (selectedParticipantId == null)
                            const Expanded(
                              child: Center(
                                child: Text(
                                  'Select a contact to view their chats',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: CupertinoColors.secondaryLabel,
                                  ),
                                ),
                              ),
                            )
                          else
                            Expanded(
                              child: _ChatsListForContact(
                                participantId: selectedParticipantId,
                                chatViewMode: chatViewMode,
                                contactsSpec: contactsSpec,
                              ),
                            ),
                        ],
                      );
                    },
                    loading: () => const Center(child: ProgressCircle()),
                    error: (error, stack) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const MacosIcon(
                            CupertinoIcons.exclamationmark_triangle,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text('Error loading contacts: $error'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Widget that displays the list of chats for a selected contact
class _ChatsListForContact extends HookConsumerWidget {
  const _ChatsListForContact({
    required this.participantId,
    required this.chatViewMode,
    required this.contactsSpec,
  });

  final int participantId;
  final ChatViewMode chatViewMode;
  final ContactsListSpec contactsSpec;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncChats = ref.watch(
      sortedChatsForParticipantProvider(
        participantId: participantId,
        viewMode: chatViewMode,
      ),
    );

    return asyncChats.when(
      data: (chats) {
        if (chats.isEmpty) {
          return const Center(
            child: Text(
              'No chats found for this contact',
              style: TextStyle(
                fontSize: 14,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            // Pinned "All Messages" card at the top
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                child: _AllMessagesCard(
                  participantId: participantId,
                  totalMessages: chats.fold<int>(
                    0,
                    (sum, chat) => sum + chat.messageCount,
                  ),
                  onTap: () {
                    // Navigate to unified contact messages view
                    ref
                        .read(panelsViewStateProvider.notifier)
                        .show(
                          panel: WindowPanel.center,
                          spec: ViewSpec.messages(
                            MessagesSpec.forContact(contactId: participantId),
                          ),
                        );
                  },
                ),
              ),
            ),
            // Pinned header with view mode selector
            SliverAppBar(
              pinned: true,
              backgroundColor: MacosTheme.of(context).canvasColor,
              automaticallyImplyLeading: false,
              toolbarHeight: 40,
              flexibleSpace: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: MacosTheme.of(context).dividerColor,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      'View mode:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: MacosPopupButton<ChatViewMode>(
                        value: chatViewMode,
                        onChanged: (newMode) {
                          if (newMode != null) {
                            ref
                                .read(panelsViewStateProvider.notifier)
                                .show(
                                  panel: WindowPanel.left,
                                  spec: ViewSpec.sidebar(
                                    SidebarSpec.contacts(
                                      listMode: contactsSpec,
                                      selectedParticipantId: participantId,
                                      chatViewMode: newMode,
                                    ),
                                  ),
                                );
                          }
                        },
                        items: const [
                          MacosPopupMenuItem(
                            value: ChatViewMode.recentActivity,
                            child: Text('Recent Activity'),
                          ),
                          MacosPopupMenuItem(
                            value: ChatViewMode.newestFirst,
                            child: Text('Newest First'),
                          ),
                          MacosPopupMenuItem(
                            value: ChatViewMode.oldestFirst,
                            child: Text('Oldest First'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Chats list
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final chat = chats[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: EnhancedChatCard(
                    chat: chat,
                    onTap: () {
                      // Show messages for this chat in center panel
                      ref
                          .read(panelsViewStateProvider.notifier)
                          .show(
                            panel: WindowPanel.center,
                            spec: ViewSpec.messages(
                              MessagesSpec.forChat(chatId: chat.chatId),
                            ),
                          );
                    },
                  ),
                );
              }, childCount: chats.length),
            ),
          ],
        );
      },
      loading: () => const Center(child: ProgressCircle()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const MacosIcon(CupertinoIcons.exclamationmark_triangle, size: 48),
            const SizedBox(height: 16),
            Text('Error loading chats: $error'),
          ],
        ),
      ),
    );
  }
}

/// Card styled like EnhancedChatCard that shows aggregated "All Messages"
/// view for a contact across all their chats/handles.
class _AllMessagesCard extends ConsumerWidget {
  const _AllMessagesCard({
    required this.participantId,
    required this.totalMessages,
    required this.onTap,
  });

  final int participantId;
  final int totalMessages;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = MacosTheme.of(context);
    final typography = theme.typography;
    final isDark = theme.brightness == Brightness.dark;

    // Format message count with space separators
    final countText = totalMessages.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]} ',
    );

    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          // Subtle highlight to distinguish from regular chat cards
          color: isDark ? const Color(0xFF3A3A45) : const Color(0xFFF5F5FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF4A4A55) : const Color(0xFFD0D0DA),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
              // Primary row: "All Messages" title + message count badge
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.chat_bubble_text_fill,
                    size: 16,
                    color: Color(0xFF007AFF),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'All Messages',
                      style: typography.title2.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF007AFF),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF007AFF).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      countText,
                      style: typography.caption1.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF007AFF),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // Secondary text: Explanation
              Text(
                'View chronological history across all conversations',
                style: typography.caption1.copyWith(
                  color: isDark
                      ? const Color(0xFFAAAAAA)
                      : const Color(0xFF888888),
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Calendar heatmap timeline visualization
              _ContactTimelineWidget(participantId: participantId),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget that loads and displays the timeline for a contact
class _ContactTimelineWidget extends ConsumerWidget {
  const _ContactTimelineWidget({required this.participantId});

  final int participantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineAsync = ref.watch(
      contactTimelineProvider(contactId: participantId),
    );

    return timelineAsync.when(
      data: (timeline) {
        if (timeline == null) {
          return const SizedBox(
            height: 40,
            child: Center(
              child: Text(
                'No timeline data available',
                style: TextStyle(fontSize: 11, color: Color(0xFF999999)),
              ),
            ),
          );
        }

        return CalendarHeatmapTimelineWidget(
          data: timeline,
          monthSize: 14,
          monthSpacing: 2,
          onMonthTap: (year, month, messageCount) {
            // Navigate to contact messages view with scroll to that month
            final scrollDate = DateTime(year, month);
            print(
              '[CONTACT_TIMELINE] Tapped $year-${month.toString().padLeft(2, '0')} '
              '($messageCount messages) for contact $participantId - scrolling to $scrollDate',
            );

            ref
                .read(panelsViewStateProvider.notifier)
                .show(
                  panel: WindowPanel.center,
                  spec: ViewSpec.messages(
                    MessagesSpec.forContact(
                      contactId: participantId,
                      scrollToDate: scrollDate,
                    ),
                  ),
                );
          },
        );
      },
      loading: () => const SizedBox(
        height: 40,
        child: Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (error, stack) => SizedBox(
        height: 40,
        child: Center(
          child: Text(
            'Error loading timeline',
            style: TextStyle(
              fontSize: 11,
              color: MacosTheme.of(context).brightness == Brightness.dark
                  ? const Color(0xFFD14343)
                  : const Color(0xFFB71C1C),
            ),
          ),
        ),
      ),
    );
  }
}
