import '../../domain/known_sources.dart';
import '../../domain/ports/import_ledger_port.dart';
import '../../domain/ports/source_database_port.dart';
import '../../domain/source_import_anomaly_counts.dart';
import '../source_import_work_progress.dart';
import 'attachment_source_projection.dart';

class AttachmentImportResult {
  const AttachmentImportResult({
    required this.startedAfterSourceRowId,
    required this.examinedAttachmentCount,
    required this.insertedAttachmentCount,
    required this.lastImportedSourceRowId,
    this.anomalyCounts = SourceImportAnomalyCounts.empty,
  });

  final int startedAfterSourceRowId;
  final int examinedAttachmentCount;
  final int insertedAttachmentCount;
  final int? lastImportedSourceRowId;
  final SourceImportAnomalyCounts anomalyCounts;
}

class AttachmentImporter {
  const AttachmentImporter({
    required this.chatDbPath,
    required this.importLedger,
    required this.sourceDatabaseOpener,
    this.sourceId = liveChatDbSourceId,
  });

  final String chatDbPath;
  final ImportLedger importLedger;
  final SourceDatabaseOpener sourceDatabaseOpener;
  final int sourceId;

  Future<AttachmentImportResult> importAttachments({
    SourceImportWorkObserver? onProgress,
  }) async {
    final startedAfterSourceRowId =
        await importLedger.maxAttachmentSourceRowIdForSource(sourceId) ?? 0;

    final sourceDb = await sourceDatabaseOpener.openReadOnly(chatDbPath);

    try {
      final rows = await sourceDb.rawQuery(
        'SELECT ROWID AS source_rowid, * FROM attachment '
        'WHERE ROWID > ? ORDER BY ROWID ASC',
        <Object?>[startedAfterSourceRowId],
      );

      if (rows.isEmpty) {
        publishSourceImportProgress(
          observer: onProgress,
          unit: SourceImportWorkUnit.attachments,
          completedWorkCount: 0,
          totalWorkCount: 0,
        );
        return AttachmentImportResult(
          startedAfterSourceRowId: startedAfterSourceRowId,
          examinedAttachmentCount: 0,
          insertedAttachmentCount: 0,
          lastImportedSourceRowId: null,
        );
      }

      final batchId = await importLedger.insertImportBatch(
        sourceId: sourceId,
        startedAtUtc: DateTime.now().toUtc().toIso8601String(),
      );

      var insertedAttachmentCount = 0;
      var completedAttachmentCount = 0;
      var metadataDegradedCount = 0;
      int? lastImportedSourceRowId;
      publishSourceImportProgress(
        observer: onProgress,
        unit: SourceImportWorkUnit.attachments,
        completedWorkCount: 0,
        totalWorkCount: rows.length,
      );
      await importLedger.writeTransaction((txn) async {
        for (final row in rows) {
          final projection = projectSourceAttachment(
            input: AttachmentSourceProjectionInput.fromSourceRow(row),
            sourceId: sourceId,
            batchId: batchId,
          );
          final sourceRowId = projection.sourceRowId;
          lastImportedSourceRowId = sourceRowId;
          if (projection.metadataDegraded) {
            metadataDegradedCount += 1;
          }
          final insertedId = await txn.insertIgnore(
            'attachments',
            projection.ledgerValues,
          );

          if (insertedId != 0) {
            insertedAttachmentCount += 1;
          }
          completedAttachmentCount += 1;
          publishSourceImportProgress(
            observer: onProgress,
            unit: SourceImportWorkUnit.attachments,
            completedWorkCount: completedAttachmentCount,
            totalWorkCount: rows.length,
            lastCompletedSourceRowId: sourceRowId,
            anomalyCounts: SourceImportAnomalyCounts(
              attachmentMetadataDegradedCount: metadataDegradedCount,
            ),
          );
        }
      });

      return AttachmentImportResult(
        startedAfterSourceRowId: startedAfterSourceRowId,
        examinedAttachmentCount: rows.length,
        insertedAttachmentCount: insertedAttachmentCount,
        lastImportedSourceRowId: lastImportedSourceRowId,
        anomalyCounts: SourceImportAnomalyCounts(
          attachmentMetadataDegradedCount: metadataDegradedCount,
        ),
      );
    } finally {
      await sourceDb.close();
    }
  }
}
