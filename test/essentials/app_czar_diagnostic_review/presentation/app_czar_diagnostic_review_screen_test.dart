import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_evaluator.dart';
import 'package:remember_this_text/essentials/app_czar/domain/app_czar_models.dart';
import 'package:remember_this_text/essentials/app_czar_diagnostic_review/domain/app_czar_diagnostic_review_state.dart';
import 'package:remember_this_text/essentials/app_czar_diagnostic_review/presentation/app_czar_diagnostic_review_screen.dart';

void main() {
  testWidgets('renders one bounded snapshot and all evidence distinctions', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: AppCzarDiagnosticReviewScreen(
            state: _visibleState(),
            onTryAssessmentAgain: () async {},
            onQuitRequested: () async {},
          ),
        ),
      ),
    );

    expect(find.text('MessageLens needs a diagnostic review'), findsOneWidget);
    expect(find.text('Assessment generation 8'), findsOneWidget);
    expect(find.textContaining('not continuously refreshed'), findsOneWidget);
    expect(find.textContaining('TRUE —'), findsWidgets);
    expect(find.textContaining('FALSE —'), findsWidgets);
    expect(find.textContaining('UNKNOWN —'), findsWidgets);
    expect(find.textContaining('CONFLICT —'), findsWidgets);
    expect(find.text('Try Assessment Again'), findsOneWidget);
    expect(find.text('Quit'), findsOneWidget);
    for (final forbidden in <String>[
      'Reset',
      'Repair',
      'Preserve',
      'Continue',
      'Copy',
      'Export',
    ]) {
      expect(find.text(forbidden), findsNothing);
    }

    final technicalEvidence = find.byKey(
      AppCzarDiagnosticReviewScreen.technicalEvidenceKey,
    );
    await tester.ensureVisible(technicalEvidence);
    await tester.tap(technicalEvidence);
    await tester.pump();
    expect(find.textContaining('Development data folder'), findsWidgets);
  });

  testWidgets('exposes only explicit restart and quit callbacks', (
    tester,
  ) async {
    var restartRequests = 0;
    var quitRequests = 0;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: AppCzarDiagnosticReviewScreen(
            state: _visibleState(),
            onTryAssessmentAgain: () async {
              restartRequests += 1;
            },
            onQuitRequested: () async {
              quitRequests += 1;
            },
          ),
        ),
      ),
    );

    final tryAgain = find.byKey(AppCzarDiagnosticReviewScreen.tryAgainKey);
    await tester.ensureVisible(tryAgain);
    await tester.tap(tryAgain);
    await tester.pump();
    final quit = find.byKey(AppCzarDiagnosticReviewScreen.quitKey);
    await tester.ensureVisible(quit);
    await tester.tap(quit);
    await tester.pump();

    expect(restartRequests, 1);
    expect(quitRequests, 1);
  });

  testWidgets('draining occurrence disables restart admission', (tester) async {
    final presenting = _visibleState();
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: AppCzarDiagnosticReviewScreen(
            state: AppCzarDiagnosticReviewState(
              phase: AppCzarDiagnosticReviewPhase.draining,
              actionAdmissionOpen: false,
              occurrence: presenting.occurrence,
            ),
            onTryAssessmentAgain: () async {},
            onQuitRequested: () async {},
          ),
        ),
      ),
    );

    final button = tester.widget<TextButton>(
      find.byKey(AppCzarDiagnosticReviewScreen.tryAgainKey),
    );
    expect(button.onPressed, isNull);
  });
}

AppCzarDiagnosticReviewState _visibleState() {
  final assessment = _diagnosticState();
  return AppCzarDiagnosticReviewState(
    phase: AppCzarDiagnosticReviewPhase.presenting,
    actionAdmissionOpen: true,
    occurrence: AppCzarDiagnosticReviewOccurrence(
      processSequence: 1,
      assessmentGeneration: assessment.generation,
      capturedAssessmentState: assessment,
      capturedAt: DateTime.utc(2026, 10, 9, 12, 30),
    ),
  );
}

AppCzarAssessmentState _diagnosticState() {
  final observations = AppCzarObservationSet(
    root: const AppCzarRootObservation(admitted: true, path: '/test/root'),
    source: const AppCzarSourceObservation(
      condition: AppCzarSourceCondition.readable,
      messageCount: 10,
      maxRowId: 10,
      sampleStable: false,
      issue: 'Two bounded source samples disagreed.',
    ),
    importStore: const AppCzarDatabaseObservation(
      condition: AppCzarDatabaseCondition.unhealthy,
      issue: 'Unsupported schema.',
    ),
    graphStore: const AppCzarDatabaseObservation.unknown(
      'Graph inspection was unavailable.',
    ),
    overlay: const AppCzarDatabaseObservation(
      condition: AppCzarDatabaseCondition.healthy,
      schemaVersion: 8,
    ),
    attachmentArchive: const AppCzarArchiveObservation(
      condition: AppCzarArchiveCondition.unknown,
      label: 'Attachment archive',
      coverage: AppCzarAttachmentCoverageObservation.unknown(
        issue: 'Coverage unavailable.',
      ),
      issue: 'Archive inspection unavailable.',
    ),
  );
  return AppCzarAssessmentState(
    generation: 8,
    root: observations.root,
    initialConstructionScope: observations.initialConstructionScope,
    source: observations.source,
    contactsPrerequisite: observations.contactsPrerequisite,
    importStore: observations.importStore,
    graphStore: observations.graphStore,
    overlay: observations.overlay,
    attachmentArchive: observations.attachmentArchive,
    localDataRepairSafety: observations.localDataRepairSafety,
    assessment: const AppCzarEvaluator().evaluate(observations),
  );
}
