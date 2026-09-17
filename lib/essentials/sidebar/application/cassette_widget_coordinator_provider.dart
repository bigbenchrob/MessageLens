import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../features/attachments/feature_level_providers.dart'
    as attachments_feature
    show
        attachmentArchiveLocationProvider,
        attachmentArchiveRelocationProductionEnabledProvider,
        attachmentArchiveRelocationWorkflowProvider;
import '../../../features/contacts/domain/spec_classes/contacts_cassette_spec.dart';
import '../../../features/contacts/feature_level_providers.dart'
    as contacts_feature
    show
        contactChooserCassetteStateProvider,
        contactsCassetteCoordinatorProvider,
        contactsInfoCassetteCoordinatorProvider;
import '../../../features/conversations/feature_level_providers.dart'
    as conversations_feature
    show conversationsCassetteCoordinatorProvider;
import '../../../features/handles/domain/spec_classes/handles_cassette_spec.dart';
import '../../../features/handles/feature_level_providers.dart'
    as handles_feature
    show
        handlesCassetteCoordinatorProvider,
        handlesInfoCassetteCoordinatorProvider,
        strayHandleReviewModeSettingProvider;
import '../../../features/messages/feature_level_providers.dart'
    as messages_feature
    show
        messagesCassetteCoordinatorProvider,
        messagesInfoCassetteCoordinatorProvider;
import '../../../features/settings/domain/spec_classes/settings_cassette_spec.dart';
import '../../../features/settings/feature_level_providers.dart'
    as settings_feature
    show
        historicalArchivesSidebarKnownSourcesProvider,
        settingsCassetteCoordinatorProvider;
import '../../../features/sidebar_utilities/domain/spec_classes/sidebar_utility_cassette_spec.dart';
import '../../../features/sidebar_utilities/feature_level_providers.dart'
    as sidebar_utilities
    show sidebarUtilitiesCassetteCoordinatorProvider;
import '../../navigation/domain/sidebar_mode.dart';
import '../domain/entities/cassette_spec.dart';
import '../presentation/view_model/sidebar_cassette_card_view_model.dart';
import 'renderable_sidebar_cassette_specs_provider.dart';
import 'sidebar_cassette_sectioning.dart';
import 'sidebar_flow_state_provider.dart';

part 'cassette_widget_coordinator_provider.g.dart';

final class SidebarCassetteResolutionError {
  const SidebarCassetteResolutionError({
    required this.error,
    required this.stackTrace,
  });

  final Object error;
  final StackTrace? stackTrace;
}

final class SidebarCassetteResolutionState {
  const SidebarCassetteResolutionState({
    required this.resolvedCassettes,
    required this.expectedVisibleCount,
    required this.isLoading,
    this.errors = const <SidebarCassetteResolutionError>[],
  });

  final List<ResolvedSidebarCassette> resolvedCassettes;
  final int expectedVisibleCount;
  final bool isLoading;
  final List<SidebarCassetteResolutionError> errors;

  bool get hasCompleteResolvedRack {
    return resolvedCassettes.length == expectedVisibleCount;
  }
}

@riverpod
Future<ResolvedSidebarCassette> resolvedSidebarCassette(
  Ref ref,
  SidebarMode mode,
  CassetteSpec spec,
  int cassetteIndex,
) async {
  final payload = await _buildPayloadForSpec(
    ref,
    spec,
    cassetteIndex: cassetteIndex,
  );

  return ResolvedSidebarCassette(
    spec: spec,
    cassetteIndex: cassetteIndex,
    payload: payload,
  );
}

@riverpod
SidebarCassetteResolutionState sidebarCassetteResolutionState(
  Ref ref,
  SidebarMode mode,
) {
  final renderableSpecs = ref.watch(
    renderableSidebarCassetteSpecsProvider(mode),
  );
  return _buildSidebarCassetteResolutionState(
    ref,
    mode: mode,
    renderableSpecs: renderableSpecs,
  );
}

SidebarCassetteResolutionState _buildSidebarCassetteResolutionState(
  Ref ref, {
  required SidebarMode mode,
  required List<RenderableSidebarCassetteSpec> renderableSpecs,
}) {
  final resolvedCassettes = <ResolvedSidebarCassette>[];
  final errors = <SidebarCassetteResolutionError>[];
  var isLoading = false;

  for (final renderableSpec in renderableSpecs) {
    final asyncResolvedCassette = ref.watch(
      resolvedSidebarCassetteProvider(
        mode,
        renderableSpec.spec,
        renderableSpec.cassetteIndex,
      ),
    );

    if (asyncResolvedCassette.isLoading || !asyncResolvedCassette.hasValue) {
      isLoading = true;
    }

    final error = asyncResolvedCassette.asError;
    if (error != null) {
      errors.add(
        SidebarCassetteResolutionError(
          error: error.error,
          stackTrace: error.stackTrace,
        ),
      );
    }

    final resolvedCassette = asyncResolvedCassette.valueOrNull;
    if (resolvedCassette != null) {
      resolvedCassettes.add(resolvedCassette);
    }
  }

  return SidebarCassetteResolutionState(
    resolvedCassettes: _applySidebarSectionSpacing(resolvedCassettes),
    expectedVisibleCount: renderableSpecs.length,
    isLoading: isLoading,
    errors: errors,
  );
}

Future<SidebarCassettePayload> _buildPayloadForSpec(
  Ref ref,
  CassetteSpec spec, {
  required int cassetteIndex,
}) {
  return spec.when(
    sidebarUtility: (sidebarSpec) async {
      final persistentSettingsContextActionId = sidebarSpec.maybeMap(
        settingsMenu: (_) {
          return ref.watch(
            sidebarFlowProvider.select(
              (flowState) => flowState.persistentSettingsContext,
            ),
          );
        },
        orElse: () => null,
      );

      final coordinator = ref.read(
        sidebar_utilities.sidebarUtilitiesCassetteCoordinatorProvider.notifier,
      );
      return coordinator.buildViewModel(
        sidebarSpec,
        cassetteIndex: cassetteIndex,
        persistentSettingsContextActionId: persistentSettingsContextActionId,
      );
    },
    contacts: (contactsSpec) async {
      contactsSpec.maybeMap(
        contactChooser: (_) {
          ref.watch(contacts_feature.contactChooserCassetteStateProvider);
          return null;
        },
        orElse: () {
          return null;
        },
      );

      final coordinator = ref.read(
        contacts_feature.contactsCassetteCoordinatorProvider.notifier,
      );
      return coordinator.buildViewModel(
        contactsSpec,
        cassetteIndex: cassetteIndex,
      );
    },
    contactsInfo: (infoSpec) async {
      final coordinator = ref.read(
        contacts_feature.contactsInfoCassetteCoordinatorProvider.notifier,
      );
      return coordinator.buildViewModel(infoSpec, cassetteIndex: cassetteIndex);
    },
    conversations: (conversationsSpec) async {
      final coordinator = ref.read(
        conversations_feature.conversationsCassetteCoordinatorProvider.notifier,
      );
      return coordinator.buildViewModel(
        conversationsSpec,
        cassetteIndex: cassetteIndex,
      );
    },
    handles: (handlesSpec) async {
      handlesSpec.when(
        strayHandlesReview: (_, __) {
          ref.watch(handles_feature.strayHandleReviewModeSettingProvider);
          return null;
        },
        strayHandlesModeSwitcher: (_, __) {
          ref.watch(handles_feature.strayHandleReviewModeSettingProvider);
          return null;
        },
        strayHandlesTypeSwitcher: (_) {
          return null;
        },
        strayHandlesInvestigationSwitcher: (_) {
          return null;
        },
      );

      final coordinator = ref.read(
        handles_feature.handlesCassetteCoordinatorProvider.notifier,
      );
      return coordinator.buildViewModel(
        handlesSpec,
        cassetteIndex: cassetteIndex,
      );
    },
    handlesInfo: (handlesInfoSpec) async {
      final coordinator = ref.read(
        handles_feature.handlesInfoCassetteCoordinatorProvider.notifier,
      );
      return coordinator.buildViewModel(
        handlesInfoSpec,
        cassetteIndex: cassetteIndex,
      );
    },
    messages: (messagesSpec) async {
      final coordinator = ref.read(
        messages_feature.messagesCassetteCoordinatorProvider.notifier,
      );
      return coordinator.buildViewModel(
        messagesSpec,
        cassetteIndex: cassetteIndex,
      );
    },
    messagesInfo: (messagesInfoSpec) async {
      final coordinator = ref.read(
        messages_feature.messagesInfoCassetteCoordinatorProvider.notifier,
      );
      return coordinator.buildViewModel(
        messagesInfoSpec,
        cassetteIndex: cassetteIndex,
      );
    },
    settings: (settingsSpec) async {
      final historicalArchivesKnownSources = await settingsSpec.maybeMap(
        historicalArchivesOverview: (_) async {
          return ref.watch(
            settings_feature
                .historicalArchivesSidebarKnownSourcesProvider
                .future,
          );
        },
        orElse: () async => null,
      );
      final attachmentArchiveLocation = await settingsSpec.maybeMap(
        attachmentArchive: (_) => ref.watch(
          attachments_feature.attachmentArchiveLocationProvider.future,
        ),
        orElse: () async => null,
      );
      final attachmentArchiveRelocation = await settingsSpec.maybeMap(
        attachmentArchive: (_) async => ref
            .watch(
              attachments_feature.attachmentArchiveRelocationWorkflowProvider,
            )
            .valueOrNull,
        orElse: () async => null,
      );
      final attachmentArchiveRelocationEnabled = settingsSpec.maybeMap(
        attachmentArchive: (_) => ref.watch(
          attachments_feature
              .attachmentArchiveRelocationProductionEnabledProvider,
        ),
        orElse: () => false,
      );

      final coordinator = ref.read(
        settings_feature.settingsCassetteCoordinatorProvider.notifier,
      );
      return coordinator.buildViewModel(
        settingsSpec,
        cassetteIndex: cassetteIndex,
        historicalArchivesKnownSources: historicalArchivesKnownSources,
        attachmentArchiveLocation: attachmentArchiveLocation,
        attachmentArchiveRelocation: attachmentArchiveRelocation,
        attachmentArchiveRelocationEnabled: attachmentArchiveRelocationEnabled,
      );
    },
  );
}

List<ResolvedSidebarCassette> _applySidebarSectionSpacing(
  List<ResolvedSidebarCassette> resolvedCassettes,
) {
  final spacedCassettes = <ResolvedSidebarCassette>[];
  SidebarCassettePayload? previousPayload;

  for (final resolvedCassette in resolvedCassettes) {
    final sectionTopSpacing = sidebarCassetteTopSpacing(
      previousPayload: previousPayload,
      currentPayload: resolvedCassette.payload,
    );

    assert(() {
      if (previousPayload == null && sectionTopSpacing != 0) {
        throw StateError(
          'sidebarCassetteTopSpacing must return 0 for the first '
          'resolved cassette in the rack.',
        );
      }

      return true;
    }());

    spacedCassettes.add(
      ResolvedSidebarCassette(
        spec: resolvedCassette.spec,
        cassetteIndex: resolvedCassette.cassetteIndex,
        payload: resolvedCassette.payload,
        topSpacing: resolvedCassette.payload.topSpacing + sectionTopSpacing,
      ),
    );
    previousPayload = resolvedCassette.payload;
  }

  return spacedCassettes;
}
