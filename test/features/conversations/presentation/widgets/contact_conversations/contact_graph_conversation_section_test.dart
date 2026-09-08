import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_favourites/conversation_favourites_provider.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/conversation_signatures/conversation_signature.dart';
import 'package:remember_this_text/features/conversations/application/contact_conversations/contact_conversation_signatures_provider.dart';
import 'package:remember_this_text/features/conversations/application/conversation_signatures/conversation_signature_display_provider.dart';
import 'package:remember_this_text/features/conversations/presentation/widgets/contact_conversations/contact_graph_conversation_section.dart';
import 'package:remember_this_text/features/messages/presentation/widgets/calendar_heatmap_timeline_widget.dart';

void main() {
  testWidgets(
    'contact conversations derive the same single expanded card from flow state',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            contactConversationSignaturesProvider(
              contactId: 24,
            ).overrideWith((ref) async => _signatures),
            conversationFavouritesControllerProvider.overrideWith(
              _EmptyConversationFavouritesController.new,
            ),
          ],
          child: const MacosApp(
            home: Align(
              alignment: Alignment.topLeft,
              child: ContactGraphConversationSection(
                contactId: 24,
                selectedConversationId: 42,
                padding: EdgeInsets.zero,
                maxHeight: 360,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CalendarHeatmapTimelineWidget), findsOneWidget);
      expect(
        find.byKey(const ValueKey('conversation-signature-calendar-42')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('conversation-signature-calendar-43')),
        findsNothing,
      );
      expect(find.text('Claire'), findsOneWidget);
      expect(find.text('Cathie'), findsOneWidget);
    },
  );

  testWidgets(
    'long selected heatmap keeps natural height inside the existing viewport',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            contactConversationSignaturesProvider(
              contactId: 24,
            ).overrideWith((ref) async => [_longSignature]),
            conversationFavouritesControllerProvider.overrideWith(
              _EmptyConversationFavouritesController.new,
            ),
          ],
          child: const MacosApp(
            home: Align(
              alignment: Alignment.topLeft,
              child: ContactGraphConversationSection(
                contactId: 24,
                selectedConversationId: 42,
                padding: EdgeInsets.zero,
                maxHeight: 360,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final selectedCard = find
          .ancestor(
            of: find.byType(CalendarHeatmapTimelineWidget),
            matching: find.byType(AnimatedContainer),
          )
          .first;
      final contactList = find.descendant(
        of: find.byType(ContactGraphConversationSection),
        matching: find.byType(ListView),
      );
      expect(tester.getSize(contactList).height, 360);
      expect(tester.getSize(selectedCard).height, greaterThan(360));
      expect(tester.takeException(), isNull);
    },
  );
}

class _EmptyConversationFavouritesController
    extends ConversationFavouritesController {
  @override
  ConversationFavourites build() {
    return const ConversationFavourites();
  }
}

const _signatures = <ConversationSignatureDisplayModel>[
  ConversationSignatureDisplayModel(
    conversationId: 42,
    title: 'Claire',
    participantLabels: ['Claire'],
    participantCount: 1,
    isGroup: false,
    messageCount: 4,
    attachmentCount: 0,
    firstMessageAtUtc: '2026-05-01T10:00:00.000Z',
    lastMessageAtUtc: '2026-05-02T10:00:00.000Z',
    lastMessageText: 'hello',
    activityMonths: [
      ConversationSignatureMonth(year: 2026, month: 5, messageCount: 4),
    ],
  ),
  ConversationSignatureDisplayModel(
    conversationId: 43,
    title: 'Cathie',
    participantLabels: ['Cathie'],
    participantCount: 1,
    isGroup: false,
    messageCount: 2,
    attachmentCount: 0,
    firstMessageAtUtc: '2026-06-01T10:00:00.000Z',
    lastMessageAtUtc: '2026-06-02T10:00:00.000Z',
    lastMessageText: 'hi',
    activityMonths: [
      ConversationSignatureMonth(year: 2026, month: 6, messageCount: 2),
    ],
  ),
];

final _longSignature = ConversationSignatureDisplayModel(
  conversationId: 42,
  title: 'Long conversation',
  participantLabels: const ['Claire'],
  participantCount: 1,
  isGroup: false,
  messageCount: 17,
  attachmentCount: 0,
  firstMessageAtUtc: '2010-01-01T10:00:00.000Z',
  lastMessageAtUtc: '2026-01-01T10:00:00.000Z',
  lastMessageText: 'hello',
  activityMonths: [
    for (var year = 2010; year <= 2026; year++)
      ConversationSignatureMonth(year: year, month: 1, messageCount: 1),
  ],
);
