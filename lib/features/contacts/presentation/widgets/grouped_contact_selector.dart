import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart'
    show ControlSize, MacosIcon, ProgressCircle, PushButton;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme_typography.dart';

import '../../application/sidebar_cassette_spec/resolver_tools/filtered_picker_sections_provider.dart';
import '../../application/sidebar_cassette_spec/resolver_tools/unified_picker_sections_provider.dart';
import '../../infrastructure/repositories/contacts_list_repository.dart'
    show ContactSummary;
import 'contact_highlight_row.dart';
import 'picker_filter_toggle.dart';

/// Smart header that can show either the full picker or the compact lozenge.
class SmartContactPickerHeader extends ConsumerWidget {
  const SmartContactPickerHeader({
    super.key,
    required this.contacts,
    required this.selectedParticipantId,
    required this.onContactSelected,
    required this.isCollapsed,
    this.onLozengeTap,
    this.maxHeight,
  });

  final List<ContactSummary> contacts;
  final int? selectedParticipantId;
  final ValueChanged<int> onContactSelected;
  final bool isCollapsed;
  final VoidCallback? onLozengeTap;
  final double? maxHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedContact = _findContact(contacts, selectedParticipantId);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      child: isCollapsed
          ? ContactLozenge(
              key: const ValueKey('contactLozenge'),
              label: selectedContact?.displayName ?? 'Select a contact',
              onTap: onLozengeTap,
            )
          : FullContactPicker(
              key: const ValueKey('fullContactPicker'),
              selectedParticipantId: selectedParticipantId,
              onContactSelected: onContactSelected,
              maxHeight: maxHeight,
            ),
    );
  }
}

/// Full picker surface with grouped list.
class FullContactPicker extends ConsumerWidget {
  const FullContactPicker({
    super.key,
    required this.selectedParticipantId,
    required this.onContactSelected,
    this.maxHeight,
  });

  final int? selectedParticipantId;
  final ValueChanged<int> onContactSelected;
  final double? maxHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupedAsync = ref.watch(filteredPickerSectionsProvider);
    // Watch the brightness state to trigger rebuilds
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeightOverride = maxHeight;
        final hasBoundedHeight =
            maxHeightOverride != null || constraints.maxHeight.isFinite;

        final pickerContent = groupedAsync.when(
          data: (unified) {
            if (unified.sections.isEmpty) {
              return const _GroupedEmptyState();
            }
            return GroupedContactsPicker(
              unified: unified,
              selectedParticipantId: selectedParticipantId,
              onContactSelected: onContactSelected,
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: ProgressCircle()),
          ),
          error: (error, _) => _GroupedSelectorError(
            message: '$error',
            onRetry: () {
              ref.invalidate(filteredPickerSectionsProvider);
            },
          ),
        );

        final decorated = Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.surfaces.control,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.lines.borderSubtle, width: 0.5),
          ),
          child: Column(
            mainAxisSize: hasBoundedHeight
                ? MainAxisSize.max
                : MainAxisSize.min,
            children: [
              const PickerFilterToggle(),
              if (hasBoundedHeight)
                Expanded(child: pickerContent)
              else
                pickerContent,
            ],
          ),
        );

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          child: hasBoundedHeight
              ? SizedBox(
                  height: maxHeightOverride ?? constraints.maxHeight,
                  child: decorated,
                )
              : decorated,
        );
      },
    );
  }
}

/// Compact lozenge shown when the header is collapsed.
class ContactLozenge extends ConsumerWidget {
  const ContactLozenge({super.key, required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the brightness state to trigger rebuilds
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    const radius = 12.0;

    // Slightly smaller horizontal margin prevents the halo from clipping
    // if the parent sliver has tight bounds.
    const outerMargin = EdgeInsets.symmetric(horizontal: 12, vertical: 2);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: outerMargin,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 1) Soft halo + drop shadow (creates the "floating" feel)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius + 2),
                  boxShadow: [
                    // Halo glow - uses surface color so busy content never touches edges
                    BoxShadow(
                      color: colors.surfaces.panel.withValues(alpha: 0.85),
                      blurRadius: 6,
                      spreadRadius: 1.5,
                    ),
                    // Natural shadow for elevation
                    BoxShadow(
                      color: colors.overlays.shadow.withValues(alpha: 0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
              ),
            ),

            // 2) Frosted surface with a hairline border
            ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaces.surfaceRaised.withValues(
                      alpha: 0.70,
                    ),
                    borderRadius: BorderRadius.circular(radius),
                    border: Border.all(
                      color: colors.lines.borderSubtle.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      MacosIcon(
                        CupertinoIcons.person_crop_circle,
                        size: 16,
                        color: colors.content.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: typography.body.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.content.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// /// Compact lozenge shown when the header is collapsed (Phase 4).
// class ContactLozenge extends StatelessWidget {
//   const ContactLozenge({
//     super.key,
//     required this.label,
//     this.onTap,
//   });

//   final String label;
//   final VoidCallback? onTap;

//   @override
//   Widget build(BuildContext context) {
//     final theme = MacosTheme.of(context);
//     return GestureDetector(
//       onTap: onTap,
//       behavior: HitTestBehavior.opaque,
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 12),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//         decoration: BoxDecoration(
//           color: theme.canvasColor,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: theme.dividerColor.withValues(alpha: 0.6),
//           ),
//           boxShadow: const [
//             BoxShadow(
//               color: Color(0x26000000),
//               offset: Offset(0, 2),
//               blurRadius: 6,
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             const MacosIcon(
//               CupertinoIcons.person_crop_circle,
//               size: 16,
//               color: CupertinoColors.secondaryLabel,
//             ),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 label,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: theme.typography.body.copyWith(
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

const double _kLetterSlotHeight = 18;
const double _kPickerMinHeight = 160;
const double _kPickerMaxHeight = 360;
const double _kJumpBarWidth = 24;

// NEW: integrated jump bar
class GroupedContactsPicker extends ConsumerStatefulWidget {
  const GroupedContactsPicker({
    super.key,
    required this.unified,
    required this.selectedParticipantId,
    required this.onContactSelected,
  });

  final UnifiedPickerSections unified;
  final int? selectedParticipantId;
  final ValueChanged<int> onContactSelected;

  @override
  ConsumerState<GroupedContactsPicker> createState() =>
      _GroupedContactsPickerState();
}

class _GroupedContactsPickerState extends ConsumerState<GroupedContactsPicker> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  String? _activeLetter;
  bool _isScrollable = false;

  List<String> get _letters => widget.unified.alphabeticalLetters;

  @override
  void initState() {
    super.initState();
    _itemPositionsListener.itemPositions.addListener(_handlePositionsChanged);
  }

  @override
  void dispose() {
    _itemPositionsListener.itemPositions.removeListener(
      _handlePositionsChanged,
    );
    super.dispose();
  }

  void _handlePositionsChanged() {
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty || _letters.isEmpty) {
      return;
    }

    final visiblePositions =
        positions
            .where((position) => position.itemTrailingEdge > 0)
            .toList(growable: false)
          ..sort((a, b) => a.index.compareTo(b.index));

    if (visiblePositions.isEmpty) {
      return;
    }

    // Determine if the list is scrollable: not all sections fit in the viewport.
    final totalSections = widget.unified.sections.length;
    final allVisible =
        visiblePositions.length >= totalSections &&
        visiblePositions.first.itemLeadingEdge >= 0 &&
        visiblePositions.last.itemTrailingEdge <= 1.0;
    final scrollable = !allVisible;

    // Map section index to alphabetical letter, accounting for
    // non-alphabetical sections (FAVORITES, RECENTS) at the top.
    final firstVisibleIndex = visiblePositions.first.index;
    final offset = widget.unified.alphabeticalStartIndex;
    final letterIndex = firstVisibleIndex - offset;

    String? newLetter;
    if (letterIndex >= 0 && letterIndex < _letters.length) {
      newLetter = _letters[letterIndex];
    }

    if (newLetter != _activeLetter || scrollable != _isScrollable) {
      setState(() {
        _activeLetter = newLetter;
        _isScrollable = scrollable;
      });
    }
  }

  void _scrollToLetter(String letter) {
    final letterIndex = _letters.indexOf(letter);
    if (letterIndex == -1) {
      return;
    }

    // Offset by the number of non-alphabetical sections at the top.
    final sectionIndex = widget.unified.alphabeticalStartIndex + letterIndex;

    _itemScrollController.scrollTo(
      index: sectionIndex,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch the brightness state to trigger rebuilds
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedHeight = constraints.maxHeight.isFinite;
        final availableHeight = hasBoundedHeight
            ? constraints.maxHeight
            : _calculatePickerHeight(_letters.length);
        final jumpBarHeight = _calculatePickerHeight(_letters.length);

        final list = SizedBox(
          height: availableHeight,
          child: _GroupedContactsList(
            unified: widget.unified,
            selectedParticipantId: widget.selectedParticipantId,
            onContactSelected: widget.onContactSelected,
            controller: _itemScrollController,
            positionsListener: _itemPositionsListener,
          ),
        );

        return SizedBox(
          height: availableHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ColoredBox(
                    color: colors.surfaces.control,
                    child: list,
                  ),
                ),
              ),
              if (_isScrollable) ...[
                const SizedBox(width: 8),
                Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: _kJumpBarWidth,
                    height: jumpBarHeight,
                    child: _JumpBar(
                      letters: _letters,
                      activeLetter: _activeLetter,
                      onLetterTap: _scrollToLetter,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

double _calculatePickerHeight(int letterCount) {
  if (letterCount == 0) {
    return _kPickerMinHeight;
  }
  final base = letterCount * _kLetterSlotHeight;
  final num clamped = base.clamp(_kPickerMinHeight, _kPickerMaxHeight);
  return clamped.toDouble();
}

class _GroupedEmptyState extends ConsumerWidget {
  const _GroupedEmptyState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the brightness state to trigger rebuilds
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    return Center(
      child: Text(
        'No contacts available',
        style: TextStyle(color: colors.content.textSecondary, fontSize: 13),
      ),
    );
  }
}

class _GroupedContactsList extends StatefulWidget {
  const _GroupedContactsList({
    required this.unified,
    required this.selectedParticipantId,
    required this.onContactSelected,
    required this.controller,
    required this.positionsListener,
  });

  final UnifiedPickerSections unified;
  final int? selectedParticipantId;
  final ValueChanged<int> onContactSelected;
  final ItemScrollController controller;
  final ItemPositionsListener positionsListener;

  @override
  State<_GroupedContactsList> createState() => _GroupedContactsListState();
}

class _GroupedContactsListState extends State<_GroupedContactsList> {
  @override
  Widget build(BuildContext context) {
    final sections = widget.unified.sections;

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: ScrollablePositionedList.builder(
        itemCount: sections.length,
        itemScrollController: widget.controller,
        itemPositionsListener: widget.positionsListener,
        itemBuilder: (context, index) {
          return _ContactGroupSection(
            section: sections[index],
            allFavoriteIds: widget.unified.allFavoriteIds,
            selectedParticipantId: widget.selectedParticipantId,
            onContactSelected: widget.onContactSelected,
          );
        },
      ),
    );
  }
}

class _JumpBar extends ConsumerStatefulWidget {
  const _JumpBar({
    required this.letters,
    required this.activeLetter,
    required this.onLetterTap,
  });

  final List<String> letters;
  final String? activeLetter;
  final ValueChanged<String> onLetterTap;

  @override
  ConsumerState<_JumpBar> createState() => _JumpBarState();
}

class _JumpBarState extends ConsumerState<_JumpBar> {
  String? _hoveredLetter;

  @override
  Widget build(BuildContext context) {
    if (widget.letters.isEmpty) {
      return const SizedBox(width: _kJumpBarWidth);
    }

    // Watch the brightness state to trigger rebuilds
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : _calculatePickerHeight(widget.letters.length);
        final letterHeight = height / widget.letters.length;

        return Column(
          children: [
            for (var i = 0; i < widget.letters.length; i++)
              MouseRegion(
                key: ValueKey('jumpBarLetter_${widget.letters[i]}'),
                onEnter: (_) => setState(() {
                  _hoveredLetter = widget.letters[i];
                }),
                onExit: (_) => setState(() {
                  if (_hoveredLetter == widget.letters[i]) {
                    _hoveredLetter = null;
                  }
                }),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => widget.onLetterTap(widget.letters[i]),
                  child: Container(
                    height: letterHeight,
                    alignment: Alignment.center,
                    decoration: _letterDecoration(
                      colors: colors,
                      letter: widget.letters[i],
                      activeLetter: widget.activeLetter,
                      hoveredLetter: _hoveredLetter,
                    ),
                    child: Text(
                      widget.letters[i],
                      style: typography.caption1.copyWith(
                        color: widget.letters[i] == widget.activeLetter
                            ? colors.buttons.primaryForeground
                            : colors.content.textTertiary,
                        fontWeight: widget.letters[i] == widget.activeLetter
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

BoxDecoration _letterDecoration({
  required ThemeColors colors,
  required String letter,
  required String? activeLetter,
  required String? hoveredLetter,
}) {
  final isActive = letter == activeLetter;
  final isHovered = letter == hoveredLetter;

  final color = isActive
      ? colors.accents.primary.withValues(alpha: 0.85)
      : isHovered
      ? colors.surfaces.hover
      : Colors.transparent;

  return BoxDecoration(color: color, borderRadius: BorderRadius.circular(4));
}

class _GroupedSelectorError extends ConsumerWidget {
  const _GroupedSelectorError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the brightness state to trigger rebuilds
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const MacosIcon(
          CupertinoIcons.exclamationmark_triangle,
          color: CupertinoColors.systemYellow,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text('Unable to load grouped contacts', style: typography.caption1),
        const SizedBox(height: 4),
        Text(
          message,
          style: typography.caption2.copyWith(
            color: colors.content.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        PushButton(
          controlSize: ControlSize.small,
          onPressed: onRetry,
          child: const Text('Retry'),
        ),
      ],
    );
  }
}

class _ContactGroupSection extends ConsumerWidget {
  const _ContactGroupSection({
    required this.section,
    required this.allFavoriteIds,
    required this.selectedParticipantId,
    required this.onContactSelected,
  });

  final PickerSection section;
  final Set<int> allFavoriteIds;
  final int? selectedParticipantId;
  final ValueChanged<int> onContactSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = ref.watch(themeTypographyProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section header — same visual grammar for all sections
          Padding(
            padding: const EdgeInsets.only(
              left: 8,
              right: 8,
              top: 4,
              bottom: 4,
            ),
            child: Text(section.label, style: typography.pickerSectionLabel),
          ),
          ...section.contacts.map(
            (contact) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: _ContactListItem(
                contact: contact,
                showFavoriteIndicator: allFavoriteIds.contains(
                  contact.participantId,
                ),
                selected: contact.participantId == selectedParticipantId,
                onTap: () => onContactSelected(contact.participantId),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactListItem extends StatelessWidget {
  const _ContactListItem({
    required this.contact,
    required this.selected,
    required this.onTap,
    this.showFavoriteIndicator = false,
  });

  final ContactSummary contact;
  final bool selected;
  final VoidCallback onTap;
  final bool showFavoriteIndicator;

  @override
  Widget build(BuildContext context) {
    return ContactHighlightRow(
      displayName: contact.displayName,
      shortName: contact.shortName,
      showFavoriteIndicator: showFavoriteIndicator,
      onTap: onTap,
    );
  }
}

ContactSummary? _findContact(
  List<ContactSummary> contacts,
  int? participantId,
) {
  if (participantId == null) {
    return null;
  }
  for (final contact in contacts) {
    if (contact.participantId == participantId) {
      return contact;
    }
  }
  return null;
}
