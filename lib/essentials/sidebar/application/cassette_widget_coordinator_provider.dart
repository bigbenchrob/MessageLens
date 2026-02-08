import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../features/contacts/feature_level_providers.dart'
    as contacts_feature;
import '../../../features/handles/feature_level_providers.dart'
    as handles_feature;
import '../../../features/messages/feature_level_providers.dart'
    as messages_feature;
import '../../../features/sidebar_utilities/feature_level_providers.dart'
    as sidebar_utilities;
import '../../../features/sidebar_utilities/presentation/cassettes/theme_playground_cassette.dart';
import '../../navigation/domain/sidebar_mode.dart';

/// barrel file import to expose cassette spec and feature cassette spec definitions
import '../domain/entities/features/presentation_cassette_spec.dart';
import '../feature_level_providers.dart';

/// utility widgets to wrap each cassette in a card
import '../presentation/sidebar_info_card.dart';
import '../presentation/view/sidebar_cassette_card.dart';
import '../presentation/view/sidebar_navigation_card.dart';
import '../presentation/view_model/sidebar_cassette_card_view_model.dart';

part 'cassette_widget_coordinator_provider.g.dart';

@riverpod
class CassetteWidgetCoordinator extends _$CassetteWidgetCoordinator {
  /// NOTE: This is now async because feature-side spec handling may require
  /// repositories/data access (counts, derived values, etc.).
  ///
  /// This means the provider becomes an AsyncValue<List<Widget>> at call sites.
  @override
  Future<List<Widget>> build(SidebarMode mode) async {
    final rack = ref.watch(cassetteRackStateProvider(mode));
    final widgets = <Widget>[];

    /// Build a view model for a given cassette spec by routing to the owning feature.
    ///
    /// IMPORTANT:
    /// Every branch returns a Future, even if the underlying coordinator is sync.
    /// This avoids mixed return types inside `spec.when(...)`.
    ///
    /// The [cassetteIndex] is passed to feature coordinators so widgets can
    /// update the rack without holding specs in state.
    Future<SidebarCassetteCardViewModel> buildViewModelForSpec(
      CassetteSpec spec, {
      required int cassetteIndex,
    }) {
      return spec.when(
        sidebarUtility: (sidebarSpec) async {
          final coordinator = ref.read(
            sidebar_utilities
                .sidebarUtilitiesCassetteCoordinatorProvider
                .notifier,
          );
          return coordinator.buildViewModel(
            sidebarSpec,
            cassetteIndex: cassetteIndex,
          );
        },
        presentation: (presentationSpec) async {
          return presentationSpec.map(
            themePlayground: (_) {
              return const SidebarCassetteCardViewModel(
                title: 'Theme playground',
                subtitle: 'Verify theme reacts to system appearance changes.',
                child: ThemePlaygroundCassette(),
              );
            },
          );
        },
        contacts: (contactsSpec) async {
          final coordinator = ref.read(
            contacts_feature.contactsCassetteCoordinatorProvider.notifier,
          );
          return coordinator.buildViewModel(
            contactsSpec,
            cassetteIndex: cassetteIndex,
          );
        },
        contactsSettings: (settingsSpec) async {
          final coordinator = ref.read(
            contacts_feature.contactsSettingsCoordinatorProvider.notifier,
          );
          return coordinator.buildViewModel(
            settingsSpec,
            cassetteIndex: cassetteIndex,
          );
        },
        contactsInfo: (infoSpec) async {
          final coordinator = ref.read(
            contacts_feature.contactsInfoCassetteCoordinatorProvider.notifier,
          );
          return coordinator.buildViewModel(
            infoSpec,
            cassetteIndex: cassetteIndex,
          );
        },
        handles: (handlesSpec) async {
          final coordinator = ref.read(
            handles_feature.featureCassetteSpecCoordinatorProvider.notifier,
          );
          return coordinator.buildForSpec(
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
            messages_feature.featureCassetteSpecCoordinatorProvider.notifier,
          );
          return coordinator.buildForSpec(
            messagesSpec,
            cassetteIndex: cassetteIndex,
          );
        },
      );
    }

    /// Convert a view model into a concrete widget and append it to the list.
    ///
    /// This is async because it awaits buildViewModelForSpec(spec).
    Future<void> addCassette(
      CassetteSpec spec, {
      required int cassetteIndex,
    }) async {
      final viewModel = await buildViewModelForSpec(
        spec,
        cassetteIndex: cassetteIndex,
      );

      switch (viewModel.cardType) {
        case CassetteCardType.standard:
          widgets.add(
            SidebarCassetteCard(
              title: viewModel.title,
              subtitle: viewModel.subtitle,
              sectionTitle: viewModel.sectionTitle,
              footerText: viewModel.footerText,
              isControl: viewModel.isControl,
              isNaked: viewModel.isNaked,
              shouldExpand: viewModel.shouldExpand,
              child: viewModel.child,
            ),
          );
        case CassetteCardType.info:
          widgets.add(
            SidebarInfoCard(
              title: viewModel.title.isEmpty ? null : viewModel.title,
              body: TextSpan(text: viewModel.infoBodyText ?? ''),
              footnote: viewModel.footerText,
              action: viewModel.infoAction,
            ),
          );
        case CassetteCardType.sidebarNavigation:
          widgets.add(SidebarNavigationCard(child: viewModel.child));
      }
    }

    // Build widgets for the explicit rack cassettes.
    for (var i = 0; i < rack.cassettes.length; i++) {
      await addCassette(rack.cassettes[i], cassetteIndex: i);
    }

    return widgets;
  }
}
