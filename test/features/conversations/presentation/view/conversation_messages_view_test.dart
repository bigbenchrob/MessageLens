import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/config/theme/widgets/layout/cross_column_track_plan.dart';
import 'package:remember_this_text/config/theme/widgets/layout/page_track_layout_matrix.dart';
import 'package:remember_this_text/config/theme/widgets/layout/resolved_track_layout_matrix.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation_reader_provider.dart';
import 'package:remember_this_text/essentials/search/application/message_text_search_query.dart';
import 'package:remember_this_text/features/contacts/application/display_identity/display_identity.dart';
import 'package:remember_this_text/features/contacts/application/display_identity/display_identity_resolver_provider.dart';
import 'package:remember_this_text/features/conversations/presentation/view/conversation_messages_view.dart';
import 'package:remember_this_text/features/messages/application/message_evidence/message_evidence_spine_provider.dart';
import 'package:remember_this_text/features/messages/domain/message_evidence/message_evidence_row_data.dart';
import 'package:remember_this_text/features/messages/domain/message_evidence/message_evidence_scope.dart';
import 'package:remember_this_text/features/messages/domain/message_evidence/message_evidence_search_mode.dart';
import 'package:remember_this_text/features/messages/domain/message_evidence/message_evidence_skeleton.dart';

void main() {
  testWidgets('renders graph conversation through evidence spine', (
    tester,
  ) async {
    const scope = ConversationEvidenceScope(conversationId: 42);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          conversationOverviewByIdProvider(conversationId: 42).overrideWith((
            ref,
          ) async {
            return const ConversationOverview(
              conversationId: 42,
              participantHandles: ['1 (778) 990-8506', '+15552'],
              participantCount: 2,
              isGroup: true,
              messageCount: 3,
              attachmentCount: 0,
              firstMessageAtUtc: '2026-05-18T10:00:00.000Z',
              lastMessageAtUtc: '2026-05-20T10:00:00.000Z',
              lastMessageText: 'newest',
            );
          }),
          displayIdentityResolverProvider.overrideWith((ref) async {
            return const DisplayIdentityResolver(
              identitiesByHandleKey: {
                '17789908506': ParticipantDisplayIdentity(
                  primaryLabel: 'Claire',
                  source: DisplayIdentitySource.userOverride,
                  isKnownContact: true,
                  contactId: 17,
                ),
              },
            );
          }),
          messageEvidenceTimelineSkeletonProvider(scope: scope).overrideWith((
            ref,
          ) async {
            return const MessageEvidenceTimelineSkeleton(
              entries: [
                MessageEvidenceSkeletonEntry(
                  messageId: 1,
                  dateUtc: '2026-05-18T10:00:00.000Z',
                  monthKey: '2026-05',
                ),
                MessageEvidenceSkeletonEntry(
                  messageId: 2,
                  dateUtc: '2026-05-19T10:00:00.000Z',
                  monthKey: '2026-05',
                ),
                MessageEvidenceSkeletonEntry(
                  messageId: 3,
                  dateUtc: '2026-05-20T10:00:00.000Z',
                  monthKey: '2026-05',
                ),
              ],
            );
          }),
          messageEvidenceRowProvider(scope: scope, messageId: 1).overrideWith((
            ref,
          ) async {
            return const MessageEvidenceRowData(
              messageId: 1,
              dateUtc: '2026-05-18T10:00:00.000Z',
              isFromMe: false,
              text: 'oldest',
              associatedMessageId: null,
              attachmentCount: 0,
            );
          }),
          messageEvidenceRowProvider(scope: scope, messageId: 2).overrideWith((
            ref,
          ) async {
            return const MessageEvidenceRowData(
              messageId: 2,
              dateUtc: '2026-05-19T10:00:00.000Z',
              isFromMe: false,
              text: null,
              associatedMessageId: null,
              attachmentCount: 0,
              senderDisplayHandle: '+15552',
              itemKind: 'system',
              isSparseArtifact: true,
              hasAttributedBodySource: true,
            );
          }),
          messageEvidenceRowProvider(scope: scope, messageId: 3).overrideWith((
            ref,
          ) async {
            return const MessageEvidenceRowData(
              messageId: 3,
              dateUtc: '2026-05-20T10:00:00.000Z',
              isFromMe: true,
              text: 'newest',
              associatedMessageId: 1,
              attachmentCount: 0,
              semanticKind: 'reaction',
            );
          }),
        ],
        child: const MacosApp(
          home: ConversationMessagesView(conversationId: 42),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(find.text('Conversation with Claire and +15552'), findsOneWidget);
    expect(find.textContaining('3 messages'), findsOneWidget);
    expect(find.text('newest'), findsOneWidget);
    expect(find.text('associated 1'), findsNothing);
    expect(find.text('reaction'), findsNothing);
    expect(find.text('View options'), findsNothing);
    expect(find.text('Latest 500'), findsNothing);
  });

  testWidgets(
    'renders its Contacts title in A2 then continues its native header',
    (tester) async {
      const scope = ConversationEvidenceScope(conversationId: 42);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            conversationOverviewByIdProvider(conversationId: 42).overrideWith((
              ref,
            ) async {
              return const ConversationOverview(
                conversationId: 42,
                participantHandles: ['+17789908506'],
                participantCount: 1,
                isGroup: false,
                messageCount: 1,
                attachmentCount: 0,
                firstMessageAtUtc: '2026-05-20T10:00:00.000Z',
                lastMessageAtUtc: '2026-05-20T10:00:00.000Z',
                lastMessageText: 'tracked conversation',
              );
            }),
            displayIdentityResolverProvider.overrideWith((ref) async {
              return const DisplayIdentityResolver(
                identitiesByHandleKey: {
                  '17789908506': ParticipantDisplayIdentity(
                    primaryLabel: 'Claire',
                    source: DisplayIdentitySource.userOverride,
                    isKnownContact: true,
                    contactId: 17,
                  ),
                },
              );
            }),
            messageEvidenceTimelineSkeletonProvider(scope: scope).overrideWith((
              ref,
            ) async {
              return const MessageEvidenceTimelineSkeleton(entries: []);
            }),
          ],
          child: MacosApp(
            home: ResolvedTrackLayoutMatrixScope(
              matrix: _resolvedConversationHeaderMatrix(
                title: 'Conversation with Claire',
              ),
              child: const SizedBox(
                width: 960,
                height: 720,
                child: ConversationMessagesView(conversationId: 42),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(find.text('Conversation with Claire'), findsOneWidget);
      expect(find.text('Search this conversation'), findsOneWidget);
      expect(find.byType(TrackCellView), findsOneWidget);
      expect(
        tester.widget<TrackCellView>(find.byType(TrackCellView)).cellId,
        const CellId(trackId: TrackId.trackA, columnId: TrackColumnId.column2),
      );
    },
  );

  testWidgets('shows search and anchor context without batch controls', (
    tester,
  ) async {
    const scope = ConversationEvidenceScope(conversationId: 42);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          conversationOverviewByIdProvider(conversationId: 42).overrideWith((
            ref,
          ) async {
            return null;
          }),
          messageEvidenceTimelineSkeletonProvider(scope: scope).overrideWith((
            ref,
          ) async {
            return const MessageEvidenceTimelineSkeleton(entries: []);
          }),
        ],
        child: const MacosApp(
          home: ConversationMessagesView(
            conversationId: 42,
            anchorMessageId: 101,
            searchQuery: 'settlement',
          ),
        ),
      ),
    );

    await tester.pump();

    await tester.pump();

    expect(
      find.textContaining('Message text contains "settlement"'),
      findsOneWidget,
    );
    expect(find.textContaining('Anchored at message 101'), findsOneWidget);
    expect(find.text('View options'), findsNothing);
    expect(find.text('Latest 500'), findsNothing);
  });

  testWidgets('passes anchor and search highlight into the evidence timeline', (
    tester,
  ) async {
    const scope = ConversationEvidenceScope(conversationId: 42);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          conversationOverviewByIdProvider(conversationId: 42).overrideWith((
            ref,
          ) async {
            return null;
          }),
          messageEvidenceTimelineSkeletonProvider(scope: scope).overrideWith((
            ref,
          ) async {
            return const MessageEvidenceTimelineSkeleton(
              entries: [
                MessageEvidenceSkeletonEntry(
                  messageId: 100,
                  dateUtc: '2026-05-18T10:00:00.000Z',
                  monthKey: '2026-05',
                ),
                MessageEvidenceSkeletonEntry(
                  messageId: 101,
                  dateUtc: '2026-05-20T10:00:00.000Z',
                  monthKey: '2026-05',
                ),
              ],
            );
          }),
          messageEvidenceTextMatchIdsProvider(
            scope: scope,
            searchIntent: _intent('settlement  '),
            mode: MessageEvidenceSearchMode.allTerms,
          ).overrideWith((ref) async {
            return [101];
          }),
          messageEvidenceRowProvider(scope: scope, messageId: 101).overrideWith(
            (ref) async {
              return const MessageEvidenceRowData(
                messageId: 101,
                dateUtc: '2026-05-20T10:00:00.000Z',
                isFromMe: true,
                text: 'settlement authority',
                associatedMessageId: null,
                attachmentCount: 0,
              );
            },
          ),
        ],
        child: const MacosApp(
          home: ConversationMessagesView(
            conversationId: 42,
            anchorMessageId: 101,
            searchQuery: 'settlement  ',
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(find.text('settlement authority'), findsOneWidget);
    expect(
      tester
          .widget<MacosTextField>(find.byType(MacosTextField))
          .controller
          ?.text,
      'settlement  ',
    );
  });

  testWidgets('conversation search displays only matching scope rows', (
    tester,
  ) async {
    const scope = ConversationEvidenceScope(conversationId: 42);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          conversationOverviewByIdProvider(conversationId: 42).overrideWith((
            ref,
          ) async {
            return const ConversationOverview(
              conversationId: 42,
              participantHandles: ['+15551'],
              participantCount: 1,
              isGroup: false,
              messageCount: 2,
              attachmentCount: 0,
              firstMessageAtUtc: '2026-05-18T10:00:00.000Z',
              lastMessageAtUtc: '2026-05-20T10:00:00.000Z',
              lastMessageText: 'other',
            );
          }),
          messageEvidenceTimelineSkeletonProvider(scope: scope).overrideWith((
            ref,
          ) async {
            return const MessageEvidenceTimelineSkeleton(
              entries: [
                MessageEvidenceSkeletonEntry(
                  messageId: 1,
                  dateUtc: '2026-05-18T10:00:00.000Z',
                  monthKey: '2026-05',
                ),
                MessageEvidenceSkeletonEntry(
                  messageId: 2,
                  dateUtc: '2026-05-20T10:00:00.000Z',
                  monthKey: '2026-05',
                ),
              ],
            );
          }),
          messageEvidenceTextMatchIdsProvider(
            scope: scope,
            searchIntent: _intent('settlement'),
            mode: MessageEvidenceSearchMode.allTerms,
          ).overrideWith((ref) async {
            return [1];
          }),
          messageEvidenceRowProvider(scope: scope, messageId: 1).overrideWith((
            ref,
          ) async {
            return const MessageEvidenceRowData(
              messageId: 1,
              dateUtc: '2026-05-18T10:00:00.000Z',
              isFromMe: false,
              text: 'settlement authority',
              associatedMessageId: null,
              attachmentCount: 0,
            );
          }),
          messageEvidenceRowProvider(scope: scope, messageId: 2).overrideWith((
            ref,
          ) async {
            return const MessageEvidenceRowData(
              messageId: 2,
              dateUtc: '2026-05-20T10:00:00.000Z',
              isFromMe: false,
              text: 'other message',
              associatedMessageId: null,
              attachmentCount: 0,
            );
          }),
        ],
        child: const MacosApp(
          home: ConversationMessagesView(
            conversationId: 42,
            searchQuery: 'settlement',
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(find.text('settlement authority'), findsOneWidget);
    expect(find.text('other message'), findsNothing);
    expect(find.text('1 of 2 messages match "settlement"'), findsOneWidget);
  });
}

MessageTextSearchExecutionIntent _intent(String rawInput) {
  return MessageTextSearchQuery.parse(rawInput).executionIntent;
}

ResolvedTrackLayoutMatrix _resolvedConversationHeaderMatrix({
  required String title,
}) {
  final matrix = PageTrackLayoutMatrix<TrackOccupant>(
    trackIds: const [TrackId.trackA],
    columnIds: TrackColumnId.values,
    cells: [
      const MatrixCell<TrackOccupant>.occupied(
        cellId: CellId(
          trackId: TrackId.trackA,
          columnId: TrackColumnId.column1,
        ),
        occupant: FixedHeightTrackOccupant(height: 40),
      ),
      MatrixCell<TrackOccupant>.occupied(
        cellId: const CellId(
          trackId: TrackId.trackA,
          columnId: TrackColumnId.column2,
        ),
        occupant: TextTrackOccupant(
          text: title,
          style: const TextStyle(fontSize: 20),
        ),
      ),
      const MatrixCell<TrackOccupant>.empty(
        cellId: CellId(
          trackId: TrackId.trackA,
          columnId: TrackColumnId.column3,
        ),
      ),
    ],
  );
  return ResolvedTrackLayoutMatrix.resolve(
    matrix: matrix,
    constraints: const PresentationConstraints(
      availableWidth: 960,
      textScaler: TextScaler.noScaling,
      textDirection: TextDirection.ltr,
    ),
  );
}
