import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/spec_classes/settings_view_spec.dart';
import '../resolvers/attachment_archive_panel_resolver.dart';
import '../resolvers/historical_archives_panel_resolver.dart';
import '../resolvers/message_history_coverage_report_panel_resolver.dart';

part 'view_spec_coordinator.g.dart';

@riverpod
class ViewSpecCoordinator extends _$ViewSpecCoordinator {
  @override
  void build() {
    // Stateless coordinator.
  }

  Widget buildForSpec(SettingsViewSpec spec) {
    return spec.when(
      attachmentArchiveWorkflow: () =>
          AttachmentArchivePanelResolver().resolve(),
      historicalArchivesWorkflow: () =>
          HistoricalArchivesPanelResolver().resolve(),
      messageHistoryCoverageReport: () =>
          MessageHistoryCoverageReportPanelResolver().resolve(),
    );
  }
}
