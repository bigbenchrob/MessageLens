import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart' show ProgressCircle;

import '../../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../../config/theme/theme_typography.dart';

/// Widget displayed while the folder aggregate is loading
class FolderAggregateLoadingWidget extends ConsumerWidget {
  const FolderAggregateLoadingWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = ref.watch(themeTypographyProvider);
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const ProgressCircle(radius: 20),
          const SizedBox(height: 16),
          Text('Loading Address Book Folders...', style: typography.title3),
          const SizedBox(height: 8),
          Text(
            'Scanning for AddressBook databases',
            style: typography.body.copyWith(
              color: colors.content.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
