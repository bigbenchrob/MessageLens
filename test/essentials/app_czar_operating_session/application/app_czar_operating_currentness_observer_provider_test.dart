import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/app_czar/domain/app_czar_models.dart';
import 'package:remember_this_text/essentials/app_czar_operating_session/application/app_czar_operating_currentness_observer_provider.dart';
import 'package:remember_this_text/essentials/app_czar_operating_session/domain/app_czar_operating_currentness_models.dart';

void main() {
  test('currentness read is fenced by exact before/after revisions', () async {
    final beforeToken = Object();
    final afterToken = Object();
    final fences = <AppCzarOperatingReadFence>[
      _fence(revisionToken: beforeToken),
      _fence(revisionToken: afterToken),
    ];
    final observer = _observer(readFence: () async => fences.removeAt(0));

    final observation = await observer.readCurrentness();

    expect(observation.isCoherent, isFalse);
    expect(observation.source?.condition, AppCzarSourceCondition.readable);
    expect(
      observation.importStore?.condition,
      AppCzarDatabaseCondition.healthy,
    );
    expect(observation.graphStore?.condition, AppCzarDatabaseCondition.healthy);
  });

  test('active mutation defers without reading source or stores', () async {
    var protectedReads = 0;
    final activeFence = _fence(revisionToken: Object(), isActive: true);
    final observer = ReadOnlyAppCzarOperatingCurrentnessObserver(
      readFence: () async => activeFence,
      readSource: () async {
        protectedReads++;
        return _source;
      },
      readImportStore: () async {
        protectedReads++;
        return _importStore;
      },
      readGraphStore: () async {
        protectedReads++;
        return _graphStore;
      },
      readArchive: () async {
        protectedReads++;
        return _archive;
      },
    );

    final currentness = await observer.readCurrentness();
    final coverage = await observer.readCoverage();

    expect(protectedReads, 0);
    expect(currentness.isCoherent, isFalse);
    expect(currentness.source, isNull);
    expect(coverage.isCoherent, isFalse);
    expect(coverage.archive.condition, AppCzarArchiveCondition.unknown);
  });

  test('read failures remain UNKNOWN evidence inside a stable fence', () async {
    final token = Object();
    final observer = _observer(
      readFence: () async => _fence(revisionToken: token),
      readSource: () async => throw StateError('source probe failed'),
      readImportStore: () async => throw StateError('import probe failed'),
      readGraphStore: () async => throw StateError('graph probe failed'),
      readArchive: () async => throw StateError('coverage probe failed'),
    );

    final currentness = await observer.readCurrentness();
    final coverage = await observer.readCoverage();

    expect(currentness.isCoherent, isTrue);
    expect(currentness.source?.condition, AppCzarSourceCondition.unknown);
    expect(
      currentness.importStore?.condition,
      AppCzarDatabaseCondition.unknown,
    );
    expect(currentness.graphStore?.condition, AppCzarDatabaseCondition.unknown);
    expect(coverage.isCoherent, isTrue);
    expect(coverage.archive.condition, AppCzarArchiveCondition.unknown);
    expect(coverage.archive.issue, contains('coverage probe failed'));
  });
}

ReadOnlyAppCzarOperatingCurrentnessObserver _observer({
  required Future<AppCzarOperatingReadFence> Function() readFence,
  Future<AppCzarSourceObservation> Function()? readSource,
  Future<AppCzarDatabaseObservation> Function()? readImportStore,
  Future<AppCzarDatabaseObservation> Function()? readGraphStore,
  Future<AppCzarArchiveObservation> Function()? readArchive,
}) {
  return ReadOnlyAppCzarOperatingCurrentnessObserver(
    readFence: readFence,
    readSource: readSource ?? () async => _source,
    readImportStore: readImportStore ?? () async => _importStore,
    readGraphStore: readGraphStore ?? () async => _graphStore,
    readArchive: readArchive ?? () async => _archive,
  );
}

AppCzarOperatingReadFence _fence({
  required Object revisionToken,
  bool isActive = false,
}) {
  return AppCzarOperatingReadFence(
    messageDataGeneration: 4,
    archiveLocation: const AppCzarOperatingArchiveLocationEvidence(
      generation: 2,
      isReadable: true,
      isWritableMutationEligible: true,
      resolvedPath: '/test/archive',
    ),
    mutation: AppCzarOperatingMutationFence(
      isActive: isActive,
      revisionToken: revisionToken,
      lastReleasedAtMicroseconds: 12,
    ),
  );
}

const _source = AppCzarSourceObservation(
  condition: AppCzarSourceCondition.readable,
  messageCount: 10,
  maxRowId: 20,
  sampleStable: true,
);

const _importStore = AppCzarDatabaseObservation(
  condition: AppCzarDatabaseCondition.healthy,
  messageCount: 10,
  liveMessageCount: 10,
  liveMaxSourceRowId: 20,
);

const _graphStore = AppCzarDatabaseObservation(
  condition: AppCzarDatabaseCondition.healthy,
  messageCount: 10,
  chatCount: 2,
  chatMessageEdgeCount: 10,
);

const _coverage = AppCzarAttachmentCoverageObservation(
  condition: AppCzarAttachmentCoverageCondition.complete,
  requiredCount: 1,
  coveredCount: 1,
  missingCount: 0,
  unverifiableCount: 0,
  archiveScopeIdentity: 'test-scope',
  archiveGeneration: 2,
);

const _archive = AppCzarArchiveObservation(
  condition: AppCzarArchiveCondition.available,
  label: 'Test archive',
  coverage: _coverage,
  archiveScopeIdentity: 'test-scope',
  archiveGeneration: 2,
  resolvedPath: '/test/archive',
);
