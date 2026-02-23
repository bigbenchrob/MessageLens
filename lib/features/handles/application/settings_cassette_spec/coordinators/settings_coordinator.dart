import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/domain/entities/features/handles_settings_spec.dart';
import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../resolvers/manual_linking_resolver.dart';
import '../resolvers/spam_management_resolver.dart';

part 'settings_coordinator.g.dart';

/// Handles Settings Cassette Coordinator
///
/// Routes [HandlesSettingsSpec] variants to their respective resolvers.
/// This coordinator is the entry point for handles-related settings cassettes.
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// - Receives a [HandlesSettingsSpec]
/// - Pattern-matches on the spec
/// - Calls exactly ONE resolver
/// - Returns the resolver's `Future<SidebarCassetteCardViewModel>`
@riverpod
class HandlesSettingsCoordinator extends _$HandlesSettingsCoordinator {
  @override
  void build() {
    // Stateless coordinator
  }

  /// Build a cassette view model for the given [HandlesSettingsSpec].
  Future<SidebarCassetteCardViewModel> buildViewModel(
    HandlesSettingsSpec spec,
  ) async {
    return spec.map(
      manualLinking: (_) =>
          ref.read(manualLinkingResolverProvider.notifier).resolve(),
      spamManagement: (_) =>
          ref.read(spamManagementResolverProvider.notifier).resolve(),
    );
  }
}
