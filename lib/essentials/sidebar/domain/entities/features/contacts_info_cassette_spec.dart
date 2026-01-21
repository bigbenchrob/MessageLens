import 'package:freezed_annotation/freezed_annotation.dart';

part 'contacts_info_cassette_spec.freezed.dart';

/// Sidebar-surface spec for Contacts "info" cassettes.
///
/// IMPORTANT:
/// - This is a *sidebar protocol* entity, so it lives under `essentials/sidebar/...`.
/// - It does NOT contain explanatory text directly.
/// - It carries only a *feature-owned key* that the Contacts feature will resolve
///   into surface-agnostic InfoContent.
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
  const factory ContactsInfoCassetteSpec.infoCard({
    required ContactsInfoKey key,
  }) = ContactsInfoCassetteSpecInfoCard;
}

/// Feature-owned keys that identify informational content meaning for Contacts.
///
/// NOTE:
/// This enum is referenced by a sidebar protocol spec, but its values are owned by the
/// Contacts feature. Keeping it here is acceptable because:
/// - it is still "meaning-level", not UI-level
/// - it allows the spec to remain lightweight
///
/// Alternative (later):
/// - Move this enum into the Contacts feature and reference it here by import.
/// - That is a larger migration because essentials then depends on feature code.
/// For now, keep it here to avoid circular dependencies.
enum ContactsInfoKey { favouritesVsRecents }
