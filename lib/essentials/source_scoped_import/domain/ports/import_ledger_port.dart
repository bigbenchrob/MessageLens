import 'dart:typed_data';

abstract interface class ImportLedger {
  Future<int> insertImportBatch({
    required int sourceId,
    required String startedAtUtc,
  });

  Future<int> getOrCreateSource({
    required String sourceKey,
    required String sourceKind,
    String? sourceLabel,
  });

  Future<int?> sourceIdForKey(String sourceKey);

  Future<SourceScopedImportSourceDeletionResult> deleteRowsForSource({
    required int sourceId,
  });

  Future<int?> maxMessageSourceRowIdForSource(int sourceId);

  Future<int> messageCountForSource(int sourceId);

  Future<ImportLedgerMessageStatusSnapshot> messageStatusForSource(
    int sourceId,
  );

  Future<ImportLedgerProjectionStatusSnapshot> projectionStatusSnapshot();

  Future<int?> maxHandleSourceRowIdForSource(int sourceId);

  Future<int?> maxAttachmentSourceRowIdForSource(int sourceId);

  Future<ImportLedgerMessageTextWindow> messageTextEnrichmentWindow({
    int? sourceId,
    int? startedAfterSourceRowId,
  });

  Future<List<ImportLedgerMessageTextCandidate>> readMessageTextEnrichmentPage({
    required int afterSsId,
    required int throughSsId,
    required int limit,
    int? sourceId,
    int? startedAfterSourceRowId,
  });

  Future<List<Map<String, Object?>>> queryTable(
    String table, {
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  });

  Future<T> writeTransaction<T>(
    Future<T> Function(ImportLedgerWriteTransaction txn) action,
  );
}

abstract interface class ImportLedgerWriteTransaction {
  Future<int> insertIgnore(String table, Map<String, Object?> values);

  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
  });
}

final class ImportLedgerMessageTextCandidate {
  const ImportLedgerMessageTextCandidate({
    required this.ssId,
    required this.sourceRowId,
    required this.attributedBodyBlob,
  });

  final int ssId;
  final int sourceRowId;
  final Uint8List attributedBodyBlob;
}

final class ImportLedgerMessageTextWindow {
  const ImportLedgerMessageTextWindow({
    required this.candidateCount,
    required this.highWaterSsId,
  });

  final int candidateCount;
  final int? highWaterSsId;
}

final class ImportLedgerMessageStatusSnapshot {
  const ImportLedgerMessageStatusSnapshot({
    required this.count,
    required this.maxSourceRowId,
    required this.needingEnrichmentCount,
    required this.withoutTextCount,
  });

  final int count;
  final int maxSourceRowId;
  final int needingEnrichmentCount;
  final int withoutTextCount;
}

final class ImportLedgerProjectionStatusSnapshot {
  const ImportLedgerProjectionStatusSnapshot({
    required this.chatCount,
    required this.handleCount,
    required this.chatToMessageEdgeCount,
    required this.chatToHandleEdgeCount,
    required this.attachmentCount,
    required this.messageToAttachmentEdgeCount,
  });

  final int chatCount;
  final int handleCount;
  final int chatToMessageEdgeCount;
  final int chatToHandleEdgeCount;
  final int attachmentCount;
  final int messageToAttachmentEdgeCount;
}

final class SourceScopedImportSourceDeletionResult {
  const SourceScopedImportSourceDeletionResult({
    required this.sourceId,
    required this.messages,
    required this.chats,
    required this.handles,
    required this.contacts,
    required this.contactChannels,
    required this.attachments,
    required this.chatMessageEdges,
    required this.chatHandleEdges,
    required this.messageAttachmentEdges,
    required this.importBatches,
  });

  final int sourceId;
  final int messages;
  final int chats;
  final int handles;
  final int contacts;
  final int contactChannels;
  final int attachments;
  final int chatMessageEdges;
  final int chatHandleEdges;
  final int messageAttachmentEdges;
  final int importBatches;

  int get deletedSourceFactCount {
    return messages +
        chats +
        handles +
        contacts +
        contactChannels +
        attachments;
  }

  int get deletedTopologyEdgeCount {
    return chatMessageEdges + chatHandleEdges + messageAttachmentEdges;
  }
}
