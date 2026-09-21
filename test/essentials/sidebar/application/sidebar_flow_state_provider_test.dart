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
import 'package:remember_this_text/essentials/sidebar/application/cassette_rack_state_provider.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_flow_state_provider.dart';
import 'package:remember_this_text/essentials/sidebar/domain/entities/cassette_spec.dart';
import 'package:remember_this_text/features/contacts/domain/spec_classes/contacts_cassette_spec.dart';
import 'package:remember_this_text/features/contacts/domain/spec_classes/contacts_info_cassette_spec.dart';
import 'package:remember_this_text/features/conversations/domain/spec_classes/conversations_cassette_spec.dart';
import 'package:remember_this_text/features/conversations/domain/spec_classes/conversations_view_spec.dart';
import 'package:remember_this_text/features/handles/domain/entities/stray_handle_investigation_id.dart';
import 'package:remember_this_text/features/handles/domain/spec_classes/handles_cassette_spec.dart';
import 'package:remember_this_text/features/messages/domain/search_investigation_id.dart';
import 'package:remember_this_text/features/messages/domain/spec_classes/messages_cassette_spec.dart';
import 'package:remember_this_text/features/messages/domain/spec_classes/messages_view_spec.dart';
import 'package:remember_this_text/features/settings/domain/spec_classes/settings_view_spec.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/sidebar_utilities_constants.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/spec_classes/sidebar_utility_cassette_spec.dart';

void main() {
  group('debugAssertValidSidebarFlowState', () {
    test('allows canonical conversation-browser state', () {
      expect(
        () => debugAssertValidSidebarFlowState(const SidebarFlowState()),
        returnsNormally,
      );
    });

    test('rejects selected handle without chosen contact', () {
      expect(
        () => debugAssertValidSidebarFlowState(
          const SidebarFlowState(
            topMenuChoice: TopChatMenuChoice.contacts,
            selectedHandleId: 7,
          ),
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('selectedHandleId requires a chosen contact'),
          ),
        ),
      );
    });

    test('rejects contact recovered scope without chosen contact', () {
      expect(
        () => debugAssertValidSidebarFlowState(
          const SidebarFlowState(
            topMenuChoice: TopChatMenuChoice.contacts,
            messageScope: SidebarFlowMessageScope.recoveredDeleted,
          ),
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('Recovered contact scope requires a chosen contact'),
          ),
        ),
      );
    });

    test('rejects global recovered branch outside recovered scope', () {
      expect(
        () => debugAssertValidSidebarFlowState(
          const SidebarFlowState(
            topMenuChoice: TopChatMenuChoice.recoveredUnlinkedMessages,
          ),
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('Global recovered branch must remain in recoveredDeleted'),
          ),
        ),
      );
    });

    test(
      'rejects transient settings action as persistent settings context',
      () {
        expect(
          () => debugAssertValidSidebarFlowState(
            const SidebarFlowState(
              persistentSettingsContext: SettingsMenuActionId.sendLogs,
            ),
          ),
          throwsA(
            isA<StateError>().having(
              (error) => error.message,
              'message',
              contains('persistentSettingsContext cannot hold transient'),
            ),
          ),
        );
      },
    );
  });

  group('SidebarFlowNavigationPreference', () {
    test('serializes restorable contact navigation context', () {
      final preference = SidebarFlowNavigationPreference.fromState(
        SidebarFlowState(
          topMenuChoice: TopChatMenuChoice.contacts,
          chosenContactId: 42,
          selectedHandleId: 7,
          scrollToDate: DateTime(2026, 6, 1),
        ),
      );
      final restored = SidebarFlowNavigationPreference.fromStorage(
        preference.storageValue,
      );

      expect(restored?.state.topMenuChoice, TopChatMenuChoice.contacts);
      expect(restored?.state.chosenContactId, 42);
      expect(restored?.state.selectedHandleId, 7);
      expect(restored?.state.scrollToDate, isNull);
      expect(
        restored?.state.contactProjection,
        SidebarFlowContactProjection.allMessages,
      );
    });

    test('serializes restorable conversation navigation context', () {
      final preference = SidebarFlowNavigationPreference.fromState(
        const SidebarFlowState(
          topMenuChoice: TopChatMenuChoice.conversations,
          selectedConversationId: 8796093022216,
          selectedConversationAnchorMessageId: 8796093170832,
          selectedConversationSearchQuery: 'flower',
        ),
      );
      final restored = SidebarFlowNavigationPreference.fromStorage(
        preference.storageValue,
      );

      expect(restored?.state.topMenuChoice, TopChatMenuChoice.conversations);
      expect(restored?.state.selectedConversationId, 8796093022216);
      expect(restored?.state.selectedConversationAnchorMessageId, isNull);
      expect(restored?.state.selectedConversationSearchQuery, isNull);
    });
  });

  group('sidebarFlowProvider', () {
    late ProviderContainer container;
    late OverlayDatabase overlayDb;

    setUp(() {
      overlayDb = OverlayDatabase(NativeDatabase.memory());
      container = ProviderContainer(
        overrides: [
          conversationGraphPopulatedProvider.overrideWith(
            _AlwaysPopulatedGraph.new,
          ),
          overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await overlayDb.close();
    });

    test('default conversations state waits for sidebar selection', () {
      final flowState = container.read(sidebarFlowProvider);
      final rack = container.read(
        cassetteRackStateProvider(SidebarMode.messages),
      );

      expect(flowState.topMenuChoice, defaultTopChatMenuChoice);
      expect(flowState.projectedCenterSpec, isNull);
      expect(
        rack.cassettes.first,
        const CassetteSpec.sidebarUtility(
          SidebarUtilityCassetteSpec.topChatMenu(),
        ),
      );
      expect(
        rack.cassettes,
        contains(
          const CassetteSpec.conversations(
            ConversationsCassetteSpec.conversationSignatures(),
          ),
        ),
      );
    });

    testWidgets(
      'contactChosen resets subordinate state and starts chosen-contact branch at selection control',
      (tester) async {
        await _mountMessagesPanelReconciliation(tester, container);
        _switchToContacts(container);

        container
            .read(sidebarFlowProvider.notifier)
            .contactChosen(contactId: 42, infoCardIndex: 1);

        await _flushMessagesPanelReconciliation(tester);

        final flowState = container.read(sidebarFlowProvider);
        final rack = container.read(
          cassetteRackStateProvider(SidebarMode.messages),
        );
        final centerSpec = _activeSpec(container, WindowPanel.center);

        expect(flowState.topMenuChoice, TopChatMenuChoice.contacts);
        expect(flowState.chosenContactId, 42);
        expect(flowState.selectedHandleId, isNull);
        expect(flowState.messageScope, SidebarFlowMessageScope.regular);

        expect(rack.cassettes.first, _topChatMenuSpec());

        final selectionControlIndex = _contactSpecIndex(
          rack.cassettes,
          const ContactsCassetteSpec.contactSelectionControl(
            chosenContactId: 42,
          ),
        );
        final heroIndex = _contactSpecIndex(
          rack.cassettes,
          const ContactsCassetteSpec.contactHeroSummary(chosenContactId: 42),
        );
        final messageScopeIndex = _contactSpecIndex(
          rack.cassettes,
          const ContactsCassetteSpec.messageScopeToggle(contactId: 42),
        );

        expect(selectionControlIndex, lessThan(heroIndex));
        expect(heroIndex, lessThan(messageScopeIndex));
        expect(
          rack.cassettes,
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
          rack.cassettes,
          contains(
            const CassetteSpec.contacts(
              ContactsCassetteSpec.messageScopeToggle(contactId: 42),
            ),
          ),
        );
        expect(
          rack.cassettes,
          contains(
            const CassetteSpec.contacts(
              ContactsCassetteSpec.handleFilter(contactId: 42),
            ),
          ),
        );
        expect(
          rack.cassettes,
          contains(
            const CassetteSpec.messages(
              MessagesCassetteSpec.heatMap(contactId: 42),
            ),
          ),
        );
        expect(
          centerSpec,
          equals(
            const ViewSpec.messages(MessagesSpec.forContact(contactId: 42)),
          ),
        );
      },
    );

    test('setPersistentSettingsContext stores durable settings context', () {
      container
          .read(sidebarFlowProvider.notifier)
          .setPersistentSettingsContext(SettingsMenuActionId.textSize);

      expect(
        container.read(sidebarFlowProvider).persistentSettingsContext,
        SettingsMenuActionId.textSize,
      );
    });

    test('conversations top menu waits for sidebar selection', () {
      container
          .read(sidebarFlowProvider.notifier)
          .topMenuChanged(
            choice: TopChatMenuChoice.conversations,
            cassetteIndex: 0,
          );

      expect(container.read(sidebarFlowProvider).projectedCenterSpec, isNull);
    });

    test(
      'contacts top menu restores persisted contact and projection context',
      () async {
        await overlayDb.writeOverlaySetting(
          settingKey: sidebarContactContextOverlaySettingKey,
          settingValue: const SidebarContactContextPreference(
            contactId: 42,
            projection: SidebarFlowContactProjection.conversations,
          ).storageValue,
        );

        await container
            .read(sidebarFlowProvider.notifier)
            .topMenuChangedRestoringContactContext(
              choice: TopChatMenuChoice.contacts,
              cassetteIndex: 0,
            );

        final flowState = container.read(sidebarFlowProvider);
        final rack = container.read(
          cassetteRackStateProvider(SidebarMode.messages),
        );

        expect(flowState.topMenuChoice, TopChatMenuChoice.contacts);
        expect(flowState.chosenContactId, 42);
        expect(
          flowState.contactProjection,
          SidebarFlowContactProjection.conversations,
        );
        expect(
          rack.cassettes,
          contains(
            const CassetteSpec.contacts(
              ContactsCassetteSpec.contactSelectionControl(chosenContactId: 42),
            ),
          ),
        );
        expect(
          rack.cassettes,
          contains(
            const CassetteSpec.messages(
              MessagesCassetteSpec.heatMap(contactId: 42),
            ),
          ),
        );
      },
    );

    test('contact projection changes persist contact context', () async {
      final flow = container.read(sidebarFlowProvider.notifier);

      flow.showContactConversationNavigator(contactId: 42);
      await _expectOverlaySetting(
        overlayDb,
        sidebarContactContextOverlaySettingKey,
        '42|conversations',
      );

      flow.showContactTimelineAt(contactId: 42);
      await _expectOverlaySetting(
        overlayDb,
        sidebarContactContextOverlaySettingKey,
        '42|all_messages',
      );
    });

    testWidgets('startup restores persisted sidebar flow navigation context', (
      tester,
    ) async {
      await overlayDb.writeOverlaySetting(
        settingKey: sidebarFlowNavigationOverlaySettingKey,
        settingValue: SidebarFlowNavigationPreference.fromState(
          const SidebarFlowState(
            topMenuChoice: TopChatMenuChoice.contacts,
            chosenContactId: 42,
            selectedHandleId: 7,
          ),
        ).storageValue,
      );
      await _mountMessagesPanelReconciliation(tester, container);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));

      final flowState = container.read(sidebarFlowProvider);
      final rack = container.read(
        cassetteRackStateProvider(SidebarMode.messages),
      );

      expect(flowState.topMenuChoice, TopChatMenuChoice.contacts);
      expect(flowState.chosenContactId, 42);
      expect(flowState.selectedHandleId, 7);
      expect(
        flowState.projectedCenterSpec,
        equals(
          const ViewSpec.messages(
            MessagesSpec.forContact(contactId: 42, filterHandleId: 7),
          ),
        ),
      );
      expect(
        rack.cassettes.first,
        const CassetteSpec.sidebarUtility(
          SidebarUtilityCassetteSpec.topChatMenu(
            selectedChoice: TopChatMenuChoice.contacts,
          ),
        ),
      );
      expect(
        rack.cassettes,
        contains(
          const CassetteSpec.contacts(
            ContactsCassetteSpec.contactSelectionControl(chosenContactId: 42),
          ),
        ),
      );
    });

    test('selected conversation derives conversation center spec', () {
      container
          .read(sidebarFlowProvider.notifier)
          .selectConversation(conversationId: 8796093022216);

      final flowState = container.read(sidebarFlowProvider);

      expect(flowState.topMenuChoice, TopChatMenuChoice.conversations);
      expect(flowState.selectedConversationId, 8796093022216);
      expect(
        flowState.projectedCenterSpec,
        equals(
          const ViewSpec.conversations(
            ConversationsSpec.conversationMessages(
              conversationId: 8796093022216,
            ),
          ),
        ),
      );
    });

    test('selected contact conversation derives center spec', () {
      container
          .read(sidebarFlowProvider.notifier)
          .selectContactConversation(
            contactId: 42,
            conversationId: 8796093022216,
          );

      final flowState = container.read(sidebarFlowProvider);

      expect(flowState.topMenuChoice, TopChatMenuChoice.contacts);
      expect(flowState.chosenContactId, 42);
      expect(
        flowState.contactProjection,
        SidebarFlowContactProjection.conversations,
      );
      expect(flowState.selectedConversationId, 8796093022216);
      expect(
        flowState.projectedCenterSpec,
        equals(
          const ViewSpec.conversations(
            ConversationsSpec.conversationMessages(
              conversationId: 8796093022216,
            ),
          ),
        ),
      );
    });

    test('historical archives projects a settings-mode center spec', () {
      container
          .read(sidebarFlowProvider.notifier)
          .setPersistentSettingsContext(
            SettingsMenuActionId.historicalArchives,
          );

      expect(
        container.read(sidebarFlowProvider).projectedSettingsCenterSpec,
        equals(
          const ViewSpec.settings(
            SettingsViewSpec.historicalArchivesWorkflow(),
          ),
        ),
      );
      expect(
        container
            .read(sidebarFlowProvider)
            .projectedCenterSpecForMode(SidebarMode.settings),
        equals(
          const ViewSpec.settings(
            SettingsViewSpec.historicalArchivesWorkflow(),
          ),
        ),
      );
    });

    test('attachment archive projects a center spec and no sidebar body', () {
      container
          .read(sidebarFlowProvider.notifier)
          .setPersistentSettingsContext(SettingsMenuActionId.attachmentArchive);

      expect(
        container.read(sidebarFlowProvider).projectedSettingsCenterSpec,
        equals(
          const ViewSpec.settings(SettingsViewSpec.attachmentArchiveWorkflow()),
        ),
      );
    });

    test('message history coverage projects a settings-mode center spec', () {
      container
          .read(sidebarFlowProvider.notifier)
          .setPersistentSettingsContext(
            SettingsMenuActionId.messageHistoryCoverage,
          );

      expect(
        container.read(sidebarFlowProvider).projectedSettingsCenterSpec,
        equals(
          const ViewSpec.settings(
            SettingsViewSpec.messageHistoryCoverageReport(),
          ),
        ),
      );
      expect(
        container
            .read(sidebarFlowProvider)
            .projectedCenterSpecForMode(SidebarMode.settings),
        equals(
          const ViewSpec.settings(
            SettingsViewSpec.messageHistoryCoverageReport(),
          ),
        ),
      );
    });

    testWidgets(
      'chooseAnotherContact replaces the whole chosen-contact branch and hides incompatible panels by derivation',
      (tester) async {
        await _mountMessagesPanelReconciliation(tester, container);

        final flow = container.read(sidebarFlowProvider.notifier);
        final panels = container.read(
          panelsViewStateProvider(SidebarMode.messages).notifier,
        );

        _switchToContacts(container);
        flow.contactChosen(contactId: 42, infoCardIndex: 1);
        panels.show(
          panel: WindowPanel.right,
          spec: const ViewSpec.messages(MessagesSpec.forHandle(handleId: 9001)),
        );

        flow.chooseAnotherContact(infoCardIndex: 1);

        await _flushMessagesPanelReconciliation(tester);

        final flowState = container.read(sidebarFlowProvider);
        final rack = container.read(
          cassetteRackStateProvider(SidebarMode.messages),
        );
        final storedPanelState = container.read(
          panelsViewStateProvider(SidebarMode.messages),
        );

        expect(flowState.chosenContactId, isNull);
        expect(flowState.selectedHandleId, isNull);
        expect(flowState.messageScope, SidebarFlowMessageScope.regular);

        expect(rack.cassettes.first, _topChatMenuSpec());
        expect(
          rack.cassettes,
          contains(
            const CassetteSpec.contactsInfo(
              ContactsInfoCassetteSpec.infoCard(
                key: ContactsInfoKey.pickerContentSources,
              ),
            ),
          ),
        );
        expect(
          rack.cassettes,
          contains(
            const CassetteSpec.contacts(ContactsCassetteSpec.contactChooser()),
          ),
        );
        expect(
          rack.cassettes,
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
          rack.cassettes,
          isNot(
            contains(
              const CassetteSpec.contacts(
                ContactsCassetteSpec.contactHeroSummary(chosenContactId: 42),
              ),
            ),
          ),
        );
        expect(
          rack.cassettes,
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
          rack.cassettes,
          isNot(
            contains(
              const CassetteSpec.contacts(
                ContactsCassetteSpec.messageScopeToggle(contactId: 42),
              ),
            ),
          ),
        );
        expect(
          rack.cassettes,
          isNot(
            contains(
              const CassetteSpec.contacts(
                ContactsCassetteSpec.handleFilter(contactId: 42),
              ),
            ),
          ),
        );
        expect(_activeSpec(container, WindowPanel.center), isNull);
        expect(_activeSpec(container, WindowPanel.right), isNull);
        expect(storedPanelState[WindowPanel.center]?.isEmpty ?? true, isTrue);
        expect(storedPanelState[WindowPanel.right]?.isEmpty, isFalse);
      },
    );

    testWidgets(
      'contactChosen removes obsolete hero and filter specs when replacing contact',
      (tester) async {
        await _mountMessagesPanelReconciliation(tester, container);

        final flow = container.read(sidebarFlowProvider.notifier);

        _switchToContacts(container);
        flow.contactChosen(contactId: 41, infoCardIndex: 1);
        flow.handleSelected(contactId: 41, handleId: 7, cassetteIndex: 4);
        flow.contactChosen(contactId: 42, infoCardIndex: 1);

        await _flushMessagesPanelReconciliation(tester);

        final rack = container.read(
          cassetteRackStateProvider(SidebarMode.messages),
        );

        expect(
          rack.cassettes,
          contains(
            const CassetteSpec.contacts(
              ContactsCassetteSpec.contactSelectionControl(chosenContactId: 42),
            ),
          ),
        );
        expect(
          rack.cassettes,
          contains(
            const CassetteSpec.contacts(
              ContactsCassetteSpec.contactHeroSummary(chosenContactId: 42),
            ),
          ),
        );
        expect(
          rack.cassettes,
          isNot(
            contains(
              const CassetteSpec.contacts(
                ContactsCassetteSpec.contactHeroSummary(chosenContactId: 41),
              ),
            ),
          ),
        );
        expect(
          rack.cassettes,
          isNot(
            contains(
              const CassetteSpec.contactsInfo(
                ContactsInfoCassetteSpec.infoCard(
                  key: ContactsInfoKey.chosenContact,
                  chosenContactId: 41,
                ),
              ),
            ),
          ),
        );
        expect(
          rack.cassettes,
          isNot(
            contains(
              const CassetteSpec.contacts(
                ContactsCassetteSpec.handleFilter(contactId: 41),
              ),
            ),
          ),
        );
      },
    );

    testWidgets(
      'chooseAnotherContact hides incompatible stored flow-managed center panel by derivation',
      (tester) async {
        await _mountMessagesPanelReconciliation(tester, container);

        final flow = container.read(sidebarFlowProvider.notifier);
        final panels = container.read(
          panelsViewStateProvider(SidebarMode.messages).notifier,
        );

        _switchToContacts(container);
        flow.contactChosen(contactId: 42, infoCardIndex: 1);
        panels.show(
          panel: WindowPanel.center,
          spec: const ViewSpec.messages(MessagesSpec.forContact(contactId: 42)),
        );

        flow.chooseAnotherContact(infoCardIndex: 1);

        await _flushMessagesPanelReconciliation(tester);

        final storedPanelState = container.read(
          panelsViewStateProvider(SidebarMode.messages),
        );

        expect(_activeSpec(container, WindowPanel.center), isNull);
        expect(storedPanelState[WindowPanel.center]?.isEmpty, isFalse);
      },
    );

    testWidgets('handleSelected updates selected handle and center panel', (
      tester,
    ) async {
      await _mountMessagesPanelReconciliation(tester, container);

      final flow = container.read(sidebarFlowProvider.notifier);

      _switchToContacts(container);
      flow.contactChosen(contactId: 42, infoCardIndex: 1);
      flow.handleSelected(contactId: 42, handleId: 7, cassetteIndex: 4);

      await _flushMessagesPanelReconciliation(tester);

      final flowState = container.read(sidebarFlowProvider);
      final rack = container.read(
        cassetteRackStateProvider(SidebarMode.messages),
      );
      final centerSpec = _activeSpec(container, WindowPanel.center);

      expect(flowState.chosenContactId, 42);
      expect(flowState.selectedHandleId, 7);
      expect(flowState.messageScope, SidebarFlowMessageScope.regular);
      expect(
        rack.cassettes[4],
        equals(
          const CassetteSpec.contacts(
            ContactsCassetteSpec.handleFilter(
              contactId: 42,
              selectedHandleId: 7,
            ),
          ),
        ),
      );
      expect(
        centerSpec,
        equals(
          const ViewSpec.messages(
            MessagesSpec.forContact(contactId: 42, filterHandleId: 7),
          ),
        ),
      );
    });

    testWidgets(
      'setContactMessageScope switches recovered mode and back to regular',
      (tester) async {
        await _mountMessagesPanelReconciliation(tester, container);

        final flow = container.read(sidebarFlowProvider.notifier);

        _switchToContacts(container);
        flow.contactChosen(contactId: 42, infoCardIndex: 1);
        flow.setContactMessageScope(
          contactId: 42,
          messageScope: SidebarFlowMessageScope.recoveredDeleted,
          cassetteIndex: 3,
        );

        await _flushMessagesPanelReconciliation(tester);

        expect(container.read(sidebarFlowProvider).selectedHandleId, isNull);
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

        flow.setContactMessageScope(
          contactId: 42,
          messageScope: SidebarFlowMessageScope.regular,
          cassetteIndex: 3,
        );

        await _flushMessagesPanelReconciliation(tester);

        expect(
          container.read(sidebarFlowProvider).messageScope,
          SidebarFlowMessageScope.regular,
        );
        expect(
          _activeSpec(container, WindowPanel.center),
          equals(
            const ViewSpec.messages(MessagesSpec.forContact(contactId: 42)),
          ),
        );
      },
    );

    testWidgets(
      'showContactTimelineAt clears handle filter in projected center spec',
      (tester) async {
        await _mountMessagesPanelReconciliation(tester, container);

        final flow = container.read(sidebarFlowProvider.notifier);
        final anchorDate = DateTime(2024, 05, 01);

        _switchToContacts(container);
        flow.contactChosen(contactId: 42, infoCardIndex: 1);
        flow.handleSelected(contactId: 42, handleId: 7, cassetteIndex: 4);
        flow.showContactTimelineAt(contactId: 42, scrollToDate: anchorDate);

        await _flushMessagesPanelReconciliation(tester);

        expect(container.read(sidebarFlowProvider).selectedHandleId, isNull);
        expect(container.read(sidebarFlowProvider).scrollToDate, anchorDate);
        expect(
          _activeSpec(container, WindowPanel.center),
          equals(
            ViewSpec.messages(
              MessagesSpec.forContact(contactId: 42, scrollToDate: anchorDate),
            ),
          ),
        );
      },
    );

    testWidgets(
      'projected center change leaves stored right panel but hides it by derivation',
      (tester) async {
        await _mountMessagesPanelReconciliation(tester, container);

        final flow = container.read(sidebarFlowProvider.notifier);
        final panels = container.read(
          panelsViewStateProvider(SidebarMode.messages).notifier,
        );

        _switchToContacts(container);
        flow.showGlobalTimeline();
        panels.show(
          panel: WindowPanel.right,
          spec: const ViewSpec.conversations(
            ConversationsSpec.conversationExcerpt(
              conversationId: 5,
              anchorMessageId: 99,
              originatingInvestigationId: SearchInvestigationId(0),
            ),
          ),
        );

        flow.showContactTimelineAt(contactId: 42);

        await _flushMessagesPanelReconciliation(tester);

        expect(_activeSpec(container, WindowPanel.right), isNull);
        expect(
          container
              .read(
                panelsViewStateProvider(SidebarMode.messages),
              )[WindowPanel.right]
              ?.isEmpty,
          isFalse,
        );
      },
    );

    testWidgets('top menu recovered no-handle branch projects center panel', (
      tester,
    ) async {
      await _mountMessagesPanelReconciliation(tester, container);

      container
          .read(sidebarFlowProvider.notifier)
          .topMenuChanged(
            choice: TopChatMenuChoice.recoveredNoHandleFromMeMessages,
            cassetteIndex: 0,
          );

      await _flushMessagesPanelReconciliation(tester);

      expect(
        _activeSpec(container, WindowPanel.center),
        equals(
          const ViewSpec.messages(
            MessagesSpec.recoveredNoHandleFromMeMessages(),
          ),
        ),
      );
    });

    test('top menu stray handles branch cascades the full review stack', () {
      container
          .read(sidebarFlowProvider.notifier)
          .topMenuChanged(
            choice: TopChatMenuChoice.strayHandles,
            cassetteIndex: 0,
          );

      final flowState = container.read(sidebarFlowProvider);
      final rack = container.read(
        cassetteRackStateProvider(SidebarMode.messages),
      );

      expect(flowState.topMenuChoice, TopChatMenuChoice.strayHandles);
      expect(
        flowState.projectedCenterSpec,
        equals(
          const ViewSpec.messages(
            MessagesSpec.handleInvestigation(
              investigationId: StrayHandleInvestigationId.initial,
              investigation: StrayHandleInvestigation.identifySources,
              target: HandleInvestigationTarget.idle(),
            ),
          ),
        ),
      );
      expect(
        rack.cassettes,
        equals([
          const CassetteSpec.sidebarUtility(
            SidebarUtilityCassetteSpec.topChatMenu(
              selectedChoice: TopChatMenuChoice.strayHandles,
            ),
          ),
          const CassetteSpec.handles(
            HandlesCassetteSpec.strayHandlesInvestigationSwitcher(),
          ),
          const CassetteSpec.handles(
            HandlesCassetteSpec.strayHandlesTypeSwitcher(),
          ),
          const CassetteSpec.handles(
            HandlesCassetteSpec.strayHandlesModeSwitcher(
              investigation: StrayHandleInvestigation.identifySources,
              filter: StrayHandleFilter.phones,
            ),
          ),
          const CassetteSpec.handles(
            HandlesCassetteSpec.strayHandlesReview(
              investigation: StrayHandleInvestigation.identifySources,
              filter: StrayHandleFilter.phones,
            ),
          ),
        ]),
      );
    });

    testWidgets('stray handle lens derives handle lens center spec', (
      tester,
    ) async {
      await _mountMessagesPanelReconciliation(tester, container);

      container
          .read(sidebarFlowProvider.notifier)
          .openStrayHandleLens(handleId: 7);

      await _flushMessagesPanelReconciliation(tester);

      final flowState = container.read(sidebarFlowProvider);
      expect(flowState.topMenuChoice, TopChatMenuChoice.strayHandles);
      expect(flowState.selectedHandleEvidenceId, 7);
      expect(
        flowState.selectedHandleEvidenceKind,
        SidebarFlowHandleEvidenceKind.lens,
      );
      expect(
        _activeSpec(container, WindowPanel.center),
        equals(
          ViewSpec.messages(
            MessagesSpec.handleInvestigation(
              investigationId: flowState.strayHandleInvestigationId!,
              investigation: StrayHandleInvestigation.identifySources,
              target: const HandleInvestigationTarget.selectedSource(
                handleId: 7,
              ),
            ),
          ),
        ),
      );
    });

    testWidgets(
      'new stray handle investigation makes stored handle evidence ineffective',
      (tester) async {
        await _mountMessagesPanelReconciliation(tester, container);

        final flow = container.read(sidebarFlowProvider.notifier);
        flow.openStrayHandleLens(handleId: 7);
        await _flushMessagesPanelReconciliation(tester);

        final originatingInvestigationId = container
            .read(sidebarFlowProvider)
            .selectedHandleEvidenceInvestigationId;
        expect(originatingInvestigationId, isNotNull);
        expect(
          _activeSpec(container, WindowPanel.center),
          equals(
            ViewSpec.messages(
              MessagesSpec.handleInvestigation(
                investigationId: originatingInvestigationId!,
                investigation: StrayHandleInvestigation.identifySources,
                target: const HandleInvestigationTarget.selectedSource(
                  handleId: 7,
                ),
              ),
            ),
          ),
        );

        flow.beginNewStrayHandleInvestigation();
        await _flushMessagesPanelReconciliation(tester);

        final flowState = container.read(sidebarFlowProvider);
        expect(flowState.selectedHandleEvidenceId, 7);
        expect(
          flowState.selectedHandleEvidenceInvestigationId,
          originatingInvestigationId,
        );
        expect(flowState.effectiveSelectedHandleEvidenceId, isNull);
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
        expect(_activeSpec(container, WindowPanel.center), isNotNull);
      },
    );

    testWidgets('handle messages derive standalone handle center spec', (
      tester,
    ) async {
      await _mountMessagesPanelReconciliation(tester, container);

      container
          .read(sidebarFlowProvider.notifier)
          .openHandleMessages(handleId: 9001);

      await _flushMessagesPanelReconciliation(tester);

      final flowState = container.read(sidebarFlowProvider);
      expect(flowState.topMenuChoice, TopChatMenuChoice.strayHandles);
      expect(flowState.selectedHandleEvidenceId, 9001);
      expect(
        flowState.selectedHandleEvidenceKind,
        SidebarFlowHandleEvidenceKind.messages,
      );
      expect(
        _activeSpec(container, WindowPanel.center),
        equals(const ViewSpec.messages(MessagesSpec.forHandle(handleId: 9001))),
      );
    });

    testWidgets(
      'showRecoveredDeletedAt stores month anchor in projected center spec',
      (tester) async {
        await _mountMessagesPanelReconciliation(tester, container);

        final flow = container.read(sidebarFlowProvider.notifier);
        final anchorDate = DateTime(2021, 09, 01);

        flow.showRecoveredDeletedAt(contactId: 42, startDate: anchorDate);

        await _flushMessagesPanelReconciliation(tester);

        expect(container.read(sidebarFlowProvider).scrollToDate, anchorDate);
        expect(
          _activeSpec(container, WindowPanel.center),
          equals(
            ViewSpec.messages(
              MessagesSpec.recoveredUnlinkedMessages(
                contactId: 42,
                scrollToDate: anchorDate,
              ),
            ),
          ),
        );
      },
    );
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
  if (panel == WindowPanel.right) {
    return container.read(
      effectiveRightPanelSpecProvider(SidebarMode.messages),
    );
  }

  return stacks[panel]?.activePage?.spec;
}

void _switchToContacts(ProviderContainer container) {
  container
      .read(sidebarFlowProvider.notifier)
      .topMenuChanged(choice: TopChatMenuChoice.contacts, cassetteIndex: 0);
}

CassetteSpec _topChatMenuSpec() {
  return const CassetteSpec.sidebarUtility(
    SidebarUtilityCassetteSpec.topChatMenu(
      selectedChoice: TopChatMenuChoice.contacts,
    ),
  );
}

int _contactSpecIndex(List<CassetteSpec> cassettes, ContactsCassetteSpec spec) {
  final index = cassettes.indexOf(CassetteSpec.contacts(spec));
  expect(index, greaterThanOrEqualTo(0));
  return index;
}

Future<void> _expectOverlaySetting(
  OverlayDatabase overlayDb,
  String key,
  String expectedValue,
) async {
  for (var attempt = 0; attempt < 10; attempt += 1) {
    final value = await overlayDb.readOverlaySetting(key);
    if (value == expectedValue) {
      expect(value, expectedValue);
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  expect(await overlayDb.readOverlaySetting(key), expectedValue);
}

class _AlwaysPopulatedGraph extends ConversationGraphPopulated {
  @override
  bool build() {
    return true;
  }
}
