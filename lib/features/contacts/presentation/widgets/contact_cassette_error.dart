import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../config/theme/theme.dart';

class ContactCassetteError extends StatelessWidget {
  const ContactCassetteError({
    required this.onRetry,
    required this.message,
    super.key,
  });

  final VoidCallback onRetry;
  final String message;

  @override
  Widget build(BuildContext context) {
    final typography = MacosTheme.of(context).typography;
    final bbc = AppTheme.bbc(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_triangle,
              color: MacosColors.systemRedColor,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Unable to load contacts',
                style: typography.caption1.copyWith(
                  color: MacosColors.systemRedColor,
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
          style: typography.caption2.copyWith(color: bbc.bbcSubheadText),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
