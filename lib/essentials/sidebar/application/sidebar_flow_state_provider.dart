import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../features/contacts/domain/spec_classes/contacts_cassette_spec.dart';
import '../../../features/contacts/domain/spec_classes/contacts_info_cassette_spec.dart';
import '../../../features/conversations/domain/spec_classes/conversations_view_spec.dart';
import '../../../features/handles/domain/entities/stray_handle_investigation_id.dart';
import '../../../features/handles/domain/spec_classes/handles_cassette_spec.dart';
import '../../../features/messages/domain/spec_classes/messages_view_spec.dart';
import '../../../features/settings/domain/spec_classes/settings_view_spec.dart';
import '../../../features/sidebar_utilities/domain/sidebar_utilities_constants.dart';
import '../../../features/sidebar_utilities/domain/spec_classes/sidebar_utility_cassette_spec.dart';
import '../../logging/feature_level_providers.dart' show appLoggerProvider;
import '../../navigation/domain/entities/view_spec.dart';
import '../../navigation/domain/sidebar_mode.dart';
import '../domain/entities/cassette_spec.dart';
import 'cassette_rack_state_provider.dart';
import 'sidebar_flow_preference_store.dart';
import 'sidebar_flow_preference_store_provider.dart';

part 'sidebar_flow_state_provider.freezed.dart';
part 'sidebar_flow_state_provider.g.dart';

enum SidebarFlowMessageScope { regular, recoveredDeleted }

enum SidebarFlowContactProjection { allMessages, conversations }

enum SidebarFlowHandleEvidenceKind { lens, messages }

extension SidebarFlowMessageScopeStorage on SidebarFlowMessageScope {
  String get storageValue {
    return switch (this) {
      SidebarFlowMessageScope.regular => 'regular',
      SidebarFlowMessageScope.recoveredDeleted => 'recovered_deleted',
    };
  }

  static SidebarFlowMessageScope fromStorage(String? rawValue) {
    return switch (rawValue) {
      'recovered_deleted' => SidebarFlowMessageScope.recoveredDeleted,
      _ => SidebarFlowMessageScope.regular,
    };
  }
}

extension SidebarFlowContactProjectionStorage on SidebarFlowContactProjection {
  String get storageValue {
    return switch (this) {
      SidebarFlowContactProjection.allMessages => 'all_messages',
      SidebarFlowContactProjection.conversations => 'conversations',
    };
  }

  static SidebarFlowContactProjection fromStorage(String? rawValue) {
    return switch (rawValue) {
      'conversations' => SidebarFlowContactProjection.conversations,
      _ => SidebarFlowContactProjection.allMessages,
    };
  }
}

class SidebarContactContextPreference {
  const SidebarContactContextPreference({
    required this.contactId,
    required this.projection,
  });

  final int? contactId;
  final SidebarFlowContactProjection projection;

  String get storageValue {
    return '${contactId ?? 'none'}|${projection.storageValue}';
  }

  static SidebarContactContextPreference fromStorage(String? rawValue) {
    final parts = rawValue?.split('|') ?? const <String>[];
    final rawContactId = parts.isEmpty ? null : parts[0];
    return SidebarContactContextPreference(
      contactId: rawContactId == null || rawContactId == 'none'
          ? null
          : int.tryParse(rawContactId),
      projection: SidebarFlowContactProjectionStorage.fromStorage(
        parts.length < 2 ? null : parts[1],
      ),
    );
  }
}

const String sidebarContactContextOverlaySettingKey =
    sidebarContactContextPreferenceSettingKey;
const String sidebarFlowNavigationOverlaySettingKey =
    sidebarFlowNavigationPreferenceSettingKey;

@visibleForTesting
class SidebarFlowNavigationPreference {
  const SidebarFlowNavigationPreference._({required this.state});

  final SidebarFlowState state;

  String get storageValue {
    final restorableState = _restorableSidebarFlowState(state);
    return jsonEncode({
      'topMenuChoice': restorableState.topMenuChoice.id,
      'chosenContactId': restorableState.chosenContactId,
      'selectedHandleId': restorableState.selectedHandleId,
      'selectedConversationId': restorableState.selectedConversationId,
      'strayHandleInvestigation':
          restorableState.strayHandleInvestigation?.name,
      'messageScope': restorableState.messageScope.storageValue,
      'contactProjection': restorableState.contactProjection.storageValue,
    });
  }

  static SidebarFlowNavigationPreference fromState(SidebarFlowState state) {
    return SidebarFlowNavigationPreference._(
      state: _restorableSidebarFlowState(state),
    );
  }

  static SidebarFlowNavigationPreference? fromStorage(String? rawValue) {
    if (rawValue == null || rawValue.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is! Map<String, Object?>) {
        return null;
      }

      final state = SidebarFlowState(
        topMenuChoice: TopChatMenuChoice.fromId(
          decoded['topMenuChoice'] as String? ?? defaultTopChatMenuChoice.id,
        ),
        chosenContactId: decoded['chosenContactId'] as int?,
        selectedHandleId: decoded['selectedHandleId'] as int?,
        selectedConversationId: decoded['selectedConversationId'] as int?,
        strayHandleInvestigation: _strayHandleInvestigationFromStorage(
          decoded['strayHandleInvestigation'] as String?,
        ),
        messageScope: SidebarFlowMessageScopeStorage.fromStorage(
          decoded['messageScope'] as String?,
        ),
        contactProjection: SidebarFlowContactProjectionStorage.fromStorage(
          decoded['contactProjection'] as String?,
        ),
      );
      return SidebarFlowNavigationPreference._(
        state: _restorableSidebarFlowState(state),
      );
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    } on StateError {
      return null;
    }
  }
}

SidebarFlowState _restorableSidebarFlowState(SidebarFlowState state) {
  switch (state.topMenuChoice) {
    case TopChatMenuChoice.conversations:
      return SidebarFlowState(
        topMenuChoice: TopChatMenuChoice.conversations,
        selectedConversationId: state.selectedConversationId,
      );
    case TopChatMenuChoice.contacts:
      if (state.chosenContactId == null) {
        return const SidebarFlowState(
          topMenuChoice: TopChatMenuChoice.contacts,
        );
      }

      final isRecoveredScope =
          state.messageScope == SidebarFlowMessageScope.recoveredDeleted;
      return SidebarFlowState(
        topMenuChoice: TopChatMenuChoice.contacts,
        chosenContactId: state.chosenContactId,
        selectedHandleId: isRecoveredScope ? null : state.selectedHandleId,
        messageScope: state.messageScope,
        contactProjection: isRecoveredScope
            ? SidebarFlowContactProjection.allMessages
            : state.contactProjection,
      );
    case TopChatMenuChoice.strayHandles:
      return SidebarFlowState(
        topMenuChoice: TopChatMenuChoice.strayHandles,
        strayHandleInvestigation:
            state.strayHandleInvestigation ??
            StrayHandleInvestigation.identifySources,
        strayHandleInvestigationId: StrayHandleInvestigationId.initial,
      );
    case TopChatMenuChoice.searchAllMessages:
      return const SidebarFlowState(
        topMenuChoice: TopChatMenuChoice.searchAllMessages,
      );
    case TopChatMenuChoice.recoveredUnlinkedMessages:
      return const SidebarFlowState(
        topMenuChoice: TopChatMenuChoice.recoveredUnlinkedMessages,
        messageScope: SidebarFlowMessageScope.recoveredDeleted,
      );
    case TopChatMenuChoice.recoveredNoHandleFromMeMessages:
      return const SidebarFlowState(
        topMenuChoice: TopChatMenuChoice.recoveredNoHandleFromMeMessages,
      );
  }
}

StrayHandleInvestigation? _strayHandleInvestigationFromStorage(String? raw) {
  return switch (raw) {
    'identifySources' => StrayHandleInvestigation.identifySources,
    'numericSenderIds' => StrayHandleInvestigation.numericSenderIds,
    _ => null,
  };
}

@visibleForTesting
void debugAssertValidSidebarFlowState(SidebarFlowState state) {
  final persistentSettingsContext = state.persistentSettingsContext;
  if (persistentSettingsContext != null &&
      !persistentSettingsContext.isPersistentContext) {
    throw StateError(
      'SidebarFlowState.persistentSettingsContext cannot hold transient '
      'settings actions.',
    );
  }

  if (state.selectedConversationId == null &&
      (state.selectedConversationAnchorMessageId != null ||
          state.selectedConversationSearchQuery != null)) {
    throw StateError('Conversation anchors require a selected conversation.');
  }

  final handleEvidenceSelected =
      state.selectedHandleEvidenceId != null ||
      state.selectedHandleEvidenceKind != null ||
      state.selectedHandleEvidenceInvestigationId != null;
  if (handleEvidenceSelected &&
      (state.selectedHandleEvidenceId == null ||
          state.selectedHandleEvidenceKind == null ||
          state.selectedHandleEvidenceInvestigationId == null)) {
    throw StateError(
      'Handle evidence selection requires handle id, evidence kind, and '
      'originating investigation.',
    );
  }

  final hasStrayHandleInvestigation =
      state.strayHandleInvestigationId != null ||
      state.strayHandleInvestigation != null;
  if (state.topMenuChoice != TopChatMenuChoice.strayHandles &&
      (handleEvidenceSelected || hasStrayHandleInvestigation)) {
    throw StateError(
      'Handle investigation state belongs only to the stray handles branch.',
    );
  }

  if (state.topMenuChoice == TopChatMenuChoice.strayHandles &&
      (state.strayHandleInvestigationId == null ||
          state.strayHandleInvestigation == null)) {
    throw StateError(
      'Unknown Sources requires investigation identity and kind.',
    );
  }

  switch (state.topMenuChoice) {
    case TopChatMenuChoice.conversations:
      if (state.chosenContactId != null || state.selectedHandleId != null) {
        throw StateError(
          'Conversations branch cannot retain contact-specific selection '
          'state.',
        );
      }

      if (state.messageScope != SidebarFlowMessageScope.regular) {
        throw StateError(
          'Conversations branch must remain in regular message scope.',
        );
      }

      if (state.contactProjection != SidebarFlowContactProjection.allMessages) {
        throw StateError(
          'Conversations branch cannot retain contact projection state.',
        );
      }

    case TopChatMenuChoice.contacts:
      final contactConversationSelected =
          state.selectedConversationId != null &&
          state.chosenContactId != null &&
          state.messageScope == SidebarFlowMessageScope.regular &&
          state.contactProjection == SidebarFlowContactProjection.conversations;
      if (state.selectedConversationId != null &&
          !contactConversationSelected) {
        throw StateError(
          'Contacts branch can retain conversation selection only in '
          'conversation projection mode.',
        );
      }

      if (state.selectedHandleId != null && state.chosenContactId == null) {
        throw StateError(
          'SidebarFlowState.selectedHandleId requires a chosen contact on '
          'the contacts branch.',
        );
      }

      if (state.messageScope == SidebarFlowMessageScope.recoveredDeleted &&
          state.chosenContactId == null) {
        throw StateError(
          'Recovered contact scope requires a chosen contact on the contacts '
          'branch.',
        );
      }

      if (state.messageScope == SidebarFlowMessageScope.recoveredDeleted &&
          state.selectedHandleId != null) {
        throw StateError(
          'Recovered contact scope cannot retain a selected handle filter.',
        );
      }

      if (state.messageScope == SidebarFlowMessageScope.recoveredDeleted &&
          state.contactProjection != SidebarFlowContactProjection.allMessages) {
        throw StateError(
          'Recovered contact scope cannot use conversation projection mode.',
        );
      }

      if (state.contactProjection ==
              SidebarFlowContactProjection.conversations &&
          state.selectedHandleId != null) {
        throw StateError(
          'Contact conversation projection cannot retain a selected handle '
          'filter.',
        );
      }

    case TopChatMenuChoice.strayHandles:
      if (state.strayHandleInvestigationId == null) {
        throw StateError(
          'Stray handles branch requires a current investigation identity.',
        );
      }

      if (state.chosenContactId != null ||
          state.selectedHandleId != null ||
          state.selectedConversationId != null) {
        throw StateError(
          'Stray handles branch cannot retain contact-specific selection '
          'state.',
        );
      }

      if (state.messageScope != SidebarFlowMessageScope.regular) {
        throw StateError(
          'Stray handles branch must remain in regular message scope.',
        );
      }

      if (state.contactProjection != SidebarFlowContactProjection.allMessages) {
        throw StateError(
          'Stray handles branch cannot retain contact projection state.',
        );
      }

    case TopChatMenuChoice.searchAllMessages:
      if (state.chosenContactId != null ||
          state.selectedHandleId != null ||
          state.selectedConversationId != null) {
        throw StateError(
          'Global timeline branch cannot retain contact-specific selection '
          'state.',
        );
      }

      if (state.messageScope != SidebarFlowMessageScope.regular) {
        throw StateError(
          'Global timeline branch must remain in regular message scope.',
        );
      }

      if (state.contactProjection != SidebarFlowContactProjection.allMessages) {
        throw StateError(
          'Global timeline branch cannot retain contact projection state.',
        );
      }

    case TopChatMenuChoice.recoveredUnlinkedMessages:
      if (state.chosenContactId != null ||
          state.selectedHandleId != null ||
          state.selectedConversationId != null) {
        throw StateError(
          'Global recovered branch cannot retain contact-specific selection '
          'state.',
        );
      }

      if (state.messageScope != SidebarFlowMessageScope.recoveredDeleted) {
        throw StateError(
          'Global recovered branch must remain in recoveredDeleted scope.',
        );
      }

      if (state.contactProjection != SidebarFlowContactProjection.allMessages) {
        throw StateError(
          'Global recovered branch cannot retain contact projection state.',
        );
      }

    case TopChatMenuChoice.recoveredNoHandleFromMeMessages:
      if (state.chosenContactId != null ||
          state.selectedHandleId != null ||
          state.selectedConversationId != null) {
        throw StateError(
          'Recovered no-handle branch cannot retain contact-specific '
          'selection state.',
        );
      }

      if (state.messageScope != SidebarFlowMessageScope.regular) {
        throw StateError(
          'Recovered no-handle branch must remain in regular message scope.',
        );
      }

      if (state.contactProjection != SidebarFlowContactProjection.allMessages) {
        throw StateError(
          'Recovered no-handle branch cannot retain contact projection state.',
        );
      }
  }
}

@freezed
abstract class SidebarFlowState with _$SidebarFlowState {
  const factory SidebarFlowState({
    @Default(defaultTopChatMenuChoice) TopChatMenuChoice topMenuChoice,
    int? chosenContactId,
    int? selectedHandleId,
    int? selectedConversationId,
    int? selectedConversationAnchorMessageId,
    String? selectedConversationSearchQuery,
    int? selectedHandleEvidenceId,
    SidebarFlowHandleEvidenceKind? selectedHandleEvidenceKind,
    StrayHandleInvestigationId? selectedHandleEvidenceInvestigationId,
    StrayHandleInvestigationId? strayHandleInvestigationId,
    StrayHandleInvestigation? strayHandleInvestigation,
    SettingsMenuActionId? persistentSettingsContext,
    DateTime? scrollToDate,
    @Default(SidebarFlowMessageScope.regular)
    SidebarFlowMessageScope messageScope,
    @Default(SidebarFlowContactProjection.allMessages)
    SidebarFlowContactProjection contactProjection,
  }) = _SidebarFlowState;

  const SidebarFlowState._();

  bool get isContactsBranch {
    return topMenuChoice == TopChatMenuChoice.contacts;
  }

  bool get hasCompatibleSelectedHandleEvidence {
    final currentInvestigationId = strayHandleInvestigationId;
    final originatingInvestigationId = selectedHandleEvidenceInvestigationId;
    return topMenuChoice == TopChatMenuChoice.strayHandles &&
        currentInvestigationId != null &&
        originatingInvestigationId != null &&
        currentInvestigationId == originatingInvestigationId;
  }

  int? get effectiveSelectedHandleEvidenceId {
    if (!hasCompatibleSelectedHandleEvidence) {
      return null;
    }
    return selectedHandleEvidenceId;
  }

  ViewSpec? get projectedCenterSpec {
    assert(() {
      debugAssertValidSidebarFlowState(this);
      return true;
    }());

    switch (topMenuChoice) {
      case TopChatMenuChoice.conversations:
        final conversationId = selectedConversationId;
        if (conversationId == null) {
          return null;
        }
        return ViewSpec.conversations(
          ConversationsSpec.conversationMessages(
            conversationId: conversationId,
            anchorMessageId: selectedConversationAnchorMessageId,
            searchQuery: selectedConversationSearchQuery,
          ),
        );
      case TopChatMenuChoice.contacts:
        final contactId = chosenContactId;
        if (contactId == null) {
          return null;
        }

        switch (messageScope) {
          case SidebarFlowMessageScope.regular:
            if (contactProjection ==
                SidebarFlowContactProjection.conversations) {
              final conversationId = selectedConversationId;
              if (conversationId != null) {
                return ViewSpec.conversations(
                  ConversationsSpec.conversationMessages(
                    conversationId: conversationId,
                    anchorMessageId: selectedConversationAnchorMessageId,
                    searchQuery: selectedConversationSearchQuery,
                  ),
                );
              }
              return null;
            }
            return ViewSpec.messages(
              MessagesSpec.forContact(
                contactId: contactId,
                scrollToDate: scrollToDate,
                filterHandleId: selectedHandleId,
              ),
            );
          case SidebarFlowMessageScope.recoveredDeleted:
            return ViewSpec.messages(
              MessagesSpec.recoveredUnlinkedMessages(
                contactId: contactId,
                scrollToDate: scrollToDate,
              ),
            );
        }
      case TopChatMenuChoice.strayHandles:
        final investigationId = strayHandleInvestigationId;
        final investigation = strayHandleInvestigation;
        if (investigationId == null || investigation == null) {
          throw StateError(
            'Unknown Sources cannot project without investigation identity '
            'and kind.',
          );
        }
        final handleEvidenceId = effectiveSelectedHandleEvidenceId;
        final handleEvidenceKind = selectedHandleEvidenceKind;
        if (handleEvidenceId == null || handleEvidenceKind == null) {
          return ViewSpec.messages(
            MessagesSpec.handleInvestigation(
              investigationId: investigationId,
              investigation: investigation,
              target: const HandleInvestigationTarget.idle(),
            ),
          );
        }
        return ViewSpec.messages(switch (handleEvidenceKind) {
          SidebarFlowHandleEvidenceKind.lens =>
            MessagesSpec.handleInvestigation(
              investigationId: investigationId,
              investigation: investigation,
              target: HandleInvestigationTarget.selectedSource(
                handleId: handleEvidenceId,
              ),
            ),
          SidebarFlowHandleEvidenceKind.messages => MessagesSpec.forHandle(
            handleId: handleEvidenceId,
          ),
        });
      case TopChatMenuChoice.searchAllMessages:
        return ViewSpec.messages(
          MessagesSpec.globalTimeline(scrollToDate: scrollToDate),
        );
      case TopChatMenuChoice.recoveredUnlinkedMessages:
        return ViewSpec.messages(
          MessagesSpec.recoveredUnlinkedMessages(scrollToDate: scrollToDate),
        );
      case TopChatMenuChoice.recoveredNoHandleFromMeMessages:
        return ViewSpec.messages(
          MessagesSpec.recoveredNoHandleFromMeMessages(
            scrollToDate: scrollToDate,
          ),
        );
    }
  }

  ViewSpec? get projectedSettingsCenterSpec {
    assert(() {
      debugAssertValidSidebarFlowState(this);
      return true;
    }());

    return switch (persistentSettingsContext) {
      SettingsMenuActionId.attachmentArchive => const ViewSpec.settings(
        SettingsViewSpec.attachmentArchiveWorkflow(),
      ),
      SettingsMenuActionId.historicalArchives => const ViewSpec.settings(
        SettingsViewSpec.historicalArchivesWorkflow(),
      ),
      SettingsMenuActionId.messageHistoryCoverage => const ViewSpec.settings(
        SettingsViewSpec.messageHistoryCoverageReport(),
      ),
      SettingsMenuActionId.textSize ||
      SettingsMenuActionId.imageSize ||
      SettingsMenuActionId.sendLogs ||
      SettingsMenuActionId.resetMessageData ||
      null => null,
    };
  }

  ViewSpec? projectedCenterSpecForMode(SidebarMode mode) {
    return switch (mode) {
      SidebarMode.messages => projectedCenterSpec,
      SidebarMode.settings => projectedSettingsCenterSpec,
    };
  }
}

@riverpod
class SidebarFlow extends _$SidebarFlow {
  Future<void> _contactContextPersistChain = Future<void>.value();
  Future<void> _navigationPreferencePersistChain = Future<void>.value();
  bool _restoreScheduled = false;
  bool _hasLocalMutation = false;
  bool _isDisposed = false;

  @override
  SidebarFlowState build() {
    ref.onDispose(() {
      _isDisposed = true;
    });
    _scheduleNavigationPreferenceRestore();
    const initialState = SidebarFlowState();
    assert(() {
      debugAssertValidSidebarFlowState(initialState);
      return true;
    }());
    return initialState;
  }

  void _setState(SidebarFlowState nextState, {bool persistNavigation = true}) {
    assert(() {
      debugAssertValidSidebarFlowState(nextState);
      return true;
    }());

    state = nextState;
    if (!persistNavigation) {
      return;
    }

    _hasLocalMutation = true;
    _scheduleNavigationPreferencePersist(
      SidebarFlowNavigationPreference.fromState(nextState),
    );
  }

  void topMenuChanged({
    required TopChatMenuChoice choice,
    required int cassetteIndex,
  }) {
    _setState(switch (choice) {
      TopChatMenuChoice.conversations => const SidebarFlowState(
        topMenuChoice: TopChatMenuChoice.conversations,
      ),
      TopChatMenuChoice.contacts => const SidebarFlowState(
        topMenuChoice: TopChatMenuChoice.contacts,
      ),
      TopChatMenuChoice.strayHandles => const SidebarFlowState(
        topMenuChoice: TopChatMenuChoice.strayHandles,
        strayHandleInvestigation: StrayHandleInvestigation.identifySources,
        strayHandleInvestigationId: StrayHandleInvestigationId.initial,
      ),
      TopChatMenuChoice.searchAllMessages => const SidebarFlowState(
        topMenuChoice: TopChatMenuChoice.searchAllMessages,
      ),
      TopChatMenuChoice.recoveredUnlinkedMessages => const SidebarFlowState(
        topMenuChoice: TopChatMenuChoice.recoveredUnlinkedMessages,
        messageScope: SidebarFlowMessageScope.recoveredDeleted,
      ),
      TopChatMenuChoice.recoveredNoHandleFromMeMessages =>
        const SidebarFlowState(
          topMenuChoice: TopChatMenuChoice.recoveredNoHandleFromMeMessages,
        ),
    });

    final newSpec = CassetteSpec.sidebarUtility(
      SidebarUtilityCassetteSpec.topChatMenu(selectedChoice: choice),
    );

    ref
        .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
        .replaceAtIndexAndCascade(cassetteIndex, newSpec);
  }

  Future<void> topMenuChangedRestoringContactContext({
    required TopChatMenuChoice choice,
    required int cassetteIndex,
  }) async {
    if (choice != TopChatMenuChoice.contacts) {
      topMenuChanged(choice: choice, cassetteIndex: cassetteIndex);
      return;
    }

    final persistedContext = await _readContactContextPreference();
    final contactId = persistedContext.contactId;
    if (contactId == null) {
      topMenuChanged(choice: choice, cassetteIndex: cassetteIndex);
      return;
    }

    _setState(
      SidebarFlowState(
        topMenuChoice: TopChatMenuChoice.contacts,
        chosenContactId: contactId,
        contactProjection: persistedContext.projection,
      ),
    );

    final topMenuSpec = CassetteSpec.sidebarUtility(
      SidebarUtilityCassetteSpec.topChatMenu(selectedChoice: choice),
    );
    ref
        .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
        .replaceAtIndexAndCascade(cassetteIndex, topMenuSpec);
    ref
        .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
        .replaceAtIndexAndCascade(
          cassetteIndex + 1,
          CassetteSpec.contacts(
            ContactsCassetteSpec.contactSelectionControl(
              chosenContactId: contactId,
            ),
          ),
        );
  }

  void contactChosen({
    required int contactId,
    required int infoCardIndex,
    SidebarFlowContactProjection contactProjection =
        SidebarFlowContactProjection.allMessages,
  }) {
    _setState(
      state.copyWith(
        topMenuChoice: TopChatMenuChoice.contacts,
        chosenContactId: contactId,
        selectedHandleId: null,
        selectedConversationId: null,
        selectedConversationAnchorMessageId: null,
        selectedConversationSearchQuery: null,
        selectedHandleEvidenceId: null,
        selectedHandleEvidenceKind: null,
        selectedHandleEvidenceInvestigationId: null,
        strayHandleInvestigationId: null,
        strayHandleInvestigation: null,
        messageScope: SidebarFlowMessageScope.regular,
        contactProjection: contactProjection,
      ),
    );
    _scheduleContactContextPreferencePersist(
      SidebarContactContextPreference(
        contactId: contactId,
        projection: contactProjection,
      ),
    );

    final newSpec = CassetteSpec.contacts(
      ContactsCassetteSpec.contactSelectionControl(chosenContactId: contactId),
    );

    ref
        .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
        .replaceAtIndexAndCascade(infoCardIndex, newSpec);
  }

  void chooseAnotherContact({required int infoCardIndex}) {
    ref
        .read(appLoggerProvider.notifier)
        .debug(
          'chooseAnotherContact start',
          source: 'SidebarFlow',
          context: {
            'infoCardIndex': infoCardIndex,
            'previousChosenContactId': state.chosenContactId,
            'previousSelectedHandleId': state.selectedHandleId,
            'previousProjectedCenterSpec': '${state.projectedCenterSpec}',
          },
        );

    _setState(
      state.copyWith(
        chosenContactId: null,
        selectedHandleId: null,
        selectedConversationId: null,
        selectedConversationAnchorMessageId: null,
        selectedConversationSearchQuery: null,
        selectedHandleEvidenceId: null,
        selectedHandleEvidenceKind: null,
        selectedHandleEvidenceInvestigationId: null,
        strayHandleInvestigationId: null,
        strayHandleInvestigation: null,
        messageScope: SidebarFlowMessageScope.regular,
        contactProjection: SidebarFlowContactProjection.allMessages,
      ),
    );
    _scheduleContactContextPreferencePersist(
      const SidebarContactContextPreference(
        contactId: null,
        projection: SidebarFlowContactProjection.allMessages,
      ),
    );

    const newSpec = CassetteSpec.contactsInfo(
      ContactsInfoCassetteSpec.infoCard(
        key: ContactsInfoKey.pickerContentSources,
      ),
    );

    ref
        .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
        .replaceAtIndexAndCascade(infoCardIndex, newSpec);

    ref
        .read(appLoggerProvider.notifier)
        .debug(
          'chooseAnotherContact complete',
          source: 'SidebarFlow',
          context: {
            'infoCardIndex': infoCardIndex,
            'chosenContactId': state.chosenContactId,
            'selectedHandleId': state.selectedHandleId,
            'projectedCenterSpec': '${state.projectedCenterSpec}',
          },
        );
  }

  void handleSelected({
    required int contactId,
    required int? handleId,
    required int cassetteIndex,
  }) {
    _setState(
      state.copyWith(
        topMenuChoice: TopChatMenuChoice.contacts,
        chosenContactId: contactId,
        selectedHandleId: handleId,
        selectedConversationId: null,
        selectedConversationAnchorMessageId: null,
        selectedConversationSearchQuery: null,
        selectedHandleEvidenceId: null,
        selectedHandleEvidenceKind: null,
        selectedHandleEvidenceInvestigationId: null,
        strayHandleInvestigationId: null,
        strayHandleInvestigation: null,
        messageScope: SidebarFlowMessageScope.regular,
        contactProjection: SidebarFlowContactProjection.allMessages,
      ),
    );
    _scheduleContactContextPreferencePersist(
      SidebarContactContextPreference(
        contactId: contactId,
        projection: SidebarFlowContactProjection.allMessages,
      ),
    );

    final newSpec = CassetteSpec.contacts(
      ContactsCassetteSpec.handleFilter(
        contactId: contactId,
        selectedHandleId: handleId,
      ),
    );

    ref
        .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
        .replaceAtIndexAndCascade(cassetteIndex, newSpec);
  }

  void setContactMessageScope({
    required int contactId,
    required SidebarFlowMessageScope messageScope,
    required int cassetteIndex,
  }) {
    if (messageScope == SidebarFlowMessageScope.regular) {
      _setState(
        state.copyWith(
          topMenuChoice: TopChatMenuChoice.contacts,
          chosenContactId: contactId,
          selectedConversationId: null,
          selectedConversationAnchorMessageId: null,
          selectedConversationSearchQuery: null,
          selectedHandleEvidenceId: null,
          selectedHandleEvidenceKind: null,
          selectedHandleEvidenceInvestigationId: null,
          strayHandleInvestigationId: null,
          strayHandleInvestigation: null,
          scrollToDate: null,
          messageScope: SidebarFlowMessageScope.regular,
          contactProjection: SidebarFlowContactProjection.allMessages,
        ),
      );
      _scheduleContactContextPreferencePersist(
        SidebarContactContextPreference(
          contactId: contactId,
          projection: SidebarFlowContactProjection.allMessages,
        ),
      );
      ref
          .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
          .replaceAtIndexAndCascade(
            cassetteIndex,
            CassetteSpec.contacts(
              ContactsCassetteSpec.messageScopeToggle(contactId: contactId),
            ),
          );
      return;
    }

    _setState(
      state.copyWith(
        topMenuChoice: TopChatMenuChoice.contacts,
        chosenContactId: contactId,
        selectedHandleId: null,
        selectedConversationId: null,
        selectedConversationAnchorMessageId: null,
        selectedConversationSearchQuery: null,
        selectedHandleEvidenceId: null,
        selectedHandleEvidenceKind: null,
        selectedHandleEvidenceInvestigationId: null,
        strayHandleInvestigationId: null,
        strayHandleInvestigation: null,
        scrollToDate: null,
        messageScope: SidebarFlowMessageScope.recoveredDeleted,
        contactProjection: SidebarFlowContactProjection.allMessages,
      ),
    );
    _scheduleContactContextPreferencePersist(
      SidebarContactContextPreference(
        contactId: contactId,
        projection: SidebarFlowContactProjection.allMessages,
      ),
    );

    ref
        .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
        .replaceAtIndexAndCascade(
          cassetteIndex,
          CassetteSpec.contacts(
            ContactsCassetteSpec.messageScopeToggle(contactId: contactId),
          ),
        );
  }

  void showGlobalRecoveredDeleted() {
    _setState(
      state.copyWith(
        topMenuChoice: TopChatMenuChoice.recoveredUnlinkedMessages,
        chosenContactId: null,
        selectedHandleId: null,
        selectedConversationId: null,
        selectedConversationAnchorMessageId: null,
        selectedConversationSearchQuery: null,
        selectedHandleEvidenceId: null,
        selectedHandleEvidenceKind: null,
        selectedHandleEvidenceInvestigationId: null,
        strayHandleInvestigationId: null,
        strayHandleInvestigation: null,
        scrollToDate: null,
        messageScope: SidebarFlowMessageScope.recoveredDeleted,
        contactProjection: SidebarFlowContactProjection.allMessages,
      ),
    );
  }

  void showRecoveredNoHandleFromMe({DateTime? scrollToDate}) {
    _setState(
      state.copyWith(
        topMenuChoice: TopChatMenuChoice.recoveredNoHandleFromMeMessages,
        chosenContactId: null,
        selectedHandleId: null,
        selectedConversationId: null,
        selectedConversationAnchorMessageId: null,
        selectedConversationSearchQuery: null,
        selectedHandleEvidenceId: null,
        selectedHandleEvidenceKind: null,
        selectedHandleEvidenceInvestigationId: null,
        strayHandleInvestigationId: null,
        strayHandleInvestigation: null,
        scrollToDate: scrollToDate,
        messageScope: SidebarFlowMessageScope.regular,
        contactProjection: SidebarFlowContactProjection.allMessages,
      ),
    );
  }

  void showContactConversationNavigator({required int contactId}) {
    _setState(
      state.copyWith(
        topMenuChoice: TopChatMenuChoice.contacts,
        chosenContactId: contactId,
        selectedHandleId: null,
        selectedConversationId: null,
        selectedConversationAnchorMessageId: null,
        selectedConversationSearchQuery: null,
        selectedHandleEvidenceId: null,
        selectedHandleEvidenceKind: null,
        selectedHandleEvidenceInvestigationId: null,
        strayHandleInvestigationId: null,
        strayHandleInvestigation: null,
        scrollToDate: null,
        messageScope: SidebarFlowMessageScope.regular,
        contactProjection: SidebarFlowContactProjection.conversations,
      ),
    );
    _scheduleContactContextPreferencePersist(
      SidebarContactContextPreference(
        contactId: contactId,
        projection: SidebarFlowContactProjection.conversations,
      ),
    );
  }

  void selectContactConversation({
    required int contactId,
    required int conversationId,
    int? anchorMessageId,
    String? searchQuery,
  }) {
    _setState(
      state.copyWith(
        topMenuChoice: TopChatMenuChoice.contacts,
        chosenContactId: contactId,
        selectedHandleId: null,
        selectedConversationId: conversationId,
        selectedConversationAnchorMessageId: anchorMessageId,
        selectedConversationSearchQuery: searchQuery,
        selectedHandleEvidenceId: null,
        selectedHandleEvidenceKind: null,
        selectedHandleEvidenceInvestigationId: null,
        strayHandleInvestigationId: null,
        strayHandleInvestigation: null,
        scrollToDate: null,
        messageScope: SidebarFlowMessageScope.regular,
        contactProjection: SidebarFlowContactProjection.conversations,
      ),
    );
    _scheduleContactContextPreferencePersist(
      SidebarContactContextPreference(
        contactId: contactId,
        projection: SidebarFlowContactProjection.conversations,
      ),
    );
  }

  void showGlobalTimeline() {
    _setState(
      state.copyWith(
        topMenuChoice: TopChatMenuChoice.searchAllMessages,
        chosenContactId: null,
        selectedHandleId: null,
        selectedConversationId: null,
        selectedConversationAnchorMessageId: null,
        selectedConversationSearchQuery: null,
        selectedHandleEvidenceId: null,
        selectedHandleEvidenceKind: null,
        selectedHandleEvidenceInvestigationId: null,
        strayHandleInvestigationId: null,
        strayHandleInvestigation: null,
        scrollToDate: null,
        messageScope: SidebarFlowMessageScope.regular,
        contactProjection: SidebarFlowContactProjection.allMessages,
      ),
    );
  }

  void showGlobalTimelineAt(DateTime? scrollToDate) {
    _setState(
      state.copyWith(
        topMenuChoice: TopChatMenuChoice.searchAllMessages,
        chosenContactId: null,
        selectedHandleId: null,
        selectedConversationId: null,
        selectedConversationAnchorMessageId: null,
        selectedConversationSearchQuery: null,
        selectedHandleEvidenceId: null,
        selectedHandleEvidenceKind: null,
        selectedHandleEvidenceInvestigationId: null,
        strayHandleInvestigationId: null,
        strayHandleInvestigation: null,
        scrollToDate: scrollToDate,
        messageScope: SidebarFlowMessageScope.regular,
        contactProjection: SidebarFlowContactProjection.allMessages,
      ),
    );
  }

  void showContactTimelineAt({
    required int contactId,
    DateTime? scrollToDate,
    int? filterHandleId,
  }) {
    _setState(
      state.copyWith(
        topMenuChoice: TopChatMenuChoice.contacts,
        chosenContactId: contactId,
        selectedHandleId: filterHandleId,
        selectedConversationId: null,
        selectedConversationAnchorMessageId: null,
        selectedConversationSearchQuery: null,
        selectedHandleEvidenceId: null,
        selectedHandleEvidenceKind: null,
        selectedHandleEvidenceInvestigationId: null,
        strayHandleInvestigationId: null,
        strayHandleInvestigation: null,
        scrollToDate: scrollToDate,
        messageScope: SidebarFlowMessageScope.regular,
        contactProjection: SidebarFlowContactProjection.allMessages,
      ),
    );
    _scheduleContactContextPreferencePersist(
      SidebarContactContextPreference(
        contactId: contactId,
        projection: SidebarFlowContactProjection.allMessages,
      ),
    );
  }

  void selectConversation({
    required int conversationId,
    int? anchorMessageId,
    String? searchQuery,
  }) {
    _setState(
      SidebarFlowState(
        topMenuChoice: TopChatMenuChoice.conversations,
        selectedConversationId: conversationId,
        selectedConversationAnchorMessageId: anchorMessageId,
        selectedConversationSearchQuery: searchQuery,
      ),
    );
  }

  void showConversationContext() {
    _setState(
      const SidebarFlowState(topMenuChoice: TopChatMenuChoice.conversations),
    );
  }

  void showRecoveredDeletedAt({
    required int? contactId,
    required DateTime startDate,
  }) {
    _setState(
      state.copyWith(
        topMenuChoice: contactId == null
            ? TopChatMenuChoice.recoveredUnlinkedMessages
            : TopChatMenuChoice.contacts,
        chosenContactId: contactId,
        selectedHandleId: null,
        selectedConversationId: null,
        selectedConversationAnchorMessageId: null,
        selectedConversationSearchQuery: null,
        selectedHandleEvidenceId: null,
        selectedHandleEvidenceKind: null,
        selectedHandleEvidenceInvestigationId: null,
        strayHandleInvestigationId: null,
        strayHandleInvestigation: null,
        scrollToDate: startDate,
        messageScope: SidebarFlowMessageScope.recoveredDeleted,
        contactProjection: SidebarFlowContactProjection.allMessages,
      ),
    );
  }

  void openStrayHandleLens({required int handleId}) {
    final investigationId =
        state.strayHandleInvestigationId ?? StrayHandleInvestigationId.initial;
    final investigation =
        state.strayHandleInvestigation ??
        StrayHandleInvestigation.identifySources;
    _setState(
      state.copyWith(
        topMenuChoice: TopChatMenuChoice.strayHandles,
        chosenContactId: null,
        selectedHandleId: null,
        selectedConversationId: null,
        selectedConversationAnchorMessageId: null,
        selectedConversationSearchQuery: null,
        selectedHandleEvidenceId: handleId,
        selectedHandleEvidenceKind: SidebarFlowHandleEvidenceKind.lens,
        selectedHandleEvidenceInvestigationId: investigationId,
        strayHandleInvestigationId: investigationId,
        strayHandleInvestigation: investigation,
        scrollToDate: null,
        messageScope: SidebarFlowMessageScope.regular,
        contactProjection: SidebarFlowContactProjection.allMessages,
      ),
    );
  }

  void openHandleMessages({required int handleId}) {
    final investigationId =
        state.strayHandleInvestigationId ?? StrayHandleInvestigationId.initial;
    final investigation =
        state.strayHandleInvestigation ??
        StrayHandleInvestigation.identifySources;
    _setState(
      state.copyWith(
        topMenuChoice: TopChatMenuChoice.strayHandles,
        chosenContactId: null,
        selectedHandleId: null,
        selectedConversationId: null,
        selectedConversationAnchorMessageId: null,
        selectedConversationSearchQuery: null,
        selectedHandleEvidenceId: handleId,
        selectedHandleEvidenceKind: SidebarFlowHandleEvidenceKind.messages,
        selectedHandleEvidenceInvestigationId: investigationId,
        strayHandleInvestigationId: investigationId,
        strayHandleInvestigation: investigation,
        scrollToDate: null,
        messageScope: SidebarFlowMessageScope.regular,
        contactProjection: SidebarFlowContactProjection.allMessages,
      ),
    );
  }

  /// Begins a new unfamiliar-source investigation episode.
  ///
  /// Existing handle evidence remains stored with its original provenance but
  /// ceases to project into the center panel because it is no longer compatible
  /// with the current investigation.
  void beginNewStrayHandleInvestigation({
    StrayHandleInvestigation? investigation,
  }) {
    if (state.topMenuChoice != TopChatMenuChoice.strayHandles) {
      throw StateError(
        'A stray-handle investigation can begin only on the stray handles '
        'branch.',
      );
    }

    final currentInvestigationId =
        state.strayHandleInvestigationId ?? StrayHandleInvestigationId.initial;
    _setState(
      state.copyWith(
        strayHandleInvestigationId: currentInvestigationId.next(),
        strayHandleInvestigation:
            investigation ?? state.strayHandleInvestigation,
      ),
    );
  }

  void setPersistentSettingsContext(SettingsMenuActionId? actionId) {
    _setState(state.copyWith(persistentSettingsContext: actionId));
  }

  Future<SidebarContactContextPreference>
  _readContactContextPreference() async {
    final store = await ref.read(sidebarFlowPreferenceStoreProvider.future);
    final rawValue = await store.readContactContextPreference();
    return SidebarContactContextPreference.fromStorage(rawValue);
  }

  void _scheduleContactContextPreferencePersist(
    SidebarContactContextPreference preference,
  ) {
    final storeFuture = ref.read(sidebarFlowPreferenceStoreProvider.future);
    _contactContextPersistChain = _contactContextPersistChain
        .catchError(
          (Object error, StackTrace stackTrace) =>
              _logPreferencePersistenceFailure(
                operation: 'contact-context prior persist',
                error: error,
                stackTrace: stackTrace,
              ),
        )
        .then((_) async {
          final store = await storeFuture;
          await store.writeContactContextPreference(preference.storageValue);
        });
    unawaited(
      _contactContextPersistChain.catchError(
        (Object error, StackTrace stackTrace) =>
            _logPreferencePersistenceFailure(
              operation: 'contact-context persist',
              error: error,
              stackTrace: stackTrace,
            ),
      ),
    );
  }

  void _scheduleNavigationPreferenceRestore() {
    if (_restoreScheduled) {
      return;
    }
    _restoreScheduled = true;
    unawaited(_restoreNavigationPreference());
  }

  Future<void> _restoreNavigationPreference() async {
    try {
      final preference = await _readNavigationPreference();
      if (_isDisposed || _hasLocalMutation || preference == null) {
        return;
      }

      _setState(preference.state, persistNavigation: false);
      _restoreCassetteRackForState(preference.state);
    } catch (error, stackTrace) {
      if (_isDisposed) {
        return;
      }

      ref
          .read(appLoggerProvider.notifier)
          .warn(
            'Sidebar navigation preference restore failed',
            source: 'SidebarFlow',
            context: <String, Object?>{
              'error': error.toString(),
              'stackTrace': stackTrace.toString(),
            },
          );
      // Restore is best-effort user intent. Invalid or unavailable overlay
      // state should never block the default sidebar from rendering.
    }
  }

  void _restoreCassetteRackForState(SidebarFlowState restoredState) {
    if (_isDisposed) {
      return;
    }

    final topMenuSpec = CassetteSpec.sidebarUtility(
      SidebarUtilityCassetteSpec.topChatMenu(
        selectedChoice: restoredState.topMenuChoice,
      ),
    );
    final rack = ref.read(cassetteRackStateProvider(SidebarMode.messages));
    if (rack.cassettes.isEmpty) {
      return;
    }

    final rackNotifier = ref.read(
      cassetteRackStateProvider(SidebarMode.messages).notifier,
    );
    rackNotifier.replaceAtIndexAndCascade(0, topMenuSpec);

    final contactId = restoredState.chosenContactId;
    if (restoredState.topMenuChoice != TopChatMenuChoice.contacts ||
        contactId == null) {
      return;
    }

    rackNotifier.replaceAtIndexAndCascade(
      1,
      CassetteSpec.contacts(
        ContactsCassetteSpec.contactSelectionControl(
          chosenContactId: contactId,
        ),
      ),
    );
  }

  Future<SidebarFlowNavigationPreference?> _readNavigationPreference() async {
    final store = await ref.read(sidebarFlowPreferenceStoreProvider.future);
    final rawValue = await store.readNavigationPreference();
    return SidebarFlowNavigationPreference.fromStorage(rawValue);
  }

  void _scheduleNavigationPreferencePersist(
    SidebarFlowNavigationPreference preference,
  ) {
    final storeFuture = ref.read(sidebarFlowPreferenceStoreProvider.future);
    _navigationPreferencePersistChain = _navigationPreferencePersistChain
        .catchError(
          (Object error, StackTrace stackTrace) =>
              _logPreferencePersistenceFailure(
                operation: 'navigation prior persist',
                error: error,
                stackTrace: stackTrace,
              ),
        )
        .then((_) async {
          final store = await storeFuture;
          await store.writeNavigationPreference(preference.storageValue);
        });
    unawaited(
      _navigationPreferencePersistChain.catchError(
        (Object error, StackTrace stackTrace) =>
            _logPreferencePersistenceFailure(
              operation: 'navigation persist',
              error: error,
              stackTrace: stackTrace,
            ),
      ),
    );
  }

  void _logPreferencePersistenceFailure({
    required String operation,
    required Object error,
    required StackTrace stackTrace,
  }) {
    if (_isDisposed) {
      return;
    }

    ref
        .read(appLoggerProvider.notifier)
        .warn(
          'Sidebar preference persistence failed',
          source: 'SidebarFlow',
          context: <String, Object?>{
            'operation': operation,
            'error': error.toString(),
            'stackTrace': stackTrace.toString(),
          },
        );
  }
}
