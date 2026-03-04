import 'package:freezed_annotation/freezed_annotation.dart';

part 'handles_info_cassette_spec.freezed.dart';

/// Sidebar-surface spec for Handles "info" cassettes.
///
/// IMPORTANT:
/// - This is a *sidebar protocol* entity, so it lives under `essentials/sidebar/...`.
/// - It does NOT contain explanatory text directly.
/// - It carries only a *feature-owned key* that the Handles feature will resolve
///   into surface-agnostic InfoContent.
///
/// This allows:
/// - centralized spec routing (CassetteSpec.* variants)
/// - feature-owned meaning (HandlesInfoContentResolver)
/// - reuse of the same key for future surfaces (tooltips/onboarding) without changing
///   this cassette spec unless the sidebar needs new variants.
///
/// When to add new variants here:
/// - Only when the sidebar needs a structurally different kind of "info cassette"
///   (e.g., a warning banner vs. an info card, or something with actions).
/// - If the only change is wording/data, add a new key instead.
@freezed
abstract class HandlesInfoCassetteSpec with _$HandlesInfoCassetteSpec {
  const HandlesInfoCassetteSpec._();

  /// Request an informational card.
  ///
  /// The `key` identifies the meaning; the Handles feature will resolve it.
  /// The `childVariant` specifies which cassette follows the info card.
  const factory HandlesInfoCassetteSpec.infoCard({
    required HandlesInfoKey key,
    required HandlesCassetteChildVariant childVariant,
  }) = HandlesInfoCassetteSpecInfoCard;
}

/// Feature-owned keys that identify informational content meaning for Handles.
///
/// NOTE:
/// This enum is referenced by a sidebar protocol spec, but its values are owned by the
/// Handles feature. Keeping it here is acceptable because:
/// - it is still "meaning-level", not UI-level
/// - it allows the spec to remain lightweight
///
/// Alternative (later):
/// - Move this enum into the Handles feature and reference it here by import.
/// - That is a larger migration because essentials then depends on feature code.
/// For now, keep it here to avoid circular dependencies.
enum HandlesInfoKey {
  /// Explanation for stray emails section
  strayEmailsExplanation,

  /// Explanation for stray phone numbers section
  strayPhoneNumbersExplanation,
}

/// Variants for child cassettes that can follow a handles info card.
///
/// This enum is shared between HandlesInfoCassetteSpec and the topology layer.
enum HandlesCassetteChildVariant {
  /// List of stray phone numbers
  strayPhoneNumbers,

  /// List of stray emails
  strayEmails,
}
