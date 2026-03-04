import 'package:freezed_annotation/freezed_annotation.dart';

part 'contacts_settings_spec.freezed.dart';

/// Specification for contacts-related settings cassettes.
///
/// These specs are wrapped by [ContactsCassetteSpec.settings] to keep the
/// top-level [CassetteSpec] clean while allowing for a rich hierarchy of
/// settings screens within the Contacts feature.
@freezed
abstract class ContactsSettingsSpec with _$ContactsSettingsSpec {
  /// Info card explaining how to customize contact display names.
  ///
  /// Displayed when user navigates to Settings → Contacts.
  /// Explains that name customization is done from the contact's hero card.
  const factory ContactsSettingsSpec.displayNameInfo() = _DisplayNameInfo;
}
