import 'dart:typed_data';

import '../../domain/ports/import_ledger_port.dart';
import '../../domain/ports/message_extractor_port.dart';
import '../../domain/source_import_anomaly_counts.dart';
import '../source_import_page_metric.dart';
import '../source_import_work_progress.dart';

const int defaultRichTextCandidatePageSize = 500;
const int defaultRichTextPageBlobByteTarget = 8 * 1024 * 1024;
// Keep this aligned with the native decoder's per-record input ceiling. The
// ledger applies it before materializing a BLOB into Dart memory.
const int defaultMaximumAttributedBodyBlobBytes = 8 * 1024 * 1024;

class MessageRichTextEnrichmentResult {
  const MessageRichTextEnrichmentResult({
    required this.candidateMessageCount,
    required this.enrichedMessageCount,
    required this.missingExtractionCount,
    required this.extractorAvailable,
    this.anomalyCounts = SourceImportAnomalyCounts.empty,
  });

  final int candidateMessageCount;
  final int enrichedMessageCount;
  final int missingExtractionCount;
  final bool extractorAvailable;
  final SourceImportAnomalyCounts anomalyCounts;
}

class MessageRichTextEnricher {
  const MessageRichTextEnricher({
    required this.chatDbPath,
    required this.importLedger,
    required this.extractor,
    this.candidatePageSize = defaultRichTextCandidatePageSize,
    this.pageBlobByteTarget = defaultRichTextPageBlobByteTarget,
    this.maximumAttributedBodyBlobBytes = defaultMaximumAttributedBodyBlobBytes,
    this.onPageMetric,
  });

  final String chatDbPath;
  final ImportLedger importLedger;
  final MessageExtractorPort extractor;
  final int candidatePageSize;
  final int pageBlobByteTarget;
  final int maximumAttributedBodyBlobBytes;
  final SourceImportPageMetricObserver? onPageMetric;

  Future<MessageRichTextEnrichmentResult> enrichMissingText({
    SourceImportWorkObserver? onProgress,
  }) async {
    return _enrichMissingText(
      sourceId: null,
      startedAfterSourceRowId: null,
      onProgress: onProgress,
    );
  }

  Future<MessageRichTextEnrichmentResult> enrichMissingTextAfterSourceRowId({
    required int sourceId,
    required int startedAfterSourceRowId,
    SourceImportWorkObserver? onProgress,
  }) {
    return _enrichMissingText(
      sourceId: sourceId,
      startedAfterSourceRowId: startedAfterSourceRowId,
      onProgress: onProgress,
    );
  }

  Future<MessageRichTextEnrichmentResult> enrichMissingTextForSource({
    required int sourceId,
    SourceImportWorkObserver? onProgress,
  }) {
    return _enrichMissingText(
      sourceId: sourceId,
      startedAfterSourceRowId: null,
      onProgress: onProgress,
    );
  }

  Future<MessageRichTextEnrichmentResult> _enrichMissingText({
    required int? sourceId,
    required int? startedAfterSourceRowId,
    required SourceImportWorkObserver? onProgress,
  }) async {
    if (candidatePageSize <= 0) {
      throw ArgumentError.value(
        candidatePageSize,
        'candidatePageSize',
        'must be greater than 0',
      );
    }
    if (pageBlobByteTarget <= 0) {
      throw ArgumentError.value(
        pageBlobByteTarget,
        'pageBlobByteTarget',
        'must be greater than 0',
      );
    }
    if (maximumAttributedBodyBlobBytes <= 0) {
      throw ArgumentError.value(
        maximumAttributedBodyBlobBytes,
        'maximumAttributedBodyBlobBytes',
        'must be greater than 0',
      );
    }

    final window = await importLedger.messageTextEnrichmentWindow(
      sourceId: sourceId,
      startedAfterSourceRowId: startedAfterSourceRowId,
    );
    final candidateMessageCount = window.candidateCount;

    if (candidateMessageCount == 0) {
      publishSourceImportProgress(
        observer: onProgress,
        unit: SourceImportWorkUnit.richTextExtraction,
        completedWorkCount: 0,
        totalWorkCount: 0,
      );
      return const MessageRichTextEnrichmentResult(
        candidateMessageCount: 0,
        enrichedMessageCount: 0,
        missingExtractionCount: 0,
        extractorAvailable: true,
      );
    }
    final highWaterSsId = window.highWaterSsId;
    if (highWaterSsId == null) {
      throw const SourceImportSystemicException(
        unit: SourceImportWorkUnit.richTextExtraction,
        failureCode: 'rich_text_candidate_window_invalid',
        reason: 'The non-empty rich-text window has no high-water identity.',
      );
    }

    final extractorAvailable = await extractor.isBlobExtractionAvailable();
    if (!extractorAvailable) {
      throw const SourceImportSystemicException(
        unit: SourceImportWorkUnit.richTextExtraction,
        failureCode: 'typedstream_decoder_unavailable',
        reason: 'Attributed-string decoding is unavailable for this run.',
      );
    }

    publishSourceImportProgress(
      observer: onProgress,
      unit: SourceImportWorkUnit.richTextExtraction,
      completedWorkCount: 0,
      totalWorkCount: candidateMessageCount,
    );
    var enrichedMessageCount = 0;
    var missingExtractionCount = 0;
    var completedCandidateCount = 0;
    var pageCursorSsId = 0;
    var decoderPageOrdinal = 0;
    publishSourceImportProgress(
      observer: onProgress,
      unit: SourceImportWorkUnit.richTextPersistence,
      completedWorkCount: 0,
      totalWorkCount: candidateMessageCount,
    );

    while (pageCursorSsId < highWaterSsId) {
      var candidates = await importLedger.readMessageTextEnrichmentPage(
        afterSsId: pageCursorSsId,
        throughSsId: highWaterSsId,
        limit: candidatePageSize,
        sourceId: sourceId,
        startedAfterSourceRowId: startedAfterSourceRowId,
      );
      if (candidates.isEmpty) {
        break;
      }
      final candidatePageLastSsId = candidates.last.ssId;

      for (final decoderPage in _partitionCandidatesByBlobBytes(
        candidates,
        pageBlobByteTarget: pageBlobByteTarget,
      )) {
        decoderPageOrdinal += 1;
        final stopwatch = Stopwatch()..start();
        final completedBeforePage = completedCandidateCount;
        final pageBlobBytes = decoderPage.fold<int>(0, (total, candidate) {
          return total + candidate.attributedBodyBlobByteCount;
        });
        final maximumPageBlobBytes = decoderPage.fold<int>(0, (
          maximum,
          candidate,
        ) {
          final blobBytes = candidate.attributedBodyBlobByteCount;
          return blobBytes > maximum ? blobBytes : maximum;
        });
        try {
          final candidateBySsId = <int, ImportLedgerMessageTextCandidate>{
            for (final candidate in decoderPage) candidate.ssId: candidate,
          };
          final candidatesWithinNativeBudget = decoderPage
              .where((candidate) {
                return candidate.attributedBodyBlobByteCount <=
                    maximumAttributedBodyBlobBytes;
              })
              .toList(growable: false);
          final loadedBlobsByMessageSsId = await importLedger
              .readMessageTextEnrichmentBlobs(
                ssIds: <int>[
                  for (final candidate in candidatesWithinNativeBudget)
                    candidate.ssId,
                ],
                maximumBlobBytes: maximumAttributedBodyBlobBytes,
              );
          final blobsByMessageSsId = <int, Uint8List>{
            for (final candidate in candidatesWithinNativeBudget)
              if (loadedBlobsByMessageSsId[candidate.ssId]?.length ==
                  candidate.attributedBodyBlobByteCount)
                candidate.ssId: loadedBlobsByMessageSsId[candidate.ssId]!,
          };
          final extracted = blobsByMessageSsId.isEmpty
              ? const <int, String>{}
              : await extractor.extractMessageTextsFromBlobs(
                  blobsByMessageSsId,
                  onProgress:
                      ({
                        required completedWorkCount,
                        required totalWorkCount,
                        required lastCompletedWorkId,
                      }) {
                        final candidate = candidateBySsId[lastCompletedWorkId];
                        publishSourceImportProgress(
                          observer: onProgress,
                          unit: SourceImportWorkUnit.richTextExtraction,
                          completedWorkCount:
                              completedBeforePage + completedWorkCount,
                          totalWorkCount: candidateMessageCount,
                          lastCompletedSourceRowId: candidate?.sourceRowId,
                          anomalyCounts: SourceImportAnomalyCounts(
                            richTextDecodeUnavailableCount:
                                missingExtractionCount,
                          ),
                        );
                      },
                );

          var pageEnrichedMessageCount = 0;
          var pageMissingExtractionCount = 0;
          await importLedger.writeTransaction((txn) async {
            for (final candidate in decoderPage) {
              final normalized = extracted[candidate.ssId]?.trim();
              if (normalized == null || normalized.isEmpty) {
                pageMissingExtractionCount += 1;
                continue;
              }
              final updated = await txn.update(
                'messages',
                <String, Object?>{'text': normalized},
                where: 'ss_id = ? AND text IS NULL',
                whereArgs: <Object?>[candidate.ssId],
              );
              if (updated > 0) {
                pageEnrichedMessageCount += 1;
              }
            }
          });

          enrichedMessageCount += pageEnrichedMessageCount;
          missingExtractionCount += pageMissingExtractionCount;
          completedCandidateCount += decoderPage.length;
          if (completedCandidateCount > candidateMessageCount) {
            throw SourceImportSystemicException(
              unit: SourceImportWorkUnit.richTextPersistence,
              failureCode: 'rich_text_candidate_window_changed',
              reason:
                  'Expected $candidateMessageCount rich-text candidates '
                  'but processed more than that frozen total.',
            );
          }
          final lastCompletedCandidate = decoderPage.last;
          publishSourceImportProgress(
            observer: onProgress,
            unit: SourceImportWorkUnit.richTextExtraction,
            completedWorkCount: completedCandidateCount,
            totalWorkCount: candidateMessageCount,
            lastCompletedSourceRowId: lastCompletedCandidate.sourceRowId,
            anomalyCounts: SourceImportAnomalyCounts(
              richTextDecodeUnavailableCount: missingExtractionCount,
            ),
          );
          publishSourceImportProgress(
            observer: onProgress,
            unit: SourceImportWorkUnit.richTextPersistence,
            completedWorkCount: completedCandidateCount,
            totalWorkCount: candidateMessageCount,
            lastCompletedSourceRowId: lastCompletedCandidate.sourceRowId,
            anomalyCounts: SourceImportAnomalyCounts(
              richTextDecodeUnavailableCount: missingExtractionCount,
            ),
          );
          stopwatch.stop();
          onPageMetric?.call(
            SourceImportPageMetric(
              stage: SourceImportPageStage.richText,
              outcome: SourceImportPageOutcome.completed,
              pageOrdinal: decoderPageOrdinal,
              pageRowCount: decoderPage.length,
              cumulativeCompletedCount: completedCandidateCount,
              totalWorkCount: candidateMessageCount,
              totalBlobBytes: pageBlobBytes,
              maximumBlobBytes: maximumPageBlobBytes,
              elapsedMilliseconds: stopwatch.elapsedMilliseconds,
            ),
          );
        } catch (_) {
          stopwatch.stop();
          onPageMetric?.call(
            SourceImportPageMetric(
              stage: SourceImportPageStage.richText,
              outcome: SourceImportPageOutcome.failed,
              pageOrdinal: decoderPageOrdinal,
              pageRowCount: decoderPage.length,
              cumulativeCompletedCount: completedBeforePage,
              totalWorkCount: candidateMessageCount,
              totalBlobBytes: pageBlobBytes,
              maximumBlobBytes: maximumPageBlobBytes,
              elapsedMilliseconds: stopwatch.elapsedMilliseconds,
            ),
          );
          rethrow;
        }
        await Future<void>.delayed(Duration.zero);
      }
      pageCursorSsId = candidatePageLastSsId;
      candidates = const <ImportLedgerMessageTextCandidate>[];
    }

    if (completedCandidateCount != candidateMessageCount) {
      throw SourceImportSystemicException(
        unit: SourceImportWorkUnit.richTextPersistence,
        failureCode: 'rich_text_candidate_window_changed',
        reason:
            'Expected $candidateMessageCount rich-text candidates but '
            'completed $completedCandidateCount.',
      );
    }

    return MessageRichTextEnrichmentResult(
      candidateMessageCount: candidateMessageCount,
      enrichedMessageCount: enrichedMessageCount,
      missingExtractionCount: missingExtractionCount,
      extractorAvailable: true,
      anomalyCounts: SourceImportAnomalyCounts(
        richTextDecodeUnavailableCount: missingExtractionCount,
      ),
    );
  }
}

Iterable<List<ImportLedgerMessageTextCandidate>>
_partitionCandidatesByBlobBytes(
  List<ImportLedgerMessageTextCandidate> candidates, {
  required int pageBlobByteTarget,
}) sync* {
  var page = <ImportLedgerMessageTextCandidate>[];
  var pageBlobBytes = 0;
  for (final candidate in candidates) {
    final candidateBlobBytes = candidate.attributedBodyBlobByteCount;
    if (page.isNotEmpty &&
        pageBlobBytes + candidateBlobBytes > pageBlobByteTarget) {
      yield page;
      page = <ImportLedgerMessageTextCandidate>[];
      pageBlobBytes = 0;
    }
    page.add(candidate);
    pageBlobBytes += candidateBlobBytes;
  }
  if (page.isNotEmpty) {
    yield page;
  }
}
