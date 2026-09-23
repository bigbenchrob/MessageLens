import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/spacing/app_spacing.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../application/attachment_showcase.dart';
import '../../application/attachment_showcase_source_provider.dart';

/// Presentation-only ambient preview of the latest sampled attachment.
class AttachmentShowcaseView extends ConsumerWidget {
  const AttachmentShowcaseView({super.key});

  static const previewKey = Key('attachment-showcase-preview');
  static const fallbackKey = Key('attachment-showcase-fallback');
  static const presentationAreaKey = Key(
    'attachment-showcase-presentation-area',
  );
  static const double previewHeight = 220;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final item = ref.watch(attachmentShowcaseSourceProvider);
    return SizedBox(
      key: presentationAreaKey,
      height: previewHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaces.control,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.lines.borderSubtle, width: 0.8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: item == null
                ? const _AttachmentShowcaseFallback(
                    key: fallbackKey,
                    label: 'Attachments will appear here as they are added.',
                  )
                : _AttachmentShowcaseItemView(
                    key: ValueKey(item.stablePresentationIdentity),
                    item: item,
                  ),
          ),
        ),
      ),
    );
  }
}

class _AttachmentShowcaseItemView extends StatelessWidget {
  const _AttachmentShowcaseItemView({required this.item, super.key});

  final AttachmentShowcaseItem item;

  @override
  Widget build(BuildContext context) {
    return switch (item.mediaKind) {
      AttachmentShowcaseMediaKind.image => Image.file(
        File(item.resolvedPath),
        key: AttachmentShowcaseView.previewKey,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
        cacheWidth: 960,
        cacheHeight: 540,
        errorBuilder: (context, error, stackTrace) =>
            const _AttachmentShowcaseFallback(
              key: AttachmentShowcaseView.fallbackKey,
              label: 'Preview unavailable',
            ),
      ),
      AttachmentShowcaseMediaKind.video => const _AttachmentShowcaseFallback(
        key: AttachmentShowcaseView.fallbackKey,
        icon: CupertinoIcons.video_camera,
        label: 'Video attachment added',
      ),
      AttachmentShowcaseMediaKind.pdf => const _AttachmentShowcaseFallback(
        key: AttachmentShowcaseView.fallbackKey,
        icon: CupertinoIcons.doc_text,
        label: 'PDF attachment added',
      ),
      AttachmentShowcaseMediaKind.other => const _AttachmentShowcaseFallback(
        key: AttachmentShowcaseView.fallbackKey,
        label: 'Attachment added',
      ),
    };
  }
}

class _AttachmentShowcaseFallback extends ConsumerWidget {
  const _AttachmentShowcaseFallback({
    required this.label,
    this.icon = CupertinoIcons.photo,
    super.key,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: colors.content.iconSecondary, size: 34),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              textAlign: TextAlign.center,
              style: typography.body.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
