import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../features/contacts/feature_level_providers.dart'
    as contacts_feature;
import '../domain/entities/tooltip_spec.dart';

part 'tooltip_coordinator.g.dart';

/// TooltipCoordinator - Routes tooltip specs to feature coordinators
///
/// This is the essentials-level entry point for tooltip resolution.
/// It pattern-matches on [TooltipSpec] variants and delegates to the
/// appropriate feature-level coordinator.
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// Coordinators:
/// - Receive specs
/// - Pattern-match on variants
/// - Route to owning feature's coordinator
/// - Return resolved content
///
/// The coordinator MUST NOT:
/// - Perform IO
/// - Construct widgets
/// - Interpret spec semantics (that's the resolver's job)
@riverpod
class TooltipCoordinator extends _$TooltipCoordinator {
  @override
  void build() {
    // Stateless coordinator
  }

  /// Resolve a tooltip spec to display text.
  ///
  /// Routes to the appropriate feature coordinator based on spec type.
  Future<String> resolve(TooltipSpec spec) {
    return spec.when(
      contacts: (contactsSpec) {
        final coordinator = ref.read(
          contacts_feature.contactsTooltipCoordinatorProvider.notifier,
        );
        return coordinator.resolve(contactsSpec);
      },
      // Future handlers:
      // messages: (messagesSpec) => ...
      // handles: (handlesSpec) => ...
    );
  }
}
