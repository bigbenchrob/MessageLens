/// Information about a canonical handle for display purposes.
class CanonicalHandleInfo {
  const CanonicalHandleInfo({required this.compound, required this.display});

  /// The compound identifier (normalized + service).
  final String compound;

  /// Human-readable display string.
  final String display;
}
