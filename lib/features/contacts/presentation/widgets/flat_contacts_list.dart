import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../config/theme/theme.dart';

import '../../application_pre_cassette/contacts_list_provider.dart';

/// Simple flat list of contacts for small contact counts.
/// No fancy features - just a clean, clickable list.
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
    final typography = MacosTheme.of(context).typography;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: contacts.map((contact) {
        final isSelected = contact.participantId == selectedParticipantId;

        return _FlatContactRow(
          contact: contact,
          isSelected: isSelected,
          onTap: () => onContactSelected(contact.participantId),
          typography: typography,
          colors: bbc,
        );
      }).toList(),
    );
  }
}

class _FlatContactRow extends StatelessWidget {
  const _FlatContactRow({
    required this.contact,
    required this.isSelected,
    required this.onTap,
    required this.typography,
    required this.colors,
  });

  final ContactSummary contact;
  final bool isSelected;
  final VoidCallback onTap;
  final MacosTypography typography;
  final BbcColors colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.bbcPrimaryOne.withValues(alpha: 0.12)
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(color: colors.bbcBorderSubtle, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                contact.displayName,
                style: typography.body.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Icon(
                CupertinoIcons.checkmark_alt,
                size: 14,
                color: colors.bbcPrimaryOne,
              ),
            ],
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
    final typography = MacosTheme.of(context).typography;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Center(
        child: Text(
          'No contacts available',
          style: typography.body.copyWith(color: bbc.bbcSubheadText),
        ),
      ),
    );
  }
}
