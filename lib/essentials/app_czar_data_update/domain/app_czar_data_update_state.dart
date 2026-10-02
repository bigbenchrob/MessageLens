import 'package:meta/meta.dart';

import '../../conversation_graph/application/conversation_graph_build_observation.dart';

enum AppCzarDataUpdatePhase {
  dormant,
  preparing,
  updating,
  preservingAttachments,
  restartRequested,
  failed,
}

@immutable
final class AppCzarDataUpdateState {
  const AppCzarDataUpdateState({
    required this.phase,
    this.assessmentGeneration,
    this.sourceMessageCount,
    this.localMessageCount,
    this.messagesToImport,
    this.suboperation,
    this.completedWorkCount,
    this.totalWorkCount,
    this.attachmentsExamined,
    this.attachmentsPreserved,
    this.attachmentsSkipped,
    this.attachmentsFailed,
    this.failure,
  });

  const AppCzarDataUpdateState.dormant()
    : this(phase: AppCzarDataUpdatePhase.dormant);

  final AppCzarDataUpdatePhase phase;
  final int? assessmentGeneration;
  final int? sourceMessageCount;
  final int? localMessageCount;
  final int? messagesToImport;
  final ConversationGraphBuildSuboperation? suboperation;
  final int? completedWorkCount;
  final int? totalWorkCount;
  final int? attachmentsExamined;
  final int? attachmentsPreserved;
  final int? attachmentsSkipped;
  final int? attachmentsFailed;
  final String? failure;

  bool get isVisible => phase != AppCzarDataUpdatePhase.dormant;

  AppCzarDataUpdateState copyWith({
    AppCzarDataUpdatePhase? phase,
    int? sourceMessageCount,
    int? localMessageCount,
    int? messagesToImport,
    ConversationGraphBuildSuboperation? suboperation,
    int? completedWorkCount,
    int? totalWorkCount,
    int? attachmentsExamined,
    int? attachmentsPreserved,
    int? attachmentsSkipped,
    int? attachmentsFailed,
    String? failure,
    bool clearGraphProgress = false,
    bool clearFailure = false,
  }) {
    return AppCzarDataUpdateState(
      phase: phase ?? this.phase,
      assessmentGeneration: assessmentGeneration,
      sourceMessageCount: sourceMessageCount ?? this.sourceMessageCount,
      localMessageCount: localMessageCount ?? this.localMessageCount,
      messagesToImport: messagesToImport ?? this.messagesToImport,
      suboperation:
          suboperation ?? (clearGraphProgress ? null : this.suboperation),
      completedWorkCount: clearGraphProgress
          ? null
          : completedWorkCount ?? this.completedWorkCount,
      totalWorkCount: clearGraphProgress
          ? null
          : totalWorkCount ?? this.totalWorkCount,
      attachmentsExamined: attachmentsExamined ?? this.attachmentsExamined,
      attachmentsPreserved: attachmentsPreserved ?? this.attachmentsPreserved,
      attachmentsSkipped: attachmentsSkipped ?? this.attachmentsSkipped,
      attachmentsFailed: attachmentsFailed ?? this.attachmentsFailed,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }
}
