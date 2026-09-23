import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/onboarding/domain/onboarding_environment_report.dart';
import '../../../../../essentials/onboarding/domain/onboarding_journey_state.dart';
import '../../../../../essentials/onboarding/feature_level_providers.dart'
    show onboardingJourneyCoordinatorProvider;
import '../../../domain/entities/environment_readiness_surface_view_model.dart';

part 'environment_readiness_surface_provider.g.dart';

@riverpod
EnvironmentReadinessSurfaceViewModel environmentReadinessSurface(Ref ref) {
  final journey = ref.watch(onboardingJourneyCoordinatorProvider);
  return switch (journey) {
    OnboardingCheckingPrerequisites() => _checkingSurface(),
    OnboardingNeedsMessagesAccess(:final evidence) => _surfaceForReport(
      evidence!.report,
    ),
    OnboardingNeedsLocalHistoryConfirmation(:final evidence) =>
      _sparseMessagesSurface(
        evidence!.report,
        _evidenceFor(evidence.report),
        allowAcceptance: true,
      ),
    OnboardingNeedsContactsAccess(:final evidence) => _sourceBlockedSurface(
      evidence!.report,
      _evidenceFor(evidence.report),
    ),
    OnboardingReadyToImport(:final evidence) => _readySurface(
      evidence!.report,
      _evidenceFor(evidence.report),
    ),
    OnboardingOperationFailed(:final summary, :final evidence) =>
      evidence == null
          ? _failedSurface(summary)
          : _retrySurface(evidence.report, _evidenceFor(evidence.report)),
    OnboardingNormalApplication(:final evidence) when evidence != null =>
      _completedInstallationSurface(_evidenceFor(evidence.report)),
    _ => _checkingSurface(),
  };
}

EnvironmentReadinessSurfaceViewModel _checkingSurface() {
  return const EnvironmentReadinessSurfaceViewModel(
    kind: EnvironmentReadinessEpisodeKind.checking,
    title: 'Checking what MessageLens needs',
    body:
        'I’m checking the local permissions and data sources needed to prepare your Messages history.',
    tone: EnvironmentReadinessTone.primary,
    actions: <EnvironmentReadinessAction>[],
    evidence: <EnvironmentReadinessEvidence>[],
  );
}

EnvironmentReadinessSurfaceViewModel _failedSurface(Object error) {
  return EnvironmentReadinessSurfaceViewModel(
    kind: EnvironmentReadinessEpisodeKind.failed,
    title: 'MessageLens couldn’t check readiness',
    body:
        'The readiness inspection did not finish. Nothing has been imported, and you can try the check again.',
    tone: EnvironmentReadinessTone.failure,
    actions: const <EnvironmentReadinessAction>[
      EnvironmentReadinessAction(
        kind: EnvironmentReadinessActionKind.recheck,
        label: 'Try Again',
      ),
    ],
    evidence: <EnvironmentReadinessEvidence>[
      EnvironmentReadinessEvidence(
        label: 'Readiness inspection',
        value: 'Failed: $error',
      ),
    ],
  );
}

EnvironmentReadinessSurfaceViewModel _surfaceForReport(
  OnboardingEnvironmentReport report,
) {
  final evidence = _evidenceFor(report);
  if (_isMessagesInspectionFailure(report)) {
    return EnvironmentReadinessSurfaceViewModel(
      kind: EnvironmentReadinessEpisodeKind.failed,
      title: 'MessageLens couldn’t check the Messages database',
      body:
          'The local Messages database is present, but this readiness check could not read it reliably.',
      tone: EnvironmentReadinessTone.failure,
      actions: const <EnvironmentReadinessAction>[
        EnvironmentReadinessAction(
          kind: EnvironmentReadinessActionKind.recheck,
          label: 'Try Again',
        ),
        EnvironmentReadinessAction(
          kind: EnvironmentReadinessActionKind.sendReport,
          label: 'Send Report To Developer',
        ),
      ],
      evidence: evidence,
    );
  }

  return switch (report.state) {
    OnboardingEnvironmentState.maintenanceInProgress =>
      EnvironmentReadinessSurfaceViewModel(
        kind: EnvironmentReadinessEpisodeKind.checking,
        title: 'Preparing MessageLens',
        body:
            'Message data maintenance is in progress. I’ll continue when the current operation finishes.',
        tone: EnvironmentReadinessTone.primary,
        actions: const <EnvironmentReadinessAction>[],
        evidence: evidence,
      ),
    OnboardingEnvironmentState.permissionBlocked => _fdaBlockedSurface(
      evidence,
    ),
    OnboardingEnvironmentState.sourceUnavailable => _sourceBlockedSurface(
      report,
      evidence,
    ),
    OnboardingEnvironmentState.sourceSparseOrUnsynced => _sparseMessagesSurface(
      report,
      evidence,
    ),
    OnboardingEnvironmentState.importFailed ||
    OnboardingEnvironmentState.graphProjectionFailed => _retrySurface(
      report,
      evidence,
    ),
    OnboardingEnvironmentState.readyToImport => _readySurface(report, evidence),
    OnboardingEnvironmentState.ready => _completedInstallationSurface(evidence),
  };
}

EnvironmentReadinessSurfaceViewModel _fdaBlockedSurface(
  List<EnvironmentReadinessEvidence> evidence,
) {
  return EnvironmentReadinessSurfaceViewModel(
    kind: EnvironmentReadinessEpisodeKind.blocked,
    title: 'MessageLens needs Full Disk Access',
    body:
        'macOS protects the local Messages and Contacts databases. Grant access in System Settings, then relaunch MessageLens when macOS asks.',
    tone: EnvironmentReadinessTone.warning,
    instructions: const <String>[
      'Open Full Disk Access in System Settings.',
      'Add or enable MessageLens.',
      'Quit and reopen MessageLens when macOS asks.',
    ],
    actions: const <EnvironmentReadinessAction>[
      EnvironmentReadinessAction(
        kind: EnvironmentReadinessActionKind.openSettings,
        label: 'Open System Settings',
      ),
      EnvironmentReadinessAction(
        kind: EnvironmentReadinessActionKind.recheck,
        label: 'Re-check',
      ),
    ],
    evidence: evidence,
  );
}

EnvironmentReadinessSurfaceViewModel _sourceBlockedSurface(
  OnboardingEnvironmentReport report,
  List<EnvironmentReadinessEvidence> evidence,
) {
  if (report.blockerKind == OnboardingBlockerKind.addressBookUnavailable) {
    return EnvironmentReadinessSurfaceViewModel(
      kind: EnvironmentReadinessEpisodeKind.blocked,
      title: 'MessageLens needs local Contacts data',
      body:
          'The current import pipeline uses local Contacts data to prepare names and relationship context. MessageLens could not read that local data. Check that Contacts data is available on this Mac, then check again.',
      tone: EnvironmentReadinessTone.warning,
      actions: const <EnvironmentReadinessAction>[
        EnvironmentReadinessAction(
          kind: EnvironmentReadinessActionKind.recheck,
          label: 'Re-check',
        ),
      ],
      evidence: evidence,
    );
  }

  return EnvironmentReadinessSurfaceViewModel(
    kind: EnvironmentReadinessEpisodeKind.blocked,
    title: 'MessageLens can’t find local Messages data',
    body:
        'MessageLens imports the Messages history stored on this Mac. Open Messages and confirm that the history you expect is available locally, then check again.',
    tone: EnvironmentReadinessTone.warning,
    actions: const <EnvironmentReadinessAction>[
      EnvironmentReadinessAction(
        kind: EnvironmentReadinessActionKind.recheck,
        label: 'Re-check',
      ),
    ],
    evidence: evidence,
  );
}

EnvironmentReadinessSurfaceViewModel _sparseMessagesSurface(
  OnboardingEnvironmentReport report,
  List<EnvironmentReadinessEvidence> evidence, {
  bool allowAcceptance = false,
}) {
  return EnvironmentReadinessSurfaceViewModel(
    kind: EnvironmentReadinessEpisodeKind.blocked,
    title: 'Your local Messages history looks incomplete',
    body:
        'MessageLens imports only the history stored on this Mac. If messages you expect are missing here, make sure Messages in iCloud is enabled and has finished syncing on your devices before continuing.',
    sanityEvidence: _messageCountEvidence(report),
    tone: EnvironmentReadinessTone.warning,
    actions: <EnvironmentReadinessAction>[
      if (allowAcceptance)
        const EnvironmentReadinessAction(
          kind: EnvironmentReadinessActionKind.acceptLocalHistory,
          label: 'Use This Local History',
        ),
      const EnvironmentReadinessAction(
        kind: EnvironmentReadinessActionKind.recheck,
        label: 'Re-check',
      ),
    ],
    evidence: evidence,
  );
}

EnvironmentReadinessSurfaceViewModel _retrySurface(
  OnboardingEnvironmentReport report,
  List<EnvironmentReadinessEvidence> evidence,
) {
  final graphFailed =
      report.state == OnboardingEnvironmentState.graphProjectionFailed;
  return EnvironmentReadinessSurfaceViewModel(
    kind: EnvironmentReadinessEpisodeKind.failed,
    title: 'Setup needs another try',
    body: graphFailed
        ? 'MessageLens imported local data, but could not finish preparing it for browsing.'
        : 'MessageLens could not finish making its local copy of your Messages history.',
    tone: EnvironmentReadinessTone.failure,
    actions: <EnvironmentReadinessAction>[
      EnvironmentReadinessAction(
        kind: EnvironmentReadinessActionKind.startImport,
        label: graphFailed
            ? 'Retry Import and Graph Build'
            : 'Try Import Again',
      ),
      const EnvironmentReadinessAction(
        kind: EnvironmentReadinessActionKind.sendReport,
        label: 'Send Report To Developer',
      ),
    ],
    evidence: evidence,
  );
}

EnvironmentReadinessSurfaceViewModel _readySurface(
  OnboardingEnvironmentReport report,
  List<EnvironmentReadinessEvidence> evidence,
) {
  return EnvironmentReadinessSurfaceViewModel(
    kind: EnvironmentReadinessEpisodeKind.ready,
    title: 'Everything is ready',
    body:
        'MessageLens can read the Messages and Contacts available on this Mac. I’m ready to make a local copy for browsing.',
    sanityEvidence: _messageCountEvidence(report),
    tone: EnvironmentReadinessTone.success,
    actions: const <EnvironmentReadinessAction>[
      EnvironmentReadinessAction(
        kind: EnvironmentReadinessActionKind.startImport,
        label: 'Import My Messages',
      ),
    ],
    evidence: evidence,
  );
}

EnvironmentReadinessSurfaceViewModel _completedInstallationSurface(
  List<EnvironmentReadinessEvidence> evidence,
) {
  return EnvironmentReadinessSurfaceViewModel(
    kind: EnvironmentReadinessEpisodeKind.ready,
    title: 'MessageLens is ready',
    body:
        'The required local sources are available, and MessageLens browsing data is prepared.',
    tone: EnvironmentReadinessTone.success,
    actions: const <EnvironmentReadinessAction>[],
    evidence: evidence,
  );
}

bool _isMessagesInspectionFailure(OnboardingEnvironmentReport report) {
  return report.hasFullDiskAccess &&
      report.messagesDatabase.exists &&
      !report.messagesDatabase.readable &&
      report.messagesDatabase.failureMessage != null;
}

String? _messageCountEvidence(OnboardingEnvironmentReport report) {
  final count = report.messagesDatabase.rowCount;
  if (count == null) {
    return null;
  }
  return 'I found ${_formatCount(count)} messages stored on this Mac.';
}

String _formatCount(int count) {
  final digits = count.toString();
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(digits[index]);
  }
  return buffer.toString();
}

List<EnvironmentReadinessEvidence> _evidenceFor(
  OnboardingEnvironmentReport report,
) {
  final messageCount = report.messagesDatabase.rowCount;
  return <EnvironmentReadinessEvidence>[
    EnvironmentReadinessEvidence(
      label: 'Full Disk Access',
      value: report.hasFullDiskAccess ? 'Available' : 'Required',
    ),
    EnvironmentReadinessEvidence(
      label: 'Messages database',
      value: report.messagesDatabase.readable
          ? messageCount == null
                ? 'Available'
                : 'Available (${_formatCount(messageCount)} messages)'
          : report.messagesDatabase.exists
          ? 'Present but unreadable'
          : 'Not found',
    ),
    EnvironmentReadinessEvidence(
      label: 'Contacts database',
      value: report.addressBookDatabase?.readable == true
          ? 'Available'
          : report.addressBookDatabase == null
          ? 'Not found'
          : 'Present but unreadable',
    ),
    EnvironmentReadinessEvidence(
      label: 'Import storage',
      value: report.sourceScopedImportDatabase.hasData
          ? 'Prepared'
          : report.sourceScopedImportDatabase.exists
          ? 'Ready'
          : 'Will be prepared during import',
    ),
    EnvironmentReadinessEvidence(
      label: 'Conversation browsing data',
      value: report.conversationGraph.hasData
          ? 'Prepared'
          : report.conversationGraph.exists
          ? 'Ready'
          : 'Will be prepared during import',
    ),
    EnvironmentReadinessEvidence(
      label: 'Attachment archive',
      value: switch (report.attachmentArchiveStatus) {
        OnboardingAttachmentArchiveStatus.available =>
          report.attachmentArchiveDirectory.readable
              ? 'Available'
              : report.attachmentArchiveDirectory.exists
              ? 'Present but unreadable'
              : 'Not created yet',
        OnboardingAttachmentArchiveStatus.readOnly => 'Available (read-only)',
        OnboardingAttachmentArchiveStatus.unavailable =>
          'External archive unavailable',
      },
    ),
  ];
}
