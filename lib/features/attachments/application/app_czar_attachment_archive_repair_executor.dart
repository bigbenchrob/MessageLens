import '../../../essentials/app_czar_attachment_archive_repair/application/app_czar_attachment_archive_repair_executor_provider.dart';
import '../../../essentials/app_czar_attachment_archive_repair/domain/app_czar_attachment_archive_repair_models.dart';
import '../../../essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import 'current_messages_attachment_source_reader.dart';
import 'required_attachment_evidence_reader.dart';

const int appCzarAttachmentArchiveRepairPageSize =
    appCzarAttachmentArchiveRepairMaximumAuthorizedItems;

/// Fresh archive-location evidence used to bind one repair occurrence.
final class AttachmentArchiveRepairArchiveContext {
  factory AttachmentArchiveRepairArchiveContext({
    required String archiveScopeIdentity,
    required int archiveGeneration,
    required String resolvedArchivePath,
    required bool automaticPreservationAllowed,
  }) {
    return AttachmentArchiveRepairArchiveContext._(
      archiveScopeIdentity: archiveScopeIdentity,
      archiveGeneration: archiveGeneration,
      resolvedArchivePath: canonicalAppCzarAttachmentArchivePath(
        resolvedArchivePath,
      ),
      automaticPreservationAllowed: automaticPreservationAllowed,
    );
  }

  const AttachmentArchiveRepairArchiveContext._({
    required this.archiveScopeIdentity,
    required this.archiveGeneration,
    required this.resolvedArchivePath,
    required this.automaticPreservationAllowed,
  });

  final String archiveScopeIdentity;
  final int archiveGeneration;
  final String resolvedArchivePath;

  /// Scheduling evidence only. Mutation still requires callback-local proof.
  final bool automaticPreservationAllowed;

  RequiredAttachmentEvidenceBinding get evidenceBinding {
    return RequiredAttachmentEvidenceBinding(
      archiveRootPath: resolvedArchivePath,
      archiveScopeIdentity: archiveScopeIdentity,
      archiveGeneration: archiveGeneration,
    );
  }

  bool matches(AppCzarAttachmentArchiveRepairBinding binding) {
    return archiveScopeIdentity == binding.archiveScopeIdentity &&
        archiveGeneration == binding.archiveGeneration &&
        resolvedArchivePath == binding.resolvedArchivePath;
  }
}

enum AttachmentArchiveRepairMutationBatchStatus {
  settled,
  sourceAccessLost,
  sourceInconclusive,
  archiveBindingChanged,
  stopped,
}

/// Aggregate result of one bounded, callback-local mutation tenure.
final class AttachmentArchiveRepairMutationBatchResult {
  const AttachmentArchiveRepairMutationBatchResult({
    required this.status,
    required this.processedCount,
    required this.preservedCount,
  });

  const AttachmentArchiveRepairMutationBatchResult.stopped()
    : this(
        status: AttachmentArchiveRepairMutationBatchStatus.stopped,
        processedCount: 0,
        preservedCount: 0,
      );

  final AttachmentArchiveRepairMutationBatchStatus status;
  final int processedCount;
  final int preservedCount;
}

/// The only seam through which this coordinator may request archive writes.
///
/// Implementations acquire one Ball tenure and writable-root lease for this
/// bounded authorized batch. Neither proof may be retained after
/// [preserveNoRecordBatch]
/// settles.
abstract interface class AttachmentArchiveRepairMutationBatchExecutor {
  Future<AttachmentArchiveRepairMutationBatchResult> preserveNoRecordBatch({
    required AppCzarAttachmentArchiveRepairBinding binding,
    required List<CurrentMessagesAttachmentSourceObservation> sources,
    required bool Function() shouldStop,
  });
}

typedef AttachmentArchiveRepairArchiveContextReader =
    Future<AttachmentArchiveRepairArchiveContext> Function();
typedef AttachmentArchiveRepairSourceReaderResolver =
    Future<CurrentMessagesAttachmentSourceReader> Function();

/// Generation-bound repair executor driven entirely by current evidence.
///
/// It has no cursor or operation-history store. A replacement process derives
/// its remaining work from the required universe and committed object facts.
final class MessageLensAppCzarAttachmentArchiveRepairExecutor
    implements AppCzarAttachmentArchiveRepairExecutor {
  MessageLensAppCzarAttachmentArchiveRepairExecutor({
    required RequiredAttachmentEvidenceReader evidenceReader,
    required AttachmentArchiveRepairSourceReaderResolver sourceReaderResolver,
    required AttachmentArchiveRepairArchiveContextReader archiveContextReader,
    required AttachmentArchiveRepairMutationBatchExecutor mutationBatchExecutor,
    this.pageSize = appCzarAttachmentArchiveRepairPageSize,
  }) : _evidenceReader = evidenceReader,
       _sourceReaderResolver = sourceReaderResolver,
       _archiveContextReader = archiveContextReader,
       _mutationBatchExecutor = mutationBatchExecutor {
    if (pageSize < 1 || pageSize > 100) {
      throw ArgumentError.value(pageSize, 'pageSize', 'must be 1 through 100');
    }
  }

  final RequiredAttachmentEvidenceReader _evidenceReader;
  final AttachmentArchiveRepairSourceReaderResolver _sourceReaderResolver;
  final AttachmentArchiveRepairArchiveContextReader _archiveContextReader;
  final AttachmentArchiveRepairMutationBatchExecutor _mutationBatchExecutor;
  final int pageSize;

  bool _stopRequested = false;
  Future<void>? _activeDrain;
  _AttachmentArchiveRepairBatchPlan? _pendingPlan;
  var _nextPlanIdentity = 0;

  @override
  Future<AppCzarAttachmentArchiveRepairObservation> inspectCurrent({
    required AppCzarAttachmentArchiveRepairBinding binding,
  }) {
    return _runOne(binding, () => _inspect(binding));
  }

  @override
  Future<AppCzarAttachmentArchiveRepairObservation> preserveAuthorizedBatch({
    required AppCzarAttachmentArchiveRepairBinding binding,
    required AppCzarAttachmentArchiveRepairBatchAuthorization authorization,
    AppCzarAttachmentArchiveRepairProgressObserver? onProgress,
  }) {
    return _runOne(
      binding,
      () => _preserveAuthorizedBatch(
        binding,
        authorization,
        onProgress: onProgress,
      ),
    );
  }

  @override
  Future<void> stopAndDrain() async {
    _stopRequested = true;
    _pendingPlan = null;
    final activeDrain = _activeDrain;
    if (activeDrain != null) {
      await activeDrain;
    }
  }

  Future<AppCzarAttachmentArchiveRepairObservation> _runOne(
    AppCzarAttachmentArchiveRepairBinding binding,
    Future<AppCzarAttachmentArchiveRepairObservation> Function() action,
  ) async {
    if (_stopRequested) {
      return _observation(
        kind: AppCzarAttachmentArchiveRepairObservationKind.stopped,
        binding: binding,
      );
    }
    if (_activeDrain != null) {
      throw StateError('Attachment Archive Repair is already running.');
    }

    final run = Future<AppCzarAttachmentArchiveRepairObservation>.sync(action);
    final drain = run.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    _activeDrain = drain;
    try {
      return await run;
    } finally {
      if (identical(_activeDrain, drain)) {
        _activeDrain = null;
      }
    }
  }

  Future<AppCzarAttachmentArchiveRepairObservation> _inspect(
    AppCzarAttachmentArchiveRepairBinding binding,
  ) async {
    _pendingPlan = null;
    if (_stopRequested) {
      return _stopped(binding);
    }

    final startingContext = await _readMatchingContext(binding);
    if (startingContext == null) {
      return _bindingChanged(binding);
    }
    final evidenceBinding = startingContext.evidenceBinding;

    try {
      final firstSummary = await _evidenceReader.readSummary(
        binding: evidenceBinding,
        pageSize: pageSize,
      );
      if (_stopRequested) {
        return _stopped(binding);
      }

      final partition = await _classifyCurrentPartition(
        binding: binding,
        evidenceBinding: evidenceBinding,
      );
      if (partition.terminalKind case final terminalKind?) {
        return _observation(kind: terminalKind, binding: binding);
      }

      final secondSummary = await _evidenceReader.readSummary(
        binding: evidenceBinding,
        pageSize: pageSize,
      );
      if (_stopRequested) {
        return _stopped(binding);
      }
      final endingContext = await _readMatchingContext(binding);
      if (endingContext == null ||
          !_sameArchiveContext(startingContext, endingContext)) {
        return _bindingChanged(binding);
      }
      if (!_stableSummary(firstSummary, secondSummary) ||
          !_partitionMatchesSummary(partition, secondSummary)) {
        return _observation(
          kind: AppCzarAttachmentArchiveRepairObservationKind.coverageUnknown,
          binding: binding,
        );
      }

      final plan = partition.plannedItems.isEmpty
          ? null
          : _createPlan(
              binding: binding,
              requiredEvidenceFingerprint: secondSummary.materialFingerprint,
              items: partition.plannedItems,
            );
      _pendingPlan = plan;
      final snapshot = AppCzarAttachmentArchiveRepairSnapshot(
        requiredCount: partition.requiredCount,
        coveredCount: partition.coveredCount,
        availableFromMessagesCount: partition.availableFromMessagesCount,
        sourceAbsentCount: partition.sourceAbsentCount,
        sourceUnknownCount: partition.sourceUnknownCount,
        recordBackedRecoveryCount: partition.recordBackedRecoveryCount,
        unsafeOrConflictingCount: partition.unsafeOrConflictingCount,
        nextBatchAuthorization: plan?.authorization,
        automaticPreservationAllowed:
            endingContext.automaticPreservationAllowed,
      );
      if (!snapshot.isCoherent) {
        return _observation(
          kind: AppCzarAttachmentArchiveRepairObservationKind.coverageUnknown,
          binding: binding,
        );
      }
      return _observation(
        kind: snapshot.needAttentionCount == 0
            ? AppCzarAttachmentArchiveRepairObservationKind.coverageComplete
            : AppCzarAttachmentArchiveRepairObservationKind.coverageIncomplete,
        binding: binding,
        snapshot: snapshot,
      );
    } on RequiredAttachmentEvidenceReadException {
      return _observation(
        kind: AppCzarAttachmentArchiveRepairObservationKind.coverageUnknown,
        binding: binding,
      );
    }
  }

  Future<AppCzarAttachmentArchiveRepairObservation> _preserveAuthorizedBatch(
    AppCzarAttachmentArchiveRepairBinding binding,
    AppCzarAttachmentArchiveRepairBatchAuthorization authorization, {
    required AppCzarAttachmentArchiveRepairProgressObserver? onProgress,
  }) async {
    final authorizedPlan = _pendingPlan;
    if (authorizedPlan == null ||
        !identical(authorizedPlan.authorization, authorization) ||
        !authorizedPlan.matchesBinding(binding) ||
        !authorization.isCoherent ||
        !authorization.hasKnownByteScope) {
      return _inspect(binding);
    }

    // Claim this displayed plan before any await so double invocation cannot
    // reuse the same human authorization.
    _pendingPlan = null;
    final current = await _inspect(binding);
    final revalidatedPlan = _pendingPlan;
    if (current.kind !=
            AppCzarAttachmentArchiveRepairObservationKind.coverageIncomplete ||
        current.snapshot?.hasAutomaticWork != true ||
        revalidatedPlan == null ||
        !authorizedPlan.hasSameEvidenceAs(revalidatedPlan) ||
        _stopRequested) {
      return current;
    }

    // Consume the freshly revalidated plan too. No authorization remains for
    // another mutation admission, even if this batch settles only partially.
    _pendingPlan = null;
    final batchResult = await _mutationBatchExecutor.preserveNoRecordBatch(
      binding: binding,
      sources: authorizedPlan.sources,
      shouldStop: () => _stopRequested,
    );
    onProgress?.call(
      AppCzarAttachmentArchiveRepairProgress(
        completedCount: batchResult.processedCount.clamp(
          0,
          authorization.itemCount,
        ),
        totalCount: authorization.itemCount,
      ),
    );
    switch (batchResult.status) {
      case AttachmentArchiveRepairMutationBatchStatus.settled:
        break;
      case AttachmentArchiveRepairMutationBatchStatus.sourceAccessLost:
        return _observation(
          kind: AppCzarAttachmentArchiveRepairObservationKind.sourceAccessLost,
          binding: binding,
        );
      case AttachmentArchiveRepairMutationBatchStatus.sourceInconclusive:
        return _observation(
          kind: AppCzarAttachmentArchiveRepairObservationKind.coverageUnknown,
          binding: binding,
        );
      case AttachmentArchiveRepairMutationBatchStatus.archiveBindingChanged:
        return _bindingChanged(binding);
      case AttachmentArchiveRepairMutationBatchStatus.stopped:
        return _stopped(binding);
    }
    if (_stopRequested) {
      return _stopped(binding);
    }
    return _inspect(binding);
  }

  Future<_AttachmentRepairPartition> _classifyCurrentPartition({
    required AppCzarAttachmentArchiveRepairBinding binding,
    required RequiredAttachmentEvidenceBinding evidenceBinding,
  }) async {
    var partition = const _AttachmentRepairPartition();
    RequiredAttachmentEvidenceCursor? cursor;
    final sourceReader = await _sourceReaderResolver();
    while (true) {
      if (_stopRequested) {
        return partition.withTerminal(
          AppCzarAttachmentArchiveRepairObservationKind.stopped,
        );
      }
      final context = await _readMatchingContext(binding);
      if (context == null || context.evidenceBinding != evidenceBinding) {
        return partition.withTerminal(
          AppCzarAttachmentArchiveRepairObservationKind.archiveBindingChanged,
        );
      }
      final page = await _evidenceReader.readPage(
        binding: evidenceBinding,
        after: cursor,
        limit: pageSize,
      );
      if (page.binding != evidenceBinding) {
        return partition.withTerminal(
          AppCzarAttachmentArchiveRepairObservationKind.coverageUnknown,
        );
      }

      final noRecordItems = page.items
          .where(
            (item) =>
                item.condition ==
                RequiredAttachmentEvidenceCondition.noDurableRecord,
          )
          .toList(growable: false);
      if (noRecordItems.any((item) => item.archiveKey == null)) {
        return partition.withTerminal(
          AppCzarAttachmentArchiveRepairObservationKind.coverageUnknown,
        );
      }
      final keys = noRecordItems
          .map((item) => item.archiveKey!)
          .toList(growable: false);
      final observations = keys.isEmpty
          ? const <CurrentMessagesAttachmentSourceObservation>[]
          : await sourceReader.observeCurrentPage(keys);
      if (!_sourcePageIsCoherent(keys, observations)) {
        return partition.withTerminal(
          AppCzarAttachmentArchiveRepairObservationKind.coverageUnknown,
        );
      }
      if (observations.any(
        (item) =>
            item.condition ==
            CurrentMessagesAttachmentSourceCondition.sourceUnavailable,
      )) {
        return partition.withTerminal(
          AppCzarAttachmentArchiveRepairObservationKind.sourceAccessLost,
        );
      }
      if (observations.any(
        (item) =>
            item.condition ==
            CurrentMessagesAttachmentSourceCondition.sourceInconclusive,
      )) {
        return partition.withTerminal(
          AppCzarAttachmentArchiveRepairObservationKind.coverageUnknown,
        );
      }

      var observationIndex = 0;
      for (final item in page.items) {
        partition = switch (item.condition) {
          RequiredAttachmentEvidenceCondition.coveredAndValid =>
            partition.addCovered(),
          RequiredAttachmentEvidenceCondition.noDurableRecord =>
            partition.addSource(
              requiredEvidence: item,
              sourceEvidence: observations[observationIndex++],
            ),
          RequiredAttachmentEvidenceCondition.recordPayloadAbsent ||
          RequiredAttachmentEvidenceCondition.recordWrongSize =>
            partition.addRecordBacked(),
          RequiredAttachmentEvidenceCondition.unsafeOrUnverifiablePath ||
          RequiredAttachmentEvidenceCondition.conflictingDurableEvidence ||
          RequiredAttachmentEvidenceCondition.ambiguousRequiredIdentity =>
            partition.addUnsafeOrConflicting(),
        };
      }

      if (!page.hasMore) {
        return partition;
      }
      final nextCursor = page.nextCursor;
      if (nextCursor == null || nextCursor == cursor) {
        return partition.withTerminal(
          AppCzarAttachmentArchiveRepairObservationKind.coverageUnknown,
        );
      }
      cursor = nextCursor;
    }
  }

  Future<AttachmentArchiveRepairArchiveContext?> _readMatchingContext(
    AppCzarAttachmentArchiveRepairBinding binding,
  ) async {
    try {
      final context = await _archiveContextReader();
      return context.matches(binding) ? context : null;
    } on Object {
      return null;
    }
  }

  _AttachmentArchiveRepairBatchPlan _createPlan({
    required AppCzarAttachmentArchiveRepairBinding binding,
    required String requiredEvidenceFingerprint,
    required List<_AttachmentArchiveRepairPlannedItem> items,
  }) {
    int? totalKnownBytes = 0;
    for (final item in items) {
      final bytes = item.sourceEvidence.fileSizeBytes;
      if (bytes == null || bytes < 0) {
        totalKnownBytes = null;
        break;
      }
      totalKnownBytes = totalKnownBytes! + bytes;
    }
    final authorization = AppCzarAttachmentArchiveRepairBatchAuthorization(
      planIdentity:
          '${binding.occurrenceId}:${binding.assessmentGeneration}:'
          '${_nextPlanIdentity++}',
      itemCount: items.length,
      totalKnownBytes: totalKnownBytes,
    );
    return _AttachmentArchiveRepairBatchPlan(
      binding: binding,
      requiredEvidenceFingerprint: requiredEvidenceFingerprint,
      items: items,
      authorization: authorization,
    );
  }

  static bool _sourcePageIsCoherent(
    List<ArchiveCompatibilityKey> keys,
    List<CurrentMessagesAttachmentSourceObservation> observations,
  ) {
    if (keys.length != observations.length) {
      return false;
    }
    for (var index = 0; index < keys.length; index++) {
      if (observations[index].archiveKey != keys[index]) {
        return false;
      }
    }
    return true;
  }

  static bool _stableSummary(
    RequiredAttachmentEvidenceSummary first,
    RequiredAttachmentEvidenceSummary second,
  ) {
    return first.binding == second.binding &&
        first.materialFingerprint == second.materialFingerprint &&
        first.requiredCount == second.requiredCount &&
        first.coveredCount == second.coveredCount &&
        first.missingCount == second.missingCount &&
        first.unverifiableCount == second.unverifiableCount;
  }

  static bool _partitionMatchesSummary(
    _AttachmentRepairPartition partition,
    RequiredAttachmentEvidenceSummary summary,
  ) {
    return partition.requiredCount == summary.requiredCount &&
        partition.coveredCount == summary.coveredCount &&
        partition.availableFromMessagesCount +
                partition.sourceAbsentCount +
                partition.sourceUnknownCount +
                partition.recordBackedRecoveryCount ==
            summary.missingCount &&
        partition.unsafeOrConflictingCount == summary.unverifiableCount;
  }

  static bool _sameArchiveContext(
    AttachmentArchiveRepairArchiveContext first,
    AttachmentArchiveRepairArchiveContext second,
  ) {
    return first.archiveScopeIdentity == second.archiveScopeIdentity &&
        first.archiveGeneration == second.archiveGeneration &&
        first.resolvedArchivePath == second.resolvedArchivePath &&
        first.automaticPreservationAllowed ==
            second.automaticPreservationAllowed;
  }

  static AppCzarAttachmentArchiveRepairObservation _stopped(
    AppCzarAttachmentArchiveRepairBinding binding,
  ) {
    return _observation(
      kind: AppCzarAttachmentArchiveRepairObservationKind.stopped,
      binding: binding,
    );
  }

  static AppCzarAttachmentArchiveRepairObservation _bindingChanged(
    AppCzarAttachmentArchiveRepairBinding binding,
  ) {
    return _observation(
      kind: AppCzarAttachmentArchiveRepairObservationKind.archiveBindingChanged,
      binding: binding,
    );
  }

  static AppCzarAttachmentArchiveRepairObservation _observation({
    required AppCzarAttachmentArchiveRepairObservationKind kind,
    required AppCzarAttachmentArchiveRepairBinding binding,
    AppCzarAttachmentArchiveRepairSnapshot? snapshot,
  }) {
    return AppCzarAttachmentArchiveRepairObservation(
      kind: kind,
      binding: binding,
      snapshot: snapshot,
    );
  }
}

final class _AttachmentRepairPartition {
  const _AttachmentRepairPartition({
    this.coveredCount = 0,
    this.availableFromMessagesCount = 0,
    this.sourceAbsentCount = 0,
    this.sourceUnknownCount = 0,
    this.recordBackedRecoveryCount = 0,
    this.unsafeOrConflictingCount = 0,
    this.plannedItems = const [],
    this.terminalKind,
  });

  final int coveredCount;
  final int availableFromMessagesCount;
  final int sourceAbsentCount;
  final int sourceUnknownCount;
  final int recordBackedRecoveryCount;
  final int unsafeOrConflictingCount;
  final List<_AttachmentArchiveRepairPlannedItem> plannedItems;
  final AppCzarAttachmentArchiveRepairObservationKind? terminalKind;

  int get requiredCount {
    return coveredCount +
        availableFromMessagesCount +
        sourceAbsentCount +
        sourceUnknownCount +
        recordBackedRecoveryCount +
        unsafeOrConflictingCount;
  }

  _AttachmentRepairPartition addCovered() {
    return _copy(coveredCount: coveredCount + 1);
  }

  _AttachmentRepairPartition addRecordBacked() {
    return _copy(recordBackedRecoveryCount: recordBackedRecoveryCount + 1);
  }

  _AttachmentRepairPartition addUnsafeOrConflicting() {
    return _copy(unsafeOrConflictingCount: unsafeOrConflictingCount + 1);
  }

  _AttachmentRepairPartition addSource({
    required RequiredAttachmentEvidenceItem requiredEvidence,
    required CurrentMessagesAttachmentSourceObservation sourceEvidence,
  }) {
    final condition = sourceEvidence.condition;
    final nextPlannedItems =
        condition == CurrentMessagesAttachmentSourceCondition.available &&
            plannedItems.length <
                appCzarAttachmentArchiveRepairMaximumAuthorizedItems
        ? List<_AttachmentArchiveRepairPlannedItem>.unmodifiable([
            ...plannedItems,
            _AttachmentArchiveRepairPlannedItem(
              requiredEvidence: requiredEvidence,
              sourceEvidence: sourceEvidence,
            ),
          ])
        : plannedItems;
    return switch (condition) {
      CurrentMessagesAttachmentSourceCondition.available => _copy(
        availableFromMessagesCount: availableFromMessagesCount + 1,
        plannedItems: nextPlannedItems,
      ),
      CurrentMessagesAttachmentSourceCondition.absent => _copy(
        sourceAbsentCount: sourceAbsentCount + 1,
      ),
      CurrentMessagesAttachmentSourceCondition.unreadable ||
      CurrentMessagesAttachmentSourceCondition.unknown => _copy(
        sourceUnknownCount: sourceUnknownCount + 1,
      ),
      CurrentMessagesAttachmentSourceCondition.sourceUnavailable ||
      CurrentMessagesAttachmentSourceCondition.sourceInconclusive =>
        throw StateError(
          'Global source outcomes must terminate before item classification.',
        ),
    };
  }

  _AttachmentRepairPartition withTerminal(
    AppCzarAttachmentArchiveRepairObservationKind kind,
  ) {
    return _copy(terminalKind: kind);
  }

  _AttachmentRepairPartition _copy({
    int? coveredCount,
    int? availableFromMessagesCount,
    int? sourceAbsentCount,
    int? sourceUnknownCount,
    int? recordBackedRecoveryCount,
    int? unsafeOrConflictingCount,
    List<_AttachmentArchiveRepairPlannedItem>? plannedItems,
    AppCzarAttachmentArchiveRepairObservationKind? terminalKind,
  }) {
    return _AttachmentRepairPartition(
      coveredCount: coveredCount ?? this.coveredCount,
      availableFromMessagesCount:
          availableFromMessagesCount ?? this.availableFromMessagesCount,
      sourceAbsentCount: sourceAbsentCount ?? this.sourceAbsentCount,
      sourceUnknownCount: sourceUnknownCount ?? this.sourceUnknownCount,
      recordBackedRecoveryCount:
          recordBackedRecoveryCount ?? this.recordBackedRecoveryCount,
      unsafeOrConflictingCount:
          unsafeOrConflictingCount ?? this.unsafeOrConflictingCount,
      plannedItems: plannedItems ?? this.plannedItems,
      terminalKind: terminalKind ?? this.terminalKind,
    );
  }
}

/// One exact compatibility identity and the evidence presented for consent.
final class _AttachmentArchiveRepairPlannedItem {
  const _AttachmentArchiveRepairPlannedItem({
    required this.requiredEvidence,
    required this.sourceEvidence,
  });

  final RequiredAttachmentEvidenceItem requiredEvidence;
  final CurrentMessagesAttachmentSourceObservation sourceEvidence;

  bool hasSameEvidenceAs(_AttachmentArchiveRepairPlannedItem other) {
    return requiredEvidence.cursor == other.requiredEvidence.cursor &&
        requiredEvidence.archiveKey == other.requiredEvidence.archiveKey &&
        requiredEvidence.condition == other.requiredEvidence.condition &&
        requiredEvidence.materialFingerprint ==
            other.requiredEvidence.materialFingerprint &&
        sourceEvidence.hasSameMaterialEvidenceAs(other.sourceEvidence);
  }
}

/// Exact, immutable, occurrence-owned evidence behind one visible action.
///
/// This plan is never persisted or exposed to presentation. Its privacy-safe
/// authorization handle identifies it, while these ordered items establish the
/// only compatibility keys the existing mutation boundary may receive.
final class _AttachmentArchiveRepairBatchPlan {
  _AttachmentArchiveRepairBatchPlan({
    required this.binding,
    required this.requiredEvidenceFingerprint,
    required Iterable<_AttachmentArchiveRepairPlannedItem> items,
    required this.authorization,
  }) : items = List<_AttachmentArchiveRepairPlannedItem>.unmodifiable(items);

  final AppCzarAttachmentArchiveRepairBinding binding;
  final String requiredEvidenceFingerprint;
  final List<_AttachmentArchiveRepairPlannedItem> items;
  final AppCzarAttachmentArchiveRepairBatchAuthorization authorization;

  List<CurrentMessagesAttachmentSourceObservation> get sources {
    return List<CurrentMessagesAttachmentSourceObservation>.unmodifiable(
      items.map((item) => item.sourceEvidence),
    );
  }

  bool matchesBinding(AppCzarAttachmentArchiveRepairBinding other) {
    return binding.occurrenceId == other.occurrenceId &&
        binding.assessmentGeneration == other.assessmentGeneration &&
        binding.hasSameArchiveBinding(other);
  }

  bool hasSameEvidenceAs(_AttachmentArchiveRepairBatchPlan other) {
    if (!matchesBinding(other.binding) ||
        requiredEvidenceFingerprint != other.requiredEvidenceFingerprint ||
        authorization.itemCount != other.authorization.itemCount ||
        authorization.totalKnownBytes != other.authorization.totalKnownBytes ||
        items.length != other.items.length) {
      return false;
    }
    for (var index = 0; index < items.length; index++) {
      if (!items[index].hasSameEvidenceAs(other.items[index])) {
        return false;
      }
    }
    return true;
  }
}
