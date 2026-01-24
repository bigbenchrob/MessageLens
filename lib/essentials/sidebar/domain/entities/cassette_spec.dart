import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../features/sidebar_utilities/domain/sidebar_utilities_constants.dart';
import 'features/contacts_cassette_spec.dart';
import 'features/contacts_info_cassette_spec.dart';
import 'features/contacts_settings_spec.dart';
import 'features/handles_cassette_spec.dart';
import 'features/handles_info_cassette_spec.dart';
import 'features/messages_cassette_spec.dart';
import 'features/presentation_cassette_spec.dart';
import 'features/sidebar_utility_cassette_spec.dart';
import 'features/sidebar_utility_settings_spec.dart';

// import '../../../../features/contacts/feature_level_providers.dart' as contacts_features;

part 'cassette_spec.freezed.dart';
part 'cascade/cassette_child_resolver.dart';
part 'cascade/sidebar_utility_topology.dart';
part 'cascade/sidebar_utility_settings_topology.dart';
part 'cascade/contacts_cassette_topology.dart';
part 'cascade/contacts_info_topology.dart';
part 'cascade/contacts_settings_topology.dart';
part 'cascade/handles_cassette_topology.dart';
part 'cascade/handles_info_topology.dart';
part 'cascade/messages_cassette_topology.dart';
part 'cascade/links/contacts_to_messages.dart';
part 'cascade/links/sidebar_utility_to_contacts.dart';

@freezed
abstract class CassetteSpec with _$CassetteSpec {
  const factory CassetteSpec.sidebarUtility(SidebarUtilityCassetteSpec spec) =
      _CassetteSidebarWidget;
  const factory CassetteSpec.sidebarUtilitySettings(
    SidebarUtilitySettingsSpec spec,
  ) = _CassetteSidebarUtilitySettings;
  const factory CassetteSpec.presentation(PresentationCassetteSpec spec) =
      _CassettePresentation;
  const factory CassetteSpec.contacts(ContactsCassetteSpec spec) =
      _CassetteContacts;
  const factory CassetteSpec.contactsSettings(ContactsSettingsSpec spec) =
      _CassetteContactsSettings;
  const factory CassetteSpec.contactsInfo(ContactsInfoCassetteSpec spec) =
      _CassetteContactsInfo;
  const factory CassetteSpec.handles(HandlesCassetteSpec spec) =
      _CassetteHandles;
  const factory CassetteSpec.handlesInfo(HandlesInfoCassetteSpec spec) =
      _CassetteHandlesInfo;
  const factory CassetteSpec.messages(MessagesCassetteSpec spec) =
      _CassetteMessages;
}

extension CassetteSpecX on CassetteSpec {
  /// Resolve the child cassette spec for this cassette, if any.
  CassetteSpec? childSpec() {
    return resolveCassetteChild(this);
  }
}
