import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'package:remember_this_text/essentials/db/shared/handle_identifier_utils.dart';
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

  test('groups identities by participant and shows their handles', () async {
    // Create participants
    await database
        .into(database.workingParticipants)
        .insert(
          WorkingParticipantsCompanion.insert(
            id: const drift.Value(1),
            originalName: 'Claire Jennings',
            displayName: 'Claire Jennings',
            shortName: 'Claire',
          ),
        );
    await database
        .into(database.workingParticipants)
        .insert(
          WorkingParticipantsCompanion.insert(
            id: const drift.Value(2),
            originalName: 'Mom',
            displayName: 'Mom',
            shortName: 'Mom',
          ),
        );
    await database
        .into(database.workingParticipants)
        .insert(
          WorkingParticipantsCompanion.insert(
            id: const drift.Value(4),
            originalName: '555-0300',
            displayName: '555-0300',
            shortName: '555-0300',
          ),
        );

    // Create handles
    await database
        .into(database.handlesCanonical)
        .insert(
          HandlesCanonicalCompanion.insert(
            id: const drift.Value(101),
            rawIdentifier: 'claire@example.com',
            displayName: 'claire@example.com',
            compoundIdentifier: buildCompoundIdentifier(
              normalizedIdentifier: 'claire@example.com',
              rawIdentifier: 'claire@example.com',
              service: 'iMessage',
            ),
            service: const drift.Value('iMessage'),
          ),
        );
    await database
        .into(database.handlesCanonical)
        .insert(
          HandlesCanonicalCompanion.insert(
            id: const drift.Value(102),
            rawIdentifier: '555-0100',
            displayName: '555-0100',
            compoundIdentifier: buildCompoundIdentifier(
              normalizedIdentifier: '555-0100',
              rawIdentifier: '555-0100',
              service: 'SMS',
            ),
            service: const drift.Value('SMS'),
          ),
        );
    await database
        .into(database.handlesCanonical)
        .insert(
          HandlesCanonicalCompanion.insert(
            id: const drift.Value(104),
            rawIdentifier: '555-0300',
            displayName: '555-0300',
            compoundIdentifier: buildCompoundIdentifier(
              normalizedIdentifier: '555-0300',
              rawIdentifier: '555-0300',
              service: 'SMS',
            ),
            service: const drift.Value('SMS'),
          ),
        );

    // Create handle_to_participant links
    await database
        .into(database.handleToParticipant)
        .insert(
          HandleToParticipantCompanion.insert(handleId: 101, participantId: 1),
        );
    await database
        .into(database.handleToParticipant)
        .insert(
          HandleToParticipantCompanion.insert(handleId: 102, participantId: 2),
        );
    await database
        .into(database.handleToParticipant)
        .insert(
          HandleToParticipantCompanion.insert(handleId: 104, participantId: 4),
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
    expect(
      claire.identities.first.normalizedAddress,
      buildCompoundIdentifier(
        normalizedIdentifier: 'claire@example.com',
        rawIdentifier: 'claire@example.com',
        service: 'iMessage',
      ),
    );
    expect(claire.identities.first.service, 'iMessage');

    // Participant 2 - Mom
    final mom = result.firstWhere(
      (entry) => entry.contactKey == 'participant:2',
    );
    expect(mom.identities.length, 1);
    expect(mom.displayName, 'Mom');
    expect(
      mom.identities.first.normalizedAddress,
      buildCompoundIdentifier(
        normalizedIdentifier: '555-0100',
        rawIdentifier: '555-0100',
        service: 'SMS',
      ),
    );
    expect(mom.identities.first.service, 'SMS');

    final individual = result.firstWhere(
      (entry) => entry.contactKey == 'participant:4',
    );
    expect(individual.identities.single.identityId, 4);
    expect(individual.displayName, '555-0300');
  });

  test('prefers alphabetic display names over numeric handles', () async {
    // Create participants
    await database
        .into(database.workingParticipants)
        .insert(
          WorkingParticipantsCompanion.insert(
            id: const drift.Value(10),
            originalName: '555-0400',
            displayName: '555-0400',
            shortName: '555-0400',
          ),
        );
    await database
        .into(database.workingParticipants)
        .insert(
          WorkingParticipantsCompanion.insert(
            id: const drift.Value(11),
            originalName: 'Jamie Rivera',
            displayName: 'Jamie Rivera',
            shortName: 'Jamie',
          ),
        );

    // Create handles
    await database
        .into(database.handlesCanonical)
        .insert(
          HandlesCanonicalCompanion.insert(
            id: const drift.Value(110),
            rawIdentifier: '555-0400',
            displayName: '555-0400',
            compoundIdentifier: buildCompoundIdentifier(
              normalizedIdentifier: '555-0400',
              rawIdentifier: '555-0400',
              service: 'SMS',
            ),
            service: const drift.Value('SMS'),
          ),
        );
    await database
        .into(database.handlesCanonical)
        .insert(
          HandlesCanonicalCompanion.insert(
            id: const drift.Value(111),
            rawIdentifier: 'beta@example.com',
            displayName: 'beta@example.com',
            compoundIdentifier: buildCompoundIdentifier(
              normalizedIdentifier: 'beta@example.com',
              rawIdentifier: 'beta@example.com',
              service: 'iMessage',
            ),
            service: const drift.Value('iMessage'),
          ),
        );

    // Create handle_to_participant links
    await database
        .into(database.handleToParticipant)
        .insert(
          HandleToParticipantCompanion.insert(handleId: 110, participantId: 10),
        );
    await database
        .into(database.handleToParticipant)
        .insert(
          HandleToParticipantCompanion.insert(handleId: 111, participantId: 11),
        );

    final result = await container.read(
      contactShortNameCandidatesProvider.future,
    );

    // Participant 11 has the alphabetic name
    final entry = result.firstWhere(
      (candidate) => candidate.contactKey == 'participant:11',
    );

    expect(entry.displayName, 'Jamie Rivera');
  });

  test(
    'falls back to handle when identities only contain numeric labels',
    () async {
      // Create participant
      await database
          .into(database.workingParticipants)
          .insert(
            WorkingParticipantsCompanion.insert(
              id: const drift.Value(20),
              originalName: '+12024742228',
              displayName: '+12024742228',
              shortName: '+12024742228',
            ),
          );

      // Create handle
      await database
          .into(database.handlesCanonical)
          .insert(
            HandlesCanonicalCompanion.insert(
              id: const drift.Value(120),
              rawIdentifier: '+12024742228',
              displayName: '+12024742228',
              compoundIdentifier: buildCompoundIdentifier(
                normalizedIdentifier: '+12024742228',
                rawIdentifier: '+12024742228',
                service: 'iMessage',
              ),
              service: const drift.Value('iMessage'),
            ),
          );

      // Create handle_to_participant link
      await database
          .into(database.handleToParticipant)
          .insert(
            HandleToParticipantCompanion.insert(
              handleId: 120,
              participantId: 20,
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
