import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/features/environment_summary/presentation/view/environment_summary_panel.dart';
import 'package:remember_this_text/features/settings/application/view_spec/coordinators/view_spec_coordinator.dart';
import 'package:remember_this_text/features/settings/application/view_spec/payloads/settings_panel_render_descriptor.dart';
import 'package:remember_this_text/features/settings/domain/spec_classes/settings_view_spec.dart';
import 'package:remember_this_text/features/settings/presentation/rendering/settings_panel_render_router.dart';
import 'package:remember_this_text/features/settings/presentation/view/attachment_archive_panel.dart';

void main() {
  test('resolves Settings specs to data-only render descriptors', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final coordinator = container.read(viewSpecCoordinatorProvider.notifier);

    expect(
      coordinator.resolveForSpec(const SettingsViewSpec.environmentSummary()),
      SettingsPanelRenderDescriptor.environmentSummary,
    );
    expect(
      coordinator.resolveForSpec(
        const SettingsViewSpec.attachmentArchiveWorkflow(),
      ),
      SettingsPanelRenderDescriptor.attachmentArchiveWorkflow,
    );
    expect(
      coordinator.resolveForSpec(
        const SettingsViewSpec.historicalArchivesWorkflow(),
      ),
      SettingsPanelRenderDescriptor.historicalArchivesWorkflow,
    );
    expect(
      coordinator.resolveForSpec(
        const SettingsViewSpec.messageHistoryCoverageReport(),
      ),
      SettingsPanelRenderDescriptor.messageHistoryCoverageReport,
    );
  });

  test('terminal render edge constructs new Settings panels', () {
    const router = SettingsPanelRenderRouter();

    expect(
      router.build(SettingsPanelRenderDescriptor.environmentSummary),
      isA<EnvironmentSummaryPanel>(),
    );
    expect(
      router.build(SettingsPanelRenderDescriptor.attachmentArchiveWorkflow),
      isA<AttachmentArchivePanel>(),
    );
  });
}
