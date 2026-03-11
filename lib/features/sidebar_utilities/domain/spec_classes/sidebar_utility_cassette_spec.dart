import 'package:freezed_annotation/freezed_annotation.dart';

import '../sidebar_utilities_constants.dart';

part 'sidebar_utility_cassette_spec.freezed.dart';
part 'sidebar_utility_cassette_spec.g.dart';

/// Spec for sidebar utility cassettes (top-level navigation menus).
///
/// These are the control cassettes that determine what cascade follows.
/// Both messages mode (topChatMenu) and settings mode (settingsMenu) are
/// unified here since they're structurally identical navigation menus.
@freezed
abstract class SidebarUtilityCassetteSpec with _$SidebarUtilityCassetteSpec {
  /// Top-level menu for messages/chat mode.
  const factory SidebarUtilityCassetteSpec.topChatMenu({
    @Default(TopChatMenuChoice.contacts) TopChatMenuChoice selectedChoice,
  }) = _SidebarUtilityCassetteSpecTopChatMenu;

  /// Top-level menu for settings mode.
  const factory SidebarUtilityCassetteSpec.settingsMenu({
    @Default(SettingsMenuChoice.actions) SettingsMenuChoice selectedChoice,
  }) = _SidebarUtilityCassetteSpecSettingsMenu;

  factory SidebarUtilityCassetteSpec.fromJson(Map<String, dynamic> json) =>
      _$SidebarUtilityCassetteSpecFromJson(json);
}
