import 'package:meta/meta.dart';

import '../../../essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import 'current_messages_attachment_source_reader.dart';
import 'required_attachment_evidence_reader.dart';

const int attachmentRepairabilityEvidenceDefaultPageSize = 75;

typedef AttachmentRepairabilitySourceReaderResolver =
    Future<CurrentMessagesAttachmentSourceReader> Function();
typedef AttachmentRepairabilityBindingValidator = Future<bool> Function();

enum AttachmentRepairabilityEvidenceStatus {
  settled,
  sourceUnavailable,
  inconclusive,
  bindingChanged,
  stopped,
}

@immutable
final class AttachmentRepairabilityAvailableItem {
  const AttachmentRepairabilityAvailableItem({
    required this.requiredEvidence,
    required this.sourceEvidence,
  });

  final RequiredAttachmentEvidenceItem requiredEvidence;
  final CurrentMessagesAttachmentSourceObservation sourceEvidence;

  bool hasSameMaterialEvidenceAs(AttachmentRepairabilityAvailableItem other) {
    return requiredEvidence.cursor == other.requiredEvidence.cursor &&
        requiredEvidence.archiveKey == other.requiredEvidence.archiveKey &&
        requiredEvidence.condition == other.requiredEvidence.condition &&
        requiredEvidence.materialFingerprint ==
            other.requiredEvidence.materialFingerprint &&
        sourceEvidence.hasSameMaterialEvidenceAs(other.sourceEvidence);
  }
}

/// One fresh, read-only classification of required attachment coverage and
/// current automatic repairability.
///
/// This is evidence, not policy or mutation authority. It never persists a
/// baseline, waiver, or completed-operation marker. The bounded available
/// items are retained only so Attachment Archive Repair can present one exact
/// current batch without repeating the required-universe algorithm.
final class AttachmentRepairabilityEvidence {
  AttachmentRepairabilityEvidence({
    required this.status,
    required this.summary,
    required this.coveredCount,
    required this.availableFromMessagesCount,
    required this.sourceAbsentCount,
    required this.sourceUnknownCount,
    required this.recordBackedRecoveryCount,
    required this.unsafeOrConflictingCount,
    required Iterable<AttachmentRepairabilityAvailableItem> availableItems,
    this.issue,
  }) : availableItems = List<AttachmentRepairabilityAvailableItem>.unmodifiable(
         availableItems,
       ),
       coverageIsStable = true;

  AttachmentRepairabilityEvidence.terminal({
    required this.status,
    required this.summary,
    this.coverageIsStable = false,
    this.issue,
  }) : coveredCount = 0,
       availableFromMessagesCount = 0,
       sourceAbsentCount = 0,
       sourceUnknownCount = 0,
       recordBackedRecoveryCount = 0,
       unsafeOrConflictingCount = 0,
       availableItems = const <AttachmentRepairabilityAvailableItem>[];

  final AttachmentRepairabilityEvidenceStatus status;
  final RequiredAttachmentEvidenceSummary? summary;
  final bool coverageIsStable;
  final int coveredCount;
  final int availableFromMessagesCount;
  final int sourceAbsentCount;
  final int sourceUnknownCount;
  final int recordBackedRecoveryCount;
  final int unsafeOrConflictingCount;
  final List<AttachmentRepairabilityAvailableItem> availableItems;
  final String? issue;

  int get requiredCount {
    return coveredCount +
        availableFromMessagesCount +
        sourceAbsentCount +
        sourceUnknownCount +
        recordBackedRecoveryCount +
        unsafeOrConflictingCount;
  }

  bool get isSettledAndCoherent {
    final stableSummary = summary;
    return status == AttachmentRepairabilityEvidenceStatus.settled &&
        stableSummary != null &&
        requiredCount == stableSummary.requiredCount &&
        coveredCount == stableSummary.coveredCount &&
        availableFromMessagesCount +
                sourceAbsentCount +
                sourceUnknownCount +
                recordBackedRecoveryCount ==
            stableSummary.missingCount &&
        unsafeOrConflictingCount == stableSummary.unverifiableCount &&
        availableItems.length <= availableFromMessagesCount;
  }
}

/// Singular classifier shared by AppCzar, Attachment Archive Repair, and the
/// Operating post-update observer.
///
/// Complete durable coverage takes the summary-only fast path. An incomplete
/// summary performs the existing keyset-paged required-universe scan and asks
/// the current Messages source about only exact no-record compatibility keys.
final class AttachmentRepairabilityEvidenceReader {
  AttachmentRepairabilityEvidenceReader({
    required RequiredAttachmentEvidenceReader requiredEvidenceReader,
    required AttachmentRepairabilitySourceReaderResolver sourceReaderResolver,
    this.pageSize = attachmentRepairabilityEvidenceDefaultPageSize,
    this.maximumAvailableItems = attachmentRepairabilityEvidenceDefaultPageSize,
  }) : _requiredEvidenceReader = requiredEvidenceReader,
       _sourceReaderResolver = sourceReaderResolver {
    if (pageSize < 1 || pageSize > 100) {
      throw ArgumentError.value(pageSize, 'pageSize', 'must be 1 through 100');
    }
    if (maximumAvailableItems < 1 || maximumAvailableItems > pageSize) {
      throw ArgumentError.value(
        maximumAvailableItems,
        'maximumAvailableItems',
        'must be 1 through pageSize',
      );
    }
  }

  final RequiredAttachmentEvidenceReader _requiredEvidenceReader;
  final AttachmentRepairabilitySourceReaderResolver _sourceReaderResolver;
  final int pageSize;
  final int maximumAvailableItems;

  Future<AttachmentRepairabilityEvidence> readCurrent({
    required RequiredAttachmentEvidenceBinding binding,
    AttachmentRepairabilityBindingValidator? bindingIsCurrent,
    bool Function()? shouldStop,
  }) async {
    final isStopped = shouldStop ?? () => false;
    if (isStopped()) {
      return AttachmentRepairabilityEvidence.terminal(
        status: AttachmentRepairabilityEvidenceStatus.stopped,
        summary: null,
      );
    }
    if (!await _bindingRemainsCurrent(bindingIsCurrent)) {
      return AttachmentRepairabilityEvidence.terminal(
        status: AttachmentRepairabilityEvidenceStatus.bindingChanged,
        summary: null,
      );
    }

    final first = await _requiredEvidenceReader.readSummary(
      binding: binding,
      pageSize: pageSize,
    );
    if (!_summaryIsCoherent(first)) {
      return AttachmentRepairabilityEvidence.terminal(
        status: AttachmentRepairabilityEvidenceStatus.inconclusive,
        summary: first,
        issue: 'Required attachment coverage counts did not reconcile.',
      );
    }
    if (isStopped()) {
      return AttachmentRepairabilityEvidence.terminal(
        status: AttachmentRepairabilityEvidenceStatus.stopped,
        summary: first,
      );
    }

    // Complete coverage never interrogates current source payload paths.
    if (first.missingCount == 0 && first.unverifiableCount == 0) {
      final second = await _requiredEvidenceReader.readSummary(
        binding: binding,
        pageSize: pageSize,
      );
      if (isStopped()) {
        return AttachmentRepairabilityEvidence.terminal(
          status: AttachmentRepairabilityEvidenceStatus.stopped,
          summary: second,
        );
      }
      if (!await _bindingRemainsCurrent(bindingIsCurrent)) {
        return AttachmentRepairabilityEvidence.terminal(
          status: AttachmentRepairabilityEvidenceStatus.bindingChanged,
          summary: second,
        );
      }
      if (!_stableSummary(first, second)) {
        return AttachmentRepairabilityEvidence.terminal(
          status: AttachmentRepairabilityEvidenceStatus.inconclusive,
          summary: second,
          issue:
              'Attachment graph, archive metadata, or payload state changed during the bounded evidence read.',
        );
      }
      return AttachmentRepairabilityEvidence(
        status: AttachmentRepairabilityEvidenceStatus.settled,
        summary: second,
        coveredCount: second.coveredCount,
        availableFromMessagesCount: 0,
        sourceAbsentCount: 0,
        sourceUnknownCount: 0,
        recordBackedRecoveryCount: 0,
        unsafeOrConflictingCount: 0,
        availableItems: const <AttachmentRepairabilityAvailableItem>[],
      );
    }

    var partition = const _AttachmentRepairabilityPartition();
    AttachmentRepairabilityEvidenceStatus? terminalStatus;
    String? terminalIssue;
    CurrentMessagesAttachmentSourceReader? sourceReader;
    try {
      sourceReader = await _sourceReaderResolver();
    } on Object catch (error) {
      terminalStatus = AttachmentRepairabilityEvidenceStatus.inconclusive;
      terminalIssue =
          'The current Messages attachment source is unavailable: $error';
    }

    RequiredAttachmentEvidenceCursor? cursor;
    while (terminalStatus == null) {
      if (isStopped()) {
        terminalStatus = AttachmentRepairabilityEvidenceStatus.stopped;
        break;
      }
      if (!await _bindingRemainsCurrent(bindingIsCurrent)) {
        terminalStatus = AttachmentRepairabilityEvidenceStatus.bindingChanged;
        break;
      }
      final page = await _requiredEvidenceReader.readPage(
        binding: binding,
        after: cursor,
        limit: pageSize,
      );
      if (page.binding != binding) {
        terminalStatus = AttachmentRepairabilityEvidenceStatus.inconclusive;
        terminalIssue =
            'Required attachment evidence changed archive binding during classification.';
        break;
      }

      final noRecordItems = page.items
          .where(
            (item) =>
                item.condition ==
                RequiredAttachmentEvidenceCondition.noDurableRecord,
          )
          .toList(growable: false);
      if (noRecordItems.any((item) => item.archiveKey == null)) {
        terminalStatus = AttachmentRepairabilityEvidenceStatus.inconclusive;
        terminalIssue =
            'A required no-record attachment lacked one exact compatibility identity.';
        break;
      }
      final keys = noRecordItems
          .map((item) => item.archiveKey!)
          .toList(growable: false);
      final observations = keys.isEmpty
          ? const <CurrentMessagesAttachmentSourceObservation>[]
          : await sourceReader!.observeCurrentPage(keys);
      if (!_sourcePageIsCoherent(keys, observations)) {
        terminalStatus = AttachmentRepairabilityEvidenceStatus.inconclusive;
        terminalIssue =
            'The current Messages source returned incoherent attachment identity evidence.';
        break;
      }
      final sourceUnavailable = observations
          .where(
            (item) =>
                item.condition ==
                CurrentMessagesAttachmentSourceCondition.sourceUnavailable,
          )
          .firstOrNull;
      if (sourceUnavailable != null) {
        terminalStatus =
            AttachmentRepairabilityEvidenceStatus.sourceUnavailable;
        terminalIssue = sourceUnavailable.issue;
        break;
      }
      final sourceInconclusive = observations
          .where(
            (item) =>
                item.condition ==
                CurrentMessagesAttachmentSourceCondition.sourceInconclusive,
          )
          .firstOrNull;
      if (sourceInconclusive != null) {
        terminalStatus = AttachmentRepairabilityEvidenceStatus.inconclusive;
        terminalIssue = sourceInconclusive.issue;
        break;
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
              maximumAvailableItems: maximumAvailableItems,
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
        break;
      }
      final nextCursor = page.nextCursor;
      if (nextCursor == null || nextCursor == cursor) {
        terminalStatus = AttachmentRepairabilityEvidenceStatus.inconclusive;
        terminalIssue =
            'Required attachment evidence pagination did not advance.';
        break;
      }
      cursor = nextCursor;
    }

    final second = await _requiredEvidenceReader.readSummary(
      binding: binding,
      pageSize: pageSize,
    );
    if (isStopped()) {
      return AttachmentRepairabilityEvidence.terminal(
        status: AttachmentRepairabilityEvidenceStatus.stopped,
        summary: second,
      );
    }
    if (!await _bindingRemainsCurrent(bindingIsCurrent)) {
      return AttachmentRepairabilityEvidence.terminal(
        status: AttachmentRepairabilityEvidenceStatus.bindingChanged,
        summary: second,
      );
    }
    if (!_stableSummary(first, second)) {
      return AttachmentRepairabilityEvidence.terminal(
        status: AttachmentRepairabilityEvidenceStatus.inconclusive,
        summary: second,
        issue:
            'Attachment graph, archive metadata, or payload state changed during the bounded evidence read.',
      );
    }
    if (terminalStatus != null) {
      return AttachmentRepairabilityEvidence.terminal(
        status: terminalStatus,
        summary: second,
        coverageIsStable: true,
        issue: terminalIssue,
      );
    }
    if (!_partitionMatchesSummary(partition, second)) {
      return AttachmentRepairabilityEvidence.terminal(
        status: AttachmentRepairabilityEvidenceStatus.inconclusive,
        summary: second,
        coverageIsStable: true,
        issue:
            'Current attachment repairability counts did not reconcile with required coverage.',
      );
    }
    return AttachmentRepairabilityEvidence(
      status: AttachmentRepairabilityEvidenceStatus.settled,
      summary: second,
      coveredCount: partition.coveredCount,
      availableFromMessagesCount: partition.availableFromMessagesCount,
      sourceAbsentCount: partition.sourceAbsentCount,
      sourceUnknownCount: partition.sourceUnknownCount,
      recordBackedRecoveryCount: partition.recordBackedRecoveryCount,
      unsafeOrConflictingCount: partition.unsafeOrConflictingCount,
      availableItems: partition.availableItems,
    );
  }

  static Future<bool> _bindingRemainsCurrent(
    AttachmentRepairabilityBindingValidator? validator,
  ) async {
    return validator == null || await validator();
  }

  static bool _summaryIsCoherent(RequiredAttachmentEvidenceSummary summary) {
    return summary.requiredCount >= 0 &&
        summary.coveredCount >= 0 &&
        summary.missingCount >= 0 &&
        summary.unverifiableCount >= 0 &&
        summary.coveredCount +
                summary.missingCount +
                summary.unverifiableCount ==
            summary.requiredCount;
  }

  static bool _stableSummary(
    RequiredAttachmentEvidenceSummary first,
    RequiredAttachmentEvidenceSummary second,
  ) {
    return _summaryIsCoherent(second) &&
        first.binding == second.binding &&
        first.materialFingerprint == second.materialFingerprint &&
        first.requiredCount == second.requiredCount &&
        first.coveredCount == second.coveredCount &&
        first.missingCount == second.missingCount &&
        first.unverifiableCount == second.unverifiableCount;
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

  static bool _partitionMatchesSummary(
    _AttachmentRepairabilityPartition partition,
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
}

final class _AttachmentRepairabilityPartition {
  const _AttachmentRepairabilityPartition({
    this.coveredCount = 0,
    this.availableFromMessagesCount = 0,
    this.sourceAbsentCount = 0,
    this.sourceUnknownCount = 0,
    this.recordBackedRecoveryCount = 0,
    this.unsafeOrConflictingCount = 0,
    this.availableItems = const <AttachmentRepairabilityAvailableItem>[],
  });

  final int coveredCount;
  final int availableFromMessagesCount;
  final int sourceAbsentCount;
  final int sourceUnknownCount;
  final int recordBackedRecoveryCount;
  final int unsafeOrConflictingCount;
  final List<AttachmentRepairabilityAvailableItem> availableItems;

  int get requiredCount {
    return coveredCount +
        availableFromMessagesCount +
        sourceAbsentCount +
        sourceUnknownCount +
        recordBackedRecoveryCount +
        unsafeOrConflictingCount;
  }

  _AttachmentRepairabilityPartition addCovered() {
    return _copy(coveredCount: coveredCount + 1);
  }

  _AttachmentRepairabilityPartition addRecordBacked() {
    return _copy(recordBackedRecoveryCount: recordBackedRecoveryCount + 1);
  }

  _AttachmentRepairabilityPartition addUnsafeOrConflicting() {
    return _copy(unsafeOrConflictingCount: unsafeOrConflictingCount + 1);
  }

  _AttachmentRepairabilityPartition addSource({
    required RequiredAttachmentEvidenceItem requiredEvidence,
    required CurrentMessagesAttachmentSourceObservation sourceEvidence,
    required int maximumAvailableItems,
  }) {
    final condition = sourceEvidence.condition;
    final nextAvailableItems =
        condition == CurrentMessagesAttachmentSourceCondition.available &&
            availableItems.length < maximumAvailableItems
        ? List<AttachmentRepairabilityAvailableItem>.unmodifiable([
            ...availableItems,
            AttachmentRepairabilityAvailableItem(
              requiredEvidence: requiredEvidence,
              sourceEvidence: sourceEvidence,
            ),
          ])
        : availableItems;
    return switch (condition) {
      CurrentMessagesAttachmentSourceCondition.available => _copy(
        availableFromMessagesCount: availableFromMessagesCount + 1,
        availableItems: nextAvailableItems,
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

  _AttachmentRepairabilityPartition _copy({
    int? coveredCount,
    int? availableFromMessagesCount,
    int? sourceAbsentCount,
    int? sourceUnknownCount,
    int? recordBackedRecoveryCount,
    int? unsafeOrConflictingCount,
    List<AttachmentRepairabilityAvailableItem>? availableItems,
  }) {
    return _AttachmentRepairabilityPartition(
      coveredCount: coveredCount ?? this.coveredCount,
      availableFromMessagesCount:
          availableFromMessagesCount ?? this.availableFromMessagesCount,
      sourceAbsentCount: sourceAbsentCount ?? this.sourceAbsentCount,
      sourceUnknownCount: sourceUnknownCount ?? this.sourceUnknownCount,
      recordBackedRecoveryCount:
          recordBackedRecoveryCount ?? this.recordBackedRecoveryCount,
      unsafeOrConflictingCount:
          unsafeOrConflictingCount ?? this.unsafeOrConflictingCount,
      availableItems: availableItems ?? this.availableItems,
    );
  }
}
