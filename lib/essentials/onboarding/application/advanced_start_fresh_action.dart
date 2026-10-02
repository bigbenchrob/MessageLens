import 'dart:async';

import '../../archive_environment/domain/archive_mutation_denied_exception.dart';
import '../domain/advanced_start_fresh_presentation.dart';
import '../domain/message_lens_installation_state.dart';
import 'advanced_start_fresh_presentation_provider.dart';
import 'start_fresh_service.dart';

enum AdvancedStartFreshActionResult {
  cancelled,
  startedFresh,
  failed,
  superseded,
}

enum AdvancedStartFreshLifecycleEvent {
  requestReceived,
  requestClaimed,
  duplicateRequestJoined,
  currentStateReadStarted,
  currentStateReadCompleted,
  authorizationRequested,
  authorizationCancelled,
  authorizationAccepted,
  serviceStarted,
  serviceCompleted,
  terminalPresentationPublished,
  requestReleased,
}

typedef AdvancedStartFreshLifecycleReporter =
    void Function(
      AdvancedStartFreshLifecycleEvent event, {
      required int requestId,
      String? detail,
    });

abstract interface class AdvancedStartFreshAction {
  Future<AdvancedStartFreshActionResult> request();

  Future<AdvancedStartFreshActionResult> retry({required int occurrence});

  void dismissFailure({required int occurrence});
}

final class AdvancedStartFreshActionImpl implements AdvancedStartFreshAction {
  AdvancedStartFreshActionImpl({
    required this.readInstallationState,
    required this.requestAuthorization,
    required this.readStartFreshService,
    required this.presentation,
    required this.waitForPresentationFrame,
    required this.reportFailure,
    this.reportLifecycle = _ignoreLifecycleEvent,
  });

  final Future<MessageLensInstallationState> Function() readInstallationState;
  final Future<bool> Function() requestAuthorization;
  final Future<StartFreshService> Function() readStartFreshService;
  final AdvancedStartFreshPresentationPort presentation;
  final Future<void> Function() waitForPresentationFrame;
  final void Function(Object error, StackTrace stackTrace) reportFailure;
  final AdvancedStartFreshLifecycleReporter reportLifecycle;

  int _lastRequestId = 0;
  _ActiveAdvancedStartFreshRequest? _activeRequest;
  Future<void>? _activeExecution;

  @override
  Future<AdvancedStartFreshActionResult> request() {
    return _claimRequest(origin: 'request', run: _runInitialRequest);
  }

  Future<AdvancedStartFreshActionResult> _runInitialRequest(
    int requestId,
  ) async {
    _recordLifecycle(
      AdvancedStartFreshLifecycleEvent.currentStateReadStarted,
      requestId: requestId,
    );
    late final MessageLensInstallationState installationState;
    try {
      installationState = await readInstallationState();
      _recordLifecycle(
        AdvancedStartFreshLifecycleEvent.currentStateReadCompleted,
        requestId: requestId,
        detail: installationState.kind.name,
      );
    } catch (error, stackTrace) {
      reportFailure(error, stackTrace);
      _recordLifecycle(
        AdvancedStartFreshLifecycleEvent.currentStateReadCompleted,
        requestId: requestId,
        detail: 'unavailable',
      );
      return _presentInitialFailure(
        const AdvancedStartFreshFailure(
          kind: AdvancedStartFreshFailureKind.installationStateUnavailable,
          summary:
              'MessageLens could not verify whether Reset Message Data is '
              'available. No data was changed.',
          canRetry: false,
        ),
        requestId: requestId,
      );
    }

    if (installationState.kind != MessageLensInstallationStateKind.completed) {
      return _presentInitialFailure(
        AdvancedStartFreshFailure(
          kind: AdvancedStartFreshFailureKind.installationIneligible,
          summary: _ineligibleSummary(installationState.kind),
          canRetry: false,
        ),
        requestId: requestId,
      );
    }

    try {
      _recordLifecycle(
        AdvancedStartFreshLifecycleEvent.authorizationRequested,
        requestId: requestId,
      );
      if (!await requestAuthorization()) {
        _recordLifecycle(
          AdvancedStartFreshLifecycleEvent.authorizationCancelled,
          requestId: requestId,
        );
        return AdvancedStartFreshActionResult.cancelled;
      }
      _recordLifecycle(
        AdvancedStartFreshLifecycleEvent.authorizationAccepted,
        requestId: requestId,
      );
    } catch (error, stackTrace) {
      reportFailure(error, stackTrace);
      return _presentInitialFailure(
        const AdvancedStartFreshFailure(
          kind: AdvancedStartFreshFailureKind.executionFailed,
          summary:
              'MessageLens could not open Reset Message Data. No data was '
              'changed.',
          canRetry: false,
        ),
        requestId: requestId,
      );
    }

    final occurrence = presentation.beginPreparing();
    return _execute(
      requestId: requestId,
      occurrence: occurrence,
      entryPoint: StartFreshEntryPoint.completedInstallationAdvancedReset,
    );
  }

  @override
  Future<AdvancedStartFreshActionResult> retry({required int occurrence}) {
    return _claimRequest(
      origin: 'retry',
      run: (requestId) {
        return _runRetry(requestId: requestId, occurrence: occurrence);
      },
    );
  }

  Future<AdvancedStartFreshActionResult> _runRetry({
    required int requestId,
    required int occurrence,
  }) async {
    final nextOccurrence = presentation.beginRetry(
      expectedOccurrence: occurrence,
    );
    if (nextOccurrence == null) {
      return AdvancedStartFreshActionResult.superseded;
    }

    return _execute(requestId: requestId, occurrence: nextOccurrence);
  }

  @override
  void dismissFailure({required int occurrence}) {
    presentation.dismiss(expectedOccurrence: occurrence);
  }

  AdvancedStartFreshActionResult _presentInitialFailure(
    AdvancedStartFreshFailure failure, {
    required int requestId,
  }) {
    final occurrence = presentation.beginPreparing();
    presentation.showFailure(expectedOccurrence: occurrence, failure: failure);
    _recordLifecycle(
      AdvancedStartFreshLifecycleEvent.terminalPresentationPublished,
      requestId: requestId,
      detail: failure.kind.name,
    );
    return AdvancedStartFreshActionResult.failed;
  }

  Future<AdvancedStartFreshActionResult> _execute({
    required int requestId,
    required int occurrence,
    StartFreshEntryPoint? entryPoint,
  }) async {
    await waitForPresentationFrame();
    if (!presentation.isCurrent(occurrence)) {
      return AdvancedStartFreshActionResult.superseded;
    }

    try {
      final resolvedEntryPoint = entryPoint ?? await _resolveRetryEntryPoint();
      final service = await readStartFreshService();
      _recordLifecycle(
        AdvancedStartFreshLifecycleEvent.serviceStarted,
        requestId: requestId,
        detail: resolvedEntryPoint.name,
      );
      await service.startFresh(entryPoint: resolvedEntryPoint);
      _recordLifecycle(
        AdvancedStartFreshLifecycleEvent.serviceCompleted,
        requestId: requestId,
        detail: 'verifiedVirgin',
      );
      presentation.showVerifiedVirgin(expectedOccurrence: occurrence);
      if (!presentation.isCurrent(occurrence)) {
        return AdvancedStartFreshActionResult.superseded;
      }
      _recordLifecycle(
        AdvancedStartFreshLifecycleEvent.terminalPresentationPublished,
        requestId: requestId,
        detail: 'verifiedVirgin',
      );
      await presentation.waitUntilDismissed(expectedOccurrence: occurrence);
      return presentation.isCurrent(occurrence)
          ? AdvancedStartFreshActionResult.startedFresh
          : AdvancedStartFreshActionResult.superseded;
    } catch (error, stackTrace) {
      reportFailure(error, stackTrace);
      _recordLifecycle(
        AdvancedStartFreshLifecycleEvent.serviceCompleted,
        requestId: requestId,
        detail: 'failed',
      );
      final failure = await _failureFor(error);
      presentation.showFailure(
        expectedOccurrence: occurrence,
        failure: failure,
      );
      if (presentation.isCurrent(occurrence)) {
        _recordLifecycle(
          AdvancedStartFreshLifecycleEvent.terminalPresentationPublished,
          requestId: requestId,
          detail: failure.kind.name,
        );
      }
      return presentation.isCurrent(occurrence)
          ? AdvancedStartFreshActionResult.failed
          : AdvancedStartFreshActionResult.superseded;
    }
  }

  Future<AdvancedStartFreshActionResult> _claimRequest({
    required String origin,
    required Future<AdvancedStartFreshActionResult> Function(int requestId) run,
  }) {
    final activeRequest = _activeRequest;
    if (activeRequest != null) {
      assert(
        _activeExecution != null,
        'An active Advanced Start Fresh claim must retain its execution.',
      );
      _recordLifecycle(
        AdvancedStartFreshLifecycleEvent.requestReceived,
        requestId: activeRequest.requestId,
        detail: '$origin-duplicate',
      );
      _recordLifecycle(
        AdvancedStartFreshLifecycleEvent.duplicateRequestJoined,
        requestId: activeRequest.requestId,
        detail: origin,
      );
      return activeRequest.completer.future;
    }

    final requestId = ++_lastRequestId;
    _recordLifecycle(
      AdvancedStartFreshLifecycleEvent.requestReceived,
      requestId: requestId,
      detail: origin,
    );
    final claimedRequest = _ActiveAdvancedStartFreshRequest(
      requestId: requestId,
      completer: Completer<AdvancedStartFreshActionResult>(),
    );
    _activeRequest = claimedRequest;
    _recordLifecycle(
      AdvancedStartFreshLifecycleEvent.requestClaimed,
      requestId: requestId,
      detail: origin,
    );
    _activeExecution = _runClaimedRequest(
      claimedRequest: claimedRequest,
      run: run,
    );
    return claimedRequest.completer.future;
  }

  Future<void> _runClaimedRequest({
    required _ActiveAdvancedStartFreshRequest claimedRequest,
    required Future<AdvancedStartFreshActionResult> Function(int requestId) run,
  }) async {
    late final AdvancedStartFreshActionResult result;
    try {
      result = await run(claimedRequest.requestId);
    } catch (error, stackTrace) {
      reportFailure(error, stackTrace);
      result = _presentInitialFailure(
        const AdvancedStartFreshFailure(
          kind: AdvancedStartFreshFailureKind.executionFailed,
          summary:
              'MessageLens could not finish Reset Message Data. No further '
              'data was changed.',
          canRetry: false,
        ),
        requestId: claimedRequest.requestId,
      );
    }

    if (identical(_activeRequest, claimedRequest)) {
      _activeRequest = null;
      _activeExecution = null;
    }
    _recordLifecycle(
      AdvancedStartFreshLifecycleEvent.requestReleased,
      requestId: claimedRequest.requestId,
      detail: result.name,
    );
    claimedRequest.completer.complete(result);
  }

  void _recordLifecycle(
    AdvancedStartFreshLifecycleEvent event, {
    required int requestId,
    String? detail,
  }) {
    try {
      reportLifecycle(event, requestId: requestId, detail: detail);
    } catch (error, stackTrace) {
      reportFailure(error, stackTrace);
    }
  }

  Future<StartFreshEntryPoint> _resolveRetryEntryPoint() async {
    final installationState = await readInstallationState();
    return switch (installationState.kind) {
      MessageLensInstallationStateKind.completed =>
        StartFreshEntryPoint.completedInstallationAdvancedReset,
      MessageLensInstallationStateKind.resumable ||
      MessageLensInstallationStateKind.abandoned =>
        StartFreshEntryPoint.incompleteInstallation,
      _ => throw StateError(
        'Start Fresh retry is unavailable for '
        '${installationState.kind.name}: ${installationState.reason}',
      ),
    };
  }

  Future<AdvancedStartFreshFailure> _failureFor(Object error) async {
    final kind = switch (error) {
      ArchiveMutationDeniedException() =>
        AdvancedStartFreshFailureKind.mutationUnavailable,
      StartFreshVirginVerificationException() =>
        AdvancedStartFreshFailureKind.virginVerificationFailed,
      _ => AdvancedStartFreshFailureKind.executionFailed,
    };
    var canRetry = false;
    try {
      final installationState = await readInstallationState();
      canRetry =
          installationState.kind ==
              MessageLensInstallationStateKind.completed ||
          installationState.mayStartFresh;
    } catch (error, stackTrace) {
      reportFailure(error, stackTrace);
      canRetry = false;
    }

    final summary = switch (kind) {
      AdvancedStartFreshFailureKind.installationIneligible =>
        'Reset Message Data is not available for the current installation.',
      AdvancedStartFreshFailureKind.installationStateUnavailable =>
        'MessageLens could not verify the current installation state.',
      AdvancedStartFreshFailureKind.mutationUnavailable =>
        'Another MessageLens data operation is still active.',
      AdvancedStartFreshFailureKind.virginVerificationFailed =>
        'MessageLens could not verify a clean onboarding state.',
      AdvancedStartFreshFailureKind.executionFailed =>
        'MessageLens could not finish starting fresh.',
    };
    return AdvancedStartFreshFailure(
      kind: kind,
      summary: summary,
      canRetry: canRetry,
    );
  }
}

final class _ActiveAdvancedStartFreshRequest {
  const _ActiveAdvancedStartFreshRequest({
    required this.requestId,
    required this.completer,
  });

  final int requestId;
  final Completer<AdvancedStartFreshActionResult> completer;
}

void _ignoreLifecycleEvent(
  AdvancedStartFreshLifecycleEvent event, {
  required int requestId,
  String? detail,
}) {}

String _ineligibleSummary(MessageLensInstallationStateKind kind) {
  final currentCondition = switch (kind) {
    MessageLensInstallationStateKind.virgin =>
      'before MessageLens setup has completed',
    MessageLensInstallationStateKind.resumable =>
      'while MessageLens has resumable setup work',
    MessageLensInstallationStateKind.abandoned =>
      'while MessageLens has incomplete setup artifacts',
    MessageLensInstallationStateKind.remediationRequired =>
      'while this installation requires attention',
    MessageLensInstallationStateKind.completed =>
      'for the current installation',
  };
  return 'Reset Message Data is unavailable $currentCondition. '
      'No data was changed.';
}
