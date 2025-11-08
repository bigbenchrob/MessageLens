import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/features/contacts/application/virtual_participants_provider.dart';

void main() {
  group('virtualParticipantsProvider', () {
    late OverlayDatabase overlayDb;
    late ProviderContainer container;

    setUp(() {
      overlayDb = OverlayDatabase(NativeDatabase.memory());
      container = ProviderContainer(
        overrides: [
          overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
        ],
      );
    });

    tearDown(() async {
      await overlayDb.close();
      container.dispose();
    });

    test('returns empty list when no virtual contacts exist', () async {
      final result = await container.read(virtualParticipantsProvider.future);
      expect(result, isEmpty);
    });

    test('returns sorted virtual participants', () async {
      await overlayDb.createVirtualParticipant(displayName: 'Charlie');
      await overlayDb.createVirtualParticipant(displayName: 'Alice');
      await overlayDb.createVirtualParticipant(displayName: 'Bob');

      final result = await container.read(virtualParticipantsProvider.future);
      expect(
        result.map((row) => row.displayName),
        orderedEquals(['Alice', 'Bob', 'Charlie']),
      );
    });
  });
}
