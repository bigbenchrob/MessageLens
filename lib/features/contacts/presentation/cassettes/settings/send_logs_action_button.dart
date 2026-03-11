import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../../../essentials/logging/application/app_logger.dart';
import '../../../../../essentials/logging/infrastructure/log_export_service.dart';

/// A small button that triggers the log export + email compose flow.
///
/// Designed to sit inside a [SidebarInfoCard] as its `action` widget.
class SendLogsActionButton extends ConsumerWidget {
  const SendLogsActionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return GestureDetector(
      onTap: () {
        final writer = ref.read(appLoggerProvider.notifier).writer;
        LogExportService(writer).exportAndPresent();
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.accents.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            'Send Logs\u2026',
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
