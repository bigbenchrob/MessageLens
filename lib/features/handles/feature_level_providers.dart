import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../essentials/sidebar/domain/entities/features/handles_cassette_spec.dart';
import '../../essentials/sidebar/domain/entities/features/handles_settings_spec.dart';
import '../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import 'application/cassette_builders/stray_emails_cassette_builder_provider.dart';
import 'application/cassette_builders/stray_handles_mode_switcher_cassette_builder_provider.dart';
import 'application/cassette_builders/stray_handles_review_cassette_builder_provider.dart';
import 'application/cassette_builders/stray_phone_numbers_cassette_builder_provider.dart';
import 'application/cassette_builders/unmatched_handles_cassette_builder_provider.dart';
import 'application/settings/manual_linking_cassette_builder_provider.dart';
import 'application/settings/spam_management_cassette_builder_provider.dart';
import 'application/state/stray_handle_mode_provider.dart';

// Export coordinator for Handles info cassettes (cross-surface spec pattern)
export 'application/spec_coordinators/info_cassette_coordinator.dart';

part 'feature_level_providers.g.dart';

// =============================================================================
// PLACEHOLDER SPECS - Replace with actual Freezed specs when implemented
// =============================================================================

/// Placeholder for HandlesSpec (ViewSpec for center panel).
/// Replace with: import '../../essentials/navigation/domain/entities/features/handles_spec.dart';
typedef HandlesSpec = void;

// =============================================================================
// COORDINATORS
// =============================================================================

/// Coordinator that maps [HandlesSpec] to rendered widgets for the center panel.
@riverpod
class ViewSpecCoordinator extends _$ViewSpecCoordinator {
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

/// Coordinator that maps [HandlesCassetteSpec] to cassette widgets.
@riverpod
class FeatureCassetteSpecCoordinator extends _$FeatureCassetteSpecCoordinator {
  @override
  void build() {
    // Stateless coordinator
  }

  SidebarCassetteCardViewModel buildForSpec(
    HandlesCassetteSpec spec, {
    required int cassetteIndex,
  }) {
    return spec.when(
      unmatchedHandlesList: (_) =>
          ref.read(unmatchedHandlesCassetteBuilderProvider),
      strayPhoneNumbers: () =>
          ref.read(strayPhoneNumbersCassetteBuilderProvider),
      strayEmails: () => ref.read(strayEmailsCassetteBuilderProvider),
      strayHandlesReview: (filter, _) {
        // Read mode from global provider (mode switcher controls this)
        final mode = ref.watch(strayHandleModeSettingProvider);
        return ref.read(
          strayHandlesReviewCassetteBuilderProvider(filter: filter, mode: mode),
        );
      },
      strayHandlesModeSwitcher: (filter) => ref.read(
        strayHandlesModeSwitcherCassetteBuilderProvider(filter: filter),
      ),
    );
  }
}

/// Coordinator that maps [HandlesSettingsSpec] to cassette widgets.
@riverpod
class SettingsCassetteSpecCoordinator
    extends _$SettingsCassetteSpecCoordinator {
  @override
  void build() {
    // Stateless coordinator
  }

  /// Build a cassette view model for the given [HandlesSettingsSpec].
  SidebarCassetteCardViewModel buildForSpec(HandlesSettingsSpec spec) {
    return spec.when(
      manualLinking: () => ref.read(manualLinkingCassetteBuilderProvider),
      spamManagement: () => ref.read(spamManagementCassetteBuilderProvider),
    );
  }
}
