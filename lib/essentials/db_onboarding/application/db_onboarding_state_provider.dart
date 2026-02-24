import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/util/paths_helper.dart';
import '../../../providers.dart';
import '../../db_importers/domain/value_objects/db_import_stage.dart';
import '../domain/db_onboarding_phase.dart';
import '../domain/db_onboarding_state.dart';

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
    return DbOnboardingState.initial();
  }

  /// Start the onboarding flow.
  ///
  /// This checks FDA permissions first, then proceeds to locate databases.
  Future<void> startOnboarding() async {
    state = state.copyWith(currentPhase: DbOnboardingPhase.checkingPermissions);

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
