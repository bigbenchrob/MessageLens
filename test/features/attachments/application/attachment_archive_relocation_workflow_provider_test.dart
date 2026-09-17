import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_location_dependencies_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_location_folder_chooser.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_relocation_provider.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_configuration.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_relocation.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/filesystem_attachment_archive_relocation_journal_store.dart';

import '../../../test_support/test_archive_fixture.dart';

void main() {
  test(
    'cancelled destination picker leaves workflow and journal unchanged',
    () async {
      final fixture = await TestArchiveFixture.create(
        prefix: 'relocation_picker_cancel_',
      );
      addTearDown(fixture.dispose);
      final chooser = _FixedFolderChooser(null);
      final container = ProviderContainer(
        overrides: [
          admittedArchiveAccessAuthorityProvider.overrideWithValue(
            fixture.authority,
          ),
          attachmentArchiveLocationFolderChooserProvider.overrideWithValue(
            chooser,
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(
        await container.read(
          attachmentArchiveRelocationWorkflowProvider.future,
        ),
        isNull,
      );
      final result = await container
          .read(attachmentArchiveRelocationWorkflowProvider.notifier)
          .chooseDestinationAndPrepare();

      expect(result, isNull);
      expect(chooser.calls, 1);
      final store = FilesystemAttachmentArchiveRelocationJournalStore(
        primaryArchiveRootPath: fixture.root.path,
      );
      expect(await store.readCurrent(), isNull);
    },
  );

  test(
    'provider reconstructs pending state from journal without engine dependencies',
    () async {
      final fixture = await TestArchiveFixture.create(
        prefix: 'relocation_restart_discovery_',
      );
      addTearDown(fixture.dispose);
      final store = FilesystemAttachmentArchiveRelocationJournalStore(
        primaryArchiveRootPath: fixture.root.path,
      );
      await store.create(
        AttachmentArchiveRelocationJournal.selected(
          operationId: 'pending-operation',
          archiveInstanceId: fixture.authority.identity.archiveInstanceId.value,
          sourceRootPath: fixture.authority.resolvePath('attachment_archive'),
          sourceConfiguration:
              const AttachmentArchiveLocationConfiguration.defaultInternal(),
          sourceLocationGeneration: 0,
          destinationParentBookmarkDataBase64: 'AQID',
          destinationParentLastKnownPath: '/tmp/disposable-destination',
          destinationVolumeName: 'Disposable',
          nowUtc: DateTime.utc(2026, 9, 17),
        ),
      );

      final container = ProviderContainer(
        overrides: [
          admittedArchiveAccessAuthorityProvider.overrideWithValue(
            fixture.authority,
          ),
        ],
      );
      addTearDown(container.dispose);

      final progress = await container.read(
        attachmentArchiveRelocationWorkflowProvider.future,
      );

      expect(progress?.operationId, 'pending-operation');
      expect(progress?.stage, AttachmentArchiveRelocationStage.selected);
      expect(progress?.filesCopied, 0);
    },
  );
}

final class _FixedFolderChooser
    implements AttachmentArchiveLocationFolderChooser {
  _FixedFolderChooser(this.result);

  final String? result;
  int calls = 0;

  @override
  Future<String?> chooseArchiveDirectory() async {
    calls++;
    return result;
  }
}
