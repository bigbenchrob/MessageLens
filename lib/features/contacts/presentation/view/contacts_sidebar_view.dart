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
import '../../domain/participant_origin.dart';
import '../widgets/grouped_contact_selector.dart';

class ContactsSidebarView extends ConsumerWidget {
  const ContactsSidebarView({required this.spec, super.key});

  final SidebarSpec spec;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsSpec = spec.when(
      contacts: (listMode, _, __) => listMode,
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

    void showSidebar({required ContactsListSpec listMode, int? participantId}) {
      ref
          .read(panelsViewStateProvider.notifier)
          .show(
            panel: WindowPanel.left,
            spec: ViewSpec.sidebar(
              SidebarSpec.contacts(
                listMode: listMode,
                selectedParticipantId: participantId,
                chatViewMode: chatViewMode,
              ),
            ),
          );
    }

    void selectParticipant(int? participantId) {
      showSidebar(listMode: contactsSpec, participantId: participantId);

      if (participantId != null) {
        ref
            .read(panelsViewStateProvider.notifier)
            .clear(panel: WindowPanel.center);
      }
    }

    void retryContacts() {
      ref.invalidate(contactsListProvider(spec: contactsSpec));
    }

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
                  onChanged: (mode) {
                    if (mode == 'unmatched') {
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
            toolBar: const ToolBar(height: 40, title: Text('Contacts')),
            children: [
              ContentArea(
                builder: (context, scrollController) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                              'Contacts:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SizedBox(
                                height: 28,
                                child: asyncContacts.when(
                                  data: (contacts) {
                                    final entries = _entriesFromContacts(
                                      contacts,
                                    );
                                    final hasSelection =
                                        selectedParticipantId != null &&
                                        entries.any(
                                          (entry) =>
                                              entry.participantId ==
                                              selectedParticipantId,
                                        );
                                    final menuSelection = hasSelection
                                        ? selectedParticipantId
                                        : null;
                                    final menuItems = _buildContactMenuItems(
                                      entries,
                                    );
                                    return MacosPopupButton<int?>(
                                      value: menuSelection,
                                      items: menuItems,
                                      onChanged: selectParticipant,
                                      itemHeight: 48,
                                    );
                                  },
                                  loading: () => const _ContactMenuLoading(),
                                  error: (error, _) => _ContactMenuError(
                                    onRetry: retryContacts,
                                    error: error,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                GroupedContactSelector(
                  selectedParticipantId: selectedParticipantId,
                  onContactSelected: (participantId) {
                    selectParticipant(participantId);
                  },
                ),
                Expanded(
                  child: asyncContacts.when(
                    data: (contacts) {
                      if (selectedParticipantId == null) {
                        return const Center(
                          child: Text(
                                  'Select a contact to view their chats',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: CupertinoColors.secondaryLabel,
                                  ),
                                ),
                              );
                            }

                            return _ChatsListForContact(
                              participantId: selectedParticipantId,
                              chatViewMode: chatViewMode,
                              contactsSpec: contactsSpec,
                            );
                          },
                          loading: () => const Center(child: ProgressCircle()),
                          error: (error, _) => Center(
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
                        ),
                      ),
                    ],
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

class _ContactMenuLoading extends StatelessWidget {
  const _ContactMenuLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 30,
      child: Align(alignment: Alignment.centerLeft, child: ProgressCircle()),
    );
  }
}

class _ContactMenuError extends StatelessWidget {
  const _ContactMenuError({required this.onRetry, required this.error});

  final VoidCallback onRetry;
  final Object error;

  @override
  Widget build(BuildContext context) {
    final typography = MacosTheme.of(context).typography;

    return Row(
      children: [
        const MacosIcon(
          CupertinoIcons.exclamationmark_triangle,
          size: 18,
          color: CupertinoColors.systemRed,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: MacosTooltip(
            message: '$error',
            child: Text(
              'Unable to load contacts',
              style: typography.caption1.copyWith(
                color: CupertinoColors.systemRed,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 8),
        PushButton(
          controlSize: ControlSize.small,
          onPressed: onRetry,
          child: const Text('Retry'),
        ),
      ],
    );
  }
}

List<_ContactMenuEntry> _entriesFromContacts(List<ContactSummary> contacts) {
  return contacts
      .map(
        (contact) => _ContactMenuEntry(
          participantId: contact.participantId,
          displayName: contact.displayName,
          shortName: contact.shortName,
          handleCount: contact.handleCount,
          origin: contact.origin,
        ),
      )
      .toList(growable: false);
}

List<MacosPopupMenuItem<int?>> _buildContactMenuItems(
  List<_ContactMenuEntry> entries,
) {
  return [
    const MacosPopupMenuItem<int?>(
      value: null,
      child: Text('Select a contact...'),
    ),
    ...entries.map(
      (entry) => MacosPopupMenuItem<int?>(
        value: entry.participantId,
        child: _ContactMenuItem(entry: entry),
      ),
    ),
  ];
}

class _ContactMenuEntry {
  const _ContactMenuEntry({
    required this.participantId,
    required this.displayName,
    required this.shortName,
    required this.handleCount,
    required this.origin,
  });

  final int participantId;
  final String displayName;
  final String shortName;
  final int handleCount;
  final ParticipantOrigin origin;
}

class _ContactMenuItem extends StatelessWidget {
  const _ContactMenuItem({required this.entry});

  final _ContactMenuEntry entry;

  @override
  Widget build(BuildContext context) {
    final typography = MacosTheme.of(context).typography;
    final subtitleParts = <String>[];

    if (entry.shortName.trim() != entry.displayName.trim()) {
      subtitleParts.add(entry.shortName);
    }

    subtitleParts.add(_formatHandleCountLabel(entry.handleCount));

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 42),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  entry.displayName,
                  style: typography.headline.copyWith(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (subtitleParts.isNotEmpty)
                  Text(
                    subtitleParts.join(' • '),
                    style: typography.caption2.copyWith(
                      color: CupertinoColors.secondaryLabel,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (entry.origin != ParticipantOrigin.working)
            _OriginBadge(origin: entry.origin),
        ],
      ),
    );
  }
}

class _OriginBadge extends StatelessWidget {
  const _OriginBadge({required this.origin});

  final ParticipantOrigin origin;

  @override
  Widget build(BuildContext context) {
    switch (origin) {
      case ParticipantOrigin.overlayVirtual:
        return const _Badge(label: 'Virtual', color: Color(0xFF9B59B6));
      case ParticipantOrigin.overlayOverride:
        return const _Badge(label: 'Override', color: Color(0xFF0A84FF));
      case ParticipantOrigin.working:
        return const SizedBox.shrink();
    }
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: MacosTheme.of(context).typography.caption2.copyWith(
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

String _formatHandleCountLabel(int count) {
  if (count <= 0) {
    return 'No linked handles';
  }

  return count == 1 ? '1 linked handle' : '$count linked handles';
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
