import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/domain_driven_development/value_objects.dart';
import 'package:remember_this_text/essentials/archive_environment/domain.dart';
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart'
    show
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
        AttachmentArchiveLocationState,
        attachmentArchiveLocationProvider;
import 'package:sqlite3/sqlite3.dart';

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
  });
}

final class _RecordingOnboardingDatabaseProbeReader
    implements OnboardingDatabaseProbeReader {
  final SqliteOnboardingDatabaseProbeReader _delegate =
      const SqliteOnboardingDatabaseProbeReader();
  final List<String> tableCountPaths = <String>[];
  final List<String> graphReadinessPaths = <String>[];

  @override
  OnboardingDatabaseProbe probeFile(String filePath, {int? rowCount}) {
    return _delegate.probeFile(filePath, rowCount: rowCount);
  }

  @override
  OnboardingDatabaseProbe probeDirectory(String directoryPath) {
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
