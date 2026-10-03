import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart'
    show driftConversationGraphDatabaseProvider, overlayDatabaseProvider;
import 'package:remember_this_text/essentials/db/feature_level_providers/message_data_version_provider.dart'
    show messageDataVersionProvider;
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/features/contacts/application/display_identity/display_identity_resolver_provider.dart';

import '../../../../essentials/conversation_graph/conversation_graph_test_database.dart';

void main() {
  late ConversationGraphDatabase graphDb;
  late OverlayDatabase overlayDb;
  late ProviderContainer container;

  setUp(() async {
    graphDb = await openConversationGraphTestDatabase();
    overlayDb = OverlayDatabase(NativeDatabase.memory());
    await overlayDb.customSelect('SELECT 1').get();

    container = ProviderContainer(
      overrides: [
        driftConversationGraphDatabaseProvider.overrideWith(
          (ref) async => graphDb,
        ),
        overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await graphDb.close();
    await overlayDb.close();
  });

  test(
    'first construction reads identities from the populated graph',
    () async {
      await _insertGraphIdentity(
        graphDb,
        contactId: 9001,
        displayName: 'Claire Merriman Campbell',
        handleId: 7001,
        handleValue: '+17789908506',
      );

      final subscription = container.listen(
        displayIdentityResolverProvider,
        (_, _) {},
      );
      try {
        final resolver = await container.read(
          displayIdentityResolverProvider.future,
        );

        expect(
          resolver.resolveContact(9001).primaryLabel,
          'Claire Merriman Campbell',
        );
        expect(
          resolver.resolveParticipantForHandle('+17789908506').primaryLabel,
          'Claire Merriman Campbell',
        );
      } finally {
        subscription.close();
      }
    },
  );

  test('message-data generation rebuilds a retained resolver', () async {
    final subscription = container.listen(
      displayIdentityResolverProvider,
      (_, _) {},
    );
    try {
      final initialResolver = await container.read(
        displayIdentityResolverProvider.future,
      );
      expect(initialResolver.resolveContact(9001).primaryLabel, 'contact 9001');

      await _insertGraphIdentity(
        graphDb,
        contactId: 9001,
        displayName: 'Claire Merriman Campbell',
        handleId: 7001,
        handleValue: '+17789908506',
      );

      final resolverBeforeGenerationChange = await container.read(
        displayIdentityResolverProvider.future,
      );
      expect(resolverBeforeGenerationChange, same(initialResolver));
      expect(
        resolverBeforeGenerationChange.resolveContact(9001).primaryLabel,
        'contact 9001',
      );

      container.read(messageDataVersionProvider.notifier).bump();

      final refreshedResolver = await container.read(
        displayIdentityResolverProvider.future,
      );
      expect(refreshedResolver, isNot(same(initialResolver)));
      expect(
        refreshedResolver.resolveContact(9001).primaryLabel,
        'Claire Merriman Campbell',
      );
      expect(
        refreshedResolver
            .resolveParticipantForHandle('+17789908506')
            .primaryLabel,
        'Claire Merriman Campbell',
      );
    } finally {
      subscription.close();
    }
  });
}

Future<void> _insertGraphIdentity(
  ConversationGraphDatabase graphDb, {
  required int contactId,
  required String displayName,
  required int handleId,
  required String handleValue,
}) async {
  await graphDb.database.insert('contacts', <String, Object?>{
    'contact_id': contactId,
    'display_name': displayName,
  });
  await graphDb.database.insert('handles', <String, Object?>{
    'ss_id': handleId,
    'id': handleValue,
    'service': 'iMessage',
    'is_me': 0,
  });
  await graphDb.database.insert('contact_to_handle', <String, Object?>{
    'contact_id': contactId,
    'handle_ss_id': handleId,
    'handle_value': handleValue,
  });
}
