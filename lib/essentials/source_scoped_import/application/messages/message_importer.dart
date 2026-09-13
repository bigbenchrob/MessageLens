import 'dart:typed_data';

import '../../../../core/util/date_converter.dart';
import '../../domain/apple_associated_message_reference.dart';
import '../../domain/known_sources.dart';
import '../../domain/ports/import_ledger_port.dart';
import '../../domain/ports/source_database_port.dart';
import '../../domain/source_import_anomaly_counts.dart';
import '../../domain/source_scoped_row_key.dart';
import '../source_import_page_metric.dart';
import '../source_import_work_progress.dart';

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
          final associatedTargetGuids = <String>{
            for (final row in rows)
              if (_nullableInt(row, 'associated_message_type') != null)
                if (_nullableString(row, 'associated_message_guid')
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
            for (final row in rows) {
              int? sourceRowId;
              try {
                sourceRowId = _requiredInt(row, 'source_rowid');
                pageLastSourceRowId = sourceRowId;
                final attributedBody = _nullableBlob(row, 'attributedBody');
                if (attributedBody != null) {
                  pageBlobBytes += attributedBody.length;
                  if (attributedBody.length > maximumPageBlobBytes) {
                    maximumPageBlobBytes = attributedBody.length;
                  }
                }

                final dateUtc = DateConverter.appleToIsoString(row['date']);
                if (dateUtc == null) {
                  pageMessageTimestampUnavailableCount += 1;
                }
                if (_nullableInt(row, 'has_chat_relationship') != 1) {
                  pageRecoveredUnlinkedMessageCount += 1;
                }
                final associatedMessageReference = _nullableString(
                  row,
                  'associated_message_guid',
                );
                if (_nullableInt(row, 'associated_message_type') != null &&
                    associatedMessageReference != null &&
                    !resolvedAssociatedTargetGuids.contains(
                      appleAssociatedMessageTargetGuid(
                        associatedMessageReference,
                      ),
                    )) {
                  pageUnresolvedReactionTargetCount += 1;
                }

                final insertedId = await txn.insertIgnore('messages', <
                  String,
                  Object?
                >{
                  'ss_id': SourceScopedRowKey.pack(
                    sourceId: sourceId,
                    sourceRowId: sourceRowId,
                  ),
                  'source_id': sourceId,
                  'source_rowid': sourceRowId,
                  'guid': _requiredString(row, 'guid'),
                  'sender_handle_ss_id': _senderHandleSsId(row),
                  'is_from_me': _boolInt(row, 'is_from_me'),
                  'date_utc': dateUtc,
                  'date_read_utc': DateConverter.appleToIsoString(
                    row['date_read'],
                  ),
                  'date_delivered_utc': DateConverter.appleToIsoString(
                    row['date_delivered'],
                  ),
                  'text': _nullableString(row, 'text'),
                  'attributed_body_blob': attributedBody,
                  'associated_message_guid': associatedMessageReference,
                  'raw_item_type': _nullableInt(row, 'item_type'),
                  'raw_associated_message_type': _nullableInt(
                    row,
                    'associated_message_type',
                  ),
                  'thread_originator_guid': _nullableString(
                    row,
                    'thread_originator_guid',
                  ),
                  'error_code': _nullableInt(row, 'error'),
                  'is_system_message': _boolIntOrZero(row, 'is_system_message'),
                  'has_attributed_body_source': attributedBody == null ? 0 : 1,
                  'has_message_summary_info': _boolIntOrZero(
                    row,
                    'has_message_summary_info',
                  ),
                  'has_payload_data_source': _boolIntOrZero(
                    row,
                    'has_payload_data_source',
                  ),
                  'batch_id': batchId,
                });

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

  int? _senderHandleSsId(Map<String, Object?> row) {
    final handleId = _nullableInt(row, 'handle_id');
    if (handleId == null || handleId <= 0) {
      return null;
    }
    return SourceScopedRowKey.pack(sourceId: sourceId, sourceRowId: handleId);
  }

  static int _boolInt(Map<String, Object?> row, String field) {
    final value = _requiredInt(row, field);
    return value == 0 ? 0 : 1;
  }

  static int _boolIntOrZero(Map<String, Object?> row, String field) {
    final value = _nullableInt(row, field);
    if (value == null) {
      return 0;
    }
    return value == 0 ? 0 : 1;
  }

  static String _requiredString(Map<String, Object?> row, String field) {
    final value = row[field];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    throw StateError('message.$field is required');
  }

  static int _requiredInt(Map<String, Object?> row, String field) {
    final value = _nullableInt(row, field);
    if (value == null) {
      throw StateError('message.$field is required');
    }
    return value;
  }

  static int? _nullableInt(Map<String, Object?> row, String field) {
    final value = row[field];
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    return null;
  }

  static String? _nullableString(Map<String, Object?> row, String field) {
    final value = row[field];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    return null;
  }

  static Uint8List? _nullableBlob(Map<String, Object?> row, String field) {
    final value = row[field];
    if (value is Uint8List) {
      return value;
    }
    if (value is List<int>) {
      return Uint8List.fromList(value);
    }
    return null;
  }
}
