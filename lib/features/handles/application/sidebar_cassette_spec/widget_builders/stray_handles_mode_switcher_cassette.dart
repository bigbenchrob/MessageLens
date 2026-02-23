import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../../config/theme/theme_typography.dart';
import '../../../../../../essentials/sidebar/domain/entities/features/handles_cassette_spec.dart';
import '../../state/stray_handle_mode_provider.dart';

/// A macOS-style popup menu for filtering stray handles by mode.
///
/// This cassette reads and writes to [strayHandleModeSettingProvider], which
/// the list cassette watches to determine which handles to display.
///
/// Visually quieter than the primary segmented control, acting as a
/// secondary filter rather than primary navigation.
class StrayHandlesModeSwitcherCassette extends ConsumerWidget {
  const StrayHandlesModeSwitcherCassette({required this.filter, super.key});

  final StrayHandleFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final currentMode = ref.watch(strayHandleModeSettingProvider);

    // Spacing constants:
    // - 20pt from segmented control above (contributes with type switcher bottom)
    // - 6pt between "Show:" label and popup (horizontal)
    // - 24pt to section header below (16pt here + 4pt wrapper + 4pt from review card)
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // "Show:" label - secondary color, normal weight to de-emphasize
          Text(
            'Show:',
            style: typography.caption.copyWith(
              color: colors.content.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 6), // 6pt label-to-popup spacing
          // Popup button
          MacosPopupButton<StrayHandleMode>(
            value: currentMode,
            onChanged: (mode) {
              if (mode != null) {
                ref.read(strayHandleModeSettingProvider.notifier).setMode(mode);
              }
            },
            items: const [
              MacosPopupMenuItem<StrayHandleMode>(
                value: StrayHandleMode.allStrays,
                child: Text('All'),
              ),
              MacosPopupMenuItem<StrayHandleMode>(
                value: StrayHandleMode.spamCandidates,
                child: Text('Spam'),
              ),
              MacosPopupMenuItem<StrayHandleMode>(
                value: StrayHandleMode.dismissed,
                child: Text('Dismissed'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
