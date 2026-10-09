import 'package:meta/meta.dart';

import '../../../core/util/count_label_formatter.dart';
import '../domain/app_czar_models.dart';

enum AppCzarPresentationSignificance {
  healthy,
  attention,
  informational,
  unknown,
  pending,
}

enum AppCzarDiagnosticEvidenceStatus {
  confirmedPositive('TRUE'),
  confirmedNegative('FALSE'),
  insufficient('UNKNOWN'),
  conflict('CONFLICT');

  const AppCzarDiagnosticEvidenceStatus(this.label);

  final String label;
}

enum AppCzarPresentationRowId {
  developmentDataFolder,
  initialConstructionScope,
  messagesDatabase,
  messagesSourceSample,
  contactsPrerequisite,
  importStore,
  graphStore,
  overlay,
  localDataset,
  localDataRepairSafety,
  attachmentArchive,
  attachmentCoverage,
  attachmentRepairOpportunity,
  newMessages,
}

@immutable
final class AppCzarPresentationRow {
  AppCzarPresentationRow({
    required this.id,
    required this.label,
    required this.value,
    required this.detail,
    required this.significance,
    required Iterable<AppCzarFactId> factIds,
    required Iterable<String> evidence,
  }) : factIds = List<AppCzarFactId>.unmodifiable(factIds),
       evidence = List<String>.unmodifiable(evidence);

  final AppCzarPresentationRowId id;
  final String label;
  final String value;
  final String detail;
  final AppCzarPresentationSignificance significance;
  final List<AppCzarFactId> factIds;
  final List<String> evidence;
}

@immutable
final class AppCzarAssessmentPresentation {
  AppCzarAssessmentPresentation({
    required this.complete,
    required Iterable<AppCzarPresentationRow> rows,
    required this.diagnosis,
    required this.virtualCoordinator,
  }) : rows = List<AppCzarPresentationRow>.unmodifiable(rows);

  final bool complete;
  final List<AppCzarPresentationRow> rows;
  final String diagnosis;
  final String virtualCoordinator;

  AppCzarPresentationRow row(AppCzarPresentationRowId id) {
    return rows.singleWhere((row) => row.id == id);
  }
}

@immutable
final class AppCzarDiagnosticProjectionInput {
  const AppCzarDiagnosticProjectionInput({
    required this.occurrenceSequence,
    required this.assessmentGeneration,
    required this.capturedAssessmentState,
    required this.capturedAt,
  });

  final int occurrenceSequence;
  final int assessmentGeneration;
  final AppCzarAssessmentState capturedAssessmentState;
  final DateTime capturedAt;
}

@immutable
final class AppCzarDiagnosticPresentationRow {
  const AppCzarDiagnosticPresentationRow({
    required this.id,
    required this.label,
    required this.value,
    required this.detail,
    required this.status,
    required this.evidence,
  });

  final AppCzarPresentationRowId id;
  final String label;
  final String value;
  final String detail;
  final AppCzarDiagnosticEvidenceStatus status;
  final List<String> evidence;
}

@immutable
final class AppCzarDiagnosticPresentation {
  AppCzarDiagnosticPresentation({
    required this.occurrenceSequence,
    required this.assessmentGeneration,
    required this.capturedAt,
    required this.diagnosis,
    required Iterable<AppCzarDiagnosticPresentationRow> rows,
  }) : rows = List<AppCzarDiagnosticPresentationRow>.unmodifiable(rows);

  final int occurrenceSequence;
  final int assessmentGeneration;
  final DateTime capturedAt;
  final String diagnosis;
  final List<AppCzarDiagnosticPresentationRow> rows;
}

/// Pure projection from current observations and evaluated facts to UI copy.
///
/// Significance is deliberately assigned per proposition. It never feeds back
/// into fact evaluation or virtual-coordinator selection.
final class AppCzarPresentationProjector {
  const AppCzarPresentationProjector();

  AppCzarDiagnosticPresentation projectDiagnostic(
    AppCzarDiagnosticProjectionInput input,
  ) {
    final state = input.capturedAssessmentState;
    final assessment = state.assessment;
    if (!state.isComplete ||
        assessment == null ||
        state.generation != input.assessmentGeneration ||
        assessment.virtualCoordinator !=
            AppCzarVirtualCoordinator.diagnosticReview) {
      throw StateError(
        'Diagnostic projection requires one completed Diagnostic Review assessment generation.',
      );
    }

    final ordinary = project(state);
    final rows = <AppCzarDiagnosticPresentationRow>[];
    for (final row in ordinary.rows) {
      rows.add(_diagnosticRow(state, assessment, row));
      if (row.id == AppCzarPresentationRowId.localDataset) {
        rows.add(_diagnosticLocalDataRepairSafetyRow(state, assessment));
      }
    }
    return AppCzarDiagnosticPresentation(
      occurrenceSequence: input.occurrenceSequence,
      assessmentGeneration: input.assessmentGeneration,
      capturedAt: input.capturedAt,
      diagnosis: assessment.diagnosis,
      rows: rows,
    );
  }

  AppCzarDiagnosticPresentationRow _diagnosticRow(
    AppCzarAssessmentState state,
    AppCzarAssessment assessment,
    AppCzarPresentationRow row,
  ) {
    final evidence = <String>[
      for (final factId in row.factIds)
        _bounded(
          'Fact ${assessment.fact(factId).label}: '
          '${assessment.fact(factId).truth.label} — '
          '${assessment.fact(factId).detail}',
        ),
      for (final item in row.evidence) _bounded(item),
    ];
    return AppCzarDiagnosticPresentationRow(
      id: row.id,
      label: row.label,
      value: row.value,
      detail: row.detail,
      status: _diagnosticStatus(state, assessment, row),
      evidence: List<String>.unmodifiable(evidence.take(12)),
    );
  }

  AppCzarDiagnosticPresentationRow _diagnosticLocalDataRepairSafetyRow(
    AppCzarAssessmentState state,
    AppCzarAssessment assessment,
  ) {
    final observation = state.requireObservationSet().localDataRepairSafety;
    final fact = assessment.fact(
      AppCzarFactId.localDataRepairMayResetDerivedStores,
    );
    final evidence = <String>[
      _bounded('Fact ${fact.label}: ${fact.truth.label} — ${fact.detail}'),
      'Safety condition: ${observation.condition.name}.',
      if (observation.archiveRootPath != null)
        _bounded('Bound archive root: ${observation.archiveRootPath}.'),
      if (observation.archiveInstanceId != null)
        _bounded('Bound archive instance: ${observation.archiveInstanceId}.'),
      if (observation.archiveScopeIdentity != null)
        _bounded('Bound archive scope: ${observation.archiveScopeIdentity}.'),
      if (observation.archiveGeneration != null)
        'Bound archive generation: ${observation.archiveGeneration}.',
      if (observation.issue != null) _bounded(observation.issue!),
    ];
    return AppCzarDiagnosticPresentationRow(
      id: AppCzarPresentationRowId.localDataRepairSafety,
      label: 'Local Data Repair safety',
      value: switch (observation.condition) {
        AppCzarLocalDataRepairSafetyCondition.rebuildableLiveOnlyPartial =>
          'Reconstructible live-only partial data',
        AppCzarLocalDataRepairSafetyCondition.protectedMaterialPresent =>
          'Protected material present',
        AppCzarLocalDataRepairSafetyCondition.sourceFactMissing =>
          'Required current source fact missing',
        AppCzarLocalDataRepairSafetyCondition.retiredArtifactsPresent =>
          'Retired artifacts present',
        AppCzarLocalDataRepairSafetyCondition.unsupportedOrCorrupt =>
          'Unsupported or unhealthy material',
        AppCzarLocalDataRepairSafetyCondition.unknown =>
          'Could not be established',
      },
      detail: fact.detail,
      status: switch (fact.truth) {
        AppCzarTruth.trueValue =>
          AppCzarDiagnosticEvidenceStatus.confirmedPositive,
        AppCzarTruth.falseValue =>
          AppCzarDiagnosticEvidenceStatus.confirmedNegative,
        AppCzarTruth.unknown => AppCzarDiagnosticEvidenceStatus.insufficient,
      },
      evidence: List<String>.unmodifiable(evidence.take(12)),
    );
  }

  AppCzarAssessmentPresentation project(AppCzarAssessmentState state) {
    final assessment = state.assessment;
    if (assessment == null) {
      return AppCzarAssessmentPresentation(
        complete: false,
        rows: _pendingRows(),
        diagnosis: 'Still assessing…',
        virtualCoordinator: 'Not selected yet',
      );
    }

    final observations = state.requireObservationSet();
    return AppCzarAssessmentPresentation(
      complete: true,
      rows: <AppCzarPresentationRow>[
        _rootRow(observations.root, assessment),
        _initialConstructionScopeRow(
          observations.initialConstructionScope,
          assessment,
        ),
        _sourceRow(observations.source, assessment),
        _sourceSampleRow(observations.source, assessment),
        _contactsPrerequisiteRow(observations.contactsPrerequisite, assessment),
        _databaseRow(
          id: AppCzarPresentationRowId.importStore,
          label: 'MessageLens import data',
          factId: AppCzarFactId.importStoreHealthy,
          observation: observations.importStore,
          assessment: assessment,
        ),
        _databaseRow(
          id: AppCzarPresentationRowId.graphStore,
          label: 'MessageLens conversation data',
          factId: AppCzarFactId.graphStoreHealthy,
          observation: observations.graphStore,
          assessment: assessment,
        ),
        _overlayRow(observations.overlay, assessment),
        _localDatasetRow(observations, assessment),
        _archiveRow(observations.attachmentArchive, assessment),
        _attachmentCoverageRow(
          observations.attachmentArchive.coverage,
          assessment,
        ),
        _attachmentRepairOpportunityRow(
          observations.attachmentArchive.repairability,
          assessment,
        ),
        _newMessagesRow(observations, assessment),
      ],
      diagnosis: assessment.diagnosis,
      virtualCoordinator: assessment.virtualCoordinator.displayName,
    );
  }

  AppCzarDiagnosticEvidenceStatus _diagnosticStatus(
    AppCzarAssessmentState state,
    AppCzarAssessment assessment,
    AppCzarPresentationRow row,
  ) {
    if (_hasLiteralConflict(state, row.id)) {
      return AppCzarDiagnosticEvidenceStatus.conflict;
    }
    final truths = row.factIds.map((id) => assessment.fact(id).truth);
    if (truths.contains(AppCzarTruth.unknown)) {
      return AppCzarDiagnosticEvidenceStatus.insufficient;
    }
    if (truths.contains(AppCzarTruth.falseValue)) {
      return AppCzarDiagnosticEvidenceStatus.confirmedNegative;
    }
    return AppCzarDiagnosticEvidenceStatus.confirmedPositive;
  }

  bool _hasLiteralConflict(
    AppCzarAssessmentState state,
    AppCzarPresentationRowId rowId,
  ) {
    final observations = state.requireObservationSet();
    return switch (rowId) {
      AppCzarPresentationRowId.messagesSourceSample =>
        observations.source.sampleStable == false,
      AppCzarPresentationRowId.attachmentArchive =>
        observations.attachmentArchive.condition ==
                AppCzarArchiveCondition.available &&
            !observations.attachmentArchive.hasCompleteArchiveBinding,
      AppCzarPresentationRowId.attachmentCoverage =>
        !observations.attachmentArchive.hasCoherentCoverageBinding,
      AppCzarPresentationRowId.attachmentRepairOpportunity =>
        !observations.attachmentArchive.hasCoherentRepairabilityBinding ||
            (observations
                        .attachmentArchive
                        .repairability
                        .unsafeOrConflictingCount ??
                    0) >
                0,
      AppCzarPresentationRowId.newMessages => _hasSourceLocalDirectionConflict(
        observations,
      ),
      AppCzarPresentationRowId.developmentDataFolder ||
      AppCzarPresentationRowId.initialConstructionScope ||
      AppCzarPresentationRowId.messagesDatabase ||
      AppCzarPresentationRowId.contactsPrerequisite ||
      AppCzarPresentationRowId.importStore ||
      AppCzarPresentationRowId.graphStore ||
      AppCzarPresentationRowId.overlay ||
      AppCzarPresentationRowId.localDataset ||
      AppCzarPresentationRowId.localDataRepairSafety => false,
    };
  }

  bool _hasSourceLocalDirectionConflict(AppCzarObservationSet observations) {
    final sourceCount = observations.source.messageCount;
    final sourceHighWater = observations.source.maxRowId;
    final localCount = observations.importStore.liveMessageCount;
    final localHighWater = observations.importStore.liveMaxSourceRowId;
    return (sourceCount != null &&
            localCount != null &&
            sourceCount < localCount) ||
        (sourceHighWater != null &&
            localHighWater != null &&
            sourceHighWater < localHighWater);
  }

  String _bounded(String value) {
    const maximumLength = 320;
    if (value.length <= maximumLength) {
      return value;
    }
    return '${value.substring(0, maximumLength - 1)}…';
  }

  List<AppCzarPresentationRow> _pendingRows() {
    const labels = <AppCzarPresentationRowId, String>{
      AppCzarPresentationRowId.developmentDataFolder: 'Development data folder',
      AppCzarPresentationRowId.initialConstructionScope:
          'Initial construction scope',
      AppCzarPresentationRowId.messagesDatabase: 'Messages database',
      AppCzarPresentationRowId.messagesSourceSample: 'Messages source sample',
      AppCzarPresentationRowId.contactsPrerequisite: 'Contacts prerequisite',
      AppCzarPresentationRowId.importStore: 'MessageLens import data',
      AppCzarPresentationRowId.graphStore: 'MessageLens conversation data',
      AppCzarPresentationRowId.overlay: 'MessageLens overlay',
      AppCzarPresentationRowId.localDataset: 'Local message dataset',
      AppCzarPresentationRowId.attachmentArchive: 'Attachment archive',
      AppCzarPresentationRowId.attachmentCoverage: 'Attachment coverage',
      AppCzarPresentationRowId.attachmentRepairOpportunity:
          'Current attachment repair opportunity',
      AppCzarPresentationRowId.newMessages: 'New messages',
    };
    return <AppCzarPresentationRow>[
      for (final entry in labels.entries)
        AppCzarPresentationRow(
          id: entry.key,
          label: entry.value,
          value: 'Checking',
          detail: 'Checking current evidence…',
          significance: AppCzarPresentationSignificance.pending,
          factIds: const <AppCzarFactId>[],
          evidence: const <String>[],
        ),
    ];
  }

  AppCzarPresentationRow _rootRow(
    AppCzarRootObservation observation,
    AppCzarAssessment assessment,
  ) {
    final fact = assessment.fact(AppCzarFactId.developmentRootAdmitted);
    return AppCzarPresentationRow(
      id: AppCzarPresentationRowId.developmentDataFolder,
      label: 'Development data folder',
      value: observation.admitted ? 'Admitted' : 'Not admitted',
      detail: observation.path,
      significance: observation.admitted
          ? AppCzarPresentationSignificance.healthy
          : AppCzarPresentationSignificance.attention,
      factIds: const <AppCzarFactId>[AppCzarFactId.developmentRootAdmitted],
      evidence: <String>[
        'Admission result: ${observation.admitted ? 'admitted' : 'not admitted'}.',
        'Observed data root: ${observation.path}.',
        'Fact result: ${fact.truth.label}.',
      ],
    );
  }

  AppCzarPresentationRow _sourceRow(
    AppCzarSourceObservation observation,
    AppCzarAssessment assessment,
  ) {
    final fact = assessment.fact(AppCzarFactId.messagesSourceReadable);
    switch (observation.condition) {
      case AppCzarSourceCondition.readable:
        final count = observation.messageCount;
        final highWater = observation.maxRowId;
        return AppCzarPresentationRow(
          id: AppCzarPresentationRowId.messagesDatabase,
          label: 'Messages database',
          value: count == null
              ? 'Readable'
              : 'Readable — ${CountLabelFormatter.messages(count)}',
          detail: highWater == null
              ? fact.detail
              : 'Current high-water: $highWater.',
          significance: AppCzarPresentationSignificance.healthy,
          factIds: const <AppCzarFactId>[AppCzarFactId.messagesSourceReadable],
          evidence: <String>[
            'The current Messages source was opened read-only.',
            if (count != null) 'Message count: $count.',
            if (highWater != null) 'High-water: $highWater.',
          ],
        );
      case AppCzarSourceCondition.accessDenied:
      case AppCzarSourceCondition.unavailable:
        return AppCzarPresentationRow(
          id: AppCzarPresentationRowId.messagesDatabase,
          label: 'Messages database',
          value: 'Cannot currently be read',
          detail: observation.issue ?? fact.detail,
          significance: AppCzarPresentationSignificance.attention,
          factIds: const <AppCzarFactId>[AppCzarFactId.messagesSourceReadable],
          evidence: <String>[
            'Source-readability result: unavailable.',
            if (observation.issue != null) observation.issue!,
          ],
        );
      case AppCzarSourceCondition.unknown:
        return AppCzarPresentationRow(
          id: AppCzarPresentationRowId.messagesDatabase,
          label: 'Messages database',
          value: 'Readability unknown',
          detail: observation.issue ?? fact.detail,
          significance: AppCzarPresentationSignificance.unknown,
          factIds: const <AppCzarFactId>[AppCzarFactId.messagesSourceReadable],
          evidence: <String>[
            'Source-readability result: inconclusive.',
            if (observation.issue != null) observation.issue!,
          ],
        );
    }
  }

  AppCzarPresentationRow _initialConstructionScopeRow(
    AppCzarInitialConstructionScopeObservation observation,
    AppCzarAssessment assessment,
  ) {
    final fact = assessment.fact(AppCzarFactId.initialConstructionScopeSafe);
    return AppCzarPresentationRow(
      id: AppCzarPresentationRowId.initialConstructionScope,
      label: 'Initial construction scope',
      value: switch (observation.condition) {
        AppCzarInitialConstructionScopeCondition.safeEmpty => 'Safe empty',
        AppCzarInitialConstructionScopeCondition.consequentialData =>
          'Consequential data present',
        AppCzarInitialConstructionScopeCondition.protectedNonLiveData =>
          'Protected non-live data present',
        AppCzarInitialConstructionScopeCondition.retiredOrUnsupportedMaterial =>
          'Retired or unsupported material present',
        AppCzarInitialConstructionScopeCondition.unhealthy => 'Unhealthy',
        AppCzarInitialConstructionScopeCondition.unknown => 'Unknown',
      },
      detail: fact.detail,
      significance: switch (observation.condition) {
        AppCzarInitialConstructionScopeCondition.safeEmpty =>
          AppCzarPresentationSignificance.healthy,
        AppCzarInitialConstructionScopeCondition.unknown =>
          AppCzarPresentationSignificance.unknown,
        _ => AppCzarPresentationSignificance.informational,
      },
      factIds: const <AppCzarFactId>[
        AppCzarFactId.initialConstructionScopeSafe,
      ],
      evidence: <String>[
        'Import messages: ${observation.importMessageCount ?? 'unknown'}.',
        'Graph messages: ${observation.graphMessageCount ?? 'unknown'}.',
        'Graph chats: ${observation.graphChatCount ?? 'unknown'}.',
        'Graph edges: ${observation.graphEdgeCount ?? 'unknown'}.',
        'Non-live sources: ${observation.nonLiveSourceCount ?? 'unknown'}.',
        'Retired derived artifacts: ${observation.hasRetiredDerivedArtifacts}.',
      ],
    );
  }

  AppCzarPresentationRow _contactsPrerequisiteRow(
    AppCzarContactsPrerequisiteObservation observation,
    AppCzarAssessment assessment,
  ) {
    final fact = assessment.fact(AppCzarFactId.contactsPrerequisiteSatisfied);
    return AppCzarPresentationRow(
      id: AppCzarPresentationRowId.contactsPrerequisite,
      label: 'Contacts prerequisite',
      value: switch (observation.condition) {
        AppCzarContactsPrerequisiteCondition.notRequiredForCurrentScope =>
          'Not required for this jurisdiction',
        AppCzarContactsPrerequisiteCondition.viableWithContacts =>
          'Viable — ${observation.contactCount} contacts',
        AppCzarContactsPrerequisiteCondition.viableEmpty =>
          'Viable — zero contacts',
        AppCzarContactsPrerequisiteCondition.accessDenied =>
          'Current read denied',
        AppCzarContactsPrerequisiteCondition.unavailable =>
          'No viable current database',
        AppCzarContactsPrerequisiteCondition.invalidOrCorrupt =>
          'Invalid or corrupt',
        AppCzarContactsPrerequisiteCondition.unknown => 'Unknown',
      },
      detail: observation.issue ?? fact.detail,
      significance: switch (observation.condition) {
        AppCzarContactsPrerequisiteCondition.viableWithContacts ||
        AppCzarContactsPrerequisiteCondition.viableEmpty =>
          AppCzarPresentationSignificance.healthy,
        AppCzarContactsPrerequisiteCondition.notRequiredForCurrentScope =>
          AppCzarPresentationSignificance.informational,
        AppCzarContactsPrerequisiteCondition.accessDenied ||
        AppCzarContactsPrerequisiteCondition.unavailable ||
        AppCzarContactsPrerequisiteCondition.invalidOrCorrupt =>
          AppCzarPresentationSignificance.attention,
        AppCzarContactsPrerequisiteCondition.unknown =>
          AppCzarPresentationSignificance.unknown,
      },
      factIds: const <AppCzarFactId>[
        AppCzarFactId.contactsPrerequisiteSatisfied,
      ],
      evidence: <String>[
        'Contacts condition: ${observation.condition.name}.',
        if (observation.contactCount != null)
          'Contact count: ${observation.contactCount}.',
        if (observation.viableStoreCount != null)
          'Viable store count: ${observation.viableStoreCount}.',
      ],
    );
  }

  AppCzarPresentationRow _sourceSampleRow(
    AppCzarSourceObservation observation,
    AppCzarAssessment assessment,
  ) {
    final fact = assessment.fact(AppCzarFactId.sourceSampleStable);
    final stable = observation.sampleStable;
    return AppCzarPresentationRow(
      id: AppCzarPresentationRowId.messagesSourceSample,
      label: 'Messages source sample',
      value: stable == null
          ? 'Stability unknown'
          : stable
          ? 'Stable'
          : 'Changed during assessment',
      detail: fact.detail,
      significance: stable == null
          ? AppCzarPresentationSignificance.unknown
          : stable
          ? AppCzarPresentationSignificance.healthy
          : AppCzarPresentationSignificance.informational,
      factIds: const <AppCzarFactId>[AppCzarFactId.sourceSampleStable],
      evidence: <String>[
        if (stable == null)
          'No completed bounded sample comparison is present.',
        if (stable == true) 'Two bounded current samples agreed.',
        if (stable == false) 'Two bounded current samples did not agree.',
      ],
    );
  }

  AppCzarPresentationRow _databaseRow({
    required AppCzarPresentationRowId id,
    required String label,
    required AppCzarFactId factId,
    required AppCzarDatabaseObservation observation,
    required AppCzarAssessment assessment,
  }) {
    final fact = assessment.fact(factId);
    final count = observation.messageCount;
    return AppCzarPresentationRow(
      id: id,
      label: label,
      value: switch (observation.condition) {
        AppCzarDatabaseCondition.healthy =>
          count == null
              ? 'Healthy'
              : 'Healthy — ${CountLabelFormatter.messages(count)}',
        AppCzarDatabaseCondition.absent => 'Not present',
        AppCzarDatabaseCondition.unhealthy => 'Needs attention',
        AppCzarDatabaseCondition.unknown => 'Status unknown',
      },
      detail: fact.detail,
      significance: switch (observation.condition) {
        AppCzarDatabaseCondition.healthy =>
          AppCzarPresentationSignificance.healthy,
        AppCzarDatabaseCondition.absent =>
          AppCzarPresentationSignificance.informational,
        AppCzarDatabaseCondition.unhealthy =>
          AppCzarPresentationSignificance.attention,
        AppCzarDatabaseCondition.unknown =>
          AppCzarPresentationSignificance.unknown,
      },
      factIds: <AppCzarFactId>[factId],
      evidence: <String>[
        'Database condition: ${observation.condition.name}.',
        if (observation.schemaVersion != null)
          'Schema version: ${observation.schemaVersion}.',
        if (count != null) 'Message count: $count.',
        if (observation.issue != null) observation.issue!,
      ],
    );
  }

  AppCzarPresentationRow _overlayRow(
    AppCzarDatabaseObservation observation,
    AppCzarAssessment assessment,
  ) {
    final fact = assessment.fact(AppCzarFactId.overlayHealthy);
    return AppCzarPresentationRow(
      id: AppCzarPresentationRowId.overlay,
      label: 'MessageLens overlay',
      value: switch (observation.condition) {
        AppCzarDatabaseCondition.healthy => 'Healthy',
        AppCzarDatabaseCondition.absent => 'Not created yet',
        AppCzarDatabaseCondition.unhealthy => 'Needs attention',
        AppCzarDatabaseCondition.unknown => 'Status unknown',
      },
      detail: fact.detail,
      significance: switch (observation.condition) {
        AppCzarDatabaseCondition.healthy || AppCzarDatabaseCondition.absent =>
          AppCzarPresentationSignificance.healthy,
        AppCzarDatabaseCondition.unhealthy =>
          AppCzarPresentationSignificance.attention,
        AppCzarDatabaseCondition.unknown =>
          AppCzarPresentationSignificance.unknown,
      },
      factIds: const <AppCzarFactId>[AppCzarFactId.overlayHealthy],
      evidence: <String>[
        'Overlay condition: ${observation.condition.name}.',
        if (observation.schemaVersion != null)
          'Schema version: ${observation.schemaVersion}.',
        if (observation.issue != null) observation.issue!,
      ],
    );
  }

  AppCzarPresentationRow _localDatasetRow(
    AppCzarObservationSet observations,
    AppCzarAssessment assessment,
  ) {
    final fact = assessment.fact(AppCzarFactId.localDatasetComplete);
    final count = observations.graphStore.messageCount;
    return AppCzarPresentationRow(
      id: AppCzarPresentationRowId.localDataset,
      label: 'Local message dataset',
      value: switch (fact.truth) {
        AppCzarTruth.trueValue =>
          count == null
              ? 'Complete'
              : 'Complete — ${CountLabelFormatter.messages(count)}',
        AppCzarTruth.falseValue => 'Incomplete',
        AppCzarTruth.unknown => 'Completeness unknown',
      },
      detail: fact.detail,
      significance: switch (fact.truth) {
        AppCzarTruth.trueValue => AppCzarPresentationSignificance.healthy,
        AppCzarTruth.falseValue => AppCzarPresentationSignificance.attention,
        AppCzarTruth.unknown => AppCzarPresentationSignificance.unknown,
      },
      factIds: const <AppCzarFactId>[AppCzarFactId.localDatasetComplete],
      evidence: <String>[
        if (observations.importStore.messageCount != null)
          'Import message count: ${observations.importStore.messageCount}.',
        if (observations.graphStore.messageCount != null)
          'Graph message count: ${observations.graphStore.messageCount}.',
        if (observations.graphStore.chatCount != null)
          'Graph chat count: ${observations.graphStore.chatCount}.',
        if (observations.graphStore.chatMessageEdgeCount != null)
          'Graph chat-message edge count: ${observations.graphStore.chatMessageEdgeCount}.',
      ],
    );
  }

  AppCzarPresentationRow _archiveRow(
    AppCzarArchiveObservation observation,
    AppCzarAssessment assessment,
  ) {
    final fact = assessment.fact(AppCzarFactId.attachmentArchiveAvailable);
    return AppCzarPresentationRow(
      id: AppCzarPresentationRowId.attachmentArchive,
      label: 'Attachment archive',
      value: switch (observation.condition) {
        AppCzarArchiveCondition.available => 'Available — ${observation.label}',
        AppCzarArchiveCondition.readOnly =>
          'Available read-only — ${observation.label}',
        AppCzarArchiveCondition.notCreated => 'Not created yet',
        AppCzarArchiveCondition.unavailable => 'Unavailable',
        AppCzarArchiveCondition.unknown => 'Status unknown',
      },
      detail: fact.detail,
      significance: switch (observation.condition) {
        AppCzarArchiveCondition.available ||
        AppCzarArchiveCondition.notCreated =>
          AppCzarPresentationSignificance.healthy,
        AppCzarArchiveCondition.readOnly =>
          AppCzarPresentationSignificance.informational,
        AppCzarArchiveCondition.unavailable =>
          AppCzarPresentationSignificance.attention,
        AppCzarArchiveCondition.unknown =>
          AppCzarPresentationSignificance.unknown,
      },
      factIds: const <AppCzarFactId>[AppCzarFactId.attachmentArchiveAvailable],
      evidence: <String>[
        'Archive condition: ${observation.condition.name}.',
        'Archive label: ${observation.label}.',
        if (observation.resolvedPath != null)
          'Resolved archive path: ${observation.resolvedPath}.',
        if (observation.issue != null) observation.issue!,
      ],
    );
  }

  AppCzarPresentationRow _attachmentCoverageRow(
    AppCzarAttachmentCoverageObservation observation,
    AppCzarAssessment assessment,
  ) {
    final fact = assessment.fact(AppCzarFactId.attachmentCoverageComplete);
    final requiredCount = observation.requiredCount;
    final coveredCount = observation.coveredCount;
    final missingCount = observation.missingCount;
    final unverifiableCount = observation.unverifiableCount;
    return AppCzarPresentationRow(
      id: AppCzarPresentationRowId.attachmentCoverage,
      label: 'Attachment coverage',
      value: switch (fact.truth) {
        AppCzarTruth.trueValue =>
          'Complete — $coveredCount of $requiredCount required payloads covered',
        AppCzarTruth.falseValue =>
          'Incomplete — $missingCount required payloads are not covered',
        AppCzarTruth.unknown => 'Could not be established',
      },
      detail: fact.detail,
      significance: switch (fact.truth) {
        AppCzarTruth.trueValue => AppCzarPresentationSignificance.healthy,
        AppCzarTruth.falseValue => AppCzarPresentationSignificance.attention,
        AppCzarTruth.unknown => AppCzarPresentationSignificance.unknown,
      },
      factIds: const <AppCzarFactId>[AppCzarFactId.attachmentCoverageComplete],
      evidence: <String>[
        'Coverage condition: ${observation.condition.name}.',
        if (requiredCount != null) 'Required payload records: $requiredCount.',
        if (coveredCount != null) 'Covered payload records: $coveredCount.',
        if (missingCount != null) 'Uncovered payload records: $missingCount.',
        if (unverifiableCount != null)
          'Unverifiable payload records: $unverifiableCount.',
        if (observation.archiveGeneration != null)
          'Observed attachment generation: ${observation.archiveGeneration}.',
        if (observation.issue != null) observation.issue!,
      ],
    );
  }

  AppCzarPresentationRow _newMessagesRow(
    AppCzarObservationSet observations,
    AppCzarAssessment assessment,
  ) {
    final deltaKnown = assessment.fact(AppCzarFactId.sourceLocalDeltaKnown);
    final sourceAhead = assessment.fact(AppCzarFactId.sourceAheadOfLocal);
    final sourceCount = observations.source.messageCount;
    final localCount = observations.importStore.liveMessageCount;
    final sourceHighWater = observations.source.maxRowId;
    final localHighWater = observations.importStore.liveMaxSourceRowId;

    if (deltaKnown.truth != AppCzarTruth.trueValue ||
        sourceAhead.truth == AppCzarTruth.unknown) {
      return AppCzarPresentationRow(
        id: AppCzarPresentationRowId.newMessages,
        label: 'New messages',
        value: 'Unknown',
        detail: sourceAhead.detail,
        significance: AppCzarPresentationSignificance.unknown,
        factIds: const <AppCzarFactId>[
          AppCzarFactId.sourceLocalDeltaKnown,
          AppCzarFactId.sourceAheadOfLocal,
        ],
        evidence: <String>[
          if (sourceCount != null) 'Source message count: $sourceCount.',
          if (localCount != null) 'Local live-import count: $localCount.',
          if (sourceHighWater != null) 'Source high-water: $sourceHighWater.',
          if (localHighWater != null) 'Local high-water: $localHighWater.',
          'Delta result: ${sourceAhead.detail}',
        ],
      );
    }

    if (sourceAhead.truth == AppCzarTruth.falseValue) {
      return AppCzarPresentationRow(
        id: AppCzarPresentationRowId.newMessages,
        label: 'New messages',
        value: '0',
        detail: 'Source and MessageLens are current.',
        significance: AppCzarPresentationSignificance.healthy,
        factIds: const <AppCzarFactId>[
          AppCzarFactId.sourceLocalDeltaKnown,
          AppCzarFactId.sourceAheadOfLocal,
        ],
        evidence: <String>[
          'Source message count: $sourceCount.',
          'Local live-import count: $localCount.',
          'Source high-water: $sourceHighWater.',
          'Local high-water: $localHighWater.',
        ],
      );
    }

    final countDelta = sourceCount! - localCount!;
    return AppCzarPresentationRow(
      id: AppCzarPresentationRowId.newMessages,
      label: 'New messages',
      value: countDelta > 0
          ? CountLabelFormatter.formatCount(countDelta)
          : 'Detected',
      detail: 'Newer source data is available for MessageLens to update.',
      significance: AppCzarPresentationSignificance.informational,
      factIds: const <AppCzarFactId>[
        AppCzarFactId.sourceLocalDeltaKnown,
        AppCzarFactId.sourceAheadOfLocal,
      ],
      evidence: <String>[
        'Source message count: $sourceCount.',
        'Local live-import count: $localCount.',
        'Source high-water: $sourceHighWater.',
        'Local high-water: $localHighWater.',
      ],
    );
  }

  AppCzarPresentationRow _attachmentRepairOpportunityRow(
    AppCzarAttachmentRepairabilityObservation observation,
    AppCzarAssessment assessment,
  ) {
    final fact = assessment.fact(
      AppCzarFactId.attachmentRepairOpportunityPresent,
    );
    final available = observation.availableFromMessagesCount;
    final absent = observation.sourceAbsentCount;
    final unknown = observation.sourceUnknownCount;
    final recordBacked = observation.recordBackedRecoveryCount;
    final unsafe = observation.unsafeOrConflictingCount;
    final hasDebt = (observation.needAttentionCount ?? 0) > 0;
    return AppCzarPresentationRow(
      id: AppCzarPresentationRowId.attachmentRepairOpportunity,
      label: 'Current attachment repair opportunity',
      value: switch (fact.truth) {
        AppCzarTruth.trueValue =>
          'Available — $available payloads can be preserved now',
        AppCzarTruth.falseValue => 'No current automatic repair opportunity',
        AppCzarTruth.unknown => 'Could not be established',
      },
      detail: fact.detail,
      significance: switch (fact.truth) {
        AppCzarTruth.trueValue => AppCzarPresentationSignificance.attention,
        AppCzarTruth.falseValue =>
          hasDebt
              ? AppCzarPresentationSignificance.informational
              : AppCzarPresentationSignificance.healthy,
        AppCzarTruth.unknown => AppCzarPresentationSignificance.unknown,
      },
      factIds: const <AppCzarFactId>[
        AppCzarFactId.attachmentRepairOpportunityPresent,
      ],
      evidence: <String>[
        'Repair opportunity condition: ${observation.condition.name}.',
        if (available != null) 'Available from Messages: $available.',
        if (absent != null) 'Currently absent from Messages: $absent.',
        if (unknown != null) 'Source evidence unknown: $unknown.',
        if (recordBacked != null)
          'Record-backed recovery needed: $recordBacked.',
        if (unsafe != null) 'Unsafe or conflicting evidence: $unsafe.',
        if (observation.issue != null) observation.issue!,
      ],
    );
  }
}
