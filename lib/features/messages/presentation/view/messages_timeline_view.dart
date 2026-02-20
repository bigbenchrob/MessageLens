import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:macos_ui/macos_ui.dart' as macos_ui;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../contacts/infrastructure/repositories/contact_profile_provider.dart';
import '../../domain/value_objects/message_timeline_scope.dart';
import '../view_model/timeline/hydration/message_by_ordinal_provider.dart';
import '../view_model/timeline/message_timeline_view_model_provider.dart';
import '../view_model/timeline/ordinal/current_visible_month_provider.dart';
import '../view_model/timeline/timeline_metadata_provider.dart';
import '../widgets/message_card.dart';

/// Unified view for message timelines across all scopes.
///
/// Works with global, contact, and chat scopes using the same
/// virtual-scrolling infrastructure with scope-specific headers.
class MessagesTimelineView extends HookConsumerWidget {
  const MessagesTimelineView({
    required this.scope,
    this.scrollToDate,
    super.key,
  });

  /// The scope determining which messages to show.
  final MessageTimelineScope scope;

  /// Optional date to scroll to on initial load.
  final DateTime? scrollToDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = MacosTheme.of(context);
    final vm = ref.watch(messageTimelineViewModelProvider(scope: scope));
    final ordinalAsync = vm.ordinal;

    // Handle initial scroll positioning
    useEffect(() {
      if (scrollToDate != null && ordinalAsync.hasValue) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await ref
              .read(messageTimelineViewModelProvider(scope: scope).notifier)
              .jumpToDate(scrollToDate!);
        });
      } else if (scrollToDate == null && ordinalAsync.hasValue) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await ref
              .read(messageTimelineViewModelProvider(scope: scope).notifier)
              .jumpToLatest();
        });
      }
      return null;
    }, [scrollToDate, ordinalAsync.hasValue]);

    // Color scheme: header/search get a darker chrome, message list gets lighter
    final isDark = theme.brightness == Brightness.dark;
    final chromeBg = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFE8E8ED);
    final messageListBg = isDark
        ? const Color(0xFF2C2C2E)
        : const Color(0xFFF8F8FA);

    // Build scope-specific scaffold
    return switch (scope) {
      GlobalTimelineScope() => _buildGlobalScaffold(
        context,
        ref,
        vm,
        theme,
        chromeBg,
        messageListBg,
      ),
      ContactTimelineScope(:final contactId) => _buildContactScaffold(
        context,
        ref,
        vm,
        theme,
        contactId,
        chromeBg,
        messageListBg,
      ),
      ChatTimelineScope(:final chatId) => _buildChatScaffold(
        context,
        ref,
        vm,
        theme,
        chatId,
        chromeBg,
        messageListBg,
      ),
    };
  }

  Widget _buildGlobalScaffold(
    BuildContext context,
    WidgetRef ref,
    MessageTimelineViewModelState vm,
    MacosThemeData theme,
    Color chromeBg,
    Color messageListBg,
  ) {
    return Material(
      color: chromeBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _GlobalHeader(scope: scope, scrollToDate: scrollToDate),
          _SearchBar(scope: scope, vm: vm),
          Expanded(
            child: ColoredBox(
              color: messageListBg,
              child: _buildMessageList(context, ref, vm, theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactScaffold(
    BuildContext context,
    WidgetRef ref,
    MessageTimelineViewModelState vm,
    MacosThemeData theme,
    int contactId,
    Color chromeBg,
    Color messageListBg,
  ) {
    return Material(
      color: chromeBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ContactHeader(
            contactId: contactId,
            scope: scope,
            scrollToDate: scrollToDate,
          ),
          _SearchBar(scope: scope, vm: vm),
          Expanded(
            child: ColoredBox(
              color: messageListBg,
              child: _buildMessageList(context, ref, vm, theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatScaffold(
    BuildContext context,
    WidgetRef ref,
    MessageTimelineViewModelState vm,
    MacosThemeData theme,
    int chatId,
    Color chromeBg,
    Color messageListBg,
  ) {
    return Material(
      color: chromeBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ChatHeader(chatId: chatId, scope: scope, scrollToDate: scrollToDate),
          _SearchBar(scope: scope, vm: vm),
          Expanded(
            child: ColoredBox(
              color: messageListBg,
              child: _buildMessageList(context, ref, vm, theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(
    BuildContext context,
    WidgetRef ref,
    MessageTimelineViewModelState vm,
    MacosThemeData theme,
  ) {
    if (vm.isSearching) {
      return _SearchResultsList(vm: vm);
    }

    return vm.ordinal.when(
      data: (ordinalState) {
        if (ordinalState.totalCount == 0) {
          return Center(
            child: Text(_emptyMessage, style: theme.typography.title3),
          );
        }

        return ScrollablePositionedList.builder(
          itemScrollController: ordinalState.itemScrollController,
          itemPositionsListener: ordinalState.itemPositionsListener,
          itemCount: ordinalState.totalCount,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            return _MessageRow(scope: scope, ordinal: index);
          },
        );
      },
      loading: () => const Center(child: ProgressCircle()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Unable to load timeline: $error'),
        ),
      ),
    );
  }

  String get _emptyMessage {
    return switch (scope) {
      GlobalTimelineScope() => 'No messages indexed yet.',
      ContactTimelineScope() => 'No messages with this contact yet.',
      ChatTimelineScope() => 'No messages in this chat yet.',
    };
  }
}

/// Unified search bar with mode toggle for all timeline scopes.
class _SearchBar extends ConsumerWidget {
  const _SearchBar({required this.scope, required this.vm});

  final MessageTimelineScope scope;
  final MessageTimelineViewModelState vm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placeholder = switch (scope) {
      GlobalTimelineScope() => 'Search all messages',
      ContactTimelineScope() => 'Search messages with this contact',
      ChatTimelineScope() => 'Search this conversation',
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: MacosTextField(
              controller: vm.searchController,
              placeholder: placeholder,
              clearButtonMode: macos_ui.OverlayVisibilityMode.editing,
            ),
          ),
          const SizedBox(width: 12),
          _SearchModeToggle(scope: scope, mode: vm.searchMode),
        ],
      ),
    );
  }
}

/// Search mode toggle buttons.
class _SearchModeToggle extends ConsumerWidget {
  const _SearchModeToggle({required this.scope, required this.mode});

  final MessageTimelineScope scope;
  final MessageSearchMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = MacosTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeColor = CupertinoColors.systemBlue.resolveFrom(context);
    final inactiveColor =
        isDark ? const Color(0xFF98989D) : const Color(0xFF6E6E73);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MacosTooltip(
          message: 'All terms must match',
          child: GestureDetector(
            onTap: () => ref
                .read(messageTimelineViewModelProvider(scope: scope).notifier)
                .setSearchMode(MessageSearchMode.allTerms),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: mode == MessageSearchMode.allTerms
                    ? activeColor.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: mode == MessageSearchMode.allTerms
                      ? activeColor.withValues(alpha: 0.4)
                      : inactiveColor.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                'AND',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: mode == MessageSearchMode.allTerms
                      ? activeColor
                      : inactiveColor,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        MacosTooltip(
          message: 'Any term can match',
          child: GestureDetector(
            onTap: () => ref
                .read(messageTimelineViewModelProvider(scope: scope).notifier)
                .setSearchMode(MessageSearchMode.anyTerm),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: mode == MessageSearchMode.anyTerm
                    ? activeColor.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: mode == MessageSearchMode.anyTerm
                      ? activeColor.withValues(alpha: 0.4)
                      : inactiveColor.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                'OR',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: mode == MessageSearchMode.anyTerm
                      ? activeColor
                      : inactiveColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Header for global (all messages) view.
class _GlobalHeader extends ConsumerWidget {
  const _GlobalHeader({required this.scope, this.scrollToDate});

  final MessageTimelineScope scope;
  final DateTime? scrollToDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = MacosTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryColor = isDark
        ? const Color(0xFF98989D)
        : const Color(0xFF6E6E73);

    final metadataAsync = ref.watch(timelineMetadataProvider(scope: scope));
    final visibleMonthAsync = ref.watch(
      currentVisibleMonthForScopeProvider(scope: scope),
    );

    final metadata = metadataAsync.valueOrNull;
    final visibleMonth = visibleMonthAsync.valueOrNull;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'All Messages',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          if (metadata != null) ...[
            Text(
              _buildMetadataLine(metadata),
              style: TextStyle(fontSize: 13, color: secondaryColor),
            ),
          ],
          if (scrollToDate != null || visibleMonth != null) ...[
            const SizedBox(height: 6),
            _ScrollPositionIndicator(
              scrollToDate: scrollToDate,
              visibleMonthKey: visibleMonth,
            ),
          ],
        ],
      ),
    );
  }

  String _buildMetadataLine(TimelineMetadata metadata) {
    final count = _formatCount(metadata.totalMessages);
    if (metadata.durationSpan.isEmpty) {
      return '$count messages';
    }
    return '$count messages over ${metadata.durationSpan}';
  }

  String _formatCount(int count) {
    return count.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }
}

/// Shows current scroll position when viewing a portion of the timeline.
class _ScrollPositionIndicator extends StatelessWidget {
  const _ScrollPositionIndicator({this.scrollToDate, this.visibleMonthKey});

  /// The date explicitly requested via navigation (e.g., from heatmap click).
  final DateTime? scrollToDate;

  /// The month key of the currently visible top message (e.g., '2023-06').
  final String? visibleMonthKey;

  @override
  Widget build(BuildContext context) {
    final displayText = _getDisplayText();
    if (displayText == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBlue.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: CupertinoColors.systemBlue.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.calendar,
            size: 12,
            color: CupertinoColors.systemBlue.resolveFrom(context),
          ),
          const SizedBox(width: 6),
          Text(
            displayText,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.systemBlue.resolveFrom(context),
            ),
          ),
        ],
      ),
    );
  }

  String? _getDisplayText() {
    // Prefer explicit scroll-to date when navigating from heatmap
    if (scrollToDate != null) {
      return 'SCROLLED TO ${DateFormat('MMMM yyyy').format(scrollToDate!)}';
    }

    // Fall back to currently visible month from scroll position
    if (visibleMonthKey != null && visibleMonthKey!.isNotEmpty) {
      final parts = visibleMonthKey!.split('-');
      if (parts.length == 2) {
        final year = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        if (year != null && month != null) {
          final date = DateTime(year, month);
          return 'VIEWING ${DateFormat('MMMM yyyy').format(date).toUpperCase()}';
        }
      }
    }

    return null;
  }
}

/// Header for contact message view.
class _ContactHeader extends ConsumerWidget {
  const _ContactHeader({
    required this.contactId,
    required this.scope,
    this.scrollToDate,
  });

  final int contactId;
  final MessageTimelineScope scope;
  final DateTime? scrollToDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = MacosTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryColor = isDark
        ? const Color(0xFF98989D)
        : const Color(0xFF6E6E73);

    // Get contact profile for display name
    final profileAsync = ref.watch(
      contactProfileProvider(contactId: contactId),
    );
    final metadataAsync = ref.watch(timelineMetadataProvider(scope: scope));
    final visibleMonthAsync = ref.watch(
      currentVisibleMonthForScopeProvider(scope: scope),
    );

    final displayName = profileAsync.valueOrNull?.displayName ?? 'Contact';
    final metadata = metadataAsync.valueOrNull;
    final visibleMonth = visibleMonthAsync.valueOrNull;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All messages from $displayName',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          if (metadata != null) ...[
            Text(
              _buildMetadataLine(metadata),
              style: TextStyle(fontSize: 13, color: secondaryColor),
            ),
          ],
          if (scrollToDate != null || visibleMonth != null) ...[
            const SizedBox(height: 6),
            _ScrollPositionIndicator(
              scrollToDate: scrollToDate,
              visibleMonthKey: visibleMonth,
            ),
          ],
        ],
      ),
    );
  }

  String _buildMetadataLine(TimelineMetadata metadata) {
    final count = _formatCount(metadata.totalMessages);
    if (metadata.durationSpan.isEmpty) {
      return '$count messages';
    }
    return '$count messages over ${metadata.durationSpan}';
  }

  String _formatCount(int count) {
    return count.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }
}

/// Header for chat message view.
class _ChatHeader extends ConsumerWidget {
  const _ChatHeader({
    required this.chatId,
    required this.scope,
    this.scrollToDate,
  });

  final int chatId;
  final MessageTimelineScope scope;
  final DateTime? scrollToDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = MacosTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryColor = isDark
        ? const Color(0xFF98989D)
        : const Color(0xFF6E6E73);

    final metadataAsync = ref.watch(timelineMetadataProvider(scope: scope));
    final visibleMonthAsync = ref.watch(
      currentVisibleMonthForScopeProvider(scope: scope),
    );

    final metadata = metadataAsync.valueOrNull;
    final visibleMonth = visibleMonthAsync.valueOrNull;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Conversation',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          if (metadata != null) ...[
            Text(
              _buildMetadataLine(metadata),
              style: TextStyle(fontSize: 13, color: secondaryColor),
            ),
          ],
          if (scrollToDate != null || visibleMonth != null) ...[
            const SizedBox(height: 6),
            _ScrollPositionIndicator(
              scrollToDate: scrollToDate,
              visibleMonthKey: visibleMonth,
            ),
          ],
        ],
      ),
    );
  }

  String _buildMetadataLine(TimelineMetadata metadata) {
    final count = _formatCount(metadata.totalMessages);
    if (metadata.durationSpan.isEmpty) {
      return '$count messages';
    }
    return '$count messages over ${metadata.durationSpan}';
  }

  String _formatCount(int count) {
    return count.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }
}

/// Single message row with hydration.
class _MessageRow extends ConsumerWidget {
  const _MessageRow({required this.scope, required this.ordinal});

  final MessageTimelineScope scope;
  final int ordinal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = MacosTheme.of(context);
    final itemAsync = ref.watch(
      messageByTimelineOrdinalProvider(scope: scope, ordinal: ordinal),
    );

    return itemAsync.when(
      data: (item) {
        if (item == null) {
          return _SkeletonRow(theme: theme);
        }
        return MessageCard(message: item);
      },
      loading: () => _SkeletonRow(theme: theme),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Row $ordinal failed: $error'),
      ),
    );
  }
}

/// Skeleton placeholder while message is loading.
class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow({required this.theme});

  final MacosThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: theme.canvasColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.35)),
      ),
      child: const Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

/// Search results list.
class _SearchResultsList extends StatelessWidget {
  const _SearchResultsList({required this.vm});

  final MessageTimelineViewModelState vm;

  @override
  Widget build(BuildContext context) {
    return vm.searchResults.when(
      data: (results) {
        if (results.isEmpty) {
          return Center(
            child: Text('No matches found for "${vm.debouncedQuery}"'),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: results.length,
          itemBuilder: (context, index) {
            return MessageCard(message: results[index]);
          },
        );
      },
      loading: () => const Center(child: ProgressCircle()),
      error: (error, _) => Center(child: Text('Search failed: $error')),
    );
  }
}
