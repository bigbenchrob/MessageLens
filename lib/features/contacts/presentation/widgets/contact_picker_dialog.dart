import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../application/sidebar_cassette_spec/resolver_tools/participants_for_picker_provider.dart';

/// Dialog for picking a contact/participant to assign to a handle
///
/// This shows a searchable list of all participants. The user can:
/// - Search by name (filters the list)
/// - Select a participant
/// - Cancel or confirm the selection
///
/// Returns the selected participant ID when confirmed, or null when cancelled.
class ContactPickerDialog extends HookConsumerWidget {
  const ContactPickerDialog({super.key});

  /// Show the contact picker dialog
  ///
  /// Returns the selected participant ID, or null if cancelled
  static Future<int?> show(BuildContext context) {
    return showMacosSheet<int?>(
      context: context,
      builder: (context) => const ContactPickerDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final selectedParticipant = useState<ParticipantForPicker?>(null);

    // Debounce search input
    useEffect(() {
      void listener() {
        searchQuery.value = searchController.text;
      }

      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    final participantsAsync = ref.watch(
      participantsForPickerProvider(searchQuery: searchQuery.value),
    );

    return MacosSheet(
      child: Center(
        child: Container(
          width: 500,
          height: 600,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Assign to Contact',
                style: typography.title1.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Select the contact this handle belongs to',
                style: typography.caption1.copyWith(
                  color: colors.content.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // Search field
              MacosSearchField(
                controller: searchController,
                placeholder: 'Search contacts...',
                autofocus: true,
              ),
              const SizedBox(height: 16),

              // Participant list
              Expanded(
                child: participantsAsync.when(
                  data: (participants) {
                    if (participants.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MacosIcon(
                              CupertinoIcons.person_crop_circle,
                              size: 48,
                              color: colors.content.textDisabled,
                            ),
                            const SizedBox(height: 16),
                            const Text('No contacts found'),
                          ],
                        ),
                      );
                    }

                    return DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: colors.lines.borderSubtle),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: MacosScrollbar(
                        child: ListView.separated(
                          itemCount: participants.length,
                          separatorBuilder: (_, __) =>
                              Divider(height: 1, color: colors.lines.divider),
                          itemBuilder: (context, index) {
                            final participant = participants[index];
                            final isSelected =
                                selectedParticipant.value?.id == participant.id;

                            return _ParticipantListItem(
                              participant: participant,
                              isSelected: isSelected,
                              onTap: () {
                                selectedParticipant.value = participant;
                              },
                            );
                          },
                        ),
                      ),
                    );
                  },
                  loading: () => const Center(child: ProgressCircle()),
                  error: (error, _) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MacosIcon(
                          CupertinoIcons.exclamationmark_triangle,
                          size: 48,
                          color: colors.accents.secondary,
                        ),
                        const SizedBox(height: 16),
                        Text('Error loading contacts: $error'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PushButton(
                    controlSize: ControlSize.large,
                    onPressed: () {
                      Navigator.of(context).pop(null);
                    },
                    secondary: true,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  PushButton(
                    controlSize: ControlSize.large,
                    onPressed: selectedParticipant.value != null
                        ? () {
                            Navigator.of(
                              context,
                            ).pop(selectedParticipant.value!.id);
                          }
                        : null,
                    child: const Text('Assign'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParticipantListItem extends ConsumerWidget {
  const _ParticipantListItem({
    required this.participant,
    required this.isSelected,
    required this.onTap,
  });

  final ParticipantForPicker participant;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    return GestureDetector(
      onTap: onTap,
      child: ColoredBox(
        color: isSelected
            ? colors.accents.primary.withValues(alpha: 0.14)
            : Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Selection indicator
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? colors.accents.primary
                        : colors.content.textDisabled,
                    width: 2,
                  ),
                  color: isSelected
                      ? colors.accents.primary
                      : Colors.transparent,
                ),
                child: isSelected
                    ? Icon(
                        CupertinoIcons.check_mark,
                        size: 12,
                        color: colors.buttons.primaryForeground,
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // Participant info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      participant.displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: colors.content.textPrimary,
                      ),
                    ),
                    if (participant.shortName.isNotEmpty &&
                        participant.shortName != participant.displayName) ...[
                      const SizedBox(height: 2),
                      Text(
                        participant.shortName,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.content.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Handle count
              Text(
                '${participant.handleCount} ${participant.handleCount == 1 ? 'handle' : 'handles'}',
                style: TextStyle(
                  fontSize: 12,
                  color: colors.content.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
