import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'package:remember_this_text/features/contacts/application_pre_cassette/manual_handle_link_service.dart';

// Helper to build compound identifier
String buildCompoundIdentifier({
  required String normalizedIdentifier,
  required String rawIdentifier,
  required String service,
}) {
  return '${normalizedIdentifier}_${rawIdentifier}_$service';
}

void main() {
  group('ManualHandleLinkService', () {
    late OverlayDatabase overlayDb;
    late WorkingDatabase workingDb;
    late ProviderContainer container;

    setUp(() {
      overlayDb = OverlayDatabase(NativeDatabase.memory());
      workingDb = WorkingDatabase(NativeDatabase.memory());

      // Create container with overridden database providers
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

    test('linkHandleToParticipant creates link successfully', () async {
      // Arrange: Create handle and participant
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

      // Act: Link handle to participant
      final service = container.read(manualHandleLinkServiceProvider.notifier);
      final result = await service.linkHandleToParticipant(
        handleId: handleId,
        participantId: participantId,
      );

      // Assert: Link was created successfully
      expect(result.isRight(), isTrue);

      // Verify overlay DB link
      final overlayLink = await overlayDb.getHandleOverride(handleId);
      expect(overlayLink, isNotNull);
      expect(overlayLink!.handleId, handleId);
      expect(overlayLink.participantId, participantId);
      expect(overlayLink.source, 'user_manual');
      expect(overlayLink.confidence, 1.0);

      // Verify working DB link
      final workingLinks = await (workingDb.select(
        workingDb.handleToParticipant,
      )..where((tbl) => tbl.handleId.equals(handleId))).get();
      expect(workingLinks, hasLength(1));
      expect(workingLinks.first.handleId, handleId);
      expect(workingLinks.first.participantId, participantId);
    });

    test('linkHandleToParticipant overrides automatic link', () async {
      // Arrange: Create handle and two participants
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

      // Create automatic link (wrong participant)
      await workingDb
          .into(workingDb.handleToParticipant)
          .insert(
            HandleToParticipantCompanion.insert(
              handleId: handleId,
              participantId: wrongParticipantId,
              confidence: const drift.Value(0.8),
              source: const drift.Value('addressbook'),
            ),
          );

      // Act: Manually correct the link
      final service = container.read(manualHandleLinkServiceProvider.notifier);
      final result = await service.linkHandleToParticipant(
        handleId: handleId,
        participantId: correctParticipantId,
      );

      // Assert: Manual link replaced automatic link
      expect(result.isRight(), isTrue);

      // Verify working DB link was replaced (INSERT OR REPLACE)
      final workingLinks = await (workingDb.select(
        workingDb.handleToParticipant,
      )..where((tbl) => tbl.handleId.equals(handleId))).get();
      expect(workingLinks, hasLength(1));
      expect(workingLinks.first.handleId, handleId);
      expect(workingLinks.first.participantId, correctParticipantId);
    });

    test(
      'linkHandleToParticipant prevents duplicate manual link to different participant',
      () async {
        // Arrange: Create handle and two participants
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

        final participant1 = await workingDb
            .into(workingDb.workingParticipants)
            .insert(
              WorkingParticipantsCompanion.insert(
                originalName: 'Person One',
                displayName: 'Person One',
                shortName: 'One',
              ),
            );

        final participant2 = await workingDb
            .into(workingDb.workingParticipants)
            .insert(
              WorkingParticipantsCompanion.insert(
                originalName: 'Person Two',
                displayName: 'Person Two',
                shortName: 'Two',
              ),
            );

        // Create first manual link
        final service = container.read(
          manualHandleLinkServiceProvider.notifier,
        );
        await service.linkHandleToParticipant(
          handleId: handleId,
          participantId: participant1,
        );

        // Act: Try to link to different participant
        final result = await service.linkHandleToParticipant(
          handleId: handleId,
          participantId: participant2,
        );

        // Assert: Error returned
        expect(result.isLeft(), isTrue);
        result.fold((failure) {
          expect(
            failure.message,
            contains('already manually linked to a different contact'),
          );
        }, (_) => fail('Expected Left(Failure) but got Right(Unit)'));

        // Verify original link unchanged
        final overlayLink = await overlayDb.getHandleOverride(handleId);
        expect(overlayLink!.participantId, participant1);
      },
    );

    test(
      'linkHandleToParticipant allows re-linking to same participant',
      () async {
        // Arrange: Create handle and participant
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

        // Create initial link
        final service = container.read(
          manualHandleLinkServiceProvider.notifier,
        );
        await service.linkHandleToParticipant(
          handleId: handleId,
          participantId: participantId,
        );

        // Act: Link again to same participant (idempotent)
        final result = await service.linkHandleToParticipant(
          handleId: handleId,
          participantId: participantId,
        );

        // Assert: Success
        expect(result.isRight(), isTrue);
      },
    );

    test('unlinkHandle removes manual link successfully', () async {
      // Arrange: Create handle, participant, and manual link
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

      final service = container.read(manualHandleLinkServiceProvider.notifier);
      await service.linkHandleToParticipant(
        handleId: handleId,
        participantId: participantId,
      );

      // Act: Unlink handle
      final result = await service.unlinkHandle(handleId: handleId);

      // Assert: Link removed successfully
      expect(result.isRight(), isTrue);

      // Verify overlay link removed
      final overlayLink = await overlayDb.getHandleOverride(handleId);
      expect(overlayLink, isNull);

      // Verify working DB link removed
      final workingLinks = await (workingDb.select(
        workingDb.handleToParticipant,
      )..where((tbl) => tbl.handleId.equals(handleId))).get();
      expect(workingLinks, isEmpty);
    });

    test('unlinkHandle returns error when no manual link exists', () async {
      // Act: Try to unlink non-existent link
      final service = container.read(manualHandleLinkServiceProvider.notifier);
      final result = await service.unlinkHandle(handleId: 999);

      // Assert: Error returned
      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure.message, contains('No manual link found'));
      }, (_) => fail('Expected Left(Failure) but got Right(Unit)'));
    });
  });
}
