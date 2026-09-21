import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_adoption_workflow.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_adoption_workflow_provider.dart';
import 'package:remember_this_text/features/attachments/application/attachment_archive_location_provider.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_adoption.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_candidate_verification.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_configuration.dart';
import 'package:remember_this_text/features/attachments/domain/entities/attachment_archive_location_state.dart';
import 'package:remember_this_text/features/settings/presentation/view/attachment_archive_panel.dart';

void main() {
  group('AttachmentArchivePanel', () {
    testWidgets('initial state keeps paths and actions in the center pane', (
      tester,
    ) async {
      await _pump(
        tester,
        _state(AttachmentArchiveAdoptionWorkflowStage.currentArchive),
      );

      expect(find.text('Attachment Archive'), findsOneWidget);
      expect(find.text('CURRENT ARCHIVE'), findsOneWidget);
      expect(
        find.text('/Volumes/WD/MessageLens/attachment_archive'),
        findsOneWidget,
      );
      expect(
        find.byKey(AttachmentArchivePanel.chooseButtonKey),
        findsOneWidget,
      );
      expect(find.text('Internal'), findsNothing);
      expect(find.text('customExternal'), findsNothing);
    });

    testWidgets(
      'checking uses exact determinate file, byte, and percent totals',
      (tester) async {
        await _pump(
          tester,
          _state(
            AttachmentArchiveAdoptionWorkflowStage.checking,
            progress: const AttachmentArchiveVerificationProgress(
              phase: AttachmentArchiveVerificationPhase.sourceCoverage,
              filesChecked: 1847,
              bytesChecked: 1600000000,
              totalFiles: 4039,
              totalBytes: 3470000000,
            ),
          ),
        );

        expect(find.text('Checking archive copy…'), findsOneWidget);
        expect(find.text('1847 of 4039 files checked'), findsOneWidget);
        expect(find.textContaining('of 3.23 GB'), findsOneWidget);
        expect(find.textContaining('46%'), findsOneWidget);
        expect(find.byKey(AttachmentArchivePanel.progressKey), findsOneWidget);
      },
    );

    testWidgets(
      'verified-behind explains switch-first remediation beside copy',
      (tester) async {
        await _pump(
          tester,
          _state(
            AttachmentArchiveAdoptionWorkflowStage.candidateBehind,
            candidateIsAdoptable: true,
            missingCount: 3,
            missingBytes: 7200000,
          ),
        );

        expect(find.text('This copy is almost up to date'), findsOneWidget);
        expect(find.textContaining('3 new attachments'), findsOneWidget);
        expect(
          find.textContaining('all new attachments go there'),
          findsOneWidget,
        );
        expect(find.byKey(AttachmentArchivePanel.useButtonKey), findsOneWidget);
        expect(find.textContaining('manually'), findsNothing);
      },
    );

    testWidgets('invalid copy never exposes Use This Copy', (tester) async {
      await _pump(
        tester,
        _state(
          AttachmentArchiveAdoptionWorkflowStage.candidateInvalid,
          issue: 'Candidate content conflicts with the current archive.',
        ),
      );

      expect(find.text("This copy can't be used"), findsOneWidget);
      expect(find.byKey(AttachmentArchivePanel.useButtonKey), findsNothing);
      expect(find.text('Choose a Different Copy'), findsOneWidget);
    });

    testWidgets(
      'pending state says active archive did not revert and can resume',
      (tester) async {
        await _pump(
          tester,
          _state(
            AttachmentArchiveAdoptionWorkflowStage.remediationPending,
            missingCount: 3,
            missingBytes: 7200000,
            issue: 'The original volume is disconnected.',
          ),
        );

        expect(find.text('Attachment archive switched'), findsOneWidget);
        expect(
          find.textContaining('New attachments are being stored in'),
          findsOneWidget,
        );
        expect(find.textContaining('3 older attachments'), findsOneWidget);
        expect(
          find.byKey(AttachmentArchivePanel.resumeButtonKey),
          findsOneWidget,
        );
        expect(find.textContaining('reverted'), findsNothing);
      },
    );

    testWidgets(
      'remediation shows exact determinate attachment and byte totals',
      (tester) async {
        await _pump(
          tester,
          _state(
            AttachmentArchiveAdoptionWorkflowStage.remediating,
            missingCount: 5,
            missingBytes: 7200000,
            remediationProgress: const AttachmentArchiveRemediationProgress(
              filesCompleted: 2,
              totalFiles: 5,
              bytesCompleted: 5100000,
              totalBytes: 7200000,
            ),
          ),
        );

        expect(find.text('Adding missing attachments'), findsOneWidget);
        expect(find.textContaining('2 of 5 attachments'), findsOneWidget);
        expect(find.textContaining('of 6.87 MB'), findsOneWidget);
        expect(find.byKey(AttachmentArchivePanel.progressKey), findsOneWidget);
      },
    );

    testWidgets('success keeps both current and undeleted original visible', (
      tester,
    ) async {
      await _pump(
        tester,
        _state(AttachmentArchiveAdoptionWorkflowStage.success),
      );

      expect(find.text('Attachment archive switched'), findsOneWidget);
      expect(find.text('CURRENT ARCHIVE'), findsOneWidget);
      expect(find.text('ORIGINAL ARCHIVE'), findsOneWidget);
      expect(
        find.text('/Volumes/Toshiba/ML_ADOPTION_TEST/attachment_archive'),
        findsOneWidget,
      );
      expect(
        find.text('/Volumes/WD/MessageLens/attachment_archive'),
        findsOneWidget,
      );
      expect(find.textContaining('has not deleted'), findsOneWidget);
    });
  });
}

Future<void> _pump(
  WidgetTester tester,
  AttachmentArchiveAdoptionWorkflowState workflow,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        attachmentArchiveLocationProvider.overrideWith(
          () => _FixedLocation(_location),
        ),
        attachmentArchiveAdoptionWorkflowProvider.overrideWith(
          () => _FixedWorkflow(workflow),
        ),
      ],
      child: const CupertinoApp(home: AttachmentArchivePanel()),
    ),
  );
  await tester.pumpAndSettle();
}

final _configuration = AttachmentArchiveLocationConfiguration.customExternal(
  bookmarkDataBase64: 'AQID',
  lastKnownPath: '/Volumes/WD/MessageLens/attachment_archive',
  volumeName: 'WD',
  customWritePolicy: AttachmentArchiveCustomWritePolicy.activeArchive,
);

final _location = AttachmentArchiveLocationState.customAvailable(
  configuration: _configuration,
  archiveRootPath: '/Volumes/WD/MessageLens/attachment_archive',
  generation: 7,
);

AttachmentArchiveAdoptionWorkflowState _state(
  AttachmentArchiveAdoptionWorkflowStage stage, {
  AttachmentArchiveVerificationProgress? progress,
  bool candidateIsAdoptable = false,
  int? missingCount,
  int? missingBytes,
  String? issue,
  AttachmentArchiveRemediationProgress? remediationProgress,
}) {
  return AttachmentArchiveAdoptionWorkflowState(
    stage: stage,
    executionEnabled: true,
    sourcePath: '/Volumes/WD/MessageLens/attachment_archive',
    candidatePath: '/Volumes/Toshiba/ML_ADOPTION_TEST/attachment_archive',
    candidateVolumeName: 'Toshiba',
    candidateIsAdoptable: candidateIsAdoptable,
    progress: progress,
    missingCount: missingCount,
    missingBytes: missingBytes,
    issue: issue,
    remediationProgress: remediationProgress,
  );
}

final class _FixedLocation extends AttachmentArchiveLocation {
  _FixedLocation(this.value);

  final AttachmentArchiveLocationState value;

  @override
  Future<AttachmentArchiveLocationState> build() async => value;
}

final class _FixedWorkflow extends AttachmentArchiveAdoptionWorkflow {
  _FixedWorkflow(this.value);

  final AttachmentArchiveAdoptionWorkflowState value;

  @override
  AttachmentArchiveAdoptionWorkflowState build() => value;
}
