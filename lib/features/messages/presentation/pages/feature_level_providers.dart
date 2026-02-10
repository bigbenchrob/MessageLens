import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';

// =============================================================================
// PUBLIC API — Barrel exports
// =============================================================================

export './application/sidebar_cassette_spec/coordinators/cassette_coordinator.dart';
export './application/view_spec/coordinators/view_spec_coordinator.dart';
export 'infrastructure/repositories/messages_repository_provider.dart';

part 'feature_level_providers.g.dart';

// =============================================================================
// PLACEHOLDER SPECS - Replace with actual Freezed specs when implemented
// =============================================================================

/// Placeholder for MessagesSettingsSpec (sidebar cassettes in settings mode).
/// Replace with: import '../../essentials/sidebar/domain/entities/features/messages_settings_spec.dart';
typedef MessagesSettingsSpec = void;

// =============================================================================
// COORDINATORS (to be relocated to settings_cassette_spec/ in future cleanup)
// =============================================================================

/// Coordinator that maps [MessagesSettingsSpec] to cassette widgets.
@riverpod
class SettingsCassetteSpecCoordinator
    extends _$SettingsCassetteSpecCoordinator {
  @override
  void build() {
    // Stateless coordinator
  }

  /// Build a cassette view model for the given [MessagesSettingsSpec].
  SidebarCassetteCardViewModel buildForSpec(MessagesSettingsSpec spec) {
    // TODO: Implement when MessagesSettingsSpec is defined
    return const SidebarCassetteCardViewModel(
      title: 'Message Settings',
      subtitle: 'Coming soon',
      child: SizedBox.shrink(),
    );
  }
}
