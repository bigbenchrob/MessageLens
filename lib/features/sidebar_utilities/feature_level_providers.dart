import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../essentials/sidebar/domain/entities/features/sidebar_utility_cassette_spec.dart';
import '../../essentials/sidebar/domain/entities/features/sidebar_utility_settings_spec.dart';
import '../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import './application/cassette_builders/settings_top_menu_builder_provider.dart';
import './application/cassette_builders/top_chat_menu_builder_provider.dart';

part 'feature_level_providers.g.dart';

// =============================================================================
// COORDINATORS
// =============================================================================

/// Coordinator that maps [SidebarUtilityCassetteSpec] to cassette widgets
/// for messages mode (topChatMenu).
@riverpod
class FeatureCassetteSpecCoordinator extends _$FeatureCassetteSpecCoordinator {
  @override
  void build() {
    // Stateless coordinator
  }

  /// Build a widget for the given [spec].
  SidebarCassetteCardViewModel buildForSpec(SidebarUtilityCassetteSpec spec) {
    return spec.when(
      topChatMenu: (selectedChoice) {
        final content = ref.read(topChatMenuBuilderProvider(spec));
        return SidebarCassetteCardViewModel(
          title: '',
          child: content,
          isNaked: true,
        );
      },
    );
  }
}

/// Coordinator that maps [SidebarUtilitySettingsSpec] to cassette widgets
/// for settings mode.
@riverpod
class SettingsCassetteSpecCoordinator
    extends _$SettingsCassetteSpecCoordinator {
  @override
  void build() {
    // Stateless coordinator
  }

  /// Build a widget for the given [spec].
  SidebarCassetteCardViewModel buildForSpec(SidebarUtilitySettingsSpec spec) {
    return spec.when(
      settingsMenu: (selectedChoice) {
        final content = ref.read(settingsTopMenuBuilderProvider(spec));
        return SidebarCassetteCardViewModel(
          title: '',
          child: content,
          isNaked: true,
        );
      },
    );
  }
}
