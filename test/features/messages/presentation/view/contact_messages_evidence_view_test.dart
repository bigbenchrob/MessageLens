import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/config/theme/widgets/layout/cross_column_track_plan.dart';
import 'package:remember_this_text/config/theme/widgets/layout/page_track_layout_matrix.dart';
import 'package:remember_this_text/config/theme/widgets/layout/resolved_track_layout_matrix.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/contacts/contact_graph.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/contacts/contact_graph_provider.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversations/conversation.dart';
import 'package:remember_this_text/essentials/search/application/graph_message_search.dart';
import 'package:remember_this_text/essentials/search/application/graph_search_repository_provider.dart';
import 'package:remember_this_text/essentials/search/application/message_text_search_query.dart';
import 'package:remember_this_text/features/contacts/application/display_identity/display_identity.dart';
import 'package:remember_this_text/features/contacts/application/display_identity/display_identity_resolver_provider.dart';
import 'package:remember_this_text/features/contacts/application/read_models/handles_for_contact_provider.dart';
import 'package:remember_this_text/features/contacts/application/read_models/linked_handle.dart';
import 'package:remember_this_text/features/messages/application/message_evidence/current_visible_month_provider.dart';
import 'package:remember_this_text/features/messages/domain/message_evidence/message_evidence_scope.dart';
import 'package:remember_this_text/features/messages/presentation/view/contact_messages_evidence_view.dart';

void main() {
  testWidgets('opens contact message evidence timeline at latest message', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ..._contactGraphOverrides(
            messages: const [
              ConversationMessage(
                messageId: 2,
                dateUtc: '2026-05-20T10:00:00.000Z',
                isFromMe: true,
                text: 'newest message',
                associatedMessageId: null,
                attachmentCount: 0,
              ),
              ConversationMessage(
                messageId: 1,
                dateUtc: '2026-05-19T10:00:00.000Z',
                isFromMe: false,
                text: 'older message',
                associatedMessageId: null,
                attachmentCount: 0,
              ),
            ],
          ),
        ],
        child: const MacosApp(home: ContactMessagesEvidenceView(contactId: 24)),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('newest message'), findsOneWidget);
  });

  testWidgets('publishes selected contact month for heatmap feedback', (
    tester,
  ) async {
    final visibleMonthWrites = <String?>[];
    final monthAnchor = DateTime(2026, 4);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ..._contactGraphOverrides(
            messages: const [
              ConversationMessage(
                messageId: 1,
                dateUtc: '2026-04-20T10:00:00.000Z',
                isFromMe: true,
                text: 'april message',
                associatedMessageId: null,
                attachmentCount: 0,
              ),
            ],
            monthAnchor: monthAnchor,
          ),
          currentVisibleMonthForScopeProvider(
            scope: const ContactAllMessagesEvidenceScope(contactId: 24),
          ).overrideWith(() => _VisibleMonthSpy(visibleMonthWrites)),
        ],
        child: MacosApp(
          home: ContactMessagesEvidenceView(
            contactId: 24,
            monthAnchor: monthAnchor,
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(visibleMonthWrites, contains('2026-04'));
  });

  testWidgets('opens filtered contact message timeline through shared view', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ..._contactGraphOverrides(
            messages: const [
              ConversationMessage(
                messageId: 3,
                dateUtc: '2026-05-20T10:00:00.000Z',
                isFromMe: true,
                text: 'selected handle message',
                associatedMessageId: null,
                attachmentCount: 0,
              ),
            ],
            filterHandleId: 12,
          ),
        ],
        child: const MacosApp(
          home: ContactMessagesEvidenceView(contactId: 24, filterHandleId: 12),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('selected handle message'), findsOneWidget);
    expect(find.text('Messages from Claire'), findsOneWidget);
    expect(find.text('All messages from Claire'), findsNothing);
    expect(
      find.text('Selected handle: clairemc@gmail.com (iMessage)'),
      findsOneWidget,
    );
    expect(find.text('1 message'), findsOneWidget);
  });

  testWidgets(
    'renders its title in A2 then continues its native evidence header',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ..._contactGraphOverrides(
              messages: const [
                ConversationMessage(
                  messageId: 3,
                  dateUtc: '2026-05-20T10:00:00.000Z',
                  isFromMe: true,
                  text: 'tracked contact message',
                  associatedMessageId: null,
                  attachmentCount: 0,
                ),
              ],
            ),
          ],
          child: MacosApp(
            home: ResolvedTrackLayoutMatrixScope(
              matrix: _resolvedContactsHeaderMatrix(
                title: 'All messages from Claire',
              ),
              child: const SizedBox(
                width: 960,
                height: 720,
                child: ContactMessagesEvidenceView(contactId: 24),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('All messages from Claire'), findsOneWidget);
      expect(find.text('Search messages from Claire'), findsOneWidget);
      expect(find.byType(TrackCellView), findsOneWidget);
      expect(
        tester.widget<TrackCellView>(find.byType(TrackCellView)).cellId,
        const CellId(trackId: TrackId.trackA, columnId: TrackColumnId.column2),
      );
    },
  );

  testWidgets(
    'publishes filtered selected contact month for heatmap feedback',
    (tester) async {
      final visibleMonthWrites = <String?>[];
      final monthAnchor = DateTime(2026, 4);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ..._contactGraphOverrides(
              messages: const [
                ConversationMessage(
                  messageId: 3,
                  dateUtc: '2026-04-20T10:00:00.000Z',
                  isFromMe: true,
                  text: 'filtered april message',
                  associatedMessageId: null,
                  attachmentCount: 0,
                ),
              ],
              monthAnchor: monthAnchor,
              filterHandleId: 12,
            ),
            currentVisibleMonthForScopeProvider(
              scope: const ContactHandleMessagesEvidenceScope(
                contactId: 24,
                handleId: 12,
              ),
            ).overrideWith(() => _VisibleMonthSpy(visibleMonthWrites)),
          ],
          child: MacosApp(
            home: ContactMessagesEvidenceView(
              contactId: 24,
              monthAnchor: monthAnchor,
              filterHandleId: 12,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(visibleMonthWrites, contains('2026-04'));
    },
  );

  testWidgets(
    'contact search filters rendered rows to the matching evidence scope',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ..._contactGraphOverrides(
              messages: const [
                ConversationMessage(
                  messageId: 1,
                  dateUtc: '2026-04-20T10:00:00.000Z',
                  isFromMe: true,
                  text: 'settlement message',
                  associatedMessageId: null,
                  attachmentCount: 0,
                ),
                ConversationMessage(
                  messageId: 2,
                  dateUtc: '2026-05-20T10:00:00.000Z',
                  isFromMe: false,
                  text: 'other message',
                  associatedMessageId: null,
                  attachmentCount: 0,
                ),
              ],
              matchingIdsByQuery: const {
                'settlement': [1],
              },
            ),
          ],
          child: const MacosApp(
            home: ContactMessagesEvidenceView(contactId: 24),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.enterText(find.byType(MacosTextField), 'settlement');
      await tester.pumpAndSettle();

      expect(find.text('settlement message'), findsOneWidget);
      expect(find.text('other message'), findsNothing);
      expect(find.text('1 of 2 messages match "settlement"'), findsOneWidget);
    },
  );
}

ResolvedTrackLayoutMatrix _resolvedContactsHeaderMatrix({
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

List<Override> _contactGraphOverrides({
  required List<ConversationMessage> messages,
  DateTime? monthAnchor,
  int? filterHandleId,
  Map<String, List<int>> matchingIdsByQuery = const <String, List<int>>{},
}) {
  return [
    displayIdentityResolverProvider.overrideWith((ref) async {
      return const DisplayIdentityResolver(
        identitiesByHandleKey: {},
        identitiesByContactId: {
          24: ParticipantDisplayIdentity(
            primaryLabel: 'Claire',
            source: DisplayIdentitySource.userOverride,
            isKnownContact: true,
            contactId: 24,
          ),
        },
      );
    }),
    contactPageGraphMessagesProvider(
      contactId: 24,
      limit: monthAnchor == null ? 500 : 100000,
      monthAnchor: monthAnchor,
    ).overrideWith((ref) async {
      return messages;
    }),
    contactPageGraphMessageTimelineProvider(contactId: 24).overrideWith((
      ref,
    ) async {
      return [
        for (final message in messages)
          ContactGraphMessageTimelineEntry(
            messageId: message.messageId,
            dateUtc: message.dateUtc,
            monthKey: _monthKey(message.dateUtc),
          ),
      ];
    }),
    handlesForContactProvider(contactId: 24).overrideWith((ref) async {
      return const [
        LinkedHandle(
          handleId: 12,
          displayValue: 'clairemc@gmail.com',
          service: 'iMessage',
          isOverrideLink: false,
        ),
      ];
    }),
    if (filterHandleId != null)
      contactPageGraphHandleMessageTimelineProvider(
        contactId: 24,
        handleId: filterHandleId,
      ).overrideWith((ref) async {
        return [
          for (final message in messages)
            ContactGraphMessageTimelineEntry(
              messageId: message.messageId,
              dateUtc: message.dateUtc,
              monthKey: _monthKey(message.dateUtc),
            ),
        ];
      }),
    graphSearchRepositoryProvider.overrideWith((ref) async {
      return _FakeGraphSearchRepository(matchingIdsByQuery);
    }),
    for (final message in messages)
      contactPageGraphMessageByIdProvider(
        contactId: 24,
        messageId: message.messageId,
      ).overrideWith((ref) async {
        return message;
      }),
    if (filterHandleId != null)
      for (final message in messages)
        contactPageGraphHandleMessageByIdProvider(
          contactId: 24,
          handleId: filterHandleId,
          messageId: message.messageId,
        ).overrideWith((ref) async {
          return message;
        }),
    contactPageGraphSnapshotProvider(contactId: 24).overrideWith((ref) async {
      return const ContactGraphSnapshot(
        contactId: 24,
        conversations: <ConversationOverview>[],
        messageActivity: ContactMessageActivity(
          firstMessageAtUtc: '2026-04-10T10:00:00.000Z',
          lastMessageAtUtc: '2026-05-20T10:00:00.000Z',
          monthCounts: <ContactMessageMonthCount>[
            ContactMessageMonthCount(year: 2026, month: 4, messageCount: 1),
            ContactMessageMonthCount(year: 2026, month: 5, messageCount: 1),
          ],
        ),
      );
    }),
  ];
}

class _FakeGraphSearchRepository implements GraphSearchRepository {
  const _FakeGraphSearchRepository(this.matchesByQuery);

  final Map<String, List<int>> matchesByQuery;

  @override
  Future<List<int>> searchMessageIds({
    required GraphMessageSearchScope scope,
    required List<MessageTextSearchToken> textTokens,
    required bool matchAnyTerm,
    required bool filterSaved,
    int limit = graphSearchResultLimit,
  }) async {
    final query = textTokens.map((token) => token.normalizedText).join(' ');
    return matchesByQuery[query] ?? const <int>[];
  }
}

String? _monthKey(String? value) {
  final parsed = value == null ? null : DateTime.tryParse(value);
  if (parsed == null) {
    return null;
  }
  return '${parsed.year.toString().padLeft(4, '0')}-'
      '${parsed.month.toString().padLeft(2, '0')}';
}

class _VisibleMonthSpy extends CurrentVisibleMonthForScope {
  _VisibleMonthSpy(this.writes);

  final List<String?> writes;

  @override
  String? build({required MessageEvidenceScope scope}) {
    return null;
  }

  @override
  void setVisibleMonthKey(String? monthKey) {
    writes.add(monthKey);
    super.setVisibleMonthKey(monthKey);
  }
}
