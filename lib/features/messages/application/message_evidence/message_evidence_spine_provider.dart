import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/util/date_label_formatter.dart';
import '../../../../essentials/conversation_graph/application/conversations/conversation.dart';
import '../../../../essentials/conversation_graph/feature_level_providers.dart'
    show
        contactPageGraphHandleMessageByIdProvider,
        contactPageGraphHandleMessagesProvider,
        contactPageGraphHandleMessageTimelineProvider,
        contactPageGraphMessageByIdProvider,
        contactPageGraphMessagesProvider,
        contactPageGraphMessageTimelineProvider,
        conversationReaderProvider,
        messageAttachmentsProvider,
        messageGraphReaderProvider;
import '../../../../essentials/db/feature_level_providers/message_data_version_provider.dart'
    show messageDataVersionProvider;
import '../../../../essentials/search/application/graph_message_search.dart';
import '../../../../essentials/search/application/message_text_search_matching.dart';
import '../../../../essentials/search/application/message_text_search_query.dart';
import '../../../../essentials/search/application/search_service.dart';
import '../../../../essentials/search/feature_level_providers.dart'
    show searchServiceProvider;
import '../../../attachments/feature_level_providers.dart'
    show attachmentFileAccessProvider;
import '../../../contacts/feature_level_providers.dart'
    show
        DisplayIdentityResolver,
        displayIdentityResolverProvider,
        handlesForContactProvider;
import '../../../conversations/feature_level_providers.dart'
    show
        ConversationSignatureDisplayByIdsRequest,
        conversationSignatureDisplayByIdsProvider;
import '../../domain/message_evidence/message_evidence_row_data.dart';
import '../../domain/message_evidence/message_evidence_scope.dart';
import '../../domain/message_evidence/message_evidence_search_mode.dart';
import '../../domain/message_evidence/message_evidence_skeleton.dart';
import '../../domain/message_evidence/recovered_message_evidence.dart';
import 'contact_evidence_cache_policy.dart';
import 'message_attachment_evidence.dart';
import 'recovered_message_evidence_provider.dart';

part 'message_evidence_spine_provider.g.dart';

@riverpod
Future<MessageEvidenceTimelineSkeleton> messageEvidenceTimelineSkeleton(
  Ref ref, {
  required MessageEvidenceScope scope,
}) async {
  ref.watch(messageDataVersionProvider);
  if (scope is ContactAllMessagesEvidenceScope ||
      scope is ContactHandleMessagesEvidenceScope) {
    retainPreparedContactEvidence(ref);
  }

  return switch (scope) {
    ContactAllMessagesEvidenceScope(:final contactId) =>
      _contactAllMessagesTimelineSkeleton(ref, contactId: contactId),
    ContactHandleMessagesEvidenceScope(:final contactId, :final handleId) =>
      _contactHandleMessagesTimelineSkeleton(
        ref,
        contactId: contactId,
        handleId: handleId,
      ),
    ContactMessageSearchEvidenceScope(
      :final contactId,
      :final query,
      :final handleId,
    ) =>
      _contactMessageSearchTimelineSkeleton(
        ref,
        contactId: contactId,
        query: query,
        handleId: handleId,
      ),
    GlobalMessagesEvidenceScope() => _globalMessagesTimelineSkeleton(ref),
    MessageSearchEvidenceScope(:final query, :final mode) =>
      _globalMessageSearchTimelineSkeleton(ref, query: query, mode: mode),
    HandleMessagesEvidenceScope(:final handleId) =>
      _handleMessagesTimelineSkeleton(ref, handleId: handleId),
    ConversationEvidenceScope(:final conversationId) =>
      _conversationTimelineSkeleton(ref, conversationId: conversationId),
    ConversationExcerptEvidenceScope(
      :final conversationId,
      :final anchorMessageId,
      :final beforeCount,
      :final afterCount,
    ) =>
      _conversationExcerptSkeleton(
        ref,
        conversationId: conversationId,
        anchorMessageId: anchorMessageId,
        beforeCount: beforeCount,
        afterCount: afterCount,
      ),
    RecoveredMessagesEvidenceScope(
      :final contactId,
      :final onlyNoHandleFromMe,
    ) =>
      _recoveredMessagesTimelineSkeleton(
        ref,
        contactId: contactId,
        onlyNoHandleFromMe: onlyNoHandleFromMe,
      ),
  };
}

@riverpod
Future<MessageEvidenceRowData?> messageEvidenceRow(
  Ref ref, {
  required MessageEvidenceScope scope,
  required int messageId,
}) async {
  _keepHydratedEvidenceAliveBriefly(ref);

  final message = await switch (scope) {
    ContactAllMessagesEvidenceScope(:final contactId) => ref.watch(
      contactPageGraphMessageByIdProvider(
        contactId: contactId,
        messageId: messageId,
      ).future,
    ),
    ContactHandleMessagesEvidenceScope(:final contactId, :final handleId) =>
      ref.watch(
        contactPageGraphHandleMessageByIdProvider(
          contactId: contactId,
          handleId: handleId,
          messageId: messageId,
        ).future,
      ),
    ContactMessageSearchEvidenceScope(:final contactId, :final handleId) =>
      handleId == null
          ? ref.watch(
              contactPageGraphMessageByIdProvider(
                contactId: contactId,
                messageId: messageId,
              ).future,
            )
          : ref.watch(
              contactPageGraphHandleMessageByIdProvider(
                contactId: contactId,
                handleId: handleId,
                messageId: messageId,
              ).future,
            ),
    MessageSearchEvidenceScope() || GlobalMessagesEvidenceScope() =>
      _globalMessageById(ref, messageId: messageId),
    HandleMessagesEvidenceScope(:final handleId) => _handleMessageById(
      ref,
      handleId: handleId,
      messageId: messageId,
    ),
    ConversationEvidenceScope(:final conversationId) =>
      _conversationMessageById(
        ref,
        conversationId: conversationId,
        messageId: messageId,
      ),
    ConversationExcerptEvidenceScope() => _globalMessageById(
      ref,
      messageId: messageId,
    ),
    RecoveredMessagesEvidenceScope(
      :final contactId,
      :final onlyNoHandleFromMe,
    ) =>
      _recoveredMessageById(
        ref,
        contactId: contactId,
        onlyNoHandleFromMe: onlyNoHandleFromMe,
        messageId: messageId,
      ),
  };
  if (message == null) {
    return null;
  }
  if (scope is RecoveredMessagesEvidenceScope) {
    return _resolveRecoveredMessageSender(ref, message);
  }
  return _resolveGraphMessageSender(ref, message);
}

Future<MessageEvidenceRowData> _resolveRecoveredMessageSender(
  Ref ref,
  ConversationMessage message,
) async {
  final resolver = await ref.watch(displayIdentityResolverProvider.future);
  return _messageEvidenceRowDataFromGraphMessage(message, resolver);
}

Future<MessageEvidenceRowData> _resolveGraphMessageSender(
  Ref ref,
  ConversationMessage message,
) async {
  final resolver = await ref.watch(displayIdentityResolverProvider.future);
  final conversationIdentities = await _conversationEvidenceIdentities(ref, [
    message.conversationId,
  ]);
  final conversationIdentity = conversationIdentities[message.conversationId];
  return _messageEvidenceRowDataFromGraphMessage(
    message,
    resolver,
    conversationDisplayTitle: conversationIdentity?.title,
    isSelfConversation: conversationIdentity?.isSelfConversation ?? false,
  );
}

MessageEvidenceRowData _messageEvidenceRowDataFromGraphMessage(
  ConversationMessage message,
  DisplayIdentityResolver resolver, {
  String? conversationDisplayTitle,
  bool isSelfConversation = false,
}) {
  final rawHandleLabel =
      message.senderRawHandleLabel ?? message.senderDisplayHandle;
  final senderIdentity = resolver.resolveSender(
    isFromMe: message.isFromMe,
    senderCanonicalHandleId: message.senderCanonicalHandleId,
    senderHandleId: message.senderHandleId,
    rawHandleLabel: rawHandleLabel,
  );

  return MessageEvidenceRowData(
    messageId: message.messageId,
    dateUtc: message.dateUtc,
    isFromMe: message.isFromMe,
    text: message.text,
    associatedMessageId: message.associatedMessageId,
    attachmentCount: message.attachmentCount,
    sourceConversationId: message.conversationId,
    conversationDisplayTitle: conversationDisplayTitle,
    isSelfConversation: isSelfConversation,
    senderIsMe: senderIdentity.isSelf,
    senderHandleId: message.senderHandleId,
    senderCanonicalHandleId: message.senderCanonicalHandleId,
    senderDisplayHandle: senderIdentity.primaryLabel,
    senderRawHandleLabel: senderIdentity.rawHandleLabel,
    semanticKind: message.semanticKind,
    itemKind: message.itemKind,
    isSystemMessage: message.isSystemMessage,
    isSparseArtifact: message.isSparseArtifact,
    hasAttributedBodySource: message.hasAttributedBodySource,
    hasMessageSummaryInfo: message.hasMessageSummaryInfo,
    hasPayloadDataSource: message.hasPayloadDataSource,
    errorCode: message.errorCode,
  );
}

@riverpod
Future<List<MessageAttachmentEvidence>> messageEvidenceAttachments(
  Ref ref, {
  required MessageEvidenceScope scope,
  required int messageId,
}) async {
  _keepHydratedEvidenceAliveBriefly(ref);

  return switch (scope) {
    RecoveredMessagesEvidenceScope(
      :final contactId,
      :final onlyNoHandleFromMe,
    ) =>
      _recoveredMessageAttachments(
        ref,
        contactId: contactId,
        onlyNoHandleFromMe: onlyNoHandleFromMe,
        messageId: messageId,
      ),
    ContactAllMessagesEvidenceScope() ||
    ContactHandleMessagesEvidenceScope() ||
    ContactMessageSearchEvidenceScope() ||
    MessageSearchEvidenceScope() ||
    GlobalMessagesEvidenceScope() ||
    HandleMessagesEvidenceScope() ||
    ConversationEvidenceScope() ||
    ConversationExcerptEvidenceScope() => _messageAttachments(
      ref,
      messageId: messageId,
    ),
  };
}

@riverpod
Future<Map<int, MessageEvidenceRowData>> messageEvidenceInitialRows(
  Ref ref, {
  required MessageEvidenceScope scope,
  DateTime? monthAnchor,
  int hydrationLimit = 80,
}) async {
  ref.watch(messageDataVersionProvider);
  if (scope is ContactAllMessagesEvidenceScope ||
      scope is ContactHandleMessagesEvidenceScope) {
    retainPreparedContactEvidence(ref);
  }

  final messages = await switch (scope) {
    ContactAllMessagesEvidenceScope(:final contactId) => ref.watch(
      contactPageGraphMessagesProvider(
        contactId: contactId,
        limit: hydrationLimit,
        monthAnchor: monthAnchor,
      ).future,
    ),
    ContactHandleMessagesEvidenceScope(:final contactId, :final handleId) =>
      ref.watch(
        contactPageGraphHandleMessagesProvider(
          contactId: contactId,
          handleId: handleId,
          limit: hydrationLimit,
          monthAnchor: monthAnchor,
        ).future,
      ),
    _ => Future.value(const <ConversationMessage>[]),
  };

  final resolver = await ref.watch(displayIdentityResolverProvider.future);
  final conversationIdentities = await _conversationEvidenceIdentities(
    ref,
    messages.map((message) {
      return message.conversationId;
    }),
  );
  final rows = [
    for (final message in messages)
      _messageEvidenceRowDataFromGraphMessage(
        message,
        resolver,
        conversationDisplayTitle:
            conversationIdentities[message.conversationId]?.title,
        isSelfConversation:
            conversationIdentities[message.conversationId]
                ?.isSelfConversation ??
            false,
      ),
  ];
  return {for (final row in rows) row.messageId: row};
}

typedef _ConversationEvidenceIdentity = ({
  String title,
  bool isSelfConversation,
});

Future<Map<int, _ConversationEvidenceIdentity>> _conversationEvidenceIdentities(
  Ref ref,
  Iterable<int?> conversationIds,
) async {
  final ids = conversationIds.whereType<int>().toSet().toList()..sort();
  if (ids.isEmpty) {
    return const <int, _ConversationEvidenceIdentity>{};
  }

  final conversations = await ref.watch(
    conversationSignatureDisplayByIdsProvider(
      request: ConversationSignatureDisplayByIdsRequest(conversationIds: ids),
    ).future,
  );
  return {
    for (final conversation in conversations)
      conversation.conversationId: (
        title: conversation.title.trim(),
        isSelfConversation: conversation.isSelfConversation,
      ),
  };
}

void _keepHydratedEvidenceAliveBriefly(Ref ref) {
  final link = ref.keepAlive();
  Timer? timer;

  ref.onCancel(() {
    timer = Timer(const Duration(minutes: 2), link.close);
  });
  ref.onResume(() {
    timer?.cancel();
    timer = null;
  });
  ref.onDispose(() {
    timer?.cancel();
  });
}

@riverpod
Future<List<int>> messageEvidenceTextMatchIds(
  Ref ref, {
  required MessageEvidenceScope scope,
  required MessageTextSearchExecutionIntent searchIntent,
  MessageEvidenceSearchMode mode = MessageEvidenceSearchMode.allTerms,
}) async {
  ref.watch(messageDataVersionProvider);

  if (!searchIntent.isExecutable) {
    return const <int>[];
  }
  final matchAnyTerm = mode == MessageEvidenceSearchMode.anyTerm;

  return switch (scope) {
    ConversationEvidenceScope(:final conversationId) =>
      _conversationMessageIdsMatchingText(
        ref,
        conversationId: conversationId,
        searchIntent: searchIntent,
        matchAnyTerm: matchAnyTerm,
      ),
    GlobalMessagesEvidenceScope() => _globalMessageIdsMatchingText(
      ref,
      searchIntent: searchIntent,
      matchAnyTerm: matchAnyTerm,
    ),
    MessageSearchEvidenceScope() => _globalMessageIdsMatchingText(
      ref,
      searchIntent: searchIntent,
      matchAnyTerm: matchAnyTerm,
    ),
    ContactAllMessagesEvidenceScope(:final contactId) =>
      _contactMessageIdsMatchingText(
        ref,
        contactId: contactId,
        searchIntent: searchIntent,
        matchAnyTerm: matchAnyTerm,
      ),
    ContactHandleMessagesEvidenceScope(:final contactId, :final handleId) =>
      _contactMessageIdsMatchingText(
        ref,
        contactId: contactId,
        handleId: handleId,
        searchIntent: searchIntent,
        matchAnyTerm: matchAnyTerm,
      ),
    ContactMessageSearchEvidenceScope(:final contactId, :final handleId) =>
      _contactMessageIdsMatchingText(
        ref,
        contactId: contactId,
        handleId: handleId,
        searchIntent: searchIntent,
        matchAnyTerm: matchAnyTerm,
      ),
    HandleMessagesEvidenceScope(:final handleId) =>
      _handleMessageIdsMatchingText(
        ref,
        handleId: handleId,
        searchIntent: searchIntent,
        matchAnyTerm: matchAnyTerm,
      ),
    ConversationExcerptEvidenceScope(
      :final conversationId,
      :final anchorMessageId,
      :final beforeCount,
      :final afterCount,
    ) =>
      _conversationExcerptMessageIdsMatchingText(
        ref,
        conversationId: conversationId,
        anchorMessageId: anchorMessageId,
        beforeCount: beforeCount,
        afterCount: afterCount,
        searchIntent: searchIntent,
        matchAnyTerm: matchAnyTerm,
      ),
    RecoveredMessagesEvidenceScope(
      :final contactId,
      :final onlyNoHandleFromMe,
    ) =>
      _recoveredMessageIdsMatchingText(
        ref,
        contactId: contactId,
        onlyNoHandleFromMe: onlyNoHandleFromMe,
        searchIntent: searchIntent,
        matchAnyTerm: matchAnyTerm,
      ),
  };
}

Future<MessageEvidenceTimelineSkeleton> _conversationTimelineSkeleton(
  Ref ref, {
  required int conversationId,
}) async {
  final reader = await ref.watch(conversationReaderProvider.future);
  final entries = await reader.readMessageTimeline(
    conversationId: conversationId,
  );
  return MessageEvidenceTimelineSkeleton(
    entries: [
      for (final entry in entries)
        MessageEvidenceSkeletonEntry(
          messageId: entry.messageId,
          dateUtc: entry.dateUtc,
          monthKey: entry.monthKey,
        ),
    ],
  );
}

Future<List<int>> _conversationMessageIdsMatchingText(
  Ref ref, {
  required int conversationId,
  required MessageTextSearchExecutionIntent searchIntent,
  required bool matchAnyTerm,
}) async {
  return _graphSearchMessageIds(
    ref,
    scope: GraphMessageSearchScope.conversation(conversationId),
    searchIntent: searchIntent,
    matchAnyTerm: matchAnyTerm,
  );
}

Future<ConversationMessage?> _conversationMessageById(
  Ref ref, {
  required int conversationId,
  required int messageId,
}) async {
  final reader = await ref.watch(conversationReaderProvider.future);
  return reader.readMessageById(
    conversationId: conversationId,
    messageId: messageId,
  );
}

Future<MessageEvidenceTimelineSkeleton> _globalMessagesTimelineSkeleton(
  Ref ref,
) async {
  final reader = await ref.watch(messageGraphReaderProvider.future);
  final entries = await reader.readGlobalMessageTimeline();
  return MessageEvidenceTimelineSkeleton(
    entries: [
      for (final entry in entries)
        MessageEvidenceSkeletonEntry(
          messageId: entry.messageId,
          dateUtc: entry.dateUtc,
          monthKey: entry.monthKey,
        ),
    ],
  );
}

Future<MessageEvidenceTimelineSkeleton> _globalMessageSearchTimelineSkeleton(
  Ref ref, {
  required String query,
  required MessageEvidenceSearchMode mode,
}) async {
  final searchIntent = MessageTextSearchQuery.parse(query).executionIntent;
  if (!searchIntent.isExecutable) {
    return const MessageEvidenceTimelineSkeleton(entries: []);
  }
  final skeleton = await _globalMessagesTimelineSkeleton(ref);
  final matchingIds = await _globalMessageIdsMatchingText(
    ref,
    searchIntent: searchIntent,
    matchAnyTerm: mode == MessageEvidenceSearchMode.anyTerm,
  );
  return skeleton.filteredByMessageIds(matchingIds);
}

Future<ConversationMessage?> _globalMessageById(
  Ref ref, {
  required int messageId,
}) async {
  final reader = await ref.watch(messageGraphReaderProvider.future);
  return reader.readGlobalMessageById(messageId: messageId);
}

Future<List<int>> _globalMessageIdsMatchingText(
  Ref ref, {
  required MessageTextSearchExecutionIntent searchIntent,
  required bool matchAnyTerm,
}) async {
  return _graphSearchMessageIds(
    ref,
    scope: const GraphMessageSearchScope.global(),
    searchIntent: searchIntent,
    matchAnyTerm: matchAnyTerm,
  );
}

Future<List<int>> _handleMessageIdsMatchingText(
  Ref ref, {
  required int handleId,
  required MessageTextSearchExecutionIntent searchIntent,
  required bool matchAnyTerm,
}) async {
  return _graphSearchMessageIds(
    ref,
    scope: GraphMessageSearchScope.handle(handleId),
    searchIntent: searchIntent,
    matchAnyTerm: matchAnyTerm,
  );
}

Future<List<int>> _graphSearchMessageIds(
  Ref ref, {
  required GraphMessageSearchScope scope,
  required MessageTextSearchExecutionIntent searchIntent,
  required bool matchAnyTerm,
}) async {
  final searchService = ref.watch(searchServiceProvider);
  return searchService.searchGraphMessageIdsForIntent(
    scope: scope,
    intent: searchIntent,
    mode: matchAnyTerm ? SearchMode.anyTerm : SearchMode.allTerms,
  );
}

Future<MessageEvidenceTimelineSkeleton> _handleMessagesTimelineSkeleton(
  Ref ref, {
  required int handleId,
}) async {
  final reader = await ref.watch(messageGraphReaderProvider.future);
  final entries = await reader.readHandleMessageTimeline(handleId: handleId);
  return MessageEvidenceTimelineSkeleton(
    entries: [
      for (final entry in entries)
        MessageEvidenceSkeletonEntry(
          messageId: entry.messageId,
          dateUtc: entry.dateUtc,
          monthKey: entry.monthKey,
        ),
    ],
  );
}

Future<ConversationMessage?> _handleMessageById(
  Ref ref, {
  required int handleId,
  required int messageId,
}) async {
  final reader = await ref.watch(messageGraphReaderProvider.future);
  return reader.readHandleMessageById(handleId: handleId, messageId: messageId);
}

Future<MessageEvidenceTimelineSkeleton> _conversationExcerptSkeleton(
  Ref ref, {
  required int conversationId,
  required int anchorMessageId,
  required int beforeCount,
  required int afterCount,
}) async {
  final reader = await ref.watch(messageGraphReaderProvider.future);
  final entries = await reader.readConversationExcerptTimeline(
    conversationId: conversationId,
    anchorMessageId: anchorMessageId,
    beforeCount: beforeCount,
    afterCount: afterCount,
  );
  return MessageEvidenceTimelineSkeleton(
    entries: [
      for (final entry in entries)
        MessageEvidenceSkeletonEntry(
          messageId: entry.messageId,
          dateUtc: entry.dateUtc,
          monthKey: entry.monthKey,
        ),
    ],
    initialAnchorMessageId: anchorMessageId,
  );
}

Future<List<int>> _conversationExcerptMessageIdsMatchingText(
  Ref ref, {
  required int conversationId,
  required int anchorMessageId,
  required int beforeCount,
  required int afterCount,
  required MessageTextSearchExecutionIntent searchIntent,
  required bool matchAnyTerm,
}) async {
  final skeleton = await _conversationExcerptSkeleton(
    ref,
    conversationId: conversationId,
    anchorMessageId: anchorMessageId,
    beforeCount: beforeCount,
    afterCount: afterCount,
  );
  if (skeleton.isEmpty) {
    return const <int>[];
  }

  final matchingIds = await _globalMessageIdsMatchingText(
    ref,
    searchIntent: searchIntent,
    matchAnyTerm: matchAnyTerm,
  );
  return skeleton
      .filteredByMessageIds(matchingIds)
      .entries
      .map((entry) {
        return entry.messageId;
      })
      .toList(growable: false);
}

Future<MessageEvidenceTimelineSkeleton> _contactAllMessagesTimelineSkeleton(
  Ref ref, {
  required int contactId,
}) async {
  final entries = await ref.watch(
    contactPageGraphMessageTimelineProvider(contactId: contactId).future,
  );
  return MessageEvidenceTimelineSkeleton(
    entries: [
      for (final entry in entries)
        MessageEvidenceSkeletonEntry(
          messageId: entry.messageId,
          dateUtc: entry.dateUtc,
          monthKey: entry.monthKey,
        ),
    ],
  );
}

Future<MessageEvidenceTimelineSkeleton> _contactHandleMessagesTimelineSkeleton(
  Ref ref, {
  required int contactId,
  required int handleId,
}) async {
  final entries = await ref.watch(
    contactPageGraphHandleMessageTimelineProvider(
      contactId: contactId,
      handleId: handleId,
    ).future,
  );
  return MessageEvidenceTimelineSkeleton(
    entries: [
      for (final entry in entries)
        MessageEvidenceSkeletonEntry(
          messageId: entry.messageId,
          dateUtc: entry.dateUtc,
          monthKey: entry.monthKey,
        ),
    ],
  );
}

Future<MessageEvidenceTimelineSkeleton> _contactMessageSearchTimelineSkeleton(
  Ref ref, {
  required int contactId,
  required String query,
  required int? handleId,
}) async {
  final searchIntent = MessageTextSearchQuery.parse(query).executionIntent;
  if (!searchIntent.isExecutable) {
    return const MessageEvidenceTimelineSkeleton(entries: []);
  }
  final baseSkeleton = handleId == null
      ? await _contactAllMessagesTimelineSkeleton(ref, contactId: contactId)
      : await _contactHandleMessagesTimelineSkeleton(
          ref,
          contactId: contactId,
          handleId: handleId,
        );
  final matchingIds = await _contactMessageIdsMatchingText(
    ref,
    contactId: contactId,
    handleId: handleId,
    searchIntent: searchIntent,
    matchAnyTerm: false,
  );
  return baseSkeleton.filteredByMessageIds(matchingIds);
}

Future<List<int>> _contactMessageIdsMatchingText(
  Ref ref, {
  required int contactId,
  required MessageTextSearchExecutionIntent searchIntent,
  required bool matchAnyTerm,
  int? handleId,
}) async {
  final canonicalHandleIds = handleId == null
      ? (await ref.watch(
              handlesForContactProvider(contactId: contactId).future,
            ))
            .map((handle) {
              return handle.handleId;
            })
            .toSet()
            .toList(growable: false)
      : <int>[handleId];
  if (canonicalHandleIds.isEmpty) {
    return const <int>[];
  }

  return _graphSearchMessageIds(
    ref,
    scope: GraphMessageSearchScope.contactCanonicalHandles(canonicalHandleIds),
    searchIntent: searchIntent,
    matchAnyTerm: matchAnyTerm,
  );
}

Future<MessageEvidenceTimelineSkeleton> _recoveredMessagesTimelineSkeleton(
  Ref ref, {
  required int? contactId,
  required bool onlyNoHandleFromMe,
}) async {
  final messages = await _recoveredMessagesForScope(
    ref,
    contactId: contactId,
    onlyNoHandleFromMe: onlyNoHandleFromMe,
  );
  return MessageEvidenceTimelineSkeleton(
    entries: [
      for (final message in messages)
        MessageEvidenceSkeletonEntry(
          messageId: message.id,
          dateUtc: _dateUtcString(message.sentAt),
          monthKey: _monthKey(message.sentAt),
        ),
    ],
  );
}

Future<ConversationMessage?> _recoveredMessageById(
  Ref ref, {
  required int? contactId,
  required bool onlyNoHandleFromMe,
  required int messageId,
}) async {
  final messages = await _recoveredMessagesForScope(
    ref,
    contactId: contactId,
    onlyNoHandleFromMe: onlyNoHandleFromMe,
  );
  final message = messages.where((item) {
    return item.id == messageId;
  }).firstOrNull;
  if (message == null) {
    return null;
  }
  return ConversationMessage(
    messageId: message.id,
    dateUtc: _dateUtcString(message.sentAt),
    isFromMe: message.isFromMe,
    text: message.text,
    associatedMessageId: null,
    attachmentCount: message.attachmentCount,
    senderHandleId: message.senderHandleId,
    senderDisplayHandle: _recoveredSenderLabel(message),
    semanticKind: message.isInferred
        ? '${message.semanticKind} (best guess)'
        : message.semanticKind,
    itemKind: message.itemType,
    isSparseArtifact: message.isSparseArtifact,
  );
}

Future<List<MessageAttachmentEvidence>> _messageAttachments(
  Ref ref, {
  required int messageId,
}) async {
  final attachments = await ref.watch(
    messageAttachmentsProvider(messageId).future,
  );
  final fileAccess = ref.watch(attachmentFileAccessProvider);
  return messageAttachmentEvidenceFromMessageAttachments(
    attachments,
    fileAccess,
  );
}

Future<List<MessageAttachmentEvidence>> _recoveredMessageAttachments(
  Ref ref, {
  required int? contactId,
  required bool onlyNoHandleFromMe,
  required int messageId,
}) async {
  final messages = await _recoveredMessagesForScope(
    ref,
    contactId: contactId,
    onlyNoHandleFromMe: onlyNoHandleFromMe,
  );
  final message = messages.where((item) {
    return item.id == messageId;
  }).firstOrNull;
  if (message == null) {
    return const <MessageAttachmentEvidence>[];
  }
  final fileAccess = ref.watch(attachmentFileAccessProvider);
  return [
    for (final attachment in message.attachments)
      messageAttachmentEvidenceFromRecoveredAttachment(attachment, fileAccess),
  ];
}

Future<List<int>> _recoveredMessageIdsMatchingText(
  Ref ref, {
  required int? contactId,
  required bool onlyNoHandleFromMe,
  required MessageTextSearchExecutionIntent searchIntent,
  required bool matchAnyTerm,
}) async {
  if (searchIntent.tokens.isEmpty || searchIntent.filterSaved) {
    return const <int>[];
  }

  final messages = await _recoveredMessagesForScope(
    ref,
    contactId: contactId,
    onlyNoHandleFromMe: onlyNoHandleFromMe,
  );

  return [
    for (final message in messages)
      if (_recoveredMessageMatchesTerms(
        message: message,
        searchIntent: searchIntent,
        matchAnyTerm: matchAnyTerm,
      ))
        message.id,
  ];
}

bool _recoveredMessageMatchesTerms({
  required RecoveredUnlinkedMessageItem message,
  required MessageTextSearchExecutionIntent searchIntent,
  required bool matchAnyTerm,
}) {
  final attachmentText = message.attachments
      .map((attachment) {
        return attachment.transferName?.trim();
      })
      .whereType<String>()
      .where((name) {
        return name.isNotEmpty;
      })
      .join(' ');
  final haystack = [
    message.senderLabel,
    message.contactName,
    message.service,
    message.itemType,
    message.semanticKind,
    message.text,
    attachmentText,
  ].whereType<String>().join(' ');

  return messageTextMatchesSearchIntent(
    text: haystack,
    intent: searchIntent,
    matchAnyTerm: matchAnyTerm,
  );
}

Future<List<RecoveredUnlinkedMessageItem>> _recoveredMessagesForScope(
  Ref ref, {
  required int? contactId,
  required bool onlyNoHandleFromMe,
}) async {
  final asyncMessages = ref.watch(
    recoveredUnlinkedMessagesProvider(contactId: contactId),
  );
  final messages =
      asyncMessages.valueOrNull ??
      await ref.watch(
        recoveredUnlinkedMessagesProvider(contactId: contactId).future,
      ) ??
      const <RecoveredUnlinkedMessageItem>[];

  return filterRecoveredTimelineMessages(
    messages: messages,
    onlyNoHandleFromMe: onlyNoHandleFromMe,
  );
}

String _recoveredSenderLabel(RecoveredUnlinkedMessageItem message) {
  if (message.isFromMe) {
    return 'You';
  }
  final contactName = message.contactName?.trim();
  if (contactName != null && contactName.isNotEmpty) {
    return contactName;
  }
  final senderLabel = message.senderLabel.trim();
  if (senderLabel.isNotEmpty) {
    return senderLabel;
  }
  return 'Unknown sender';
}

String? _dateUtcString(DateTime? value) {
  if (value == null) {
    return null;
  }
  return value.toUtc().toIso8601String();
}

String? _monthKey(DateTime? value) {
  return DateLabelFormatter.monthKeyOrNull(value);
}
