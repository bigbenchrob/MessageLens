import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../features/sidebar_utilities/domain/sidebar_utilities_constants.dart';
import 'features/contacts_cassette_spec.dart';
import 'features/handles_cassette_spec.dart';
import 'features/messages_cassette_spec.dart';
import 'features/sidebar_utility_cassette_spec.dart';

part 'cassette_spec.freezed.dart';

@freezed
abstract class CassetteSpec with _$CassetteSpec {
  const factory CassetteSpec.sidebarUtility(SidebarUtilityCassetteSpec spec) =
      _CassetteSidebarWidget;
  const factory CassetteSpec.contacts(ContactsCassetteSpec spec) =
      _CasetteContacts;
  const factory CassetteSpec.handles(HandlesCassetteSpec spec) =
      _CasetteHandles;
  const factory CassetteSpec.messages(MessagesCassetteSpec spec) =
      _CassetteMessages;
}

extension CassetteSpecX on CassetteSpec {
  /// Resolve the child cassette spec for this cassette, if any.
  CassetteSpec? childSpec() {
    return when(
      sidebarUtility: (sidebarSpec) => sidebarSpec.childSpec(),
      contacts: (contactsSpec) => contactsSpec.childSpec(),
      handles: (handlesSpec) => handlesSpec.childSpec(),
      messages: (messagesSpec) => messagesSpec.childSpec(),
    );
  }
}

extension SidebarUtilityCassetteSpecX on SidebarUtilityCassetteSpec {
  /// Determine the next cassette to show beneath this sidebar utility.
  CassetteSpec? childSpec() {
    return when(
      topChatMenu: (selectedChoice) {
        switch (selectedChoice) {
          case TopChatMenuChoice.contacts:
            return const CassetteSpec.contacts(
              ContactsCassetteSpec.contactsEnhancedPicker(),
            );

          case TopChatMenuChoice.unmatchedHandles:
            // Placeholder – adjust to your real cassette type
            return const CassetteSpec.handles(
              HandlesCassetteSpec.unmatchedHandlesList(),
            );

          case TopChatMenuChoice.allMessages:
            return const CassetteSpec.messages(
              MessagesCassetteSpec.heatMap(contactId: null),
            );
        }
      },

      // other variants...
    );
  }
}

extension ContactsCassetteSpecX on ContactsCassetteSpec {
  /// Contacts cascade into a messages heatmap when a contact is selected.
  CassetteSpec? childSpec() {
    return when(
      contactsFlatMenu: (chosenContactId) {
        if (chosenContactId == null) {
          return null;
        }
        return CassetteSpec.messages(
          MessagesCassetteSpec.heatMap(contactId: chosenContactId),
        );
      },
      contactsEnhancedPicker: (chosenContactId) {
        if (chosenContactId == null) {
          return null;
        }
        return CassetteSpec.messages(
          MessagesCassetteSpec.heatMap(contactId: chosenContactId),
        );
      },
      contactHeroSummary: (chosenContactId) {
        return CassetteSpec.messages(
          MessagesCassetteSpec.heatMap(contactId: chosenContactId),
        );
      },
    );
  }
}

extension HandlesCassetteSpecX on HandlesCassetteSpec {
  /// Handles cassettes currently have no children.
  CassetteSpec? childSpec() {
    return when(unmatchedHandlesList: (_) => null);
  }
}

extension MessagesCassetteSpecX on MessagesCassetteSpec {
  /// Handles cassettes currently have no children.
  CassetteSpec? childSpec() {
    return when(heatMap: (_) => null);
  }
}
