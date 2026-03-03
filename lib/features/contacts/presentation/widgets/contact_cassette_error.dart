import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart' show ControlSize, PushButton;

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme_typography.dart';

class ContactCassetteError extends ConsumerWidget {
  const ContactCassetteError({
    required this.onRetry,
    required this.message,
    super.key,
  });

  final VoidCallback onRetry;
  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = ref.watch(themeTypographyProvider);
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              CupertinoIcons.exclamationmark_triangle,
              color: colors.accents.secondary,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Unable to load contacts',
                style: typography.caption1.copyWith(
                  color: colors.accents.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            PushButton(
              controlSize: ControlSize.small,
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          message,
          style: typography.caption2.copyWith(
            color: colors.content.textSecondary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
