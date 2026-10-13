import '../../domain/source_scoped_row_key.dart';

/// Raw source-owned endpoint identity from one chat-handle join row.
///
/// This immutable input has no raw join identity, endpoint-existence evidence,
/// source database, ledger, transaction, progress, or lifecycle capability.
/// The importer proves endpoint existence before invoking the projection.
final class ChatHandleRelationshipSourceProjectionInput {
  const ChatHandleRelationshipSourceProjectionInput({
    required this.sourceChatRowId,
    required this.sourceHandleRowId,
  });

  factory ChatHandleRelationshipSourceProjectionInput.fromSourceRow(
    Map<String, Object?> row,
  ) {
    return ChatHandleRelationshipSourceProjectionInput(
      sourceChatRowId: row['chat_id'],
      sourceHandleRowId: row['handle_id'],
    );
  }

  final Object? sourceChatRowId;
  final Object? sourceHandleRowId;

  int? get nullableSourceChatRowId => _nullableInt(sourceChatRowId);

  int? get nullableSourceHandleRowId => _nullableInt(sourceHandleRowId);
}

/// The complete canonical import-ledger row for one admitted source join.
final class ProjectedSourceChatHandleRelationship {
  ProjectedSourceChatHandleRelationship({
    required this.sourceChatRowId,
    required this.sourceHandleRowId,
    required Map<String, Object?> ledgerValues,
  }) : ledgerValues = Map<String, Object?>.unmodifiable(ledgerValues);

  final int sourceChatRowId;
  final int sourceHandleRowId;
  final Map<String, Object?> ledgerValues;
}

ProjectedSourceChatHandleRelationship projectSourceChatHandleRelationship(
  ChatHandleRelationshipSourceProjectionInput input,
  int sourceId,
  int batchId,
) {
  final sourceChatRowId = _requiredInt(input.sourceChatRowId, 'chat_id');
  final sourceHandleRowId = _requiredInt(input.sourceHandleRowId, 'handle_id');

  return ProjectedSourceChatHandleRelationship(
    sourceChatRowId: sourceChatRowId,
    sourceHandleRowId: sourceHandleRowId,
    ledgerValues: <String, Object?>{
      'source_id': sourceId,
      'source_chat_rowid': sourceChatRowId,
      'source_handle_rowid': sourceHandleRowId,
      'chat_ss_id': SourceScopedRowKey.pack(
        sourceId: sourceId,
        sourceRowId: sourceChatRowId,
      ),
      'handle_ss_id': SourceScopedRowKey.pack(
        sourceId: sourceId,
        sourceRowId: sourceHandleRowId,
      ),
      'batch_id': batchId,
    },
  );
}

int _requiredInt(Object? value, String field) {
  final coerced = _nullableInt(value);
  if (coerced != null) {
    return coerced;
  }
  throw StateError('chat_handle_join.$field is required');
}

int? _nullableInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is double) {
    return value.round();
  }
  return null;
}
