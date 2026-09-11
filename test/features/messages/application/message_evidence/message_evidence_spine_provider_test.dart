import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/contacts/contact_graph.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/contacts/contact_graph_provider.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation_reader.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation_reader_provider.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation_repository.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_graph_reader.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_graph_reader_provider.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/messages/message_graph_repository.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers/message_data_version_provider.dart';
import 'package:remember_this_text/essentials/search/application/graph_message_search.dart';
import 'package:remember_this_text/essentials/search/application/graph_search_repository_provider.dart';
import 'package:remember_this_text/essentials/search/application/message_text_search_query.dart';
import 'package:remember_this_text/features/contacts/application/display_identity/display_identity.dart';
import 'package:remember_this_text/features/contacts/application/display_identity/display_identity_resolver_provider.dart';
import 'package:remember_this_text/features/contacts/application/read_models/handles_for_contact_provider.dart';
import 'package:remember_this_text/features/contacts/application/read_models/linked_handle.dart';
import 'package:remember_this_text/features/conversations/feature_level_providers.dart'
    show
        ConversationSignatureDisplayByIdsRequest,
        ConversationSignatureDisplayModel,
        conversationSignatureDisplayByIdsProvider;
import 'package:remember_this_text/features/messages/application/message_evidence/message_evidence_spine_provider.dart';
import 'package:remember_this_text/features/messages/application/message_evidence/recovered_message_evidence_provider.dart';
import 'package:remember_this_text/features/messages/domain/entities/attachment_info.dart';
import 'package:remember_this_text/features/messages/domain/message_evidence/message_evidence_scope.dart';
import 'package:remember_this_text/features/messages/domain/message_evidence/message_evidence_search_mode.dart';
import 'package:remember_this_text/features/messages/domain/message_evidence/recovered_message_evidence.dart';

Override _displayIdentityResolverOverride() {
  return displayIdentityResolverProvider.overrideWith((ref) async {
    return const DisplayIdentityResolver(identitiesByHandleKey: {});
  });
}

Override _graphSearchRepositoryOverride({
  Map<String, List<int>> globalMatchesByQuery = const <String, List<int>>{},
  Map<String, List<int>> conversationMatchesByQuery =
      const <String, List<int>>{},
}) {
  return graphSearchRepositoryProvider.overrideWith((ref) async {
    return _FakeGraphSearchRepository(
      globalMatchesByQuery: globalMatchesByQuery,
      conversationMatchesByQuery: conversationMatchesByQuery,
    );
  });
}

void main() {
  test('text-match provider identity follows structured search intent', () {
    const scope = GlobalMessagesEvidenceScope();
    final prefix = messageEvidenceTextMatchIdsProvider(
      scope: scope,
      searchIntent: _intent('post'),
    );
    final exact = messageEvidenceTextMatchIdsProvider(
      scope: scope,
      searchIntent: _intent('post '),
    );
    final equivalentExact = messageEvidenceTextMatchIdsProvider(
      scope: scope,
      searchIntent: _intent('  post   '),
    );

    expect(prefix, isNot(exact));
    expect(exact, equivalentExact);
    expect(exact.hashCode, equivalentExact.hashCode);
  });

  test(
    'contact evidence skeleton preserves full graph timeline entries',
    () async {
      final container = ProviderContainer(
        overrides: [
          _displayIdentityResolverOverride(),
          contactPageGraphMessageTimelineProvider(contactId: 24).overrideWith((
            ref,
          ) async {
            return const [
              ContactGraphMessageTimelineEntry(
                messageId: 1,
                dateUtc: '2026-04-20T10:00:00.000Z',
                monthKey: '2026-04',
              ),
              ContactGraphMessageTimelineEntry(
                messageId: 2,
                dateUtc: '2026-05-20T10:00:00.000Z',
                monthKey: '2026-05',
              ),
            ];
          }),
        ],
      );
      addTearDown(container.dispose);

      final skeleton = await container.read(
        messageEvidenceTimelineSkeletonProvider(
          scope: const ContactAllMessagesEvidenceScope(contactId: 24),
        ).future,
      );

      expect(skeleton.totalCount, 2);
      expect(skeleton.entries.map((entry) => entry.messageId), [1, 2]);
      expect(skeleton.entries.map((entry) => entry.monthKey), [
        '2026-04',
        '2026-05',
      ]);
      expect(skeleton.latestIndex(), 1);
      expect(skeleton.indexForMonth(DateTime(2026, 4)), 0);
    },
  );

  test(
    'contact evidence skeleton refreshes when message data version changes',
    () async {
      var includeNewMessage = false;
      final container = ProviderContainer(
        overrides: [
          _displayIdentityResolverOverride(),
          contactPageGraphMessageTimelineProvider(contactId: 24).overrideWith((
            ref,
          ) async {
            ref.watch(messageDataVersionProvider);
            return [
              const ContactGraphMessageTimelineEntry(
                messageId: 1,
                dateUtc: '2026-04-20T10:00:00.000Z',
                monthKey: '2026-04',
              ),
              if (includeNewMessage)
                const ContactGraphMessageTimelineEntry(
                  messageId: 2,
                  dateUtc: '2026-05-20T10:00:00.000Z',
                  monthKey: '2026-05',
                ),
            ];
          }),
        ],
      );
      addTearDown(container.dispose);

      const scope = ContactAllMessagesEvidenceScope(contactId: 24);

      final initialSkeleton = await container.read(
        messageEvidenceTimelineSkeletonProvider(scope: scope).future,
      );
      expect(initialSkeleton.entries.map((entry) => entry.messageId), [1]);

      includeNewMessage = true;
      container.read(messageDataVersionProvider.notifier).bump();

      final refreshedSkeleton = await container.read(
        messageEvidenceTimelineSkeletonProvider(scope: scope).future,
      );
      expect(refreshedSkeleton.entries.map((entry) => entry.messageId), [1, 2]);
    },
  );

  test('retains prepared contact evidence across category switches', () async {
    var timelineReadCount = 0;
    final container = ProviderContainer(
      overrides: [
        _displayIdentityResolverOverride(),
        contactPageGraphMessageTimelineProvider(contactId: 24).overrideWith((
          ref,
        ) async {
          ref.watch(messageDataVersionProvider);
          timelineReadCount += 1;
          return const [
            ContactGraphMessageTimelineEntry(
              messageId: 1,
              dateUtc: '2026-04-20T10:00:00.000Z',
              monthKey: '2026-04',
            ),
          ];
        }),
      ],
    );
    addTearDown(container.dispose);

    const scope = ContactAllMessagesEvidenceScope(contactId: 24);
    final firstSubscription = container.listen(
      messageEvidenceTimelineSkeletonProvider(scope: scope),
      (_, __) {},
    );
    await container.read(
      messageEvidenceTimelineSkeletonProvider(scope: scope).future,
    );
    firstSubscription.close();
    await Future<void>.delayed(Duration.zero);

    final secondSubscription = container.listen(
      messageEvidenceTimelineSkeletonProvider(scope: scope),
      (_, __) {},
    );
    await container.read(
      messageEvidenceTimelineSkeletonProvider(scope: scope).future,
    );
    expect(timelineReadCount, 1);

    container.read(messageDataVersionProvider.notifier).bump();
    await container.read(
      messageEvidenceTimelineSkeletonProvider(scope: scope).future,
    );
    expect(timelineReadCount, 2);
    secondSubscription.close();
  });

  test(
    'contact evidence row stays hydrated when message data version changes',
    () async {
      var lookupCount = 0;
      var text = 'already hydrated';
      final container = ProviderContainer(
        overrides: [
          _displayIdentityResolverOverride(),
          contactPageGraphMessageByIdProvider(
            contactId: 24,
            messageId: 1,
          ).overrideWith((ref) async {
            lookupCount += 1;
            return ConversationMessage(
              messageId: 1,
              dateUtc: '2026-04-20T10:00:00.000Z',
              isFromMe: false,
              text: text,
              associatedMessageId: null,
              attachmentCount: 0,
            );
          }),
        ],
      );
      addTearDown(container.dispose);

      const scope = ContactAllMessagesEvidenceScope(contactId: 24);

      final initialRow = await container.read(
        messageEvidenceRowProvider(scope: scope, messageId: 1).future,
      );
      expect(initialRow?.text, 'already hydrated');
      expect(lookupCount, 1);

      text = 'would require explicit row invalidation';
      container.read(messageDataVersionProvider.notifier).bump();

      final preservedRow = await container.read(
        messageEvidenceRowProvider(scope: scope, messageId: 1).future,
      );
      expect(preservedRow?.text, 'already hydrated');
      expect(lookupCount, 1);
    },
  );

  test(
    'contact handle evidence skeleton preserves filtered graph timeline entries',
    () async {
      const scope = ContactHandleMessagesEvidenceScope(
        contactId: 24,
        handleId: 12,
      );
      final container = ProviderContainer(
        overrides: [
          _displayIdentityResolverOverride(),
          contactPageGraphHandleMessageTimelineProvider(
            contactId: 24,
            handleId: 12,
          ).overrideWith((ref) async {
            return const [
              ContactGraphMessageTimelineEntry(
                messageId: 7,
                dateUtc: '2026-05-20T10:00:00.000Z',
                monthKey: '2026-05',
              ),
            ];
          }),
          contactPageGraphHandleMessageByIdProvider(
            contactId: 24,
            handleId: 12,
            messageId: 7,
          ).overrideWith((ref) async {
            return const ConversationMessage(
              messageId: 7,
              dateUtc: '2026-05-20T10:00:00.000Z',
              isFromMe: false,
              text: 'filtered handle row',
              associatedMessageId: null,
              attachmentCount: 0,
            );
          }),
        ],
      );
      addTearDown(container.dispose);

      final skeleton = await container.read(
        messageEvidenceTimelineSkeletonProvider(scope: scope).future,
      );
      final message = await container.read(
        messageEvidenceRowProvider(scope: scope, messageId: 7).future,
      );

      expect(skeleton.entries.map((entry) => entry.messageId), [7]);
      expect(message?.text, 'filtered handle row');
    },
  );

  test(
    'contact search evidence scope filters the full contact skeleton',
    () async {
      const scope = ContactMessageSearchEvidenceScope(
        contactId: 24,
        query: 'settlement',
      );
      final container = ProviderContainer(
        overrides: [
          _displayIdentityResolverOverride(),
          _graphSearchRepositoryOverride(
            globalMatchesByQuery: const {
              'settlement': [2],
            },
          ),
          handlesForContactProvider(contactId: 24).overrideWith((ref) async {
            return const [
              LinkedHandle(
                handleId: 12,
                displayValue: 'claire@example.com',
                service: 'iMessage',
                isOverrideLink: false,
              ),
            ];
          }),
          contactPageGraphMessageTimelineProvider(contactId: 24).overrideWith((
            ref,
          ) async {
            return const [
              ContactGraphMessageTimelineEntry(
                messageId: 1,
                dateUtc: '2026-04-20T10:00:00.000Z',
                monthKey: '2026-04',
              ),
              ContactGraphMessageTimelineEntry(
                messageId: 2,
                dateUtc: '2026-05-20T10:00:00.000Z',
                monthKey: '2026-05',
              ),
            ];
          }),
          contactPageGraphMessageByIdProvider(
            contactId: 24,
            messageId: 2,
          ).overrideWith((ref) async {
            return const ConversationMessage(
              messageId: 2,
              dateUtc: '2026-05-20T10:00:00.000Z',
              isFromMe: false,
              text: 'settlement row',
              associatedMessageId: null,
              attachmentCount: 0,
            );
          }),
        ],
      );
      addTearDown(container.dispose);

      final skeleton = await container.read(
        messageEvidenceTimelineSkeletonProvider(scope: scope).future,
      );
      final message = await container.read(
        messageEvidenceRowProvider(scope: scope, messageId: 2).future,
      );

      expect(skeleton.entries.map((entry) => entry.messageId), [2]);
      expect(message?.text, 'settlement row');
    },
  );

  test('global evidence scope exposes skeleton and row hydration', () async {
    const scope = GlobalMessagesEvidenceScope();
    const hydratedMessage = ConversationMessage(
      messageId: 11,
      dateUtc: '2026-05-20T10:00:00.000Z',
      isFromMe: true,
      text: 'global row',
      associatedMessageId: null,
      attachmentCount: 0,
    );
    const repository = _FakeMessageGraphRepository(
      timeline: [
        ConversationMessageTimelineEntry(
          messageId: 11,
          dateUtc: '2026-05-20T10:00:00.000Z',
          monthKey: '2026-05',
        ),
      ],
      hydratedMessage: hydratedMessage,
    );
    final container = ProviderContainer(
      overrides: [
        _displayIdentityResolverOverride(),
        messageGraphReaderProvider.overrideWith((ref) async {
          return const MessageGraphReader(repository: repository);
        }),
      ],
    );
    addTearDown(container.dispose);

    final skeleton = await container.read(
      messageEvidenceTimelineSkeletonProvider(scope: scope).future,
    );
    final message = await container.read(
      messageEvidenceRowProvider(scope: scope, messageId: 11).future,
    );

    expect(skeleton.entries.map((entry) => entry.messageId), [11]);
    expect(message?.messageId, hydratedMessage.messageId);
    expect(message?.text, hydratedMessage.text);
  });

  test('graph evidence carries canonical Conversation identity', () async {
    const scope = GlobalMessagesEvidenceScope();
    const hydratedMessage = ConversationMessage(
      messageId: 12,
      dateUtc: '2026-05-20T10:00:00.000Z',
      isFromMe: true,
      text: 'outgoing row',
      associatedMessageId: null,
      attachmentCount: 0,
      conversationId: 7,
    );
    const repository = _FakeMessageGraphRepository(
      timeline: [],
      hydratedMessage: hydratedMessage,
    );
    final request = ConversationSignatureDisplayByIdsRequest(
      conversationIds: const [7],
    );
    final container = ProviderContainer(
      overrides: [
        _displayIdentityResolverOverride(),
        messageGraphReaderProvider.overrideWith((ref) async {
          return const MessageGraphReader(repository: repository);
        }),
        conversationSignatureDisplayByIdsProvider(
          request: request,
        ).overrideWith((ref) async {
          return const [
            ConversationSignatureDisplayModel(
              conversationId: 7,
              title: 'Claire',
              participantLabels: ['Claire'],
              participantCount: 1,
              isGroup: false,
              isSelfConversation: true,
              messageCount: 1,
              attachmentCount: 0,
              firstMessageAtUtc: '2026-05-20T10:00:00.000Z',
              lastMessageAtUtc: '2026-05-20T10:00:00.000Z',
              lastMessageText: 'outgoing row',
              activityMonths: [],
            ),
          ];
        }),
      ],
    );
    addTearDown(container.dispose);

    final message = await container.read(
      messageEvidenceRowProvider(scope: scope, messageId: 12).future,
    );

    expect(message?.conversationDisplayTitle, 'Claire');
    expect(message?.isSelfConversation, isTrue);
  });

  test('global evidence scope exposes text match ids', () async {
    const scope = GlobalMessagesEvidenceScope();
    const repository = _FakeMessageGraphRepository(
      timeline: [],
      hydratedMessage: ConversationMessage(
        messageId: 11,
        dateUtc: '2026-05-20T10:00:00.000Z',
        isFromMe: true,
        text: 'global row',
        associatedMessageId: null,
        attachmentCount: 0,
      ),
      globalMatchesByQuery: {
        'settlement': [11, 12],
      },
    );
    final container = ProviderContainer(
      overrides: [
        _displayIdentityResolverOverride(),
        _graphSearchRepositoryOverride(
          globalMatchesByQuery: const {
            'settlement': [11, 12],
          },
        ),
        messageGraphReaderProvider.overrideWith((ref) async {
          return const MessageGraphReader(repository: repository);
        }),
      ],
    );
    addTearDown(container.dispose);

    final matches = await container.read(
      messageEvidenceTextMatchIdsProvider(
        scope: scope,
        searchIntent: _intent('settlement'),
      ).future,
    );
    final emptyMatches = await container.read(
      messageEvidenceTextMatchIdsProvider(
        scope: scope,
        searchIntent: _intent('  '),
      ).future,
    );

    expect(matches, [11, 12]);
    expect(emptyMatches, isEmpty);
  });

  test(
    'message search evidence scope exposes matching skeleton rows',
    () async {
      const scope = MessageSearchEvidenceScope(query: 'settlement');
      const repository = _FakeMessageGraphRepository(
        timeline: [
          ConversationMessageTimelineEntry(
            messageId: 10,
            dateUtc: '2026-05-19T10:00:00.000Z',
            monthKey: '2026-05',
          ),
          ConversationMessageTimelineEntry(
            messageId: 11,
            dateUtc: '2026-05-20T10:00:00.000Z',
            monthKey: '2026-05',
          ),
        ],
        hydratedMessage: ConversationMessage(
          messageId: 11,
          dateUtc: '2026-05-20T10:00:00.000Z',
          isFromMe: true,
          text: 'settlement row',
          associatedMessageId: null,
          attachmentCount: 0,
        ),
        globalMatchesByQuery: {
          'settlement': [11],
        },
      );
      final container = ProviderContainer(
        overrides: [
          _displayIdentityResolverOverride(),
          _graphSearchRepositoryOverride(
            globalMatchesByQuery: const {
              'settlement': [11],
            },
          ),
          messageGraphReaderProvider.overrideWith((ref) async {
            return const MessageGraphReader(repository: repository);
          }),
        ],
      );
      addTearDown(container.dispose);

      final skeleton = await container.read(
        messageEvidenceTimelineSkeletonProvider(scope: scope).future,
      );
      final message = await container.read(
        messageEvidenceRowProvider(scope: scope, messageId: 11).future,
      );

      expect(skeleton.entries.map((entry) => entry.messageId), [11]);
      expect(message?.text, 'settlement row');
    },
  );

  test('handle evidence scope exposes skeleton and row hydration', () async {
    const scope = HandleMessagesEvidenceScope(handleId: 12);
    const hydratedMessage = ConversationMessage(
      messageId: 21,
      dateUtc: '2026-05-20T10:00:00.000Z',
      isFromMe: false,
      text: 'handle row',
      associatedMessageId: null,
      attachmentCount: 0,
    );
    const repository = _FakeMessageGraphRepository(
      timeline: [],
      hydratedMessage: hydratedMessage,
      handleTimeline: [
        ConversationMessageTimelineEntry(
          messageId: 21,
          dateUtc: '2026-05-20T10:00:00.000Z',
          monthKey: '2026-05',
        ),
      ],
    );
    final container = ProviderContainer(
      overrides: [
        _displayIdentityResolverOverride(),
        messageGraphReaderProvider.overrideWith((ref) async {
          return const MessageGraphReader(repository: repository);
        }),
      ],
    );
    addTearDown(container.dispose);

    final skeleton = await container.read(
      messageEvidenceTimelineSkeletonProvider(scope: scope).future,
    );
    final message = await container.read(
      messageEvidenceRowProvider(scope: scope, messageId: 21).future,
    );

    expect(skeleton.entries.map((entry) => entry.messageId), [21]);
    expect(message?.messageId, hydratedMessage.messageId);
    expect(message?.text, hydratedMessage.text);
  });

  test(
    'conversation excerpt scope exposes bounded evidence skeleton',
    () async {
      const scope = ConversationExcerptEvidenceScope(
        conversationId: 7,
        anchorMessageId: 11,
        beforeCount: 1,
        afterCount: 1,
      );
      const repository = _FakeMessageGraphRepository(
        timeline: [],
        hydratedMessage: ConversationMessage(
          messageId: 11,
          dateUtc: '2026-05-20T10:00:00.000Z',
          isFromMe: false,
          text: 'context row',
          associatedMessageId: null,
          attachmentCount: 0,
        ),
        contextTimeline: [
          ConversationMessageTimelineEntry(
            messageId: 10,
            dateUtc: '2026-05-19T10:00:00.000Z',
            monthKey: '2026-05',
          ),
          ConversationMessageTimelineEntry(
            messageId: 11,
            dateUtc: '2026-05-20T10:00:00.000Z',
            monthKey: '2026-05',
          ),
        ],
      );
      final container = ProviderContainer(
        overrides: [
          _displayIdentityResolverOverride(),
          _graphSearchRepositoryOverride(
            globalMatchesByQuery: const {
              'context': [9, 11, 12],
            },
          ),
          messageGraphReaderProvider.overrideWith((ref) async {
            return const MessageGraphReader(repository: repository);
          }),
        ],
      );
      addTearDown(container.dispose);

      final skeleton = await container.read(
        messageEvidenceTimelineSkeletonProvider(scope: scope).future,
      );
      final message = await container.read(
        messageEvidenceRowProvider(scope: scope, messageId: 11).future,
      );
      final matches = await container.read(
        messageEvidenceTextMatchIdsProvider(
          scope: scope,
          searchIntent: _intent('context'),
        ).future,
      );

      expect(skeleton.entries.map((entry) => entry.messageId), [10, 11]);
      expect(skeleton.initialAnchorMessageId, 11);
      expect(message?.text, 'context row');
      expect(matches, [11]);
    },
  );

  test(
    'recovered evidence scope exposes skeleton rows and attachments',
    () async {
      const scope = RecoveredMessagesEvidenceScope(
        contactId: 7,
        onlyNoHandleFromMe: false,
      );
      final container = ProviderContainer(
        overrides: [
          _displayIdentityResolverOverride(),
          recoveredUnlinkedMessagesProvider(contactId: 7).overrideWith((ref) {
            return Stream<List<RecoveredUnlinkedMessageItem>>.value([
              RecoveredUnlinkedMessageItem(
                id: 30,
                guid: 'recovered-30',
                senderHandleId: null,
                contactName: null,
                rawItemType: null,
                rawAssociatedMessageType: null,
                semanticKind: 'plain-text',
                isSparseArtifact: false,
                isFromMe: false,
                isInferred: false,
                senderLabel: 'Recovered sender',
                service: 'iMessage',
                text: 'recovered row',
                sentAt: DateTime.utc(2026, 5, 20, 10),
                itemType: 'text',
                hasAttachments: true,
                attachmentCount: 1,
                attachments: const [
                  AttachmentInfo(
                    id: 1001,
                    localPath: '/missing/recovered.jpg',
                    mimeType: 'image/jpeg',
                    transferName: 'recovered.jpg',
                  ),
                ],
              ),
            ]);
          }),
        ],
      );
      final subscription = container.listen(
        recoveredUnlinkedMessagesProvider(contactId: 7),
        (_, _) {},
      );
      final skeletonSubscription = container.listen(
        messageEvidenceTimelineSkeletonProvider(scope: scope),
        (_, _) {},
      );
      addTearDown(subscription.close);
      addTearDown(skeletonSubscription.close);
      addTearDown(container.dispose);

      final skeleton = await container.read(
        messageEvidenceTimelineSkeletonProvider(scope: scope).future,
      );
      final message = await container.read(
        messageEvidenceRowProvider(scope: scope, messageId: 30).future,
      );
      final attachments = await container.read(
        messageEvidenceAttachmentsProvider(scope: scope, messageId: 30).future,
      );

      expect(skeleton.entries.map((entry) => entry.messageId), [30]);
      expect(skeleton.entries.single.monthKey, '2026-05');
      expect(message?.text, 'recovered row');
      expect(message?.senderDisplayHandle, 'Recovered sender');
      expect(attachments.single.displayName, 'recovered.jpg');
    },
  );

  test('recovered evidence scope exposes text match ids', () async {
    const scope = RecoveredMessagesEvidenceScope(
      contactId: 7,
      onlyNoHandleFromMe: false,
    );
    final container = ProviderContainer(
      overrides: [
        _displayIdentityResolverOverride(),
        recoveredUnlinkedMessagesProvider(contactId: 7).overrideWith((ref) {
          return Stream<List<RecoveredUnlinkedMessageItem>>.value([
            RecoveredUnlinkedMessageItem(
              id: 30,
              guid: 'recovered-30',
              senderHandleId: null,
              contactName: null,
              rawItemType: null,
              rawAssociatedMessageType: null,
              semanticKind: 'plain-text',
              isSparseArtifact: false,
              isFromMe: false,
              isInferred: false,
              senderLabel: 'Recovered sender',
              service: 'iMessage',
              text: 'invoice receipt',
              sentAt: DateTime.utc(2026, 5, 20, 10),
              itemType: 'text',
              hasAttachments: false,
              attachmentCount: 0,
              attachments: const <AttachmentInfo>[],
            ),
            RecoveredUnlinkedMessageItem(
              id: 40,
              guid: 'recovered-40',
              senderHandleId: null,
              contactName: null,
              rawItemType: null,
              rawAssociatedMessageType: null,
              semanticKind: 'plain-text',
              isSparseArtifact: false,
              isFromMe: false,
              isInferred: false,
              senderLabel: 'Other sender',
              service: 'SMS',
              text: 'unrelated note',
              sentAt: DateTime.utc(2026, 5, 21, 10),
              itemType: 'text',
              hasAttachments: false,
              attachmentCount: 0,
              attachments: const <AttachmentInfo>[],
            ),
            RecoveredUnlinkedMessageItem(
              id: 50,
              guid: 'recovered-50',
              senderHandleId: null,
              contactName: null,
              rawItemType: null,
              rawAssociatedMessageType: null,
              semanticKind: 'plain-text',
              isSparseArtifact: false,
              isFromMe: false,
              isInferred: false,
              senderLabel: 'Other sender',
              service: 'SMS',
              text: 'invoiced yesterday',
              sentAt: DateTime.utc(2026, 5, 22, 10),
              itemType: 'text',
              hasAttachments: false,
              attachmentCount: 0,
              attachments: const <AttachmentInfo>[],
            ),
          ]);
        }),
      ],
    );
    final subscription = container.listen(
      recoveredUnlinkedMessagesProvider(contactId: 7),
      (_, _) {},
    );
    final matchesSubscription = container.listen(
      messageEvidenceTextMatchIdsProvider(
        scope: scope,
        searchIntent: _intent('invoice'),
      ),
      (_, _) {},
    );
    addTearDown(subscription.close);
    addTearDown(matchesSubscription.close);
    addTearDown(container.dispose);

    final matches = await container.read(
      messageEvidenceTextMatchIdsProvider(
        scope: scope,
        searchIntent: _intent('invoice'),
      ).future,
    );
    final exactMatches = await container.read(
      messageEvidenceTextMatchIdsProvider(
        scope: scope,
        searchIntent: _intent('invoice '),
      ).future,
    );
    final allTermMatches = await container.read(
      messageEvidenceTextMatchIdsProvider(
        scope: scope,
        searchIntent: _intent('invoice note '),
        mode: MessageEvidenceSearchMode.allTerms,
      ).future,
    );
    final anyTermMatches = await container.read(
      messageEvidenceTextMatchIdsProvider(
        scope: scope,
        searchIntent: _intent('invoice note '),
        mode: MessageEvidenceSearchMode.anyTerm,
      ).future,
    );

    expect(matches, [30, 50]);
    expect(exactMatches, [30]);
    expect(allTermMatches, isEmpty);
    expect(anyTermMatches, [30, 40]);
  });

  test(
    'conversation evidence scope exposes skeleton and row hydration',
    () async {
      const scope = ConversationEvidenceScope(conversationId: 7);
      const hydratedMessage = ConversationMessage(
        messageId: 2,
        dateUtc: '2026-05-20T10:00:00.000Z',
        isFromMe: true,
        text: 'conversation row',
        associatedMessageId: null,
        attachmentCount: 0,
      );
      const repository = _FakeConversationRepository(
        timeline: [
          ConversationMessageTimelineEntry(
            messageId: 1,
            dateUtc: '2026-04-20T10:00:00.000Z',
            monthKey: '2026-04',
          ),
          ConversationMessageTimelineEntry(
            messageId: 2,
            dateUtc: '2026-05-20T10:00:00.000Z',
            monthKey: '2026-05',
          ),
        ],
        hydratedMessage: hydratedMessage,
      );
      final container = ProviderContainer(
        overrides: [
          _displayIdentityResolverOverride(),
          conversationReaderProvider.overrideWith((ref) async {
            return const ConversationReader(repository: repository);
          }),
        ],
      );
      addTearDown(container.dispose);

      final skeleton = await container.read(
        messageEvidenceTimelineSkeletonProvider(scope: scope).future,
      );
      final message = await container.read(
        messageEvidenceRowProvider(scope: scope, messageId: 2).future,
      );

      expect(skeleton.entries.map((entry) => entry.messageId), [1, 2]);
      expect(skeleton.latestIndex(), 1);
      expect(message?.messageId, hydratedMessage.messageId);
      expect(message?.text, hydratedMessage.text);
    },
  );

  test(
    'conversation evidence scope exposes full-scope text match ids',
    () async {
      const scope = ConversationEvidenceScope(conversationId: 7);
      const repository = _FakeConversationRepository(
        timeline: [],
        hydratedMessage: ConversationMessage(
          messageId: 1,
          dateUtc: null,
          isFromMe: false,
          text: null,
          associatedMessageId: null,
          attachmentCount: 0,
        ),
      );
      final container = ProviderContainer(
        overrides: [
          _displayIdentityResolverOverride(),
          _graphSearchRepositoryOverride(
            conversationMatchesByQuery: const {
              'settlement': [1, 2],
            },
          ),
          conversationReaderProvider.overrideWith((ref) async {
            return const ConversationReader(repository: repository);
          }),
        ],
      );
      addTearDown(container.dispose);

      final matches = await container.read(
        messageEvidenceTextMatchIdsProvider(
          scope: scope,
          searchIntent: _intent('settlement'),
        ).future,
      );
      final emptyMatches = await container.read(
        messageEvidenceTextMatchIdsProvider(
          scope: scope,
          searchIntent: _intent('  '),
        ).future,
      );

      expect(matches, [1, 2]);
      expect(emptyMatches, isEmpty);
    },
  );
}

MessageTextSearchExecutionIntent _intent(String rawInput) {
  return MessageTextSearchQuery.parse(rawInput).executionIntent;
}

class _FakeGraphSearchRepository implements GraphSearchRepository {
  const _FakeGraphSearchRepository({
    required this.globalMatchesByQuery,
    required this.conversationMatchesByQuery,
  });

  final Map<String, List<int>> globalMatchesByQuery;
  final Map<String, List<int>> conversationMatchesByQuery;

  @override
  Future<List<int>> searchMessageIds({
    required GraphMessageSearchScope scope,
    required List<MessageTextSearchToken> textTokens,
    required bool matchAnyTerm,
    required bool filterSaved,
    int limit = graphSearchResultLimit,
  }) async {
    final query = textTokens.map((token) => token.normalizedText).join(' ');
    return switch (scope.type) {
      GraphMessageSearchScopeType.global =>
        globalMatchesByQuery[query] ?? const <int>[],
      GraphMessageSearchScopeType.conversation =>
        conversationMatchesByQuery[query] ?? const <int>[],
      GraphMessageSearchScopeType.contact =>
        globalMatchesByQuery[query] ?? const <int>[],
      GraphMessageSearchScopeType.handle => const <int>[],
    };
  }
}

class _FakeMessageGraphRepository implements MessageGraphRepository {
  const _FakeMessageGraphRepository({
    required this.timeline,
    required this.hydratedMessage,
    this.handleTimeline = const <ConversationMessageTimelineEntry>[],
    this.contextTimeline = const <ConversationMessageTimelineEntry>[],
    this.globalMatchesByQuery = const <String, List<int>>{},
  });

  final List<ConversationMessageTimelineEntry> timeline;
  final ConversationMessage hydratedMessage;
  final List<ConversationMessageTimelineEntry> handleTimeline;
  final List<ConversationMessageTimelineEntry> contextTimeline;
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
    return hydratedMessage.messageId == messageId ? hydratedMessage : null;
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
    return handleTimeline;
  }

  @override
  Future<ConversationMessage?> readHandleMessageById({
    required int handleId,
    required int messageId,
  }) async {
    return hydratedMessage.messageId == messageId ? hydratedMessage : null;
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
    return contextTimeline;
  }
}

class _FakeConversationRepository implements ConversationRepository {
  const _FakeConversationRepository({
    required this.timeline,
    required this.hydratedMessage,
  });

  final List<ConversationMessageTimelineEntry> timeline;
  final ConversationMessage hydratedMessage;

  @override
  Future<List<ConversationMessageTimelineEntry>> readMessageTimeline({
    required int conversationId,
  }) async {
    return timeline;
  }

  @override
  Future<ConversationMessage?> readMessageById({
    required int conversationId,
    required int messageId,
  }) async {
    return hydratedMessage.messageId == messageId ? hydratedMessage : null;
  }

  @override
  Future<List<int>> readMessageIdsMatchingText({
    required int conversationId,
    required String query,
    bool matchAnyTerm = false,
  }) async {
    if (query == 'settlement') {
      return const [1, 2];
    }
    return const <int>[];
  }

  @override
  Future<List<ConversationMessage>> readMessages({
    required int conversationId,
    int limit = 100,
  }) {
    throw UnsupportedError(
      '_FakeConversationRepository.readMessages is not used by these tests.',
    );
  }

  @override
  Future<List<ConversationOverview>> readOverviews({int limit = 100}) {
    throw UnsupportedError(
      '_FakeConversationRepository.readOverviews is not used by these tests.',
    );
  }

  @override
  Future<List<ConversationOverview>> readOverviewsByIds({
    required List<int> conversationIds,
  }) {
    throw UnsupportedError(
      '_FakeConversationRepository.readOverviewsByIds is not used by these tests.',
    );
  }

  @override
  Future<Map<int, ConversationActivityTrace>> readActivityTraces({
    required List<int> conversationIds,
  }) {
    throw UnsupportedError(
      '_FakeConversationRepository.readActivityTraces is not used by these tests.',
    );
  }

  @override
  Future<Map<int, ConversationMessageTextMatch>>
  readConversationMessageTextMatches({
    required String query,
    int limit = 500,
    int snippetsPerConversation = 3,
  }) {
    throw UnsupportedError(
      '_FakeConversationRepository.readConversationMessageTextMatches is not used by these tests.',
    );
  }
}
