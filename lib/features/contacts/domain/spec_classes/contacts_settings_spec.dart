import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../sidebar_utilities/domain/sidebar_utilities_constants.dart';

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

  /// Actions submenu with dropdown to choose an action.
  ///
  /// Displayed when user navigates to Settings → Actions.
  /// Cascades to [sendLogsInfo] or [reimportDataInfo] based on choice.
  const factory ContactsSettingsSpec.actionsMenu({
    @Default(ActionsMenuChoice.sendLogs) ActionsMenuChoice selectedChoice,
  }) = _ActionsMenu;

  /// Info card with diagnostic log export action.
  const factory ContactsSettingsSpec.sendLogsInfo() = _SendLogsInfo;

  /// Info card with reimport data action.
  const factory ContactsSettingsSpec.reimportDataInfo() = _ReimportDataInfo;
}
