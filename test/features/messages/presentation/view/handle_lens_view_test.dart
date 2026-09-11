import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/widgets.dart'
    show Directionality, SizedBox, TextDirection;
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/identity/live_chat_graph_identity.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_graph_reader.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_graph_reader_provider.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_graph_repository.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart'
    show overlayDatabaseProvider;
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/search/application/graph_message_search.dart';
import 'package:remember_this_text/essentials/search/application/message_text_search_query.dart';
import 'package:remember_this_text/essentials/search/application/search_service.dart';
import 'package:remember_this_text/essentials/search/feature_level_providers.dart'
    show searchServiceProvider;
import 'package:remember_this_text/features/contacts/application/display_identity/display_identity.dart';
import 'package:remember_this_text/features/contacts/application/display_identity/display_identity_resolver_provider.dart';
import 'package:remember_this_text/features/handles/application/read_models/handle_source_presentation.dart';
import 'package:remember_this_text/features/handles/application/read_models/handle_source_presentation_provider.dart';
import 'package:remember_this_text/features/handles/domain/spec_classes/handles_cassette_spec.dart';
import 'package:remember_this_text/features/handles/domain/utilities/handle_normalizer.dart';
import 'package:remember_this_text/features/messages/presentation/view/handle_lens_view.dart';

void main() {
  testWidgets('renders unfamiliar-source evidence with one unified header', (
    tester,
  ) async {
    final handleId = canonicalLiveChatGraphId(12);
    const handleValue = '1 (604) 307-8325';
    const repository = _FakeMessageGraphRepository(
      timeline: [
        ConversationMessageTimelineEntry(
          messageId: 1,
          dateUtc: '2020-06-22T17:04:00.000Z',
          monthKey: '2020-06',
        ),
      ],
      hydratedMessage: ConversationMessage(
        messageId: 1,
        dateUtc: '2020-06-22T17:04:00.000Z',
        isFromMe: true,
        text: 'Please forward the information.',
        associatedMessageId: null,
        attachmentCount: 0,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          handleSourcePresentationProvider(handleId: handleId).overrideWith(
            (ref) async => HandleSourcePresentation(
              canonicalHandleId: handleId,
              primaryDisplayLabel: handleValue,
              rawEndpoint: handleValue,
              statusLabel: 'Unfamiliar source',
              messageCount: 243,
            ),
          ),
          messageGraphReaderProvider.overrideWith((ref) async {
            return const MessageGraphReader(repository: repository);
          }),
          displayIdentityResolverProvider.overrideWith((ref) async {
            return const DisplayIdentityResolver(identitiesByHandleKey: {});
          }),
        ],
        child: MacosApp(
          home: HandleLensView(
            handleId: handleId,
            investigation: StrayHandleInvestigation.identifySources,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Messages not linked to a contact'), findsOneWidget);
    expect(find.text('Unfamiliar source'), findsNothing);
    expect(find.text(handleValue), findsOneWidget);
    expect(find.text('Message evidence'), findsNothing);
    expect(find.textContaining('Handle scope'), findsNothing);
    expect(find.textContaining('Last:'), findsNothing);
    expect(find.text('SMS'), findsNothing);
    expect(find.text('Create Contact'), findsOneWidget);
    expect(find.text('Link to Existing'), findsOneWidget);
    expect(find.text('Dismiss'), findsOneWidget);
    expect(find.text('Please forward the information.'), findsOneWidget);
  });

  testWidgets('keeps the Messages ViewSpec while source identity is loading', (
    tester,
  ) async {
    final handleId = canonicalLiveChatGraphId(12);
    final presentationCompleter = Completer<HandleSourcePresentation>();
    const repository = _FakeMessageGraphRepository(
      timeline: [
        ConversationMessageTimelineEntry(
          messageId: 1,
          dateUtc: '2020-06-22T17:04:00.000Z',
          monthKey: '2020-06',
        ),
      ],
      hydratedMessage: ConversationMessage(
        messageId: 1,
        dateUtc: '2020-06-22T17:04:00.000Z',
        isFromMe: true,
        text: 'Please forward the information.',
        associatedMessageId: null,
        attachmentCount: 0,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          handleSourcePresentationProvider(
            handleId: handleId,
          ).overrideWith((ref) => presentationCompleter.future),
          messageGraphReaderProvider.overrideWith((ref) async {
            return const MessageGraphReader(repository: repository);
          }),
          displayIdentityResolverProvider.overrideWith((ref) async {
            return const DisplayIdentityResolver(identitiesByHandleKey: {});
          }),
        ],
        child: MacosApp(
          home: HandleLensView(
            handleId: handleId,
            investigation: StrayHandleInvestigation.numericSenderIds,
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Loading source...'), findsOneWidget);
    expect(find.text('Messages from numeric IDs'), findsOneWidget);
    expect(find.text('Create Contact'), findsOneWidget);
    expect(find.text('Dismiss'), findsOneWidget);
  });

  testWidgets('filters Handle Lens evidence to graph search matches', (
    tester,
  ) async {
    final handleId = canonicalLiveChatGraphId(12);
    const repository = _FakeMessageGraphRepository(
      timeline: [
        ConversationMessageTimelineEntry(
          messageId: 1,
          dateUtc: '2020-06-22T17:04:00.000Z',
          monthKey: '2020-06',
        ),
        ConversationMessageTimelineEntry(
          messageId: 2,
          dateUtc: '2020-06-23T17:04:00.000Z',
          monthKey: '2020-06',
        ),
      ],
      hydratedMessages: {
        1: ConversationMessage(
          messageId: 1,
          dateUtc: '2020-06-22T17:04:00.000Z',
          isFromMe: true,
          text: 'first lens message',
          associatedMessageId: null,
          attachmentCount: 0,
        ),
        2: ConversationMessage(
          messageId: 2,
          dateUtc: '2020-06-23T17:04:00.000Z',
          isFromMe: false,
          text: 'matching lens result',
          associatedMessageId: null,
          attachmentCount: 0,
        ),
      },
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          handleSourcePresentationProvider(handleId: handleId).overrideWith(
            (ref) async => HandleSourcePresentation(
              canonicalHandleId: handleId,
              primaryDisplayLabel: 'Unknown sender',
              rawEndpoint: '+15551234567',
              statusLabel: 'Unfamiliar source',
              messageCount: 2,
            ),
          ),
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
          displayIdentityResolverProvider.overrideWith((ref) async {
            return const DisplayIdentityResolver(identitiesByHandleKey: {});
          }),
        ],
        child: MacosApp(
          home: HandleLensView(
            handleId: handleId,
            investigation: StrayHandleInvestigation.identifySources,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('first lens message'), findsOneWidget);
    expect(find.text('matching lens result'), findsOneWidget);

    await tester.enterText(find.byType(MacosTextField), 'matching alternate');
    await tester.pumpAndSettle();

    expect(find.text('first lens message'), findsNothing);
    expect(find.text('matching lens result'), findsOneWidget);
    expect(
      find.textContaining('1 of 2 messages match "matching alternate"'),
      findsOneWidget,
    );
    expect(find.text('Messages matching "matching alternate"'), findsOneWidget);

    await tester.tap(find.text('OR'));
    await tester.pumpAndSettle();

    expect(find.text('first lens message'), findsOneWidget);
    expect(find.text('matching lens result'), findsOneWidget);
    expect(
      find.textContaining('2 of 2 messages match "matching alternate"'),
      findsOneWidget,
    );
  });

  testWidgets('Dismiss button invokes recoverable Handles dismissal', (
    tester,
  ) async {
    final handleId = canonicalLiveChatGraphId(12);
    const handleValue = '1 (604) 307-8325';
    final overlayDb = OverlayDatabase(NativeDatabase.memory());
    addTearDown(overlayDb.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
          handleSourcePresentationProvider(handleId: handleId).overrideWith(
            (ref) async => HandleSourcePresentation(
              canonicalHandleId: handleId,
              primaryDisplayLabel: handleValue,
              rawEndpoint: handleValue,
              statusLabel: 'Unfamiliar source',
              messageCount: 0,
            ),
          ),
        ],
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: HandleLensActionBar(handleId: handleId),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dismiss'));
    await tester.pumpAndSettle();

    expect(
      await overlayDb.getAllDismissedHandles(),
      contains(normalizeHandleIdentifier(handleValue)),
    );
    expect(await overlayDb.getHandleOverride(handleId), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
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
