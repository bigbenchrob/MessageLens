import 'package:freezed_annotation/freezed_annotation.dart';

part 'contacts_tooltip_spec.freezed.dart';

/// ContactsTooltipSpec - Feature-level tooltip specification
///
/// Defines all tooltip keys used within the contacts feature.
/// Resolvers interpret these keys and return display text.
///
/// ## Usage
///
/// ```dart
/// TooltipSpec.contacts(ContactsTooltipSpec.editDisplayName())
/// ```
@freezed
sealed class ContactsTooltipSpec with _$ContactsTooltipSpec {
  const ContactsTooltipSpec._();

  /// Tooltip for the edit display name icon in the hero card
  const factory ContactsTooltipSpec.editDisplayName() = EditDisplayNameTooltip;

  // Future tooltips:
  // const factory ContactsTooltipSpec.favoriteContact() = FavoriteContactTooltip;
  // const factory ContactsTooltipSpec.viewAllChats() = ViewAllChatsTooltip;
}
