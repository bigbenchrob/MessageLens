import 'package:flutter/widgets.dart';

import '../../application/view_spec/payloads/settings_panel_render_descriptor.dart';
import '../../application/view_spec/resolvers/historical_archives_panel_resolver.dart';
import '../../application/view_spec/resolvers/message_history_coverage_report_panel_resolver.dart';
import '../view/attachment_archive_panel.dart';

/// Terminal Settings render edge for data-only panel descriptors.
final class SettingsPanelRenderRouter {
  const SettingsPanelRenderRouter();

  Widget build(SettingsPanelRenderDescriptor descriptor) {
    return switch (descriptor) {
      SettingsPanelRenderDescriptor.attachmentArchiveWorkflow =>
        const AttachmentArchivePanel(),
      SettingsPanelRenderDescriptor.historicalArchivesWorkflow =>
        HistoricalArchivesPanelResolver().resolve(),
      SettingsPanelRenderDescriptor.messageHistoryCoverageReport =>
        MessageHistoryCoverageReportPanelResolver().resolve(),
    };
  }
}
