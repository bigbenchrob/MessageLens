import '../../../db/shared/handle_identifier_utils.dart';
import '../../domain/source_scoped_row_key.dart';

/// The raw, source-owned facts selected from one Messages handle row.
///
/// This immutable input carries no database or filesystem capability. Source
/// ordering, account evidence, identity reconciliation, and persistence remain
/// owned by [HandleImporter]'s caller boundary.
final class HandleSourceProjectionInput {
  const HandleSourceProjectionInput({
    required this.sourceRowId,
    required this.identifier,
    required this.service,
  });

  factory HandleSourceProjectionInput.fromSourceRow(Map<String, Object?> row) {
    return HandleSourceProjectionInput(
      sourceRowId: row['source_rowid'],
      identifier: row['id'],
      service: row['service'],
    );
  }

  final Object? sourceRowId;
  final Object? identifier;
  final Object? service;

  int get requiredSourceRowId => _requiredInt(sourceRowId, 'source_rowid');

  String get requiredIdentifier => _requiredString(identifier, 'id');
}

/// The complete canonical ledger row derived from one source handle row.
///
/// [isMe] is supplied as already-evaluated importer evidence. This projection
/// deliberately does not inspect accounts, messages, prior ledger state, or
/// otherwise decide local-account identity.
final class ProjectedSourceHandle {
  ProjectedSourceHandle({
    required this.sourceRowId,
    required this.rawIdentifier,
    required this.identifierInterpretation,
    required Map<String, Object?> ledgerValues,
  }) : ledgerValues = Map<String, Object?>.unmodifiable(ledgerValues);

  final int sourceRowId;
  final String rawIdentifier;
  final HandleIdentifierInterpretation identifierInterpretation;
  final Map<String, Object?> ledgerValues;
}

ProjectedSourceHandle projectSourceHandle({
  required HandleSourceProjectionInput input,
  required int sourceId,
  required int batchId,
  required bool isMe,
  HandleIdentifierInterpreter handleIdentifierInterpreter =
      interpretHandleIdentifier,
}) {
  final sourceRowId = input.requiredSourceRowId;
  final rawIdentifier = input.requiredIdentifier;
  final interpretation = _interpretIdentifier(
    rawIdentifier,
    handleIdentifierInterpreter,
  );

  return ProjectedSourceHandle(
    sourceRowId: sourceRowId,
    rawIdentifier: rawIdentifier,
    identifierInterpretation: interpretation,
    ledgerValues: <String, Object?>{
      'ss_id': SourceScopedRowKey.pack(
        sourceId: sourceId,
        sourceRowId: sourceRowId,
      ),
      'source_id': sourceId,
      'source_rowid': sourceRowId,
      'id': rawIdentifier,
      'service': _nullableString(input.service),
      'is_me': isMe ? 1 : 0,
      'batch_id': batchId,
    },
  );
}

HandleIdentifierInterpretation _interpretIdentifier(
  String rawIdentifier,
  HandleIdentifierInterpreter interpreter,
) {
  try {
    return interpreter(rawIdentifier);
  } on HandleIdentifierNormalizationException {
    return const HandleIdentifierInterpretation.preservedUnnormalized();
  }
}

int _requiredInt(Object? value, String field) {
  if (value is int) {
    return value;
  }
  if (value is double) {
    return value.round();
  }
  throw StateError('handle.$field is required');
}

String _requiredString(Object? value, String field) {
  final string = _nullableString(value);
  if (string == null) {
    throw StateError('handle.$field is required');
  }
  return string;
}

String? _nullableString(Object? value) {
  if (value is String && value.isNotEmpty) {
    return value;
  }
  return null;
}
