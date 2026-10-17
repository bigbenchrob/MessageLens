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
  bool _accepting = true;
  bool _restartRequested = false;
  Future<void>? _settingsFlight;
  Future<AppCzarSourceObservation>? _checkFlight;
  Future<void>? _checkContinuation;
  Future<void>? _restartFlight;
  Object? _drainFailure;
  StackTrace? _drainFailureStack;

  @override
  AppCzarSourceAccessState build() {
    ref.onDispose(_sealAdmission);
    void considerAssessment(AppCzarAssessmentState assessment) {
      if (!_accepting) {
        return;
      }
      if (_startedGeneration != null) {
        if (assessment.generation != _startedGeneration ||
            !shouldExecuteAppCzarSourceAccessRepair(assessment)) {
          _sealAdmission();
        }
        return;
      }
      if (shouldExecuteAppCzarSourceAccessRepair(assessment)) {
        _startedGeneration = assessment.generation;
        _current = AppCzarSourceAccessState(
          phase: AppCzarSourceAccessPhase.waitingForHuman,
          assessmentGeneration: assessment.generation,
          sourceReason: _literalSourceReason(assessment.source!),
        );
      }
    }

    ref.listen(appCzarAssessmentControllerProvider, (_, next) {
      considerAssessment(next);
      _publish(_current);
    });
    considerAssessment(ref.read(appCzarAssessmentControllerProvider));
    return _current;
  }

  void _sealAdmission() {
    _accepting = false;
  }

  /// Waits for admitted source/Settings work. A pending restart is a refusal,
  /// never quiescence: awaiting it here could recursively await this drain.
  Future<void> stopAndDrain() async {
    _sealAdmission();
    await Future.wait<Object?>([
      if (_settingsFlight != null) _settingsFlight!,
      if (_checkFlight != null) _checkFlight!,
    ]);
    final failure = _drainFailure;
    if (failure != null) {
      Error.throwWithStackTrace(failure, _drainFailureStack!);
    }
    if (_restartFlight != null) {
      throw StateError(
        'Source Access restart is still in flight; exit is not admitted.',
      );
    }
    // Admission is sealed and no restart is active: the remaining check
    // continuation can only retire, so awaiting it cannot await a restarter.
    await _checkContinuation;
  }

  Future<void> openSystemSettings() {
    if (!_accepting ||
        !_current.isVisible ||
        _settingsFlight != null ||
        _restartRequested) {
      return Future<void>.value();
    }
    late final Future<void> flight;
    flight = Future<void>.microtask(_openSettings).whenComplete(() {
      if (identical(_settingsFlight, flight)) {
        _settingsFlight = null;
      }
    });
    _settingsFlight = flight;
    return flight;
  }

  Future<void> _openSettings() async {
    if (!_accepting) {
      return;
    }
    try {
      await ref.read(realFdaSettingsOpeningAuthorityProvider).openSettings();
      _publish(_current.copyWith(clearSettingsFailure: true));
    } on Object catch (error, stack) {
      _retainDrainFailure(error, stack);
      _publish(
        _current.copyWith(
          settingsFailure: 'System Settings could not be opened: $error',
        ),
      );
    }
  }

  Future<void> checkAgain() {
    if (!_accepting ||
        !_current.canCheckAgain ||
        _checkContinuation != null ||
        _restartRequested) {
      return Future<void>.value();
    }
    final check = Future<AppCzarSourceObservation>.microtask(_readSource);
    _checkFlight = check;
    late final Future<void> continuation;
    continuation = _finishCheck(check).whenComplete(() {
      if (identical(_checkContinuation, continuation)) {
        _checkContinuation = null;
      }
    });
    _checkContinuation = continuation;
    return continuation;
  }

  Future<AppCzarSourceObservation> _readSource() async {
    if (!_accepting) {
      return const AppCzarSourceObservation.unknown(
        'Source check admission closed.',
      );
    }
    _publish(
      _current.copyWith(
        phase: AppCzarSourceAccessPhase.checking,
        clearSettingsFailure: true,
        clearRestartFailure: true,
      ),
    );
    try {
      final observation = await ref
          .read(appCzarObservationReaderProvider)
          .readSource();
      return observation;
    } on Object catch (error, stack) {
      _retainDrainFailure(error, stack);
      return AppCzarSourceObservation.unknown(
        'The fresh Messages source check did not complete: $error',
      );
    }
  }

  Future<void> _finishCheck(Future<AppCzarSourceObservation> check) async {
    try {
      final observation = await check;
      if (identical(_checkFlight, check)) {
        _checkFlight = null;
      }
      if (!_accepting) {
        return;
      }
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
    } on Object catch (error, stack) {
      _retainDrainFailure(error, stack);
      _publish(
        _current.copyWith(
          phase: AppCzarSourceAccessPhase.inconclusive,
          sourceReason:
              'The fresh Messages source check did not complete: $error',
        ),
      );
    }
  }

  Future<void> restartAndReassess() {
    if (!_accepting || !_current.canRestartAndReassess || _restartRequested) {
      return Future<void>.value();
    }
    return _requestRestart();
  }

  Future<void> _requestRestart() {
    if (!_accepting || _restartRequested) {
      return Future<void>.value();
    }
    _restartRequested = true;
    late final Future<void> flight;
    flight = Future<void>.microtask(_restartAfterWork).whenComplete(() {
      if (identical(_restartFlight, flight)) {
        _restartFlight = null;
      }
    });
    _restartFlight = flight;
    return flight;
  }

  Future<void> _restartAfterWork() async {
    try {
      await Future.wait<Object?>([
        if (_settingsFlight != null) _settingsFlight!,
        if (_checkFlight != null) _checkFlight!,
      ]);
      if (!_accepting) {
        return;
      }
      _publish(
        _current.copyWith(
          phase: AppCzarSourceAccessPhase.restartRequested,
          clearRestartFailure: true,
        ),
      );
      if (!_accepting) {
        return;
      }
      await ref.read(appCzarProcessRestarterProvider).restartAndReassess();
    } on Object catch (error, stack) {
      _restartRequested = false;
      _retainDrainFailure(error, stack);
      _publish(
        _current.copyWith(
          phase: AppCzarSourceAccessPhase.restartFailed,
          restartFailure: 'MessageLens could not restart: $error',
        ),
      );
    }
  }

  void _retainDrainFailure(Object error, StackTrace stack) {
    // Before sealing, errors are handled by the existing presentation states.
    // An error while draining must instead make the exit request fail closed.
    if (!_accepting) {
      _drainFailure ??= error;
      _drainFailureStack ??= stack;
    }
  }

  void _publish(AppCzarSourceAccessState next) {
    if (!_accepting) {
      return;
    }
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
