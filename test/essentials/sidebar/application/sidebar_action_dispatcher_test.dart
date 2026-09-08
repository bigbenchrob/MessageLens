import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/db/feature_level_providers.dart'
    show overlayDatabaseProvider;
import 'package:remember_this_text/essentials/db/feature_level_providers/conversation_graph_readiness_provider.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/navigation/application/panel_widget_providers.dart';
import 'package:remember_this_text/essentials/navigation/application/panels_view_state_provider.dart';
import 'package:remember_this_text/essentials/navigation/domain/entities/view_spec.dart';
import 'package:remember_this_text/essentials/navigation/domain/navigation_constants.dart';
import 'package:remember_this_text/essentials/navigation/domain/sidebar_mode.dart';
import 'package:remember_this_text/essentials/onboarding/application/advanced_start_fresh_action.dart';
import 'package:remember_this_text/essentials/onboarding/application/advanced_start_fresh_action_provider.dart';
import 'package:remember_this_text/essentials/sidebar/application/cassette_rack_state_provider.dart';
import 'package:remember_this_text/essentials/sidebar/application/ephemeral_cassette_projection_provider.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_action_dispatcher.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_flow_state_provider.dart';
import 'package:remember_this_text/essentials/sidebar/domain/entities/cassette_spec.dart';
import 'package:remember_this_text/essentials/sidebar/domain/sidebar_action_intent.dart';
import 'package:remember_this_text/features/contacts/domain/spec_classes/contacts_cassette_spec.dart';
import 'package:remember_this_text/features/contacts/domain/spec_classes/contacts_info_cassette_spec.dart';
import 'package:remember_this_text/features/conversations/domain/spec_classes/conversations_view_spec.dart';
import 'package:remember_this_text/features/handles/application/state/stray_handle_mode_provider.dart';
import 'package:remember_this_text/features/handles/domain/spec_classes/handles_cassette_spec.dart';
import 'package:remember_this_text/features/messages/domain/spec_classes/messages_cassette_spec.dart';
import 'package:remember_this_text/features/messages/domain/spec_classes/messages_view_spec.dart';
import 'package:remember_this_text/features/settings/domain/spec_classes/settings_cassette_spec.dart';
import 'package:remember_this_text/features/settings/domain/spec_classes/settings_view_spec.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/sidebar_utilities_constants.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/spec_classes/sidebar_utility_cassette_spec.dart';
import '../../../test_support/cassette_rack_test_harness.dart';

void main() {
  group('sidebarActionDispatcherProvider', () {
    late ProviderContainer container;
    late SidebarActionDispatcher dispatcher;
    late _FakeAdvancedStartFreshAction startFreshAction;
    late OverlayDatabase overlayDb;

    setUp(() {
      startFreshAction = _FakeAdvancedStartFreshAction();
      overlayDb = OverlayDatabase(NativeDatabase.memory());
      container = ProviderContainer(
        overrides: [
          conversationGraphPopulatedProvider.overrideWith(
            _AlwaysPopulatedGraph.new,
          ),
          overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
          advancedStartFreshActionProvider.overrideWith(
            (ref) => startFreshAction,
          ),
          ...cassetteRackTestHarnessOverrides(),
        ],
      );
      dispatcher = container.read(sidebarActionDispatcherProvider.notifier);
    });

    tearDown(() async {
      container.dispose();
      await overlayDb.close();
    });

    testWidgets('dispatches top menu changes through sidebar flow', (
      tester,
    ) async {
      await _mountMessagesPanelReconciliation(tester, container);

      await dispatcher.dispatch(
        intent: const TopMenuChanged(
          choice: SidebarTopMenuChoice.searchAllMessages,
        ),
        context: const SidebarActionDispatchContext(
          sidebarMode: SidebarMode.messages,
          cassetteIndex: 0,
        ),
      );

      await _flushMessagesPanelReconciliation(tester);

      final flowState = container.read(sidebarFlowProvider);
      final centerSpec = _activeSpec(container, WindowPanel.center);

      expect(flowState.topMenuChoice.name, 'searchAllMessages');
      expect(
        centerSpec,
        equals(const ViewSpec.messages(MessagesSpec.globalTimeline())),
      );
    });

    testWidgets('dispatches conversation selection through sidebar flow', (
      tester,
    ) async {
      await _mountMessagesPanelReconciliation(tester, container);

      await dispatcher.dispatch(
        intent: const ConversationSelected(conversationId: 8796093022216),
        context: const SidebarActionDispatchContext(
          sidebarMode: SidebarMode.messages,
        ),
      );

      await _flushMessagesPanelReconciliation(tester);

      final flowState = container.read(sidebarFlowProvider);
      expect(flowState.topMenuChoice, TopChatMenuChoice.conversations);
      expect(flowState.selectedConversationId, 8796093022216);
      expect(
        _activeSpec(container, WindowPanel.center),
        equals(
          const ViewSpec.conversations(
            ConversationsSpec.conversationMessages(
              conversationId: 8796093022216,
            ),
          ),
        ),
      );
    });

    testWidgets(
      'dispatches contact conversation selection through sidebar flow',
      (tester) async {
        await _mountMessagesPanelReconciliation(tester, container);

        await dispatcher.dispatch(
          intent: const ContactConversationSelected(
            contactId: 24,
            conversationId: 8796093022216,
            anchorMessageId: 45,
          ),
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.messages,
          ),
        );

        await _flushMessagesPanelReconciliation(tester);

        final flowState = container.read(sidebarFlowProvider);
        expect(flowState.topMenuChoice, TopChatMenuChoice.contacts);
        expect(flowState.chosenContactId, 24);
        expect(flowState.selectedConversationId, 8796093022216);
        expect(flowState.selectedConversationAnchorMessageId, 45);
        expect(
          _activeSpec(container, WindowPanel.center),
          equals(
            const ViewSpec.conversations(
              ConversationsSpec.conversationMessages(
                conversationId: 8796093022216,
                anchorMessageId: 45,
              ),
            ),
          ),
        );
      },
    );

    test(
      'dispatches stray handle filter changes via cassette replacement',
      () async {
        final flow = container.read(sidebarFlowProvider.notifier);
        flow.openStrayHandleLens(handleId: 7);
        final originatingInvestigationId = container
            .read(sidebarFlowProvider)
            .selectedHandleEvidenceInvestigationId;
        final rackNotifier = container.read(
          cassetteRackStateProvider(SidebarMode.messages).notifier,
        );
        rackNotifier.seedRackForTest([
          const CassetteSpec.handles(
            HandlesCassetteSpec.strayHandlesTypeSwitcher(),
          ),
        ]);

        await dispatcher.dispatch(
          intent: const StrayHandleFilterChanged(
            filter: SidebarStrayHandleFilter.emails,
          ),
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.messages,
            cassetteIndex: 0,
          ),
        );

        expect(
          container
              .read(cassetteRackStateProvider(SidebarMode.messages))
              .cassettes,
          equals([
            const CassetteSpec.handles(
              HandlesCassetteSpec.strayHandlesTypeSwitcher(
                selectedFilter: StrayHandleFilter.emails,
              ),
            ),
            const CassetteSpec.handles(
              HandlesCassetteSpec.strayHandlesModeSwitcher(
                investigation: StrayHandleInvestigation.identifySources,
                filter: StrayHandleFilter.emails,
              ),
            ),
            const CassetteSpec.handles(
              HandlesCassetteSpec.strayHandlesReview(
                investigation: StrayHandleInvestigation.identifySources,
                filter: StrayHandleFilter.emails,
              ),
            ),
          ]),
        );
        final flowState = container.read(sidebarFlowProvider);
        expect(flowState.selectedHandleEvidenceId, 7);
        expect(
          flowState.selectedHandleEvidenceInvestigationId,
          originatingInvestigationId,
        );
        expect(
          flowState.strayHandleInvestigationId,
          isNot(originatingInvestigationId),
        );
        expect(
          flowState.strayHandleInvestigation,
          StrayHandleInvestigation.identifySources,
        );
        expect(
          flowState.projectedCenterSpec,
          equals(
            ViewSpec.messages(
              MessagesSpec.handleInvestigation(
                investigationId: flowState.strayHandleInvestigationId!,
                investigation: StrayHandleInvestigation.identifySources,
                target: const HandleInvestigationTarget.idle(),
              ),
            ),
          ),
        );
      },
    );

    test(
      'dispatches source investigation changes via cassette replacement',
      () async {
        final flow = container.read(sidebarFlowProvider.notifier);
        flow.openStrayHandleLens(handleId: 7);
        final originatingInvestigationId = container
            .read(sidebarFlowProvider)
            .selectedHandleEvidenceInvestigationId;
        final rackNotifier = container.read(
          cassetteRackStateProvider(SidebarMode.messages).notifier,
        );
        rackNotifier.seedRackForTest([
          const CassetteSpec.handles(
            HandlesCassetteSpec.strayHandlesInvestigationSwitcher(),
          ),
        ]);

        await dispatcher.dispatch(
          intent: const StrayHandleInvestigationChanged(
            investigation: SidebarStrayHandleInvestigation.numericSenderIds,
          ),
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.messages,
            cassetteIndex: 0,
          ),
        );

        expect(
          container
              .read(cassetteRackStateProvider(SidebarMode.messages))
              .cassettes,
          equals([
            const CassetteSpec.handles(
              HandlesCassetteSpec.strayHandlesInvestigationSwitcher(
                selectedInvestigation:
                    StrayHandleInvestigation.numericSenderIds,
              ),
            ),
            const CassetteSpec.handles(
              HandlesCassetteSpec.strayHandlesModeSwitcher(
                investigation: StrayHandleInvestigation.numericSenderIds,
              ),
            ),
            const CassetteSpec.handles(
              HandlesCassetteSpec.strayHandlesReview(
                investigation: StrayHandleInvestigation.numericSenderIds,
              ),
            ),
          ]),
        );
        final flowState = container.read(sidebarFlowProvider);
        expect(flowState.selectedHandleEvidenceId, 7);
        expect(
          flowState.selectedHandleEvidenceInvestigationId,
          originatingInvestigationId,
        );
        expect(
          flowState.strayHandleInvestigationId,
          isNot(originatingInvestigationId),
        );
        expect(
          flowState.strayHandleInvestigation,
          StrayHandleInvestigation.numericSenderIds,
        );
        expect(
          flowState.projectedCenterSpec,
          equals(
            ViewSpec.messages(
              MessagesSpec.handleInvestigation(
                investigationId: flowState.strayHandleInvestigationId!,
                investigation: StrayHandleInvestigation.numericSenderIds,
                target: const HandleInvestigationTarget.idle(),
              ),
            ),
          ),
        );
      },
    );

    test('dispatches stray handle mode changes through mode state', () async {
      final flow = container.read(sidebarFlowProvider.notifier);
      flow.openStrayHandleLens(handleId: 7);
      final originatingInvestigationId = container
          .read(sidebarFlowProvider)
          .selectedHandleEvidenceInvestigationId;

      await dispatcher.dispatch(
        intent: const StrayHandleModeChanged(
          mode: SidebarStrayHandleReviewMode.dismissed,
        ),
        context: const SidebarActionDispatchContext(
          sidebarMode: SidebarMode.messages,
        ),
      );

      expect(
        container.read(strayHandleReviewModeSettingProvider),
        StrayHandleReviewMode.dismissed,
      );
      final flowState = container.read(sidebarFlowProvider);
      expect(flowState.selectedHandleEvidenceId, 7);
      expect(
        flowState.selectedHandleEvidenceInvestigationId,
        originatingInvestigationId,
      );
      expect(
        flowState.strayHandleInvestigationId,
        isNot(originatingInvestigationId),
      );
      expect(
        flowState.projectedCenterSpec,
        equals(
          ViewSpec.messages(
            MessagesSpec.handleInvestigation(
              investigationId: flowState.strayHandleInvestigationId!,
              investigation: StrayHandleInvestigation.identifySources,
              target: const HandleInvestigationTarget.idle(),
            ),
          ),
        ),
      );
    });

    testWidgets(
      'dispatches handle message opening to standalone handle route',
      (tester) async {
        await _mountMessagesPanelReconciliation(tester, container);

        await dispatcher.dispatch(
          intent: const HandleMessagesOpened(handleId: 9001),
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.messages,
          ),
        );

        await _flushMessagesPanelReconciliation(tester);

        expect(
          _activeSpec(container, WindowPanel.center),
          equals(
            const ViewSpec.messages(MessagesSpec.forHandle(handleId: 9001)),
          ),
        );
      },
    );

    testWidgets('dispatches stray handle lens opening through sidebar flow', (
      tester,
    ) async {
      await _mountMessagesPanelReconciliation(tester, container);

      await dispatcher.dispatch(
        intent: const StrayHandleOpened(handleId: 7),
        context: const SidebarActionDispatchContext(
          sidebarMode: SidebarMode.messages,
        ),
      );

      await _flushMessagesPanelReconciliation(tester);

      expect(
        _activeSpec(container, WindowPanel.center),
        equals(
          ViewSpec.messages(
            MessagesSpec.handleInvestigation(
              investigationId: container
                  .read(sidebarFlowProvider)
                  .strayHandleInvestigationId!,
              investigation: StrayHandleInvestigation.identifySources,
              target: const HandleInvestigationTarget.selectedSource(
                handleId: 7,
              ),
            ),
          ),
        ),
      );
    });

    test(
      'dispatches reset message data through advanced Start Fresh',
      () async {
        await dispatcher.dispatch(
          intent: const ResetMessageDataRequested(),
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.settings,
            cassetteIndex: 1,
          ),
        );

        expect(startFreshAction.requestCalls, 1);
      },
    );

    test(
      'dispatches persistent settings selection to flow state and child cascade',
      () async {
        final rackNotifier = container.read(
          cassetteRackStateProvider(SidebarMode.settings).notifier,
        );
        rackNotifier.seedRackForTest([
          const CassetteSpec.sidebarUtility(
            SidebarUtilityCassetteSpec.settingsMenu(),
          ),
        ]);

        await dispatcher.dispatch(
          intent: const SettingsPersistentContextChosen(
            actionId: SettingsMenuActionId.textSize,
          ),
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.settings,
            cassetteIndex: 0,
          ),
        );

        expect(
          container
              .read(cassetteRackStateProvider(SidebarMode.settings))
              .cassettes,
          equals([
            const CassetteSpec.sidebarUtility(
              SidebarUtilityCassetteSpec.settingsMenu(),
            ),
            const CassetteSpec.settings(SettingsCassetteSpec.textSizeInfo()),
          ]),
        );
        expect(
          container.read(sidebarFlowProvider).persistentSettingsContext,
          SettingsMenuActionId.textSize,
        );
      },
    );

    test(
      'dispatches send logs transient selection into ephemeral projection and clears durable settings context',
      () async {
        final rackNotifier = container.read(
          cassetteRackStateProvider(SidebarMode.settings).notifier,
        );
        container
            .read(sidebarFlowProvider.notifier)
            .setPersistentSettingsContext(SettingsMenuActionId.textSize);
        rackNotifier.seedRackForTest([
          const CassetteSpec.sidebarUtility(
            SidebarUtilityCassetteSpec.settingsMenu(),
          ),
          const CassetteSpec.settings(SettingsCassetteSpec.textSizeInfo()),
        ]);

        await dispatcher.dispatch(
          intent: const ShowSendLogsFlow(),
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.settings,
            cassetteIndex: 0,
          ),
        );

        expect(
          container
              .read(cassetteRackStateProvider(SidebarMode.settings))
              .cassettes,
          equals([
            const CassetteSpec.sidebarUtility(
              SidebarUtilityCassetteSpec.settingsMenu(),
            ),
          ]),
        );
        expect(
          container
              .read(ephemeralCassetteProjectionProvider(SidebarMode.settings))
              .cassettes,
          equals([
            const CassetteSpec.settings(SettingsCassetteSpec.sendLogsPanel()),
          ]),
        );
        expect(
          container.read(sidebarFlowProvider).persistentSettingsContext,
          isNull,
        );
      },
    );

    test(
      'dispatches message history coverage durable selection into stable cascade and derived center panel',
      () async {
        final rackNotifier = container.read(
          cassetteRackStateProvider(SidebarMode.settings).notifier,
        );
        rackNotifier.seedRackForTest([
          const CassetteSpec.sidebarUtility(
            SidebarUtilityCassetteSpec.settingsMenu(),
          ),
        ]);

        await dispatcher.dispatch(
          intent: const SettingsPersistentContextChosen(
            actionId: SettingsMenuActionId.messageHistoryCoverage,
          ),
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.settings,
            cassetteIndex: 0,
          ),
        );

        expect(
          container
              .read(cassetteRackStateProvider(SidebarMode.settings))
              .cassettes,
          equals([
            const CassetteSpec.sidebarUtility(
              SidebarUtilityCassetteSpec.settingsMenu(),
            ),
            const CassetteSpec.settings(
              SettingsCassetteSpec.messageHistoryCoverageOverview(),
            ),
            const CassetteSpec.settings(
              SettingsCassetteSpec.messageHistoryCoverageHowToRead(),
            ),
            const CassetteSpec.settings(
              SettingsCassetteSpec.messageHistoryCoverageOlderMessagesNote(),
            ),
          ]),
        );
        expect(
          container
              .read(ephemeralCassetteProjectionProvider(SidebarMode.settings))
              .cassettes,
          isEmpty,
        );
        expect(
          container.read(
            effectiveCenterPanelSpecProvider(SidebarMode.settings),
          ),
          equals(
            const ViewSpec.settings(
              SettingsViewSpec.messageHistoryCoverageReport(),
            ),
          ),
        );
        expect(
          container.read(sidebarFlowProvider).persistentSettingsContext,
          SettingsMenuActionId.messageHistoryCoverage,
        );
      },
    );

    test(
      'dispatches reset transient selection into ephemeral projection and clears durable settings context',
      () async {
        final rackNotifier = container.read(
          cassetteRackStateProvider(SidebarMode.settings).notifier,
        );
        container
            .read(sidebarFlowProvider.notifier)
            .setPersistentSettingsContext(SettingsMenuActionId.textSize);
        rackNotifier.seedRackForTest([
          const CassetteSpec.sidebarUtility(
            SidebarUtilityCassetteSpec.settingsMenu(),
          ),
          const CassetteSpec.settings(SettingsCassetteSpec.textSizeInfo()),
        ]);

        await dispatcher.dispatch(
          intent: const ShowResetMessageDataFlow(),
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.settings,
            cassetteIndex: 0,
          ),
        );

        expect(
          container
              .read(cassetteRackStateProvider(SidebarMode.settings))
              .cassettes,
          equals([
            const CassetteSpec.sidebarUtility(
              SidebarUtilityCassetteSpec.settingsMenu(),
            ),
          ]),
        );
        expect(
          container
              .read(ephemeralCassetteProjectionProvider(SidebarMode.settings))
              .cassettes,
          equals([
            const CassetteSpec.settings(
              SettingsCassetteSpec.resetMessageDataPanel(),
            ),
          ]),
        );
        expect(
          container.read(sidebarFlowProvider).persistentSettingsContext,
          isNull,
        );
      },
    );

    test(
      'cancelling reset transient projection leaves settings at the root menu',
      () async {
        final rackNotifier = container.read(
          cassetteRackStateProvider(SidebarMode.settings).notifier,
        );
        container
            .read(sidebarFlowProvider.notifier)
            .setPersistentSettingsContext(SettingsMenuActionId.textSize);
        rackNotifier.seedRackForTest([
          const CassetteSpec.sidebarUtility(
            SidebarUtilityCassetteSpec.settingsMenu(),
          ),
          const CassetteSpec.settings(SettingsCassetteSpec.textSizeInfo()),
        ]);

        await dispatcher.dispatch(
          intent: const ShowResetMessageDataFlow(),
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.settings,
            cassetteIndex: 0,
          ),
        );

        await dispatcher.dispatch(
          intent: const SettingsTransientActionCancelled(),
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.settings,
            cassetteIndex: 1,
          ),
        );

        expect(
          container
              .read(cassetteRackStateProvider(SidebarMode.settings))
              .cassettes,
          equals([
            const CassetteSpec.sidebarUtility(
              SidebarUtilityCassetteSpec.settingsMenu(),
            ),
          ]),
        );
        expect(
          container
              .read(ephemeralCassetteProjectionProvider(SidebarMode.settings))
              .cassettes,
          isEmpty,
        );
        expect(
          container.read(sidebarFlowProvider).persistentSettingsContext,
          isNull,
        );
      },
    );

    test(
      'changing persistent settings context clears incompatible ephemeral projection',
      () async {
        final rackNotifier = container.read(
          cassetteRackStateProvider(SidebarMode.settings).notifier,
        );
        rackNotifier.seedRackForTest([
          const CassetteSpec.sidebarUtility(
            SidebarUtilityCassetteSpec.settingsMenu(),
          ),
        ]);
        container
            .read(
              ephemeralCassetteProjectionProvider(
                SidebarMode.settings,
              ).notifier,
            )
            .replaceProjection(
              const CassetteSpec.settings(SettingsCassetteSpec.sendLogsPanel()),
            );

        await dispatcher.dispatch(
          intent: const SettingsPersistentContextChosen(
            actionId: SettingsMenuActionId.textSize,
          ),
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.settings,
            cassetteIndex: 0,
          ),
        );

        expect(
          container
              .read(ephemeralCassetteProjectionProvider(SidebarMode.settings))
              .cassettes,
          isEmpty,
        );
        expect(
          container
              .read(cassetteRackStateProvider(SidebarMode.settings))
              .cassettes,
          equals([
            const CassetteSpec.sidebarUtility(
              SidebarUtilityCassetteSpec.settingsMenu(),
            ),
            const CassetteSpec.settings(SettingsCassetteSpec.textSizeInfo()),
          ]),
        );
      },
    );

    testWidgets('dispatches heat map month focus through sidebar flow', (
      tester,
    ) async {
      await _mountMessagesPanelReconciliation(tester, container);

      final anchor = DateTime(2024, 04, 01);

      await dispatcher.dispatch(
        intent: HeatMapMonthFocused(contactId: 42, monthAnchor: anchor),
        context: const SidebarActionDispatchContext(
          sidebarMode: SidebarMode.messages,
        ),
      );

      await _flushMessagesPanelReconciliation(tester);

      expect(
        _activeSpec(container, WindowPanel.center),
        equals(
          ViewSpec.messages(
            MessagesSpec.forContact(contactId: 42, scrollToDate: anchor),
          ),
        ),
      );
    });

    testWidgets(
      'dispatches contact all-messages heat map focus through projected graph route',
      (tester) async {
        await _mountMessagesPanelReconciliation(tester, container);

        final flow = container.read(sidebarFlowProvider.notifier);
        final anchor = DateTime(2024, 04, 01);

        flow.topMenuChanged(
          choice: TopChatMenuChoice.contacts,
          cassetteIndex: 0,
        );
        flow.contactChosen(contactId: 42, infoCardIndex: 1);
        await _flushMessagesPanelReconciliation(tester);

        expect(
          _activeSpec(container, WindowPanel.center),
          equals(
            const ViewSpec.messages(MessagesSpec.forContact(contactId: 42)),
          ),
        );

        await dispatcher.dispatch(
          intent: HeatMapMonthFocused(contactId: 42, monthAnchor: anchor),
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.messages,
          ),
        );

        await _flushMessagesPanelReconciliation(tester);

        expect(container.read(sidebarFlowProvider).selectedHandleId, isNull);
        expect(container.read(sidebarFlowProvider).scrollToDate, anchor);
        expect(
          _activeSpec(container, WindowPanel.center),
          equals(
            ViewSpec.messages(
              MessagesSpec.forContact(contactId: 42, scrollToDate: anchor),
            ),
          ),
        );
      },
    );

    testWidgets(
      'dispatches filtered contact heat map focus through projected graph route',
      (tester) async {
        await _mountMessagesPanelReconciliation(tester, container);

        final flow = container.read(sidebarFlowProvider.notifier);
        final anchor = DateTime(2024, 04, 01);

        flow.topMenuChanged(
          choice: TopChatMenuChoice.contacts,
          cassetteIndex: 0,
        );
        flow.contactChosen(contactId: 42, infoCardIndex: 1);
        flow.handleSelected(contactId: 42, handleId: 7, cassetteIndex: 4);
        await _flushMessagesPanelReconciliation(tester);

        await dispatcher.dispatch(
          intent: HeatMapMonthFocused(contactId: 42, monthAnchor: anchor),
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.messages,
          ),
        );

        await _flushMessagesPanelReconciliation(tester);

        expect(container.read(sidebarFlowProvider).selectedHandleId, 7);
        expect(container.read(sidebarFlowProvider).scrollToDate, anchor);
        expect(
          _activeSpec(container, WindowPanel.center),
          equals(
            ViewSpec.messages(
              MessagesSpec.forContact(
                contactId: 42,
                scrollToDate: anchor,
                filterHandleId: 7,
              ),
            ),
          ),
        );
      },
    );

    test(
      'dispatches choose another contact from downstream cassette context',
      () async {
        final rackNotifier = container.read(
          cassetteRackStateProvider(SidebarMode.messages).notifier,
        );
        rackNotifier.seedRackForTest([
          const CassetteSpec.sidebarUtility(
            SidebarUtilityCassetteSpec.topChatMenu(),
          ),
          const CassetteSpec.contacts(
            ContactsCassetteSpec.contactSelectionControl(chosenContactId: 42),
          ),
          const CassetteSpec.contacts(
            ContactsCassetteSpec.contactHeroSummary(chosenContactId: 42),
          ),
          const CassetteSpec.contacts(
            ContactsCassetteSpec.messageScopeToggle(contactId: 42),
          ),
          const CassetteSpec.contacts(
            ContactsCassetteSpec.handleFilter(contactId: 42),
          ),
          const CassetteSpec.messages(
            MessagesCassetteSpec.heatMap(contactId: 42),
          ),
        ]);
        container
            .read(sidebarFlowProvider.notifier)
            .contactChosen(contactId: 42, infoCardIndex: 1);

        await dispatcher.dispatch(
          intent: const ChooseAnotherContact(),
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.messages,
            cassetteIndex: 4,
          ),
        );

        expect(container.read(sidebarFlowProvider).chosenContactId, isNull);
        final cassettes = container
            .read(cassetteRackStateProvider(SidebarMode.messages))
            .cassettes;

        expect(
          cassettes.first,
          const CassetteSpec.sidebarUtility(
            SidebarUtilityCassetteSpec.topChatMenu(),
          ),
        );
        expect(
          cassettes,
          contains(
            const CassetteSpec.contactsInfo(
              ContactsInfoCassetteSpec.infoCard(
                key: ContactsInfoKey.pickerContentSources,
              ),
            ),
          ),
        );
        expect(
          cassettes,
          contains(
            const CassetteSpec.contacts(ContactsCassetteSpec.contactChooser()),
          ),
        );
        expect(
          cassettes,
          isNot(
            contains(
              const CassetteSpec.contacts(
                ContactsCassetteSpec.contactSelectionControl(
                  chosenContactId: 42,
                ),
              ),
            ),
          ),
        );
        expect(
          cassettes,
          isNot(
            contains(
              const CassetteSpec.contacts(
                ContactsCassetteSpec.contactHeroSummary(chosenContactId: 42),
              ),
            ),
          ),
        );
        expect(
          cassettes,
          isNot(
            contains(
              const CassetteSpec.contactsInfo(
                ContactsInfoCassetteSpec.infoCard(
                  key: ContactsInfoKey.chosenContact,
                  chosenContactId: 42,
                ),
              ),
            ),
          ),
        );
        expect(
          cassettes,
          isNot(
            contains(
              const CassetteSpec.contacts(
                ContactsCassetteSpec.messageScopeToggle(contactId: 42),
              ),
            ),
          ),
        );
        expect(
          cassettes,
          isNot(
            contains(
              const CassetteSpec.contacts(
                ContactsCassetteSpec.handleFilter(contactId: 42),
              ),
            ),
          ),
        );
      },
    );

    testWidgets('dispatches contact handle selection through sidebar flow', (
      tester,
    ) async {
      await _mountMessagesPanelReconciliation(tester, container);

      container
          .read(sidebarFlowProvider.notifier)
          .contactChosen(contactId: 42, infoCardIndex: 1);

      await dispatcher.dispatch(
        intent: const ContactHandleSelected(contactId: 42, handleId: 7),
        context: const SidebarActionDispatchContext(
          sidebarMode: SidebarMode.messages,
          cassetteIndex: 4,
        ),
      );

      await _flushMessagesPanelReconciliation(tester);

      expect(container.read(sidebarFlowProvider).selectedHandleId, 7);
      expect(
        _activeSpec(container, WindowPanel.center),
        equals(
          const ViewSpec.messages(
            MessagesSpec.forContact(contactId: 42, filterHandleId: 7),
          ),
        ),
      );
    });

    testWidgets(
      'dispatches contact message scope changes through sidebar flow',
      (tester) async {
        await _mountMessagesPanelReconciliation(tester, container);

        container
            .read(sidebarFlowProvider.notifier)
            .contactChosen(contactId: 42, infoCardIndex: 1);

        await dispatcher.dispatch(
          intent: const ContactMessageScopeChanged(
            contactId: 42,
            scope: SidebarMessageScope.recoveredDeleted,
          ),
          context: const SidebarActionDispatchContext(
            sidebarMode: SidebarMode.messages,
            cassetteIndex: 3,
          ),
        );

        await _flushMessagesPanelReconciliation(tester);

        expect(
          container.read(sidebarFlowProvider).messageScope,
          SidebarFlowMessageScope.recoveredDeleted,
        );
        expect(
          _activeSpec(container, WindowPanel.center),
          equals(
            const ViewSpec.messages(
              MessagesSpec.recoveredUnlinkedMessages(contactId: 42),
            ),
          ),
        );
      },
    );

    testWidgets('dispatches contact projection changes through sidebar flow', (
      tester,
    ) async {
      await _mountMessagesPanelReconciliation(tester, container);

      container
          .read(sidebarFlowProvider.notifier)
          .selectContactConversation(contactId: 42, conversationId: 9001);

      await dispatcher.dispatch(
        intent: const ContactProjectionChanged(
          contactId: 42,
          projection: SidebarContactProjection.allMessages,
        ),
        context: const SidebarActionDispatchContext(
          sidebarMode: SidebarMode.messages,
        ),
      );

      await _flushMessagesPanelReconciliation(tester);

      var flowState = container.read(sidebarFlowProvider);
      expect(flowState.topMenuChoice, TopChatMenuChoice.contacts);
      expect(flowState.chosenContactId, 42);
      expect(
        flowState.contactProjection,
        SidebarFlowContactProjection.allMessages,
      );
      expect(flowState.selectedConversationId, isNull);
      expect(
        _activeSpec(container, WindowPanel.center),
        equals(const ViewSpec.messages(MessagesSpec.forContact(contactId: 42))),
      );

      await dispatcher.dispatch(
        intent: const ContactProjectionChanged(
          contactId: 42,
          projection: SidebarContactProjection.conversations,
        ),
        context: const SidebarActionDispatchContext(
          sidebarMode: SidebarMode.messages,
        ),
      );

      await _flushMessagesPanelReconciliation(tester);

      flowState = container.read(sidebarFlowProvider);
      expect(flowState.topMenuChoice, TopChatMenuChoice.contacts);
      expect(flowState.chosenContactId, 42);
      expect(
        flowState.contactProjection,
        SidebarFlowContactProjection.conversations,
      );
      expect(flowState.selectedConversationId, isNull);
      expect(_activeSpec(container, WindowPanel.center), isNull);
    });

    testWidgets('dispatches recovered no-handle opening through sidebar flow', (
      tester,
    ) async {
      await _mountMessagesPanelReconciliation(tester, container);

      await dispatcher.dispatch(
        intent: const RecoveredNoHandleFromMeOpened(),
        context: const SidebarActionDispatchContext(
          sidebarMode: SidebarMode.messages,
        ),
      );

      await _flushMessagesPanelReconciliation(tester);

      final flowState = container.read(sidebarFlowProvider);
      expect(
        flowState.topMenuChoice,
        TopChatMenuChoice.recoveredNoHandleFromMeMessages,
      );
      expect(flowState.chosenContactId, isNull);
      expect(flowState.selectedHandleId, isNull);
      expect(
        _activeSpec(container, WindowPanel.center),
        equals(
          const ViewSpec.messages(
            MessagesSpec.recoveredNoHandleFromMeMessages(),
          ),
        ),
      );
    });
  });
}

Future<void> _mountMessagesPanelReconciliation(
  WidgetTester tester,
  ProviderContainer container,
) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const Directionality(
        textDirection: TextDirection.ltr,
        child: _MessagesPanelReconciliationHost(),
      ),
    ),
  );
}

Future<void> _flushMessagesPanelReconciliation(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
}

class _MessagesPanelReconciliationHost extends ConsumerWidget {
  const _MessagesPanelReconciliationHost();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(sidebarFlowProvider);
    ref.watch(cassetteRackStateProvider(SidebarMode.messages));
    ref.watch(effectiveCenterPanelSpecProvider(SidebarMode.messages));
    ref.watch(effectiveRightPanelSpecProvider(SidebarMode.messages));
    return const SizedBox.shrink();
  }
}

ViewSpec? _activeSpec(ProviderContainer container, WindowPanel panel) {
  if (panel == WindowPanel.center) {
    return container.read(
      effectiveCenterPanelSpecProvider(SidebarMode.messages),
    );
  }

  final stacks = container.read(panelsViewStateProvider(SidebarMode.messages));
  return stacks[panel]?.activePage?.spec;
}

class _AlwaysPopulatedGraph extends ConversationGraphPopulated {
  @override
  bool build() {
    return true;
  }
}

final class _FakeAdvancedStartFreshAction implements AdvancedStartFreshAction {
  int requestCalls = 0;

  @override
  Future<AdvancedStartFreshActionResult> request() async {
    requestCalls += 1;
    return AdvancedStartFreshActionResult.startedFresh;
  }

  @override
  void dismissFailure({required int occurrence}) {}

  @override
  Future<AdvancedStartFreshActionResult> retry({
    required int occurrence,
  }) async {
    return AdvancedStartFreshActionResult.startedFresh;
  }
}
