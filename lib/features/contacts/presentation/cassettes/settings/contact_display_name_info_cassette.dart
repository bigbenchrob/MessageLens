import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/theme_typography.dart';

/// Info card explaining how to customize contact display names.
///
/// Shown in Settings → Contacts. Explains that name customization is done
/// from each contact's hero card rather than through global settings.
class ContactDisplayNameInfoCassette extends ConsumerWidget {
  const ContactDisplayNameInfoCassette({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.infoCard(InfoCard.background),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.infoCard(InfoCard.border), width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Contact Names', style: typography.infoCardTitle),
            const SizedBox(height: 8),
            Text(
              'Contact names are imported from your Contacts app. '
              "If the imported name isn't quite right, you can customize it.",
              style: typography.infoCardBody,
            ),
            const SizedBox(height: 12),
            Text(
              "To customize a contact's name:",
              style: typography.infoCardBody.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '1. Switch to Messages mode',
                    style: typography.infoCardBody,
                  ),
                  const SizedBox(height: 2),
                  Text('2. Select the contact', style: typography.infoCardBody),
                  const SizedBox(height: 2),
                  Text(
                    '3. Click "edit" on their hero card',
                    style: typography.infoCardBody,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your custom name will be used throughout the app.',
              style: typography.infoCardFootnote,
            ),
          ],
        ),
      ),
    );
  }
}
