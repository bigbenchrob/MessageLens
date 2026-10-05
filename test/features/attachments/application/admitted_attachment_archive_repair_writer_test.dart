import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/app_czar_attachment_archive_repair/domain/app_czar_attachment_archive_repair_models.dart';
import 'package:remember_this_text/essentials/archive_compatibility/domain/archive_compatibility_key.dart';
import 'package:remember_this_text/essentials/archive_environment/domain.dart';
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/features/attachments/application/admitted_attachment_archive_repair_writer.dart';
import 'package:remember_this_text/features/attachments/application/app_czar_attachment_archive_repair_executor.dart';
import 'package:remember_this_text/features/attachments/application/app_czar_attachment_archive_repair_executor_factory_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_file_store.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_location_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_read_store.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_remediation_authority.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_write_store.dart';
import 'package:remember_this_text/features/attachments/application/current_messages_attachment_source_reader.dart';
import 'package:remember_this_text/features/attachments/application/required_attachment_evidence_reader.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_state.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_recovery_metadata.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/filesystem_attachment_archive_file_store.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/overlay_attachment_archive_read_store.dart';
import 'package:remember_this_text/features/attachments/infrastructure/repositories/overlay_attachment_archive_write_store.dart';

import '../../../test_support/test_archive_fixture.dart';

void main() {
  const archiveKey = ArchiveCompatibilityKey(
    messageGuid: 'repair-message-guid',
    importAttachmentId: 314,
  );

  late TestArchiveFixture archiveFixture;
  late Directory sourceDirectory;
  late File sourceFile;
  late ProviderContainer container;
  late ArchiveMutationCoordinator mutationCoordinator;
  late AttachmentArchiveWritableRootLease writableRootLease;
  late OverlayDatabase overlayDatabase;
  late OverlayAttachmentArchiveReadStore baseReadStore;
  late OverlayAttachmentArchiveWriteStore baseWriteStore;
  late CurrentMessagesAttachmentSourceObservation expectedSource;
  late List<String> events;

  setUp(() async {
    archiveFixture = await TestArchiveFixture.create(
      prefix: 'admitted_attachment_archive_repair_writer_archive_',
    );
    sourceDirectory = await Directory.systemTemp.createTemp(
      'admitted_attachment_archive_repair_writer_source_',
    );
    sourceFile = File('${sourceDirectory.path}/payload.jpg');
    await sourceFile.writeAsString('current source payload');
    container = ProviderContainer(
      overrides: [
        admittedArchiveAccessAuthorityProvider.overrideWithValue(
          archiveFixture.authority,
        ),
      ],
    );
    mutationCoordinator = container.read(
      archiveMutationCoordinatorProvider.notifier,
    );
    writableRootLease = (await container.read(
      attachmentArchiveWritableRootAdmissionProvider.future,
    )).lease!;
    overlayDatabase = OverlayDatabase(NativeDatabase.memory());
    baseReadStore = OverlayAttachmentArchiveReadStore(
      overlayDb: overlayDatabase,
      archiveDirectory: writableRootLease.archiveRootPath,
    );
    baseWriteStore = OverlayAttachmentArchiveWriteStore(
      overlayDatabase: overlayDatabase,
    );
    expectedSource = _availableObservation(
      archiveKey: archiveKey,
      sourceFile: sourceFile,
    );
    events = <String>[];
  });

  tearDown(() async {
    container.dispose();
    await overlayDatabase.close();
    await archiveFixture.dispose();
    if (sourceDirectory.existsSync()) {
      await sourceDirectory.delete(recursive: true);
    }
  });

  test(
    're-proves source and commits metadata only after payload install',
    () async {
      final sourceReader = _QueueSourceReader(
        <CurrentMessagesAttachmentSourceObservation>[
          expectedSource,
          expectedSource,
        ],
        events,
      );
      final fileStore = _RecordingFileStore(
        const FilesystemAttachmentArchiveFileStore(),
        events,
      );
      final readStore = _RecordingReadStore(baseReadStore, events);
      final writeStore = _RecordingWriteStore(baseWriteStore, events);
      final writer = _writer(
        sourceReader: sourceReader,
        fileStore: fileStore,
        readStore: readStore,
        writeStore: writeStore,
      );

      final result = await _preserveWithAuthority(
        coordinator: mutationCoordinator,
        writer: writer,
        writableRootLease: writableRootLease,
        expectedSource: expectedSource,
        archivedAtUtc: DateTime.utc(2026, 10, 4),
      );

      expect(
        result.status,
        AdmittedAttachmentArchiveRepairWriteStatus.preserved,
      );
      expect(result.installedBytes, await sourceFile.length());
      expect(sourceReader.calls, <ArchiveCompatibilityKey>[
        archiveKey,
        archiveKey,
      ]);
      expect(
        events.indexOf('source-read'),
        lessThan(events.indexOf('payload-write-start')),
      );
      expect(
        events.indexOf('payload-write-complete'),
        lessThan(events.lastIndexOf('source-read')),
      );
      expect(
        events.lastIndexOf('source-read'),
        lessThan(events.indexOf('metadata-commit')),
      );
      expect(
        events.indexOf('metadata-commit'),
        lessThan(events.indexOf('record-verify')),
      );
      expect(
        events.indexOf('record-verify'),
        lessThan(events.indexOf('payload-integrity-verify')),
      );

      final record = await baseReadStore.readArchiveRecord(archiveKey);
      expect(record, isNotNull);
      expect(record!.archiveFileExists, isTrue);
      expect(record.fileSizeBytes, await sourceFile.length());
      expect(record.contentHash, isNotEmpty);
      expect(record.provenance, 'archived');
      final rows = await overlayDatabase
          .select(overlayDatabase.archivedAttachments)
          .get();
      expect(rows.single.originalLocalPath, sourceFile.path);
      expect(rows.single.archivedAtUtc, '2026-10-04T00:00:00.000Z');
    },
  );

  test(
    'executor drain waits for the real writer and Ball release, then unlocks',
    () async {
      final writerEntered = Completer<void>();
      final releaseWriter = Completer<void>();
      addTearDown(() {
        if (!releaseWriter.isCompleted) {
          releaseWriter.complete();
        }
      });
      final lifecycle = <String>[];
      final writer = _writer(
        sourceReader: _BlockingAvailableSourceReader(
          observation: expectedSource,
          entered: writerEntered,
          release: releaseWriter,
        ),
        fileStore: _RecordingFileStore(
          const FilesystemAttachmentArchiveFileStore(),
          events,
        ),
        readStore: _RecordingReadStore(baseReadStore, events),
        writeStore: _RecordingWriteStore(baseWriteStore, events),
      );
      final binding = AppCzarAttachmentArchiveRepairBinding(
        occurrenceId: 1,
        assessmentGeneration: 1,
        archiveScopeIdentity: 'real-batch-drain-test',
        archiveGeneration: writableRootLease.locationGeneration,
        resolvedArchivePath: writableRootLease.archiveRootPath,
      );
      final context = AttachmentArchiveRepairArchiveContext(
        archiveScopeIdentity: binding.archiveScopeIdentity,
        archiveGeneration: binding.archiveGeneration,
        resolvedArchivePath: binding.resolvedArchivePath,
        automaticPreservationAllowed: true,
      );
      final evidence = _SingleNoRecordEvidenceReader(
        binding: context.evidenceBinding,
        archiveKey: archiveKey,
      );
      final batchExecutor =
          createAdmittedAttachmentArchiveRepairMutationBatchExecutor(
            runAdmitted: (action) async {
              try {
                return await mutationCoordinator.runWithCapability<
                  AttachmentArchiveRepairMutationBatchResult
                >(
                  operation: ArchiveMutationOperation.attachmentReconciliation,
                  ownerLabel: 'real-attachment-repair-drain-test',
                  action: action,
                );
              } finally {
                lifecycle.add('ball-released');
              }
            },
            readCurrentContext: () async => context,
            readWritableAdmission: () async {
              return AttachmentArchiveWritableRootAdmission.admitted(
                writableRootLease,
              );
            },
            readWriter: () async => writer,
          );
      final executor = MessageLensAppCzarAttachmentArchiveRepairExecutor(
        evidenceReader: evidence,
        sourceReaderResolver: () async {
          return _AlwaysAvailableSourceReader(expectedSource);
        },
        archiveContextReader: () async => context,
        mutationBatchExecutor: batchExecutor,
      );

      final preservation = executor.preserveAvailable(binding: binding);
      await writerEntered.future;
      expect(mutationCoordinator.state.isLocked, isTrue);
      expect(
        mutationCoordinator.state.activeOperations,
        contains(ArchiveMutationOperation.attachmentReconciliation),
      );

      var drainCompleted = false;
      final drain = executor.stopAndDrain().then((_) {
        lifecycle.add('drain-complete');
        drainCompleted = true;
      });
      await Future<void>.delayed(Duration.zero);

      expect(drainCompleted, isFalse);
      expect(lifecycle, isEmpty);
      expect(mutationCoordinator.state.isLocked, isTrue);

      releaseWriter.complete();
      final observation = await preservation;
      await drain;

      expect(
        observation.kind,
        AppCzarAttachmentArchiveRepairObservationKind.stopped,
      );
      expect(lifecycle, <String>['ball-released', 'drain-complete']);
      expect(mutationCoordinator.state.isLocked, isFalse);
      expect(mutationCoordinator.state.activeOperations, isEmpty);
      expect(await baseReadStore.readArchiveRecord(archiveKey), isNotNull);
      await mutationCoordinator.runWithCapability<void>(
        operation: ArchiveMutationOperation.attachmentReconciliation,
        ownerLabel: 'post-drain-unlocked-test',
        action: (capability) async {
          capability.requireOperation(
            ArchiveMutationOperation.attachmentReconciliation,
          );
        },
      );
    },
  );

  test('does not overwrite a record that appears before mutation', () async {
    await baseWriteStore.writeArchiveRecord(
      ArchivedAttachmentWrite(
        archiveKey: archiveKey,
        archiveRelativePath: 'aa/already-present.jpg',
        archivedAtUtc: DateTime.utc(2026, 10, 4).toIso8601String(),
        fileSizeBytes: 10,
        contentHash: 'a' * 64,
        originalLocalPath: null,
      ),
    );
    final fileStore = _RecordingFileStore(
      const FilesystemAttachmentArchiveFileStore(),
      events,
    );
    final writeStore = _RecordingWriteStore(baseWriteStore, events);
    final writer = _writer(
      sourceReader: _QueueSourceReader(
        <CurrentMessagesAttachmentSourceObservation>[expectedSource],
        events,
      ),
      fileStore: fileStore,
      readStore: _RecordingReadStore(baseReadStore, events),
      writeStore: writeStore,
    );

    final result = await _preserveWithAuthority(
      coordinator: mutationCoordinator,
      writer: writer,
      writableRootLease: writableRootLease,
      expectedSource: expectedSource,
    );

    expect(
      result.status,
      AdmittedAttachmentArchiveRepairWriteStatus.recordAppeared,
    );
    expect(fileStore.writeCalls, 0);
    expect(writeStore.metadataWrites, 0);
  });

  test('changed current material evidence prevents mutation', () async {
    final changedSource = CurrentMessagesAttachmentSourceObservation.available(
      archiveKey: archiveKey,
      sourcePath: sourceFile.path,
      mimeType: 'image/jpeg',
      fileSizeBytes: expectedSource.fileSizeBytes! + 1,
      modifiedAtMicrosecondsSinceEpoch:
          expectedSource.modifiedAtMicrosecondsSinceEpoch!,
    );
    final fileStore = _RecordingFileStore(
      const FilesystemAttachmentArchiveFileStore(),
      events,
    );
    final writeStore = _RecordingWriteStore(baseWriteStore, events);
    final writer = _writer(
      sourceReader: _QueueSourceReader(
        <CurrentMessagesAttachmentSourceObservation>[changedSource],
        events,
      ),
      fileStore: fileStore,
      readStore: _RecordingReadStore(baseReadStore, events),
      writeStore: writeStore,
    );

    final result = await _preserveWithAuthority(
      coordinator: mutationCoordinator,
      writer: writer,
      writableRootLease: writableRootLease,
      expectedSource: expectedSource,
    );

    expect(
      result.status,
      AdmittedAttachmentArchiveRepairWriteStatus.sourceChanged,
    );
    expect(fileStore.writeCalls, 0);
    expect(writeStore.recordChecks, 0);
    expect(writeStore.metadataWrites, 0);
  });

  test(
    'source change after payload install prevents metadata commit',
    () async {
      final changedSource =
          CurrentMessagesAttachmentSourceObservation.available(
            archiveKey: archiveKey,
            sourcePath: sourceFile.path,
            mimeType: 'image/jpeg',
            fileSizeBytes: expectedSource.fileSizeBytes!,
            modifiedAtMicrosecondsSinceEpoch:
                expectedSource.modifiedAtMicrosecondsSinceEpoch! + 1,
          );
      final fileStore = _RecordingFileStore(
        const FilesystemAttachmentArchiveFileStore(),
        events,
      );
      final writeStore = _RecordingWriteStore(baseWriteStore, events);
      final writer = _writer(
        sourceReader: _QueueSourceReader(
          <CurrentMessagesAttachmentSourceObservation>[
            expectedSource,
            changedSource,
          ],
          events,
        ),
        fileStore: fileStore,
        readStore: _RecordingReadStore(baseReadStore, events),
        writeStore: writeStore,
      );

      final result = await _preserveWithAuthority(
        coordinator: mutationCoordinator,
        writer: writer,
        writableRootLease: writableRootLease,
        expectedSource: expectedSource,
      );

      expect(
        result.status,
        AdmittedAttachmentArchiveRepairWriteStatus.sourceChanged,
      );
      expect(fileStore.writeCalls, 1);
      expect(writeStore.metadataWrites, 0);
      expect(result.archiveRelativePath, isNotNull);
      expect(await baseReadStore.readArchiveRecord(archiveKey), isNull);
    },
  );

  test('source unavailable remains factual and performs no mutation', () async {
    const unavailable =
        CurrentMessagesAttachmentSourceObservation.sourceUnavailable(
          archiveKey: archiveKey,
          issue: 'Messages database unavailable.',
        );
    final fileStore = _RecordingFileStore(
      const FilesystemAttachmentArchiveFileStore(),
      events,
    );
    final writeStore = _RecordingWriteStore(baseWriteStore, events);
    final writer = _writer(
      sourceReader: _QueueSourceReader(
        <CurrentMessagesAttachmentSourceObservation>[unavailable],
        events,
      ),
      fileStore: fileStore,
      readStore: _RecordingReadStore(baseReadStore, events),
      writeStore: writeStore,
    );

    final result = await _preserveWithAuthority(
      coordinator: mutationCoordinator,
      writer: writer,
      writableRootLease: writableRootLease,
      expectedSource: expectedSource,
    );

    expect(
      result.status,
      AdmittedAttachmentArchiveRepairWriteStatus.sourceUnavailable,
    );
    expect(fileStore.writeCalls, 0);
    expect(writeStore.metadataWrites, 0);
  });

  test(
    'distinguishes global source inconclusive from item inconclusive',
    () async {
      const globallyInconclusive =
          CurrentMessagesAttachmentSourceObservation.sourceInconclusive(
            archiveKey: archiveKey,
            issue: 'The source query was inconclusive.',
          );
      const itemInconclusive =
          CurrentMessagesAttachmentSourceObservation.unknown(
            archiveKey: archiveKey,
            issue: 'The payload path was inconclusive.',
          );
      final fileStore = _RecordingFileStore(
        const FilesystemAttachmentArchiveFileStore(),
        events,
      );
      final writer = _writer(
        sourceReader: _QueueSourceReader(
          <CurrentMessagesAttachmentSourceObservation>[
            globallyInconclusive,
            itemInconclusive,
          ],
          events,
        ),
        fileStore: fileStore,
        readStore: _RecordingReadStore(baseReadStore, events),
        writeStore: _RecordingWriteStore(baseWriteStore, events),
      );

      final globalResult = await _preserveWithAuthority(
        coordinator: mutationCoordinator,
        writer: writer,
        writableRootLease: writableRootLease,
        expectedSource: expectedSource,
      );
      final itemResult = await _preserveWithAuthority(
        coordinator: mutationCoordinator,
        writer: writer,
        writableRootLease: writableRootLease,
        expectedSource: expectedSource,
      );

      expect(
        globalResult.status,
        AdmittedAttachmentArchiveRepairWriteStatus.sourceInconclusive,
      );
      expect(
        itemResult.status,
        AdmittedAttachmentArchiveRepairWriteStatus.itemInconclusive,
      );
      expect(fileStore.writeCalls, 0);
    },
  );

  test(
    'metadata failure leaves verified payload without false success',
    () async {
      final fileStore = _RecordingFileStore(
        const FilesystemAttachmentArchiveFileStore(),
        events,
      );
      final writeStore = _RecordingWriteStore(
        baseWriteStore,
        events,
        failMetadataWrite: true,
      );
      final writer = _writer(
        sourceReader: _QueueSourceReader(
          <CurrentMessagesAttachmentSourceObservation>[
            expectedSource,
            expectedSource,
          ],
          events,
        ),
        fileStore: fileStore,
        readStore: _RecordingReadStore(baseReadStore, events),
        writeStore: writeStore,
      );

      final result = await _preserveWithAuthority(
        coordinator: mutationCoordinator,
        writer: writer,
        writableRootLease: writableRootLease,
        expectedSource: expectedSource,
      );

      expect(
        result.status,
        AdmittedAttachmentArchiveRepairWriteStatus.metadataCommitFailed,
      );
      expect(result.archiveRelativePath, isNotNull);
      expect(
        File(
          path.join(
            writableRootLease.archiveRootPath,
            result.archiveRelativePath,
          ),
        ).existsSync(),
        isTrue,
      );
      expect(await baseReadStore.readArchiveRecord(archiveKey), isNull);
    },
  );

  test('post-commit verification mismatch never reports preserved', () async {
    final writer = _writer(
      sourceReader: _QueueSourceReader(
        <CurrentMessagesAttachmentSourceObservation>[
          expectedSource,
          expectedSource,
        ],
        events,
      ),
      fileStore: _RecordingFileStore(
        const FilesystemAttachmentArchiveFileStore(),
        events,
      ),
      readStore: _RecordingReadStore(
        baseReadStore,
        events,
        forceMissingRecord: true,
      ),
      writeStore: _RecordingWriteStore(baseWriteStore, events),
    );

    final result = await _preserveWithAuthority(
      coordinator: mutationCoordinator,
      writer: writer,
      writableRootLease: writableRootLease,
      expectedSource: expectedSource,
    );

    expect(
      result.status,
      AdmittedAttachmentArchiveRepairWriteStatus.verificationFailed,
    );
    expect(await baseReadStore.readArchiveRecord(archiveKey), isNotNull);
  });

  test('rejects wrong-operation and expired callback capabilities', () async {
    final fileStore = _RecordingFileStore(
      const FilesystemAttachmentArchiveFileStore(),
      events,
    );
    final writer = _writer(
      sourceReader: _QueueSourceReader(
        <CurrentMessagesAttachmentSourceObservation>[expectedSource],
        events,
      ),
      fileStore: fileStore,
      readStore: _RecordingReadStore(baseReadStore, events),
      writeStore: _RecordingWriteStore(baseWriteStore, events),
    );

    await expectLater(
      mutationCoordinator.runWithCapability<void>(
        operation: ArchiveMutationOperation.graphBuild,
        ownerLabel: 'wrong-operation-repair-writer-test',
        action: (capability) async {
          await writer.preserveNoRecord(
            capability: capability,
            writableRootLease: writableRootLease,
            expectedSource: expectedSource,
          );
        },
      ),
      throwsA(isA<ArchiveMutationCapabilityDeniedException>()),
    );

    late ArchiveMutationCapability expiredCapability;
    await mutationCoordinator.runWithCapability<void>(
      operation: ArchiveMutationOperation.attachmentReconciliation,
      ownerLabel: 'capture-expired-repair-capability-test',
      action: (capability) async {
        expiredCapability = capability;
      },
    );
    await expectLater(
      writer.preserveNoRecord(
        capability: expiredCapability,
        writableRootLease: writableRootLease,
        expectedSource: expectedSource,
      ),
      throwsA(isA<ArchiveMutationCapabilityDeniedException>()),
    );
    expect(fileStore.writeCalls, 0);
  });
}

AdmittedAttachmentArchiveRepairWriter _writer({
  required CurrentMessagesAttachmentSourceReader sourceReader,
  required AttachmentArchiveFileStore fileStore,
  required AttachmentArchiveReadStore readStore,
  required AttachmentArchiveWriteStore writeStore,
}) {
  return AdmittedAttachmentArchiveRepairWriter(
    sourceReader: sourceReader,
    fileStore: fileStore,
    readStore: readStore,
    writeStore: writeStore,
  );
}

Future<AdmittedAttachmentArchiveRepairWriteResult> _preserveWithAuthority({
  required ArchiveMutationCoordinator coordinator,
  required AdmittedAttachmentArchiveRepairWriter writer,
  required AttachmentArchiveWritableRootLease writableRootLease,
  required CurrentMessagesAttachmentSourceObservation expectedSource,
  DateTime? archivedAtUtc,
}) {
  return coordinator
      .runWithCapability<AdmittedAttachmentArchiveRepairWriteResult>(
        operation: ArchiveMutationOperation.attachmentReconciliation,
        ownerLabel: 'admitted-attachment-repair-writer-test',
        action: (capability) => writer.preserveNoRecord(
          capability: capability,
          writableRootLease: writableRootLease,
          expectedSource: expectedSource,
          archivedAtUtc: archivedAtUtc,
        ),
      );
}

CurrentMessagesAttachmentSourceObservation _availableObservation({
  required ArchiveCompatibilityKey archiveKey,
  required File sourceFile,
}) {
  final stat = sourceFile.statSync();
  return CurrentMessagesAttachmentSourceObservation.available(
    archiveKey: archiveKey,
    sourcePath: sourceFile.path,
    mimeType: 'image/jpeg',
    fileSizeBytes: stat.size,
    modifiedAtMicrosecondsSinceEpoch: stat.modified.microsecondsSinceEpoch,
  );
}

final class _QueueSourceReader
    implements CurrentMessagesAttachmentSourceReader {
  _QueueSourceReader(this.observations, this.events);

  final List<CurrentMessagesAttachmentSourceObservation> observations;
  final List<String> events;
  final calls = <ArchiveCompatibilityKey>[];

  @override
  Future<CurrentMessagesAttachmentSourceObservation> observeCurrent(
    ArchiveCompatibilityKey archiveKey,
  ) async {
    events.add('source-read');
    calls.add(archiveKey);
    if (observations.isEmpty) {
      throw StateError('No source observation remains.');
    }
    return observations.removeAt(0);
  }

  @override
  Future<List<CurrentMessagesAttachmentSourceObservation>> observeCurrentPage(
    List<ArchiveCompatibilityKey> archiveKeys,
  ) async {
    final results = <CurrentMessagesAttachmentSourceObservation>[];
    for (final archiveKey in archiveKeys) {
      results.add(await observeCurrent(archiveKey));
    }
    return results;
  }
}

final class _AlwaysAvailableSourceReader
    implements CurrentMessagesAttachmentSourceReader {
  const _AlwaysAvailableSourceReader(this.observation);

  final CurrentMessagesAttachmentSourceObservation observation;

  @override
  Future<CurrentMessagesAttachmentSourceObservation> observeCurrent(
    ArchiveCompatibilityKey archiveKey,
  ) async {
    expect(archiveKey, observation.archiveKey);
    return observation;
  }

  @override
  Future<List<CurrentMessagesAttachmentSourceObservation>> observeCurrentPage(
    List<ArchiveCompatibilityKey> archiveKeys,
  ) async {
    expect(archiveKeys, <ArchiveCompatibilityKey>[observation.archiveKey]);
    return <CurrentMessagesAttachmentSourceObservation>[observation];
  }
}

final class _BlockingAvailableSourceReader
    implements CurrentMessagesAttachmentSourceReader {
  _BlockingAvailableSourceReader({
    required this.observation,
    required this.entered,
    required this.release,
  });

  final CurrentMessagesAttachmentSourceObservation observation;
  final Completer<void> entered;
  final Completer<void> release;
  bool _blocked = false;

  @override
  Future<CurrentMessagesAttachmentSourceObservation> observeCurrent(
    ArchiveCompatibilityKey archiveKey,
  ) async {
    expect(archiveKey, observation.archiveKey);
    if (!_blocked) {
      _blocked = true;
      entered.complete();
      await release.future;
    }
    return observation;
  }

  @override
  Future<List<CurrentMessagesAttachmentSourceObservation>> observeCurrentPage(
    List<ArchiveCompatibilityKey> archiveKeys,
  ) async {
    final observations = <CurrentMessagesAttachmentSourceObservation>[];
    for (final archiveKey in archiveKeys) {
      observations.add(await observeCurrent(archiveKey));
    }
    return observations;
  }
}

final class _SingleNoRecordEvidenceReader
    implements RequiredAttachmentEvidenceReader {
  const _SingleNoRecordEvidenceReader({
    required this.binding,
    required this.archiveKey,
  });

  final RequiredAttachmentEvidenceBinding binding;
  final ArchiveCompatibilityKey archiveKey;

  @override
  Future<RequiredAttachmentEvidencePage> readPage({
    required RequiredAttachmentEvidenceBinding binding,
    RequiredAttachmentEvidenceCursor? after,
    int limit = 75,
  }) async {
    expect(binding, this.binding);
    expect(after, isNull);
    expect(limit, greaterThanOrEqualTo(1));
    return RequiredAttachmentEvidencePage(
      items: <RequiredAttachmentEvidenceItem>[
        RequiredAttachmentEvidenceItem(
          cursor: RequiredAttachmentEvidenceCursor(
            messageGuid: archiveKey.messageGuid,
            liveAttachmentRowId: archiveKey.liveSourceAttachmentRowId,
          ),
          archiveKey: archiveKey,
          condition: RequiredAttachmentEvidenceCondition.noDurableRecord,
          materialFingerprint: 'single-no-record',
        ),
      ],
      nextCursor: null,
      hasMore: false,
      binding: binding,
    );
  }

  @override
  Future<RequiredAttachmentEvidenceSummary> readSummary({
    required RequiredAttachmentEvidenceBinding binding,
    int pageSize = 75,
  }) async {
    expect(binding, this.binding);
    expect(pageSize, greaterThanOrEqualTo(1));
    return RequiredAttachmentEvidenceSummary(
      requiredCount: 1,
      coveredCount: 0,
      missingCount: 1,
      unverifiableCount: 0,
      materialFingerprint: 'single-no-record-summary',
      binding: binding,
    );
  }
}

final class _RecordingFileStore implements AttachmentArchiveFileStore {
  const _RecordingFileStore(this.delegate, this.events);

  final AttachmentArchiveFileStore delegate;
  final List<String> events;

  int get writeCalls =>
      events.where((event) => event == 'payload-write-start').length;

  @override
  Future<ArchiveIntegrityFileCheck> checkIntegrity({
    required String archiveDirectoryPath,
    required String relativePath,
    required String? storedHash,
  }) {
    events.add('payload-integrity-verify');
    return delegate.checkIntegrity(
      archiveDirectoryPath: archiveDirectoryPath,
      relativePath: relativePath,
      storedHash: storedHash,
    );
  }

  @override
  Future<void> ensureArchiveDirectory(
    String archiveDirectoryPath, {
    required Future<void> Function(AttachmentArchiveMutationBoundary boundary)
    validateMutation,
  }) {
    return delegate.ensureArchiveDirectory(
      archiveDirectoryPath,
      validateMutation: validateMutation,
    );
  }

  @override
  String expandHomePath(String rawPath) => delegate.expandHomePath(rawPath);

  @override
  bool fileExists(String path) => delegate.fileExists(path);

  @override
  Future<AttachmentArchiveFileInstall> installVerifiedArchiveEntry({
    required String archiveDirectoryPath,
    required Stream<List<int>> sourceBytes,
    required String sourceExtension,
    required int expectedSizeBytes,
    required String expectedSha256,
    required Future<void> Function(AttachmentArchiveMutationBoundary boundary)
    validateMutation,
  }) {
    return delegate.installVerifiedArchiveEntry(
      archiveDirectoryPath: archiveDirectoryPath,
      sourceBytes: sourceBytes,
      sourceExtension: sourceExtension,
      expectedSizeBytes: expectedSizeBytes,
      expectedSha256: expectedSha256,
      validateMutation: validateMutation,
    );
  }

  @override
  Future<AttachmentArchiveFileInstall> installVerifiedArchiveEntryAtPath({
    required String archiveDirectoryPath,
    required Stream<List<int>> sourceBytes,
    required AttachmentArchiveRemediationAuthority remediationAuthority,
  }) {
    return delegate.installVerifiedArchiveEntryAtPath(
      archiveDirectoryPath: archiveDirectoryPath,
      sourceBytes: sourceBytes,
      remediationAuthority: remediationAuthority,
    );
  }

  @override
  Future<ArchivedAttachmentFileWrite?> writeArchiveEntry({
    required String archiveDirectoryPath,
    required String sourcePath,
    required ArchiveCompatibilityKey archiveKey,
    required String? sha256Hex,
    required Future<void> Function(AttachmentArchiveMutationBoundary boundary)
    validateMutation,
  }) async {
    events.add('payload-write-start');
    final result = await delegate.writeArchiveEntry(
      archiveDirectoryPath: archiveDirectoryPath,
      sourcePath: sourcePath,
      archiveKey: archiveKey,
      sha256Hex: sha256Hex,
      validateMutation: validateMutation,
    );
    events.add('payload-write-complete');
    return result;
  }
}

final class _RecordingWriteStore implements AttachmentArchiveWriteStore {
  const _RecordingWriteStore(
    this.delegate,
    this.events, {
    this.failMetadataWrite = false,
  });

  final AttachmentArchiveWriteStore delegate;
  final List<String> events;
  final bool failMetadataWrite;

  int get recordChecks =>
      events.where((event) => event == 'record-check').length;
  int get metadataWrites =>
      events.where((event) => event == 'metadata-commit').length;

  @override
  Future<void> clearRecoveryHint(ArchiveCompatibilityKey archiveKey) {
    return delegate.clearRecoveryHint(archiveKey);
  }

  @override
  Future<bool> hasArchiveRecord(ArchiveCompatibilityKey archiveKey) {
    events.add('record-check');
    return delegate.hasArchiveRecord(archiveKey);
  }

  @override
  Future<List<ArchiveIntegrityEntry>> readIntegrityEntries() {
    return delegate.readIntegrityEntries();
  }

  @override
  Future<AttachmentRecoveryMetadata?> readRecoveryHint(
    ArchiveCompatibilityKey archiveKey,
  ) {
    return delegate.readRecoveryHint(archiveKey);
  }

  @override
  Future<void> reconcileArchiveRecord(ArchivedAttachmentWrite record) {
    return delegate.reconcileArchiveRecord(record);
  }

  @override
  Future<void> writeArchiveRecord(ArchivedAttachmentWrite record) {
    events.add('metadata-commit');
    if (failMetadataWrite) {
      throw StateError('Simulated metadata failure.');
    }
    return delegate.writeArchiveRecord(record);
  }

  @override
  Future<void> writeRecoveryHint({
    required ArchiveCompatibilityKey archiveKey,
    required AttachmentRecoveryMetadata metadata,
  }) {
    return delegate.writeRecoveryHint(
      archiveKey: archiveKey,
      metadata: metadata,
    );
  }
}

final class _RecordingReadStore implements AttachmentArchiveReadStore {
  const _RecordingReadStore(
    this.delegate,
    this.events, {
    this.forceMissingRecord = false,
  });

  final AttachmentArchiveReadStore delegate;
  final List<String> events;
  final bool forceMissingRecord;

  @override
  AttachmentArchiveLocationState get location => delegate.location;

  @override
  Future<Map<ArchiveCompatibilityKey, AttachmentArchiveMetadataRecord>>
  readAllArchiveMetadata() {
    return delegate.readAllArchiveMetadata();
  }

  @override
  Future<AttachmentArchiveLookupRecord?> readArchiveRecord(
    ArchiveCompatibilityKey archiveKey,
  ) {
    events.add('record-verify');
    if (forceMissingRecord) {
      return Future<AttachmentArchiveLookupRecord?>.value();
    }
    return delegate.readArchiveRecord(archiveKey);
  }

  @override
  Future<AttachmentRecoveryMetadata?> readRecoveryHint(
    ArchiveCompatibilityKey archiveKey,
  ) {
    return delegate.readRecoveryHint(archiveKey);
  }
}
