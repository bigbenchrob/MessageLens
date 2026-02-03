import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../../../essentials/db/feature_level_providers.dart';
import '../../../../../essentials/navigation/domain/entities/features/messages_spec.dart';
import '../../../../../essentials/navigation/domain/entities/view_spec.dart';
import '../../../../../essentials/navigation/domain/navigation_constants.dart';
import '../../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../../essentials/navigation/feature_level_providers.dart';
import '../../../../../essentials/sidebar/application/cassette_rack_state_provider.dart';
import '../../../../../essentials/sidebar/feature_level_providers.dart';
import '../../../domain/spec_classes/contacts_cassette_spec.dart';
import '../../../infrastructure/repositories/recent_contacts_repository.dart';

/// Section displaying recent contacts at the top of the contact picker.
///
/// This widget shows recently accessed contacts for quick selection,
/// typically displayed above the main contact list or grouped picker.
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

        ref.watch(themeColorsProvider);
        final colors = ref.read(themeColorsProvider.notifier);

        return Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Recent contacts section
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: recents.map((recent) {
                  final isSelected = recent.participantId == chosenContactId;
                  return _RecentContactRow(
                    displayName: recent.displayName,
                    participantId: recent.participantId,
                    isSelected: isSelected,
                    cassetteIndex: cassetteIndex,
                  );
                }).toList(),
              ),
            ),

            // Divider
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 14),
              child: Container(
                height: 1,
                color: colors.lines.borderSubtle.withValues(alpha: 0.8),
              ),
            ),

            // Full contact picker
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: mainPicker,
              ),
            ),
          ],
        );
      },
      loading: () => mainPicker,
      error: (_, __) => mainPicker,
    );
  }
}

/// Row widget for a recent contact.
class _RecentContactRow extends ConsumerStatefulWidget {
  const _RecentContactRow({
    required this.displayName,
    required this.participantId,
    required this.isSelected,
    required this.cassetteIndex,
  });

  final String displayName;
  final int participantId;
  final bool isSelected;
  final int cassetteIndex;

  @override
  ConsumerState<_RecentContactRow> createState() => _RecentContactRowState();
}

class _RecentContactRowState extends ConsumerState<_RecentContactRow> {
  bool _isHovered = false;

  void _handleTap() {
    // Construct the new spec (widgets may construct specs as output)
    final newSpec = CassetteSpec.contacts(
      ContactsCassetteSpec.contactHeroSummary(
        chosenContactId: widget.participantId,
      ),
    );

    // Update the cassette rack using the index
    ref
        .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
        .replaceAtIndexAndCascade(widget.cassetteIndex, newSpec);

    // Track as recently accessed
    _trackContactAccess(widget.participantId);

    // Show messages in center panel
    _showMessages(widget.participantId);
  }

  Future<void> _trackContactAccess(int contactId) async {
    final overlayDb = await ref.read(overlayDatabaseProvider.future);
    await overlayDb.trackContactAccess(contactId);
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

    final hoverColor = colors.accents.primary.withValues(alpha: 0.15);
    final selectedColor = colors.accents.primary.withValues(alpha: 0.12);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _handleTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? selectedColor
                : _isHovered
                    ? hoverColor
                    : Colors.transparent,
            border: Border(
              bottom: BorderSide(color: colors.lines.borderSubtle, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.displayName,
                  style: typography.body.copyWith(
                    fontWeight:
                        widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.isSelected) ...[
                const SizedBox(width: 8),
                Icon(
                  CupertinoIcons.checkmark_alt,
                  size: 14,
                  color: colors.accents.primary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
