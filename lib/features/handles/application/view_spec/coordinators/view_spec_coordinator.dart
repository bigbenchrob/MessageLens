import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'view_spec_coordinator.g.dart';

// =============================================================================
// PLACEHOLDER - Replace with actual HandlesSpec when implemented
// =============================================================================

/// Placeholder for HandlesSpec (ViewSpec for center panel).
/// Replace with: import '../../../../../essentials/navigation/domain/entities/features/handles_spec.dart';
typedef HandlesSpec = void;

/// Handles View Spec Coordinator
///
/// Routes [HandlesSpec] to rendered widgets for the center panel.
/// This is a placeholder until HandlesSpec is properly defined.
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// - Receives a [HandlesSpec]
/// - Pattern-matches on the spec
/// - Calls exactly ONE resolver
/// - Returns a Widget
@riverpod
class HandlesViewSpecCoordinator extends _$HandlesViewSpecCoordinator {
  @override
  void build() {
    // Stateless coordinator
  }

  /// Build a widget for the given [HandlesSpec].
  Widget buildForSpec(HandlesSpec spec) {
    // TODO: Implement when HandlesSpec is defined
    return _buildPlaceholder('Handles view coming soon');
  }

  Widget _buildPlaceholder(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}
