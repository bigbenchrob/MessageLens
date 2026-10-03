import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_reset_message_data_action_availability_provider.g.dart';

/// Controls whether the Settings root exposes the advanced message-data reset
/// entry point.
///
/// Existing compositions keep the action by default. A composition whose
/// reset authority is not admitted can override this policy at its root.
@riverpod
bool settingsResetMessageDataActionAvailable(Ref ref) {
  return true;
}
