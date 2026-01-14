import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'package:remember_this_text/features/contacts/application_pre_cassette/participants_search_provider.dart';
import 'package:remember_this_text/features/contacts/domain/participant_origin.dart';

String buildCompoundIdentifier({
  required String normalizedIdentifier,
  required String rawIdentifier,
  required String service,
}) {
  return '${normalizedIdentifier}_${rawIdentifier}_$service';
}

void main() {
  group('participantsSearchProvider', () {
    late OverlayDatabase overlayDb;
    late WorkingDatabase workingDb;
    late ProviderContainer container;

    setUp(() {
      overlayDb = OverlayDatabase(NativeDatabase.memory());
      workingDb = WorkingDatabase(NativeDatabase.memory());

      container = ProviderContainer(
        overrides: [
          overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
          driftWorkingDatabaseProvider.overrideWith((ref) async => workingDb),
        ],
      );
    });

    tearDown(() async {
      await overlayDb.close();
      await workingDb.close();
      container.dispose();
    });

    test(
      'returns working and virtual participants while filtering placeholders',
      () async {
        final workingHandleId = await workingDb
            .into(workingDb.handlesCanonical)
            .insert(
              HandlesCanonicalCompanion.insert(
                rawIdentifier: '+15550003',
                displayName: '+15550003',
                compoundIdentifier: buildCompoundIdentifier(
                  normalizedIdentifier: '+15550003',
                  rawIdentifier: '+15550003',
                  service: 'SMS',
                ),
                service: const drift.Value('SMS'),
              ),
            );

        final workingParticipantId = await workingDb
            .into(workingDb.workingParticipants)
            .insert(
              WorkingParticipantsCompanion.insert(
                originalName: 'Existing Person',
                displayName: 'Existing Person',
                shortName: 'Existing',
              ),
            );

        await workingDb
            .into(workingDb.handleToParticipant)
            .insert(
              HandleToParticipantCompanion.insert(
                handleId: workingHandleId,
                participantId: workingParticipantId,
                confidence: const drift.Value(1.0),
                source: const drift.Value('addressbook'),
              ),
            );

        await overlayDb.setParticipantNickname(
          workingParticipantId,
          'Preferred Existing',
        );

        final placeholderParticipantId = await workingDb
            .into(workingDb.workingParticipants)
            .insert(
              WorkingParticipantsCompanion.insert(
                originalName: 'Unknown Contact',
                displayName: 'Unknown Contact',
                shortName: 'Unknown Contact',
              ),
            );

        final placeholderHandleId = await workingDb
            .into(workingDb.handlesCanonical)
            .insert(
              HandlesCanonicalCompanion.insert(
                rawIdentifier: '+15559999',
                displayName: '+15559999',
                compoundIdentifier: buildCompoundIdentifier(
                  normalizedIdentifier: '+15559999',
                  rawIdentifier: '+15559999',
                  service: 'SMS',
                ),
                service: const drift.Value('SMS'),
              ),
            );

        await workingDb
            .into(workingDb.handleToParticipant)
            .insert(
              HandleToParticipantCompanion.insert(
                handleId: placeholderHandleId,
                participantId: placeholderParticipantId,
                confidence: const drift.Value(1.0),
                source: const drift.Value('addressbook'),
              ),
            );

        final virtualContact = await overlayDb.createVirtualParticipant(
          displayName: 'Virtual Friend',
        );

        final results = await container.read(
          participantsSearchProvider(query: '').future,
        );

        expect(results.length, equals(2));

        final workingResult = results.firstWhere(
          (result) => result.id == workingParticipantId,
        );
        expect(workingResult.origin, ParticipantOrigin.overlayOverride);
        expect(workingResult.shortName, 'Preferred Existing');
        expect(workingResult.handleCount, equals(1));
        expect(workingResult.isVirtual, isFalse);

        final virtualResult = results.firstWhere(
          (result) => result.id == virtualContact.id,
        );
        expect(virtualResult.origin, ParticipantOrigin.overlayVirtual);
        expect(virtualResult.handleCount, equals(0));
        expect(virtualResult.isVirtual, isTrue);

        expect(
          results.any((result) => result.displayName == 'Unknown Contact'),
          isFalse,
        );
      },
    );

    test('filters by query string case-insensitively', () async {
      final participantId = await workingDb
          .into(workingDb.workingParticipants)
          .insert(
            WorkingParticipantsCompanion.insert(
              originalName: 'Search Target',
              displayName: 'Search Target',
              shortName: 'Target',
            ),
          );

      final handleId = await workingDb
          .into(workingDb.handlesCanonical)
          .insert(
            HandlesCanonicalCompanion.insert(
              rawIdentifier: '+15557777',
              displayName: '+15557777',
              compoundIdentifier: buildCompoundIdentifier(
                normalizedIdentifier: '+15557777',
                rawIdentifier: '+15557777',
                service: 'SMS',
              ),
              service: const drift.Value('SMS'),
            ),
          );

      await workingDb
          .into(workingDb.handleToParticipant)
          .insert(
            HandleToParticipantCompanion.insert(
              handleId: handleId,
              participantId: participantId,
              confidence: const drift.Value(1.0),
              source: const drift.Value('addressbook'),
            ),
          );

      final results = await container.read(
        participantsSearchProvider(query: 'target').future,
      );

      expect(results, hasLength(1));
      expect(results.first.id, equals(participantId));
    });
  });
}
