import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/util/paths_helper.dart';
import '../../../providers.dart';
import '../../db_importers/domain/value_objects/db_import_stage.dart';
import '../../db_importers/presentation/view_model/db_import_control_provider.dart';
import '../domain/db_onboarding_phase.dart';
import '../domain/db_onboarding_state.dart';
import '../domain/import_sub_stage.dart';

part 'db_onboarding_state_provider.g.dart';

/// Manages the onboarding state machine and coordinates with import/migration.
///
/// This provider maps the detailed internal import and migration stages to
/// user-friendly phases displayed in the stepper UI.
@Riverpod(keepAlive: true)
class DbOnboardingStateNotifier extends _$DbOnboardingStateNotifier {
  PathsHelper? _pathsHelper;

  @override
  DbOnboardingState build() {
    // Listen to import control state changes and update onboarding phases
    ref.listen<DbImportControlState>(
      dbImportControlViewModelProvider,
      (previous, next) => _handleImportControlChange(previous, next),
    );

    return DbOnboardingState.initial();
  }

  /// React to import/migration control state changes.
  void _handleImportControlChange(
    DbImportControlState? previous,
    DbImportControlState next,
  ) {
    // Only update if onboarding is active (not complete, not error)
    if (state.currentPhase == DbOnboardingPhase.complete ||
        state.currentPhase == DbOnboardingPhase.error) {
      return;
    }

    // Convert UiStageProgress list to ImportSubStage list
    final subStages = next.stages
        .map(
          (s) => ImportSubStage(
            key: s.name,
            label: s.displayName,
            sortIndex: s.sortIndex,
            isActive: s.isActive,
            isComplete: s.isComplete,
            progress: s.progress,
            current: s.current,
            total: s.total,
          ),
        )
        .toList();

    // Update progress percentage and status message
    state = state.copyWith(
      progressPercent: next.progress,
      importStatusMessage: next.statusMessage,
      importSubStages: subStages,
    );

    // Extract current/total from the active stage in stages list
    final activeStage = next.stages.where((s) => s.isActive).firstOrNull;
    if (activeStage != null) {
      state = state.copyWith(
        importCurrent: activeStage.current,
        importTotal: activeStage.total,
        progressPercent: activeStage.progress ?? state.progressPercent,
      );
    }

    // Map current stage to onboarding phase
    final stageName = next.currentStage;
    if (stageName == null) {
      return;
    }

    // Try to find matching import stage
    final importStage = DbImportStage.values
        .where((s) => s.key == stageName)
        .firstOrNull;

    if (importStage != null) {
      updateFromImportStage(importStage);
    }

    // Handle completion state
    final lastImport = next.lastImportResult;
    final lastMigration = next.lastMigrationResult;

    if (lastMigration?.success == true) {
      markComplete();
    } else if (lastImport?.success == false) {
      setError(lastImport?.error ?? 'Import failed');
    } else if (lastMigration?.success == false) {
      setError(lastMigration?.error ?? 'Migration failed');
    }
  }

  /// Start the onboarding flow.
  ///
  /// This checks FDA permissions first, then proceeds to locate databases.
  Future<void> startOnboarding({bool devMode = false}) async {
    state = state.copyWith(
      currentPhase: DbOnboardingPhase.checkingPermissions,
      devMode: devMode,
    );

    // Check FDA by attempting to stat the chat.db file
    final fdaGranted = await _checkFullDiskAccess();
    state = state.copyWith(fdaGranted: fdaGranted);

    if (!fdaGranted) {
      // Stay on checkingPermissions phase - UI will show instructions
      return;
    }

    // FDA granted, proceed to locate messages
    await _proceedToLocateMessages();
  }

  /// Reset to initial state, optionally preserving dev mode.
  void resetState({bool preserveDevMode = false}) {
    final wasDevMode = state.devMode;
    state = DbOnboardingState.initial();
    if (preserveDevMode && wasDevMode) {
      state = state.copyWith(devMode: true);
    }
  }

  /// Retry after FDA instructions.
  Future<void> retryFdaCheck() async {
    state = state.copyWith(
      currentPhase: DbOnboardingPhase.checkingPermissions,
      errorMessage: null,
    );

    final fdaGranted = await _checkFullDiskAccess();
    state = state.copyWith(fdaGranted: fdaGranted);

    if (fdaGranted) {
      await _proceedToLocateMessages();
    }
  }

  /// Retry after an error.
  Future<void> retry() async {
    state = state.copyWith(errorMessage: null);
    await startOnboarding();
  }

  /// Mark setup as complete and transition to normal app state.
  void markComplete() {
    state = state.copyWith(
      currentPhase: DbOnboardingPhase.complete,
      importComplete: true,
    );
  }

  /// Set an error state.
  void setError(String message) {
    state = state.copyWith(
      currentPhase: DbOnboardingPhase.error,
      errorMessage: message,
    );
  }

  /// Update the current phase based on import progress.
  ///
  /// Called by the import system to update onboarding UI.
  void updateFromImportStage(DbImportStage stage) {
    final phase = _mapImportStageToPhase(stage);
    if (phase != null) {
      state = state.copyWith(currentPhase: phase);
    }

    // Check for contacts-related stages
    if (stage == DbImportStage.importingAddressBook) {
      state = state.copyWith(
        currentPhase: DbOnboardingPhase.locatingContacts,
        contactsDbFound: true,
      );
    }

    if (stage == DbImportStage.linkingContacts) {
      state = state.copyWith(currentPhase: DbOnboardingPhase.linkingContacts);
    }
  }

  /// Update progress percentage.
  void updateProgress(double progress) {
    state = state.copyWith(progressPercent: progress);
  }

  Future<bool> _checkFullDiskAccess() async {
    try {
      _pathsHelper ??= await ref.read(pathsHelperProvider.future);
      final chatDbPath = _pathsHelper!.chatDBPath;
      final file = File(chatDbPath);

      // Try to stat the file - this will fail if FDA is not granted
      file.statSync();
      return true;
    } on FileSystemException {
      // Permission denied
      return false;
    } catch (e) {
      // Other error - treat as FDA issue
      return false;
    }
  }

  Future<void> _proceedToLocateMessages() async {
    state = state.copyWith(currentPhase: DbOnboardingPhase.locatingMessages);

    try {
      _pathsHelper ??= await ref.read(pathsHelperProvider.future);
      final chatDbPath = _pathsHelper!.chatDBPath;
      final file = File(chatDbPath);

      if (file.existsSync()) {
        state = state.copyWith(
          currentPhase: DbOnboardingPhase.messagesFound,
          messagesDbFound: true,
        );

        // Brief pause to show "found" state
        await Future<void>.delayed(const Duration(milliseconds: 500));

        // Proceed to import phase
        state = state.copyWith(
          currentPhase: DbOnboardingPhase.importingMessages,
        );

        // Actually trigger the import and migration pipeline
        ref
            .read(dbImportControlViewModelProvider.notifier)
            .runImportAndMigration();
      } else {
        setError('Messages database not found at expected location.');
      }
    } catch (e) {
      setError('Failed to locate Messages database: $e');
    }
  }

  DbOnboardingPhase? _mapImportStageToPhase(DbImportStage stage) {
    return switch (stage) {
      DbImportStage.preparingSources => DbOnboardingPhase.locatingMessages,
      DbImportStage.clearingLedger => DbOnboardingPhase.importingMessages,
      DbImportStage.importingHandles => DbOnboardingPhase.importingMessages,
      DbImportStage.importingChats => DbOnboardingPhase.importingMessages,
      DbImportStage.importingParticipants =>
        DbOnboardingPhase.importingMessages,
      DbImportStage.importingMessages => DbOnboardingPhase.importingMessages,
      DbImportStage.extractingRichContent =>
        DbOnboardingPhase.importingMessages,
      DbImportStage.importingAttachments => DbOnboardingPhase.importingMessages,
      DbImportStage.linkingMessageArtifacts =>
        DbOnboardingPhase.importingMessages,
      DbImportStage.importingAddressBook => DbOnboardingPhase.locatingContacts,
      DbImportStage.linkingContacts => DbOnboardingPhase.linkingContacts,
      DbImportStage.completed => null, // Wait for migration
    };
  }
}
