import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../config/theme/colors/theme_colors.dart';

import '../../application_pre_cassette/contacts_list_provider.dart';
import '../../application_pre_cassette/grouped_contacts_provider.dart';
import 'contact_highlight_row.dart';

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
    final groupedAsync = ref.watch(groupedContactsProvider);
    // Watch the brightness state to trigger rebuilds
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeightOverride = maxHeight;
        final hasBoundedHeight =
            maxHeightOverride != null || constraints.maxHeight.isFinite;

        Widget buildPicker(Widget child) {
          if (hasBoundedHeight) {
            final height = (maxHeightOverride ?? constraints.maxHeight).clamp(
              220.0,
              600.0,
            );
            return Expanded(
              child: SizedBox(height: height, child: child),
            );
          }
          return Expanded(child: child);
        }

        final pickerContent = groupedAsync.when(
          data: (grouped) {
            if (grouped.availableLetters.isEmpty) {
              return const _GroupedEmptyState();
            }
            return GroupedContactsPicker(
              grouped: grouped,
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
              ref.invalidate(groupedContactsProvider);
            },
          ),
        );

        final column = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [buildPicker(pickerContent)],
        );

        final decorated = Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.surfaces.control,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.lines.borderSubtle, width: 0.5),
          ),
          child: column,
        );

        final withMargin = Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          child: decorated,
        );

        if (hasBoundedHeight) {
          final height = (maxHeightOverride ?? constraints.maxHeight).clamp(
            220.0,
            600.0,
          );
          return SizedBox(height: height, child: withMargin);
        }

        return withMargin;
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
    final theme = MacosTheme.of(context);
    // Watch the brightness state to trigger rebuilds
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
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
                          style: theme.typography.body.copyWith(
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
    required this.grouped,
    required this.selectedParticipantId,
    required this.onContactSelected,
  });

  final GroupedContacts grouped;
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

  List<String> get _letters => widget.grouped.availableLetters;

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

    final firstVisible = visiblePositions.first;
    final currentLetter = _letters[firstVisible.index];
    if (currentLetter != _activeLetter) {
      setState(() {
        _activeLetter = currentLetter;
      });
    }
  }

  void _scrollToLetter(String letter) {
    final index = _letters.indexOf(letter);
    if (index == -1) {
      return;
    }

    _itemScrollController.scrollTo(
      index: index,
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
            : _calculatePickerHeight(widget.grouped.availableLetters.length);
        final jumpBarHeight = _calculatePickerHeight(
          widget.grouped.availableLetters.length,
        );

        final list = SizedBox(
          height: availableHeight,
          child: _GroupedContactsList(
            grouped: widget.grouped,
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
    required this.grouped,
    required this.selectedParticipantId,
    required this.onContactSelected,
    required this.controller,
    required this.positionsListener,
  });

  final GroupedContacts grouped;
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
    final letters = widget.grouped.availableLetters;

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: ScrollablePositionedList.builder(
        itemCount: letters.length,
        itemScrollController: widget.controller,
        itemPositionsListener: widget.positionsListener,
        itemBuilder: (context, index) {
          final letter = letters[index];
          final contacts = widget.grouped.groups[letter] ?? const [];
          return _ContactGroupSection(
            letter: letter,
            contacts: contacts,
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

    final typography = MacosTheme.of(context).typography;
    // Watch the brightness state to trigger rebuilds
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

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
                            ? Colors.white
                            : colors.content.textSecondary,
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
    final typography = MacosTheme.of(context).typography;
    // Watch the brightness state to trigger rebuilds
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

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
    required this.letter,
    required this.contacts,
    required this.selectedParticipantId,
    required this.onContactSelected,
  });

  final String letter;
  final List<ContactSummary> contacts;
  final int? selectedParticipantId;
  final ValueChanged<int> onContactSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = MacosTheme.of(context).typography;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              letter,
              style: typography.title3.copyWith(
                fontSize: 14,
                color: colors.content.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          ...contacts.map(
            (contact) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: _ContactListItem(
                contact: contact,
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
  });

  final ContactSummary contact;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ContactHighlightRow(
      displayName: contact.displayName,
      shortName: contact.shortName,
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
