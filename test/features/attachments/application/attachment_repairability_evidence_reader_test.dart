import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import 'package:remember_this_text/features/attachments/application/attachment_repairability_evidence_reader.dart';
import 'package:remember_this_text/features/attachments/application/current_messages_attachment_source_reader.dart';
import 'package:remember_this_text/features/attachments/application/required_attachment_evidence_reader.dart';

void main() {
  group('AttachmentRepairabilityEvidenceReader', () {
    test('complete coverage takes the summary-only fast path', () async {
      final required = _RequiredReader(<RequiredAttachmentEvidenceItem>[
        _item(0, RequiredAttachmentEvidenceCondition.coveredAndValid),
      ]);
      var sourceResolutions = 0;
      final reader = AttachmentRepairabilityEvidenceReader(
        requiredEvidenceReader: required,
        sourceReaderResolver: () async {
          sourceResolutions += 1;
          return _SourceReader(const {});
        },
      );

      final evidence = await reader.readCurrent(binding: _binding);

      expect(evidence.status, AttachmentRepairabilityEvidenceStatus.settled);
      expect(evidence.coverageIsStable, isTrue);
      expect(evidence.coveredCount, 1);
      expect(evidence.requiredCount, 1);
      expect(evidence.availableFromMessagesCount, 0);
      expect(required.summaryReads, 2);
      expect(required.pageReads, 0);
      expect(sourceResolutions, 0);
    });

    test('one shared partition keeps every material class distinct', () async {
      final required = _RequiredReader(<RequiredAttachmentEvidenceItem>[
        _item(0, RequiredAttachmentEvidenceCondition.coveredAndValid),
        _item(1, RequiredAttachmentEvidenceCondition.noDurableRecord),
        _item(2, RequiredAttachmentEvidenceCondition.noDurableRecord),
        _item(3, RequiredAttachmentEvidenceCondition.noDurableRecord),
        _item(4, RequiredAttachmentEvidenceCondition.recordPayloadAbsent),
        _item(5, RequiredAttachmentEvidenceCondition.unsafeOrUnverifiablePath),
      ]);
      final source = _SourceReader(
        <ArchiveCompatibilityKey, CurrentMessagesAttachmentSourceCondition>{
          _key(1): CurrentMessagesAttachmentSourceCondition.available,
          _key(2): CurrentMessagesAttachmentSourceCondition.absent,
          _key(3): CurrentMessagesAttachmentSourceCondition.unreadable,
        },
      );
      final reader = AttachmentRepairabilityEvidenceReader(
        requiredEvidenceReader: required,
        sourceReaderResolver: () async => source,
        pageSize: 2,
        maximumAvailableItems: 2,
      );

      final evidence = await reader.readCurrent(binding: _binding);

      expect(evidence.status, AttachmentRepairabilityEvidenceStatus.settled);
      expect(evidence.isSettledAndCoherent, isTrue);
      expect(evidence.requiredCount, 6);
      expect(evidence.coveredCount, 1);
      expect(evidence.availableFromMessagesCount, 1);
      expect(evidence.sourceAbsentCount, 1);
      expect(evidence.sourceUnknownCount, 1);
      expect(evidence.recordBackedRecoveryCount, 1);
      expect(evidence.unsafeOrConflictingCount, 1);
      expect(
        evidence.availableItems.single.requiredEvidence.archiveKey,
        _key(1),
      );
      expect(required.pageLimits, everyElement(2));
      expect(source.pages.expand((page) => page), <ArchiveCompatibilityKey>[
        _key(1),
        _key(2),
        _key(3),
      ]);
    });

    test('source-absent debt remains in the required universe', () async {
      final required = _RequiredReader(<RequiredAttachmentEvidenceItem>[
        _item(0, RequiredAttachmentEvidenceCondition.coveredAndValid),
        _item(1, RequiredAttachmentEvidenceCondition.noDurableRecord),
        _item(2, RequiredAttachmentEvidenceCondition.noDurableRecord),
      ]);
      final source = _SourceReader(
        <ArchiveCompatibilityKey, CurrentMessagesAttachmentSourceCondition>{
          _key(1): CurrentMessagesAttachmentSourceCondition.absent,
          _key(2): CurrentMessagesAttachmentSourceCondition.absent,
        },
      );
      final reader = AttachmentRepairabilityEvidenceReader(
        requiredEvidenceReader: required,
        sourceReaderResolver: () async => source,
      );

      final evidence = await reader.readCurrent(binding: _binding);

      expect(evidence.isSettledAndCoherent, isTrue);
      expect(evidence.requiredCount, 3);
      expect(evidence.coveredCount, 1);
      expect(evidence.sourceAbsentCount, 2);
      expect(evidence.availableFromMessagesCount, 0);
    });

    test(
      'source access loss and inconclusive evidence stay distinct',
      () async {
        Future<AttachmentRepairabilityEvidence> read(
          CurrentMessagesAttachmentSourceCondition condition,
        ) {
          final required = _RequiredReader(<RequiredAttachmentEvidenceItem>[
            _item(1, RequiredAttachmentEvidenceCondition.noDurableRecord),
          ]);
          return AttachmentRepairabilityEvidenceReader(
            requiredEvidenceReader: required,
            sourceReaderResolver: () async => _SourceReader(<
              ArchiveCompatibilityKey,
              CurrentMessagesAttachmentSourceCondition
            >{_key(1): condition}),
          ).readCurrent(binding: _binding);
        }

        final unavailable = await read(
          CurrentMessagesAttachmentSourceCondition.sourceUnavailable,
        );
        final inconclusive = await read(
          CurrentMessagesAttachmentSourceCondition.sourceInconclusive,
        );

        expect(
          unavailable.status,
          AttachmentRepairabilityEvidenceStatus.sourceUnavailable,
        );
        expect(
          inconclusive.status,
          AttachmentRepairabilityEvidenceStatus.inconclusive,
        );
      },
    );

    test('changed material summary fails closed', () async {
      final required = _RequiredReader(
        <RequiredAttachmentEvidenceItem>[
          _item(1, RequiredAttachmentEvidenceCondition.noDurableRecord),
        ],
        summaryFingerprints: const <String>['revision-a', 'revision-b'],
      );
      final reader = AttachmentRepairabilityEvidenceReader(
        requiredEvidenceReader: required,
        sourceReaderResolver: () async => _SourceReader(
          <ArchiveCompatibilityKey, CurrentMessagesAttachmentSourceCondition>{
            _key(1): CurrentMessagesAttachmentSourceCondition.absent,
          },
        ),
      );

      final evidence = await reader.readCurrent(binding: _binding);

      expect(
        evidence.status,
        AttachmentRepairabilityEvidenceStatus.inconclusive,
      );
      expect(evidence.coverageIsStable, isFalse);
      expect(evidence.issue, contains('changed during'));
    });

    test(
      'binding change and stop terminate without publishing a partition',
      () async {
        final required = _RequiredReader(<RequiredAttachmentEvidenceItem>[
          _item(0, RequiredAttachmentEvidenceCondition.coveredAndValid),
        ]);
        var bindingChecks = 0;
        final reader = AttachmentRepairabilityEvidenceReader(
          requiredEvidenceReader: required,
          sourceReaderResolver: () async => _SourceReader(const {}),
        );

        final changed = await reader.readCurrent(
          binding: _binding,
          bindingIsCurrent: () async {
            bindingChecks += 1;
            return bindingChecks < 2;
          },
        );
        final stopped = await reader.readCurrent(
          binding: _binding,
          shouldStop: () => true,
        );

        expect(
          changed.status,
          AttachmentRepairabilityEvidenceStatus.bindingChanged,
        );
        expect(stopped.status, AttachmentRepairabilityEvidenceStatus.stopped);
        expect(changed.availableItems, isEmpty);
        expect(stopped.availableItems, isEmpty);
      },
    );
  });
}

const _binding = RequiredAttachmentEvidenceBinding(
  archiveRootPath: '/test/archive',
  archiveScopeIdentity: 'scope',
  archiveGeneration: 7,
);

ArchiveCompatibilityKey _key(int index) {
  return ArchiveCompatibilityKey(
    messageGuid: 'guid-$index',
    importAttachmentId: index,
  );
}

RequiredAttachmentEvidenceItem _item(
  int index,
  RequiredAttachmentEvidenceCondition condition,
) {
  return RequiredAttachmentEvidenceItem(
    cursor: RequiredAttachmentEvidenceCursor(
      messageGuid: 'guid-$index',
      liveAttachmentRowId: index,
    ),
    archiveKey:
        condition ==
            RequiredAttachmentEvidenceCondition.ambiguousRequiredIdentity
        ? null
        : _key(index),
    condition: condition,
    materialFingerprint: 'item-$index-${condition.name}',
  );
}

final class _RequiredReader implements RequiredAttachmentEvidenceReader {
  _RequiredReader(this.items, {this.summaryFingerprints = const <String>[]});

  final List<RequiredAttachmentEvidenceItem> items;
  final List<String> summaryFingerprints;
  final List<int> pageLimits = <int>[];
  var pageReads = 0;
  var summaryReads = 0;

  @override
  Future<RequiredAttachmentEvidencePage> readPage({
    required RequiredAttachmentEvidenceBinding binding,
    RequiredAttachmentEvidenceCursor? after,
    int limit = 75,
  }) async {
    pageReads += 1;
    pageLimits.add(limit);
    final start = after == null
        ? 0
        : items.indexWhere((item) => item.cursor == after) + 1;
    final end = (start + limit).clamp(0, items.length);
    final page = items.sublist(start, end);
    return RequiredAttachmentEvidencePage(
      items: page,
      nextCursor: page.isEmpty ? null : page.last.cursor,
      hasMore: end < items.length,
      binding: binding,
    );
  }

  @override
  Future<RequiredAttachmentEvidenceSummary> readSummary({
    required RequiredAttachmentEvidenceBinding binding,
    int pageSize = 75,
  }) async {
    final call = summaryReads;
    summaryReads += 1;
    return RequiredAttachmentEvidenceSummary(
      requiredCount: items.length,
      coveredCount: items.where((item) => item.isCovered).length,
      missingCount: items.where((item) => item.isMissing).length,
      unverifiableCount: items.where((item) => item.isUnverifiable).length,
      materialFingerprint: call < summaryFingerprints.length
          ? summaryFingerprints[call]
          : items.map((item) => item.materialFingerprint).join('|'),
      binding: binding,
    );
  }
}

final class _SourceReader implements CurrentMessagesAttachmentSourceReader {
  _SourceReader(this.conditions);

  final Map<ArchiveCompatibilityKey, CurrentMessagesAttachmentSourceCondition>
  conditions;
  final List<List<ArchiveCompatibilityKey>> pages =
      <List<ArchiveCompatibilityKey>>[];

  @override
  Future<CurrentMessagesAttachmentSourceObservation> observeCurrent(
    ArchiveCompatibilityKey archiveKey,
  ) async {
    return _observation(archiveKey);
  }

  @override
  Future<List<CurrentMessagesAttachmentSourceObservation>> observeCurrentPage(
    List<ArchiveCompatibilityKey> archiveKeys,
  ) async {
    pages.add(List<ArchiveCompatibilityKey>.of(archiveKeys));
    return archiveKeys.map(_observation).toList(growable: false);
  }

  CurrentMessagesAttachmentSourceObservation _observation(
    ArchiveCompatibilityKey key,
  ) {
    return switch (conditions[key] ??
        CurrentMessagesAttachmentSourceCondition.unknown) {
      CurrentMessagesAttachmentSourceCondition.available =>
        CurrentMessagesAttachmentSourceObservation.available(
          archiveKey: key,
          sourcePath: '/test/source/${key.importAttachmentId}.bin',
          mimeType: 'application/octet-stream',
          fileSizeBytes: key.importAttachmentId + 1,
          modifiedAtMicrosecondsSinceEpoch: key.importAttachmentId + 100,
        ),
      CurrentMessagesAttachmentSourceCondition.absent =>
        CurrentMessagesAttachmentSourceObservation.absent(archiveKey: key),
      CurrentMessagesAttachmentSourceCondition.unreadable =>
        CurrentMessagesAttachmentSourceObservation.unreadable(archiveKey: key),
      CurrentMessagesAttachmentSourceCondition.sourceUnavailable =>
        CurrentMessagesAttachmentSourceObservation.sourceUnavailable(
          archiveKey: key,
          issue: 'Source unavailable.',
        ),
      CurrentMessagesAttachmentSourceCondition.sourceInconclusive =>
        CurrentMessagesAttachmentSourceObservation.sourceInconclusive(
          archiveKey: key,
          issue: 'Source inconclusive.',
        ),
      CurrentMessagesAttachmentSourceCondition.unknown =>
        CurrentMessagesAttachmentSourceObservation.unknown(archiveKey: key),
    };
  }
}
