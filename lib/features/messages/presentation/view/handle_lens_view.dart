import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../config/theme/widgets/buttons/buttons.dart';
import '../../../../essentials/search/application/message_text_search_query.dart';
import '../../../contacts/feature_level_providers.dart'
    show ContactPickerDialog;
import '../../../handles/domain/spec_classes/handles_cassette_spec.dart';
import '../../../handles/feature_level_providers.dart'
    show
        HandleSourcePresentation,
        handleSourcePresentationProvider,
        handleSourceReviewActionsProvider;
import '../../application/handle_lens/handle_lens_investigation_actions_provider.dart';
import '../../application/handle_lens/handle_lens_session_provider.dart';
import '../../application/message_evidence/message_evidence_spine_provider.dart';
import '../../domain/message_evidence/message_evidence_scope.dart';
import '../../domain/message_evidence/message_evidence_search_mode.dart';
import '../view_model/handle_investigation_presentation.dart';
import '../view_model/handle_lens_header_labels.dart';
import '../widgets/message_evidence/message_evidence_header.dart';
import '../widgets/message_evidence/message_evidence_idle_view.dart';
import '../widgets/message_evidence/message_evidence_timeline_view.dart';

/// Triage view for a single stray handle.
///
/// Shows a header with the handle value, three action buttons (Create Contact,
/// Link to Existing, Dismiss), and a shared graph-backed message evidence
/// timeline for identifying the correspondent.
class HandleLensView extends HookConsumerWidget {
  const HandleLensView({
    required this.handleId,
    required this.investigation,
    super.key,
  });

  final int handleId;
  final StrayHandleInvestigation investigation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = _readThemeColors(ref);
    final typography = ref.watch(themeTypographyProvider);
    final asyncSourcePresentation = ref.watch(
      handleSourcePresentationProvider(handleId: handleId),
    );
    final session = ref.watch(handleLensSessionProvider(handleId: handleId));
    final sessionActions = ref.read(
      handleLensSessionProvider(handleId: handleId).notifier,
    );
    final searchController = useTextEditingController(text: session.query);

    if (searchController.text != session.query) {
      searchController.value = TextEditingValue(
        text: session.query,
        selection: TextSelection.collapsed(offset: session.query.length),
      );
    }

    useEffect(() {
      void listener() {
        sessionActions.setQuery(searchController.text);
      }

      searchController.addListener(listener);
      return () {
        searchController.removeListener(listener);
      };
    }, [searchController]);

    final sourcePresentation = asyncSourcePresentation.valueOrNull;

    return MacosScaffold(
      children: [
        ContentArea(
          builder: (context, scrollController) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _HandleLensEvidencePane(
                    handleId: handleId,
                    investigation: investigation,
                    sourcePresentation: sourcePresentation,
                    searchController: searchController,
                    searchQuery: session.query,
                    searchMode: session.searchMode,
                    onSearchModeChanged: sessionActions.setSearchMode,
                    actions: HandleLensActionBar(handleId: handleId),
                    details: session.isCreatingContact
                        ? HandleLensCreateContactForm(
                            handleId: handleId,
                            typography: typography,
                            errorColor: colors.buttons.destructiveForeground,
                          )
                        : null,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

ThemeColors _readThemeColors(WidgetRef ref) {
  return ref.read(themeColorsProvider.notifier);
}

// =============================================================================
// Action bar
// =============================================================================

class HandleLensActionBar extends ConsumerWidget {
  const HandleLensActionBar({required this.handleId, super.key});

  final int handleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(handleLensSessionProvider(handleId: handleId));
    final sessionActions = ref.read(
      handleLensSessionProvider(handleId: handleId).notifier,
    );
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        AppHeaderActionButton(
          icon: session.isCreatingContact
              ? CupertinoIcons.xmark
              : CupertinoIcons.person_add,
          label: session.isCreatingContact ? 'Cancel' : 'Create Contact',
          isEnabled: !session.isBusy,
          onPressed: sessionActions.toggleCreateContact,
        ),
        AppHeaderActionButton(
          icon: CupertinoIcons.link,
          label: 'Link to Existing',
          isEnabled: !session.isBusy,
          onPressed: () => _linkToExisting(context, ref),
        ),
        AppHeaderActionButton(
          icon: CupertinoIcons.checkmark_circle,
          label: 'Dismiss',
          isEnabled: !session.isBusy,
          onPressed: () => _dismiss(ref),
        ),
      ],
    );
  }

  Future<void> _linkToExisting(BuildContext context, WidgetRef ref) async {
    final participantId = await ContactPickerDialog.show(context);
    if (participantId == null) {
      return;
    }

    final sessionActions = ref.read(
      handleLensSessionProvider(handleId: handleId).notifier,
    );
    sessionActions.setBusy(isBusy: true);
    try {
      final failureMessage = await ref
          .read(handleSourceReviewActionsProvider.notifier)
          .associateSourceWithExistingContact(
            handleId: handleId,
            participantId: participantId,
          );
      sessionActions.setErrorMessage(failureMessage);
    } finally {
      sessionActions.setBusy(isBusy: false);
    }
  }

  Future<void> _dismiss(WidgetRef ref) async {
    final sessionActions = ref.read(
      handleLensSessionProvider(handleId: handleId).notifier,
    );
    sessionActions.setBusy(isBusy: true);
    try {
      final failureMessage = await ref
          .read(handleLensInvestigationActionsProvider.notifier)
          .dismissCurrentSource(handleId: handleId);
      sessionActions.setErrorMessage(failureMessage);
    } finally {
      sessionActions.setBusy(isBusy: false);
    }
  }
}

// =============================================================================
// Inline create contact form
// =============================================================================

class HandleLensCreateContactForm extends HookConsumerWidget {
  const HandleLensCreateContactForm({
    required this.handleId,
    required this.typography,
    required this.errorColor,
    super.key,
  });

  final int handleId;
  final ThemeTypography typography;
  final Color errorColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final session = ref.watch(handleLensSessionProvider(handleId: handleId));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: MacosTextField(
                controller: nameController,
                placeholder: 'Contact name...',
                autofocus: true,
                onSubmitted: (_) => _submit(ref, nameController),
              ),
            ),
            const SizedBox(width: 8),
            PushButton(
              controlSize: ControlSize.regular,
              onPressed: session.isBusy
                  ? null
                  : () => _submit(ref, nameController),
              child: session.isBusy
                  ? const CupertinoActivityIndicator()
                  : const Text('Create & Link'),
            ),
          ],
        ),
        if (session.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              session.errorMessage!,
              style: typography.caption.copyWith(color: errorColor),
            ),
          ),
      ],
    );
  }

  Future<void> _submit(
    WidgetRef ref,
    TextEditingController nameController,
  ) async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      return;
    }

    final sessionActions = ref.read(
      handleLensSessionProvider(handleId: handleId).notifier,
    );
    sessionActions.setErrorMessage(null);
    sessionActions.setBusy(isBusy: true);
    try {
      final failureMessage = await ref
          .read(handleSourceReviewActionsProvider.notifier)
          .createContactAndAssociateSource(
            handleId: handleId,
            displayName: name,
          );

      if (failureMessage != null) {
        sessionActions.setErrorMessage(failureMessage);
        return;
      }

      sessionActions.finishCreatingContact();
      nameController.clear();
    } finally {
      sessionActions.setBusy(isBusy: false);
    }
  }
}

class _HandleLensEvidencePane extends ConsumerWidget {
  const _HandleLensEvidencePane({
    required this.handleId,
    required this.investigation,
    required this.sourcePresentation,
    required this.searchController,
    required this.searchQuery,
    required this.searchMode,
    required this.onSearchModeChanged,
    required this.actions,
    this.details,
  });

  final int handleId;
  final StrayHandleInvestigation investigation;
  final HandleSourcePresentation? sourcePresentation;
  final TextEditingController searchController;
  final String searchQuery;
  final MessageEvidenceSearchMode searchMode;
  final ValueChanged<MessageEvidenceSearchMode> onSearchModeChanged;
  final Widget actions;
  final Widget? details;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investigationPresentation = handleInvestigationPresentation(
      investigation,
    );
    final evidenceScope = HandleMessagesEvidenceScope(handleId: handleId);
    final searchIntent = MessageTextSearchQuery.parse(
      searchQuery,
    ).executionIntent;
    final displayQuery = searchIntent.isExecutable ? searchQuery.trim() : '';
    final skeletonAsync = ref.watch(
      messageEvidenceTimelineSkeletonProvider(scope: evidenceScope),
    );
    final matchingIdsAsync = !searchIntent.isExecutable
        ? null
        : ref.watch(
            messageEvidenceTextMatchIdsProvider(
              scope: evidenceScope,
              searchIntent: searchIntent,
              mode: searchMode,
            ),
          );

    return skeletonAsync.when(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: true,
      data: (skeleton) {
        return MessageEvidenceTimelineView(
          evidenceScope: evidenceScope,
          skeleton: skeleton,
          headerData: MessageEvidenceHeaderModel(
            title: investigationPresentation.panelTitle,
            identityContextLine:
                sourcePresentation?.primaryDisplayLabel ?? 'Loading source...',
            dateRangeLabel: handleLensDateSpan(skeleton.entries),
            countLabel: handleLensCountLabel(
              totalCount: (sourcePresentation?.messageCount ?? 0) == 0
                  ? skeleton.totalCount
                  : sourcePresentation!.messageCount,
              query: displayQuery,
              matchingIds: matchingIdsAsync?.valueOrNull,
              isMatchingLoaded: matchingIdsAsync?.hasValue ?? false,
            ),
            activeScopeLabel: displayQuery.isEmpty
                ? null
                : 'Message text contains "$displayQuery"',
            searchConfig: MessageEvidenceHeaderSearchConfig(
              controller: searchController,
              placeholder: 'Search messages from this handle',
              mode: searchMode,
              onModeChanged: onSearchModeChanged,
            ),
            actions: actions,
            details: details,
          ),
          emptyMessage: 'No messages found for this handle.',
          highlightQuery: searchQuery,
          useFixedPanelFrame: true,
        );
      },
      loading: () => MessageEvidenceIdleView(
        headerData: MessageEvidenceHeaderModel(
          title: investigationPresentation.panelTitle,
          identityContextLine:
              sourcePresentation?.primaryDisplayLabel ?? 'Loading source...',
        ),
        content: const Center(child: ProgressCircle()),
        useFixedPanelFrame: true,
      ),
      error: (error, stackTrace) => MessageEvidenceIdleView(
        headerData: MessageEvidenceHeaderModel(
          title: investigationPresentation.panelTitle,
          identityContextLine:
              sourcePresentation?.primaryDisplayLabel ??
              'Unable to load source',
        ),
        content: Center(child: Text('Unable to load handle evidence: $error')),
        useFixedPanelFrame: true,
      ),
    );
  }
}
