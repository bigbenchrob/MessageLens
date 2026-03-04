import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../db/feature_level_providers.dart' show databaseDirectoryPath;
import '../../db_importers/presentation/view_model/db_import_control_provider.dart';
import '../domain/onboarding_status.dart';
import 'database_existence_checker.dart';

part 'onboarding_gate_provider.g.dart';

/// Controls the onboarding overlay lifecycle.
///
/// On [build], checks whether both import and working databases exist with data.
/// If not, exposes [OnboardingStatus.awaitingUserAction] so the overlay appears.
///
/// [startImportAndMigration] delegates to [DbImportControlViewModel] and
/// watches its state to transition through importing → migrating → complete.
@Riverpod(keepAlive: true)
class OnboardingGate extends _$OnboardingGate {
  static const _checker = DatabaseExistenceChecker();

  @override
  OnboardingStatus build() {
    final hasData = _checker.hasPopulatedDatabases(databaseDirectoryPath);
    if (hasData) {
      return OnboardingStatus.notNeeded;
    }
    return OnboardingStatus.awaitingUserAction;
  }

  /// Kick off the full import + migration pipeline.
  ///
  /// Transitions: awaitingUserAction → importing → migrating → complete.
  /// Delegates all real work to [DbImportControlViewModel.runImportAndMigration].
  Future<void> startImportAndMigration() async {
    if (state != OnboardingStatus.awaitingUserAction) {
      return;
    }

    state = OnboardingStatus.importing;

    final controller = ref.read(dbImportControlViewModelProvider.notifier);
    await controller.runImportAndMigration();

    // After the pipeline completes, check if both succeeded.
    final controlState = ref.read(dbImportControlViewModelProvider);
    final importOk = controlState.lastImportResult?.success ?? false;
    final migrationOk = controlState.lastMigrationResult?.success ?? false;

    if (importOk && migrationOk) {
      state = OnboardingStatus.complete;
    }
    // On failure, stay at current status — V1 does not handle errors.
  }

  /// Dismiss the overlay after the user taps "Get Started".
  void dismiss() {
    state = OnboardingStatus.notNeeded;
  }
}
