import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../../../essentials/navigation/domain/entities/view_spec.dart';
import '../../../../../essentials/navigation/domain/navigation_constants.dart';
import '../../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../../essentials/navigation/feature_level_providers.dart';
import '../../../../../essentials/sidebar/application/cassette_rack_state_provider.dart';
import '../../../../../essentials/sidebar/feature_level_providers.dart';
import '../../../../messages/domain/spec_classes/messages_view_spec.dart';
import '../../../application/services/manual_handle_link_service.dart';
import '../../../domain/spec_classes/contacts_cassette_spec.dart';
import '../../../domain/spec_classes/contacts_info_cassette_spec.dart';
import '../../../infrastructure/repositories/handles_for_contact_provider.dart';

/// Widget builder for the handle-filter cassette.
///
/// Displays a "From phone # / email:" dropdown listing every handle linked
/// to the given contact. The default "All" selection shows messages for the
/// full contact; selecting a specific handle narrows the center panel to that
/// handle's messages and exposes an "Unlink" action.
class HandleFilterWidget extends ConsumerWidget {
  const HandleFilterWidget({
    super.key,
    required this.contactId,
    required this.selectedHandleId,
    required this.cassetteIndex,
  });

  final int contactId;
  final int? selectedHandleId;
  final int cassetteIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final handlesAsync = ref.watch(
      handlesForContactProvider(contactId: contactId),
    );

    return handlesAsync.when(
      data: (handles) {
        // If there's only one handle (or none), no filter dropdown is useful.
        if (handles.length <= 1) {
          return const SizedBox.shrink();
        }

        return _HandleFilterDropdown(
          contactId: contactId,
          handles: handles,
          selectedHandleId: selectedHandleId,
          cassetteIndex: cassetteIndex,
          colors: colors,
          typography: typography,
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _HandleFilterDropdown extends ConsumerWidget {
  static const _popupMenuMaxHeight = 320.0;

  const _HandleFilterDropdown({
    required this.contactId,
    required this.handles,
    required this.selectedHandleId,
    required this.cassetteIndex,
    required this.colors,
    required this.typography,
  });

  final int contactId;
  final List<LinkedHandle> handles;
  final int? selectedHandleId;
  final int cassetteIndex;
  final ThemeColors colors;
  final ThemeTypography typography;

  void _onHandleSelected(WidgetRef ref, int? handleId) {
    // Update the cassette spec with the new selection (drives unlink affordance).
    final newSpec = CassetteSpec.contacts(
      ContactsCassetteSpec.handleFilter(
        contactId: contactId,
        selectedHandleId: handleId,
      ),
    );
    ref
        .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
        .replaceAtIndexAndCascade(cassetteIndex, newSpec);

    // Navigate the center panel to the same contact timeline, optionally
    // filtered to messages from the selected handle.
    ref
        .read(panelsViewStateProvider(SidebarMode.messages).notifier)
        .show(
          panel: WindowPanel.center,
          spec: ViewSpec.messages(
            MessagesSpec.forContact(
              contactId: contactId,
              filterHandleId: handleId,
            ),
          ),
        );
  }

  Future<void> _onUnlink(WidgetRef ref) async {
    if (selectedHandleId == null) {
      return;
    }

    final result = await ref
        .read(manualHandleLinkServiceProvider.notifier)
        .unlinkHandle(handleId: selectedHandleId!);

    result.fold(
      (failure) {
        // Failures are unlikely here; silently ignore.
      },
      (contactDeleted) {
        // Invalidate handles list so the dropdown rebuilds.
        ref.invalidate(handlesForContactProvider(contactId: contactId));

        if (contactDeleted) {
          // Virtual participant was removed — navigate back to picker.
          const pickerSpec = CassetteSpec.contactsInfo(
            ContactsInfoCassetteSpec.infoCard(
              key: ContactsInfoKey.favouritesVsRecents,
            ),
          );
          // Replace from the info card level (index 1) to cascade fresh.
          ref
              .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
              .replaceAtIndexAndCascade(1, pickerSpec);

          // Clear the center panel.
          ref
              .read(panelsViewStateProvider(SidebarMode.messages).notifier)
              .clear(panel: WindowPanel.center);
        } else {
          // Still has other handles — reset to "All".
          _onHandleSelected(ref, null);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final muted = colors.content.textSecondary;
    final label = typography.caption1.copyWith(color: muted);

    // Find the selected handle to check if it's an override link.
    final selectedHandle = selectedHandleId != null
        ? handles.where((h) => h.handleId == selectedHandleId).firstOrNull
        : null;
    final canUnlink = selectedHandle?.isOverrideLink ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('From phone # / email:', style: label),
          const SizedBox(height: 4),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth - 36;

              return SizedBox(
                width: double.infinity,
                child: MacosPopupButton<int?>(
                  value: selectedHandleId,
                  onChanged: (value) => _onHandleSelected(ref, value),
                  menuMaxHeight: _popupMenuMaxHeight,
                  selectedItemBuilder: (context) {
                    return [
                      _HandlePopupLabel(
                        text: 'All linked handles',
                        width: itemWidth,
                      ),
                      for (final handle in handles)
                        _HandlePopupLabel(
                          text: _handleMenuLabel(handle),
                          width: itemWidth,
                        ),
                    ];
                  },
                  items: [
                    const MacosPopupMenuItem<int?>(
                      value: null,
                      child: _HandlePopupLabel(text: 'All linked handles'),
                    ),
                    ...handles.map(
                      (handle) => MacosPopupMenuItem<int?>(
                        value: handle.handleId,
                        child: _HandlePopupLabel(
                          text: _handleMenuLabel(handle),
                          width: itemWidth,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          if (canUnlink) ...[
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => _onUnlink(ref),
              child: Text(
                'Unlink this number from contact',
                style: typography.caption1.copyWith(
                  color: colors.buttons.destructiveForeground,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _handleMenuLabel(LinkedHandle handle) {
  return '${handle.displayValue} (${handle.service})';
}

class _HandlePopupLabel extends StatelessWidget {
  const _HandlePopupLabel({required this.text, this.width});

  final String text;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final child = Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
    );

    if (width == null) {
      return child;
    }

    return SizedBox(width: width, child: child);
  }
}
