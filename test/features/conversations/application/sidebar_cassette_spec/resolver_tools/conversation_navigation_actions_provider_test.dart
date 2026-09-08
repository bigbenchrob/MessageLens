import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart'
    show overlayDatabaseProvider;
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_flow_state_provider.dart';
import 'package:remember_this_text/features/conversations/application/contact_conversations/contact_conversation_navigation_actions_provider.dart';
import 'package:remember_this_text/features/conversations/application/sidebar_cassette_spec/resolver_tools/conversation_navigation_actions_provider.dart';
import 'package:remember_this_text/features/messages/application/message_evidence/message_evidence_spine_provider.dart';
import 'package:remember_this_text/features/messages/domain/message_evidence/message_evidence_scope.dart';
import 'package:remember_this_text/features/messages/domain/message_evidence/message_evidence_skeleton.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/sidebar_utilities_constants.dart';

void main() {
  late OverlayDatabase overlayDb;
  late ProviderContainer container;
  late Future<MessageEvidenceTimelineSkeleton> Function() skeletonLoader;

  setUp(() {
    overlayDb = OverlayDatabase(NativeDatabase.memory());
    skeletonLoader = () async => _conversationSkeleton;
    container = ProviderContainer(
      overrides: [
        overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
        messageEvidenceTimelineSkeletonProvider(
          scope: const ConversationEvidenceScope(conversationId: 8796093022216),
        ).overrideWith((ref) => skeletonLoader()),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await overlayDb.close();
  });

  test(
    'selectConversation dispatches conversation sidebar flow intent',
    () async {
      await container
          .read(conversationNavigationActionsProvider.notifier)
          .selectConversation(conversationId: 8796093022216);

      final flowState = container.read(sidebarFlowProvider);
      expect(flowState.topMenuChoice, TopChatMenuChoice.conversations);
      expect(flowState.selectedConversationId, 8796093022216);
      expect(flowState.chosenContactId, isNull);
    },
  );

  test(
    'main month navigation anchors the first message and preserves branch',
    () async {
      final actions = container.read(
        conversationNavigationActionsProvider.notifier,
      );
      await actions.selectConversation(conversationId: 8796093022216);

      await actions.selectConversationMonth(
        conversationId: 8796093022216,
        monthAnchor: DateTime(2026, 5),
      );

      final flowState = container.read(sidebarFlowProvider);
      expect(flowState.topMenuChoice, TopChatMenuChoice.conversations);
      expect(flowState.selectedConversationId, 8796093022216);
      expect(flowState.selectedConversationAnchorMessageId, 101);
    },
  );

  test('no-match month cannot fall through to the latest message', () async {
    final actions = container.read(
      conversationNavigationActionsProvider.notifier,
    );
    await actions.selectConversation(conversationId: 8796093022216);

    await actions.selectConversationMonth(
      conversationId: 8796093022216,
      monthAnchor: DateTime(2026, 4),
    );

    final flowState = container.read(sidebarFlowProvider);
    expect(flowState.selectedConversationId, 8796093022216);
    expect(flowState.selectedConversationAnchorMessageId, isNull);
  });

  test('stale month resolution cannot restore a previous selection', () async {
    final skeletonCompleter = Completer<MessageEvidenceTimelineSkeleton>();
    skeletonLoader = () => skeletonCompleter.future;
    final actions = container.read(
      conversationNavigationActionsProvider.notifier,
    );
    await actions.selectConversation(conversationId: 8796093022216);

    final pendingNavigation = actions.selectConversationMonth(
      conversationId: 8796093022216,
      monthAnchor: DateTime(2026, 5),
    );
    await Future<void>.delayed(Duration.zero);
    await actions.selectConversation(conversationId: 99);
    skeletonCompleter.complete(_conversationSkeleton);
    await pendingNavigation;

    final flowState = container.read(sidebarFlowProvider);
    expect(flowState.selectedConversationId, 99);
    expect(flowState.selectedConversationAnchorMessageId, isNull);
  });

  test(
    'selectContactConversation dispatches contact conversation flow intent',
    () async {
      await container
          .read(contactConversationNavigationActionsProvider.notifier)
          .selectContactConversation(
            contactId: 24,
            conversationId: 8796093022216,
          );

      final flowState = container.read(sidebarFlowProvider);
      expect(flowState.topMenuChoice, TopChatMenuChoice.contacts);
      expect(flowState.chosenContactId, 24);
      expect(flowState.selectedConversationId, 8796093022216);
      expect(
        flowState.contactProjection,
        SidebarFlowContactProjection.conversations,
      );
    },
  );

  test(
    'contact month navigation anchors the first message and preserves contact branch',
    () async {
      final actions = container.read(
        contactConversationNavigationActionsProvider.notifier,
      );
      await actions.selectContactConversation(
        contactId: 24,
        conversationId: 8796093022216,
      );

      await actions.selectContactConversationMonth(
        contactId: 24,
        conversationId: 8796093022216,
        monthAnchor: DateTime(2026, 5),
      );

      final flowState = container.read(sidebarFlowProvider);
      expect(flowState.topMenuChoice, TopChatMenuChoice.contacts);
      expect(flowState.chosenContactId, 24);
      expect(flowState.selectedConversationId, 8796093022216);
      expect(flowState.selectedConversationAnchorMessageId, 101);
      expect(
        flowState.contactProjection,
        SidebarFlowContactProjection.conversations,
      );
    },
  );
}

const _conversationSkeleton = MessageEvidenceTimelineSkeleton(
  entries: [
    MessageEvidenceSkeletonEntry(
      messageId: 101,
      dateUtc: '2026-05-01T10:00:00.000Z',
      monthKey: '2026-05',
    ),
    MessageEvidenceSkeletonEntry(
      messageId: 102,
      dateUtc: '2026-05-02T10:00:00.000Z',
      monthKey: '2026-05',
    ),
    MessageEvidenceSkeletonEntry(
      messageId: 201,
      dateUtc: '2026-06-01T10:00:00.000Z',
      monthKey: '2026-06',
    ),
  ],
);
