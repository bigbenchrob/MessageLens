import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Virgin first import cannot reach reset or checkpoint machinery', () {
    final source = _read(
      'lib/essentials/onboarding/application/'
      'virgin_onboarding_import_executor.dart',
    );

    expect(source, contains('VirginOnboardingImportExecutor'));
    expect(source, contains('OnboardingOperationStage.messageDataBuild'));
    expect(source, isNot(contains('MessageDataResetService')));
    expect(source, isNot(contains('messageDataReset')));
    expect(source, isNot(contains('verifiedArchiveCheckpointProvider')));
    expect(source, isNot(contains('archive_adoption')));
  });

  test('installation classification imports no writable provider seams', () {
    final provider = _read(
      'lib/essentials/onboarding/application/'
      'message_lens_installation_state_provider.dart',
    );
    final reader = _read(
      'lib/essentials/onboarding/infrastructure/persistence/'
      'sqlite_message_lens_installation_evidence_reader.dart',
    );

    expect(provider, isNot(contains('onboardingOperationControllerProvider')));
    expect(provider, isNot(contains('overlayDatabaseProvider')));
    expect(provider, isNot(contains('appLoggerProvider')));
    expect(reader, contains('OpenMode.readOnly'));
    expect(reader, contains('PRAGMA query_only = ON'));
    expect(reader, isNot(contains('MigrationStrategy')));
    expect(reader, isNot(contains('openDatabase(')));
  });

  test('archive admission and container construction precede runApp', () {
    final source = _read('lib/main.dart');
    final mainSource = source.substring(source.indexOf('void main() async'));
    final archiveAdmission = mainSource.indexOf('await _admitArchive()');
    final providerContainer = mainSource.indexOf('ProviderContainer(');
    final runApp = mainSource.indexOf('runApp(');

    expect(archiveAdmission, greaterThanOrEqualTo(0));
    expect(providerContainer, greaterThan(archiveAdmission));
    expect(runApp, greaterThan(providerContainer));
    expect(
      mainSource,
      isNot(contains('messageLensInstallationStateProvider.future')),
    );
  });

  test('StartupApp gates persistent initialization on classification', () {
    final source = _read('lib/main.dart');
    final startupSource = source.substring(source.indexOf('class StartupApp'));
    final classificationWatch = startupSource.indexOf(
      'ref.watch(messageLensInstallationStateProvider)',
    );
    final classifiedData = startupSource.indexOf('data: (state)');
    final persistentInitialization = startupSource.indexOf(
      '_schedulePostClassificationInitialization(state)',
      classifiedData,
    );
    final admittedApplication = startupSource.indexOf(
      'return widget.admittedChild',
      persistentInitialization,
    );

    expect(classificationWatch, greaterThanOrEqualTo(0));
    expect(classifiedData, greaterThan(classificationWatch));
    expect(persistentInitialization, greaterThan(classifiedData));
    expect(admittedApplication, greaterThan(persistentInitialization));
    expect(startupSource, contains("Text('Checking databases…')"));
  });
}

String _read(String relativePath) {
  return File('${Directory.current.path}/$relativePath').readAsStringSync();
}
