import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../config/theme/widgets/buttons/app_header_action_button.dart';
import '../../../../config/theme/widgets/layout/cross_column_track_plan.dart';
import '../../../../essentials/navigation/domain/entities/view_spec.dart';
import '../../../../essentials/search/application/message_text_search_query.dart';
import '../../../handles/domain/spec_classes/handles_cassette_spec.dart';
import '../../../handles/feature_level_providers.dart'
    show handleSourcePresentationProvider;
import '../../application/handle_lens/handle_lens_session_provider.dart';
import '../../application/message_evidence/message_evidence_spine_provider.dart';
import '../../domain/message_evidence/message_evidence_scope.dart';
import '../../domain/spec_classes/messages_view_spec.dart';
import '../view/handle_lens_view.dart';
import '../view_model/handle_investigation_presentation.dart';
import '../view_model/handle_lens_header_labels.dart';
import '../widgets/message_evidence/message_evidence_track_occupants.dart';

/// Feature-prepared occupants for the complete unfamiliar-source center lens.
///
/// Messages owns this center-panel presentation, including how source facts and
/// review actions appear beside Message evidence. Handles remains the source of
/// canonical handle facts and review actions. Navigation places these prepared
/// occupants without interpreting either feature's semantics.
final class UnfamiliarSourcesMessageTrackOccupants {
  const UnfamiliarSourcesMessageTrackOccupants({
    required this.panelIdentity,
    this.subject,
    this.metrics,
    this.searchControls,
    this.actions,
  });

  final TrackOccupant panelIdentity;
  final TrackOccupant? subject;
  final TrackOccupant? metrics;
  final TrackOccupant? searchControls;
  final TrackOccupant? actions;
}

UnfamiliarSourcesMessageTrackOccupants? unfamiliarSourcesMessageTrackOccupants({
  required WidgetRef ref,
  required ViewSpec? centerSpec,
  required ThemeColors colors,
  required ThemeTypography typography,
}) {
  final investigation = _handleInvestigation(centerSpec);
  if (investigation == null) {
    return null;
  }

  return investigation.target.when(
    idle: () => unfamiliarSourcesIdleMessageTrackOccupants(
      investigation: investigation.investigation,
      typography: typography,
    ),
    selectedSource: (handleId) => _selectedSourceTrackOccupants(
      ref: ref,
      handleId: handleId,
      investigation: investigation.investigation,
      colors: colors,
      typography: typography,
    ),
  );
}

UnfamiliarSourcesMessageTrackOccupants
unfamiliarSourcesIdleMessageTrackOccupants({
  required StrayHandleInvestigation investigation,
  required ThemeTypography typography,
}) {
  final presentation = handleInvestigationPresentation(investigation);
  return UnfamiliarSourcesMessageTrackOccupants(
    panelIdentity: TextTrackOccupant(
      text: presentation.panelTitle,
      style: typography.title1,
    ),
  );
}

UnfamiliarSourcesMessageTrackOccupants _selectedSourceTrackOccupants({
  required WidgetRef ref,
  required int handleId,
  required StrayHandleInvestigation investigation,
  required ThemeColors colors,
  required ThemeTypography typography,
}) {
  final investigationPresentation = handleInvestigationPresentation(
    investigation,
  );
  final sourcePresentationAsync = ref.watch(
    handleSourcePresentationProvider(handleId: handleId),
  );
  final sourcePresentation = sourcePresentationAsync.valueOrNull;
  if (sourcePresentation == null) {
    return UnfamiliarSourcesMessageTrackOccupants(
      panelIdentity: TextTrackOccupant(
        text: investigationPresentation.panelTitle,
        style: typography.title1,
      ),
      subject: TextTrackOccupant(
        text: sourcePresentationAsync.hasError
            ? 'Unable to load source'
            : 'Loading source...',
        style: typography.title2,
      ),
    );
  }

  final session = ref.watch(handleLensSessionProvider(handleId: handleId));
  final searchIntent = MessageTextSearchQuery.parse(
    session.query,
  ).executionIntent;
  final displayQuery = searchIntent.isExecutable ? session.query.trim() : '';
  final evidenceScope = HandleMessagesEvidenceScope(handleId: handleId);
  final skeletonAsync = ref.watch(
    messageEvidenceTimelineSkeletonProvider(scope: evidenceScope),
  );
  final matchingIdsAsync = !searchIntent.isExecutable
      ? null
      : ref.watch(
          messageEvidenceTextMatchIdsProvider(
            scope: evidenceScope,
            searchIntent: searchIntent,
            mode: session.searchMode,
          ),
        );
  final skeleton = skeletonAsync.valueOrNull;
  final totalCount = sourcePresentation.messageCount == 0
      ? skeleton?.totalCount ?? 0
      : sourcePresentation.messageCount;
  final secondaryStyle = typography.callout.copyWith(
    color: colors.content.textSecondary,
  );
  final sessionActions = ref.read(
    handleLensSessionProvider(handleId: handleId).notifier,
  );

  return UnfamiliarSourcesMessageTrackOccupants(
    panelIdentity: TextTrackOccupant(
      text: investigationPresentation.panelTitle,
      style: typography.title1,
    ),
    subject: TextTrackOccupant(
      text: sourcePresentation.primaryDisplayLabel,
      style: typography.title2,
    ),
    metrics: HandleLensMetricsTrackOccupant(
      dateRangeLabel: skeleton == null
          ? 'Loading message dates...'
          : handleLensDateSpan(skeleton.entries),
      countLabel: handleLensCountLabel(
        totalCount: totalCount,
        query: displayQuery,
        matchingIds: matchingIdsAsync?.valueOrNull,
        isMatchingLoaded: matchingIdsAsync?.hasValue ?? false,
      ),
      style: secondaryStyle,
    ),
    searchControls: MessageEvidenceSearchControlsTrackOccupant(
      query: session.query,
      placeholder: 'Search messages from this handle',
      mode: session.searchMode,
      onQueryChanged: sessionActions.setQuery,
      onModeChanged: sessionActions.setSearchMode,
    ),
    actions: HandleLensActionsTrackOccupant(
      handleId: handleId,
      isCreatingContact: session.isCreatingContact,
      errorMessage: session.errorMessage,
      typography: typography,
      errorColor: colors.buttons.destructiveForeground,
    ),
  );
}

final class HandleLensMetricsTrackOccupant implements TrackOccupant {
  const HandleLensMetricsTrackOccupant({
    required this.dateRangeLabel,
    required this.countLabel,
    required this.style,
  });

  static const double _spacing = 14;
  static const double _runSpacing = 4;

  final String dateRangeLabel;
  final String countLabel;
  final TextStyle style;

  @override
  OccupantDimensionalClaim dimensionalClaim(
    PresentationConstraints constraints,
  ) {
    final layout = _layoutFor(constraints);
    return OccupantDimensionalClaim(
      naturalHeight: layout.naturalHeight,
      preferredWidth: layout.preferredWidth,
    );
  }

  @override
  Widget buildPresentation(
    BuildContext context,
    ResolvedTrackAllocation allocation,
  ) {
    final layout = _layoutFor(
      PresentationConstraints.fromBuildContext(
        context,
        availableWidth: allocation.availableWidth,
      ),
    );
    final date = _singleLineText(dateRangeLabel);
    final count = _singleLineText(countLabel);
    if (layout.usesTwoRuns) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          date,
          const SizedBox(height: _runSpacing),
          count,
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        date,
        const SizedBox(width: _spacing),
        count,
      ],
    );
  }

  _HandleLensMetricsLayout _layoutFor(PresentationConstraints constraints) {
    final dateMetrics = _measureSingleLineText(dateRangeLabel, constraints);
    final countMetrics = _measureSingleLineText(countLabel, constraints);
    final preferredWidth = dateMetrics.width + _spacing + countMetrics.width;
    final usesTwoRuns = preferredWidth > constraints.availableWidth;
    return _HandleLensMetricsLayout(
      usesTwoRuns: usesTwoRuns,
      naturalHeight: usesTwoRuns
          ? dateMetrics.height + _runSpacing + countMetrics.height
          : math.max(dateMetrics.height, countMetrics.height),
      preferredWidth: preferredWidth,
    );
  }

  _SingleLineTextMetrics _measureSingleLineText(
    String text,
    PresentationConstraints constraints,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      ellipsis: '\u2026',
      textDirection: constraints.textDirection,
      textScaler: constraints.textScaler,
      locale: constraints.locale,
    )..layout();
    final metrics = _SingleLineTextMetrics(
      width: painter.width,
      height: painter.height,
    );
    painter.dispose();
    return metrics;
  }

  Text _singleLineText(String text) {
    return Text(
      text,
      style: style,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
    );
  }
}

final class _HandleLensMetricsLayout {
  const _HandleLensMetricsLayout({
    required this.usesTwoRuns,
    required this.naturalHeight,
    required this.preferredWidth,
  });

  final bool usesTwoRuns;
  final double naturalHeight;
  final double preferredWidth;
}

final class _SingleLineTextMetrics {
  const _SingleLineTextMetrics({required this.width, required this.height});

  final double width;
  final double height;
}

final class HandleLensActionsTrackOccupant implements TrackOccupant {
  const HandleLensActionsTrackOccupant({
    required this.handleId,
    required this.isCreatingContact,
    required this.errorMessage,
    required this.typography,
    required this.errorColor,
  });

  static const double _detailsGap = 8;
  static const double _formControlHeight = 28;
  static const double _errorGap = 6;

  final int handleId;
  final bool isCreatingContact;
  final String? errorMessage;
  final ThemeTypography typography;
  final Color errorColor;

  @override
  OccupantDimensionalClaim dimensionalClaim(
    PresentationConstraints constraints,
  ) {
    final captionHeight = TextTrackOccupant(
      text: 'Create Contact',
      style: typography.caption,
    ).dimensionalClaim(constraints).naturalHeight;
    var naturalHeight =
        math.max(AppHeaderActionButton.iconSize, captionHeight) +
        (AppHeaderActionButton.verticalPadding * 2) +
        (AppHeaderActionButton.borderWidth * 2);
    if (!isCreatingContact) {
      return OccupantDimensionalClaim(naturalHeight: naturalHeight);
    }

    naturalHeight += _detailsGap + _formControlHeight;
    final error = errorMessage;
    if (error != null && error.isNotEmpty) {
      final errorHeight = TextTrackOccupant(
        text: error,
        style: typography.caption.copyWith(color: errorColor),
        maxLines: 2,
        softWrap: true,
      ).dimensionalClaim(constraints).naturalHeight;
      naturalHeight += _errorGap + errorHeight;
    }
    return OccupantDimensionalClaim(naturalHeight: naturalHeight);
  }

  @override
  Widget buildPresentation(
    BuildContext context,
    ResolvedTrackAllocation allocation,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HandleLensActionBar(handleId: handleId),
        if (isCreatingContact) ...[
          const SizedBox(height: _detailsGap),
          HandleLensCreateContactForm(
            handleId: handleId,
            typography: typography,
            errorColor: errorColor,
          ),
        ],
      ],
    );
  }
}

({StrayHandleInvestigation investigation, HandleInvestigationTarget target})?
_handleInvestigation(ViewSpec? spec) {
  return spec?.maybeWhen(
    messages: (messagesSpec) {
      return messagesSpec.maybeWhen(
        handleInvestigation: (investigationId, investigation, target) =>
            (investigation: investigation, target: target),
        orElse: () => null,
      );
    },
    orElse: () => null,
  );
}
