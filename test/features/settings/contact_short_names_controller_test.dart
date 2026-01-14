import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/features/settings/application/contact_short_names/contact_short_names_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late OverlayDatabase testDb;

  setUp(() {
    // Create in-memory database for testing
    testDb = OverlayDatabase(NativeDatabase.memory());

    container = ProviderContainer(
      overrides: [overlayDatabaseProvider.overrideWith((ref) async => testDb)],
    );
  });

  tearDown(() async {
    await testDb.close();
    container.dispose();
  });

  test('defaults to empty mapping when no settings are stored', () async {
    final result = await container.read(contactShortNamesProvider.future);
    expect(result, isEmpty);
  });

  test('setShortName persists entries and updates state', () async {
    final notifier = container.read(contactShortNamesProvider.notifier);

    await notifier.setShortName(
      contactKey: 'participant:123',
      shortName: 'Claire',
    );

    final stored = await container.read(contactShortNamesProvider.future);
    expect(stored['participant:123'], 'Claire');

    // Verify in database by querying participant overrides
    final allShortNames = await testDb.getAllNicknamesByKey();
    expect(allShortNames['participant:123'], 'Claire');

    // Clear by setting to empty string
    await notifier.setShortName(contactKey: 'participant:123', shortName: '');
    final afterClear = await container.read(contactShortNamesProvider.future);
    expect(afterClear.containsKey('participant:123'), isFalse);
  });

  test('refresh re-reads values from storage', () async {
    // Add short name directly to database
    await testDb.setParticipantNickname(1, 'CJ');

    final notifier = container.read(contactShortNamesProvider.notifier);
    await notifier.refresh();

    final result = await container.read(contactShortNamesProvider.future);
    expect(result, equals({'participant:1': 'CJ'}));
  });
}
