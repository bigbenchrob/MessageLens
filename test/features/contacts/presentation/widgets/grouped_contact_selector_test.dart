import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import 'package:remember_this_text/features/contacts/application/grouped_contacts_provider.dart';
import 'package:remember_this_text/features/contacts/presentation/widgets/grouped_contact_selector.dart';

import '../../../../test_utils/contact_summary_fixture.dart';

void main() {
  testWidgets('grouped selector renders sections and handles taps',
      (tester) async {
    final grouped = GroupedContacts(
      groups: {
        'A': [
          buildContactSummary(participantId: 1, displayName: 'Alice'),
        ],
        'B': [
          buildContactSummary(participantId: 2, displayName: 'Bob'),
        ],
      },
      letterCounts: const {'A': 1, 'B': 1},
      availableLetters: const ['A', 'B'],
    );

    int? tappedId;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          groupedContactsProvider.overrideWith((ref) async => grouped),
        ],
        child: MacosApp(
          home: MacosWindow(
            child: GroupedContactSelector(
              selectedParticipantId: null,
              onContactSelected: (id) {
                tappedId = id;
              },
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Grouped contacts (preview)'), findsOneWidget);
    expect(find.text('A'), findsWidgets);
    expect(find.text('B'), findsWidgets);

    await tester.tap(find.text('Bob'));
    expect(tappedId, 2);
  });
}
