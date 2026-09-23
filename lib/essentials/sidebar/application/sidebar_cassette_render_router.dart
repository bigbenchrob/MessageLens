import 'package:flutter/widgets.dart';

import '../../../features/contacts/feature_level_providers.dart'
    as contacts_feature
    show
        ContactChooserCassettePayload,
        ContactHeroSummaryCassettePayload,
        ContactMessageScopeToggleCassettePayload,
        ContactSelectionControlCassettePayload,
        HandleFilterCassettePayload,
        buildPlacementGovernedCassetteBody;
import '../../../features/conversations/feature_level_providers.dart'
    as conversations_feature
    show
        ConversationSignaturesCassettePayload,
        buildPlacementGovernedCassetteBody;
import '../../../features/handles/feature_level_providers.dart'
    as handles_feature
    show
        StrayHandlesInvestigationSwitcherCassettePayload,
        StrayHandlesModeSwitcherCassettePayload,
        StrayHandlesReviewCassettePayload,
        StrayHandlesTypeSwitcherCassettePayload,
        buildPlacementGovernedCassetteBody;
import '../../../features/messages/feature_level_providers.dart'
    as messages_feature
    show
        MessagesHeatmapCassettePayload,
        RecoveredNoHandleFromMeNavigatorCassettePayload,
        RecoveredUnlinkedNavigatorCassettePayload,
        buildPlacementGovernedCassetteBody;
import '../../../features/settings/feature_level_providers.dart'
    as settings_feature
    show
        HistoricalArchivesSettingsCassettePayload,
        SettingsActionCardCassettePayload,
        SettingsInfoActionsCassettePayload,
        buildFeatureInfoSupplementalContent,
        buildHistoricalArchivesSettingsCassette,
        buildPlacementGovernedCassetteBody;
import '../../../features/sidebar_utilities/feature_level_providers.dart'
    as sidebar_utilities_feature
    show
        SettingsTopMenuCassettePayload,
        TopChatMenuCassettePayload,
        buildPlacementGovernedCassetteBody;
import '../../navigation/domain/sidebar_mode.dart';
import '../presentation/view/sidebar_body_model_content.dart';
import '../presentation/view/sidebar_cassette_card.dart';
import '../presentation/view/sidebar_info_card.dart';
import '../presentation/view_model/sidebar_cassette_card_view_model.dart';

Widget buildResolvedSidebarCassetteWidget({
  required SidebarMode mode,
  required ResolvedSidebarCassette resolvedCassette,
}) {
  return Padding(
    key: ValueKey<String>(
      'cassette:${mode.name}:${resolvedCassette.cassetteIndex}:${resolvedCassette.spec}',
    ),
    padding: EdgeInsets.only(top: resolvedCassette.topSpacing),
    child: buildSidebarCassettePayloadWidget(
      mode: mode,
      resolvedCassette: resolvedCassette,
    ),
  );
}

List<Widget> buildResolvedSidebarCassetteWidgets({
  required SidebarMode mode,
  required Iterable<ResolvedSidebarCassette> resolvedCassettes,
}) {
  return [
    for (final resolvedCassette in resolvedCassettes)
      buildResolvedSidebarCassetteWidget(
        mode: mode,
        resolvedCassette: resolvedCassette,
      ),
  ];
}

Widget buildSidebarCassettePayloadWidget({
  required SidebarMode mode,
  required ResolvedSidebarCassette resolvedCassette,
}) {
  final payload = resolvedCassette.payload;

  if (payload
      case settings_feature.HistoricalArchivesSettingsCassettePayload()) {
    return settings_feature.buildHistoricalArchivesSettingsCassette(
      payload: payload,
    );
  }

  // LAW: Rendering is selected here from render kind plus allowed payload
  // subtype checks. Payloads must not smuggle builder callbacks or hidden
  // render-selection logic across the boundary.
  // Rendering is selected here by explicit render kind plus payload subtype.
  // Payloads must not transport builder callbacks or hidden render logic.
  return switch (payload.renderKind) {
    SidebarCassetteRenderKind.placementGovernedFeature =>
      _buildPlacementGovernedFeatureCassetteWidget(
        payload: _requirePlacementGovernedPayload(payload),
      ),
    SidebarCassetteRenderKind.featureInfo => SidebarInfoCard(
      title: _requireFeatureInfoPayload(payload).title,
      bodyText: _requireFeatureInfoPayload(payload).bodyText,
      footnote: _requireFeatureInfoPayload(payload).footnote,
      content: _buildFeatureInfoSupplementalContent(
        payload: _requireFeatureInfoPayload(payload),
      ),
    ),
    SidebarCassetteRenderKind.sharedBodyModel => _buildSharedBodyModelWidget(
      mode: mode,
      resolvedCassette: resolvedCassette,
      payload: _requireSharedBodyModelPayload(payload),
    ),
  };
}

FeatureInfoSidebarCassettePayload _requireFeatureInfoPayload(
  SidebarCassettePayload payload,
) {
  return switch (payload) {
    FeatureInfoSidebarCassettePayload() => payload,
    SidebarCassettePayload() => throw StateError(
      'Render kind ${payload.renderKind} expected '
      'FeatureInfoSidebarCassettePayload but received '
      '${payload.runtimeType}.',
    ),
  };
}

SharedBodyModelSidebarCassettePayload _requireSharedBodyModelPayload(
  SidebarCassettePayload payload,
) {
  return switch (payload) {
    SharedBodyModelSidebarCassettePayload() => payload,
    SidebarCassettePayload() => throw StateError(
      'Render kind ${payload.renderKind} expected '
      'SharedBodyModelSidebarCassettePayload but received '
      '${payload.runtimeType}.',
    ),
  };
}

Widget? _buildFeatureInfoSupplementalContent({
  required FeatureInfoSidebarCassettePayload payload,
}) {
  return switch (payload) {
    settings_feature.SettingsInfoActionsCassettePayload() =>
      settings_feature.buildFeatureInfoSupplementalContent(payload: payload),
    settings_feature.HistoricalArchivesSettingsCassettePayload() =>
      settings_feature.buildFeatureInfoSupplementalContent(payload: payload),
    StaticFeatureInfoSidebarCassettePayload() => null,
    FeatureInfoSidebarCassettePayload() => throw UnsupportedError(
      'Unhandled feature-info payload type: ${payload.runtimeType}',
    ),
  };
}

PlacementGovernedSidebarCassettePayload _requirePlacementGovernedPayload(
  SidebarCassettePayload payload,
) {
  return switch (payload) {
    PlacementGovernedSidebarCassettePayload() => payload,
    SidebarCassettePayload() => throw StateError(
      'Render kind ${payload.renderKind} expected '
      'PlacementGovernedSidebarCassettePayload but received '
      '${payload.runtimeType}.',
    ),
  };
}

Widget _buildSharedBodyModelWidget({
  required SidebarMode mode,
  required ResolvedSidebarCassette resolvedCassette,
  required SharedBodyModelSidebarCassettePayload payload,
}) {
  return SidebarCassetteCard(
    title: payload.title,
    subtitle: payload.subtitle,
    sectionTitle: payload.sectionTitle,
    footerText: payload.footerText,
    isNaked: payload.isNaked,
    shouldExpand: payload.shouldExpand,
    role: payload.role,
    placementMode: payload.placementMode,
    contentAlignment: payload.contentAlignment,
    layoutStyle: payload.layoutStyle,
    child: SidebarBodyModelContent(
      bodyModel: payload.bodyModel,
      sidebarMode: mode,
      cassetteIndex: resolvedCassette.cassetteIndex,
    ),
  );
}

Widget _buildPlacementGovernedFeatureCassetteWidget({
  required PlacementGovernedSidebarCassettePayload payload,
}) {
  return SidebarCassetteCard.placementGoverned(
    title: payload.title,
    subtitle: payload.subtitle,
    sectionTitle: payload.sectionTitle,
    footerText: payload.footerText,
    isNaked: payload.isNaked,
    shouldExpand: payload.shouldExpand,
    role: payload.role,
    placementMode: payload.placementMode,
    contentAlignment: payload.contentAlignment,
    layoutStyle: payload.layoutStyle,
    child: _buildPlacementGovernedCassetteBody(payload: payload),
  );
}

Widget _buildPlacementGovernedCassetteBody({
  required PlacementGovernedSidebarCassettePayload payload,
}) {
  return switch (payload) {
    contacts_feature.ContactChooserCassettePayload() =>
      contacts_feature.buildPlacementGovernedCassetteBody(payload: payload),
    contacts_feature.ContactHeroSummaryCassettePayload() =>
      contacts_feature.buildPlacementGovernedCassetteBody(payload: payload),
    contacts_feature.ContactMessageScopeToggleCassettePayload() =>
      contacts_feature.buildPlacementGovernedCassetteBody(payload: payload),
    contacts_feature.ContactSelectionControlCassettePayload() =>
      contacts_feature.buildPlacementGovernedCassetteBody(payload: payload),
    contacts_feature.HandleFilterCassettePayload() =>
      contacts_feature.buildPlacementGovernedCassetteBody(payload: payload),
    handles_feature.StrayHandlesInvestigationSwitcherCassettePayload() =>
      handles_feature.buildPlacementGovernedCassetteBody(payload: payload),
    handles_feature.StrayHandlesModeSwitcherCassettePayload() =>
      handles_feature.buildPlacementGovernedCassetteBody(payload: payload),
    handles_feature.StrayHandlesReviewCassettePayload() =>
      handles_feature.buildPlacementGovernedCassetteBody(payload: payload),
    handles_feature.StrayHandlesTypeSwitcherCassettePayload() =>
      handles_feature.buildPlacementGovernedCassetteBody(payload: payload),
    conversations_feature.ConversationSignaturesCassettePayload() =>
      conversations_feature.buildPlacementGovernedCassetteBody(
        payload: payload,
      ),
    messages_feature.MessagesHeatmapCassettePayload() =>
      messages_feature.buildPlacementGovernedCassetteBody(payload: payload),
    messages_feature.RecoveredUnlinkedNavigatorCassettePayload() =>
      messages_feature.buildPlacementGovernedCassetteBody(payload: payload),
    messages_feature.RecoveredNoHandleFromMeNavigatorCassettePayload() =>
      messages_feature.buildPlacementGovernedCassetteBody(payload: payload),
    settings_feature.SettingsActionCardCassettePayload() =>
      settings_feature.buildPlacementGovernedCassetteBody(payload: payload),
    sidebar_utilities_feature.SettingsTopMenuCassettePayload() =>
      sidebar_utilities_feature.buildPlacementGovernedCassetteBody(
        payload: payload,
      ),
    sidebar_utilities_feature.TopChatMenuCassettePayload() =>
      sidebar_utilities_feature.buildPlacementGovernedCassetteBody(
        payload: payload,
      ),
    PlacementGovernedSidebarCassettePayload() => throw UnsupportedError(
      'Unhandled placement-governed cassette payload type: ${payload.runtimeType}',
    ),
  };
}
