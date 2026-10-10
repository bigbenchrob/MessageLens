import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app_czar/domain/app_czar_models.dart';
import '../domain/startup_presentation_evidence.dart';
import 'startup_presentation_evidence_inputs.dart';

part 'app_czar_startup_presentation_evidence_provider.g.dart';

const int _maximumSupportFacts = 32;

@riverpod
StartupPresentationEvidence appCzarStartupPresentationEvidence(Ref ref) {
  final state = ref.watch(startupPresentationAppCzarAssessmentSnapshotProvider);
  final assessment = state?.assessment;
  if (state == null || assessment == null) {
    return StartupPresentationEvidence.unavailable(
      composition: StartupPresentationComposition.appCzar,
      reason: 'No completed AppCzar assessment is available in this process.',
    );
  }

  return StartupPresentationEvidence.appCzar(
    assessmentGeneration: state.generation,
    selectedDisposition: assessment.virtualCoordinator.displayName,
    facts: assessment.facts.take(_maximumSupportFacts).map(_projectFact),
  );
}

@riverpod
Future<StartupSupportEvidence> appCzarStartupSupportEvidence(Ref ref) async {
  final presentation = ref.watch(appCzarStartupPresentationEvidenceProvider);
  return StartupSupportEvidence(
    presentation: presentation,
    headerDescription: 'completed AppCzar assessment presentation evidence',
    artifacts: <StartupSupportArtifact>[
      StartupSupportArtifact(
        kind: StartupSupportArtifactKind.appCzarAssessment,
        json: <String, Object?>{
          'schema_version': 1,
          'composition': presentation.composition.name,
          'availability': presentation.availability.name,
          if (presentation.provenance case final provenance?)
            'provenance': provenance.name,
          if (presentation.observationScope case final scope?)
            'observation_scope': scope.name,
          if (presentation.appCzarAssessmentGeneration case final generation?)
            'assessment_generation': generation,
          if (presentation.appCzarSelectedDisposition case final disposition?)
            'selected_disposition': disposition,
          if (presentation.unavailableReason case final reason?)
            'unavailable_reason': reason,
          'facts': <Map<String, Object?>>[
            for (final fact in presentation.appCzarFacts)
              <String, Object?>{
                'id': fact.id,
                'label': fact.label,
                'truth': _supportTruth(fact.truth),
              },
          ],
          'privacy_notes': const <String>[
            'Completed assessment presentation facts only.',
            'Paths, archive identities, record identifiers, content, and mutation capabilities are omitted.',
          ],
        },
      ),
    ],
  );
}

StartupPresentationFact _projectFact(AppCzarFact fact) {
  return StartupPresentationFact(
    id: fact.id.name,
    label: fact.label,
    truth: switch (fact.truth) {
      AppCzarTruth.trueValue => StartupPresentationFactTruth.trueValue,
      AppCzarTruth.falseValue => StartupPresentationFactTruth.falseValue,
      AppCzarTruth.unknown => StartupPresentationFactTruth.unknown,
    },
  );
}

String _supportTruth(StartupPresentationFactTruth truth) {
  return switch (truth) {
    StartupPresentationFactTruth.trueValue => 'TRUE',
    StartupPresentationFactTruth.falseValue => 'FALSE',
    StartupPresentationFactTruth.unknown => 'UNKNOWN',
  };
}
