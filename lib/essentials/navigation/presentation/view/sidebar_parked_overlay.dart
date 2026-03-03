import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/spacing/app_spacing.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../application/panels_view_state_provider.dart';
import '../../domain/entities/features/import_spec.dart';
import '../../domain/entities/panel_stack.dart';
import '../../domain/entities/view_spec.dart';
import '../../domain/navigation_constants.dart';
import '../../domain/sidebar_mode.dart';
import '../../feature_level_providers.dart';

/// Overlay displayed in the sidebar when the center panel is showing
/// content that operates independently of the cassette rack (e.g.
/// import/migration controls, workbench).
///
/// Provides a prominent Cancel button so the user can dismiss the
/// center panel operation and return to normal sidebar navigation.
class SidebarParkedOverlay extends ConsumerWidget {
  const SidebarParkedOverlay({super.key, required this.mode});

  final SidebarMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    final stack = ref.watch(
      panelsViewStateProvider(mode).select(
        (stacks) => stacks[WindowPanel.center] ?? const PanelStack.empty(),
      ),
    );
    final spec = stack.activePage?.spec;
    final label = _labelForSpec(spec);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        children: [
          const Spacer(),
          Icon(
            _iconForSpec(spec),
            size: 48,
            color: colors.content.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            label,
            style: typography.cassetteCardTitle.copyWith(
              color: colors.content.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'The sidebar is unavailable while\nthis operation is active.',
            style: typography.cassetteCardSubtitle.copyWith(
              color: colors.content.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton.filled(
              onPressed: () => _dismiss(ref),
              child: const Text('Cancel'),
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  void _dismiss(WidgetRef ref) {
    ref
        .read(panelsViewStateProvider(mode).notifier)
        .clear(panel: WindowPanel.center);
  }

  static String _labelForSpec(ViewSpec? spec) {
    if (spec == null) {
      return 'Operation in Progress';
    }
    return spec.when(
      import: (importSpec) => importSpec.maybeWhen(
        forImport: () => 'Database Import',
        forMigration: () => 'Database Migration',
        orElse: () => 'Database Operation',
      ),
      workbench: (_) => 'Developer Workbench',
      messages: (_) => 'Operation in Progress',
      chats: (_) => 'Operation in Progress',
      contacts: (_) => 'Operation in Progress',
      settings: (_) => 'Operation in Progress',
    );
  }

  static IconData _iconForSpec(ViewSpec? spec) {
    if (spec == null) {
      return CupertinoIcons.gear_alt;
    }
    return spec.when(
      import: (_) => CupertinoIcons.square_arrow_down,
      workbench: (_) => CupertinoIcons.hammer,
      messages: (_) => CupertinoIcons.gear_alt,
      chats: (_) => CupertinoIcons.gear_alt,
      contacts: (_) => CupertinoIcons.gear_alt,
      settings: (_) => CupertinoIcons.gear_alt,
    );
  }
}
