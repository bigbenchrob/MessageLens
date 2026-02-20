import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/spacing/app_spacing.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../../../essentials/db/feature_level_providers.dart';
import '../../../../../essentials/navigation/domain/entities/view_spec.dart';
import '../../../../../essentials/navigation/domain/navigation_constants.dart';
import '../../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../../essentials/navigation/feature_level_providers.dart';
import '../../../../../essentials/sidebar/application/cassette_rack_state_provider.dart';
import '../../../../../essentials/sidebar/feature_level_providers.dart';
import '../../../infrastructure/repositories/recent_contacts_repository.dart';
import '../../../presentation/widgets/contact_initial_badge.dart';

/// Section displaying recent contacts at the top of the contact picker.
///
/// This widget shows recently accessed contacts for quick selection,
/// typically displayed above the main contact list or grouped picker.
///
/// ## Design Guidelines
///
/// The recents section is a **lightweight suggestion**, not a secondary picker.
/// It should communicate: "You can pick a contact from the picker below, but
/// here are a few you accessed recently if that helps."
///
/// Visual treatment:
/// - No card/container - just inline content
/// - "Recents" label in caption style with tertiary color
/// - Contact rows with reduced contrast (textSecondary)
/// - Spacing between rows instead of heavy dividers
/// - Extra padding before the main picker to establish separation
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// Widget builders:
/// - Accept fully-decided inputs (not specs)
/// - May use `ref.watch()` for reactive updates
/// - Construct specs only on user interaction (output, not interpretation)
class RecentContactsSection extends ConsumerWidget {
  const RecentContactsSection({
    super.key,
    required this.chosenContactId,
    required this.cassetteIndex,
    required this.mainPicker,
  });

  /// Currently selected contact ID, if any.
  final int? chosenContactId;

  /// Position in the cassette rack (for updates via replaceAtIndexAndCascade).
  final int cassetteIndex;

  /// The main picker widget to display below the recent contacts.
  final Widget mainPicker;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRecents = ref.watch(recentContactsProvider);

    return asyncRecents.when(
      data: (recents) {
        if (recents.isEmpty) {
          return mainPicker;
        }

        final typography = ref.watch(themeTypographyProvider);

        return Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Recent contacts section - lightweight suggestion, not a card
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.md,
                right: AppSpacing.md,
                top: AppSpacing.xs,
                bottom: AppSpacing.md, // Increased spacing before picker
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // "RECENTS" section label — whispers "section label", not peer
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      'RECENTS',
                      style: typography.pickerSectionLabel,
                    ),
                  ),

                  // Recent contact rows with initial badges
                  ...recents.asMap().entries.map((entry) {
                    final index = entry.key;
                    final recent = entry.value;
                    final isSelected = recent.participantId == chosenContactId;
                    final isLast = index == recents.length - 1;

                    return _RecentContactRow(
                      displayName: recent.displayName,
                      participantId: recent.participantId,
                      isSelected: isSelected,
                      cassetteIndex: cassetteIndex,
                      showDivider: !isLast,
                    );
                  }),
                ],
              ),
            ),

            // Full contact picker
            Expanded(child: mainPicker),
          ],
        );
      },
      loading: () => mainPicker,
      error: (_, __) => mainPicker,
    );
  }
}

/// Row widget for a recent contact.
///
/// Lightweight styling to read as a helpful suggestion:
/// - Regular weight, slightly reduced contrast (textSecondary)
/// - Subtle hover highlight
/// - Minimal spacing between rows (no heavy dividers)
class _RecentContactRow extends ConsumerStatefulWidget {
  const _RecentContactRow({
    required this.displayName,
    required this.participantId,
    required this.isSelected,
    required this.cassetteIndex,
    this.showDivider = false,
  });

  final String displayName;
  final int participantId;
  final bool isSelected;
  final int cassetteIndex;
  final bool showDivider;

  @override
  ConsumerState<_RecentContactRow> createState() => _RecentContactRowState();
}

class _RecentContactRowState extends ConsumerState<_RecentContactRow> {
  bool _isHovered = false;

  void _handleTap() {
    // Replace the info card (one level up) with the chosen-contact variant.
    // The info card's cascade topology will produce:
    //   infoCard(chosenContact) → selectionControl → heroSummary → heatMap
    final infoCardIndex = widget.cassetteIndex - 1;
    final newSpec = CassetteSpec.contactsInfo(
      ContactsInfoCassetteSpec.infoCard(
        key: ContactsInfoKey.chosenContact,
        chosenContactId: widget.participantId,
      ),
    );

    ref
        .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
        .replaceAtIndexAndCascade(infoCardIndex, newSpec);

    // Track as recently accessed
    _trackContactAccess(widget.participantId);

    // Show messages in center panel
    _showMessages(widget.participantId);
  }

  Future<void> _trackContactAccess(int contactId) async {
    final overlayDb = await ref.read(overlayDatabaseProvider.future);
    await overlayDb.trackContactAccess(contactId);
    // Invalidate to refresh the recents list
    ref.invalidate(recentContactsProvider);
  }

  void _showMessages(int contactId) {
    ref
        .read(panelsViewStateProvider(SidebarMode.messages).notifier)
        .show(
          panel: WindowPanel.center,
          spec: ViewSpec.messages(
            MessagesSpec.forContact(contactId: contactId, scrollToDate: null),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    // Very subtle hover - just enough to show interactivity
    final hoverColor = colors.surfaces.hover;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _handleTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _isHovered ? hoverColor : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                ContactInitialBadge(displayName: widget.displayName),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.displayName,
                    style: typography.body.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: colors.content.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                if (widget.isSelected) ...[
                  const SizedBox(width: 6),
                  Icon(
                    CupertinoIcons.checkmark_alt,
                    size: 12,
                    color: colors.accents.primary.withValues(alpha: 0.7),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
