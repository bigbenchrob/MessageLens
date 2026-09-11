import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../../essentials/debug/feature_level_providers.dart'
    show DeveloperModeValue, developerModeProvider;
import '../../../../../../essentials/external_links/feature_level_providers.dart'
    show externalLinkActionsProvider;
import '../../../../../../essentials/search/application/message_text_search_matching.dart';
import '../../../../../../essentials/search/application/message_text_search_query.dart';
import '../../../../../attachments/domain/constants/attachment_provenance.dart';
import '../../../../../attachments/domain/constants/resolved_attachment_availability.dart';
import '../../../../../attachments/feature_level_providers.dart'
    show
        AttachmentFileAccess,
        attachmentFileAccessProvider,
        attachmentRecoveryActionsProvider,
        videoThumbnailCacheProvider;
import '../../../../application/actions/message_media_diagnostics_provider.dart';
import '../../../widgets/message_evidence/media_tile_attachment.dart';
import 'message_display_metrics.dart';

enum MessageLayout { bubble, fullWidth }

enum MessageClusterRole { standalone, first, middle, last }

class MessageGroupingStyle {
  const MessageGroupingStyle({
    required this.role,
    required this.showSenderHeader,
    required this.compactTopSpacing,
    required this.compactBottomSpacing,
    required this.softenContinuationChrome,
  });

  static const standalone = MessageGroupingStyle(
    role: MessageClusterRole.standalone,
    showSenderHeader: true,
    compactTopSpacing: false,
    compactBottomSpacing: false,
    softenContinuationChrome: false,
  );

  final MessageClusterRole role;
  final bool showSenderHeader;
  final bool compactTopSpacing;
  final bool compactBottomSpacing;
  final bool softenContinuationChrome;
}

Widget _alignMediaForLayout({
  required MessageLayout layout,
  required bool isMe,
  required Widget child,
}) {
  if (layout == MessageLayout.bubble) {
    return child;
  }

  return Align(
    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: messageMaxBubbleWidth),
      child: child,
    ),
  );
}

Widget _alignMetadataForLayout({
  required MessageLayout layout,
  required bool isMe,
  required Widget child,
}) {
  if (layout == MessageLayout.bubble) {
    return child;
  }

  return Align(
    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: messageMaxBubbleWidth),
      child: child,
    ),
  );
}

String _formatCompactMessageDateTime(DateTime dateTime) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  final month = months[dateTime.month - 1];
  final day = dateTime.day;
  final year = dateTime.year;
  final hour = dateTime.hour;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
  final amPm = hour >= 12 ? 'PM' : 'AM';

  return '$month $day $year • $hour12:$minute $amPm';
}

String _formatClusterContinuationTime(DateTime dateTime) {
  final hour = dateTime.hour;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

  return '$hour12:$minute';
}

String _formatMessageIdLabel(int messageId) {
  final formattedId = messageId.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]},',
  );
  return 'Message ID $formattedId';
}

BorderRadius _textBorderRadiusForRole(MessageClusterRole role) {
  const large = Radius.circular(16);
  const flat = Radius.zero;

  return switch (role) {
    MessageClusterRole.standalone => const BorderRadius.all(large),
    MessageClusterRole.first => const BorderRadius.only(
      topLeft: large,
      topRight: large,
      bottomLeft: flat,
      bottomRight: flat,
    ),
    MessageClusterRole.middle => BorderRadius.zero,
    MessageClusterRole.last => const BorderRadius.only(
      topLeft: flat,
      topRight: flat,
      bottomLeft: large,
      bottomRight: large,
    ),
  };
}

Border? _textBorderForRole({
  required MessageClusterRole role,
  required Color color,
}) {
  return switch (role) {
    MessageClusterRole.standalone => Border.all(color: color, width: 1),
    MessageClusterRole.first => Border(
      top: BorderSide(color: color),
      left: BorderSide(color: color),
      right: BorderSide(color: color),
    ),
    MessageClusterRole.middle => Border(
      left: BorderSide(color: color),
      right: BorderSide(color: color),
    ),
    MessageClusterRole.last => Border(
      left: BorderSide(color: color),
      right: BorderSide(color: color),
      bottom: BorderSide(color: color),
    ),
  };
}

class MessageShell extends StatelessWidget {
  const MessageShell({
    super.key,
    required this.isMe,
    required this.child,
    this.metadata,
    this.layout = MessageLayout.bubble,
    this.grouping = MessageGroupingStyle.standalone,
  });

  final bool isMe;
  final Widget child;
  final Widget? metadata;
  final MessageLayout layout;
  final MessageGroupingStyle grouping;

  @override
  Widget build(BuildContext context) {
    final bubbleRow = switch (layout) {
      MessageLayout.bubble => Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: messageMaxBubbleWidth),
            child: child,
          ),
        ],
      ),
      MessageLayout.fullWidth => child,
    };

    return Padding(
      padding: switch (layout) {
        MessageLayout.bubble => const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 12,
        ),
        MessageLayout.fullWidth => EdgeInsets.only(
          top: grouping.compactTopSpacing ? 0 : 10,
          bottom: grouping.compactBottomSpacing ? 0 : 6,
        ),
      },
      child: Column(
        crossAxisAlignment: switch (layout) {
          MessageLayout.bubble =>
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          MessageLayout.fullWidth => CrossAxisAlignment.stretch,
        },
        children: [
          bubbleRow,
          if (metadata != null) ...[messageGapXS, metadata!],
        ],
      ),
    );
  }
}

class MetadataLine extends ConsumerWidget {
  const MetadataLine({
    super.key,
    required this.sender,
    required this.sentAt,
    required this.messageId,
    this.senderHandleLabel,
    this.layout = MessageLayout.bubble,
  });

  final String sender;
  final DateTime sentAt;
  final int messageId;
  final String? senderHandleLabel;
  final MessageLayout layout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final developerMode = ref.watch(developerModeProvider).valueOrNull;
    final isDeveloperMode = developerMode == DeveloperModeValue.developer;
    final formattedDateTime = _formatDateTime(sentAt);
    final handleLabel = senderHandleLabel?.trim();
    final handleText = handleLabel == null || handleLabel.isEmpty
        ? ''
        : ' * handle: $handleLabel';
    final metadataText = isDeveloperMode
        ? '$sender * $formattedDateTime$handleText * ID: $messageId'
        : '$sender * $formattedDateTime$handleText';

    return Text(
      metadataText,
      style: TextStyle(
        color: layout == MessageLayout.fullWidth
            ? colors.content.textSecondary
            : colors.messageBubble(MessageBubble.metadata),
        fontSize: layout == MessageLayout.fullWidth ? 12 : 11,
        height: 1.2,
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final weekday = weekdays[dateTime.weekday - 1];
    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final amPm = hour >= 12 ? 'PM' : 'AM';
    final year = dateTime.year;
    return '$weekday, $month $day, $year $hour12:$minute $amPm';
  }
}

class TextMessageTile extends ConsumerWidget {
  const TextMessageTile({
    super.key,
    required this.isMe,
    required this.text,
    required this.sender,
    required this.sentAt,
    required this.messageId,
    this.senderHandleLabel,
    this.highlight,
    this.layout = MessageLayout.bubble,
    this.grouping = MessageGroupingStyle.standalone,
    this.inlineTrailingAction,
  });

  final bool isMe;
  final String text;
  final String sender;
  final DateTime sentAt;
  final int messageId;
  final String? senderHandleLabel;
  final String? highlight;
  final MessageLayout layout;
  final MessageGroupingStyle grouping;
  final Widget? inlineTrailingAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final developerMode = ref.watch(developerModeProvider).valueOrNull;
    final isDeveloperMode = developerMode == DeveloperModeValue.developer;
    final handleLabel = senderHandleLabel?.trim();
    final bg = switch (layout) {
      MessageLayout.bubble =>
        isMe
            ? colors.messageBubble(MessageBubble.sentBg)
            : colors.messageBubble(MessageBubble.receivedBg),
      MessageLayout.fullWidth =>
        isMe
            ? colors.messagePanels.accentTintSoft
            : colors.messagePanels.receivedSurface,
    };
    final borderColor = switch (layout) {
      MessageLayout.bubble => null,
      MessageLayout.fullWidth =>
        isMe
            ? colors.messagePanels.accentBorderSoft
            : colors.messagePanels.cardBorder,
    };
    final style = TextStyle(
      color: layout == MessageLayout.fullWidth
          ? grouping.softenContinuationChrome
                ? colors.content.textPrimary.withValues(alpha: 0.94)
                : colors.content.textPrimary
          : isMe
          ? colors.messageBubble(MessageBubble.sentText)
          : colors.messageBubble(MessageBubble.receivedText),
      height: 1.25,
      fontSize: 14.5,
    );
    final highlightStyle = style.copyWith(
      backgroundColor: layout == MessageLayout.fullWidth
          ? isMe
                ? colors.messagePanels.selectionTint
                : colors.messageBubble(MessageBubble.receivedHighlight)
          : isMe
          ? colors.messageBubble(MessageBubble.sentHighlight)
          : colors.messageBubble(MessageBubble.receivedHighlight),
    );
    final contentSpan = _buildContentSpan(
      baseStyle: style,
      highlightStyle: highlightStyle,
    );
    final inlineAction = inlineTrailingAction;
    final usesOverlayAction =
        inlineAction != null && !grouping.showSenderHeader;

    return MessageShell(
      isMe: isMe,
      layout: layout,
      grouping: grouping,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: messageBubblePadding.horizontal / 2,
          vertical:
              layout == MessageLayout.fullWidth && grouping.compactTopSpacing
              ? 4
              : messageBubblePadding.vertical / 2,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: layout == MessageLayout.fullWidth
              ? _textBorderRadiusForRole(grouping.role)
              : messageTextRadius,
          border: borderColor == null
              ? null
              : layout == MessageLayout.fullWidth
              ? _textBorderForRole(role: grouping.role, color: borderColor)
              : Border.all(color: borderColor, width: 1),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (grouping.showSenderHeader) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: sender,
                                style: TextStyle(
                                  color: colors.content.textSecondary,
                                  fontSize: 12,
                                  height: 1.2,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text: ' — ',
                                style: TextStyle(
                                  color: colors.content.textTertiary,
                                  fontSize: 12,
                                  height: 1.2,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              TextSpan(
                                text: _formatCompactMessageDateTime(sentAt),
                                style: TextStyle(
                                  color: colors.content.textSecondaryQuiet,
                                  fontSize: 12,
                                  height: 1.2,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              if (handleLabel != null && handleLabel.isNotEmpty)
                                TextSpan(
                                  text: ' — handle: $handleLabel',
                                  style: TextStyle(
                                    color: colors.content.textSecondary,
                                    fontSize: 12,
                                    height: 1.2,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              if (isDeveloperMode)
                                TextSpan(
                                  text:
                                      ' — ${_formatMessageIdLabel(messageId)}',
                                  style: TextStyle(
                                    color: colors.content.textSecondary,
                                    fontSize: 12,
                                    height: 1.2,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (inlineAction != null) ...[
                        const SizedBox(width: 12),
                        inlineAction,
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                if (grouping.showSenderHeader)
                  _buildMessageBody(
                    contentSpan: contentSpan,
                    reserveTrailingActionSpace: false,
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildMessageBody(
                          contentSpan: contentSpan,
                          reserveTrailingActionSpace: usesOverlayAction,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          _formatClusterContinuationTime(sentAt),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: colors.content.textSecondaryQuiet,
                            fontSize: 11,
                            height: 1.1,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            if (usesOverlayAction)
              Positioned(right: 12, top: 8, child: inlineAction),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBody({
    required TextSpan contentSpan,
    required bool reserveTrailingActionSpace,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: reserveTrailingActionSpace ? 44 : 0),
      child: SelectableText.rich(contentSpan),
    );
  }

  TextSpan _buildContentSpan({
    required TextStyle baseStyle,
    required TextStyle highlightStyle,
  }) {
    final rawQuery = highlight;
    if (rawQuery == null) {
      return TextSpan(text: text, style: baseStyle);
    }
    final intent = MessageTextSearchQuery.parse(rawQuery).executionIntent;
    final matches = messageTextSearchHighlightMatches(
      text: text,
      intent: intent,
    );
    if (matches.isEmpty) {
      return TextSpan(text: text, style: baseStyle);
    }

    final spans = <TextSpan>[];
    var start = 0;
    for (final match in matches) {
      if (match.start > start) {
        spans.add(
          TextSpan(text: text.substring(start, match.start), style: baseStyle),
        );
      }

      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: highlightStyle,
        ),
      );
      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: baseStyle));
    }

    if (spans.isEmpty) {
      return TextSpan(text: text, style: baseStyle);
    }

    return TextSpan(children: spans);
  }
}

/// Placeholder shown when an image or video file is not locally available.
///
/// Differentiates between:
/// - **cloudOnly**: The file is known in the DB but not on disk (iCloud-evicted).
/// - **missing**: No local path was ever recorded for this attachment.
class _MediaUnavailablePlaceholder extends ConsumerWidget {
  const _MediaUnavailablePlaceholder({
    required this.hasLocalReference,
    required this.mediaLabel,
    this.sourceProvenance,
    this.onPrioritizeRecoveryTap,
    this.cardKey,
    this.availability,
  });

  final bool hasLocalReference;

  /// Human label for the media type — "Image" or "Video".
  final String mediaLabel;
  final AttachmentProvenance? sourceProvenance;
  final VoidCallback? onPrioritizeRecoveryTap;
  final Key? cardKey;
  final ResolvedAttachmentAvailability? availability;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    final isPendingArchive =
        availability == ResolvedAttachmentAvailability.pendingArchive;
    final isCloudOnly = availability == null
        ? hasLocalReference
        : availability ==
                  ResolvedAttachmentAvailability.unavailableAwaitingRecovery &&
              hasLocalReference;

    final icon = isPendingArchive
        ? Icons.archive_outlined
        : isCloudOnly
        ? Icons.cloud_outlined
        : Icons.broken_image_outlined;
    final label = isPendingArchive
        ? '$mediaLabel being archived'
        : isCloudOnly
        ? '$mediaLabel in iCloud'
        : availability ==
              ResolvedAttachmentAvailability.unavailableAwaitingRecovery
        ? '$mediaLabel awaiting recovery'
        : '$mediaLabel unavailable';
    final tooltipMessage = isPendingArchive
        ? '$mediaLabel being added to the archive'
        : isCloudOnly
        ? '$mediaLabel stored in iCloud\u2009—\u2009not downloaded to this Mac'
        : availability ==
              ResolvedAttachmentAvailability.unavailableAwaitingRecovery
        ? '$mediaLabel awaiting recovery'
        : '$mediaLabel not available';

    return Tooltip(
      message: tooltipMessage,
      waitDuration: const Duration(milliseconds: 300),
      child: Align(
        alignment: Alignment.centerLeft,
        widthFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 240),
          child: DecoratedBox(
            key: cardKey,
            decoration: BoxDecoration(
              color: colors.surfaces.surface,
              borderRadius: messageMediaRadius,
              border: Border.all(color: colors.lines.borderSubtle),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 15, color: colors.content.iconSecondary),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.15,
                            fontWeight: FontWeight.w600,
                            color: colors.content.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (sourceProvenance case final provenance?) ...[
                    const SizedBox(height: 8),
                    _AttachmentSourceBadge(
                      provenance: provenance,
                      showTooltip: false,
                    ),
                  ],
                  if (!isPendingArchive && onPrioritizeRecoveryTap != null) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: onPrioritizeRecoveryTap,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.surfaces.surface.withValues(
                            alpha: 0.68,
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Text(
                            'Prioritize recovery',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: colors.accents.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AttachmentSourceBadge extends ConsumerWidget {
  const _AttachmentSourceBadge({
    required this.provenance,
    this.showTooltip = true,
  });

  final AttachmentProvenance provenance;
  final bool showTooltip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final isLive = provenance == AttachmentProvenance.messagesLive;
    final isBackup = provenance == AttachmentProvenance.importedHistorical;
    final label = switch (provenance) {
      AttachmentProvenance.messagesLive => 'Live',
      AttachmentProvenance.archived => 'Archive',
      AttachmentProvenance.importedHistorical => 'Backup',
    };
    final tooltipMessage = switch (provenance) {
      AttachmentProvenance.messagesLive =>
        'Attachment source: Live Messages file',
      AttachmentProvenance.archived => 'Attachment source: MessageLens archive',
      AttachmentProvenance.importedHistorical =>
        'Attachment source: recovered backup archive',
    };

    final badge = DecoratedBox(
      key: ValueKey<String>('attachment-source-badge-$label'),
      decoration: BoxDecoration(
        color: isLive
            ? colors.surfaces.surface.withValues(alpha: 0.88)
            : isBackup
            ? colors.messagePanels.mutedTint
            : colors.accents.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isLive
              ? colors.lines.borderSubtle
              : isBackup
              ? colors.messagePanels.mutedBorder
              : colors.accents.primary.withValues(alpha: 0.28),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isLive
                ? colors.content.textSecondary
                : isBackup
                ? colors.content.textSecondary
                : colors.accents.primary,
          ),
        ),
      ),
    );

    if (!showTooltip) {
      return badge;
    }

    return Tooltip(
      message: tooltipMessage,
      waitDuration: const Duration(milliseconds: 300),
      child: badge,
    );
  }
}

AttachmentProvenance? _placeholderSourceProvenance(
  MediaTileAttachment attachment,
) {
  final provenance = attachment.provenance;
  if (provenance != null) {
    return provenance;
  }

  if (attachment.hasLocalFile) {
    return AttachmentProvenance.messagesLive;
  }

  return null;
}

File? _displayableMediaFile(
  MediaTileAttachment attachment,
  AttachmentFileAccess fileAccess,
) {
  final explicitPath = attachment.resolvedDisplayPath;
  if (explicitPath != null && explicitPath.isNotEmpty) {
    final existingPath = fileAccess.existingExpandedPath(explicitPath);
    return existingPath == null ? null : File(existingPath);
  }

  if (attachment.availability != null) {
    return null;
  }

  final existingPath = fileAccess.existingExpandedPath(attachment.localPath);
  return existingPath == null ? null : File(existingPath);
}

class ImageMessageTile extends ConsumerWidget {
  const ImageMessageTile({
    super.key,
    required this.isMe,
    required this.attachment,
    required this.sender,
    required this.sentAt,
    required this.messageId,
    this.senderHandleLabel,
    this.captionText,
    this.layout = MessageLayout.bubble,
    this.grouping = MessageGroupingStyle.standalone,
  });

  final bool isMe;
  final MediaTileAttachment attachment;
  final String sender;
  final DateTime sentAt;
  final int messageId;
  final String? senderHandleLabel;
  final String? captionText;
  final MessageLayout layout;
  final MessageGroupingStyle grouping;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fileAccess = ref.watch(attachmentFileAccessProvider);
    final file = _displayableMediaFile(attachment, fileAccess);
    final aspectRatio = attachment.aspectRatio ?? 4 / 3;
    final archiveKey = attachment.archiveCompatibilityKey;
    final canPrioritizeRecovery =
        archiveKey != null &&
        attachment.availability !=
            ResolvedAttachmentAvailability.pendingArchive;
    final provenance = attachment.provenance;

    return MessageShell(
      isMe: isMe,
      layout: layout,
      grouping: grouping,
      metadata: _alignMetadataForLayout(
        layout: layout,
        isMe: isMe,
        child: MetadataLine(
          sender: sender,
          sentAt: sentAt,
          messageId: messageId,
          senderHandleLabel: senderHandleLabel,
          layout: layout,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _alignMediaForLayout(
            layout: layout,
            isMe: isMe,
            child: file != null
                ? ClipRRect(
                    borderRadius: messageMediaRadius,
                    child: _IntrinsicSizedMedia(
                      child: AspectRatio(
                        aspectRatio: aspectRatio,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            const ColoredBox(color: Colors.black12),
                            Image.file(
                              file,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.medium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : _MediaUnavailablePlaceholder(
                    availability: attachment.availability,
                    hasLocalReference: attachment.hasLocalFile,
                    sourceProvenance: _placeholderSourceProvenance(attachment),
                    cardKey: const ValueKey<String>(
                      'unavailable-media-card-Image',
                    ),
                    mediaLabel: 'Image',
                    onPrioritizeRecoveryTap: canPrioritizeRecovery
                        ? () {
                            ref
                                .read(
                                  attachmentRecoveryActionsProvider.notifier,
                                )
                                .prioritizeRecovery(
                                  archiveKey: archiveKey,
                                  resolvedLocalPath: fileAccess.expandPath(
                                    attachment.localPath,
                                  ),
                                  mimeType: attachment.mimeType,
                                );
                          }
                        : null,
                  ),
          ),
          if (file != null)
            if (provenance case final attachmentProvenance?) ...[
              const SizedBox(height: 8),
              _alignMediaForLayout(
                layout: layout,
                isMe: isMe,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _AttachmentSourceBadge(
                    provenance: attachmentProvenance,
                  ),
                ),
              ),
            ],
          if (captionText != null) ...[
            messageGapMD,
            _AttachedTextBubble(
              isMe: isMe,
              text: captionText!,
              layout: layout,
              grouping: grouping,
            ),
          ],
        ],
      ),
    );
  }
}

class VideoMessageTile extends ConsumerStatefulWidget {
  const VideoMessageTile({
    super.key,
    required this.isMe,
    required this.attachment,
    required this.sender,
    required this.sentAt,
    required this.messageId,
    this.senderHandleLabel,
    this.captionText,
    this.layout = MessageLayout.bubble,
    this.grouping = MessageGroupingStyle.standalone,
  });

  final bool isMe;
  final MediaTileAttachment attachment;
  final String sender;
  final DateTime sentAt;
  final int messageId;
  final String? senderHandleLabel;
  final String? captionText;
  final MessageLayout layout;
  final MessageGroupingStyle grouping;

  @override
  ConsumerState<VideoMessageTile> createState() => _VideoMessageTileState();
}

class _VideoMessageTileState extends ConsumerState<VideoMessageTile> {
  static const _thumbnailEnrichmentDelay = Duration(milliseconds: 350);

  VideoPlayerController? _controller;
  bool _ready = false;
  bool _isActivating = false;
  bool _activationFailed = false;
  Timer? _thumbnailEnrichmentTimer;
  File? _thumbnailFile;
  String? _thumbnailSourcePath;
  int _thumbnailRequestGeneration = 0;
  int _activationGeneration = 0;
  double? _resolvedAspectRatio;

  @override
  void initState() {
    super.initState();
    _scheduleThumbnailEnrichment();
  }

  @override
  void didUpdateWidget(covariant VideoMessageTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    final fileAccess = ref.read(attachmentFileAccessProvider);
    final previousVideoPath = _displayableMediaFile(
      oldWidget.attachment,
      fileAccess,
    )?.path;
    final currentVideoPath = _displayableMediaFile(
      widget.attachment,
      fileAccess,
    )?.path;
    if (previousVideoPath == currentVideoPath) {
      if (_thumbnailFile == null && currentVideoPath != null) {
        _scheduleThumbnailEnrichment();
      }
      return;
    }

    _thumbnailEnrichmentTimer?.cancel();
    _thumbnailEnrichmentTimer = null;
    _thumbnailFile = null;
    _thumbnailSourcePath = null;
    _thumbnailRequestGeneration++;
    _activationGeneration++;
    _disposeActiveController();
    _ready = false;
    _isActivating = false;
    _activationFailed = false;
    _resolvedAspectRatio = null;
    _scheduleThumbnailEnrichment();
  }

  @override
  void dispose() {
    _thumbnailEnrichmentTimer?.cancel();
    _disposeActiveController();
    super.dispose();
  }

  void _disposeActiveController() {
    final controller = _controller;
    _controller = null;
    if (controller == null) {
      return;
    }

    unawaited(() async {
      try {
        if (controller.value.isPlaying) {
          await controller.pause();
        }
      } catch (error, stackTrace) {
        _logVideoFailure(
          stage: 'pauseDuringDispose',
          error: error,
          stackTrace: stackTrace,
        );
      }

      try {
        await controller.dispose();
      } catch (error, stackTrace) {
        _logVideoFailure(
          stage: 'disposeController',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }());
  }

  double _effectiveAspectRatio() {
    final resolvedAspectRatio = _resolvedAspectRatio;
    if (resolvedAspectRatio != null &&
        resolvedAspectRatio.isFinite &&
        resolvedAspectRatio > 0) {
      return resolvedAspectRatio;
    }

    final attachmentAspectRatio = widget.attachment.aspectRatio;
    if (attachmentAspectRatio != null &&
        attachmentAspectRatio.isFinite &&
        attachmentAspectRatio > 0) {
      return attachmentAspectRatio;
    }

    return 16 / 9;
  }

  void _scheduleThumbnailEnrichment() {
    if (_controller != null) {
      return;
    }

    final videoFile = _displayableMediaFile(
      widget.attachment,
      ref.read(attachmentFileAccessProvider),
    );
    if (videoFile == null) {
      return;
    }
    if (_thumbnailFile != null && _thumbnailSourcePath == videoFile.path) {
      return;
    }
    if (_thumbnailEnrichmentTimer != null) {
      return;
    }

    _thumbnailEnrichmentTimer = Timer(_thumbnailEnrichmentDelay, () {
      _thumbnailEnrichmentTimer = null;
      unawaited(_loadThumbnail(videoFile));
    });
  }

  Future<void> _loadThumbnail(File videoFile) async {
    if (_controller != null) {
      return;
    }

    final requestGeneration = ++_thumbnailRequestGeneration;
    final thumbnailCache = ref.read(videoThumbnailCacheProvider);

    try {
      final thumbnailPath = await thumbnailCache.getOrCreateThumbnailPath(
        videoPath: videoFile.path,
      );
      if (!mounted || requestGeneration != _thumbnailRequestGeneration) {
        return;
      }

      setState(() {
        _thumbnailFile = thumbnailPath == null ? null : File(thumbnailPath);
        _thumbnailSourcePath = videoFile.path;
      });
    } catch (error, stackTrace) {
      _logVideoFailure(
        stage: 'loadThumbnail',
        error: error,
        stackTrace: stackTrace,
        filePath: videoFile.path,
      );
      if (!mounted || requestGeneration != _thumbnailRequestGeneration) {
        return;
      }

      setState(() {
        _thumbnailFile = null;
        _thumbnailSourcePath = videoFile.path;
      });
    }
  }

  Future<void> _toggle() async {
    final controller = _controller;
    if (controller == null || !_ready) {
      return;
    }

    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }
  }

  Future<void> _activateVideo({required bool autoplay}) async {
    final existingController = _controller;
    if (existingController != null) {
      if (autoplay && _ready && !existingController.value.isPlaying) {
        await existingController.play();
        if (!mounted) {
          return;
        }
        setState(() {});
      }
      return;
    }

    if (_isActivating) {
      return;
    }

    final file = _displayableMediaFile(
      widget.attachment,
      ref.read(attachmentFileAccessProvider),
    );
    if (file == null) {
      return;
    }

    setState(() {
      _isActivating = true;
      _activationFailed = false;
    });
    _thumbnailEnrichmentTimer?.cancel();
    _thumbnailEnrichmentTimer = null;
    _thumbnailRequestGeneration++;
    final activationGeneration = ++_activationGeneration;

    final controller = VideoPlayerController.file(file);

    try {
      await controller.initialize();

      if (!mounted || activationGeneration != _activationGeneration) {
        await controller.dispose();
        return;
      }

      final controllerAspectRatio = controller.value.aspectRatio;

      _controller = controller;

      setState(() {
        _ready = true;
        _isActivating = false;
        if (controllerAspectRatio.isFinite && controllerAspectRatio > 0) {
          _resolvedAspectRatio = controllerAspectRatio;
        }
      });

      if (autoplay) {
        await controller.play();
        if (!mounted || activationGeneration != _activationGeneration) {
          return;
        }
      }
    } catch (error, stackTrace) {
      _logVideoFailure(
        stage: 'activateVideo',
        error: error,
        stackTrace: stackTrace,
        filePath: file.path,
      );
      await controller.dispose();
      if (!mounted || activationGeneration != _activationGeneration) {
        return;
      }
      setState(() {
        _ready = false;
        _isActivating = false;
        _activationFailed = true;
      });
    }
  }

  void _logVideoFailure({
    required String stage,
    required Object error,
    required StackTrace stackTrace,
    String? filePath,
  }) {
    ref
        .read(messageMediaDiagnosticsProvider.notifier)
        .reportVideoTileFailure(
          stage: stage,
          error: error,
          stackTrace: stackTrace,
          filePath: filePath,
          attachmentLocalPath: widget.attachment.localPath,
          attachmentResolvedDisplayPath: widget.attachment.resolvedDisplayPath,
          mimeType: widget.attachment.mimeType,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeColorsProvider);
    final aspectRatio = _effectiveAspectRatio();
    final fileAccess = ref.watch(attachmentFileAccessProvider);
    final file = _displayableMediaFile(widget.attachment, fileAccess);
    final hasPlayableVideo = file != null;
    final hasVideoController = _controller != null;
    final archiveKey = widget.attachment.archiveCompatibilityKey;
    final canPrioritizeRecovery =
        archiveKey != null &&
        widget.attachment.availability !=
            ResolvedAttachmentAvailability.pendingArchive;
    final provenance = widget.attachment.provenance;

    return MessageShell(
      isMe: widget.isMe,
      layout: widget.layout,
      grouping: widget.grouping,
      metadata: _alignMetadataForLayout(
        layout: widget.layout,
        isMe: widget.isMe,
        child: MetadataLine(
          sender: widget.sender,
          sentAt: widget.sentAt,
          messageId: widget.messageId,
          senderHandleLabel: widget.senderHandleLabel,
          layout: widget.layout,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _alignMediaForLayout(
            layout: widget.layout,
            isMe: widget.isMe,
            child: hasPlayableVideo
                ? hasVideoController
                      ? _ActivatedVideoPlayer(
                          controller: _controller!,
                          aspectRatio: aspectRatio,
                          isReady: _ready,
                          onTogglePlayback: _toggle,
                        )
                      : VideoActivationShell(
                          aspectRatio: aspectRatio,
                          isActivating: _isActivating,
                          activationFailed: _activationFailed,
                          thumbnailFile: _thumbnailFile,
                          onActivate: _isActivating
                              ? null
                              : () {
                                  unawaited(_activateVideo(autoplay: true));
                                },
                        )
                : _MediaUnavailablePlaceholder(
                    availability: widget.attachment.availability,
                    hasLocalReference: widget.attachment.hasLocalFile,
                    sourceProvenance: _placeholderSourceProvenance(
                      widget.attachment,
                    ),
                    cardKey: const ValueKey<String>(
                      'unavailable-media-card-Video',
                    ),
                    mediaLabel: 'Video',
                    onPrioritizeRecoveryTap: canPrioritizeRecovery
                        ? () {
                            ref
                                .read(
                                  attachmentRecoveryActionsProvider.notifier,
                                )
                                .prioritizeRecovery(
                                  archiveKey: archiveKey,
                                  resolvedLocalPath: fileAccess.expandPath(
                                    widget.attachment.localPath,
                                  ),
                                  mimeType: widget.attachment.mimeType,
                                );
                          }
                        : null,
                  ),
          ),
          if (hasPlayableVideo)
            if (provenance case final attachmentProvenance?) ...[
              const SizedBox(height: 8),
              _alignMediaForLayout(
                layout: widget.layout,
                isMe: widget.isMe,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _AttachmentSourceBadge(
                    provenance: attachmentProvenance,
                  ),
                ),
              ),
            ],
          if (widget.captionText != null) ...[
            messageGapMD,
            _AttachedTextBubble(
              isMe: widget.isMe,
              text: widget.captionText!,
              layout: widget.layout,
              grouping: widget.grouping,
            ),
          ],
        ],
      ),
    );
  }
}

class _ActivatedVideoPlayer extends ConsumerWidget {
  const _ActivatedVideoPlayer({
    required this.controller,
    required this.aspectRatio,
    required this.isReady,
    required this.onTogglePlayback,
  });

  final VideoPlayerController controller;
  final double aspectRatio;
  final bool isReady;
  final Future<void> Function() onTogglePlayback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaces.surface,
        borderRadius: messageMediaRadius,
        border: Border.all(color: colors.lines.borderSubtle),
      ),
      child: ClipRRect(
        borderRadius: messageMediaRadius,
        child: _IntrinsicSizedMedia(
          child: ValueListenableBuilder<VideoPlayerValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              final playerAspectRatio =
                  value.isInitialized &&
                      value.aspectRatio.isFinite &&
                      value.aspectRatio > 0
                  ? value.aspectRatio
                  : aspectRatio;
              final isPlaying = value.isPlaying;

              return AspectRatio(
                aspectRatio: playerAspectRatio,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const ColoredBox(color: Colors.black),
                    if (isReady)
                      child!
                    else
                      const Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: isReady
                              ? () {
                                  unawaited(onTogglePlayback());
                                }
                              : null,
                        ),
                      ),
                    ),
                    if (!isPlaying && isReady)
                      const Center(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              shape: BoxShape.circle,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (isReady)
                      Positioned(
                        left: 10,
                        right: 10,
                        bottom: 10,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  key: const ValueKey<String>(
                                    'active-video-toggle-button',
                                  ),
                                  onPressed: () {
                                    unawaited(onTogglePlayback());
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 28,
                                    minHeight: 28,
                                  ),
                                  splashRadius: 18,
                                  icon: Icon(
                                    isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: VideoProgressIndicator(
                                    controller,
                                    allowScrubbing: true,
                                    padding: EdgeInsets.zero,
                                    colors: VideoProgressColors(
                                      playedColor:
                                          colors.messagePanels.accentBorderSoft,
                                      bufferedColor: Colors.white.withValues(
                                        alpha: 0.32,
                                      ),
                                      backgroundColor: Colors.white.withValues(
                                        alpha: 0.18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
            child: VideoPlayer(controller),
          ),
        ),
      ),
    );
  }
}

class VideoActivationShell extends ConsumerWidget {
  const VideoActivationShell({
    super.key,
    required this.aspectRatio,
    required this.isActivating,
    required this.activationFailed,
    required this.thumbnailFile,
    required this.onActivate,
  });

  final double aspectRatio;
  final bool isActivating;
  final bool activationFailed;
  final File? thumbnailFile;
  final VoidCallback? onActivate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    final buttonLabel = switch ((isActivating, activationFailed)) {
      (true, _) => 'Loading video...',
      (false, true) => 'Retry video',
      (false, false) => 'Play video',
    };

    return DecoratedBox(
      key: const ValueKey<String>('video-activation-shell-card'),
      decoration: BoxDecoration(
        color: colors.surfaces.surface,
        borderRadius: messageMediaRadius,
        border: Border.all(color: colors.lines.borderSubtle),
      ),
      child: ClipRRect(
        borderRadius: messageMediaRadius,
        child: _IntrinsicSizedMedia(
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (thumbnailFile != null)
                  Positioned.fill(
                    child: Image.file(
                      thumbnailFile!,
                      key: const ValueKey<String>('video-activation-thumbnail'),
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.low,
                    ),
                  )
                else
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colors.messagePanels.receivedSurface,
                          colors.surfaces.surface,
                        ],
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(
                            alpha: thumbnailFile == null ? 0.02 : 0.08,
                          ),
                          Colors.black.withValues(
                            alpha: thumbnailFile == null ? 0.06 : 0.26,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.surfaces.surface.withValues(alpha: 0.84),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.ondemand_video_outlined,
                            size: 16,
                            color: colors.content.textPrimary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Video',
                            style: TextStyle(
                              color: colors.content.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: isActivating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : TextButton.icon(
                          key: const ValueKey<String>(
                            'video-activation-shell-button',
                          ),
                          onPressed: onActivate,
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: Text(buttonLabel),
                          style: TextButton.styleFrom(
                            foregroundColor: colors.content.textPrimary,
                            backgroundColor: colors.surfaces.surface.withValues(
                              alpha: thumbnailFile == null ? 0.82 : 0.9,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AttachedTextBubble extends ConsumerWidget {
  const _AttachedTextBubble({
    required this.isMe,
    required this.text,
    required this.layout,
    required this.grouping,
  });

  final bool isMe;
  final String text;
  final MessageLayout layout;
  final MessageGroupingStyle grouping;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final bg = switch (layout) {
      MessageLayout.bubble =>
        isMe
            ? colors.messageBubble(MessageBubble.sentBg)
            : colors.messageBubble(MessageBubble.receivedBg),
      MessageLayout.fullWidth =>
        isMe
            ? colors.messagePanels.accentTintSoft
            : colors.messagePanels.receivedSurface,
    };
    final borderColor = switch (layout) {
      MessageLayout.bubble => null,
      MessageLayout.fullWidth =>
        isMe
            ? colors.messagePanels.accentBorderSoft
            : colors.messagePanels.cardBorder,
    };
    final textColor = switch (layout) {
      MessageLayout.bubble =>
        isMe
            ? colors.messageBubble(MessageBubble.sentText)
            : colors.messageBubble(MessageBubble.receivedText),
      MessageLayout.fullWidth =>
        grouping.softenContinuationChrome
            ? colors.content.textPrimary.withValues(alpha: 0.94)
            : colors.content.textPrimary,
    };

    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: messageBubblePadding.horizontal / 2,
          vertical: messageBubblePadding.vertical / 2,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: messageTextRadius,
          border: borderColor == null
              ? null
              : Border.all(color: borderColor, width: 1),
        ),
        child: SelectableText(
          text,
          style: TextStyle(color: textColor, height: 1.25, fontSize: 14.5),
        ),
      ),
    );
  }
}

class LinkPreviewTile extends ConsumerWidget {
  const LinkPreviewTile({
    super.key,
    required this.isMe,
    required this.url,
    required this.sender,
    required this.sentAt,
    required this.messageId,
    this.senderHandleLabel,
    this.previewImage,
    this.previewImageWidget,
    this.previewText,
    this.layout = MessageLayout.bubble,
    this.grouping = MessageGroupingStyle.standalone,
  }) : assert(
         previewImage != null || previewImageWidget != null,
         'Provide either previewImage or previewImageWidget',
       );

  final bool isMe;
  final Uri url;
  final String sender;
  final DateTime sentAt;
  final int messageId;
  final String? senderHandleLabel;
  final File? previewImage;
  final Widget? previewImageWidget;
  final String? previewText;
  final MessageLayout layout;
  final MessageGroupingStyle grouping;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final domain = url.host;
    final image =
        previewImageWidget ??
        Image.file(
          previewImage!,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
        );

    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaces.surface,
        borderRadius: messageMediaRadius,
        border: Border.all(color: colors.lines.borderSubtle),
      ),
      child: ClipRRect(
        borderRadius: messageMediaRadius,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _IntrinsicSizedMedia(child: image),
            Container(
              color: colors.messageBubble(MessageBubble.linkBanner),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Text(
                domain,
                style: TextStyle(
                  color: colors.messageBubble(MessageBubble.linkBannerText),
                  fontSize: 12.5,
                  height: 1.2,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if ((previewText ?? '').trim().isNotEmpty)
              Container(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Text(
                  previewText!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.25,
                    color: colors.content.textPrimary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    return MessageShell(
      isMe: isMe,
      layout: layout,
      grouping: grouping,
      metadata: MetadataLine(
        sender: sender,
        sentAt: sentAt,
        messageId: messageId,
        senderHandleLabel: senderHandleLabel,
        layout: layout,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(onTap: () => _launch(ref, url), child: card),
      ),
    );
  }

  Future<void> _launch(WidgetRef ref, Uri target) async {
    await ref.read(externalLinkActionsProvider.notifier).open(target);
  }
}

class _IntrinsicSizedMedia extends StatelessWidget {
  const _IntrinsicSizedMedia({required this.child});

  final Widget child;

  static const double _maxHeight = 420;
  static const double _minHeight = 140;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: _minHeight,
            maxHeight: _maxHeight,
          ),
          child: child,
        );
      },
    );
  }
}

enum MsgType { text, image, video, link }

class DemoMessage {
  DemoMessage({
    required this.type,
    required this.isMe,
    required this.sender,
    required this.sentAt,
    required this.messageId,
    this.text,
    this.file,
    this.url,
    this.previewText,
  });

  final MsgType type;
  final bool isMe;
  final String sender;
  final DateTime sentAt;
  final int messageId;
  final String? text;
  final File? file;
  final Uri? url;
  final String? previewText;
}

class DemoConversationList extends StatelessWidget {
  const DemoConversationList({super.key, required this.items});

  final List<DemoMessage> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: conversationHorizontalPadding(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final message = items[index];
        switch (message.type) {
          case MsgType.text:
            return TextMessageTile(
              isMe: message.isMe,
              text: message.text ?? '',
              sender: message.sender,
              sentAt: message.sentAt,
              messageId: message.messageId,
            );
          case MsgType.image:
            return ImageMessageTile(
              isMe: message.isMe,
              attachment: MediaTileAttachment(
                id: message.messageId,
                localPath: message.file?.path,
                mimeType: 'image/*',
                transferName: message.file?.path,
              ),
              sender: message.sender,
              sentAt: message.sentAt,
              messageId: message.messageId,
            );
          case MsgType.video:
            return VideoMessageTile(
              isMe: message.isMe,
              attachment: MediaTileAttachment(
                id: message.messageId,
                localPath: message.file?.path,
                mimeType: 'video/*',
                transferName: message.file?.path,
              ),
              sender: message.sender,
              sentAt: message.sentAt,
              messageId: message.messageId,
            );
          case MsgType.link:
            return LinkPreviewTile(
              isMe: message.isMe,
              url: message.url!,
              sender: message.sender,
              sentAt: message.sentAt,
              messageId: message.messageId,
              previewImage: message.file,
              previewText: message.previewText,
            );
        }
      },
    );
  }
}
