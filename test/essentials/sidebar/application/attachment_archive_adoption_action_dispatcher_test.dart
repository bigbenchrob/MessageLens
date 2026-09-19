import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/navigation/domain/sidebar_mode.dart';
import 'package:remember_this_text/essentials/sidebar/application/sidebar_action_dispatcher.dart';
import 'package:remember_this_text/essentials/sidebar/domain/sidebar_action_intent.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_adoption_workflow.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_adoption_workflow_provider.dart';

void main() {
  test(
    'typed archive intents dispatch only to the adoption workflow',
    () async {
      final container = ProviderContainer(
        overrides: [
          attachmentArchiveAdoptionWorkflowProvider.overrideWith(
            _RecordingAdoptionWorkflow.new,
          ),
        ],
      );
      addTearDown(container.dispose);
      final dispatcher = container.read(
        sidebarActionDispatcherProvider.notifier,
      );
      const context = SidebarActionDispatchContext(
        sidebarMode: SidebarMode.settings,
        cassetteIndex: 2,
      );

      for (final intent in <SidebarActionIntent>[
        const AttachmentArchiveUseExistingRequested(),
        const AttachmentArchiveChooseAnotherFolderRequested(),
        const AttachmentArchiveCheckAgainRequested(),
        const AttachmentArchiveUseCandidateRequested(),
        const AttachmentArchiveCancelCheckRequested(),
      ]) {
        await dispatcher.dispatch(intent: intent, context: context);
      }

      final workflow =
          container.read(attachmentArchiveAdoptionWorkflowProvider.notifier)
              as _RecordingAdoptionWorkflow;
      expect(workflow.calls, [
        'use-existing',
        'choose-another',
        'check-again',
        'use-candidate',
        'cancel-check',
      ]);
    },
  );
}

final class _RecordingAdoptionWorkflow
    extends AttachmentArchiveAdoptionWorkflow {
  final List<String> calls = [];

  @override
  AttachmentArchiveAdoptionWorkflowState build() {
    return const AttachmentArchiveAdoptionWorkflowState.currentArchive(
      executionEnabled: true,
    );
  }

  @override
  Future<void> chooseExistingArchive() async {
    calls.add('use-existing');
  }

  @override
  Future<void> chooseAnotherFolder() async {
    calls.add('choose-another');
  }

  @override
  Future<void> checkAgain() async {
    calls.add('check-again');
  }

  @override
  Future<void> useCandidate() async {
    calls.add('use-candidate');
  }

  @override
  Future<void> cancelCheck() async {
    calls.add('cancel-check');
  }
}
