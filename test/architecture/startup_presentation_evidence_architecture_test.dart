import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('support and Environment consumers depend only on the neutral seam', () {
    final diagnosticProvider = _read(
      'lib/essentials/logging/application/diagnostic_report_provider.dart',
    );
    final environmentProvider = _read(
      'lib/features/environment_summary/application/'
      'environment_summary_provider.dart',
    );

    for (final source in <String>[diagnosticProvider, environmentProvider]) {
      expect(source, contains('startup_presentation_evidence'));
      expect(source, isNot(contains('essentials/onboarding')));
      expect(source, isNot(contains('onboardingOperationControllerProvider')));
      expect(source, isNot(contains('onboardingJourneyCoordinatorProvider')));
      expect(source, isNot(contains('appCzarAssessmentControllerProvider')));
      expect(source, isNot(contains('AppCzarEvaluator')));
      expect(source, isNot(contains('AppCzarObservationReader')));
    }
  });

  test(
    'AppCzar evidence adapter projects only supplied completed snapshots',
    () {
      final adapter = _read(
        'lib/essentials/startup_presentation_evidence/application/'
        'app_czar_startup_presentation_evidence_provider.dart',
      );

      expect(
        adapter,
        contains('startupPresentationAppCzarAssessmentSnapshotProvider'),
      );
      expect(adapter, contains('state?.assessment'));
      expect(adapter, contains('assessmentGeneration: state.generation'));
      expect(adapter, isNot(contains('essentials/onboarding')));
      expect(adapter, isNot(contains('onboardingOperationControllerProvider')));
      expect(adapter, isNot(contains('appCzarAssessmentControllerProvider')));
      expect(adapter, isNot(contains('AppCzarEvaluator')));
      expect(adapter, isNot(contains('AppCzarObservationReader')));
      expect(adapter, isNot(contains('.detail')));
      expect(adapter, isNot(contains('resolvedPath')));
      expect(adapter, isNot(contains('archiveInstanceId')));
    },
  );

  test('StartupApp authority is isolated behind the StartupApp adapter', () {
    final directory = Directory(
      'lib/essentials/startup_presentation_evidence/application',
    );
    final dartFiles = directory.listSync().whereType<File>().where(
      (file) => file.path.endsWith('.dart'),
    );

    for (final file in dartFiles) {
      final source = file.readAsStringSync();
      final hasStartupAppAuthority =
          source.contains('onboardingOperationControllerProvider') ||
          source.contains('startupValidationTelemetryProvider');
      if (hasStartupAppAuthority) {
        expect(
          file.path,
          endsWith('startup_app_startup_presentation_evidence_provider.dart'),
        );
      }
    }
  });

  test('composition input is explicit and production activation stays off', () {
    final mainSource = _read('lib/main.dart');

    expect(
      mainSource,
      contains(
        'const productionAppCzarActivation = '
        'ProductionAppCzarActivation.disabled;',
      ),
    );
    expect(
      mainSource,
      contains('startupPresentationCompositionProvider.overrideWith'),
    );
    expect(
      mainSource,
      contains(
        'startupPresentationAppCzarAssessmentSnapshotProvider.overrideWith',
      ),
    );
    expect(
      mainSource,
      contains('if (!ref.exists(appCzarAssessmentControllerProvider))'),
    );
  });
}

String _read(String path) => File(path).readAsStringSync();
