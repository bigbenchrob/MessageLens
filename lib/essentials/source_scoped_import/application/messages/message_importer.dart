import '../../domain/apple_associated_message_reference.dart';
import '../../domain/known_sources.dart';
import '../../domain/ports/import_ledger_port.dart';
import '../../domain/ports/source_database_port.dart';
import '../../domain/source_import_anomaly_counts.dart';
import '../source_import_page_metric.dart';
import '../source_import_work_progress.dart';
import 'message_source_projection.dart';

const int defaultMessageImportPageSize = 500;

class MessageImportResult {
  const MessageImportResult({
    required this.startedAfterSourceRowId,
    required this.insertedMessageCount,
    required this.lastImportedSourceRowId,
    this.anomalyCounts = SourceImportAnomalyCounts.empty,
  });

  final int startedAfterSourceRowId;
  final int insertedMessageCount;
  final int? lastImportedSourceRowId;
  final SourceImportAnomalyCounts anomalyCounts;
}

enum MessageImportPageBoundary { beforePersistence }

final class MessageImportPageBoundaryObservation {
  const MessageImportPageBoundaryObservation({
    required this.boundary,
    required this.pageOrdinal,
    required this.pageRowCount,
    required this.cumulativeCommittedCount,
  });

  final MessageImportPageBoundary boundary;
  final int pageOrdinal;
  final int pageRowCount;
  final int cumulativeCommittedCount;
}

typedef MessageImportPageBoundaryObserver =
    void Function(MessageImportPageBoundaryObservation observation);

class MessageImporter {
  const MessageImporter({
    required this.chatDbPath,
    required this.importLedger,
    required this.sourceDatabaseOpener,
    this.sourceId = liveChatDbSourceId,
    this.pageSize = defaultMessageImportPageSize,
    this.onPageMetric,
    this.onPageBoundary,
  });

  final String chatDbPath;
  final ImportLedger importLedger;
  final SourceDatabaseOpener sourceDatabaseOpener;
  final int sourceId;
  final int pageSize;
  final SourceImportPageMetricObserver? onPageMetric;
  final MessageImportPageBoundaryObserver? onPageBoundary;

  Future<MessageImportResult> importNewMessages({
    SourceImportWorkObserver? onProgress,
  }) async {
    if (pageSize <= 0) {
      throw ArgumentError.value(pageSize, 'pageSize', 'must be greater than 0');
    }
    final startedAfterSourceRowId =
        await importLedger.maxMessageSourceRowIdForSource(sourceId) ?? 0;

    final sourceDb = await sourceDatabaseOpener.openReadOnly(chatDbPath);

    try {
      final window = await sourceDb.messageImportWindowAfter(
        startedAfterSourceRowId,
      );
      final runHighWaterSourceRowId = window.highWaterSourceRowId;
      final totalMessageCount = window.totalRowCount;
      if (totalMessageCount == 0) {
        publishSourceImportProgress(
          observer: onProgress,
          unit: SourceImportWorkUnit.messages,
          completedWorkCount: 0,
          totalWorkCount: 0,
        );
        return MessageImportResult(
          startedAfterSourceRowId: startedAfterSourceRowId,
          insertedMessageCount: 0,
          lastImportedSourceRowId: null,
        );
      }
      if (runHighWaterSourceRowId == null) {
        throw const SourceImportSystemicException(
          unit: SourceImportWorkUnit.messages,
          failureCode: 'source_message_window_invalid',
          reason: 'The non-empty source message window has no high-water row.',
        );
      }

      final batchId = await importLedger.insertImportBatch(
        sourceId: sourceId,
        startedAtUtc: DateTime.now().toUtc().toIso8601String(),
      );

      var insertedMessageCount = 0;
      var completedMessageCount = 0;
      var messageTimestampUnavailableCount = 0;
      var recoveredUnlinkedMessageCount = 0;
      var unresolvedReactionTargetCount = 0;
      int? lastImportedSourceRowId;
      var pageCursorSourceRowId = startedAfterSourceRowId;
      var pageOrdinal = 0;

      publishSourceImportProgress(
        observer: onProgress,
        unit: SourceImportWorkUnit.messages,
        completedWorkCount: 0,
        totalWorkCount: totalMessageCount,
      );

      while (pageCursorSourceRowId < runHighWaterSourceRowId) {
        pageOrdinal += 1;
        final stopwatch = Stopwatch()..start();
        var pageRowCount = 0;
        var pageBlobBytes = 0;
        var maximumPageBlobBytes = 0;
        try {
          final rows = await sourceDb.readMessageImportPage(
            afterSourceRowId: pageCursorSourceRowId,
            throughSourceRowId: runHighWaterSourceRowId,
            limit: pageSize,
          );
          if (rows.isEmpty) {
            throw const SourceImportSystemicException(
              unit: SourceImportWorkUnit.messages,
              failureCode: 'source_message_window_changed',
              reason: 'The frozen source message window changed during import.',
            );
          }
          pageRowCount = rows.length;
          final projectionInputs = rows
              .map(MessageSourceProjectionInput.fromSourceRow)
              .toList(growable: false);
          final associatedTargetGuids = <String>{
            for (final input in projectionInputs)
              if (input.nullableAssociatedMessageType != null)
                if (input.nullableAssociatedMessageGuid
                    case final String reference)
                  appleAssociatedMessageTargetGuid(reference),
          };
          final resolvedAssociatedTargetGuids = await sourceDb
              .findExistingMessageGuids(associatedTargetGuids);

          var pageInsertedMessageCount = 0;
          var pageMessageTimestampUnavailableCount = 0;
          var pageRecoveredUnlinkedMessageCount = 0;
          var pageUnresolvedReactionTargetCount = 0;
          int? pageLastSourceRowId;
          onPageBoundary?.call(
            MessageImportPageBoundaryObservation(
              boundary: MessageImportPageBoundary.beforePersistence,
              pageOrdinal: pageOrdinal,
              pageRowCount: rows.length,
              cumulativeCommittedCount: completedMessageCount,
            ),
          );
          await importLedger.writeTransaction((txn) async {
            for (final input in projectionInputs) {
              int? sourceRowId;
              try {
                sourceRowId = input.requiredSourceRowId;
                pageLastSourceRowId = sourceRowId;
                final attributedBody = input.nullableAttributedBody;
                if (attributedBody != null) {
                  pageBlobBytes += attributedBody.length;
                  if (attributedBody.length > maximumPageBlobBytes) {
                    maximumPageBlobBytes = attributedBody.length;
                  }
                }

                final dateUtc = input.dateUtc;
                if (dateUtc == null) {
                  pageMessageTimestampUnavailableCount += 1;
                }
                if (input.nullableHasChatRelationship != 1) {
                  pageRecoveredUnlinkedMessageCount += 1;
                }
                final associatedMessageReference =
                    input.nullableAssociatedMessageGuid;
                if (input.nullableAssociatedMessageType != null &&
                    associatedMessageReference != null &&
                    !resolvedAssociatedTargetGuids.contains(
                      appleAssociatedMessageTargetGuid(
                        associatedMessageReference,
                      ),
                    )) {
                  pageUnresolvedReactionTargetCount += 1;
                }

                final projection = projectSourceMessage(
                  input: input,
                  sourceId: sourceId,
                  batchId: batchId,
                );
                final insertedId = await txn.insertIgnore(
                  'messages',
                  projection.ledgerValues,
                );

                if (insertedId != 0) {
                  pageInsertedMessageCount += 1;
                }
              } on StateError catch (error) {
                throw SourceImportRecordException(
                  unit: SourceImportWorkUnit.messages,
                  sourceRowId: sourceRowId,
                  reason: error.message,
                );
              }
            }
          });

          final durablePageLastSourceRowId = pageLastSourceRowId;
          if (durablePageLastSourceRowId == null) {
            throw const SourceImportSystemicException(
              unit: SourceImportWorkUnit.messages,
              failureCode: 'source_message_page_invalid',
              reason: 'A non-empty source message page has no final row.',
            );
          }
          pageCursorSourceRowId = durablePageLastSourceRowId;
          lastImportedSourceRowId = durablePageLastSourceRowId;
          insertedMessageCount += pageInsertedMessageCount;
          completedMessageCount += rows.length;
          messageTimestampUnavailableCount +=
              pageMessageTimestampUnavailableCount;
          recoveredUnlinkedMessageCount += pageRecoveredUnlinkedMessageCount;
          unresolvedReactionTargetCount += pageUnresolvedReactionTargetCount;
          stopwatch.stop();
          onPageMetric?.call(
            SourceImportPageMetric(
              stage: SourceImportPageStage.messages,
              outcome: SourceImportPageOutcome.completed,
              pageOrdinal: pageOrdinal,
              pageRowCount: pageRowCount,
              cumulativeCompletedCount: completedMessageCount,
              totalWorkCount: totalMessageCount,
              totalBlobBytes: pageBlobBytes,
              maximumBlobBytes: maximumPageBlobBytes,
              elapsedMilliseconds: stopwatch.elapsedMilliseconds,
            ),
          );
          publishSourceImportProgress(
            observer: onProgress,
            unit: SourceImportWorkUnit.messages,
            completedWorkCount: completedMessageCount,
            totalWorkCount: totalMessageCount,
            lastCompletedSourceRowId: durablePageLastSourceRowId,
            anomalyCounts: SourceImportAnomalyCounts(
              messageTimestampUnavailableCount:
                  messageTimestampUnavailableCount,
              recoveredUnlinkedMessageCount: recoveredUnlinkedMessageCount,
              unresolvedReactionTargetCount: unresolvedReactionTargetCount,
            ),
          );
        } catch (error, stackTrace) {
          stopwatch.stop();
          onPageMetric?.call(
            SourceImportPageMetric(
              stage: SourceImportPageStage.messages,
              outcome: SourceImportPageOutcome.failed,
              pageOrdinal: pageOrdinal,
              pageRowCount: pageRowCount,
              cumulativeCompletedCount: completedMessageCount,
              totalWorkCount: totalMessageCount,
              totalBlobBytes: pageBlobBytes,
              maximumBlobBytes: maximumPageBlobBytes,
              elapsedMilliseconds: stopwatch.elapsedMilliseconds,
            ),
          );
          Error.throwWithStackTrace(error, stackTrace);
        }
        await Future<void>.delayed(Duration.zero);
      }

      if (completedMessageCount != totalMessageCount) {
        throw SourceImportSystemicException(
          unit: SourceImportWorkUnit.messages,
          failureCode: 'source_message_window_count_changed',
          reason:
              'Expected $totalMessageCount source messages but completed '
              '$completedMessageCount.',
        );
      }

      return MessageImportResult(
        startedAfterSourceRowId: startedAfterSourceRowId,
        insertedMessageCount: insertedMessageCount,
        lastImportedSourceRowId: lastImportedSourceRowId,
        anomalyCounts: SourceImportAnomalyCounts(
          messageTimestampUnavailableCount: messageTimestampUnavailableCount,
          recoveredUnlinkedMessageCount: recoveredUnlinkedMessageCount,
          unresolvedReactionTargetCount: unresolvedReactionTargetCount,
        ),
      );
    } finally {
      await sourceDb.close();
    }
  }
}
