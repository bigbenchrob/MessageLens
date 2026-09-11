import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/identity/live_chat_graph_identity.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_graph_reader.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_graph_reader_provider.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_graph_repository.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers/conversation_graph_readiness_provider.dart';
import 'package:remember_this_text/essentials/navigation/application/panels_view_state_provider.dart';
import 'package:remember_this_text/essentials/navigation/domain/entities/view_spec.dart';
import 'package:remember_this_text/essentials/navigation/domain/navigation_constants.dart';
import 'package:remember_this_text/essentials/navigation/domain/sidebar_mode.dart';
import 'package:remember_this_text/essentials/search/application/graph_message_search.dart';
import 'package:remember_this_text/essentials/search/application/graph_search_repository_provider.dart';
import 'package:remember_this_text/essentials/search/application/message_text_search_query.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_flow_state_provider.dart';
import 'package:remember_this_text/features/conversations/application/actions/conversation_excerpt_navigation_actions_provider.dart';
import 'package:remember_this_text/features/conversations/domain/spec_classes/conversations_view_spec.dart';
import 'package:remember_this_text/features/messages/application/message_evidence/current_search_investigation_provider.dart';
import 'package:remember_this_text/features/messages/application/message_evidence/global_messages_search_session_provider.dart';
import 'package:remember_this_text/features/messages/application/message_evidence/message_evidence_spine_provider.dart';
import 'package:remember_this_text/features/messages/domain/message_evidence/message_evidence_row_data.dart';
import 'package:remember_this_text/features/messages/domain/message_evidence/message_evidence_scope.dart';
import 'package:remember_this_text/features/messages/domain/search_investigation_id.dart';
import 'package:remember_this_text/features/messages/presentation/view/global_messages_evidence_view.dart';
import 'package:remember_this_text/features/messages/presentation/view_model/global_messages_evidence_presentation_provider.dart';
import 'package:remember_this_text/features/messages/presentation/widgets/message_evidence/message_evidence_row.dart';

void main() {
  testWidgets('renders global timeline through evidence spine', (tester) async {
    const message = ConversationMessage(
      messageId: 1,
      dateUtc: '2026-04-20T10:00:00.000Z',
      isFromMe: true,
      text: 'global message',
      associatedMessageId: null,
      attachmentCount: 0,
    );
    const repository = _FakeMessageGraphRepository(
      timeline: [
        ConversationMessageTimelineEntry(
          messageId: 1,
          dateUtc: '2026-04-20T10:00:00.000Z',
          monthKey: '2026-04',
        ),
      ],
      messagesById: {1: message},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          messageGraphReaderProvider.overrideWith((ref) async {
            return const MessageGraphReader(repository: repository);
          }),
          messageEvidenceRowProvider(
            scope: const GlobalMessagesEvidenceScope(),
            messageId: message.messageId,
          ).overrideWith((ref) async => _rowData(message)),
        ],
        child: const MacosApp(home: GlobalMessagesEvidenceView()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('All messages'), findsOneWidget);
    expect(find.text('global message'), findsOneWidget);
    expect(find.text('In conversation'), findsNothing);
  });

  testWidgets(
    'opens conversation context from an unfiltered canonical message',
    (tester) async {
      final messageId = canonicalLiveChatGraphId(10);
      final conversationId = canonicalLiveChatGraphId(99);
      final message = ConversationMessage(
        messageId: messageId,
        dateUtc: '2026-04-20T10:00:00.000Z',
        isFromMe: true,
        text: 'unfiltered canonical message',
        associatedMessageId: null,
        attachmentCount: 0,
        conversationId: conversationId,
      );
      final repository = _FakeMessageGraphRepository(
        timeline: [
          ConversationMessageTimelineEntry(
            messageId: messageId,
            dateUtc: message.dateUtc,
            monthKey: '2026-04',
          ),
        ],
        messagesById: {messageId: message},
      );
      const scope = GlobalMessagesEvidenceScope();
      final container = ProviderContainer(
        overrides: [
          messageGraphReaderProvider.overrideWith((ref) async {
            return MessageGraphReader(repository: repository);
          }),
          messageEvidenceRowProvider(
            scope: scope,
            messageId: messageId,
          ).overrideWith((ref) async => _rowData(message)),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MacosApp(home: GlobalMessagesEvidenceView()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('In conversation'), findsOneWidget);
      final investigationId = container.read(
        currentSearchInvestigationProvider,
      );

      await tester.tap(find.text('In conversation'));
      await tester.pump();

      expect(
        container
            .read(
              panelsViewStateProvider(SidebarMode.messages),
            )[WindowPanel.right]
            ?.activePage
            ?.spec,
        ViewSpec.conversations(
          ConversationsSpec.conversationExcerpt(
            conversationId: conversationId,
            anchorMessageId: messageId,
            originatingInvestigationId: investigationId,
          ),
        ),
      );
    },
  );

  testWidgets('hides action for the exact active unfiltered excerpt', (
    tester,
  ) async {
    final messageId = canonicalLiveChatGraphId(11);
    final conversationId = canonicalLiveChatGraphId(100);
    final message = ConversationMessage(
      messageId: messageId,
      dateUtc: '2026-04-20T10:00:00.000Z',
      isFromMe: true,
      text: 'active context message',
      associatedMessageId: null,
      attachmentCount: 0,
      conversationId: conversationId,
    );
    final repository = _FakeMessageGraphRepository(
      timeline: [
        ConversationMessageTimelineEntry(
          messageId: messageId,
          dateUtc: message.dateUtc,
          monthKey: '2026-04',
        ),
      ],
      messagesById: {messageId: message},
    );
    const scope = GlobalMessagesEvidenceScope();
    final container = ProviderContainer(
      overrides: [
        messageGraphReaderProvider.overrideWith((ref) async {
          return MessageGraphReader(repository: repository);
        }),
        messageEvidenceRowProvider(
          scope: scope,
          messageId: messageId,
        ).overrideWith((ref) async => _rowData(message)),
      ],
    );
    addTearDown(container.dispose);
    container
        .read(conversationExcerptNavigationActionsProvider.notifier)
        .open(
          conversationId: conversationId,
          anchorMessageId: messageId,
          originatingInvestigationId: container.read(
            currentSearchInvestigationProvider,
          ),
        );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MacosApp(home: GlobalMessagesEvidenceView()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('In conversation'), findsNothing);
  });

  testWidgets('filters global timeline through evidence spine text matches', (
    tester,
  ) async {
    final matchingMessage = ConversationMessage(
      messageId: canonicalLiveChatGraphId(1),
      dateUtc: '2026-04-20T10:00:00.000Z',
      isFromMe: true,
      text: 'needle global message',
      associatedMessageId: null,
      attachmentCount: 0,
      conversationId: canonicalLiveChatGraphId(99),
    );
    final nonMatchingMessage = ConversationMessage(
      messageId: canonicalLiveChatGraphId(2),
      dateUtc: '2026-04-21T10:00:00.000Z',
      isFromMe: true,
      text: 'other global message',
      associatedMessageId: null,
      attachmentCount: 0,
    );
    final repository = _FakeMessageGraphRepository(
      timeline: [
        ConversationMessageTimelineEntry(
          messageId: matchingMessage.messageId,
          dateUtc: '2026-04-20T10:00:00.000Z',
          monthKey: '2026-04',
        ),
        ConversationMessageTimelineEntry(
          messageId: nonMatchingMessage.messageId,
          dateUtc: '2026-04-21T10:00:00.000Z',
          monthKey: '2026-04',
        ),
      ],
      messagesById: {
        matchingMessage.messageId: matchingMessage,
        nonMatchingMessage.messageId: nonMatchingMessage,
      },
      globalMatchesByQuery: {
        'needle': [matchingMessage.messageId],
      },
    );
    const allMessagesScope = GlobalMessagesEvidenceScope();
    const searchScope = MessageSearchEvidenceScope(query: 'needle');
    final container = ProviderContainer(
      overrides: [
        messageGraphReaderProvider.overrideWith((ref) async {
          return MessageGraphReader(repository: repository);
        }),
        graphSearchRepositoryProvider.overrideWith((ref) async {
          return _FakeGraphSearchRepository(
            globalMatchesByQuery: {
              'needle': [matchingMessage.messageId],
            },
          );
        }),
        messageEvidenceRowProvider(
          scope: allMessagesScope,
          messageId: matchingMessage.messageId,
        ).overrideWith((ref) async => _rowData(matchingMessage)),
        messageEvidenceRowProvider(
          scope: allMessagesScope,
          messageId: nonMatchingMessage.messageId,
        ).overrideWith((ref) async => _rowData(nonMatchingMessage)),
        messageEvidenceRowProvider(
          scope: searchScope,
          messageId: matchingMessage.messageId,
        ).overrideWith((ref) async => _rowData(matchingMessage)),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MacosApp(home: GlobalMessagesEvidenceView()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('needle global message'), findsOneWidget);
    expect(find.text('other global message'), findsOneWidget);

    await tester.enterText(find.byType(MacosTextField), 'needle');
    await tester.pumpAndSettle();

    expect(find.text('needle global message'), findsOneWidget);
    expect(find.text('other global message'), findsNothing);
    expect(find.text('1 of 2 messages match "needle"'), findsOneWidget);
    expect(find.text('In conversation'), findsOneWidget);
  });

  testWidgets('global search keeps raw input while execution intent changes', (
    tester,
  ) async {
    const repository = _FakeMessageGraphRepository(
      timeline: [],
      messagesById: {},
    );
    final container = ProviderContainer(
      overrides: [
        messageGraphReaderProvider.overrideWith((ref) async {
          return const MessageGraphReader(repository: repository);
        }),
        graphSearchRepositoryProvider.overrideWith((ref) async {
          return const _FakeGraphSearchRepository();
        }),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MacosApp(home: GlobalMessagesEvidenceView()),
      ),
    );
    await tester.pumpAndSettle();

    final fieldFinder = find.byType(MacosTextField);
    await tester.enterText(fieldFinder, 'post');
    await tester.pump();
    final prefixPresentation = container.read(
      globalMessagesEvidencePresentationProvider(),
    );
    expect(prefixPresentation.query, 'post');
    expect(
      (prefixPresentation.evidenceScope as MessageSearchEvidenceScope)
          .searchIntent
          .tokens,
      const [PrefixMessageTextSearchToken('post')],
    );

    await tester.enterText(fieldFinder, 'post ');
    await tester.pump();
    final exactPresentation = container.read(
      globalMessagesEvidencePresentationProvider(),
    );
    expect(
      tester.widget<MacosTextField>(fieldFinder).controller?.text,
      'post ',
    );
    expect(
      container.read(globalMessagesSearchSessionProvider()).query,
      'post ',
    );
    expect(
      (exactPresentation.evidenceScope as MessageSearchEvidenceScope)
          .searchIntent
          .tokens,
      const [ExactMessageTextSearchToken('post')],
    );

    await tester.enterText(fieldFinder, 'post   ');
    await tester.pump();
    expect(
      tester.widget<MacosTextField>(fieldFinder).controller?.text,
      'post   ',
    );
    expect(
      container.read(globalMessagesSearchSessionProvider()).query,
      'post   ',
    );

    await tester.enterText(fieldFinder, 'p');
    await tester.pump();
    expect(
      container
          .read(globalMessagesEvidencePresentationProvider())
          .hasExecutableSearch,
      isFalse,
    );
    await tester.enterText(fieldFinder, 'p ');
    await tester.pump();
    expect(tester.widget<MacosTextField>(fieldFinder).controller?.text, 'p ');
    expect(
      container
          .read(globalMessagesEvidencePresentationProvider())
          .hasExecutableSearch,
      isTrue,
    );
  });

  testWidgets(
    'anchors center evidence to active right-panel conversation excerpt',
    (tester) async {
      final targetMessageId = canonicalLiveChatGraphId(123);
      final otherMessageId = canonicalLiveChatGraphId(124);
      final targetMessage = ConversationMessage(
        messageId: targetMessageId,
        dateUtc: '2026-04-20T10:00:00.000Z',
        isFromMe: true,
        text: 'context target message',
        associatedMessageId: null,
        attachmentCount: 0,
        conversationId: canonicalLiveChatGraphId(99),
      );
      final otherMessage = ConversationMessage(
        messageId: otherMessageId,
        dateUtc: '2026-04-21T10:00:00.000Z',
        isFromMe: true,
        text: 'other global message',
        associatedMessageId: null,
        attachmentCount: 0,
      );
      final repository = _FakeMessageGraphRepository(
        timeline: [
          ConversationMessageTimelineEntry(
            messageId: otherMessage.messageId,
            dateUtc: '2026-04-21T10:00:00.000Z',
            monthKey: '2026-04',
          ),
          ConversationMessageTimelineEntry(
            messageId: targetMessage.messageId,
            dateUtc: '2026-04-20T10:00:00.000Z',
            monthKey: '2026-04',
          ),
        ],
        messagesById: {
          targetMessage.messageId: targetMessage,
          otherMessage.messageId: otherMessage,
        },
      );
      const allMessagesScope = GlobalMessagesEvidenceScope();
      final container = ProviderContainer(
        overrides: [
          conversationGraphPopulatedProvider.overrideWith(
            _AlwaysPopulatedGraph.new,
          ),
          messageGraphReaderProvider.overrideWith((ref) async {
            return MessageGraphReader(repository: repository);
          }),
          messageEvidenceRowProvider(
            scope: allMessagesScope,
            messageId: targetMessage.messageId,
          ).overrideWith((ref) async => _rowData(targetMessage)),
          messageEvidenceRowProvider(
            scope: allMessagesScope,
            messageId: otherMessage.messageId,
          ).overrideWith((ref) async => _rowData(otherMessage)),
        ],
      );
      addTearDown(container.dispose);

      container.read(sidebarFlowProvider.notifier).showGlobalTimeline();
      container
          .read(panelsViewStateProvider(SidebarMode.messages).notifier)
          .show(
            panel: WindowPanel.right,
            spec: ViewSpec.conversations(
              ConversationsSpec.conversationExcerpt(
                conversationId: canonicalLiveChatGraphId(99),
                anchorMessageId: targetMessageId,
                originatingInvestigationId: const SearchInvestigationId(0),
              ),
            ),
          );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MacosApp(home: GlobalMessagesEvidenceView()),
        ),
      );

      await tester.pumpAndSettle();

      final targetRow = tester.widget<MessageEvidenceRow>(
        find.ancestor(
          of: find.text('context target message'),
          matching: find.byType(MessageEvidenceRow),
        ),
      );
      final otherRow = tester.widget<MessageEvidenceRow>(
        find.ancestor(
          of: find.text('other global message'),
          matching: find.byType(MessageEvidenceRow),
        ),
      );

      expect(targetRow.isAnchorMessage, isTrue);
      expect(otherRow.isAnchorMessage, isFalse);

      container.read(currentSearchInvestigationProvider.notifier).advance();
      await tester.pump();

      final staleTargetRow = tester.widget<MessageEvidenceRow>(
        find.ancestor(
          of: find.text('context target message'),
          matching: find.byType(MessageEvidenceRow),
        ),
      );
      expect(staleTargetRow.isAnchorMessage, isFalse);
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
}

MessageEvidenceRowData _rowData(ConversationMessage message) {
  return MessageEvidenceRowData(
    messageId: message.messageId,
    dateUtc: message.dateUtc,
    isFromMe: message.isFromMe,
    text: message.text,
    associatedMessageId: message.associatedMessageId,
    attachmentCount: message.attachmentCount,
    sourceConversationId: message.conversationId,
  );
}

class _FakeGraphSearchRepository implements GraphSearchRepository {
  const _FakeGraphSearchRepository({
    this.globalMatchesByQuery = const <String, List<int>>{},
  });

  final Map<String, List<int>> globalMatchesByQuery;

  @override
  Future<List<int>> searchMessageIds({
    required GraphMessageSearchScope scope,
    required List<MessageTextSearchToken> textTokens,
    required bool matchAnyTerm,
    required bool filterSaved,
    int limit = graphSearchResultLimit,
  }) async {
    if (scope.type != GraphMessageSearchScopeType.global) {
      return const <int>[];
    }
    final query = textTokens.map((token) => token.normalizedText).join(' ');
    return globalMatchesByQuery[query] ?? const <int>[];
  }
}

class _FakeMessageGraphRepository implements MessageGraphRepository {
  const _FakeMessageGraphRepository({
    required this.timeline,
    required this.messagesById,
    this.globalMatchesByQuery = const <String, List<int>>{},
  });

  final List<ConversationMessageTimelineEntry> timeline;
  final Map<int, ConversationMessage> messagesById;
  final Map<String, List<int>> globalMatchesByQuery;

  @override
  Future<List<ConversationMessageTimelineEntry>>
  readGlobalMessageTimeline() async {
    return timeline;
  }

  @override
  Future<ConversationMessage?> readGlobalMessageById({
    required int messageId,
  }) async {
    return messagesById[messageId];
  }

  @override
  Future<List<int>> readGlobalMessageIdsMatchingText({
    required String query,
    bool matchAnyTerm = false,
  }) async {
    return globalMatchesByQuery[query] ?? const <int>[];
  }

  @override
  Future<List<ConversationMessageTimelineEntry>> readHandleMessageTimeline({
    required int handleId,
  }) async {
    return const <ConversationMessageTimelineEntry>[];
  }

  @override
  Future<ConversationMessage?> readHandleMessageById({
    required int handleId,
    required int messageId,
  }) async {
    return null;
  }

  @override
  Future<List<int>> readHandleMessageIdsMatchingText({
    required int handleId,
    required String query,
    bool matchAnyTerm = false,
  }) async {
    return const <int>[];
  }

  @override
  Future<List<ConversationMessageTimelineEntry>>
  readConversationExcerptTimeline({
    required int conversationId,
    required int anchorMessageId,
    required int beforeCount,
    required int afterCount,
  }) async {
    return const <ConversationMessageTimelineEntry>[];
  }
}

class _AlwaysPopulatedGraph extends ConversationGraphPopulated {
  @override
  bool build() {
    return true;
  }
}
