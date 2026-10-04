import 'package:meta/meta.dart';

enum AppCzarTruth {
  trueValue('TRUE'),
  falseValue('FALSE'),
  unknown('UNKNOWN');

  const AppCzarTruth(this.label);

  final String label;
}

enum AppCzarDatabaseCondition { absent, healthy, unhealthy, unknown }

enum AppCzarSourceCondition { readable, accessDenied, unavailable, unknown }

enum AppCzarArchiveCondition {
  available,
  readOnly,
  notCreated,
  unavailable,
  unknown,
}

enum AppCzarAttachmentCoverageCondition { complete, incomplete, unknown }

enum AppCzarFactId {
  developmentRootAdmitted,
  messagesSourceReadable,
  sourceSampleStable,
  importStoreHealthy,
  graphStoreHealthy,
  overlayHealthy,
  localDatasetComplete,
  attachmentArchiveAvailable,
  attachmentCoverageComplete,
  sourceLocalDeltaKnown,
  sourceAheadOfLocal,
}

enum AppCzarDiagnosisKind {
  healthyCurrentInstallation,
  incompleteLocalDataset,
  sourceAccessUnavailable,
  attachmentArchiveUnavailable,
  attachmentArchiveCoverageIncomplete,
  localDataNeedsRepair,
  sourceAheadOfLocal,
  contradictoryOrInsufficientEvidence,
}

@immutable
final class AppCzarAttachmentCoverageObservation {
  const AppCzarAttachmentCoverageObservation({
    required this.condition,
    required this.requiredCount,
    required this.coveredCount,
    required this.missingCount,
    required this.unverifiableCount,
    required this.archiveScopeIdentity,
    required this.archiveGeneration,
    this.issue,
  });

  const AppCzarAttachmentCoverageObservation.unknown({
    required String issue,
    String? archiveScopeIdentity,
    int? archiveGeneration,
    int? requiredCount,
    int? coveredCount,
    int? missingCount,
    int? unverifiableCount,
  }) : this(
         condition: AppCzarAttachmentCoverageCondition.unknown,
         requiredCount: requiredCount,
         coveredCount: coveredCount,
         missingCount: missingCount,
         unverifiableCount: unverifiableCount,
         archiveScopeIdentity: archiveScopeIdentity,
         archiveGeneration: archiveGeneration,
         issue: issue,
       );

  final AppCzarAttachmentCoverageCondition condition;
  final int? requiredCount;
  final int? coveredCount;
  final int? missingCount;
  final int? unverifiableCount;

  /// Opaque identity for the admitted data root and one resolved attachment
  /// archive configuration/root. It is diagnostic scope, not path authority.
  final String? archiveScopeIdentity;

  /// The attachment-location generation observed for this read-only scope.
  /// Fresh startup probes begin at the location owner's initial generation.
  final int? archiveGeneration;
  final String? issue;

  bool get hasCoherentMaterialCounts {
    if (condition == AppCzarAttachmentCoverageCondition.unknown) {
      return true;
    }
    final required = requiredCount;
    final covered = coveredCount;
    final missing = missingCount;
    final unverifiable = unverifiableCount;
    final scope = archiveScopeIdentity;
    final generation = archiveGeneration;
    if (required == null ||
        covered == null ||
        missing == null ||
        unverifiable == null ||
        required < 0 ||
        covered < 0 ||
        missing < 0 ||
        unverifiable < 0 ||
        covered + missing + unverifiable != required ||
        scope == null ||
        scope.isEmpty ||
        generation == null ||
        generation < 0) {
      return false;
    }
    return switch (condition) {
      AppCzarAttachmentCoverageCondition.complete =>
        covered == required && missing == 0 && unverifiable == 0,
      AppCzarAttachmentCoverageCondition.incomplete => missing > 0,
      AppCzarAttachmentCoverageCondition.unknown => true,
    };
  }
}

enum AppCzarVirtualCoordinator {
  operatingSession('Operating Session'),
  onboarding('Onboarding'),
  sourceAccessRepair('Source Access Repair'),
  attachmentArchiveRepair('Attachment Archive Repair'),
  localDataRepair('Local Data Repair'),
  dataUpdate('Data Update'),
  diagnosticReview('Diagnostic Review');

  const AppCzarVirtualCoordinator(this.displayName);

  final String displayName;
}

@immutable
final class AppCzarRootObservation {
  const AppCzarRootObservation({required this.admitted, required this.path});

  final bool admitted;
  final String path;
}

@immutable
final class AppCzarSourceObservation {
  const AppCzarSourceObservation({
    required this.condition,
    this.messageCount,
    this.maxRowId,
    this.sampleStable,
    this.issue,
  });

  const AppCzarSourceObservation.unknown(String issue)
    : this(condition: AppCzarSourceCondition.unknown, issue: issue);

  final AppCzarSourceCondition condition;
  final int? messageCount;
  final int? maxRowId;
  final bool? sampleStable;
  final String? issue;
}

@immutable
final class AppCzarDatabaseObservation {
  const AppCzarDatabaseObservation({
    required this.condition,
    this.schemaVersion,
    this.messageCount,
    this.liveMessageCount,
    this.liveMaxSourceRowId,
    this.chatCount,
    this.chatMessageEdgeCount,
    this.issue,
  });

  const AppCzarDatabaseObservation.unknown(String issue)
    : this(condition: AppCzarDatabaseCondition.unknown, issue: issue);

  const AppCzarDatabaseObservation.absent()
    : this(condition: AppCzarDatabaseCondition.absent);

  final AppCzarDatabaseCondition condition;
  final int? schemaVersion;
  final int? messageCount;
  final int? liveMessageCount;
  final int? liveMaxSourceRowId;
  final int? chatCount;
  final int? chatMessageEdgeCount;
  final String? issue;
}

@immutable
final class AppCzarArchiveObservation {
  const AppCzarArchiveObservation({
    required this.condition,
    required this.label,
    required this.coverage,
    this.archiveScopeIdentity,
    this.archiveGeneration,
    this.resolvedPath,
    this.issue,
  });

  factory AppCzarArchiveObservation.unknown(String issue) {
    return AppCzarArchiveObservation(
      condition: AppCzarArchiveCondition.unknown,
      label: 'Attachment archive',
      coverage: AppCzarAttachmentCoverageObservation.unknown(issue: issue),
      issue: issue,
    );
  }

  final AppCzarArchiveCondition condition;
  final String label;
  final AppCzarAttachmentCoverageObservation coverage;
  final String? archiveScopeIdentity;
  final int? archiveGeneration;
  final String? resolvedPath;
  final String? issue;

  bool get hasCoherentCoverageBinding {
    if (!coverage.hasCoherentMaterialCounts) {
      return false;
    }
    if (coverage.condition == AppCzarAttachmentCoverageCondition.unknown) {
      return true;
    }
    final scope = archiveScopeIdentity;
    final generation = archiveGeneration;
    return scope != null &&
        scope.isNotEmpty &&
        generation != null &&
        generation >= 0 &&
        coverage.archiveScopeIdentity == scope &&
        coverage.archiveGeneration == generation;
  }
}

@immutable
final class AppCzarObservationSet {
  const AppCzarObservationSet({
    required this.root,
    required this.source,
    required this.importStore,
    required this.graphStore,
    required this.overlay,
    required this.attachmentArchive,
  });

  final AppCzarRootObservation root;
  final AppCzarSourceObservation source;
  final AppCzarDatabaseObservation importStore;
  final AppCzarDatabaseObservation graphStore;
  final AppCzarDatabaseObservation overlay;
  final AppCzarArchiveObservation attachmentArchive;
}

@immutable
final class AppCzarFact {
  const AppCzarFact({
    required this.id,
    required this.label,
    required this.truth,
    required this.detail,
  });

  final AppCzarFactId id;
  final String label;
  final AppCzarTruth truth;
  final String detail;
}

@immutable
final class AppCzarAssessment {
  AppCzarAssessment({
    required Iterable<AppCzarFact> facts,
    required this.diagnosisKind,
    required this.diagnosis,
    required this.virtualCoordinator,
  }) : facts = List<AppCzarFact>.unmodifiable(facts),
       _factsById = <AppCzarFactId, AppCzarFact>{
         for (final fact in facts) fact.id: fact,
       };

  final List<AppCzarFact> facts;
  final Map<AppCzarFactId, AppCzarFact> _factsById;
  final AppCzarDiagnosisKind diagnosisKind;
  final String diagnosis;
  final AppCzarVirtualCoordinator virtualCoordinator;

  AppCzarFact fact(AppCzarFactId id) => _factsById[id]!;
}

@immutable
final class AppCzarAssessmentState {
  const AppCzarAssessmentState({
    required this.generation,
    this.root,
    this.source,
    this.importStore,
    this.graphStore,
    this.overlay,
    this.attachmentArchive,
    this.assessment,
  });

  factory AppCzarAssessmentState.initial(int generation) {
    return AppCzarAssessmentState(generation: generation);
  }

  final int generation;
  final AppCzarRootObservation? root;
  final AppCzarSourceObservation? source;
  final AppCzarDatabaseObservation? importStore;
  final AppCzarDatabaseObservation? graphStore;
  final AppCzarDatabaseObservation? overlay;
  final AppCzarArchiveObservation? attachmentArchive;
  final AppCzarAssessment? assessment;

  bool get isComplete => assessment != null;

  AppCzarAssessmentState copyWith({
    AppCzarRootObservation? root,
    AppCzarSourceObservation? source,
    AppCzarDatabaseObservation? importStore,
    AppCzarDatabaseObservation? graphStore,
    AppCzarDatabaseObservation? overlay,
    AppCzarArchiveObservation? attachmentArchive,
    AppCzarAssessment? assessment,
  }) {
    return AppCzarAssessmentState(
      generation: generation,
      root: root ?? this.root,
      source: source ?? this.source,
      importStore: importStore ?? this.importStore,
      graphStore: graphStore ?? this.graphStore,
      overlay: overlay ?? this.overlay,
      attachmentArchive: attachmentArchive ?? this.attachmentArchive,
      assessment: assessment ?? this.assessment,
    );
  }

  AppCzarObservationSet requireObservationSet() {
    return AppCzarObservationSet(
      root: root!,
      source: source!,
      importStore: importStore!,
      graphStore: graphStore!,
      overlay: overlay!,
      attachmentArchive: attachmentArchive!,
    );
  }
}
