import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/essentials/onboarding/application/advanced_start_fresh_action.dart';
import 'package:remember_this_text/essentials/onboarding/application/advanced_start_fresh_presentation_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/start_fresh_service.dart';
import 'package:remember_this_text/essentials/onboarding/domain/advanced_start_fresh_presentation.dart';
import 'package:remember_this_text/essentials/onboarding/domain/message_lens_installation_state.dart';

void main() {
  test(
    'completed installation requires authorization before advanced Start Fresh',
    () async {
      final service = _FakeStartFreshService();
      final presentation = _FakePresentationPort();
      final framePainted = Completer<void>();
      final authorizationRequested = Completer<void>();
      var authorizationRequests = 0;
      final action = AdvancedStartFreshActionImpl(
        readInstallationState: () async => _completedState,
        requestAuthorization: () async {
          authorizationRequests += 1;
          authorizationRequested.complete();
          return true;
        },
        readStartFreshService: () async => service,
        presentation: presentation,
        waitForPresentationFrame: () => framePainted.future,
        reportFailure: (_, _) {},
      );

      final resultFuture = action.request();
      await authorizationRequested.future;
      await presentation.preparingStarted.future;

      expect(
        presentation.state.phase,
        AdvancedStartFreshPresentationPhase.preparing,
      );
      expect(service.entryPoints, isEmpty);

      framePainted.complete();
      final result = await resultFuture;

      expect(result, AdvancedStartFreshActionResult.startedFresh);
      expect(authorizationRequests, 1);
      expect(service.entryPoints, [
        StartFreshEntryPoint.completedInstallationAdvancedReset,
      ]);
      expect(
        presentation.state.phase,
        AdvancedStartFreshPresentationPhase.verifiedVirgin,
      );
    },
  );

  test('cancelled authorization performs no Start Fresh mutation', () async {
    final service = _FakeStartFreshService();
    final action = AdvancedStartFreshActionImpl(
      readInstallationState: () async => _completedState,
      requestAuthorization: () async => false,
      readStartFreshService: () async => service,
      presentation: _FakePresentationPort(),
      waitForPresentationFrame: () async {},
      reportFailure: (_, _) {},
    );

    final result = await action.request();

    expect(result, AdvancedStartFreshActionResult.cancelled);
    expect(service.entryPoints, isEmpty);
  });

  test(
    'rapid requests during a slow current-state read join one claim',
    () async {
      final stateRead = Completer<MessageLensInstallationState>();
      final authorization = Completer<bool>();
      final authorizationStarted = Completer<void>();
      final lifecycle = <(AdvancedStartFreshLifecycleEvent, int)>[];
      var stateReadCount = 0;
      var authorizationCount = 0;
      final presentation = _FakePresentationPort();
      final action = AdvancedStartFreshActionImpl(
        readInstallationState: () {
          stateReadCount += 1;
          return stateRead.future;
        },
        requestAuthorization: () {
          authorizationCount += 1;
          authorizationStarted.complete();
          return authorization.future;
        },
        readStartFreshService: () async => _FakeStartFreshService(),
        presentation: presentation,
        waitForPresentationFrame: () async {},
        reportFailure: (_, _) {},
        reportLifecycle: (event, {required requestId, detail}) {
          lifecycle.add((event, requestId));
        },
      );

      final first = action.request();
      final duplicate = action.request();

      expect(identical(first, duplicate), isTrue);
      expect(stateReadCount, 1);
      expect(authorizationCount, 0);
      expect(presentation.beginPreparingCount, 0);
      expect(
        lifecycle.where(
          (entry) =>
              entry.$1 ==
              AdvancedStartFreshLifecycleEvent.duplicateRequestJoined,
        ),
        hasLength(1),
      );
      expect(lifecycle.map((entry) => entry.$2).toSet(), {1});

      stateRead.complete(_completedState);
      await authorizationStarted.future;
      authorization.complete(false);

      expect(await first, AdvancedStartFreshActionResult.cancelled);
      expect(stateReadCount, 1);
      expect(authorizationCount, 1);
      expect(presentation.beginPreparingCount, 0);
    },
  );

  test(
    'requests while authorization is pending do not reclassify or restack',
    () async {
      final authorization = Completer<bool>();
      final authorizationStarted = Completer<void>();
      var stateReadCount = 0;
      var authorizationCount = 0;
      final action = AdvancedStartFreshActionImpl(
        readInstallationState: () async {
          stateReadCount += 1;
          return _completedState;
        },
        requestAuthorization: () {
          authorizationCount += 1;
          authorizationStarted.complete();
          return authorization.future;
        },
        readStartFreshService: () async => _FakeStartFreshService(),
        presentation: _FakePresentationPort(),
        waitForPresentationFrame: () async {},
        reportFailure: (_, _) {},
      );

      final first = action.request();
      await authorizationStarted.future;
      final duplicate = action.request();

      expect(identical(first, duplicate), isTrue);
      expect(stateReadCount, 1);
      expect(authorizationCount, 1);
      authorization.complete(false);
      expect(await duplicate, AdvancedStartFreshActionResult.cancelled);
    },
  );

  test(
    'requests while service is pending share one service and occurrence',
    () async {
      final service = _ControlledStartFreshService();
      final presentation = _FakePresentationPort();
      final action = AdvancedStartFreshActionImpl(
        readInstallationState: () async => _completedState,
        requestAuthorization: () async => true,
        readStartFreshService: () async => service,
        presentation: presentation,
        waitForPresentationFrame: () async {},
        reportFailure: (_, _) {},
      );

      final first = action.request();
      await service.started.future;
      final duplicate = action.request();

      expect(identical(first, duplicate), isTrue);
      expect(service.entryPoints, hasLength(1));
      expect(presentation.beginPreparingCount, 1);
      service.completion.complete(_virginResult);
      expect(await duplicate, AdvancedStartFreshActionResult.startedFresh);
      expect(presentation.verifiedCount, 1);
    },
  );

  test(
    'verified success retains the claim until presentation handoff dismisses',
    () async {
      final service = _ControlledStartFreshService();
      final presentation = _FakePresentationPort(autoDismiss: false);
      final action = AdvancedStartFreshActionImpl(
        readInstallationState: () async => _completedState,
        requestAuthorization: () async => true,
        readStartFreshService: () async => service,
        presentation: presentation,
        waitForPresentationFrame: () async {},
        reportFailure: (_, _) {},
      );

      final first = action.request();
      await service.started.future;
      final duplicateBeforeSuccess = action.request();
      service.completion.complete(_virginResult);
      await presentation.verified.future;
      final duplicateDuringHandoff = action.request();

      expect(identical(first, duplicateBeforeSuccess), isTrue);
      expect(identical(first, duplicateDuringHandoff), isTrue);
      expect(service.entryPoints, hasLength(1));
      expect(presentation.beginPreparingCount, 1);
      expect(presentation.failureCount, 0);

      presentation.dismiss(expectedOccurrence: presentation.state.occurrence);
      expect(await first, AdvancedStartFreshActionResult.startedFresh);
      expect(presentation.dismissCount, 1);
    },
  );

  test('cancel releases the claim and a later request may proceed', () async {
    final service = _FakeStartFreshService();
    var authorizationCount = 0;
    final action = AdvancedStartFreshActionImpl(
      readInstallationState: () async => _completedState,
      requestAuthorization: () async {
        authorizationCount += 1;
        return authorizationCount > 1;
      },
      readStartFreshService: () async => service,
      presentation: _FakePresentationPort(),
      waitForPresentationFrame: () async {},
      reportFailure: (_, _) {},
    );

    expect(await action.request(), AdvancedStartFreshActionResult.cancelled);
    expect(await action.request(), AdvancedStartFreshActionResult.startedFresh);
    expect(authorizationCount, 2);
    expect(service.entryPoints, hasLength(1));
  });

  test(
    'advanced reset presents typed ineligibility before authorization',
    () async {
      var authorizationRequested = false;
      final service = _FakeStartFreshService();
      final presentation = _FakePresentationPort();
      final action = AdvancedStartFreshActionImpl(
        readInstallationState: () async {
          return const MessageLensInstallationState(
            kind: MessageLensInstallationStateKind.abandoned,
            reason: 'incomplete test installation',
          );
        },
        requestAuthorization: () async {
          authorizationRequested = true;
          return true;
        },
        readStartFreshService: () async => service,
        presentation: presentation,
        waitForPresentationFrame: () async {},
        reportFailure: (_, _) {},
      );

      final result = await action.request();

      expect(result, AdvancedStartFreshActionResult.failed);
      expect(authorizationRequested, isFalse);
      expect(service.entryPoints, isEmpty);
      expect(
        presentation.state.failure?.kind,
        AdvancedStartFreshFailureKind.installationIneligible,
      );
      expect(presentation.state.failure?.canRetry, isFalse);
    },
  );

  test('current-state read failure is a typed visible outcome', () async {
    final reportedFailures = <Object>[];
    final presentation = _FakePresentationPort();
    final action = AdvancedStartFreshActionImpl(
      readInstallationState: () async => throw StateError('read failed'),
      requestAuthorization: () async => true,
      readStartFreshService: () async => _FakeStartFreshService(),
      presentation: presentation,
      waitForPresentationFrame: () async {},
      reportFailure: (error, _) {
        reportedFailures.add(error);
      },
    );

    final result = await action.request();

    expect(result, AdvancedStartFreshActionResult.failed);
    expect(reportedFailures, hasLength(1));
    expect(
      presentation.state.failure?.kind,
      AdvancedStartFreshFailureKind.installationStateUnavailable,
    );
    expect(presentation.state.failure?.canRetry, isFalse);
  });

  test(
    'typed failure remains visible and can retry from abandoned state',
    () async {
      final service = _FakeStartFreshService()..failure = StateError('disk');
      final presentation = _FakePresentationPort();
      var stateReadCount = 0;
      final action = AdvancedStartFreshActionImpl(
        readInstallationState: () async {
          stateReadCount += 1;
          return stateReadCount == 1 ? _completedState : _abandonedState;
        },
        requestAuthorization: () async => true,
        readStartFreshService: () async => service,
        presentation: presentation,
        waitForPresentationFrame: () async {},
        reportFailure: (_, _) {},
      );

      expect(await action.request(), AdvancedStartFreshActionResult.failed);
      final failedOccurrence = presentation.state.occurrence;
      expect(
        presentation.state.phase,
        AdvancedStartFreshPresentationPhase.failed,
      );
      expect(presentation.state.failure?.canRetry, isTrue);

      service.failure = null;
      expect(
        await action.retry(occurrence: failedOccurrence),
        AdvancedStartFreshActionResult.startedFresh,
      );
      expect(service.entryPoints, [
        StartFreshEntryPoint.completedInstallationAdvancedReset,
        StartFreshEntryPoint.incompleteInstallation,
      ]);
    },
  );

  test('virgin verification failure is a typed visible outcome', () async {
    final service = _FakeStartFreshService()
      ..failure = const StartFreshVirginVerificationException(
        verifiedState: MessageLensInstallationState(
          kind: MessageLensInstallationStateKind.remediationRequired,
          reason: 'derived evidence remains',
        ),
      );
    final presentation = _FakePresentationPort();
    var stateReadCount = 0;
    final action = AdvancedStartFreshActionImpl(
      readInstallationState: () async {
        stateReadCount += 1;
        return stateReadCount == 1 ? _completedState : _remediationState;
      },
      requestAuthorization: () async => true,
      readStartFreshService: () async => service,
      presentation: presentation,
      waitForPresentationFrame: () async {},
      reportFailure: (_, _) {},
    );

    expect(await action.request(), AdvancedStartFreshActionResult.failed);
    expect(
      presentation.state.failure?.kind,
      AdvancedStartFreshFailureKind.virginVerificationFailed,
    );
    expect(presentation.state.failure?.canRetry, isFalse);
  });

  test(
    'service failure remains visible and duplicate input cannot mask it',
    () async {
      final service = _ControlledStartFreshService();
      final presentation = _FakePresentationPort();
      var stateReadCount = 0;
      final action = AdvancedStartFreshActionImpl(
        readInstallationState: () async {
          stateReadCount += 1;
          return stateReadCount == 1 ? _completedState : _abandonedState;
        },
        requestAuthorization: () async => true,
        readStartFreshService: () async => service,
        presentation: presentation,
        waitForPresentationFrame: () async {},
        reportFailure: (_, _) {},
      );

      final first = action.request();
      await service.started.future;
      final duplicate = action.request();
      service.completion.completeError(StateError('disk'));

      expect(await first, AdvancedStartFreshActionResult.failed);
      expect(await duplicate, AdvancedStartFreshActionResult.failed);
      expect(service.entryPoints, hasLength(1));
      expect(presentation.beginPreparingCount, 1);
      expect(
        presentation.state.phase,
        AdvancedStartFreshPresentationPhase.failed,
      );
      expect(presentation.state.failure?.canRetry, isTrue);
      expect(presentation.failureCount, 1);
    },
  );
}

const _completedState = MessageLensInstallationState(
  kind: MessageLensInstallationStateKind.completed,
  reason: 'healthy completed test installation',
);

const _abandonedState = MessageLensInstallationState(
  kind: MessageLensInstallationStateKind.abandoned,
  reason: 'retryable partial reset',
);

const _remediationState = MessageLensInstallationState(
  kind: MessageLensInstallationStateKind.remediationRequired,
  reason: 'manual inspection required',
);

const _virginResult = StartFreshResult(
  verifiedState: MessageLensInstallationState(
    kind: MessageLensInstallationStateKind.virgin,
    reason: 'verified test reset',
  ),
);

final class _FakeStartFreshService implements StartFreshService {
  final entryPoints = <StartFreshEntryPoint>[];
  Object? failure;

  @override
  Future<StartFreshResult> startFresh({
    StartFreshEntryPoint entryPoint =
        StartFreshEntryPoint.incompleteInstallation,
  }) async {
    entryPoints.add(entryPoint);
    if (failure case final currentFailure?) {
      throw currentFailure;
    }
    return _virginResult;
  }
}

final class _ControlledStartFreshService implements StartFreshService {
  final entryPoints = <StartFreshEntryPoint>[];
  final started = Completer<void>();
  final completion = Completer<StartFreshResult>();

  @override
  Future<StartFreshResult> startFresh({
    StartFreshEntryPoint entryPoint =
        StartFreshEntryPoint.incompleteInstallation,
  }) {
    entryPoints.add(entryPoint);
    started.complete();
    return completion.future;
  }
}

final class _FakePresentationPort
    implements AdvancedStartFreshPresentationPort {
  _FakePresentationPort({this.autoDismiss = true});

  final bool autoDismiss;
  AdvancedStartFreshPresentation state =
      const AdvancedStartFreshPresentation.idle();
  final preparingStarted = Completer<void>();
  final verified = Completer<void>();
  Completer<void>? _dismissed;
  int beginPreparingCount = 0;
  int verifiedCount = 0;
  int failureCount = 0;
  int dismissCount = 0;

  @override
  int beginPreparing() {
    beginPreparingCount += 1;
    final occurrence = state.occurrence + 1;
    _dismissed = Completer<void>();
    state = AdvancedStartFreshPresentation(
      occurrence: occurrence,
      phase: AdvancedStartFreshPresentationPhase.preparing,
    );
    if (!preparingStarted.isCompleted) {
      preparingStarted.complete();
    }
    return occurrence;
  }

  @override
  int? beginRetry({required int expectedOccurrence}) {
    if (!isCurrent(expectedOccurrence) ||
        state.phase != AdvancedStartFreshPresentationPhase.failed ||
        state.failure?.canRetry != true) {
      return null;
    }
    return beginPreparing();
  }

  @override
  void dismiss({required int expectedOccurrence}) {
    if (!isCurrent(expectedOccurrence)) {
      return;
    }
    dismissCount += 1;
    state = AdvancedStartFreshPresentation(
      occurrence: expectedOccurrence,
      phase: AdvancedStartFreshPresentationPhase.idle,
    );
    final dismissed = _dismissed;
    if (dismissed != null && !dismissed.isCompleted) {
      dismissed.complete();
    }
  }

  @override
  bool isCurrent(int occurrence) => state.occurrence == occurrence;

  @override
  void showFailure({
    required int expectedOccurrence,
    required AdvancedStartFreshFailure failure,
  }) {
    if (!isCurrent(expectedOccurrence)) {
      return;
    }
    failureCount += 1;
    state = AdvancedStartFreshPresentation(
      occurrence: expectedOccurrence,
      phase: AdvancedStartFreshPresentationPhase.failed,
      failure: failure,
    );
  }

  @override
  void showVerifiedVirgin({required int expectedOccurrence}) {
    if (!isCurrent(expectedOccurrence)) {
      return;
    }
    verifiedCount += 1;
    state = AdvancedStartFreshPresentation(
      occurrence: expectedOccurrence,
      phase: AdvancedStartFreshPresentationPhase.verifiedVirgin,
    );
    if (!verified.isCompleted) {
      verified.complete();
    }
    if (autoDismiss) {
      final dismissed = _dismissed;
      if (dismissed != null && !dismissed.isCompleted) {
        dismissed.complete();
      }
    }
  }

  @override
  Future<void> waitUntilDismissed({required int expectedOccurrence}) {
    if (!isCurrent(expectedOccurrence) ||
        state.phase == AdvancedStartFreshPresentationPhase.idle) {
      return Future<void>.value();
    }
    return _dismissed?.future ?? Future<void>.value();
  }
}
