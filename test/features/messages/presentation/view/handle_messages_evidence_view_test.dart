import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_graph_reader.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_graph_reader_provider.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_graph_repository.dart';
import 'package:remember_this_text/essentials/search/application/graph_message_search.dart';
import 'package:remember_this_text/essentials/search/application/message_text_search_query.dart';
import 'package:remember_this_text/essentials/search/application/search_service.dart';
import 'package:remember_this_text/essentials/search/feature_level_providers.dart'
    show searchServiceProvider;
import 'package:remember_this_text/features/contacts/application/display_identity/display_identity.dart';
import 'package:remember_this_text/features/contacts/application/display_identity/display_identity_resolver_provider.dart';
import 'package:remember_this_text/features/handles/application/read_models/handle_display_name_provider.dart';
import 'package:remember_this_text/features/messages/presentation/view/handle_messages_evidence_view.dart';

void main() {
  testWidgets('renders handle messages through evidence spine', (tester) async {
    const repository = _FakeMessageGraphRepository(
      timeline: [
        ConversationMessageTimelineEntry(
          messageId: 1,
          dateUtc: '2026-04-20T10:00:00.000Z',
          monthKey: '2026-04',
        ),
      ],
      hydratedMessage: ConversationMessage(
        messageId: 1,
        dateUtc: '2026-04-20T10:00:00.000Z',
        isFromMe: false,
        text: 'handle message',
        associatedMessageId: null,
        attachmentCount: 0,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          messageGraphReaderProvider.overrideWith((ref) async {
            return const MessageGraphReader(repository: repository);
          }),
          handleDisplayNameProvider(handleId: 12).overrideWith((ref) async {
            return 'Claire';
          }),
          displayIdentityResolverProvider.overrideWith((ref) async {
            return const DisplayIdentityResolver(identitiesByHandleKey: {});
          }),
        ],
        child: const MacosApp(home: HandleMessagesEvidenceView(handleId: 12)),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Messages for Claire'), findsOneWidget);
    expect(find.text('handle message'), findsOneWidget);
  });

  testWidgets('filters handle timeline to graph search matches', (
    tester,
  ) async {
    const repository = _FakeMessageGraphRepository(
      timeline: [
        ConversationMessageTimelineEntry(
          messageId: 1,
          dateUtc: '2026-04-20T10:00:00.000Z',
          monthKey: '2026-04',
        ),
        ConversationMessageTimelineEntry(
          messageId: 2,
          dateUtc: '2026-04-21T10:00:00.000Z',
          monthKey: '2026-04',
        ),
      ],
      hydratedMessages: {
        1: ConversationMessage(
          messageId: 1,
          dateUtc: '2026-04-20T10:00:00.000Z',
          isFromMe: false,
          text: 'first handle message',
          associatedMessageId: null,
          attachmentCount: 0,
        ),
        2: ConversationMessage(
          messageId: 2,
          dateUtc: '2026-04-21T10:00:00.000Z',
          isFromMe: false,
          text: 'matching handle result',
          associatedMessageId: null,
          attachmentCount: 0,
        ),
      },
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          messageGraphReaderProvider.overrideWith((ref) async {
            return const MessageGraphReader(repository: repository);
          }),
          searchServiceProvider.overrideWith((ref) {
            return SearchService(
              readRepository: () async {
                return const _FakeGraphSearchRepository(
                  allTermIds: [2],
                  anyTermIds: [1, 2],
                );
              },
            );
          }),
          handleDisplayNameProvider(handleId: 12).overrideWith((ref) async {
            return 'Claire';
          }),
          displayIdentityResolverProvider.overrideWith((ref) async {
            return const DisplayIdentityResolver(identitiesByHandleKey: {});
          }),
        ],
        child: const MacosApp(home: HandleMessagesEvidenceView(handleId: 12)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('first handle message'), findsOneWidget);
    expect(find.text('matching handle result'), findsOneWidget);

    await tester.enterText(find.byType(MacosTextField), 'matching alternate');
    await tester.pumpAndSettle();

    expect(find.text('first handle message'), findsNothing);
    expect(find.text('matching handle result'), findsOneWidget);
    expect(
      find.textContaining('1 of 2 messages match "matching alternate"'),
      findsOneWidget,
    );
    expect(find.text('Messages matching "matching alternate"'), findsOneWidget);

    await tester.tap(find.text('OR'));
    await tester.pumpAndSettle();

    expect(find.text('first handle message'), findsOneWidget);
    expect(find.text('matching handle result'), findsOneWidget);
    expect(
      find.textContaining('2 of 2 messages match "matching alternate"'),
      findsOneWidget,
    );
  });
}

class _FakeMessageGraphRepository implements MessageGraphRepository {
  const _FakeMessageGraphRepository({
    required this.timeline,
    this.hydratedMessage,
    this.hydratedMessages = const <int, ConversationMessage>{},
  });

  final List<ConversationMessageTimelineEntry> timeline;
  final ConversationMessage? hydratedMessage;
  final Map<int, ConversationMessage> hydratedMessages;

  @override
  Future<List<ConversationMessageTimelineEntry>>
  readGlobalMessageTimeline() async {
    return const <ConversationMessageTimelineEntry>[];
  }

  @override
  Future<ConversationMessage?> readGlobalMessageById({
    required int messageId,
  }) async {
    return null;
  }

  @override
  Future<List<int>> readGlobalMessageIdsMatchingText({
    required String query,
    bool matchAnyTerm = false,
  }) async {
    return const <int>[];
  }

  @override
  Future<List<ConversationMessageTimelineEntry>> readHandleMessageTimeline({
    required int handleId,
  }) async {
    return timeline;
  }

  @override
  Future<ConversationMessage?> readHandleMessageById({
    required int handleId,
    required int messageId,
  }) async {
    final mappedMessage = hydratedMessages[messageId];
    if (mappedMessage != null) {
      return mappedMessage;
    }
    return hydratedMessage?.messageId == messageId ? hydratedMessage : null;
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

class _FakeGraphSearchRepository implements GraphSearchRepository {
  const _FakeGraphSearchRepository({
    required this.allTermIds,
    required this.anyTermIds,
  });

  final List<int> allTermIds;
  final List<int> anyTermIds;

  @override
  Future<List<int>> searchMessageIds({
    required GraphMessageSearchScope scope,
    required List<MessageTextSearchToken> textTokens,
    required bool matchAnyTerm,
    required bool filterSaved,
    int limit = graphSearchResultLimit,
  }) async {
    return matchAnyTerm ? anyTermIds : allTermIds;
  }
}
