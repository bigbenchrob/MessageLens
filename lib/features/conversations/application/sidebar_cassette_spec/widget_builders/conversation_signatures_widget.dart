import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/spacing/app_spacing.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../../../config/theme/widgets/theme_widgets.dart';
import '../../../../../core/util/count_label_formatter.dart';
import '../../../../../core/util/date_label_formatter.dart';
import '../../../../../essentials/conversation_graph/feature_level_providers.dart'
    show conversationFavouritesControllerProvider;
import '../../../../../essentials/sidebar/feature_level_providers.dart'
    show sidebarFlowProvider;
import '../../../../../essentials/sidebar/presentation/view/sidebar_grouped_control_section_surface.dart';
import '../../../domain/conversation_tags/conversation_tag_display.dart';
import '../../../presentation/widgets/conversation_favourite_button.dart';
import '../../../presentation/widgets/conversation_signature_card.dart';
import '../../../presentation/widgets/conversation_signature_card_presentation.dart';
import '../../../presentation/widgets/conversation_tag_button.dart';
import '../../conversation_retrieval/conversation_retrieval_tag_token.dart';
import '../../conversation_signatures/conversation_signature_display_provider.dart'
    show
        ConversationSignatureDisplayModel,
        ConversationSignatureFilter,
        ConversationSignatureSelectedTagsRequest,
        ConversationSignatureSort,
        conversationSignatureIdsWithDuplicateChatHooks,
        conversationSignatureDisplayProvider,
        conversationSignatureFilterLabel,
        conversationSignatureSortLabel,
        favouriteConversationSignatureDisplayProvider;
import '../../conversation_tags/conversation_tags_provider.dart'
    show conversationTagsProvider;
import '../resolver_tools/conversation_navigation_actions_provider.dart';
import '../resolver_tools/conversation_signature_preferences_actions_provider.dart';
import '../resolver_tools/conversation_signature_preferences_provider.dart';

class ConversationSignaturesWidget extends ConsumerStatefulWidget {
  const ConversationSignaturesWidget({super.key});

  @override
  ConsumerState<ConversationSignaturesWidget> createState() =>
      _ConversationSignaturesWidgetState();
}

class _ConversationSignaturesWidgetState
    extends ConsumerState<ConversationSignaturesWidget> {
  late final TextEditingController _retrievalController;
  late final FocusNode _retrievalFocusNode;
  final List<ConversationRetrievalTagToken> _selectedTagTokens = [];
  var _retrievalDraft = '';

  @override
  void initState() {
    super.initState();
    _retrievalController = TextEditingController();
    _retrievalFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _retrievalController.dispose();
    _retrievalFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final cardStyle = conversationSignatureCardStyle(colors, typography);
    final preferences = ref.watch(
      conversationSignaturePreferencesControllerProvider,
    );
    final favourites = ref.watch(conversationFavouritesControllerProvider);
    final tagDefinitionsAsync = ref.watch(conversationTagsProvider);
    final favouriteConversationIds = favourites.coreConversationIds;
    final selectedTagIds = [
      for (final token in _selectedTagTokens) token.tagId,
    ];
    final selectedConversationId = ref.watch(
      sidebarFlowProvider.select((state) => state.selectedConversationId),
    );
    final browseSignaturesAsync =
        preferences.mode == ConversationSignatureMode.browse
        ? ref.watch(
            conversationSignatureDisplayProvider(
              selectedTags: ConversationSignatureSelectedTagsRequest(
                tagIds: selectedTagIds,
              ),
              filter: preferences.filter,
              sort: preferences.sort,
            ),
          )
        : null;
    final isSortEnabled =
        browseSignaturesAsync?.maybeWhen(
          data: (signatures) => signatures.length > 6,
          orElse: () => true,
        ) ??
        true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ConversationSignatureModeToggle(
          mode: preferences.mode,
          onChanged: (mode) {
            unawaited(
              ref
                  .read(
                    conversationSignaturePreferencesActionsProvider.notifier,
                  )
                  .setMode(mode),
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        if (preferences.mode == ConversationSignatureMode.browse) ...[
          _ConversationSignatureControls(
            retrievalController: _retrievalController,
            retrievalFocusNode: _retrievalFocusNode,
            retrievalDraft: _retrievalDraft,
            selectedTagTokens: _selectedTagTokens,
            tagDefinitionsAsync: tagDefinitionsAsync,
            filter: preferences.filter,
            sort: preferences.sort,
            isSortEnabled: isSortEnabled,
            onRetrievalDraftChanged: (value) {
              setState(() {
                _retrievalDraft = value;
              });
            },
            onAcceptTag: _acceptTag,
            onRemoveTag: _removeTag,
            onFilterChanged: (value) {
              unawaited(
                ref
                    .read(
                      conversationSignaturePreferencesActionsProvider.notifier,
                    )
                    .setFilter(value),
              );
            },
            onSortChanged: (value) {
              unawaited(
                ref
                    .read(
                      conversationSignaturePreferencesActionsProvider.notifier,
                    )
                    .setSort(value),
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _conversationSignatureListInset,
            ),
            child: preferences.mode == ConversationSignatureMode.favourites
                ? _ConversationSignatureListAsync(
                    signaturesAsync: ref.watch(
                      favouriteConversationSignatureDisplayProvider(
                        conversationIds: favouriteConversationIds,
                      ),
                    ),
                    emptyMessage:
                        'No favourite conversations yet.\n'
                        'Click the star beside a conversation to add it here.',
                    loadingMessage: 'Loading favourites...',
                    errorMessagePrefix: 'Unable to load favourites.',
                    selectedConversationId: selectedConversationId,
                    cardStyle: favouriteConversationSignatureCardStyle(
                      colors,
                      typography,
                    ),
                  )
                : _ConversationSignatureListAsync(
                    signaturesAsync: browseSignaturesAsync!,
                    titleContextForSignature: _titleContextForSort(
                      preferences.sort,
                    ),
                    summaryHighlightForSignature: _summaryHighlightForSort(
                      preferences.sort,
                    ),
                    highlightedMonthForSignature: _highlightedMonthForSort(
                      preferences.sort,
                    ),
                    emptyMessage: 'No matching conversations.',
                    loadingMessage: 'Loading conversations...',
                    errorMessagePrefix:
                        'Unable to load conversation signatures.',
                    selectedConversationId: selectedConversationId,
                    cardStyle: cardStyle,
                  ),
          ),
        ),
      ],
    );
  }

  void _acceptTag(ConversationRetrievalTagToken token) {
    setState(() {
      if (!_selectedTagTokens.any(
        (existing) => existing.tagId == token.tagId,
      )) {
        _selectedTagTokens.add(token);
      }
      _retrievalDraft = '';
      _retrievalController.clear();
    });
    _retrievalFocusNode.requestFocus();
  }

  void _removeTag(int tagId) {
    setState(() {
      _selectedTagTokens.removeWhere((token) => token.tagId == tagId);
    });
    _retrievalFocusNode.requestFocus();
  }
}

const double _conversationSignatureListInset = 12;
const double _conversationSignatureControlInset = 12;

class _ConversationSignatureStatus extends StatelessWidget {
  const _ConversationSignatureStatus({
    required this.message,
    required this.colors,
    required this.typography,
  });

  final String message;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: typography.caption.copyWith(color: colors.content.textSecondary),
    );
  }
}

class _ConversationSignatureListAsync extends ConsumerWidget {
  const _ConversationSignatureListAsync({
    required this.signaturesAsync,
    required this.emptyMessage,
    required this.loadingMessage,
    required this.errorMessagePrefix,
    required this.selectedConversationId,
    required this.cardStyle,
    this.summaryHighlightForSignature,
    this.highlightedMonthForSignature,
    this.titleContextForSignature,
  });

  final AsyncValue<List<ConversationSignatureDisplayModel>> signaturesAsync;
  final String emptyMessage;
  final String loadingMessage;
  final String errorMessagePrefix;
  final int? selectedConversationId;
  final ConversationSignatureCardStyle cardStyle;
  final ConversationSignatureSummaryHighlight Function(
    ConversationSignatureDisplayModel signature,
  )?
  summaryHighlightForSignature;
  final ConversationSignatureMonthMarker? Function(
    ConversationSignatureDisplayModel signature,
  )?
  highlightedMonthForSignature;
  final String? Function(ConversationSignatureDisplayModel signature)?
  titleContextForSignature;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return signaturesAsync.when(
      data: (signatures) {
        if (signatures.isEmpty) {
          return Center(
            child: _ConversationSignatureStatus(
              message: emptyMessage,
              colors: colors,
              typography: typography,
            ),
          );
        }

        final conversationIdsWithChatHooks =
            conversationSignatureIdsWithDuplicateChatHooks(signatures);

        return ListView.separated(
          itemCount: signatures.length,
          separatorBuilder: (context, index) => const SizedBox(height: 7),
          itemBuilder: (context, index) {
            final signature = signatures[index];
            return ConversationSignatureCard(
              key: ValueKey<int>(signature.conversationId),
              signature: conversationSignatureCardDataFromDisplay(
                signature,
                titleContextLabel: titleContextForSignature?.call(signature),
                summaryHighlight:
                    summaryHighlightForSignature?.call(signature) ??
                    ConversationSignatureSummaryHighlight.none,
                highlightedMonth: highlightedMonthForSignature?.call(signature),
                includeTags: true,
                includeChatHook: conversationIdsWithChatHooks.contains(
                  signature.conversationId,
                ),
              ),
              style: cardStyle,
              monthColorForMessageCount:
                  conversationSignatureMonthColorForMessageCount,
              isSelected: signature.conversationId == selectedConversationId,
              onMonthTap: (year, month, _) {
                unawaited(
                  ref
                      .read(conversationNavigationActionsProvider.notifier)
                      .selectConversationMonth(
                        conversationId: signature.conversationId,
                        monthAnchor: DateTime(year, month),
                      ),
                );
              },
              trailing: _ConversationIntentActions(
                conversationId: signature.conversationId,
              ),
              onPressed: () {
                unawaited(
                  ref
                      .read(conversationNavigationActionsProvider.notifier)
                      .selectConversation(
                        conversationId: signature.conversationId,
                      ),
                );
              },
            );
          },
        );
      },
      loading: () => Center(
        child: _ConversationSignatureStatus(
          message: loadingMessage,
          colors: colors,
          typography: typography,
        ),
      ),
      error: (error, _) => Center(
        child: _ConversationSignatureStatus(
          message: '$errorMessagePrefix $error',
          colors: colors,
          typography: typography,
        ),
      ),
    );
  }
}

class _ConversationIntentActions extends StatelessWidget {
  const _ConversationIntentActions({required this.conversationId});

  final int conversationId;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConversationTagButton(conversationId: conversationId),
        ConversationFavouriteButton(conversationId: conversationId),
      ],
    );
  }
}

class _ConversationSignatureModeToggle extends ConsumerWidget {
  const _ConversationSignatureModeToggle({
    required this.mode,
    required this.onChanged,
  });

  final ConversationSignatureMode mode;
  final ValueChanged<ConversationSignatureMode> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _conversationSignatureControlInset,
      ),
      child: AppSegmentedModeControl<ConversationSignatureMode>(
        options: ConversationSignatureMode.values,
        selectedOption: mode,
        onSelected: onChanged,
        labelBuilder: (option) {
          return switch (option) {
            ConversationSignatureMode.favourites => 'Favourites',
            ConversationSignatureMode.browse => 'Browse',
          };
        },
      ),
    );
  }
}

class _ConversationSignatureControls extends ConsumerWidget {
  const _ConversationSignatureControls({
    required this.retrievalController,
    required this.retrievalFocusNode,
    required this.retrievalDraft,
    required this.selectedTagTokens,
    required this.tagDefinitionsAsync,
    required this.filter,
    required this.sort,
    required this.isSortEnabled,
    required this.onRetrievalDraftChanged,
    required this.onAcceptTag,
    required this.onRemoveTag,
    required this.onFilterChanged,
    required this.onSortChanged,
  });

  final TextEditingController retrievalController;
  final FocusNode retrievalFocusNode;
  final String retrievalDraft;
  final List<ConversationRetrievalTagToken> selectedTagTokens;
  final AsyncValue<List<ConversationTagDisplay>> tagDefinitionsAsync;
  final ConversationSignatureFilter filter;
  final ConversationSignatureSort sort;
  final bool isSortEnabled;
  final ValueChanged<String> onRetrievalDraftChanged;
  final ValueChanged<ConversationRetrievalTagToken> onAcceptTag;
  final ValueChanged<int> onRemoveTag;
  final ValueChanged<ConversationSignatureFilter> onFilterChanged;
  final ValueChanged<ConversationSignatureSort> onSortChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final labelStyle = typography.caption.copyWith(
      color: colors.content.textTertiary,
      fontWeight: FontWeight.w500,
    );
    final valueStyle = typography.caption.copyWith(
      color: colors.content.textPrimary,
      fontWeight: FontWeight.w500,
    );
    final selectedTagIds = selectedTagTokens.map((token) => token.tagId);
    final suggestions = tagDefinitionsAsync.maybeWhen(
      data: (tags) {
        return matchingConversationTagSuggestions(
          tags: tags,
          rawQuery: retrievalDraft,
          excludedTagIds: selectedTagIds,
        ).take(4).toList();
      },
      orElse: () => const <ConversationTagDisplay>[],
    );

    return SidebarGroupedControlSectionSurface(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _conversationSignatureControlInset,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _ConversationTagRetrievalField(
                controller: retrievalController,
                focusNode: retrievalFocusNode,
                selectedTokens: selectedTagTokens,
                suggestions: suggestions,
                onChanged: onRetrievalDraftChanged,
                onAcceptTag: onAcceptTag,
                onRemoveTag: onRemoveTag,
                colors: colors,
                typography: typography,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppThemeWidgets.dropdownMenu<ConversationSignatureFilter>(
                options: ConversationSignatureFilter.values,
                selectedOption: filter,
                onSelected: onFilterChanged,
                optionLabelBuilder: conversationSignatureFilterLabel,
                leadingLabel: 'Show',
                triggerPadding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 7,
                ),
                itemPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                triggerBorderRadius: BorderRadius.circular(6),
                panelBorderRadius: BorderRadius.circular(8),
                trailingIconSize: 12,
                leadingLabelStyle: labelStyle,
                selectedValueStyle: valueStyle,
              ),
              const SizedBox(height: AppSpacing.xs),
              AppThemeWidgets.dropdownMenu<ConversationSignatureSort>(
                options: ConversationSignatureSort.values,
                selectedOption: sort,
                onSelected: onSortChanged,
                optionLabelBuilder: conversationSignatureSortLabel,
                leadingLabel: 'Sort',
                isEnabled: isSortEnabled,
                triggerPadding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 7,
                ),
                itemPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                triggerBorderRadius: BorderRadius.circular(6),
                panelBorderRadius: BorderRadius.circular(8),
                trailingIconSize: 12,
                leadingLabelStyle: labelStyle,
                selectedValueStyle: valueStyle,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConversationTagRetrievalField extends StatelessWidget {
  const _ConversationTagRetrievalField({
    required this.controller,
    required this.focusNode,
    required this.selectedTokens,
    required this.suggestions,
    required this.onChanged,
    required this.onAcceptTag,
    required this.onRemoveTag,
    required this.colors,
    required this.typography,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final List<ConversationRetrievalTagToken> selectedTokens;
  final List<ConversationTagDisplay> suggestions;
  final ValueChanged<String> onChanged;
  final ValueChanged<ConversationRetrievalTagToken> onAcceptTag;
  final ValueChanged<int> onRemoveTag;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    final hasTokens = selectedTokens.isNotEmpty;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaces.control,
        border: Border.all(color: colors.lines.borderSubtle),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasTokens) ...[
              Wrap(
                spacing: 5,
                runSpacing: 5,
                children: [
                  for (final token in selectedTokens)
                    _ConversationTagRetrievalTokenChip(
                      token: token,
                      onRemoveTag: onRemoveTag,
                      colors: colors,
                      typography: typography,
                    ),
                ],
              ),
              const SizedBox(height: 5),
            ],
            CupertinoTextField.borderless(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              onSubmitted: (_) {
                if (suggestions.isNotEmpty) {
                  onAcceptTag(
                    ConversationRetrievalTagToken.fromTag(suggestions.first),
                  );
                }
              },
              placeholder: hasTokens ? 'Add another tag' : 'Find by tag',
              placeholderStyle: typography.caption.copyWith(
                color: colors.content.textTertiary,
              ),
              style: typography.caption.copyWith(
                color: colors.content.textPrimary,
              ),
              prefix: Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Icon(
                  CupertinoIcons.tag,
                  size: 13,
                  color: colors.content.textTertiary,
                ),
              ),
            ),
            if (suggestions.isNotEmpty) ...[
              const SizedBox(height: 5),
              Wrap(
                spacing: 5,
                runSpacing: 5,
                children: [
                  for (final suggestion in suggestions)
                    _ConversationTagSuggestionButton(
                      tag: suggestion,
                      onAcceptTag: onAcceptTag,
                      colors: colors,
                      typography: typography,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ConversationTagRetrievalTokenChip extends StatelessWidget {
  const _ConversationTagRetrievalTokenChip({
    required this.token,
    required this.onRemoveTag,
    required this.colors,
    required this.typography,
  });

  final ConversationRetrievalTagToken token;
  final ValueChanged<int> onRemoveTag;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaces.selected,
        border: Border.all(color: colors.lines.borderSubtle),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 6, right: 2, top: 2, bottom: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.tag_fill,
              size: 10,
              color: colors.accents.primary,
            ),
            const SizedBox(width: 3),
            Text(
              token.label,
              style: typography.caption.copyWith(
                color: colors.content.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 2),
            CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size(16, 16),
              onPressed: () {
                onRemoveTag(token.tagId);
              },
              child: Icon(
                CupertinoIcons.xmark_circle_fill,
                size: 12,
                color: colors.content.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationTagSuggestionButton extends StatelessWidget {
  const _ConversationTagSuggestionButton({
    required this.tag,
    required this.onAcceptTag,
    required this.colors,
    required this.typography,
  });

  final ConversationTagDisplay tag;
  final ValueChanged<ConversationRetrievalTagToken> onAcceptTag;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      minimumSize: Size.zero,
      color: colors.surfaces.surface,
      borderRadius: BorderRadius.circular(999),
      onPressed: () {
        onAcceptTag(ConversationRetrievalTagToken.fromTag(tag));
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.tag,
            size: 10,
            color: colors.content.textTertiary,
          ),
          const SizedBox(width: 3),
          Text(
            tag.displayName,
            style: typography.caption.copyWith(
              color: colors.content.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

String? Function(ConversationSignatureDisplayModel signature)?
_titleContextForSort(ConversationSignatureSort sort) {
  return switch (sort) {
    ConversationSignatureSort.mostRecentlyUpdated => _todayLastUpdatedTime,
    ConversationSignatureSort.longestRunning => _firstToLastSpanContext,
    _ => null,
  };
}

ConversationSignatureSummaryHighlight Function(
  ConversationSignatureDisplayModel signature,
)
_summaryHighlightForSort(ConversationSignatureSort sort) {
  return switch (sort) {
    ConversationSignatureSort.mostRecentlyUpdated =>
      _recentUpdateSummaryHighlight,
    ConversationSignatureSort.mostTotalMessages =>
      (_) => ConversationSignatureSummaryHighlight.messageCount,
    ConversationSignatureSort.byDateOfCreation =>
      (_) => ConversationSignatureSummaryHighlight.firstDate,
    ConversationSignatureSort.startedMostRecently =>
      (_) => ConversationSignatureSummaryHighlight.firstDate,
    ConversationSignatureSort.longestRunning =>
      (_) => ConversationSignatureSummaryHighlight.dateRange,
    ConversationSignatureSort.dormant =>
      (_) => ConversationSignatureSummaryHighlight.none,
  };
}

ConversationSignatureSummaryHighlight _recentUpdateSummaryHighlight(
  ConversationSignatureDisplayModel signature,
) {
  if (_todayLastUpdatedTime(signature) != null) {
    return ConversationSignatureSummaryHighlight.none;
  }
  return ConversationSignatureSummaryHighlight.lastDate;
}

ConversationSignatureMonthMarker? Function(
  ConversationSignatureDisplayModel signature,
)?
_highlightedMonthForSort(ConversationSignatureSort sort) {
  return switch (sort) {
    ConversationSignatureSort.dormant => _lastMessageMonthMarker,
    _ => null,
  };
}

ConversationSignatureMonthMarker? _lastMessageMonthMarker(
  ConversationSignatureDisplayModel signature,
) {
  final parsed = DateLabelFormatter.parseIso(
    signature.lastMessageAtUtc,
  )?.toLocal();
  if (parsed == null) {
    return null;
  }
  return ConversationSignatureMonthMarker(
    year: parsed.year,
    month: parsed.month,
  );
}

String? _todayLastUpdatedTime(ConversationSignatureDisplayModel signature) {
  return DateLabelFormatter.localTimeIfTodayFromIso(signature.lastMessageAtUtc);
}

String? _firstToLastSpanContext(ConversationSignatureDisplayModel signature) {
  final first = DateLabelFormatter.parseIso(
    signature.firstMessageAtUtc,
  )?.toLocal();
  final last = DateLabelFormatter.parseIso(
    signature.lastMessageAtUtc,
  )?.toLocal();
  if (first == null || last == null || last.isBefore(first)) {
    return null;
  }
  final months = (last.year - first.year) * 12 + last.month - first.month;
  return CountLabelFormatter.formatNoun(
    count: months,
    singular: 'month',
    plural: 'months',
  );
}
