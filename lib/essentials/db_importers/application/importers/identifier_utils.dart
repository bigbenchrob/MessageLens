/// Shared identifier-normalization logic used by multiple importers.

/// Normalizes a phone number or email to a canonical form for matching.
///
/// - Emails are lower-cased.
/// - Phone numbers are stripped to digits (plus leading '+' removed),
///   and US-style 11-digit numbers starting with '1' are trimmed to 10 digits.
String? normalizeIdentifier(String? value) {
  if (value == null) {
    return null;
  }
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  if (trimmed.contains('@')) {
    return trimmed.toLowerCase();
  }
  final digits = trimmed.replaceAll(RegExp(r'[^0-9+]'), '');
  if (digits.isEmpty) {
    return null;
  }
  final normalized = digits.startsWith('+') ? digits.substring(1) : digits;
  if (normalized.length == 11 && normalized.startsWith('1')) {
    return normalized.substring(1);
  }
  return normalized;
}
