import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart' as macos_ui;

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../../../config/theme/widgets/layout/app_panel_bands.dart';
import '../../../../../config/theme/widgets/layout/page_track_layout_matrix.dart';
import '../../../../../config/theme/widgets/layout/resolved_track_layout_matrix.dart';
import '../../../domain/message_evidence/message_evidence_search_mode.dart';
import 'message_evidence_header_track_metrics.dart';

class MessageEvidenceHeaderModel {
  const MessageEvidenceHeaderModel({
    required this.title,
    this.identityContextLine,
    this.scopeContextLine,
    this.dateRangeLabel,
    this.countLabel,
    this.scopeNote,
    this.activeScopeLabel,
    this.activeScopeIndicator,
    this.searchConfig,
    this.actions,
    this.details,
    this.supplementalMetricParts = const <String>[],
  });

  final String title;
  final String? identityContextLine;
  final String? scopeContextLine;
  final String? dateRangeLabel;
  final String? countLabel;
  final String? scopeNote;
  final String? activeScopeLabel;
  final Widget? activeScopeIndicator;
  final MessageEvidenceHeaderSearchConfig? searchConfig;
  final Widget? actions;
  final Widget? details;
  final List<String> supplementalMetricParts;
}

class MessageEvidenceHeaderSearchConfig {
  const MessageEvidenceHeaderSearchConfig({
    required this.controller,
    required this.placeholder,
    this.mode,
    this.onModeChanged,
  });

  final TextEditingController controller;
  final String placeholder;
  final MessageEvidenceSearchMode? mode;
  final ValueChanged<MessageEvidenceSearchMode>? onModeChanged;
}

class MessageEvidenceHeader extends ConsumerWidget {
  const MessageEvidenceHeader({
    required this.data,
    this.details,
    this.padding = AppPanelBands.centerPanelPadding,
    this.useFixedPanelFrame = false,
    this.continueInNativeFlowAfterTracks = false,
    super.key,
  });

  final MessageEvidenceHeaderModel data;
  final Widget? details;
  final EdgeInsets padding;
  final bool useFixedPanelFrame;

  /// Continues the Messages-owned header flow after the page's shared Track
  /// region ends.
  ///
  /// This is used when a page shares only its title row across columns. The
  /// remaining header content has no cross-column relationship and therefore
  /// returns to the feature's native layout rather than occupying false Tracks.
  final bool continueInNativeFlowAfterTracks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final identityContextLine = data.identityContextLine?.trim();
    final scopeContextLine = data.scopeContextLine?.trim();
    final scopeNote = data.scopeNote?.trim();
    final activeScopeLabel = data.activeScopeLabel?.trim();
    final hasIdentityContext =
        identityContextLine != null && identityContextLine.isNotEmpty;
    final metricParts =
        [data.dateRangeLabel, data.countLabel, ...data.supplementalMetricParts]
            .whereType<String>()
            .where((part) => part.trim().isNotEmpty)
            .toList(growable: false);
    final resolvedDetails = data.details ?? details;

    final hasResolvedMatrix =
        ResolvedTrackLayoutMatrixScope.maybeOf(context) != null;
    final title = Text(data.title, style: typography.title1);
    final primary = _MessageEvidencePrimaryBand(
      identityContextLine: identityContextLine,
      hasIdentityContext: hasIdentityContext,
      metricParts: metricParts,
      scopeContextLine: scopeContextLine,
      scopeNote: scopeNote,
      activeScopeLabel: activeScopeLabel,
      activeScopeIndicator: data.activeScopeIndicator,
    );
    final secondary = _MessageEvidenceSecondaryBand(
      searchConfig: data.searchConfig,
      actions: data.actions,
      details: resolvedDetails,
    );
    return ColoredBox(
      color: colors.messagePanels.coolPanelSurface,
      child: useFixedPanelFrame && hasResolvedMatrix
          ? _MessageEvidenceTrackedHeader(
              primary: primary,
              secondary: secondary,
              padding: padding,
              continueInNativeFlowAfterTracks: continueInNativeFlowAfterTracks,
            )
          : _MessageEvidenceFallbackHeader(
              padding: padding,
              title: title,
              primary: primary,
              secondary: secondary,
            ),
    );
  }
}

class _MessageEvidenceTrackedHeader extends StatelessWidget {
  const _MessageEvidenceTrackedHeader({
    required this.primary,
    required this.secondary,
    required this.padding,
    required this.continueInNativeFlowAfterTracks,
  });

  final Widget primary;
  final Widget secondary;
  final EdgeInsets padding;
  final bool continueInNativeFlowAfterTracks;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _MessageEvidenceTrackCells(),
        if (continueInNativeFlowAfterTracks)
          Padding(
            padding: EdgeInsets.fromLTRB(
              padding.left,
              AppPanelBands.titleToPrimaryGap,
              padding.right,
              padding.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                primary,
                const SizedBox(height: AppPanelBands.primaryToSecondaryGap),
                secondary,
              ],
            ),
          ),
      ],
    );
  }
}

class _MessageEvidenceFallbackHeader extends StatelessWidget {
  const _MessageEvidenceFallbackHeader({
    required this.padding,
    required this.title,
    required this.primary,
    required this.secondary,
  });

  final EdgeInsets padding;
  final Widget title;
  final Widget primary;
  final Widget secondary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          title,
          const SizedBox(height: AppPanelBands.titleToPrimaryGap),
          primary,
          const SizedBox(height: AppPanelBands.primaryToSecondaryGap),
          secondary,
        ],
      ),
    );
  }
}

class _MessageEvidenceTrackCells extends StatelessWidget {
  const _MessageEvidenceTrackCells();

  @override
  Widget build(BuildContext context) {
    final matrix = ResolvedTrackLayoutMatrixScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final trackId in matrix.trackIds)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: TrackCellView(
              cellId: CellId(trackId: trackId, columnId: TrackColumnId.column2),
            ),
          ),
      ],
    );
  }
}

class _MessageEvidencePrimaryBand extends ConsumerWidget {
  const _MessageEvidencePrimaryBand({
    required this.identityContextLine,
    required this.hasIdentityContext,
    required this.metricParts,
    required this.scopeContextLine,
    required this.scopeNote,
    required this.activeScopeLabel,
    required this.activeScopeIndicator,
  });

  final String? identityContextLine;
  final bool hasIdentityContext;
  final List<String> metricParts;
  final String? scopeContextLine;
  final String? scopeNote;
  final String? activeScopeLabel;
  final Widget? activeScopeIndicator;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasIdentityContext)
          Text(
            identityContextLine!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typography.callout.copyWith(
              color: colors.content.textSecondary,
            ),
          ),
        if (metricParts.isNotEmpty) ...[
          SizedBox(height: hasIdentityContext ? 7 : 0),
          Wrap(
            spacing: 14,
            runSpacing: 4,
            children: [
              for (final part in metricParts)
                Text(
                  part,
                  style: typography.callout.copyWith(
                    color: colors.content.textSecondary,
                  ),
                ),
            ],
          ),
        ],
        if (scopeContextLine != null && scopeContextLine!.isNotEmpty) ...[
          const SizedBox(height: 7),
          Text(
            scopeContextLine!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typography.caption.copyWith(
              color: colors.content.textSecondary,
            ),
          ),
        ],
        if (scopeNote != null && scopeNote!.isNotEmpty) ...[
          const SizedBox(height: 5),
          Text(
            scopeNote!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typography.caption.copyWith(
              color: colors.content.textSecondary,
            ),
          ),
        ],
        if (activeScopeLabel != null && activeScopeLabel!.isNotEmpty) ...[
          const SizedBox(height: 7),
          Text(
            activeScopeLabel!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typography.caption.copyWith(
              color: colors.content.textSecondary,
            ),
          ),
        ],
        if (activeScopeIndicator != null) ...[
          const SizedBox(height: 8),
          activeScopeIndicator!,
        ],
      ],
    );
  }
}

class _MessageEvidenceSecondaryBand extends StatelessWidget {
  const _MessageEvidenceSecondaryBand({
    required this.searchConfig,
    required this.actions,
    required this.details,
  });

  final MessageEvidenceHeaderSearchConfig? searchConfig;
  final Widget? actions;
  final Widget? details;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (searchConfig != null)
          MessageEvidenceSearchControlsPresentation(
            query: searchConfig!.controller.text,
            placeholder: searchConfig!.placeholder,
            mode: searchConfig!.mode,
            onQueryChanged: (query) {
              if (searchConfig!.controller.text == query) {
                return;
              }
              searchConfig!.controller.value = TextEditingValue(
                text: query,
                selection: TextSelection.collapsed(offset: query.length),
              );
            },
            onModeChanged: searchConfig!.onModeChanged,
          ),
        if (actions != null) ...[
          SizedBox(height: searchConfig == null ? 0 : 9),
          _MessageEvidenceHeaderActionRow(child: actions!),
        ],
        if (details != null) ...[
          SizedBox(height: searchConfig == null && actions == null ? 0 : 8),
          details!,
        ],
      ],
    );
  }
}

/// Feature-owned Search controls presentation used by both legacy headers and
/// page-level Track occupants.
class MessageEvidenceSearchControlsPresentation extends ConsumerStatefulWidget {
  const MessageEvidenceSearchControlsPresentation({
    required this.query,
    required this.placeholder,
    required this.onQueryChanged,
    this.mode,
    this.onModeChanged,
    super.key,
  });

  final String query;
  final String placeholder;
  final ValueChanged<String> onQueryChanged;
  final MessageEvidenceSearchMode? mode;
  final ValueChanged<MessageEvidenceSearchMode>? onModeChanged;

  @override
  ConsumerState<MessageEvidenceSearchControlsPresentation> createState() {
    return _MessageEvidenceSearchControlsPresentationState();
  }
}

class _MessageEvidenceSearchControlsPresentationState
    extends ConsumerState<MessageEvidenceSearchControlsPresentation> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.query,
  );

  @override
  void didUpdateWidget(MessageEvidenceSearchControlsPresentation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text == widget.query) {
      return;
    }
    _controller.value = TextEditingValue(
      text: widget.query,
      selection: TextSelection.collapsed(offset: widget.query.length),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 460),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.search,
            size: MessageEvidenceHeaderTrackMetrics.searchLeadingSlotWidth,
            color: colors.content.textSecondary,
          ),
          const SizedBox(
            width: MessageEvidenceHeaderTrackMetrics.searchLeadingGap,
          ),
          Expanded(
            child: macos_ui.MacosTextField(
              controller: _controller,
              placeholder: widget.placeholder,
              clearButtonMode: macos_ui.OverlayVisibilityMode.editing,
              onChanged: widget.onQueryChanged,
            ),
          ),
          if (widget.mode != null && widget.onModeChanged != null) ...[
            const SizedBox(width: 8),
            _MessageEvidenceSearchModeToggle(
              mode: widget.mode!,
              onModeChanged: widget.onModeChanged!,
            ),
          ],
        ],
      ),
    );
  }
}

/// One stable row describing the current Search investigation and its state.
class SearchInvestigationStatusPresentation extends StatefulWidget {
  const SearchInvestigationStatusPresentation({
    required this.description,
    required this.isSearching,
    required this.style,
    this.activityDelay = const Duration(milliseconds: 175),
    super.key,
  });

  final String description;
  final bool isSearching;
  final TextStyle style;
  final Duration activityDelay;

  @override
  State<SearchInvestigationStatusPresentation> createState() {
    return _SearchInvestigationStatusPresentationState();
  }
}

class _SearchInvestigationStatusPresentationState
    extends State<SearchInvestigationStatusPresentation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _activityDelayController;
  bool _showActivity = false;

  @override
  void initState() {
    super.initState();
    _activityDelayController = AnimationController(
      vsync: this,
      duration: widget.activityDelay,
    )..addStatusListener(_handleActivityDelayStatus);
    _synchronizeActivity();
  }

  @override
  void didUpdateWidget(SearchInvestigationStatusPresentation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSearching != widget.isSearching ||
        oldWidget.description != widget.description ||
        oldWidget.activityDelay != widget.activityDelay) {
      _activityDelayController.duration = widget.activityDelay;
      _synchronizeActivity();
    }
  }

  @override
  void dispose() {
    _activityDelayController.dispose();
    super.dispose();
  }

  void _synchronizeActivity() {
    _activityDelayController.reset();
    if (!widget.isSearching) {
      _showActivity = false;
      return;
    }
    _showActivity = false;
    _activityDelayController.forward();
  }

  void _handleActivityDelayStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && widget.isSearching) {
      setState(() {
        _showActivity = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final description = _showActivity
        ? '${widget.description} · Searching...'
        : widget.description;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 460),
      child: Row(
        children: [
          SizedBox(
            width: MessageEvidenceHeaderTrackMetrics.searchLeadingSlotWidth,
            child: _showActivity
                ? const Align(
                    alignment: Alignment.centerLeft,
                    child: macos_ui.ProgressCircle(
                      radius: MessageEvidenceHeaderTrackMetrics
                          .investigationStatusIndicatorRadius,
                      semanticLabel: 'Searching',
                    ),
                  )
                : null,
          ),
          const SizedBox(
            width: MessageEvidenceHeaderTrackMetrics.searchLeadingGap,
          ),
          const SizedBox(
            width:
                MessageEvidenceHeaderTrackMetrics.searchStatusFieldChromeInset,
          ),
          Expanded(
            child: Text(
              description,
              style: widget.style,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageEvidenceSearchModeToggle extends ConsumerWidget {
  const _MessageEvidenceSearchModeToggle({
    required this.mode,
    required this.onModeChanged,
  });

  final MessageEvidenceSearchMode mode;
  final ValueChanged<MessageEvidenceSearchMode> onModeChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaces.control,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SearchModeSegment(
              label: 'AND',
              description: 'Match all terms',
              isSelected: mode == MessageEvidenceSearchMode.allTerms,
              onPressed: () {
                onModeChanged(MessageEvidenceSearchMode.allTerms);
              },
            ),
            _SearchModeSegment(
              label: 'OR',
              description: 'Match any term',
              isSelected: mode == MessageEvidenceSearchMode.anyTerm,
              onPressed: () {
                onModeChanged(MessageEvidenceSearchMode.anyTerm);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchModeSegment extends ConsumerWidget {
  const _SearchModeSegment({
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onPressed,
  });

  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return macos_ui.MacosTooltip(
      message: description,
      useMousePosition: false,
      child: Semantics(
        button: true,
        selected: isSelected,
        label: '$label — $description',
        excludeSemantics: true,
        onTap: onPressed,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onPressed,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.surfaces.selected
                    : colors.surfaces.control.withValues(alpha: 0),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Text(
                  label,
                  style: typography.caption.copyWith(
                    color: isSelected
                        ? colors.content.textPrimary
                        : colors.content.textSecondary,
                    fontWeight: FontWeight.w700,
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

class _MessageEvidenceHeaderActionRow extends StatelessWidget {
  const _MessageEvidenceHeaderActionRow({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      child: child,
    );
  }
}

class MessageEvidenceDisclosureButton extends ConsumerWidget {
  const MessageEvidenceDisclosureButton({
    required this.label,
    required this.isExpanded,
    required this.onPressed,
    super.key,
  });

  final String label;
  final bool isExpanded;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return GestureDetector(
      onTap: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isExpanded
                ? CupertinoIcons.chevron_down
                : CupertinoIcons.chevron_right,
            size: 13,
            color: colors.content.textSecondary,
          ),
          const SizedBox(width: 5),
          Text(label, style: typography.caption),
        ],
      ),
    );
  }
}
