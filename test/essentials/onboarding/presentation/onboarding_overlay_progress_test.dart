import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import 'package:remember_this_text/essentials/onboarding/application/onboarding_journey_coordinator_provider.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_journey_operation_projection.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_journey_state.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_operation_snapshot.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_status.dart';
import 'package:remember_this_text/essentials/onboarding/presentation/onboarding_overlay.dart';

void main() {
  testWidgets('active work renders indeterminate without truthful units', (
    tester,
  ) async {
    await _pump(
      tester,
      OnboardingBuildingLocalData(occurrence: 1, operation: _operation()),
    );

    expect(find.text('Building browsing data…'), findsOneWidget);
    final indicator = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(indicator.value, isNull);
    _expectNoCancellationControl();
  });

  testWidgets('Journey projection supplies determinate progress', (
    tester,
  ) async {
    await _pump(
      tester,
      OnboardingBuildingLocalData(
        occurrence: 1,
        operation: _operation(
          substage: OnboardingOperationSubstage.importingMessages,
          progress: const OnboardingJourneyOperationProgress(
            completedWorkUnits: 42000,
            totalWorkUnits: 137000,
          ),
        ),
      ),
    );

    expect(find.text('Messages  42000 / 137000'), findsOneWidget);
    final indicator = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(indicator.value, closeTo(42000 / 137000, 0.000001));
  });

  testWidgets('reimport wording comes only from the typed projection', (
    tester,
  ) async {
    await _pump(
      tester,
      OnboardingReimporting(
        occurrence: 1,
        operation: _operation(kind: OnboardingOperationKind.reimport),
        status: OnboardingStatus.reimportBuildingGraph,
      ),
    );

    expect(find.text('Rebuilding browsing data…'), findsOneWidget);
    expect(find.text('Browsing data ready'), findsNothing);
  });

  testWidgets('interrupted work exposes explicit Continue Setup', (
    tester,
  ) async {
    await _pump(
      tester,
      OnboardingOperationInterrupted(
        occurrence: 7,
        operation: _operation(
          phase: OnboardingJourneyOperationPhase.interrupted,
          actions: const <OnboardingJourneyOperationAction>{
            OnboardingJourneyOperationAction.continueSetup,
          },
        ),
      ),
    );

    expect(find.text('Setup was interrupted'), findsOneWidget);
    expect(find.text('Continue Setup'), findsOneWidget);
    _expectNoCancellationControl();
  });

  testWidgets('verified first import presents terminal acknowledgement', (
    tester,
  ) async {
    await _pump(
      tester,
      OnboardingReadyToStart(
        occurrence: 8,
        operation: _operation(
          phase: OnboardingJourneyOperationPhase.verified,
          actions: const <OnboardingJourneyOperationAction>{
            OnboardingJourneyOperationAction.acknowledgeCompletion,
          },
        ),
      ),
    );

    expect(find.text('You’re ready to start'), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);
  });

  testWidgets('automatic recovery remains non-interactive', (tester) async {
    await _pump(
      tester,
      OnboardingRecoveringDerivedData(
        occurrence: 9,
        operation: _operation(
          kind: OnboardingOperationKind.automaticRecovery,
          stage: OnboardingOperationStage.automaticRecoveryReset,
        ),
      ),
    );

    expect(find.text('Preparing MessageLens to try again'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
    _expectNoCancellationControl();
  });
}

Future<void> _pump(WidgetTester tester, OnboardingJourneyState journey) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        onboardingJourneyCoordinatorProvider.overrideWith(
          () => _FixedJourneyCoordinator(journey),
        ),
      ],
      child: const MacosApp(home: OnboardingOverlay()),
    ),
  );
  await tester.pump();
}

OnboardingJourneyOperationProjection _operation({
  OnboardingOperationKind kind = OnboardingOperationKind.initialImport,
  OnboardingJourneyOperationPhase phase =
      OnboardingJourneyOperationPhase.active,
  OnboardingOperationStage stage = OnboardingOperationStage.messageDataBuild,
  OnboardingOperationSubstage? substage,
  OnboardingJourneyOperationProgress? progress,
  Set<OnboardingJourneyOperationAction> actions =
      const <OnboardingJourneyOperationAction>{},
}) {
  return OnboardingJourneyOperationProjection(
    operationId: OnboardingOperationId('123e4567-e89b-42d3-a456-426614174000'),
    kind: kind,
    phase: phase,
    stage: stage,
    substage: substage,
    progressRevision: 2,
    progress: progress,
    failure: null,
    availableActions: actions,
  );
}

void _expectNoCancellationControl() {
  for (final label in <String>[
    'Abort Import',
    'Cancel',
    'Stop',
    'Quit Setup',
    'Try Later',
  ]) {
    expect(
      find.text(label),
      findsNothing,
      reason: 'Unexpected control: $label',
    );
  }
}

final class _FixedJourneyCoordinator extends OnboardingJourneyCoordinator {
  _FixedJourneyCoordinator(this.journey);

  final OnboardingJourneyState journey;

  @override
  OnboardingJourneyState build() => journey;
}
