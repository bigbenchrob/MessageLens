import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../../../config/theme/widgets/theme_widgets.dart';
import '../../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../../essentials/sidebar/feature_level_providers.dart';
import '../../../domain/sidebar_utilities_constants.dart';

/// Top Chat Menu Widget Builder
///
/// A dumb widget that:
/// - Receives fully-decided inputs (no specs)
/// - Assembles the dropdown menu UI
/// - On user interaction, constructs a new spec and updates the rack
///
/// This widget MAY call ref.watch() for theme/styling providers.
/// This widget MAY construct specs as OUTPUT when responding to user interaction.
/// This widget MUST NOT interpret specs to decide what to render.
///
/// See: _AGENT_INSTRUCTIONS/agent-per-project/90-CROSS-SURFACE-SPEC-SYSTEMS/00-cross-surface-spec-system.md
class TopChatMenuWidget extends ConsumerWidget {
  /// The currently selected menu choice.
  final TopChatMenuChoice currentChoice;

  /// The index of this cassette in the rack.
  /// Used to update the rack without holding specs in state.
  final int cassetteIndex;

  /// The sidebar mode (messages/settings).
  final SidebarMode sidebarMode;

  const TopChatMenuWidget({
    super.key,
    required this.currentChoice,
    required this.cassetteIndex,
    required this.sidebarMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const choices = TopChatMenuChoice.values;

    // Theme providers - watch state for brightness rebuilds, read notifier for API
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    void handleSelectionChange(TopChatMenuChoice newChoice) {
      // Construct the new spec locally - this is OUTPUT, not interpretation
      final newSpec = CassetteSpec.sidebarUtility(
        SidebarUtilityCassetteSpec.topChatMenu(selectedChoice: newChoice),
      );

      // Update the rack using index-based method (no need to hold old spec)
      ref
          .read(cassetteRackStateProvider(sidebarMode).notifier)
          .replaceAtIndexAndCascade(cassetteIndex, newSpec);
    }

    return AppThemeWidgets.dropdownMenu<TopChatMenuChoice>(
      options: choices,
      selectedOption: currentChoice,
      onSelected: handleSelectionChange,
      optionLabelBuilder: (choice) => choice.label,
      // Naked card wrapper provides 12px horizontal margin
      outerPadding: EdgeInsets.zero,
      // Match card internal padding: 12px left for text alignment
      triggerPadding: const EdgeInsets.only(
        left: 12.0,
        right: 16.0,
        top: 10.0,
        bottom: 10.0,
      ),
      // Typography tokens for control header hierarchy:
      // - controlValue for selected option (confident, primary)
      // - Brand-tinted chevron background for intentional feel
      selectedValueStyle: typography.controlValue,
      chevronColor: colors.accents.primary,
      chevronBackgroundColor: colors.accents.primary.withValues(alpha: 0.12),
    );
  }
}
