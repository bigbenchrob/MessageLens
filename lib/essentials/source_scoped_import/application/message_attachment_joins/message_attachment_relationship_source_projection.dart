import '../../domain/source_scoped_row_key.dart';

/// Raw source-owned endpoint identity from one message-attachment join row.
///
/// This immutable input has no raw join identity, endpoint-existence evidence,
/// source database, ledger, transaction, progress, or lifecycle capability.
/// The importer proves endpoint existence before invoking the projection.
final class MessageAttachmentRelationshipSourceProjectionInput {
  const MessageAttachmentRelationshipSourceProjectionInput({
    required this.sourceMessageRowId,
    required this.sourceAttachmentRowId,
  });

  factory MessageAttachmentRelationshipSourceProjectionInput.fromSourceRow(
    Map<String, Object?> row,
  ) {
    return MessageAttachmentRelationshipSourceProjectionInput(
      sourceMessageRowId: row['message_id'],
      sourceAttachmentRowId: row['attachment_id'],
    );
  }

  final Object? sourceMessageRowId;
  final Object? sourceAttachmentRowId;

  int? get nullableSourceMessageRowId => _nullableInt(sourceMessageRowId);

  int? get nullableSourceAttachmentRowId => _nullableInt(sourceAttachmentRowId);
}

/// The complete canonical import-ledger row for one admitted source join.
final class ProjectedSourceMessageAttachmentRelationship {
  ProjectedSourceMessageAttachmentRelationship({
    required this.sourceMessageRowId,
    required this.sourceAttachmentRowId,
    required Map<String, Object?> ledgerValues,
  }) : ledgerValues = Map<String, Object?>.unmodifiable(ledgerValues);

  final int sourceMessageRowId;
  final int sourceAttachmentRowId;
  final Map<String, Object?> ledgerValues;
}

ProjectedSourceMessageAttachmentRelationship
projectSourceMessageAttachmentRelationship(
  MessageAttachmentRelationshipSourceProjectionInput input,
  int sourceId,
  int batchId,
) {
  final sourceMessageRowId = _requiredInt(
    input.sourceMessageRowId,
    'message_id',
  );
  final sourceAttachmentRowId = _requiredInt(
    input.sourceAttachmentRowId,
    'attachment_id',
  );

  return ProjectedSourceMessageAttachmentRelationship(
    sourceMessageRowId: sourceMessageRowId,
    sourceAttachmentRowId: sourceAttachmentRowId,
    ledgerValues: <String, Object?>{
      'message_source_id': sourceId,
      'attachment_source_id': sourceId,
      'source_message_rowid': sourceMessageRowId,
      'source_attachment_rowid': sourceAttachmentRowId,
      'message_ss_id': SourceScopedRowKey.pack(
        sourceId: sourceId,
        sourceRowId: sourceMessageRowId,
      ),
      'attachment_ss_id': SourceScopedRowKey.pack(
        sourceId: sourceId,
        sourceRowId: sourceAttachmentRowId,
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
  throw StateError('message_attachment_join.$field is required');
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
