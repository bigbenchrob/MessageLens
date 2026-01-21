import '../../../essentials/db/domain/overlay_db_constants.dart';
import '../../../essentials/db/infrastructure/data_sources/local/working/working_database.dart';

/// Resolves the display name for a [WorkingParticipant] based on the
/// configured [ParticipantNameMode] and optional nickname overrides.
///
/// This centralizes the name formatting logic used throughout the app:
/// - `firstNameOnly`: Returns just the given name (e.g. "Rob")
/// - `firstInitialLastName`: Returns first initial + last name (e.g. "R. Campbell")
/// - `nickname`: Uses custom nickname if available, otherwise falls back
/// - `fullName`: Uses the full display name
/// - `overrideDisplayName`: Uses custom display name override if available
/// - `inherit`: Should not be passed directly; caller should resolve to actual mode
class ParticipantNameResolver {
  const ParticipantNameResolver._();

  /// Resolves the display name for a participant based on the given mode.
  ///
  /// [participant] - The working participant record with name fields
  /// [mode] - The display mode to use for formatting
  /// [nickname] - Optional custom nickname (from overlay database)
  /// [displayNameOverride] - Optional custom display name override
  ///
  /// Returns the formatted name, or 'Unknown Contact' if no name is available.
  static String resolve({
    required WorkingParticipant participant,
    required ParticipantNameMode mode,
    String? nickname,
    String? displayNameOverride,
  }) {
    // Handle special modes that use override values first
    if (mode == ParticipantNameMode.nickname) {
      final trimmedNickname = nickname?.trim();
      if (trimmedNickname != null && trimmedNickname.isNotEmpty) {
        return trimmedNickname;
      }
      // Fall through to firstNameOnly as default fallback for nickname mode
      return _resolveFirstNameOnly(participant);
    }

    if (mode == ParticipantNameMode.overrideDisplayName) {
      final trimmedOverride = displayNameOverride?.trim();
      if (trimmedOverride != null && trimmedOverride.isNotEmpty) {
        return trimmedOverride;
      }
      // Fall through to fullName as default fallback
      return _resolveFullName(participant);
    }

    return switch (mode) {
      ParticipantNameMode.firstNameOnly => _resolveFirstNameOnly(participant),
      ParticipantNameMode.firstInitialLastName => _resolveFirstInitialLastName(
        participant,
      ),
      ParticipantNameMode.fullName => _resolveFullName(participant),
      // inherit should be resolved by caller before calling this method
      ParticipantNameMode.inherit => _resolveFirstNameOnly(participant),
      // Already handled above but required for exhaustiveness
      ParticipantNameMode.nickname => _resolveFirstNameOnly(participant),
      ParticipantNameMode.overrideDisplayName => _resolveFullName(participant),
    };
  }

  /// Returns just the first/given name.
  /// Example: "Rob"
  static String _resolveFirstNameOnly(WorkingParticipant participant) {
    final givenName = participant.givenName?.trim();
    if (givenName != null && givenName.isNotEmpty) {
      return givenName;
    }

    // Fall back to full name resolution if no given name
    return _resolveFullName(participant);
  }

  /// Returns first initial + last name.
  /// Example: "R. Campbell"
  static String _resolveFirstInitialLastName(WorkingParticipant participant) {
    final givenName = participant.givenName?.trim();
    final familyName = participant.familyName?.trim();

    if (givenName != null &&
        givenName.isNotEmpty &&
        familyName != null &&
        familyName.isNotEmpty) {
      return '${givenName[0]}. $familyName';
    }

    // If we only have family name, use it alone
    if (familyName != null && familyName.isNotEmpty) {
      return familyName;
    }

    // If we only have given name, use full name fallback
    return _resolveFullName(participant);
  }

  /// Returns the full display name using available name components.
  static String _resolveFullName(WorkingParticipant participant) {
    final candidates = <String?>[
      participant.displayName,
      participant.originalName,
      _buildFullNameFromParts(participant),
      participant.organization,
    ];

    for (final candidate in candidates) {
      if (candidate != null && candidate.trim().isNotEmpty) {
        return candidate.trim();
      }
    }

    return 'Unknown Contact';
  }

  /// Builds full name from given + family name parts.
  static String? _buildFullNameFromParts(WorkingParticipant participant) {
    final given = participant.givenName?.trim();
    final family = participant.familyName?.trim();

    if (given?.isNotEmpty == true && family?.isNotEmpty == true) {
      return '$given $family';
    }

    return given?.isNotEmpty == true ? given : family;
  }
}
