import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/resolver_tools/favorite_contacts_provider.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/resolver_tools/favorite_contacts_repository_provider.dart';
import 'package:remember_this_text/features/contacts/infrastructure/repositories/contacts_list_repository.dart';
import 'package:remember_this_text/features/contacts/infrastructure/repositories/favorite_contacts_repository.dart';

import '../../../test_utils/contact_summary_fixture.dart';

void main() {
  group('favoriteContactsProvider', () {
    late OverlayDatabase overlayDb;
    ProviderContainer? container;

    setUp(() {
      overlayDb = OverlayDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await overlayDb.close();
      container?.dispose();
    });

    test(
      'returns resolved favorites ordered by last interaction, newest first',
      () async {
        await overlayDb.addFavorite(1, DateTime.utc(2024, 12, 1));
        await overlayDb.addFavorite(2, DateTime.utc(2024, 12, 5));

        container = ProviderContainer(
          overrides: [
            favoriteContactsRepositoryProvider.overrideWith(
              (ref) async => FavoriteContactsRepository(overlayDb),
            ),
            contactsListRepositoryProvider.overrideWith(
              (ref) async => [
                buildContactSummary(participantId: 1, displayName: 'Alice'),
                buildContactSummary(participantId: 2, displayName: 'Bob'),
              ],
            ),
          ],
        );

        final results = await container!.read(favoriteContactsProvider.future);

        expect(results, hasLength(2));
        expect(
          results.map((entry) => entry.contact.participantId),
          equals([2, 1]), // lastInteractionUtc desc
        );
      },
    );

    test('excludes favorites without matching contact summaries', () async {
      await overlayDb.addFavorite(1, DateTime.utc(2024, 12, 1));

      container = ProviderContainer(
        overrides: [
          favoriteContactsRepositoryProvider.overrideWith(
            (ref) async => FavoriteContactsRepository(overlayDb),
          ),
          contactsListRepositoryProvider.overrideWith(
            (ref) async => [
              buildContactSummary(participantId: 2, displayName: 'Bob'),
            ],
          ),
        ],
      );

      final results = await container!.read(favoriteContactsProvider.future);

      expect(results, isEmpty);
    });
  });
}
