import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/features/settings/application/view_spec/coordinators/view_spec_coordinator.dart';
import 'package:remember_this_text/features/settings/application/view_spec/payloads/settings_panel_render_descriptor.dart';
import 'package:remember_this_text/features/settings/domain/spec_classes/settings_view_spec.dart';

void main() {
  test('resolves Settings specs to data-only render descriptors', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final coordinator = container.read(viewSpecCoordinatorProvider.notifier);

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
}
