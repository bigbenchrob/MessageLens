import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'package:remember_this_text/essentials/logging/application/message_logger.dart';
import 'package:remember_this_text/features/contacts/application/manual_handle_link_service.dart';
import 'package:remember_this_text/features/contacts/application/virtual_participants_provider.dart';

void main() {
  group('ManualHandleLinkService virtual participants', () {
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
      'createVirtualParticipant returns overlay id and invalidates provider',
      () async {
        final service = container.read(
          manualHandleLinkServiceProvider.notifier,
        );

        final result = await service.createVirtualParticipant(
          displayName: 'Virtual Friend',
        );

        expect(result.isRight(), isTrue);
        final id = result.getOrElse(() => -1);
        expect(id, greaterThanOrEqualTo(1000000000));

        final participants = await overlayDb.getVirtualParticipants();
        expect(participants, hasLength(1));
        expect(participants.first.id, equals(id));

        // Provider should read the newly created participant
        final providerResult = await container.read(
          virtualParticipantsProvider.future,
        );
        expect(providerResult, hasLength(1));
        expect(providerResult.first.displayName, 'Virtual Friend');
      },
    );

    test(
      'createVirtualParticipant logs warning when name duplicates',
      () async {
        final service = container.read(
          manualHandleLinkServiceProvider.notifier,
        );

        await service.createVirtualParticipant(displayName: 'Jamie');
        await service.createVirtualParticipant(displayName: 'jamie');

        final logs = container.read(messageLoggerProvider);
        final warningLog = logs.where((entry) => entry.level == 'warn');
        expect(warningLog, isNotEmpty);
        expect(
          warningLog.last.message,
          contains('Duplicate virtual contact name requested'),
        );
      },
    );

    test('createVirtualParticipant returns failure when name empty', () async {
      final service = container.read(manualHandleLinkServiceProvider.notifier);

      final result = await service.createVirtualParticipant(displayName: '   ');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) =>
            expect(failure.message, contains('Display name cannot be empty')),
        (_) => fail('Expected failure for empty display name'),
      );
    });
  });
}
