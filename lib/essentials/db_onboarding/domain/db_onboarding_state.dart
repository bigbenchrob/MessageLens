import 'package:freezed_annotation/freezed_annotation.dart';

import 'db_onboarding_phase.dart';
import 'import_sub_stage.dart';

part 'db_onboarding_state.freezed.dart';

/// State representing the current progress of database onboarding.
///
/// This is a simplified, user-facing projection of the internal import/migration
/// progress. The [currentPhase] drives the stepper UI while boolean flags track
/// key milestones.
@freezed
abstract class DbOnboardingState with _$DbOnboardingState {
  const factory DbOnboardingState({
    /// The current phase being displayed in the stepper.
    required DbOnboardingPhase currentPhase,

    /// Whether Full Disk Access has been granted.
    required bool fdaGranted,

    /// Whether the Messages database (chat.db) was found.
    required bool messagesDbFound,

    /// Whether the Contacts database (AddressBook) was found.
    required bool contactsDbFound,

    /// Whether the import process has completed successfully.
    required bool importComplete,

    /// Whether onboarding is running in developer mode.
    ///
    /// When true, the fullscreen overlay is suppressed and progress
    /// is shown inline in the developer tools panel.
    @Default(false) bool devMode,

    /// Optional error message if the current phase is [DbOnboardingPhase.error].
    String? errorMessage,

    /// Optional progress percentage for the current phase (0.0 to 1.0).
    double? progressPercent,

    /// Current count for import progress (e.g., messages imported so far).
    int? importCurrent,

    /// Total count for import progress (e.g., total messages to import).
    int? importTotal,

    /// Human-readable description of current import activity.
    String? importStatusMessage,

    /// List of import sub-stages with their individual progress.
    ///
    /// These are the granular steps within a main phase (e.g., "Importing Messages"
    /// contains sub-stages like "Importing handles", "Importing chats", etc.)
    @Default(<ImportSubStage>[]) List<ImportSubStage> importSubStages,
  }) = _DbOnboardingState;

  /// Initial state for starting the onboarding flow.
  factory DbOnboardingState.initial() => const DbOnboardingState(
    currentPhase: DbOnboardingPhase.checkingPermissions,
    fdaGranted: false,
    messagesDbFound: false,
    contactsDbFound: false,
    importComplete: false,
  );
}
