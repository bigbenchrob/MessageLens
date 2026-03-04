import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'package:remember_this_text/features/contacts/domain/participant_origin.dart';
import 'package:remember_this_text/features/contacts/infrastructure/repositories/contacts_list_repository.dart';

String buildCompoundIdentifier({
  required String normalizedIdentifier,
  required String rawIdentifier,
  required String service,
}) {
  return '${normalizedIdentifier}_${rawIdentifier}_$service';
}

void main() {
  group('contactsListRepositoryProvider', () {
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

    test('includes virtual participants with overlay origin', () async {
      final handleId = await workingDb
          .into(workingDb.handlesCanonical)
          .insert(
            HandlesCanonicalCompanion.insert(
              rawIdentifier: '+15550001',
              displayName: '+15550001',
              compoundIdentifier: buildCompoundIdentifier(
                normalizedIdentifier: '+15550001',
                rawIdentifier: '+15550001',
                service: 'SMS',
              ),
              service: const drift.Value('SMS'),
            ),
          );

      final participantId = await workingDb
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
              handleId: handleId,
              participantId: participantId,
              confidence: const drift.Value(1.0),
              source: const drift.Value('addressbook'),
            ),
          );

      final chatId = await workingDb
          .into(workingDb.workingChats)
          .insert(WorkingChatsCompanion.insert(guid: 'chat-1'));

      await workingDb
          .into(workingDb.chatToHandle)
          .insert(
            ChatToHandleCompanion.insert(
              chatId: chatId,
              handleId: handleId,
              role: const drift.Value('member'),
            ),
          );

      final virtualHandleId = await workingDb
          .into(workingDb.handlesCanonical)
          .insert(
            HandlesCanonicalCompanion.insert(
              rawIdentifier: '+15550002',
              displayName: '+15550002',
              compoundIdentifier: buildCompoundIdentifier(
                normalizedIdentifier: '+15550002',
                rawIdentifier: '+15550002',
                service: 'SMS',
              ),
              service: const drift.Value('SMS'),
            ),
          );

      await workingDb
          .into(workingDb.chatToHandle)
          .insert(
            ChatToHandleCompanion.insert(
              chatId: chatId,
              handleId: virtualHandleId,
              role: const drift.Value('member'),
            ),
          );

      final virtualParticipant = await overlayDb.createVirtualParticipant(
        displayName: 'Virtual Friend',
      );

      await overlayDb.setHandleVirtualParticipantOverride(
        virtualHandleId,
        virtualParticipant.id,
      );

      final results = await container.read(
        contactsListRepositoryProvider.future,
      );

      expect(results.length, equals(2));

      final workingEntry = results.firstWhere(
        (entry) => entry.participantId == participantId,
      );
      expect(workingEntry.origin, ParticipantOrigin.working);
      expect(workingEntry.handleCount, equals(1));

      final virtualEntry = results.firstWhere(
        (entry) => entry.participantId == virtualParticipant.id,
      );
      expect(virtualEntry.origin, ParticipantOrigin.overlayVirtual);
      expect(virtualEntry.displayName, 'Virtual Friend');
      expect(virtualEntry.handleCount, equals(1));
      expect(virtualEntry.isVirtual, isTrue);
    });
  });
}
