import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart'
    show admittedArchiveAccessAuthorityProvider;
import 'package:remember_this_text/essentials/db/feature_level_providers.dart'
    show driftConversationGraphDatabaseProvider, overlayDatabaseProvider;
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/source_scoped_row_key.dart';
import 'package:remember_this_text/features/attachments/application/archive_settings_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_location_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_service_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_recovery_hint_storage.dart';
import 'package:remember_this_text/features/attachments/application/current_messages_attachment_path_lookup.dart';
import 'package:remember_this_text/features/attachments/application/graph_attachment_archive_providers.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_state.dart';

import '../../../test_support/test_archive_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> insertGraphAttachment(
    ConversationGraphDatabase graphDb, {
    required String messageGuid,
    required int importAttachmentId,
    required String localPath,
    required String mimeType,
    int? messageSourceRowId,
  }) async {
    final messageSsId = SourceScopedRowKey.pack(
      sourceId: 1,
      sourceRowId: messageSourceRowId ?? importAttachmentId + 100000,
    );
    final attachmentSsId = SourceScopedRowKey.pack(
      sourceId: 1,
      sourceRowId: importAttachmentId,
    );
    await graphDb.executeSql(
      '''
      INSERT OR IGNORE INTO messages (ss_id, guid, is_from_me)
      VALUES (?, ?, 0)
      ''',
      <Object?>[messageSsId, messageGuid],
    );
    await graphDb.executeSql(
      '''
      INSERT OR IGNORE INTO attachments (ss_id, guid, filename, mime_type)
      VALUES (?, ?, ?, ?)
      ''',
      <Object?>[
        attachmentSsId,
        'attachment-guid-$importAttachmentId',
        localPath,
        mimeType,
      ],
    );
    await graphDb.executeSql(
      '''
      INSERT OR IGNORE INTO message_to_attachment (
        message_ss_id,
        attachment_ss_id
      ) VALUES (?, ?)
      ''',
      <Object?>[messageSsId, attachmentSsId],
    );
  }

  group('AttachmentArchiveService.prioritizeRecovery', () {
    late OverlayDatabase overlayDb;
    late Directory tempDir;
    late ProviderContainer container;
    late TestArchiveFixture archiveFixture;

    setUp(() async {
      overlayDb = OverlayDatabase(NativeDatabase.memory());
      archiveFixture = await TestArchiveFixture.create(
        prefix: 'attachment-priority-test-',
      );
      tempDir = archiveFixture.root;
      await overlayDb.writeOverlaySetting(
        settingKey: 'attachment_archive_enabled',
        settingValue: 'true',
      );

      container = ProviderContainer(
        overrides: [
          admittedArchiveAccessAuthorityProvider.overrideWithValue(
            archiveFixture.authority,
          ),
          overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
          attachmentArchiveLocationProvider.overrideWith(
            (ref) async => AttachmentArchiveLocationState.defaultAvailable(
              archiveRootPath: tempDir.path,
            ),
          ),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await overlayDb.close();
      await archiveFixture.dispose();
    });

    test(
      'stores a recovery hint and archives immediately when source exists',
      () async {
        final sourceFile = File('${tempDir.path}/messages/recover-now.jpg');
        await sourceFile.parent.create(recursive: true);
        await sourceFile.writeAsString('recover-now');

        await container
            .read(attachmentArchiveServiceProvider.notifier)
            .prioritizeRecovery(
              archiveKey: const ArchiveCompatibilityKey(
                messageGuid: 'm-recover-now',
                importAttachmentId: 99,
              ),
              resolvedLocalPath: sourceFile.path,
              mimeType: 'image/jpeg',
            );

        var archivedRow =
            await (overlayDb.select(overlayDb.archivedAttachments)..where(
                  (t) =>
                      t.messageGuid.equals('m-recover-now') &
                      t.importAttachmentId.equals(99),
                ))
                .getSingleOrNull();

        for (var attempt = 0; attempt < 20 && archivedRow == null; attempt++) {
          await Future<void>.delayed(const Duration(milliseconds: 10));
          archivedRow =
              await (overlayDb.select(overlayDb.archivedAttachments)..where(
                    (t) =>
                        t.messageGuid.equals('m-recover-now') &
                        t.importAttachmentId.equals(99),
                  ))
                  .getSingleOrNull();
        }

        expect(archivedRow, isNotNull);
        expect(
          await overlayDb.readOverlaySetting(
            attachmentRecoveryHintSettingKey(
              archiveKey: const ArchiveCompatibilityKey(
                messageGuid: 'm-recover-now',
                importAttachmentId: 99,
              ),
            ),
          ),
          isNull,
        );
      },
    );
  });

  group('AttachmentArchiveService.archiveNextGraphSweepChunk', () {
    late OverlayDatabase overlayDb;
    late ConversationGraphDatabase graphDb;
    late Directory tempDir;
    late ProviderContainer container;
    late _TestCurrentMessagesAttachmentPathLookup attachmentPathLookup;
    late TestArchiveFixture archiveFixture;

    setUp(() async {
      overlayDb = OverlayDatabase(NativeDatabase.memory());
      graphDb = ConversationGraphDatabase(NativeDatabase.memory());
      archiveFixture = await TestArchiveFixture.create(
        prefix: 'attachment-working-sweep-test-',
      );
      tempDir = archiveFixture.root;
      attachmentPathLookup = _TestCurrentMessagesAttachmentPathLookup();
      await overlayDb.writeOverlaySetting(
        settingKey: 'attachment_archive_enabled',
        settingValue: 'true',
      );

      container = ProviderContainer(
        overrides: [
          admittedArchiveAccessAuthorityProvider.overrideWithValue(
            archiveFixture.authority,
          ),
          overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
          driftConversationGraphDatabaseProvider.overrideWith(
            (ref) async => graphDb,
          ),
          currentMessagesAttachmentPathLookupProvider.overrideWith(
            (ref) async => attachmentPathLookup,
          ),
          attachmentArchiveLocationProvider.overrideWith(
            (ref) async => AttachmentArchiveLocationState.defaultAvailable(
              archiveRootPath: '${tempDir.path}/archive',
            ),
          ),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await overlayDb.close();
      await graphDb.close();
      await archiveFixture.dispose();
    });

    test('sweeps forward in small chunks and persists its cursor', () async {
      final alreadyArchivedSource = File(
        '${tempDir.path}/already-archived.png',
      );
      final delayedPdfSource = File('${tempDir.path}/delayed-document.pdf');
      final firstSweepSource = File('${tempDir.path}/first-sweep.png');
      final secondSweepSource = File('${tempDir.path}/second-sweep.png');
      final thirdSweepSource = File('${tempDir.path}/third-sweep.png');

      await alreadyArchivedSource.writeAsString('already-archived');
      await delayedPdfSource.writeAsString('delayed-document');
      await firstSweepSource.writeAsString('first-sweep');
      await secondSweepSource.writeAsString('second-sweep');
      await thirdSweepSource.writeAsString('third-sweep');

      await insertGraphAttachment(
        graphDb,
        messageGuid: 'message-already-archived',
        importAttachmentId: 11,
        localPath: alreadyArchivedSource.path,
        mimeType: 'image/png',
      );
      await insertGraphAttachment(
        graphDb,
        messageGuid: 'message-delayed-pdf',
        importAttachmentId: 12,
        localPath: delayedPdfSource.path,
        mimeType: 'application/pdf',
      );
      await insertGraphAttachment(
        graphDb,
        messageGuid: 'message-first-sweep',
        importAttachmentId: 13,
        localPath: firstSweepSource.path,
        mimeType: 'image/png',
      );
      await insertGraphAttachment(
        graphDb,
        messageGuid: 'message-second-sweep',
        importAttachmentId: 14,
        localPath: secondSweepSource.path,
        mimeType: 'image/png',
      );
      await insertGraphAttachment(
        graphDb,
        messageGuid: 'message-third-sweep',
        importAttachmentId: 15,
        localPath: thirdSweepSource.path,
        mimeType: 'image/png',
      );

      await overlayDb
          .into(overlayDb.archivedAttachments)
          .insert(
            ArchivedAttachmentsCompanion.insert(
              messageGuid: 'message-already-archived',
              importAttachmentId: 11,
              archiveRelativePath: 'existing/already-archived.png',
              archivedAtUtc: DateTime.now().toUtc().toIso8601String(),
              fileSizeBytes: 16,
            ),
          );

      final firstResult = await container
          .read(attachmentArchiveServiceProvider.notifier)
          .archiveNextGraphSweepChunk(limit: 2);

      expect(firstResult.totalScanned, 2);
      expect(firstResult.newlyArchived, 2);
      expect(
        await overlayDb.readOverlaySetting(kArchiveSweepCursorKey),
        '${SourceScopedRowKey.pack(sourceId: 1, sourceRowId: 13)}',
      );
      expect(
        await overlayDb.readOverlaySetting(kArchiveSweepLastTotalScannedKey),
        '2',
      );
      expect(
        await overlayDb.readOverlaySetting(kArchiveSweepLastNewlyArchivedKey),
        '2',
      );
      expect(
        await overlayDb.readOverlaySetting(kArchiveSweepLastSkippedKey),
        '0',
      );
      expect(
        await overlayDb.readOverlaySetting(kArchiveSweepLastFailedKey),
        '0',
      );
      expect(
        await overlayDb.readOverlaySetting(kArchiveSweepLastStartedAtUtcKey),
        isNotNull,
      );
      expect(
        await overlayDb.readOverlaySetting(kArchiveSweepLastCompletedAtUtcKey),
        isNotNull,
      );

      final firstArchivedRow =
          await (overlayDb.select(overlayDb.archivedAttachments)..where(
                (t) =>
                    t.messageGuid.equals('message-first-sweep') &
                    t.importAttachmentId.equals(13),
              ))
              .getSingleOrNull();
      final pdfArchivedRow =
          await (overlayDb.select(overlayDb.archivedAttachments)..where(
                (t) =>
                    t.messageGuid.equals('message-delayed-pdf') &
                    t.importAttachmentId.equals(12),
              ))
              .getSingleOrNull();
      final secondArchivedRowAfterFirstSweep =
          await (overlayDb.select(overlayDb.archivedAttachments)..where(
                (t) =>
                    t.messageGuid.equals('message-second-sweep') &
                    t.importAttachmentId.equals(14),
              ))
              .getSingleOrNull();
      expect(firstArchivedRow, isNotNull);
      expect(pdfArchivedRow, isNotNull);
      expect(secondArchivedRowAfterFirstSweep, isNull);

      final secondResult = await container
          .read(attachmentArchiveServiceProvider.notifier)
          .archiveNextGraphSweepChunk(limit: 2);

      expect(secondResult.totalScanned, 2);
      expect(secondResult.newlyArchived, 2);
      expect(
        await overlayDb.readOverlaySetting(kArchiveSweepCursorKey),
        '${SourceScopedRowKey.pack(sourceId: 1, sourceRowId: 15)}',
      );

      final secondArchivedRow =
          await (overlayDb.select(overlayDb.archivedAttachments)..where(
                (t) =>
                    t.messageGuid.equals('message-second-sweep') &
                    t.importAttachmentId.equals(14),
              ))
              .getSingleOrNull();
      final thirdArchivedRow =
          await (overlayDb.select(overlayDb.archivedAttachments)..where(
                (t) =>
                    t.messageGuid.equals('message-third-sweep') &
                    t.importAttachmentId.equals(15),
              ))
              .getSingleOrNull();
      expect(secondArchivedRow, isNotNull);
      expect(thirdArchivedRow, isNotNull);

      final wrapResult = await container
          .read(attachmentArchiveServiceProvider.notifier)
          .archiveNextGraphSweepChunk(limit: 2);

      expect(wrapResult.totalScanned, 0);
      expect(await overlayDb.readOverlaySetting(kArchiveSweepCursorKey), '0');
    });

    test(
      'refreshes an obsolete Messages attachment path from chat.db',
      () async {
        final liveSource = File('${tempDir.path}/messages/live-path.png');
        await liveSource.parent.create(recursive: true);
        await liveSource.writeAsString('live-path');
        attachmentPathLookup.pathsBySourceRowId[500] = liveSource.path;

        await insertGraphAttachment(
          graphDb,
          messageGuid: 'message-path-drift',
          importAttachmentId: 500,
          localPath: '${tempDir.path}/messages/obsolete-path.png',
          mimeType: 'image/png',
        );

        final result = await container
            .read(attachmentArchiveServiceProvider.notifier)
            .archiveNextGraphSweepChunk(limit: 1);

        expect(result.totalScanned, 1);
        expect(result.newlyArchived, 1);

        final archivedRow =
            await (overlayDb.select(overlayDb.archivedAttachments)..where(
                  (t) =>
                      t.messageGuid.equals('message-path-drift') &
                      t.importAttachmentId.equals(500),
                ))
                .getSingleOrNull();
        expect(archivedRow, isNotNull);
        expect(archivedRow!.originalLocalPath, liveSource.path);
        expect(
          File(
            '${tempDir.path}/archive/${archivedRow.archiveRelativePath}',
          ).existsSync(),
          isTrue,
        );
      },
    );

    test(
      'archives graph attachments for the imported message source row range',
      () async {
        final beforeRangeSource = File('${tempDir.path}/before-range.png');
        final inRangeSource = File('${tempDir.path}/in-range.png');
        final afterRangeSource = File('${tempDir.path}/after-range.png');
        await beforeRangeSource.writeAsString('before-range');
        await inRangeSource.writeAsString('in-range');
        await afterRangeSource.writeAsString('after-range');

        await insertGraphAttachment(
          graphDb,
          messageGuid: 'message-before-range',
          importAttachmentId: 610,
          localPath: beforeRangeSource.path,
          mimeType: 'image/png',
          messageSourceRowId: 99,
        );
        await insertGraphAttachment(
          graphDb,
          messageGuid: 'message-in-range',
          importAttachmentId: 611,
          localPath: inRangeSource.path,
          mimeType: 'image/png',
          messageSourceRowId: 100,
        );
        await insertGraphAttachment(
          graphDb,
          messageGuid: 'message-after-range',
          importAttachmentId: 612,
          localPath: afterRangeSource.path,
          mimeType: 'image/png',
          messageSourceRowId: 102,
        );

        final result = await container
            .read(attachmentArchiveServiceProvider.notifier)
            .archiveGraphMessageSourceRange(
              sourceId: 1,
              startedAfterSourceRowId: 99,
              lastImportedSourceRowId: 101,
            );

        expect(result.totalScanned, 1);
        expect(result.newlyArchived, 1);

        final inRangeArchive =
            await (overlayDb.select(overlayDb.archivedAttachments)..where(
                  (t) =>
                      t.messageGuid.equals('message-in-range') &
                      t.importAttachmentId.equals(611),
                ))
                .getSingleOrNull();
        final beforeRangeArchive =
            await (overlayDb.select(overlayDb.archivedAttachments)..where(
                  (t) =>
                      t.messageGuid.equals('message-before-range') &
                      t.importAttachmentId.equals(610),
                ))
                .getSingleOrNull();
        final afterRangeArchive =
            await (overlayDb.select(overlayDb.archivedAttachments)..where(
                  (t) =>
                      t.messageGuid.equals('message-after-range') &
                      t.importAttachmentId.equals(612),
                ))
                .getSingleOrNull();

        expect(inRangeArchive, isNotNull);
        expect(beforeRangeArchive, isNull);
        expect(afterRangeArchive, isNull);
      },
    );

    test(
      'persists manual burst totals separately from chunk sweep status',
      () async {
        final maintenanceSource = File('${tempDir.path}/maintenance.png');
        final firstBurstSource = File('${tempDir.path}/burst-first.png');
        final secondBurstSource = File('${tempDir.path}/burst-second.png');
        final thirdBurstSource = File('${tempDir.path}/burst-third.png');

        await maintenanceSource.writeAsString('maintenance');
        await firstBurstSource.writeAsString('burst-first');
        await secondBurstSource.writeAsString('burst-second');
        await thirdBurstSource.writeAsString('burst-third');

        await insertGraphAttachment(
          graphDb,
          messageGuid: 'message-maintenance',
          importAttachmentId: 20,
          localPath: maintenanceSource.path,
          mimeType: 'image/png',
        );
        await insertGraphAttachment(
          graphDb,
          messageGuid: 'message-burst-first',
          importAttachmentId: 21,
          localPath: firstBurstSource.path,
          mimeType: 'image/png',
        );
        await insertGraphAttachment(
          graphDb,
          messageGuid: 'message-burst-second',
          importAttachmentId: 22,
          localPath: secondBurstSource.path,
          mimeType: 'image/png',
        );
        await insertGraphAttachment(
          graphDb,
          messageGuid: 'message-burst-third',
          importAttachmentId: 23,
          localPath: thirdBurstSource.path,
          mimeType: 'image/png',
        );

        final maintenanceResult = await container
            .read(attachmentArchiveServiceProvider.notifier)
            .archiveNextGraphSweepChunk(limit: 1);

        expect(maintenanceResult.totalScanned, 1);
        expect(maintenanceResult.newlyArchived, 1);

        final result = await container
            .read(attachmentArchiveServiceProvider.notifier)
            .archiveGraphSweepBurst(chunkLimit: 2, maxChunks: 2);

        expect(result.totalScanned, 3);
        expect(result.newlyArchived, 3);
        expect(await overlayDb.readOverlaySetting(kArchiveSweepCursorKey), '0');
        expect(
          await overlayDb.readOverlaySetting(
            kArchiveManualSweepLastTotalScannedKey,
          ),
          '3',
        );
        expect(
          await overlayDb.readOverlaySetting(
            kArchiveManualSweepLastNewlyArchivedKey,
          ),
          '3',
        );
        expect(
          await overlayDb.readOverlaySetting(kArchiveManualSweepLastSkippedKey),
          '0',
        );
        expect(
          await overlayDb.readOverlaySetting(kArchiveManualSweepLastFailedKey),
          '0',
        );
        expect(
          await overlayDb.readOverlaySetting(
            kArchiveManualSweepLastStartedAtUtcKey,
          ),
          isNotNull,
        );
        expect(
          await overlayDb.readOverlaySetting(
            kArchiveManualSweepLastCompletedAtUtcKey,
          ),
          isNotNull,
        );

        expect(
          await overlayDb.readOverlaySetting(kArchiveSweepLastTotalScannedKey),
          '1',
        );
        expect(
          await overlayDb.readOverlaySetting(kArchiveSweepLastNewlyArchivedKey),
          '1',
        );
        expect(
          await overlayDb.readOverlaySetting(kArchiveSweepLastSkippedKey),
          '0',
        );
      },
    );

    test(
      'manual burst stops after one cursor cycle for a short tail',
      () async {
        final firstTailSource = File('${tempDir.path}/tail-first.png');
        final secondTailSource = File('${tempDir.path}/tail-second.png');
        final thirdTailSource = File('${tempDir.path}/tail-third.png');

        await firstTailSource.writeAsString('tail-first');
        await secondTailSource.writeAsString('tail-second');
        await thirdTailSource.writeAsString('tail-third');

        await insertGraphAttachment(
          graphDb,
          messageGuid: 'message-tail-first',
          importAttachmentId: 31,
          localPath: firstTailSource.path,
          mimeType: 'image/png',
        );
        await insertGraphAttachment(
          graphDb,
          messageGuid: 'message-tail-second',
          importAttachmentId: 32,
          localPath: secondTailSource.path,
          mimeType: 'image/png',
        );
        await insertGraphAttachment(
          graphDb,
          messageGuid: 'message-tail-third',
          importAttachmentId: 33,
          localPath: thirdTailSource.path,
          mimeType: 'image/png',
        );

        final result = await container
            .read(attachmentArchiveServiceProvider.notifier)
            .archiveGraphSweepBurst(chunkLimit: 100, maxChunks: 25);

        expect(result.totalScanned, 3);
        expect(result.newlyArchived, 3);
        expect(await overlayDb.readOverlaySetting(kArchiveSweepCursorKey), '0');
        expect(
          await overlayDb.readOverlaySetting(
            kArchiveManualSweepLastTotalScannedKey,
          ),
          '3',
        );
      },
    );

    test('manual burst stores skipped sample details', () async {
      await insertGraphAttachment(
        graphDb,
        messageGuid: 'message-missing-first',
        importAttachmentId: 41,
        localPath: '${tempDir.path}/missing-first.png',
        mimeType: 'image/png',
      );
      await insertGraphAttachment(
        graphDb,
        messageGuid: 'message-missing-second',
        importAttachmentId: 42,
        localPath: '${tempDir.path}/missing-second.png',
        mimeType: 'image/png',
      );

      final result = await container
          .read(attachmentArchiveServiceProvider.notifier)
          .archiveGraphSweepBurst(chunkLimit: 100, maxChunks: 25);

      expect(result.totalScanned, 2);
      expect(result.newlyArchived, 0);
      expect(result.skipped, 2);

      final skippedSamples = await overlayDb.readOverlaySetting(
        kArchiveManualSweepLastSkippedSamplesKey,
      );
      expect(skippedSamples, isNotNull);
      expect(skippedSamples, contains('41 | source missing |'));
      expect(skippedSamples, contains('missing-first.png'));
      expect(skippedSamples, contains('42 | source missing |'));
      expect(skippedSamples, contains('missing-second.png'));
    });
  });
}

final class _TestCurrentMessagesAttachmentPathLookup
    implements CurrentMessagesAttachmentPathLookup {
  final Map<int, String> pathsBySourceRowId = <int, String>{};

  @override
  Future<String?> attachmentPathForSourceRowId(int sourceRowId) async {
    return pathsBySourceRowId[sourceRowId];
  }
}
