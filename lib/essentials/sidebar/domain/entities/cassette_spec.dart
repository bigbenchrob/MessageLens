import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../features/sidebar_utilities/domain/sidebar_utilities_constants.dart';
import 'features/contacts_cassette_spec.dart';
import 'features/contacts_info_cassette_spec.dart';
import 'features/contacts_settings_spec.dart';
import 'features/handles_cassette_spec.dart';
import 'features/messages_cassette_spec.dart';
import 'features/presentation_cassette_spec.dart';
import 'features/sidebar_utility_cassette_spec.dart';
import 'features/sidebar_utility_settings_spec.dart';

// import '../../../../features/contacts/feature_level_providers.dart' as contacts_features;

part 'cassette_spec.freezed.dart';

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
  const factory CassetteSpec.messages(MessagesCassetteSpec spec) =
      _CassetteMessages;
}

extension CassetteSpecX on CassetteSpec {
  /// Resolve the child cassette spec for this cassette, if any.
  CassetteSpec? childSpec() {
    return when(
      sidebarUtility: (sidebarSpec) => sidebarSpec.childSpec(),
      sidebarUtilitySettings: (settingsSpec) => settingsSpec.childSpec(),
      presentation: (spec) => spec.childSpec(),
      contacts: (contactsSpec) => contactsSpec.childSpec(),
      contactsSettings: (settingsSpec) => settingsSpec.childSpec(),
      contactsInfo: (infoSpec) => infoSpec.childSpec(),
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
            return const CassetteSpec.contactsInfo(
              ContactsInfoCassetteSpec.infoCard(
                key: ContactsInfoKey.favouritesVsRecents,
              ),
            );

          case TopChatMenuChoice.strayEmails:
            return const CassetteSpec.handles(
              HandlesCassetteSpec.infoCard(
                message:
                    'These are messages from email addresses that do not '
                    'belong to a contact in your address book.',
                childVariant: HandlesCassetteChildVariant.strayEmails,
              ),
            );

          case TopChatMenuChoice.strayPhoneNumbers:
            return const CassetteSpec.handles(
              HandlesCassetteSpec.strayPhoneNumbers(),
            );

          case TopChatMenuChoice.searchAllMessages:
            return const CassetteSpec.messages(
              MessagesCassetteSpec.heatMap(
                contactId: null,
                useV2Timeline: true,
              ),
            );

          case TopChatMenuChoice.themePlayground:
            return const CassetteSpec.presentation(
              PresentationCassetteSpec.themePlayground(),
            );
        }
      },
    );
  }
}

extension SidebarUtilitySettingsSpecX on SidebarUtilitySettingsSpec {
  /// Determine the next cassette to show beneath this settings utility.
  CassetteSpec? childSpec() {
    return when(
      settingsMenu: (selectedChoice) {
        switch (selectedChoice) {
          case SettingsMenuChoice.contacts:
            return const CassetteSpec.contactsSettings(
              ContactsSettingsSpec.shortNames(),
            );
        }
      },
    );
  }
}

extension ContactsCassetteSpecX on ContactsCassetteSpec {
  /// Contacts cascade into a messages heatmap when a contact is selected.
  CassetteSpec? childSpec() {
    return when(
      recentContacts: (chosenContactId) {
        if (chosenContactId == null) {
          return null;
        }
        return CassetteSpec.messages(
          MessagesCassetteSpec.heatMap(contactId: chosenContactId),
        );
      },
      contactChooser: (chosenContactId) {
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

extension ContactsInfoCassetteSpecX on ContactsInfoCassetteSpec {
  CassetteSpec? childSpec() {
    return when(
      infoCard: (key) {
        // After the info card, show the normal contact chooser.

        return const CassetteSpec.contacts(
          ContactsCassetteSpec.contactChooser(),
        );
      },
    );
  }
}

extension HandlesCassetteSpecX on HandlesCassetteSpec {
  /// Resolve child spec for handles cassettes.
  CassetteSpec? childSpec() {
    return when(
      unmatchedHandlesList: (_) => null,
      infoCard: (_, __, ___, childVariant) {
        return switch (childVariant) {
          HandlesCassetteChildVariant.strayPhoneNumbers =>
            const CassetteSpec.handles(HandlesCassetteSpec.strayPhoneNumbers()),
          HandlesCassetteChildVariant.strayEmails => const CassetteSpec.handles(
            HandlesCassetteSpec.strayEmails(),
          ),
        };
      },
      strayPhoneNumbers: () => null,
      strayEmails: () => null,
    );
  }
}

extension MessagesCassetteSpecX on MessagesCassetteSpec {
  /// Handles cassettes currently have no children.
  CassetteSpec? childSpec() {
    return when(heatMap: (_, __) => null);
  }
}

extension ContactsSettingsSpecX on ContactsSettingsSpec {
  /// Settings specs currently have no children.
  CassetteSpec? childSpec() {
    return when(shortNames: () => null);
  }
}
