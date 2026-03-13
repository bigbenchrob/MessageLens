import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../config/theme/theme_typography.dart';
import '../../../../essentials/db/feature_level_providers.dart';
import '../../../../essentials/logging/application/app_logger.dart';
import '../../../contacts/application/services/manual_handle_link_service.dart';
import '../../../contacts/presentation/widgets/contact_picker_dialog.dart';
import '../../../handles/infrastructure/repositories/handle_display_name_provider.dart';
import '../../../handles/infrastructure/repositories/stray_handles_provider.dart';
import '../../infrastructure/repositories/messages_for_handle_provider.dart';

/// Triage view for a single stray handle.
///
/// Shows a header with the handle value and service type, three action buttons
/// (Create Contact, Link to Existing, Dismiss), and a scrollable message list
/// powered by [messagesForHandleProvider].
class HandleLensView extends HookConsumerWidget {
  const HandleLensView({required this.handleId, super.key});

  final int handleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final asyncMessages = ref.watch(
      messagesForHandleProvider(handleId: handleId),
    );
    final asyncHandles = ref.watch(strayHandlesProvider);
    final asyncDisplayName = ref.watch(
      handleDisplayNameProvider(handleId: handleId),
    );
    final isCreating = useState(false);
    final nameController = useTextEditingController();
    final isBusy = useState(false);
    final newestFirst = useState(false);

    // Find the stray handle summary for header info.
    final handleSummary = asyncHandles.whenOrNull(
      data: (handles) {
        final matches = handles.where((h) => h.handleId == handleId);
        return matches.isNotEmpty ? matches.first : null;
      },
    );

    // Use resolved display name (virtual contact > real contact > raw handle).
    final handleValue = asyncDisplayName.valueOrNull ?? 'Handle #$handleId';
    final serviceType = handleSummary?.serviceType ?? '';

    return MacosScaffold(
      toolBar: ToolBar(title: Text(handleValue), titleWidth: 300),
      children: [
        ContentArea(
          builder: (context, scrollController) {
            return CustomScrollView(
              controller: scrollController,
              slivers: [
                // Header + actions
                SliverToBoxAdapter(
                  child: _HandleLensHeader(
                    handleValue: handleValue,
                    serviceType: serviceType,
                    messageCount: handleSummary?.totalMessages ?? 0,
                    lastMessageDate: handleSummary?.lastMessageDate,
                    isReviewed: handleSummary?.reviewedAt != null,
                    colors: colors,
                    typography: typography,
                  ),
                ),

                // Action bar
                SliverToBoxAdapter(
                  child: _ActionBar(
                    handleId: handleId,
                    isCreating: isCreating,
                    nameController: nameController,
                    isBusy: isBusy,
                    newestFirst: newestFirst,
                    colors: colors,
                    typography: typography,
                  ),
                ),

                // Inline create contact form
                if (isCreating.value)
                  SliverToBoxAdapter(
                    child: _CreateContactForm(
                      handleId: handleId,
                      nameController: nameController,
                      isBusy: isBusy,
                      isCreating: isCreating,
                      colors: colors,
                      typography: typography,
                    ),
                  ),

                // Divider
                SliverToBoxAdapter(
                  child: Divider(height: 1, color: colors.lines.border),
                ),

                // Message list
                asyncMessages.when(
                  data: (messages) {
                    if (messages.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Text(
                            'No messages found for this handle.',
                            style: typography.body.copyWith(
                              color: colors.content.textTertiary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      );
                    }

                    // Order by user preference (default: oldest first)
                    final ordered = newestFirst.value
                        ? messages.reversed.toList()
                        : messages;

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _MessageRow(
                          message: ordered[index],
                          colors: colors,
                          typography: typography,
                        ),
                        childCount: ordered.length,
                      ),
                    );
                  },
                  loading: () => const SliverFillRemaining(
                    child: Center(child: ProgressCircle()),
                  ),
                  error: (error, _) => SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'Error loading messages: $error',
                        style: typography.body.copyWith(
                          color: colors.accents.secondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

// =============================================================================
// Header
// =============================================================================

class _HandleLensHeader extends StatelessWidget {
  const _HandleLensHeader({
    required this.handleValue,
    required this.serviceType,
    required this.messageCount,
    required this.lastMessageDate,
    required this.isReviewed,
    required this.colors,
    required this.typography,
  });

  final String handleValue;
  final String serviceType;
  final int messageCount;
  final DateTime? lastMessageDate;
  final bool isReviewed;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.surfaces.hover,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              _isPhone ? CupertinoIcons.phone : CupertinoIcons.mail,
              size: 24,
              color: colors.content.textSecondary,
            ),
          ),
          const SizedBox(width: 16),

          // Handle value + metadata
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  handleValue,
                  style: typography.body.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colors.content.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _ServiceBadge(
                      serviceType: serviceType,
                      colors: colors,
                      typography: typography,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$messageCount message${messageCount == 1 ? '' : 's'}',
                      style: typography.caption.copyWith(
                        color: colors.content.textTertiary,
                      ),
                    ),
                    if (lastMessageDate != null) ...[
                      const SizedBox(width: 12),
                      Text(
                        'Last: ${DateFormat.yMMMd().format(lastMessageDate!)}',
                        style: typography.caption.copyWith(
                          color: colors.content.textTertiary,
                        ),
                      ),
                    ],
                    if (isReviewed) ...[
                      const SizedBox(width: 12),
                      Icon(
                        CupertinoIcons.checkmark_circle,
                        size: 14,
                        color: colors.content.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Reviewed',
                        style: typography.caption.copyWith(
                          color: colors.content.textTertiary,
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
    );
  }

  bool get _isPhone => serviceType != 'iMessage';
}

// =============================================================================
// Service badge
// =============================================================================

class _ServiceBadge extends StatelessWidget {
  const _ServiceBadge({
    required this.serviceType,
    required this.colors,
    required this.typography,
  });

  final String serviceType;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colors.surfaces.hover,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        serviceType.isEmpty ? 'Unknown' : serviceType,
        style: typography.caption.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: colors.content.textSecondary,
        ),
      ),
    );
  }
}

// =============================================================================
// Action bar
// =============================================================================

class _ActionBar extends HookConsumerWidget {
  const _ActionBar({
    required this.handleId,
    required this.isCreating,
    required this.nameController,
    required this.isBusy,
    required this.newestFirst,
    required this.colors,
    required this.typography,
  });

  final int handleId;
  final ValueNotifier<bool> isCreating;
  final TextEditingController nameController;
  final ValueNotifier<bool> isBusy;
  final ValueNotifier<bool> newestFirst;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Row(
        children: [
          // Create Contact
          PushButton(
            controlSize: ControlSize.regular,
            onPressed: isBusy.value
                ? null
                : () {
                    isCreating.value = !isCreating.value;
                    if (!isCreating.value) {
                      nameController.clear();
                    }
                  },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                MacosIcon(
                  isCreating.value
                      ? CupertinoIcons.xmark
                      : CupertinoIcons.person_add,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(isCreating.value ? 'Cancel' : 'Create Contact'),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Link to Existing
          PushButton(
            controlSize: ControlSize.regular,
            secondary: true,
            onPressed: isBusy.value
                ? null
                : () => _linkToExisting(context, ref),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                MacosIcon(CupertinoIcons.link, size: 14),
                SizedBox(width: 6),
                Text('Link to Existing'),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Dismiss
          PushButton(
            controlSize: ControlSize.regular,
            secondary: true,
            onPressed: isBusy.value ? null : () => _dismiss(ref),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                MacosIcon(CupertinoIcons.checkmark_circle, size: 14),
                SizedBox(width: 6),
                Text('Dismiss'),
              ],
            ),
          ),

          const Spacer(),

          // Sort order toggle
          MacosTooltip(
            message: newestFirst.value
                ? 'Showing newest first'
                : 'Showing oldest first',
            child: MacosIconButton(
              icon: MacosIcon(
                newestFirst.value
                    ? CupertinoIcons.arrow_down
                    : CupertinoIcons.arrow_up,
                size: 16,
                color: colors.content.textSecondary,
              ),
              onPressed: () => newestFirst.value = !newestFirst.value,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _linkToExisting(BuildContext context, WidgetRef ref) async {
    final participantId = await ContactPickerDialog.show(context);
    if (participantId == null) {
      return;
    }

    isBusy.value = true;
    try {
      final result = await ref
          .read(manualHandleLinkServiceProvider.notifier)
          .linkHandleToParticipant(
            handleId: handleId,
            participantId: participantId,
          );

      result.fold(
        (failure) {
          // Show error — kept simple for Phase 2.
          ref
              .read(appLoggerProvider.notifier)
              .warn('Link failed: ${failure.message}', source: 'HandleLens');
        },
        (_) {
          ref.invalidate(strayHandlesProvider);
          ref.invalidate(handleDisplayNameProvider(handleId: handleId));
        },
      );
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> _dismiss(WidgetRef ref) async {
    isBusy.value = true;
    try {
      final overlayDb = await ref.read(overlayDatabaseProvider.future);
      await overlayDb.setHandleReviewed(handleId);
      ref.invalidate(strayHandlesProvider);
    } finally {
      isBusy.value = false;
    }
  }
}

// =============================================================================
// Inline create contact form
// =============================================================================

class _CreateContactForm extends HookConsumerWidget {
  const _CreateContactForm({
    required this.handleId,
    required this.nameController,
    required this.isBusy,
    required this.isCreating,
    required this.colors,
    required this.typography,
  });

  final int handleId;
  final TextEditingController nameController;
  final ValueNotifier<bool> isBusy;
  final ValueNotifier<bool> isCreating;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errorMessage = useState<String?>(null);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: MacosTextField(
                  controller: nameController,
                  placeholder: 'Contact name...',
                  autofocus: true,
                  onSubmitted: (_) => _submit(ref, errorMessage),
                ),
              ),
              const SizedBox(width: 8),
              PushButton(
                controlSize: ControlSize.regular,
                onPressed: isBusy.value
                    ? null
                    : () => _submit(ref, errorMessage),
                child: isBusy.value
                    ? const CupertinoActivityIndicator()
                    : const Text('Create & Link'),
              ),
            ],
          ),
          if (errorMessage.value != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                errorMessage.value!,
                style: typography.caption.copyWith(
                  color: const Color(0xFFD64545),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _submit(
    WidgetRef ref,
    ValueNotifier<String?> errorMessage,
  ) async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      return;
    }

    errorMessage.value = null;
    isBusy.value = true;
    try {
      final service = ref.read(manualHandleLinkServiceProvider.notifier);

      // Create virtual participant.
      final createResult = await service.createVirtualParticipant(
        displayName: name,
      );

      await createResult.fold(
        (failure) async {
          errorMessage.value = failure.message;
        },
        (virtualParticipantId) async {
          // Link handle to virtual participant.
          final linkResult = await service.linkHandleToVirtualParticipant(
            handleId: handleId,
            virtualParticipantId: virtualParticipantId,
          );

          linkResult.fold(
            (failure) {
              ref
                  .read(appLoggerProvider.notifier)
                  .warn(
                    'Link to virtual failed: ${failure.message}',
                    source: 'HandleLens',
                  );
            },
            (_) {
              ref.invalidate(strayHandlesProvider);
              ref.invalidate(handleDisplayNameProvider(handleId: handleId));
              isCreating.value = false;
              nameController.clear();
            },
          );
        },
      );
    } finally {
      isBusy.value = false;
    }
  }
}

// =============================================================================
// Message row
// =============================================================================

class _MessageRow extends StatelessWidget {
  const _MessageRow({
    required this.message,
    required this.colors,
    required this.typography,
  });

  final MessageWithChatContext message;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('MMM d, yyyy h:mm a');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timestamp + chat context
          Row(
            children: [
              Text(
                dateFormatter.format(message.sentAt),
                style: typography.caption.copyWith(
                  color: colors.content.textTertiary,
                  fontSize: 11,
                ),
              ),
              if (message.chatDisplayName != null) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    message.chatDisplayName!,
                    style: typography.caption.copyWith(
                      color: colors.content.textTertiary,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),

          // Direction indicator + message body
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                message.isFromMe
                    ? CupertinoIcons.arrow_up_right
                    : CupertinoIcons.arrow_down_left,
                size: 12,
                color: message.isFromMe
                    ? colors.accents.primary
                    : colors.content.textTertiary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  message.text.isEmpty ? '(No text content)' : message.text,
                  style: typography.body.copyWith(
                    color: colors.content.textPrimary,
                    fontSize: 13,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
