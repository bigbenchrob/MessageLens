import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/navigation/domain/entities/features/contacts_list_spec.dart';
import 'package:remember_this_text/features/contacts/application_pre_cassette/contacts_list_provider.dart';
import 'package:remember_this_text/features/contacts/application_pre_cassette/grouped_contacts_provider.dart';

import '../../../test_utils/contact_summary_fixture.dart';

void main() {
  group('groupedContactsProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          contactsListProvider(
            spec: const ContactsListSpec.alphabetical(),
          ).overrideWith(
            (ref) async => [
              buildContactSummary(participantId: 1, displayName: 'alice'),
              buildContactSummary(participantId: 2, displayName: 'Bob'),
              buildContactSummary(participantId: 3, displayName: '1Friend'),
              buildContactSummary(participantId: 4, displayName: 'Émile'),
            ],
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('groups contacts by first letter with non-alpha under #', () async {
      final grouped = await container.read(groupedContactsProvider.future);

      expect(grouped.groups['A']!.map((c) => c.displayName), ['alice']);
      expect(grouped.groups['B']!.map((c) => c.displayName), ['Bob']);
      expect(
        grouped.groups['#']!.map((c) => c.displayName),
        containsAll(['1Friend', 'Émile']),
      );
      expect(grouped.letterCounts, containsPair('A', 1));
      expect(grouped.letterCounts, containsPair('#', 2));
      expect(grouped.availableLetters, ['A', 'B', '#']);
    });

    test('letter counts provider proxies grouped data', () async {
      final counts = await container.read(
        groupedContactLetterCountsProvider.future,
      );

      expect(counts['A'], 1);
      expect(counts['B'], 1);
      expect(counts['#'], 2);
    });
  });
}
