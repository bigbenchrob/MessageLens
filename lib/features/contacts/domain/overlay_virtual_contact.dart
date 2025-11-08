class OverlayVirtualContact {
  const OverlayVirtualContact({
    required this.id,
    required this.displayName,
    required this.shortName,
    this.notes,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });

  final int id;
  final String displayName;
  final String shortName;
  final String? notes;
  final String createdAtUtc;
  final String updatedAtUtc;
}
