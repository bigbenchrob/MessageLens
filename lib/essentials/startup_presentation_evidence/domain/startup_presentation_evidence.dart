import 'package:meta/meta.dart';

enum StartupPresentationComposition { startupApp, appCzar }

enum StartupPresentationAvailability { available, unavailable }

enum StartupPresentationProvenance {
  startupValidationTelemetry,
  completedAppCzarAssessment,
}

enum StartupPresentationObservationScope {
  latestStartupAdmissionDecision,
  completedAppCzarAssessmentGeneration,
}

enum StartupPresentationFactTruth { trueValue, falseValue, unknown }

@immutable
final class StartupPresentationFact {
  const StartupPresentationFact({
    required this.id,
    required this.label,
    required this.truth,
  });

  final String id;
  final String label;
  final StartupPresentationFactTruth truth;
}

/// Immutable, display-only startup evidence for support and Environment UI.
///
/// This evidence cannot select a coordinator, authorize a mutation, start an
/// assessment, or grant startup admission. It is projected from evidence that
/// the selected startup composition has already established.
@immutable
final class StartupPresentationEvidence {
  StartupPresentationEvidence._({
    required this.composition,
    required this.availability,
    required this.provenance,
    required this.observationScope,
    required this.unavailableReason,
    required this.installationState,
    required this.admissionBasis,
    required this.appCzarAssessmentGeneration,
    required this.appCzarSelectedDisposition,
    required Iterable<StartupPresentationFact> appCzarFacts,
  }) : appCzarFacts = List<StartupPresentationFact>.unmodifiable(appCzarFacts);

  factory StartupPresentationEvidence.unavailable({
    required StartupPresentationComposition composition,
    required String reason,
  }) {
    return StartupPresentationEvidence._(
      composition: composition,
      availability: StartupPresentationAvailability.unavailable,
      provenance: null,
      observationScope: null,
      unavailableReason: reason,
      installationState: null,
      admissionBasis: null,
      appCzarAssessmentGeneration: null,
      appCzarSelectedDisposition: null,
      appCzarFacts: const <StartupPresentationFact>[],
    );
  }

  factory StartupPresentationEvidence.startupApp({
    required String? installationState,
    required String? admissionBasis,
  }) {
    return StartupPresentationEvidence._(
      composition: StartupPresentationComposition.startupApp,
      availability: StartupPresentationAvailability.available,
      provenance: StartupPresentationProvenance.startupValidationTelemetry,
      observationScope:
          StartupPresentationObservationScope.latestStartupAdmissionDecision,
      unavailableReason: null,
      installationState: installationState,
      admissionBasis: admissionBasis,
      appCzarAssessmentGeneration: null,
      appCzarSelectedDisposition: null,
      appCzarFacts: const <StartupPresentationFact>[],
    );
  }

  factory StartupPresentationEvidence.appCzar({
    required int assessmentGeneration,
    required String selectedDisposition,
    required Iterable<StartupPresentationFact> facts,
  }) {
    return StartupPresentationEvidence._(
      composition: StartupPresentationComposition.appCzar,
      availability: StartupPresentationAvailability.available,
      provenance: StartupPresentationProvenance.completedAppCzarAssessment,
      observationScope: StartupPresentationObservationScope
          .completedAppCzarAssessmentGeneration,
      unavailableReason: null,
      installationState: null,
      admissionBasis: null,
      appCzarAssessmentGeneration: assessmentGeneration,
      appCzarSelectedDisposition: selectedDisposition,
      appCzarFacts: facts,
    );
  }

  final StartupPresentationComposition composition;
  final StartupPresentationAvailability availability;
  final StartupPresentationProvenance? provenance;
  final StartupPresentationObservationScope? observationScope;
  final String? unavailableReason;
  final String? installationState;
  final String? admissionBasis;
  final int? appCzarAssessmentGeneration;
  final String? appCzarSelectedDisposition;
  final List<StartupPresentationFact> appCzarFacts;

  bool get isAvailable {
    return availability == StartupPresentationAvailability.available;
  }
}

enum StartupSupportArtifactKind {
  startupValidation('startup_validation.json'),
  onboardingOperation('onboarding_operation.json'),
  appCzarAssessment('app_czar_assessment.json');

  const StartupSupportArtifactKind(this.fileName);

  final String fileName;
}

@immutable
final class StartupSupportArtifact {
  StartupSupportArtifact({
    required this.kind,
    required Map<String, Object?> json,
  }) : json = _deeplyImmutableJsonObject(json);

  final StartupSupportArtifactKind kind;
  final Map<String, Object?> json;
}

/// Bounded startup evidence prepared for the existing support exporter.
@immutable
final class StartupSupportEvidence {
  StartupSupportEvidence({
    required this.presentation,
    required this.headerDescription,
    required Iterable<StartupSupportArtifact> artifacts,
  }) : artifacts = List<StartupSupportArtifact>.unmodifiable(artifacts);

  final StartupPresentationEvidence presentation;
  final String headerDescription;
  final List<StartupSupportArtifact> artifacts;
}

Map<String, Object?> _deeplyImmutableJsonObject(Map<String, Object?> source) {
  return Map<String, Object?>.unmodifiable(<String, Object?>{
    for (final entry in source.entries)
      entry.key: _deeplyImmutableJsonValue(entry.value),
  });
}

Object? _deeplyImmutableJsonValue(Object? value) {
  if (value is Map<String, Object?>) {
    return _deeplyImmutableJsonObject(value);
  }
  if (value is List<Object?>) {
    return List<Object?>.unmodifiable(
      value.map<Object?>(_deeplyImmutableJsonValue),
    );
  }
  return value;
}
