import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../features/contacts/domain/spec_classes/contacts_cassette_spec.dart';
import '../../../../features/contacts/domain/spec_classes/contacts_info_cassette_spec.dart';
import '../../../../features/contacts/domain/spec_classes/contacts_settings_spec.dart';
import '../../../../features/handles/domain/spec_classes/handles_cassette_spec.dart';
import '../../../../features/handles/domain/spec_classes/handles_info_cassette_spec.dart';
import '../../../../features/messages/domain/spec_classes/messages_cassette_spec.dart';
import '../../../../features/messages/domain/spec_classes/messages_info_cassette_spec.dart';
import '../../../../features/sidebar_utilities/domain/sidebar_utilities_constants.dart';
import '../../../../features/sidebar_utilities/domain/spec_classes/sidebar_utility_cassette_spec.dart';

part 'cassette_spec.freezed.dart';
part 'cascade/cassette_child_resolver.dart';
part 'cascade/sidebar_utility_topology.dart';
part 'cascade/contacts_cassette_topology.dart';
part 'cascade/contacts_info_topology.dart';
part 'cascade/contacts_settings_topology.dart';
part 'cascade/handles_cassette_topology.dart';
part 'cascade/handles_info_topology.dart';
part 'cascade/messages_cassette_topology.dart';
part 'cascade/messages_info_topology.dart';
part 'cascade/links/contacts_to_messages.dart';
part 'cascade/links/sidebar_utility_to_contacts.dart';

@freezed
abstract class CassetteSpec with _$CassetteSpec {
  const factory CassetteSpec.sidebarUtility(SidebarUtilityCassetteSpec spec) =
      _CassetteSidebarWidget;
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
  const factory CassetteSpec.messagesInfo(MessagesInfoCassetteSpec spec) =
      _CassetteMessagesInfo;
}

extension CassetteSpecX on CassetteSpec {
  /// Resolve the child cassette spec for this cassette, if any.
  CassetteSpec? childSpec() {
    return resolveCassetteChild(this);
  }
}
