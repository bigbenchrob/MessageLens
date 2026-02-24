import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../navigation/domain/entities/features/db_setup_spec.dart';
import '../../presentation/view/db_onboarding_panel.dart';

part 'db_setup_spec_coordinator.g.dart';

/// Coordinates ViewSpec.dbSetup requests to the appropriate panel widget.
@riverpod
class DbSetupSpecCoordinator extends _$DbSetupSpecCoordinator {
  @override
  void build() {
    // No-op initialization
  }

  /// Build the panel widget for the given [DbSetupSpec].
  Widget buildForSpec(DbSetupSpec spec) {
    return spec.when(
      firstRun: () => const DbOnboardingPanel(
        key: ValueKey('db-onboarding-first-run'),
      ),
      rerunImport: () => const DbOnboardingPanel(
        key: ValueKey('db-onboarding-rerun'),
      ),
    );
  }
}
