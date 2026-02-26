import 'package:freezed_annotation/freezed_annotation.dart';

part 'db_setup_spec.freezed.dart';

/// Specification for database setup/onboarding views.
///
/// Used by [ViewSpec.dbSetup] to determine which setup UI to display.
@freezed
abstract class DbSetupSpec with _$DbSetupSpec {
  /// Initial first-run setup flow.
  ///
  /// Shown automatically when app detects empty working database.
  const factory DbSetupSpec.firstRun() = _DbSetupFirstRun;

  /// Manual re-run of import process.
  ///
  /// Available via Settings or debug menu for re-importing data.
  const factory DbSetupSpec.rerunImport() = _DbSetupRerunImport;

  /// Developer tools panel for testing onboarding.
  ///
  /// Provides controls to delete database files and trigger onboarding
  /// without restarting the app.
  const factory DbSetupSpec.developerTools() = _DbSetupDeveloperTools;
}
