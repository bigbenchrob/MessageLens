import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Start Fresh is typed, authorized, and verified', () {
    final service = File(
      'lib/essentials/onboarding/application/start_fresh_service.dart',
    ).readAsStringSync();
    final provider = File(
      'lib/essentials/onboarding/application/start_fresh_service_provider.dart',
    ).readAsStringSync();

    expect(service, contains('MessageLensInstallationState'));
    expect(service, contains('ArchiveMutationCapability'));
    expect(service, contains('resetDerivedDataForStartFresh'));
    expect(service, contains('MessageLensInstallationStateKind.virgin'));
    expect(provider, contains('ArchiveMutationOperation.startFresh'));
  });

  test('Start Fresh targets only canonical derived database base names', () {
    final resetService = File(
      'lib/essentials/onboarding/application/message_data_reset_service.dart',
    ).readAsStringSync();
    final fileStore = File(
      'lib/essentials/onboarding/infrastructure/persistence/'
      'filesystem_derived_message_data_file_store.dart',
    ).readAsStringSync();

    expect(resetService, contains('AppDatabaseFile.sourceScopedImport'));
    expect(resetService, contains('AppDatabaseFile.conversationGraph'));
    expect(resetService, isNot(contains('attachment_archive')));
    expect(fileStore, contains('_validatedDatabaseBaseName'));
    expect(fileStore, isNot(contains('delete(recursive: true)')));
  });

  test('startup has no reachable reset no-op or destructive old label', () {
    final mainSource = File('lib/main.dart').readAsStringSync();

    expect(mainSource, contains('startFreshServiceProvider'));
    expect(mainSource, contains("This MessageLens setup wasn't completed"));
    expect(mainSource, isNot(contains('Delete MessageLens App Data')));
    expect(mainSource, isNot(contains("logger.warn('Delete requested'")));
  });

  test('operation policy blocks database reopen during Start Fresh', () {
    final operationPolicy = File(
      'lib/essentials/archive_environment/domain/'
      'archive_mutation_operation.dart',
    ).readAsStringSync();

    expect(operationPolicy, contains('ArchiveMutationOperation.startFresh'));
    expect(operationPolicy, contains('blocksDatabaseReopen'));
  });

  test('advanced Start Fresh owns presentation before mutation', () {
    final actionProvider = File(
      'lib/essentials/onboarding/application/'
      'advanced_start_fresh_action_provider.dart',
    ).readAsStringSync();
    final action = File(
      'lib/essentials/onboarding/application/advanced_start_fresh_action.dart',
    ).readAsStringSync();
    final shell = File(
      'lib/essentials/navigation/presentation/view/macos_app_shell.dart',
    ).readAsStringSync();

    expect(actionProvider, contains('@Riverpod(keepAlive: true)'));
    expect(action, contains('presentation.beginPreparing()'));
    expect(action, contains('await waitForPresentationFrame()'));
    expect(shell, contains('AdvancedStartFreshOverlayHost'));
  });

  test('advanced Start Fresh claims once before asynchronous work', () {
    final action = File(
      'lib/essentials/onboarding/application/'
      'advanced_start_fresh_action.dart',
    ).readAsStringSync();
    final claimIndex = action.indexOf('_activeRequest = claimedRequest;');
    final runIndex = action.indexOf('_activeExecution = _runClaimedRequest');

    expect(claimIndex, greaterThanOrEqualTo(0));
    expect(runIndex, greaterThan(claimIndex));
    expect(action, contains('return activeRequest.completer.future;'));
    expect(action, contains('waitUntilDismissed'));
    expect(action, isNot(contains('unawaited(')));
    expect(action, isNot(contains('Timer(')));
  });

  test('advanced Start Fresh eligibility reads current durable evidence', () {
    final actionProvider = File(
      'lib/essentials/onboarding/application/'
      'advanced_start_fresh_action_provider.dart',
    ).readAsStringSync();
    final currentStateReader = File(
      'lib/essentials/onboarding/application/'
      'advanced_start_fresh_current_state_reader_provider.dart',
    ).readAsStringSync();

    expect(
      actionProvider,
      contains('advancedStartFreshCurrentStateReaderProvider'),
    );
    expect(
      actionProvider,
      isNot(contains('messageLensInstallationStateProvider')),
    );
    expect(currentStateReader, contains('evidenceReader.readBounded'));
    expect(currentStateReader, contains('classifier.classify(evidence)'));
  });

  test('installation evidence inspection cannot block the Flutter isolate', () {
    final contract = File(
      'lib/essentials/onboarding/application/'
      'message_lens_installation_evidence_reader.dart',
    ).readAsStringSync();
    final reader = File(
      'lib/essentials/onboarding/infrastructure/persistence/'
      'sqlite_message_lens_installation_evidence_reader.dart',
    ).readAsStringSync();
    final advancedActionProvider = File(
      'lib/essentials/onboarding/application/'
      'advanced_start_fresh_action_provider.dart',
    ).readAsStringSync();

    expect(contract, contains('Future<MessageLensInstallationEvidence> read'));
    expect(reader, contains('Isolate.run'));
    expect(
      advancedActionProvider,
      isNot(contains('ref.invalidate(messageLensInstallationStateProvider)')),
    );
  });

  test('Start Fresh reuses the executable Onboarding Presence composition', () {
    final provider = File(
      'lib/essentials/onboarding/application/start_fresh_service_provider.dart',
    ).readAsStringSync();

    expect(
      provider,
      contains('requiredSourcesReadinessRepositoryProvider.future'),
    );
    expect(
      provider,
      isNot(contains('presenceScheduleMaintenanceRepositoryProvider.future')),
    );
  });
}
