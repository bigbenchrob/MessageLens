import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../essentials/navigation/domain/entities/view_spec.dart';
import '../../../../essentials/navigation/domain/navigation_constants.dart';
import '../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../essentials/navigation/feature_level_providers.dart';
import '../../application/use_cases/global_message_timeline_provider.dart';
import '../view_model/shared/display_widgets/new_display_widgets.dart';
import '../view_model/shared/hydration/attachment_info.dart';
import '../view_model/shared/hydration/message_by_id_provider.dart';
import '../view_model/shared/hydration/messages_for_handle_provider.dart';
import '../view_model/view_model_global/global_timeline_controller.dart';
import '../widgets/message_link_preview_card.dart';

class GlobalTimelineView extends HookConsumerWidget {
  const GlobalTimelineView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineAsync = ref.watch(globalTimelineControllerProvider());
    final scrollController = useScrollController();

    useEffect(() {
      final notifier = ref.read(globalTimelineControllerProvider().notifier);
      void handleScroll() {
        if (!scrollController.hasClients) {
          return;
        }
        const threshold = 320.0;
        final offset = scrollController.offset;
        final maxScroll = scrollController.position.maxScrollExtent;
        if (offset <= threshold) {
          notifier.loadMoreBefore();
        }
        if (maxScroll - offset <= threshold) {
          notifier.loadMoreAfter();
        }
      }

      scrollController.addListener(handleScroll);
      return () => scrollController.removeListener(handleScroll);
    }, [scrollController, ref]);

    Future<void> refresh() {
      return ref.read(globalTimelineControllerProvider().notifier).refresh();
    }

    return MacosScaffold(
      toolBar: ToolBar(
        title: const Text('All Messages Timeline'),
        actions: [
          ToolBarIconButton(
            icon: const MacosIcon(CupertinoIcons.refresh),
            label: 'Refresh',
            onPressed: refresh,
            showLabel: false,
          ),
        ],
      ),
      children: [
        ContentArea(
          builder: (context, _) {
            return timelineAsync.when(
              data: (state) => _TimelineBody(
                state: state,
                scrollController: scrollController,
              ),
              loading: () => const Center(child: ProgressCircle()),
              error: (error, _) =>
                  _TimelineError(error: error, onRetry: refresh),
            );
          },
        ),
      ],
    );
  }
}

class _TimelineBody extends ConsumerWidget {
  const _TimelineBody({required this.state, required this.scrollController});

  final GlobalTimelineState state;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isEmpty) {
      return const _EmptyTimeline();
    }

    return Column(
      children: [
        _TimelineSummaryHeader(state: state),
        if (state.isLoadingBefore)
          const _LoadingBanner(message: 'Loading newer messages…'),
        Expanded(
          child: Scrollbar(
            controller: scrollController,
            thumbVisibility: true,
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final item = state.items[index];
                return _GlobalTimelineMessageRow(item: item);
              },
            ),
          ),
        ),
        if (state.isLoadingAfter)
          const _LoadingBanner(message: 'Loading older messages…'),
      ],
    );
  }
}

class _GlobalTimelineMessageRow extends ConsumerWidget {
  const _GlobalTimelineMessageRow({required this.item});

  final GlobalMessageTimelineItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageAsync = ref.watch(
      messageByIdProvider(messageId: item.messageId),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: messageAsync.when(
        data: (message) {
          return _TimelineMessageCard(item: item, message: message);
        },
        loading: () => const _MessageSkeleton(),
        error: (error, _) =>
            _MessageErrorTile(messageId: item.messageId, error: error),
      ),
    );
  }
}

class _TimelineSummaryHeader extends ConsumerWidget {
  const _TimelineSummaryHeader({required this.state});

  final GlobalTimelineState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final macosTheme = MacosTheme.of(context);
    final boundsAsync = ref.watch(globalTimelineBoundsProvider);
    final firstItem = state.items.first;
    final lastItem = state.items.last;
    final ordinalLabel =
        '${NumberFormat.compact().format(firstItem.ordinal + 1)} – ${NumberFormat.compact().format(lastItem.ordinal + 1)}';
    final visibleDates = _formatDateRange(firstItem.sentAt, lastItem.sentAt);
    final totalFormatted = NumberFormat.decimalPattern().format(
      state.totalCount,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 16),
      decoration: BoxDecoration(
        color: macosTheme.canvasColor,
        border: Border(
          bottom: BorderSide(
            color: macosTheme.dividerColor.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Global message timeline',
            style: macosTheme.typography.title2.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'View every message in chronological order and hop to any era.',
            style: macosTheme.typography.caption1.copyWith(
              color: macosTheme.typography.caption1.color?.withValues(
                alpha: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatCard(
                label: 'Total messages',
                value: totalFormatted,
                icon: CupertinoIcons.list_number,
              ),
              _StatCard(
                label: 'Visible ordinals',
                value: ordinalLabel,
                icon: CupertinoIcons.number,
              ),
              _StatCard(
                label: 'Visible dates',
                value: visibleDates,
                icon: CupertinoIcons.calendar,
              ),
              boundsAsync.when(
                data: (bounds) => _StatCard(
                  label: 'Archive span',
                  value: _formatDateRange(bounds.earliest, bounds.latest),
                  icon: CupertinoIcons.time,
                ),
                loading: () => const _StatCard(
                  label: 'Archive span',
                  value: 'Loading…',
                  icon: CupertinoIcons.time,
                ),
                error: (_, __) => const _StatCard(
                  label: 'Archive span',
                  value: 'Unavailable',
                  icon: CupertinoIcons.time,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _TimelineActionsRow(state: state),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final macosTheme = MacosTheme.of(context);
    return Container(
      constraints: const BoxConstraints(minWidth: 180),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: macosTheme.canvasColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: macosTheme.dividerColor.withValues(alpha: 0.8),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: macosTheme.typography.body.color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: macosTheme.typography.title3.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: macosTheme.typography.caption1.copyWith(
                    color: macosTheme.typography.caption1.color?.withValues(
                      alpha: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineActionsRow extends ConsumerWidget {
  const _TimelineActionsRow({required this.state});

  final GlobalTimelineState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(globalTimelineControllerProvider().notifier);

    Future<void> handleJumpToDate() async {
      final initialDate = state.items.isNotEmpty
          ? (state.items.last.sentAt ?? DateTime.now())
          : DateTime.now();
      final selected = await _JumpToDateSheet.show(
        context,
        initialDate: initialDate,
      );
      if (selected == null) {
        return;
      }
      final success = await notifier.jumpToDate(selected);
      if (!success && context.mounted) {
        await _showNoResultsDialog(context, selected);
      }
    }

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        PushButton(
          controlSize: ControlSize.small,
          onPressed: state.items.isEmpty ? null : () => notifier.jumpToOldest(),
          secondary: true,
          child: const Text('Jump to oldest'),
        ),
        PushButton(
          controlSize: ControlSize.small,
          onPressed: state.items.isEmpty ? null : () => notifier.jumpToNewest(),
          secondary: true,
          child: const Text('Jump to newest'),
        ),
        PushButton(
          controlSize: ControlSize.small,
          onPressed: state.items.isEmpty ? null : handleJumpToDate,
          child: const Text('Jump to date…'),
        ),
      ],
    );
  }
}

class _TimelineMessageCard extends ConsumerWidget {
  const _TimelineMessageCard({required this.item, required this.message});

  final GlobalMessageTimelineItem item;
  final MessageListItem message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final macosTheme = MacosTheme.of(context);
    final monthLabel = _formatMonthLabel(item.monthKey, item.sentAt);

    void openChat() {
      ref
          .read(panelsViewStateProvider(SidebarMode.messages).notifier)
          .show(
            panel: WindowPanel.center,
            spec: ViewSpec.messages(MessagesSpec.forChat(chatId: item.chatId)),
          );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: macosTheme.canvasColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: macosTheme.dividerColor.withValues(alpha: 0.6),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Chip(
                icon: CupertinoIcons.chat_bubble_text,
                label: 'Chat ${item.chatId}',
              ),
              const SizedBox(width: 8),
              _Chip(icon: CupertinoIcons.number, label: '#${item.ordinal + 1}'),
              const Spacer(),
              PushButton(
                controlSize: ControlSize.small,
                onPressed: openChat,
                child: const Text('Open chat'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            monthLabel,
            style: macosTheme.typography.callout.copyWith(
              color: macosTheme.typography.callout.color?.withValues(
                alpha: 0.7,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildMessageTile(message),
        ],
      ),
    );
  }

  Widget _buildMessageTile(MessageListItem message) {
    final urls = _extractUrls(message.text);
    final isPureUrlMessage =
        urls.length == 1 && message.text.trim() == urls.first;

    final urlPreviewAttachment = _findAttachment(message.attachments, (
      AttachmentInfo attachment,
    ) {
      return attachment.isUrlPreview && attachment.localPath != null;
    });

    final imageAttachments = message.attachments.where(
      (AttachmentInfo attachment) =>
          attachment.isImage && attachment.localPath != null,
    );
    final videoAttachments = message.attachments.where(
      (AttachmentInfo attachment) =>
          attachment.isVideo && attachment.localPath != null,
    );

    if (urlPreviewAttachment != null || isPureUrlMessage) {
      return MessageLinkPreviewCard(
        message: message,
        maxWidth: MsgTheme.maxBubbleWidth,
      );
    }

    if (imageAttachments.isNotEmpty) {
      final attachment = imageAttachments.first;
      return ImageMessageTile(
        isMe: message.isFromMe,
        attachment: attachment,
        sender: message.senderName,
        sentAt: message.sentAt ?? DateTime.now(),
        messageId: message.id,
      );
    }

    if (videoAttachments.isNotEmpty) {
      final attachment = videoAttachments.first;
      return VideoMessageTile(
        isMe: message.isFromMe,
        attachment: attachment,
        sender: message.senderName,
        sentAt: message.sentAt ?? DateTime.now(),
        messageId: message.id,
      );
    }

    return TextMessageTile(
      isMe: message.isFromMe,
      text: message.text,
      sender: message.senderName,
      sentAt: message.sentAt ?? DateTime.now(),
      messageId: message.id,
    );
  }

  List<String> _extractUrls(String text) {
    final urlPattern = RegExp(
      r'https?://[^\s<>"{}|\\^`\[\]]+',
      caseSensitive: false,
    );
    final matches = urlPattern.allMatches(text);
    return matches.map((match) => match.group(0)!).toList();
  }

  AttachmentInfo? _findAttachment(
    List<AttachmentInfo> attachments,
    bool Function(AttachmentInfo attachment) predicate,
  ) {
    for (final attachment in attachments) {
      if (predicate(attachment)) {
        return attachment;
      }
    }
    return null;
  }

  String _formatMonthLabel(String raw, DateTime? fallback) {
    final parts = raw.split('-');
    if (parts.length == 2) {
      final year = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      if (year != null && month != null) {
        final date = DateTime(year, month);
        return DateFormat('MMMM yyyy').format(date);
      }
    }
    if (fallback != null) {
      return DateFormat('MMMM yyyy').format(fallback.toLocal());
    }
    return raw;
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF374151)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageSkeleton extends StatelessWidget {
  const _MessageSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _MessageErrorTile extends StatelessWidget {
  const _MessageErrorTile({required this.messageId, required this.error});

  final int messageId;
  final Object error;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEAB308)),
      ),
      child: Text(
        'Unable to load message $messageId: $error',
        style: const TextStyle(color: Color(0xFF92400E)),
      ),
    );
  }
}

class _LoadingBanner extends StatelessWidget {
  const _LoadingBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(color: Color(0xFFF3F4F6)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text(
            message,
            style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
          ),
        ],
      ),
    );
  }
}

class _EmptyTimeline extends StatelessWidget {
  const _EmptyTimeline();

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MacosIcon(CupertinoIcons.archivebox, size: 64),
          const SizedBox(height: 16),
          Text('No messages indexed yet', style: theme.typography.title3),
          const SizedBox(height: 8),
          Text(
            'Import conversations to populate the global timeline.',
            style: theme.typography.body,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TimelineError extends StatelessWidget {
  const _TimelineError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MacosIcon(
            CupertinoIcons.exclamationmark_triangle,
            size: 56,
            color: CupertinoColors.systemYellow,
          ),
          const SizedBox(height: 12),
          Text('Unable to load timeline', style: theme.typography.title3),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              '$error',
              style: theme.typography.body,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          PushButton(
            onPressed: onRetry,
            controlSize: ControlSize.regular,
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

Future<void> _showNoResultsDialog(BuildContext context, DateTime date) {
  final formatted = DateFormat.yMMMMd().format(date.toLocal());
  return showMacosAlertDialog(
    context: context,
    builder: (context) => MacosAlertDialog(
      appIcon: const MacosIcon(CupertinoIcons.exclamationmark_triangle),
      title: const Text('No messages found'),
      message: Text(
        'There are no messages on or after $formatted. '
        'Try selecting an earlier date.',
      ),
      primaryButton: PushButton(
        controlSize: ControlSize.large,
        onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
        child: const Text('OK'),
      ),
    ),
  );
}

String _formatDateRange(DateTime? start, DateTime? end) {
  if (start == null && end == null) {
    return 'Unknown range';
  }
  final formatter = DateFormat('MMM d, yyyy');
  if (start == null) {
    return formatter.format(end!.toLocal());
  }
  if (end == null) {
    return formatter.format(start.toLocal());
  }
  if (start.isAtSameMomentAs(end)) {
    return formatter.format(start.toLocal());
  }
  return '${formatter.format(start.toLocal())} – ${formatter.format(end.toLocal())}';
}

class _JumpToDateSheet extends StatefulWidget {
  const _JumpToDateSheet({required this.initialDate});

  final DateTime initialDate;

  static Future<DateTime?> show(
    BuildContext context, {
    required DateTime initialDate,
  }) {
    return showMacosSheet<DateTime?>(
      context: context,
      builder: (context) => _JumpToDateSheet(initialDate: initialDate),
    );
  }

  @override
  State<_JumpToDateSheet> createState() => _JumpToDateSheetState();
}

class _JumpToDateSheetState extends State<_JumpToDateSheet> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    return MacosSheet(
      child: Center(
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Jump to date',
                style: theme.typography.title2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select a date to jump to the closest message.',
                style: theme.typography.caption1,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 240,
                child: MacosDatePicker(
                  initialDate: _selectedDate,
                  onDateChanged: (value) {
                    setState(() => _selectedDate = value);
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PushButton(
                    controlSize: ControlSize.large,
                    secondary: true,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  PushButton(
                    controlSize: ControlSize.large,
                    onPressed: () {
                      Navigator.of(context).pop(_selectedDate);
                    },
                    child: const Text('Jump'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
