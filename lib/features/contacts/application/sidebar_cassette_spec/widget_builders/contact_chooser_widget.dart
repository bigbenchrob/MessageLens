import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../../../constants/domain/contact_constants.dart';
import '../../../../../essentials/db/feature_level_providers.dart';
import '../../../../../essentials/navigation/domain/entities/features/contacts_list_spec.dart';
import '../../../../../essentials/navigation/domain/entities/features/messages_spec.dart';
import '../../../../../essentials/navigation/domain/entities/view_spec.dart';
import '../../../../../essentials/navigation/domain/navigation_constants.dart';
import '../../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../../essentials/navigation/feature_level_providers.dart';
import '../../../../../essentials/sidebar/application/cassette_rack_state_provider.dart';
import '../../../../../essentials/sidebar/feature_level_providers.dart';
import '../../../application_pre_cassette/contact_picker_mode.dart';
import '../../../domain/spec_classes/contacts_cassette_spec.dart';
import '../../../infrastructure/repositories/contacts_list_repository.dart';
import '../../../infrastructure/repositories/recent_contacts_repository.dart';
import '../../../presentation/cassettes/contacts_enhanced_picker_cassette.dart';
import '../../../presentation/cassettes/contacts_flat_menu_cassette.dart';

/// Debug flag for temporarily forcing the flat chooser.
const bool _forceFlatContactChooser = false;

/// Widget builder for the contact chooser cassette.
///
/// This widget handles all the reactive logic for displaying contacts:
/// - Watching contact list from repository
/// - Determining flat vs grouped display based on count
/// - Handling contact selection
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// Widget builders:
/// - Accept fully-decided inputs (not specs)
/// - May use `ref.watch()` for reactive updates
/// - Construct specs only on user interaction (output, not interpretation)
class ContactChooserWidget extends ConsumerWidget {
  const ContactChooserWidget({
    super.key,
    required this.chosenContactId,
    required this.cassetteIndex,
    required this.showRecentContacts,
  });

  /// Currently selected contact ID, if any.
  final int? chosenContactId;

  /// Position in the cassette rack (for updates via replaceAtIndexAndCascade).
  final int cassetteIndex;

  /// Whether to show the recent contacts section at the top.
  final bool showRecentContacts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maintenanceLocked = ref.watch(dbMaintenanceLockProvider);
    if (maintenanceLocked) {
      debugPrint('ContactChooser: maintenance lock active (skipping load)');
      return const Center(child: ProgressCircle());
    }

    final asyncContacts = ref.watch(
      contactsListRepositoryProvider(
        spec: const ContactsListSpec.alphabetical(),
      ),
    );
    final asyncRecents = ref.watch(recentContactsProvider);

    return asyncContacts.when(
      data: (contacts) {
        final config = resolveContactPickerConfig(contacts.length);

        // Build the main picker widget
        Widget mainPicker;
        if (_forceFlatContactChooser) {
          mainPicker = _ContactsFlatMenuAdapter(
            contacts: contacts,
            chosenContactId: chosenContactId,
            cassetteIndex: cassetteIndex,
          );
        } else {
          mainPicker = switch (config.mode) {
            ContactPickerMode.flat => _ContactsFlatMenuAdapter(
              contacts: contacts,
              chosenContactId: chosenContactId,
              cassetteIndex: cassetteIndex,
            ),
            ContactPickerMode.grouped => _ContactsEnhancedPickerAdapter(
              chosenContactId: chosenContactId,
              cassetteIndex: cassetteIndex,
            ),
          };
        }

        // Wrap with recent contacts section if any exist
        return LayoutBuilder(
          builder: (context, constraints) {
            final child = asyncRecents.when(
              data: (recents) {
                if (recents.isEmpty || !showRecentContacts) {
                  return mainPicker;
                }
                return _CombinedContactPicker(
                  recents: recents,
                  mainPicker: mainPicker,
                  chosenContactId: chosenContactId,
                  cassetteIndex: cassetteIndex,
                );
              },
              loading: () => mainPicker,
              error: (_, __) => mainPicker,
            );

            if (constraints.hasBoundedHeight) {
              return SizedBox(height: constraints.maxHeight, child: child);
            }

            return SizedBox(height: 400, child: child);
          },
        );
      },
      loading: () => const Center(child: ProgressCircle()),
      error: (error, stack) {
        debugPrint('ContactChooser error: $error');
        return Center(
          child: Text(
            'Error loading contacts: $error',
            style: const TextStyle(color: Colors.red),
          ),
        );
      },
    );
  }
}

/// Adapter to pass decided data to legacy ContactsFlatMenuCassette.
///
/// This will be removed once ContactsFlatMenuCassette is updated to accept
/// decided data instead of specs.
class _ContactsFlatMenuAdapter extends ConsumerWidget {
  const _ContactsFlatMenuAdapter({
    required this.contacts,
    required this.chosenContactId,
    required this.cassetteIndex,
  });

  final List<ContactSummary> contacts;
  final int? chosenContactId;
  final int cassetteIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // For now, we still need to construct a spec for the legacy widget.
    // This is a temporary bridge that will be removed when the cassette
    // widgets are updated to accept decided data.
    final spec = ContactsCassetteSpec.contactChooser(
      chosenContactId: chosenContactId,
    );
    return ContactsFlatMenuCassette(spec: spec, contacts: contacts);
  }
}

/// Adapter to pass decided data to legacy ContactsEnhancedPickerCassette.
class _ContactsEnhancedPickerAdapter extends ConsumerWidget {
  const _ContactsEnhancedPickerAdapter({
    required this.chosenContactId,
    required this.cassetteIndex,
  });

  final int? chosenContactId;
  final int cassetteIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spec = ContactsCassetteSpec.contactChooser(
      chosenContactId: chosenContactId,
    );
    return ContactsEnhancedPickerCassette(spec: spec);
  }
}

/// Combined picker showing recent contacts at top and full picker below.
class _CombinedContactPicker extends ConsumerWidget {
  const _CombinedContactPicker({
    required this.recents,
    required this.mainPicker,
    required this.chosenContactId,
    required this.cassetteIndex,
  });

  final List<RecentContactSummary> recents;
  final Widget mainPicker;
  final int? chosenContactId;
  final int cassetteIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    fontWeight: widget.isSelected
                        ? FontWeight.w600
                        : FontWeight.w400,
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
