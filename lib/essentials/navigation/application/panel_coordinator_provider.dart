import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../features/conversations/feature_level_providers.dart'
    as conversations_feature
    show viewSpecCoordinatorProvider;
import '../../../features/environment_readiness/feature_level_providers.dart'
    as environment_readiness_feature
    show viewSpecCoordinatorProvider;
import '../../../features/messages/feature_level_providers.dart'
    as messages_feature
    show viewSpecCoordinatorProvider;
import '../../../features/settings/feature_level_providers.dart'
    as settings_feature
    show SettingsPanelRenderRouter, viewSpecCoordinatorProvider;
import '../../onboarding/domain/spec_classes/onboarding_view_spec.dart';
import '../../onboarding/presentation/onboarding_dev_panel.dart';
import '../domain/entities/panel_stack.dart';
import '../domain/entities/view_spec.dart';
import '../domain/navigation_constants.dart';
import '../domain/sidebar_mode.dart';
import '../presentation/view/panel_stack_surface.dart';

part 'panel_coordinator_provider.g.dart';

/// Coordinator that maps panel ViewSpecs to rendered widgets
@riverpod
class PanelCoordinator extends _$PanelCoordinator {
  @override
  void build(SidebarMode mode) {}

  Widget buildPanelSurface(WindowPanel panel, PanelStack stack) {
    return PanelStackSurface(
      panel: panel,
      stack: stack,
      buildPanel: buildForPage,
      placeholder: _buildEmptyPanelPlaceholder(panel),
    );
  }

  Widget buildForPage(PanelPage page) {
    return buildForSpec(page.spec);
  }

  Widget buildForSpec(ViewSpec spec) {
    return spec.when(
      messages: (messagesSpec) => ref
          .read(messages_feature.viewSpecCoordinatorProvider.notifier)
          .buildForSpec(messagesSpec),
      conversations: (conversationsSpec) => ref
          .read(conversations_feature.viewSpecCoordinatorProvider.notifier)
          .buildForSpec(conversationsSpec),
      settings: (settingsSpec) {
        final descriptor = ref
            .read(settings_feature.viewSpecCoordinatorProvider.notifier)
            .resolveForSpec(settingsSpec);
        return const settings_feature.SettingsPanelRenderRouter().build(
          descriptor,
        );
      },
      environmentReadiness: (readinessSpec) => ref
          .read(
            environment_readiness_feature.viewSpecCoordinatorProvider.notifier,
          )
          .buildForSpec(readinessSpec),
      onboarding: (onboardingSpec) =>
          onboardingSpec.when(devPanel: () => const OnboardingDevPanel()),
    );
  }

  /// Placeholder for empty panels
  Widget _buildEmptyPanelPlaceholder(WindowPanel panel) {
    return const SizedBox.shrink();
  }
}
