import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const domainPath =
      'lib/essentials/onboarding/domain/onboarding_operation_snapshot.dart';
  const controllerPath =
      'lib/essentials/onboarding/application/'
      'onboarding_operation_snapshot_controller.dart';
  const providerPath =
      'lib/essentials/onboarding/application/'
      'onboarding_operation_snapshot_provider.dart';
  const storePath =
      'lib/essentials/onboarding/infrastructure/persistence/'
      'overlay_onboarding_operation_snapshot_store.dart';
  const storeContractPath =
      'lib/essentials/onboarding/application/'
      'onboarding_operation_snapshot_store.dart';
  const readOnlyEvidencePath =
      'lib/essentials/onboarding/infrastructure/persistence/'
      'sqlite_message_lens_installation_evidence_reader.dart';
  const reconciliationPath =
      'lib/essentials/onboarding/application/'
      'onboarding_operation_reconciliation.dart';
  const coordinatorPath =
      'lib/essentials/onboarding/application/'
      'onboarding_journey_coordinator_provider.dart';

  test('one canonical durable snapshot authority uses overlay settings', () {
    final store = File(storePath).readAsStringSync();
    final storeContract = File(storeContractPath).readAsStringSync();
    final readOnlyEvidence = File(readOnlyEvidencePath).readAsStringSync();
    final providers = File(providerPath).readAsStringSync();

    expect(
      storeContract,
      contains(
        <String>[
          'onboardingOperationSnapshotSettingKey =',
          "    'onboarding_operation_snapshot_v1'",
        ].join('\n'),
      ),
    );
    expect(
      store,
      contains('settingKey = onboardingOperationSnapshotSettingKey'),
    );
    expect(readOnlyEvidence, contains('onboardingOperationSnapshotSettingKey'));
    expect(store, contains('writeOverlaySetting'));
    expect(providers, contains('OverlayOnboardingOperationSnapshotStore'));
    expect(_dartSourcesContaining('onboarding_operation_snapshot_v1'), {
      storeContractPath,
    });
  });

  test('operation and stage truth are typed and distinct', () {
    final domain = File(domainPath).readAsStringSync();

    expect(domain, contains('enum OnboardingOperationStatus'));
    expect(domain, contains('interrupted'));
    expect(domain, contains('failed'));
    expect(domain, contains('enum OnboardingOperationStage'));
    expect(domain, contains("'current_stage': currentStage?.name"));
  });

  test('presentation cannot mutate the operation snapshot directly', () {
    final violations = <String>[];
    for (final file in _dartFilesUnder(
      'lib/essentials/onboarding/presentation',
    )) {
      final source = file.readAsStringSync();
      if (source.contains('OnboardingOperationSnapshotController') ||
          source.contains('onboardingOperationControllerProvider') ||
          source.contains('OnboardingOperationSnapshotStore')) {
        violations.add(file.path);
      }
    }

    expect(violations, isEmpty);
  });

  test('progress is observation-driven and has no timer heartbeat', () {
    final controller = File(controllerPath).readAsStringSync();
    final domain = File(domainPath).readAsStringSync();
    final providers = File(providerPath).readAsStringSync();

    expect(controller, contains('reportProgress'));
    expect(domain, contains('lastProgressObservedAtUtc'));
    expect(controller, isNot(contains('Timer.periodic')));
    expect(providers, isNot(contains('Timer.periodic')));
  });

  test('new process mechanically interrupts stale running state', () {
    final controller = File(controllerPath).readAsStringSync();

    expect(
      controller,
      contains('_current.processSessionId != _processSessionId'),
    );
    expect(controller, contains('_current.interrupt'));
  });

  test('completion requires typed durable proof', () {
    final controller = File(controllerPath).readAsStringSync();

    expect(controller, contains('OnboardingOperationCompletionProof proof'));
    expect(controller, contains('_requireCompatibleCompletionProof'));
    expect(controller, contains('OnboardingInstallationReadyProof'));
  });

  test('snapshot records work but cannot grant mutation authority', () {
    final controller = File(controllerPath).readAsStringSync();
    final coordinator = File(coordinatorPath).readAsStringSync();

    expect(controller, isNot(contains('archiveMutationCoordinatorProvider')));
    expect(controller, isNot(contains('ArchiveMutationOperation')));
    expect(coordinator, contains('archiveMutationCoordinatorProvider'));
    expect(coordinator, contains('ArchiveMutationOperation.onboardingImport'));
  });

  test('reconciliation is a pure evidence interpretation owned by Journey', () {
    final reconciliation = File(reconciliationPath).readAsStringSync();
    final coordinator = File(coordinatorPath).readAsStringSync();

    expect(reconciliation, contains('OnboardingEnvironmentReport report'));
    expect(reconciliation, contains('OnboardingOperationSnapshot snapshot'));
    expect(reconciliation, isNot(contains('Provider')));
    expect(reconciliation, isNot(contains('Ref ')));
    expect(reconciliation, isNot(contains('ref.')));
    expect(reconciliation, isNot(contains('OnboardingDatabaseProbeReader')));
    expect(reconciliation, isNot(contains('probeFile')));
    expect(
      coordinator,
      contains('onboardingReconciliationEvidenceFrom(report, snapshot)'),
    );
  });

  test('operational persistence contains no narrator copy', () {
    final domain = File(domainPath).readAsStringSync().toLowerCase();
    final store = File(storePath).readAsStringSync().toLowerCase();

    for (final forbidden in <String>[
      "i've got you",
      'working on it',
      'messagelens is',
      'narrator',
    ]) {
      expect(domain, isNot(contains(forbidden)));
      expect(store, isNot(contains(forbidden)));
    }
  });

  test('raw snapshot progress is not imported database truth', () {
    final controller = File(controllerPath).readAsStringSync();
    final domain = File(domainPath).readAsStringSync();

    expect(controller, contains('cannot substitute its snapshot'));
    expect(domain, isNot(contains('rowsImported')));
    expect(domain, isNot(contains('graphRowsCreated')));
  });

  test('Delete MessageLens App Data remains outside this foundation', () {
    final sources = _dartFilesUnder(
      'lib/essentials/onboarding',
    ).map((file) => file.readAsStringSync()).join('\n');

    expect(sources, isNot(contains('deleteMessageLensAppData')));
  });
}

Set<String> _dartSourcesContaining(String needle) {
  final paths = <String>{};
  for (final file in _dartFilesUnder('lib')) {
    if (file.readAsStringSync().contains(needle)) {
      paths.add(file.path);
    }
  }
  return paths;
}

List<File> _dartFilesUnder(String path) {
  return Directory(path)
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList(growable: false);
}
