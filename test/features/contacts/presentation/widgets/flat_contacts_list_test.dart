import 'package:flutter_test/flutter_test.dart';
import 'package:macos_ui/macos_ui.dart';

import 'package:remember_this_text/features/contacts/presentation/widgets/flat_contacts_list.dart';

import '../../../../test_utils/contact_summary_fixture.dart';

void main() {
  testWidgets('flat contacts list renders entries and handles selection',
      (tester) async {
    int? tappedId;

    await tester.pumpWidget(
      MacosApp(
        home: MacosWindow(
          child: FlatContactsList(
            contacts: [
              buildContactSummary(participantId: 1, displayName: 'Alice'),
              buildContactSummary(participantId: 2, displayName: 'Bob'),
            ],
            selectedParticipantId: null,
            onContactSelected: (id) {
              tappedId = id;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Bob'));
    expect(tappedId, 2);
  });
}
