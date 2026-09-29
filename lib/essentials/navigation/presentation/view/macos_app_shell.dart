import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../config/theme/widgets/layout/cross_column_track_plan.dart';
import '../../../../config/theme/widgets/layout/resolved_track_layout_matrix.dart';
import '../../../../features/conversations/presentation/layout/contacts_page_conversation_track_occupants.dart';
import '../../../../features/conversations/presentation/widgets/conversation_signature_card.dart';
import '../../../../features/messages/presentation/layout/contacts_page_message_track_occupants.dart';
import '../../../../features/messages/presentation/layout/recovered_messages_page_track_occupants.dart';
import '../../../../features/messages/presentation/layout/search_page_message_evidence_track_occupants.dart';
import '../../../../features/messages/presentation/layout/unfamiliar_sources_message_track_occupants.dart';
import '../../../../features/sidebar_utilities/domain/sidebar_utilities_constants.dart';
import '../../../app_mode/feature_level_providers.dart'
    show switchableDarkModeProvider;
import '../../../conversation_graph/presentation/status/conversation_graph_status_sheet.dart';
import '../../../debug/feature_level_providers.dart'
    show
        DeveloperModeValue,
        columnBandDebugMarginsProvider,
        developerModeProvider;
import '../../../onboarding/feature_level_providers.dart'
    show onboardingJourneyCoordinatorProvider;
import '../../../onboarding/presentation/advanced_start_fresh_overlay.dart';
import '../../../onboarding/presentation/onboarding_overlay.dart';
import '../../../sidebar/application/sidebar_flow_state_provider.dart';
import '../../application/app_shell_actions_provider.dart';
import '../../application/panel_widget_providers.dart';
import '../../application/sidebar_mode_provider.dart';
import '../../domain/sidebar_mode.dart';
import '../layout/contacts_page_track_plan.dart';
import '../layout/historical_archives_page_track_plan.dart';
import '../layout/message_history_coverage_page_track_plan.dart';
import '../layout/recovered_messages_page_track_plan.dart';
import '../layout/search_page_conversation_track_occupants.dart';
import '../layout/search_page_track_plan.dart';
import '../layout/unfamiliar_sources_page_track_plan.dart';
import '../widgets/app_mode_toggle.dart';
import '../widgets/onboarding_center_panel_sync_observer.dart';
import '../widgets/onboarding_sidebar_visibility_owner.dart';
import 'workspace_layout.dart';

/// macOS window with a fixed navigation column and primary content canvas.
class MacosAppShell extends ConsumerStatefulWidget {
  const MacosAppShell({super.key});

  @override
  ConsumerState<MacosAppShell> createState() => _MacosAppShellState();
}

class _MacosAppShellState extends ConsumerState<MacosAppShell> {
  static const double _toolbarHorizontalPadding = 8.0;
  static const double _toolbarVerticalPadding = 4.0;
  static const double _defaultEndSidebarWidth = 360.0;
  static const double _endSidebarContentHorizontalInset = 32.0;
  static const double _minimumEndSidebarWidth =
      ConversationSignatureCardPresentationMetrics.canonicalWidth +
      (_endSidebarContentHorizontalInset * 2);
  Timer? _windowFrameDebounce;
  final FocusNode _normalSidebarFocusNode = FocusNode(
    debugLabel: 'normal-application-sidebar',
  );
  DateTime _lastFrameSave = DateTime.fromMillisecondsSinceEpoch(0);
  bool _pendingTrailingFrameSave = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _windowFrameDebounce?.cancel();
    _normalSidebarFocusNode.dispose();
    super.dispose();
  }

  void _showConversationGraphStatus() {
    unawaited(
      showMacosSheet<void>(
        context: context,
        barrierDismissible: true,
        builder: (context) => const ConversationGraphStatusSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Capture window size/position after each frame (debounced)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      final elapsed = now.difference(_lastFrameSave).inMilliseconds;

      // Throttle: only allow an immediate save if > 1500ms since last save
      if (elapsed > 1500) {
        _lastFrameSave = now;
        unawaited(
          ref
              .read(appShellActionsProvider.notifier)
              .saveCurrentWindowState(includeSize: false),
        );
        _pendingTrailingFrameSave = false;
      } else {
        // Schedule a trailing save 1600ms after last immediate save
        _pendingTrailingFrameSave = true;
        _windowFrameDebounce?.cancel();
        final delay = 1600 - elapsed;
        _windowFrameDebounce = Timer(Duration(milliseconds: delay), () {
          if (_pendingTrailingFrameSave) {
            _lastFrameSave = DateTime.now();
            _pendingTrailingFrameSave = false;
            unawaited(
              ref
                  .read(appShellActionsProvider.notifier)
                  .saveCurrentWindowState(includeSize: false),
            );
          }
        });
      }
    });

    final onboardingJourney = ref.watch(onboardingJourneyCoordinatorProvider);
    final onboardingStatus = onboardingJourney.compatibilityStatus;
    final showOnboardingOverlay = onboardingJourney.requiresOperationOverlay;
    final activeMode = ref.watch(activeSidebarModeProvider);
    final sidebarFlowState = ref.watch(sidebarFlowProvider);
    final useSearchTrackPlan =
        activeMode == SidebarMode.messages &&
        sidebarFlowState.topMenuChoice == TopChatMenuChoice.searchAllMessages;
    final useUnfamiliarSourcesTrackPlan =
        activeMode == SidebarMode.messages &&
        sidebarFlowState.topMenuChoice == TopChatMenuChoice.strayHandles;
    final useRecoveredMessagesTrackPlan =
        activeMode == SidebarMode.messages &&
        (sidebarFlowState.topMenuChoice ==
                TopChatMenuChoice.recoveredUnlinkedMessages ||
            sidebarFlowState.topMenuChoice ==
                TopChatMenuChoice.recoveredNoHandleFromMeMessages);
    final useContactsTrackPlan =
        activeMode == SidebarMode.messages &&
        sidebarFlowState.topMenuChoice == TopChatMenuChoice.contacts;
    final useHistoricalArchivesTrackPlan =
        activeMode == SidebarMode.settings &&
        sidebarFlowState.persistentSettingsContext ==
            SettingsMenuActionId.historicalArchives;
    final useMessageHistoryCoverageTrackPlan =
        activeMode == SidebarMode.settings &&
        sidebarFlowState.persistentSettingsContext ==
            SettingsMenuActionId.messageHistoryCoverage;
    final SearchPageTrackComposition? searchPageTrackComposition;
    final UnfamiliarSourcesPageTrackComposition?
    unfamiliarSourcesTrackComposition;
    final RecoveredMessagesPageTrackComposition?
    recoveredMessagesTrackComposition;
    final ContactsPageTrackComposition? contactsPageTrackComposition;
    if (useSearchTrackPlan) {
      final typography = ref.watch(themeTypographyProvider);
      ref.watch(themeColorsProvider);
      final colors = ref.read(themeColorsProvider.notifier);
      final presentationConstraints = PresentationConstraints.fromBuildContext(
        context,
        availableWidth: MediaQuery.sizeOf(context).width,
      );
      final centerSpec = ref.watch(
        effectiveCenterPanelSpecProvider(activeMode),
      );
      final rightSpec = ref.watch(effectiveRightPanelSpecProvider(activeMode));
      final messageOccupants = searchPageMessageEvidenceTrackOccupants(
        ref: ref,
        centerSpec: centerSpec,
        colors: colors,
        typography: typography,
        constraints: presentationConstraints,
      );
      final conversationOccupants = searchPageConversationExcerptTrackOccupants(
        ref: ref,
        rightSpec: rightSpec,
        colors: colors,
        typography: typography,
        constraints: presentationConstraints,
      );
      searchPageTrackComposition = composeSearchPageTrackLayout(
        presentationConstraints: presentationConstraints,
        typography: typography,
        centerTitle: messageOccupants.title,
        centerMetadata: messageOccupants.metadata,
        centerSearchControls: messageOccupants.searchControls,
        centerInvestigationStatus: messageOccupants.investigationStatus,
        centerInvestigationStatusMinimumReservedHeight:
            messageOccupants.investigationStatusMinimumReservedHeight,
        rightTitle: conversationOccupants.title,
        rightConversationCardMinimumReservedHeight:
            conversationOccupants.cardMinimumReservedHeight,
        rightConversationCard: conversationOccupants.card,
        rightTemporalOrientation: conversationOccupants.temporalOrientation,
      );
      unfamiliarSourcesTrackComposition = null;
      recoveredMessagesTrackComposition = null;
      contactsPageTrackComposition = null;
    } else {
      searchPageTrackComposition = null;
      if (useUnfamiliarSourcesTrackPlan) {
        final typography = ref.watch(themeTypographyProvider);
        ref.watch(themeColorsProvider);
        final colors = ref.read(themeColorsProvider.notifier);
        final presentationConstraints =
            PresentationConstraints.fromBuildContext(
              context,
              availableWidth: MediaQuery.sizeOf(context).width,
            );
        final centerSpec = ref.watch(
          effectiveCenterPanelSpecProvider(activeMode),
        );
        final messageOccupants = unfamiliarSourcesMessageTrackOccupants(
          ref: ref,
          centerSpec: centerSpec,
          colors: colors,
          typography: typography,
        );
        unfamiliarSourcesTrackComposition =
            composeUnfamiliarSourcesPageTrackLayout(
              presentationConstraints: presentationConstraints,
              typography: typography,
              messageOccupants: messageOccupants,
            );
        recoveredMessagesTrackComposition = null;
        contactsPageTrackComposition = null;
      } else if (useRecoveredMessagesTrackPlan) {
        unfamiliarSourcesTrackComposition = null;
        final typography = ref.watch(themeTypographyProvider);
        final presentationConstraints =
            PresentationConstraints.fromBuildContext(
              context,
              availableWidth: MediaQuery.sizeOf(context).width,
            );
        final messageOccupants = recoveredMessagesPageTrackOccupants(
          onlyNoHandleFromMe:
              sidebarFlowState.topMenuChoice ==
              TopChatMenuChoice.recoveredNoHandleFromMeMessages,
          typography: typography,
        );
        recoveredMessagesTrackComposition =
            composeRecoveredMessagesPageTrackLayout(
              presentationConstraints: presentationConstraints,
              typography: typography,
              topMenuChoice: sidebarFlowState.topMenuChoice,
              messageOccupants: messageOccupants,
            );
        contactsPageTrackComposition = null;
      } else if (useContactsTrackPlan) {
        unfamiliarSourcesTrackComposition = null;
        recoveredMessagesTrackComposition = null;
        final typography = ref.watch(themeTypographyProvider);
        final presentationConstraints =
            PresentationConstraints.fromBuildContext(
              context,
              availableWidth: MediaQuery.sizeOf(context).width,
            );
        final centerSpec = ref.watch(
          effectiveCenterPanelSpecProvider(activeMode),
        );
        final messageOccupants = contactsPageMessageTrackOccupants(
          ref: ref,
          centerSpec: centerSpec,
          typography: typography,
        );
        final conversationOccupants = contactsPageConversationTrackOccupants(
          ref: ref,
          centerSpec: centerSpec,
          typography: typography,
        );
        contactsPageTrackComposition = composeContactsPageTrackLayout(
          presentationConstraints: presentationConstraints,
          typography: typography,
          centerTitle: messageOccupants.title ?? conversationOccupants.title,
        );
      } else {
        unfamiliarSourcesTrackComposition = null;
        recoveredMessagesTrackComposition = null;
        contactsPageTrackComposition = null;
      }
    }

    final HistoricalArchivesPageTrackComposition?
    historicalArchivesTrackComposition;
    if (useHistoricalArchivesTrackPlan) {
      final typography = ref.watch(themeTypographyProvider);
      historicalArchivesTrackComposition =
          composeHistoricalArchivesPageTrackLayout(
            presentationConstraints: PresentationConstraints.fromBuildContext(
              context,
              availableWidth: MediaQuery.sizeOf(context).width,
            ),
            typography: typography,
          );
    } else {
      historicalArchivesTrackComposition = null;
    }

    final MessageHistoryCoveragePageTrackComposition?
    messageHistoryCoverageTrackComposition;
    if (useMessageHistoryCoverageTrackPlan) {
      final typography = ref.watch(themeTypographyProvider);
      messageHistoryCoverageTrackComposition =
          composeMessageHistoryCoveragePageTrackLayout(
            presentationConstraints: PresentationConstraints.fromBuildContext(
              context,
              availableWidth: MediaQuery.sizeOf(context).width,
            ),
            typography: typography,
          );
    } else {
      messageHistoryCoverageTrackComposition = null;
    }

    final onboardingOwnsSidebar = onboardingOwnsNormalSidebar(onboardingStatus);

    Widget window = MacosWindow(
      sidebar: Sidebar(
        key: const ValueKey<String>('normal-application-sidebar'),
        startWidth: WorkspaceLayout.navigationColumnWidth,
        minWidth: WorkspaceLayout.navigationColumnWidth,
        maxWidth: 400,
        windowBreakpoint: 0,
        shownByDefault: !onboardingOwnsSidebar,
        topOffset: 0,
        top: SizedBox(
          // macos_ui contributes 12 px before a non-null top widget. Keeping
          // this at 39 px makes native sidebar content begin at the 51 px
          // toolbar boundary without a second layout offset.
          height: 39,
          child: Center(
            child: Focus(
              focusNode: _normalSidebarFocusNode,
              child: const AppModeToggle(),
            ),
          ),
        ),
        builder: (context, scrollController) {
          return IndexedStack(
            index: activeMode == SidebarMode.messages ? 0 : 1,
            children: const <Widget>[
              WorkspaceSidebar(mode: SidebarMode.messages),
              WorkspaceSidebar(mode: SidebarMode.settings),
            ],
          );
        },
      ),
      endSidebar: Sidebar(
        key: ValueKey<String>('end-sidebar-${activeMode.name}'),
        startWidth: _defaultEndSidebarWidth,
        minWidth: _minimumEndSidebarWidth,
        maxWidth: 520,
        shownByDefault: false,
        builder: (context, scrollController) {
          return RightPanelHost(mode: activeMode);
        },
      ),
      child: MacosScaffold(
        toolBar: ToolBar(
          // Position mode toggle above sidebar, other controls above center panel.
          padding: const EdgeInsets.only(
            left: _toolbarHorizontalPadding,
            right: _toolbarHorizontalPadding,
            top: _toolbarVerticalPadding,
            bottom: _toolbarVerticalPadding,
          ),
          title: const _ToolbarTitle(),
          centerTitle: true,
          actions: [
            if (kDebugMode)
              ToolBarIconButton(
                label: 'Conversation graph status',
                icon: const MacosIcon(CupertinoIcons.waveform_path_ecg),
                onPressed: _showConversationGraphStatus,
                showLabel: false,
              ),
            if (kDebugMode)
              () {
                final developerMode = ref.watch(developerModeProvider);
                final isDeveloperMode =
                    developerMode.valueOrNull == DeveloperModeValue.developer;
                return ToolBarIconButton(
                  label: isDeveloperMode
                      ? 'Developer mode enabled'
                      : 'Developer mode disabled',
                  icon: MacosIcon(
                    isDeveloperMode
                        ? CupertinoIcons.hammer_fill
                        : CupertinoIcons.hammer,
                  ),
                  onPressed: () {
                    unawaited(
                      ref
                          .read(appShellActionsProvider.notifier)
                          .toggleDeveloperMode(),
                    );
                  },
                  showLabel: false,
                );
              }(),
            if (kDebugMode &&
                ref.watch(developerModeProvider).valueOrNull ==
                    DeveloperModeValue.developer)
              () {
                final marginsVisible = ref.watch(
                  columnBandDebugMarginsProvider,
                );
                return ToolBarIconButton(
                  label: marginsVisible
                      ? 'Hide layout band margins'
                      : 'Show layout band margins',
                  icon: MacosIcon(
                    marginsVisible ? Icons.border_outer : Icons.border_clear,
                  ),
                  onPressed: () {
                    ref
                        .read(appShellActionsProvider.notifier)
                        .toggleColumnBandDebugMargins();
                  },
                  showLabel: false,
                );
              }(),
            () {
              final themeMode = ref.watch(switchableDarkModeProvider);
              final (IconData icon, String tooltip) = switch (themeMode) {
                ThemeMode.system => (
                  CupertinoIcons.circle_lefthalf_fill,
                  'Theme: System (click to switch to Light)',
                ),
                ThemeMode.light => (
                  CupertinoIcons.sun_max_fill,
                  'Theme: Light (click to switch to Dark)',
                ),
                ThemeMode.dark => (
                  CupertinoIcons.moon_stars_fill,
                  'Theme: Dark (click to switch to System)',
                ),
              };
              return ToolBarIconButton(
                label: tooltip,
                icon: MacosIcon(icon),
                onPressed: () {
                  ref.read(appShellActionsProvider.notifier).cycleThemeMode();
                },
                showLabel: false,
              );
            }(),
          ],
        ),
        children: [
          ContentArea(
            builder: (context, scrollController) {
              return Stack(
                children: [
                  IndexedStack(
                    index: activeMode == SidebarMode.messages ? 0 : 1,
                    children: const <Widget>[
                      WorkspaceContent(mode: SidebarMode.messages),
                      WorkspaceContent(mode: SidebarMode.settings),
                    ],
                  ),
                  OnboardingSidebarVisibilityOwner(
                    status: onboardingStatus,
                    onNormalApplicationRevealed: () {
                      _normalSidebarFocusNode.requestFocus();
                    },
                  ),
                  const OnboardingCenterPanelSyncObserver(),
                  _EndSidebarSyncObserver(mode: activeMode),
                ],
              );
            },
          ),
        ],
      ),
    );
    final resolvedTrackMatrix =
        searchPageTrackComposition?.resolvedMatrix ??
        unfamiliarSourcesTrackComposition?.resolvedMatrix ??
        recoveredMessagesTrackComposition?.resolvedMatrix ??
        contactsPageTrackComposition?.resolvedMatrix ??
        historicalArchivesTrackComposition?.resolvedMatrix ??
        messageHistoryCoverageTrackComposition?.resolvedMatrix;
    if (resolvedTrackMatrix != null) {
      window = ResolvedTrackLayoutMatrixScope(
        matrix: resolvedTrackMatrix,
        child: window,
      );
    }

    return Stack(
      children: <Widget>[
        window,
        if (showOnboardingOverlay) const OnboardingOverlay(),
        const AdvancedStartFreshOverlayHost(),
      ],
    );
  }
}

class _EndSidebarSyncObserver extends ConsumerWidget {
  const _EndSidebarSyncObserver({required this.mode});

  final SidebarMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shouldShow = ref.watch(shouldShowEndSidebarProvider(mode));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) {
        return;
      }

      final scope = MacosWindowScope.of(context);
      if (scope.isEndSidebarShown != shouldShow) {
        scope.toggleEndSidebar();
        unawaited(
          ref
              .read(appShellActionsProvider.notifier)
              .animateEndSidebarWindowWidth(
                showing: shouldShow,
                sidebarWidth: _MacosAppShellState._defaultEndSidebarWidth,
              ),
        );
      }
    });

    return const SizedBox.shrink();
  }
}

class _ToolbarTitle extends StatelessWidget {
  const _ToolbarTitle();

  static const String _toolbarIconAsset =
      'assets/branding/message_lens_toolbar_icon.png';

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          _toolbarIconAsset,
          width: 18,
          height: 18,
          filterQuality: FilterQuality.high,
        ),
        const SizedBox(width: 8),
        const Text('MessageLens'),
      ],
    );
  }
}
