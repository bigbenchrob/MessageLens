// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../../config/theme/theme_typography.dart';
import '../../../../domain/entities/address_book_folder_aggregate.dart';

/// Widget displayed when folder aggregate loads successfully
class FolderAggregateDataWidget extends ConsumerWidget {
  final AddressBookFolderAggregate aggregate;

  const FolderAggregateDataWidget({super.key, required this.aggregate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = ref.watch(themeTypographyProvider);
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 48, color: Colors.green),
            const SizedBox(height: 16),
            Text('Address Book Loaded Successfully!', style: typography.title2),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'Found ${aggregate.folders.length} address book folder(s)',
                    style: typography.body,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  if (aggregate.folders.isNotEmpty)
                    Text(
                      'Ready to browse ${aggregate.folders.length} folder(s)',
                      style: typography.body.copyWith(
                        color: colors.content.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Ready to browse contacts!', style: typography.headline),
            const SizedBox(height: 32),
            // Navigation buttons to demonstrate go_router
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => context.push('/contacts'),
                  icon: const Icon(Icons.contacts),
                  label: const Text('View Contacts'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // Example of programmatic navigation
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Staying on folders screen'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Click "View Contacts" to navigate to the contacts screen',
              style: typography.body.copyWith(
                color: colors.content.textTertiary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
