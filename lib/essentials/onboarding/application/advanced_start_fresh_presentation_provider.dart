import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/advanced_start_fresh_presentation.dart';

part 'advanced_start_fresh_presentation_provider.g.dart';

abstract interface class AdvancedStartFreshPresentationPort {
  int beginPreparing();

  int? beginRetry({required int expectedOccurrence});

  bool isCurrent(int occurrence);

  void showVerifiedVirgin({required int expectedOccurrence});

  Future<void> waitUntilDismissed({required int expectedOccurrence});

  void showFailure({
    required int expectedOccurrence,
    required AdvancedStartFreshFailure failure,
  });

  void dismiss({required int expectedOccurrence});
}

@Riverpod(keepAlive: true)
class AdvancedStartFreshPresentationController
    extends _$AdvancedStartFreshPresentationController
    implements AdvancedStartFreshPresentationPort {
  Completer<void>? _dismissed;
  int? _dismissedOccurrence;

  @override
  AdvancedStartFreshPresentation build() {
    _completeDismissalWaiter();
    return const AdvancedStartFreshPresentation.idle();
  }

  @override
  int beginPreparing() {
    _completeDismissalWaiter();
    final occurrence = state.occurrence + 1;
    _dismissedOccurrence = occurrence;
    _dismissed = Completer<void>();
    state = AdvancedStartFreshPresentation(
      occurrence: occurrence,
      phase: AdvancedStartFreshPresentationPhase.preparing,
    );
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
  bool isCurrent(int occurrence) => state.occurrence == occurrence;

  @override
  void showVerifiedVirgin({required int expectedOccurrence}) {
    if (!isCurrent(expectedOccurrence)) {
      return;
    }
    state = AdvancedStartFreshPresentation(
      occurrence: expectedOccurrence,
      phase: AdvancedStartFreshPresentationPhase.verifiedVirgin,
    );
  }

  @override
  Future<void> waitUntilDismissed({required int expectedOccurrence}) {
    if (!isCurrent(expectedOccurrence) ||
        state.phase == AdvancedStartFreshPresentationPhase.idle ||
        _dismissedOccurrence != expectedOccurrence) {
      return Future<void>.value();
    }
    return _dismissed?.future ?? Future<void>.value();
  }

  @override
  void showFailure({
    required int expectedOccurrence,
    required AdvancedStartFreshFailure failure,
  }) {
    if (!isCurrent(expectedOccurrence)) {
      return;
    }
    state = AdvancedStartFreshPresentation(
      occurrence: expectedOccurrence,
      phase: AdvancedStartFreshPresentationPhase.failed,
      failure: failure,
    );
  }

  @override
  void dismiss({required int expectedOccurrence}) {
    if (!isCurrent(expectedOccurrence)) {
      return;
    }
    state = AdvancedStartFreshPresentation(
      occurrence: expectedOccurrence,
      phase: AdvancedStartFreshPresentationPhase.idle,
    );
    _completeDismissalWaiter();
  }

  void _completeDismissalWaiter() {
    final dismissed = _dismissed;
    _dismissed = null;
    _dismissedOccurrence = null;
    if (dismissed != null && !dismissed.isCompleted) {
      dismissed.complete();
    }
  }
}
