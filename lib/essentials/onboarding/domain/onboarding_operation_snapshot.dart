import 'package:meta/meta.dart';

import '../../source_scoped_import/domain/source_import_anomaly_counts.dart';

enum OnboardingOperationKind { initialImport, reimport, automaticRecovery }

enum OnboardingOperationStatus { idle, running, interrupted, failed, completed }

enum OnboardingOperationStage {
  environmentPreparation,
  messageDataBuild,
  durableReadinessVerification,
  automaticRecoveryReset,
}

enum OnboardingOperationSubstage {
  preparingEnvironment,
  resettingDerivedData,
  importingChats,
  importingHandles,
  importingContacts,
  importingContactEmailChannels,
  importingContactPhoneChannels,
  importingMessages,
  extractingRichText,
  persistingRichText,
  importingAttachments,
  importingChatMessageRelationships,
  importingChatHandleRelationships,
  importingMessageAttachmentRelationships,
  projectingHandles,
  projectingContacts,
  projectingChatHandleRelationships,
  projectingConversations,
  projectingMessages,
  projectingAttachments,
  projectingChatMessageRelationships,
  projectingMessageAttachmentRelationships,
  verifyingDurableReadiness,
}

enum OnboardingOperationFailureCategory {
  environmentPreparation,
  messageDataBuild,
  durableReadinessVerification,
  durableStateInconsistent,
  unexpected,
}

enum OnboardingOperationRecoveryDisposition {
  retryFromSafeBoundary,
  manualInspectionRequired,
  notRequired,
}

@immutable
final class OnboardingOperationId {
  OnboardingOperationId(String value) : value = _validate(value);

  final String value;

  static String _validate(String value) {
    final normalized = value.trim().toLowerCase();
    final uuidPattern = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-'
      r'[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    );
    if (!uuidPattern.hasMatch(normalized)) {
      throw FormatException('Invalid onboarding operation identifier: $value');
    }
    return normalized;
  }

  @override
  bool operator ==(Object other) {
    return other is OnboardingOperationId && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

@immutable
final class OnboardingProcessSessionId {
  OnboardingProcessSessionId(String value) : value = _validate(value);

  final String value;

  static String _validate(String value) {
    final normalized = value.trim().toLowerCase();
    final uuidPattern = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-'
      r'[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    );
    if (!uuidPattern.hasMatch(normalized)) {
      throw FormatException('Invalid onboarding process session: $value');
    }
    return normalized;
  }

  @override
  bool operator ==(Object other) {
    return other is OnboardingProcessSessionId && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

@immutable
final class OnboardingOperationProgress {
  const OnboardingOperationProgress({
    required this.completedWorkUnits,
    required this.totalWorkUnits,
    this.lastCompletedSourceRowId,
    this.anomalyCounts = SourceImportAnomalyCounts.empty,
  }) : assert(completedWorkUnits >= 0),
       assert(totalWorkUnits >= 0),
       assert(completedWorkUnits <= totalWorkUnits);

  final int completedWorkUnits;
  final int totalWorkUnits;
  final int? lastCompletedSourceRowId;
  final SourceImportAnomalyCounts anomalyCounts;

  int get preservedUnnormalizedCount =>
      anomalyCounts.preservedUnnormalizedHandleCount;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'completed_work_units': completedWorkUnits,
      'total_work_units': totalWorkUnits,
      'last_completed_source_rowid': lastCompletedSourceRowId,
      'preserved_unnormalized_count': preservedUnnormalizedCount,
      'source_anomaly_counts': anomalyCounts.toJson(),
    };
  }

  factory OnboardingOperationProgress.fromJson(Map<String, Object?> json) {
    final completedWorkUnits = json['completed_work_units'];
    final totalWorkUnits = json['total_work_units'];
    if (completedWorkUnits is! int || totalWorkUnits is! int) {
      throw const FormatException('Invalid onboarding progress payload.');
    }
    return OnboardingOperationProgress(
      completedWorkUnits: completedWorkUnits,
      totalWorkUnits: totalWorkUnits,
      lastCompletedSourceRowId: json['last_completed_source_rowid'] as int?,
      anomalyCounts: json['source_anomaly_counts'] == null
          ? SourceImportAnomalyCounts(
              preservedUnnormalizedHandleCount:
                  json['preserved_unnormalized_count'] as int? ?? 0,
            )
          : SourceImportAnomalyCounts.fromJson(
              _requiredMap(
                json['source_anomaly_counts'],
                'source anomaly counts',
              ),
            ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is OnboardingOperationProgress &&
        other.completedWorkUnits == completedWorkUnits &&
        other.totalWorkUnits == totalWorkUnits &&
        other.lastCompletedSourceRowId == lastCompletedSourceRowId &&
        other.anomalyCounts == anomalyCounts;
  }

  @override
  int get hashCode => Object.hash(
    completedWorkUnits,
    totalWorkUnits,
    lastCompletedSourceRowId,
    anomalyCounts,
  );
}

@immutable
final class OnboardingOperationFailure {
  const OnboardingOperationFailure({
    required this.category,
    required this.occurredAtUtc,
    required this.summary,
    required this.recoveryDisposition,
  });

  final OnboardingOperationFailureCategory category;
  final DateTime occurredAtUtc;
  final String summary;
  final OnboardingOperationRecoveryDisposition recoveryDisposition;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'category': category.name,
      'occurred_at_utc': occurredAtUtc.toIso8601String(),
      'summary': summary,
      'recovery_disposition': recoveryDisposition.name,
    };
  }

  factory OnboardingOperationFailure.fromJson(Map<String, Object?> json) {
    return OnboardingOperationFailure(
      category: _enumByName(
        OnboardingOperationFailureCategory.values,
        json['category'],
        'failure category',
      ),
      occurredAtUtc: _dateTime(json['occurred_at_utc'], 'failure occurrence'),
      summary: _requiredString(json['summary'], 'failure summary'),
      recoveryDisposition: _enumByName(
        OnboardingOperationRecoveryDisposition.values,
        json['recovery_disposition'],
        'recovery disposition',
      ),
    );
  }
}

@immutable
final class OnboardingOperationSnapshot {
  const OnboardingOperationSnapshot._({
    required this.status,
    required this.completedStages,
    required this.progressRevision,
    this.sourceAnomalyCounts = SourceImportAnomalyCounts.empty,
    this.operationId,
    this.processSessionId,
    this.kind,
    this.currentStage,
    this.currentSubstage,
    this.startedAtUtc,
    this.stageStartedAtUtc,
    this.lastProgressObservedAtUtc,
    this.progress,
    this.failure,
    this.finishedAtUtc,
  });

  static const int currentFormatVersion = 1;

  const OnboardingOperationSnapshot.idle()
    : this._(
        status: OnboardingOperationStatus.idle,
        completedStages: const <OnboardingOperationStage>[],
        progressRevision: 0,
      );

  final OnboardingOperationStatus status;
  final OnboardingOperationId? operationId;
  final OnboardingProcessSessionId? processSessionId;
  final OnboardingOperationKind? kind;
  final OnboardingOperationStage? currentStage;
  final OnboardingOperationSubstage? currentSubstage;
  final List<OnboardingOperationStage> completedStages;
  final DateTime? startedAtUtc;
  final DateTime? stageStartedAtUtc;
  final DateTime? lastProgressObservedAtUtc;
  final OnboardingOperationProgress? progress;
  final int progressRevision;
  final SourceImportAnomalyCounts sourceAnomalyCounts;

  int get preservedUnnormalizedHandleCount =>
      sourceAnomalyCounts.preservedUnnormalizedHandleCount;
  final OnboardingOperationFailure? failure;
  final DateTime? finishedAtUtc;

  bool get isActive => status == OnboardingOperationStatus.running;

  static OnboardingOperationSnapshot running({
    required OnboardingOperationId operationId,
    required OnboardingProcessSessionId processSessionId,
    required OnboardingOperationKind kind,
    required OnboardingOperationStage stage,
    required DateTime observedAtUtc,
  }) {
    return OnboardingOperationSnapshot._(
      status: OnboardingOperationStatus.running,
      operationId: operationId,
      processSessionId: processSessionId,
      kind: kind,
      currentStage: stage,
      completedStages: const <OnboardingOperationStage>[],
      startedAtUtc: observedAtUtc,
      stageStartedAtUtc: observedAtUtc,
      lastProgressObservedAtUtc: observedAtUtc,
      progressRevision: 1,
    );
  }

  OnboardingOperationSnapshot transitionToStage({
    required OnboardingOperationStage stage,
    required DateTime observedAtUtc,
  }) {
    _requireRunning();
    if (stage == currentStage) {
      return this;
    }
    final completed = <OnboardingOperationStage>{...completedStages};
    final previousStage = currentStage;
    if (previousStage != null) {
      completed.add(previousStage);
    }
    return _copy(
      currentStage: stage,
      completedStages: List<OnboardingOperationStage>.unmodifiable(completed),
      stageStartedAtUtc: observedAtUtc,
      lastProgressObservedAtUtc: observedAtUtc,
      clearProgress: true,
      clearSubstage: true,
      progressRevision: progressRevision + 1,
    );
  }

  OnboardingOperationSnapshot observeProgress({
    required DateTime observedAtUtc,
    OnboardingOperationSubstage? substage,
    OnboardingOperationProgress? progress,
  }) {
    _requireRunning();
    if (substage == currentSubstage && progress == this.progress) {
      return this;
    }
    final observedAnomalyCounts =
        progress?.anomalyCounts ?? SourceImportAnomalyCounts.empty;
    return _copy(
      currentSubstage: substage,
      lastProgressObservedAtUtc: observedAtUtc,
      progress: progress,
      clearProgress: progress == null,
      progressRevision: progressRevision + 1,
      sourceAnomalyCounts: sourceAnomalyCounts.mergeMaximum(
        observedAnomalyCounts,
      ),
    );
  }

  OnboardingOperationSnapshot interrupt({required DateTime observedAtUtc}) {
    _requireRunning();
    return _copy(
      status: OnboardingOperationStatus.interrupted,
      finishedAtUtc: observedAtUtc,
      progressRevision: progressRevision + 1,
    );
  }

  OnboardingOperationSnapshot resume({
    required OnboardingProcessSessionId processSessionId,
    required DateTime observedAtUtc,
  }) {
    if (status != OnboardingOperationStatus.interrupted) {
      throw StateError('Only interrupted onboarding can resume.');
    }
    return _copy(
      status: OnboardingOperationStatus.running,
      processSessionId: processSessionId,
      lastProgressObservedAtUtc: observedAtUtc,
      clearFinishedAtUtc: true,
      progressRevision: progressRevision + 1,
    );
  }

  OnboardingOperationSnapshot fail({
    required OnboardingOperationFailure failure,
  }) {
    if (status != OnboardingOperationStatus.running &&
        status != OnboardingOperationStatus.interrupted) {
      throw StateError('Only running or interrupted onboarding can fail.');
    }
    return _copy(
      status: OnboardingOperationStatus.failed,
      failure: failure,
      finishedAtUtc: failure.occurredAtUtc,
      progressRevision: progressRevision + 1,
    );
  }

  OnboardingOperationSnapshot complete({required DateTime verifiedAtUtc}) {
    if (status != OnboardingOperationStatus.running &&
        status != OnboardingOperationStatus.interrupted) {
      throw StateError('Only running or interrupted onboarding can complete.');
    }
    final completed = <OnboardingOperationStage>{...completedStages};
    final finalStage = currentStage;
    if (finalStage != null) {
      completed.add(finalStage);
    }
    return _copy(
      status: OnboardingOperationStatus.completed,
      completedStages: List<OnboardingOperationStage>.unmodifiable(completed),
      lastProgressObservedAtUtc: verifiedAtUtc,
      finishedAtUtc: verifiedAtUtc,
      clearFailure: true,
      progressRevision: progressRevision + 1,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'format_version': currentFormatVersion,
      'status': status.name,
      'operation_id': operationId?.value,
      'process_session_id': processSessionId?.value,
      'kind': kind?.name,
      'current_stage': currentStage?.name,
      'current_substage': currentSubstage?.name,
      'completed_stages': completedStages.map((stage) => stage.name).toList(),
      'started_at_utc': startedAtUtc?.toIso8601String(),
      'stage_started_at_utc': stageStartedAtUtc?.toIso8601String(),
      'last_progress_observed_at_utc': lastProgressObservedAtUtc
          ?.toIso8601String(),
      'progress': progress?.toJson(),
      'progress_revision': progressRevision,
      'preserved_unnormalized_handle_count': preservedUnnormalizedHandleCount,
      'source_anomaly_counts': sourceAnomalyCounts.toJson(),
      'failure': failure?.toJson(),
      'finished_at_utc': finishedAtUtc?.toIso8601String(),
    };
  }

  factory OnboardingOperationSnapshot.fromJson(Map<String, Object?> json) {
    if (json['format_version'] != currentFormatVersion) {
      throw const FormatException(
        'Unsupported onboarding operation snapshot format.',
      );
    }
    final status = _enumByName(
      OnboardingOperationStatus.values,
      json['status'],
      'operation status',
    );
    if (status == OnboardingOperationStatus.idle) {
      return const OnboardingOperationSnapshot.idle();
    }

    final completedRaw = json['completed_stages'];
    if (completedRaw is! List<Object?>) {
      throw const FormatException('Invalid completed onboarding stages.');
    }
    final progressRaw = json['progress'];
    final failureRaw = json['failure'];
    final snapshot = OnboardingOperationSnapshot._(
      status: status,
      operationId: OnboardingOperationId(
        _requiredString(json['operation_id'], 'operation identifier'),
      ),
      processSessionId: OnboardingProcessSessionId(
        _requiredString(json['process_session_id'], 'process session'),
      ),
      kind: _enumByName(
        OnboardingOperationKind.values,
        json['kind'],
        'operation kind',
      ),
      currentStage: _nullableEnumByName(
        OnboardingOperationStage.values,
        json['current_stage'],
        'current stage',
      ),
      currentSubstage: _nullableEnumByName(
        OnboardingOperationSubstage.values,
        json['current_substage'],
        'current substage',
      ),
      completedStages: List<OnboardingOperationStage>.unmodifiable(
        completedRaw.map(
          (value) => _enumByName(
            OnboardingOperationStage.values,
            value,
            'completed stage',
          ),
        ),
      ),
      startedAtUtc: _dateTime(json['started_at_utc'], 'operation start'),
      stageStartedAtUtc: _nullableDateTime(json['stage_started_at_utc']),
      lastProgressObservedAtUtc: _nullableDateTime(
        json['last_progress_observed_at_utc'],
      ),
      progress: progressRaw == null
          ? null
          : OnboardingOperationProgress.fromJson(
              _requiredMap(progressRaw, 'progress'),
            ),
      progressRevision: json['progress_revision'] as int? ?? 0,
      sourceAnomalyCounts: json['source_anomaly_counts'] == null
          ? SourceImportAnomalyCounts(
              preservedUnnormalizedHandleCount:
                  json['preserved_unnormalized_handle_count'] as int? ?? 0,
            )
          : SourceImportAnomalyCounts.fromJson(
              _requiredMap(
                json['source_anomaly_counts'],
                'source anomaly counts',
              ),
            ),
      failure: failureRaw == null
          ? null
          : OnboardingOperationFailure.fromJson(
              _requiredMap(failureRaw, 'failure'),
            ),
      finishedAtUtc: _nullableDateTime(json['finished_at_utc']),
    );
    snapshot._validateShape();
    return snapshot;
  }

  void _validateShape() {
    if (operationId == null ||
        processSessionId == null ||
        kind == null ||
        currentStage == null ||
        startedAtUtc == null) {
      throw const FormatException('Incomplete onboarding operation snapshot.');
    }
    if (status == OnboardingOperationStatus.failed && failure == null) {
      throw const FormatException('Failed onboarding snapshot lacks failure.');
    }
    if (status == OnboardingOperationStatus.running && finishedAtUtc != null) {
      throw const FormatException('Running onboarding snapshot is finished.');
    }
  }

  void _requireRunning() {
    if (status != OnboardingOperationStatus.running) {
      throw StateError('Onboarding operation is not running.');
    }
  }

  OnboardingOperationSnapshot _copy({
    OnboardingOperationStatus? status,
    OnboardingProcessSessionId? processSessionId,
    OnboardingOperationStage? currentStage,
    OnboardingOperationSubstage? currentSubstage,
    bool clearSubstage = false,
    List<OnboardingOperationStage>? completedStages,
    DateTime? stageStartedAtUtc,
    DateTime? lastProgressObservedAtUtc,
    OnboardingOperationProgress? progress,
    bool clearProgress = false,
    int? progressRevision,
    SourceImportAnomalyCounts? sourceAnomalyCounts,
    OnboardingOperationFailure? failure,
    bool clearFailure = false,
    DateTime? finishedAtUtc,
    bool clearFinishedAtUtc = false,
  }) {
    return OnboardingOperationSnapshot._(
      status: status ?? this.status,
      operationId: operationId,
      processSessionId: processSessionId ?? this.processSessionId,
      kind: kind,
      currentStage: currentStage ?? this.currentStage,
      currentSubstage: clearSubstage
          ? null
          : currentSubstage ?? this.currentSubstage,
      completedStages: completedStages ?? this.completedStages,
      startedAtUtc: startedAtUtc,
      stageStartedAtUtc: stageStartedAtUtc ?? this.stageStartedAtUtc,
      lastProgressObservedAtUtc:
          lastProgressObservedAtUtc ?? this.lastProgressObservedAtUtc,
      progress: clearProgress ? null : progress ?? this.progress,
      progressRevision: progressRevision ?? this.progressRevision,
      sourceAnomalyCounts: sourceAnomalyCounts ?? this.sourceAnomalyCounts,
      failure: clearFailure ? null : failure ?? this.failure,
      finishedAtUtc: clearFinishedAtUtc
          ? null
          : finishedAtUtc ?? this.finishedAtUtc,
    );
  }
}

T _enumByName<T extends Enum>(List<T> values, Object? raw, String fieldName) {
  if (raw is! String) {
    throw FormatException('Invalid $fieldName.');
  }
  return values.firstWhere(
    (value) => value.name == raw,
    orElse: () => throw FormatException('Unknown $fieldName: $raw'),
  );
}

T? _nullableEnumByName<T extends Enum>(
  List<T> values,
  Object? raw,
  String fieldName,
) {
  if (raw == null) {
    return null;
  }
  return _enumByName(values, raw, fieldName);
}

String _requiredString(Object? raw, String fieldName) {
  if (raw is! String || raw.trim().isEmpty) {
    throw FormatException('Invalid $fieldName.');
  }
  return raw;
}

DateTime _dateTime(Object? raw, String fieldName) {
  final parsed = raw is String ? DateTime.tryParse(raw)?.toUtc() : null;
  if (parsed == null) {
    throw FormatException('Invalid $fieldName.');
  }
  return parsed;
}

DateTime? _nullableDateTime(Object? raw) {
  if (raw == null) {
    return null;
  }
  return _dateTime(raw, 'timestamp');
}

Map<String, Object?> _requiredMap(Object? raw, String fieldName) {
  if (raw is! Map<String, Object?>) {
    throw FormatException('Invalid $fieldName.');
  }
  return raw;
}
