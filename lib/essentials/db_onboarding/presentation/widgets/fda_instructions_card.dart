import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/theme/colors/theme_colors.dart';

/// Instructions for enabling Full Disk Access on macOS.
///
/// Shows step-by-step guide with a button to open System Settings.
class FdaInstructionsCard extends ConsumerWidget {
  const FdaInstructionsCard({
    required this.onRetry,
    super.key,
  });

  /// Called when user taps "Check Again" after enabling FDA.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaces.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.lines.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.lock_shield,
                size: 24,
                color: colors.accents.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Full Disk Access Required',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: colors.content.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'To import your messages, this app needs permission to read '
            'the Messages database on your Mac.',
            style: TextStyle(
              fontSize: 14,
              color: colors.content.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          _buildSteps(colors),
          const SizedBox(height: 24),
          Row(
            children: [
              CupertinoButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: colors.accents.primary,
                borderRadius: BorderRadius.circular(8),
                onPressed: _openSystemSettings,
                child: const Text(
                  'Open System Settings',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                onPressed: onRetry,
                child: Text(
                  'Check Again',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colors.accents.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSteps(ThemeColors colors) {
    const steps = [
      'Open System Settings → Privacy & Security',
      'Scroll down and click "Full Disk Access"',
      'Click the "+" button and add this app',
      'Enable the toggle next to the app',
      'Return here and click "Check Again"',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: colors.surfaces.control,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.content.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    steps[i],
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.content.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _openSystemSettings() async {
    // Opens Privacy & Security directly on macOS
    final uri = Uri.parse(
      'x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
