import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app_czar/application/app_czar_assessment_provider.dart';
import '../../app_czar/domain/app_czar_models.dart';
import '../domain/app_czar_operating_session_state.dart';
import 'app_czar_operating_currentness_controller.dart';
import 'app_czar_operating_session_visual_initializer_provider.dart';

part 'app_czar_operating_session_controller.g.dart';

var _nextOperatingOccurrenceSequence = 0;

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
  final archive = assessmentState.attachmentArchive;
  if (archive == null || !archive.hasCompleteArchiveBinding) {
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
    AppCzarFactId.sourceLocalDeltaKnown,
  };
  for (final factId in requiredTrueFacts) {
    if (_uniqueFactTruth(assessment, factId) != AppCzarTruth.trueValue) {
      return false;
    }
  }

  if (_uniqueFactTruth(
        assessment,
        AppCzarFactId.attachmentRepairOpportunityPresent,
      ) !=
      AppCzarTruth.falseValue) {
    return false;
  }
  final coverageTruth = _uniqueFactTruth(
    assessment,
    AppCzarFactId.attachmentCoverageComplete,
  );
  if ((coverageTruth != AppCzarTruth.trueValue &&
          coverageTruth != AppCzarTruth.falseValue) ||
      !archive.repairability.isOperatingSafe ||
      !archive.hasCoherentRepairabilityBinding) {
    return false;
  }

  return _uniqueFactTruth(assessment, AppCzarFactId.sourceAheadOfLocal) ==
      AppCzarTruth.falseValue;
}

@Riverpod(keepAlive: true)
class AppCzarOperatingSessionController
    extends _$AppCzarOperatingSessionController {
  AppCzarOperatingSessionState _current =
      const AppCzarOperatingSessionState.dormant();
  AppCzarOperatingSessionOccurrence? _startedOccurrence;
  AppCzarAssessmentState? _latestAssessmentState;

  @override
  AppCzarOperatingSessionState build() {
    final assessmentState = ref.read(appCzarAssessmentControllerProvider);
    _latestAssessmentState = assessmentState;
    ref.listen<AppCzarAssessmentState>(appCzarAssessmentControllerProvider, (
      previous,
      next,
    ) {
      _handleAssessmentChange(next);
    });
    if (shouldExecuteAppCzarOperatingSession(assessmentState)) {
      _beginOccurrence(assessmentState);
    }
    return _current;
  }

  void _handleAssessmentChange(AppCzarAssessmentState assessmentState) {
    _latestAssessmentState = assessmentState;
    final startedOccurrence = _startedOccurrence;
    if (startedOccurrence != null) {
      final stillAdmitted =
          assessmentState.generation ==
              startedOccurrence.assessmentGeneration &&
          shouldExecuteAppCzarOperatingSession(assessmentState);
      if (!stillAdmitted) {
        if (_current.phase == AppCzarOperatingSessionPhase.admitted ||
            _current.phase == AppCzarOperatingSessionPhase.draining) {
          _beginDrain(startedOccurrence);
          state = _current;
          return;
        }
        _clearStartedOccurrence();
        _current = const AppCzarOperatingSessionState.dormant();
      } else {
        return;
      }
    }

    if (shouldExecuteAppCzarOperatingSession(assessmentState)) {
      _beginOccurrence(assessmentState);
    }
    state = _current;
  }

  void _beginOccurrence(AppCzarAssessmentState assessmentState) {
    final generation = assessmentState.generation;
    final archive = assessmentState.attachmentArchive;
    final occurrence = AppCzarOperatingSessionOccurrence(
      processSequence: ++_nextOperatingOccurrenceSequence,
      assessmentGeneration: generation,
      admittedArchiveScopeIdentity: archive?.archiveScopeIdentity,
      admittedArchiveProbeGeneration: archive?.archiveGeneration,
      admittedArchiveResolvedPath: archive?.resolvedPath,
    );
    _startedOccurrence = occurrence;
    _current = AppCzarOperatingSessionState(
      phase: AppCzarOperatingSessionPhase.restoringVisualWindowState,
      assessmentGeneration: generation,
      occurrence: occurrence,
    );
    Future<void>.microtask(() => _initialize(occurrence));
  }

  void _beginDrain(AppCzarOperatingSessionOccurrence occurrence) {
    if (_current.phase == AppCzarOperatingSessionPhase.draining) {
      return;
    }
    _current = AppCzarOperatingSessionState(
      phase: AppCzarOperatingSessionPhase.draining,
      assessmentGeneration: occurrence.assessmentGeneration,
      occurrence: occurrence,
    );
    final drain = ref
        .read(
          appCzarOperatingCurrentnessControllerProvider(occurrence).notifier,
        )
        .stopAndDrain();
    unawaited(_drainAndRelease(occurrence, drain));
  }

  Future<void> _drainAndRelease(
    AppCzarOperatingSessionOccurrence occurrence,
    Future<void> drain,
  ) async {
    await drain;
    if (_startedOccurrence != occurrence ||
        _current.phase != AppCzarOperatingSessionPhase.draining) {
      return;
    }

    _clearStartedOccurrence();
    final assessmentState = _latestAssessmentState!;
    if (shouldExecuteAppCzarOperatingSession(assessmentState)) {
      _beginOccurrence(assessmentState);
    } else if (assessmentState.generation == occurrence.assessmentGeneration) {
      _current = _operatingAdmissionLostFailure(
        occurrence.assessmentGeneration,
      );
    } else {
      _current = const AppCzarOperatingSessionState.dormant();
    }
    state = _current;
  }

  void _clearStartedOccurrence() {
    _startedOccurrence = null;
  }

  Future<void> _initialize(AppCzarOperatingSessionOccurrence occurrence) async {
    final generation = occurrence.assessmentGeneration;
    if (!_isCurrentOperatingOccurrence(occurrence)) {
      _publishStaleAssessmentFailure(occurrence);
      return;
    }

    try {
      await ref
          .read(appCzarOperatingSessionVisualInitializerProvider)
          .initializeVisualWindowState();
    } on Object catch (error) {
      if (!_isCurrentOperatingOccurrence(occurrence)) {
        _publishStaleAssessmentFailure(occurrence);
        return;
      }
      _publishForOccurrence(
        occurrence,
        AppCzarOperatingSessionState(
          phase: AppCzarOperatingSessionPhase.failed,
          assessmentGeneration: generation,
          occurrence: _startedOccurrence,
          failure: 'Visual window-state initialization failed: $error',
        ),
      );
      return;
    }

    if (!_isCurrentOperatingOccurrence(occurrence)) {
      _publishStaleAssessmentFailure(occurrence);
      return;
    }

    _publishForOccurrence(
      occurrence,
      AppCzarOperatingSessionState(
        phase: AppCzarOperatingSessionPhase.admitted,
        assessmentGeneration: generation,
        occurrence: _startedOccurrence,
      ),
    );
  }

  bool _isCurrentOperatingOccurrence(
    AppCzarOperatingSessionOccurrence occurrence,
  ) {
    final currentAssessment = _latestAssessmentState!;
    return _startedOccurrence == occurrence &&
        currentAssessment.generation == occurrence.assessmentGeneration &&
        shouldExecuteAppCzarOperatingSession(currentAssessment);
  }

  void _publishStaleAssessmentFailure(
    AppCzarOperatingSessionOccurrence occurrence,
  ) {
    _publishForOccurrence(
      occurrence,
      _staleAssessmentFailure(occurrence.assessmentGeneration),
    );
  }

  void _publishForOccurrence(
    AppCzarOperatingSessionOccurrence occurrence,
    AppCzarOperatingSessionState next,
  ) {
    if (_startedOccurrence != occurrence) {
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

AppCzarOperatingSessionState _operatingAdmissionLostFailure(int generation) {
  return AppCzarOperatingSessionState(
    phase: AppCzarOperatingSessionPhase.failed,
    assessmentGeneration: generation,
    failure:
        'The facts that admitted this Operating occurrence changed while its currentness work was draining.',
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
