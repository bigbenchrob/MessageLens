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
    Future<SidebarCassetteCardViewModel> buildViewModelForSpec(
      CassetteSpec spec,
    ) {
      return spec.when(
        sidebarUtility: (sidebarSpec) async {
          final coordinator = ref.read(
            sidebar_utilities.featureCassetteSpecCoordinatorProvider.notifier,
          );
          return coordinator.buildForSpec(sidebarSpec);
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
          return coordinator.buildViewModel(contactsSpec);
        },
        contactsSettings: (settingsSpec) async {
          final coordinator = ref.read(
            contacts_feature.settingsCassetteSpecCoordinatorProvider.notifier,
          );
          return coordinator.buildForSpec(settingsSpec);
        },
        contactsInfo: (infoSpec) async {
          final coordinator = ref.read(
            contacts_feature.infoCassetteCoordinatorProvider.notifier,
          );
          return coordinator.buildViewModel(infoSpec);
        },
        handles: (handlesSpec) async {
          final coordinator = ref.read(
            handles_feature.featureCassetteSpecCoordinatorProvider.notifier,
          );
          return coordinator.buildForSpec(handlesSpec);
        },
        handlesInfo: (handlesInfoSpec) async {
          final coordinator = ref.read(
            handles_feature.handlesInfoCassetteCoordinatorProvider.notifier,
          );
          return coordinator.buildViewModel(handlesInfoSpec);
        },
        messages: (messagesSpec) async {
          final coordinator = ref.read(
            messages_feature.featureCassetteSpecCoordinatorProvider.notifier,
          );
          return coordinator.buildForSpec(messagesSpec);
        },
      );
    }

    /// Convert a view model into a concrete widget and append it to the list.
    ///
    /// This is async because it awaits buildViewModelForSpec(spec).
    Future<void> addCassette(CassetteSpec spec) async {
      final viewModel = await buildViewModelForSpec(spec);

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
            ),
          );
      }
    }

    // Build widgets for the explicit rack cassettes.
    for (final spec in rack.cassettes) {
      await addCassette(spec);
    }

    // Then build any chained children.
    var childSpec = rack.cassettes.isNotEmpty
        ? rack.cassettes.last.childSpec()
        : null;

    while (childSpec != null) {
      await addCassette(childSpec);
      childSpec = childSpec.childSpec();
    }

    return widgets;
  }
}
