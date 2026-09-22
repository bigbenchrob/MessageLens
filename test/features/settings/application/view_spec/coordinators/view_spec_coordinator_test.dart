import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/features/environment_summary/presentation/view/environment_summary_panel.dart';
import 'package:remember_this_text/features/settings/application/view_spec/coordinators/view_spec_coordinator.dart';
import 'package:remember_this_text/features/settings/domain/spec_classes/settings_view_spec.dart';

void main() {
  test('environment spec resolves the Environment-owned center panel', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final widget = container
        .read(viewSpecCoordinatorProvider.notifier)
        .buildForSpec(const SettingsViewSpec.environmentSummary());

    expect(widget, isA<EnvironmentSummaryPanel>());
  });
}
