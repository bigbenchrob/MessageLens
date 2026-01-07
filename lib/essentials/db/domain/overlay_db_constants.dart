/// How this participant’s name should be displayed in the UI.
///
/// Stored as an int in user_overlays.db (participant_overrides.name_mode).
/// `null` in the database means "inherit the global default".
enum ParticipantNameMode {
  /// Use the global default from settings.
  inherit(0),

  /// e.g. "Rob"
  firstNameOnly(1),

  /// e.g. "R. Campbell"
  firstInitialLastName(2),

  /// Use nickname (if present; otherwise fallback handled by resolver).
  nickname(3),

  /// Use computed/working full name (displayName).
  fullName(4),

  /// Use displayNameOverride (if present; otherwise fallback handled by resolver).
  overrideDisplayName(5);

  const ParticipantNameMode(this.dbValue);
  final int dbValue;

  static ParticipantNameMode? fromDb(int? v) {
    if (v == null) {
      return null;
    }
    for (final mode in ParticipantNameMode.values) {
      if (mode.dbValue == v) {
        return mode;
      }
    }
    return null;
  }
}
