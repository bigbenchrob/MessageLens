import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show SelectableText, Tooltip;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/spacing/app_spacing.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../essentials/navigation/feature_level_providers.dart'
    show panelActionsProvider;
import '../../../attachments/domain/constants/attachment_provenance.dart';
import '../../../attachments/domain/constants/resolved_attachment_availability.dart';
import '../../../attachments/domain/entities/resolved_attachment.dart';
import '../../../attachments/feature_level_providers.dart'
    show attachmentFileAccessProvider, attachmentResolverProvider;
import '../../domain/entities/attachment_info.dart';

class RecoveredAttachmentSidebarView extends ConsumerWidget {
  const RecoveredAttachmentSidebarView({
    required this.messageId,
    required this.attachment,
    super.key,
  });

  final int messageId;
  final AttachmentInfo attachment;

  String _displayName({String? fallbackPath}) {
    final transferName = attachment.transferName?.trim();
    if (transferName != null && transferName.isNotEmpty) {
      return transferName;
    }

    final resolvedPath = fallbackPath?.trim() ?? attachment.localPath?.trim();
    if (resolvedPath == null || resolvedPath.isEmpty) {
      return 'Recovered attachment';
    }

    final segments = resolvedPath.split('/');
    final lastSegment = segments.isEmpty ? resolvedPath : segments.last.trim();
    if (lastSegment.isEmpty) {
      return 'Recovered attachment';
    }

    return lastSegment;
  }

  String _kindLabel() {
    if (attachment.isImage) {
      return 'Recovered image attachment';
    }
    if (attachment.isVideo) {
      return 'Recovered video attachment';
    }
    if (attachment.isUrlPreview) {
      return 'Recovered link preview attachment';
    }
    return 'Recovered attachment';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final fileAccess = ref.watch(attachmentFileAccessProvider);
    final presentation = _RecoveredAttachmentSidebarPresentation.from(
      attachment: attachment,
      recordedPath: fileAccess.expandPath(attachment.localPath),
      resolvedAttachmentAsync: _watchResolvedAttachment(ref),
    );

    return ColoredBox(
      color: colors.surfaces.canvas,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                children: [
                  Text('Recovered attachment', style: typography.headline),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _displayName(fallbackPath: presentation.displayNamePath),
                    style: typography.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${_kindLabel()} from recovered message $messageId',
                    style: typography.caption1.copyWith(
                      color: colors.content.textSecondary,
                    ),
                  ),
                  if (presentation.sourceLabel case final sourceLabel?) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _RecoveredAttachmentSourceBadge(
                      label: sourceLabel,
                      tooltipMessage: presentation.sourceTooltipMessage!,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  _RecoveredAttachmentPreview(
                    attachment: attachment,
                    presentation: presentation,
                  ),
                  if (presentation.pathLabel case final pathLabel?) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      pathLabel,
                      style: typography.caption.copyWith(
                        color: colors.content.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    SelectableText(
                      presentation.pathValue!,
                      style: typography.caption1,
                    ),
                  ],
                  if (attachment.mimeType != null &&
                      attachment.mimeType!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'MIME type',
                      style: typography.caption.copyWith(
                        color: colors.content.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(attachment.mimeType!, style: typography.caption1),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerLeft,
              child: PushButton(
                controlSize: ControlSize.large,
                secondary: true,
                onPressed: () {
                  ref
                      .read(panelActionsProvider.notifier)
                      .closeActiveRightPanel();
                },
                child: const Text('Close sidebar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AsyncValue<ResolvedAttachment>? _watchResolvedAttachment(WidgetRef ref) {
    return ref.watch(attachmentResolverProvider(attachment));
  }
}

class _RecoveredAttachmentPreview extends ConsumerWidget {
  const _RecoveredAttachmentPreview({
    required this.attachment,
    required this.presentation,
  });

  final AttachmentInfo attachment;
  final _RecoveredAttachmentSidebarPresentation presentation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final previewFile = presentation.previewFile;
    final hasResolvedFile = previewFile != null;

    if (hasResolvedFile && attachment.isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          previewFile,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) {
            return const _RecoveredAttachmentPlaceholder(
              cardKey: ValueKey<String>('recovered-placeholder-image-error'),
              title: 'Image preview unavailable',
              body:
                  'A file was resolved for this image, but Flutter could not render it here.',
            );
          },
        ),
      );
    }

    if (presentation.isResolving) {
      return const _RecoveredAttachmentPlaceholder(
        cardKey: ValueKey<String>('recovered-placeholder-loading'),
        title: 'Checking attachment availability',
        body:
            'MessageLens is checking the live Messages folder and the attachment archive for a displayable file.',
      );
    }

    if (hasResolvedFile && attachment.isVideo) {
      return const _RecoveredAttachmentPlaceholder(
        cardKey: ValueKey<String>('recovered-placeholder-video'),
        title: 'Recovered video',
        body:
            'This recovered attachment looks like a video. Inline video playback can be added later.',
      );
    }

    if (hasResolvedFile && attachment.isUrlPreview) {
      return const _RecoveredAttachmentPlaceholder(
        cardKey: ValueKey<String>('recovered-placeholder-link-preview'),
        title: 'Recovered link preview attachment',
        body:
            'This attachment appears to be a stored link-preview payload. Dedicated preview rendering can be added later.',
      );
    }

    if (hasResolvedFile) {
      return const _RecoveredAttachmentPlaceholder(
        cardKey: ValueKey<String>('recovered-placeholder-file'),
        title: 'Recovered file',
        body:
            'A recovered attachment file is linked to this message. Rich inline rendering is not available for this file type yet.',
      );
    }

    return _RecoveredAttachmentPlaceholder(
      cardKey: presentation.cardKey,
      title: presentation.placeholderTitle,
      body: presentation.placeholderBody,
      iconColor: colors.content.textSecondary,
      textStyle: typography.body,
    );
  }
}

class _RecoveredAttachmentSidebarPresentation {
  const _RecoveredAttachmentSidebarPresentation({
    required this.cardKey,
    required this.displayNamePath,
    required this.isResolving,
    required this.pathLabel,
    required this.pathValue,
    required this.placeholderBody,
    required this.placeholderTitle,
    required this.previewFile,
    required this.sourceLabel,
    required this.sourceTooltipMessage,
  });

  factory _RecoveredAttachmentSidebarPresentation.from({
    required AttachmentInfo attachment,
    required String? recordedPath,
    required AsyncValue<ResolvedAttachment>? resolvedAttachmentAsync,
  }) {
    final resolvedAttachment = resolvedAttachmentAsync?.valueOrNull;
    final resolvedFilePath = resolvedAttachment?.resolvedFilePath;
    final hasRecordedPath = recordedPath != null && recordedPath.isNotEmpty;
    final hasResolvedFile =
        resolvedFilePath != null && resolvedFilePath.isNotEmpty;
    final availability = resolvedAttachment?.availability;
    final provenance = resolvedAttachment?.provenance;

    return _RecoveredAttachmentSidebarPresentation(
      cardKey: _placeholderCardKey(
        attachment: attachment,
        availability: availability,
        hasRecordedPath: hasRecordedPath,
      ),
      displayNamePath: recordedPath ?? resolvedFilePath,
      isResolving: resolvedAttachmentAsync?.isLoading ?? false,
      pathLabel: _pathLabel(
        hasRecordedPath: hasRecordedPath,
        hasResolvedFile: hasResolvedFile,
        provenance: provenance,
      ),
      pathValue: hasResolvedFile ? resolvedFilePath : recordedPath,
      placeholderBody: _placeholderBody(
        attachment: attachment,
        availability: availability,
        hasRecordedPath: hasRecordedPath,
      ),
      placeholderTitle: _placeholderTitle(
        attachment: attachment,
        availability: availability,
        hasRecordedPath: hasRecordedPath,
      ),
      previewFile: hasResolvedFile ? File(resolvedFilePath) : null,
      sourceLabel: _sourceLabel(provenance),
      sourceTooltipMessage: _sourceTooltipMessage(provenance),
    );
  }

  final Key cardKey;
  final String? displayNamePath;
  final bool isResolving;
  final String? pathLabel;
  final String? pathValue;
  final String placeholderBody;
  final String placeholderTitle;
  final File? previewFile;
  final String? sourceLabel;
  final String? sourceTooltipMessage;

  static Key _placeholderCardKey({
    required AttachmentInfo attachment,
    required ResolvedAttachmentAvailability? availability,
    required bool hasRecordedPath,
  }) {
    if (attachment.isImage) {
      if (availability == null && !hasRecordedPath) {
        return const ValueKey<String>('recovered-placeholder-metadata-only');
      }

      return const ValueKey<String>('recovered-placeholder-image-unavailable');
    }

    if (attachment.isVideo) {
      return switch (availability) {
        ResolvedAttachmentAvailability.archiveUnavailable =>
          const ValueKey<String>(
            'recovered-placeholder-video-archive-unavailable',
          ),
        ResolvedAttachmentAvailability.pendingArchive => const ValueKey<String>(
          'recovered-placeholder-video-pending',
        ),
        ResolvedAttachmentAvailability.unavailableAwaitingRecovery =>
          const ValueKey<String>('recovered-placeholder-video-missing'),
        ResolvedAttachmentAvailability.nonRecoverable => const ValueKey<String>(
          'recovered-placeholder-video-unavailable',
        ),
        _ => const ValueKey<String>('recovered-placeholder-video-metadata'),
      };
    }

    return const ValueKey<String>('recovered-placeholder-metadata-only');
  }

  static String? _pathLabel({
    required bool hasRecordedPath,
    required bool hasResolvedFile,
    required AttachmentProvenance? provenance,
  }) {
    if (hasResolvedFile) {
      return switch (provenance) {
        AttachmentProvenance.archived => 'Archived file path',
        AttachmentProvenance.importedHistorical => 'Recovered backup path',
        _ => 'Recovered file path',
      };
    }

    if (hasRecordedPath) {
      return 'Recorded source path';
    }

    return null;
  }

  static String _placeholderTitle({
    required AttachmentInfo attachment,
    required ResolvedAttachmentAvailability? availability,
    required bool hasRecordedPath,
  }) {
    final mediaLabel = _mediaLabel(attachment);

    return switch (availability) {
      ResolvedAttachmentAvailability.archiveUnavailable =>
        '$mediaLabel archive unavailable',
      ResolvedAttachmentAvailability.pendingArchive =>
        '$mediaLabel being archived',
      ResolvedAttachmentAvailability.unavailableAwaitingRecovery =>
        hasRecordedPath
            ? '$mediaLabel no longer present'
            : '$mediaLabel awaiting recovery',
      ResolvedAttachmentAvailability.nonRecoverable =>
        '$mediaLabel unavailable',
      _ =>
        hasRecordedPath
            ? '$mediaLabel no longer present'
            : 'Attachment metadata only',
    };
  }

  static String _placeholderBody({
    required AttachmentInfo attachment,
    required ResolvedAttachmentAvailability? availability,
    required bool hasRecordedPath,
  }) {
    final mediaNoun = _mediaLabel(attachment).toLowerCase();

    return switch (availability) {
      ResolvedAttachmentAvailability.archiveUnavailable =>
        'The configured attachment archive is disconnected or unavailable. '
            'Reconnect it to determine whether this $mediaNoun is archived.',
      ResolvedAttachmentAvailability.pendingArchive =>
        'The original $mediaNoun file is present, but MessageLens is still adding it to the archive before showing it here.',
      ResolvedAttachmentAvailability.unavailableAwaitingRecovery =>
        hasRecordedPath
            ? 'This $mediaNoun is no longer present at the recorded Messages attachment path on this Mac. If an archived or backup copy becomes available, it will appear here.'
            : 'This $mediaNoun is not displayable yet, but MessageLens still has enough metadata to try recovery later.',
      ResolvedAttachmentAvailability.nonRecoverable =>
        'This $mediaNoun still has identifying metadata, but no displayable local or archived file is currently available.',
      _ =>
        hasRecordedPath
            ? 'This $mediaNoun is no longer present at the recorded Messages attachment path on this Mac.'
            : 'This recovered attachment still has identifying metadata, but no local file path survived into the current projection.',
    };
  }

  static String _mediaLabel(AttachmentInfo attachment) {
    if (attachment.isImage) {
      return 'Image';
    }
    if (attachment.isVideo) {
      return 'Video';
    }
    if (attachment.isUrlPreview) {
      return 'Link preview attachment';
    }
    return 'Attachment';
  }

  static String? _sourceLabel(AttachmentProvenance? provenance) {
    return switch (provenance) {
      AttachmentProvenance.messagesLive => 'Live',
      AttachmentProvenance.archived => 'Archive',
      AttachmentProvenance.importedHistorical => 'Backup',
      null => null,
    };
  }

  static String? _sourceTooltipMessage(AttachmentProvenance? provenance) {
    return switch (provenance) {
      AttachmentProvenance.messagesLive =>
        'Attachment source: Live Messages file',
      AttachmentProvenance.archived => 'Attachment source: MessageLens archive',
      AttachmentProvenance.importedHistorical =>
        'Attachment source: recovered backup archive',
      null => null,
    };
  }
}

class _RecoveredAttachmentSourceBadge extends ConsumerWidget {
  const _RecoveredAttachmentSourceBadge({
    required this.label,
    required this.tooltipMessage,
  });

  final String label;
  final String tooltipMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final isLive = label == 'Live';
    final isBackup = label == 'Backup';

    return Tooltip(
      message: tooltipMessage,
      waitDuration: const Duration(milliseconds: 300),
      child: DecoratedBox(
        key: ValueKey<String>('recovered-attachment-source-badge-$label'),
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
            style: ref
                .watch(themeTypographyProvider)
                .caption1
                .copyWith(
                  fontWeight: FontWeight.w700,
                  color: isLive || isBackup
                      ? colors.content.textSecondary
                      : colors.accents.primary,
                ),
          ),
        ),
      ),
    );
  }
}

class _RecoveredAttachmentPlaceholder extends ConsumerWidget {
  const _RecoveredAttachmentPlaceholder({
    required this.title,
    required this.body,
    this.cardKey,
    this.iconColor,
    this.textStyle,
  });

  final String title;
  final String body;
  final Key? cardKey;
  final Color? iconColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return Align(
      alignment: Alignment.centerLeft,
      widthFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 260),
        child: Container(
          key: cardKey,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surfaces.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.lines.borderSubtle, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.doc,
                color: iconColor ?? colors.content.textSecondary,
                size: 24,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                title,
                style: typography.body.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(body, style: textStyle ?? typography.body),
            ],
          ),
        ),
      ),
    );
  }
}
