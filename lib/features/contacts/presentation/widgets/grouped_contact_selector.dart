import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../application/contacts_list_provider.dart';
import '../../application/grouped_contacts_provider.dart';

class GroupedContactSelector extends ConsumerStatefulWidget {
  const GroupedContactSelector({
    super.key,
    required this.selectedParticipantId,
    required this.onContactSelected,
  });

  final int? selectedParticipantId;
  final ValueChanged<int> onContactSelected;

  @override
  ConsumerState<GroupedContactSelector> createState() =>
      _GroupedContactSelectorState();
}

class _GroupedContactSelectorState
    extends ConsumerState<GroupedContactSelector> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupedAsync = ref.watch(groupedContactsProvider);
    final theme = MacosTheme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Grouped contacts (preview)',
            style: theme.typography.caption1.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 260,
            child: groupedAsync.when(
              data: (grouped) {
                if (grouped.availableLetters.isEmpty) {
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

                return MacosScrollbar(
                  controller: _scrollController,
                  child: ListView(
                    controller: _scrollController,
                    padding: EdgeInsets.zero,
                    children: [
                      for (final letter in grouped.availableLetters)
                        _ContactGroupSection(
                          letter: letter,
                          contacts: grouped.groups[letter] ?? const [],
                          selectedParticipantId: widget.selectedParticipantId,
                          onContactSelected: widget.onContactSelected,
                          count: grouped.letterCounts[letter] ?? 0,
                        ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: ProgressCircle()),
              error: (error, _) => _GroupedSelectorError(
                message: '$error',
                onRetry: () {
                  ref.invalidate(groupedContactsProvider);
                },
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
