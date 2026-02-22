/// Utilities for normalizing handle identifiers.
///
/// Normalization ensures that dismissal state persists across re-imports even
/// when the handle's raw_identifier has different formatting (e.g., phone
/// numbers with or without country codes, different punctuation).

/// Normalizes a handle identifier to a canonical form.
///
/// - **Phone numbers**: Strips all non-digit characters except leading `+`.
///   E.g., `(604) 828-6252` → `6048286252`, `+1 604-828-6252` → `+16048286252`
/// - **Email addresses**: Lowercases and trims whitespace.
///   E.g., `Test@Example.COM` → `test@example.com`
String normalizeHandleIdentifier(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return trimmed;
  }

  if (trimmed.contains('@')) {
    // Email: lowercase only
    return trimmed.toLowerCase();
  }

  // Phone: preserve leading + but strip everything else except digits
  final hasPlus = trimmed.startsWith('+');
  final digits = trimmed.replaceAll(RegExp(r'[^\d]'), '');

  return hasPlus ? '+$digits' : digits;
}

/// Returns true if the handle appears to be a short code (3-8 digits, no
/// country code prefix).
///
/// Short codes are often used for commercial messaging (2FA, promotions, etc.)
/// and are strong indicators of non-personal communication.
bool isShortCode(String handleValue) {
  final normalized = normalizeHandleIdentifier(handleValue);

  // Must not have country code prefix
  if (normalized.startsWith('+')) {
    return false;
  }

  // Must be all digits
  if (!RegExp(r'^\d+$').hasMatch(normalized)) {
    return false;
  }

  // Short codes are typically 3-8 digits
  return normalized.length >= 3 && normalized.length <= 8;
}
