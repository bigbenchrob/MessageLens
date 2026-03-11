import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:macos_ui/macos_ui.dart'
    show MacosTextField, MacosTooltip, ProgressCircle;
import 'package:macos_ui/macos_ui.dart' as macos_ui;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/spacing/app_spacing.dart';
import '../../../../config/theme/theme_typography.dart';

import '../../../contacts/infrastructure/repositories/contact_profile_provider.dart';
import '../../domain/value_objects/message_timeline_scope.dart';
import '../view_model/timeline/hydration/message_by_id_provider.dart';
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
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
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
    final isDark = colors.isDark;
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
        chromeBg,
        messageListBg,
      ),
      ContactTimelineScope(:final contactId) => _buildContactScaffold(
        context,
        ref,
        vm,
        contactId,
        chromeBg,
        messageListBg,
      ),
      ChatTimelineScope(:final chatId) => _buildChatScaffold(
        context,
        ref,
        vm,
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
            child: _FadeOverlayList(
              backgroundColor: messageListBg,
              child: _buildMessageList(context, ref, vm),
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
            child: _FadeOverlayList(
              backgroundColor: messageListBg,
              child: _buildMessageList(context, ref, vm),
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
            child: _FadeOverlayList(
              backgroundColor: messageListBg,
              child: _buildMessageList(context, ref, vm),
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
  ) {
    if (vm.isSearching) {
      return _SearchResultsList(vm: vm);
    }

    final typography = ref.watch(themeTypographyProvider);

    return vm.ordinal.when(
      data: (ordinalState) {
        if (ordinalState.totalCount == 0) {
          return Center(child: Text(_emptyMessage, style: typography.title3));
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

/// Wraps the message list with a scroll-driven gradient fade overlay at top.
///
/// The overlay is invisible at rest and only appears during scroll motion,
/// providing a soft collision boundary without becoming a visible surface.
///
/// ## Design Contract
///
/// Top-of-list blur is interaction-driven, not layout-driven.
/// It must be invisible at rest, engage only during scrolling, and fade out
/// immediately when motion stops. Height ≤ 24pt and strength must not be
/// perceptible as a visual element.
class _FadeOverlayList extends StatefulWidget {
  const _FadeOverlayList({required this.backgroundColor, required this.child});

  final Color backgroundColor;
  final Widget child;

  @override
  State<_FadeOverlayList> createState() => _FadeOverlayListState();
}

class _FadeOverlayListState extends State<_FadeOverlayList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150), // Fast fade in
      reverseDuration: const Duration(milliseconds: 300), // Slower fade out
    );
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      // User started scrolling — show overlay
      _controller.forward();
    } else if (notification is ScrollEndNotification) {
      // User stopped scrolling — hide overlay
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: widget.backgroundColor,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          _handleScrollNotification(notification);
          return false; // Don't consume the notification
        },
        child: Stack(
          children: [
            widget.child,
            // Scroll-driven gradient fade overlay at top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 20, // Shallow: just enough to soften collision
              child: IgnorePointer(
                child: FadeTransition(
                  opacity: _opacity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.4, 1.0],
                        colors: [
                          widget.backgroundColor,
                          widget.backgroundColor.withValues(alpha: 0.6),
                          widget.backgroundColor.withValues(alpha: 0),
                        ],
                      ),
                    ),
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

/// Unified search bar with mode toggle for all timeline scopes.
class _SearchBar extends ConsumerWidget {
  const _SearchBar({required this.scope, required this.vm});

  final MessageTimelineScope scope;
  final MessageTimelineViewModelState vm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    final placeholder = switch (scope) {
      GlobalTimelineScope() => 'Search all messages',
      ContactTimelineScope() => 'Search messages with this contact',
      ChatTimelineScope() => 'Search this conversation',
    };

    final decoration = BoxDecoration(
      color: colors.surfaces.control,
      border: Border.all(color: colors.lines.borderSubtle),
      borderRadius: const BorderRadius.all(Radius.circular(7)),
    );
    final focusedDecoration = BoxDecoration(
      color: colors.surfaces.control,
      border: Border.all(color: colors.accents.focusRing, width: 2),
      borderRadius: const BorderRadius.all(Radius.circular(7)),
    );

    return Padding(
      // Top: tight gap from header; bottom: looser gap to content
      padding: const EdgeInsets.fromLTRB(
        16,
        AppSpacing
            .xs, // Completes panelHeaderToControlsGap (header: 8 + search: 4 = 12)
        16,
        AppSpacing.panelControlsToContentGap,
      ),
      child: Row(
        children: [
          Expanded(
            child: MacosTextField(
              controller: vm.searchController,
              placeholder: placeholder,
              clearButtonMode: macos_ui.OverlayVisibilityMode.editing,
              decoration: decoration,
              focusedDecoration: focusedDecoration,
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
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final isDark = colors.isDark;
    final activeColor = CupertinoColors.systemBlue.resolveFrom(context);
    final inactiveColor = isDark
        ? const Color(0xFF98989D)
        : const Color(0xFF6E6E73);

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
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final secondaryColor = colors.content.textSecondary;

    final metadataAsync = ref.watch(timelineMetadataProvider(scope: scope));
    final visibleMonthAsync = ref.watch(
      currentVisibleMonthForScopeProvider(scope: scope),
    );

    final metadata = metadataAsync.valueOrNull;
    final visibleMonth = visibleMonthAsync.valueOrNull;

    final primaryColor = colors.content.textPrimary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All Messages',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
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
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final secondaryColor = colors.content.textSecondary;

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

    final primaryColor = colors.content.textPrimary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All messages from $displayName',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
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
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final secondaryColor = colors.content.textSecondary;

    final metadataAsync = ref.watch(timelineMetadataProvider(scope: scope));
    final visibleMonthAsync = ref.watch(
      currentVisibleMonthForScopeProvider(scope: scope),
    );

    final metadata = metadataAsync.valueOrNull;
    final visibleMonth = visibleMonthAsync.valueOrNull;

    final primaryColor = colors.content.textPrimary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Conversation',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
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
    final itemAsync = ref.watch(
      messageByTimelineOrdinalProvider(scope: scope, ordinal: ordinal),
    );

    return itemAsync.when(
      data: (item) {
        if (item == null) {
          return const _SkeletonRow();
        }
        return MessageCard(message: item);
      },
      loading: () => const _SkeletonRow(),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Row $ordinal failed: $error'),
      ),
    );
  }
}

/// Skeleton placeholder while message is loading.
class _SkeletonRow extends ConsumerWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: colors.surfaces.canvas,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.lines.divider.withValues(alpha: 0.35)),
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

/// Search results list with virtual scrolling.
///
/// Uses on-demand hydration like the main timeline for fast initial display.
class _SearchResultsList extends ConsumerWidget {
  const _SearchResultsList({required this.vm});

  final MessageTimelineViewModelState vm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return vm.searchResultIds.when(
      data: (resultIds) {
        if (resultIds.isEmpty) {
          return Center(
            child: Text('No matches found for "${vm.debouncedQuery}"'),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                '${resultIds.length} results',
                style: TextStyle(
                  fontSize: 12,
                  color: colors.content.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: resultIds.length,
                itemBuilder: (context, index) {
                  return _SearchResultRow(messageId: resultIds[index]);
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: ProgressCircle()),
      error: (error, _) => Center(child: Text('Search failed: $error')),
    );
  }
}

/// Single search result row with on-demand hydration.
class _SearchResultRow extends ConsumerWidget {
  const _SearchResultRow({required this.messageId});

  final int messageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(messageByIdProvider(messageId: messageId));

    return itemAsync.when(
      data: (item) {
        if (item == null) {
          return const _SkeletonRow();
        }
        return MessageCard(message: item);
      },
      loading: () => const _SkeletonRow(),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Message $messageId failed: $error'),
      ),
    );
  }
}
