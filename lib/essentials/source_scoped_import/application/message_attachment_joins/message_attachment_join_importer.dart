import '../../domain/known_sources.dart';
import '../../domain/ports/import_ledger_port.dart';
import '../../domain/ports/source_database_port.dart';
import '../../domain/source_import_anomaly_counts.dart';
import '../source_import_work_progress.dart';
import 'message_attachment_relationship_source_projection.dart';

class MessageAttachmentJoinImportResult {
  const MessageAttachmentJoinImportResult({
    required this.examinedJoinCount,
    required this.insertedJoinCount,
    this.omittedJoinCount = 0,
  });

  final int examinedJoinCount;
  final int insertedJoinCount;
  final int omittedJoinCount;
}

class MessageAttachmentJoinImporter {
  const MessageAttachmentJoinImporter({
    required this.chatDbPath,
    required this.importLedger,
    required this.sourceDatabaseOpener,
    this.sourceId = liveChatDbSourceId,
  });

  final String chatDbPath;
  final ImportLedger importLedger;
  final SourceDatabaseOpener sourceDatabaseOpener;
  final int sourceId;

  Future<MessageAttachmentJoinImportResult> importJoins({
    SourceImportWorkObserver? onProgress,
  }) async {
    return _importJoinsWhere(
      whereClause: null,
      whereArgs: const <Object?>[],
      onProgress: onProgress,
    );
  }

  Future<MessageAttachmentJoinImportResult> importJoinsAfterSourceMessageRowId({
    required int startedAfterSourceRowId,
    SourceImportWorkObserver? onProgress,
  }) {
    return _importJoinsWhere(
      whereClause: 'WHERE maj.message_id > ?',
      whereArgs: <Object?>[startedAfterSourceRowId],
      onProgress: onProgress,
    );
  }

  Future<MessageAttachmentJoinImportResult> _importJoinsWhere({
    required String? whereClause,
    required List<Object?> whereArgs,
    required SourceImportWorkObserver? onProgress,
  }) async {
    final sourceDb = await sourceDatabaseOpener.openReadOnly(chatDbPath);

    try {
      final rows = await sourceDb.rawQuery(
        'SELECT maj.ROWID AS source_rowid, maj.message_id, '
        'maj.attachment_id, m.ROWID AS existing_message_rowid, '
        'a.ROWID AS existing_attachment_rowid '
        'FROM message_attachment_join maj '
        'LEFT JOIN message m ON m.ROWID = maj.message_id '
        'LEFT JOIN attachment a ON a.ROWID = maj.attachment_id '
        '${whereClause ?? ''} '
        'ORDER BY message_id ASC, attachment_id ASC',
        whereArgs,
      );

      if (rows.isEmpty) {
        publishSourceImportProgress(
          observer: onProgress,
          unit: SourceImportWorkUnit.messageAttachmentRelationships,
          completedWorkCount: 0,
          totalWorkCount: 0,
        );
        return const MessageAttachmentJoinImportResult(
          examinedJoinCount: 0,
          insertedJoinCount: 0,
        );
      }

      final batchId = await importLedger.insertImportBatch(
        sourceId: sourceId,
        startedAtUtc: DateTime.now().toUtc().toIso8601String(),
      );

      var insertedJoinCount = 0;
      var completedJoinCount = 0;
      var omittedJoinCount = 0;
      publishSourceImportProgress(
        observer: onProgress,
        unit: SourceImportWorkUnit.messageAttachmentRelationships,
        completedWorkCount: 0,
        totalWorkCount: rows.length,
      );
      await importLedger.writeTransaction((txn) async {
        for (final row in rows) {
          final sourceRowId = _requiredInt(row, 'source_rowid');
          final projectionInput =
              MessageAttachmentRelationshipSourceProjectionInput.fromSourceRow(
                row,
              );
          final sourceMessageRowId = projectionInput.nullableSourceMessageRowId;
          final sourceAttachmentRowId =
              projectionInput.nullableSourceAttachmentRowId;
          final hasEndpoints =
              sourceMessageRowId != null &&
              sourceAttachmentRowId != null &&
              _nullableEndpointRowId(row['existing_message_rowid']) != null &&
              _nullableEndpointRowId(row['existing_attachment_rowid']) != null;
          if (!hasEndpoints) {
            omittedJoinCount += 1;
            completedJoinCount += 1;
            publishSourceImportProgress(
              observer: onProgress,
              unit: SourceImportWorkUnit.messageAttachmentRelationships,
              completedWorkCount: completedJoinCount,
              totalWorkCount: rows.length,
              lastCompletedSourceRowId: sourceRowId,
              anomalyCounts: SourceImportAnomalyCounts(
                omittedMessageAttachmentRelationshipCount: omittedJoinCount,
              ),
            );
            continue;
          }
          final projected = projectSourceMessageAttachmentRelationship(
            projectionInput,
            sourceId,
            batchId,
          );
          final insertedId = await txn.insertIgnore(
            'message_to_attachment',
            projected.ledgerValues,
          );

          if (insertedId != 0) {
            insertedJoinCount += 1;
          }
          completedJoinCount += 1;
          publishSourceImportProgress(
            observer: onProgress,
            unit: SourceImportWorkUnit.messageAttachmentRelationships,
            completedWorkCount: completedJoinCount,
            totalWorkCount: rows.length,
            lastCompletedSourceRowId: sourceRowId,
            anomalyCounts: SourceImportAnomalyCounts(
              omittedMessageAttachmentRelationshipCount: omittedJoinCount,
            ),
          );
        }
      });

      return MessageAttachmentJoinImportResult(
        examinedJoinCount: rows.length,
        insertedJoinCount: insertedJoinCount,
        omittedJoinCount: omittedJoinCount,
      );
    } finally {
      await sourceDb.close();
    }
  }

  static int _requiredInt(Map<String, Object?> row, String field) {
    final value = _nullableEndpointRowId(row[field]);
    if (value != null) {
      return value;
    }
    throw StateError('message_attachment_join.$field is required');
  }

  static int? _nullableEndpointRowId(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    return null;
  }
}
