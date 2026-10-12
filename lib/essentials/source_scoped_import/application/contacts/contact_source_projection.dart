import '../../../../core/util/date_converter.dart';
import '../../../db/shared/handle_identifier_utils.dart';
import '../../domain/source_scoped_row_key.dart';

enum ContactSourceOmissionReason { invalidSourcePrimaryKey }

enum ContactChannelSourceOmissionReason {
  invalidOwner,
  ownerNotImported,
  missingValue,
}

enum ContactChannelKind {
  email('email'),
  phone('phone');

  const ContactChannelKind(this.ledgerValue);

  final String ledgerValue;
}

sealed class ContactSourceProjectionResult {
  const ContactSourceProjectionResult();
}

final class ProjectedSourceContact extends ContactSourceProjectionResult {
  const ProjectedSourceContact({
    required this.ssId,
    required this.sourceId,
    required this.sourceRowId,
    required this.displayName,
    required this.firstName,
    required this.lastName,
    required this.organization,
    required this.createdAtUtc,
    required this.batchId,
    required this.enrichmentUnavailable,
  });

  final int ssId;
  final int sourceId;
  final int sourceRowId;
  final String displayName;
  final String? firstName;
  final String? lastName;
  final String? organization;
  final String? createdAtUtc;
  final int batchId;
  final bool enrichmentUnavailable;

  Map<String, Object?> get ledgerValues {
    return Map<String, Object?>.unmodifiable(<String, Object?>{
      'ss_id': ssId,
      'source_id': sourceId,
      'source_rowid': sourceRowId,
      'display_name': displayName,
      'first_name': firstName,
      'last_name': lastName,
      'organization': organization,
      'created_at_utc': createdAtUtc,
      'batch_id': batchId,
    });
  }
}

final class OmittedSourceContact extends ContactSourceProjectionResult {
  const OmittedSourceContact({required this.reason});

  final ContactSourceOmissionReason reason;
}

sealed class ContactChannelSourceProjectionResult {
  const ContactChannelSourceProjectionResult({
    required this.sourceContactRowId,
  });

  final int? sourceContactRowId;
}

final class ProjectedSourceContactChannel
    extends ContactChannelSourceProjectionResult {
  const ProjectedSourceContactChannel({
    required super.sourceContactRowId,
    required this.sourceId,
    required this.contactSsId,
    required this.kind,
    required this.value,
    required this.label,
    required this.batchId,
  });

  @override
  int get sourceContactRowId => super.sourceContactRowId!;

  final int sourceId;
  final int contactSsId;
  final ContactChannelKind kind;
  final String value;
  final String? label;
  final int batchId;

  Map<String, Object?> get ledgerValues {
    return Map<String, Object?>.unmodifiable(<String, Object?>{
      'source_id': sourceId,
      'source_contact_rowid': sourceContactRowId,
      'contact_ss_id': contactSsId,
      'kind': kind.ledgerValue,
      'value': value,
      'label': label,
      'batch_id': batchId,
    });
  }
}

final class OmittedSourceContactChannel
    extends ContactChannelSourceProjectionResult {
  const OmittedSourceContactChannel({
    required super.sourceContactRowId,
    required this.reason,
  });

  final ContactChannelSourceOmissionReason reason;
}

ContactSourceProjectionResult projectSourceContact({
  required Object? sourcePrimaryKey,
  required Object? rawFirstName,
  required Object? rawMiddleName,
  required Object? rawLastName,
  required Object? rawOrganization,
  required Object? rawCreationDate,
  required int sourceId,
  required int batchId,
}) {
  final sourceRowId = _readNullableContactSourceInteger(sourcePrimaryKey);
  if (sourceRowId == null) {
    return const OmittedSourceContact(
      reason: ContactSourceOmissionReason.invalidSourcePrimaryKey,
    );
  }

  final firstName = readTrimmedContactSourceText(rawFirstName);
  final middleName = readTrimmedContactSourceText(rawMiddleName);
  final lastName = readTrimmedContactSourceText(rawLastName);
  final organization = readTrimmedContactSourceText(rawOrganization);
  final displayName = buildContactDisplayName(
    firstName: firstName,
    middleName: middleName,
    lastName: lastName,
    organization: organization,
  );

  return ProjectedSourceContact(
    ssId: SourceScopedRowKey.pack(sourceId: sourceId, sourceRowId: sourceRowId),
    sourceId: sourceId,
    sourceRowId: sourceRowId,
    displayName: displayName ?? 'Unknown Contact',
    firstName: firstName,
    lastName: lastName,
    organization: organization,
    createdAtUtc: projectContactCreatedAtUtc(rawCreationDate),
    batchId: batchId,
    enrichmentUnavailable: displayName == null,
  );
}

ContactChannelSourceProjectionResult projectSourceContactChannel({
  required Object? rawOwner,
  required Object? rawPrimaryValue,
  required Object? rawFallbackValue,
  required Object? rawLabel,
  required ContactChannelKind kind,
  required Set<int> importedContactSourceRowIds,
  required int sourceId,
  required int batchId,
}) {
  final owner = _readNullableContactSourceInteger(rawOwner);
  final value = switch (kind) {
    ContactChannelKind.email => _projectContactEmailValue(
      rawPrimaryValue,
      rawFallbackValue,
    ),
    ContactChannelKind.phone => _projectContactPhoneValue(
      rawPrimaryValue,
      rawFallbackValue,
    ),
  };

  if (owner == null) {
    return const OmittedSourceContactChannel(
      sourceContactRowId: null,
      reason: ContactChannelSourceOmissionReason.invalidOwner,
    );
  }
  if (!importedContactSourceRowIds.contains(owner)) {
    return OmittedSourceContactChannel(
      sourceContactRowId: owner,
      reason: ContactChannelSourceOmissionReason.ownerNotImported,
    );
  }
  if (value == null) {
    return OmittedSourceContactChannel(
      sourceContactRowId: owner,
      reason: ContactChannelSourceOmissionReason.missingValue,
    );
  }

  return ProjectedSourceContactChannel(
    sourceContactRowId: owner,
    sourceId: sourceId,
    contactSsId: SourceScopedRowKey.pack(
      sourceId: sourceId,
      sourceRowId: owner,
    ),
    kind: kind,
    value: value,
    label: readTrimmedContactSourceText(rawLabel),
    batchId: batchId,
  );
}

String? readTrimmedContactSourceText(Object? value) {
  if (value is! String) {
    return null;
  }
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String? buildContactDisplayName({
  String? firstName,
  String? middleName,
  String? lastName,
  String? organization,
}) {
  final parts = <String>[
    if (firstName != null) firstName,
    if (middleName != null) middleName,
    if (lastName != null) lastName,
  ];
  if (parts.isNotEmpty) {
    return parts.join(' ');
  }
  return organization;
}

String? projectContactEmailAddress(Map<String, Object?> row) {
  return _projectContactEmailValue(row['ZADDRESS'], row['ZADDRESSNORMALIZED']);
}

String? projectContactPhoneNumber(Map<String, Object?> row) {
  return _projectContactPhoneValue(row['ZFULLNUMBER'], row['ZVALUE']);
}

String? _projectContactEmailValue(Object? primary, Object? fallback) {
  final address =
      readTrimmedContactSourceText(primary) ??
      readTrimmedContactSourceText(fallback);
  return address?.toLowerCase();
}

String? _projectContactPhoneValue(Object? primary, Object? fallback) {
  final rawNumber =
      readTrimmedContactSourceText(primary) ??
      readTrimmedContactSourceText(fallback);
  if (rawNumber == null) {
    return null;
  }
  return normalizeHandleIdentifier(rawNumber) ?? rawNumber;
}

String? projectContactCreatedAtUtc(Object? value) {
  return DateConverter.appleToIsoString(value);
}

int? _readNullableContactSourceInteger(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is double) {
    return value.round();
  }
  return null;
}
