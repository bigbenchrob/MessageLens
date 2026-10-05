import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../config/theme/colors/theme_colors.dart';
import '../../../config/theme/spacing/app_spacing.dart';
import '../../../config/theme/theme_typography.dart';
import '../../../core/util/count_label_formatter.dart';
import '../../conversation_graph/application/conversation_graph_build_observation.dart';
import '../application/app_czar_operating_currentness_controller.dart';
import '../application/app_czar_operating_session_controller.dart';
import '../domain/app_czar_operating_currentness_models.dart';
import '../domain/app_czar_operating_session_state.dart';

/// Owns the presentation lifetime of one admitted Operating currentness
/// occurrence.
///
/// This is intentionally the only presentation watcher for the currentness
/// controller. It starts the service after the workspace's first frame and
/// keeps the ordinary workspace mounted while factual progress is shown.
class AppCzarOperatingCurrentnessStatusHost extends ConsumerStatefulWidget {
  const AppCzarOperatingCurrentnessStatusHost({super.key});

  static const statusKey = Key('app-czar-operating-currentness-status');
  static const issueKey = Key('app-czar-operating-currentness-issue');

  @override
  ConsumerState<AppCzarOperatingCurrentnessStatusHost> createState() =>
      _AppCzarOperatingCurrentnessStatusHostState();
}

class _AppCzarOperatingCurrentnessStatusHostState
    extends ConsumerState<AppCzarOperatingCurrentnessStatusHost> {
  AppCzarOperatingSessionOccurrence? _startScheduledFor;
  AppCzarOperatingSessionOccurrence? _startedOccurrence;
  AppCzarOperatingSessionOccurrence? _restartScheduledFor;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(appCzarOperatingSessionControllerProvider);
    final occurrence = session.ownsOperatingShell ? session.occurrence : null;
    if (occurrence == null) {
      return const SizedBox.shrink();
    }

    final currentness = ref.watch(
      appCzarOperatingCurrentnessControllerProvider(occurrence),
    );
    if (session.isAdmitted) {
      _scheduleStartAfterShellFrame(occurrence);
    }
    if (currentness.requiresRestartPresentation) {
      _scheduleRestartAfterIssueFrame(occurrence);
    }

    if (!currentness.hasVisibleStatus) {
      return const SizedBox.shrink();
    }

    return _AppCzarOperatingCurrentnessStatus(state: currentness);
  }

  void _scheduleStartAfterShellFrame(
    AppCzarOperatingSessionOccurrence occurrence,
  ) {
    if (_startedOccurrence == occurrence || _startScheduledFor == occurrence) {
      return;
    }
    _startScheduledFor = occurrence;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final session = ref.read(appCzarOperatingSessionControllerProvider);
      if (!session.isAdmitted || session.occurrence != occurrence) {
        if (_startScheduledFor == occurrence) {
          _startScheduledFor = null;
        }
        return;
      }
      _startScheduledFor = null;
      _startedOccurrence = occurrence;
      ref
          .read(
            appCzarOperatingCurrentnessControllerProvider(occurrence).notifier,
          )
          .start();
    });
  }

  void _scheduleRestartAfterIssueFrame(
    AppCzarOperatingSessionOccurrence occurrence,
  ) {
    if (_restartScheduledFor == occurrence) {
      return;
    }
    _restartScheduledFor = occurrence;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      // The issue-bearing frame must finish before restart admission. Schedule
      // the restart at the end of a subsequent frame so the issue cannot be
      // replaced by `restarting` during the frame that first presents it.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        unawaited(_restartAfterPresentedIssue(occurrence));
      });
      WidgetsBinding.instance.scheduleFrame();
    });
  }

  Future<void> _restartAfterPresentedIssue(
    AppCzarOperatingSessionOccurrence occurrence,
  ) async {
    final session = ref.read(appCzarOperatingSessionControllerProvider);
    if (!session.isAdmitted || session.occurrence != occurrence) {
      if (_restartScheduledFor == occurrence) {
        _restartScheduledFor = null;
      }
      return;
    }
    final currentness = ref.read(
      appCzarOperatingCurrentnessControllerProvider(occurrence),
    );
    if (!currentness.requiresRestartPresentation) {
      if (_restartScheduledFor == occurrence) {
        _restartScheduledFor = null;
      }
      return;
    }
    await ref
        .read(
          appCzarOperatingCurrentnessControllerProvider(occurrence).notifier,
        )
        .restartAfterIssuePresented();
  }
}

class _AppCzarOperatingCurrentnessStatus extends ConsumerWidget {
  const _AppCzarOperatingCurrentnessStatus({required this.state});

  final AppCzarOperatingCurrentnessState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final content = _statusContent(state);
    final isIssue = state.phase == AppCzarOperatingCurrentnessPhase.issue;

    return Positioned(
      top: AppSpacing.md,
      right: AppSpacing.md,
      child: IgnorePointer(
        child: Semantics(
          container: true,
          liveRegion: true,
          label: [
            content.title,
            if (content.detail case final detail?) detail,
          ].join('. '),
          child: ExcludeSemantics(
            child: KeyedSubtree(
              key: AppCzarOperatingCurrentnessStatusHost.statusKey,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: DecoratedBox(
                  key: isIssue
                      ? AppCzarOperatingCurrentnessStatusHost.issueKey
                      : null,
                  decoration: BoxDecoration(
                    color: colors.surfaces.surfaceRaised,
                    border: Border.all(
                      color: isIssue
                          ? colors.status.error
                          : colors.lines.border,
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _StatusIndicator(phase: state.phase),
                        const SizedBox(width: AppSpacing.md),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                content.title,
                                style: typography.headline.copyWith(
                                  color: isIssue
                                      ? colors.status.error
                                      : colors.content.textPrimary,
                                ),
                              ),
                              if (content.detail case final detail?) ...[
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  detail,
                                  maxLines: isIssue ? 3 : 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: typography.caption1.copyWith(
                                    color: colors.content.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusIndicator extends ConsumerWidget {
  const _StatusIndicator({required this.phase});

  final AppCzarOperatingCurrentnessPhase phase;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    return switch (phase) {
      AppCzarOperatingCurrentnessPhase.idle => MacosIcon(
        CupertinoIcons.info_circle_fill,
        size: AppSpacing.lg,
        color: colors.accents.primary,
      ),
      AppCzarOperatingCurrentnessPhase.issue => MacosIcon(
        CupertinoIcons.exclamationmark_triangle_fill,
        size: AppSpacing.lg,
        color: colors.status.error,
      ),
      AppCzarOperatingCurrentnessPhase.restarting => MacosIcon(
        CupertinoIcons.arrow_clockwise,
        size: AppSpacing.lg,
        color: colors.accents.primary,
      ),
      _ => const Padding(
        padding: EdgeInsets.all(AppSpacing.xs),
        child: ProgressCircle(radius: AppSpacing.sm),
      ),
    };
  }
}

final class _StatusContent {
  const _StatusContent(this.title, [this.detail]);

  final String title;
  final String? detail;
}

_StatusContent _statusContent(AppCzarOperatingCurrentnessState state) {
  return switch (state.phase) {
    AppCzarOperatingCurrentnessPhase.idle => _StatusContent(
      'Attachment archive',
      '${CountLabelFormatter.formatCount(state.attachmentDebtCount!)} required payloads are not preserved. '
          'None are currently available from Messages.',
    ),
    AppCzarOperatingCurrentnessPhase.stopped => const _StatusContent(''),
    AppCzarOperatingCurrentnessPhase.updating => _StatusContent(
      _progressLabel(state),
      _graphStageLabel(state.suboperation),
    ),
    AppCzarOperatingCurrentnessPhase.preservingAttachments =>
      const _StatusContent('Preserving attachments…'),
    AppCzarOperatingCurrentnessPhase.verifyingCoverage => _StatusContent(
      'Verifying attachment coverage…',
      _attachmentResultLabel(state),
    ),
    AppCzarOperatingCurrentnessPhase.issue => _StatusContent(
      'Update could not be completed',
      state.issue,
    ),
    AppCzarOperatingCurrentnessPhase.restarting => const _StatusContent(
      'Restarting MessageLens…',
    ),
  };
}

String _progressLabel(AppCzarOperatingCurrentnessState state) {
  final completed = state.completedWorkCount;
  final total = state.totalWorkCount;
  if (completed == null || total == null) {
    return 'Updating MessageLens…';
  }
  return 'Updating MessageLens — $completed / $total';
}

String? _attachmentResultLabel(AppCzarOperatingCurrentnessState state) {
  final examined = state.attachmentsExamined;
  final preserved = state.attachmentsPreserved;
  final skipped = state.attachmentsSkipped;
  final failed = state.attachmentsFailed;
  if (examined == null ||
      preserved == null ||
      skipped == null ||
      failed == null) {
    return null;
  }
  return '$examined examined · $preserved preserved · '
      '$skipped skipped · $failed failed';
}

String _graphStageLabel(ConversationGraphBuildSuboperation? suboperation) {
  return switch (suboperation) {
    null => 'Preparing the supported incremental update',
    ConversationGraphBuildSuboperation.importChats => 'Importing conversations',
    ConversationGraphBuildSuboperation.importHandles => 'Importing handles',
    ConversationGraphBuildSuboperation.importContacts => 'Importing contacts',
    ConversationGraphBuildSuboperation.importContactEmailChannels =>
      'Importing contact email channels',
    ConversationGraphBuildSuboperation.importContactPhoneChannels =>
      'Importing contact phone channels',
    ConversationGraphBuildSuboperation.importMessages => 'Importing messages',
    ConversationGraphBuildSuboperation.extractRichText =>
      'Reading message formatting',
    ConversationGraphBuildSuboperation.persistRichText =>
      'Saving message formatting',
    ConversationGraphBuildSuboperation.importAttachments =>
      'Importing attachment facts',
    ConversationGraphBuildSuboperation.importChatMessageRelationships =>
      'Linking messages to conversations',
    ConversationGraphBuildSuboperation.importChatHandleRelationships =>
      'Linking handles to conversations',
    ConversationGraphBuildSuboperation.importMessageAttachmentRelationships =>
      'Linking attachments to messages',
    ConversationGraphBuildSuboperation.projectHandles => 'Updating handles',
    ConversationGraphBuildSuboperation.projectContacts => 'Updating contacts',
    ConversationGraphBuildSuboperation.projectChatHandleRelationships =>
      'Updating conversation participants',
    ConversationGraphBuildSuboperation.projectConversations =>
      'Updating conversation data',
    ConversationGraphBuildSuboperation.projectMessages =>
      'Updating message data',
    ConversationGraphBuildSuboperation.projectAttachments =>
      'Updating attachment data',
    ConversationGraphBuildSuboperation.projectChatMessageRelationships =>
      'Updating conversation-message links',
    ConversationGraphBuildSuboperation.projectMessageAttachmentRelationships =>
      'Updating message-attachment links',
  };
}
