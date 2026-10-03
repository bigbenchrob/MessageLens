import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app_czar/application/app_czar_assessment_provider.dart';
import '../../app_czar/domain/app_czar_models.dart';
import '../../app_czar_data_update/application/app_czar_process_restarter_provider.dart';
import '../../onboarding/application/real_fda_settings_opening_authority_provider.dart';
import '../domain/app_czar_source_access_state.dart';

part 'app_czar_source_access_controller.g.dart';

@visibleForTesting
bool shouldExecuteAppCzarSourceAccessRepair(
  AppCzarAssessmentState assessmentState,
) {
  final assessment = assessmentState.assessment;
  final source = assessmentState.source;
  if (assessment == null || source == null) {
    return false;
  }
  final sourceConditionIsConclusiveFailure =
      source.condition == AppCzarSourceCondition.accessDenied ||
      source.condition == AppCzarSourceCondition.unavailable;
  return assessment.virtualCoordinator ==
          AppCzarVirtualCoordinator.sourceAccessRepair &&
      assessment.fact(AppCzarFactId.messagesSourceReadable).truth ==
          AppCzarTruth.falseValue &&
      sourceConditionIsConclusiveFailure;
}

@Riverpod(keepAlive: true)
class AppCzarSourceAccessController extends _$AppCzarSourceAccessController {
  AppCzarSourceAccessState _current = const AppCzarSourceAccessState.dormant();
  int? _startedGeneration;
  bool _checkInFlight = false;
  bool _settingsOpenInFlight = false;
  bool _restartRequested = false;

  @override
  AppCzarSourceAccessState build() {
    final assessmentState = ref.watch(appCzarAssessmentControllerProvider);
    if (_startedGeneration == null &&
        shouldExecuteAppCzarSourceAccessRepair(assessmentState)) {
      _startedGeneration = assessmentState.generation;
      _current = AppCzarSourceAccessState(
        phase: AppCzarSourceAccessPhase.waitingForHuman,
        assessmentGeneration: assessmentState.generation,
        sourceReason: _literalSourceReason(assessmentState.source!),
      );
    }
    return _current;
  }

  Future<void> openSystemSettings() async {
    if (!_current.isVisible ||
        _settingsOpenInFlight ||
        _current.phase == AppCzarSourceAccessPhase.restartRequested) {
      return;
    }
    _settingsOpenInFlight = true;
    try {
      await ref.read(realFdaSettingsOpeningAuthorityProvider).openSettings();
      _publish(_current.copyWith(clearSettingsFailure: true));
    } on Object catch (error) {
      _publish(
        _current.copyWith(
          settingsFailure: 'System Settings could not be opened: $error',
        ),
      );
    } finally {
      _settingsOpenInFlight = false;
    }
  }

  Future<void> checkAgain() async {
    if (!_current.canCheckAgain || _checkInFlight || _restartRequested) {
      return;
    }
    _checkInFlight = true;
    _publish(
      _current.copyWith(
        phase: AppCzarSourceAccessPhase.checking,
        clearSettingsFailure: true,
        clearRestartFailure: true,
      ),
    );

    AppCzarSourceObservation observation;
    try {
      observation = await ref
          .read(appCzarObservationReaderProvider)
          .readSource();
    } on Object catch (error) {
      observation = AppCzarSourceObservation.unknown(
        'The fresh Messages source check did not complete: $error',
      );
    }

    try {
      switch (observation.condition) {
        case AppCzarSourceCondition.readable:
          _publish(
            _current.copyWith(
              phase: AppCzarSourceAccessPhase.restartRequested,
              sourceReason:
                  'The current read-only Messages source check succeeded.',
              clearRestartFailure: true,
            ),
          );
          await _requestRestart();
        case AppCzarSourceCondition.accessDenied:
        case AppCzarSourceCondition.unavailable:
          _publish(
            _current.copyWith(
              phase: AppCzarSourceAccessPhase.waitingForHuman,
              sourceReason: _literalSourceReason(observation),
              clearRestartFailure: true,
            ),
          );
        case AppCzarSourceCondition.unknown:
          _publish(
            _current.copyWith(
              phase: AppCzarSourceAccessPhase.inconclusive,
              sourceReason: _literalUnknownReason(observation),
              clearRestartFailure: true,
            ),
          );
      }
    } finally {
      _checkInFlight = false;
    }
  }

  Future<void> restartAndReassess() async {
    if (!_current.canRestartAndReassess || _restartRequested) {
      return;
    }
    await _requestRestart();
  }

  Future<void> _requestRestart() async {
    if (_restartRequested) {
      return;
    }
    _restartRequested = true;
    _publish(
      _current.copyWith(
        phase: AppCzarSourceAccessPhase.restartRequested,
        clearRestartFailure: true,
      ),
    );
    try {
      await ref.read(appCzarProcessRestarterProvider).restartAndReassess();
    } on Object catch (error) {
      _restartRequested = false;
      _publish(
        _current.copyWith(
          phase: AppCzarSourceAccessPhase.restartFailed,
          restartFailure: 'MessageLens could not restart: $error',
        ),
      );
    }
  }

  void _publish(AppCzarSourceAccessState next) {
    _current = next;
    state = next;
  }
}

String _literalSourceReason(AppCzarSourceObservation observation) {
  return observation.issue ??
      'The Messages source did not complete its read-only check.';
}

String _literalUnknownReason(AppCzarSourceObservation observation) {
  return observation.issue ??
      'MessageLens could not determine whether the Messages source is currently readable.';
}
