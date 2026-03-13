import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../features/messages/feature_level_providers.dart'
    as messages_feature;
import '../../db_importers/presentation/view/db_import_control_panel.dart';
import '../../db_importers/presentation/view_model/db_import_control_provider.dart';
import '../../onboarding/domain/import_spec.dart';
import '../../onboarding/presentation/onboarding_dev_panel.dart';
import '../domain/entities/panel_stack.dart';
import '../domain/entities/view_spec.dart';
import '../domain/navigation_constants.dart';
import '../domain/sidebar_mode.dart';
import '../feature_level_providers.dart';
import '../presentation/view/panel_stack_surface.dart';

part 'panel_coordinator_provider.g.dart';

/// Coordinator that maps panel ViewSpecs to rendered widgets
@riverpod
class PanelCoordinator extends _$PanelCoordinator {
  @override
  void build(SidebarMode mode) {
    ref.listen<Map<WindowPanel, PanelStack>>(panelsViewStateProvider(mode), (
      previous,
      next,
    ) {
      final nextStack = next[WindowPanel.center];
      final nextSpec = nextStack?.activePage?.spec;
      if (nextSpec == null) {
        return;
      }

      nextSpec.maybeWhen(
        import: (importSpec) {
          _syncImportPanelMode(importSpec);
        },
        orElse: () {
          // No-op for other specs.
        },
      );
    });
  }

  Widget buildPanelSurface(WindowPanel panel, PanelStack stack) {
    return PanelStackSurface(
      panel: panel,
      stack: stack,
      buildPanel: buildForPage,
      placeholder: _buildEmptyPanelPlaceholder(panel),
    );
  }

  Widget buildForPage(PanelPage page) {
    return buildForSpec(page.spec);
  }

  Widget buildForSpec(ViewSpec spec) {
    return spec.when(
      messages: (messagesSpec) => ref
          .read(messages_feature.viewSpecCoordinatorProvider.notifier)
          .buildForSpec(messagesSpec),
      import: _buildImportPanel,
      onboarding: (_) => const OnboardingDevPanel(),
    );
  }

  Widget _buildImportPanel(ImportSpec spec) {
    // Listener established in build() keeps the control view model in sync.
    final panelKey = spec.when(
      forImport: () => const ValueKey('import-mode'),
      forMigration: () => const ValueKey('migration-mode'),
    );
    return DbImportControlPanel(key: panelKey);
  }

  void _syncImportPanelMode(ImportSpec spec) {
    final desiredMode = spec.when(
      forImport: () => DbImportMode.import,
      forMigration: () => DbImportMode.migration,
    );

    final controlState = ref.read(dbImportControlViewModelProvider);
    if (controlState.selectedMode == desiredMode) {
      return;
    }

    ref.read(dbImportControlViewModelProvider.notifier).setMode(desiredMode);
  }

  /// Placeholder for empty panels
  Widget _buildEmptyPanelPlaceholder(WindowPanel panel) {
    return const SizedBox.shrink();
  }
}
