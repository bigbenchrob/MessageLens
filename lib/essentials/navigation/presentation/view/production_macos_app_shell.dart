import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../onboarding/feature_level_providers.dart'
    show onboardingJourneyCoordinatorProvider;
import '../../../onboarding/presentation/advanced_start_fresh_overlay.dart';
import '../../../onboarding/presentation/onboarding_overlay.dart';
import '../widgets/onboarding_center_panel_sync_observer.dart';
import '../widgets/onboarding_sidebar_visibility_owner.dart';
import 'macos_app_shell.dart';

/// Production onboarding decoration around the neutral workspace shell.
///
/// The exact-development AppCzar route never imports or mounts this wrapper.
class MacosAppShell extends ConsumerWidget {
  const MacosAppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journey = ref.watch(onboardingJourneyCoordinatorProvider);
    final status = journey.compatibilityStatus;

    return MessageLensWorkspaceShell(
      normalSidebarShownByDefault: !onboardingOwnsNormalSidebar(status),
      showConversationGraphStatusAction: true,
      sidebarVisibilityOwnerBuilder: (requestNormalSidebarFocus) {
        return OnboardingSidebarVisibilityOwner(
          status: status,
          onNormalApplicationRevealed: requestNormalSidebarFocus,
        );
      },
      centerOverlayObservers: const <Widget>[
        OnboardingCenterPanelSyncObserver(),
      ],
      fullWindowOverlays: <Widget>[
        if (journey.requiresOperationOverlay) const OnboardingOverlay(),
        const AdvancedStartFreshOverlayHost(),
      ],
    );
  }
}
