import '../../domain/source_scoped_row_key.dart';

/// Raw source-owned identity selected from one chat-message join row.
///
/// This immutable input has no source database, ledger, transaction, progress,
/// or endpoint-existence capability. The importer remains responsible for
/// proving that both referenced source endpoints exist before projection.
final class ChatMessageRelationshipSourceProjectionInput {
  const ChatMessageRelationshipSourceProjectionInput({
    required this.sourceRowId,
    required this.sourceChatRowId,
    required this.sourceMessageRowId,
  });

  factory ChatMessageRelationshipSourceProjectionInput.fromSourceRow(
    Map<String, Object?> row,
  ) {
    return ChatMessageRelationshipSourceProjectionInput(
      sourceRowId: row['source_rowid'],
      sourceChatRowId: row['chat_id'],
      sourceMessageRowId: row['message_id'],
    );
  }

  final Object? sourceRowId;
  final Object? sourceChatRowId;
  final Object? sourceMessageRowId;

  int get requiredSourceRowId {
    return _requiredInt(sourceRowId, 'source_rowid');
  }

  int? get nullableSourceChatRowId => _nullableInt(sourceChatRowId);

  int? get nullableSourceMessageRowId => _nullableInt(sourceMessageRowId);
}

/// The complete canonical import-ledger row for one admitted source join.
final class ProjectedSourceChatMessageRelationship {
  ProjectedSourceChatMessageRelationship({
    required this.sourceRowId,
    required this.sourceChatRowId,
    required this.sourceMessageRowId,
    required Map<String, Object?> ledgerValues,
  }) : ledgerValues = Map<String, Object?>.unmodifiable(ledgerValues);

  final int sourceRowId;
  final int sourceChatRowId;
  final int sourceMessageRowId;
  final Map<String, Object?> ledgerValues;
}

ProjectedSourceChatMessageRelationship projectSourceChatMessageRelationship(
  ChatMessageRelationshipSourceProjectionInput input,
  int sourceId,
) {
  final sourceRowId = input.requiredSourceRowId;
  final sourceChatRowId = _requiredInt(input.sourceChatRowId, 'chat_id');
  final sourceMessageRowId = _requiredInt(
    input.sourceMessageRowId,
    'message_id',
  );

  return ProjectedSourceChatMessageRelationship(
    sourceRowId: sourceRowId,
    sourceChatRowId: sourceChatRowId,
    sourceMessageRowId: sourceMessageRowId,
    ledgerValues: <String, Object?>{
      'ss_id': SourceScopedRowKey.pack(
        sourceId: sourceId,
        sourceRowId: sourceRowId,
      ),
      'source_id': sourceId,
      'source_rowid': sourceRowId,
      'source_chat_rowid': sourceChatRowId,
      'source_message_rowid': sourceMessageRowId,
      'chat_ss_id': SourceScopedRowKey.pack(
        sourceId: sourceId,
        sourceRowId: sourceChatRowId,
      ),
      'message_ss_id': SourceScopedRowKey.pack(
        sourceId: sourceId,
        sourceRowId: sourceMessageRowId,
      ),
    },
  );
}

int _requiredInt(Object? value, String field) {
  final coerced = _nullableInt(value);
  if (coerced != null) {
    return coerced;
  }
  throw StateError('chat_message_join.$field is required');
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
