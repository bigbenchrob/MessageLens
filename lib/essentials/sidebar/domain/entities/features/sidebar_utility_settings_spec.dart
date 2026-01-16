import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../features/sidebar_utilities/domain/sidebar_utilities_constants.dart';

part 'sidebar_utility_settings_spec.freezed.dart';
part 'sidebar_utility_settings_spec.g.dart';

/// Spec for sidebar utility cassettes in settings mode.
@freezed
abstract class SidebarUtilitySettingsSpec with _$SidebarUtilitySettingsSpec {
  const factory SidebarUtilitySettingsSpec.settingsMenu({
    @Default(SettingsMenuChoice.contacts) SettingsMenuChoice selectedChoice,
  }) = _SidebarUtilitySettingsSpecSettingsMenu;

  factory SidebarUtilitySettingsSpec.fromJson(Map<String, dynamic> json) =>
      _$SidebarUtilitySettingsSpecFromJson(json);
}
