import 'package:freezed_annotation/freezed_annotation.dart';

part 'contacts_settings_spec.freezed.dart';

/// Specification for contacts-related settings cassettes.
///
/// These specs are wrapped by [ContactsCassetteSpec.settings] to keep the
/// top-level [CassetteSpec] clean while allowing for a rich hierarchy of
/// settings screens within the Contacts feature.
@freezed
abstract class ContactsSettingsSpec with _$ContactsSettingsSpec {
  /// Settings for how contact names are displayed (short names, nicknames, etc).
  const factory ContactsSettingsSpec.shortNames() = _ShortNames;
}
