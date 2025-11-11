import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../application/contacts_list_provider.dart';
import '../../application/grouped_contacts_provider.dart';

// NEW: collapsible contacts picker section
final contactsPickerExpandedProvider = StateProvider<bool>(
  (ref) => true,
);

// NEW: collapsible contacts picker section
class ContactsPickerSection extends ConsumerWidget {
  const ContactsPickerSection({
    super.key,
    required this.contacts,
    required this.selectedParticipantId,
    required this.onContactSelected,
  });

  final List<ContactSummary> contacts;
  final int? selectedParticipantId;
  final ValueChanged<int> onContactSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpanded = ref.watch(contactsPickerExpandedProvider);
    final groupedAsync = ref.watch(groupedContactsProvider);
    final theme = MacosTheme.of(context);
    final selectedContact = _findContact(
      contacts,
      selectedParticipantId,
    );
    final selectedName = selectedContact?.displayName ?? 'Select a contact';
    void handleSelection(int participantId) {
      onContactSelected(participantId);
      ref.read(contactsPickerExpandedProvider.notifier).state = false;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.canvasColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.6),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            key: const ValueKey('contactsPickerHeader'), // NEW: collapsible contacts picker section
            onTap: () {
              final notifier = ref.read(
                contactsPickerExpandedProvider.notifier,
              );
              notifier.state = !notifier.state;
            },
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                MacosIcon(
                  isExpanded
                      ? CupertinoIcons.chevron_down
                      : CupertinoIcons.chevron_right,
                  size: 14,
                  color: CupertinoColors.secondaryLabel,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selectedName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedSize(
            clipBehavior: Clip.none,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOut,
            child: isExpanded
                ? Column(
                    children: [
                      const SizedBox(height: 8),
                      groupedAsync.when(
                        data: (grouped) {
                          if (grouped.availableLetters.isEmpty) {
                            return const _GroupedEmptyState();
                          }
                          return GroupedContactsPicker(
                            grouped: grouped,
                            selectedParticipantId: selectedParticipantId,
                            onContactSelected: handleSelection,
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
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

const double _kLetterSlotHeight = 18;
const double _kPickerMinHeight = 160;
const double _kPickerMaxHeight = 360;
const double _kJumpBarWidth = 24;

// NEW: integrated jump bar
class GroupedContactsPicker extends StatefulWidget {
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
  State<GroupedContactsPicker> createState() => _GroupedContactsPickerState();
}

class _GroupedContactsPickerState extends State<GroupedContactsPicker> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  String? _activeLetter;

  List<String> get _letters => widget.grouped.availableLetters;

  double get _pickerHeight {
    if (_letters.isEmpty) {
      return _kPickerMinHeight;
    }
    final baseHeight = _letters.length * _kLetterSlotHeight;
    final clampedHeight =
        baseHeight.clamp(_kPickerMinHeight, _kPickerMaxHeight);
    return clampedHeight;
  }

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

    final visiblePositions = positions
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
    final pickerHeight = _pickerHeight;

    return SizedBox(
      height: pickerHeight,
      child: Row(
        children: [
          Expanded(
            child: _GroupedContactsList(
              grouped: widget.grouped,
              selectedParticipantId: widget.selectedParticipantId,
              onContactSelected: widget.onContactSelected,
              controller: _itemScrollController,
              positionsListener: _itemPositionsListener,
            ),
          ),
          _JumpBar(
            letters: _letters,
            totalHeight: pickerHeight,
            activeLetter: _activeLetter,
            onLetterTap: _scrollToLetter,
          ),
        ],
      ),
    );
  }
}

class _GroupedEmptyState extends StatelessWidget {
  const _GroupedEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No contacts available',
        style: TextStyle(
          color: CupertinoColors.secondaryLabel,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _GroupedContactsList extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final letters = grouped.availableLetters;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: ScrollablePositionedList.builder(
        itemScrollController: controller,
        itemPositionsListener: positionsListener,
        itemCount: letters.length,
        itemBuilder: (context, index) {
          final letter = letters[index];
          final contacts = grouped.groups[letter] ?? const [];
          final count = grouped.letterCounts[letter] ?? contacts.length;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: _ContactGroupSection(
              letter: letter,
              contacts: contacts,
              selectedParticipantId: selectedParticipantId,
              onContactSelected: onContactSelected,
              count: count,
            ),
          );
        },
      ),
    );
  }
}

class _JumpBar extends StatefulWidget {
  const _JumpBar({
    required this.letters,
    required this.totalHeight,
    required this.activeLetter,
    required this.onLetterTap,
  });

  final List<String> letters;
  final double totalHeight;
  final String? activeLetter;
  final ValueChanged<String> onLetterTap;

  @override
  State<_JumpBar> createState() => _JumpBarState();
}

class _JumpBarState extends State<_JumpBar> {
  String? _hoveredLetter;

  @override
  Widget build(BuildContext context) {
    if (widget.letters.isEmpty) {
      return const SizedBox(width: _kJumpBarWidth);
    }

    final letterHeight = widget.totalHeight / widget.letters.length;
    final typography = MacosTheme.of(context).typography;
    const baseBackground = Color(0xFF3A3A3A);

    return Container(
      width: _kJumpBarWidth,
      decoration: BoxDecoration(
        color: baseBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (final letter in widget.letters)
            MouseRegion(
              onEnter: (_) => setState(() {
                _hoveredLetter = letter;
              }),
              onExit: (_) => setState(() {
                if (_hoveredLetter == letter) {
                  _hoveredLetter = null;
                }
              }),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => widget.onLetterTap(letter),
                child: Container(
                  height: letterHeight,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: letter == widget.activeLetter
                        ? MacosTheme.of(context).primaryColor.withValues(
                              alpha: 0.9,
                            )
                        : letter == _hoveredLetter
                            ? Colors.white.withValues(alpha: 0.15)
                            : Colors.transparent,
                  ),
                  child: Text(
                    letter,
                    style: typography.caption1.copyWith(
                      color: letter == widget.activeLetter
                          ? Colors.white
                          : Colors.white.withOpacity(
                              letter == _hoveredLetter ? 0.95 : 0.75,
                            ),
                      fontWeight: letter == widget.activeLetter
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GroupedSelectorError extends StatelessWidget {
  const _GroupedSelectorError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final typography = MacosTheme.of(context).typography;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const MacosIcon(
          CupertinoIcons.exclamationmark_triangle,
          color: CupertinoColors.systemYellow,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          'Unable to load grouped contacts',
          style: typography.caption1,
        ),
        const SizedBox(height: 4),
        Text(
          message,
          style: typography.caption2.copyWith(
            color: CupertinoColors.secondaryLabel,
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

class _ContactGroupSection extends StatelessWidget {
  const _ContactGroupSection({
    required this.letter,
    required this.contacts,
    required this.selectedParticipantId,
    required this.onContactSelected,
    required this.count,
  });

  final String letter;
  final List<ContactSummary> contacts;
  final int? selectedParticipantId;
  final ValueChanged<int> onContactSelected;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ContactSectionHeader(letter: letter, count: count),
          const SizedBox(height: 4),
          ...contacts.map(
            (contact) => _ContactListItem(
              contact: contact,
              selected: contact.participantId == selectedParticipantId,
              onTap: () => onContactSelected(contact.participantId),
            ),
          ),
          if (contacts.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              alignment: Alignment.centerLeft,
              child: Text(
                'No contacts for $letter',
                style: theme.typography.caption2.copyWith(
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ContactSectionHeader extends StatelessWidget {
  const _ContactSectionHeader({required this.letter, required this.count});

  final String letter;
  final int count;

  @override
  Widget build(BuildContext context) {
    final typography = MacosTheme.of(context).typography;

    return Row(
      children: [
        Text(
          letter,
          style: typography.title3.copyWith(fontSize: 14),
        ),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: CupertinoColors.systemFill,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '$count',
            style: typography.caption2,
          ),
        ),
      ],
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
    final theme = MacosTheme.of(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? theme.primaryColor.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.displayName,
                    style: theme.typography.headline.copyWith(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (contact.shortName != contact.displayName)
                    Text(
                      contact.shortName,
                      style: theme.typography.caption2.copyWith(
                        color: CupertinoColors.secondaryLabel,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${contact.handleCount}',
              style: theme.typography.caption2,
            ),
          ],
        ),
      ),
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
