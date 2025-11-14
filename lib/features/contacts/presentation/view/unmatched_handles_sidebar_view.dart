import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../essentials/navigation/domain/entities/features/contacts_list_spec.dart';
import '../../../../essentials/navigation/domain/entities/features/handles_list_spec.dart';
import '../../../../essentials/navigation/domain/entities/features/messages_spec.dart';
import '../../../../essentials/navigation/domain/entities/features/sidebar_spec.dart';
import '../../../../essentials/navigation/domain/entities/view_spec.dart';
import '../../../../essentials/navigation/domain/navigation_constants.dart';
import '../../../../essentials/navigation/feature_level_providers.dart';
import '../../../settings/presentation/view_model/manual_linking_provider.dart';
import '../../application/unmatched_handles_provider.dart';
import '../widgets/contact_picker_dialog.dart';

class UnmatchedHandlesSidebarView extends HookConsumerWidget {
  const UnmatchedHandlesSidebarView({required this.spec, super.key});

  final SidebarSpec spec;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Extract the current list mode
    final handlesSpec = spec.when(
      contacts: (_, __, ___) => throw StateError('Wrong spec type'),
      unmatchedHandles: (listMode) => listMode,
    );

    // Determine which provider to use based on the spec
    final asyncHandles = handlesSpec.when(
      phones: (filterMode) =>
          ref.watch(unmatchedPhonesProvider(filterMode: filterMode)),
      emails: () => ref.watch(unmatchedEmailsProvider),
    );

    final dateFormatter = DateFormat('MMM d, yyyy');

    // Track selected handle
    final selectedHandleId = useState<int?>(null);

    final title = handlesSpec.when(
      phones: (filterMode) {
        return filterMode == PhoneFilterMode.all
            ? 'Unmatched Phone Numbers'
            : 'Spam Candidates';
      },
      emails: () => 'Unmatched Emails',
    );

    void openGlobalTimeline() {
      ref
          .read(panelsViewStateProvider.notifier)
          .show(
            panel: WindowPanel.center,
            spec: const ViewSpec.messages(MessagesSpec.globalTimeline()),
          );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: MacosTheme.of(context).dividerColor,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              const Text(
                'Show messages from:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MacosPopupButton<String>(
                  value: 'unmatched',
                  onChanged: (newMode) {
                    if (newMode == 'contacts') {
                      // Switch to contacts view
                      ref
                          .read(panelsViewStateProvider.notifier)
                          .show(
                            panel: WindowPanel.left,
                            spec: const ViewSpec.sidebar(
                              SidebarSpec.contacts(
                                listMode: ContactsListSpec.all(),
                              ),
                            ),
                          );
                    } else if (newMode == 'all') {
                      openGlobalTimeline();
                    }
                  },
                  items: const [
                    MacosPopupMenuItem(
                      value: 'contacts',
                      child: Text('Contacts'),
                    ),
                    MacosPopupMenuItem(
                      value: 'unmatched',
                      child: Text('Unmatched phone or email'),
                    ),
                    MacosPopupMenuItem(
                      value: 'all',
                      child: Text('All Messages'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: MacosScaffold(
            toolBar: ToolBar(
              height: 40,
              title: Text(title),
              actions: [
                ToolBarIconButton(
                  icon: const MacosIcon(CupertinoIcons.search),
                  label: 'Search',
                  onPressed: () {
                    // TODO: Implement search
                  },
                  showLabel: false,
                ),
              ],
            ),
            children: [
              ContentArea(
                builder: (context, scrollController) {
                  return Column(
                    children: [
                      // Handle type selector (Phones vs Emails)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: MacosTheme.of(context).dividerColor,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Text('Phone Numbers'),
                                  const SizedBox(width: 8),
                                  MacosRadioButton<String>(
                                    value: 'phones',
                                    groupValue: handlesSpec.when(
                                      phones: (_) => 'phones',
                                      emails: () => 'emails',
                                    ),
                                    onChanged: (value) {
                                      ref
                                          .read(
                                            panelsViewStateProvider.notifier,
                                          )
                                          .show(
                                            panel: WindowPanel.left,
                                            spec: const ViewSpec.sidebar(
                                              SidebarSpec.unmatchedHandles(
                                                listMode:
                                                    HandlesListSpec.phones(
                                                      filterMode:
                                                          PhoneFilterMode.all,
                                                    ),
                                              ),
                                            ),
                                          );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  const Text('Email Addresses'),
                                  const SizedBox(width: 8),
                                  MacosRadioButton<String>(
                                    value: 'emails',
                                    groupValue: handlesSpec.when(
                                      phones: (_) => 'phones',
                                      emails: () => 'emails',
                                    ),
                                    onChanged: (value) {
                                      ref
                                          .read(
                                            panelsViewStateProvider.notifier,
                                          )
                                          .show(
                                            panel: WindowPanel.left,
                                            spec: const ViewSpec.sidebar(
                                              SidebarSpec.unmatchedHandles(
                                                listMode:
                                                    HandlesListSpec.emails(),
                                              ),
                                            ),
                                          );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Phone filter (only show for phones)
                      if (handlesSpec is HandlesListSpecPhones)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: MacosTheme.of(context).dividerColor,
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    const Text('All Numbers'),
                                    const SizedBox(width: 8),
                                    MacosRadioButton<PhoneFilterMode>(
                                      value: PhoneFilterMode.all,
                                      groupValue: handlesSpec.filterMode,
                                      onChanged: (value) {
                                        ref
                                            .read(
                                              panelsViewStateProvider.notifier,
                                            )
                                            .show(
                                              panel: WindowPanel.left,
                                              spec: const ViewSpec.sidebar(
                                                SidebarSpec.unmatchedHandles(
                                                  listMode:
                                                      HandlesListSpec.phones(
                                                        filterMode:
                                                            PhoneFilterMode.all,
                                                      ),
                                                ),
                                              ),
                                            );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    const Text('Spam Candidates'),
                                    const SizedBox(width: 8),
                                    MacosRadioButton<PhoneFilterMode>(
                                      value: PhoneFilterMode.spamCandidates,
                                      groupValue: handlesSpec.filterMode,
                                      onChanged: (value) {
                                        ref
                                            .read(
                                              panelsViewStateProvider.notifier,
                                            )
                                            .show(
                                              panel: WindowPanel.left,
                                              spec: const ViewSpec.sidebar(
                                                SidebarSpec.unmatchedHandles(
                                                  listMode:
                                                      HandlesListSpec.phones(
                                                        filterMode:
                                                            PhoneFilterMode
                                                                .spamCandidates,
                                                      ),
                                                ),
                                              ),
                                            );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Handles list
                      Expanded(
                        child: asyncHandles.when(
                          data: (handles) {
                            if (handles.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const MacosIcon(
                                      CupertinoIcons.checkmark_circle,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      handlesSpec.when(
                                        phones: (_) =>
                                            'No unmatched phone numbers',
                                        emails: () => 'No unmatched emails',
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return ListView.builder(
                              controller: scrollController,
                              itemCount: handles.length,
                              itemBuilder: (context, index) {
                                final handle = handles[index];
                                final isSelected =
                                    handle.handleId == selectedHandleId.value;

                                return _UnmatchedHandleListItem(
                                  handle: handle,
                                  isSelected: isSelected,
                                  dateFormatter: dateFormatter,
                                  onTap: () {
                                    selectedHandleId.value = handle.handleId;

                                    // Show all messages from this handle in center panel
                                    ref
                                        .read(panelsViewStateProvider.notifier)
                                        .show(
                                          panel: WindowPanel.center,
                                          spec: ViewSpec.messages(
                                            MessagesSpec.forHandle(
                                              handleId: handle.handleId,
                                            ),
                                          ),
                                        );
                                  },
                                );
                              },
                            );
                          },
                          loading: () => const Center(child: ProgressCircle()),
                          error: (error, stack) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const MacosIcon(
                                  CupertinoIcons.exclamationmark_triangle,
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                Text('Error loading handles: $error'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UnmatchedHandleListItem extends HookConsumerWidget {
  const _UnmatchedHandleListItem({
    required this.handle,
    required this.isSelected,
    required this.dateFormatter,
    required this.onTap,
  });

  final UnmatchedHandleSummary handle;
  final bool isSelected;
  final DateFormat dateFormatter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = MacosTheme.of(context);
    final isProcessing = useState(false);

    Future<void> handleAssignToContact() async {
      try {
        // Show contact picker dialog
        final participantId = await ContactPickerDialog.show(context);

        if (participantId == null) {
          return; // User cancelled
        }

        // Show processing state
        isProcessing.value = true;

        // Link the handle to the participant
        await ref
            .read(manualLinkingProvider.notifier)
            .linkHandleToParticipant(
              handleId: handle.handleId,
              participantId: participantId,
            );

        if (context.mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Handle successfully assigned to contact'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (error) {
        if (context.mounted) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to assign handle: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        isProcessing.value = false;
      }
    }

    void showContextMenu(BuildContext context, Offset position) {
      final overlay =
          Overlay.of(context).context.findRenderObject()! as RenderBox;

      showMenu<String>(
        context: context,
        position: RelativeRect.fromRect(
          Rect.fromLTWH(position.dx, position.dy, 0, 0),
          Offset.zero & overlay.size,
        ),
        items: [
          const PopupMenuItem<String>(
            value: 'assign',
            child: Row(
              children: [
                Icon(CupertinoIcons.person_add, size: 16),
                SizedBox(width: 8),
                Text('Assign to contact...'),
              ],
            ),
          ),
        ],
      ).then((value) {
        if (value == 'assign') {
          handleAssignToContact();
        }
      });
    }

    return GestureDetector(
      onTap: isProcessing.value ? null : onTap,
      onSecondaryTapDown: (details) {
        showContextMenu(context, details.globalPosition);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? CupertinoColors.activeBlue.withValues(alpha: 0.2)
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(color: theme.dividerColor, width: 0.5),
          ),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                // Icon indicating service type
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: handle.isProbableSpam
                        ? Colors.orange.withValues(alpha: 0.2)
                        : CupertinoColors.activeBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    handle.serviceType.toLowerCase().contains('sms') ||
                            handle.serviceType == 'iMessage'
                        ? CupertinoIcons.phone_fill
                        : CupertinoIcons.mail_solid,
                    size: 20,
                    color: handle.isProbableSpam
                        ? Colors.orange
                        : CupertinoColors.activeBlue,
                  ),
                ),
                const SizedBox(width: 12),
                // Handle info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              handle.handleValue,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (handle.isProbableSpam) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'SPAM?',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${handle.totalMessages} ${handle.totalMessages == 1 ? 'message' : 'messages'} · ${handle.serviceType}',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.typography.body.color?.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Last message date
                if (handle.lastMessageDate != null)
                  Text(
                    dateFormatter.format(handle.lastMessageDate!),
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.typography.body.color?.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
            // Processing overlay
            if (isProcessing.value)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.1),
                  child: const Center(child: ProgressCircle(radius: 12)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
