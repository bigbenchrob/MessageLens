import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/sidebar/domain/sidebar_action_intent.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_adoption_workflow.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_adoption.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_candidate_verification.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_configuration.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_state.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/payloads/attachment_archive_settings_cassette_payload.dart';
import 'package:remember_this_text/features/settings/application/sidebar_cassette_spec/resolvers/attachment_archive_settings_resolver.dart';

void main() {
  late ProviderContainer container;
  late AttachmentArchiveSettingsResolver resolver;

  setUp(() {
    container = ProviderContainer();
    resolver = container.read(
      attachmentArchiveSettingsResolverProvider.notifier,
    );
  });

  tearDown(() => container.dispose());

  test(
    'current location uses physical context without configuration jargon',
    () {
      final payload = resolver.resolve(
        cassetteIndex: 2,
        location: AttachmentArchiveLocationState.defaultAvailable(
          archiveRootPath:
              '/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/'
              'MessageLens Development/attachment_archive',
          generation: 3,
        ),
        workflow: _idle(),
      );

      expect(
        payload.workflowView,
        AttachmentArchiveSettingsWorkflowView.currentLocation,
      );
      expect(payload.bodyText, contains('Current archive'));
      expect(payload.bodyText, contains('/Volumes/WD_ELEMENTS'));
      expect(payload.bodyText, contains('WD_ELEMENTS · Connected'));
      expect(payload.bodyText, isNot(contains('Internal')));
      expect(payload.bodyText, isNot(contains('defaultInternal')));
      expect(payload.actions, isEmpty);
      expect(payload.footnote, isNull);
      expect(payload.statusLines, isEmpty);
      expect(payload.workflowTitle, isNull);
    },
  );

  test('mounted-volume path reports meaningful volume and connection', () {
    final payload = resolver.resolve(
      cassetteIndex: 2,
      location: AttachmentArchiveLocationState.customAvailable(
        configuration: _activeExternalConfiguration,
        archiveRootPath: '/Volumes/External/attachment_archive',
        generation: 4,
      ),
      workflow: _idle(),
    );

    expect(payload.bodyText, contains('External · Connected'));
    expect(payload.bodyText, contains('/Volumes/External/attachment_archive'));
    expect(payload.bodyText, isNot(contains('customExternal')));
    expect(payload.actions, isEmpty);
    expect(payload.statusLines, isEmpty);
  });

  test('unavailable external state retains path, volume, and issue', () {
    final payload = resolver.resolve(
      cassetteIndex: 2,
      location: AttachmentArchiveLocationState.customUnavailable(
        configuration: _activeExternalConfiguration,
        issue: 'Volume disconnected.',
        generation: 5,
      ),
      workflow: _idle(),
    );

    expect(payload.bodyText, contains('External · Not connected'));
    expect(payload.bodyText, contains('/Volumes/External/attachment_archive'));
    expect(payload.bodyText, contains('Volume disconnected.'));
    expect(payload.actions, isEmpty);
    expect(payload.statusLines, isEmpty);
  });

  test('read-only and permission-denied states remain distinct', () {
    final readOnly = resolver.resolve(
      cassetteIndex: 2,
      location: AttachmentArchiveLocationState.customReadOnly(
        configuration: _activeExternalConfiguration,
        archiveRootPath: '/Volumes/External/attachment_archive',
        issue: 'Mounted read-only.',
        generation: 6,
      ),
      workflow: _idle(),
    );
    final denied = resolver.resolve(
      cassetteIndex: 2,
      location: AttachmentArchiveLocationState.permissionDenied(
        configuration: _activeExternalConfiguration,
        issue: 'Permission was denied.',
        generation: 7,
      ),
      workflow: _idle(),
    );

    expect(readOnly.bodyText, contains('External · Connected · Read-only'));
    expect(denied.bodyText, contains('External · Permission needed'));
    expect(readOnly.actions, isEmpty);
    expect(denied.actions, isEmpty);
  });

  test('exact enabled workflow offers Choose Archive Copy', () {
    final payload = resolver.resolve(
      cassetteIndex: 2,
      location: AttachmentArchiveLocationState.defaultAvailable(
        archiveRootPath: '/tmp/MessageLens/attachment_archive',
      ),
      workflow: _idle(executionEnabled: true),
    );

    expect(payload.bodyText, contains('Select the copied attachment_archive'));
    expect(payload.bodyText, contains('will not copy or move'));
    expect(payload.actions, hasLength(1));
    expect(payload.actions.single.label, 'Choose Archive Copy…');
    expect(payload.actions.single.isEnabled, isTrue);
    expect(
      payload.actions.single.intent,
      isA<AttachmentArchiveUseExistingRequested>(),
    );
  });

  test('unavailable source keeps no-fallback copy and disables selection', () {
    final payload = resolver.resolve(
      cassetteIndex: 2,
      location: AttachmentArchiveLocationState.customUnavailable(
        configuration: _activeExternalConfiguration,
        issue: 'Volume disconnected.',
      ),
      workflow: _idle(executionEnabled: true),
    );

    expect(
      payload.bodyText,
      contains('Message browsing and search remain available'),
    );
    expect(payload.actions.single.isEnabled, isFalse);
  });

  test('checking shows truthful progress and Cancel', () {
    final payload = resolver.resolve(
      cassetteIndex: 2,
      location: _internalLocation,
      workflow: const AttachmentArchiveAdoptionWorkflowState(
        stage: AttachmentArchiveAdoptionWorkflowStage.checking,
        executionEnabled: true,
        sourcePath: '/source/attachment_archive',
        candidatePath: '/candidate/attachment_archive',
        progress: AttachmentArchiveVerificationProgress(
          phase: AttachmentArchiveVerificationPhase.sourceCoverage,
          filesChecked: 19,
          bytesChecked: 4096,
        ),
      ),
    );

    expect(payload.bodyText, contains('Current archive'));
    expect(payload.workflowTitle, 'Checking archive copy…');
    expect(
      payload.workflowBodyText,
      contains('Neither archive is being changed'),
    );
    expect(payload.workflowBodyText, contains('19 files'));
    expect(payload.statusLines.first.label, 'Selected copy');
    expect(payload.actions.single.label, 'Cancel');
  });

  test('complete shows paths, totals, extras, and explicit adoption', () {
    final payload = resolver.resolve(
      cassetteIndex: 2,
      location: _internalLocation,
      workflow: const AttachmentArchiveAdoptionWorkflowState(
        stage: AttachmentArchiveAdoptionWorkflowStage.candidateComplete,
        executionEnabled: true,
        sourcePath: '/source/attachment_archive',
        candidatePath: '/candidate/attachment_archive',
        candidateVolumeName: 'External',
        candidateIsAdoptable: true,
        verifiedFileCount: 4039,
        verifiedBytes: 3461590538,
        allowedExtraCount: 3,
        allowedExtraBytes: 900,
      ),
    );

    expect(payload.workflowTitle, 'Archive copy verified');
    expect(
      payload.workflowBodyText,
      contains('3 additional preserved attachments'),
    );
    expect(payload.workflowBodyText, contains('4039 files · 3.22 GB verified'));
    expect(payload.workflowBodyText, contains('has not changed'));
    expect(
      payload.statusLines.map((line) => line.label),
      containsAll(<String>['Selected copy', 'Status']),
    );
    expect(payload.actions.map((action) => action.label), [
      'Cancel',
      'Use This Copy',
    ]);
    expect(
      payload.actions.last.intent,
      isA<AttachmentArchiveUseCandidateRequested>(),
    );
  });

  test('read-only complete only offers a different copy', () {
    final payload = resolver.resolve(
      cassetteIndex: 2,
      location: _internalLocation,
      workflow: const AttachmentArchiveAdoptionWorkflowState(
        stage: AttachmentArchiveAdoptionWorkflowStage.candidateComplete,
        executionEnabled: true,
        candidatePath: '/candidate/attachment_archive',
        verifiedFileCount: 4,
        verifiedBytes: 10,
      ),
    );

    expect(payload.workflowTitle, 'This copy can’t be used');
    expect(
      payload.workflowBodyText,
      contains('cannot use it as the active archive'),
    );
    expect(payload.actions.map((action) => action.label), [
      'Choose a Different Copy',
    ]);
  });

  test('behind is normal synchronization state with exact missing totals', () {
    final payload = resolver.resolve(
      cassetteIndex: 2,
      location: _internalLocation,
      workflow: const AttachmentArchiveAdoptionWorkflowState(
        stage: AttachmentArchiveAdoptionWorkflowStage.candidateBehind,
        executionEnabled: true,
        sourcePath: '/source/attachment_archive',
        candidatePath: '/candidate/attachment_archive',
        missingCount: 1,
        missingBytes: 3250586,
      ),
    );

    expect(payload.workflowTitle, 'This copy is not up to date');
    expect(payload.workflowBodyText, contains('1 attachment (3.1 MB)'));
    expect(payload.workflowBodyText, contains('Update the copied folder'));
    expect(payload.workflowBodyText, contains('has not changed'));
    expect(payload.actions.map((action) => action.label), ['Check Again']);
    expect(
      payload.actions.where((action) => action.label.contains('Use')),
      isEmpty,
    );
  });

  test('invalid shows the typed reason and only choose another', () {
    final payload = resolver.resolve(
      cassetteIndex: 2,
      location: _internalLocation,
      workflow: const AttachmentArchiveAdoptionWorkflowState(
        stage: AttachmentArchiveAdoptionWorkflowStage.candidateInvalid,
        executionEnabled: true,
        issue: 'The candidate contains a symbolic link.',
      ),
    );

    expect(payload.workflowTitle, 'This copy couldn’t be verified');
    expect(payload.workflowBodyText, contains('symbolic link'));
    expect(payload.workflowBodyText, contains('has not changed'));
    expect(payload.actions.single.label, 'Choose a Different Copy');
  });

  test('approval change requires another explicit check', () {
    final payload = resolver.resolve(
      cassetteIndex: 2,
      location: _internalLocation,
      workflow: const AttachmentArchiveAdoptionWorkflowState(
        stage: AttachmentArchiveAdoptionWorkflowStage.archiveChanged,
        executionEnabled: true,
        sourcePath: '/source/attachment_archive',
        candidatePath: '/candidate/attachment_archive',
      ),
    );

    expect(payload.workflowTitle, contains('changed since it was checked'));
    expect(payload.workflowBodyText, contains('has not changed'));
    expect(payload.actions.single.label, 'Check Again');
  });

  test('switching and success never use mover language', () {
    final switching = resolver.resolve(
      cassetteIndex: 2,
      location: _internalLocation,
      workflow: const AttachmentArchiveAdoptionWorkflowState(
        stage: AttachmentArchiveAdoptionWorkflowStage.switching,
        executionEnabled: true,
      ),
    );
    final success = resolver.resolve(
      cassetteIndex: 2,
      location: AttachmentArchiveLocationState.customAvailable(
        configuration: _activeExternalConfiguration,
        archiveRootPath: '/candidate/attachment_archive',
      ),
      workflow: const AttachmentArchiveAdoptionWorkflowState(
        stage: AttachmentArchiveAdoptionWorkflowStage.success,
        executionEnabled: true,
        sourcePath: '/source/attachment_archive',
        candidatePath: '/candidate/attachment_archive',
        candidateVolumeName: 'External',
      ),
    );

    expect(switching.workflowTitle, 'Switching to archive copy…');
    expect(switching.workflowBodyText, isNot(contains('Copying')));
    expect(success.workflowTitle, 'Attachment archive switched');
    expect(
      success.workflowBodyText,
      contains('MessageLens has not deleted it'),
    );
    expect(success.workflowBodyText, isNot(contains('moved successfully')));
    expect(success.actions, isEmpty);
  });

  test('rollback and recovery outcomes do not claim success', () {
    final restored = resolver.resolve(
      cassetteIndex: 2,
      location: _internalLocation,
      workflow: const AttachmentArchiveAdoptionWorkflowState(
        stage: AttachmentArchiveAdoptionWorkflowStage.currentArchive,
        executionEnabled: true,
      ),
      recovery: const AttachmentArchiveAdoptionResult(
        outcome: AttachmentArchiveAdoptionOutcome.rollbackRestoredPrevious,
        transactionId: 'transaction',
      ),
    );
    final pending = resolver.resolve(
      cassetteIndex: 2,
      location: _internalLocation,
      workflow: const AttachmentArchiveAdoptionWorkflowState(
        stage: AttachmentArchiveAdoptionWorkflowStage.currentArchive,
        executionEnabled: true,
      ),
      recovery: const AttachmentArchiveAdoptionResult(
        outcome:
            AttachmentArchiveAdoptionOutcome.rollbackPendingPreviousUnavailable,
        transactionId: 'transaction',
      ),
    );
    final conflict = resolver.resolve(
      cassetteIndex: 2,
      location: _internalLocation,
      workflow: const AttachmentArchiveAdoptionWorkflowState(
        stage: AttachmentArchiveAdoptionWorkflowStage.currentArchive,
        executionEnabled: true,
      ),
      recovery: const AttachmentArchiveAdoptionResult(
        outcome: AttachmentArchiveAdoptionOutcome.configurationConflict,
        transactionId: 'transaction',
      ),
    );

    expect(restored.workflowBodyText, contains('restored the previous'));
    expect(pending.workflowTitle, contains('waiting for the previous archive'));
    expect(conflict.workflowBodyText, contains('did not guess'));
    for (final payload in [restored, pending, conflict]) {
      expect(
        payload.workflowTitle,
        isNot(contains('Attachment archive switched')),
      );
    }
  });
}

AttachmentArchiveAdoptionWorkflowState _idle({bool executionEnabled = false}) {
  return AttachmentArchiveAdoptionWorkflowState.currentArchive(
    executionEnabled: executionEnabled,
  );
}

final _internalLocation = AttachmentArchiveLocationState.defaultAvailable(
  archiveRootPath: '/source/attachment_archive',
  generation: 3,
);

final _activeExternalConfiguration =
    AttachmentArchiveLocationConfiguration.customExternal(
      bookmarkDataBase64: 'AQID',
      lastKnownPath: '/Volumes/External/attachment_archive',
      volumeName: 'External',
      customWritePolicy: AttachmentArchiveCustomWritePolicy.activeArchive,
    );
