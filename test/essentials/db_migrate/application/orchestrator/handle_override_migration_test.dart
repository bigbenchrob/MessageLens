import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../lib/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../../../../lib/essentials/db/infrastructure/data_sources/local/working/working_database.dart';

// Helper to build compound identifier
String buildCompoundIdentifier({
  required String normalizedIdentifier,
  required String rawIdentifier,
  required String service,
}) {
  return '${normalizedIdentifier}_${rawIdentifier}_$service';
}

void main() {
  group('Handle Override Migration Integration', () {
    late OverlayDatabase overlayDb;
    late WorkingDatabase workingDb;

    setUp(() {
      overlayDb = OverlayDatabase(NativeDatabase.memory());
      workingDb = WorkingDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await overlayDb.close();
      await workingDb.close();
    });

    test('overlay handle overrides survive migration', () async {
      // Create handle and participant in working DB
      final handleId = await workingDb
          .into(workingDb.handlesCanonical)
          .insert(
            HandlesCanonicalCompanion.insert(
              rawIdentifier: '+17789908506',
              displayName: '+17789908506',
              compoundIdentifier: buildCompoundIdentifier(
                normalizedIdentifier: '+17789908506',
                rawIdentifier: '+17789908506',
                service: 'SMS',
              ),
              service: const drift.Value('SMS'),
            ),
          );

      final participantId = await workingDb
          .into(workingDb.workingParticipants)
          .insert(
            WorkingParticipantsCompanion.insert(
              originalName: 'Rusung Tan',
              displayName: 'Rusung Tan',
              shortName: 'Rusung',
            ),
          );

      // Create manual override in overlay DB
      await overlayDb.setHandleOverride(handleId, participantId);

      // Verify override exists
      final override = await overlayDb.getHandleOverride(handleId);
      expect(override, isNotNull);
      expect(override!.handleId, handleId);
      expect(override.participantId, participantId);
      expect(override.source, 'user_manual');
      expect(override.confidence, 1.0);

      // Simulate migration: Read overrides from overlay DB
      final overrides = await overlayDb.getAllHandleOverrides();
      expect(overrides, hasLength(1));

      // Simulate migration: Clear working DB (except handles/participants for test simplicity)
      await workingDb.delete(workingDb.handleToParticipant).go();

      // Simulate migration: Restore overrides
      for (final o in overrides) {
        await workingDb
            .into(workingDb.handleToParticipant)
            .insertOnConflictUpdate(
              HandleToParticipantCompanion.insert(
                handleId: o.handleId,
                participantId: o.participantId,
                confidence: const drift.Value(1.0),
                source: const drift.Value('user_manual'),
              ),
            );
      }

      // Verify override was restored to working DB
      final links = await workingDb.select(workingDb.handleToParticipant).get();
      expect(links, hasLength(1));
      expect(links.first.handleId, handleId);
      expect(links.first.participantId, participantId);
      expect(links.first.source, 'user_manual');
      expect(links.first.confidence, 1.0);
    });

    test('manual overrides override AddressBook links', () async {
      // Create handle and two participants
      final handleId = await workingDb
          .into(workingDb.handlesCanonical)
          .insert(
            HandlesCanonicalCompanion.insert(
              rawIdentifier: '+17789908506',
              displayName: '+17789908506',
              compoundIdentifier: buildCompoundIdentifier(
                normalizedIdentifier: '+17789908506',
                rawIdentifier: '+17789908506',
                service: 'SMS',
              ),
              service: const drift.Value('SMS'),
            ),
          );

      final wrongParticipantId = await workingDb
          .into(workingDb.workingParticipants)
          .insert(
            WorkingParticipantsCompanion.insert(
              originalName: 'Wrong Person',
              displayName: 'Wrong Person',
              shortName: 'Wrong',
            ),
          );

      final correctParticipantId = await workingDb
          .into(workingDb.workingParticipants)
          .insert(
            WorkingParticipantsCompanion.insert(
              originalName: 'Rusung Tan',
              displayName: 'Rusung Tan',
              shortName: 'Rusung',
            ),
          );

      // Simulate AddressBook automatic link (wrong participant)
      await workingDb
          .into(workingDb.handleToParticipant)
          .insert(
            HandleToParticipantCompanion.insert(
              handleId: handleId,
              participantId: wrongParticipantId,
              confidence: const drift.Value(1.0),
              source: const drift.Value('addressbook'),
            ),
          );

      // User manually corrects the link in overlay DB
      await overlayDb.setHandleOverride(handleId, correctParticipantId);

      // Simulate migration restoration
      // Note: Must delete old AddressBook link first because UNIQUE constraint
      // is on (handleId, participantId) pair, allowing multiple participants per handle
      await (workingDb.delete(workingDb.handleToParticipant)..where(
            (tbl) =>
                tbl.handleId.equals(handleId) &
                tbl.source.equals('addressbook'),
          ))
          .go();

      final overrides = await overlayDb.getAllHandleOverrides();
      for (final o in overrides) {
        await workingDb
            .into(workingDb.handleToParticipant)
            .insert(
              HandleToParticipantCompanion.insert(
                handleId: o.handleId,
                participantId: o.participantId,
                confidence: const drift.Value(1.0),
                source: const drift.Value('user_manual'),
              ),
            );
      }

      // Verify manual override replaced AddressBook link
      final links = await workingDb.select(workingDb.handleToParticipant).get();
      expect(links, hasLength(1));
      expect(links.first.handleId, handleId);
      expect(links.first.participantId, correctParticipantId); // Corrected!
      expect(links.first.source, 'user_manual');
    });

    test('multiple handle overrides restored correctly', () async {
      // Create 3 handles and participants
      final handles = <int>[];
      final participants = <int>[];

      for (var i = 1; i <= 3; i++) {
        final handleId = await workingDb
            .into(workingDb.handlesCanonical)
            .insert(
              HandlesCanonicalCompanion.insert(
                rawIdentifier: '+1778990850$i',
                displayName: '+1778990850$i',
                compoundIdentifier: buildCompoundIdentifier(
                  normalizedIdentifier: '+1778990850$i',
                  rawIdentifier: '+1778990850$i',
                  service: 'SMS',
                ),
                service: const drift.Value('SMS'),
              ),
            );
        handles.add(handleId);

        final participantId = await workingDb
            .into(workingDb.workingParticipants)
            .insert(
              WorkingParticipantsCompanion.insert(
                originalName: 'Person $i',
                displayName: 'Person $i',
                shortName: 'P$i',
              ),
            );
        participants.add(participantId);

        // Create overlay overrides
        await overlayDb.setHandleOverride(handleId, participantId);
      }

      // Simulate migration
      final overrides = await overlayDb.getAllHandleOverrides();
      expect(overrides, hasLength(3));

      await workingDb.delete(workingDb.handleToParticipant).go();

      for (final o in overrides) {
        await workingDb
            .into(workingDb.handleToParticipant)
            .insertOnConflictUpdate(
              HandleToParticipantCompanion.insert(
                handleId: o.handleId,
                participantId: o.participantId,
                confidence: const drift.Value(1.0),
                source: const drift.Value('user_manual'),
              ),
            );
      }

      // Verify all overrides restored
      final links = await workingDb.select(workingDb.handleToParticipant).get();
      expect(links, hasLength(3));

      for (var i = 0; i < 3; i++) {
        expect(links[i].handleId, handles[i]);
        expect(links[i].participantId, participants[i]);
        expect(links[i].source, 'user_manual');
      }
    });

    test('empty override list handled gracefully', () async {
      // No overrides in overlay DB
      final overrides = await overlayDb.getAllHandleOverrides();
      expect(overrides, isEmpty);

      // Simulate migration with empty overrides - should not throw
      expect(() async {
        for (final o in overrides) {
          await workingDb
              .into(workingDb.handleToParticipant)
              .insertOnConflictUpdate(
                HandleToParticipantCompanion.insert(
                  handleId: o.handleId,
                  participantId: o.participantId,
                  confidence: const drift.Value(1.0),
                  source: const drift.Value('user_manual'),
                ),
              );
        }
      }, returnsNormally);

      // No links should exist
      final links = await workingDb.select(workingDb.handleToParticipant).get();
      expect(links, isEmpty);
    });
  });
}
