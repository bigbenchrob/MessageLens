String sanitizeHandleService(String? rawService) {
  final trimmed = rawService?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return 'Unknown';
  }
  return trimmed;
}

String buildCompoundIdentifier({
  String? normalizedIdentifier,
  String? rawIdentifier,
  required String service,
}) {
  final safeService = sanitizeHandleService(service);
  final normalizedBase = normalizedIdentifier?.trim();
  if (normalizedBase != null && normalizedBase.isNotEmpty) {
    return '$normalizedBase-$safeService';
  }

  final fallback = _fallbackCompoundBase(rawIdentifier);
  if (fallback == null || fallback.isEmpty) {
    return 'unknown-$safeService';
  }
  return '$fallback-$safeService';
}

String? _fallbackCompoundBase(String? rawIdentifier) {
  if (rawIdentifier == null) {
    return null;
  }

  var candidate = rawIdentifier.trim();
  if (candidate.isEmpty) {
    return null;
  }

  candidate = _stripKnownSchemes(candidate);
  candidate = candidate.replaceAll(RegExp(r'\s+'), '');
  return candidate.toLowerCase();
}

String _stripKnownSchemes(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return trimmed;
  }

  final lower = trimmed.toLowerCase();
  if (lower.startsWith('tel:')) {
    return trimmed.substring(trimmed.indexOf(':') + 1).trim();
  }
  if (lower.startsWith('mailto:')) {
    return trimmed.substring(trimmed.indexOf(':') + 1).trim();
  }
  return trimmed;
}

/// Format a phone number into human-friendly format if possible.
///
/// Returns the formatted number like "1 (234) 567-8901" for US/Canada numbers,
/// or "+63 909 032 9007" for international numbers.
///
/// Examples:
/// - "+12345678901" → "1 (234) 567-8901" (US/Canada)
/// - "2345678901" → "(234) 567-8901" (US/Canada)
/// - "+639090329007" → "+63 909 032 9007" (Philippines)
/// - "+97466780166" → "+974 667 801 66" (Qatar)
/// - "me@me.com" → "me@me.com" (unchanged - email)
/// - "urn:biz:..." → "urn:biz:..." (unchanged - URN)
/// - "1234" → "1234" (unchanged - too short)
String formatPhoneNumberForDisplay(String? rawIdentifier) {
  if (rawIdentifier == null || rawIdentifier.isEmpty) {
    return '';
  }

  final trimmed = rawIdentifier.trim();

  // If it contains known non-phone patterns, return as-is
  if (trimmed.contains('@') ||
      trimmed.contains(RegExp(r'[a-zA-Z]')) ||
      trimmed.startsWith('urn:') ||
      trimmed.startsWith('mailto:') ||
      trimmed.contains(':')) {
    return trimmed;
  }

  // Extract only digits
  final digitsOnly = trimmed.replaceAll(RegExp(r'[^\d]'), '');

  // Too short to be a valid phone number
  if (digitsOnly.length < 10) {
    return trimmed;
  }

  // US/Canada format (10-11 digits)
  if (digitsOnly.length == 10) {
    // Format: (234) 567-8901
    return '(${digitsOnly.substring(0, 3)}) ${digitsOnly.substring(3, 6)}-${digitsOnly.substring(6)}';
  } else if (digitsOnly.length == 11 && digitsOnly.startsWith('1')) {
    // Format: 1 (234) 567-8901
    return '${digitsOnly[0]} (${digitsOnly.substring(1, 4)}) ${digitsOnly.substring(4, 7)}-${digitsOnly.substring(7)}';
  }

  // International number (12+ digits) - format with country code and spacing
  // Keep the + prefix if it exists, add spacing for readability
  final hasPlus = trimmed.startsWith('+');
  final prefix = hasPlus ? '+' : '';

  // For international numbers, group digits: +CC CCC CCC CCCC
  // This is a generic format that works reasonably well for most countries
  if (digitsOnly.length == 12) {
    // Format: +CC CCC CCC CCC (e.g., +974 667 801 66)
    return '$prefix${digitsOnly.substring(0, 3)} ${digitsOnly.substring(3, 6)} ${digitsOnly.substring(6, 9)} ${digitsOnly.substring(9)}';
  } else if (digitsOnly.length == 13) {
    // Format: +CC CCC CCC CCCC (e.g., +63 909 032 9007)
    return '$prefix${digitsOnly.substring(0, 2)} ${digitsOnly.substring(2, 5)} ${digitsOnly.substring(5, 8)} ${digitsOnly.substring(8)}';
  } else if (digitsOnly.length >= 14) {
    // Format: +CCC CCC CCC CCCC
    return '$prefix${digitsOnly.substring(0, 3)} ${digitsOnly.substring(3, 6)} ${digitsOnly.substring(6, 9)} ${digitsOnly.substring(9)}';
  }

  // Fallback: just add spacing every 3-4 digits for readability
  return _addGenericSpacing(digitsOnly, hasPlus);
}

/// Add generic spacing to long phone numbers for readability
String _addGenericSpacing(String digitsOnly, bool hasPlus) {
  final prefix = hasPlus ? '+' : '';
  final buffer = StringBuffer(prefix);

  // Add space every 3-4 digits
  for (var i = 0; i < digitsOnly.length; i++) {
    if (i > 0 && i % 3 == 0) {
      buffer.write(' ');
    }
    buffer.write(digitsOnly[i]);
  }

  return buffer.toString();
}
