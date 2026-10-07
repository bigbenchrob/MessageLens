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

enum AppCzarAttachmentRepairOpportunityCondition { present, absent, unknown }

enum AppCzarLocalDataRepairSafetyCondition {
  rebuildableLiveOnlyPartial,
  protectedMaterialPresent,
  sourceFactMissing,
  retiredArtifactsPresent,
  unsupportedOrCorrupt,
  unknown,
}

enum AppCzarInitialConstructionScopeCondition {
  safeEmpty,
  consequentialData,
  protectedNonLiveData,
  retiredOrUnsupportedMaterial,
  unhealthy,
  unknown,
}

enum AppCzarContactsPrerequisiteCondition {
  notRequiredForCurrentScope,
  viableWithContacts,
  viableEmpty,
  accessDenied,
  unavailable,
  invalidOrCorrupt,
  unknown,
}

enum AppCzarFactId {
  developmentRootAdmitted,
  initialConstructionScopeSafe,
  messagesSourceReadable,
  sourceSampleStable,
  contactsPrerequisiteSatisfied,
  importStoreHealthy,
  graphStoreHealthy,
  overlayHealthy,
  localDatasetComplete,
  attachmentArchiveAvailable,
  attachmentCoverageComplete,
  attachmentRepairOpportunityPresent,
  localDataRepairMayResetDerivedStores,
  sourceLocalDeltaKnown,
  sourceAheadOfLocal,
}

@immutable
final class AppCzarLocalDataRepairSafetyObservation {
  const AppCzarLocalDataRepairSafetyObservation({
    required this.condition,
    required this.archiveRootPath,
    required this.archiveInstanceId,
    required this.archiveScopeIdentity,
    required this.archiveGeneration,
    required this.sourceFingerprint,
    required this.evidenceFingerprint,
    required this.resetFootprint,
    required this.consequentialRowCounts,
    this.issue,
  });

  const AppCzarLocalDataRepairSafetyObservation.unknown({
    required String issue,
    String? archiveRootPath,
    String? archiveInstanceId,
    String? archiveScopeIdentity,
    int? archiveGeneration,
  }) : this(
         condition: AppCzarLocalDataRepairSafetyCondition.unknown,
         archiveRootPath: archiveRootPath,
         archiveInstanceId: archiveInstanceId,
         archiveScopeIdentity: archiveScopeIdentity,
         archiveGeneration: archiveGeneration,
         sourceFingerprint: null,
         evidenceFingerprint: null,
         resetFootprint: const <String>[],
         consequentialRowCounts: const <String, int>{},
         issue: issue,
       );

  final AppCzarLocalDataRepairSafetyCondition condition;
  final String? archiveRootPath;
  final String? archiveInstanceId;
  final String? archiveScopeIdentity;
  final int? archiveGeneration;
  final String? sourceFingerprint;
  final String? evidenceFingerprint;
  final List<String> resetFootprint;
  final Map<String, int> consequentialRowCounts;
  final String? issue;

  bool get mayResetDerivedStores {
    return condition ==
            AppCzarLocalDataRepairSafetyCondition.rebuildableLiveOnlyPartial &&
        archiveRootPath != null &&
        archiveInstanceId != null &&
        archiveScopeIdentity != null &&
        archiveGeneration != null &&
        sourceFingerprint != null &&
        evidenceFingerprint != null &&
        resetFootprint.isNotEmpty &&
        consequentialRowCounts.values.any((count) => count > 0);
  }

  bool hasSameMutationBinding(AppCzarLocalDataRepairSafetyObservation other) {
    return mayResetDerivedStores &&
        other.mayResetDerivedStores &&
        archiveRootPath == other.archiveRootPath &&
        archiveInstanceId == other.archiveInstanceId &&
        archiveScopeIdentity == other.archiveScopeIdentity &&
        archiveGeneration == other.archiveGeneration &&
        sourceFingerprint == other.sourceFingerprint &&
        evidenceFingerprint == other.evidenceFingerprint &&
        _sameStrings(resetFootprint, other.resetFootprint);
  }
}

@immutable
final class AppCzarInitialConstructionScopeObservation {
  const AppCzarInitialConstructionScopeObservation({
    required this.condition,
    required this.importMessageCount,
    required this.graphMessageCount,
    required this.graphChatCount,
    required this.graphEdgeCount,
    required this.nonLiveSourceCount,
    required this.hasRetiredDerivedArtifacts,
    required this.issue,
  });

  const AppCzarInitialConstructionScopeObservation.unknown(String issue)
    : this(
        condition: AppCzarInitialConstructionScopeCondition.unknown,
        importMessageCount: null,
        graphMessageCount: null,
        graphChatCount: null,
        graphEdgeCount: null,
        nonLiveSourceCount: null,
        hasRetiredDerivedArtifacts: false,
        issue: issue,
      );

  final AppCzarInitialConstructionScopeCondition condition;
  final int? importMessageCount;
  final int? graphMessageCount;
  final int? graphChatCount;
  final int? graphEdgeCount;
  final int? nonLiveSourceCount;
  final bool hasRetiredDerivedArtifacts;
  final String? issue;
}

@immutable
final class AppCzarContactsPrerequisiteObservation {
  const AppCzarContactsPrerequisiteObservation({
    required this.condition,
    this.contactCount,
    this.viableStoreCount,
    this.sourceDatabasePath,
    this.issue,
  });

  const AppCzarContactsPrerequisiteObservation.unknown(String issue)
    : this(
        condition: AppCzarContactsPrerequisiteCondition.unknown,
        issue: issue,
      );

  final AppCzarContactsPrerequisiteCondition condition;
  final int? contactCount;
  final int? viableStoreCount;
  final String? sourceDatabasePath;
  final String? issue;
}

enum AppCzarDiagnosisKind {
  healthyCurrentInstallation,
  incompleteLocalDataset,
  sourceAccessUnavailable,
  attachmentArchiveUnavailable,
  attachmentArchiveCoverageIncomplete,
  operatingWithKnownAttachmentDebt,
  localDataNeedsRepair,
  sourceAheadOfLocal,
  contradictoryOrInsufficientEvidence,
}

/// Current aggregate evidence about whether uncovered attachment payloads are
/// automatically repairable from the presently readable Messages source.
///
/// This is neither coverage truth nor Operating authority. In particular,
/// [AppCzarAttachmentRepairOpportunityCondition.absent] says only that no
/// current automatic source-backed work was proved. Evaluators must still
/// inspect all uncertainty, conflict, record-backed recovery, and binding
/// evidence before selecting a coordinator.
@immutable
final class AppCzarAttachmentRepairabilityObservation {
  const AppCzarAttachmentRepairabilityObservation({
    required this.condition,
    required this.availableFromMessagesCount,
    required this.sourceAbsentCount,
    required this.sourceUnknownCount,
    required this.recordBackedRecoveryCount,
    required this.unsafeOrConflictingCount,
    required this.archiveScopeIdentity,
    required this.archiveGeneration,
    this.issue,
  });

  const AppCzarAttachmentRepairabilityObservation.unknown({
    required String issue,
    String? archiveScopeIdentity,
    int? archiveGeneration,
    int? availableFromMessagesCount,
    int? sourceAbsentCount,
    int? sourceUnknownCount,
    int? recordBackedRecoveryCount,
    int? unsafeOrConflictingCount,
  }) : this(
         condition: AppCzarAttachmentRepairOpportunityCondition.unknown,
         availableFromMessagesCount: availableFromMessagesCount,
         sourceAbsentCount: sourceAbsentCount,
         sourceUnknownCount: sourceUnknownCount,
         recordBackedRecoveryCount: recordBackedRecoveryCount,
         unsafeOrConflictingCount: unsafeOrConflictingCount,
         archiveScopeIdentity: archiveScopeIdentity,
         archiveGeneration: archiveGeneration,
         issue: issue,
       );

  final AppCzarAttachmentRepairOpportunityCondition condition;
  final int? availableFromMessagesCount;
  final int? sourceAbsentCount;
  final int? sourceUnknownCount;
  final int? recordBackedRecoveryCount;
  final int? unsafeOrConflictingCount;
  final String? archiveScopeIdentity;
  final int? archiveGeneration;
  final String? issue;

  int? get needAttentionCount {
    final available = availableFromMessagesCount;
    final absent = sourceAbsentCount;
    final unknown = sourceUnknownCount;
    final recordBacked = recordBackedRecoveryCount;
    final unsafe = unsafeOrConflictingCount;
    if (available == null ||
        absent == null ||
        unknown == null ||
        recordBacked == null ||
        unsafe == null) {
      return null;
    }
    return available + absent + unknown + recordBacked + unsafe;
  }

  bool hasCoherentMaterialCounts(
    AppCzarAttachmentCoverageObservation coverage,
  ) {
    if (condition == AppCzarAttachmentRepairOpportunityCondition.unknown) {
      return true;
    }
    final available = availableFromMessagesCount;
    final absent = sourceAbsentCount;
    final unknown = sourceUnknownCount;
    final recordBacked = recordBackedRecoveryCount;
    final unsafe = unsafeOrConflictingCount;
    final scope = archiveScopeIdentity;
    final generation = archiveGeneration;
    final coverageMissing = coverage.missingCount;
    final coverageUnverifiable = coverage.unverifiableCount;
    if (available == null ||
        absent == null ||
        unknown == null ||
        recordBacked == null ||
        unsafe == null ||
        available < 0 ||
        absent < 0 ||
        unknown < 0 ||
        recordBacked < 0 ||
        unsafe < 0 ||
        coverageMissing == null ||
        coverageUnverifiable == null ||
        available + absent + unknown + recordBacked != coverageMissing ||
        unsafe != coverageUnverifiable ||
        scope == null ||
        scope.isEmpty ||
        generation == null ||
        generation < 0) {
      return false;
    }
    return switch (condition) {
      AppCzarAttachmentRepairOpportunityCondition.present =>
        available > 0 && unknown == 0 && unsafe == 0,
      AppCzarAttachmentRepairOpportunityCondition.absent =>
        available == 0 && unknown == 0 && unsafe == 0,
      AppCzarAttachmentRepairOpportunityCondition.unknown => true,
    };
  }

  bool get isOperatingSafe {
    return condition == AppCzarAttachmentRepairOpportunityCondition.absent &&
        availableFromMessagesCount == 0 &&
        sourceUnknownCount == 0 &&
        recordBackedRecoveryCount == 0 &&
        unsafeOrConflictingCount == 0;
  }
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
    this.repairability =
        const AppCzarAttachmentRepairabilityObservation.unknown(
          issue: 'Current attachment repairability was not observed.',
        ),
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
      repairability: AppCzarAttachmentRepairabilityObservation.unknown(
        issue: issue,
      ),
      issue: issue,
    );
  }

  final AppCzarArchiveCondition condition;
  final String label;
  final AppCzarAttachmentCoverageObservation coverage;
  final AppCzarAttachmentRepairabilityObservation repairability;
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

  bool get hasCoherentRepairabilityBinding {
    if (!repairability.hasCoherentMaterialCounts(coverage)) {
      return false;
    }
    if (repairability.condition ==
        AppCzarAttachmentRepairOpportunityCondition.unknown) {
      return true;
    }
    final scope = archiveScopeIdentity;
    final generation = archiveGeneration;
    return scope != null &&
        scope.isNotEmpty &&
        generation != null &&
        generation >= 0 &&
        repairability.archiveScopeIdentity == scope &&
        repairability.archiveGeneration == generation;
  }

  /// Whether this observation identifies one exact archive occurrence.
  ///
  /// Operating Session uses this read-only evidence to bind its process-local
  /// occurrence. It is not mutation authority.
  bool get hasCompleteArchiveBinding {
    final scope = archiveScopeIdentity;
    final generation = archiveGeneration;
    final path = resolvedPath;
    return scope != null &&
        scope.isNotEmpty &&
        generation != null &&
        generation >= 0 &&
        path != null &&
        path.isNotEmpty &&
        coverage.archiveScopeIdentity == scope &&
        coverage.archiveGeneration == generation &&
        repairability.archiveScopeIdentity == scope &&
        repairability.archiveGeneration == generation &&
        hasCoherentCoverageBinding &&
        hasCoherentRepairabilityBinding;
  }
}

@immutable
final class AppCzarObservationSet {
  AppCzarObservationSet({
    required this.root,
    AppCzarInitialConstructionScopeObservation? initialConstructionScope,
    required this.source,
    this.contactsPrerequisite = const AppCzarContactsPrerequisiteObservation(
      condition: AppCzarContactsPrerequisiteCondition.viableEmpty,
      contactCount: 0,
      viableStoreCount: 1,
    ),
    required this.importStore,
    required this.graphStore,
    required this.overlay,
    required this.attachmentArchive,
    this.localDataRepairSafety =
        const AppCzarLocalDataRepairSafetyObservation.unknown(
          issue: 'Local Data Repair safety was not observed.',
        ),
  }) : initialConstructionScope =
           initialConstructionScope ??
           deriveCompatibilityInitialConstructionScope(importStore, graphStore);

  final AppCzarRootObservation root;
  final AppCzarInitialConstructionScopeObservation initialConstructionScope;
  final AppCzarSourceObservation source;
  final AppCzarContactsPrerequisiteObservation contactsPrerequisite;
  final AppCzarDatabaseObservation importStore;
  final AppCzarDatabaseObservation graphStore;
  final AppCzarDatabaseObservation overlay;
  final AppCzarArchiveObservation attachmentArchive;
  final AppCzarLocalDataRepairSafetyObservation localDataRepairSafety;
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
    this.initialConstructionScope,
    this.source,
    this.contactsPrerequisite,
    this.importStore,
    this.graphStore,
    this.overlay,
    this.attachmentArchive,
    this.localDataRepairSafety,
    this.assessment,
  });

  factory AppCzarAssessmentState.initial(int generation) {
    return AppCzarAssessmentState(generation: generation);
  }

  final int generation;
  final AppCzarRootObservation? root;
  final AppCzarInitialConstructionScopeObservation? initialConstructionScope;
  final AppCzarSourceObservation? source;
  final AppCzarContactsPrerequisiteObservation? contactsPrerequisite;
  final AppCzarDatabaseObservation? importStore;
  final AppCzarDatabaseObservation? graphStore;
  final AppCzarDatabaseObservation? overlay;
  final AppCzarArchiveObservation? attachmentArchive;
  final AppCzarLocalDataRepairSafetyObservation? localDataRepairSafety;
  final AppCzarAssessment? assessment;

  bool get isComplete => assessment != null;

  AppCzarAssessmentState copyWith({
    AppCzarRootObservation? root,
    AppCzarInitialConstructionScopeObservation? initialConstructionScope,
    AppCzarSourceObservation? source,
    AppCzarContactsPrerequisiteObservation? contactsPrerequisite,
    AppCzarDatabaseObservation? importStore,
    AppCzarDatabaseObservation? graphStore,
    AppCzarDatabaseObservation? overlay,
    AppCzarArchiveObservation? attachmentArchive,
    AppCzarLocalDataRepairSafetyObservation? localDataRepairSafety,
    AppCzarAssessment? assessment,
  }) {
    return AppCzarAssessmentState(
      generation: generation,
      root: root ?? this.root,
      initialConstructionScope:
          initialConstructionScope ?? this.initialConstructionScope,
      source: source ?? this.source,
      contactsPrerequisite: contactsPrerequisite ?? this.contactsPrerequisite,
      importStore: importStore ?? this.importStore,
      graphStore: graphStore ?? this.graphStore,
      overlay: overlay ?? this.overlay,
      attachmentArchive: attachmentArchive ?? this.attachmentArchive,
      localDataRepairSafety:
          localDataRepairSafety ?? this.localDataRepairSafety,
      assessment: assessment ?? this.assessment,
    );
  }

  AppCzarObservationSet requireObservationSet() {
    return AppCzarObservationSet(
      root: root!,
      initialConstructionScope:
          initialConstructionScope ??
          deriveCompatibilityInitialConstructionScope(
            importStore!,
            graphStore!,
          ),
      source: source!,
      contactsPrerequisite:
          contactsPrerequisite ??
          const AppCzarContactsPrerequisiteObservation(
            condition: AppCzarContactsPrerequisiteCondition.viableEmpty,
            contactCount: 0,
            viableStoreCount: 1,
          ),
      importStore: importStore!,
      graphStore: graphStore!,
      overlay: overlay!,
      attachmentArchive: attachmentArchive!,
      localDataRepairSafety:
          localDataRepairSafety ??
          const AppCzarLocalDataRepairSafetyObservation.unknown(
            issue: 'Local Data Repair safety was not observed.',
          ),
    );
  }
}

bool _sameStrings(List<String> left, List<String> right) {
  if (left.length != right.length) {
    return false;
  }
  for (var index = 0; index < left.length; index += 1) {
    if (left[index] != right[index]) {
      return false;
    }
  }
  return true;
}

AppCzarInitialConstructionScopeObservation
deriveCompatibilityInitialConstructionScope(
  AppCzarDatabaseObservation importStore,
  AppCzarDatabaseObservation graphStore,
) {
  if (importStore.condition == AppCzarDatabaseCondition.unknown ||
      graphStore.condition == AppCzarDatabaseCondition.unknown) {
    return const AppCzarInitialConstructionScopeObservation.unknown(
      'The compatibility evidence did not establish local store scope.',
    );
  }
  if (importStore.condition == AppCzarDatabaseCondition.unhealthy ||
      graphStore.condition == AppCzarDatabaseCondition.unhealthy) {
    return AppCzarInitialConstructionScopeObservation(
      condition: AppCzarInitialConstructionScopeCondition.unhealthy,
      importMessageCount: importStore.messageCount,
      graphMessageCount: graphStore.messageCount,
      graphChatCount: graphStore.chatCount,
      graphEdgeCount: graphStore.chatMessageEdgeCount,
      nonLiveSourceCount: null,
      hasRetiredDerivedArtifacts: false,
      issue: 'A local store is unhealthy.',
    );
  }
  final counts = <int>[
    importStore.messageCount ?? 0,
    graphStore.messageCount ?? 0,
    graphStore.chatCount ?? 0,
    graphStore.chatMessageEdgeCount ?? 0,
  ];
  return AppCzarInitialConstructionScopeObservation(
    condition: counts.any((count) => count > 0)
        ? AppCzarInitialConstructionScopeCondition.consequentialData
        : AppCzarInitialConstructionScopeCondition.safeEmpty,
    importMessageCount: counts[0],
    graphMessageCount: counts[1],
    graphChatCount: counts[2],
    graphEdgeCount: counts[3],
    nonLiveSourceCount: 0,
    hasRetiredDerivedArtifacts: false,
    issue: null,
  );
}
