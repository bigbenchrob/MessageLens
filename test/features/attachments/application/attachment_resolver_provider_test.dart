import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart'
    show admittedArchiveAccessAuthorityProvider;
import 'package:remember_this_text/essentials/db/feature_level_providers.dart'
    show overlayDatabaseProvider;
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_adoption_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_location_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_recovery_hint_storage.dart';
import 'package:remember_this_text/features/attachments/application/attachment_resolver_provider.dart';
import 'package:remember_this_text/features/attachments/domain/constants/attachment_archive_payload_status.dart';
import 'package:remember_this_text/features/attachments/domain/constants/attachment_provenance.dart';
import 'package:remember_this_text/features/attachments/domain/constants/resolved_attachment_availability.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_adoption.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_configuration.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_state.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_recovery_metadata.dart';
import 'package:remember_this_text/features/messages/domain/entities/attachment_info.dart';

import '../../../test_support/test_archive_fixture.dart';

void main() {
  group('attachmentResolverProvider', () {
    late OverlayDatabase overlayDb;
    late Directory tempDir;
    late TestArchiveFixture archiveFixture;
    ProviderContainer? container;

    setUp(() async {
      overlayDb = OverlayDatabase(NativeDatabase.memory());
      archiveFixture = await TestArchiveFixture.create(
        prefix: 'attachment_resolver_archive_',
      );
      tempDir = await Directory.systemTemp.createTemp(
        'attachment-resolver-test-',
      );
    });

    tearDown(() async {
      container?.dispose();
      await overlayDb.close();
      await archiveFixture.dispose();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    Future<ProviderContainer> createContainer({
      required bool archiveEnabled,
      AttachmentArchiveLocationState? location,
      AttachmentArchiveAdoptionTransaction? pendingAdoption,
    }) async {
      await overlayDb.writeOverlaySetting(
        settingKey: 'attachment_archive_enabled',
        settingValue: archiveEnabled.toString(),
      );

      return ProviderContainer(
        overrides: [
          admittedArchiveAccessAuthorityProvider.overrideWithValue(
            archiveFixture.authority,
          ),
          overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
          attachmentArchiveLocationProvider.overrideWith(
            () => _FixedAttachmentArchiveLocation(
              location ??
                  AttachmentArchiveLocationState.defaultAvailable(
                    archiveRootPath: tempDir.path,
                  ),
            ),
          ),
          attachmentArchivePendingAdoptionTransactionProvider.overrideWith(
            (ref) async => pendingAdoption,
          ),
        ],
      );
    }

    test('archive disabled resolves live file directly', () async {
      final liveFile = File('${tempDir.path}/messages/photo.jpg');
      await liveFile.parent.create(recursive: true);
      await liveFile.writeAsString('live');

      container = await createContainer(archiveEnabled: false);

      final result = await container!.read(
        attachmentResolverProvider(
          AttachmentInfo(
            id: 1,
            archiveCompatibilityKey: const ArchiveCompatibilityKey(
              messageGuid: 'm1',
              importAttachmentId: 11,
            ),
            localPath: liveFile.path,
            mimeType: 'image/jpeg',
            transferName: 'photo.jpg',
          ),
        ).future,
      );

      expect(result.availability, ResolvedAttachmentAvailability.available);
      expect(result.provenance, AttachmentProvenance.messagesLive);
      expect(result.resolvedFilePath, liveFile.path);
    });

    test('archive enabled resolves archived file first', () async {
      final archiveFile = File('${tempDir.path}/ab/hash.jpg');
      await archiveFile.parent.create(recursive: true);
      await archiveFile.writeAsString('archived');

      await overlayDb
          .into(overlayDb.archivedAttachments)
          .insert(
            ArchivedAttachmentsCompanion.insert(
              messageGuid: 'm2',
              importAttachmentId: 22,
              archiveRelativePath: 'ab/hash.jpg',
              archivedAtUtc: DateTime.now().toUtc().toIso8601String(),
              fileSizeBytes: await archiveFile.length(),
              contentHash: const drift.Value('hash'),
              originalLocalPath: const drift.Value('/tmp/missing.jpg'),
            ),
          );

      container = await createContainer(archiveEnabled: true);

      final result = await container!.read(
        attachmentResolverProvider(
          const AttachmentInfo(
            id: 2,
            archiveCompatibilityKey: ArchiveCompatibilityKey(
              messageGuid: 'm2',
              importAttachmentId: 22,
            ),
            localPath: '/tmp/does-not-exist.jpg',
            mimeType: 'image/jpeg',
            transferName: 'archived.jpg',
          ),
        ).future,
      );

      expect(result.availability, ResolvedAttachmentAvailability.available);
      expect(result.provenance, AttachmentProvenance.archived);
      expect(result.resolvedFilePath, archiveFile.path);
    });

    test(
      'archive enabled reports pending when live file exists but archive does not',
      () async {
        final liveFile = File('${tempDir.path}/messages/pending.png');
        await liveFile.parent.create(recursive: true);
        await liveFile.writeAsString('pending');

        container = await createContainer(archiveEnabled: true);

        final result = await container!.read(
          attachmentResolverProvider(
            AttachmentInfo(
              id: 3,
              archiveCompatibilityKey: const ArchiveCompatibilityKey(
                messageGuid: 'm3',
                importAttachmentId: 33,
              ),
              localPath: liveFile.path,
              mimeType: 'image/png',
              transferName: 'pending.png',
            ),
          ).future,
        );

        expect(
          result.availability,
          ResolvedAttachmentAvailability.pendingArchive,
        );
        expect(result.resolvedFilePath, isNull);
        expect(result.recoveryMetadata?.recoveryPriority, 1);

        var archiveCreated = false;
        for (var attempt = 0; attempt < 20; attempt++) {
          final archivedRow =
              await (overlayDb.select(overlayDb.archivedAttachments)..where(
                    (t) =>
                        t.messageGuid.equals('m3') &
                        t.importAttachmentId.equals(33),
                  ))
                  .getSingleOrNull();
          if (archivedRow != null) {
            archiveCreated = true;
            break;
          }
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }

        expect(archiveCreated, isTrue);
      },
    );

    test(
      'archive enabled reports unavailable awaiting recovery when no file is available',
      () async {
        container = await createContainer(archiveEnabled: true);

        final result = await container!.read(
          attachmentResolverProvider(
            const AttachmentInfo(
              id: 4,
              archiveCompatibilityKey: ArchiveCompatibilityKey(
                messageGuid: 'm4',
                importAttachmentId: 44,
              ),
              localPath: '/tmp/evicted.mov',
              mimeType: 'video/quicktime',
              transferName: 'evicted.mov',
            ),
          ).future,
        );

        expect(
          result.availability,
          ResolvedAttachmentAvailability.unavailableAwaitingRecovery,
        );
        expect(result.recoveryMetadata?.isNonRecoverable, isFalse);
        expect(result.resolvedFilePath, isNull);
      },
    );

    test(
      'archive enabled merges stored user-interest recovery hint into unresolved metadata',
      () async {
        const userInterestRaisedAt = '2026-04-05T12:34:56.000Z';
        final expectedUserInterestRaisedAt = DateTime.parse(
          userInterestRaisedAt,
        ).toUtc();

        await overlayDb.writeOverlaySetting(
          settingKey: attachmentRecoveryHintSettingKey(
            archiveKey: const ArchiveCompatibilityKey(
              messageGuid: 'm-priority',
              importAttachmentId: 55,
            ),
          ),
          settingValue: encodeAttachmentRecoveryHint(
            AttachmentRecoveryMetadata(
              recoveryPriority: 10,
              userInterestRaisedAt: expectedUserInterestRaisedAt,
            ),
          ),
        );

        container = await createContainer(archiveEnabled: true);

        final result = await container!.read(
          attachmentResolverProvider(
            const AttachmentInfo(
              id: 6,
              archiveCompatibilityKey: ArchiveCompatibilityKey(
                messageGuid: 'm-priority',
                importAttachmentId: 55,
              ),
              localPath: '/tmp/missing-priority.jpg',
              mimeType: 'image/jpeg',
              transferName: 'missing-priority.jpg',
            ),
          ).future,
        );

        expect(
          result.availability,
          ResolvedAttachmentAvailability.unavailableAwaitingRecovery,
        );
        expect(result.recoveryMetadata?.recoveryPriority, 10);
        expect(
          result.recoveryMetadata?.userInterestRaisedAt,
          expectedUserInterestRaisedAt,
        );
      },
    );

    test(
      'archive enabled reports non-recoverable when no live path or archive key exists',
      () async {
        container = await createContainer(archiveEnabled: true);

        final result = await container!.read(
          attachmentResolverProvider(
            const AttachmentInfo(
              id: 5,
              localPath: null,
              mimeType: 'application/octet-stream',
              transferName: 'unknown.bin',
            ),
          ).future,
        );

        expect(
          result.availability,
          ResolvedAttachmentAvailability.nonRecoverable,
        );
        expect(result.recoveryMetadata?.isNonRecoverable, isTrue);
      },
    );

    test(
      'unavailable external root is not treated as a missing payload',
      () async {
        await overlayDb
            .into(overlayDb.archivedAttachments)
            .insert(
              ArchivedAttachmentsCompanion.insert(
                messageGuid: 'm-offline',
                importAttachmentId: 77,
                archiveRelativePath: 'payload.jpg',
                archivedAtUtc: '2026-09-15T10:00:00.000Z',
                fileSizeBytes: 5,
              ),
            );
        final configuration =
            AttachmentArchiveLocationConfiguration.customExternal(
              bookmarkDataBase64: 'AQID',
              lastKnownPath: '/Volumes/Offline/Archive',
            );
        container = await createContainer(
          archiveEnabled: true,
          location: AttachmentArchiveLocationState.customUnavailable(
            configuration: configuration,
            issue: 'Volume is disconnected.',
            generation: 9,
          ),
        );

        final result = await container!.read(
          attachmentResolverProvider(
            const AttachmentInfo(
              id: 7,
              archiveCompatibilityKey: ArchiveCompatibilityKey(
                messageGuid: 'm-offline',
                importAttachmentId: 77,
              ),
              localPath: '/tmp/not-present.jpg',
              mimeType: 'image/jpeg',
              transferName: 'offline.jpg',
            ),
          ).future,
        );

        expect(
          result.availability,
          ResolvedAttachmentAvailability.archiveUnavailable,
        );
        expect(
          result.archivePayloadStatus,
          AttachmentArchivePayloadStatus.rootUnavailable,
        );
        expect(result.archiveLocationGeneration, 9);
        expect(result.recoveryMetadata, isNull);
      },
    );

    test(
      'live fallback retains archive-unavailable evidence without ingestion',
      () async {
        final liveFile = File('${tempDir.path}/messages/live-fallback.jpg');
        await liveFile.parent.create(recursive: true);
        await liveFile.writeAsString('live');
        final configuration =
            AttachmentArchiveLocationConfiguration.customExternal(
              bookmarkDataBase64: 'AQID',
              lastKnownPath: '/Volumes/Offline/Archive',
            );
        container = await createContainer(
          archiveEnabled: true,
          location: AttachmentArchiveLocationState.customUnavailable(
            configuration: configuration,
            issue: 'Volume is disconnected.',
            generation: 11,
          ),
        );

        final result = await container!.read(
          attachmentResolverProvider(
            AttachmentInfo(
              id: 8,
              archiveCompatibilityKey: const ArchiveCompatibilityKey(
                messageGuid: 'm-live-offline',
                importAttachmentId: 88,
              ),
              localPath: liveFile.path,
              mimeType: 'image/jpeg',
              transferName: 'live-fallback.jpg',
            ),
          ).future,
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));
        final unexpectedArchiveRow =
            await (overlayDb.select(overlayDb.archivedAttachments)..where(
                  (row) =>
                      row.messageGuid.equals('m-live-offline') &
                      row.importAttachmentId.equals(88),
                ))
                .getSingleOrNull();

        expect(result.availability, ResolvedAttachmentAvailability.available);
        expect(result.provenance, AttachmentProvenance.messagesLive);
        expect(result.resolvedFilePath, liveFile.path);
        expect(
          result.archiveRootAvailability,
          AttachmentArchiveLocationAvailability.customUnavailable,
        );
        expect(result.archiveRootIssue, 'Volume is disconnected.');
        expect(unexpectedArchiveRow, isNull);
      },
    );

    test(
      'exact durable remediation path reports pending without reading the old '
      'archive as a fallback',
      () async {
        const relativePath = 'aa/pending.bin';
        final retainedSource = await Directory(
          '${tempDir.path}.retained-source',
        ).create();
        addTearDown(() async {
          if (retainedSource.existsSync()) {
            await retainedSource.delete(recursive: true);
          }
        });
        final retainedPayload = File(
          path.join(retainedSource.path, relativePath),
        );
        await retainedPayload.parent.create(recursive: true);
        await retainedPayload.writeAsBytes(<int>[1, 2, 3], flush: true);
        await overlayDb
            .into(overlayDb.archivedAttachments)
            .insert(
              ArchivedAttachmentsCompanion.insert(
                messageGuid: 'm-remediation',
                importAttachmentId: 99,
                archiveRelativePath: relativePath,
                archivedAtUtc: '2026-09-20T10:00:00.000Z',
                fileSizeBytes: 3,
                contentHash: drift.Value(List<String>.filled(64, 'a').join()),
              ),
            );
        final intended = AttachmentArchiveLocationConfiguration.customExternal(
          bookmarkDataBase64: 'AQID',
          lastKnownPath: tempDir.path,
          customWritePolicy: AttachmentArchiveCustomWritePolicy.activeArchive,
        );
        final pending = AttachmentArchiveAdoptionTransaction(
          formatVersion:
              AttachmentArchiveAdoptionTransaction.currentFormatVersion,
          transactionId: '11111111-1111-4111-8111-111111111111',
          state: AttachmentArchiveAdoptionTransactionState
              .activeRemediationPending,
          kind: AttachmentArchiveAdoptionTransactionKind.verifiedBehind,
          previousConfiguration:
              const AttachmentArchiveLocationConfiguration.defaultInternal(),
          intendedConfiguration: intended,
          sourceCanonicalIdentity: '/disposable/retained-source',
          candidateCanonicalIdentity: tempDir.path,
          sourceLocationGeneration: 5,
          verificationContentDigest: List<String>.filled(64, '1').join(),
          sourceStructuralSnapshotFingerprint: List<String>.filled(
            64,
            '2',
          ).join(),
          candidateStructuralSnapshotFingerprint: List<String>.filled(
            64,
            '3',
          ).join(),
          verifiedFileCount: 4,
          verifiedBytes: 40,
          remediationPayloads: [
            AttachmentArchiveRemediationPayload(
              relativePath: relativePath,
              expectedSizeBytes: 3,
              expectedSha256: List<String>.filled(64, 'a').join(),
            ),
          ],
          createdAtUtc: DateTime.utc(2026, 9, 20),
          updatedAtUtc: DateTime.utc(2026, 9, 20),
        );
        container = await createContainer(
          archiveEnabled: true,
          location: AttachmentArchiveLocationState.customAvailable(
            configuration: intended,
            archiveRootPath: tempDir.path,
            generation: 6,
          ),
          pendingAdoption: pending,
        );

        final result = await container!.read(
          attachmentResolverProvider(
            AttachmentInfo(
              id: 9,
              archiveCompatibilityKey: const ArchiveCompatibilityKey(
                messageGuid: 'm-remediation',
                importAttachmentId: 99,
              ),
              localPath: retainedPayload.path,
              mimeType: 'application/octet-stream',
              transferName: 'pending.bin',
            ),
          ).future,
        );

        expect(
          result.availability,
          ResolvedAttachmentAvailability.pendingHistoricalRemediation,
        );
        expect(result.resolvedFilePath, isNull);
        expect(result.provenance, isNull);

        container!.dispose();
        container = await createContainer(
          archiveEnabled: true,
          location: AttachmentArchiveLocationState.customUnavailable(
            configuration: intended,
            generation: 6,
            issue: 'Candidate volume disconnected.',
          ),
          pendingAdoption: pending,
        );
        final unavailableResult = await container!.read(
          attachmentResolverProvider(
            AttachmentInfo(
              id: 9,
              archiveCompatibilityKey: const ArchiveCompatibilityKey(
                messageGuid: 'm-remediation',
                importAttachmentId: 99,
              ),
              localPath: retainedPayload.path,
              mimeType: 'application/octet-stream',
              transferName: 'pending.bin',
            ),
          ).future,
        );
        expect(
          unavailableResult.availability,
          ResolvedAttachmentAvailability.pendingHistoricalRemediation,
        );
        expect(unavailableResult.resolvedFilePath, isNull);
        expect(unavailableResult.provenance, isNull);
      },
    );
  });
}

final class _FixedAttachmentArchiveLocation extends AttachmentArchiveLocation {
  _FixedAttachmentArchiveLocation(this.location);

  final AttachmentArchiveLocationState location;

  @override
  Future<AttachmentArchiveLocationState> build() async => location;
}
