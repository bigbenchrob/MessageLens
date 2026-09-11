import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/features/messages/application/message_evidence/global_messages_search_session_provider.dart';
import 'package:remember_this_text/features/messages/application/message_evidence/message_evidence_spine_provider.dart';
import 'package:remember_this_text/features/messages/domain/message_evidence/message_evidence_scope.dart';
import 'package:remember_this_text/features/messages/domain/message_evidence/message_evidence_skeleton.dart';
import 'package:remember_this_text/features/messages/presentation/view_model/global_messages_evidence_presentation_provider.dart';

void main() {
  test(
    'prepares global and searched evidence from one semantic boundary',
    () async {
      const allScope = GlobalMessagesEvidenceScope();
      const searchScope = MessageSearchEvidenceScope(query: 'family');
      const allSkeleton = MessageEvidenceTimelineSkeleton(
        entries: [
          MessageEvidenceSkeletonEntry(
            messageId: 1,
            dateUtc: '2025-01-01T12:00:00.000Z',
            monthKey: '2025-01',
          ),
          MessageEvidenceSkeletonEntry(
            messageId: 2,
            dateUtc: '2025-02-01T12:00:00.000Z',
            monthKey: '2025-02',
          ),
        ],
      );
      const searchSkeleton = MessageEvidenceTimelineSkeleton(
        entries: [
          MessageEvidenceSkeletonEntry(
            messageId: 2,
            dateUtc: '2025-02-01T12:00:00.000Z',
            monthKey: '2025-02',
          ),
        ],
      );
      final container = ProviderContainer(
        overrides: [
          messageEvidenceTimelineSkeletonProvider(
            scope: allScope,
          ).overrideWith((ref) async => allSkeleton),
          messageEvidenceTimelineSkeletonProvider(
            scope: searchScope,
          ).overrideWith((ref) async => searchSkeleton),
        ],
      );
      addTearDown(container.dispose);
      final presentationProvider = globalMessagesEvidencePresentationProvider();
      final subscription = container.listen(
        presentationProvider,
        (previous, next) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      await container.read(
        messageEvidenceTimelineSkeletonProvider(scope: allScope).future,
      );
      await Future<void>.delayed(Duration.zero);

      final initial = container.read(presentationProvider);
      expect(initial.evidenceScope, allScope);
      expect(initial.labels?.count, '2 messages');

      container
          .read(globalMessagesSearchSessionProvider().notifier)
          .setQuery('family');
      await container.read(
        messageEvidenceTimelineSkeletonProvider(scope: searchScope).future,
      );
      await Future<void>.delayed(Duration.zero);

      final searched = container.read(presentationProvider);
      expect(searched.evidenceScope, searchScope);
      expect(searched.labels?.count, '1 of 2 messages match "family"');
      expect(
        searched.investigationStatus?.description,
        'Messages matching "family"',
      );
      expect(searched.investigationStatus?.isSearching, isFalse);
    },
  );

  test('derives active investigation status from evidence loading', () async {
    const allScope = GlobalMessagesEvidenceScope();
    const searchScope = MessageSearchEvidenceScope(query: 'family');
    const allSkeleton = MessageEvidenceTimelineSkeleton(entries: []);
    final searchCompleter = Completer<MessageEvidenceTimelineSkeleton>();
    final container = ProviderContainer(
      overrides: [
        messageEvidenceTimelineSkeletonProvider(
          scope: allScope,
        ).overrideWith((ref) async => allSkeleton),
        messageEvidenceTimelineSkeletonProvider(
          scope: searchScope,
        ).overrideWith((ref) => searchCompleter.future),
      ],
    );
    addTearDown(container.dispose);
    final presentationProvider = globalMessagesEvidencePresentationProvider();
    final subscription = container.listen(
      presentationProvider,
      (previous, next) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    await container.read(
      messageEvidenceTimelineSkeletonProvider(scope: allScope).future,
    );
    container
        .read(globalMessagesSearchSessionProvider().notifier)
        .setQuery('family');
    await Future<void>.delayed(Duration.zero);

    final searching = container.read(presentationProvider);
    expect(searching.investigationStatus?.isSearching, isTrue);
    expect(
      searching.investigationStatus?.description,
      'Messages matching "family"',
    );

    searchCompleter.complete(
      const MessageEvidenceTimelineSkeleton(entries: []),
    );
    await searchCompleter.future;
    await Future<void>.delayed(Duration.zero);

    expect(
      container.read(presentationProvider).investigationStatus?.isSearching,
      isFalse,
    );
  });
}
