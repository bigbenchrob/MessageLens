import '../domain/app_czar_models.dart';

final class AppCzarEvaluator {
  const AppCzarEvaluator();

  AppCzarAssessment evaluate(AppCzarObservationSet observations) {
    final facts = <AppCzarFact>[
      _rootFact(observations.root),
      _initialConstructionScopeFact(observations.initialConstructionScope),
      _sourceReadableFact(observations.source),
      _sourceStableFact(observations.source),
      _contactsPrerequisiteFact(observations.contactsPrerequisite),
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
      _attachmentCoverageFact(observations.attachmentArchive),
      _attachmentRepairOpportunityFact(observations.attachmentArchive),
      _localDataRepairSafetyFact(observations.localDataRepairSafety),
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

  AppCzarFact _localDataRepairSafetyFact(
    AppCzarLocalDataRepairSafetyObservation observation,
  ) {
    return AppCzarFact(
      id: AppCzarFactId.localDataRepairMayResetDerivedStores,
      label: 'Local Data Repair may reset derived stores',
      truth:
          observation.condition ==
              AppCzarLocalDataRepairSafetyCondition.rebuildableLiveOnlyPartial
          ? AppCzarTruth.trueValue
          : observation.condition ==
                AppCzarLocalDataRepairSafetyCondition.unknown
          ? AppCzarTruth.unknown
          : AppCzarTruth.falseValue,
      detail: observation.mayResetDerivedStores
          ? 'The exact active derived-store footprint is reconstructible from stable current live sources.'
          : observation.issue ??
                'The active derived-store footprint is not authorized for automatic reset.',
    );
  }

  AppCzarFact _initialConstructionScopeFact(
    AppCzarInitialConstructionScopeObservation observation,
  ) {
    return AppCzarFact(
      id: AppCzarFactId.initialConstructionScopeSafe,
      label: 'Initial construction scope safe',
      truth: switch (observation.condition) {
        AppCzarInitialConstructionScopeCondition.safeEmpty =>
          AppCzarTruth.trueValue,
        AppCzarInitialConstructionScopeCondition.consequentialData ||
        AppCzarInitialConstructionScopeCondition.protectedNonLiveData ||
        AppCzarInitialConstructionScopeCondition.retiredOrUnsupportedMaterial ||
        AppCzarInitialConstructionScopeCondition.unhealthy =>
          AppCzarTruth.falseValue,
        AppCzarInitialConstructionScopeCondition.unknown =>
          AppCzarTruth.unknown,
      },
      detail: switch (observation.condition) {
        AppCzarInitialConstructionScopeCondition.safeEmpty =>
          'No consequential import, graph, non-live, or retired derived data is present.',
        _ =>
          observation.issue ??
              'Initial-construction scope could not be established.',
      },
    );
  }

  AppCzarFact _contactsPrerequisiteFact(
    AppCzarContactsPrerequisiteObservation observation,
  ) {
    return AppCzarFact(
      id: AppCzarFactId.contactsPrerequisiteSatisfied,
      label: 'Contacts source prerequisite satisfied',
      truth: switch (observation.condition) {
        AppCzarContactsPrerequisiteCondition.notRequiredForCurrentScope =>
          AppCzarTruth.trueValue,
        AppCzarContactsPrerequisiteCondition.viableWithContacts ||
        AppCzarContactsPrerequisiteCondition.viableEmpty =>
          AppCzarTruth.trueValue,
        AppCzarContactsPrerequisiteCondition.accessDenied ||
        AppCzarContactsPrerequisiteCondition.unavailable ||
        AppCzarContactsPrerequisiteCondition.invalidOrCorrupt =>
          AppCzarTruth.falseValue,
        AppCzarContactsPrerequisiteCondition.unknown => AppCzarTruth.unknown,
      },
      detail: switch (observation.condition) {
        AppCzarContactsPrerequisiteCondition.notRequiredForCurrentScope =>
          'Contacts are not an input to the current jurisdiction.',
        AppCzarContactsPrerequisiteCondition.viableWithContacts =>
          '${observation.contactCount} contacts are available from '
              '${observation.viableStoreCount} viable store(s).',
        AppCzarContactsPrerequisiteCondition.viableEmpty =>
          'The Contacts source is viable and currently contains zero contacts.',
        _ => observation.issue ?? 'The Contacts source could not be assessed.',
      },
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

  AppCzarFact _attachmentCoverageFact(
    AppCzarArchiveObservation archiveObservation,
  ) {
    final observation = archiveObservation.coverage;
    if (!archiveObservation.hasCoherentCoverageBinding) {
      return const AppCzarFact(
        id: AppCzarFactId.attachmentCoverageComplete,
        label: 'Required attachment coverage complete',
        truth: AppCzarTruth.unknown,
        detail:
            'Attachment coverage evidence is not coherently bound to the current archive scope.',
      );
    }
    final requiredCount = observation.requiredCount;
    final coveredCount = observation.coveredCount;
    final missingCount = observation.missingCount;
    return AppCzarFact(
      id: AppCzarFactId.attachmentCoverageComplete,
      label: 'Required attachment coverage complete',
      truth: switch (observation.condition) {
        AppCzarAttachmentCoverageCondition.complete => AppCzarTruth.trueValue,
        AppCzarAttachmentCoverageCondition.incomplete =>
          AppCzarTruth.falseValue,
        AppCzarAttachmentCoverageCondition.unknown => AppCzarTruth.unknown,
      },
      detail: switch (observation.condition) {
        AppCzarAttachmentCoverageCondition.complete =>
          '$coveredCount of $requiredCount required attachment payloads have current durable coverage evidence.',
        AppCzarAttachmentCoverageCondition.incomplete =>
          '$missingCount required attachment payloads do not have current durable coverage evidence.',
        AppCzarAttachmentCoverageCondition.unknown =>
          observation.issue ?? 'Required attachment coverage is inconclusive.',
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

  AppCzarFact _attachmentRepairOpportunityFact(
    AppCzarArchiveObservation archiveObservation,
  ) {
    final observation = archiveObservation.repairability;
    if (!archiveObservation.hasCoherentRepairabilityBinding) {
      return const AppCzarFact(
        id: AppCzarFactId.attachmentRepairOpportunityPresent,
        label: 'Current attachment repair opportunity present',
        truth: AppCzarTruth.unknown,
        detail:
            'Attachment repairability evidence is not coherently bound to the current archive scope.',
      );
    }
    return AppCzarFact(
      id: AppCzarFactId.attachmentRepairOpportunityPresent,
      label: 'Current attachment repair opportunity present',
      truth: switch (observation.condition) {
        AppCzarAttachmentRepairOpportunityCondition.present =>
          AppCzarTruth.trueValue,
        AppCzarAttachmentRepairOpportunityCondition.absent =>
          AppCzarTruth.falseValue,
        AppCzarAttachmentRepairOpportunityCondition.unknown =>
          AppCzarTruth.unknown,
      },
      detail: switch (observation.condition) {
        AppCzarAttachmentRepairOpportunityCondition.present =>
          '${observation.availableFromMessagesCount} uncovered attachment payload(s) are currently available from Messages.',
        AppCzarAttachmentRepairOpportunityCondition.absent =>
          '${observation.sourceAbsentCount} uncovered attachment payload(s) are currently absent from Messages.',
        AppCzarAttachmentRepairOpportunityCondition.unknown =>
          observation.issue ??
              'Current attachment repairability is inconclusive.',
      },
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

    final initialScope = observations.initialConstructionScope;
    if (initialScope.condition ==
        AppCzarInitialConstructionScopeCondition.unknown) {
      return const _AppCzarSelection.diagnostic(
        'Current physical evidence does not establish initial-construction scope.',
      );
    }
    if (initialScope.condition ==
            AppCzarInitialConstructionScopeCondition
                .retiredOrUnsupportedMaterial ||
        initialScope.condition ==
            AppCzarInitialConstructionScopeCondition.unhealthy) {
      return const _AppCzarSelection.diagnostic(
        'Existing protected, retired, unsupported, or unhealthy MessageLens data requires separate review.',
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
      return const _AppCzarSelection.diagnostic(
        'One or more current MessageLens data stores are unhealthy and cannot be reset automatically.',
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

    final safeInitialConstructionScope =
        initialScope.condition ==
        AppCzarInitialConstructionScopeCondition.safeEmpty;
    if (safeInitialConstructionScope) {
      if (!observations.attachmentArchive.hasCompleteArchiveBinding) {
        return const _AppCzarSelection.diagnostic(
          'The current attachment archive identity and configuration are not coherently bound.',
        );
      }
      final contacts = observations.contactsPrerequisite;
      if (contacts.condition ==
              AppCzarContactsPrerequisiteCondition.notRequiredForCurrentScope ||
          contacts.condition ==
              AppCzarContactsPrerequisiteCondition.invalidOrCorrupt ||
          contacts.condition == AppCzarContactsPrerequisiteCondition.unknown) {
        return const _AppCzarSelection.diagnostic(
          'Current Contacts evidence is invalid, conflicting, or inconclusive.',
        );
      }
      final sourceReadable = fact(AppCzarFactId.messagesSourceReadable);
      if (sourceReadable.truth == AppCzarTruth.unknown) {
        return const _AppCzarSelection.diagnostic(
          'Current evidence does not establish whether the Messages source is readable.',
        );
      }
      if (sourceReadable.truth == AppCzarTruth.trueValue &&
          fact(AppCzarFactId.sourceSampleStable).truth !=
              AppCzarTruth.trueValue) {
        return const _AppCzarSelection.diagnostic(
          'Current Messages evidence did not settle into one stable sample.',
        );
      }
      return const _AppCzarSelection(
        kind: AppCzarDiagnosisKind.incompleteLocalDataset,
        diagnosis:
            'This safe empty installation is ready for source-grounded construction.',
        coordinator: AppCzarVirtualCoordinator.onboarding,
      );
    }

    if ((initialScope.condition ==
                AppCzarInitialConstructionScopeCondition.consequentialData ||
            initialScope.condition ==
                AppCzarInitialConstructionScopeCondition
                    .protectedNonLiveData) &&
        fact(AppCzarFactId.localDatasetComplete).truth !=
            AppCzarTruth.trueValue) {
      final repairSafety = fact(
        AppCzarFactId.localDataRepairMayResetDerivedStores,
      );
      if (initialScope.condition ==
              AppCzarInitialConstructionScopeCondition.consequentialData &&
          repairSafety.truth == AppCzarTruth.trueValue) {
        return const _AppCzarSelection(
          kind: AppCzarDiagnosisKind.localDataNeedsRepair,
          diagnosis:
              'The exact partial live-derived dataset can be reconstructed from current sources.',
          coordinator: AppCzarVirtualCoordinator.localDataRepair,
        );
      }
      return const _AppCzarSelection(
        kind: AppCzarDiagnosisKind.contradictoryOrInsufficientEvidence,
        diagnosis:
            'Partial local data is protected, unsupported, or not proven reconstructible.',
        coordinator: AppCzarVirtualCoordinator.diagnosticReview,
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
      return const _AppCzarSelection.diagnostic(
        'MessageLens does not currently have one proven complete local dataset.',
      );
    }

    final attachmentCoverage = fact(AppCzarFactId.attachmentCoverageComplete);
    if (attachmentCoverage.truth == AppCzarTruth.unknown) {
      return const _AppCzarSelection.diagnostic(
        'Current evidence does not establish complete required attachment coverage.',
      );
    }
    final repairOpportunity = fact(
      AppCzarFactId.attachmentRepairOpportunityPresent,
    );
    if (repairOpportunity.truth == AppCzarTruth.unknown) {
      return const _AppCzarSelection.diagnostic(
        'Current uncovered attachment evidence is unknown or conflicting.',
      );
    }
    final repairability = observations.attachmentArchive.repairability;
    final hasCurrentAutomaticWork =
        repairOpportunity.truth == AppCzarTruth.trueValue &&
        (repairability.availableFromMessagesCount ?? 0) > 0;
    final hasRecordBackedRecovery =
        (repairability.recordBackedRecoveryCount ?? 0) > 0;
    if (attachmentCoverage.truth == AppCzarTruth.falseValue &&
        (hasCurrentAutomaticWork || hasRecordBackedRecovery)) {
      return const _AppCzarSelection(
        kind: AppCzarDiagnosisKind.attachmentArchiveCoverageIncomplete,
        diagnosis:
            'The current attachment archive has actionable required attachment evidence.',
        coordinator: AppCzarVirtualCoordinator.attachmentArchiveRepair,
      );
    }
    if (attachmentCoverage.truth == AppCzarTruth.falseValue &&
        !repairability.isOperatingSafe) {
      return const _AppCzarSelection.diagnostic(
        'Incomplete attachment coverage is not currently safe for Operating admission.',
      );
    }
    if (attachmentCoverage.truth == AppCzarTruth.trueValue &&
        !repairability.isOperatingSafe) {
      return const _AppCzarSelection.diagnostic(
        'Complete attachment coverage contradicts current repairability evidence.',
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

    if (!observations.attachmentArchive.hasCompleteArchiveBinding) {
      return const _AppCzarSelection.diagnostic(
        'The configured archive did not provide one complete authentic location binding.',
      );
    }

    if (attachmentCoverage.truth == AppCzarTruth.falseValue) {
      return const _AppCzarSelection(
        kind: AppCzarDiagnosisKind.operatingWithKnownAttachmentDebt,
        diagnosis:
            'This installation is operable with known source-absent attachment coverage debt.',
        coordinator: AppCzarVirtualCoordinator.operatingSession,
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
