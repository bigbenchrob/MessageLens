import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers/conversation_graph_readiness_provider.dart';
import 'package:remember_this_text/essentials/navigation/application/panel_widget_providers.dart';
import 'package:remember_this_text/essentials/navigation/application/panels_view_state_provider.dart';
import 'package:remember_this_text/essentials/navigation/domain/navigation_constants.dart';
import 'package:remember_this_text/essentials/navigation/domain/sidebar_mode.dart';
import 'package:remember_this_text/essentials/search/application/message_text_search_query.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_flow_state_provider.dart';
import 'package:remember_this_text/features/conversations/application/actions/conversation_excerpt_navigation_actions_provider.dart';
import 'package:remember_this_text/features/messages/application/message_evidence/current_search_investigation_provider.dart';
import 'package:remember_this_text/features/messages/application/message_evidence/global_messages_search_session_provider.dart';
import 'package:remember_this_text/features/messages/domain/message_evidence/message_evidence_search_mode.dart';
import 'package:remember_this_text/features/messages/presentation/widgets/message_evidence/message_evidence_header.dart';
import 'package:remember_this_text/features/messages/presentation/widgets/message_evidence/message_evidence_header_track_metrics.dart';

void main() {
  testWidgets('renders typed message evidence header data and slots', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CupertinoApp(
          home: MessageEvidenceHeader(
            data: MessageEvidenceHeaderModel(
              title: 'Conversation with Claire and Cathie',
              dateRangeLabel: 'Jan 2014 to May 2026',
              countLabel: '86,563 messages',
              actions: Text('Copy evidence summary'),
            ),
            details: Text('Showing 100 loaded messages'),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Conversation with Claire and Cathie'), findsOneWidget);
    expect(find.text('Jan 2014 to May 2026'), findsOneWidget);
    expect(find.text('86,563 messages'), findsOneWidget);
    expect(find.text('Copy evidence summary'), findsOneWidget);
    expect(find.text('Showing 100 loaded messages'), findsOneWidget);
  });

  testWidgets('does not expose evidence-spine diagnostics in the header', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CupertinoApp(
          home: MessageEvidenceHeader(
            data: MessageEvidenceHeaderModel(
              title: 'Conversation with Claire and Cathie',
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Conversation with Claire and Cathie'), findsOneWidget);
    expect(find.textContaining('evidence skeleton'), findsNothing);
    expect(find.textContaining('hydrate visible rows'), findsNothing);
  });

  testWidgets('renders standard search and action regions', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    MessageEvidenceSearchMode? selectedMode;

    await tester.pumpWidget(
      ProviderScope(
        child: MacosApp(
          home: MessageEvidenceHeader(
            data: MessageEvidenceHeaderModel(
              title: 'All messages from Claire',
              searchConfig: MessageEvidenceHeaderSearchConfig(
                controller: controller,
                placeholder: 'Search messages from Claire',
                mode: MessageEvidenceSearchMode.allTerms,
                onModeChanged: (mode) {
                  selectedMode = mode;
                },
              ),
              actions: const Text('Copy evidence summary'),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byIcon(CupertinoIcons.search), findsOneWidget);
    expect(find.text('Search messages from Claire'), findsOneWidget);
    expect(find.text('AND'), findsOneWidget);
    expect(find.text('OR'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'AND — Match all terms' &&
            widget.properties.button == true &&
            widget.properties.selected == true,
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'OR — Match any term' &&
            widget.properties.button == true &&
            widget.properties.selected == false,
      ),
      findsOneWidget,
    );
    expect(find.text('Copy evidence summary'), findsOneWidget);

    await tester.tap(find.text('OR'));
    expect(selectedMode, MessageEvidenceSearchMode.anyTerm);
  });

  testWidgets('search control preserves raw trailing spaces during parsing', (
    tester,
  ) async {
    final observedRawInput = <String>[];
    final observedIntents = <MessageTextSearchExecutionIntent>[];

    await tester.pumpWidget(
      ProviderScope(
        child: MacosApp(
          home: MessageEvidenceSearchControlsPresentation(
            query: '',
            placeholder: 'Search messages',
            onQueryChanged: (rawInput) {
              observedRawInput.add(rawInput);
              observedIntents.add(
                MessageTextSearchQuery.parse(rawInput).executionIntent,
              );
            },
          ),
        ),
      ),
    );

    final fieldFinder = find.byType(MacosTextField);
    await tester.enterText(fieldFinder, 'post ');
    await tester.pump();

    expect(
      tester.widget<MacosTextField>(fieldFinder).controller?.text,
      'post ',
    );
    expect(observedRawInput.last, 'post ');
    expect(observedIntents.last.tokens, const [
      ExactMessageTextSearchToken('post'),
    ]);

    await tester.enterText(fieldFinder, 'post   ');
    await tester.pump();

    expect(
      tester.widget<MacosTextField>(fieldFinder).controller?.text,
      'post   ',
    );
    expect(observedRawInput.last, 'post   ');
    expect(observedIntents.last, observedIntents[observedIntents.length - 2]);

    await tester.enterText(fieldFinder, 'p');
    await tester.pump();
    expect(observedIntents.last.isExecutable, isFalse);
    expect(tester.widget<MacosTextField>(fieldFinder).controller?.text, 'p');

    await tester.enterText(fieldFinder, 'p ');
    await tester.pump();
    expect(observedIntents.last.isExecutable, isTrue);
    expect(tester.widget<MacosTextField>(fieldFinder).controller?.text, 'p ');
  });

  testWidgets('clear button starts a new investigation declaratively', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        conversationGraphPopulatedProvider.overrideWith(
          _AlwaysPopulatedGraph.new,
        ),
      ],
    );
    addTearDown(container.dispose);
    final flowSubscription = container.listen(sidebarFlowProvider, (_, __) {});
    final actionSubscription = container.listen(
      conversationExcerptNavigationActionsProvider,
      (_, __) {},
    );
    final effectivePanelSubscription = container.listen(
      effectiveRightPanelSpecProvider(SidebarMode.messages),
      (_, __) {},
    );
    addTearDown(flowSubscription.close);
    addTearDown(actionSubscription.close);
    addTearDown(effectivePanelSubscription.close);
    await tester.pump(const Duration(milliseconds: 1));
    container.read(sidebarFlowProvider.notifier).showGlobalTimeline();
    await tester.pump(const Duration(milliseconds: 1));
    final session = container.read(
      globalMessagesSearchSessionProvider(monthAnchor: null).notifier,
    );
    session.setQuery('family');
    await tester.pump(const Duration(milliseconds: 1));
    final originatingId = container.read(currentSearchInvestigationProvider);
    container
        .read(conversationExcerptNavigationActionsProvider.notifier)
        .open(
          conversationId: 42,
          anchorMessageId: 9001,
          originatingInvestigationId: originatingId,
        );
    await tester.pump(const Duration(milliseconds: 1));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MacosApp(
          home: MessageEvidenceSearchControlsPresentation(
            query: 'family',
            placeholder: 'Search these messages',
            mode: MessageEvidenceSearchMode.allTerms,
            onQueryChanged: session.setQuery,
            onModeChanged: session.setMode,
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(CupertinoIcons.clear_thick_circled));
    await tester.pump(const Duration(milliseconds: 1));

    expect(
      container
          .read(globalMessagesSearchSessionProvider(monthAnchor: null))
          .query,
      isEmpty,
    );
    expect(
      container.read(currentSearchInvestigationProvider),
      isNot(originatingId),
    );
    expect(
      container
          .read(
            panelsViewStateProvider(SidebarMode.messages),
          )[WindowPanel.right]
          ?.isEmpty,
      isFalse,
    );
    expect(
      container.read(effectiveRightPanelSpecProvider(SidebarMode.messages)),
      isNull,
    );
  });

  testWidgets(
    'investigation status aligns with the field and delays activity chrome',
    (tester) async {
      const description = 'Messages matching "family"';
      const style = TextStyle(fontSize: 13, height: 1);

      Widget subject({required bool isSearching}) {
        return ProviderScope(
          child: MacosApp(
            home: Center(
              child: SizedBox(
                width: 500,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MessageEvidenceSearchControlsPresentation(
                      query: 'family',
                      placeholder: 'Search these messages',
                      mode: MessageEvidenceSearchMode.allTerms,
                      onQueryChanged: (_) {},
                      onModeChanged: (_) {},
                    ),
                    SearchInvestigationStatusPresentation(
                      description: description,
                      isSearching: isSearching,
                      style: style,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      await tester.pumpWidget(subject(isSearching: true));
      await tester.pump();

      final fieldLeft = tester.getTopLeft(find.byType(MacosTextField)).dx;
      final statusLeft = tester.getTopLeft(find.text(description)).dx;
      final restingSize = tester.getSize(
        find.byType(SearchInvestigationStatusPresentation),
      );
      expect(
        statusLeft,
        closeTo(
          fieldLeft +
              MessageEvidenceHeaderTrackMetrics.searchStatusFieldChromeInset,
          0.01,
        ),
      );
      expect(find.byType(ProgressCircle), findsNothing);

      await tester.pump(const Duration(milliseconds: 174));
      expect(find.byType(ProgressCircle), findsNothing);

      await tester.pump(const Duration(milliseconds: 2));
      expect(find.byType(ProgressCircle), findsOneWidget);
      expect(find.text('$description · Searching...'), findsOneWidget);
      expect(
        tester.getSize(find.byType(SearchInvestigationStatusPresentation)),
        restingSize,
      );

      await tester.pumpWidget(subject(isSearching: false));
      await tester.pump();
      expect(find.byType(ProgressCircle), findsNothing);
      expect(find.text(description), findsOneWidget);
      expect(
        tester.getSize(find.byType(SearchInvestigationStatusPresentation)),
        restingSize,
      );
    },
  );
}

class _AlwaysPopulatedGraph extends ConversationGraphPopulated {
  @override
  bool build() => true;
}
