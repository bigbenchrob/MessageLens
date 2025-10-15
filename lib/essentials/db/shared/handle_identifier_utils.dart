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
