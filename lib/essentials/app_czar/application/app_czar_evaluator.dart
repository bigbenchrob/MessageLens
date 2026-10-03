import '../domain/app_czar_models.dart';

final class AppCzarEvaluator {
  const AppCzarEvaluator();

  AppCzarAssessment evaluate(AppCzarObservationSet observations) {
    final facts = <AppCzarFact>[
      _rootFact(observations.root),
      _sourceReadableFact(observations.source),
      _sourceStableFact(observations.source),
      _databaseFact(
        id: AppCzarFactId.importStoreHealthy,
        label: 'MessageLens import data',
        observation: observations.importStore,
      ),
      _databaseFact(
        id: AppCzarFactId.graphStoreHealthy,
        label: 'MessageLens conversation data',
        observation: observations.graphStore,
      ),
      _overlayFact(observations.overlay),
      _localDatasetFact(observations),
      _archiveFact(observations.attachmentArchive),
      _deltaKnownFact(observations),
      _sourceAheadFact(observations),
    ];

    final factsById = <AppCzarFactId, AppCzarFact>{
      for (final fact in facts) fact.id: fact,
    };
    final selection = _select(observations, factsById);
    return AppCzarAssessment(
      facts: facts,
      diagnosisKind: selection.kind,
      diagnosis: selection.diagnosis,
      virtualCoordinator: selection.coordinator,
    );
  }

  AppCzarFact _rootFact(AppCzarRootObservation observation) {
    return AppCzarFact(
      id: AppCzarFactId.developmentRootAdmitted,
      label: 'Development data root admitted',
      truth: observation.admitted
          ? AppCzarTruth.trueValue
          : AppCzarTruth.falseValue,
      detail: observation.path,
    );
  }

  AppCzarFact _sourceReadableFact(AppCzarSourceObservation observation) {
    final truth = switch (observation.condition) {
      AppCzarSourceCondition.readable => AppCzarTruth.trueValue,
      AppCzarSourceCondition.accessDenied ||
      AppCzarSourceCondition.unavailable => AppCzarTruth.falseValue,
      AppCzarSourceCondition.unknown => AppCzarTruth.unknown,
    };
    return AppCzarFact(
      id: AppCzarFactId.messagesSourceReadable,
      label: 'Messages database readable',
      truth: truth,
      detail: switch (observation.condition) {
        AppCzarSourceCondition.readable =>
          observation.messageCount != null && observation.maxRowId != null
              ? '${observation.messageCount} messages; high-water '
                    '${observation.maxRowId}.'
              : 'The current Messages source completed its read-only probe.',
        AppCzarSourceCondition.accessDenied ||
        AppCzarSourceCondition.unavailable ||
        AppCzarSourceCondition.unknown =>
          observation.issue ?? 'The Messages source could not be inspected.',
      },
    );
  }

  AppCzarFact _sourceStableFact(AppCzarSourceObservation observation) {
    final stable = observation.sampleStable;
    return AppCzarFact(
      id: AppCzarFactId.sourceSampleStable,
      label: 'Messages source sample stable',
      truth: stable == null
          ? AppCzarTruth.unknown
          : stable
          ? AppCzarTruth.trueValue
          : AppCzarTruth.falseValue,
      detail: stable == null
          ? 'A stable sample requires a readable Messages source.'
          : stable
          ? 'Two bounded current samples agree.'
          : 'The source changed between the two bounded samples.',
    );
  }

  AppCzarFact _databaseFact({
    required AppCzarFactId id,
    required String label,
    required AppCzarDatabaseObservation observation,
  }) {
    return AppCzarFact(
      id: id,
      label: label,
      truth: switch (observation.condition) {
        AppCzarDatabaseCondition.healthy => AppCzarTruth.trueValue,
        AppCzarDatabaseCondition.absent ||
        AppCzarDatabaseCondition.unhealthy => AppCzarTruth.falseValue,
        AppCzarDatabaseCondition.unknown => AppCzarTruth.unknown,
      },
      detail: switch (observation.condition) {
        AppCzarDatabaseCondition.healthy => _healthyDatabaseDetail(observation),
        AppCzarDatabaseCondition.absent => 'The store does not exist.',
        AppCzarDatabaseCondition.unhealthy ||
        AppCzarDatabaseCondition.unknown =>
          observation.issue ?? 'The store could not be inspected.',
      },
    );
  }

  String _healthyDatabaseDetail(AppCzarDatabaseObservation observation) {
    final evidence = <String>[
      if (observation.messageCount != null)
        '${observation.messageCount} messages',
      if (observation.schemaVersion != null)
        'schema ${observation.schemaVersion}',
    ];
    if (evidence.isEmpty) {
      return 'The store passed its bounded health reads.';
    }
    return '${evidence.join('; ')}.';
  }

  AppCzarFact _overlayFact(AppCzarDatabaseObservation observation) {
    return AppCzarFact(
      id: AppCzarFactId.overlayHealthy,
      label: 'Overlay safe to use',
      truth: switch (observation.condition) {
        AppCzarDatabaseCondition.healthy ||
        AppCzarDatabaseCondition.absent => AppCzarTruth.trueValue,
        AppCzarDatabaseCondition.unhealthy => AppCzarTruth.falseValue,
        AppCzarDatabaseCondition.unknown => AppCzarTruth.unknown,
      },
      detail: switch (observation.condition) {
        AppCzarDatabaseCondition.healthy =>
          'Readable at schema ${observation.schemaVersion}.',
        AppCzarDatabaseCondition.absent =>
          'Not created yet; no unhealthy overlay was observed.',
        AppCzarDatabaseCondition.unhealthy ||
        AppCzarDatabaseCondition.unknown =>
          observation.issue ?? 'The overlay could not be inspected.',
      },
    );
  }

  AppCzarFact _localDatasetFact(AppCzarObservationSet observations) {
    final importStore = observations.importStore;
    final graphStore = observations.graphStore;
    if (importStore.condition == AppCzarDatabaseCondition.unknown ||
        graphStore.condition == AppCzarDatabaseCondition.unknown) {
      return const AppCzarFact(
        id: AppCzarFactId.localDatasetComplete,
        label: 'Complete local message dataset',
        truth: AppCzarTruth.unknown,
        detail: 'The required local stores could not both be inspected.',
      );
    }
    if (importStore.condition != AppCzarDatabaseCondition.healthy ||
        graphStore.condition != AppCzarDatabaseCondition.healthy) {
      return const AppCzarFact(
        id: AppCzarFactId.localDatasetComplete,
        label: 'Complete local message dataset',
        truth: AppCzarTruth.falseValue,
        detail: 'The required import and graph stores are not both healthy.',
      );
    }

    final importCount = importStore.messageCount;
    final graphCount = graphStore.messageCount;
    final graphTopologyIsPresent =
        (graphStore.chatCount ?? 0) > 0 &&
        (graphStore.chatMessageEdgeCount ?? 0) > 0;
    final complete =
        importCount != null &&
        importCount > 0 &&
        graphCount == importCount &&
        graphTopologyIsPresent;
    return AppCzarFact(
      id: AppCzarFactId.localDatasetComplete,
      label: 'Complete local message dataset',
      truth: complete ? AppCzarTruth.trueValue : AppCzarTruth.falseValue,
      detail: complete
          ? '$graphCount messages are projected with conversation topology.'
          : 'Import and graph evidence do not establish one complete dataset.',
    );
  }

  AppCzarFact _archiveFact(AppCzarArchiveObservation observation) {
    return AppCzarFact(
      id: AppCzarFactId.attachmentArchiveAvailable,
      label: 'Attachment archive available',
      truth: switch (observation.condition) {
        AppCzarArchiveCondition.available ||
        AppCzarArchiveCondition.readOnly ||
        AppCzarArchiveCondition.notCreated => AppCzarTruth.trueValue,
        AppCzarArchiveCondition.unavailable => AppCzarTruth.falseValue,
        AppCzarArchiveCondition.unknown => AppCzarTruth.unknown,
      },
      detail: switch (observation.condition) {
        AppCzarArchiveCondition.available =>
          '${observation.label} is connected.',
        AppCzarArchiveCondition.readOnly =>
          '${observation.label} is connected read-only.',
        AppCzarArchiveCondition.notCreated =>
          'The default archive has not been created yet.',
        AppCzarArchiveCondition.unavailable ||
        AppCzarArchiveCondition.unknown =>
          observation.issue ?? 'The configured archive could not be inspected.',
      },
    );
  }

  AppCzarFact _deltaKnownFact(AppCzarObservationSet observations) {
    final source = observations.source;
    final localComplete = _localDatasetFact(observations);
    final known =
        source.condition == AppCzarSourceCondition.readable &&
        source.sampleStable == true &&
        localComplete.truth == AppCzarTruth.trueValue &&
        source.messageCount != null &&
        source.maxRowId != null &&
        observations.importStore.liveMessageCount != null &&
        observations.importStore.liveMaxSourceRowId != null;
    return AppCzarFact(
      id: AppCzarFactId.sourceLocalDeltaKnown,
      label: 'Source versus local delta known',
      truth: known ? AppCzarTruth.trueValue : AppCzarTruth.unknown,
      detail: known
          ? 'Current source and live import counts and high-water values are '
                'comparable.'
          : 'The current source and local prerequisites are not all established.',
    );
  }

  AppCzarFact _sourceAheadFact(AppCzarObservationSet observations) {
    final deltaKnown = _deltaKnownFact(observations);
    if (deltaKnown.truth != AppCzarTruth.trueValue) {
      return const AppCzarFact(
        id: AppCzarFactId.sourceAheadOfLocal,
        label: 'New source messages present',
        truth: AppCzarTruth.unknown,
        detail: 'A current source-versus-local delta is not available.',
      );
    }
    final sourceHighWater = observations.source.maxRowId!;
    final localHighWater = observations.importStore.liveMaxSourceRowId!;
    final sourceCount = observations.source.messageCount!;
    final localCount = observations.importStore.liveMessageCount!;
    if (sourceHighWater < localHighWater || sourceCount < localCount) {
      return AppCzarFact(
        id: AppCzarFactId.sourceAheadOfLocal,
        label: 'New source messages present',
        truth: AppCzarTruth.unknown,
        detail:
            'Source count/high-water $sourceCount/$sourceHighWater and local '
            '$localCount/$localHighWater do not establish a forward delta.',
      );
    }
    final sourceAhead =
        sourceHighWater > localHighWater || sourceCount > localCount;
    return AppCzarFact(
      id: AppCzarFactId.sourceAheadOfLocal,
      label: 'New source messages present',
      truth: sourceAhead ? AppCzarTruth.trueValue : AppCzarTruth.falseValue,
      detail: sourceAhead
          ? 'Source count/high-water $sourceCount/$sourceHighWater is ahead '
                'of local $localCount/$localHighWater.'
          : 'Source and local count/high-water agree at '
                '$sourceCount/$sourceHighWater.',
    );
  }

  _AppCzarSelection _select(
    AppCzarObservationSet observations,
    Map<AppCzarFactId, AppCzarFact> facts,
  ) {
    AppCzarFact fact(AppCzarFactId id) => facts[id]!;

    if (fact(AppCzarFactId.developmentRootAdmitted).truth !=
        AppCzarTruth.trueValue) {
      return const _AppCzarSelection.diagnostic(
        'The development data root is not currently admitted.',
      );
    }

    final unhealthyLocalStore =
        <AppCzarDatabaseObservation>[
          observations.importStore,
          observations.graphStore,
          observations.overlay,
        ].any(
          (observation) =>
              observation.condition == AppCzarDatabaseCondition.unhealthy,
        );
    if (unhealthyLocalStore) {
      return const _AppCzarSelection(
        kind: AppCzarDiagnosisKind.localDataNeedsRepair,
        diagnosis:
            'One or more current MessageLens data stores need repair before use.',
        coordinator: AppCzarVirtualCoordinator.localDataRepair,
      );
    }

    final unknownLocalStore =
        <AppCzarDatabaseObservation>[
          observations.importStore,
          observations.graphStore,
          observations.overlay,
        ].any(
          (observation) =>
              observation.condition == AppCzarDatabaseCondition.unknown,
        );
    if (unknownLocalStore) {
      return const _AppCzarSelection.diagnostic(
        'One or more current MessageLens data stores could not be inspected.',
      );
    }

    if (fact(AppCzarFactId.attachmentArchiveAvailable).truth ==
        AppCzarTruth.falseValue) {
      return const _AppCzarSelection(
        kind: AppCzarDiagnosisKind.attachmentArchiveUnavailable,
        diagnosis:
            'The configured attachment archive is currently unavailable.',
        coordinator: AppCzarVirtualCoordinator.attachmentArchiveRepair,
      );
    }
    if (fact(AppCzarFactId.attachmentArchiveAvailable).truth ==
        AppCzarTruth.unknown) {
      return const _AppCzarSelection.diagnostic(
        'The configured attachment archive could not be assessed.',
      );
    }

    final sourceReadable = fact(AppCzarFactId.messagesSourceReadable);
    if (sourceReadable.truth == AppCzarTruth.falseValue) {
      return const _AppCzarSelection(
        kind: AppCzarDiagnosisKind.sourceAccessUnavailable,
        diagnosis:
            'The current Messages source cannot be inspected with the available access.',
        coordinator: AppCzarVirtualCoordinator.sourceAccessRepair,
      );
    }
    if (sourceReadable.truth == AppCzarTruth.unknown) {
      return const _AppCzarSelection.diagnostic(
        'Current evidence does not establish whether the Messages source is readable.',
      );
    }

    if (fact(AppCzarFactId.sourceSampleStable).truth !=
        AppCzarTruth.trueValue) {
      return const _AppCzarSelection.diagnostic(
        'Current Messages evidence did not settle into one stable sample.',
      );
    }

    if (fact(AppCzarFactId.localDatasetComplete).truth ==
        AppCzarTruth.falseValue) {
      return const _AppCzarSelection(
        kind: AppCzarDiagnosisKind.incompleteLocalDataset,
        diagnosis:
            'MessageLens does not currently have a complete local message dataset.',
        coordinator: AppCzarVirtualCoordinator.onboarding,
      );
    }

    if (fact(AppCzarFactId.localDatasetComplete).truth !=
            AppCzarTruth.trueValue ||
        fact(AppCzarFactId.sourceLocalDeltaKnown).truth !=
            AppCzarTruth.trueValue) {
      return const _AppCzarSelection.diagnostic(
        'Current evidence is insufficient to choose a safe MessageLens action.',
      );
    }

    final sourceAhead = fact(AppCzarFactId.sourceAheadOfLocal);
    if (sourceAhead.truth == AppCzarTruth.unknown) {
      return const _AppCzarSelection.diagnostic(
        'Current source and local count/high-water evidence contradict each other.',
      );
    }
    if (sourceAhead.truth == AppCzarTruth.trueValue) {
      return const _AppCzarSelection(
        kind: AppCzarDiagnosisKind.sourceAheadOfLocal,
        diagnosis: 'The Messages source currently contains newer local data.',
        coordinator: AppCzarVirtualCoordinator.dataUpdate,
      );
    }

    return const _AppCzarSelection(
      kind: AppCzarDiagnosisKind.healthyCurrentInstallation,
      diagnosis:
          'This appears to be a healthy current MessageLens installation.',
      coordinator: AppCzarVirtualCoordinator.operatingSession,
    );
  }
}

final class _AppCzarSelection {
  const _AppCzarSelection({
    required this.kind,
    required this.diagnosis,
    required this.coordinator,
  });

  const _AppCzarSelection.diagnostic(String diagnosis)
    : this(
        kind: AppCzarDiagnosisKind.contradictoryOrInsufficientEvidence,
        diagnosis: diagnosis,
        coordinator: AppCzarVirtualCoordinator.diagnosticReview,
      );

  final AppCzarDiagnosisKind kind;
  final String diagnosis;
  final AppCzarVirtualCoordinator coordinator;
}
