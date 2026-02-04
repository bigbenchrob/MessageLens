import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_spec.freezed.dart';

@freezed
abstract class SettingsSpec with _$SettingsSpec {
  /// Contact display name customization info.
  /// Explains that names can be customized from the hero card.
  const factory SettingsSpec.contactDisplayNameInfo() =
      _SettingsContactDisplayNameInfo;

  const SettingsSpec._();
}
