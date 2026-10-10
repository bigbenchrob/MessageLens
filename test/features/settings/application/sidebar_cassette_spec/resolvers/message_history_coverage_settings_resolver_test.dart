import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/conversation_graph/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/messages_source/feature_level_providers.dart';
import 'package:remember_this_text/essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import 'package:remember_this_text/essentials/source_scoped_import/feature_level_providers.dart';
import 'package:remember_this_text/features/settings/application/message_history_coverage_repository.dart';
import 'package:remember_this_text/features/settings/application/message_history_coverage_repository_provider.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/entities/message_history_coverage_report.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/resolvers/message_history_coverage_settings_resolver.dart';

void main() {
  group('MessageHistoryCoverageSettingsResolver', () {
    test('returns the explanatory sidebar payloads', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final resolver = container.read(
        messageHistoryCoverageSettingsResolverProvider.notifier,
      );

      final overview = resolver.resolveOverview(cassetteIndex: 2);
      final howTo = resolver.resolveHowToRead(cassetteIndex: 3);
      final olderMessages = resolver.resolveOlderMessagesNote(cassetteIndex: 4);

      expect(overview, isA<StaticFeatureInfoSidebarCassettePayload>());
      expect(overview.title, 'Message History Coverage');
      expect(overview.bodyText, contains('currently stored by Messages'));
      expect(overview.bodyText, isNot(contains('chat.db')));
      expect(howTo.title, 'How to read this report');
      expect(howTo.topSpacing, 10);
      expect(howTo.bodyText, contains('Recovered Messages'));
      expect(olderMessages.title, 'About older messages');
      expect(olderMessages.topSpacing, 16);
      expect(olderMessages.bodyText, contains('Historical Archives'));
    });

    test('reconciles exact current-source identities', () async {
      final repository = _FakeCoverageRepository(
        evidence: _evidence(
          sourceRows: const <int>{1, 2, 3},
          graphRows: const <int, CurrentSourceMessageGraphPlacement>{
            1: CurrentSourceMessageGraphPlacement.conversationLinked,
            2: CurrentSourceMessageGraphPlacement.recoveredUnlinked,
          },
        ),
      );
      final container = _container(repository: repository);
      addTearDown(container.dispose);

      final report = await container.read(
        messageHistoryCoverageReportProvider.future,
      );

      expect(report.totalCurrentMessages, 3);
      expect(report.accountedInConversations, 1);
      expect(report.recoveredUnlinked, 1);
      expect(report.unaccounted, 1);
      expect(report.status, MessageHistoryCoverageStatus.incomplete);
      expect(repository.readCount, 1);
    });

    test(
      'provider cache prevents widget rebuild from repeating query',
      () async {
        final repository = _FakeCoverageRepository(
          evidence: _evidence(
            sourceRows: const <int>{1},
            graphRows: const <int, CurrentSourceMessageGraphPlacement>{
              1: CurrentSourceMessageGraphPlacement.conversationLinked,
            },
          ),
        );
        final container = _container(repository: repository);
        addTearDown(container.dispose);

        await container.read(messageHistoryCoverageReportProvider.future);
        await container.read(messageHistoryCoverageReportProvider.future);

        expect(repository.readCount, 1);
      },
    );

    test('maintenance is unavailable and opens no evidence stores', () async {
      var repositoryWasRequested = false;
      final container = ProviderContainer(
        overrides: [
          dbMaintenanceLockProvider.overrideWith((ref) => true),
          currentMessagesSourceEvidenceProvider.overrideWith(
            (ref) => const CurrentMessagesSourceEvidence.readable(
              sourcePath: '/source/chat.db',
              maxRowId: 1,
            ),
          ),
          messageHistoryCoverageRepositoryProvider.overrideWith((ref) async {
            repositoryWasRequested = true;
            throw StateError('repository must not be opened');
          }),
        ],
      );
      addTearDown(container.dispose);

      final report = await container.read(
        messageHistoryCoverageReportProvider.future,
      );

      expect(
        report.status,
        MessageHistoryCoverageStatus.temporarilyUnavailable,
      );
      expect(repositoryWasRequested, isFalse);
      expect(report.totalCurrentMessages, isNull);
    });

    test('maintenance release recomputes current truth', () async {
      var maintenance = true;
      final repository = _FakeCoverageRepository(
        evidence: _evidence(
          sourceRows: const <int>{1},
          graphRows: const <int, CurrentSourceMessageGraphPlacement>{
            1: CurrentSourceMessageGraphPlacement.conversationLinked,
          },
        ),
      );
      final container = _container(
        repository: repository,
        maintenance: () => maintenance,
      );
      addTearDown(container.dispose);

      expect(
        (await container.read(
          messageHistoryCoverageReportProvider.future,
        )).status,
        MessageHistoryCoverageStatus.temporarilyUnavailable,
      );
      maintenance = false;
      container.invalidate(dbMaintenanceLockProvider);

      expect(
        (await container.read(
          messageHistoryCoverageReportProvider.future,
        )).status,
        MessageHistoryCoverageStatus.complete,
      );
      expect(repository.readCount, 1);
    });

    test('genuine repository failure becomes failed', () async {
      final container = _container(repository: _FailingCoverageRepository());
      addTearDown(container.dispose);

      final report = await container.read(
        messageHistoryCoverageReportProvider.future,
      );

      expect(report.status, MessageHistoryCoverageStatus.failed);
      expect(report.detail, contains('query failed'));
    });

    test('passes the exact neutral source identity to coverage', () async {
      final repository = _FakeCoverageRepository(
        evidence: _evidence(
          sourceRows: const <int>{1},
          graphRows: const <int, CurrentSourceMessageGraphPlacement>{
            1: CurrentSourceMessageGraphPlacement.conversationLinked,
          },
        ),
      );
      final container = _container(
        repository: repository,
        sourcePath: '/alternate/Library/Messages/chat.db',
      );
      addTearDown(container.dispose);

      await container.read(messageHistoryCoverageReportProvider.future);

      expect(
        repository.lastChatDatabasePath,
        '/alternate/Library/Messages/chat.db',
      );
    });

    test('non-readable neutral evidence never opens coverage stores', () async {
      for (final condition in <CurrentMessagesSourceReadCondition>[
        CurrentMessagesSourceReadCondition.accessDenied,
        CurrentMessagesSourceReadCondition.unavailable,
        CurrentMessagesSourceReadCondition.unknown,
      ]) {
        var repositoryWasRequested = false;
        final container = ProviderContainer(
          overrides: [
            dbMaintenanceLockProvider.overrideWith((ref) => false),
            currentMessagesSourceEvidenceProvider.overrideWith(
              (ref) => CurrentMessagesSourceEvidence.failed(
                sourcePath: '/source/chat.db',
                condition: condition,
                error: StateError(condition.name),
                stackTrace: StackTrace.empty,
              ),
            ),
            messageHistoryCoverageRepositoryProvider.overrideWith((ref) async {
              repositoryWasRequested = true;
              throw StateError('repository must not be opened');
            }),
          ],
        );
        addTearDown(container.dispose);

        final report = await container.read(
          messageHistoryCoverageReportProvider.future,
        );

        expect(report.status, MessageHistoryCoverageStatus.failed);
        expect(report.detail, contains('Check Full Disk Access'));
        expect(repositoryWasRequested, isFalse);
      }
    });
  });
}

ProviderContainer _container({
  required MessageHistoryCoverageRepository repository,
  bool Function()? maintenance,
  String sourcePath = '/source/chat.db',
}) {
  return ProviderContainer(
    overrides: [
      dbMaintenanceLockProvider.overrideWith(
        (ref) => maintenance?.call() ?? false,
      ),
      currentMessagesSourceEvidenceProvider.overrideWith(
        (ref) => CurrentMessagesSourceEvidence.readable(
          sourcePath: sourcePath,
          maxRowId: 1,
        ),
      ),
      messageHistoryCoverageRepositoryProvider.overrideWith(
        (ref) async => repository,
      ),
    ],
  );
}

MessageHistoryCoverageEvidence _evidence({
  required Set<int> sourceRows,
  required Map<int, CurrentSourceMessageGraphPlacement> graphRows,
}) {
  return MessageHistoryCoverageEvidence(
    currentSource: CurrentMessagesSourceCoverageEvidence(
      sourceRowIds: sourceRows,
      earliestMessageDate: DateTime.utc(2012, 7, 25),
      latestMessageDate: DateTime.utc(2026, 8, 22),
    ),
    currentSourceGraph: CurrentSourceMessageGraphCoverageEvidence(
      placementBySourceRowId: graphRows,
    ),
  );
}

final class _FakeCoverageRepository
    implements MessageHistoryCoverageRepository {
  _FakeCoverageRepository({required this.evidence});

  final MessageHistoryCoverageEvidence evidence;
  var readCount = 0;
  String? lastChatDatabasePath;

  @override
  Future<MessageHistoryCoverageEvidence> readEvidence({
    required String chatDatabasePath,
  }) async {
    readCount++;
    lastChatDatabasePath = chatDatabasePath;
    return evidence;
  }
}

final class _FailingCoverageRepository
    implements MessageHistoryCoverageRepository {
  @override
  Future<MessageHistoryCoverageEvidence> readEvidence({
    required String chatDatabasePath,
  }) {
    throw StateError('query failed');
  }
}
