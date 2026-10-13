import '../../../../core/util/date_converter.dart';
import '../../domain/source_scoped_row_key.dart';

/// The raw, source-owned facts selected from one Messages attachment row.
///
/// This immutable input carries no database, filesystem, payload, or archive
/// capability. Source ordering, cursors, batching, duplicate handling,
/// progress, anomalies, and persistence remain importer-owned.
final class AttachmentSourceProjectionInput {
  const AttachmentSourceProjectionInput({
    required this.sourceRowId,
    required this.guid,
    required this.filename,
    required this.transferName,
    required this.uti,
    required this.mimeType,
    required this.totalBytes,
    required this.createdDate,
    required this.createdAt,
  });

  factory AttachmentSourceProjectionInput.fromSourceRow(
    Map<String, Object?> row,
  ) {
    return AttachmentSourceProjectionInput(
      sourceRowId: row['source_rowid'],
      guid: row['guid'],
      filename: row['filename'],
      transferName: row['transfer_name'],
      uti: row['uti'],
      mimeType: row['mime_type'],
      totalBytes: row['total_bytes'],
      createdDate: row['created_date'],
      createdAt: row['created_at'],
    );
  }

  final Object? sourceRowId;
  final Object? guid;
  final Object? filename;
  final Object? transferName;
  final Object? uti;
  final Object? mimeType;
  final Object? totalBytes;
  final Object? createdDate;
  final Object? createdAt;

  int get requiredSourceRowId => _requiredInt(sourceRowId, 'source_rowid');
}

/// The complete canonical ledger row derived from one attachment source row.
///
/// [metadataDegraded] is the existing source-metadata anomaly fact. It does
/// not describe payload availability, archive coverage, or recoverability.
final class ProjectedSourceAttachment {
  ProjectedSourceAttachment({
    required this.sourceRowId,
    required Map<String, Object?> ledgerValues,
    required this.metadataDegraded,
  }) : ledgerValues = Map<String, Object?>.unmodifiable(ledgerValues);

  final int sourceRowId;
  final Map<String, Object?> ledgerValues;
  final bool metadataDegraded;
}

ProjectedSourceAttachment projectSourceAttachment({
  required AttachmentSourceProjectionInput input,
  required int sourceId,
  required int batchId,
}) {
  final sourceRowId = input.requiredSourceRowId;
  final guid = _nullableString(input.guid);
  final filename = _nullableString(input.filename);
  final transferName = _nullableString(input.transferName);
  final uti = _nullableString(input.uti);
  final mimeType = _nullableString(input.mimeType);

  return ProjectedSourceAttachment(
    sourceRowId: sourceRowId,
    ledgerValues: <String, Object?>{
      'ss_id': SourceScopedRowKey.pack(
        sourceId: sourceId,
        sourceRowId: sourceRowId,
      ),
      'source_id': sourceId,
      'source_rowid': sourceRowId,
      'guid': guid,
      'filename': filename,
      'transfer_name': transferName,
      'uti': uti,
      'mime_type': mimeType,
      'total_bytes': _nullableInt(input.totalBytes),
      'created_at_utc':
          DateConverter.appleToIsoString(input.createdDate) ??
          DateConverter.appleToIsoString(input.createdAt),
      'batch_id': batchId,
    },
    metadataDegraded:
        guid == null &&
        filename == null &&
        transferName == null &&
        uti == null &&
        mimeType == null,
  );
}

int _requiredInt(Object? value, String field) {
  final intValue = _nullableInt(value);
  if (intValue == null) {
    throw StateError('attachment.$field is required');
  }
  return intValue;
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
