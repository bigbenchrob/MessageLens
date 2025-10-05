import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'package:remember_this_text/features/settings/application/contact_short_names/contact_short_name_candidates_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late WorkingDatabase database;
  late ProviderContainer container;

  setUp(() async {
    database = WorkingDatabase(NativeDatabase.memory());
    await database.customStatement('PRAGMA foreign_keys = ON');

    container = ProviderContainer(
      overrides: [
        driftWorkingDatabaseProvider.overrideWith((ref) async => database),
      ],
    );
  });

  tearDown(() async {
    await database.close();
    container.dispose();
  });

  test(
    'groups identities by contactRef and ignores system identities',
    () async {
      await database
          .into(database.workingParticipants)
          .insert(
            WorkingParticipantsCompanion.insert(
              id: const drift.Value(1),
              normalizedAddress: const drift.Value('claire@example.com'),
              service: const drift.Value('iMessage'),
              displayName: const drift.Value('Claire Jennings'),
              contactRef: const drift.Value('alpha'),
              isSystem: const drift.Value(false),
            ),
          );
      await database
          .into(database.workingParticipants)
          .insert(
            WorkingParticipantsCompanion.insert(
              id: const drift.Value(2),
              normalizedAddress: const drift.Value('555-0100'),
              service: const drift.Value('SMS'),
              displayName: const drift.Value('Mom'),
              contactRef: const drift.Value('alpha'),
              isSystem: const drift.Value(false),
            ),
          );
      await database
          .into(database.workingParticipants)
          .insert(
            WorkingParticipantsCompanion.insert(
              id: const drift.Value(3),
              normalizedAddress: const drift.Value('555-0200'),
              service: const drift.Value('SMS'),
              displayName: const drift.Value('Backup Line'),
              isSystem: const drift.Value(true),
            ),
          );
      await database
          .into(database.workingParticipants)
          .insert(
            WorkingParticipantsCompanion.insert(
              id: const drift.Value(4),
              normalizedAddress: const drift.Value('555-0300'),
              service: const drift.Value('SMS'),
              isSystem: const drift.Value(false),
            ),
          );

      final result = await container.read(
        contactShortNameCandidatesProvider.future,
      );
      expect(result.length, 3);

      // Participant 1 - Claire Jennings
      final claire = result.firstWhere(
        (entry) => entry.contactKey == 'participant:1',
      );
      expect(claire.identities.length, 1);
      expect(claire.displayName, 'Claire Jennings');

      // Participant 2 - Mom
      final mom = result.firstWhere(
        (entry) => entry.contactKey == 'participant:2',
      );
      expect(mom.identities.length, 1);
      expect(mom.displayName, 'Mom');

      final individual = result.firstWhere(
        (entry) => entry.contactKey == 'participant:4',
      );
      expect(individual.identities.single.identityId, 4);
      expect(individual.displayName, '555-0300');
    },
  );

  test('prefers alphabetic display names over numeric handles', () async {
    await database
        .into(database.workingParticipants)
        .insert(
          WorkingParticipantsCompanion.insert(
            id: const drift.Value(10),
            normalizedAddress: const drift.Value('555-0400'),
            service: const drift.Value('SMS'),
            displayName: const drift.Value('555-0400'),
            contactRef: const drift.Value('beta'),
            isSystem: const drift.Value(false),
          ),
        );
    await database
        .into(database.workingParticipants)
        .insert(
          WorkingParticipantsCompanion.insert(
            id: const drift.Value(11),
            normalizedAddress: const drift.Value('beta@example.com'),
            service: const drift.Value('iMessage'),
            displayName: const drift.Value('Jamie Rivera'),
            contactRef: const drift.Value('beta'),
            isSystem: const drift.Value(false),
          ),
        );

    final result = await container.read(
      contactShortNameCandidatesProvider.future,
    );

    // Participant 10 has the alphabetic name
    final entry = result.firstWhere(
      (candidate) => candidate.contactKey == 'participant:11',
    );

    expect(entry.displayName, 'Jamie Rivera');
  });

  test(
    'falls back to handle when identities only contain numeric labels',
    () async {
      await database
          .into(database.workingParticipants)
          .insert(
            WorkingParticipantsCompanion.insert(
              id: const drift.Value(20),
              normalizedAddress: const drift.Value('+12024742228'),
              service: const drift.Value('iMessage'),
              displayName: const drift.Value('+12024742228'),
              contactRef: const drift.Value('gamma'),
              isSystem: const drift.Value(false),
            ),
          );

      final result = await container.read(
        contactShortNameCandidatesProvider.future,
      );

      final entry = result.firstWhere(
        (candidate) => candidate.contactKey == 'participant:20',
      );

      expect(entry.displayName, '+12024742228');
    },
  );
}
