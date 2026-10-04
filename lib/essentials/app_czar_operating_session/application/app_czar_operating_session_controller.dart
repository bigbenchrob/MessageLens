import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app_czar/application/app_czar_assessment_provider.dart';
import '../../app_czar/domain/app_czar_models.dart';
import '../domain/app_czar_operating_session_state.dart';
import 'app_czar_operating_session_visual_initializer_provider.dart';

part 'app_czar_operating_session_controller.g.dart';

@visibleForTesting
bool shouldExecuteAppCzarOperatingSession(
  AppCzarAssessmentState assessmentState,
) {
  final assessment = assessmentState.assessment;
  if (assessment == null ||
      assessment.virtualCoordinator !=
          AppCzarVirtualCoordinator.operatingSession) {
    return false;
  }

  const requiredTrueFacts = <AppCzarFactId>{
    AppCzarFactId.developmentRootAdmitted,
    AppCzarFactId.messagesSourceReadable,
    AppCzarFactId.sourceSampleStable,
    AppCzarFactId.importStoreHealthy,
    AppCzarFactId.graphStoreHealthy,
    AppCzarFactId.overlayHealthy,
    AppCzarFactId.localDatasetComplete,
    AppCzarFactId.attachmentArchiveAvailable,
    AppCzarFactId.attachmentCoverageComplete,
    AppCzarFactId.sourceLocalDeltaKnown,
  };
  for (final factId in requiredTrueFacts) {
    if (_uniqueFactTruth(assessment, factId) != AppCzarTruth.trueValue) {
      return false;
    }
  }

  return _uniqueFactTruth(assessment, AppCzarFactId.sourceAheadOfLocal) ==
      AppCzarTruth.falseValue;
}

@Riverpod(keepAlive: true)
class AppCzarOperatingSessionController
    extends _$AppCzarOperatingSessionController {
  AppCzarOperatingSessionState _current =
      const AppCzarOperatingSessionState.dormant();
  int? _startedGeneration;

  @override
  AppCzarOperatingSessionState build() {
    final assessmentState = ref.watch(appCzarAssessmentControllerProvider);
    if (_startedGeneration case final startedGeneration?
        when assessmentState.generation != startedGeneration) {
      _startedGeneration = null;
      _current = const AppCzarOperatingSessionState.dormant();
    }

    if (_startedGeneration case final startedGeneration?) {
      if (!shouldExecuteAppCzarOperatingSession(assessmentState)) {
        _current = _staleAssessmentFailure(startedGeneration);
      }
      return _current;
    }
    if (shouldExecuteAppCzarOperatingSession(assessmentState)) {
      final generation = assessmentState.generation;
      _startedGeneration = generation;
      _current = AppCzarOperatingSessionState(
        phase: AppCzarOperatingSessionPhase.restoringVisualWindowState,
        assessmentGeneration: generation,
      );
      Future<void>.microtask(() => _initialize(generation));
    }
    return _current;
  }

  Future<void> _initialize(int generation) async {
    if (!_isCurrentOperatingAssessment(generation)) {
      _publishStaleAssessmentFailure(generation);
      return;
    }

    try {
      await ref
          .read(appCzarOperatingSessionVisualInitializerProvider)
          .initializeVisualWindowState();
    } on Object catch (error) {
      if (!_isCurrentOperatingAssessment(generation)) {
        _publishStaleAssessmentFailure(generation);
        return;
      }
      _publishForGeneration(
        generation,
        AppCzarOperatingSessionState(
          phase: AppCzarOperatingSessionPhase.failed,
          assessmentGeneration: generation,
          failure: 'Visual window-state initialization failed: $error',
        ),
      );
      return;
    }

    if (!_isCurrentOperatingAssessment(generation)) {
      _publishStaleAssessmentFailure(generation);
      return;
    }

    _publishForGeneration(
      generation,
      AppCzarOperatingSessionState(
        phase: AppCzarOperatingSessionPhase.admitted,
        assessmentGeneration: generation,
      ),
    );
  }

  bool _isCurrentOperatingAssessment(int generation) {
    final currentAssessment = ref.read(appCzarAssessmentControllerProvider);
    return currentAssessment.generation == generation &&
        shouldExecuteAppCzarOperatingSession(currentAssessment);
  }

  void _publishStaleAssessmentFailure(int generation) {
    _publishForGeneration(generation, _staleAssessmentFailure(generation));
  }

  void _publishForGeneration(
    int generation,
    AppCzarOperatingSessionState next,
  ) {
    if (_startedGeneration != generation) {
      return;
    }
    _current = next;
    state = next;
  }
}

AppCzarOperatingSessionState _staleAssessmentFailure(int generation) {
  return AppCzarOperatingSessionState(
    phase: AppCzarOperatingSessionPhase.failed,
    assessmentGeneration: generation,
    failure:
        'The admitted AppCzar assessment generation changed before '
        'Operating Session entry completed.',
  );
}

AppCzarTruth? _uniqueFactTruth(
  AppCzarAssessment assessment,
  AppCzarFactId factId,
) {
  AppCzarTruth? truth;
  var matches = 0;
  for (final fact in assessment.facts) {
    if (fact.id == factId) {
      matches += 1;
      truth = fact.truth;
    }
  }
  return matches == 1 ? truth : null;
}
