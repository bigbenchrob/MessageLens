import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../features/chats/presentation/view/chats_sidebar_view.dart';
import '../../../../features/messages/feature_level_providers.dart';
import '../../../../features/settings/presentation/view/settings_panel_view.dart';
import '../../../db_importers/presentation/view/db_import_control_panel.dart';
import '../../../db_importers/presentation/view_model/db_import_control_provider.dart';

import '../../../workbench/presentation/view/workbench_panel_view.dart';
import '../../domain/entities/features/chats_spec.dart';
import '../../domain/entities/features/import_spec.dart';
import '../../domain/entities/panel_stack.dart';
import '../../domain/entities/view_spec.dart';
import '../../domain/navigation_constants.dart';
import '../../feature_level_providers.dart';
import '../view/panel_stack_surface.dart';

part 'panel_coordinator_provider.g.dart';

/// Coordinator that maps panel ViewSpecs to rendered widgets
@riverpod
class PanelCoordinator extends _$PanelCoordinator {
  @override
  void build() {
    ref.listen<Map<WindowPanel, PanelStack>>(panelsViewStateProvider, (
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
          .read(messagesCoordinatorProvider.notifier)
          .buildForSpec(messagesSpec),
      chats: (chatsSpec) {
        // All chat specs render via the sidebar treatment.
        return chatsSpec.when(
          list: () => ChatsSidebarView(spec: chatsSpec),
          forContact: (_) => ChatsSidebarView(spec: chatsSpec),
          recent: (_) => ChatsSidebarView(spec: chatsSpec),
          byAgeOldest: (_) => ChatsSidebarView(spec: chatsSpec),
          byAgeNewest: (_) => ChatsSidebarView(spec: chatsSpec),
          unmatched: (_) => ChatsSidebarView(spec: chatsSpec),
          forParticipant: (_) => ChatsSidebarView(spec: chatsSpec),
        );
      },
      contacts: (_) => _buildEmptyPanelPlaceholder(WindowPanel.center),
      import: _buildImportPanel,
      settings: (_) => const SettingsPanelView(),
      workbench: (_) => const WorkbenchPanelView(),
      sidebar: (sidebarSpec) {
        return _buildEmptyPanelPlaceholder(WindowPanel.center);
      },
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
    return Container(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_outlined, size: 48, color: Color(0xFFCCCCCC)),
          const SizedBox(height: 16),
          Text(
            '${panel.name.toUpperCase()} PANEL',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF999999).withValues(alpha: 0.8),
            ),
          ),
          const Text(
            'No content selected',
            style: TextStyle(fontSize: 12, color: Color(0xFFCCCCCC)),
          ),
        ],
      ),
    );
  }
}
