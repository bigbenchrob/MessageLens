import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../features/contacts/domain/spec_classes/contacts_tooltip_spec.dart';

part 'tooltip_spec.freezed.dart';

/// TooltipSpec - Sealed class for type-safe tooltip routing
///
/// Each feature that uses tooltips has a dedicated variant. The essentials-level
/// [TooltipCoordinator] pattern-matches on these variants and routes to the
/// appropriate feature coordinator.
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// Specs are **declarative requests** that travel from widget to coordinator.
/// - Coordinators route specs to resolvers
/// - Resolvers interpret specs and return content
/// - Widget builders display resolved content
///
/// ## Adding a New Feature's Tooltips
///
/// 1. Create `{feature}_tooltip_spec.dart` in feature's domain/spec_classes/
/// 2. Add a variant here: `const factory TooltipSpec.{feature}(...)`
/// 3. Update [TooltipCoordinator] to handle the new variant
@freezed
sealed class TooltipSpec with _$TooltipSpec {
  const TooltipSpec._();

  /// Contacts feature tooltips (hero card edit, etc.)
  const factory TooltipSpec.contacts(ContactsTooltipSpec spec) =
      ContactsTooltip;

  // Future variants:
  // const factory TooltipSpec.messages(MessagesTooltipSpec spec) = MessagesTooltip;
  // const factory TooltipSpec.handles(HandlesTooltipSpec spec) = HandlesTooltip;
}
