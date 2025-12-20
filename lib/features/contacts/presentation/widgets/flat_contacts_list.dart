import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../config/theme/theme.dart';

import '../../application_pre_cassette/contacts_list_provider.dart';

// NEW: contact picker mode - flat list widget
class FlatContactsList extends StatelessWidget {
  const FlatContactsList({
    super.key,
    required this.contacts,
    required this.selectedParticipantId,
    required this.onContactSelected,
  });

  final List<ContactSummary> contacts;
  final int? selectedParticipantId;
  final ValueChanged<int> onContactSelected;

  @override
  Widget build(BuildContext context) {
    if (contacts.isEmpty) {
      return const _EmptyState();
    }

    final bbc = AppTheme.bbc(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bbc.bbcCardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bbc.bbcBorderSubtle, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contacts (flat view)',
            style: MacosTheme.of(
              context,
            ).typography.caption1.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 260),
            child: MacosScrollbar(
              child: ListView.separated(
                itemCount: contacts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  final selected =
                      contact.participantId == selectedParticipantId;
                  return _FlatContactRow(
                    contact: contact,
                    selected: selected,
                    onTap: () => onContactSelected(contact.participantId),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlatContactRow extends StatelessWidget {
  const _FlatContactRow({
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
    final bbc = AppTheme.bbc(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? bbc.bbcPrimaryOne.withValues(alpha: 0.12) : null,
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
                  if (contact.shortName.trim() != contact.displayName.trim())
                    Text(
                      contact.shortName,
                      style: theme.typography.caption2.copyWith(
                        color: bbc.bbcSubheadText,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              contact.handleCount == 1
                  ? '1 handle'
                  : '${contact.handleCount} handles',
              style: theme.typography.caption2,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final bbc = AppTheme.bbc(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bbc.bbcBorderSubtle),
      ),
      child: Center(
        child: Text(
          'No contacts available',
          style: TextStyle(color: bbc.bbcSubheadText),
        ),
      ),
    );
  }
}
