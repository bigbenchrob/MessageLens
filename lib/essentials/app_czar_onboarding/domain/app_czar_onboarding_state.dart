import '../../app_czar/domain/app_czar_models.dart';
import '../../conversation_graph/application/conversation_graph_build_observation.dart';

enum AppCzarOnboardingPhase {
  dormant,
  checkingPrerequisites,
  sourceNeedsHuman,
  contactsNeedHuman,
  building,
  restarting,
  failed,
}

final class AppCzarOnboardingState {
  const AppCzarOnboardingState({
    required this.phase,
    this.assessmentGeneration,
    this.issue,
    this.sourceCondition,
    this.contactsCondition,
    this.suboperation,
    this.completedWorkCount,
    this.totalWorkCount,
  });

  const AppCzarOnboardingState.dormant()
    : this(phase: AppCzarOnboardingPhase.dormant);

  final AppCzarOnboardingPhase phase;
  final int? assessmentGeneration;
  final String? issue;
  final AppCzarSourceCondition? sourceCondition;
  final AppCzarContactsPrerequisiteCondition? contactsCondition;
  final ConversationGraphBuildSuboperation? suboperation;
  final int? completedWorkCount;
  final int? totalWorkCount;

  bool get isVisible => phase != AppCzarOnboardingPhase.dormant;
  bool get canCheckAgain =>
      phase == AppCzarOnboardingPhase.sourceNeedsHuman ||
      phase == AppCzarOnboardingPhase.contactsNeedHuman;
  bool get canOpenSystemSettings =>
      sourceCondition == AppCzarSourceCondition.accessDenied ||
      contactsCondition == AppCzarContactsPrerequisiteCondition.accessDenied;

  AppCzarOnboardingState copyWith({
    AppCzarOnboardingPhase? phase,
    String? issue,
    bool clearIssue = false,
    AppCzarSourceCondition? sourceCondition,
    AppCzarContactsPrerequisiteCondition? contactsCondition,
    bool clearPrerequisiteConditions = false,
    ConversationGraphBuildSuboperation? suboperation,
    int? completedWorkCount,
    int? totalWorkCount,
    bool clearProgress = false,
  }) {
    return AppCzarOnboardingState(
      phase: phase ?? this.phase,
      assessmentGeneration: assessmentGeneration,
      issue: clearIssue ? null : issue ?? this.issue,
      sourceCondition: clearPrerequisiteConditions
          ? null
          : sourceCondition ?? this.sourceCondition,
      contactsCondition: clearPrerequisiteConditions
          ? null
          : contactsCondition ?? this.contactsCondition,
      suboperation: clearProgress ? null : suboperation ?? this.suboperation,
      completedWorkCount: clearProgress
          ? null
          : completedWorkCount ?? this.completedWorkCount,
      totalWorkCount: clearProgress
          ? null
          : totalWorkCount ?? this.totalWorkCount,
    );
  }
}
