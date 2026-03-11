import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../../../essentials/onboarding/application/onboarding_gate_provider.dart';

/// A button that triggers a full reimport via the onboarding overlay.
///
/// Designed to sit inside a [SidebarInfoCard] as its `action` widget.
/// Tapping opens the full-window onboarding overlay with live progress,
/// summary metrics, and a "Done" dismiss button when complete.
class ReimportDataActionButton extends ConsumerWidget {
  const ReimportDataActionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return GestureDetector(
      onTap: () {
        ref.read(onboardingGateProvider.notifier).startReimport();
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.accents.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            'Start Import',
            style: typography.infoCardBody.copyWith(
              color: colors.accents.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
