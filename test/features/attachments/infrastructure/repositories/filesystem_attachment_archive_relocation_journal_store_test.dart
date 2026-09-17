import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_relocation_activation_gate.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_configuration.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_relocation.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/filesystem_attachment_archive_relocation_journal_store.dart';

void main() {
  group('FilesystemAttachmentArchiveRelocationJournalStore', () {
    late Directory root;
    late FilesystemAttachmentArchiveRelocationJournalStore store;

    setUp(() {
      root = Directory.systemTemp.createTempSync('relocation_journal_test_');
      store = FilesystemAttachmentArchiveRelocationJournalStore(
        primaryArchiveRootPath: root.path,
      );
    });

    tearDown(() async {
      if (root.existsSync()) {
        await root.delete(recursive: true);
      }
    });

    test(
      'round-trips every durable state without filesystem inference',
      () async {
        var journal = _selectedJournal('state-round-trip');
        await store.create(journal);

        for (final stage in AttachmentArchiveRelocationStage.values) {
          journal = journal.copyWith(
            stage: stage,
            resumeStage: stage == AttachmentArchiveRelocationStage.paused
                ? AttachmentArchiveRelocationStage.copying
                : null,
            clearResumeStage: stage != AttachmentArchiveRelocationStage.paused,
            updatedAtUtc: DateTime.utc(2026, 9, 17, stage.index),
          );
          await store.save(journal);

          final restored = await store.read(journal.operationId);
          expect(restored.stage, stage);
          expect(restored.operationId, journal.operationId);
          expect(restored.sourceRootPath, journal.sourceRootPath);
          expect(
            restored.destinationParentBookmarkDataBase64,
            journal.destinationParentBookmarkDataBase64,
          );
          expect(
            restored.resumeStage,
            stage == AttachmentArchiveRelocationStage.paused
                ? AttachmentArchiveRelocationStage.copying
                : null,
          );
        }
      },
    );

    test('streams manifest and receipts in durable order', () async {
      final journal = _selectedJournal('stream-order');
      await store.create(journal);
      await store.beginManifest(journal.operationId);
      await store.beginCopyReceipts(journal.operationId);
      for (var index = 0; index < 3; index++) {
        final entry = AttachmentArchiveRelocationManifestEntry(
          relativePath: 'aa/${index.toString().padLeft(64, '0')}.bin',
          sizeBytes: index + 1,
          kind: AttachmentArchiveRelocationEntryKind.metadataKnown,
          knownSha256: null,
          metadataRowCount: 1,
        );
        await store.appendManifestEntry(
          operationId: journal.operationId,
          entry: entry,
        );
        await store.appendCopyReceipt(
          operationId: journal.operationId,
          receipt: AttachmentArchiveRelocationCopyReceipt(
            index: index,
            relativePath: entry.relativePath,
            sizeBytes: entry.sizeBytes,
            sha256: List<String>.filled(64, 'a').join(),
          ),
        );
      }

      expect(
        await store
            .readManifest(journal.operationId)
            .map((entry) => entry.sizeBytes)
            .toList(),
        <int>[1, 2, 3],
      );
      expect(
        await store
            .readCopyReceipts(journal.operationId)
            .map((receipt) => receipt.index)
            .toList(),
        <int>[0, 1, 2],
      );
      expect(await store.hashManifest(journal.operationId), hasLength(64));
    });

    test('rejects a future journal format', () async {
      final journal = _selectedJournal('future-version');
      await store.create(journal);
      final journalFile = File(
        '${root.path}/'
        '${FilesystemAttachmentArchiveRelocationJournalStore.journalDirectoryName}/'
        '${journal.operationId}/journal.json',
      );
      journalFile.writeAsStringSync(
        journalFile.readAsStringSync().replaceFirst(
          '"formatVersion":1',
          '"formatVersion":999',
        ),
        flush: true,
      );

      await expectLater(store.read(journal.operationId), throwsFormatException);
    });

    test(
      'discovers an unfinished journal if pointer publication was interrupted',
      () async {
        final journal = _selectedJournal('orphaned-pointer-window');
        await store.create(journal);
        File(
          '${root.path}/'
          '${FilesystemAttachmentArchiveRelocationJournalStore.journalDirectoryName}/'
          'current.json',
        ).deleteSync();

        final restored = await store.readCurrent();

        expect(restored?.operationId, journal.operationId);
        expect(restored?.stage, AttachmentArchiveRelocationStage.selected);
      },
    );

    test('partial verification cannot mint activation authority', () async {
      var journal = _selectedJournal('partial-verification');
      await store.create(journal);
      await store.beginManifest(journal.operationId);
      await store.beginCopyReceipts(journal.operationId);
      for (var index = 0; index < 2; index++) {
        final entry = AttachmentArchiveRelocationManifestEntry(
          relativePath: 'aa/${index.toString().padLeft(64, '0')}.bin',
          sizeBytes: 1,
          kind: AttachmentArchiveRelocationEntryKind.metadataKnown,
          knownSha256: null,
          metadataRowCount: 1,
        );
        await store.appendManifestEntry(
          operationId: journal.operationId,
          entry: entry,
        );
        await store.appendCopyReceipt(
          operationId: journal.operationId,
          receipt: AttachmentArchiveRelocationCopyReceipt(
            index: index,
            relativePath: entry.relativePath,
            sizeBytes: entry.sizeBytes,
            sha256: List<String>.filled(64, 'a').join(),
          ),
        );
      }
      journal = journal.copyWith(
        stage: AttachmentArchiveRelocationStage.configurationSwitching,
        manifestSha256: await store.hashManifest(journal.operationId),
        expectedFileCount: 2,
        expectedByteCount: 2,
        copiedFileCount: 2,
        copiedByteCount: 2,
        verifiedFileCount: 1,
        verifiedByteCount: 1,
        intendedConfiguration:
            AttachmentArchiveLocationConfiguration.customExternal(
              bookmarkDataBase64: 'Ag==',
              lastKnownPath: '/disposable/final',
              customWritePolicy:
                  AttachmentArchiveCustomWritePolicy.activeArchive,
            ),
      );
      await store.save(journal);

      await expectLater(
        AttachmentArchiveRelocationActivationGate(
          journalStore: store,
        ).issuePermit(journal.operationId),
        throwsStateError,
      );
    });
  });
}

AttachmentArchiveRelocationJournal _selectedJournal(String operationId) {
  return AttachmentArchiveRelocationJournal.selected(
    operationId: operationId,
    archiveInstanceId: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
    sourceRootPath: '/disposable/source',
    sourceConfiguration:
        const AttachmentArchiveLocationConfiguration.defaultInternal(),
    sourceLocationGeneration: 0,
    destinationParentBookmarkDataBase64: 'AQ==',
    destinationParentLastKnownPath: '/disposable/destination',
    destinationVolumeName: 'Disposable',
    nowUtc: DateTime.utc(2026, 9, 17),
  );
}
