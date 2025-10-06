import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../view_model/manual_linking_provider.dart';

/// UI component for manually linking handles to participants.
///
/// This allows users to:
/// - View handles that aren't linked to any participant
/// - Link handles to existing participants
/// - Create new participants for handles
/// - Manage manual handle-participant relationships
class ManualLinkingView extends HookConsumerWidget {
  const ManualLinkingView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    final unlinkedAsync = ref.watch(unlinkedHandlesProvider);
    final participantsAsync = ref.watch(availableParticipantsProvider);

    return ColoredBox(
      color: const Color(0xFFF4F5F8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Manual Handle Linking',
              style: MacosTheme.of(
                context,
              ).typography.headline.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Link unknown handles to contacts when automatic matching fails. Create new contacts for unrecognized phone numbers or emails.',
              style: MacosTheme.of(
                context,
              ).typography.caption1.copyWith(color: const Color(0xFF6B6B70)),
            ),
            const SizedBox(height: 20),

            // Handle list
            Expanded(
              child: unlinkedAsync.when(
                data: (List<UnlinkedHandle> handles) {
                  if (handles.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MacosIcon(
                            CupertinoIcons.link,
                            size: 48,
                            color: Color(0xFFBDBDBD),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'All handles are linked',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF767680),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Every handle is connected to a contact. Great job!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF999999),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return MacosScrollbar(
                    controller: scrollController,
                    thumbVisibility: true,
                    child: ListView.separated(
                      controller: scrollController,
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      itemCount: handles.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final handle = handles[index];
                        return _UnlinkedHandleCard(
                          handle: handle,
                          participantsAsync: participantsAsync,
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 32),
                    child: ProgressCircle(radius: 12),
                  ),
                ),
                error: (error, stackTrace) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const MacosIcon(
                        CupertinoIcons.exclamationmark_triangle,
                        size: 48,
                        color: Color(0xFFD14343),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load unlinked handles',
                        style: MacosTheme.of(context).typography.title3,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$error',
                        style: const TextStyle(color: Color(0xFF999999)),
                        textAlign: TextAlign.center,
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

class _UnlinkedHandleCard extends ConsumerWidget {
  const _UnlinkedHandleCard({
    required this.handle,
    required this.participantsAsync,
  });

  final UnlinkedHandle handle;
  final AsyncValue<List<AvailableParticipant>> participantsAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = MacosTheme.of(context);
    final typography = theme.typography;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF2C2C33)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E2EA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle info
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        handle.handleId,
                        style: typography.title2.copyWith(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'SF Mono', // Monospace for handles
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: _getServiceColor(
                                handle.service,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              child: Text(
                                handle.service,
                                style: typography.caption2.copyWith(
                                  color: _getServiceColor(handle.service),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          if (handle.chatCount > 0) ...[
                            const SizedBox(width: 8),
                            Text(
                              '${handle.chatCount} chat${handle.chatCount == 1 ? '' : 's'}',
                              style: typography.caption1.copyWith(
                                color: const Color(0xFF6B6B70),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Linking options
            participantsAsync.when(
              data: (participants) =>
                  _LinkingActions(handle: handle, participants: participants),
              loading: () => const Row(
                children: [
                  ProgressCircle(radius: 8),
                  SizedBox(width: 8),
                  Text('Loading contacts...'),
                ],
              ),
              error: (error, _) => Text(
                'Error loading contacts: $error',
                style: const TextStyle(color: Color(0xFFD14343)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getServiceColor(String service) {
    switch (service.toLowerCase()) {
      case 'imessage':
        return const Color(0xFF007AFF); // iOS blue
      case 'sms':
        return const Color(0xFF34C759); // iOS green
      case 'rcs':
        return const Color(0xFFFF9500); // iOS orange
      default:
        return const Color(0xFF8E8E93); // iOS gray
    }
  }
}

class _LinkingActions extends HookConsumerWidget {
  const _LinkingActions({required this.handle, required this.participants});

  final UnlinkedHandle handle;
  final List<AvailableParticipant> participants;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedParticipant = useState<AvailableParticipant?>(null);
    final newContactController = useTextEditingController();
    final showCreateNew = useState(false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Link to existing participant
        Row(
          children: [
            Expanded(
              child: MacosPopupButton<AvailableParticipant?>(
                value: selectedParticipant.value,
                items: [
                  const MacosPopupMenuItem<AvailableParticipant?>(
                    child: Text('Select a contact...'),
                  ),
                  ...participants.map(
                    (participant) => MacosPopupMenuItem<AvailableParticipant?>(
                      value: participant,
                      child: Text(
                        '${participant.displayName} (${participant.handleCount} handle${participant.handleCount == 1 ? '' : 's'})',
                      ),
                    ),
                  ),
                ],
                onChanged: (value) {
                  selectedParticipant.value = value;
                },
              ),
            ),
            const SizedBox(width: 12),
            PushButton(
              controlSize: ControlSize.regular,
              onPressed: selectedParticipant.value != null
                  ? () async {
                      await ref
                          .read(manualLinkingProvider.notifier)
                          .linkHandleToParticipant(
                            handleId: handle.id,
                            participantId: selectedParticipant.value!.id,
                          );
                    }
                  : null,
              child: const Text('Link'),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Create new contact option
        Row(
          children: [
            PushButton(
              controlSize: ControlSize.regular,
              onPressed: () {
                showCreateNew.value = !showCreateNew.value;
                if (showCreateNew.value) {
                  newContactController.text = _suggestContactName(
                    handle.handleId,
                  );
                }
              },
              child: Text(
                showCreateNew.value ? 'Cancel' : 'Create New Contact',
              ),
            ),
          ],
        ),

        // New contact creation form
        if (showCreateNew.value) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: MacosTextField(
                  controller: newContactController,
                  placeholder: 'Contact name',
                ),
              ),
              const SizedBox(width: 12),
              PushButton(
                controlSize: ControlSize.regular,
                onPressed: newContactController.text.trim().isNotEmpty
                    ? () async {
                        await ref
                            .read(manualLinkingProvider.notifier)
                            .createParticipantForHandle(
                              handleId: handle.id,
                              displayName: newContactController.text.trim(),
                            );
                      }
                    : null,
                child: const Text('Create'),
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _suggestContactName(String handleId) {
    // Simple name suggestion based on handle
    if (handleId.contains('@')) {
      // Email - use part before @
      final parts = handleId.split('@');
      if (parts.isNotEmpty) {
        return parts.first.replaceAll(RegExp(r'[._]'), ' ').trim();
      }
    }

    // Phone number or other - just return as is
    return handleId;
  }
}
