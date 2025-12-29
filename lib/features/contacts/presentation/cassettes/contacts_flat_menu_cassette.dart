import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../config/theme/theme.dart';
import '../../../../essentials/sidebar/domain/entities/features/contacts_cassette_spec.dart';
import '../../infrastructure/repositories/contacts_list_repository.dart';
import '../view_model/cassette_view_model.dart';

class ContactsFlatMenuCassette extends ConsumerWidget {
  const ContactsFlatMenuCassette({
    required this.spec,
    required this.contacts,
    super.key,
  });

  final ContactsCassetteSpec spec;
  final List<ContactSummary> contacts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Extract chosenContactId using pattern matching
    final selectedContactId = spec.when(
      recentContacts: (id) => id,
      contactChooser: (id) => id,
      contactHeroSummary: (id) => id,
    );

    if (contacts.isEmpty) {
      return const _EmptyState();
    }

    final bbc = AppTheme.bbc(context);
    final typography = MacosTheme.of(context).typography;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: contacts.map((contact) {
          final isSelected = contact.participantId == selectedContactId;

          return _FlatContactRow(
            contact: contact,
            isSelected: isSelected,
            onTap: () {
              ref
                  .read(cassetteViewModelProvider.notifier)
                  .updateContactSelection(
                    currentSpec: spec,
                    nextContactId: contact.participantId,
                  );
            },
            typography: typography,
            colors: bbc,
          );
        }).toList(),
      ),
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
