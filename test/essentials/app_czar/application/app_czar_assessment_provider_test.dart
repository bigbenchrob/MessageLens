import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_assessment_provider.dart';
import 'package:remember_this_text/essentials/app_czar/application/app_czar_observation_reader.dart';
import 'package:remember_this_text/essentials/app_czar/domain/app_czar_models.dart';

void main() {
  test('observation completion order cannot change the selection', () async {
    final first = _CompletingReader();
    final second = _CompletingReader();
    final firstContainer = _container(first);
    final secondContainer = _container(second);
    addTearDown(firstContainer.dispose);
    addTearDown(secondContainer.dispose);

    firstContainer.read(appCzarAssessmentControllerProvider);
    secondContainer.read(appCzarAssessmentControllerProvider);
    await Future<void>.delayed(Duration.zero);

    first.completeInOrder(<String>[
      'root',
      'source',
      'import',
      'graph',
      'overlay',
      'archive',
    ]);
    second.completeInOrder(<String>[
      'archive',
      'overlay',
      'graph',
      'import',
      'source',
      'root',
    ]);

    final firstAssessment = await _waitForAssessment(firstContainer);
    final secondAssessment = await _waitForAssessment(secondContainer);
    expect(secondAssessment.diagnosis, firstAssessment.diagnosis);
    expect(
      secondAssessment.virtualCoordinator,
      firstAssessment.virtualCoordinator,
    );
  });

  test('a new assessment generation inherits no previous facts', () async {
    final reader = _QueuedReader();
    final container = _container(reader);
    addTearDown(container.dispose);

    container.read(appCzarAssessmentControllerProvider);
    final first = await _waitForAssessment(container);
    expect(
      first.virtualCoordinator,
      AppCzarVirtualCoordinator.operatingSession,
    );

    final rerun = container
        .read(appCzarAssessmentControllerProvider.notifier)
        .runAgain();
    final resetState = container.read(appCzarAssessmentControllerProvider);
    expect(resetState.generation, 1);
    expect(resetState.assessment, isNull);
    expect(resetState.root, isNull);
    expect(resetState.source, isNull);
    expect(resetState.importStore, isNull);
    expect(resetState.graphStore, isNull);
    expect(resetState.overlay, isNull);
    expect(resetState.attachmentArchive, isNull);

    await rerun;
    final second = container
        .read(appCzarAssessmentControllerProvider)
        .assessment!;
    expect(second.virtualCoordinator, AppCzarVirtualCoordinator.onboarding);
  });
}

ProviderContainer _container(AppCzarObservationReader reader) {
  return ProviderContainer(
    overrides: [appCzarObservationReaderProvider.overrideWithValue(reader)],
  );
}

Future<AppCzarAssessment> _waitForAssessment(
  ProviderContainer container,
) async {
  for (var attempt = 0; attempt < 100; attempt += 1) {
    final assessment = container
        .read(appCzarAssessmentControllerProvider)
        .assessment;
    if (assessment != null) {
      return assessment;
    }
    await Future<void>.delayed(Duration.zero);
  }
  throw StateError('AppCzar assessment did not complete.');
}

final class _CompletingReader implements AppCzarObservationReader {
  final root = Completer<AppCzarRootObservation>();
  final source = Completer<AppCzarSourceObservation>();
  final importStore = Completer<AppCzarDatabaseObservation>();
  final graphStore = Completer<AppCzarDatabaseObservation>();
  final overlay = Completer<AppCzarDatabaseObservation>();
  final archive = Completer<AppCzarArchiveObservation>();

  void completeInOrder(List<String> order) {
    for (final item in order) {
      switch (item) {
        case 'root':
          root.complete(_root);
        case 'source':
          source.complete(_source);
        case 'import':
          importStore.complete(_importStore);
        case 'graph':
          graphStore.complete(_graphStore);
        case 'overlay':
          overlay.complete(_overlay);
        case 'archive':
          archive.complete(_archive);
      }
    }
  }

  @override
  Future<AppCzarArchiveObservation> readAttachmentArchive() => archive.future;

  @override
  Future<AppCzarDatabaseObservation> readGraphStore() => graphStore.future;

  @override
  Future<AppCzarDatabaseObservation> readImportStore() => importStore.future;

  @override
  Future<AppCzarDatabaseObservation> readOverlay() => overlay.future;

  @override
  Future<AppCzarRootObservation> readRoot() => root.future;

  @override
  Future<AppCzarSourceObservation> readSource() => source.future;
}

final class _QueuedReader implements AppCzarObservationReader {
  var generation = 0;
  var readsInGeneration = 0;

  bool get _second => generation == 1;

  void _recordRead() {
    readsInGeneration += 1;
    if (readsInGeneration == 6) {
      readsInGeneration = 0;
      generation += 1;
    }
  }

  @override
  Future<AppCzarArchiveObservation> readAttachmentArchive() async {
    const value = _archive;
    _recordRead();
    return value;
  }

  @override
  Future<AppCzarDatabaseObservation> readGraphStore() async {
    final value = _second
        ? const AppCzarDatabaseObservation.absent()
        : _graphStore;
    _recordRead();
    return value;
  }

  @override
  Future<AppCzarDatabaseObservation> readImportStore() async {
    final value = _second
        ? const AppCzarDatabaseObservation.absent()
        : _importStore;
    _recordRead();
    return value;
  }

  @override
  Future<AppCzarDatabaseObservation> readOverlay() async {
    const value = _overlay;
    _recordRead();
    return value;
  }

  @override
  Future<AppCzarRootObservation> readRoot() async {
    const value = _root;
    _recordRead();
    return value;
  }

  @override
  Future<AppCzarSourceObservation> readSource() async {
    const value = _source;
    _recordRead();
    return value;
  }
}

const _root = AppCzarRootObservation(
  admitted: true,
  path: '/Volumes/WD_ELEMENTS/MessageLens Development',
);
const _source = AppCzarSourceObservation(
  condition: AppCzarSourceCondition.readable,
  messageCount: 100,
  maxRowId: 100,
  sampleStable: true,
);
const _importStore = AppCzarDatabaseObservation(
  condition: AppCzarDatabaseCondition.healthy,
  schemaVersion: 10,
  messageCount: 100,
  liveMessageCount: 100,
  liveMaxSourceRowId: 100,
);
const _graphStore = AppCzarDatabaseObservation(
  condition: AppCzarDatabaseCondition.healthy,
  schemaVersion: 3,
  messageCount: 100,
  chatCount: 4,
  chatMessageEdgeCount: 100,
);
const _overlay = AppCzarDatabaseObservation(
  condition: AppCzarDatabaseCondition.healthy,
  schemaVersion: 8,
);
const _archive = AppCzarArchiveObservation(
  condition: AppCzarArchiveCondition.available,
  label: 'Toshiba',
  archiveScopeIdentity: 'test-scope',
  archiveGeneration: 0,
  resolvedPath: '/test/archive',
  coverage: _completeCoverage,
);
const _completeCoverage = AppCzarAttachmentCoverageObservation(
  condition: AppCzarAttachmentCoverageCondition.complete,
  requiredCount: 1,
  coveredCount: 1,
  missingCount: 0,
  unverifiableCount: 0,
  archiveScopeIdentity: 'test-scope',
  archiveGeneration: 0,
);
