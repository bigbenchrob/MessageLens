import '../../../features/sidebar_utilities/domain/sidebar_utilities_constants.dart';

enum SidebarTopMenuChoice {
  conversations,
  contacts,
  strayHandles,
  searchAllMessages,
  recoveredUnlinkedMessages,
  recoveredNoHandleFromMeMessages,
}

enum SidebarMessageScope { regular, recoveredDeleted }

enum SidebarContactProjection { allMessages, conversations }

enum SidebarStrayHandleFilter { phones, emails, businessUrns }

enum SidebarStrayHandleInvestigation { identifySources, numericSenderIds }

enum SidebarStrayHandleReviewMode { active, dismissed }

enum SidebarActionTone { neutral, primary, destructive }

/// Typed semantic action intent transported through sidebar payload data.
///
/// LAW: Intents may describe meaning across the boundary, but they must not
/// execute behavior themselves.
sealed class SidebarActionIntent {
  const SidebarActionIntent();
}

sealed class SidebarPersistentIntent extends SidebarActionIntent {
  const SidebarPersistentIntent();
}

sealed class SidebarEphemeralIntent extends SidebarActionIntent {
  const SidebarEphemeralIntent();
}

/// Immutable action descriptor for render-edge wiring.
///
/// This type may carry copy, tone, iconography, and a typed intent only.
/// Callback fields, dispatcher objects, refs, and UI runtime state are not
/// allowed here.
final class SidebarActionDescriptor {
  const SidebarActionDescriptor({
    required this.label,
    required this.intent,
    this.tone = SidebarActionTone.neutral,
    this.icon,
    this.isEnabled = true,
  });

  final String label;
  final SidebarActionIntent intent;
  final SidebarActionTone tone;
  final String? icon;
  final bool isEnabled;
}

final class TopMenuChanged extends SidebarPersistentIntent {
  const TopMenuChanged({required this.choice});

  final SidebarTopMenuChoice choice;
}

final class SettingsPersistentContextChosen extends SidebarPersistentIntent {
  const SettingsPersistentContextChosen({required this.actionId});

  final SettingsMenuActionId actionId;
}

final class ContactChosen extends SidebarPersistentIntent {
  const ContactChosen({required this.contactId});

  final int contactId;
}

final class ChooseAnotherContact extends SidebarPersistentIntent {
  const ChooseAnotherContact();
}

final class ContactHandleSelected extends SidebarPersistentIntent {
  const ContactHandleSelected({
    required this.contactId,
    required this.handleId,
  });

  final int contactId;
  final int? handleId;
}

final class ContactMessageScopeChanged extends SidebarPersistentIntent {
  const ContactMessageScopeChanged({
    required this.contactId,
    required this.scope,
  });

  final int contactId;
  final SidebarMessageScope scope;
}

final class ContactProjectionChanged extends SidebarPersistentIntent {
  const ContactProjectionChanged({
    required this.contactId,
    required this.projection,
  });

  final int contactId;
  final SidebarContactProjection projection;
}

final class HeatMapMonthFocused extends SidebarPersistentIntent {
  const HeatMapMonthFocused({this.monthAnchor, this.contactId});

  final int? contactId;
  final DateTime? monthAnchor;
}

final class ConversationSelected extends SidebarPersistentIntent {
  const ConversationSelected({
    required this.conversationId,
    this.anchorMessageId,
    this.searchQuery,
  });

  final int conversationId;
  final int? anchorMessageId;
  final String? searchQuery;
}

final class ContactConversationSelected extends SidebarPersistentIntent {
  const ContactConversationSelected({
    required this.contactId,
    required this.conversationId,
    this.anchorMessageId,
    this.searchQuery,
  });

  final int contactId;
  final int conversationId;
  final int? anchorMessageId;
  final String? searchQuery;
}

final class RecoveredMonthFocused extends SidebarPersistentIntent {
  const RecoveredMonthFocused({
    required this.monthAnchor,
    this.contactId,
    this.onlyNoHandleFromMe = false,
  });

  final int? contactId;
  final DateTime monthAnchor;
  final bool onlyNoHandleFromMe;
}

final class RecoveredNoHandleFromMeOpened extends SidebarPersistentIntent {
  const RecoveredNoHandleFromMeOpened();
}

final class StrayHandleFilterChanged extends SidebarPersistentIntent {
  const StrayHandleFilterChanged({required this.filter});

  final SidebarStrayHandleFilter filter;
}

final class StrayHandleInvestigationChanged extends SidebarPersistentIntent {
  const StrayHandleInvestigationChanged({required this.investigation});

  final SidebarStrayHandleInvestigation investigation;
}

final class StrayHandleModeChanged extends SidebarPersistentIntent {
  const StrayHandleModeChanged({required this.mode});

  final SidebarStrayHandleReviewMode mode;
}

final class StrayHandleOpened extends SidebarPersistentIntent {
  const StrayHandleOpened({required this.handleId});

  final int handleId;
}

final class HandleMessagesOpened extends SidebarPersistentIntent {
  const HandleMessagesOpened({required this.handleId});

  final int handleId;
}

final class StrayHandleDismissed extends SidebarPersistentIntent {
  const StrayHandleDismissed({required this.normalizedHandle});

  final String normalizedHandle;
}

final class StrayHandleRestored extends SidebarPersistentIntent {
  const StrayHandleRestored({required this.normalizedHandle});

  final String normalizedHandle;
}

final class ShowSendLogsFlow extends SidebarEphemeralIntent {
  const ShowSendLogsFlow();
}

final class ShowResetMessageDataFlow extends SidebarEphemeralIntent {
  const ShowResetMessageDataFlow();
}

final class SendLogsRequested extends SidebarEphemeralIntent {
  const SendLogsRequested();
}

final class ExportMessageHistoryCoverageReportRequested
    extends SidebarEphemeralIntent {
  const ExportMessageHistoryCoverageReportRequested();
}

final class SettingsTransientActionCancelled extends SidebarEphemeralIntent {
  const SettingsTransientActionCancelled();
}

final class ResetMessageDataRequested extends SidebarEphemeralIntent {
  const ResetMessageDataRequested();
}
