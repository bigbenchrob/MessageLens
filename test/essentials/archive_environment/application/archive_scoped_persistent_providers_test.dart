import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:remember_this_text/essentials/archive_environment/domain.dart'
    show ArchiveMutationOperation;
import 'package:remember_this_text/essentials/archive_environment/feature_level_providers.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/status/conversation_graph_status_log_writer_provider.dart';
import 'package:remember_this_text/essentials/conversation_graph/domain/status/conversation_graph_status.dart';
import 'package:remember_this_text/essentials/db/app_database_files.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/logging/application/diagnostic_report_provider.dart';
import 'package:remember_this_text/essentials/logging/application/pipeline_incident_storage_provider.dart';
import 'package:remember_this_text/essentials/logging/infrastructure/pipeline_audit_incident_log_writer.dart';
import 'package:remember_this_text/essentials/onboarding/application/derived_message_data_file_store_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/message_data_reset_service.dart'
    show messageDataResetServiceProvider;
import 'package:remember_this_text/features/attachments/feature_level_providers.dart'
    show attachmentArchiveLocationProvider;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../test_support/test_archive_fixture.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('persistent providers fail before archive admission', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await expectLater(
      container.read(attachmentArchiveLocationProvider.future),
      throwsStateError,
    );
    await expectLater(
      container.read(overlayDatabaseProvider.future),
      throwsStateError,
    );
    expect(
      () => container.read(derivedMessageDataFileStoreProvider),
      throwsStateError,
    );
  });

  test(
    'graph provider construction retains the requesting async Zone',
    () async {
      final zoneKey = Object();
      const zoneValue = 'requesting-owner-scope';
      Object? observedZoneValue;
      final container = ProviderContainer(
        overrides: [
          driftConversationGraphDatabaseProvider.overrideWith((ref) async {
            observedZoneValue = Zone.current[zoneKey];
            throw StateError('zone observation complete');
          }),
        ],
      );
      addTearDown(container.dispose);

      await runZoned(() async {
        await expectLater(
          container.read(driftConversationGraphDatabaseProvider.future),
          throwsStateError,
        );
      }, zoneValues: {zoneKey: zoneValue});

      expect(observedZoneValue, zoneValue);
    },
  );

  test(
    'persistent providers remain inside one admitted test archive',
    () async {
      final fixture = await TestArchiveFixture.create(
        prefix: 'messagelens_persistent_provider_test_',
      );
      final container = ProviderContainer(
        overrides: [
          admittedArchiveAccessAuthorityProvider.overrideWithValue(
            fixture.authority,
          ),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await Future<void>.delayed(Duration.zero);
        await fixture.dispose();
      });

      final importDatabase = await container.read(
        sourceScopedImportDatabaseProvider.future,
      );
      final graphDatabase = await container.read(
        driftConversationGraphDatabaseProvider.future,
      );
      final overlayDatabase = await container.read(
        overlayDatabaseProvider.future,
      );

      expect(importDatabase, isNotNull);
      expect(graphDatabase, isNotNull);
      expect(overlayDatabase, isNotNull);

      final attachmentLocation = await container.read(
        attachmentArchiveLocationProvider.future,
      );
      final attachmentPath = attachmentLocation.requireArchiveRootPath();
      expect(path.isWithin(fixture.root.path, attachmentPath), isTrue);

      final diagnosticLogPath = container.read(
        diagnosticLogDirectoryPathProvider,
      );
      expect(path.isWithin(fixture.root.path, diagnosticLogPath), isTrue);

      final incidentWriter = container.read(pipelineIncidentLogWriterProvider);
      expect(incidentWriter, isA<PipelineAuditIncidentLogWriter>());
      final incidentDirectory =
          (incidentWriter as PipelineAuditIncidentLogWriter).directoryPath;
      expect(
        path.equals(fixture.root.path, incidentDirectory) ||
            path.isWithin(fixture.root.path, incidentDirectory),
        isTrue,
      );

      final resetStore = container.read(derivedMessageDataFileStoreProvider);
      final resetProbe = File(path.join(fixture.root.path, 'reset_probe.db'))
        ..writeAsStringSync('test');
      expect(resetStore.databaseBaseFileExists('reset_probe.db'), isTrue);
      await resetStore.deleteDatabaseBaseFiles(['reset_probe.db']);
      expect(resetProbe.existsSync(), isFalse);

      final graphStatusWriter = container.read(
        conversationGraphStatusLogWriterProvider,
      );
      final graphStatusLogPath = await graphStatusWriter.writeRun(
        before: _status(),
      );
      expect(path.isWithin(fixture.root.path, graphStatusLogPath), isTrue);

      final rootFiles = fixture.root
          .listSync(recursive: true)
          .whereType<File>()
          .map((file) => path.relative(file.path, from: fixture.root.path))
          .toSet();
      expect(
        rootFiles,
        containsAll(<String>{
          '.messagelens-archive.json',
          appDatabaseFileName(AppDatabaseFile.sourceScopedImport),
          appDatabaseFileName(AppDatabaseFile.conversationGraph),
          appDatabaseFileName(AppDatabaseFile.overlay),
        }),
      );
      expect(
        rootFiles.every(
          (relativePath) =>
              !path.isAbsolute(relativePath) && !relativePath.startsWith('../'),
        ),
        isTrue,
      );
    },
  );

  test('historical import owner may open graph while others cannot', () async {
    await _verifyOwnerAwareGraphAdmission(
      operation: ArchiveMutationOperation.historicalArchiveImport,
      prefix: 'historical_import_graph_access_test_',
    );
  });

  test('historical removal owner may open graph while others cannot', () async {
    await _verifyOwnerAwareGraphAdmission(
      operation: ArchiveMutationOperation.historicalArchiveRemoval,
      prefix: 'historical_removal_graph_access_test_',
    );
  });

  test(
    'reset cannot freshly open graph and denied construction later recovers',
    () async {
      final fixture = await TestArchiveFixture.create(
        prefix: 'blocked_graph_reopen_recovery_test_',
      );
      final container = ProviderContainer(
        overrides: [
          admittedArchiveAccessAuthorityProvider.overrideWithValue(
            fixture.authority,
          ),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await Future<void>.delayed(Duration.zero);
        await fixture.dispose();
      });

      await container
          .read(archiveMutationCoordinatorProvider.notifier)
          .run<void>(
            operation: ArchiveMutationOperation.messageDataReset,
            ownerLabel: 'message-data-reset',
            action: () async {
              await expectLater(
                container.read(driftConversationGraphDatabaseProvider.future),
                throwsA(isA<StateError>()),
              );
            },
          );

      await expectLater(
        container.read(driftConversationGraphDatabaseProvider.future),
        completion(isNotNull),
      );
    },
  );

  test('message reset does not construct an unopened graph provider', () async {
    final fixture = await TestArchiveFixture.create(
      prefix: 'message_reset_unopened_graph_test_',
    );
    final observer = _ProviderInitializationObserver(
      driftConversationGraphDatabaseProvider,
    );
    final graphPath = appDatabasePath(
      AppDatabaseFile.conversationGraph,
      databaseDirectory: fixture.root.path,
    );
    File(graphPath).writeAsStringSync('disposable graph placeholder');
    final container = ProviderContainer(
      observers: [observer],
      overrides: [
        admittedArchiveAccessAuthorityProvider.overrideWithValue(
          fixture.authority,
        ),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await Future<void>.delayed(Duration.zero);
      await fixture.dispose();
    });

    await container.read(messageDataResetServiceProvider).resetDerivedData();

    expect(observer.initializationCount, 0);
    expect(File(graphPath).existsSync(), isFalse);
  });

  test('message reset closes an existing graph provider', () async {
    final fixture = await TestArchiveFixture.create(
      prefix: 'message_reset_open_graph_test_',
    );
    final container = ProviderContainer(
      overrides: [
        admittedArchiveAccessAuthorityProvider.overrideWithValue(
          fixture.authority,
        ),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await Future<void>.delayed(Duration.zero);
      await fixture.dispose();
    });
    final graphPath = appDatabasePath(
      AppDatabaseFile.conversationGraph,
      databaseDirectory: fixture.root.path,
    );

    await container.read(driftConversationGraphDatabaseProvider.future);
    expect(File(graphPath).existsSync(), isTrue);

    await container.read(messageDataResetServiceProvider).resetDerivedData();

    expect(File(graphPath).existsSync(), isFalse);
  });
}

final class _ProviderInitializationObserver extends ProviderObserver {
  _ProviderInitializationObserver(this.target);

  final ProviderBase<Object?> target;
  int initializationCount = 0;

  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    if (provider == target) {
      initializationCount += 1;
    }
  }
}

Future<void> _verifyOwnerAwareGraphAdmission({
  required ArchiveMutationOperation operation,
  required String prefix,
}) async {
  final fixture = await TestArchiveFixture.create(prefix: prefix);
  final container = ProviderContainer(
    overrides: [
      admittedArchiveAccessAuthorityProvider.overrideWithValue(
        fixture.authority,
      ),
    ],
  );
  final ownerOpenedGraph = Completer<void>();
  final releaseOwner = Completer<void>();

  try {
    final operationFuture = container
        .read(archiveMutationCoordinatorProvider.notifier)
        .run<void>(
          operation: operation,
          ownerLabel: 'owner-${operation.name}',
          action: () async {
            final graph = await container.read(
              driftConversationGraphDatabaseProvider.future,
            );
            expect(graph, isNotNull);
            ownerOpenedGraph.complete();
            await releaseOwner.future;
          },
        );

    await ownerOpenedGraph.future;
    await container
        .read(conversationGraphConnectionLifecycleProvider)
        .closeIfActive();
    container.invalidate(driftConversationGraphDatabaseProvider);
    await Future<void>.delayed(Duration.zero);

    await expectLater(
      container.read(driftConversationGraphDatabaseProvider.future),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('unavailable during database maintenance'),
        ),
      ),
    );

    releaseOwner.complete();
    await operationFuture;
    await expectLater(
      container.read(driftConversationGraphDatabaseProvider.future),
      completion(isNotNull),
    );
  } finally {
    if (!releaseOwner.isCompleted) {
      releaseOwner.complete();
    }
    container.dispose();
    await Future<void>.delayed(Duration.zero);
    await fixture.dispose();
  }
}

ConversationGraphStatus _status() {
  return const ConversationGraphStatus(
    chatDbPath: '/tmp/synthetic-chat.db',
    importLedgerDatabaseLabel: 'import',
    graphDatabaseLabel: 'graph',
    sourceId: 1,
    sourceMessageCount: 1,
    sourceMaxRowId: 1,
    ledgerMessageCount: 1,
    ledgerMaxSourceRowId: 1,
    ledgerMessagesNeedingEnrichment: 0,
    ledgerMessagesStillWithoutText: 0,
    graphMessageCount: 1,
    associatedMessageEdgeCount: 0,
    sourceChatCount: 0,
    importChatCount: 0,
    graphChatCount: 0,
    sourceHandleCount: 0,
    importHandleCount: 0,
    graphHandleCount: 0,
    importTopologyEdgeCount: 0,
    graphTopologyEdgeCount: 0,
    duplicateGraphTopologyEdgeCount: 0,
    importChatToHandleEdgeCount: 0,
    graphChatToHandleEdgeCount: 0,
    duplicateGraphChatToHandleEdgeCount: 0,
    sourceAttachmentCount: 0,
    importAttachmentCount: 0,
    graphAttachmentCount: 0,
    importMessageToAttachmentEdgeCount: 0,
    graphMessageToAttachmentEdgeCount: 0,
    duplicateGraphMessageToAttachmentEdgeCount: 0,
  );
}
