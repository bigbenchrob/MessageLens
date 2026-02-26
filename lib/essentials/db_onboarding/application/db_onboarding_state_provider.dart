import 'dart:async';
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

/// Minimum duration a phase should be visible before transitioning.
/// This ensures users can read the phase labels without them flashing by.
const _minPhaseDuration = Duration(seconds: 1);

/// Manages the onboarding state machine and coordinates with import/migration.
///
/// This provider maps the detailed internal import and migration stages to
/// user-friendly phases displayed in the stepper UI.
@Riverpod(keepAlive: true)
class DbOnboardingStateNotifier extends _$DbOnboardingStateNotifier {
  PathsHelper? _pathsHelper;

  /// Timestamp when the current phase became active.
  DateTime _phaseStartTime = DateTime.now();

  /// Queue of phases waiting to be displayed.
  /// Each phase is shown for at least [_minPhaseDuration] before the next.
  final List<DbOnboardingPhase> _phaseQueue = [];

  /// Timer for processing the next phase in the queue.
  Timer? _phaseTimer;

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
    // Initialize phase timing and clear any pending transitions
    _phaseStartTime = DateTime.now();
    _phaseTimer?.cancel();
    _phaseTimer = null;
    _phaseQueue.clear();

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
    // Cancel any pending phase transitions
    _phaseTimer?.cancel();
    _phaseTimer = null;
    _phaseQueue.clear();
    _phaseStartTime = DateTime.now();

    final wasDevMode = state.devMode;
    // Single atomic state update to avoid race conditions
    // (shell watches this state and shows overlay if devMode briefly becomes false)
    var newState = DbOnboardingState.initial();
    if (preserveDevMode && wasDevMode) {
      newState = newState.copyWith(devMode: true);
    }
    state = newState;
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
    _transitionToPhase(DbOnboardingPhase.complete);
    // Also mark importComplete flag (may happen before or after phase transition)
    state = state.copyWith(importComplete: true);
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
      _transitionToPhase(phase);
    }

    // Update contacts flag when we reach the contacts phase
    if (stage == DbImportStage.importingAddressBook) {
      state = state.copyWith(contactsDbFound: true);
    }
  }

  /// Transition to a new phase, enforcing minimum display duration.
  ///
  /// Each phase is displayed for at least [_minPhaseDuration] so users can
  /// read the labels. Phases are queued and processed sequentially - no phase
  /// is skipped even if multiple transitions are requested quickly.
  void _transitionToPhase(DbOnboardingPhase newPhase) {
    // Don't queue the same phase twice in a row
    final lastQueued = _phaseQueue.isNotEmpty ? _phaseQueue.last : state.currentPhase;
    if (newPhase == lastQueued) {
      return;
    }

    // Add to queue
    _phaseQueue.add(newPhase);

    // Start processing if not already running
    _scheduleNextPhaseTransition();
  }

  /// Schedule the next phase transition from the queue.
  void _scheduleNextPhaseTransition() {
    // Don't schedule if timer already running or queue empty
    if (_phaseTimer != null || _phaseQueue.isEmpty) {
      return;
    }

    // Skip throttling for the very first transition (from checkingPermissions)
    if (state.currentPhase == DbOnboardingPhase.checkingPermissions) {
      _executeNextPhaseTransition();
      return;
    }

    final elapsed = DateTime.now().difference(_phaseStartTime);
    final remaining = _minPhaseDuration - elapsed;

    if (remaining <= Duration.zero) {
      // Enough time has passed, transition immediately
      _executeNextPhaseTransition();
    } else {
      // Wait for minimum duration before transitioning
      _phaseTimer = Timer(remaining, _executeNextPhaseTransition);
    }
  }

  /// Execute the next phase transition from the queue.
  void _executeNextPhaseTransition() {
    _phaseTimer?.cancel();
    _phaseTimer = null;

    if (_phaseQueue.isEmpty) {
      return;
    }

    final nextPhase = _phaseQueue.removeAt(0);
    _phaseStartTime = DateTime.now();
    state = state.copyWith(currentPhase: nextPhase);

    // Continue processing queue if more phases are waiting
    if (_phaseQueue.isNotEmpty) {
      _scheduleNextPhaseTransition();
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
    _transitionToPhase(DbOnboardingPhase.messagesDatabase);

    try {
      _pathsHelper ??= await ref.read(pathsHelperProvider.future);
      final chatDbPath = _pathsHelper!.chatDBPath;
      final file = File(chatDbPath);

      if (file.existsSync()) {
        state = state.copyWith(messagesDbFound: true);

        // Brief pause to show "found" state before proceeding
        await Future<void>.delayed(const Duration(milliseconds: 300));

        // Proceed to conversation metadata phase
        _transitionToPhase(DbOnboardingPhase.conversationMetadata);

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
      DbImportStage.preparingSources => DbOnboardingPhase.messagesDatabase,
      DbImportStage.clearingLedger => DbOnboardingPhase.conversationMetadata,
      DbImportStage.importingHandles => DbOnboardingPhase.conversationMetadata,
      DbImportStage.importingChats => DbOnboardingPhase.conversationMetadata,
      DbImportStage.importingParticipants =>
        DbOnboardingPhase.conversationMetadata,
      DbImportStage.importingMessages => DbOnboardingPhase.importingMessages,
      DbImportStage.extractingRichContent =>
        DbOnboardingPhase.processingContent,
      DbImportStage.importingAttachments =>
        DbOnboardingPhase.importingAttachments,
      DbImportStage.linkingMessageArtifacts =>
        DbOnboardingPhase.importingAttachments,
      DbImportStage.importingAddressBook => DbOnboardingPhase.contactsDatabase,
      DbImportStage.linkingContacts => DbOnboardingPhase.contactsDatabase,
      DbImportStage.completed => null, // Wait for migration
    };
  }
}
