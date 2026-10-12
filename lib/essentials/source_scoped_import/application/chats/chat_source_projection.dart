import '../../../../core/util/date_converter.dart';
import '../../domain/source_scoped_row_key.dart';

/// The raw, source-owned facts selected from one Messages chat row.
///
/// This immutable input carries no database or filesystem capability. Source
/// ordering, batching, duplicate handling, progress, and persistence remain
/// owned by [ChatImporter]'s caller boundary.
final class ChatSourceProjectionInput {
  const ChatSourceProjectionInput({
    required this.sourceRowId,
    required this.guid,
    required this.serviceName,
    required this.service,
    required this.groupId,
    required this.originalGroupId,
    required this.lastReadMessageTimestamp,
  });

  factory ChatSourceProjectionInput.fromSourceRow(Map<String, Object?> row) {
    return ChatSourceProjectionInput(
      sourceRowId: row['source_rowid'],
      guid: row['guid'],
      serviceName: row['service_name'],
      service: row['service'],
      groupId: row['group_id'],
      originalGroupId: row['original_group_id'],
      lastReadMessageTimestamp: row['last_read_message_timestamp'],
    );
  }

  final Object? sourceRowId;
  final Object? guid;
  final Object? serviceName;
  final Object? service;
  final Object? groupId;
  final Object? originalGroupId;
  final Object? lastReadMessageTimestamp;

  int get requiredSourceRowId => _requiredInt(sourceRowId, 'source_rowid');

  String get requiredGuid => _requiredString(guid, 'guid');
}

/// The complete canonical ledger row derived from one source chat row.
///
/// This projection deliberately does not inspect handles, infer group-chat
/// status, consult prior ledger state, or perform any persistence.
final class ProjectedSourceChat {
  ProjectedSourceChat({
    required this.sourceRowId,
    required Map<String, Object?> ledgerValues,
  }) : ledgerValues = Map<String, Object?>.unmodifiable(ledgerValues);

  final int sourceRowId;
  final Map<String, Object?> ledgerValues;
}

ProjectedSourceChat projectSourceChat({
  required ChatSourceProjectionInput input,
  required int sourceId,
  required int batchId,
}) {
  final sourceRowId = input.requiredSourceRowId;

  return ProjectedSourceChat(
    sourceRowId: sourceRowId,
    ledgerValues: <String, Object?>{
      'ss_id': SourceScopedRowKey.pack(
        sourceId: sourceId,
        sourceRowId: sourceRowId,
      ),
      'source_id': sourceId,
      'source_rowid': sourceRowId,
      'guid': input.requiredGuid,
      'service':
          _nullableString(input.serviceName) ?? _nullableString(input.service),
      'group_id': _nullableString(input.groupId),
      'original_group_id': _nullableString(input.originalGroupId),
      'last_read_message_at_utc': DateConverter.appleToIsoString(
        input.lastReadMessageTimestamp,
      ),
      'batch_id': batchId,
    },
  );
}

int _requiredInt(Object? value, String field) {
  if (value is int) {
    return value;
  }
  if (value is double) {
    return value.round();
  }
  throw StateError('chat.$field is required');
}

String _requiredString(Object? value, String field) {
  final string = _nullableString(value);
  if (string == null) {
    throw StateError('chat.$field is required');
  }
  return string;
}

String? _nullableString(Object? value) {
  if (value is String && value.isNotEmpty) {
    return value;
  }
  return null;
}
