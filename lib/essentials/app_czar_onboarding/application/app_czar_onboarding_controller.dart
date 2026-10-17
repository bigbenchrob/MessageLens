import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app_czar/application/app_czar_assessment_provider.dart';
import '../../app_czar/application/app_czar_observation_reader.dart';
import '../../app_czar/domain/app_czar_models.dart';
import '../../app_czar_data_update/application/app_czar_process_restarter_provider.dart';
import '../../onboarding/application/real_fda_settings_opening_authority_provider.dart';
import '../domain/app_czar_onboarding_state.dart';
import 'app_czar_onboarding_build_executor_provider.dart';

part 'app_czar_onboarding_controller.g.dart';

@visibleForTesting
bool shouldExecuteAppCzarOnboarding(AppCzarAssessmentState state) {
  final assessment = state.assessment;
  final initialScope = state.initialConstructionScope;
  final contacts = state.contactsPrerequisite;
  final archive = state.attachmentArchive;
  if (assessment == null ||
      initialScope == null ||
      contacts == null ||
      archive == null) {
    return false;
  }
  final sourceTruth = assessment
      .fact(AppCzarFactId.messagesSourceReadable)
      .truth;
  final contactsIsAdmissible =
      contacts.condition ==
          AppCzarContactsPrerequisiteCondition.viableWithContacts ||
      contacts.condition == AppCzarContactsPrerequisiteCondition.viableEmpty ||
      contacts.condition == AppCzarContactsPrerequisiteCondition.accessDenied ||
      contacts.condition == AppCzarContactsPrerequisiteCondition.unavailable;
  return state.generation >= 0 &&
      assessment.virtualCoordinator == AppCzarVirtualCoordinator.onboarding &&
      assessment.fact(AppCzarFactId.developmentRootAdmitted).truth ==
          AppCzarTruth.trueValue &&
      assessment.fact(AppCzarFactId.initialConstructionScopeSafe).truth ==
          AppCzarTruth.trueValue &&
      assessment.fact(AppCzarFactId.attachmentArchiveAvailable).truth ==
          AppCzarTruth.trueValue &&
      archive.hasCompleteArchiveBinding &&
      initialScope.condition ==
          AppCzarInitialConstructionScopeCondition.safeEmpty &&
      sourceTruth != AppCzarTruth.unknown &&
      contactsIsAdmissible;
}

@Riverpod(keepAlive: true)
class AppCzarOnboardingController extends _$AppCzarOnboardingController {
  AppCzarOnboardingState _current = const AppCzarOnboardingState.dormant();
  int? _startedGeneration;
  var _occurrenceGeneration = 0;
  var _accepting = true;
  var _restartRequested = false;
  var _restartAfterCurrentRun = false;
  Future<void>? _activeRun;
  final _settingsFlights = <Future<void>>{};
  Future<void>? _restartFlight;
  bool _restartActive = false;
  bool _stopped = false;
  Object? _drainFailure;
  StackTrace? _drainFailureStack;
  String? _admittedRootPath;
  String? _admittedArchiveScopeIdentity;
  int? _admittedArchiveGeneration;
  String? _admittedArchivePath;

  @override
  AppCzarOnboardingState build() {
    ref.onDispose(_stopOrdinary);
    ref.listen(appCzarAssessmentControllerProvider, (_, next) {
      _considerAssessment(next);
      if (!_stopped) {
        state = _current;
      }
    });
    _considerAssessment(ref.read(appCzarAssessmentControllerProvider));
    return _current;
  }

  void _considerAssessment(AppCzarAssessmentState assessment) {
    if (_stopped) {
      return;
    }
    if (_startedGeneration == null &&
        shouldExecuteAppCzarOnboarding(assessment)) {
      _startedGeneration = assessment.generation;
      _admittedRootPath = assessment.root!.path;
      _admittedArchiveScopeIdentity =
          assessment.attachmentArchive!.archiveScopeIdentity;
      _admittedArchiveGeneration =
          assessment.attachmentArchive!.archiveGeneration;
      _admittedArchivePath = assessment.attachmentArchive!.resolvedPath;
      _current = AppCzarOnboardingState(
        phase: AppCzarOnboardingPhase.checkingPrerequisites,
        assessmentGeneration: assessment.generation,
      );
      _schedule(_selfLocateAndContinue);
    } else if (_startedGeneration != null &&
        assessment.generation != _startedGeneration &&
        !_restartRequested) {
      _queueRestartAfterCurrentRun();
    }
  }

  Future<void> openSystemSettings() {
    if (!_current.canCheckAgain ||
        !_current.canOpenSystemSettings ||
        !_accepting) {
      return Future<void>.value();
    }
    // Register before calling the port: even a synchronous reentrant stop must
    // see this admitted operation. The barrier settles with the real request.
    final settled = Completer<void>();
    _settingsFlights.add(settled.future);
    return _openSettings(_occurrenceGeneration, settled);
  }

  Future<void> _openSettings(int generation, Completer<void> settled) async {
    try {
      await ref.read(realFdaSettingsOpeningAuthorityProvider).openSettings();
    } on Object catch (error, stack) {
      if (_canPublish(generation)) {
        _publish(
          _current.copyWith(
            issue: 'System Settings could not be opened: $error',
          ),
        );
      } else {
        _retainDrainFailure(error, stack);
      }
    } finally {
      _settingsFlights.remove(settled.future);
      settled.complete();
    }
  }

  Future<void> checkAgain() async {
    if (!_current.canCheckAgain || !_accepting || _activeRun != null) {
      return;
    }
    _publish(
      _current.copyWith(
        phase: AppCzarOnboardingPhase.checkingPrerequisites,
        clearIssue: true,
        clearProgress: true,
        clearPrerequisiteConditions: true,
      ),
    );
    _schedule(_selfLocateAndContinue);
    await _activeRun;
  }

  void _sealAdmission() {
    if (!_accepting) {
      return;
    }
    _accepting = false;
    _occurrenceGeneration += 1;
  }

  void _stopOrdinary() {
    _stopped = true;
    _restartAfterCurrentRun = false;
    _sealAdmission();
  }

  Future<void> _settleWork() async {
    await Future.wait<void>([
      if (_activeRun != null) _activeRun!,
      ..._settingsFlights,
    ]);
  }

  void _throwDrainFailure() {
    final failure = _drainFailure;
    if (failure != null) {
      Error.throwWithStackTrace(failure, _drainFailureStack!);
    }
  }

  void _retainDrainFailure(Object error, StackTrace stack) {
    _drainFailure ??= error;
    _drainFailureStack ??= stack;
  }

  Future<void> stopAndDrain({bool restart = false}) async {
    if (!restart) {
      _stopOrdinary();
    } else {
      _sealAdmission();
      // Explicit restart is dispatched only after the work below settles.
      _restartAfterCurrentRun = false;
    }
    await _settleWork();
    _throwDrainFailure();
    if (_restartActive) {
      // The restarter may itself request drain. Awaiting it here would recurse.
      throw StateError('Onboarding restart is active; exit is not admitted.');
    }
    if (restart && !_stopped) {
      await _requestRestart();
    } else {
      // A queued dispatch can only retire after the ordinary stop seal.
      await _restartFlight;
    }
    _throwDrainFailure();
  }

  void _schedule(Future<void> Function() action) {
    if (_activeRun != null || !_accepting) {
      return;
    }
    late final Future<void> run;
    run =
        Future<void>.microtask(() async {
          if (!_accepting) {
            return;
          }
          try {
            await action();
          } on Object catch (error, stack) {
            _retainDrainFailure(error, stack);
          }
        }).whenComplete(() {
          if (identical(_activeRun, run)) {
            _activeRun = null;
            if (_restartAfterCurrentRun && !_stopped) {
              _requestRestart();
            }
          }
        });
    _activeRun = run;
    unawaited(run);
  }

  Future<void> _selfLocateAndContinue() async {
    final generation = _occurrenceGeneration;
    final reader = ref.read(appCzarObservationReaderProvider);
    if (reader is! AppCzarInitialConstructionScopeReader ||
        reader is! AppCzarContactsPrerequisiteReader) {
      await _restartAfterDrain();
      return;
    }
    final initialScopeReader = reader as AppCzarInitialConstructionScopeReader;
    final contactsReader = reader as AppCzarContactsPrerequisiteReader;
    late final List<Object> results;
    try {
      results = await Future.wait<Object>([
        reader.readRoot(),
        initialScopeReader.readInitialConstructionScope(),
        reader.readSource(),
        contactsReader.readContactsPrerequisite(),
        reader.readAttachmentArchive(),
      ]);
    } on Object catch (error, stack) {
      if (_canPublish(generation)) {
        await _restartAfterDrain();
      } else {
        _retainDrainFailure(error, stack);
      }
      return;
    }
    if (!_canPublish(generation)) {
      return;
    }
    final root = results[0] as AppCzarRootObservation;
    final scope = results[1] as AppCzarInitialConstructionScopeObservation;
    final source = results[2] as AppCzarSourceObservation;
    final contacts = results[3] as AppCzarContactsPrerequisiteObservation;
    final archive = results[4] as AppCzarArchiveObservation;
    if (!root.admitted ||
        root.path != _admittedRootPath ||
        scope.condition != AppCzarInitialConstructionScopeCondition.safeEmpty ||
        !archive.hasCompleteArchiveBinding ||
        archive.archiveScopeIdentity != _admittedArchiveScopeIdentity ||
        archive.archiveGeneration != _admittedArchiveGeneration ||
        archive.resolvedPath != _admittedArchivePath ||
        (archive.condition != AppCzarArchiveCondition.available &&
            archive.condition != AppCzarArchiveCondition.readOnly &&
            archive.condition != AppCzarArchiveCondition.notCreated)) {
      await _restartAfterDrain();
      return;
    }
    switch (source.condition) {
      case AppCzarSourceCondition.accessDenied:
      case AppCzarSourceCondition.unavailable:
        _publish(
          _current.copyWith(
            phase: AppCzarOnboardingPhase.sourceNeedsHuman,
            sourceCondition: source.condition,
            issue:
                source.issue ?? 'The Messages source cannot currently be read.',
          ),
        );
        return;
      case AppCzarSourceCondition.unknown:
        await _restartAfterDrain();
        return;
      case AppCzarSourceCondition.readable:
        if (source.sampleStable != true) {
          await _restartAfterDrain();
          return;
        }
    }
    switch (contacts.condition) {
      case AppCzarContactsPrerequisiteCondition.notRequiredForCurrentScope:
        await _restartAfterDrain();
        return;
      case AppCzarContactsPrerequisiteCondition.accessDenied:
      case AppCzarContactsPrerequisiteCondition.unavailable:
        _publish(
          _current.copyWith(
            phase: AppCzarOnboardingPhase.contactsNeedHuman,
            contactsCondition: contacts.condition,
            issue: contacts.issue ?? 'The Contacts source needs attention.',
          ),
        );
        return;
      case AppCzarContactsPrerequisiteCondition.invalidOrCorrupt:
      case AppCzarContactsPrerequisiteCondition.unknown:
        await _restartAfterDrain();
        return;
      case AppCzarContactsPrerequisiteCondition.viableWithContacts:
      case AppCzarContactsPrerequisiteCondition.viableEmpty:
        await _runInitialBuild(generation);
    }
  }

  Future<void> _runInitialBuild(int generation) async {
    if (!_canPublish(generation)) {
      return;
    }
    _publish(
      _current.copyWith(
        phase: AppCzarOnboardingPhase.building,
        clearIssue: true,
        clearProgress: true,
        clearPrerequisiteConditions: true,
      ),
    );
    if (!_canPublish(generation)) {
      return;
    }
    try {
      await ref
          .read(appCzarOnboardingBuildExecutorProvider)
          .run(
            onObservation: (observation) {
              if (_canPublish(generation)) {
                _publish(
                  _current.copyWith(
                    phase: AppCzarOnboardingPhase.building,
                    suboperation: observation.suboperation,
                    completedWorkCount: observation.completedWorkCount,
                    totalWorkCount: observation.totalWorkCount,
                  ),
                );
              }
            },
          );
    } on Object catch (error, stack) {
      if (!_canPublish(generation)) {
        _retainDrainFailure(error, stack);
      }
      if (_canPublish(generation)) {
        _publish(
          _current.copyWith(
            phase: AppCzarOnboardingPhase.restarting,
            issue: 'Initial construction ended with an error: $error',
            clearProgress: true,
          ),
        );
      }
    }
    if (_canPublish(generation)) {
      _queueRestartAfterCurrentRun();
    }
  }

  Future<void> _restartAfterDrain() async {
    _queueRestartAfterCurrentRun();
  }

  void _queueRestartAfterCurrentRun() {
    if (_stopped || _restartRequested || _restartAfterCurrentRun) {
      return;
    }
    _sealAdmission();
    _restartAfterCurrentRun = true;
    if (_activeRun == null) {
      _requestRestart();
    }
  }

  Future<void> _requestRestart() {
    if (_stopped) {
      return Future<void>.value();
    }
    if (_restartRequested) {
      return _restartFlight ?? Future<void>.value();
    }
    _restartRequested = true;
    _restartAfterCurrentRun = false;
    final generation = _occurrenceGeneration;
    late final Future<void> flight;
    flight =
        Future<void>.microtask(() async {
          try {
            await _settleWork();
            if (_stopped || generation != _occurrenceGeneration) {
              return;
            }
            _throwDrainFailure();
            _publish(
              _current.copyWith(
                phase: AppCzarOnboardingPhase.restarting,
                clearProgress: true,
              ),
            );
            if (_stopped || generation != _occurrenceGeneration) {
              return;
            }
            _restartActive = true;
            await ref
                .read(appCzarProcessRestarterProvider)
                .restartAndReassess();
          } on Object catch (error, stack) {
            _retainDrainFailure(error, stack);
            _restartRequested = false;
            if (!_stopped && generation == _occurrenceGeneration) {
              _publish(
                _current.copyWith(
                  phase: AppCzarOnboardingPhase.failed,
                  issue: 'MessageLens could not restart: $error',
                ),
              );
            }
          } finally {
            _restartActive = false;
          }
        }).whenComplete(() {
          if (identical(_restartFlight, flight)) {
            _restartFlight = null;
          }
        });
    _restartFlight = flight;
    return flight;
  }

  bool _canPublish(int generation) {
    return _accepting && generation == _occurrenceGeneration;
  }

  void _publish(AppCzarOnboardingState next) {
    _current = next;
    state = next;
  }
}
