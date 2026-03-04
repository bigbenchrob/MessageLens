import 'package:freezed_annotation/freezed_annotation.dart';

part 'handles_settings_spec.freezed.dart';

/// Specification for handles-related settings cassettes.
///
/// These specs represent settings screens within the Handles feature,
/// allowing users to manage handle-to-participant linking and spam filtering.
@freezed
abstract class HandlesSettingsSpec with _$HandlesSettingsSpec {
  /// Settings for manually linking handles to participants.
  ///
  /// Allows users to:
  /// - View handles not linked to any participant
  /// - Link handles to existing participants
  /// - Create new participants for handles
  const factory HandlesSettingsSpec.manualLinking() = _ManualLinking;

  /// Settings for managing spam/blacklisted handles.
  ///
  /// Allows users to:
  /// - View all blacklisted handles
  /// - Unblock handles (remove from blacklist)
  /// - Manually blacklist handles
  const factory HandlesSettingsSpec.spamManagement() = _SpamManagement;
}
