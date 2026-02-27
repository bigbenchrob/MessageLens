import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/util/paths_helper.dart';
import '../../../providers.dart';
import '../../db/feature_level_providers.dart';
import '../../db_importers/domain/value_objects/db_import_stage.dart';
import '../../db_importers/presentation/view_model/db_import_control_provider.dart';
import '../domain/db_onboarding_phase.dart';
import '../domain/db_onboarding_state.dart';
import '../domain/import_sub_stage.dart';

part 'db_onboarding_state_provider.g.dart';

/// Default minimum duration a phase should be visible before transitioning.
/// This ensures users can read the phase labels without them flashing by.
const _defaultPhaseMinDurationMs = 1000;
const _phaseMinDurationOverlayKey = 'onboarding_min_phase_duration_ms';

const _conversationMetadataSubStageOrder = <String>[
  'clearingLedger',
  'importingHandles',
  'importingChats',
  'importingParticipants',
];

const _importingAttachmentsSubStageOrder = <String>[
  'importingAttachments',
  'linkingMessageArtifacts',
];

const _contactsSubStageOrder = <String>[
  'importingAddressBook',
  'linkingContacts',
];

const _migrationSignalStageKeys = <String>{
  'clearingWorking',
  'migratingIdentities',
};

/// Manages the onboarding state machine and coordinates with import/migration.
///
/// This provider maps the detailed internal import and migration stages to
/// user-friendly phases displayed in the stepper UI.
@Riverpod(keepAlive: true)
class DbOnboardingStateNotifier extends _$DbOnboardingStateNotifier {
  PathsHelper? _pathsHelper;

  /// Timestamp when the current phase became active.
  DateTime _phaseStartTime = DateTime.now();

  /// The target phase we're transitioning toward.
  /// We only transition forward (never backward) to avoid jumping around.
  DbOnboardingPhase? _targetPhase;

  /// Timer for delayed phase transitions.
  Timer? _phaseTimer;

  /// Timer for delayed sub-stage transitions.
  Timer? _subStageTimer;

  /// Latest sub-stage snapshot from import/migration control state.
  List<ImportSubStage> _latestRawSubStages = const <ImportSubStage>[];

  /// Currently displayed active sub-stage key for paced UI transitions.
  String? _displaySubStageKey;

  /// Target active sub-stage key we are stepping toward.
  String? _targetSubStageKey;

  /// Timestamp when the current sub-stage snapshot became visible.
  DateTime _subStageDisplayStartTime = DateTime.now();

  /// Monotonic token used to invalidate stale async onboarding flows.
  int _flowToken = 0;

  String? _lastDebugMessage;

  void _logDebug(String message) {
    if (!state.devMode) {
      return;
    }

    if (_lastDebugMessage == message) {
      return;
    }

    _lastDebugMessage = message;

    debugPrint('[OnboardingDebug] $message');
  }

  @override
  DbOnboardingState build() {
    ref.onDispose(() {
      _cancelPendingTransitions();
    });

    unawaited(_hydratePhaseDurationPreference());

    // Listen to import control state changes and update onboarding phases
    ref.listen<DbImportControlState>(
      dbImportControlViewModelProvider,
      (previous, next) => _handleImportControlChange(previous, next),
    );

    return DbOnboardingState.initial();
  }

  Future<void> _hydratePhaseDurationPreference() async {
    try {
      final overlayDb = await ref.read(overlayDatabaseProvider.future);
      final storedValue = await overlayDb.readOverlaySetting(
        _phaseMinDurationOverlayKey,
      );

      if (storedValue == null) {
        return;
      }

      final parsed = int.tryParse(storedValue);
      if (parsed == null) {
        return;
      }

      final clampedMs = parsed.clamp(200, 5000);
      state = state.copyWith(phaseMinDurationMs: clampedMs);
    } catch (_) {
      // Preference hydration failure should not block onboarding.
    }
  }

  /// React to import/migration control state changes.
  void _handleImportControlChange(
    DbImportControlState? previous,
    DbImportControlState next,
  ) {
    // Only update if onboarding is active (not complete, not error)
    if (state.currentPhase == DbOnboardingPhase.error ||
        (state.currentPhase == DbOnboardingPhase.complete &&
            state.importComplete)) {
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
    final isMigrationProcessing = _isMigrationProcessing(next);
    final contactsPhaseDone = _arePhaseSubStagesEffectivelyComplete(
      subStages,
      _contactsSubStageOrder,
    );

    state = state.copyWith(
      progressPercent: next.progress,
      importStatusMessage: next.statusMessage,
      migrationInProgress: isMigrationProcessing,
    );

    if (isMigrationProcessing) {
      _logDebug('migration detected -> transitioning to migration step');
      _transitionToPhase(DbOnboardingPhase.complete);
    } else if (contactsPhaseDone) {
      _logDebug(
        'contacts substages effectively complete -> transitioning to migration step',
      );
      _transitionToPhase(DbOnboardingPhase.complete);
    }

    _applyOrQueueSubStageSnapshot(subStages);

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
    // Initialize phase timing and clear any pending transitions.
    final flowToken = ++_flowToken;
    _phaseStartTime = DateTime.now();
    _subStageDisplayStartTime = DateTime.now();
    _cancelPendingTransitions();
    _resetSubStagePacing(clearDisplayedSubStages: true);

    state = state.copyWith(
      currentPhase: DbOnboardingPhase.checkingPermissions,
      devMode: devMode,
      onboardingStarted: true,
      importComplete: false,
      migrationInProgress: false,
    );

    // Check FDA by attempting to stat the chat.db file
    final fdaGranted = await _checkFullDiskAccess();
    if (flowToken != _flowToken) {
      return;
    }

    state = state.copyWith(fdaGranted: fdaGranted);

    if (!fdaGranted) {
      // Stay on checkingPermissions phase - UI will show instructions
      return;
    }

    // FDA granted, proceed to locate messages
    await _proceedToLocateMessages(flowToken);
  }

  /// Reset to initial state, optionally preserving dev mode.
  void resetState({bool preserveDevMode = false}) {
    // Cancel any pending phase transitions
    ++_flowToken;
    _cancelPendingTransitions();
    _phaseStartTime = DateTime.now();
    _subStageDisplayStartTime = DateTime.now();
    _resetSubStagePacing(clearDisplayedSubStages: true);

    final wasDevMode = state.devMode;
    // Single atomic state update to avoid race conditions
    // (shell watches this state and shows overlay if devMode briefly becomes false)
    var newState = DbOnboardingState.initial();
    if (preserveDevMode && wasDevMode) {
      newState = newState.copyWith(
        devMode: true,
        phaseMinDurationMs: state.phaseMinDurationMs,
      );
    }
    state = newState.copyWith(phaseMinDurationMs: state.phaseMinDurationMs);
  }

  /// Retry after FDA instructions.
  Future<void> retryFdaCheck() async {
    final flowToken = ++_flowToken;
    _cancelPendingTransitions();
    _resetSubStagePacing(clearDisplayedSubStages: true);

    state = state.copyWith(
      currentPhase: DbOnboardingPhase.checkingPermissions,
      errorMessage: null,
      onboardingStarted: true,
      importComplete: false,
      migrationInProgress: false,
    );

    final fdaGranted = await _checkFullDiskAccess();
    if (flowToken != _flowToken) {
      return;
    }

    state = state.copyWith(fdaGranted: fdaGranted);

    if (fdaGranted) {
      await _proceedToLocateMessages(flowToken);
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
    state = state.copyWith(importComplete: true, migrationInProgress: false);
  }

  /// Set an error state.
  void setError(String message) {
    _cancelPendingTransitions();
    state = state.copyWith(
      currentPhase: DbOnboardingPhase.error,
      errorMessage: message,
      migrationInProgress: false,
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
  /// read the labels. We only transition forward (never backward) to avoid
  /// jumping around when import stages fire repeatedly.
  void _transitionToPhase(DbOnboardingPhase newPhase) {
    if (state.currentPhase.isTerminal) {
      return;
    }

    // Only accept forward transitions (or same phase)
    if (newPhase.stepIndex < state.currentPhase.stepIndex) {
      return;
    }

    // Update target if it's further ahead
    if (_targetPhase == null || newPhase.stepIndex > _targetPhase!.stepIndex) {
      _targetPhase = newPhase;
      _logDebug('phase target updated: ${newPhase.name}');
    }

    // Start stepping toward target if not already doing so
    _scheduleNextStep();
  }

  /// Schedule the next single-step transition toward the target phase.
  void _scheduleNextStep() {
    if (state.currentPhase.isTerminal) {
      return;
    }

    // Don't schedule if timer already running
    if (_phaseTimer != null) {
      return;
    }

    // Nothing to do if we've reached the target
    if (_targetPhase == null ||
        state.currentPhase.stepIndex >= _targetPhase!.stepIndex) {
      return;
    }

    final elapsed = DateTime.now().difference(_phaseStartTime);
    final minPhaseDuration = Duration(
      milliseconds: state.phaseMinDurationMs <= 0
          ? _defaultPhaseMinDurationMs
          : state.phaseMinDurationMs,
    );
    final remaining = minPhaseDuration - elapsed;

    if (remaining <= Duration.zero) {
      // Enough time has passed, step immediately
      _executeNextStep();
    } else {
      // Wait for minimum duration before stepping
      _phaseTimer = Timer(remaining, _executeNextStep);
    }
  }

  /// Execute one step toward the target phase.
  void _executeNextStep() {
    _phaseTimer?.cancel();
    _phaseTimer = null;

    if (state.currentPhase.isTerminal) {
      return;
    }

    // Nothing to do if we've reached the target
    if (_targetPhase == null ||
        state.currentPhase.stepIndex >= _targetPhase!.stepIndex) {
      return;
    }

    // Step to the next phase in sequence
    final nextIndex = state.currentPhase.stepIndex + 1;
    final nextPhase = kDbOnboardingPhaseOrder.firstWhere(
      (p) => p.stepIndex == nextIndex,
      orElse: () => _targetPhase!,
    );

    _phaseStartTime = DateTime.now();
    state = state.copyWith(currentPhase: nextPhase);
    _logDebug(
      'phase advance: now=${nextPhase.name} target=${_targetPhase?.name}',
    );
    _resetSubStagePacing(clearDisplayedSubStages: true);

    // Continue stepping if we haven't reached the target
    if (nextPhase.stepIndex < _targetPhase!.stepIndex) {
      _scheduleNextStep();
    }
  }

  /// Update progress percentage.
  void updateProgress(double progress) {
    state = state.copyWith(progressPercent: progress);
  }

  /// Configure the minimum phase display duration.
  ///
  /// Exposed for the onboarding developer tools panel so timing can be tuned
  /// without code edits.
  void setPhaseMinDuration(Duration duration) {
    final clampedMs = duration.inMilliseconds.clamp(200, 5000);
    state = state.copyWith(phaseMinDurationMs: clampedMs);
    unawaited(_persistPhaseDurationPreference(clampedMs));
  }

  Future<void> _persistPhaseDurationPreference(int milliseconds) async {
    try {
      final overlayDb = await ref.read(overlayDatabaseProvider.future);
      await overlayDb.writeOverlaySetting(
        settingKey: _phaseMinDurationOverlayKey,
        settingValue: milliseconds.toString(),
      );
    } catch (_) {
      // Preference persistence failure should not block onboarding.
    }
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

  Future<void> _proceedToLocateMessages(int flowToken) async {
    if (flowToken != _flowToken) {
      return;
    }

    _transitionToPhase(DbOnboardingPhase.messagesDatabase);

    try {
      _pathsHelper ??= await ref.read(pathsHelperProvider.future);
      if (flowToken != _flowToken) {
        return;
      }

      final chatDbPath = _pathsHelper!.chatDBPath;
      final file = File(chatDbPath);

      if (file.existsSync()) {
        if (flowToken != _flowToken) {
          return;
        }

        state = state.copyWith(messagesDbFound: true);

        // Brief pause to show "found" state before proceeding
        await Future<void>.delayed(const Duration(milliseconds: 300));
        if (flowToken != _flowToken) {
          return;
        }

        // Proceed to conversation metadata phase
        _transitionToPhase(DbOnboardingPhase.conversationMetadata);

        // Actually trigger the import and migration pipeline
        ref
            .read(dbImportControlViewModelProvider.notifier)
            .runImportAndMigration();
      } else {
        if (flowToken != _flowToken) {
          return;
        }

        setError('Messages database not found at expected location.');
      }
    } catch (e) {
      if (flowToken != _flowToken) {
        return;
      }

      setError('Failed to locate Messages database: $e');
    }
  }

  void _cancelPendingTransitions() {
    _phaseTimer?.cancel();
    _phaseTimer = null;
    _targetPhase = null;

    _subStageTimer?.cancel();
    _subStageTimer = null;
  }

  void _resetSubStagePacing({required bool clearDisplayedSubStages}) {
    _subStageTimer?.cancel();
    _subStageTimer = null;
    _latestRawSubStages = const <ImportSubStage>[];
    _displaySubStageKey = null;
    _targetSubStageKey = null;
    _subStageDisplayStartTime = DateTime.now();

    _logDebug('substage pacing reset; clearDisplayed=$clearDisplayedSubStages');

    if (clearDisplayedSubStages) {
      state = state.copyWith(importSubStages: const <ImportSubStage>[]);
    }
  }

  List<String> _phaseSubStageOrder(DbOnboardingPhase phase) {
    return switch (phase) {
      DbOnboardingPhase.conversationMetadata =>
        _conversationMetadataSubStageOrder,
      DbOnboardingPhase.importingAttachments =>
        _importingAttachmentsSubStageOrder,
      DbOnboardingPhase.contactsDatabase => _contactsSubStageOrder,
      _ => const <String>[],
    };
  }

  void _applyOrQueueSubStageSnapshot(List<ImportSubStage> nextSubStages) {
    _latestRawSubStages = nextSubStages;

    final phaseOrder = _phaseSubStageOrder(state.currentPhase);
    if (phaseOrder.isEmpty) {
      state = state.copyWith(importSubStages: nextSubStages);
      return;
    }

    final phaseKeys = phaseOrder.toSet();
    final rawActiveKey = _resolveRawDisplayKey(
      nextSubStages,
      allowedKeys: phaseKeys,
      phaseOrder: phaseOrder,
    );

    if (_displaySubStageKey == null ||
        !phaseKeys.contains(_displaySubStageKey)) {
      _displaySubStageKey = rawActiveKey ?? phaseOrder.first;
      _subStageDisplayStartTime = DateTime.now();
    }

    if (rawActiveKey != null && rawActiveKey != _displaySubStageKey) {
      _targetSubStageKey = rawActiveKey;
      _logDebug('substage target updated: $_targetSubStageKey');
      _scheduleNextSubStageStep(phaseOrder);
    }

    final displayed = _buildDisplayedSubStages(
      nextSubStages,
      phaseOrder: phaseOrder,
      displayActiveKey: _displaySubStageKey,
    );
    state = state.copyWith(importSubStages: displayed);
  }

  bool _isEffectivelyComplete(ImportSubStage stage) {
    if (stage.isComplete) {
      return true;
    }

    if (stage.hasGranularProgress && stage.current! >= stage.total!) {
      return true;
    }

    final progress = stage.progress;
    if (progress != null && progress >= 1.0) {
      return true;
    }

    return false;
  }

  bool _arePhaseSubStagesEffectivelyComplete(
    List<ImportSubStage> subStages,
    List<String> phaseOrder,
  ) {
    final byKey = <String, ImportSubStage>{for (final s in subStages) s.key: s};

    for (final key in phaseOrder) {
      final stage = byKey[key];
      if (stage == null) {
        return false;
      }

      if (!_isEffectivelyComplete(stage)) {
        return false;
      }
    }

    return true;
  }

  String? _resolveRawDisplayKey(
    List<ImportSubStage> subStages, {
    required Set<String> allowedKeys,
    required List<String> phaseOrder,
  }) {
    final byKey = <String, ImportSubStage>{
      for (final s in subStages)
        if (allowedKeys.contains(s.key)) s.key: s,
    };

    // Prefer truly active incomplete stage from source.
    for (final key in phaseOrder) {
      final stage = byKey[key];
      if (stage == null) {
        continue;
      }
      if (stage.isActive && !_isEffectivelyComplete(stage)) {
        return key;
      }
    }

    // Otherwise, show the first incomplete stage in order.
    for (final key in phaseOrder) {
      final stage = byKey[key];
      if (stage == null) {
        continue;
      }
      if (!_isEffectivelyComplete(stage)) {
        return key;
      }
    }

    // If everything present is complete, stick to the last present stage.
    for (final key in phaseOrder.reversed) {
      if (byKey.containsKey(key)) {
        return key;
      }
    }

    return null;
  }

  List<ImportSubStage> _buildDisplayedSubStages(
    List<ImportSubStage> rawSubStages, {
    required List<String> phaseOrder,
    required String? displayActiveKey,
  }) {
    if (displayActiveKey == null) {
      return rawSubStages;
    }

    final displayIndex = phaseOrder.indexOf(displayActiveKey);
    if (displayIndex == -1) {
      return rawSubStages;
    }

    final phaseKeys = phaseOrder.toSet();

    return rawSubStages
        .map((stage) {
          if (!phaseKeys.contains(stage.key)) {
            return stage;
          }

          final idx = phaseOrder.indexOf(stage.key);
          if (idx < displayIndex) {
            return stage.copyWith(
              isActive: false,
              isComplete: true,
              progress: 1.0,
            );
          }

          if (idx == displayIndex) {
            // Keep the displayed sub-stage active until we deliberately advance.
            return stage.copyWith(isActive: true, isComplete: false);
          }

          return stage.copyWith(isActive: false, isComplete: false);
        })
        .toList(growable: false);
  }

  void _scheduleNextSubStageStep(List<String> phaseOrder) {
    if (_subStageTimer != null) {
      return;
    }

    if (_displaySubStageKey == null || _targetSubStageKey == null) {
      return;
    }

    final displayIndex = phaseOrder.indexOf(_displaySubStageKey!);
    final targetIndex = phaseOrder.indexOf(_targetSubStageKey!);
    if (displayIndex == -1 ||
        targetIndex == -1 ||
        targetIndex <= displayIndex) {
      _targetSubStageKey = null;
      return;
    }

    final minPhaseDuration = Duration(
      milliseconds: state.phaseMinDurationMs <= 0
          ? _defaultPhaseMinDurationMs
          : state.phaseMinDurationMs,
    );
    final elapsed = DateTime.now().difference(_subStageDisplayStartTime);
    final remaining = minPhaseDuration - elapsed;

    if (remaining <= Duration.zero) {
      _advanceSubStageStep(phaseOrder);
    } else {
      _subStageTimer = Timer(remaining, () {
        _advanceSubStageStep(phaseOrder);
      });
    }
  }

  void _advanceSubStageStep(List<String> phaseOrder) {
    _subStageTimer?.cancel();
    _subStageTimer = null;

    if (_displaySubStageKey == null || _targetSubStageKey == null) {
      return;
    }

    final displayIndex = phaseOrder.indexOf(_displaySubStageKey!);
    final targetIndex = phaseOrder.indexOf(_targetSubStageKey!);
    if (displayIndex == -1 ||
        targetIndex == -1 ||
        targetIndex <= displayIndex) {
      _targetSubStageKey = null;
      return;
    }

    final nextIndex = displayIndex + 1;
    _displaySubStageKey = phaseOrder[nextIndex];
    _subStageDisplayStartTime = DateTime.now();

    _logDebug(
      'substage advance: display=$_displaySubStageKey target=$_targetSubStageKey',
    );

    final displayed = _buildDisplayedSubStages(
      _latestRawSubStages,
      phaseOrder: phaseOrder,
      displayActiveKey: _displaySubStageKey,
    );
    state = state.copyWith(importSubStages: displayed);

    if (_displaySubStageKey != _targetSubStageKey) {
      _scheduleNextSubStageStep(phaseOrder);
    } else {
      _logDebug('substage target reached: $_targetSubStageKey');
      _targetSubStageKey = null;
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

  bool _isMigrationProcessing(DbImportControlState next) {
    if (!next.isProcessing) {
      return false;
    }

    if (next.selectedMode == DbImportMode.migration) {
      return true;
    }

    final current = next.currentStage;
    if (current != null && _migrationSignalStageKeys.contains(current)) {
      return true;
    }

    for (final stage in next.stages) {
      if (_migrationSignalStageKeys.contains(stage.name)) {
        return true;
      }
    }

    return false;
  }
}
