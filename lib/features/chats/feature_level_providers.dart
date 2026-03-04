import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';

// Export infrastructure providers
export './infrastructure/chats_repository_provider.dart';

part 'feature_level_providers.g.dart';

// =============================================================================
// PLACEHOLDER SPECS - Replace with actual Freezed specs when implemented
// =============================================================================

/// Placeholder for ChatsCassetteSpec (sidebar cassettes in messages mode).
/// Replace with: import '../../essentials/sidebar/domain/entities/features/chats_cassette_spec.dart';
typedef ChatsCassetteSpec = void;

/// Placeholder for ChatsSettingsSpec (sidebar cassettes in settings mode).
/// Replace with: import '../../essentials/sidebar/domain/entities/features/chats_settings_spec.dart';
typedef ChatsSettingsSpec = void;

// =============================================================================
// COORDINATORS
// =============================================================================

/// Coordinator that maps [ChatsCassetteSpec] to cassette widgets.
@riverpod
class FeatureCassetteSpecCoordinator extends _$FeatureCassetteSpecCoordinator {
  @override
  void build() {
    // Stateless coordinator
  }

  /// Build a cassette view model for the given [ChatsCassetteSpec].
  SidebarCassetteCardViewModel buildForSpec(ChatsCassetteSpec spec) {
    // TODO: Implement when ChatsCassetteSpec is defined
    return const SidebarCassetteCardViewModel(
      title: 'Chats',
      subtitle: 'Coming soon',
      child: SizedBox.shrink(),
    );
  }
}

/// Coordinator that maps [ChatsSettingsSpec] to cassette widgets.
@riverpod
class SettingsCassetteSpecCoordinator
    extends _$SettingsCassetteSpecCoordinator {
  @override
  void build() {
    // Stateless coordinator
  }

  /// Build a cassette view model for the given [ChatsSettingsSpec].
  SidebarCassetteCardViewModel buildForSpec(ChatsSettingsSpec spec) {
    // TODO: Implement when ChatsSettingsSpec is defined
    return const SidebarCassetteCardViewModel(
      title: 'Chat Settings',
      subtitle: 'Coming soon',
      child: SizedBox.shrink(),
    );
  }
}
