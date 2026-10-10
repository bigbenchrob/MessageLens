import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_assessment_provider.dart';
import 'package:remember_this_text/essentials/app_czar/domain/app_czar_models.dart';
import 'package:remember_this_text/essentials/onboarding/feature_level_providers.dart'
    show onboardingOperationControllerProvider;
import 'package:remember_this_text/essentials/startup_presentation_evidence/feature_level_providers.dart';

void main() {
  test(
    'projects one completed AppCzar generation without private fact detail',
    () async {
      final state = AppCzarAssessmentState(
        generation: 7,
        assessment: AppCzarAssessment(
          facts: const <AppCzarFact>[
            AppCzarFact(
              id: AppCzarFactId.developmentRootAdmitted,
              label: 'Development data folder',
              truth: AppCzarTruth.trueValue,
              detail: '/private/sensitive/root',
            ),
            AppCzarFact(
              id: AppCzarFactId.localDatasetComplete,
              label: 'Local message dataset',
              truth: AppCzarTruth.falseValue,
              detail: 'record 123 needs attention',
            ),
            AppCzarFact(
              id: AppCzarFactId.attachmentCoverageComplete,
              label: 'Attachment coverage',
              truth: AppCzarTruth.unknown,
              detail: 'archive UUID secret',
            ),
          ],
          diagnosisKind:
              AppCzarDiagnosisKind.contradictoryOrInsufficientEvidence,
          diagnosis: 'Private diagnosis detail.',
          virtualCoordinator: AppCzarVirtualCoordinator.diagnosticReview,
        ),
      );
      final container = ProviderContainer(
        overrides: <Override>[
          startupPresentationCompositionProvider.overrideWith(
            (ref) => StartupPresentationComposition.appCzar,
          ),
          startupPresentationAppCzarAssessmentSnapshotProvider.overrideWith(
            (ref) => state,
          ),
        ],
      );
      addTearDown(container.dispose);

      final presentation = container.read(startupPresentationEvidenceProvider);
      final support = await container.read(
        startupSupportEvidenceProvider.future,
      );

      expect(presentation.appCzarAssessmentGeneration, 7);
      expect(presentation.appCzarSelectedDisposition, 'Diagnostic Review');
      expect(
        presentation.appCzarFacts.map((fact) => fact.truth),
        <StartupPresentationFactTruth>[
          StartupPresentationFactTruth.trueValue,
          StartupPresentationFactTruth.falseValue,
          StartupPresentationFactTruth.unknown,
        ],
      );
      expect(
        presentation.provenance,
        StartupPresentationProvenance.completedAppCzarAssessment,
      );
      expect(
        presentation.observationScope,
        StartupPresentationObservationScope
            .completedAppCzarAssessmentGeneration,
      );

      final encoded = jsonEncode(support.artifacts.single.json);
      expect(encoded, contains('"assessment_generation":7'));
      expect(encoded, contains('"truth":"UNKNOWN"'));
      expect(encoded, isNot(contains('/private/sensitive/root')));
      expect(encoded, isNot(contains('record 123')));
      expect(encoded, isNot(contains('archive UUID')));
      expect(encoded, isNot(contains('Private diagnosis detail')));
    },
  );

  test(
    'AppCzar absence is explicit and constructs neither semantic controller',
    () async {
      final container = ProviderContainer(
        overrides: <Override>[
          startupPresentationCompositionProvider.overrideWith(
            (ref) => StartupPresentationComposition.appCzar,
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(container.exists(appCzarAssessmentControllerProvider), isFalse);
      expect(container.exists(onboardingOperationControllerProvider), isFalse);

      final presentation = container.read(startupPresentationEvidenceProvider);
      final support = await container.read(
        startupSupportEvidenceProvider.future,
      );

      expect(presentation.isAvailable, isFalse);
      expect(
        presentation.unavailableReason,
        'No completed AppCzar assessment is available in this process.',
      );
      expect(support.artifacts.single.json['availability'], 'unavailable');
      expect(container.exists(appCzarAssessmentControllerProvider), isFalse);
      expect(container.exists(onboardingOperationControllerProvider), isFalse);
    },
  );

  test('support artifacts are recursively immutable', () {
    final nested = <String, Object?>{
      'facts': <Object?>[
        <String, Object?>{'truth': 'UNKNOWN'},
      ],
    };
    final artifact = StartupSupportArtifact(
      kind: StartupSupportArtifactKind.appCzarAssessment,
      json: nested,
    );

    nested['later'] = true;
    final facts = artifact.json['facts'] as List<Object?>?;
    final fact = facts!.single as Map<String, Object?>?;

    expect(artifact.json, isNot(contains('later')));
    expect(() => facts.add('mutation'), throwsUnsupportedError);
    expect(() => fact!['truth'] = 'TRUE', throwsUnsupportedError);
  });
}
