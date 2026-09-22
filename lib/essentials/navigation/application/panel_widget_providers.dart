import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/theme/widgets/layout/cross_column_track_plan.dart';
import '../../../config/theme/widgets/layout/page_track_layout_matrix.dart';
import '../../../config/theme/widgets/layout/resolved_track_layout_matrix.dart';
import '../../../features/conversations/domain/spec_classes/conversations_view_spec.dart';
import '../../../features/messages/domain/spec_classes/messages_view_spec.dart';
import '../../../features/messages/feature_level_providers.dart'
    as messages_feature
    show currentSearchInvestigationProvider, recoveredMessagesSidebarProvider;
import '../../../features/settings/domain/spec_classes/settings_cassette_spec.dart';
import '../../../features/settings/domain/spec_classes/settings_view_spec.dart';
import '../../../features/sidebar_utilities/domain/sidebar_utilities_constants.dart';
import '../../../features/sidebar_utilities/domain/spec_classes/sidebar_utility_cassette_spec.dart';
import '../../logging/feature_level_providers.dart' show appLoggerProvider;
import '../../sidebar/application/cassette_rack_state_provider.dart';
import '../../sidebar/application/cassette_widget_coordinator_provider.dart';
import '../../sidebar/application/sidebar_cassette_render_router.dart';
import '../../sidebar/application/sidebar_cassette_sectioning.dart';
import '../../sidebar/application/sidebar_flow_state_provider.dart';
import '../../sidebar/domain/entities/cassette_spec.dart';
import '../../sidebar/presentation/view/sidebar_grouped_control_section_surface.dart';
import '../../sidebar/presentation/view/sidebar_primary_context_section_surface.dart';
import '../../sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../domain/entities/investigation_identity.dart';
import '../domain/entities/panel_stack.dart';
import '../domain/entities/view_spec.dart';
import '../domain/navigation_constants.dart';
import '../domain/sidebar_mode.dart';
import './panel_coordinator_provider.dart';
import 'panels_view_state_provider.dart';

part 'panel_widget_providers.g.dart';

bool isPinnedAppControlCassette(ResolvedSidebarCassette resolvedCassette) {
  return resolvedCassette.payload.role == SidebarCassetteRole.appControl;
}

bool shouldExpandSidebarCassette(ResolvedSidebarCassette resolvedCassette) {
  return switch (resolvedCassette.payload) {
    PlacementGovernedSidebarCassettePayload(:final shouldExpand) =>
      shouldExpand,
    SharedBodyModelSidebarCassettePayload(:final shouldExpand) => shouldExpand,
    SidebarCassettePayload() => false,
  };
}

@riverpod
PanelStack effectiveCenterPanelStack(Ref ref, SidebarMode mode) {
  final centerStack = ref.watch(
    panelsViewStateProvider(mode).select(
      (stacks) => stacks[WindowPanel.center] ?? const PanelStack.empty(),
    ),
  );

  if (mode != SidebarMode.messages && mode != SidebarMode.settings) {
    return centerStack;
  }

  final flowState = ref.watch(sidebarFlowProvider);
  final projectedCenterSpec = flowState.projectedCenterSpecForMode(mode);

  return _resolveEffectiveCenterStack(
    ref: ref,
    flowState: flowState,
    centerStack: centerStack,
    projectedCenterSpec: projectedCenterSpec,
  );
}

@riverpod
ViewSpec? effectiveCenterPanelSpec(Ref ref, SidebarMode mode) {
  final stack = ref.watch(effectiveCenterPanelStackProvider(mode));
  return stack.activePage?.spec;
}

@riverpod
PanelStack effectiveRightPanelStack(Ref ref, SidebarMode mode) {
  final rightStack = ref.watch(
    panelsViewStateProvider(
      mode,
    ).select((stacks) => stacks[WindowPanel.right] ?? const PanelStack.empty()),
  );

  if (mode != SidebarMode.messages) {
    return rightStack;
  }

  final flowState = ref.watch(sidebarFlowProvider);
  final effectiveCenterSpec = ref.watch(effectiveCenterPanelSpecProvider(mode));
  final currentSearchInvestigationId = ref.watch(
    messages_feature.currentSearchInvestigationProvider,
  );
  if (_shouldHideStoredRightPanel(
    flowState: flowState,
    centerSpec: effectiveCenterSpec,
    rightStack: rightStack,
    currentSearchInvestigationId: currentSearchInvestigationId,
  )) {
    return const PanelStack.empty();
  }

  return rightStack;
}

@riverpod
ViewSpec? effectiveRightPanelSpec(Ref ref, SidebarMode mode) {
  final stack = ref.watch(effectiveRightPanelStackProvider(mode));
  return stack.activePage?.spec;
}

/// Whether the center panel is showing content that operates independently
/// of the sidebar (e.g. maintenance, diagnostics, workbench).
///
/// When true, the sidebar should display a contextual overlay with a
/// dismiss action rather than the cassette rack.
@riverpod
bool isSidebarParked(Ref ref, SidebarMode mode) {
  final spec = ref.watch(effectiveCenterPanelSpecProvider(mode));
  if (spec == null) {
    return false;
  }
  return spec.isSidebarIndependent;
}

/// Widget provider for center panel
@riverpod
Widget centerPanelWidget(Ref ref, SidebarMode mode) {
  final stack = ref.watch(effectiveCenterPanelStackProvider(mode));
  return ref
      .read(panelCoordinatorProvider(mode).notifier)
      .buildPanelSurface(WindowPanel.center, stack);
}

@riverpod
Widget rightPanelWidget(Ref ref, SidebarMode mode) {
  final stack = ref.watch(effectiveRightPanelStackProvider(mode));
  return ref
      .read(panelCoordinatorProvider(mode).notifier)
      .buildPanelSurface(WindowPanel.right, stack);
}

@riverpod
bool shouldShowEndSidebar(Ref ref, SidebarMode mode) {
  if (mode != SidebarMode.messages) {
    return false;
  }

  final rightStack = ref.watch(effectiveRightPanelStackProvider(mode));
  return !rightStack.isEmpty;
}

@riverpod
Widget? contextualSidebarWidget(Ref ref, SidebarMode mode) {
  if (mode != SidebarMode.messages) {
    return null;
  }

  final flowState = ref.watch(sidebarFlowProvider);
  final centerSpec = ref.watch(effectiveCenterPanelSpecProvider(mode));

  if (centerSpec == null) {
    return null;
  }

  return centerSpec.when(
    messages: (messagesSpec) {
      return messagesSpec.mapOrNull(
        recoveredUnlinkedMessages: (spec) {
          if (!_shouldShowRecoveredContextFor(flowState)) {
            return null;
          }

          final effectiveContactId = flowState.isContactsBranch
              ? flowState.chosenContactId
              : spec.contactId;

          return ref.watch(
            messages_feature.recoveredMessagesSidebarProvider(
              contactId: effectiveContactId,
              scrollToDate: spec.scrollToDate,
            ),
          );
        },
        recoveredNoHandleFromMeMessages: (spec) => ref.watch(
          messages_feature.recoveredMessagesSidebarProvider(
            onlyNoHandleFromMe: true,
            scrollToDate: spec.scrollToDate,
          ),
        ),
      );
    },
    conversations: (_) => null,
    settings: (_) => null,
    environmentReadiness: (_) => null,
    onboarding: (_) => null,
  );
}

bool _supportsRecoveredAttachmentSidebar(ViewSpec? spec) {
  if (spec == null) {
    return false;
  }

  return spec.maybeWhen(
    messages: (messagesSpec) {
      return messagesSpec.maybeWhen(
        forContact: (_, __, ___) => true,
        globalTimeline: (_) => true,
        recoveredUnlinkedMessages: (_, __) => true,
        recoveredNoHandleFromMeMessages: (_) => true,
        orElse: () => false,
      );
    },
    orElse: () => false,
  );
}

bool _shouldShowRecoveredContextFor(SidebarFlowState flowState) {
  if (flowState.topMenuChoice == TopChatMenuChoice.recoveredUnlinkedMessages ||
      flowState.topMenuChoice ==
          TopChatMenuChoice.recoveredNoHandleFromMeMessages) {
    return true;
  }

  return flowState.topMenuChoice == TopChatMenuChoice.contacts &&
      flowState.messageScope == SidebarFlowMessageScope.recoveredDeleted &&
      flowState.chosenContactId != null;
}

/// Stored panel state may survive temporary incompatibility. This resolver
/// derives whether that state is currently effective without mutating it.
bool _shouldHideStoredRightPanel({
  required SidebarFlowState flowState,
  required ViewSpec? centerSpec,
  required PanelStack rightStack,
  required InvestigationIdentity currentSearchInvestigationId,
}) {
  final rightSpec = rightStack.activePage?.spec;
  if (rightSpec == null) {
    return false;
  }

  if (_isConversationExcerptRightPanel(rightSpec)) {
    return !_isCenterSpecCompatibleWithSidebar(
      flowState: flowState,
      centerSpec: rightSpec,
      currentSearchInvestigationId: currentSearchInvestigationId,
    );
  }

  if (!_supportsRecoveredAttachmentSidebar(centerSpec)) {
    return true;
  }

  return !_isCenterSpecCompatibleWithSidebar(
    flowState: flowState,
    centerSpec: rightSpec,
  );
}

bool _isConversationExcerptRightPanel(ViewSpec spec) {
  return spec.maybeWhen(
    conversations: (conversationsSpec) {
      return conversationsSpec.maybeWhen(
        conversationExcerpt: (_, __, ___, ____, _____) => true,
        orElse: () => false,
      );
    },
    orElse: () => false,
  );
}

PanelStack _resolveEffectiveCenterStack({
  required Ref ref,
  required SidebarFlowState flowState,
  required PanelStack centerStack,
  required ViewSpec? projectedCenterSpec,
}) {
  if (_shouldUseStoredCenterStack(
    ref: ref,
    flowState: flowState,
    centerStack: centerStack,
    projectedCenterSpec: projectedCenterSpec,
  )) {
    return centerStack;
  }

  if (projectedCenterSpec == null) {
    return const PanelStack.empty();
  }

  return PanelStack(
    pages: <PanelPage>[
      PanelPage(
        id: 'derived:$projectedCenterSpec',
        spec: projectedCenterSpec,
        title: _defaultPanelTitle(projectedCenterSpec),
        isClosable: false,
      ),
    ],
  );
}

bool _shouldUseStoredCenterStack({
  required Ref ref,
  required SidebarFlowState flowState,
  required PanelStack centerStack,
  required ViewSpec? projectedCenterSpec,
}) {
  final centerSpec = centerStack.activePage?.spec;
  if (centerSpec == null) {
    return false;
  }

  if (centerSpec.isSidebarIndependent) {
    return true;
  }

  if (_isFlowManagedCenterSpec(centerSpec)) {
    return false;
  }

  return !_shouldHideStoredCenterPanel(
    ref: ref,
    flowState: flowState,
    centerSpec: centerSpec,
    projectedCenterSpec: projectedCenterSpec,
  );
}

String _defaultPanelTitle(ViewSpec spec) {
  return spec.map(
    messages: (_) => 'Messages',
    conversations: (_) => 'Conversation',
    settings: (_) => 'Settings',
    environmentReadiness: (_) => 'Environment Readiness',
    onboarding: (_) => 'Onboarding',
  );
}

bool _shouldHideStoredCenterPanel({
  required Ref ref,
  required SidebarFlowState flowState,
  required ViewSpec? centerSpec,
  required ViewSpec? projectedCenterSpec,
}) {
  if (centerSpec?.isSidebarIndependent ?? false) {
    return false;
  }

  if (projectedCenterSpec != null) {
    if (centerSpec == null) {
      return true;
    }

    if (_isFlowManagedCenterSpec(centerSpec)) {
      return centerSpec != projectedCenterSpec;
    }

    return !_isCenterSpecCompatibleWithSidebar(
      flowState: flowState,
      centerSpec: centerSpec,
    );
  }

  if (centerSpec == null) {
    return false;
  }

  if (_isFlowManagedCenterSpec(centerSpec)) {
    return true;
  }

  return !_isCenterSpecCompatibleWithSidebar(
    flowState: flowState,
    centerSpec: centerSpec,
  );
}

bool _isFlowManagedCenterSpec(ViewSpec spec) {
  return spec.maybeWhen(
    messages: (messagesSpec) {
      return messagesSpec.maybeWhen(
        forContact: (_, __, ___) => true,
        globalTimeline: (_) => true,
        forHandle: (_) => true,
        recoveredUnlinkedMessages: (_, __) => true,
        recoveredNoHandleFromMeMessages: (_) => true,
        handleInvestigation: (_, __, ___) => true,
        orElse: () => false,
      );
    },
    settings: (settingsSpec) {
      return settingsSpec.maybeWhen(
        environmentSummary: () => true,
        historicalArchivesWorkflow: () => true,
        messageHistoryCoverageReport: () => true,
        orElse: () => false,
      );
    },
    orElse: () => false,
  );
}

bool _isCenterSpecCompatibleWithSidebar({
  required SidebarFlowState flowState,
  required ViewSpec? centerSpec,
  InvestigationIdentity? currentSearchInvestigationId,
}) {
  if (centerSpec == null) {
    return true;
  }

  return centerSpec.when(
    conversations: (conversationsSpec) {
      return conversationsSpec.when(
        conversationMessages: (conversationId, _, _) {
          return (flowState.topMenuChoice == TopChatMenuChoice.conversations &&
                  flowState.selectedConversationId == conversationId) ||
              (flowState.topMenuChoice == TopChatMenuChoice.contacts &&
                  flowState.messageScope == SidebarFlowMessageScope.regular &&
                  flowState.contactProjection ==
                      SidebarFlowContactProjection.conversations);
        },
        conversationExcerpt: (_, __, originatingInvestigationId, ___, ____) {
          return flowState.topMenuChoice ==
                  TopChatMenuChoice.searchAllMessages &&
              originatingInvestigationId == currentSearchInvestigationId;
        },
      );
    },
    messages: (messagesSpec) {
      return messagesSpec.when(
        forContact: (contactId, _, __) {
          return flowState.topMenuChoice == TopChatMenuChoice.contacts &&
              flowState.messageScope == SidebarFlowMessageScope.regular &&
              flowState.chosenContactId == contactId;
        },
        globalTimeline: (_) {
          return flowState.topMenuChoice == TopChatMenuChoice.searchAllMessages;
        },
        forHandle: (handleId) {
          return flowState.effectiveSelectedHandleEvidenceId == handleId &&
              flowState.selectedHandleEvidenceKind ==
                  SidebarFlowHandleEvidenceKind.messages;
        },
        recoveredUnlinkedMessages: (contactId, _) {
          if (flowState.topMenuChoice ==
              TopChatMenuChoice.recoveredUnlinkedMessages) {
            return true;
          }

          return flowState.topMenuChoice == TopChatMenuChoice.contacts &&
              flowState.messageScope ==
                  SidebarFlowMessageScope.recoveredDeleted &&
              flowState.chosenContactId != null &&
              contactId == flowState.chosenContactId;
        },
        recoveredNoHandleFromMeMessages: (_) {
          return flowState.topMenuChoice ==
              TopChatMenuChoice.recoveredNoHandleFromMeMessages;
        },
        recoveredAttachmentViewer: (_, __) => true,
        handleInvestigation: (investigationId, investigation, target) {
          if (flowState.topMenuChoice != TopChatMenuChoice.strayHandles ||
              flowState.strayHandleInvestigationId != investigationId ||
              flowState.strayHandleInvestigation != investigation) {
            return false;
          }
          return target.when(
            idle: () => flowState.effectiveSelectedHandleEvidenceId == null,
            selectedSource: (handleId) {
              return flowState.effectiveSelectedHandleEvidenceId == handleId &&
                  flowState.selectedHandleEvidenceKind ==
                      SidebarFlowHandleEvidenceKind.lens;
            },
          );
        },
      );
    },
    settings: (settingsSpec) {
      return settingsSpec.when(
        environmentSummary: () {
          return flowState.persistentSettingsContext ==
              SettingsMenuActionId.environment;
        },
        attachmentArchiveWorkflow: () {
          return flowState.persistentSettingsContext ==
              SettingsMenuActionId.attachmentArchive;
        },
        historicalArchivesWorkflow: () {
          return flowState.persistentSettingsContext ==
              SettingsMenuActionId.historicalArchives;
        },
        messageHistoryCoverageReport: () {
          return flowState.persistentSettingsContext ==
              SettingsMenuActionId.messageHistoryCoverage;
        },
      );
    },
    environmentReadiness: (_) => true,
    onboarding: (_) => true,
  );
}

/// Widget provider for the left sidebar surface.
///
/// The host reads the aggregate per-cassette resolution state for the current
/// rack and renders only when the visible rack is complete. Per-cassette
/// providers preserve previously resolved values during same-rack reloads,
/// while structural rack changes still blank until the new rack is fully
/// resolved.
///
/// Errors are logged but do not currently surface user-visible recovery UI.
@riverpod
Widget leftPanelWidget(Ref ref, SidebarMode mode) {
  final contextualWidget = ref.watch(contextualSidebarWidgetProvider(mode));
  final rack = ref.watch(cassetteRackStateProvider(mode));
  final resolutionState = ref.watch(
    sidebarCassetteResolutionStateProvider(mode),
  );

  return _buildLeftPanelSurface(
    mode: mode,
    rack: rack,
    contextualWidget: contextualWidget,
    resolutionState: resolutionState,
    logError: (error, stackTrace) {
      ref
          .read(appLoggerProvider.notifier)
          .error(
            'Sidebar cassette error: $error',
            source: 'SidebarPanel',
            context: {if (stackTrace != null) 'stackTrace': '$stackTrace'},
          );
    },
  );
}

Widget _buildLeftPanelFromWidgetRef(WidgetRef ref, SidebarMode mode) {
  final contextualWidget = ref.watch(contextualSidebarWidgetProvider(mode));
  final rack = ref.watch(cassetteRackStateProvider(mode));
  final resolutionState = ref.watch(
    sidebarCassetteResolutionStateProvider(mode),
  );

  return _buildLeftPanelSurface(
    mode: mode,
    rack: rack,
    contextualWidget: contextualWidget,
    resolutionState: resolutionState,
    logError: (error, stackTrace) {
      ref
          .read(appLoggerProvider.notifier)
          .error(
            'Sidebar cassette error: $error',
            source: 'SidebarPanel',
            context: {if (stackTrace != null) 'stackTrace': '$stackTrace'},
          );
    },
  );
}

Widget _buildLeftPanelSurface({
  required SidebarMode mode,
  required CassetteRack rack,
  required Widget? contextualWidget,
  required SidebarCassetteResolutionState resolutionState,
  required void Function(Object error, StackTrace? stackTrace) logError,
}) {
  final cassetteEntries =
      <({ResolvedSidebarCassette resolvedCassette, Widget widget})>[
        for (final resolvedCassette in resolutionState.resolvedCassettes)
          (
            resolvedCassette: resolvedCassette,
            widget: buildResolvedSidebarCassetteWidget(
              mode: mode,
              resolvedCassette: resolvedCassette,
            ),
          ),
      ];

  // Log sidebar resolution errors without disrupting the currently rendered
  // panel. User-visible incident surfacing belongs to a named diagnostics
  // surface, not imperative repair inside the panel projection path.
  for (final error in resolutionState.errors) {
    logError(error.error, error.stackTrace);
  }

  if (!resolutionState.hasCompleteResolvedRack) {
    return const Center(child: CircularProgressIndicator.adaptive());
  }

  // Render the sidebar surface with the current derived cassette list.
  //
  // The MouseRegion wrapper supports future hover-based interactions
  // (e.g., showing cassette actions on hover).
  return MouseRegion(
    key: ValueKey<String>('left-panel-$mode-${rack.cassettes.join('|')}'),
    child: _LeftSidebarSurface(
      mode: mode,
      cassetteEntries: cassetteEntries,
      contextualWidget: contextualWidget,
      contentSeamLayout: _contentSeamLayoutForRack(mode: mode, rack: rack),
    ),
  );
}

_SidebarContentSeamLayout? _contentSeamLayoutForRack({
  required SidebarMode mode,
  required CassetteRack rack,
}) {
  if (rack.cassettes.isEmpty) {
    return null;
  }

  if (mode == SidebarMode.settings) {
    const coverageOverview = CassetteSpec.settings(
      SettingsCassetteSpec.messageHistoryCoverageOverview(),
    );
    final hasCoverageOverview = rack.cassettes.contains(coverageOverview);
    return hasCoverageOverview
        ? const _SidebarContentSeamLayout(lastSharedTrackId: TrackId.trackA)
        : null;
  }

  if (mode != SidebarMode.messages) {
    return null;
  }

  final firstSpec = rack.cassettes.first.spec;
  return switch (firstSpec) {
    SidebarUtilityCassetteSpec() => firstSpec.maybeWhen(
      topChatMenu: (selectedChoice) {
        return switch (selectedChoice) {
          TopChatMenuChoice.searchAllMessages =>
            const _SidebarContentSeamLayout(
              lastSharedTrackId: TrackId.trackF,
              nativeFlowSpacing: _SidebarNativeFlowSpacing.flush,
            ),
          TopChatMenuChoice.strayHandles => const _SidebarContentSeamLayout(
            lastSharedTrackId: TrackId.trackA,
          ),
          TopChatMenuChoice.recoveredUnlinkedMessages ||
          TopChatMenuChoice.recoveredNoHandleFromMeMessages =>
            const _SidebarContentSeamLayout(lastSharedTrackId: TrackId.trackA),
          TopChatMenuChoice.contacts => const _SidebarContentSeamLayout(
            lastSharedTrackId: TrackId.trackA,
          ),
          _ => null,
        };
      },
      orElse: () => null,
    ),
    _ => null,
  };
}

class LeftPanelHost extends ConsumerWidget {
  const LeftPanelHost({super.key, required this.mode});

  final SidebarMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _buildLeftPanelFromWidgetRef(ref, mode);
  }
}

class CenterPanelHost extends ConsumerWidget {
  const CenterPanelHost({super.key, required this.mode});

  final SidebarMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(centerPanelWidgetProvider(mode));
  }
}

class RightPanelHost extends ConsumerWidget {
  const RightPanelHost({super.key, required this.mode});

  final SidebarMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(rightPanelWidgetProvider(mode));
  }
}

final class _SidebarContentSeamLayout {
  const _SidebarContentSeamLayout({
    required this.lastSharedTrackId,
    this.nativeFlowSpacing = _SidebarNativeFlowSpacing.preserveCassetteRhythm,
  });

  /// Last matrix row shared with column 1 before its cassette flow resumes.
  ///
  /// Navigation page composition owns this boundary. The generic sidebar
  /// renderer only consumes the declared ordinal coordinate.
  final TrackId lastSharedTrackId;

  /// How the column resumes its native cassette flow after the shared boundary.
  ///
  /// Cassette sectioning owns the spacing value. Page composition only declares
  /// whether that existing rhythm remains applicable after shared Track
  /// geometry or whether the shared geometry already provides the separation.
  final _SidebarNativeFlowSpacing nativeFlowSpacing;
}

enum _SidebarNativeFlowSpacing { preserveCassetteRhythm, flush }

/// Sidebar surface that separates pinned controls from scrollable content.
class _LeftSidebarSurface extends StatelessWidget {
  const _LeftSidebarSurface({
    required this.mode,
    required this.cassetteEntries,
    required this.contextualWidget,
    required this.contentSeamLayout,
  });

  final SidebarMode mode;
  final List<({ResolvedSidebarCassette resolvedCassette, Widget widget})>
  cassetteEntries;
  final Widget? contextualWidget;
  final _SidebarContentSeamLayout? contentSeamLayout;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final resolvedTrackMatrix = ResolvedTrackLayoutMatrixScope.maybeOf(
          context,
        );
        // A rack update and page-composition update may be observed in
        // different frames. Shared Track participation is truthful only while
        // this mounted surface can consume the page's resolved matrix.
        final seamLayout = resolvedTrackMatrix == null
            ? null
            : contentSeamLayout;
        final controls = <Widget>[];
        final mainContentEntries =
            <({ResolvedSidebarCassette resolvedCassette, Widget widget})>[];
        var encounteredMainContent = false;

        for (final entry in cassetteEntries) {
          final constrained = ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth),
            child: entry.widget,
          );

          final isPinnedControlCandidate = isPinnedAppControlCassette(
            entry.resolvedCassette,
          );

          // Only keep the leading control block pinned. Once main content
          // starts, preserve the authored cassette order even if later items
          // use naked/control styling for visual reasons.
          if (!encounteredMainContent && isPinnedControlCandidate) {
            controls.add(constrained);
          } else {
            encounteredMainContent = true;
            mainContentEntries.add(entry);
          }
        }

        final content = _buildSidebarContentEntries(
          mode: mode,
          cassetteEntries: mainContentEntries,
          maxWidth: constraints.maxWidth,
          contentSeamLayout: seamLayout,
          leadingContentWidgets: seamLayout == null
              ? const <Widget>[]
              : controls.skip(1).toList(growable: false),
          sharedTrackIds: seamLayout == null || resolvedTrackMatrix == null
              ? const <TrackId>[]
              : _sharedTrackIdsForSidebar(
                  matrixTrackIds: resolvedTrackMatrix.trackIds,
                  lastSharedTrackId: seamLayout.lastSharedTrackId,
                ),
        );

        if (contextualWidget case final contextualWidgetValue?) {
          content.add((
            widget: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth),
              child: contextualWidgetValue,
            ),
            shouldExpand: false,
          ));
        }

        final hasExpandingContent = content.any((c) => c.shouldExpand);
        final renderedControls = _buildSidebarControls(
          controls: controls,
          contentSeamLayout: seamLayout,
        );

        // When we have expanding content (e.g., scrollable lists that handle
        // their own scrolling), use a simple Column layout instead of
        // CustomScrollView. This prevents the outer sidebar from showing its
        // own scrollbar - only the inner list scrolls.
        if (hasExpandingContent) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...renderedControls,
              Expanded(child: _ContentFillColumn(children: content)),
            ],
          );
        }

        // For content without expanding items, use CustomScrollView so the
        // entire sidebar can scroll if content exceeds available height.
        return CustomScrollView(
          slivers: [
            for (final control in renderedControls)
              SliverToBoxAdapter(child: control),
            for (final item in content) SliverToBoxAdapter(child: item.widget),
          ],
        );
      },
    );
  }
}

List<Widget> _buildSidebarControls({
  required List<Widget> controls,
  required _SidebarContentSeamLayout? contentSeamLayout,
}) {
  if (contentSeamLayout == null) {
    return controls;
  }

  return [
    const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: TrackCellView(
        cellId: CellId(
          trackId: TrackId.trackA,
          columnId: TrackColumnId.column1,
        ),
      ),
    ),
  ];
}

List<({Widget widget, bool shouldExpand})> _buildSidebarContentEntries({
  required SidebarMode mode,
  required List<({ResolvedSidebarCassette resolvedCassette, Widget widget})>
  cassetteEntries,
  required double maxWidth,
  required _SidebarContentSeamLayout? contentSeamLayout,
  List<Widget> leadingContentWidgets = const <Widget>[],
  List<TrackId> sharedTrackIds = const <TrackId>[],
}) {
  if (contentSeamLayout != null) {
    return _buildSidebarContentEntriesWithSeam(
      mode: mode,
      cassetteEntries: cassetteEntries,
      maxWidth: maxWidth,
      leadingContentWidgets: leadingContentWidgets,
      sharedTrackIds: sharedTrackIds,
      nativeFlowSpacing: contentSeamLayout.nativeFlowSpacing,
    );
  }

  final content = <({Widget widget, bool shouldExpand})>[];
  var index = 0;

  while (index < cassetteEntries.length) {
    final entry = cassetteEntries[index];
    final groupedEntries = _collectGroupedSectionEntries(
      entries: cassetteEntries,
      startIndex: index,
    );

    if (groupedEntries.length > 1) {
      final sectionSurfaceStyle = sidebarCassetteSectionSurfaceStyleForPayload(
        groupedEntries.first.resolvedCassette.payload,
      );
      content.add((
        widget: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: _buildGroupedSectionWidget(
            mode: mode,
            entries: groupedEntries,
            sectionSurfaceStyle: sectionSurfaceStyle,
          ),
        ),
        shouldExpand: groupedEntries.any(
          (groupedEntry) =>
              shouldExpandSidebarCassette(groupedEntry.resolvedCassette),
        ),
      ));
      index += groupedEntries.length;
      continue;
    }

    content.add((
      widget: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: entry.widget,
      ),
      shouldExpand: shouldExpandSidebarCassette(entry.resolvedCassette),
    ));
    index += 1;
  }

  return content;
}

List<({Widget widget, bool shouldExpand})> _buildSidebarContentEntriesWithSeam({
  required SidebarMode mode,
  required List<({ResolvedSidebarCassette resolvedCassette, Widget widget})>
  cassetteEntries,
  required double maxWidth,
  required List<Widget> leadingContentWidgets,
  required List<TrackId> sharedTrackIds,
  required _SidebarNativeFlowSpacing nativeFlowSpacing,
}) {
  final contentStartEntries = _applyNativeFlowSpacing(
    mode: mode,
    entries: cassetteEntries,
    spacing: nativeFlowSpacing,
  );

  final contentStartContent = _buildSidebarContentEntries(
    mode: mode,
    cassetteEntries: contentStartEntries,
    maxWidth: maxWidth,
    contentSeamLayout: null,
  );

  return [
    for (final trackId in sharedTrackIds.skip(1))
      (
        widget: TrackCellView(
          cellId: CellId(trackId: trackId, columnId: TrackColumnId.column1),
        ),
        shouldExpand: false,
      ),
    for (final widget in leadingContentWidgets)
      (widget: widget, shouldExpand: false),
    ...contentStartContent,
  ];
}

List<TrackId> _sharedTrackIdsForSidebar({
  required List<TrackId> matrixTrackIds,
  required TrackId lastSharedTrackId,
}) {
  final boundaryIndex = matrixTrackIds.indexOf(lastSharedTrackId);
  if (boundaryIndex < 0) {
    throw StateError(
      'Sidebar shared-track boundary $lastSharedTrackId is outside the '
      'resolved page matrix.',
    );
  }
  return matrixTrackIds.take(boundaryIndex + 1).toList(growable: false);
}

List<({ResolvedSidebarCassette resolvedCassette, Widget widget})>
_applyNativeFlowSpacing({
  required SidebarMode mode,
  required List<({ResolvedSidebarCassette resolvedCassette, Widget widget})>
  entries,
  required _SidebarNativeFlowSpacing spacing,
}) {
  if (entries.isEmpty ||
      spacing == _SidebarNativeFlowSpacing.preserveCassetteRhythm) {
    return entries;
  }

  final first = entries.first;
  final resetResolvedCassette = ResolvedSidebarCassette(
    spec: first.resolvedCassette.spec,
    cassetteIndex: first.resolvedCassette.cassetteIndex,
    payload: first.resolvedCassette.payload,
    topSpacing: 0,
  );
  return [
    (
      resolvedCassette: resetResolvedCassette,
      widget: buildResolvedSidebarCassetteWidget(
        mode: mode,
        resolvedCassette: resetResolvedCassette,
      ),
    ),
    ...entries.skip(1),
  ];
}

List<({ResolvedSidebarCassette resolvedCassette, Widget widget})>
_collectGroupedSectionEntries({
  required List<({ResolvedSidebarCassette resolvedCassette, Widget widget})>
  entries,
  required int startIndex,
}) {
  final firstEntry = entries[startIndex];
  final firstSurfaceStyle = sidebarCassetteSectionSurfaceStyleForPayload(
    firstEntry.resolvedCassette.payload,
  );
  if (firstSurfaceStyle == SidebarCassetteSectionSurfaceStyle.none) {
    return [firstEntry];
  }

  final groupedEntries =
      <({ResolvedSidebarCassette resolvedCassette, Widget widget})>[firstEntry];
  for (var index = startIndex + 1; index < entries.length; index++) {
    final candidate = entries[index];
    if (!sidebarCassettePayloadJoinsSectionSurface(
      leadPayload: firstEntry.resolvedCassette.payload,
      candidatePayload: candidate.resolvedCassette.payload,
    )) {
      break;
    }
    groupedEntries.add(candidate);
  }

  return groupedEntries;
}

Widget _buildGroupedSectionWidget({
  required SidebarMode mode,
  required SidebarCassetteSectionSurfaceStyle sectionSurfaceStyle,
  required List<({ResolvedSidebarCassette resolvedCassette, Widget widget})>
  entries,
}) {
  final firstEntry = entries.first;
  final sectionChildren = <Widget>[
    for (var index = 0; index < entries.length; index++) ...[
      if (index > 0)
        SizedBox(height: entries[index].resolvedCassette.topSpacing),
      KeyedSubtree(
        key: ValueKey<String>(
          'cassette:${mode.name}:${entries[index].resolvedCassette.cassetteIndex}:${entries[index].resolvedCassette.spec}',
        ),
        child: buildSidebarCassettePayloadWidget(
          mode: mode,
          resolvedCassette: ResolvedSidebarCassette(
            spec: entries[index].resolvedCassette.spec,
            cassetteIndex: entries[index].resolvedCassette.cassetteIndex,
            payload: entries[index].resolvedCassette.payload,
          ),
        ),
      ),
    ],
  ];

  final sectionSurface = switch (sectionSurfaceStyle) {
    SidebarCassetteSectionSurfaceStyle.groupedControls =>
      SidebarGroupedControlSectionSurface(children: sectionChildren),
    SidebarCassetteSectionSurfaceStyle.primaryContextGroup =>
      SidebarPrimaryContextSectionSurface(children: sectionChildren),
    SidebarCassetteSectionSurfaceStyle.none => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: sectionChildren,
    ),
  };

  return Padding(
    padding: EdgeInsets.only(top: firstEntry.resolvedCassette.topSpacing),
    child: sectionSurface,
  );
}

class _ContentFillColumn extends StatelessWidget {
  const _ContentFillColumn({required this.children});

  final List<({Widget widget, bool shouldExpand})> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in children)
          if (item.shouldExpand) Expanded(child: item.widget) else item.widget,
      ],
    );
  }
}
