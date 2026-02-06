import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../../../essentials/navigation/domain/entities/features/contacts_list_spec.dart';
import '../../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../../essentials/sidebar/application/cassette_rack_state_provider.dart';
import '../../../../../essentials/sidebar/feature_level_providers.dart';
import '../../../domain/spec_classes/contacts_cassette_spec.dart';
import '../../../infrastructure/repositories/contacts_list_repository.dart';
import '../../../presentation/widgets/contact_cassette_error.dart';

/// Widget builder for the contact selection control cassette.
///
/// Displays the selected contact name with a "Change" affordance.
/// This is a compact control that sits above the Hero Card and provides
/// re-entry to the contact picker.
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// Widget builders:
/// - Accept fully-decided inputs (not specs)
/// - May use `ref.watch()` for reactive updates
/// - Construct specs only on user interaction (output, not interpretation)
///
/// ## Visual Role
///
/// The selection control creates perceptual continuity with the picker:
/// - Visually lightweight (compact height)
/// - Same top position as picker had
/// - "Change" affordance triggers picker expansion
class ContactSelectionControlWidget extends ConsumerWidget {
  const ContactSelectionControlWidget({
    super.key,
    required this.contactId,
    required this.cassetteIndex,
  });

  /// The ID of the selected contact.
  final int contactId;

  /// Position in the cassette rack (for updates via replaceAtIndexAndCascade).
  final int cassetteIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch contact to display name
    const listSpec = ContactsListSpec.alphabetical();
    final contactsAsync = ref.watch(
      contactsListRepositoryProvider(spec: listSpec),
    );

    return contactsAsync.when(
      data: (contacts) {
        final contact = _findContactById(contacts, contactId);
        if (contact == null) {
          return const Text('Contact not found');
        }

        return _SelectionControlContent(
          displayName: contact.displayName,
          cassetteIndex: cassetteIndex,
        );
      },
      loading: () => const Center(child: ProgressCircle()),
      error: (error, _) => ContactCassetteError(
        onRetry: () {
          ref.invalidate(contactsListRepositoryProvider(spec: listSpec));
        },
        message: '$error',
      ),
    );
  }

  ContactSummary? _findContactById(List<ContactSummary> contacts, int id) {
    for (final contact in contacts) {
      if (contact.participantId == id) {
        return contact;
      }
    }
    return null;
  }
}

/// The actual content of the selection control.
///
/// Separated to keep the async data fetching in the parent.
class _SelectionControlContent extends ConsumerStatefulWidget {
  const _SelectionControlContent({
    required this.displayName,
    required this.cassetteIndex,
  });

  final String displayName;
  final int cassetteIndex;

  @override
  ConsumerState<_SelectionControlContent> createState() =>
      _SelectionControlContentState();
}

class _SelectionControlContentState
    extends ConsumerState<_SelectionControlContent> {
  bool _isHovered = false;

  void _handleChange() {
    // Return to picker with fresh state (no selection)
    const newSpec = CassetteSpec.contacts(
      ContactsCassetteSpec.contactChooser(),
    );

    // Update the cassette rack using the index
    ref
        .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
        .replaceAtIndexAndCascade(widget.cassetteIndex, newSpec);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final hints = colors.interactiveHints;

    // Background lift on hover
    final bgColor = _isHovered ? hints.backgroundLift : Colors.transparent;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleChange,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(hints.cornerRadius),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: hints.paddingHorizontal,
            vertical: hints.paddingVertical,
          ),
          child: Row(
            children: [
              // Contact name
              Expanded(
                child: Text(
                  widget.displayName,
                  style: typography.body.copyWith(
                    color: colors.content.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),

              const SizedBox(width: 8),

              // "Change" affordance
              Text(
                'Change',
                style: typography.caption.copyWith(
                  color: _isHovered
                      ? colors.accents.primary
                      : colors.content.textTertiary,
                ),
              ),

              const SizedBox(width: 4),

              // Chevron icon
              Icon(
                CupertinoIcons.chevron_right,
                size: 12,
                color: _isHovered
                    ? colors.accents.primary
                    : colors.content.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
