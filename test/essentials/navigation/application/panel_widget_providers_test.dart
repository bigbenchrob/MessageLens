import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/config/theme/widgets/layout/cross_column_track_plan.dart';
import 'package:remember_this_text/config/theme/widgets/layout/page_track_layout_matrix.dart';
import 'package:remember_this_text/config/theme/widgets/layout/resolved_track_layout_matrix.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers/conversation_graph_readiness_provider.dart';
import 'package:remember_this_text/essentials/navigation/application/panel_widget_providers.dart';
import 'package:remember_this_text/essentials/navigation/application/panels_view_state_provider.dart';
import 'package:remember_this_text/essentials/navigation/domain/entities/view_spec.dart';
import 'package:remember_this_text/essentials/navigation/domain/navigation_constants.dart';
import 'package:remember_this_text/essentials/navigation/domain/sidebar_mode.dart';
import 'package:remember_this_text/essentials/sidebar/application/cassette_rack_state_provider.dart';
import 'package:remember_this_text/essentials/sidebar/application/cassette_widget_coordinator_provider.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_flow_state_provider.dart';
import 'package:remember_this_text/essentials/sidebar/domain/entities/cassette_spec.dart';
import 'package:remember_this_text/essentials/sidebar/domain/sidebar_action_intent.dart';
import 'package:remember_this_text/essentials/sidebar/domain/sidebar_body_model.dart';
import 'package:remember_this_text/essentials/sidebar/domain/sidebar_body_option.dart';
import 'package:remember_this_text/essentials/sidebar/presentation/view/sidebar_grouped_control_section_surface.dart';
import 'package:remember_this_text/essentials/sidebar/presentation/view/sidebar_info_card.dart';
import 'package:remember_this_text/essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import 'package:remember_this_text/features/contacts/domain/spec_classes/contacts_cassette_spec.dart';
import 'package:remember_this_text/features/contacts/domain/spec_classes/contacts_info_cassette_spec.dart';
import 'package:remember_this_text/features/conversations/application/view_spec/coordinators/view_spec_coordinator.dart'
    as conversations_view_spec;
import 'package:remember_this_text/features/conversations/domain/spec_classes/conversations_view_spec.dart';
import 'package:remember_this_text/features/environment_readiness/domain/spec_classes/environment_readiness_view_spec.dart';
import 'package:remember_this_text/features/messages/application/view_spec/coordinators/view_spec_coordinator.dart'
    as messages_view_spec;
import 'package:remember_this_text/features/messages/domain/search_investigation_id.dart';
import 'package:remember_this_text/features/messages/domain/spec_classes/messages_view_spec.dart';
import 'package:remember_this_text/features/settings/application/view_spec/coordinators/view_spec_coordinator.dart'
    as settings_view_spec;
import 'package:remember_this_text/features/settings/application/view_spec/payloads/settings_panel_render_descriptor.dart';
import 'package:remember_this_text/features/settings/domain/spec_classes/settings_cassette_spec.dart';
import 'package:remember_this_text/features/settings/domain/spec_classes/settings_view_spec.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/sidebar_utilities_constants.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/spec_classes/sidebar_utility_cassette_spec.dart';
import '../../../test_support/cassette_rack_test_harness.dart';

final _testSidebarResolutionStateProvider =
    StateProvider<SidebarCassetteResolutionState>((ref) {
      return const SidebarCassetteResolutionState(
        resolvedCassettes: <ResolvedSidebarCassette>[],
        expectedVisibleCount: 0,
        isLoading: false,
      );
    });

void main() {
  group('isPinnedAppControlCassette', () {
    test('returns true only for app-control resolved cassettes', () {
      final appControlCassette = _resolvedCassette(
        payload: const StaticFeatureInfoSidebarCassettePayload(
          bodyText: 'top-menu',
          role: SidebarCassetteRole.appControl,
        ),
      );
      final contextCassette = _resolvedCassette(
        payload: const StaticFeatureInfoSidebarCassettePayload(
          bodyText: 'context',
          role: SidebarCassetteRole.contextPrimary,
        ),
      );

      expect(isPinnedAppControlCassette(appControlCassette), isTrue);
      expect(isPinnedAppControlCassette(contextCassette), isFalse);
    });
  });

  group('shouldExpandSidebarCassette', () {
    test('reads expansion directly from resolved cassette payloads', () {
      final expandingCassette = _resolvedCassette(
        payload: const SharedBodyModelSidebarCassettePayload(
          bodyModel: SidebarInfoBodyModel(bodyText: 'body'),
          shouldExpand: true,
        ),
      );
      final intrinsicCassette = _resolvedCassette(
        payload: const SharedBodyModelSidebarCassettePayload(
          bodyModel: SidebarInfoBodyModel(bodyText: 'body'),
        ),
      );
      final infoCassette = _resolvedCassette(
        payload: const StaticFeatureInfoSidebarCassettePayload(
          bodyText: 'info',
        ),
      );

      expect(shouldExpandSidebarCassette(expandingCassette), isTrue);
      expect(shouldExpandSidebarCassette(intrinsicCassette), isFalse);
      expect(shouldExpandSidebarCassette(infoCassette), isFalse);
    });
  });

  group('left sidebar layout contract', () {
    testWidgets(
      'Search renders matrix cells before continuing normal cassette content',
      (tester) async {
        const topMenuSpec = CassetteSpec.sidebarUtility(
          SidebarUtilityCassetteSpec.topChatMenu(
            selectedChoice: TopChatMenuChoice.searchAllMessages,
          ),
        );
        const infoSpec = CassetteSpec.contactsInfo(
          ContactsInfoCassetteSpec.infoCard(
            key: ContactsInfoKey.pickerContentSources,
          ),
        );
        final container = ProviderContainer(
          overrides: [
            conversationGraphPopulatedProvider.overrideWith(
              _AlwaysPopulatedGraph.new,
            ),
            ...cassetteRackTestHarnessOverrides(),
            sidebarCassetteResolutionStateProvider(
              SidebarMode.messages,
            ).overrideWith((ref) {
              return ref.watch(_testSidebarResolutionStateProvider);
            }),
          ],
        );
        final rackSubscription = container.listen(
          cassetteRackStateProvider(SidebarMode.messages),
          (_, __) {},
          fireImmediately: true,
        );
        final resolutionSubscription = container.listen(
          sidebarCassetteResolutionStateProvider(SidebarMode.messages),
          (_, __) {},
          fireImmediately: true,
        );
        container
            .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
            .setRackForTesting([topMenuSpec, infoSpec]);
        container
            .read(_testSidebarResolutionStateProvider.notifier)
            .state = const SidebarCassetteResolutionState(
          resolvedCassettes: <ResolvedSidebarCassette>[
            ResolvedSidebarCassette(
              spec: topMenuSpec,
              cassetteIndex: 0,
              payload: StaticFeatureInfoSidebarCassettePayload(
                bodyText: 'legacy-top-menu',
                role: SidebarCassetteRole.appControl,
              ),
            ),
            ResolvedSidebarCassette(
              spec: infoSpec,
              cassetteIndex: 1,
              payload: StaticFeatureInfoSidebarCassettePayload(
                bodyText: 'cassette-content',
              ),
              topSpacing: 24,
            ),
          ],
          expectedVisibleCount: 2,
          isLoading: false,
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: ResolvedTrackLayoutMatrixScope(
                matrix: _testSearchSidebarMatrix(),
                child: const SizedBox(
                  width: 320,
                  height: 600,
                  child: LeftPanelHost(mode: SidebarMode.messages),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('matrix-top-menu'), findsOneWidget);
        expect(find.text('legacy-top-menu'), findsNothing);
        expect(find.text('cassette-content'), findsOneWidget);
        expect(_renderedTrackCellIds(tester), const [
          CellId(trackId: TrackId.trackA, columnId: TrackColumnId.column1),
          CellId(trackId: TrackId.trackE, columnId: TrackColumnId.column1),
          CellId(trackId: TrackId.trackF, columnId: TrackColumnId.column1),
        ]);
        final contentTopWithCassetteSpacing = tester
            .getTopLeft(find.text('cassette-content'))
            .dy;

        container
            .read(_testSidebarResolutionStateProvider.notifier)
            .state = const SidebarCassetteResolutionState(
          resolvedCassettes: <ResolvedSidebarCassette>[
            ResolvedSidebarCassette(
              spec: topMenuSpec,
              cassetteIndex: 0,
              payload: StaticFeatureInfoSidebarCassettePayload(
                bodyText: 'legacy-top-menu',
                role: SidebarCassetteRole.appControl,
              ),
            ),
            ResolvedSidebarCassette(
              spec: infoSpec,
              cassetteIndex: 1,
              payload: StaticFeatureInfoSidebarCassettePayload(
                bodyText: 'cassette-content',
              ),
            ),
          ],
          expectedVisibleCount: 2,
          isLoading: false,
        );
        await tester.pump();

        expect(
          tester.getTopLeft(find.text('cassette-content')).dy,
          contentTopWithCassetteSpacing,
        );

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        resolutionSubscription.close();
        rackSubscription.close();
        await tester.idle();
        container.dispose();
        await tester.pump();
      },
    );

    testWidgets(
      'track-enabled rack uses native flow while resolved matrix is absent',
      (tester) async {
        const topMenuSpec = CassetteSpec.sidebarUtility(
          SidebarUtilityCassetteSpec.topChatMenu(
            selectedChoice: TopChatMenuChoice.searchAllMessages,
          ),
        );
        const infoSpec = CassetteSpec.contactsInfo(
          ContactsInfoCassetteSpec.infoCard(
            key: ContactsInfoKey.pickerContentSources,
          ),
        );
        final container = ProviderContainer(
          overrides: [
            conversationGraphPopulatedProvider.overrideWith(
              _AlwaysPopulatedGraph.new,
            ),
            ...cassetteRackTestHarnessOverrides(),
            sidebarCassetteResolutionStateProvider(
              SidebarMode.messages,
            ).overrideWith((ref) {
              return ref.watch(_testSidebarResolutionStateProvider);
            }),
          ],
        );
        final rackSubscription = container.listen(
          cassetteRackStateProvider(SidebarMode.messages),
          (_, __) {},
          fireImmediately: true,
        );
        final resolutionSubscription = container.listen(
          sidebarCassetteResolutionStateProvider(SidebarMode.messages),
          (_, __) {},
          fireImmediately: true,
        );
        container
            .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
            .setRackForTesting([topMenuSpec, infoSpec]);
        container
            .read(_testSidebarResolutionStateProvider.notifier)
            .state = const SidebarCassetteResolutionState(
          resolvedCassettes: <ResolvedSidebarCassette>[
            ResolvedSidebarCassette(
              spec: topMenuSpec,
              cassetteIndex: 0,
              payload: StaticFeatureInfoSidebarCassettePayload(
                bodyText: 'native-top-menu',
                role: SidebarCassetteRole.appControl,
              ),
            ),
            ResolvedSidebarCassette(
              spec: infoSpec,
              cassetteIndex: 1,
              payload: StaticFeatureInfoSidebarCassettePayload(
                bodyText: 'native-content',
              ),
            ),
          ],
          expectedVisibleCount: 2,
          isLoading: false,
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const Directionality(
              textDirection: TextDirection.ltr,
              child: SizedBox(
                width: 320,
                height: 600,
                child: LeftPanelHost(mode: SidebarMode.messages),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.text('native-top-menu'), findsOneWidget);
        expect(find.text('native-content'), findsOneWidget);
        expect(find.byType(TrackCellView), findsNothing);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        resolutionSubscription.close();
        rackSubscription.close();
        await tester.idle();
        container.dispose();
        await tester.pump();
      },
    );

    testWidgets(
      'unfamiliar sources resumes cassette flow after A1 with coordinator spacing',
      (tester) async {
        const topMenuSpec = CassetteSpec.sidebarUtility(
          SidebarUtilityCassetteSpec.topChatMenu(
            selectedChoice: TopChatMenuChoice.strayHandles,
          ),
        );
        const firstControlSpec = CassetteSpec.contactsInfo(
          ContactsInfoCassetteSpec.infoCard(
            key: ContactsInfoKey.pickerContentSources,
          ),
        );
        const secondControlSpec = CassetteSpec.contacts(
          ContactsCassetteSpec.contactHeroSummary(chosenContactId: 42),
        );
        const listSpec = CassetteSpec.sidebarUtility(
          SidebarUtilityCassetteSpec.settingsMenu(),
        );
        final container = ProviderContainer(
          overrides: [
            conversationGraphPopulatedProvider.overrideWith(
              _AlwaysPopulatedGraph.new,
            ),
            ...cassetteRackTestHarnessOverrides(),
            sidebarCassetteResolutionStateProvider(
              SidebarMode.messages,
            ).overrideWith((ref) {
              return ref.watch(_testSidebarResolutionStateProvider);
            }),
          ],
        );
        final rackSubscription = container.listen(
          cassetteRackStateProvider(SidebarMode.messages),
          (_, __) {},
          fireImmediately: true,
        );
        final resolutionSubscription = container.listen(
          sidebarCassetteResolutionStateProvider(SidebarMode.messages),
          (_, __) {},
          fireImmediately: true,
        );
        container
            .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
            .setRackForTesting([
              topMenuSpec,
              firstControlSpec,
              secondControlSpec,
              listSpec,
            ]);
        container
            .read(_testSidebarResolutionStateProvider.notifier)
            .state = const SidebarCassetteResolutionState(
          resolvedCassettes: <ResolvedSidebarCassette>[
            ResolvedSidebarCassette(
              spec: topMenuSpec,
              cassetteIndex: 0,
              payload: StaticFeatureInfoSidebarCassettePayload(
                bodyText: 'legacy-top-menu',
                role: SidebarCassetteRole.appControl,
              ),
            ),
            ResolvedSidebarCassette(
              spec: firstControlSpec,
              cassetteIndex: 1,
              payload: StaticFeatureInfoSidebarCassettePayload(
                bodyText: 'investigation-control',
                role: SidebarCassetteRole.filter,
              ),
              topSpacing: 24,
            ),
            ResolvedSidebarCassette(
              spec: secondControlSpec,
              cassetteIndex: 2,
              payload: StaticFeatureInfoSidebarCassettePayload(
                bodyText: 'filter-control',
                role: SidebarCassetteRole.filter,
              ),
              topSpacing: 12,
            ),
            ResolvedSidebarCassette(
              spec: listSpec,
              cassetteIndex: 3,
              payload: StaticFeatureInfoSidebarCassettePayload(
                bodyText: 'source-list',
              ),
            ),
          ],
          expectedVisibleCount: 4,
          isLoading: false,
        );

        Future<void> pumpSidebar(ResolvedTrackLayoutMatrix matrix) async {
          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: ResolvedTrackLayoutMatrixScope(
                  matrix: matrix,
                  child: const SizedBox(
                    width: 320,
                    height: 600,
                    child: LeftPanelHost(mode: SidebarMode.messages),
                  ),
                ),
              ),
            ),
          );
          await tester.pump();
        }

        await pumpSidebar(_testUnfamiliarSourcesSidebarMatrix(selected: false));
        expect(find.text('matrix-top-menu'), findsOneWidget);
        expect(find.text('legacy-top-menu'), findsNothing);
        expect(find.text('investigation-control'), findsOneWidget);
        expect(find.text('filter-control'), findsOneWidget);
        expect(find.text('source-list'), findsOneWidget);
        expect(_renderedTrackCellIds(tester), const [
          CellId(trackId: TrackId.trackA, columnId: TrackColumnId.column1),
        ]);
        final trackABottom = tester
            .getBottomLeft(find.byType(TrackCellView))
            .dy;
        final groupedControlsTop = tester
            .getTopLeft(find.byType(SidebarGroupedControlSectionSurface))
            .dy;
        expect(groupedControlsTop - trackABottom, 24);
        final idleFilterTop = tester
            .getTopLeft(find.text('investigation-control'))
            .dy;

        await pumpSidebar(_testUnfamiliarSourcesSidebarMatrix(selected: true));
        final selectedFilterTop = tester
            .getTopLeft(find.text('investigation-control'))
            .dy;
        expect(selectedFilterTop, idleFilterTop);
        expect(_renderedTrackCellIds(tester), const [
          CellId(trackId: TrackId.trackA, columnId: TrackColumnId.column1),
        ]);

        await pumpSidebar(_testUnfamiliarSourcesSidebarMatrix(selected: false));
        final clearedFilterTop = tester
            .getTopLeft(find.text('investigation-control'))
            .dy;
        expect(clearedFilterTop, idleFilterTop);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        resolutionSubscription.close();
        rackSubscription.close();
        await tester.idle();
        container.dispose();
        await tester.pump();
      },
    );

    testWidgets(
      'recovered messages resumes native cassette flow immediately after A1',
      (tester) async {
        const topMenuSpec = CassetteSpec.sidebarUtility(
          SidebarUtilityCassetteSpec.topChatMenu(
            selectedChoice: TopChatMenuChoice.recoveredUnlinkedMessages,
          ),
        );
        const infoSpec = CassetteSpec.contactsInfo(
          ContactsInfoCassetteSpec.infoCard(
            key: ContactsInfoKey.pickerContentSources,
          ),
        );
        final container = ProviderContainer(
          overrides: [
            conversationGraphPopulatedProvider.overrideWith(
              _AlwaysPopulatedGraph.new,
            ),
            ...cassetteRackTestHarnessOverrides(),
            sidebarCassetteResolutionStateProvider(
              SidebarMode.messages,
            ).overrideWith((ref) {
              return ref.watch(_testSidebarResolutionStateProvider);
            }),
          ],
        );
        final rackSubscription = container.listen(
          cassetteRackStateProvider(SidebarMode.messages),
          (_, __) {},
          fireImmediately: true,
        );
        final resolutionSubscription = container.listen(
          sidebarCassetteResolutionStateProvider(SidebarMode.messages),
          (_, __) {},
          fireImmediately: true,
        );
        container
            .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
            .setRackForTesting([topMenuSpec, infoSpec]);
        container
            .read(_testSidebarResolutionStateProvider.notifier)
            .state = const SidebarCassetteResolutionState(
          resolvedCassettes: <ResolvedSidebarCassette>[
            ResolvedSidebarCassette(
              spec: topMenuSpec,
              cassetteIndex: 0,
              payload: StaticFeatureInfoSidebarCassettePayload(
                bodyText: 'legacy-top-menu',
                role: SidebarCassetteRole.appControl,
              ),
            ),
            ResolvedSidebarCassette(
              spec: infoSpec,
              cassetteIndex: 1,
              payload: StaticFeatureInfoSidebarCassettePayload(
                bodyText: 'recovered-info',
              ),
              topSpacing: 24,
            ),
          ],
          expectedVisibleCount: 2,
          isLoading: false,
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: ResolvedTrackLayoutMatrixScope(
                matrix: _testRecoveredMessagesSidebarMatrix(),
                child: const SizedBox(
                  width: 320,
                  height: 600,
                  child: LeftPanelHost(mode: SidebarMode.messages),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('matrix-top-menu'), findsOneWidget);
        expect(find.text('legacy-top-menu'), findsNothing);
        expect(find.text('recovered-info'), findsOneWidget);
        expect(_renderedTrackCellIds(tester), const [
          CellId(trackId: TrackId.trackA, columnId: TrackColumnId.column1),
        ]);
        final trackABottom = tester
            .getBottomLeft(find.byType(TrackCellView))
            .dy;
        final infoTop = tester.getTopLeft(find.byType(SidebarInfoCard)).dy;
        expect(infoTop - trackABottom, 24);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        resolutionSubscription.close();
        rackSubscription.close();
        await tester.idle();
        container.dispose();
        await tester.pump();
      },
    );

    testWidgets(
      'Message History Coverage uses A1 then resumes Settings cassette flow',
      (tester) async {
        const topMenuSpec = CassetteSpec.sidebarUtility(
          SidebarUtilityCassetteSpec.settingsMenu(),
        );
        const overviewSpec = CassetteSpec.settings(
          SettingsCassetteSpec.messageHistoryCoverageOverview(),
        );
        final container = ProviderContainer(
          overrides: [
            ...cassetteRackTestHarnessOverrides(),
            sidebarCassetteResolutionStateProvider(
              SidebarMode.settings,
            ).overrideWith((ref) {
              return ref.watch(_testSidebarResolutionStateProvider);
            }),
          ],
        );
        final rackSubscription = container.listen(
          cassetteRackStateProvider(SidebarMode.settings),
          (_, __) {},
          fireImmediately: true,
        );
        final resolutionSubscription = container.listen(
          sidebarCassetteResolutionStateProvider(SidebarMode.settings),
          (_, __) {},
          fireImmediately: true,
        );
        container
            .read(cassetteRackStateProvider(SidebarMode.settings).notifier)
            .setRackForTesting([topMenuSpec, overviewSpec]);
        container
            .read(_testSidebarResolutionStateProvider.notifier)
            .state = const SidebarCassetteResolutionState(
          resolvedCassettes: <ResolvedSidebarCassette>[
            ResolvedSidebarCassette(
              spec: topMenuSpec,
              cassetteIndex: 0,
              payload: StaticFeatureInfoSidebarCassettePayload(
                bodyText: 'legacy-settings-menu',
                role: SidebarCassetteRole.appControl,
              ),
            ),
            ResolvedSidebarCassette(
              spec: overviewSpec,
              cassetteIndex: 1,
              payload: StaticFeatureInfoSidebarCassettePayload(
                bodyText: 'coverage-overview',
              ),
              topSpacing: 24,
            ),
          ],
          expectedVisibleCount: 2,
          isLoading: false,
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: ResolvedTrackLayoutMatrixScope(
                matrix: _testMessageHistoryCoverageSidebarMatrix(),
                child: const SizedBox(
                  width: 320,
                  height: 600,
                  child: LeftPanelHost(mode: SidebarMode.settings),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('matrix-settings-menu'), findsOneWidget);
        expect(find.text('legacy-settings-menu'), findsNothing);
        expect(find.text('coverage-overview'), findsOneWidget);
        expect(_renderedTrackCellIds(tester), const [
          CellId(trackId: TrackId.trackA, columnId: TrackColumnId.column1),
        ]);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        resolutionSubscription.close();
        rackSubscription.close();
        await tester.idle();
        container.dispose();
        await tester.pump();
      },
    );

    testWidgets('Contacts resumes native cassette flow immediately after A1', (
      tester,
    ) async {
      const topMenuSpec = CassetteSpec.sidebarUtility(
        SidebarUtilityCassetteSpec.topChatMenu(
          selectedChoice: TopChatMenuChoice.contacts,
        ),
      );
      const contactControlSpec = CassetteSpec.contactsInfo(
        ContactsInfoCassetteSpec.infoCard(
          key: ContactsInfoKey.pickerContentSources,
        ),
      );
      final container = ProviderContainer(
        overrides: [
          conversationGraphPopulatedProvider.overrideWith(
            _AlwaysPopulatedGraph.new,
          ),
          ...cassetteRackTestHarnessOverrides(),
          sidebarCassetteResolutionStateProvider(
            SidebarMode.messages,
          ).overrideWith((ref) {
            return ref.watch(_testSidebarResolutionStateProvider);
          }),
        ],
      );
      final rackSubscription = container.listen(
        cassetteRackStateProvider(SidebarMode.messages),
        (_, __) {},
        fireImmediately: true,
      );
      final resolutionSubscription = container.listen(
        sidebarCassetteResolutionStateProvider(SidebarMode.messages),
        (_, __) {},
        fireImmediately: true,
      );
      container
          .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
          .setRackForTesting([topMenuSpec, contactControlSpec]);
      container
          .read(_testSidebarResolutionStateProvider.notifier)
          .state = const SidebarCassetteResolutionState(
        resolvedCassettes: <ResolvedSidebarCassette>[
          ResolvedSidebarCassette(
            spec: topMenuSpec,
            cassetteIndex: 0,
            payload: StaticFeatureInfoSidebarCassettePayload(
              bodyText: 'legacy-top-menu',
              role: SidebarCassetteRole.appControl,
            ),
          ),
          ResolvedSidebarCassette(
            spec: contactControlSpec,
            cassetteIndex: 1,
            payload: StaticFeatureInfoSidebarCassettePayload(
              bodyText: 'contact-control',
            ),
            topSpacing: 24,
          ),
        ],
        expectedVisibleCount: 2,
        isLoading: false,
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: ResolvedTrackLayoutMatrixScope(
              matrix: _testContactsSidebarMatrix(),
              child: const SizedBox(
                width: 320,
                height: 600,
                child: LeftPanelHost(mode: SidebarMode.messages),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('matrix-top-menu'), findsOneWidget);
      expect(find.text('legacy-top-menu'), findsNothing);
      expect(find.text('contact-control'), findsOneWidget);
      expect(_renderedTrackCellIds(tester), const [
        CellId(trackId: TrackId.trackA, columnId: TrackColumnId.column1),
      ]);
      final trackABottom = tester.getBottomLeft(find.byType(TrackCellView)).dy;
      final contactControlTop = tester
          .getTopLeft(find.byType(SidebarInfoCard))
          .dy;
      expect(contactControlTop - trackABottom, 24);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      resolutionSubscription.close();
      rackSubscription.close();
      await tester.idle();
      container.dispose();
      await tester.pump();
    });

    testWidgets(
      'pins app controls and uses expanding layout from descriptors',
      (tester) async {
        const topMenuSpec = CassetteSpec.sidebarUtility(
          SidebarUtilityCassetteSpec.topChatMenu(),
        );
        const heroSpec = CassetteSpec.contacts(
          ContactsCassetteSpec.contactHeroSummary(chosenContactId: 42),
        );
        final container = ProviderContainer(
          overrides: [
            conversationGraphPopulatedProvider.overrideWith(
              _AlwaysPopulatedGraph.new,
            ),
            ...cassetteRackTestHarnessOverrides(),
            sidebarCassetteResolutionStateProvider(
              SidebarMode.messages,
            ).overrideWith((ref) {
              return ref.watch(_testSidebarResolutionStateProvider);
            }),
          ],
        );
        final rackSubscription = container.listen(
          cassetteRackStateProvider(SidebarMode.messages),
          (_, __) {},
          fireImmediately: true,
        );
        final resolutionSubscription = container.listen(
          sidebarCassetteResolutionStateProvider(SidebarMode.messages),
          (_, __) {},
          fireImmediately: true,
        );

        container
            .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
            .setRackForTesting([topMenuSpec, heroSpec]);
        container
            .read(_testSidebarResolutionStateProvider.notifier)
            .state = const SidebarCassetteResolutionState(
          resolvedCassettes: <ResolvedSidebarCassette>[
            ResolvedSidebarCassette(
              spec: topMenuSpec,
              cassetteIndex: 0,
              payload: StaticFeatureInfoSidebarCassettePayload(
                bodyText: 'top-menu',
                role: SidebarCassetteRole.appControl,
              ),
            ),
            ResolvedSidebarCassette(
              spec: heroSpec,
              cassetteIndex: 1,
              payload: SharedBodyModelSidebarCassettePayload(
                bodyModel: SidebarDropdownBodyModel(
                  promptLabel: '',
                  selectedOptionId: 'hero',
                  options: <SidebarDropdownOption>[
                    SidebarDropdownOption(
                      id: 'hero',
                      label: 'hero',
                      selectionIntent: ChooseAnotherContact(),
                    ),
                  ],
                ),
                shouldExpand: true,
              ),
            ),
          ],
          expectedVisibleCount: 2,
          isLoading: false,
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const Directionality(
              textDirection: TextDirection.ltr,
              child: LeftPanelHost(mode: SidebarMode.messages),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('top-menu'), findsOneWidget);
        expect(find.text('hero'), findsOneWidget);
        expect(find.byType(CustomScrollView), findsNothing);
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Expanded &&
                widget.child.runtimeType.toString() == '_ContentFillColumn',
          ),
          findsOneWidget,
        );

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        resolutionSubscription.close();
        rackSubscription.close();
        await tester.idle();
        container.dispose();
        await tester.pump();
      },
    );

    testWidgets(
      'wraps contiguous grouped controls in one shared grouped-control surface',
      (tester) async {
        const topMenuSpec = CassetteSpec.sidebarUtility(
          SidebarUtilityCassetteSpec.topChatMenu(),
        );
        const scopeSpec = CassetteSpec.contacts(
          ContactsCassetteSpec.messageScopeToggle(contactId: 42),
        );
        const filterSpec = CassetteSpec.contacts(
          ContactsCassetteSpec.handleFilter(contactId: 42),
        );

        final container = ProviderContainer(
          overrides: [
            conversationGraphPopulatedProvider.overrideWith(
              _AlwaysPopulatedGraph.new,
            ),
            ...cassetteRackTestHarnessOverrides(),
            sidebarCassetteResolutionStateProvider(
              SidebarMode.messages,
            ).overrideWith((ref) {
              return ref.watch(_testSidebarResolutionStateProvider);
            }),
          ],
        );
        final rackSubscription = container.listen(
          cassetteRackStateProvider(SidebarMode.messages),
          (_, __) {},
          fireImmediately: true,
        );
        final resolutionSubscription = container.listen(
          sidebarCassetteResolutionStateProvider(SidebarMode.messages),
          (_, __) {},
          fireImmediately: true,
        );

        container
            .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
            .setRackForTesting([topMenuSpec, scopeSpec, filterSpec]);
        container
            .read(_testSidebarResolutionStateProvider.notifier)
            .state = const SidebarCassetteResolutionState(
          resolvedCassettes: <ResolvedSidebarCassette>[
            ResolvedSidebarCassette(
              spec: topMenuSpec,
              cassetteIndex: 0,
              payload: StaticFeatureInfoSidebarCassettePayload(
                bodyText: 'top-menu',
                role: SidebarCassetteRole.appControl,
              ),
            ),
            ResolvedSidebarCassette(
              spec: scopeSpec,
              cassetteIndex: 1,
              payload: StaticFeatureInfoSidebarCassettePayload(
                role: SidebarCassetteRole.filter,
                bodyText: 'scope',
              ),
              topSpacing: 24,
            ),
            ResolvedSidebarCassette(
              spec: filterSpec,
              cassetteIndex: 2,
              payload: StaticFeatureInfoSidebarCassettePayload(
                role: SidebarCassetteRole.filter,
                bodyText: 'handle',
              ),
              topSpacing: 12,
            ),
          ],
          expectedVisibleCount: 3,
          isLoading: false,
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const Directionality(
              textDirection: TextDirection.ltr,
              child: LeftPanelHost(mode: SidebarMode.messages),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('top-menu'), findsOneWidget);
        expect(
          find.byType(SidebarGroupedControlSectionSurface),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(SidebarGroupedControlSectionSurface),
            matching: find.text('scope'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(SidebarGroupedControlSectionSurface),
            matching: find.text('handle'),
          ),
          findsOneWidget,
        );

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        resolutionSubscription.close();
        rackSubscription.close();
        await tester.idle();
        container.dispose();
        await tester.pump();
      },
    );

    testWidgets(
      'keeps primary context and supporting context as separate sections',
      (tester) async {
        const topMenuSpec = CassetteSpec.sidebarUtility(
          SidebarUtilityCassetteSpec.topChatMenu(),
        );
        const heroSpec = CassetteSpec.contacts(
          ContactsCassetteSpec.contactHeroSummary(chosenContactId: 42),
        );
        const infoSpec = CassetteSpec.contactsInfo(
          ContactsInfoCassetteSpec.infoCard(
            key: ContactsInfoKey.chosenContact,
            chosenContactId: 42,
          ),
        );
        const filterSpec = CassetteSpec.contacts(
          ContactsCassetteSpec.messageScopeToggle(contactId: 42),
        );

        final container = ProviderContainer(
          overrides: [
            conversationGraphPopulatedProvider.overrideWith(
              _AlwaysPopulatedGraph.new,
            ),
            ...cassetteRackTestHarnessOverrides(),
            sidebarCassetteResolutionStateProvider(
              SidebarMode.messages,
            ).overrideWith((ref) {
              return ref.watch(_testSidebarResolutionStateProvider);
            }),
          ],
        );
        final rackSubscription = container.listen(
          cassetteRackStateProvider(SidebarMode.messages),
          (_, __) {},
          fireImmediately: true,
        );
        final resolutionSubscription = container.listen(
          sidebarCassetteResolutionStateProvider(SidebarMode.messages),
          (_, __) {},
          fireImmediately: true,
        );

        container
            .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
            .setRackForTesting([topMenuSpec, heroSpec, infoSpec, filterSpec]);
        container
            .read(_testSidebarResolutionStateProvider.notifier)
            .state = const SidebarCassetteResolutionState(
          resolvedCassettes: <ResolvedSidebarCassette>[
            ResolvedSidebarCassette(
              spec: topMenuSpec,
              cassetteIndex: 0,
              payload: StaticFeatureInfoSidebarCassettePayload(
                bodyText: 'top-menu',
                role: SidebarCassetteRole.appControl,
              ),
            ),
            ResolvedSidebarCassette(
              spec: heroSpec,
              cassetteIndex: 1,
              payload: StaticFeatureInfoSidebarCassettePayload(
                bodyText: 'hero',
                role: SidebarCassetteRole.contextPrimary,
                semanticStyle: SidebarCassetteSemanticStyle.primaryContextGroup,
              ),
              topSpacing: 16,
            ),
            ResolvedSidebarCassette(
              spec: infoSpec,
              cassetteIndex: 2,
              payload: StaticFeatureInfoSidebarCassettePayload(
                bodyText: 'Click the name…',
                semanticStyle: SidebarCassetteSemanticStyle.supportingContext,
              ),
              topSpacing: 8,
            ),
            ResolvedSidebarCassette(
              spec: filterSpec,
              cassetteIndex: 3,
              payload: StaticFeatureInfoSidebarCassettePayload(
                bodyText: 'scope',
                role: SidebarCassetteRole.filter,
              ),
              topSpacing: 24,
            ),
          ],
          expectedVisibleCount: 4,
          isLoading: false,
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const Directionality(
              textDirection: TextDirection.ltr,
              child: LeftPanelHost(mode: SidebarMode.messages),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('hero'), findsOneWidget);
        expect(find.text('Click the name…'), findsOneWidget);
        expect(find.text('scope'), findsOneWidget);
        expect(find.byType(SidebarGroupedControlSectionSurface), findsNothing);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        resolutionSubscription.close();
        rackSubscription.close();
        await tester.idle();
        container.dispose();
        await tester.pump();
      },
    );
  });

  group('effectiveCenterPanelSpec', () {
    test('initial messages mode has no center projection until selection', () {
      final container = ProviderContainer(
        overrides: [
          conversationGraphPopulatedProvider.overrideWith(
            _AlwaysPopulatedGraph.new,
          ),
        ],
      );

      expect(
        container.read(sidebarFlowProvider).topMenuChoice,
        defaultTopChatMenuChoice,
      );
      expect(
        container.read(effectiveCenterPanelSpecProvider(SidebarMode.messages)),
        isNull,
      );

      container.dispose();
    });

    test(
      'derives flow-managed messages center without stored center stack',
      () {
        final container = ProviderContainer(
          overrides: [
            conversationGraphPopulatedProvider.overrideWith(
              _AlwaysPopulatedGraph.new,
            ),
          ],
        );

        container.read(sidebarFlowProvider.notifier).showGlobalTimeline();

        final storedCenter = container.read(
          panelsViewStateProvider(SidebarMode.messages),
        )[WindowPanel.center];

        expect(storedCenter?.isEmpty ?? true, isTrue);
        expect(
          container.read(
            effectiveCenterPanelSpecProvider(SidebarMode.messages),
          ),
          equals(const ViewSpec.messages(MessagesSpec.globalTimeline())),
        );

        container.dispose();
      },
    );
    test(
      'derives flow-managed settings center without stored center stack',
      () {
        final container = ProviderContainer(
          overrides: [
            conversationGraphPopulatedProvider.overrideWith(
              _AlwaysPopulatedGraph.new,
            ),
          ],
        );

        container
            .read(sidebarFlowProvider.notifier)
            .setPersistentSettingsContext(
              SettingsMenuActionId.messageHistoryCoverage,
            );

        final storedCenter = container.read(
          panelsViewStateProvider(SidebarMode.settings),
        )[WindowPanel.center];

        expect(storedCenter?.isEmpty ?? true, isTrue);
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

        container.dispose();
      },
    );

    testWidgets(
      'center panel host renders derived flow-managed messages view',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            conversationGraphPopulatedProvider.overrideWith(
              _AlwaysPopulatedGraph.new,
            ),
            messages_view_spec.viewSpecCoordinatorProvider.overrideWith(
              _FakeMessagesViewSpecCoordinator.new,
            ),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const Directionality(
              textDirection: TextDirection.ltr,
              child: CenterPanelHost(mode: SidebarMode.messages),
            ),
          ),
        );
        await tester.pump();

        container.read(sidebarFlowProvider.notifier).showGlobalTimeline();
        await tester.pump();

        expect(find.text('global'), findsOneWidget);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        container.dispose();
        await tester.pump();
      },
    );

    testWidgets(
      'center panel host renders derived flow-managed settings view',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            conversationGraphPopulatedProvider.overrideWith(
              _AlwaysPopulatedGraph.new,
            ),
            settings_view_spec.viewSpecCoordinatorProvider.overrideWith(
              _FakeSettingsViewSpecCoordinator.new,
            ),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const Directionality(
              textDirection: TextDirection.ltr,
              child: CenterPanelHost(mode: SidebarMode.settings),
            ),
          ),
        );
        await tester.pump();

        container
            .read(sidebarFlowProvider.notifier)
            .setPersistentSettingsContext(
              SettingsMenuActionId.messageHistoryCoverage,
            );
        await tester.pump();

        expect(
          find.byKey(const Key('message-history-coverage-track-skeleton')),
          findsOneWidget,
        );

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        container.dispose();
        await tester.pump();
      },
    );

    test('preserves sidebar-independent center stack over flow projection', () {
      final container = ProviderContainer(
        overrides: [
          conversationGraphPopulatedProvider.overrideWith(
            _AlwaysPopulatedGraph.new,
          ),
        ],
      );

      container.read(sidebarFlowProvider.notifier).showGlobalTimeline();
      container
          .read(panelsViewStateProvider(SidebarMode.messages).notifier)
          .show(
            panel: WindowPanel.center,
            spec: const ViewSpec.environmentReadiness(
              EnvironmentReadinessSpec.readinessPanel(),
            ),
          );

      expect(
        container.read(effectiveCenterPanelSpecProvider(SidebarMode.messages)),
        equals(
          const ViewSpec.environmentReadiness(
            EnvironmentReadinessSpec.readinessPanel(),
          ),
        ),
      );

      container.dispose();
    });

    test(
      'stored flow-managed center cannot override projected center spec',
      () {
        final container = ProviderContainer(
          overrides: [
            conversationGraphPopulatedProvider.overrideWith(
              _AlwaysPopulatedGraph.new,
            ),
          ],
        );

        container.read(sidebarFlowProvider.notifier).showGlobalTimeline();
        container
            .read(panelsViewStateProvider(SidebarMode.messages).notifier)
            .show(
              panel: WindowPanel.center,
              spec: const ViewSpec.messages(
                MessagesSpec.forContact(contactId: 42),
              ),
            );

        expect(
          container.read(
            effectiveCenterPanelSpecProvider(SidebarMode.messages),
          ),
          equals(const ViewSpec.messages(MessagesSpec.globalTimeline())),
        );
        expect(
          container
              .read(
                panelsViewStateProvider(SidebarMode.messages),
              )[WindowPanel.center]
              ?.activePage
              ?.spec,
          equals(
            const ViewSpec.messages(MessagesSpec.forContact(contactId: 42)),
          ),
        );

        container.dispose();
      },
    );

    test('conversation top menu waits for sidebar-selected conversation', () {
      final container = ProviderContainer(
        overrides: [
          conversationGraphPopulatedProvider.overrideWith(
            _AlwaysPopulatedGraph.new,
          ),
        ],
      );

      container
          .read(sidebarFlowProvider.notifier)
          .topMenuChanged(
            choice: TopChatMenuChoice.conversations,
            cassetteIndex: 0,
          );

      expect(
        container.read(effectiveCenterPanelSpecProvider(SidebarMode.messages)),
        isNull,
      );

      container
          .read(sidebarFlowProvider.notifier)
          .selectConversation(conversationId: 8796093022216);

      expect(
        container.read(effectiveCenterPanelSpecProvider(SidebarMode.messages)),
        equals(
          const ViewSpec.conversations(
            ConversationsSpec.conversationMessages(
              conversationId: 8796093022216,
            ),
          ),
        ),
      );

      container
          .read(sidebarFlowProvider.notifier)
          .topMenuChanged(choice: TopChatMenuChoice.contacts, cassetteIndex: 0);

      expect(
        container.read(effectiveCenterPanelSpecProvider(SidebarMode.messages)),
        isNull,
      );

      container.dispose();
    });

    test(
      'selected conversation center derives from sidebar flow, not stored stack',
      () {
        final container = ProviderContainer(
          overrides: [
            conversationGraphPopulatedProvider.overrideWith(
              _AlwaysPopulatedGraph.new,
            ),
          ],
        );

        container
            .read(sidebarFlowProvider.notifier)
            .selectConversation(conversationId: 8796093022216);
        container
            .read(panelsViewStateProvider(SidebarMode.messages).notifier)
            .show(
              panel: WindowPanel.center,
              spec: const ViewSpec.conversations(
                ConversationsSpec.conversationMessages(
                  conversationId: 8796093022216,
                ),
              ),
            );

        expect(
          container.read(
            effectiveCenterPanelSpecProvider(SidebarMode.messages),
          ),
          equals(
            const ViewSpec.conversations(
              ConversationsSpec.conversationMessages(
                conversationId: 8796093022216,
              ),
            ),
          ),
        );

        container
            .read(sidebarFlowProvider.notifier)
            .selectConversation(conversationId: 123);

        expect(
          container.read(
            effectiveCenterPanelSpecProvider(SidebarMode.messages),
          ),
          equals(
            const ViewSpec.conversations(
              ConversationsSpec.conversationMessages(conversationId: 123),
            ),
          ),
        );
        expect(
          container
              .read(
                panelsViewStateProvider(SidebarMode.messages),
              )[WindowPanel.center]
              ?.activePage
              ?.spec,
          equals(
            const ViewSpec.conversations(
              ConversationsSpec.conversationMessages(
                conversationId: 8796093022216,
              ),
            ),
          ),
        );

        container.dispose();
      },
    );
  });

  group('effectiveRightPanelSpec', () {
    test('derives stored right panel when effective center supports it', () {
      final container = ProviderContainer(
        overrides: [
          conversationGraphPopulatedProvider.overrideWith(
            _AlwaysPopulatedGraph.new,
          ),
        ],
      );

      container.read(sidebarFlowProvider.notifier).showGlobalTimeline();
      container
          .read(panelsViewStateProvider(SidebarMode.messages).notifier)
          .show(
            panel: WindowPanel.right,
            spec: const ViewSpec.conversations(
              ConversationsSpec.conversationExcerpt(
                conversationId: 5,
                anchorMessageId: 99,
                originatingInvestigationId: SearchInvestigationId(0),
              ),
            ),
          );

      expect(
        container.read(effectiveRightPanelSpecProvider(SidebarMode.messages)),
        equals(
          const ViewSpec.conversations(
            ConversationsSpec.conversationExcerpt(
              conversationId: 5,
              anchorMessageId: 99,
              originatingInvestigationId: SearchInvestigationId(0),
            ),
          ),
        ),
      );

      container.dispose();
    });

    test(
      'flow-managed center change hides incompatible stored right panel by derivation',
      () {
        final container = ProviderContainer(
          overrides: [
            conversationGraphPopulatedProvider.overrideWith(
              _AlwaysPopulatedGraph.new,
            ),
          ],
        );

        container.read(sidebarFlowProvider.notifier).showGlobalTimeline();
        container
            .read(panelsViewStateProvider(SidebarMode.messages).notifier)
            .show(
              panel: WindowPanel.right,
              spec: const ViewSpec.conversations(
                ConversationsSpec.conversationExcerpt(
                  conversationId: 5,
                  anchorMessageId: 99,
                  originatingInvestigationId: SearchInvestigationId(0),
                ),
              ),
            );

        container
            .read(sidebarFlowProvider.notifier)
            .showContactTimelineAt(contactId: 42);

        expect(
          container.read(effectiveRightPanelSpecProvider(SidebarMode.messages)),
          isNull,
        );
        expect(
          container
              .read(
                panelsViewStateProvider(SidebarMode.messages),
              )[WindowPanel.right]
              ?.isEmpty,
          isFalse,
        );

        container.dispose();
      },
    );

    test('contact flow does not claim conversation excerpt right panel', () {
      final container = ProviderContainer(
        overrides: [
          conversationGraphPopulatedProvider.overrideWith(
            _AlwaysPopulatedGraph.new,
          ),
        ],
      );

      container
          .read(sidebarFlowProvider.notifier)
          .showContactTimelineAt(contactId: 42);
      container
          .read(panelsViewStateProvider(SidebarMode.messages).notifier)
          .show(
            panel: WindowPanel.right,
            spec: const ViewSpec.conversations(
              ConversationsSpec.conversationExcerpt(
                conversationId: 5,
                anchorMessageId: 99,
                originatingInvestigationId: SearchInvestigationId(0),
              ),
            ),
          );

      expect(
        container.read(shouldShowEndSidebarProvider(SidebarMode.messages)),
        isFalse,
      );

      container.dispose();
    });

    testWidgets('right panel host renders derived right content', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          conversationGraphPopulatedProvider.overrideWith(
            _AlwaysPopulatedGraph.new,
          ),
          messages_view_spec.viewSpecCoordinatorProvider.overrideWith(
            _FakeMessagesViewSpecCoordinator.new,
          ),
          conversations_view_spec.viewSpecCoordinatorProvider.overrideWith(
            _FakeConversationsViewSpecCoordinator.new,
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: RightPanelHost(mode: SidebarMode.messages),
          ),
        ),
      );
      await tester.pump();

      container.read(sidebarFlowProvider.notifier).showGlobalTimeline();
      container
          .read(panelsViewStateProvider(SidebarMode.messages).notifier)
          .show(
            panel: WindowPanel.right,
            spec: const ViewSpec.conversations(
              ConversationsSpec.conversationExcerpt(
                conversationId: 5,
                anchorMessageId: 99,
                originatingInvestigationId: SearchInvestigationId(0),
              ),
            ),
          );
      await tester.pump();

      expect(find.text('conversation:99'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      container.dispose();
      await tester.pump();
    });
  });

  group('panel host coordination', () {
    testWidgets('keeps prior sidebar content during same-rack async reloads', (
      tester,
    ) async {
      const chooserSpec = CassetteSpec.contacts(
        ContactsCassetteSpec.contactChooser(),
      );
      final container = ProviderContainer(
        overrides: [
          conversationGraphPopulatedProvider.overrideWith(
            _AlwaysPopulatedGraph.new,
          ),
          ...cassetteRackTestHarnessOverrides(),
          sidebarCassetteResolutionStateProvider(
            SidebarMode.messages,
          ).overrideWith((ref) {
            return ref.watch(_testSidebarResolutionStateProvider);
          }),
        ],
      );
      final rackSubscription = container.listen(
        cassetteRackStateProvider(SidebarMode.messages),
        (_, __) {},
        fireImmediately: true,
      );
      final resolutionSubscription = container.listen(
        sidebarCassetteResolutionStateProvider(SidebarMode.messages),
        (_, __) {},
        fireImmediately: true,
      );
      addTearDown(rackSubscription.close);
      addTearDown(resolutionSubscription.close);
      container
          .read(_testSidebarResolutionStateProvider.notifier)
          .state = const SidebarCassetteResolutionState(
        resolvedCassettes: <ResolvedSidebarCassette>[
          ResolvedSidebarCassette(
            spec: chooserSpec,
            cassetteIndex: 0,
            payload: StaticFeatureInfoSidebarCassettePayload(
              bodyText: 'loading-payload',
            ),
          ),
        ],
        expectedVisibleCount: 1,
        isLoading: false,
      );

      container
          .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
          .setRackForTesting([chooserSpec]);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: LeftPanelHost(mode: SidebarMode.messages),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('loading-payload'), findsOneWidget);

      container
          .read(_testSidebarResolutionStateProvider.notifier)
          .state = const SidebarCassetteResolutionState(
        resolvedCassettes: <ResolvedSidebarCassette>[
          ResolvedSidebarCassette(
            spec: chooserSpec,
            cassetteIndex: 0,
            payload: StaticFeatureInfoSidebarCassettePayload(
              bodyText: 'loading-payload',
            ),
          ),
        ],
        expectedVisibleCount: 1,
        isLoading: true,
      );
      await tester.pump();

      expect(find.text('loading-payload'), findsOneWidget);

      container
          .read(_testSidebarResolutionStateProvider.notifier)
          .state = const SidebarCassetteResolutionState(
        resolvedCassettes: <ResolvedSidebarCassette>[
          ResolvedSidebarCassette(
            spec: chooserSpec,
            cassetteIndex: 0,
            payload: StaticFeatureInfoSidebarCassettePayload(
              bodyText: 'ready-payload',
            ),
          ),
        ],
        expectedVisibleCount: 1,
        isLoading: false,
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: LeftPanelHost(mode: SidebarMode.messages),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('ready-payload'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
      container.dispose();
      await tester.pump(const Duration(milliseconds: 1));
    });

    testWidgets(
      'center host removes rendered contact panel after choosing another contact',
      (tester) async {
        const topMenuSpec = CassetteSpec.sidebarUtility(
          SidebarUtilityCassetteSpec.topChatMenu(),
        );
        const pickerInfoSpec = CassetteSpec.contactsInfo(
          ContactsInfoCassetteSpec.infoCard(
            key: ContactsInfoKey.pickerContentSources,
          ),
        );
        final container = ProviderContainer(
          overrides: [
            conversationGraphPopulatedProvider.overrideWith(
              _AlwaysPopulatedGraph.new,
            ),
            ...cassetteRackTestHarnessOverrides(),
            sidebarCassetteResolutionStateProvider(
              SidebarMode.messages,
            ).overrideWith((ref) {
              return ref.watch(_testSidebarResolutionStateProvider);
            }),
            messages_view_spec.viewSpecCoordinatorProvider.overrideWith(
              _FakeMessagesViewSpecCoordinator.new,
            ),
          ],
        );
        final rackSubscription = container.listen(
          cassetteRackStateProvider(SidebarMode.messages),
          (_, __) {},
          fireImmediately: true,
        );
        final resolutionSubscription = container.listen(
          sidebarCassetteResolutionStateProvider(SidebarMode.messages),
          (_, __) {},
          fireImmediately: true,
        );
        addTearDown(rackSubscription.close);
        addTearDown(resolutionSubscription.close);
        container
            .read(_testSidebarResolutionStateProvider.notifier)
            .state = const SidebarCassetteResolutionState(
          resolvedCassettes: <ResolvedSidebarCassette>[
            ResolvedSidebarCassette(
              spec: topMenuSpec,
              cassetteIndex: 0,
              payload: StaticFeatureInfoSidebarCassettePayload(
                bodyText: 'top-menu',
                role: SidebarCassetteRole.appControl,
              ),
            ),
          ],
          expectedVisibleCount: 1,
          isLoading: false,
        );

        container
            .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
            .setRackForTesting([topMenuSpec]);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const Directionality(
              textDirection: TextDirection.ltr,
              child: LeftPanelHost(mode: SidebarMode.messages),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('top-menu'), findsOneWidget);

        container
            .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
            .setRackForTesting([topMenuSpec, pickerInfoSpec]);
        container
            .read(_testSidebarResolutionStateProvider.notifier)
            .state = const SidebarCassetteResolutionState(
          resolvedCassettes: <ResolvedSidebarCassette>[
            ResolvedSidebarCassette(
              spec: topMenuSpec,
              cassetteIndex: 0,
              payload: StaticFeatureInfoSidebarCassettePayload(
                bodyText: 'top-menu',
                role: SidebarCassetteRole.appControl,
              ),
            ),
          ],
          expectedVisibleCount: 2,
          isLoading: true,
        );

        await tester.pump();

        expect(find.text('top-menu'), findsNothing);
        expect(find.text('picker'), findsNothing);

        container
            .read(_testSidebarResolutionStateProvider.notifier)
            .state = const SidebarCassetteResolutionState(
          resolvedCassettes: <ResolvedSidebarCassette>[
            ResolvedSidebarCassette(
              spec: topMenuSpec,
              cassetteIndex: 0,
              payload: StaticFeatureInfoSidebarCassettePayload(
                bodyText: 'top-menu',
                role: SidebarCassetteRole.appControl,
              ),
            ),
            ResolvedSidebarCassette(
              spec: pickerInfoSpec,
              cassetteIndex: 1,
              payload: StaticFeatureInfoSidebarCassettePayload(
                bodyText: 'picker',
              ),
            ),
          ],
          expectedVisibleCount: 2,
          isLoading: false,
        );
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const Directionality(
              textDirection: TextDirection.ltr,
              child: LeftPanelHost(mode: SidebarMode.messages),
            ),
          ),
        );
        await tester.pump();
        await tester.pump();

        expect(find.text('picker'), findsOneWidget);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(milliseconds: 1));
        container.dispose();
        await tester.pump(const Duration(milliseconds: 1));
      },
    );

    testWidgets(
      'does not reuse picker widgets during selected-contact transition',
      (tester) async {
        const topMenuSpec = CassetteSpec.sidebarUtility(
          SidebarUtilityCassetteSpec.topChatMenu(),
        );
        const pickerInfoSpec = CassetteSpec.contactsInfo(
          ContactsInfoCassetteSpec.infoCard(
            key: ContactsInfoKey.pickerContentSources,
          ),
        );
        const heroSpec = CassetteSpec.contacts(
          ContactsCassetteSpec.contactHeroSummary(chosenContactId: 42),
        );
        final container = ProviderContainer(
          overrides: [
            conversationGraphPopulatedProvider.overrideWith(
              _AlwaysPopulatedGraph.new,
            ),
            ...cassetteRackTestHarnessOverrides(),
            sidebarCassetteResolutionStateProvider(
              SidebarMode.messages,
            ).overrideWith((ref) {
              return ref.watch(_testSidebarResolutionStateProvider);
            }),
          ],
        );
        final rackSubscription = container.listen(
          cassetteRackStateProvider(SidebarMode.messages),
          (_, __) {},
          fireImmediately: true,
        );
        final resolutionSubscription = container.listen(
          sidebarCassetteResolutionStateProvider(SidebarMode.messages),
          (_, __) {},
          fireImmediately: true,
        );
        addTearDown(rackSubscription.close);
        addTearDown(resolutionSubscription.close);
        container
            .read(_testSidebarResolutionStateProvider.notifier)
            .state = const SidebarCassetteResolutionState(
          resolvedCassettes: <ResolvedSidebarCassette>[
            ResolvedSidebarCassette(
              spec: topMenuSpec,
              cassetteIndex: 0,
              payload: StaticFeatureInfoSidebarCassettePayload(
                bodyText: 'top-menu',
                role: SidebarCassetteRole.appControl,
              ),
            ),
            ResolvedSidebarCassette(
              spec: pickerInfoSpec,
              cassetteIndex: 1,
              payload: StaticFeatureInfoSidebarCassettePayload(
                bodyText: 'picker',
              ),
            ),
          ],
          expectedVisibleCount: 2,
          isLoading: false,
        );

        container
            .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
            .setRackForTesting([topMenuSpec, pickerInfoSpec]);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const Directionality(
              textDirection: TextDirection.ltr,
              child: LeftPanelHost(mode: SidebarMode.messages),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('picker'), findsOneWidget);

        container
            .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
            .setRackForTesting([topMenuSpec, heroSpec]);
        container
            .read(_testSidebarResolutionStateProvider.notifier)
            .state = const SidebarCassetteResolutionState(
          resolvedCassettes: <ResolvedSidebarCassette>[
            ResolvedSidebarCassette(
              spec: topMenuSpec,
              cassetteIndex: 0,
              payload: StaticFeatureInfoSidebarCassettePayload(
                bodyText: 'top-menu',
                role: SidebarCassetteRole.appControl,
              ),
            ),
          ],
          expectedVisibleCount: 2,
          isLoading: true,
        );

        await tester.pump();

        expect(find.text('picker'), findsNothing);
        expect(find.text('hero'), findsNothing);

        container
            .read(_testSidebarResolutionStateProvider.notifier)
            .state = const SidebarCassetteResolutionState(
          resolvedCassettes: <ResolvedSidebarCassette>[
            ResolvedSidebarCassette(
              spec: topMenuSpec,
              cassetteIndex: 0,
              payload: StaticFeatureInfoSidebarCassettePayload(
                bodyText: 'top-menu',
                role: SidebarCassetteRole.appControl,
              ),
            ),
            ResolvedSidebarCassette(
              spec: heroSpec,
              cassetteIndex: 1,
              payload: StaticFeatureInfoSidebarCassettePayload(
                bodyText: 'hero',
              ),
            ),
          ],
          expectedVisibleCount: 2,
          isLoading: false,
        );
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const Directionality(
              textDirection: TextDirection.ltr,
              child: LeftPanelHost(mode: SidebarMode.messages),
            ),
          ),
        );
        await tester.pump();
        await tester.pump();

        expect(find.text('hero'), findsOneWidget);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(milliseconds: 1));
        container.dispose();
        await tester.pump(const Duration(milliseconds: 1));
      },
    );
  });
}

class _AlwaysPopulatedGraph extends ConversationGraphPopulated {
  @override
  bool build() {
    return true;
  }
}

ResolvedSidebarCassette _resolvedCassette({
  required SidebarCassettePayload payload,
}) {
  return ResolvedSidebarCassette(
    spec: const CassetteSpec.sidebarUtility(
      SidebarUtilityCassetteSpec.settingsMenu(),
    ),
    cassetteIndex: 0,
    payload: payload,
    topSpacing: payload.topSpacing,
  );
}

ResolvedTrackLayoutMatrix _testSearchSidebarMatrix() {
  const columnId = TrackColumnId.column1;
  final matrix = PageTrackLayoutMatrix<TrackOccupant>(
    trackIds: const [
      TrackId.trackA,
      TrackId.trackB,
      TrackId.trackC,
      TrackId.trackD,
      TrackId.trackE,
      TrackId.trackF,
    ],
    columnIds: const [columnId],
    cells: const [
      MatrixCell<TrackOccupant>.occupied(
        cellId: CellId(trackId: TrackId.trackA, columnId: columnId),
        occupant: TextTrackOccupant(
          text: 'matrix-top-menu',
          style: TextStyle(fontSize: 14),
        ),
      ),
      MatrixCell<TrackOccupant>.empty(
        cellId: CellId(trackId: TrackId.trackB, columnId: columnId),
      ),
      MatrixCell<TrackOccupant>.empty(
        cellId: CellId(trackId: TrackId.trackC, columnId: columnId),
      ),
      MatrixCell<TrackOccupant>.empty(
        cellId: CellId(trackId: TrackId.trackD, columnId: columnId),
      ),
      MatrixCell<TrackOccupant>.occupied(
        cellId: CellId(trackId: TrackId.trackE, columnId: columnId),
        occupant: FixedHeightTrackOccupant(height: 2),
      ),
      MatrixCell<TrackOccupant>.occupied(
        cellId: CellId(trackId: TrackId.trackF, columnId: columnId),
        occupant: FixedHeightTrackOccupant(height: 16),
      ),
    ],
  );

  return ResolvedTrackLayoutMatrix.resolve(
    matrix: matrix,
    constraints: const PresentationConstraints(
      availableWidth: 288,
      textScaler: TextScaler.noScaling,
      textDirection: TextDirection.ltr,
    ),
  );
}

ResolvedTrackLayoutMatrix _testUnfamiliarSourcesSidebarMatrix({
  required bool selected,
}) {
  const sidebarColumn = TrackColumnId.column1;
  const centerColumn = TrackColumnId.column2;
  final cells = <MatrixCell<TrackOccupant>>[
    const MatrixCell<TrackOccupant>.occupied(
      cellId: CellId(trackId: TrackId.trackA, columnId: sidebarColumn),
      occupant: TextTrackOccupant(
        text: 'matrix-top-menu',
        style: TextStyle(fontSize: 14),
      ),
    ),
    const MatrixCell<TrackOccupant>.occupied(
      cellId: CellId(trackId: TrackId.trackA, columnId: centerColumn),
      occupant: FixedHeightTrackOccupant(height: 20),
    ),
    for (final trackId in TrackId.values.skip(1))
      MatrixCell<TrackOccupant>.empty(
        cellId: CellId(trackId: trackId, columnId: sidebarColumn),
      ),
    for (final trackId in TrackId.values.skip(1))
      if (selected && trackId != TrackId.trackI)
        MatrixCell<TrackOccupant>.occupied(
          cellId: CellId(trackId: trackId, columnId: centerColumn),
          occupant: const FixedHeightTrackOccupant(height: 24),
        )
      else if (trackId == TrackId.trackI)
        const MatrixCell<TrackOccupant>.occupied(
          cellId: CellId(trackId: TrackId.trackI, columnId: centerColumn),
          occupant: FixedHeightTrackOccupant(height: 16),
        )
      else
        MatrixCell<TrackOccupant>.empty(
          cellId: CellId(trackId: trackId, columnId: centerColumn),
        ),
  ];
  final matrix = PageTrackLayoutMatrix<TrackOccupant>(
    trackIds: TrackId.values,
    columnIds: const [sidebarColumn, centerColumn],
    cells: cells,
  );

  return ResolvedTrackLayoutMatrix.resolve(
    matrix: matrix,
    constraints: const PresentationConstraints(
      availableWidth: 288,
      textScaler: TextScaler.noScaling,
      textDirection: TextDirection.ltr,
    ),
  );
}

ResolvedTrackLayoutMatrix _testRecoveredMessagesSidebarMatrix() {
  const columnId = TrackColumnId.column1;
  final matrix = PageTrackLayoutMatrix<TrackOccupant>(
    trackIds: const [TrackId.trackA],
    columnIds: const [columnId],
    cells: const [
      MatrixCell<TrackOccupant>.occupied(
        cellId: CellId(trackId: TrackId.trackA, columnId: columnId),
        occupant: TextTrackOccupant(
          text: 'matrix-top-menu',
          style: TextStyle(fontSize: 14),
        ),
      ),
    ],
  );
  return ResolvedTrackLayoutMatrix.resolve(
    matrix: matrix,
    constraints: const PresentationConstraints(
      availableWidth: 288,
      textScaler: TextScaler.noScaling,
      textDirection: TextDirection.ltr,
    ),
  );
}

ResolvedTrackLayoutMatrix _testMessageHistoryCoverageSidebarMatrix() {
  const columnId = TrackColumnId.column1;
  final matrix = PageTrackLayoutMatrix<TrackOccupant>(
    trackIds: const [TrackId.trackA],
    columnIds: const [columnId],
    cells: const [
      MatrixCell<TrackOccupant>.occupied(
        cellId: CellId(trackId: TrackId.trackA, columnId: columnId),
        occupant: TextTrackOccupant(
          text: 'matrix-settings-menu',
          style: TextStyle(fontSize: 14),
        ),
      ),
    ],
  );
  return ResolvedTrackLayoutMatrix.resolve(
    matrix: matrix,
    constraints: const PresentationConstraints(
      availableWidth: 288,
      textScaler: TextScaler.noScaling,
      textDirection: TextDirection.ltr,
    ),
  );
}

ResolvedTrackLayoutMatrix _testContactsSidebarMatrix() {
  const columnId = TrackColumnId.column1;
  final matrix = PageTrackLayoutMatrix<TrackOccupant>(
    trackIds: const [TrackId.trackA],
    columnIds: const [columnId],
    cells: const [
      MatrixCell<TrackOccupant>.occupied(
        cellId: CellId(trackId: TrackId.trackA, columnId: columnId),
        occupant: TextTrackOccupant(
          text: 'matrix-top-menu',
          style: TextStyle(fontSize: 14),
        ),
      ),
    ],
  );
  return ResolvedTrackLayoutMatrix.resolve(
    matrix: matrix,
    constraints: const PresentationConstraints(
      availableWidth: 288,
      textScaler: TextScaler.noScaling,
      textDirection: TextDirection.ltr,
    ),
  );
}

List<CellId> _renderedTrackCellIds(WidgetTester tester) {
  return [
    for (final widget in tester.widgetList<TrackCellView>(
      find.byType(TrackCellView),
    ))
      widget.cellId,
  ];
}

class _FakeMessagesViewSpecCoordinator
    extends messages_view_spec.ViewSpecCoordinator {
  @override
  void build() {}

  @override
  Widget buildForSpec(MessagesSpec spec) {
    return spec.when(
      forContact: (contactId, scrollToDate, filterHandleId) =>
          Text('contact:$contactId'),
      globalTimeline: (scrollToDate) => const Text('global'),
      forHandle: (handleId) => Text('handle:$handleId'),
      recoveredUnlinkedMessages: (contactId, scrollToDate) =>
          Text('recovered:${contactId ?? 'global'}'),
      recoveredNoHandleFromMeMessages: (scrollToDate) =>
          const Text('recovered:no-handle-from-me'),
      recoveredAttachmentViewer: (messageId, attachment) =>
          Text('attachment:$messageId'),
      handleInvestigation: (investigationId, investigation, target) =>
          target.when(
            idle: () => Text('idle:${investigation.name}'),
            selectedSource: (handleId) => Text('lens:$handleId'),
          ),
    );
  }
}

class _FakeConversationsViewSpecCoordinator
    extends conversations_view_spec.ViewSpecCoordinator {
  @override
  void build() {}

  @override
  Widget buildForSpec(ConversationsSpec spec) {
    return spec.when(
      conversationMessages: (conversationId, anchorMessageId, searchQuery) =>
          Text('conversation:$conversationId'),
      conversationExcerpt:
          (conversationId, anchorMessageId, _, beforeCount, afterCount) =>
              Text('conversation:$anchorMessageId'),
    );
  }
}

class _FakeSettingsViewSpecCoordinator
    extends settings_view_spec.ViewSpecCoordinator {
  @override
  void build() {}

  @override
  SettingsPanelRenderDescriptor resolveForSpec(SettingsViewSpec spec) {
    return spec.when(
      environmentSummary: () =>
          SettingsPanelRenderDescriptor.environmentSummary,
      attachmentArchiveWorkflow: () =>
          SettingsPanelRenderDescriptor.attachmentArchiveWorkflow,
      historicalArchivesWorkflow: () =>
          SettingsPanelRenderDescriptor.historicalArchivesWorkflow,
      messageHistoryCoverageReport: () =>
          SettingsPanelRenderDescriptor.messageHistoryCoverageReport,
    );
  }
}
