import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../config/theme/spacing/app_spacing.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../../../essentials/navigation/domain/entities/view_spec.dart';
import '../../../../../essentials/navigation/domain/navigation_constants.dart';
import '../../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../../essentials/navigation/feature_level_providers.dart';
import '../../../domain/spec_classes/messages_view_spec.dart';

/// Sidebar cassette content for the recovered-unlinked-messages feature entry.
class RecoveredUnlinkedNavigatorWidget extends HookConsumerWidget {
  const RecoveredUnlinkedNavigatorWidget({
    required this.cassetteIndex,
    super.key,
  });

  final int cassetteIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = ref.watch(themeTypographyProvider);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(panelsViewStateProvider(SidebarMode.messages).notifier)
            .show(
              panel: WindowPanel.center,
              spec: const ViewSpec.messages(
                MessagesSpec.recoveredUnlinkedMessages(),
              ),
            );
      });

      return null;
    }, const []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Some messages in the iMessage database on your computer couldn't be linked to a chat conversation with a particular contact from your AddressBook. In many (but not all) cases, orphaned messages like these belong to conversations that you swiped left on in iMessage and deleted.",
          style: typography.cassetteCardSubtitle,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'However, they can be associated with a particular phone number or email address (a "handle") that belongs to a known contact. When you choose a contact, you will be given the option to view all the unlinked messages of this type. But they are listed together here for your convenience.',
          style: typography.cassetteCardSubtitle,
        ),
      ],
    );
  }
}
