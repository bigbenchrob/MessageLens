import '../../domain/known_sources.dart';
import '../../domain/ports/import_ledger_port.dart';
import '../../domain/ports/source_database_port.dart';
import '../source_import_work_progress.dart';
import 'chat_source_projection.dart';

class ChatImportResult {
  const ChatImportResult({
    required this.examinedChatCount,
    required this.insertedChatCount,
  });

  final int examinedChatCount;
  final int insertedChatCount;
}

class ChatImporter {
  const ChatImporter({
    required this.chatDbPath,
    required this.importLedger,
    required this.sourceDatabaseOpener,
    this.sourceId = liveChatDbSourceId,
  });

  final String chatDbPath;
  final ImportLedger importLedger;
  final SourceDatabaseOpener sourceDatabaseOpener;
  final int sourceId;

  Future<ChatImportResult> importChats({
    SourceImportWorkObserver? onProgress,
  }) async {
    final sourceDb = await sourceDatabaseOpener.openReadOnly(chatDbPath);

    try {
      final rows = await sourceDb.rawQuery(
        'SELECT ROWID AS source_rowid, * FROM chat ORDER BY ROWID ASC',
      );
      final batchId = await importLedger.insertImportBatch(
        sourceId: sourceId,
        startedAtUtc: DateTime.now().toUtc().toIso8601String(),
      );

      var insertedChatCount = 0;
      var completedChatCount = 0;
      publishSourceImportProgress(
        observer: onProgress,
        unit: SourceImportWorkUnit.chats,
        completedWorkCount: 0,
        totalWorkCount: rows.length,
      );
      await importLedger.writeTransaction((txn) async {
        for (final row in rows) {
          int? sourceRowId;
          int insertedId;
          try {
            final input = ChatSourceProjectionInput.fromSourceRow(row);
            sourceRowId = input.requiredSourceRowId;
            final projected = projectSourceChat(
              input: input,
              sourceId: sourceId,
              batchId: batchId,
            );
            insertedId = await txn.insertIgnore(
              'chats',
              projected.ledgerValues,
            );
          } on StateError catch (error) {
            throw SourceImportRecordException(
              unit: SourceImportWorkUnit.chats,
              sourceRowId: sourceRowId,
              reason: error.message,
            );
          }

          if (insertedId != 0) {
            insertedChatCount += 1;
          }
          completedChatCount += 1;
          publishSourceImportProgress(
            observer: onProgress,
            unit: SourceImportWorkUnit.chats,
            completedWorkCount: completedChatCount,
            totalWorkCount: rows.length,
            lastCompletedSourceRowId: sourceRowId,
          );
        }
      });

      return ChatImportResult(
        examinedChatCount: rows.length,
        insertedChatCount: insertedChatCount,
      );
    } finally {
      await sourceDb.close();
    }
  }
}
