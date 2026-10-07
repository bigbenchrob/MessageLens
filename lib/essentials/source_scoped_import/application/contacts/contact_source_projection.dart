import '../../../../core/util/date_converter.dart';
import '../../../db/shared/handle_identifier_utils.dart';

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
  final address =
      readTrimmedContactSourceText(row['ZADDRESS']) ??
      readTrimmedContactSourceText(row['ZADDRESSNORMALIZED']);
  return address?.toLowerCase();
}

String? projectContactPhoneNumber(Map<String, Object?> row) {
  final rawNumber =
      readTrimmedContactSourceText(row['ZFULLNUMBER']) ??
      readTrimmedContactSourceText(row['ZVALUE']);
  if (rawNumber == null) {
    return null;
  }
  return normalizeHandleIdentifier(rawNumber) ?? rawNumber;
}

String? projectContactCreatedAtUtc(Object? value) {
  return DateConverter.appleToIsoString(value);
}
