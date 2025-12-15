import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../essentials/db_importers/presentation/view_model/db_import_control_provider.dart';
import '../../../../essentials/navigation/domain/entities/features/chats_spec.dart';
import '../../../../essentials/navigation/domain/entities/features/messages_spec.dart';
import '../../../../essentials/navigation/domain/entities/view_spec.dart';
import '../../../../essentials/navigation/domain/navigation_constants.dart';
import '../../../../essentials/navigation/feature_level_providers.dart';
import '../../application/chats_by_age_provider.dart';
import '../view_model/chat_list_header_provider.dart';
import '../view_model/chats_view_model_provider.dart';
import '../view_model/recent_chats_provider.dart';

class ChatsSidebarView extends HookConsumerWidget {
  const ChatsSidebarView({required this.spec, super.key});

  final ChatsSpec spec;

  int? _resolveLimit() {
    return spec.when(
      list: () => null,
      forContact: (_) => null,
      recent: (limit) => limit,
      byAgeOldest: (limit) => limit,
      byAgeNewest: (limit) => limit,
      unmatched: (limit) => limit,
      forParticipant: (_) => null,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final limit = _resolveLimit();
    final scrollController = useScrollController();

    // Select provider based on spec variant
    final asyncChats = spec.when(
      recent: (limit) => ref.watch(recentChatsProvider(limit: limit)),
      byAgeOldest: (limit) => ref.watch(chatsByAgeProvider(limit: limit)),
      byAgeNewest: (limit) => ref.watch(chatsByAgeRecentProvider(limit: limit)),
      unmatched: (limit) => ref.watch(unmatchedChatsProvider(limit: limit)),
      list: () => ref.watch(recentChatsProvider()),
      forContact: (_) => ref.watch(recentChatsProvider()),
      forParticipant: (_) => ref.watch(recentChatsProvider()),
    );

    final senderFilterChatId = useState<int?>(null);
    final sortAlphabetically = useState(false);

    useEffect(() {
      asyncChats.whenData((chats) {
        final filterValue = senderFilterChatId.value;
        if (filterValue != null &&
            chats.every((chat) => chat.chatId != filterValue)) {
          senderFilterChatId.value = null;
        }
      });
      return null;
    }, [asyncChats]);

    final filterSection = asyncChats.when(
      data: (chats) => _SenderFilter(
        chats: chats,
        selectedChatId: senderFilterChatId.value,
        sortAlphabetically: sortAlphabetically.value,
        currentSpec: spec,
        onSelectedChatIdChanged: (value) {
          senderFilterChatId.value = value;
        },
        onSortAlphabeticallyChanged: (value) {
          sortAlphabetically.value = value;
        },
      ),
      loading: () => const _SenderFilterLoading(),
      error: (Object error, StackTrace _) => _SenderFilterError(error: error),
    );
    final dateFormatter = DateFormat('MMM d, yyyy • h:mm a');
    final headerTitle = ref.watch(
      chatListHeaderProvider(
        spec: spec,
        limit: limit,
        selectedChatId: senderFilterChatId.value,
      ),
    );

    // Watch the center panel to determine which chat is currently selected
    final panelState = ref.watch(panelsViewStateProvider);
    final centerStack = panelState[WindowPanel.center];
    final centerSpec = centerStack?.activePage?.spec;

    // Extract the selected chatId if viewing messages for a chat
    int? selectedChatId;
    if (centerSpec != null) {
      centerSpec.when(
        messages: (MessagesSpec messagesSpec) {
          messagesSpec.when<void>(
            forChat: (int chatId) {
              selectedChatId = chatId;
            },
            forContact: (_, __) {},
            recent: (_) {},
            globalTimeline: () {},
            forHandle: (_) {},
            forChatInDateRange: (chatId, _, __) {
              selectedChatId = chatId;
            },
          );
        },
        chats: (_) {},
        contacts: (_) {},
        import: (_) {},
        settings: (_) {},
        workbench: (_) {},
        sidebar: (_) {},
      );
    }

    return ColoredBox(
      color: const Color(0xFFF4F5F8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SearchPlaceholder(),
            const SizedBox(height: 16),
            filterSection,
            const SizedBox(height: 24),
            Text(
              headerTitle,
              style: MacosTheme.of(
                context,
              ).typography.headline.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: asyncChats.when(
                data: (List<RecentChatSummary> chats) {
                  if (chats.isEmpty) {
                    return const Center(
                      child: Text(
                        'No chats found. Start an import to populate your data.',
                        style: TextStyle(color: Color(0xFF7A7A7F)),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final filteredChats = senderFilterChatId.value == null
                      ? chats
                      : chats
                            .where(
                              (chat) => chat.chatId == senderFilterChatId.value,
                            )
                            .toList();

                  if (filteredChats.isEmpty) {
                    return const Center(
                      child: Text(
                        'No chats match the selected sender.',
                        style: TextStyle(color: Color(0xFF7A7A7F)),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      await ref
                          .read(dbImportControlViewModelProvider.notifier)
                          .runImportAndMigration(awaitCompletion: false);
                      await Future<void>.delayed(
                        const Duration(milliseconds: 400),
                      );
                    },
                    child: MacosScrollbar(
                      controller: scrollController,
                      thumbVisibility: true,
                      child: ListView.separated(
                        controller: scrollController,
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        itemCount: filteredChats.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final chat = filteredChats[index];
                          return _ChatSummaryCard(
                            summary: chat,
                            dateFormatter: dateFormatter,
                            isSelected: selectedChatId == chat.chatId,
                            onTap: () async {
                              await ref
                                  .read(chatsViewModelProvider.notifier)
                                  .selectChat(chat.chatId);
                            },
                          );
                        },
                      ),
                    ),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 32),
                    child: ProgressCircle(radius: 12),
                  ),
                ),
                error: (Object error, StackTrace stackTrace) =>
                    _ErrorState(error: error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatSummaryCard extends StatelessWidget {
  const _ChatSummaryCard({
    required this.summary,
    required this.dateFormatter,
    required this.isSelected,
    required this.onTap,
  });

  final RecentChatSummary summary;
  final DateFormat dateFormatter;
  final bool isSelected;
  final VoidCallback onTap;

  String _format(DateTime? value) {
    if (value == null) {
      return '—';
    }
    return dateFormatter.format(value);
  }

  Widget _buildParticipantTitle(BuildContext context) {
    final participantCount = summary.participants.length;

    // Limit to 3 participants, show ellipsis if more
    final displayParticipants = participantCount > 3
        ? [...summary.participants.take(3), '…']
        : summary.participants;

    // Calculate font size based on participant count
    // Base size is title2 (~17pt), scale down for multiple participants
    const baseFontSize = 17.0;
    final fontSize = participantCount == 1
        ? baseFontSize
        : participantCount == 2
        ? baseFontSize *
              0.85 // ~14.5pt for 2 participants
        : baseFontSize * 0.75; // ~12.75pt for 3+ participants

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: displayParticipants.map((participant) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  participant,
                  style: MacosTheme.of(context).typography.title2.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: fontSize,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
          ),
        ),
        if (summary.isGroup)
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: MacosIcon(
              CupertinoIcons.person_2_fill,
              size: 16,
              color: Color(0xFF58585F),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final captionStyle = MacosTheme.of(
      context,
    ).typography.caption1.copyWith(color: const Color(0xFF6B6B70));

    final isDarkMode = MacosTheme.of(context).brightness == Brightness.dark;
    const highlightDuration = Duration(milliseconds: 160);
    final accentColor = isDarkMode
        ? const Color(0xFF5B8BFF)
        : const Color(0xFF2563EB);

    final backgroundColor = isSelected
        ? (isDarkMode ? const Color(0xFF2D3548) : const Color(0xFFE8F1FF))
        : (isDarkMode ? const Color(0xFF2C2C33) : Colors.white);

    final borderColor = isSelected
        ? (isDarkMode ? const Color(0xFF4B5A7A) : const Color(0xFF94C0FF))
        : const Color(0xFFE2E2EA);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: highlightDuration,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isSelected ? 0.12 : 0.05),
                blurRadius: isSelected ? 12 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnimatedContainer(
                duration: highlightDuration,
                width: 4,
                decoration: BoxDecoration(
                  color: isSelected ? accentColor : Colors.transparent,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                    bottom: Radius.circular(12),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildParticipantTitle(context),
                      const SizedBox(height: 8),
                      Text(
                        'Messages: ${summary.messageCount}',
                        style: captionStyle,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'First message: ${_format(summary.firstMessageDate)}',
                        style: captionStyle,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Last message: ${_format(summary.lastMessageDate)}',
                            style: captionStyle,
                          ),
                          Text(
                            'ID: ${summary.chatId}',
                            style: captionStyle.copyWith(
                              fontSize: 10,
                              color: const Color(0xFF999999),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchPlaceholder extends StatelessWidget {
  const _SearchPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const MacosTextField(
      enabled: false,
      placeholder: 'Search chats (coming soon)',
      prefix: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: MacosIcon(CupertinoIcons.search, size: 16),
      ),
    );
  }
}

class _SenderFilter extends HookConsumerWidget {
  const _SenderFilter({
    required this.chats,
    required this.selectedChatId,
    required this.sortAlphabetically,
    required this.onSelectedChatIdChanged,
    required this.onSortAlphabeticallyChanged,
    required this.currentSpec,
  });

  final List<RecentChatSummary> chats;
  final int? selectedChatId;
  final bool sortAlphabetically;
  final ValueChanged<int?> onSelectedChatIdChanged;
  final ValueChanged<bool> onSortAlphabeticallyChanged;
  final ChatsSpec currentSpec;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = MacosTheme.of(context).typography;
    final options = chats
        .map(
          (chat) => _SenderFilterOption(
            chatId: chat.chatId,
            label: chat.title,
            messageCount: chat.messageCount,
          ),
        )
        .toList();

    options.sort((a, b) {
      if (sortAlphabetically) {
        return a.label.toLowerCase().compareTo(b.label.toLowerCase());
      }
      final messageComparison = b.messageCount.compareTo(a.messageCount);
      if (messageComparison != 0) {
        return messageComparison;
      }
      return a.label.toLowerCase().compareTo(b.label.toLowerCase());
    });

    final items = <MacosPopupMenuItem<int?>>[
      const MacosPopupMenuItem<int?>(child: Text('All senders')),
      ...options.map(
        (option) => MacosPopupMenuItem<int?>(
          value: option.chatId,
          child: Text(
            '${option.label} • ${_formatMessageCount(option.messageCount)}',
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    ];

    return _FilterContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filters',
            style: typography.title3.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(
            'View Mode',
            style: typography.caption1.copyWith(color: const Color(0xFF6B6B70)),
          ),
          const SizedBox(height: 8),
          MacosPopupButton<String>(
            value: _getCurrentViewMode(currentSpec),
            items: const [
              MacosPopupMenuItem<String>(
                value: 'recent',
                child: Text('Recent Activity'),
              ),
              MacosPopupMenuItem<String>(
                value: 'oldest',
                child: Text('Oldest First'),
              ),
              MacosPopupMenuItem<String>(
                value: 'newest',
                child: Text('Newest First'),
              ),
              MacosPopupMenuItem<String>(
                value: 'unmatched',
                child: Text('Unmatched Numbers'),
              ),
            ],
            onChanged: (String? value) {
              if (value == null) {
                return;
              }
              _switchViewMode(ref, value, currentSpec);
            },
          ),
          const SizedBox(height: 12),
          Text(
            'Sender',
            style: typography.caption1.copyWith(color: const Color(0xFF6B6B70)),
          ),
          const SizedBox(height: 8),
          MacosPopupButton<int?>(
            value: selectedChatId,
            items: items,
            hint: const Text('Select a sender'),
            onChanged: (value) {
              onSelectedChatIdChanged(value);
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              MacosCheckbox(
                value: sortAlphabetically,
                onChanged: (value) {
                  onSortAlphabeticallyChanged(value);
                },
              ),
              const SizedBox(width: 8),
              Text(
                sortAlphabetically
                    ? 'Alphabetical order (A–Z)'
                    : 'Most messages first',
                style: typography.caption1.copyWith(
                  color: const Color(0xFF6B6B70),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getCurrentViewMode(ChatsSpec spec) {
    return spec.when(
      recent: (_) => 'recent',
      byAgeOldest: (_) => 'oldest',
      byAgeNewest: (_) => 'newest',
      unmatched: (_) => 'unmatched',
      list: () => 'recent',
      forContact: (_) => 'recent',
      forParticipant: (_) => 'recent',
    );
  }

  void _switchViewMode(WidgetRef ref, String mode, ChatsSpec currentSpec) {
    final limit = currentSpec.when(
      recent: (l) => l,
      byAgeOldest: (l) => l,
      byAgeNewest: (l) => l,
      unmatched: (l) => l,
      list: () => null,
      forContact: (_) => null,
      forParticipant: (_) => null,
    );

    // ignore: unused_local_variable
    final newSpec = switch (mode) {
      'recent' => ChatsSpec.recent(limit: limit),
      'oldest' => ChatsSpec.byAgeOldest(limit: limit),
      'newest' => ChatsSpec.byAgeNewest(limit: limit),
      'unmatched' => ChatsSpec.unmatched(limit: limit),
      _ => ChatsSpec.recent(limit: limit),
    };

    // ref
    //     .read(panelsViewStateProvider.notifier)
    //     .show(panel: WindowPanel.left, spec: ViewSpec.chats(newSpec));
  }

  static String _formatMessageCount(int value) {
    if (value == 1) {
      return '1 message';
    }
    return '$value messages';
  }
}

class _SenderFilterOption {
  const _SenderFilterOption({
    required this.chatId,
    required this.label,
    required this.messageCount,
  });

  final int chatId;
  final String label;
  final int messageCount;
}

class _SenderFilterLoading extends StatelessWidget {
  const _SenderFilterLoading();

  @override
  Widget build(BuildContext context) {
    return const _FilterContainer(
      child: Row(
        children: [
          ProgressCircle(radius: 8),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Loading senders…',
              style: TextStyle(color: Color(0xFF6B6B70)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SenderFilterError extends StatelessWidget {
  const _SenderFilterError({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return _FilterContainer(
      child: Text(
        'Unable to load sender filter. $error',
        style: const TextStyle(color: Color(0xFFD14343)),
      ),
    );
  }
}

class _FilterContainer extends StatelessWidget {
  const _FilterContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: MacosTheme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2C2C33)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E2EA)),
      ),
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Unable to load chats. $error',
        style: const TextStyle(color: Color(0xFFD14343)),
        textAlign: TextAlign.center,
      ),
    );
  }
}
