import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/app_czar_attachment_archive_repair/domain/app_czar_attachment_archive_repair_models.dart';
import 'package:remember_this_text/essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import 'package:remember_this_text/features/attachments/application/app_czar_attachment_archive_repair_executor.dart';
import 'package:remember_this_text/features/attachments/application/current_messages_attachment_source_reader.dart';
import 'package:remember_this_text/features/attachments/application/required_attachment_evidence_reader.dart';

void main() {
  group('MessageLensAppCzarAttachmentArchiveRepairExecutor inspection', () {
    test('classifies bounded pages without mutating and keeps unknown distinct '
        'from absent', () async {
      final evidence = _FakeRequiredAttachmentEvidenceReader([
        _record(0, RequiredAttachmentEvidenceCondition.coveredAndValid),
        _record(1, RequiredAttachmentEvidenceCondition.noDurableRecord),
        _record(2, RequiredAttachmentEvidenceCondition.noDurableRecord),
        _record(3, RequiredAttachmentEvidenceCondition.noDurableRecord),
        _record(4, RequiredAttachmentEvidenceCondition.recordPayloadAbsent),
        _record(
          5,
          RequiredAttachmentEvidenceCondition.unsafeOrUnverifiablePath,
        ),
      ]);
      final source = _FakeCurrentMessagesAttachmentSourceReader({
        _key(1): CurrentMessagesAttachmentSourceCondition.available,
        _key(2): CurrentMessagesAttachmentSourceCondition.absent,
        _key(3): CurrentMessagesAttachmentSourceCondition.unknown,
      });
      final mutation = _FakeMutationBatchExecutor(evidence: evidence);
      final executor = _executor(
        evidence: evidence,
        source: source,
        mutation: mutation,
        pageSize: 2,
      );

      final observation = await executor.inspectCurrent(binding: _binding);

      expect(
        observation.kind,
        AppCzarAttachmentArchiveRepairObservationKind.coverageIncomplete,
      );
      expect(observation.snapshot?.requiredCount, 6);
      expect(observation.snapshot?.coveredCount, 1);
      expect(observation.snapshot?.availableFromMessagesCount, 1);
      expect(observation.snapshot?.sourceAbsentCount, 1);
      expect(observation.snapshot?.sourceUnknownCount, 1);
      expect(observation.snapshot?.recordBackedRecoveryCount, 1);
      expect(observation.snapshot?.unsafeOrConflictingCount, 1);
      expect(observation.snapshot?.hasAutomaticWork, isTrue);
      expect(observation.isCoherent, isTrue);
      expect(evidence.pageLimits, everyElement(lessThanOrEqualTo(2)));
      expect(evidence.pageAfters.first, isNull);
      expect(evidence.pageAfters.skip(1), everyElement(isNotNull));
      expect(source.observedPages, hasLength(2));
      expect(source.observedPages.expand((page) => page), [
        _key(1),
        _key(2),
        _key(3),
      ]);
      expect(mutation.batches, isEmpty);
    });

    test(
      'global source unavailability terminates as source access lost',
      () async {
        final evidence = _FakeRequiredAttachmentEvidenceReader([
          _record(0, RequiredAttachmentEvidenceCondition.noDurableRecord),
        ]);
        final source = _FakeCurrentMessagesAttachmentSourceReader({
          _key(0): CurrentMessagesAttachmentSourceCondition.sourceUnavailable,
        });

        final observation = await _executor(
          evidence: evidence,
          source: source,
        ).inspectCurrent(binding: _binding);

        expect(
          observation.kind,
          AppCzarAttachmentArchiveRepairObservationKind.sourceAccessLost,
        );
        expect(observation.snapshot, isNull);
      },
    );

    test('global inconclusive source evidence terminates as unknown', () async {
      final evidence = _FakeRequiredAttachmentEvidenceReader([
        _record(0, RequiredAttachmentEvidenceCondition.noDurableRecord),
      ]);
      final source = _FakeCurrentMessagesAttachmentSourceReader({
        _key(0): CurrentMessagesAttachmentSourceCondition.sourceInconclusive,
      });

      final observation = await _executor(
        evidence: evidence,
        source: source,
      ).inspectCurrent(binding: _binding);

      expect(
        observation.kind,
        AppCzarAttachmentArchiveRepairObservationKind.coverageUnknown,
      );
      expect(observation.snapshot, isNull);
    });

    test('mismatched bounded summary samples fail closed', () async {
      final evidence = _FakeRequiredAttachmentEvidenceReader(
        [_record(0, RequiredAttachmentEvidenceCondition.noDurableRecord)],
        summaryFingerprints: const ['revision-a', 'revision-b'],
      );
      final source = _FakeCurrentMessagesAttachmentSourceReader({
        _key(0): CurrentMessagesAttachmentSourceCondition.absent,
      });

      final observation = await _executor(
        evidence: evidence,
        source: source,
      ).inspectCurrent(binding: _binding);

      expect(evidence.summaryReadCount, 2);
      expect(
        observation.kind,
        AppCzarAttachmentArchiveRepairObservationKind.coverageUnknown,
      );
    });

    test('archive binding change terminates the occurrence', () async {
      final evidence = _FakeRequiredAttachmentEvidenceReader([
        _record(0, RequiredAttachmentEvidenceCondition.coveredAndValid),
      ]);
      final contexts = <AttachmentArchiveRepairArchiveContext>[
        _context,
        _context,
        AttachmentArchiveRepairArchiveContext(
          archiveScopeIdentity: 'replacement-scope',
          archiveGeneration: 8,
          resolvedArchivePath: '/test/archive-replacement',
          automaticPreservationAllowed: true,
        ),
      ];
      var contextIndex = 0;
      final executor = MessageLensAppCzarAttachmentArchiveRepairExecutor(
        evidenceReader: evidence,
        sourceReaderResolver: () async {
          return _FakeCurrentMessagesAttachmentSourceReader(const {});
        },
        archiveContextReader: () async {
          final index = contextIndex.clamp(0, contexts.length - 1);
          contextIndex += 1;
          return contexts[index];
        },
        mutationBatchExecutor: _FakeMutationBatchExecutor(evidence: evidence),
      );

      final observation = await executor.inspectCurrent(binding: _binding);

      expect(
        observation.kind,
        AppCzarAttachmentArchiveRepairObservationKind.archiveBindingChanged,
      );
    });

    test('binding and current context canonicalize the archive root once', () {
      final binding = AppCzarAttachmentArchiveRepairBinding(
        occurrenceId: 1,
        assessmentGeneration: 2,
        archiveScopeIdentity: 'scope',
        archiveGeneration: 3,
        resolvedArchivePath: '/test/archive/./',
      );
      final context = AttachmentArchiveRepairArchiveContext(
        archiveScopeIdentity: 'scope',
        archiveGeneration: 3,
        resolvedArchivePath: '/test/archive',
        automaticPreservationAllowed: true,
      );

      expect(binding.resolvedArchivePath, '/test/archive');
      expect(context.resolvedArchivePath, '/test/archive');
      expect(context.matches(binding), isTrue);
      expect(context.evidenceBinding.archiveRootPath, '/test/archive');
    });
  });

  group('MessageLensAppCzarAttachmentArchiveRepairExecutor preservation', () {
    test(
      '151 available items require three exact human confirmations',
      () async {
        final records = List<_MutableEvidenceRecord>.generate(
          151,
          (index) => _record(
            index,
            RequiredAttachmentEvidenceCondition.noDurableRecord,
          ),
        );
        final evidence = _FakeRequiredAttachmentEvidenceReader(records);
        final source = _FakeCurrentMessagesAttachmentSourceReader({
          for (var index = 0; index < records.length; index++)
            _key(index): CurrentMessagesAttachmentSourceCondition.available,
        });
        final mutation = _FakeMutationBatchExecutor(evidence: evidence);
        final executor = _executor(
          evidence: evidence,
          source: source,
          mutation: mutation,
        );

        final before = await executor.inspectCurrent(binding: _binding);

        expect(before.snapshot?.availableFromMessagesCount, 151);
        expect(before.snapshot?.nextBatchAuthorization?.itemCount, 75);
        expect(
          before.snapshot?.nextBatchAuthorization?.totalKnownBytes,
          List<int>.generate(
            75,
            (index) => index + 100,
          ).reduce((a, b) => a + b),
        );
        expect(mutation.batches, isEmpty);
        final summariesBeforePreservation = evidence.summaryReadCount;

        final progress = <AppCzarAttachmentArchiveRepairProgress>[];
        final afterFirst = await executor.preserveAuthorizedBatch(
          binding: _binding,
          authorization: before.snapshot!.nextBatchAuthorization!,
          onProgress: progress.add,
        );

        expect(mutation.batches.map((batch) => batch.length), [75]);
        expect(mutation.batches.single, List.generate(75, _key));
        expect(mutation.batches.single, isNot(contains(_key(75))));
        expect(
          afterFirst.kind,
          AppCzarAttachmentArchiveRepairObservationKind.coverageIncomplete,
        );
        expect(afterFirst.snapshot?.coveredCount, 75);
        expect(afterFirst.snapshot?.availableFromMessagesCount, 76);
        expect(afterFirst.snapshot?.nextBatchAuthorization?.itemCount, 75);
        expect(progress.map((item) => item.completedCount), [75]);
        expect(progress.single.totalCount, 75);

        final afterSecond = await executor.preserveAuthorizedBatch(
          binding: _binding,
          authorization: afterFirst.snapshot!.nextBatchAuthorization!,
        );

        expect(mutation.batches.map((batch) => batch.length), [75, 75]);
        expect(
          mutation.batches[1],
          List.generate(75, (index) => _key(index + 75)),
        );
        expect(afterSecond.snapshot?.availableFromMessagesCount, 1);
        expect(afterSecond.snapshot?.nextBatchAuthorization?.itemCount, 1);

        final afterThird = await executor.preserveAuthorizedBatch(
          binding: _binding,
          authorization: afterSecond.snapshot!.nextBatchAuthorization!,
        );

        expect(mutation.batches.map((batch) => batch.length), [75, 75, 1]);
        expect(mutation.batches[2], [_key(150)]);
        expect(source.observedPages.every((page) => page.length <= 75), isTrue);
        expect(evidence.pageLimits.every((limit) => limit <= 75), isTrue);
        expect(
          afterThird.kind,
          AppCzarAttachmentArchiveRepairObservationKind.coverageComplete,
        );
        expect(afterThird.snapshot?.coveredCount, 151);
        expect(afterThird.snapshot?.needAttentionCount, 0);
        expect(
          evidence.summaryReadCount,
          greaterThan(summariesBeforePreservation),
        );
      },
    );

    test('fresh recomputation discovers later source availability without a '
        'durable cursor', () async {
      final evidence = _FakeRequiredAttachmentEvidenceReader([
        _record(0, RequiredAttachmentEvidenceCondition.noDurableRecord),
      ]);
      final source = _FakeCurrentMessagesAttachmentSourceReader({
        _key(0): CurrentMessagesAttachmentSourceCondition.absent,
      });
      final mutation = _FakeMutationBatchExecutor(evidence: evidence);
      final executor = _executor(
        evidence: evidence,
        source: source,
        mutation: mutation,
      );

      final manual = await executor.inspectCurrent(binding: _binding);

      expect(
        manual.kind,
        AppCzarAttachmentArchiveRepairObservationKind.coverageIncomplete,
      );
      expect(manual.snapshot?.sourceAbsentCount, 1);
      expect(mutation.batches, isEmpty);

      source.conditions[_key(0)] =
          CurrentMessagesAttachmentSourceCondition.available;
      final pageCallsBeforeRetry = evidence.pageAfters.length;

      final available = await executor.inspectCurrent(binding: _binding);
      final repaired = await executor.preserveAuthorizedBatch(
        binding: _binding,
        authorization: available.snapshot!.nextBatchAuthorization!,
      );

      expect(mutation.batches, hasLength(1));
      expect(evidence.pageAfters.skip(pageCallsBeforeRetry).first, isNull);
      expect(
        repaired.kind,
        AppCzarAttachmentArchiveRepairObservationKind.coverageComplete,
      );
    });

    test(
      'stale source evidence invalidates the displayed exact plan',
      () async {
        final evidence = _FakeRequiredAttachmentEvidenceReader([
          _record(0, RequiredAttachmentEvidenceCondition.noDurableRecord),
        ]);
        final source = _FakeCurrentMessagesAttachmentSourceReader({
          _key(0): CurrentMessagesAttachmentSourceCondition.available,
        });
        final mutation = _FakeMutationBatchExecutor(evidence: evidence);
        final executor = _executor(
          evidence: evidence,
          source: source,
          mutation: mutation,
        );
        final displayed = await executor.inspectCurrent(binding: _binding);

        source.bumpMaterialVersion(_key(0));
        final refreshed = await executor.preserveAuthorizedBatch(
          binding: _binding,
          authorization: displayed.snapshot!.nextBatchAuthorization!,
        );

        expect(mutation.batches, isEmpty);
        expect(
          refreshed.kind,
          AppCzarAttachmentArchiveRepairObservationKind.coverageIncomplete,
        );
        expect(
          identical(
            refreshed.snapshot!.nextBatchAuthorization,
            displayed.snapshot!.nextBatchAuthorization,
          ),
          isFalse,
        );
      },
    );

    test(
      'stale consent cannot refill an unavailable key with item 76',
      () async {
        final records = List<_MutableEvidenceRecord>.generate(
          76,
          (index) => _record(
            index,
            RequiredAttachmentEvidenceCondition.noDurableRecord,
          ),
        );
        final evidence = _FakeRequiredAttachmentEvidenceReader(records);
        final source = _FakeCurrentMessagesAttachmentSourceReader({
          for (var index = 0; index < records.length; index++)
            _key(index): CurrentMessagesAttachmentSourceCondition.available,
        });
        final mutation = _FakeMutationBatchExecutor(evidence: evidence);
        final executor = _executor(
          evidence: evidence,
          source: source,
          mutation: mutation,
        );
        final displayed = await executor.inspectCurrent(binding: _binding);

        source.conditions[_key(0)] =
            CurrentMessagesAttachmentSourceCondition.absent;
        final refreshed = await executor.preserveAuthorizedBatch(
          binding: _binding,
          authorization: displayed.snapshot!.nextBatchAuthorization!,
        );

        expect(mutation.batches, isEmpty);
        expect(refreshed.snapshot?.nextBatchAuthorization?.itemCount, 75);

        final afterFreshConfirmation = await executor.preserveAuthorizedBatch(
          binding: _binding,
          authorization: refreshed.snapshot!.nextBatchAuthorization!,
        );
        expect(mutation.batches, hasLength(1));
        expect(mutation.batches.single.first, _key(1));
        expect(mutation.batches.single.last, _key(75));
        expect(
          afterFreshConfirmation.kind,
          AppCzarAttachmentArchiveRepairObservationKind.coverageIncomplete,
        );
      },
    );

    test(
      'new required items invalidate rather than expand old consent',
      () async {
        final evidence = _FakeRequiredAttachmentEvidenceReader([
          _record(0, RequiredAttachmentEvidenceCondition.noDurableRecord),
        ]);
        final source = _FakeCurrentMessagesAttachmentSourceReader({
          _key(0): CurrentMessagesAttachmentSourceCondition.available,
          _key(1): CurrentMessagesAttachmentSourceCondition.available,
        });
        final mutation = _FakeMutationBatchExecutor(evidence: evidence);
        final executor = _executor(
          evidence: evidence,
          source: source,
          mutation: mutation,
        );
        final displayed = await executor.inspectCurrent(binding: _binding);

        evidence.records.add(
          _record(1, RequiredAttachmentEvidenceCondition.noDurableRecord),
        );
        final refreshed = await executor.preserveAuthorizedBatch(
          binding: _binding,
          authorization: displayed.snapshot!.nextBatchAuthorization!,
        );

        expect(mutation.batches, isEmpty);
        expect(refreshed.snapshot?.nextBatchAuthorization?.itemCount, 2);
        expect(refreshed.snapshot?.availableFromMessagesCount, 2);
      },
    );

    test(
      'changed archive generation invalidates consent before mutation',
      () async {
        final evidence = _FakeRequiredAttachmentEvidenceReader([
          _record(0, RequiredAttachmentEvidenceCondition.noDurableRecord),
        ]);
        final source = _FakeCurrentMessagesAttachmentSourceReader({
          _key(0): CurrentMessagesAttachmentSourceCondition.available,
        });
        final mutation = _FakeMutationBatchExecutor(evidence: evidence);
        var context = _context;
        final executor = _executor(
          evidence: evidence,
          source: source,
          mutation: mutation,
          archiveContextReader: () async => context,
        );
        final displayed = await executor.inspectCurrent(binding: _binding);

        context = AttachmentArchiveRepairArchiveContext(
          archiveScopeIdentity: _context.archiveScopeIdentity,
          archiveGeneration: _context.archiveGeneration + 1,
          resolvedArchivePath: _context.resolvedArchivePath,
          automaticPreservationAllowed: true,
        );
        final result = await executor.preserveAuthorizedBatch(
          binding: _binding,
          authorization: displayed.snapshot!.nextBatchAuthorization!,
        );

        expect(mutation.batches, isEmpty);
        expect(
          result.kind,
          AppCzarAttachmentArchiveRepairObservationKind.archiveBindingChanged,
        );
      },
    );

    test('direct execution without the presented plan cannot mutate', () async {
      final evidence = _FakeRequiredAttachmentEvidenceReader([
        _record(0, RequiredAttachmentEvidenceCondition.noDurableRecord),
      ]);
      final source = _FakeCurrentMessagesAttachmentSourceReader({
        _key(0): CurrentMessagesAttachmentSourceCondition.available,
      });
      final mutation = _FakeMutationBatchExecutor(evidence: evidence);
      final executor = _executor(
        evidence: evidence,
        source: source,
        mutation: mutation,
      );

      final result = await executor.preserveAuthorizedBatch(
        binding: _binding,
        authorization: const AppCzarAttachmentArchiveRepairBatchAuthorization(
          planIdentity: 'not-presented-by-this-executor',
          itemCount: 1,
          totalKnownBytes: 100,
        ),
      );

      expect(mutation.batches, isEmpty);
      expect(result.snapshot?.nextBatchAuthorization?.itemCount, 1);
    });

    test(
      'unknown byte scope is visible evidence but cannot admit mutation',
      () async {
        final evidence = _FakeRequiredAttachmentEvidenceReader([
          _record(0, RequiredAttachmentEvidenceCondition.noDurableRecord),
        ]);
        final source = _FakeCurrentMessagesAttachmentSourceReader(
          {_key(0): CurrentMessagesAttachmentSourceCondition.available},
          unknownByteKeys: {_key(0)},
        );
        final mutation = _FakeMutationBatchExecutor(evidence: evidence);
        final executor = _executor(
          evidence: evidence,
          source: source,
          mutation: mutation,
        );

        final displayed = await executor.inspectCurrent(binding: _binding);

        expect(
          displayed.snapshot?.nextBatchAuthorization?.totalKnownBytes,
          isNull,
        );
        expect(displayed.snapshot?.hasAutomaticWork, isFalse);
        final result = await executor.preserveAuthorizedBatch(
          binding: _binding,
          authorization: displayed.snapshot!.nextBatchAuthorization!,
        );
        expect(mutation.batches, isEmpty);
        expect(result.snapshot?.hasAutomaticWork, isFalse);
      },
    );

    test(
      'mutation source loss and inconclusive evidence fail closed',
      () async {
        for (final scenario
            in <
              (
                AttachmentArchiveRepairMutationBatchStatus,
                AppCzarAttachmentArchiveRepairObservationKind,
              )
            >[
              (
                AttachmentArchiveRepairMutationBatchStatus.sourceAccessLost,
                AppCzarAttachmentArchiveRepairObservationKind.sourceAccessLost,
              ),
              (
                AttachmentArchiveRepairMutationBatchStatus.sourceInconclusive,
                AppCzarAttachmentArchiveRepairObservationKind.coverageUnknown,
              ),
              (
                AttachmentArchiveRepairMutationBatchStatus
                    .archiveBindingChanged,
                AppCzarAttachmentArchiveRepairObservationKind
                    .archiveBindingChanged,
              ),
            ]) {
          final evidence = _FakeRequiredAttachmentEvidenceReader([
            _record(0, RequiredAttachmentEvidenceCondition.noDurableRecord),
          ]);
          final source = _FakeCurrentMessagesAttachmentSourceReader({
            _key(0): CurrentMessagesAttachmentSourceCondition.available,
          });
          final mutation = _FakeMutationBatchExecutor(
            evidence: evidence,
            statuses: [scenario.$1],
          );

          final executor = _executor(
            evidence: evidence,
            source: source,
            mutation: mutation,
          );
          final before = await executor.inspectCurrent(binding: _binding);
          final observation = await executor.preserveAuthorizedBatch(
            binding: _binding,
            authorization: before.snapshot!.nextBatchAuthorization!,
          );

          expect(observation.kind, scenario.$2);
          expect(mutation.batches, hasLength(1));
        }
      },
    );

    test(
      'preservation evidence-read failure becomes coverage unknown',
      () async {
        final evidence = _FakeRequiredAttachmentEvidenceReader([
          _record(0, RequiredAttachmentEvidenceCondition.noDurableRecord),
        ], failPageReadOnCall: 2);
        final source = _FakeCurrentMessagesAttachmentSourceReader({
          _key(0): CurrentMessagesAttachmentSourceCondition.available,
        });
        final mutation = _FakeMutationBatchExecutor(evidence: evidence);

        final executor = _executor(
          evidence: evidence,
          source: source,
          mutation: mutation,
        );
        final before = await executor.inspectCurrent(binding: _binding);
        final observation = await executor.preserveAuthorizedBatch(
          binding: _binding,
          authorization: before.snapshot!.nextBatchAuthorization!,
        );

        expect(
          observation.kind,
          AppCzarAttachmentArchiveRepairObservationKind.coverageUnknown,
        );
        expect(mutation.batches, isEmpty);
      },
    );

    test(
      'stopAndDrain waits for the in-flight batch and prevents new admission',
      () async {
        final evidence = _FakeRequiredAttachmentEvidenceReader([
          _record(0, RequiredAttachmentEvidenceCondition.noDurableRecord),
          _record(1, RequiredAttachmentEvidenceCondition.noDurableRecord),
        ]);
        final source = _FakeCurrentMessagesAttachmentSourceReader({
          _key(0): CurrentMessagesAttachmentSourceCondition.available,
          _key(1): CurrentMessagesAttachmentSourceCondition.available,
        });
        final batchStarted = Completer<void>();
        final releaseBatch = Completer<void>();
        final mutation = _FakeMutationBatchExecutor(
          evidence: evidence,
          batchStarted: batchStarted,
          releaseBatch: releaseBatch,
        );
        final executor = _executor(
          evidence: evidence,
          source: source,
          mutation: mutation,
          pageSize: 1,
        );

        final before = await executor.inspectCurrent(binding: _binding);
        final preservation = executor.preserveAuthorizedBatch(
          binding: _binding,
          authorization: before.snapshot!.nextBatchAuthorization!,
        );
        await batchStarted.future;
        var drainFinished = false;
        final drain = executor.stopAndDrain().then((_) {
          drainFinished = true;
        });
        await Future<void>.delayed(Duration.zero);

        expect(drainFinished, isFalse);
        expect(mutation.batches, hasLength(1));
        expect(mutation.shouldStopAfterRelease, isNull);

        releaseBatch.complete();
        final observation = await preservation;
        await drain;

        expect(mutation.shouldStopAfterRelease, isTrue);
        expect(
          observation.kind,
          AppCzarAttachmentArchiveRepairObservationKind.stopped,
        );
        expect(mutation.batches, hasLength(1));
        expect(drainFinished, isTrue);

        final rejected = await executor.inspectCurrent(binding: _binding);
        expect(
          rejected.kind,
          AppCzarAttachmentArchiveRepairObservationKind.stopped,
        );
        expect(mutation.batches, hasLength(1));
      },
    );
  });
}

final _binding = AppCzarAttachmentArchiveRepairBinding(
  occurrenceId: 11,
  assessmentGeneration: 23,
  archiveScopeIdentity: 'scope-1',
  archiveGeneration: 7,
  resolvedArchivePath: '/test/archive',
);

final _context = AttachmentArchiveRepairArchiveContext(
  archiveScopeIdentity: 'scope-1',
  archiveGeneration: 7,
  resolvedArchivePath: '/test/archive',
  automaticPreservationAllowed: true,
);

ArchiveCompatibilityKey _key(int index) {
  return ArchiveCompatibilityKey(
    messageGuid: 'message-${index.toString().padLeft(4, '0')}',
    importAttachmentId: index + 100,
  );
}

_MutableEvidenceRecord _record(
  int index,
  RequiredAttachmentEvidenceCondition condition,
) {
  return _MutableEvidenceRecord(key: _key(index), condition: condition);
}

MessageLensAppCzarAttachmentArchiveRepairExecutor _executor({
  required _FakeRequiredAttachmentEvidenceReader evidence,
  required _FakeCurrentMessagesAttachmentSourceReader source,
  _FakeMutationBatchExecutor? mutation,
  int pageSize = appCzarAttachmentArchiveRepairPageSize,
  AttachmentArchiveRepairArchiveContextReader? archiveContextReader,
}) {
  return MessageLensAppCzarAttachmentArchiveRepairExecutor(
    evidenceReader: evidence,
    sourceReaderResolver: () async => source,
    archiveContextReader: archiveContextReader ?? () async => _context,
    mutationBatchExecutor:
        mutation ?? _FakeMutationBatchExecutor(evidence: evidence),
    pageSize: pageSize,
  );
}

final class _MutableEvidenceRecord {
  _MutableEvidenceRecord({required this.key, required this.condition});

  final ArchiveCompatibilityKey key;
  RequiredAttachmentEvidenceCondition condition;

  RequiredAttachmentEvidenceCursor get cursor {
    return RequiredAttachmentEvidenceCursor(
      messageGuid: key.messageGuid,
      liveAttachmentRowId: key.liveSourceAttachmentRowId,
    );
  }

  RequiredAttachmentEvidenceItem toItem() {
    return RequiredAttachmentEvidenceItem(
      cursor: cursor,
      archiveKey: key,
      condition: condition,
      materialFingerprint: '${key.storageKeySegment}:${condition.name}',
    );
  }
}

final class _FakeRequiredAttachmentEvidenceReader
    implements RequiredAttachmentEvidenceReader {
  _FakeRequiredAttachmentEvidenceReader(
    List<_MutableEvidenceRecord> records, {
    List<String> summaryFingerprints = const [],
    this.failPageReadOnCall,
  }) : records = List<_MutableEvidenceRecord>.of(records),
       _summaryFingerprints = List<String>.of(summaryFingerprints);

  final List<_MutableEvidenceRecord> records;
  final List<String> _summaryFingerprints;
  final int? failPageReadOnCall;
  final List<int> pageLimits = [];
  final List<RequiredAttachmentEvidenceCursor?> pageAfters = [];
  int summaryReadCount = 0;

  @override
  Future<RequiredAttachmentEvidencePage> readPage({
    required RequiredAttachmentEvidenceBinding binding,
    RequiredAttachmentEvidenceCursor? after,
    int limit = 75,
  }) async {
    pageLimits.add(limit);
    pageAfters.add(after);
    if (pageAfters.length == failPageReadOnCall) {
      throw const RequiredAttachmentEvidenceReadException(
        'simulated preservation evidence failure',
      );
    }
    final start = after == null
        ? 0
        : records.indexWhere((record) => record.cursor == after) + 1;
    if (start < 0) {
      throw StateError('Unknown test cursor.');
    }
    final end = (start + limit).clamp(0, records.length);
    final pageRecords = records.sublist(start, end);
    return RequiredAttachmentEvidencePage(
      items: pageRecords.map((record) => record.toItem()),
      nextCursor: pageRecords.isEmpty ? null : pageRecords.last.cursor,
      hasMore: end < records.length,
      binding: binding,
    );
  }

  @override
  Future<RequiredAttachmentEvidenceSummary> readSummary({
    required RequiredAttachmentEvidenceBinding binding,
    int pageSize = 75,
  }) async {
    final call = summaryReadCount;
    summaryReadCount += 1;
    final items = records.map((record) => record.toItem()).toList();
    final fingerprint = call < _summaryFingerprints.length
        ? _summaryFingerprints[call]
        : items.map((item) => item.materialFingerprint).join('|');
    return RequiredAttachmentEvidenceSummary(
      requiredCount: items.length,
      coveredCount: items.where((item) => item.isCovered).length,
      missingCount: items.where((item) => item.isMissing).length,
      unverifiableCount: items.where((item) => item.isUnverifiable).length,
      materialFingerprint: fingerprint,
      binding: binding,
    );
  }

  void markCovered(Iterable<ArchiveCompatibilityKey> keys) {
    final keySet = keys.toSet();
    for (final record in records) {
      if (keySet.contains(record.key)) {
        record.condition = RequiredAttachmentEvidenceCondition.coveredAndValid;
      }
    }
  }
}

final class _FakeCurrentMessagesAttachmentSourceReader
    implements CurrentMessagesAttachmentSourceReader {
  _FakeCurrentMessagesAttachmentSourceReader(
    Map<ArchiveCompatibilityKey, CurrentMessagesAttachmentSourceCondition>
    conditions, {
    Set<ArchiveCompatibilityKey> unknownByteKeys = const {},
  }) : conditions =
           Map<
             ArchiveCompatibilityKey,
             CurrentMessagesAttachmentSourceCondition
           >.of(conditions),
       unknownByteKeys = Set<ArchiveCompatibilityKey>.of(unknownByteKeys);

  final Map<ArchiveCompatibilityKey, CurrentMessagesAttachmentSourceCondition>
  conditions;
  final Set<ArchiveCompatibilityKey> unknownByteKeys;
  final Map<ArchiveCompatibilityKey, int> _materialVersions = {};
  final List<List<ArchiveCompatibilityKey>> observedPages = [];

  void bumpMaterialVersion(ArchiveCompatibilityKey key) {
    _materialVersions[key] = (_materialVersions[key] ?? 0) + 1;
  }

  @override
  Future<CurrentMessagesAttachmentSourceObservation> observeCurrent(
    ArchiveCompatibilityKey archiveKey,
  ) async {
    return _observationFor(archiveKey);
  }

  @override
  Future<List<CurrentMessagesAttachmentSourceObservation>> observeCurrentPage(
    List<ArchiveCompatibilityKey> archiveKeys,
  ) async {
    observedPages.add(List<ArchiveCompatibilityKey>.of(archiveKeys));
    return archiveKeys.map(_observationFor).toList(growable: false);
  }

  CurrentMessagesAttachmentSourceObservation _observationFor(
    ArchiveCompatibilityKey key,
  ) {
    final condition =
        conditions[key] ?? CurrentMessagesAttachmentSourceCondition.unknown;
    final version = _materialVersions[key] ?? 0;
    return switch (condition) {
      CurrentMessagesAttachmentSourceCondition.available =>
        CurrentMessagesAttachmentSourceObservation(
          archiveKey: key,
          condition: CurrentMessagesAttachmentSourceCondition.available,
          sourcePath: '/test/source/${key.importAttachmentId}/$version',
          mimeType: 'image/png',
          fileSizeBytes: unknownByteKeys.contains(key)
              ? null
              : key.importAttachmentId + version,
          modifiedAtMicrosecondsSinceEpoch:
              key.importAttachmentId * 1000 + version,
        ),
      CurrentMessagesAttachmentSourceCondition.absent =>
        CurrentMessagesAttachmentSourceObservation.absent(archiveKey: key),
      CurrentMessagesAttachmentSourceCondition.unreadable =>
        CurrentMessagesAttachmentSourceObservation.unreadable(archiveKey: key),
      CurrentMessagesAttachmentSourceCondition.sourceUnavailable =>
        CurrentMessagesAttachmentSourceObservation.sourceUnavailable(
          archiveKey: key,
        ),
      CurrentMessagesAttachmentSourceCondition.sourceInconclusive =>
        CurrentMessagesAttachmentSourceObservation.sourceInconclusive(
          archiveKey: key,
        ),
      CurrentMessagesAttachmentSourceCondition.unknown =>
        CurrentMessagesAttachmentSourceObservation.unknown(archiveKey: key),
    };
  }
}

final class _FakeMutationBatchExecutor
    implements AttachmentArchiveRepairMutationBatchExecutor {
  _FakeMutationBatchExecutor({
    required this.evidence,
    List<AttachmentArchiveRepairMutationBatchStatus> statuses = const [],
    this.batchStarted,
    this.releaseBatch,
  }) : _statuses = List<AttachmentArchiveRepairMutationBatchStatus>.of(
         statuses,
       );

  final _FakeRequiredAttachmentEvidenceReader evidence;
  final List<AttachmentArchiveRepairMutationBatchStatus> _statuses;
  final Completer<void>? batchStarted;
  final Completer<void>? releaseBatch;
  final List<List<ArchiveCompatibilityKey>> batches = [];
  bool? shouldStopAfterRelease;

  @override
  Future<AttachmentArchiveRepairMutationBatchResult> preserveNoRecordBatch({
    required AppCzarAttachmentArchiveRepairBinding binding,
    required List<CurrentMessagesAttachmentSourceObservation> sources,
    required bool Function() shouldStop,
  }) async {
    final keys = sources.map((source) => source.archiveKey).toList();
    batches.add(keys);
    if (batchStarted != null && !batchStarted!.isCompleted) {
      batchStarted!.complete();
    }
    if (releaseBatch != null) {
      await releaseBatch!.future;
      shouldStopAfterRelease = shouldStop();
    }
    final status = batches.length <= _statuses.length
        ? _statuses[batches.length - 1]
        : AttachmentArchiveRepairMutationBatchStatus.settled;
    if (status == AttachmentArchiveRepairMutationBatchStatus.settled &&
        !shouldStop()) {
      evidence.markCovered(keys);
    }
    return AttachmentArchiveRepairMutationBatchResult(
      status: status,
      processedCount: keys.length,
      preservedCount:
          status == AttachmentArchiveRepairMutationBatchStatus.settled
          ? keys.length
          : 0,
    );
  }
}
