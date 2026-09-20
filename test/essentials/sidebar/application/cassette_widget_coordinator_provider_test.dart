import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/config/theme/spacing/app_spacing.dart';
import 'package:remember_this_text/constants/domain/contact_constants.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers/conversation_graph_readiness_provider.dart';
import 'package:remember_this_text/essentials/navigation/domain/sidebar_mode.dart';
import 'package:remember_this_text/essentials/sidebar/application/cassette_rack_state_provider.dart';
import 'package:remember_this_text/essentials/sidebar/application/cassette_widget_coordinator_provider.dart';
import 'package:remember_this_text/essentials/sidebar/application/ephemeral_cassette_projection_provider.dart';
import 'package:remember_this_text/essentials/sidebar/application/renderable_sidebar_cassette_specs_provider.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_cassette_sectioning.dart';
import 'package:remember_this_text/essentials/sidebar/domain/entities/cassette_spec.dart';
import 'package:remember_this_text/essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_location_provider.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_configuration.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_state.dart';
import 'package:remember_this_text/features/contacts/application/read_models/contact_summary.dart';
import 'package:remember_this_text/features/contacts/application/read_models/contacts_list_repository_provider.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/payloads/contact_chooser_cassette_payload.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/payloads/contact_hero_summary_cassette_payload.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/payloads/contact_message_scope_toggle_cassette_payload.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/payloads/contact_selection_control_cassette_payload.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/payloads/handle_filter_cassette_payload.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/resolver_tools/contact_chooser_snapshot_provider.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/resolver_tools/filtered_picker_sections_provider.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/resolver_tools/picker_filter_mode_provider.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/resolver_tools/unified_picker_sections_provider.dart';
import 'package:remember_this_text/features/contacts/domain/participant_origin.dart';
import 'package:remember_this_text/features/contacts/domain/spec_classes/contacts_cassette_spec.dart';
import 'package:remember_this_text/features/handles/application/sidebar_cassette_spec/payloads/stray_handles_mode_switcher_cassette_payload.dart';
import 'package:remember_this_text/features/handles/application/sidebar_cassette_spec/payloads/stray_handles_review_cassette_payload.dart';
import 'package:remember_this_text/features/handles/application/state/stray_handle_mode_provider.dart';
import 'package:remember_this_text/features/handles/domain/spec_classes/handles_cassette_spec.dart';
import 'package:remember_this_text/features/messages/application/sidebar_cassette_spec/payloads/recovered_no_handle_from_me_navigator_cassette_payload.dart';
import 'package:remember_this_text/features/messages/application/sidebar_cassette_spec/payloads/recovered_unlinked_navigator_cassette_payload.dart';
import 'package:remember_this_text/features/messages/domain/spec_classes/messages_cassette_spec.dart';
import 'package:remember_this_text/features/messages/domain/spec_classes/messages_info_cassette_spec.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/payloads/attachment_archive_settings_cassette_payload.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/payloads/settings_info_actions_cassette_payload.dart';
import 'package:remember_this_text/features/settings/domain/spec_classes/settings_cassette_spec.dart';
import 'package:remember_this_text/features/sidebar_utilities/application/sidebar_cassette_spec/payloads/settings_top_menu_cassette_payload.dart';
import 'package:remember_this_text/features/sidebar_utilities/application/sidebar_cassette_spec/payloads/top_chat_menu_cassette_payload.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/sidebar_utilities_constants.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/spec_classes/sidebar_utility_cassette_spec.dart';

import '../../../test_support/cassette_rack_test_harness.dart';

void main() {
  group('sidebarCassetteResolutionStateProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          conversationGraphPopulatedProvider.overrideWith(
            _AlwaysPopulatedGraph.new,
          ),
          attachmentArchiveLocationProvider.overrideWith(
            () => _FixedAttachmentArchiveLocation(
              AttachmentArchiveLocationState.defaultAvailable(
                archiveRootPath: '/tmp/test-attachment-archive',
              ),
            ),
          ),
          ...cassetteRackTestHarnessOverrides(),
        ],
      );

      container
          .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
          .setRackForTesting([
            const CassetteSpec.handles(
              HandlesCassetteSpec.strayHandlesReview(
                investigation: StrayHandleInvestigation.identifySources,
                filter: StrayHandleFilter.phones,
              ),
            ),
          ]);
    });

    tearDown(() {
      container.dispose();
    });

    test('rebuilds stray handle review cassette when mode changes', () async {
      final initialWidgets = await _resolveSidebarCassettes(
        container,
        SidebarMode.messages,
      );
      expect(
        _strayHandlesReviewPayload(initialWidgets).mode,
        StrayHandleReviewMode.active,
      );

      container
          .read(strayHandleReviewModeSettingProvider.notifier)
          .setMode(StrayHandleReviewMode.dismissed);

      final updatedWidgets = await _resolveSidebarCassettes(
        container,
        SidebarMode.messages,
      );
      expect(
        _strayHandlesReviewPayload(updatedWidgets).mode,
        StrayHandleReviewMode.dismissed,
      );
    });

    test(
      'rebuilds stray handle mode switcher payload when mode changes',
      () async {
        container
            .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
            .setRackForTesting([
              const CassetteSpec.handles(
                HandlesCassetteSpec.strayHandlesModeSwitcher(
                  investigation: StrayHandleInvestigation.identifySources,
                  filter: StrayHandleFilter.phones,
                ),
              ),
            ]);

        final initialWidgets = await _resolveSidebarCassettes(
          container,
          SidebarMode.messages,
        );
        expect(
          _strayHandlesModeSwitcherPayload(initialWidgets).mode,
          StrayHandleReviewMode.active,
        );

        container
            .read(strayHandleReviewModeSettingProvider.notifier)
            .setMode(StrayHandleReviewMode.dismissed);

        final updatedWidgets = await _resolveSidebarCassettes(
          container,
          SidebarMode.messages,
        );
        expect(
          _strayHandlesModeSwitcherPayload(updatedWidgets).mode,
          StrayHandleReviewMode.dismissed,
        );
      },
    );

    test(
      'resolves settings menu cassette to mixed-row top menu payload',
      () async {
        container
            .read(cassetteRackStateProvider(SidebarMode.settings).notifier)
            .setRackForTesting([
              const CassetteSpec.sidebarUtility(
                SidebarUtilityCassetteSpec.settingsMenu(),
              ),
            ]);

        final payload = _settingsTopMenuPayload(
          await _resolveSidebarCassettes(container, SidebarMode.settings),
        );

        expect(
          payload.renderKind,
          SidebarCassetteRenderKind.placementGovernedFeature,
        );
        expect(payload.role, SidebarCassetteRole.appControl);
        expect(payload.promptLabel, 'Choose setting or action');
        expect(payload.persistentContextActionId, isNull);
        expect(payload.rows, hasLength(10));
      },
    );

    test(
      'renders settings menu plus ephemeral settings projection while hiding durable settings children',
      () async {
        container
            .read(cassetteRackStateProvider(SidebarMode.settings).notifier)
            .setRackForTesting([
              const CassetteSpec.sidebarUtility(
                SidebarUtilityCassetteSpec.settingsMenu(),
              ),
              const CassetteSpec.settings(SettingsCassetteSpec.textSizeInfo()),
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

        final resolved = await _resolveSidebarCassettes(
          container,
          SidebarMode.settings,
        );

        expect(resolved, hasLength(2));
        expect(
          resolved.map((cassette) => cassette.spec).toList(growable: false),
          equals([
            const CassetteSpec.sidebarUtility(
              SidebarUtilityCassetteSpec.settingsMenu(),
            ),
            const CassetteSpec.settings(SettingsCassetteSpec.sendLogsPanel()),
          ]),
        );
      },
    );

    test('renderable sidebar cassette specs concatenate without filtering', () {
      container
          .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
          .setRackForTesting([
            const CassetteSpec.contacts(
              ContactsCassetteSpec.messageScopeToggle(contactId: 42),
            ),
            const CassetteSpec.messages(
              MessagesCassetteSpec.heatMap(contactId: 42),
            ),
          ]);
      container
          .read(
            ephemeralCassetteProjectionProvider(SidebarMode.messages).notifier,
          )
          .replaceProjection(
            const CassetteSpec.settings(SettingsCassetteSpec.sendLogsPanel()),
          );

      final specs = container.read(
        renderableSidebarCassetteSpecsProvider(SidebarMode.messages),
      );

      expect(
        specs.map((entry) => entry.spec).toList(growable: false),
        equals([
          const CassetteSpec.contacts(
            ContactsCassetteSpec.messageScopeToggle(contactId: 42),
          ),
          const CassetteSpec.messages(
            MessagesCassetteSpec.heatMap(contactId: 42),
          ),
          const CassetteSpec.settings(SettingsCassetteSpec.sendLogsPanel()),
        ]),
      );
    });

    test(
      'resolves send logs settings spec to a single feature-info payload',
      () async {
        container
            .read(cassetteRackStateProvider(SidebarMode.settings).notifier)
            .setRackForTesting([
              const CassetteSpec.settings(SettingsCassetteSpec.sendLogsPanel()),
            ]);

        final payload = _settingsInfoActionsPayload(
          await _resolveSidebarCassettes(container, SidebarMode.settings),
        );

        expect(payload.renderKind, SidebarCassetteRenderKind.featureInfo);
        expect(payload.role, SidebarCassetteRole.action);
        expect(payload.actions, hasLength(1));
        expect(payload.actions.single.label, 'Send log data…');
        expect(payload.title, isNull);
      },
    );

    test(
      'resolves reset settings without generalized complete erase',
      () async {
        container
            .read(cassetteRackStateProvider(SidebarMode.settings).notifier)
            .setRackForTesting([
              const CassetteSpec.settings(
                SettingsCassetteSpec.resetMessageDataPanel(),
              ),
            ]);

        final payload = _settingsInfoActionsPayload(
          await _resolveSidebarCassettes(container, SidebarMode.settings),
        );

        expect(payload.renderKind, SidebarCassetteRenderKind.featureInfo);
        expect(payload.role, SidebarCassetteRole.action);
        expect(payload.bodyText, contains('Start Fresh'));
        expect(payload.actions, hasLength(1));
        expect(payload.actions.single.label, 'Reset message data…');
        expect(payload.title, 'Reset Message Data');
      },
    );

    test(
      'resolves text size info settings spec to feature-info payload',
      () async {
        container
            .read(cassetteRackStateProvider(SidebarMode.settings).notifier)
            .setRackForTesting([
              const CassetteSpec.settings(SettingsCassetteSpec.textSizeInfo()),
            ]);

        final payload = _staticFeatureInfoPayload(
          await _resolveSidebarCassettes(container, SidebarMode.settings),
        );

        expect(payload.title, 'Text Size');
        expect(payload.bodyText, 'Coming soon');
      },
    );

    test(
      'resolves attachment archive settings spec to location-status payload',
      () async {
        container
            .read(cassetteRackStateProvider(SidebarMode.settings).notifier)
            .setRackForTesting([
              const CassetteSpec.settings(
                SettingsCassetteSpec.attachmentArchive(),
              ),
            ]);

        final payload = _attachmentArchiveSettingsPayload(
          await _resolveSidebarCassettes(container, SidebarMode.settings),
        );

        expect(payload.renderKind, SidebarCassetteRenderKind.featureInfo);
        expect(payload.role, SidebarCassetteRole.action);
        expect(payload.bodyText, contains('Current archive'));
        expect(payload.bodyText, contains('/tmp/test-attachment-archive'));
        expect(payload.bodyText, contains('This Mac · Connected'));
        expect(payload.bodyText, isNot(contains('Internal')));
      },
    );

    test(
      'renders unavailable archive with physical status and no move action',
      () async {
        final unavailableContainer = ProviderContainer(
          overrides: [
            conversationGraphPopulatedProvider.overrideWith(
              _AlwaysPopulatedGraph.new,
            ),
            attachmentArchiveLocationProvider.overrideWith(
              () => _FixedAttachmentArchiveLocation(
                AttachmentArchiveLocationState.customUnavailable(
                  configuration:
                      AttachmentArchiveLocationConfiguration.customExternal(
                        bookmarkDataBase64: 'AQID',
                        lastKnownPath: '/Volumes/Offline/Archive',
                        volumeName: 'Offline',
                      ),
                  issue: 'Volume disconnected.',
                  generation: 5,
                ),
              ),
            ),
            ...cassetteRackTestHarnessOverrides(),
          ],
        );
        addTearDown(unavailableContainer.dispose);
        unavailableContainer
            .read(cassetteRackStateProvider(SidebarMode.settings).notifier)
            .setRackForTesting([
              const CassetteSpec.settings(
                SettingsCassetteSpec.attachmentArchive(),
              ),
            ]);

        final payload = _attachmentArchiveSettingsPayload(
          await _resolveSidebarCassettes(
            unavailableContainer,
            SidebarMode.settings,
          ),
        );

        expect(
          payload.bodyText,
          contains('Archived attachments are unavailable'),
        );
        expect(payload.bodyText, contains('/Volumes/Offline/Archive'));
        expect(payload.bodyText, contains('Offline · Not connected'));
        expect(payload.bodyText, isNot(contains('customExternal')));
        expect(payload.bodyText, isNot(contains('Move Archive')));
      },
    );

    test(
      'resolves recovered deleted messages info spec to inert payload',
      () async {
        container
            .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
            .setRackForTesting([
              const CassetteSpec.messagesInfo(
                MessagesInfoCassetteSpec.infoCard(
                  key: MessagesInfoKey.recoveredDeletedMessages,
                ),
              ),
            ]);

        final payload = _recoveredUnlinkedNavigatorPayload(
          await _resolveSidebarCassettes(container, SidebarMode.messages),
        );

        expect(payload.cassetteIndex, 0);
        expect(payload.topSpacing, AppSpacing.lg);
        expect(
          payload.renderKind,
          SidebarCassetteRenderKind.placementGovernedFeature,
        );
      },
    );

    test(
      'resolves search-all-messages info spec to static feature-info payload',
      () async {
        container
            .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
            .setRackForTesting([
              const CassetteSpec.messagesInfo(
                MessagesInfoCassetteSpec.infoCard(
                  key: MessagesInfoKey.searchAllMessages,
                ),
              ),
            ]);

        final payload = _staticFeatureInfoPayload(
          await _resolveSidebarCassettes(container, SidebarMode.messages),
        );

        expect(
          payload.bodyText,
          contains('heatmap below represents all the messages'),
        );
        expect(payload.renderKind, SidebarCassetteRenderKind.featureInfo);
      },
    );

    test(
      'resolves recovered no-handle messages info spec to inert payload',
      () async {
        container
            .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
            .setRackForTesting([
              const CassetteSpec.messagesInfo(
                MessagesInfoCassetteSpec.infoCard(
                  key: MessagesInfoKey.recoveredNoHandleMessages,
                ),
              ),
            ]);

        final payload = _recoveredNoHandleNavigatorPayload(
          await _resolveSidebarCassettes(container, SidebarMode.messages),
        );

        expect(payload.cassetteIndex, 0);
        expect(payload.topSpacing, 0);
        expect(
          payload.renderKind,
          SidebarCassetteRenderKind.placementGovernedFeature,
        );
      },
    );

    test('resolves top chat menu spec to inert payload', () async {
      container
          .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
          .setRackForTesting([
            const CassetteSpec.sidebarUtility(
              SidebarUtilityCassetteSpec.topChatMenu(
                selectedChoice: TopChatMenuChoice.contacts,
              ),
            ),
          ]);

      final payload = _topChatMenuPayload(
        await _resolveSidebarCassettes(container, SidebarMode.messages),
      );

      expect(payload.currentChoice, TopChatMenuChoice.contacts);
      expect(payload.cassetteIndex, 0);
      expect(payload.sidebarMode, SidebarMode.messages);
      expect(payload.isNaked, isTrue);
    });

    test(
      'resolves contact chooser payload without waiting for picker data',
      () async {
        final delayedContacts = Completer<List<ContactSummary>>();
        final delayedSections = Completer<UnifiedPickerSections>();

        container.dispose();
        container = ProviderContainer(
          overrides: [
            conversationGraphPopulatedProvider.overrideWith(
              _AlwaysPopulatedGraph.new,
            ),
            contactsListRepositoryProvider.overrideWith(
              (ref) => delayedContacts.future,
            ),
            filteredPickerSectionsProvider.overrideWith(
              (ref) => delayedSections.future,
            ),
            pickerFilterProvider.overrideWith(_TestPickerFilter.new),
            ...cassetteRackTestHarnessOverrides(),
          ],
        );

        container
            .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
            .setRackForTesting([
              const CassetteSpec.contacts(
                ContactsCassetteSpec.contactChooser(),
              ),
            ]);

        final payload = _contactChooserPayload(
          await _resolveSidebarCassettes(container, SidebarMode.messages),
        );

        expect(payload.cassetteIndex, 0);
        expect(payload.chosenContactId, isNull);
        expect(payload.loadState, ContactChooserLoadState.loading);
        expect(payload.pickerMode, isNull);
        expect(payload.pickerFilterMode, isNull);
        expect(payload.filteredSections, isNull);
      },
    );

    test(
      'chooser readiness updates the shared cassette resolution payload',
      () async {
        const chosenContactId = 42;
        const readySections = UnifiedPickerSections(
          sections: <PickerSection>[],
          alphabeticalLetters: <String>[],
          alphabeticalStartIndex: 0,
          allFavoriteIds: <int>{},
        );

        container.dispose();
        container = ProviderContainer(
          overrides: [
            conversationGraphPopulatedProvider.overrideWith(
              _AlwaysPopulatedGraph.new,
            ),
            contactsListRepositoryProvider.overrideWith(
              (ref) async => const <ContactSummary>[
                ContactSummary(
                  participantId: 42,
                  displayName: 'Ada Lovelace',
                  autoGeneratedName: 'Ada Lovelace',
                  totalChats: 1,
                  totalMessages: 2,
                  origin: ParticipantOrigin.working,
                  handleCount: 1,
                ),
              ],
            ),
            filteredPickerSectionsProvider.overrideWith(
              (ref) async => readySections,
            ),
            pickerFilterProvider.overrideWith(_TestPickerFilter.new),
            ...cassetteRackTestHarnessOverrides(),
          ],
        );

        container
            .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
            .setRackForTesting([
              const CassetteSpec.contacts(
                ContactsCassetteSpec.contactChooser(
                  chosenContactId: chosenContactId,
                ),
              ),
            ]);

        final initialPayload = _contactChooserPayload(
          await _awaitFirstResolvedSidebarCassettes(
            container,
            SidebarMode.messages,
          ),
        );

        expect(initialPayload.chosenContactId, chosenContactId);
        expect(initialPayload.loadState, ContactChooserLoadState.loading);

        await container.read(contactsListRepositoryProvider.future);
        await container.read(filteredPickerSectionsProvider.future);

        final stablePayload = _contactChooserPayload(
          await _resolveSidebarCassettes(container, SidebarMode.messages),
        );

        expect(stablePayload.chosenContactId, chosenContactId);
        expect(stablePayload.loadState, ContactChooserLoadState.ready);
        expect(stablePayload.pickerMode, ContactPickerMode.flat);
        expect(stablePayload.pickerFilterMode, PickerFilterMode.all);
        expect(stablePayload.filteredSections, same(readySections));
      },
    );

    test('contact chooser snapshot upgrades from loading to ready', () async {
      const readySections = UnifiedPickerSections(
        sections: <PickerSection>[],
        alphabeticalLetters: <String>[],
        alphabeticalStartIndex: 0,
        allFavoriteIds: <int>{},
      );

      container.dispose();
      container = ProviderContainer(
        overrides: [
          conversationGraphPopulatedProvider.overrideWith(
            _AlwaysPopulatedGraph.new,
          ),
          contactsListRepositoryProvider.overrideWith(
            (ref) async => const <ContactSummary>[
              ContactSummary(
                participantId: 42,
                displayName: 'Ada Lovelace',
                autoGeneratedName: 'Ada Lovelace',
                totalChats: 1,
                totalMessages: 2,
                origin: ParticipantOrigin.working,
                handleCount: 1,
              ),
            ],
          ),
          filteredPickerSectionsProvider.overrideWith(
            (ref) async => readySections,
          ),
          pickerFilterProvider.overrideWith(_TestPickerFilter.new),
        ],
      );

      final initialSnapshot = container.read(contactChooserSnapshotProvider);
      expect(initialSnapshot.loadState, ContactChooserLoadState.loading);

      await container.read(contactsListRepositoryProvider.future);
      await container.read(filteredPickerSectionsProvider.future);

      final readySnapshot = container.read(contactChooserSnapshotProvider);
      expect(readySnapshot.loadState, ContactChooserLoadState.ready);
      expect(readySnapshot.pickerMode, ContactPickerMode.flat);
      expect(readySnapshot.pickerFilterMode, PickerFilterMode.all);
      expect(readySnapshot.filteredSections, same(readySections));
    });

    test('resolves message scope toggle spec to inert payload', () async {
      container
          .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
          .setRackForTesting([
            const CassetteSpec.contacts(
              ContactsCassetteSpec.messageScopeToggle(contactId: 42),
            ),
          ]);

      final payload = _contactMessageScopeTogglePayload(
        await _resolveSidebarCassettes(container, SidebarMode.messages),
      );

      expect(payload.contactId, 42);
      expect(payload.isNaked, isTrue);
    });

    test('resolves contact hero summary spec to inert payload', () async {
      container
          .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
          .setRackForTesting([
            const CassetteSpec.contacts(
              ContactsCassetteSpec.contactHeroSummary(chosenContactId: 42),
            ),
          ]);

      final payload = _contactHeroSummaryPayload(
        await _resolveSidebarCassettes(container, SidebarMode.messages),
      );

      expect(payload.contactId, 42);
      expect(payload.cassetteIndex, 0);
      expect(payload.isNaked, isTrue);
      expect(payload.shouldExpand, isFalse);
    });

    test('resolves contact selection control spec to inert payload', () async {
      container
          .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
          .setRackForTesting([
            const CassetteSpec.contacts(
              ContactsCassetteSpec.contactSelectionControl(chosenContactId: 42),
            ),
          ]);

      final payload = _contactSelectionControlPayload(
        await _resolveSidebarCassettes(container, SidebarMode.messages),
      );

      expect(payload.contactId, 42);
      expect(payload.cassetteIndex, 0);
      expect(payload.isNaked, isTrue);
    });

    test(
      'audits chosen-contact sidebar roles, semantic styles, and spacing',
      () async {
        container
            .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
            .setRackForTesting([
              const CassetteSpec.sidebarUtility(
                SidebarUtilityCassetteSpec.topChatMenu(),
              ),
              const CassetteSpec.contacts(
                ContactsCassetteSpec.contactSelectionControl(
                  chosenContactId: 42,
                ),
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

        final resolved = await _resolveSidebarCassettes(
          container,
          SidebarMode.messages,
        );

        expect(resolved, hasLength(6));
        expect(
          resolved.map((cassette) => cassette.payload.role).toList(),
          equals([
            SidebarCassetteRole.appControl,
            SidebarCassetteRole.appControl,
            SidebarCassetteRole.contextPrimary,
            SidebarCassetteRole.filter,
            SidebarCassetteRole.filter,
            SidebarCassetteRole.contextPrimary,
          ]),
        );
        expect(
          resolved
              .map(
                (cassette) =>
                    sidebarCassetteSemanticStyleForPayload(cassette.payload),
              )
              .toList(),
          equals([
            SidebarCassetteSemanticStyle.plain,
            SidebarCassetteSemanticStyle.plain,
            SidebarCassetteSemanticStyle.primaryContextGroup,
            SidebarCassetteSemanticStyle.groupedControls,
            SidebarCassetteSemanticStyle.groupedControls,
            SidebarCassetteSemanticStyle.visualization,
          ]),
        );
        expect(resolved[0].topSpacing, 0);
        expect(resolved[1].topSpacing, sidebarCassetteInternalSectionSpacing);
        expect(resolved[2].topSpacing, sidebarCassetteMicroSpacing);
        expect(resolved[3].topSpacing, sidebarCassetteInterSectionSpacing);
        expect(resolved[4].topSpacing, sidebarCassetteInternalSectionSpacing);
        expect(resolved[5].topSpacing, sidebarCassetteInterSectionSpacing);
      },
    );

    test('resolves handle filter spec to inert payload', () async {
      container
          .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
          .setRackForTesting([
            const CassetteSpec.contacts(
              ContactsCassetteSpec.handleFilter(
                contactId: 42,
                selectedHandleId: 7,
              ),
            ),
          ]);

      final payload = _handleFilterPayload(
        await _resolveSidebarCassettes(container, SidebarMode.messages),
      );

      expect(payload.contactId, 42);
      expect(payload.selectedHandleId, 7);

      expect(payload.cassetteIndex, 0);
      expect(payload.isNaked, isTrue);
    });
  });
}

Future<List<ResolvedSidebarCassette>> _resolveSidebarCassettes(
  ProviderContainer container,
  SidebarMode mode,
) async {
  final initialState = container.read(
    sidebarCassetteResolutionStateProvider(mode),
  );
  if (_isCompleteResolutionState(initialState)) {
    return initialState.resolvedCassettes;
  }

  final completer = Completer<SidebarCassetteResolutionState>();
  final subscription = container.listen<SidebarCassetteResolutionState>(
    sidebarCassetteResolutionStateProvider(mode),
    (previous, next) {
      if (_isCompleteResolutionState(next) && !completer.isCompleted) {
        completer.complete(next);
      }
    },
    fireImmediately: true,
  );

  try {
    final state = await completer.future.timeout(const Duration(seconds: 5));
    return state.resolvedCassettes;
  } finally {
    subscription.close();
  }
}

Future<List<ResolvedSidebarCassette>> _awaitFirstResolvedSidebarCassettes(
  ProviderContainer container,
  SidebarMode mode,
) async {
  final initialState = container.read(
    sidebarCassetteResolutionStateProvider(mode),
  );
  if (initialState.resolvedCassettes.isNotEmpty) {
    return initialState.resolvedCassettes;
  }

  final completer = Completer<List<ResolvedSidebarCassette>>();
  final subscription = container.listen<SidebarCassetteResolutionState>(
    sidebarCassetteResolutionStateProvider(mode),
    (previous, next) {
      if (next.resolvedCassettes.isNotEmpty && !completer.isCompleted) {
        completer.complete(next.resolvedCassettes);
      }
    },
    fireImmediately: true,
  );

  try {
    return await completer.future.timeout(const Duration(seconds: 5));
  } finally {
    subscription.close();
  }
}

bool _isCompleteResolutionState(SidebarCassetteResolutionState state) {
  return state.hasCompleteResolvedRack && !state.isLoading;
}

StrayHandlesReviewCassettePayload _strayHandlesReviewPayload(
  List<ResolvedSidebarCassette> resolvedCassettes,
) {
  expect(resolvedCassettes, hasLength(1));
  final payload = resolvedCassettes.single.payload;
  expect(payload, isA<StrayHandlesReviewCassettePayload>());
  return payload as StrayHandlesReviewCassettePayload;
}

StrayHandlesModeSwitcherCassettePayload _strayHandlesModeSwitcherPayload(
  List<ResolvedSidebarCassette> resolvedCassettes,
) {
  expect(resolvedCassettes, hasLength(1));
  final payload = resolvedCassettes.single.payload;
  expect(payload, isA<StrayHandlesModeSwitcherCassettePayload>());
  return payload as StrayHandlesModeSwitcherCassettePayload;
}

SettingsTopMenuCassettePayload _settingsTopMenuPayload(
  List<ResolvedSidebarCassette> resolvedCassettes,
) {
  expect(resolvedCassettes, hasLength(1));
  final payload = resolvedCassettes.single.payload;
  expect(payload, isA<SettingsTopMenuCassettePayload>());
  return payload as SettingsTopMenuCassettePayload;
}

SettingsInfoActionsCassettePayload _settingsInfoActionsPayload(
  List<ResolvedSidebarCassette> resolvedCassettes,
) {
  expect(resolvedCassettes, hasLength(1));
  final payload = resolvedCassettes.single.payload;
  expect(payload, isA<SettingsInfoActionsCassettePayload>());
  return payload as SettingsInfoActionsCassettePayload;
}

AttachmentArchiveSettingsCassettePayload _attachmentArchiveSettingsPayload(
  List<ResolvedSidebarCassette> resolvedCassettes,
) {
  expect(resolvedCassettes, hasLength(1));
  final payload = resolvedCassettes.single.payload;
  expect(payload, isA<AttachmentArchiveSettingsCassettePayload>());
  return payload as AttachmentArchiveSettingsCassettePayload;
}

final class _FixedAttachmentArchiveLocation extends AttachmentArchiveLocation {
  _FixedAttachmentArchiveLocation(this.location);

  final AttachmentArchiveLocationState location;

  @override
  Future<AttachmentArchiveLocationState> build() async => location;
}

StaticFeatureInfoSidebarCassettePayload _staticFeatureInfoPayload(
  List<ResolvedSidebarCassette> resolvedCassettes,
) {
  expect(resolvedCassettes, hasLength(1));
  final payload = resolvedCassettes.single.payload;
  expect(payload, isA<StaticFeatureInfoSidebarCassettePayload>());
  return payload as StaticFeatureInfoSidebarCassettePayload;
}

RecoveredUnlinkedNavigatorCassettePayload _recoveredUnlinkedNavigatorPayload(
  List<ResolvedSidebarCassette> resolvedCassettes,
) {
  expect(resolvedCassettes, hasLength(1));
  final payload = resolvedCassettes.single.payload;
  expect(payload, isA<RecoveredUnlinkedNavigatorCassettePayload>());
  return payload as RecoveredUnlinkedNavigatorCassettePayload;
}

RecoveredNoHandleFromMeNavigatorCassettePayload
_recoveredNoHandleNavigatorPayload(
  List<ResolvedSidebarCassette> resolvedCassettes,
) {
  expect(resolvedCassettes, hasLength(1));
  final payload = resolvedCassettes.single.payload;
  expect(payload, isA<RecoveredNoHandleFromMeNavigatorCassettePayload>());
  return payload as RecoveredNoHandleFromMeNavigatorCassettePayload;
}

ContactChooserCassettePayload _contactChooserPayload(
  List<ResolvedSidebarCassette> resolvedCassettes,
) {
  expect(resolvedCassettes, hasLength(1));
  final payload = resolvedCassettes.single.payload;
  expect(payload, isA<ContactChooserCassettePayload>());
  return payload as ContactChooserCassettePayload;
}

ContactHeroSummaryCassettePayload _contactHeroSummaryPayload(
  List<ResolvedSidebarCassette> resolvedCassettes,
) {
  expect(resolvedCassettes, hasLength(1));
  final payload = resolvedCassettes.single.payload;
  expect(payload, isA<ContactHeroSummaryCassettePayload>());
  return payload as ContactHeroSummaryCassettePayload;
}

ContactMessageScopeToggleCassettePayload _contactMessageScopeTogglePayload(
  List<ResolvedSidebarCassette> resolvedCassettes,
) {
  expect(resolvedCassettes, hasLength(1));
  final payload = resolvedCassettes.single.payload;
  expect(payload, isA<ContactMessageScopeToggleCassettePayload>());
  return payload as ContactMessageScopeToggleCassettePayload;
}

ContactSelectionControlCassettePayload _contactSelectionControlPayload(
  List<ResolvedSidebarCassette> resolvedCassettes,
) {
  expect(resolvedCassettes, hasLength(1));
  final payload = resolvedCassettes.single.payload;
  expect(payload, isA<ContactSelectionControlCassettePayload>());
  return payload as ContactSelectionControlCassettePayload;
}

HandleFilterCassettePayload _handleFilterPayload(
  List<ResolvedSidebarCassette> resolvedCassettes,
) {
  expect(resolvedCassettes, hasLength(1));
  final payload = resolvedCassettes.single.payload;
  expect(payload, isA<HandleFilterCassettePayload>());
  return payload as HandleFilterCassettePayload;
}

TopChatMenuCassettePayload _topChatMenuPayload(
  List<ResolvedSidebarCassette> resolvedCassettes,
) {
  expect(resolvedCassettes, hasLength(1));
  final payload = resolvedCassettes.single.payload;
  expect(payload, isA<TopChatMenuCassettePayload>());
  return payload as TopChatMenuCassettePayload;
}

class _AlwaysPopulatedGraph extends ConversationGraphPopulated {
  @override
  bool build() {
    return true;
  }
}

class _TestPickerFilter extends PickerFilter {
  @override
  PickerFilterMode build() {
    return PickerFilterMode.all;
  }
}
