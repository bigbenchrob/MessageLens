import 'dart:async';

import 'package:uuid/uuid.dart';

import '../../source_scoped_import/domain/source_import_anomaly_counts.dart';
import '../domain/onboarding_operation_snapshot.dart';
import 'onboarding_operation_snapshot_store.dart';

enum OnboardingDurableReconciliationState {
  unavailable,
  resumable,
  inconsistent,
  completed,
}

sealed class OnboardingOperationCompletionProof {
  const OnboardingOperationCompletionProof({required this.verifiedAtUtc});

  final DateTime verifiedAtUtc;
}

final class OnboardingInstallationReadyProof
    extends OnboardingOperationCompletionProof {
  OnboardingInstallationReadyProof({
    required super.verifiedAtUtc,
    required this.sourceScopedImportRows,
    required this.conversationGraphRows,
  }) {
    if (sourceScopedImportRows <= 0 || conversationGraphRows <= 0) {
      throw ArgumentError(
        'Installation readiness requires populated import and graph stores.',
      );
    }
  }

  final int sourceScopedImportRows;
  final int conversationGraphRows;
}

final class OnboardingDerivedResetCompletedProof
    extends OnboardingOperationCompletionProof {
  const OnboardingDerivedResetCompletedProof({required super.verifiedAtUtc});
}

final class OnboardingDurableReconciliationEvidence {
  const OnboardingDurableReconciliationEvidence._({
    required this.state,
    this.completionProof,
    this.failureSummary,
  });

  const OnboardingDurableReconciliationEvidence.unavailable()
    : this._(state: OnboardingDurableReconciliationState.unavailable);

  const OnboardingDurableReconciliationEvidence.resumable()
    : this._(state: OnboardingDurableReconciliationState.resumable);

  const OnboardingDurableReconciliationEvidence.inconsistent({
    required String failureSummary,
  }) : this._(
         state: OnboardingDurableReconciliationState.inconsistent,
         failureSummary: failureSummary,
       );

  const OnboardingDurableReconciliationEvidence.completed({
    required OnboardingOperationCompletionProof proof,
  }) : this._(
         state: OnboardingDurableReconciliationState.completed,
         completionProof: proof,
       );

  final OnboardingDurableReconciliationState state;
  final OnboardingOperationCompletionProof? completionProof;
  final String? failureSummary;
}

final class OnboardingProgressReporter {
  const OnboardingProgressReporter._({
    required this.operationId,
    required Future<void> Function({
      required OnboardingOperationId operationId,
      OnboardingOperationSubstage? substage,
      required OnboardingOperationProgress? progress,
    })
    report,
  }) : _report = report;

  final OnboardingOperationId operationId;
  final Future<void> Function({
    required OnboardingOperationId operationId,
    OnboardingOperationSubstage? substage,
    required OnboardingOperationProgress? progress,
  })
  _report;

  Future<void> observe({
    required OnboardingOperationSubstage substage,
    int? completedWorkUnits,
    int? totalWorkUnits,
    int? lastCompletedSourceRowId,
    SourceImportAnomalyCounts anomalyCounts = SourceImportAnomalyCounts.empty,
    int preservedUnnormalizedCount = 0,
  }) async {
    if ((completedWorkUnits == null) != (totalWorkUnits == null)) {
      throw ArgumentError(
        'Completed and total work units must be supplied together.',
      );
    }
    await _report(
      operationId: operationId,
      substage: substage,
      progress: completedWorkUnits == null
          ? null
          : OnboardingOperationProgress(
              completedWorkUnits: completedWorkUnits,
              totalWorkUnits: totalWorkUnits!,
              lastCompletedSourceRowId: lastCompletedSourceRowId,
              anomalyCounts: SourceImportAnomalyCounts(
                preservedUnnormalizedHandleCount: preservedUnnormalizedCount,
              ).mergeMaximum(anomalyCounts),
            ),
    );
  }
}

/// Owns typed, durable publication of admitted Onboarding work.
///
/// This controller records operational truth. It never grants mutation
/// authority and cannot substitute its snapshot for import or graph data.
final class OnboardingOperationSnapshotController {
  OnboardingOperationSnapshotController({
    required OnboardingOperationSnapshotStore store,
    required OnboardingProcessSessionId processSessionId,
    DateTime Function()? now,
    String Function()? newOperationId,
  }) : _store = store,
       _processSessionId = processSessionId,
       _now = now ?? (() => DateTime.now().toUtc()),
       _newOperationId = newOperationId ?? (() => const Uuid().v4());

  final OnboardingOperationSnapshotStore _store;
  final OnboardingProcessSessionId _processSessionId;
  final DateTime Function() _now;
  final String Function() _newOperationId;
  final StreamController<OnboardingOperationSnapshot> _changes =
      StreamController<OnboardingOperationSnapshot>.broadcast(sync: true);

  OnboardingOperationSnapshot _current =
      const OnboardingOperationSnapshot.idle();
  Future<void> _writeTail = Future<void>.value();

  OnboardingOperationSnapshot get current => _current;

  Stream<OnboardingOperationSnapshot> get changes => _changes.stream;

  Future<void> initialize() async {
    final persisted = await _store.load();
    _current = persisted ?? const OnboardingOperationSnapshot.idle();
    if (_current.status == OnboardingOperationStatus.running &&
        _current.processSessionId != _processSessionId) {
      await _publish(_current.interrupt(observedAtUtc: _now()));
      return;
    }
    _changes.add(_current);
  }

  Future<OnboardingOperationId> begin({
    required OnboardingOperationKind kind,
    required OnboardingOperationStage initialStage,
  }) async {
    if (_current.status == OnboardingOperationStatus.running) {
      throw StateError('An onboarding operation is already running.');
    }
    final operationId = OnboardingOperationId(_newOperationId());
    await _publish(
      OnboardingOperationSnapshot.running(
        operationId: operationId,
        processSessionId: _processSessionId,
        kind: kind,
        stage: initialStage,
        observedAtUtc: _now(),
      ),
    );
    return operationId;
  }

  /// Clears only Onboarding operation evidence after an authorized fresh start.
  Future<void> resetToIdle() async {
    await _publish(const OnboardingOperationSnapshot.idle());
  }

  Future<void> enterStage({
    required OnboardingOperationId operationId,
    required OnboardingOperationStage stage,
  }) async {
    _requireCurrent(operationId);
    final next = _current.transitionToStage(
      stage: stage,
      observedAtUtc: _now(),
    );
    if (identical(next, _current)) {
      return;
    }
    await _publish(next);
  }

  Future<void> reportProgress({
    required OnboardingOperationId operationId,
    OnboardingOperationSubstage? substage,
    required OnboardingOperationProgress? progress,
  }) async {
    _requireCurrent(operationId);
    final next = _current.observeProgress(
      observedAtUtc: _now(),
      substage: substage,
      progress: progress,
    );
    if (identical(next, _current)) {
      return;
    }
    await _publish(next);
  }

  Future<T> runStage<T>({
    required OnboardingOperationId operationId,
    required OnboardingOperationStage stage,
    required Future<T> Function(OnboardingProgressReporter progress) action,
  }) async {
    await enterStage(operationId: operationId, stage: stage);
    final reporter = OnboardingProgressReporter._(
      operationId: operationId,
      report: reportProgress,
    );
    return Future<T>.sync(() => action(reporter));
  }

  /// Resumes the same logical operation in this process session.
  ///
  /// Persistence completes before the resumed snapshot is published, so the
  /// Journey owner never has to present an operation that is not yet durable.
  Future<OnboardingOperationId> resume({
    required OnboardingOperationId operationId,
  }) async {
    if (_current.operationId != operationId ||
        _current.status != OnboardingOperationStatus.interrupted) {
      throw StateError('Onboarding operation is not resumable.');
    }
    await _publish(
      _current.resume(
        processSessionId: _processSessionId,
        observedAtUtc: _now(),
      ),
    );
    return operationId;
  }

  Future<void> fail({
    required OnboardingOperationId operationId,
    required OnboardingOperationFailureCategory category,
    required String summary,
    required OnboardingOperationRecoveryDisposition recoveryDisposition,
  }) async {
    _requireCurrent(operationId, allowInterrupted: true);
    await _publish(
      _current.fail(
        failure: OnboardingOperationFailure(
          category: category,
          occurredAtUtc: _now(),
          summary: _boundedSummary(summary),
          recoveryDisposition: recoveryDisposition,
        ),
      ),
    );
  }

  Future<void> complete({
    required OnboardingOperationId operationId,
    required OnboardingOperationCompletionProof proof,
  }) async {
    _requireCurrent(operationId, allowInterrupted: true);
    _requireCompatibleCompletionProof(_current.kind!, proof);
    await _publish(_current.complete(verifiedAtUtc: proof.verifiedAtUtc));
  }

  Future<void> reconcile(
    OnboardingDurableReconciliationEvidence evidence,
  ) async {
    if (_current.status != OnboardingOperationStatus.interrupted) {
      return;
    }
    final operationId = _current.operationId!;
    switch (evidence.state) {
      case OnboardingDurableReconciliationState.unavailable:
      case OnboardingDurableReconciliationState.resumable:
        return;
      case OnboardingDurableReconciliationState.inconsistent:
        await fail(
          operationId: operationId,
          category: OnboardingOperationFailureCategory.durableStateInconsistent,
          summary:
              evidence.failureSummary ?? 'Durable onboarding state conflicts.',
          recoveryDisposition:
              OnboardingOperationRecoveryDisposition.retryFromSafeBoundary,
        );
      case OnboardingDurableReconciliationState.completed:
        final proof = evidence.completionProof;
        if (proof == null) {
          throw StateError('Completed reconciliation lacks durable proof.');
        }
        await complete(operationId: operationId, proof: proof);
    }
  }

  Future<void> dispose() async {
    await _writeTail;
    await _changes.close();
  }

  void _requireCurrent(
    OnboardingOperationId operationId, {
    bool allowInterrupted = false,
  }) {
    if (_current.operationId != operationId) {
      throw StateError('Stale onboarding operation identity.');
    }
    final permitted =
        _current.status == OnboardingOperationStatus.running ||
        (allowInterrupted &&
            _current.status == OnboardingOperationStatus.interrupted);
    if (!permitted) {
      throw StateError('Onboarding operation is not mutable.');
    }
  }

  void _requireCompatibleCompletionProof(
    OnboardingOperationKind kind,
    OnboardingOperationCompletionProof proof,
  ) {
    final compatible = switch (kind) {
      OnboardingOperationKind.initialImport ||
      OnboardingOperationKind.reimport =>
        proof is OnboardingInstallationReadyProof,
      OnboardingOperationKind.automaticRecovery =>
        proof is OnboardingDerivedResetCompletedProof ||
            proof is OnboardingInstallationReadyProof,
    };
    if (!compatible) {
      throw StateError('Completion proof does not establish operation truth.');
    }
  }

  Future<void> _publish(OnboardingOperationSnapshot next) {
    final previousWrite = _writeTail;
    final tailCompletion = Completer<void>();
    _writeTail = tailCompletion.future;
    return _saveAfterPreviousWrite(
      previousWrite: previousWrite,
      tailCompletion: tailCompletion,
      next: next,
    );
  }

  Future<void> _saveAfterPreviousWrite({
    required Future<void> previousWrite,
    required Completer<void> tailCompletion,
    required OnboardingOperationSnapshot next,
  }) async {
    await previousWrite;
    try {
      await _store.save(next);
      _current = next;
      _changes.add(next);
    } finally {
      tailCompletion.complete();
    }
  }

  String _boundedSummary(Object error) {
    final normalized = error.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.length <= 500) {
      return normalized;
    }
    return '${normalized.substring(0, 497)}...';
  }
}
