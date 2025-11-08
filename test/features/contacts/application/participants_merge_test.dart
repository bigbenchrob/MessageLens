import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'package:remember_this_text/features/contacts/application/participants_for_picker_provider.dart';
import 'package:remember_this_text/features/contacts/domain/participant_origin.dart';

String buildCompoundIdentifier({
  required String normalizedIdentifier,
  required String rawIdentifier,
  required String service,
}) {
  return '${normalizedIdentifier}_${rawIdentifier}_$service';
}

void main() {
  group('participantsForPickerProvider', () {
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
      'merges working and virtual participants with correct origins',
      () async {
        final workingHandleId = await workingDb
            .into(workingDb.handlesCanonical)
            .insert(
              HandlesCanonicalCompanion.insert(
                rawIdentifier: '+17785551234',
                displayName: '+17785551234',
                compoundIdentifier: buildCompoundIdentifier(
                  normalizedIdentifier: '+17785551234',
                  rawIdentifier: '+17785551234',
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

        final virtualContact = await overlayDb.createVirtualParticipant(
          displayName: 'Virtual Friend',
        );

        final virtualHandleId = await workingDb
            .into(workingDb.handlesCanonical)
            .insert(
              HandlesCanonicalCompanion.insert(
                rawIdentifier: '+17785559876',
                displayName: '+17785559876',
                compoundIdentifier: buildCompoundIdentifier(
                  normalizedIdentifier: '+17785559876',
                  rawIdentifier: '+17785559876',
                  service: 'SMS',
                ),
                service: const drift.Value('SMS'),
              ),
            );

        await overlayDb.setHandleOverride(virtualHandleId, virtualContact.id);

        final results = await container.read(
          participantsForPickerProvider(searchQuery: '').future,
        );

        expect(results, hasLength(2));
        expect(results.first.origin, ParticipantOrigin.working);
        expect(results.first.handleCount, equals(1));
        expect(results.last.origin, ParticipantOrigin.overlayVirtual);
        expect(results.last.displayName, equals('Virtual Friend'));
        expect(results.last.handleCount, equals(1));
        expect(results.last.isVirtual, isTrue);
      },
    );

    test('filters virtual participants by search query', () async {
      await workingDb
          .into(workingDb.workingParticipants)
          .insert(
            WorkingParticipantsCompanion.insert(
              originalName: 'Alice Wonderland',
              displayName: 'Alice Wonderland',
              shortName: 'Alice',
            ),
          );

      final virtualContact = await overlayDb.createVirtualParticipant(
        displayName: 'Overlay Only',
      );

      final results = await container.read(
        participantsForPickerProvider(searchQuery: 'overlay').future,
      );

      expect(results, hasLength(1));
      expect(results.first.id, virtualContact.id);
      expect(results.first.origin, ParticipantOrigin.overlayVirtual);
    });
  });
}
