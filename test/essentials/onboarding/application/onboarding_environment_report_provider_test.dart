import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/domain_driven_development/value_objects.dart';
import 'package:remember_this_text/essentials/archive_environment/domain.dart';
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart'
    show
        ArchiveMutationCapability,
        admittedArchiveAccessAuthorityProvider,
        archiveMutationCoordinatorProvider;
import 'package:remember_this_text/essentials/conversation_graph/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/app_database_files.dart';
import 'package:remember_this_text/essentials/db/application/conversation_graph_readiness.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart'
    show dbMaintenanceLockProvider, overlayDatabaseProvider;
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_database_probe_reader.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_database_probe_reader_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_environment_report_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_failure_storage_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/onboarding_failure_store.dart';
import 'package:remember_this_text/essentials/onboarding/domain/onboarding_environment_report.dart';
import 'package:remember_this_text/essentials/onboarding/infrastructure/persistence/overlay_onboarding_failure_storage.dart';
import 'package:remember_this_text/essentials/onboarding/infrastructure/persistence/sqlite_onboarding_database_probe_reader.dart';
import 'package:remember_this_text/features/address_book_folders/application/address_book_folder_providers.dart';
import 'package:remember_this_text/features/address_book_folders/domain/entities/address_book_folder_aggregate.dart';
import 'package:remember_this_text/features/address_book_folders/domain/entities/address_book_folder_entity.dart';
import 'package:remember_this_text/features/address_book_folders/domain/failures/folder_retrieval_failure.dart';
import 'package:remember_this_text/features/address_book_folders/domain/value_objects/value_objects.dart';
import 'package:remember_this_text/features/attachments/feature_level_providers.dart'
    show
        AttachmentArchiveLocation,
        AttachmentArchiveLocationConfiguration,
        AttachmentArchiveLocationState,
        attachmentArchiveLocationProvider;
import 'package:sqlite3/sqlite3.dart';

final class _AdmittedEvidenceRequest {
  const _AdmittedEvidenceRequest({
    required this.capability,
    required this.operation,
    required this.nonce,
  });

  final ArchiveMutationCapability capability;
  final ArchiveMutationOperation operation;
  final int nonce;
}

final _admittedEvidenceProvider = FutureProvider.autoDispose
    .family<OnboardingEnvironmentReport, _AdmittedEvidenceRequest>((
      ref,
      request,
    ) {
      return readAdmittedOnboardingEnvironmentEvidence(
        ref,
        capability: request.capability,
        expectedOperation: request.operation,
      );
    });

void main() {
  group('onboardingEnvironmentReportProvider', () {
    late Directory tempDir;
    late OverlayDatabase overlayDb;
    late ProviderContainer container;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'onboarding_environment_report_provider_test',
      );
      overlayDb = OverlayDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      container.dispose();
      await overlayDb.close();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
      'treats previous import failures as ready to import when app databases are empty',
      () async {
        final messagesDbPath = _createMessagesDatabase(
          tempDir.path,
          messageCount: 11,
        );
        final addressBookPath = _createReadableFile(
          tempDir.path,
          'AddressBook-v22.abcddb',
        );
        final recordedAt = DateTime.utc(2026, 03, 24, 12, 45);

        final storage = OverlayOnboardingFailureStorage(
          overlayDb: Future<OverlayDatabase>.value(overlayDb),
        );
        await storage.saveImportFailure(
          batchId: 99,
          message: 'Persisted import failure',
          recordedAt: recordedAt,
        );

        container = ProviderContainer(
          overrides: [
            ..._lifecycleOverrides(),
            overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
            onboardingFullDiskAccessProvider.overrideWith((ref) => true),
            onboardingMessagesDatabasePathProvider.overrideWith(
              (ref) => messagesDbPath,
            ),
            onboardingDatabaseDirectoryPathProvider.overrideWith(
              (ref) => tempDir.path,
            ),
            _attachmentArchiveLocationOverride(tempDir.path),
            futureGetFolderAggregateProvider.overrideWith(
              (ref) async => right(_addressBookAggregate(addressBookPath)),
            ),
          ],
        );

        final report = await container.read(
          onboardingEnvironmentReportProvider.future,
        );

        expect(report.state, OnboardingEnvironmentState.readyToImport);
        expect(
          report.blockerKind,
          OnboardingBlockerKind.sourceScopedImportDatabaseMissing,
        );
        expect(report.importFailureMessage, 'Persisted import failure');
        expect(report.usingPersistedImportFailure, isTrue);
        expect(report.lastImportFailureRecordedAt, recordedAt);
      },
    );

    test('full disk access wins when Contacts is also unavailable', () async {
      final messagesDbPath = _createMessagesDatabase(
        tempDir.path,
        messageCount: 11,
      );
      container = ProviderContainer(
        overrides: [
          ..._lifecycleOverrides(),
          overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
          onboardingFullDiskAccessProvider.overrideWith((ref) => true),
          onboardingMessagesDatabasePathProvider.overrideWith(
            (ref) => messagesDbPath,
          ),
          onboardingDatabaseDirectoryPathProvider.overrideWith(
            (ref) => tempDir.path,
          ),
          _attachmentArchiveLocationOverride(tempDir.path),
          futureGetFolderAggregateProvider.overrideWith(
            (ref) async => left(
              const FolderRetrievalFailure(message: 'Contacts unavailable'),
            ),
          ),
        ],
      );

      container
          .read(onboardingDevOverridesProvider.notifier)
          .setFullDiskAccessBlocked(enabled: true);

      final report = await container.refresh(
        onboardingEnvironmentReportProvider.future,
      );

      expect(report.state, OnboardingEnvironmentState.permissionBlocked);
      expect(report.blockerKind, OnboardingBlockerKind.fullDiskAccessMissing);
      expect(report.hasFullDiskAccess, isFalse);
    });

    test('simulated import failure overrides ready app state', () async {
      final messagesDbPath = _createMessagesDatabase(
        tempDir.path,
        messageCount: 11,
      );
      final addressBookPath = _createReadableFile(
        tempDir.path,
        'AddressBook-v22.abcddb',
      );
      _createNonEmptyDatabaseFile(
        tempDir.path,
        appDatabaseFileName(AppDatabaseFile.sourceScopedImport),
      );
      _createGraphDatabase(tempDir.path);

      container = ProviderContainer(
        overrides: [
          ..._lifecycleOverrides(),
          overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
          onboardingFullDiskAccessProvider.overrideWith((ref) => true),
          onboardingMessagesDatabasePathProvider.overrideWith(
            (ref) => messagesDbPath,
          ),
          onboardingDatabaseDirectoryPathProvider.overrideWith(
            (ref) => tempDir.path,
          ),
          _attachmentArchiveLocationOverride(tempDir.path),
          futureGetFolderAggregateProvider.overrideWith(
            (ref) async => right(_addressBookAggregate(addressBookPath)),
          ),
        ],
      );

      container
          .read(onboardingDevOverridesProvider.notifier)
          .setImportFailure(enabled: true);

      final report = await container.refresh(
        onboardingEnvironmentReportProvider.future,
      );

      expect(report.state, OnboardingEnvironmentState.importFailed);
      expect(report.blockerKind, OnboardingBlockerKind.importFailed);
      expect(
        report.importFailureMessage,
        'Simulated import failure from onboarding dev panel',
      );
      expect(report.usingPersistedImportFailure, isFalse);
    });

    test(
      'retired cleanup databases do not satisfy onboarding readiness',
      () async {
        final messagesDbPath = _createMessagesDatabase(
          tempDir.path,
          messageCount: 11,
        );
        final addressBookPath = _createReadableFile(
          tempDir.path,
          'AddressBook-v22.abcddb',
        );
        _createNonEmptyDatabaseFile(
          tempDir.path,
          appDatabaseFileName(AppDatabaseFile.retiredMacosImport),
        );
        _createNonEmptyDatabaseFile(
          tempDir.path,
          appDatabaseFileName(AppDatabaseFile.retiredWorking),
        );

        container = ProviderContainer(
          overrides: [
            ..._lifecycleOverrides(),
            overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
            onboardingFullDiskAccessProvider.overrideWith((ref) => true),
            onboardingMessagesDatabasePathProvider.overrideWith(
              (ref) => messagesDbPath,
            ),
            onboardingDatabaseDirectoryPathProvider.overrideWith(
              (ref) => tempDir.path,
            ),
            _attachmentArchiveLocationOverride(tempDir.path),
            futureGetFolderAggregateProvider.overrideWith(
              (ref) async => right(_addressBookAggregate(addressBookPath)),
            ),
          ],
        );

        final report = await container.read(
          onboardingEnvironmentReportProvider.future,
        );

        expect(report.state, OnboardingEnvironmentState.readyToImport);
        expect(
          report.blockerKind,
          OnboardingBlockerKind.sourceScopedImportDatabaseMissing,
        );
        expect(report.sourceScopedImportDatabase.exists, isFalse);
        expect(report.conversationGraph.exists, isFalse);
        expect(report.hasPopulatedAppDatabases, isFalse);
      },
    );

    test('conversation graph without topology is not ready', () async {
      final messagesDbPath = _createMessagesDatabase(
        tempDir.path,
        messageCount: 120,
      );
      final addressBookPath = _createReadableFile(
        tempDir.path,
        'AddressBook-v22.abcddb',
      );
      _createNonEmptyDatabaseFile(
        tempDir.path,
        appDatabaseFileName(AppDatabaseFile.sourceScopedImport),
      );
      _createGraphDatabase(tempDir.path, graphComplete: false);

      container = ProviderContainer(
        overrides: [
          ..._lifecycleOverrides(),
          overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
          onboardingFullDiskAccessProvider.overrideWith((ref) => true),
          onboardingMessagesDatabasePathProvider.overrideWith(
            (ref) => messagesDbPath,
          ),
          onboardingDatabaseDirectoryPathProvider.overrideWith(
            (ref) => tempDir.path,
          ),
          _attachmentArchiveLocationOverride(tempDir.path),
          futureGetFolderAggregateProvider.overrideWith(
            (ref) async => right(_addressBookAggregate(addressBookPath)),
          ),
        ],
      );

      final report = await container.read(
        onboardingEnvironmentReportProvider.future,
      );

      expect(report.state, OnboardingEnvironmentState.graphProjectionFailed);
      expect(report.blockerKind, OnboardingBlockerKind.graphProjectionFailed);
    });

    test(
      'active database maintenance is not a graph projection failure',
      () async {
        final messagesDbPath = _createMessagesDatabase(
          tempDir.path,
          messageCount: 120,
        );
        final addressBookPath = _createReadableFile(
          tempDir.path,
          'AddressBook-v22.abcddb',
        );
        _createNonEmptyDatabaseFile(
          tempDir.path,
          appDatabaseFileName(AppDatabaseFile.sourceScopedImport),
        );
        _createGraphDatabase(tempDir.path, graphComplete: false);
        final databaseProbeReader = _RecordingOnboardingDatabaseProbeReader();

        container = ProviderContainer(
          overrides: [
            ..._lifecycleOverrides(),
            overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
            onboardingDatabaseProbeReaderProvider.overrideWithValue(
              databaseProbeReader,
            ),
            dbMaintenanceLockProvider.overrideWith((ref) => true),
            onboardingFullDiskAccessProvider.overrideWith((ref) => true),
            onboardingMessagesDatabasePathProvider.overrideWith(
              (ref) => messagesDbPath,
            ),
            onboardingDatabaseDirectoryPathProvider.overrideWith(
              (ref) => tempDir.path,
            ),
            _attachmentArchiveLocationOverride(tempDir.path),
            futureGetFolderAggregateProvider.overrideWith(
              (ref) async => right(_addressBookAggregate(addressBookPath)),
            ),
          ],
        );

        final report = await container.read(
          onboardingEnvironmentReportProvider.future,
        );

        expect(report.state, OnboardingEnvironmentState.maintenanceInProgress);
        expect(report.blockerKind, OnboardingBlockerKind.none);
        expect(report.shouldResetAppDatabasesBeforeImport, isFalse);
        expect(
          databaseProbeReader.tableCountPaths,
          isNot(
            contains(
              appDatabasePath(
                AppDatabaseFile.sourceScopedImport,
                databaseDirectory: tempDir.path,
              ),
            ),
          ),
        );
        expect(
          databaseProbeReader.tableCountPaths,
          isNot(
            contains(
              appDatabasePath(
                AppDatabaseFile.conversationGraph,
                databaseDirectory: tempDir.path,
              ),
            ),
          ),
        );
        expect(databaseProbeReader.graphReadinessPaths, isEmpty);
      },
    );

    test(
      'onboarding import suppresses unrelated derived-store readiness reads',
      () async {
        final messagesDbPath = _createMessagesDatabase(
          tempDir.path,
          messageCount: 120,
        );
        final addressBookPath = _createReadableFile(
          tempDir.path,
          'AddressBook-v22.abcddb',
        );
        _createNonEmptyDatabaseFile(
          tempDir.path,
          appDatabaseFileName(AppDatabaseFile.sourceScopedImport),
        );
        _createGraphDatabase(tempDir.path, graphComplete: false);
        final databaseProbeReader = _RecordingOnboardingDatabaseProbeReader();
        final archiveAuthority = ArchiveAccessAuthority(
          identity: ResolvedArchiveIdentity(
            environment: ArchiveEnvironment.test,
            buildIdentity: ArchiveBuildIdentity.testHarness,
            archiveInstanceId: ArchiveInstanceId(
              'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
            ),
            canonicalRootPath: tempDir.path,
            bundleIdentifier: 'com.bigbenchsoftware.MessageLens.tests',
            productName: 'MessageLens Tests',
          ),
        );

        container = ProviderContainer(
          overrides: [
            ..._lifecycleOverrides(),
            admittedArchiveAccessAuthorityProvider.overrideWithValue(
              archiveAuthority,
            ),
            overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
            onboardingDatabaseProbeReaderProvider.overrideWithValue(
              databaseProbeReader,
            ),
            onboardingFullDiskAccessProvider.overrideWith((ref) => true),
            onboardingMessagesDatabasePathProvider.overrideWith(
              (ref) => messagesDbPath,
            ),
            onboardingDatabaseDirectoryPathProvider.overrideWith(
              (ref) => tempDir.path,
            ),
            _attachmentArchiveLocationOverride(tempDir.path),
            futureGetFolderAggregateProvider.overrideWith(
              (ref) async => right(_addressBookAggregate(addressBookPath)),
            ),
          ],
        );

        await container
            .read(archiveMutationCoordinatorProvider.notifier)
            .run<void>(
              operation: ArchiveMutationOperation.onboardingImport,
              ownerLabel: 'test-onboarding-import',
              action: () async {
                final report = await container.read(
                  onboardingEnvironmentReportProvider.future,
                );

                expect(
                  report.state,
                  OnboardingEnvironmentState.maintenanceInProgress,
                );
                expect(
                  databaseProbeReader.tableCountPaths,
                  isNot(
                    contains(
                      appDatabasePath(
                        AppDatabaseFile.sourceScopedImport,
                        databaseDirectory: tempDir.path,
                      ),
                    ),
                  ),
                );
                expect(
                  databaseProbeReader.tableCountPaths,
                  isNot(
                    contains(
                      appDatabasePath(
                        AppDatabaseFile.conversationGraph,
                        databaseDirectory: tempDir.path,
                      ),
                    ),
                  ),
                );
                expect(databaseProbeReader.graphReadinessPaths, isEmpty);
              },
            );
      },
    );

    test(
      'complete graph databases allow normal startup classification',
      () async {
        final messagesDbPath = _createMessagesDatabase(
          tempDir.path,
          messageCount: 120,
        );
        final addressBookPath = _createReadableFile(
          tempDir.path,
          'AddressBook-v22.abcddb',
        );
        _createNonEmptyDatabaseFile(
          tempDir.path,
          appDatabaseFileName(AppDatabaseFile.sourceScopedImport),
        );
        _createReadableFile(
          tempDir.path,
          appDatabaseFileName(AppDatabaseFile.overlay),
        );
        _createGraphDatabase(tempDir.path, graphComplete: true);
        Directory('${tempDir.path}/attachment_archive').createSync();

        container = ProviderContainer(
          overrides: [
            ..._lifecycleOverrides(),
            overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
            onboardingFullDiskAccessProvider.overrideWith((ref) => true),
            onboardingMessagesDatabasePathProvider.overrideWith(
              (ref) => messagesDbPath,
            ),
            onboardingDatabaseDirectoryPathProvider.overrideWith(
              (ref) => tempDir.path,
            ),
            _attachmentArchiveLocationOverride(tempDir.path),
            futureGetFolderAggregateProvider.overrideWith(
              (ref) async => right(_addressBookAggregate(addressBookPath)),
            ),
          ],
        );

        final report = await container.read(
          onboardingEnvironmentReportProvider.future,
        );

        expect(report.state, OnboardingEnvironmentState.ready);
        expect(report.blockerKind, OnboardingBlockerKind.none);
        expect(report.overlayDatabase.exists, isTrue);
        expect(report.overlayDatabase.readable, isTrue);
        expect(report.attachmentArchiveDirectory.exists, isTrue);
        expect(report.attachmentArchiveDirectory.readable, isTrue);
      },
    );

    test(
      'missing attachment archive is reported without blocking setup readiness',
      () async {
        final messagesDbPath = _createMessagesDatabase(
          tempDir.path,
          messageCount: 120,
        );
        final addressBookPath = _createReadableFile(
          tempDir.path,
          'AddressBook-v22.abcddb',
        );
        _createNonEmptyDatabaseFile(
          tempDir.path,
          appDatabaseFileName(AppDatabaseFile.sourceScopedImport),
        );
        _createGraphDatabase(tempDir.path, graphComplete: true);

        container = ProviderContainer(
          overrides: [
            ..._lifecycleOverrides(),
            overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
            onboardingFullDiskAccessProvider.overrideWith((ref) => true),
            onboardingMessagesDatabasePathProvider.overrideWith(
              (ref) => messagesDbPath,
            ),
            onboardingDatabaseDirectoryPathProvider.overrideWith(
              (ref) => tempDir.path,
            ),
            _attachmentArchiveLocationOverride(tempDir.path),
            futureGetFolderAggregateProvider.overrideWith(
              (ref) async => right(_addressBookAggregate(addressBookPath)),
            ),
          ],
        );

        final report = await container.read(
          onboardingEnvironmentReportProvider.future,
        );

        expect(report.state, OnboardingEnvironmentState.ready);
        expect(report.overlayDatabase.exists, isFalse);
        expect(report.attachmentArchiveDirectory.exists, isFalse);
        expect(report.attachmentArchiveDirectory.readable, isFalse);
      },
    );

    test(
      'unavailable external archive remains diagnostic and does not trigger onboarding',
      () async {
        final messagesDbPath = _createMessagesDatabase(
          tempDir.path,
          messageCount: 120,
        );
        final addressBookPath = _createReadableFile(
          tempDir.path,
          'AddressBook-v22.abcddb',
        );
        _createNonEmptyDatabaseFile(
          tempDir.path,
          appDatabaseFileName(AppDatabaseFile.sourceScopedImport),
        );
        _createGraphDatabase(tempDir.path, graphComplete: true);
        final probeReader = _RecordingOnboardingDatabaseProbeReader();
        final configuration =
            AttachmentArchiveLocationConfiguration.customExternal(
              bookmarkDataBase64: 'AQID',
              lastKnownPath: '/Volumes/Offline/Archive',
              volumeName: 'Offline',
            );

        container = ProviderContainer(
          overrides: [
            ..._lifecycleOverrides(),
            overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
            onboardingDatabaseProbeReaderProvider.overrideWithValue(
              probeReader,
            ),
            onboardingFullDiskAccessProvider.overrideWith((ref) => true),
            onboardingMessagesDatabasePathProvider.overrideWith(
              (ref) => messagesDbPath,
            ),
            onboardingDatabaseDirectoryPathProvider.overrideWith(
              (ref) => tempDir.path,
            ),
            attachmentArchiveLocationProvider.overrideWith(
              () => _FixedAttachmentArchiveLocation(
                AttachmentArchiveLocationState.customUnavailable(
                  configuration: configuration,
                  issue: 'Volume is disconnected.',
                  generation: 6,
                ),
              ),
            ),
            futureGetFolderAggregateProvider.overrideWith(
              (ref) async => right(_addressBookAggregate(addressBookPath)),
            ),
          ],
        );

        final report = await container.read(
          onboardingEnvironmentReportProvider.future,
        );

        expect(report.state, OnboardingEnvironmentState.ready);
        expect(report.blockerKind, OnboardingBlockerKind.none);
        expect(
          report.attachmentArchiveStatus,
          OnboardingAttachmentArchiveStatus.unavailable,
        );
        expect(report.attachmentArchiveIssue, 'Volume is disconnected.');
        expect(report.attachmentArchiveLocationGeneration, 6);
        expect(
          report.attachmentArchiveDirectory.path,
          '/Volumes/Offline/Archive',
        );
        expect(probeReader.directoryProbePaths, isEmpty);
      },
    );

    test(
      'does not open graph database while maintenance lock is active',
      () async {
        final messagesDbPath = _createMessagesDatabase(
          tempDir.path,
          messageCount: 120,
        );
        final addressBookPath = _createReadableFile(
          tempDir.path,
          'AddressBook-v22.abcddb',
        );
        _createNonEmptyDatabaseFile(
          tempDir.path,
          appDatabaseFileName(AppDatabaseFile.sourceScopedImport),
        );
        _createGraphDatabase(tempDir.path, graphComplete: true);

        container = ProviderContainer(
          overrides: [
            ..._lifecycleOverrides(),
            overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
            onboardingFullDiskAccessProvider.overrideWith((ref) => true),
            onboardingMessagesDatabasePathProvider.overrideWith(
              (ref) => messagesDbPath,
            ),
            onboardingDatabaseDirectoryPathProvider.overrideWith(
              (ref) => tempDir.path,
            ),
            _attachmentArchiveLocationOverride(tempDir.path),
            dbMaintenanceLockProvider.overrideWith((ref) => true),
            futureGetFolderAggregateProvider.overrideWith(
              (ref) async => right(_addressBookAggregate(addressBookPath)),
            ),
          ],
        );

        final report = await container.read(
          onboardingEnvironmentReportProvider.future,
        );

        expect(report.conversationGraph.exists, isTrue);
        expect(report.conversationGraph.rowCount, isNull);
      },
    );

    test(
      'flags a populated import ledger plus tiny conversation graph for automatic reset',
      () async {
        final messagesDbPath = _createMessagesDatabase(
          tempDir.path,
          messageCount: 120,
        );
        final addressBookPath = _createReadableFile(
          tempDir.path,
          'AddressBook-v22.abcddb',
        );
        final storage = OverlayOnboardingFailureStorage(
          overlayDb: Future<OverlayDatabase>.value(overlayDb),
        );
        _createNonEmptyDatabaseFile(
          tempDir.path,
          appDatabaseFileName(AppDatabaseFile.sourceScopedImport),
          rowCount: 120,
        );
        _createGraphDatabase(tempDir.path, rowCount: 1, graphComplete: false);
        await storage.saveGraphProjectionFailure(
          batchId: 99,
          message: 'Persisted graph projection failure',
          recordedAt: DateTime.utc(2026, 03, 24, 12, 45),
        );

        container = ProviderContainer(
          overrides: [
            ..._lifecycleOverrides(),
            overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
            onboardingFullDiskAccessProvider.overrideWith((ref) => true),
            onboardingMessagesDatabasePathProvider.overrideWith(
              (ref) => messagesDbPath,
            ),
            onboardingDatabaseDirectoryPathProvider.overrideWith(
              (ref) => tempDir.path,
            ),
            _attachmentArchiveLocationOverride(tempDir.path),
            futureGetFolderAggregateProvider.overrideWith(
              (ref) async => right(_addressBookAggregate(addressBookPath)),
            ),
          ],
        );

        final report = await container.read(
          onboardingEnvironmentReportProvider.future,
        );

        expect(report.state, OnboardingEnvironmentState.graphProjectionFailed);
        expect(report.blockerKind, OnboardingBlockerKind.graphProjectionFailed);
        expect(report.shouldResetAppDatabasesBeforeImport, isTrue);
        expect(report.resetAppDatabasesReason, isNotNull);
      },
    );

    group('admitted owner evidence', () {
      test(
        'global readers see maintenance while the exact owner gets fresh ready evidence',
        () async {
          final messagesDbPath = _createMessagesDatabase(
            tempDir.path,
            messageCount: 120,
          );
          final addressBookPath = _createReadableFile(
            tempDir.path,
            'AddressBook-v22.abcddb',
          );
          _createNonEmptyDatabaseFile(
            tempDir.path,
            appDatabaseFileName(AppDatabaseFile.sourceScopedImport),
            rowCount: 120,
          );
          _createGraphDatabase(tempDir.path, rowCount: 120);
          final probeReader = _RecordingOnboardingDatabaseProbeReader();
          container = ProviderContainer(
            overrides: _ownerEvidenceOverrides(
              tempDirPath: tempDir.path,
              overlayDb: overlayDb,
              messagesDbPath: messagesDbPath,
              addressBookPath: addressBookPath,
              probeReader: probeReader,
            ),
          );

          await container
              .read(archiveMutationCoordinatorProvider.notifier)
              .runWithCapability<void>(
                operation: ArchiveMutationOperation.onboardingImport,
                ownerLabel: 'owner-evidence-ready',
                action: (capability) async {
                  final global = await container.read(
                    onboardingEnvironmentReportProvider.future,
                  );
                  expect(
                    global.state,
                    OnboardingEnvironmentState.maintenanceInProgress,
                  );

                  final admitted = await container.read(
                    _admittedEvidenceProvider(
                      _AdmittedEvidenceRequest(
                        capability: capability,
                        operation: ArchiveMutationOperation.onboardingImport,
                        nonce: 1,
                      ),
                    ).future,
                  );

                  expect(admitted.state, OnboardingEnvironmentState.ready);
                  final globalAfterAdmitted = await container.read(
                    onboardingEnvironmentReportProvider.future,
                  );
                  expect(
                    globalAfterAdmitted.state,
                    OnboardingEnvironmentState.maintenanceInProgress,
                    reason:
                        'The caller-relative admitted report must not replace '
                        'the aggregate global report.',
                  );
                  expect(
                    probeReader.tableCountPaths,
                    contains(
                      appDatabasePath(
                        AppDatabaseFile.sourceScopedImport,
                        databaseDirectory: tempDir.path,
                      ),
                    ),
                  );
                  expect(probeReader.graphReadinessPaths, isNotEmpty);
                },
              );
        },
      );

      test('owner evidence does not reuse the prior global snapshot', () async {
        final messagesDbPath = _createMessagesDatabase(
          tempDir.path,
          messageCount: 120,
        );
        final addressBookPath = _createReadableFile(
          tempDir.path,
          'AddressBook-v22.abcddb',
        );
        _createNonEmptyDatabaseFile(
          tempDir.path,
          appDatabaseFileName(AppDatabaseFile.sourceScopedImport),
          rowCount: 120,
        );
        _createGraphDatabase(tempDir.path, rowCount: 120);
        container = ProviderContainer(
          overrides: _ownerEvidenceOverrides(
            tempDirPath: tempDir.path,
            overlayDb: overlayDb,
            messagesDbPath: messagesDbPath,
            addressBookPath: addressBookPath,
          ),
        );
        final before = await container.read(
          onboardingEnvironmentReportProvider.future,
        );
        expect(before.state, OnboardingEnvironmentState.ready);

        await container
            .read(archiveMutationCoordinatorProvider.notifier)
            .runWithCapability<void>(
              operation: ArchiveMutationOperation.onboardingImport,
              ownerLabel: 'owner-evidence-currentness',
              action: (capability) async {
                container
                    .read(onboardingDevOverridesProvider.notifier)
                    .setFullDiskAccessBlocked(enabled: true);
                final admitted = await container.read(
                  _admittedEvidenceProvider(
                    _AdmittedEvidenceRequest(
                      capability: capability,
                      operation: ArchiveMutationOperation.onboardingImport,
                      nonce: 2,
                    ),
                  ).future,
                );

                expect(
                  admitted.state,
                  OnboardingEnvironmentState.permissionBlocked,
                );
                expect(admitted.hasFullDiskAccess, isFalse);
              },
            );
      });

      test(
        'automatic-recovery owner still sees the current reset requirement',
        () async {
          final messagesDbPath = _createMessagesDatabase(
            tempDir.path,
            messageCount: 120,
          );
          final addressBookPath = _createReadableFile(
            tempDir.path,
            'AddressBook-v22.abcddb',
          );
          _createNonEmptyDatabaseFile(
            tempDir.path,
            appDatabaseFileName(AppDatabaseFile.sourceScopedImport),
            rowCount: 120,
          );
          _createGraphDatabase(tempDir.path, rowCount: 1, graphComplete: false);
          container = ProviderContainer(
            overrides: _ownerEvidenceOverrides(
              tempDirPath: tempDir.path,
              overlayDb: overlayDb,
              messagesDbPath: messagesDbPath,
              addressBookPath: addressBookPath,
            ),
          );

          await container
              .read(archiveMutationCoordinatorProvider.notifier)
              .runWithCapability<void>(
                operation: ArchiveMutationOperation.automaticRecovery,
                ownerLabel: 'owner-evidence-reset',
                action: (capability) async {
                  final admitted = await container.read(
                    _admittedEvidenceProvider(
                      _AdmittedEvidenceRequest(
                        capability: capability,
                        operation: ArchiveMutationOperation.automaticRecovery,
                        nonce: 3,
                      ),
                    ).future,
                  );

                  expect(
                    admitted.state,
                    OnboardingEnvironmentState.graphProjectionFailed,
                  );
                  expect(admitted.shouldResetAppDatabasesBeforeImport, isTrue);
                },
              );
        },
      );

      test(
        'wrong-operation and outside-Zone capabilities fail closed',
        () async {
          final messagesDbPath = _createMessagesDatabase(
            tempDir.path,
            messageCount: 120,
          );
          final addressBookPath = _createReadableFile(
            tempDir.path,
            'AddressBook-v22.abcddb',
          );
          container = ProviderContainer(
            overrides: _ownerEvidenceOverrides(
              tempDirPath: tempDir.path,
              overlayDb: overlayDb,
              messagesDbPath: messagesDbPath,
              addressBookPath: addressBookPath,
            ),
          );
          final capabilityReady = Completer<ArchiveMutationCapability>();
          final releaseOwner = Completer<void>();
          final ownerRun = container
              .read(archiveMutationCoordinatorProvider.notifier)
              .runWithCapability<void>(
                operation: ArchiveMutationOperation.onboardingImport,
                ownerLabel: 'owner-evidence-zone',
                action: (capability) async {
                  await expectLater(
                    container.read(
                      _admittedEvidenceProvider(
                        _AdmittedEvidenceRequest(
                          capability: capability,
                          operation: ArchiveMutationOperation.automaticRecovery,
                          nonce: 4,
                        ),
                      ).future,
                    ),
                    throwsA(isA<ArchiveMutationCapabilityDeniedException>()),
                  );
                  capabilityReady.complete(capability);
                  await releaseOwner.future;
                },
              );
          final capability = await capabilityReady.future;

          await expectLater(
            container.read(
              _admittedEvidenceProvider(
                _AdmittedEvidenceRequest(
                  capability: capability,
                  operation: ArchiveMutationOperation.onboardingImport,
                  nonce: 5,
                ),
              ).future,
            ),
            throwsA(isA<ArchiveMutationCapabilityDeniedException>()),
          );
          releaseOwner.complete();
          await ownerRun;

          await expectLater(
            container.read(
              _admittedEvidenceProvider(
                _AdmittedEvidenceRequest(
                  capability: capability,
                  operation: ArchiveMutationOperation.onboardingImport,
                  nonce: 6,
                ),
              ).future,
            ),
            throwsA(isA<ArchiveMutationCapabilityDeniedException>()),
          );
        },
      );

      test(
        'stronger resource policy denies the owner read before probes',
        () async {
          final messagesDbPath = _createMessagesDatabase(
            tempDir.path,
            messageCount: 120,
          );
          final addressBookPath = _createReadableFile(
            tempDir.path,
            'AddressBook-v22.abcddb',
          );
          final probeReader = _RecordingOnboardingDatabaseProbeReader();
          container = ProviderContainer(
            overrides: _ownerEvidenceOverrides(
              tempDirPath: tempDir.path,
              overlayDb: overlayDb,
              messagesDbPath: messagesDbPath,
              addressBookPath: addressBookPath,
              probeReader: probeReader,
            ),
          );

          await container
              .read(archiveMutationCoordinatorProvider.notifier)
              .run<void>(
                operation: ArchiveMutationOperation.messageDataReset,
                ownerLabel: 'stronger-resource-policy',
                action: () async {
                  await container
                      .read(archiveMutationCoordinatorProvider.notifier)
                      .runWithCapability<void>(
                        operation: ArchiveMutationOperation.onboardingImport,
                        ownerLabel: 'nested-onboarding-owner',
                        action: (capability) async {
                          await expectLater(
                            container.read(
                              _admittedEvidenceProvider(
                                _AdmittedEvidenceRequest(
                                  capability: capability,
                                  operation:
                                      ArchiveMutationOperation.onboardingImport,
                                  nonce: 7,
                                ),
                              ).future,
                            ),
                            throwsStateError,
                          );
                        },
                      );
                },
              );

          expect(probeReader.tableCountPaths, isEmpty);
          expect(probeReader.graphReadinessPaths, isEmpty);
        },
      );

      test('capability is rechecked after awaited evidence work', () async {
        final messagesDbPath = _createMessagesDatabase(
          tempDir.path,
          messageCount: 120,
        );
        final addressBookPath = _createReadableFile(
          tempDir.path,
          'AddressBook-v22.abcddb',
        );
        final loadStarted = Completer<void>();
        final releaseLoad = Completer<void>();
        final failureStore = _GatedFailureStore(
          loadStarted: loadStarted,
          releaseLoad: releaseLoad,
        );
        final probeReader = _RecordingOnboardingDatabaseProbeReader();
        container = ProviderContainer(
          overrides: _ownerEvidenceOverrides(
            tempDirPath: tempDir.path,
            overlayDb: overlayDb,
            messagesDbPath: messagesDbPath,
            addressBookPath: addressBookPath,
            failureStore: failureStore,
            probeReader: probeReader,
          ),
        );
        late Future<OnboardingEnvironmentReport> evidenceRead;

        await container
            .read(archiveMutationCoordinatorProvider.notifier)
            .runWithCapability<void>(
              operation: ArchiveMutationOperation.onboardingImport,
              ownerLabel: 'owner-evidence-stale-after-await',
              action: (capability) async {
                evidenceRead = container.read(
                  _admittedEvidenceProvider(
                    _AdmittedEvidenceRequest(
                      capability: capability,
                      operation: ArchiveMutationOperation.onboardingImport,
                      nonce: 8,
                    ),
                  ).future,
                );
                await loadStarted.future;
              },
            );

        releaseLoad.complete();
        await expectLater(
          evidenceRead,
          throwsA(isA<ArchiveMutationCapabilityDeniedException>()),
        );
        expect(failureStore.graphLoadCount, 0);
        expect(probeReader.protectedProbeCount, 0);
      });

      test(
        'resource admission is rechecked after awaited evidence work',
        () async {
          final messagesDbPath = _createMessagesDatabase(
            tempDir.path,
            messageCount: 120,
          );
          final addressBookPath = _createReadableFile(
            tempDir.path,
            'AddressBook-v22.abcddb',
          );
          final loadStarted = Completer<void>();
          final releaseLoad = Completer<void>();
          final failureStore = _GatedFailureStore(
            loadStarted: loadStarted,
            releaseLoad: releaseLoad,
          );
          final probeReader = _RecordingOnboardingDatabaseProbeReader();
          container = ProviderContainer(
            overrides: _ownerEvidenceOverrides(
              tempDirPath: tempDir.path,
              overlayDb: overlayDb,
              messagesDbPath: messagesDbPath,
              addressBookPath: addressBookPath,
              failureStore: failureStore,
              probeReader: probeReader,
            ),
          );

          await container
              .read(archiveMutationCoordinatorProvider.notifier)
              .runWithCapability<void>(
                operation: ArchiveMutationOperation.onboardingImport,
                ownerLabel: 'owner-evidence-resource-post-check',
                action: (capability) async {
                  final evidenceRead = container.read(
                    _admittedEvidenceProvider(
                      _AdmittedEvidenceRequest(
                        capability: capability,
                        operation: ArchiveMutationOperation.onboardingImport,
                        nonce: 9,
                      ),
                    ).future,
                  );
                  await loadStarted.future;
                  await container
                      .read(archiveMutationCoordinatorProvider.notifier)
                      .run<void>(
                        operation: ArchiveMutationOperation.messageDataReset,
                        ownerLabel: 'nested-stronger-resource-policy',
                        action: () async {
                          releaseLoad.complete();
                          await expectLater(evidenceRead, throwsStateError);
                        },
                      );
                },
              );

          expect(failureStore.graphLoadCount, 0);
          expect(probeReader.protectedProbeCount, 0);
        },
      );

      test(
        'Contacts evidence changed during a failure-store await is refreshed',
        () async {
          final messagesDbPath = _createMessagesDatabase(
            tempDir.path,
            messageCount: 120,
          );
          final addressBookPath = _createReadableFile(
            tempDir.path,
            'AddressBook-v22.abcddb',
          );
          final prerequisites = _MutableOwnerPrerequisites();
          final loadStarted = Completer<void>();
          final releaseLoad = Completer<void>();
          container = ProviderContainer(
            overrides: _ownerEvidenceOverrides(
              tempDirPath: tempDir.path,
              overlayDb: overlayDb,
              messagesDbPath: messagesDbPath,
              addressBookPath: addressBookPath,
              prerequisites: prerequisites,
              failureStore: _GatedFailureStore(
                loadStarted: loadStarted,
                releaseLoad: releaseLoad,
              ),
            ),
          );

          await container
              .read(archiveMutationCoordinatorProvider.notifier)
              .runWithCapability<void>(
                operation: ArchiveMutationOperation.onboardingImport,
                ownerLabel: 'owner-evidence-contacts-refresh',
                action: (capability) async {
                  final evidenceRead = container.read(
                    _admittedEvidenceProvider(
                      _AdmittedEvidenceRequest(
                        capability: capability,
                        operation: ArchiveMutationOperation.onboardingImport,
                        nonce: 10,
                      ),
                    ).future,
                  );
                  await loadStarted.future;
                  prerequisites.addressBookAvailable = false;
                  container.invalidate(futureGetFolderAggregateProvider);
                  releaseLoad.complete();

                  final admitted = await evidenceRead;
                  expect(
                    admitted.state,
                    OnboardingEnvironmentState.sourceUnavailable,
                  );
                  expect(
                    admitted.blockerKind,
                    OnboardingBlockerKind.addressBookUnavailable,
                  );
                },
              );
        },
      );

      test('FDA changed during a failure-store await is refreshed', () async {
        final messagesDbPath = _createMessagesDatabase(
          tempDir.path,
          messageCount: 120,
        );
        final addressBookPath = _createReadableFile(
          tempDir.path,
          'AddressBook-v22.abcddb',
        );
        final prerequisites = _MutableOwnerPrerequisites();
        final loadStarted = Completer<void>();
        final releaseLoad = Completer<void>();
        container = ProviderContainer(
          overrides: _ownerEvidenceOverrides(
            tempDirPath: tempDir.path,
            overlayDb: overlayDb,
            messagesDbPath: messagesDbPath,
            addressBookPath: addressBookPath,
            prerequisites: prerequisites,
            failureStore: _GatedFailureStore(
              loadStarted: loadStarted,
              releaseLoad: releaseLoad,
            ),
          ),
        );

        await container
            .read(archiveMutationCoordinatorProvider.notifier)
            .runWithCapability<void>(
              operation: ArchiveMutationOperation.onboardingImport,
              ownerLabel: 'owner-evidence-fda-refresh',
              action: (capability) async {
                final evidenceRead = container.read(
                  _admittedEvidenceProvider(
                    _AdmittedEvidenceRequest(
                      capability: capability,
                      operation: ArchiveMutationOperation.onboardingImport,
                      nonce: 11,
                    ),
                  ).future,
                );
                await loadStarted.future;
                prerequisites.hasFullDiskAccess = false;
                container.invalidate(onboardingFullDiskAccessProvider);
                releaseLoad.complete();

                final admitted = await evidenceRead;
                expect(
                  admitted.state,
                  OnboardingEnvironmentState.permissionBlocked,
                );
                expect(admitted.hasFullDiskAccess, isFalse);
              },
            );
      });

      test(
        'source failure changed during later material await is reread coherently',
        () async {
          final messagesDbPath = _createMessagesDatabase(
            tempDir.path,
            messageCount: 120,
          );
          final addressBookPath = _createReadableFile(
            tempDir.path,
            'AddressBook-v22.abcddb',
          );
          final contactsLoadStarted = Completer<void>();
          final releaseContactsLoad = Completer<void>();
          final failureStore = _MutableFailureStore(
            sourceImport: _sourceFailureEntry('old source failure', 1),
          );
          container = ProviderContainer(
            overrides: _ownerEvidenceOverrides(
              tempDirPath: tempDir.path,
              overlayDb: overlayDb,
              messagesDbPath: messagesDbPath,
              addressBookPath: addressBookPath,
              failureStore: failureStore,
              contactsLoadStarted: contactsLoadStarted,
              releaseContactsLoad: releaseContactsLoad,
            ),
          );

          await container
              .read(archiveMutationCoordinatorProvider.notifier)
              .runWithCapability<void>(
                operation: ArchiveMutationOperation.onboardingImport,
                ownerLabel: 'source-failure-revision-refresh',
                action: (capability) async {
                  final evidenceRead = container.read(
                    _admittedEvidenceProvider(
                      _AdmittedEvidenceRequest(
                        capability: capability,
                        operation: ArchiveMutationOperation.onboardingImport,
                        nonce: 13,
                      ),
                    ).future,
                  );
                  await contactsLoadStarted.future;
                  failureStore.sourceImport = _sourceFailureEntry(
                    'new source failure',
                    2,
                  );
                  releaseContactsLoad.complete();

                  final admitted = await evidenceRead;
                  expect(
                    admitted.lastImportFailure?.message,
                    'new source failure',
                  );
                  expect(admitted.lastImportFailure?.batchId, 2);
                },
              );
        },
      );

      test(
        'graph failure changed during later material await is reread coherently',
        () async {
          final messagesDbPath = _createMessagesDatabase(
            tempDir.path,
            messageCount: 120,
          );
          final addressBookPath = _createReadableFile(
            tempDir.path,
            'AddressBook-v22.abcddb',
          );
          final contactsLoadStarted = Completer<void>();
          final releaseContactsLoad = Completer<void>();
          final failureStore = _MutableFailureStore(
            graphProjection: _graphFailureEntry('old graph failure', 3),
          );
          container = ProviderContainer(
            overrides: _ownerEvidenceOverrides(
              tempDirPath: tempDir.path,
              overlayDb: overlayDb,
              messagesDbPath: messagesDbPath,
              addressBookPath: addressBookPath,
              failureStore: failureStore,
              contactsLoadStarted: contactsLoadStarted,
              releaseContactsLoad: releaseContactsLoad,
            ),
          );

          await container
              .read(archiveMutationCoordinatorProvider.notifier)
              .runWithCapability<void>(
                operation: ArchiveMutationOperation.onboardingImport,
                ownerLabel: 'graph-failure-revision-refresh',
                action: (capability) async {
                  final evidenceRead = container.read(
                    _admittedEvidenceProvider(
                      _AdmittedEvidenceRequest(
                        capability: capability,
                        operation: ArchiveMutationOperation.onboardingImport,
                        nonce: 14,
                      ),
                    ).future,
                  );
                  await contactsLoadStarted.future;
                  failureStore.graphProjection = _graphFailureEntry(
                    'new graph failure',
                    4,
                  );
                  releaseContactsLoad.complete();

                  final admitted = await evidenceRead;
                  expect(
                    admitted.lastGraphProjectionFailure?.message,
                    'new graph failure',
                  );
                  expect(admitted.lastGraphProjectionFailure?.batchId, 4);
                },
              );
        },
      );

      test(
        'failure cleared during later material await is not returned stale',
        () async {
          final messagesDbPath = _createMessagesDatabase(
            tempDir.path,
            messageCount: 120,
          );
          final addressBookPath = _createReadableFile(
            tempDir.path,
            'AddressBook-v22.abcddb',
          );
          final contactsLoadStarted = Completer<void>();
          final releaseContactsLoad = Completer<void>();
          final failureStore = _MutableFailureStore(
            sourceImport: _sourceFailureEntry('failure to clear', 5),
          );
          container = ProviderContainer(
            overrides: _ownerEvidenceOverrides(
              tempDirPath: tempDir.path,
              overlayDb: overlayDb,
              messagesDbPath: messagesDbPath,
              addressBookPath: addressBookPath,
              failureStore: failureStore,
              contactsLoadStarted: contactsLoadStarted,
              releaseContactsLoad: releaseContactsLoad,
            ),
          );

          await container
              .read(archiveMutationCoordinatorProvider.notifier)
              .runWithCapability<void>(
                operation: ArchiveMutationOperation.onboardingImport,
                ownerLabel: 'failure-clear-revision-refresh',
                action: (capability) async {
                  final evidenceRead = container.read(
                    _admittedEvidenceProvider(
                      _AdmittedEvidenceRequest(
                        capability: capability,
                        operation: ArchiveMutationOperation.onboardingImport,
                        nonce: 15,
                      ),
                    ).future,
                  );
                  await contactsLoadStarted.future;
                  failureStore.sourceImport = null;
                  releaseContactsLoad.complete();

                  final admitted = await evidenceRead;
                  expect(admitted.lastImportFailure, isNull);
                  expect(admitted.usingPersistedImportFailure, isFalse);
                },
              );
        },
      );

      test(
        'new reset-driving failure during later material await is returned',
        () async {
          final messagesDbPath = _createMessagesDatabase(
            tempDir.path,
            messageCount: 120,
          );
          final addressBookPath = _createReadableFile(
            tempDir.path,
            'AddressBook-v22.abcddb',
          );
          _createNonEmptyDatabaseFile(
            tempDir.path,
            appDatabaseFileName(AppDatabaseFile.sourceScopedImport),
            rowCount: 120,
          );
          _createGraphDatabase(tempDir.path, rowCount: 1, graphComplete: false);
          final contactsLoadStarted = Completer<void>();
          final releaseContactsLoad = Completer<void>();
          final failureStore = _MutableFailureStore();
          container = ProviderContainer(
            overrides: _ownerEvidenceOverrides(
              tempDirPath: tempDir.path,
              overlayDb: overlayDb,
              messagesDbPath: messagesDbPath,
              addressBookPath: addressBookPath,
              failureStore: failureStore,
              contactsLoadStarted: contactsLoadStarted,
              releaseContactsLoad: releaseContactsLoad,
            ),
          );

          await container
              .read(archiveMutationCoordinatorProvider.notifier)
              .runWithCapability<void>(
                operation: ArchiveMutationOperation.automaticRecovery,
                ownerLabel: 'new-reset-failure-revision-refresh',
                action: (capability) async {
                  final evidenceRead = container.read(
                    _admittedEvidenceProvider(
                      _AdmittedEvidenceRequest(
                        capability: capability,
                        operation: ArchiveMutationOperation.automaticRecovery,
                        nonce: 16,
                      ),
                    ).future,
                  );
                  await contactsLoadStarted.future;
                  failureStore.graphProjection = _graphFailureEntry(
                    'new reset-driving failure',
                    6,
                  );
                  releaseContactsLoad.complete();

                  final admitted = await evidenceRead;
                  expect(admitted.shouldResetAppDatabasesBeforeImport, isTrue);
                  expect(admitted.usingPersistedGraphProjectionFailure, isTrue);
                  expect(
                    admitted.lastGraphProjectionFailure?.message,
                    'new reset-driving failure',
                  );
                },
              );
        },
      );

      test('a second material revision mismatch fails closed', () async {
        final messagesDbPath = _createMessagesDatabase(
          tempDir.path,
          messageCount: 120,
        );
        final addressBookPath = _createReadableFile(
          tempDir.path,
          'AddressBook-v22.abcddb',
        );
        final failureStore = _MutableFailureStore(
          changeSourceOnEveryRead: true,
        );
        container = ProviderContainer(
          overrides: _ownerEvidenceOverrides(
            tempDirPath: tempDir.path,
            overlayDb: overlayDb,
            messagesDbPath: messagesDbPath,
            addressBookPath: addressBookPath,
            failureStore: failureStore,
          ),
        );

        await container
            .read(archiveMutationCoordinatorProvider.notifier)
            .runWithCapability<void>(
              operation: ArchiveMutationOperation.onboardingImport,
              ownerLabel: 'material-revision-never-stabilizes',
              action: (capability) async {
                await expectLater(
                  container.read(
                    _admittedEvidenceProvider(
                      _AdmittedEvidenceRequest(
                        capability: capability,
                        operation: ArchiveMutationOperation.onboardingImport,
                        nonce: 17,
                      ),
                    ).future,
                  ),
                  throwsA(
                    isA<StateError>().having(
                      (error) => error.message,
                      'message',
                      contains('did not stabilize'),
                    ),
                  ),
                );
              },
            );

        expect(failureStore.sourceReadCount, 4);
      });

      test(
        'retained Ball 1 cannot read evidence while Ball 2 is live',
        () async {
          final messagesDbPath = _createMessagesDatabase(
            tempDir.path,
            messageCount: 120,
          );
          final addressBookPath = _createReadableFile(
            tempDir.path,
            'AddressBook-v22.abcddb',
          );
          final probeReader = _RecordingOnboardingDatabaseProbeReader();
          container = ProviderContainer(
            overrides: _ownerEvidenceOverrides(
              tempDirPath: tempDir.path,
              overlayDb: overlayDb,
              messagesDbPath: messagesDbPath,
              addressBookPath: addressBookPath,
              probeReader: probeReader,
            ),
          );
          late ArchiveMutationCapability ball1Capability;
          late Zone ball1Zone;

          await container
              .read(archiveMutationCoordinatorProvider.notifier)
              .runWithCapability<void>(
                operation: ArchiveMutationOperation.onboardingImport,
                ownerLabel: 'owner-evidence-ball-1',
                action: (capability) async {
                  ball1Capability = capability;
                  ball1Zone = Zone.current;
                },
              );

          await container
              .read(archiveMutationCoordinatorProvider.notifier)
              .runWithCapability<void>(
                operation: ArchiveMutationOperation.onboardingImport,
                ownerLabel: 'owner-evidence-ball-2',
                action: (_) async {
                  final before = container.read(
                    archiveMutationCoordinatorProvider,
                  );
                  final staleRead = ball1Zone.run(
                    () => container.read(
                      _admittedEvidenceProvider(
                        _AdmittedEvidenceRequest(
                          capability: ball1Capability,
                          operation: ArchiveMutationOperation.onboardingImport,
                          nonce: 12,
                        ),
                      ).future,
                    ),
                  );

                  await expectLater(
                    staleRead,
                    throwsA(isA<ArchiveMutationCapabilityDeniedException>()),
                  );
                  final after = container.read(
                    archiveMutationCoordinatorProvider,
                  );
                  expect(after.ownerId, before.ownerId);
                  expect(after.holdCount, before.holdCount);
                  expect(after.operation, before.operation);
                },
              );

          expect(probeReader.protectedProbeCount, 0);
        },
      );
    });
  });
}

List<Override> _ownerEvidenceOverrides({
  required String tempDirPath,
  required OverlayDatabase overlayDb,
  required String messagesDbPath,
  required String addressBookPath,
  OnboardingDatabaseProbeReader? probeReader,
  OnboardingFailureStore? failureStore,
  _MutableOwnerPrerequisites? prerequisites,
  Completer<void>? contactsLoadStarted,
  Completer<void>? releaseContactsLoad,
}) {
  final archiveAuthority = ArchiveAccessAuthority(
    identity: ResolvedArchiveIdentity(
      environment: ArchiveEnvironment.test,
      buildIdentity: ArchiveBuildIdentity.testHarness,
      archiveInstanceId: ArchiveInstanceId(
        'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
      ),
      canonicalRootPath: tempDirPath,
      bundleIdentifier: 'com.bigbenchsoftware.MessageLens.tests',
      productName: 'MessageLens Tests',
    ),
  );
  return <Override>[
    ..._lifecycleOverrides(),
    admittedArchiveAccessAuthorityProvider.overrideWithValue(archiveAuthority),
    overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
    if (probeReader != null)
      onboardingDatabaseProbeReaderProvider.overrideWithValue(probeReader),
    if (failureStore != null)
      onboardingFailureStorageProvider.overrideWithValue(failureStore),
    onboardingFullDiskAccessProvider.overrideWith(
      (ref) => prerequisites?.hasFullDiskAccess ?? true,
    ),
    onboardingMessagesDatabasePathProvider.overrideWith(
      (ref) => messagesDbPath,
    ),
    onboardingDatabaseDirectoryPathProvider.overrideWith((ref) => tempDirPath),
    _attachmentArchiveLocationOverride(tempDirPath),
    futureGetFolderAggregateProvider.overrideWith((ref) async {
      contactsLoadStarted?.complete();
      if (releaseContactsLoad != null) {
        await releaseContactsLoad.future;
      }
      return prerequisites?.addressBookAvailable ?? true
          ? right(_addressBookAggregate(addressBookPath))
          : left(const FolderRetrievalFailure(message: 'Contacts unavailable'));
    }),
  ];
}

final class _MutableOwnerPrerequisites {
  bool hasFullDiskAccess = true;
  bool addressBookAvailable = true;
}

final class _GatedFailureStore implements OnboardingFailureStore {
  _GatedFailureStore({required this.loadStarted, required this.releaseLoad});

  final Completer<void> loadStarted;
  final Completer<void> releaseLoad;
  int graphLoadCount = 0;

  @override
  Future<void> clearGraphProjectionFailure() async {}

  @override
  Future<void> clearSourceImportFailure() async {}

  @override
  Future<OnboardingPipelineFailure?> loadGraphProjectionFailure() async => null;

  @override
  Future<PersistedOnboardingGraphProjectionFailure?>
  loadGraphProjectionFailureEntry({
    void Function()? requirePersistentArchiveStoreAdmission,
  }) async {
    requirePersistentArchiveStoreAdmission?.call();
    graphLoadCount += 1;
    return null;
  }

  @override
  Future<OnboardingPipelineFailure?> loadSourceImportFailure() async => null;

  @override
  Future<PersistedOnboardingSourceImportFailure?> loadSourceImportFailureEntry({
    void Function()? requirePersistentArchiveStoreAdmission,
  }) async {
    requirePersistentArchiveStoreAdmission?.call();
    if (!loadStarted.isCompleted) {
      loadStarted.complete();
    }
    await releaseLoad.future;
    requirePersistentArchiveStoreAdmission?.call();
    return null;
  }

  @override
  Future<void> saveGraphProjectionFailure({
    required String message,
    int batchId = 0,
    DateTime? recordedAt,
  }) async {}

  @override
  Future<void> saveImportFailure({
    required String message,
    int batchId = 0,
    DateTime? recordedAt,
    List<String> warnings = const <String>[],
  }) async {}
}

final class _MutableFailureStore implements OnboardingFailureStore {
  _MutableFailureStore({
    this.sourceImport,
    this.graphProjection,
    this.changeSourceOnEveryRead = false,
  });

  PersistedOnboardingSourceImportFailure? sourceImport;
  PersistedOnboardingGraphProjectionFailure? graphProjection;
  final bool changeSourceOnEveryRead;
  var sourceReadCount = 0;

  @override
  Future<void> clearGraphProjectionFailure() async {
    graphProjection = null;
  }

  @override
  Future<void> clearSourceImportFailure() async {
    sourceImport = null;
  }

  @override
  Future<OnboardingPipelineFailure?> loadGraphProjectionFailure() async {
    return graphProjection?.failure;
  }

  @override
  Future<PersistedOnboardingGraphProjectionFailure?>
  loadGraphProjectionFailureEntry({
    void Function()? requirePersistentArchiveStoreAdmission,
  }) async {
    requirePersistentArchiveStoreAdmission?.call();
    return graphProjection;
  }

  @override
  Future<OnboardingPipelineFailure?> loadSourceImportFailure() async {
    return sourceImport?.failure;
  }

  @override
  Future<PersistedOnboardingSourceImportFailure?> loadSourceImportFailureEntry({
    void Function()? requirePersistentArchiveStoreAdmission,
  }) async {
    requirePersistentArchiveStoreAdmission?.call();
    sourceReadCount += 1;
    if (changeSourceOnEveryRead) {
      return _sourceFailureEntry(
        'changing source failure $sourceReadCount',
        sourceReadCount,
      );
    }
    return sourceImport;
  }

  @override
  Future<void> saveGraphProjectionFailure({
    required String message,
    int batchId = 0,
    DateTime? recordedAt,
  }) async {
    graphProjection = _graphFailureEntry(message, batchId);
  }

  @override
  Future<void> saveImportFailure({
    required String message,
    int batchId = 0,
    DateTime? recordedAt,
    List<String> warnings = const <String>[],
  }) async {
    sourceImport = _sourceFailureEntry(message, batchId);
  }
}

PersistedOnboardingSourceImportFailure _sourceFailureEntry(
  String message,
  int batchId,
) {
  return PersistedOnboardingSourceImportFailure(
    recordedAt: DateTime.utc(2026, 9, 28, 12, batchId),
    failure: OnboardingPipelineFailure(
      phase: OnboardingPipelinePhase.import,
      batchId: batchId,
      message: message,
    ),
  );
}

PersistedOnboardingGraphProjectionFailure _graphFailureEntry(
  String message,
  int batchId,
) {
  return PersistedOnboardingGraphProjectionFailure(
    recordedAt: DateTime.utc(2026, 9, 28, 13, batchId),
    failure: OnboardingPipelineFailure(
      phase: OnboardingPipelinePhase.graphProjection,
      batchId: batchId,
      message: message,
    ),
  );
}

final class _RecordingOnboardingDatabaseProbeReader
    implements OnboardingDatabaseProbeReader {
  final SqliteOnboardingDatabaseProbeReader _delegate =
      const SqliteOnboardingDatabaseProbeReader();
  final List<String> tableCountPaths = <String>[];
  final List<String> graphReadinessPaths = <String>[];
  final List<String> directoryProbePaths = <String>[];
  final List<String> fileProbePaths = <String>[];

  int get protectedProbeCount =>
      tableCountPaths.length +
      graphReadinessPaths.length +
      directoryProbePaths.length +
      fileProbePaths.length;

  @override
  OnboardingDatabaseProbe probeFile(String filePath, {int? rowCount}) {
    fileProbePaths.add(filePath);
    return _delegate.probeFile(filePath, rowCount: rowCount);
  }

  @override
  OnboardingDatabaseProbe probeDirectory(String directoryPath) {
    directoryProbePaths.add(directoryPath);
    return _delegate.probeDirectory(directoryPath);
  }

  @override
  int? readTableCount({
    required String dbPath,
    required String tableName,
    bool queryOnly = false,
  }) {
    tableCountPaths.add(dbPath);
    return _delegate.readTableCount(
      dbPath: dbPath,
      tableName: tableName,
      queryOnly: queryOnly,
    );
  }

  @override
  ConversationGraphReadiness readConversationGraphReadiness(String dbPath) {
    graphReadinessPaths.add(dbPath);
    return _delegate.readConversationGraphReadiness(dbPath);
  }
}

String _createMessagesDatabase(
  String directoryPath, {
  required int messageCount,
}) {
  final filePath = '$directoryPath/messages.db';
  final db = sqlite3.open(filePath);
  try {
    db.execute('CREATE TABLE message (ROWID INTEGER PRIMARY KEY, value TEXT)');
    db.execute(
      'CREATE TABLE attachment (ROWID INTEGER PRIMARY KEY, value TEXT)',
    );
    for (var index = 0; index < messageCount; index++) {
      db.execute('INSERT INTO message (value) VALUES (?)', ['message-$index']);
    }
  } finally {
    db.dispose();
  }
  return filePath;
}

String _createNonEmptyDatabaseFile(
  String directoryPath,
  String fileName, {
  int rowCount = 1,
}) {
  final filePath = '$directoryPath/$fileName';
  final db = sqlite3.open(filePath);
  try {
    db.execute('CREATE TABLE messages (ROWID INTEGER PRIMARY KEY, value TEXT)');
    for (var index = 0; index < rowCount; index++) {
      db.execute('INSERT INTO messages (value) VALUES (?)', ['fixture-$index']);
    }
  } finally {
    db.dispose();
  }
  return filePath;
}

String _createGraphDatabase(
  String directoryPath, {
  int rowCount = 1,
  bool graphComplete = true,
}) {
  final filePath = appDatabasePath(
    AppDatabaseFile.conversationGraph,
    databaseDirectory: directoryPath,
  );
  final db = sqlite3.open(filePath);
  try {
    db
      ..execute('CREATE TABLE messages (ss_id INTEGER PRIMARY KEY)')
      ..execute('CREATE TABLE chats (ss_id INTEGER PRIMARY KEY)')
      ..execute('CREATE TABLE handles (ss_id INTEGER PRIMARY KEY)')
      ..execute('''
        CREATE TABLE chat_to_message (
          chat_ss_id INTEGER NOT NULL,
          message_ss_id INTEGER NOT NULL
        )
      ''')
      ..execute('''
        CREATE TABLE chat_to_handle (
          chat_ss_id INTEGER NOT NULL,
          handle_ss_id INTEGER NOT NULL
        )
      ''')
      ..execute('CREATE TABLE attachments (ss_id INTEGER PRIMARY KEY)')
      ..execute('''
        CREATE TABLE message_to_attachment (
          message_ss_id INTEGER NOT NULL,
          attachment_ss_id INTEGER NOT NULL
        )
      ''');
    for (var index = 0; index < rowCount; index++) {
      db.execute('INSERT INTO messages (ss_id) VALUES (?)', [index + 1]);
    }
    if (graphComplete && rowCount > 0) {
      db
        ..execute('INSERT INTO chats (ss_id) VALUES (10)')
        ..execute(
          'INSERT INTO chat_to_message (chat_ss_id, message_ss_id) '
          'VALUES (10, 1)',
        );
    }
  } finally {
    db.dispose();
  }
  return filePath;
}

String _createReadableFile(String directoryPath, String fileName) {
  final file = File('$directoryPath/$fileName');
  file.writeAsStringSync('fixture');
  return file.path;
}

AddressBookFolderAggregate _addressBookAggregate(String addressBookPath) {
  return AddressBookFolderAggregate([
    AddressBookFolderEntity(
      path: FolderPathValueObject(addressBookPath),
      shortPath: AddressBookFolderShortPath('TEST-SOURCE'),
      lastCreationDate: FolderCreationDate(DateTime.utc(2026, 03, 24)),
      lastModificationDate: FolderModificationDate(DateTime.utc(2026, 03, 24)),
      recordCount: NonZeroInt(12),
    ),
  ]);
}

List<Override> _lifecycleOverrides() {
  return [
    conversationGraphBuildControllerProvider.overrideWith(
      _FakeConversationGraphBuildController.new,
    ),
    chatDbChangeMonitorProvider.overrideWith(_FakeChatDbChangeMonitor.new),
  ];
}

Override _attachmentArchiveLocationOverride(String primaryRootPath) {
  return attachmentArchiveLocationProvider.overrideWith(
    () => _FixedAttachmentArchiveLocation(
      AttachmentArchiveLocationState.defaultAvailable(
        archiveRootPath: '$primaryRootPath/attachment_archive',
      ),
    ),
  );
}

final class _FixedAttachmentArchiveLocation extends AttachmentArchiveLocation {
  _FixedAttachmentArchiveLocation(this.location);

  final AttachmentArchiveLocationState location;

  @override
  Future<AttachmentArchiveLocationState> build() async => location;
}

final class _FakeConversationGraphBuildController
    extends ConversationGraphBuildController {
  @override
  ConversationGraphBuildState build() {
    return const ConversationGraphBuildState.idle();
  }
}

final class _FakeChatDbChangeMonitor extends ChatDbChangeMonitor {
  @override
  ChatDbChangeMonitorState build() {
    return const ChatDbChangeMonitorState(lastMaxRowId: 149359);
  }
}
