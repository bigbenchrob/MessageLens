import 'dart:math' as math;

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../features/contacts/domain/spec_classes/contacts_cassette_spec.dart';
import '../../../features/contacts/feature_level_providers.dart'
    show contactAccessActionsProvider;
import '../../../features/handles/domain/spec_classes/handles_cassette_spec.dart';
import '../../../features/handles/feature_level_providers.dart'
    show handleReviewActionsProvider, strayHandleReviewModeSettingProvider;
import '../../../features/settings/domain/spec_classes/settings_cassette_spec.dart';
import '../../../features/settings/feature_level_providers.dart'
    show
        messageHistoryCoverageReportExporterProvider,
        messageHistoryCoverageReportProvider;
import '../../../features/sidebar_utilities/domain/sidebar_utilities_constants.dart';
import '../../../features/sidebar_utilities/domain/spec_classes/sidebar_utility_cassette_spec.dart';
import '../../logging/application/diagnostic_report_actions.dart';
import '../../logging/feature_level_providers.dart'
    show diagnosticLogDirectoryPathProvider, diagnosticReportExporterProvider;
import '../../navigation/domain/sidebar_mode.dart';
import '../../onboarding/feature_level_providers.dart'
    show advancedStartFreshActionProvider;
import '../application/cassette_rack_state_provider.dart';
import '../application/ephemeral_cassette_projection_provider.dart';
import '../application/sidebar_flow_state_provider.dart';
import '../domain/entities/cassette_spec.dart';
import '../domain/sidebar_action_intent.dart';

part 'sidebar_action_dispatcher.g.dart';

class SidebarActionDispatchContext {
  const SidebarActionDispatchContext({
    required this.sidebarMode,
    this.cassetteIndex,
  });

  final SidebarMode sidebarMode;
  final int? cassetteIndex;
}

@riverpod
class SidebarActionDispatcher extends _$SidebarActionDispatcher {
  @override
  void build() {
    // Stateless dispatcher.
  }

  Future<void> dispatch({
    required SidebarActionIntent intent,
    required SidebarActionDispatchContext context,
  }) async {
    switch (intent) {
      case TopMenuChanged(:final choice):
        await ref
            .read(sidebarFlowProvider.notifier)
            .topMenuChangedRestoringContactContext(
              choice: _mapTopMenuChoice(choice),
              cassetteIndex: _requireCassetteIndex(context),
            );
      case SettingsPersistentContextChosen(:final actionId):
        ref
            .read(
              ephemeralCassetteProjectionProvider(context.sidebarMode).notifier,
            )
            .clear();
        ref
            .read(sidebarFlowProvider.notifier)
            .setPersistentSettingsContext(actionId);

        _replaceCassetteAtContext(
          context: context,
          spec: const CassetteSpec.sidebarUtility(
            SidebarUtilityCassetteSpec.settingsMenu(),
          ),
        );
      case ShowSendLogsFlow():
        ref
            .read(sidebarFlowProvider.notifier)
            .setPersistentSettingsContext(null);
        _replaceCassetteAtContext(
          context: context,
          spec: const CassetteSpec.sidebarUtility(
            SidebarUtilityCassetteSpec.settingsMenu(),
          ),
        );
        ref
            .read(
              ephemeralCassetteProjectionProvider(context.sidebarMode).notifier,
            )
            .replaceProjection(
              const CassetteSpec.settings(SettingsCassetteSpec.sendLogsPanel()),
            );
      case ShowResetMessageDataFlow():
        ref
            .read(sidebarFlowProvider.notifier)
            .setPersistentSettingsContext(null);
        _replaceCassetteAtContext(
          context: context,
          spec: const CassetteSpec.sidebarUtility(
            SidebarUtilityCassetteSpec.settingsMenu(),
          ),
        );
        ref
            .read(
              ephemeralCassetteProjectionProvider(context.sidebarMode).notifier,
            )
            .replaceProjection(
              const CassetteSpec.settings(
                SettingsCassetteSpec.resetMessageDataPanel(),
              ),
            );
      case ContactChosen(:final contactId):
        await _handleContactChosen(context: context, contactId: contactId);
      case ChooseAnotherContact():
        ref
            .read(sidebarFlowProvider.notifier)
            .chooseAnotherContact(
              infoCardIndex: _requireChosenContactBranchStartIndex(context),
            );
      case ContactHandleSelected(:final contactId, :final handleId):
        ref
            .read(sidebarFlowProvider.notifier)
            .handleSelected(
              contactId: contactId,
              handleId: handleId,
              cassetteIndex: _requireCassetteIndex(context),
            );
      case ContactMessageScopeChanged(:final contactId, :final scope):
        ref
            .read(sidebarFlowProvider.notifier)
            .setContactMessageScope(
              contactId: contactId,
              messageScope: _mapMessageScope(scope),
              cassetteIndex: _requireCassetteIndex(context),
            );
      case ContactProjectionChanged(:final contactId, :final projection):
        switch (projection) {
          case SidebarContactProjection.allMessages:
            ref
                .read(sidebarFlowProvider.notifier)
                .showContactTimelineAt(contactId: contactId);
          case SidebarContactProjection.conversations:
            ref
                .read(sidebarFlowProvider.notifier)
                .showContactConversationNavigator(contactId: contactId);
        }
      case HeatMapMonthFocused(:final monthAnchor, :final contactId):
        _dispatchHeatMapFocus(contactId: contactId, monthAnchor: monthAnchor);
      case ConversationSelected(
        :final conversationId,
        :final anchorMessageId,
        :final searchQuery,
      ):
        ref
            .read(sidebarFlowProvider.notifier)
            .selectConversation(
              conversationId: conversationId,
              anchorMessageId: anchorMessageId,
              searchQuery: searchQuery,
            );
      case ContactConversationSelected(
        :final contactId,
        :final conversationId,
        :final anchorMessageId,
        :final searchQuery,
      ):
        ref
            .read(sidebarFlowProvider.notifier)
            .selectContactConversation(
              contactId: contactId,
              conversationId: conversationId,
              anchorMessageId: anchorMessageId,
              searchQuery: searchQuery,
            );
      case RecoveredMonthFocused(
        :final monthAnchor,
        :final contactId,
        :final onlyNoHandleFromMe,
      ):
        _dispatchRecoveredMonthFocus(
          contactId: contactId,
          monthAnchor: monthAnchor,
          onlyNoHandleFromMe: onlyNoHandleFromMe,
        );
      case RecoveredNoHandleFromMeOpened():
        ref.read(sidebarFlowProvider.notifier).showRecoveredNoHandleFromMe();
      case StrayHandleFilterChanged(:final filter):
        ref
            .read(sidebarFlowProvider.notifier)
            .beginNewStrayHandleInvestigation();
        ref
            .read(strayHandleReviewModeSettingProvider.notifier)
            .setMode(StrayHandleReviewMode.active);
        _replaceCassetteAtContext(
          context: context,
          spec: CassetteSpec.handles(
            HandlesCassetteSpec.strayHandlesTypeSwitcher(
              selectedFilter: _mapStrayHandleFilter(filter),
            ),
          ),
        );
      case StrayHandleInvestigationChanged(:final investigation):
        ref
            .read(sidebarFlowProvider.notifier)
            .beginNewStrayHandleInvestigation(
              investigation: _mapStrayHandleInvestigation(investigation),
            );
        ref
            .read(strayHandleReviewModeSettingProvider.notifier)
            .setMode(StrayHandleReviewMode.active);
        _replaceCassetteAtContext(
          context: context,
          spec: CassetteSpec.handles(
            HandlesCassetteSpec.strayHandlesInvestigationSwitcher(
              selectedInvestigation: _mapStrayHandleInvestigation(
                investigation,
              ),
            ),
          ),
        );
      case StrayHandleModeChanged(:final mode):
        ref
            .read(sidebarFlowProvider.notifier)
            .beginNewStrayHandleInvestigation();
        ref
            .read(strayHandleReviewModeSettingProvider.notifier)
            .setMode(_mapStrayHandleMode(mode));
      case StrayHandleOpened(:final handleId):
        ref
            .read(sidebarFlowProvider.notifier)
            .openStrayHandleLens(handleId: handleId);
      case HandleMessagesOpened(:final handleId):
        ref
            .read(sidebarFlowProvider.notifier)
            .openHandleMessages(handleId: handleId);
      case StrayHandleDismissed(:final normalizedHandle):
        await ref
            .read(handleReviewActionsProvider.notifier)
            .dismissUnfamiliarHandle(normalizedHandle);
      case StrayHandleRestored(:final normalizedHandle):
        await ref
            .read(handleReviewActionsProvider.notifier)
            .restoreUnfamiliarHandle(normalizedHandle);
      case SettingsTransientActionCancelled():
        ref
            .read(
              ephemeralCassetteProjectionProvider(context.sidebarMode).notifier,
            )
            .clear();
      case SendLogsRequested():
        final diagnosticReportExporter = await ref.read(
          diagnosticReportExporterProvider.future,
        );
        await exportDiagnosticReport(diagnosticReportExporter);
      case ExportMessageHistoryCoverageReportRequested():
        final exportDirectoryPath = ref.read(
          diagnosticLogDirectoryPathProvider,
        );
        final report = await ref.read(
          messageHistoryCoverageReportProvider.future,
        );
        final exporter = ref.read(messageHistoryCoverageReportExporterProvider);
        await exporter.export(
          report: report,
          exportDirectoryPath: exportDirectoryPath,
        );
      case ResetMessageDataRequested():
        final startFreshAction = ref.read(advancedStartFreshActionProvider);
        await startFreshAction.request();
    }
  }

  void _dispatchHeatMapFocus({
    required int? contactId,
    required DateTime? monthAnchor,
  }) {
    if (contactId == null) {
      ref.read(sidebarFlowProvider.notifier).showGlobalTimelineAt(monthAnchor);
      return;
    }

    final flowState = ref.read(sidebarFlowProvider);
    final selectedHandleId = flowState.chosenContactId == contactId
        ? flowState.selectedHandleId
        : null;

    ref
        .read(sidebarFlowProvider.notifier)
        .showContactTimelineAt(
          contactId: contactId,
          scrollToDate: monthAnchor,
          filterHandleId: selectedHandleId,
        );
  }

  void _dispatchRecoveredMonthFocus({
    required int? contactId,
    required DateTime monthAnchor,
    required bool onlyNoHandleFromMe,
  }) {
    if (onlyNoHandleFromMe) {
      ref
          .read(sidebarFlowProvider.notifier)
          .showRecoveredNoHandleFromMe(scrollToDate: monthAnchor);
      return;
    }

    ref
        .read(sidebarFlowProvider.notifier)
        .showRecoveredDeletedAt(contactId: contactId, startDate: monthAnchor);
  }

  Future<void> _handleContactChosen({
    required SidebarActionDispatchContext context,
    required int contactId,
  }) async {
    final previousProjection = ref.read(sidebarFlowProvider).contactProjection;
    ref
        .read(sidebarFlowProvider.notifier)
        .contactChosen(
          contactId: contactId,
          infoCardIndex: _requirePreviousCassetteIndex(context),
          contactProjection: previousProjection,
        );

    await ref
        .read(contactAccessActionsProvider.notifier)
        .recordContactSelection(contactId);
  }

  void _replaceCassetteAtContext({
    required SidebarActionDispatchContext context,
    required CassetteSpec spec,
  }) {
    ref
        .read(cassetteRackStateProvider(context.sidebarMode).notifier)
        .replaceAtIndexAndCascade(_requireCassetteIndex(context), spec);
  }

  int _requireCassetteIndex(SidebarActionDispatchContext context) {
    final cassetteIndex = context.cassetteIndex;
    if (cassetteIndex == null) {
      throw StateError('Sidebar action requires a cassette index.');
    }
    return cassetteIndex;
  }

  int _requirePreviousCassetteIndex(SidebarActionDispatchContext context) {
    final cassetteIndex = _requireCassetteIndex(context);
    if (cassetteIndex <= 0) {
      throw StateError(
        'Sidebar action requires a preceding cassette index, but received '
        '$cassetteIndex.',
      );
    }
    return cassetteIndex - 1;
  }

  int _requireChosenContactBranchStartIndex(
    SidebarActionDispatchContext context,
  ) {
    final cassetteIndex = _requireCassetteIndex(context);
    final rack = ref.read(cassetteRackStateProvider(context.sidebarMode));
    if (rack.cassettes.isEmpty) {
      throw StateError('Sidebar action requires at least one cassette.');
    }

    final upperBound = math.min(cassetteIndex, rack.cassettes.length - 1);
    for (var index = 0; index <= upperBound; index++) {
      final cassette = rack.cassettes[index];
      final isChosenBranchStart = cassette.maybeMap(
        contacts: (contactsCassette) {
          return contactsCassette.spec.maybeWhen(
            contactSelectionControl: (_) => true,
            contactHeroSummary: (_) => true,
            orElse: () => false,
          );
        },
        orElse: () => false,
      );
      if (isChosenBranchStart) {
        return index;
      }
    }

    throw StateError(
      'Sidebar action requires a preceding chosen-contact branch cassette at '
      'or before index $cassetteIndex.',
    );
  }
}

TopChatMenuChoice _mapTopMenuChoice(SidebarTopMenuChoice choice) {
  return switch (choice) {
    SidebarTopMenuChoice.conversations => TopChatMenuChoice.conversations,
    SidebarTopMenuChoice.contacts => TopChatMenuChoice.contacts,
    SidebarTopMenuChoice.strayHandles => TopChatMenuChoice.strayHandles,
    SidebarTopMenuChoice.searchAllMessages =>
      TopChatMenuChoice.searchAllMessages,
    SidebarTopMenuChoice.recoveredUnlinkedMessages =>
      TopChatMenuChoice.recoveredUnlinkedMessages,
    SidebarTopMenuChoice.recoveredNoHandleFromMeMessages =>
      TopChatMenuChoice.recoveredNoHandleFromMeMessages,
  };
}

SidebarFlowMessageScope _mapMessageScope(SidebarMessageScope scope) {
  return switch (scope) {
    SidebarMessageScope.regular => SidebarFlowMessageScope.regular,
    SidebarMessageScope.recoveredDeleted =>
      SidebarFlowMessageScope.recoveredDeleted,
  };
}

StrayHandleFilter _mapStrayHandleFilter(SidebarStrayHandleFilter filter) {
  return switch (filter) {
    SidebarStrayHandleFilter.phones => StrayHandleFilter.phones,
    SidebarStrayHandleFilter.emails => StrayHandleFilter.emails,
    SidebarStrayHandleFilter.businessUrns => StrayHandleFilter.businessUrns,
  };
}

StrayHandleReviewMode _mapStrayHandleMode(SidebarStrayHandleReviewMode mode) {
  return switch (mode) {
    SidebarStrayHandleReviewMode.active => StrayHandleReviewMode.active,
    SidebarStrayHandleReviewMode.dismissed => StrayHandleReviewMode.dismissed,
  };
}

StrayHandleInvestigation _mapStrayHandleInvestigation(
  SidebarStrayHandleInvestigation investigation,
) {
  return switch (investigation) {
    SidebarStrayHandleInvestigation.identifySources =>
      StrayHandleInvestigation.identifySources,
    SidebarStrayHandleInvestigation.numericSenderIds =>
      StrayHandleInvestigation.numericSenderIds,
  };
}
