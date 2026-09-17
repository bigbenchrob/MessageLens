import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/sidebar/domain/sidebar_action_intent.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_configuration.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_state.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_relocation.dart';
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

  test('default internal state exposes a gated Move action', () {
    final gatedPayload = resolver.resolve(
      cassetteIndex: 2,
      location: _internalLocation,
      relocation: null,
      relocationEnabled: false,
    );

    expect(
      gatedPayload.workflowView,
      AttachmentArchiveSettingsWorkflowView.currentLocation,
    );
    expect(gatedPayload.bodyText, contains('built-in attachment archive'));
    expect(gatedPayload.actions.single.label, 'Move…');
    expect(gatedPayload.actions.single.isEnabled, isFalse);
    expect(gatedPayload.footnote, contains('explicitly authorized'));

    final enabledPayload = resolver.resolve(
      cassetteIndex: 2,
      location: _internalLocation,
      relocation: null,
      relocationEnabled: true,
    );
    expect(enabledPayload.actions.single.isEnabled, isTrue);
    expect(
      enabledPayload.actions.single.intent,
      isA<AttachmentArchiveMoveRequested>(),
    );
  });

  test('current external state exposes no move or restore shortcut', () {
    final payload = resolver.resolve(
      cassetteIndex: 2,
      location: AttachmentArchiveLocationState.customAvailable(
        configuration: _activeConfiguration,
        archiveRootPath: '/Volumes/Test/MessageLens Attachment Archive op',
        generation: 4,
      ),
      relocation: null,
      relocationEnabled: true,
    );

    expect(payload.actions, isEmpty);
    expect(payload.bodyText, isNot(contains('Restore Default')));
    expect(payload.footnote, contains('does not silently fall back'));
  });

  test('selection and preparation never present success or Begin early', () {
    for (final stage in [
      AttachmentArchiveRelocationStage.selected,
      AttachmentArchiveRelocationStage.preflighting,
      AttachmentArchiveRelocationStage.preflighted,
      AttachmentArchiveRelocationStage.inventorying,
    ]) {
      final payload = resolver.resolve(
        cassetteIndex: 2,
        location: _internalLocation,
        relocation: _progress(stage: stage),
        relocationEnabled: true,
      );

      expect(
        payload.workflowView,
        AttachmentArchiveSettingsWorkflowView.preparingReview,
      );
      expect(payload.bodyText, contains('No payloads are being copied yet'));
      expect(payload.title, isNot(contains('Successfully')));
      expect(
        payload.actions.map((action) => action.intent),
        isNot(contains(isA<AttachmentArchiveBeginRelocationRequested>())),
      );
    }
  });

  test('successful preflight presents disclosure and explicit Begin', () {
    final payload = resolver.resolve(
      cassetteIndex: 3,
      location: _internalLocation,
      relocation: _progress(
        stage: AttachmentArchiveRelocationStage.inventoryComplete,
      ),
      relocationEnabled: true,
    );

    expect(
      payload.workflowView,
      AttachmentArchiveSettingsWorkflowView.preflightReview,
    );
    expect(payload.bodyText, contains('copy and verify'));
    expect(payload.bodyText, contains('will not be deleted'));
    expect(
      payload.statusLines,
      contains(
        predicate<AttachmentArchiveSettingsStatusLine>(
          (line) =>
              line.label == 'Filesystem safety checks' &&
              line.value == 'Passed',
        ),
      ),
    );
    expect(
      payload.actions.first.intent,
      isA<AttachmentArchiveBeginRelocationRequested>(),
    );
  });

  test('typed preflight failures remain specific and non-destructive', () {
    final cases = <AttachmentArchiveRelocationDeferredReason, String>{
      AttachmentArchiveRelocationDeferredReason.insufficientCapacity:
          'enough available capacity',
      AttachmentArchiveRelocationDeferredReason.destinationReadOnly:
          'read-only',
      AttachmentArchiveRelocationDeferredReason.unsupportedFilesystem:
          'safe file operations',
      AttachmentArchiveRelocationDeferredReason.destinationUnavailable:
          'destination is unavailable',
      AttachmentArchiveRelocationDeferredReason.sourceUnavailable:
          'source archive is unavailable',
      AttachmentArchiveRelocationDeferredReason.unsafeLocation: 'unsafe',
      AttachmentArchiveRelocationDeferredReason.conflictingDestination:
          'conflicting managed destination',
    };

    for (final MapEntry(key: reason, value: copy) in cases.entries) {
      final payload = resolver.resolve(
        cassetteIndex: 2,
        location: _internalLocation,
        relocation: _progress(
          stage: AttachmentArchiveRelocationStage.paused,
          deferredReason: reason,
          resumeStage: AttachmentArchiveRelocationStage.preflighting,
        ),
        relocationEnabled: true,
      );

      expect(payload.bodyText, contains(copy));
      expect(payload.bodyText, isNot(contains('Move failed')));
      expect(
        payload.actions.map((action) => action.label),
        contains('Choose Another Location…'),
      );
      expect(
        payload.actions.map((action) => action.label),
        isNot(contains('Delete')),
      );
    }
  });

  test('copy, verify, finalize, and activate remain distinct', () {
    final cases = {
      AttachmentArchiveRelocationStage.copying:
          AttachmentArchiveSettingsWorkflowView.copying,
      AttachmentArchiveRelocationStage.verifying:
          AttachmentArchiveSettingsWorkflowView.verifying,
      AttachmentArchiveRelocationStage.destinationFinalizing:
          AttachmentArchiveSettingsWorkflowView.finalizing,
      AttachmentArchiveRelocationStage.configurationSwitching:
          AttachmentArchiveSettingsWorkflowView.activating,
    };

    for (final MapEntry(key: stage, value: view) in cases.entries) {
      final payload = resolver.resolve(
        cassetteIndex: 2,
        location: _internalLocation,
        relocation: _progress(stage: stage),
        relocationEnabled: true,
      );

      expect(payload.workflowView, view);
      expect(payload.title, isNot(contains('Successfully')));
      expect(
        payload.statusLines.map((line) => line.label),
        containsAll([
          'Files copied',
          'Data copied',
          'Files verified',
          'Data verified',
        ]),
      );
    }
  });

  test('paused progress offers Resume and Cancel without deletion claim', () {
    final payload = resolver.resolve(
      cassetteIndex: 2,
      location: _internalLocation,
      relocation: _progress(
        stage: AttachmentArchiveRelocationStage.paused,
        deferredReason: AttachmentArchiveRelocationDeferredReason.userPaused,
        resumeStage: AttachmentArchiveRelocationStage.copying,
      ),
      relocationEnabled: true,
    );

    expect(payload.workflowView, AttachmentArchiveSettingsWorkflowView.paused);
    expect(payload.bodyText, contains('safe file boundary'));
    expect(payload.footnote, contains('durable relocation journal'));
    expect(
      payload.actions.map((action) => action.label),
      containsAll(['Resume', 'Cancel']),
    );
  });

  test(
    'cancelled state keeps source authoritative and makes no deletion claim',
    () {
      final payload = resolver.resolve(
        cassetteIndex: 2,
        location: _internalLocation,
        relocation: _progress(
          stage: AttachmentArchiveRelocationStage.cancelled,
        ),
        relocationEnabled: true,
      );

      expect(
        payload.workflowView,
        AttachmentArchiveSettingsWorkflowView.cancelled,
      );
      expect(
        payload.bodyText,
        contains('source archive remains authoritative'),
      );
      expect(
        payload.bodyText,
        contains('does not claim that destination data was deleted'),
      );
    },
  );

  test('success names active external archive and retained original', () {
    final payload = resolver.resolve(
      cassetteIndex: 2,
      location: AttachmentArchiveLocationState.customAvailable(
        configuration: _activeConfiguration,
        archiveRootPath: '/Volumes/Test/MessageLens Attachment Archive op',
        generation: 4,
      ),
      relocation: _progress(
        stage: AttachmentArchiveRelocationStage.sourceRetained,
        activationOccurred: true,
        sourceRetained: true,
      ),
      relocationEnabled: true,
    );

    expect(
      payload.workflowView,
      AttachmentArchiveSettingsWorkflowView.completed,
    );
    expect(payload.title, contains('Moved Successfully'));
    expect(payload.bodyText, contains('original archive is still stored'));
    expect(payload.bodyText, contains('/internal/attachment_archive'));
    expect(payload.actions, isEmpty);
    expect(payload.footnote, isNot(contains('reclaimed')));
  });

  test(
    'source-retained stage without full evidence never presents success',
    () {
      final payload = resolver.resolve(
        cassetteIndex: 2,
        location: AttachmentArchiveLocationState.customAvailable(
          configuration: _activeConfiguration,
          archiveRootPath: '/Volumes/Test/MessageLens Attachment Archive op',
          generation: 4,
        ),
        relocation: _progress(
          stage: AttachmentArchiveRelocationStage.sourceRetained,
        ),
        relocationEnabled: true,
      );

      expect(
        payload.workflowView,
        AttachmentArchiveSettingsWorkflowView.failed,
      );
      expect(payload.title, isNot(contains('Successfully')));
      expect(payload.bodyText, contains('will not present'));
    },
  );

  test('disconnected active external archive never promises fallback', () {
    final payload = resolver.resolve(
      cassetteIndex: 2,
      location: AttachmentArchiveLocationState.customUnavailable(
        configuration: _activeConfiguration,
        issue: 'Drive disconnected.',
        generation: 5,
      ),
      relocation: _progress(
        stage: AttachmentArchiveRelocationStage.sourceRetained,
        activationOccurred: true,
        sourceRetained: true,
      ),
      relocationEnabled: true,
    );

    expect(payload.title, contains('Unavailable'));
    expect(payload.bodyText, contains('will not silently fall back'));
    expect(payload.bodyText, contains('Messages and search remain usable'));
  });
}

final _internalLocation = AttachmentArchiveLocationState.defaultAvailable(
  archiveRootPath: '/internal/attachment_archive',
);

final _activeConfiguration =
    AttachmentArchiveLocationConfiguration.customExternal(
      bookmarkDataBase64: 'AQID',
      lastKnownPath: '/Volumes/Test/MessageLens Attachment Archive op',
      volumeName: 'Test',
      customWritePolicy: AttachmentArchiveCustomWritePolicy.activeArchive,
    );

AttachmentArchiveRelocationProgress _progress({
  required AttachmentArchiveRelocationStage stage,
  AttachmentArchiveRelocationDeferredReason? deferredReason,
  AttachmentArchiveRelocationStage? resumeStage,
  bool activationOccurred = false,
  bool sourceRetained = false,
}) {
  return AttachmentArchiveRelocationProgress(
    operationId: 'op',
    stage: stage,
    sourceRootPath: '/internal/attachment_archive',
    destinationParentPath: '/Volumes/Test',
    destinationVolumeName: 'Test',
    destinationArchiveDirectoryName: 'MessageLens Attachment Archive op',
    createdAtUtc: DateTime.utc(2026, 9, 17),
    updatedAtUtc: DateTime.utc(2026, 9, 17, 1),
    filesCopied: 2,
    filesVerified: 1,
    bytesCopied: 2048,
    bytesVerified: 1024,
    expectedFiles: 4,
    expectedBytes: 4096,
    availableCapacityBytes: 8192,
    requiredCapacityBytes: 5120,
    deferredReason: deferredReason,
    failure: null,
    resumeStage: resumeStage,
    isResumable: !stage.isTerminal,
    activationOccurred: activationOccurred,
    sourceRetained: sourceRetained,
  );
}
