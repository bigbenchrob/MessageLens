import 'dart:typed_data';

import '../../../../core/util/date_converter.dart';
import '../../domain/source_scoped_row_key.dart';

/// The raw, source-owned facts selected by the bounded Messages source query.
///
/// This immutable value carries no database or filesystem capability. The
/// source importer owns source paging and persistence; this file owns only the
/// deterministic source-row-to-ledger projection.
final class MessageSourceProjectionInput {
  const MessageSourceProjectionInput({
    required this.sourceRowId,
    required this.guid,
    required this.handleId,
    required this.isFromMe,
    required this.date,
    required this.dateRead,
    required this.dateDelivered,
    required this.text,
    required this.attributedBody,
    required this.associatedMessageGuid,
    required this.itemType,
    required this.associatedMessageType,
    required this.threadOriginatorGuid,
    required this.error,
    required this.isSystemMessage,
    required this.hasChatRelationship,
    required this.hasMessageSummaryInfo,
    required this.hasPayloadDataSource,
  });

  factory MessageSourceProjectionInput.fromSourceRow(Map<String, Object?> row) {
    return MessageSourceProjectionInput(
      sourceRowId: row['source_rowid'],
      guid: row['guid'],
      handleId: row['handle_id'],
      isFromMe: row['is_from_me'],
      date: row['date'],
      dateRead: row['date_read'],
      dateDelivered: row['date_delivered'],
      text: row['text'],
      attributedBody: row['attributedBody'],
      associatedMessageGuid: row['associated_message_guid'],
      itemType: row['item_type'],
      associatedMessageType: row['associated_message_type'],
      threadOriginatorGuid: row['thread_originator_guid'],
      error: row['error'],
      isSystemMessage: row['is_system_message'],
      hasChatRelationship: row['has_chat_relationship'],
      hasMessageSummaryInfo: row['has_message_summary_info'],
      hasPayloadDataSource: row['has_payload_data_source'],
    );
  }

  final Object? sourceRowId;
  final Object? guid;
  final Object? handleId;
  final Object? isFromMe;
  final Object? date;
  final Object? dateRead;
  final Object? dateDelivered;
  final Object? text;
  final Object? attributedBody;
  final Object? associatedMessageGuid;
  final Object? itemType;
  final Object? associatedMessageType;
  final Object? threadOriginatorGuid;
  final Object? error;
  final Object? isSystemMessage;
  final Object? hasChatRelationship;
  final Object? hasMessageSummaryInfo;
  final Object? hasPayloadDataSource;

  int get requiredSourceRowId => _requiredInt(sourceRowId, 'source_rowid');

  Uint8List? get nullableAttributedBody => _nullableBlob(attributedBody);

  String? get dateUtc => DateConverter.appleToIsoString(date);

  int? get nullableAssociatedMessageType => _nullableInt(associatedMessageType);

  int? get nullableHasChatRelationship => _nullableInt(hasChatRelationship);

  String? get nullableAssociatedMessageGuid =>
      _nullableString(associatedMessageGuid);
}

/// The complete, canonical ledger row derived from one source Message row.
///
/// The ledger map is deliberately immutable so only the importing transaction
/// can decide how and when to persist this deterministic projection.
final class ProjectedSourceMessage {
  ProjectedSourceMessage({
    required this.sourceRowId,
    required this.attributedBody,
    required this.dateUtc,
    required this.associatedMessageReference,
    required this.associatedMessageType,
    required Map<String, Object?> ledgerValues,
  }) : ledgerValues = Map<String, Object?>.unmodifiable(ledgerValues);

  final int sourceRowId;
  final Uint8List? attributedBody;
  final String? dateUtc;
  final String? associatedMessageReference;
  final int? associatedMessageType;
  final Map<String, Object?> ledgerValues;
}

ProjectedSourceMessage projectSourceMessage({
  required MessageSourceProjectionInput input,
  required int sourceId,
  required int batchId,
}) {
  final sourceRowId = input.requiredSourceRowId;
  final attributedBody = input.nullableAttributedBody;
  final dateUtc = input.dateUtc;
  final associatedMessageReference = input.nullableAssociatedMessageGuid;
  final associatedMessageType = input.nullableAssociatedMessageType;
  final senderHandleSsId = _senderHandleSsId(
    sourceId: sourceId,
    handleId: input.handleId,
  );

  return ProjectedSourceMessage(
    sourceRowId: sourceRowId,
    attributedBody: attributedBody,
    dateUtc: dateUtc,
    associatedMessageReference: associatedMessageReference,
    associatedMessageType: associatedMessageType,
    ledgerValues: <String, Object?>{
      'ss_id': SourceScopedRowKey.pack(
        sourceId: sourceId,
        sourceRowId: sourceRowId,
      ),
      'source_id': sourceId,
      'source_rowid': sourceRowId,
      'guid': _requiredString(input.guid, 'guid'),
      'sender_handle_ss_id': senderHandleSsId,
      'is_from_me': _boolInt(input.isFromMe, 'is_from_me'),
      'date_utc': dateUtc,
      'date_read_utc': DateConverter.appleToIsoString(input.dateRead),
      'date_delivered_utc': DateConverter.appleToIsoString(input.dateDelivered),
      'text': _nullableString(input.text),
      'attributed_body_blob': attributedBody,
      'associated_message_guid': associatedMessageReference,
      'raw_item_type': _nullableInt(input.itemType),
      'raw_associated_message_type': associatedMessageType,
      'thread_originator_guid': _nullableString(input.threadOriginatorGuid),
      'error_code': _nullableInt(input.error),
      'is_system_message': _boolIntOrZero(input.isSystemMessage),
      'has_attributed_body_source': attributedBody == null ? 0 : 1,
      'has_message_summary_info': _boolIntOrZero(input.hasMessageSummaryInfo),
      'has_payload_data_source': _boolIntOrZero(input.hasPayloadDataSource),
      'batch_id': batchId,
    },
  );
}

int? _senderHandleSsId({required int sourceId, required Object? handleId}) {
  final sourceHandleId = _nullableInt(handleId);
  if (sourceHandleId == null || sourceHandleId <= 0) {
    return null;
  }
  return SourceScopedRowKey.pack(
    sourceId: sourceId,
    sourceRowId: sourceHandleId,
  );
}

int _boolInt(Object? value, String field) {
  final integer = _requiredInt(value, field);
  return integer == 0 ? 0 : 1;
}

int _boolIntOrZero(Object? value) {
  final integer = _nullableInt(value);
  if (integer == null) {
    return 0;
  }
  return integer == 0 ? 0 : 1;
}

String _requiredString(Object? value, String field) {
  if (value is String && value.isNotEmpty) {
    return value;
  }
  throw StateError('message.$field is required');
}

int _requiredInt(Object? value, String field) {
  final integer = _nullableInt(value);
  if (integer == null) {
    throw StateError('message.$field is required');
  }
  return integer;
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

String? _nullableString(Object? value) {
  if (value is String && value.isNotEmpty) {
    return value;
  }
  return null;
}

Uint8List? _nullableBlob(Object? value) {
  if (value is Uint8List) {
    return value;
  }
  if (value is List<int>) {
    return Uint8List.fromList(value);
  }
  return null;
}
