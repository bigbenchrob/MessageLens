import 'package:freezed_annotation/freezed_annotation.dart';

part 'contacts_info_cassette_spec.freezed.dart';

/// Feature-owned spec for Contacts "info" cassettes.
///
/// Lives with the Contacts feature since the keys and their meanings
/// are feature-owned. Re-exported by `essentials/sidebar/feature_level_providers.dart`
/// so the sidebar cascade topology can reference it.
///
/// This allows:
/// - centralized spec routing (CassetteSpec.* variants)
/// - feature-owned meaning (InfoContentResolver)
/// - reuse of the same key for future surfaces (tooltips/onboarding) without changing
///   this cassette spec unless the sidebar needs new variants.
///
/// When to add new variants here:
/// - Only when the sidebar needs a structurally different kind of "info cassette"
///   (e.g., a warning banner vs. an info card, or something with actions).
/// - If the only change is wording/data, add a new key instead.
@freezed
abstract class ContactsInfoCassetteSpec with _$ContactsInfoCassetteSpec {
  const ContactsInfoCassetteSpec._();

  /// Request an informational card.
  ///
  /// The `key` identifies the meaning; the Contacts feature will resolve it.
  /// [chosenContactId] is carried through so the cascade topology can route
  /// to the correct child spec (e.g. selection control for a chosen contact).
  const factory ContactsInfoCassetteSpec.infoCard({
    required ContactsInfoKey key,
    int? chosenContactId,
  }) = ContactsInfoCassetteSpecInfoCard;
}

/// Feature-owned keys that identify informational content meaning for Contacts.
enum ContactsInfoKey {
  /// Shown before a contact is chosen: explains how contacts are listed.
  favouritesVsRecents,

  /// Shown after a contact is chosen: contextual info about the selection.
  chosenContact,
}
