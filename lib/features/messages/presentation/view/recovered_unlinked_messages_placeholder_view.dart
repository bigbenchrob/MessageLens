import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/spacing/app_spacing.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../essentials/debug/application/developer_mode_provider.dart';
import '../../infrastructure/repositories/recovered_unlinked_messages_provider.dart';

/// Center-panel view for recovered unlinked messages.
class RecoveredUnlinkedMessagesPlaceholderView extends HookConsumerWidget {
  const RecoveredUnlinkedMessagesPlaceholderView({
    this.contactId,
    this.onlyNoHandleFromMe = false,
    super.key,
  });

  final int? contactId;
  final bool onlyNoHandleFromMe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final asyncMessages = ref.watch(
      recoveredUnlinkedMessagesProvider(contactId: contactId),
    );
    final searchController = useTextEditingController();
    final query = useState('');
    final isContactScoped = contactId != null;
    final title = onlyNoHandleFromMe
        ? 'Recovered No-Handle Messages'
        : isContactScoped
        ? 'Recovered Deleted Messages'
        : 'Recovered Deleted Messages';
    final description = onlyNoHandleFromMe
        ? 'Recovered orphaned records that still look like outgoing messages but no longer retain handle linkage. This is an experimental slice of the recovered dataset.'
        : isContactScoped
        ? "Showing recovered deleted-message candidates that appear to match this contact's linked handles. These records remain separate from the normal chat flow."
        : 'Source records recovered from `chat.db` without a normal chat link. Many may reflect conversations deleted on iPhone or iPad, but they remain separate from the normal chat flow.';

    return ColoredBox(
      color: colors.surfaces.canvas,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.tray_arrow_down_fill,
                      size: 24,
                      color: colors.content.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(title, style: typography.title1),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(description, style: typography.callout),
                const SizedBox(height: AppSpacing.md),
                MacosTextField(
                  controller: searchController,
                  placeholder:
                      'Filter by text, sender, service, or attachment name',
                  onChanged: (value) {
                    query.value = value.trim().toLowerCase();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: asyncMessages.when(
              data: (messages) {
                final bucketed = _applyRecoveredBucketFilter(
                  messages: messages,
                  onlyNoHandleFromMe: onlyNoHandleFromMe,
                );
                final filtered = _filterMessages(
                  messages: bucketed,
                  query: query.value,
                );

                if (bucketed.isEmpty) {
                  return _EmptyRecoveredMessagesState(
                    message: onlyNoHandleFromMe
                        ? 'No recovered no-handle outgoing messages were found.'
                        : isContactScoped
                        ? "No recovered deleted messages matched this contact's linked handles."
                        : 'No recovered deleted messages have been projected yet.',
                  );
                }

                if (filtered.isEmpty) {
                  // ignore: prefer_const_constructors
                  return _EmptyRecoveredMessagesState(
                    message:
                        'No recovered deleted messages match the current filter.',
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (isContactScoped && !onlyNoHandleFromMe)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                        child: _RecoveredLegend(
                          directCount: filtered
                              .where((message) => !message.isInferred)
                              .length,
                          inferredCount: filtered
                              .where((message) => message.isInferred)
                              .length,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        onlyNoHandleFromMe
                            ? '${filtered.length} of ${bucketed.length} recovered no-handle outgoing messages'
                            : '${filtered.length} of ${bucketed.length} recovered deleted-message candidates',
                        style: typography.caption1,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          return _RecoveredUnlinkedMessageCard(
                            message: filtered[index],
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: ProgressCircle()),
              error: (error, _) => _EmptyRecoveredMessagesState(
                message: 'Unable to load recovered deleted messages: $error',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

List<RecoveredUnlinkedMessageItem> _applyRecoveredBucketFilter({
  required List<RecoveredUnlinkedMessageItem> messages,
  required bool onlyNoHandleFromMe,
}) {
  if (!onlyNoHandleFromMe) {
    return messages;
  }

  return messages
      .where((message) {
        return message.isFromMe && message.senderHandleId == null;
      })
      .toList(growable: false);
}

List<RecoveredUnlinkedMessageItem> _filterMessages({
  required List<RecoveredUnlinkedMessageItem> messages,
  required String query,
}) {
  if (query.isEmpty) {
    return messages;
  }

  return messages
      .where((message) {
        final attachmentText = message.attachmentNames.join(' ').toLowerCase();
        final haystack = [
          message.senderLabel.toLowerCase(),
          message.service.toLowerCase(),
          message.itemType.toLowerCase(),
          message.text.toLowerCase(),
          attachmentText,
        ].join(' ');
        return haystack.contains(query);
      })
      .toList(growable: false);
}

class _EmptyRecoveredMessagesState extends ConsumerWidget {
  const _EmptyRecoveredMessagesState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.tray,
              size: 36,
              color: colors.content.textTertiary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(message, style: typography.body, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _RecoveredUnlinkedMessageCard extends ConsumerWidget {
  const _RecoveredUnlinkedMessageCard({required this.message});

  final RecoveredUnlinkedMessageItem message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final developerMode = ref.watch(developerModeProvider).valueOrNull;
    final isDeveloperMode = developerMode == DeveloperModeValue.developer;
    final dateFormatter = DateFormat('MMM d, yyyy h:mm a');
    final backgroundColor = message.isInferred
        ? colors.accents.primary.withValues(alpha: 0.10)
        : colors.surfaces.surface;
    final borderColor = message.isInferred
        ? colors.accents.primary.withValues(alpha: 0.28)
        : colors.lines.borderSubtle;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(message.senderLabel, style: typography.headline),
              ),
              Text(
                message.sentAt == null
                    ? 'Unknown date'
                    : dateFormatter.format(message.sentAt!),
                style: typography.caption1,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${message.service} • ${message.itemType}',
            style: typography.caption1,
          ),
          if (isDeveloperMode) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              message.contactName == null
                  ? 'Message ID: ${message.id}'
                  : 'Contact: ${message.contactName} • Message ID: ${message.id}',
              style: typography.caption1.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
          ],
          if (message.isInferred) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Best guess: inferred from nearby recovered messages for this contact.',
              style: typography.caption1.copyWith(
                color: colors.accents.primary.withValues(alpha: 0.92),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(message.text, style: typography.body),
          if (message.hasAttachments) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              message.attachmentCount == 1
                  ? '1 attachment preserved'
                  : '${message.attachmentCount} attachments preserved',
              style: typography.caption,
            ),
            if (message.attachmentNames.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final attachmentName in message.attachmentNames.take(6))
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaces.control,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(attachmentName, style: typography.caption1),
                    ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _RecoveredLegend extends ConsumerWidget {
  const _RecoveredLegend({
    required this.directCount,
    required this.inferredCount,
  });

  final int directCount;
  final int inferredCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaces.control,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.lines.borderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Legend',
            style: typography.caption.copyWith(
              color: colors.content.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Attributed matches are linked by surviving sender identity. Best-guess rows are nearby outgoing no-handle records shown as a conservative heuristic for deleted-conversation context.',
            style: typography.caption1,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              _LegendChip(
                label: '$directCount attributed',
                backgroundColor: colors.surfaces.surface,
                borderColor: colors.lines.borderSubtle,
              ),
              _LegendChip(
                label: '$inferredCount best guess',
                backgroundColor: colors.accents.primary.withValues(alpha: 0.10),
                borderColor: colors.accents.primary.withValues(alpha: 0.28),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendChip extends ConsumerWidget {
  const _LegendChip({
    required this.label,
    required this.backgroundColor,
    required this.borderColor,
  });

  final String label;
  final Color backgroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = ref.watch(themeTypographyProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Text(label, style: typography.caption1),
    );
  }
}
