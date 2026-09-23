import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/spec_classes/settings_view_spec.dart';
import '../payloads/settings_panel_render_descriptor.dart';

part 'view_spec_coordinator.g.dart';

@riverpod
class ViewSpecCoordinator extends _$ViewSpecCoordinator {
  @override
  void build() {
    // Stateless coordinator.
  }

  SettingsPanelRenderDescriptor resolveForSpec(SettingsViewSpec spec) {
    return spec.when(
      environmentSummary: () =>
          SettingsPanelRenderDescriptor.environmentSummary,
      attachmentArchiveWorkflow: () =>
          SettingsPanelRenderDescriptor.attachmentArchiveWorkflow,
      historicalArchivesWorkflow: () =>
          SettingsPanelRenderDescriptor.historicalArchivesWorkflow,
      messageHistoryCoverageReport: () =>
          SettingsPanelRenderDescriptor.messageHistoryCoverageReport,
    );
  }
}
