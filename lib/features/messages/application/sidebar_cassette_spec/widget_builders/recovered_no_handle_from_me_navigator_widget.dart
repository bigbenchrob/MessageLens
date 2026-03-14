import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../../config/theme/spacing/app_spacing.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../../../essentials/navigation/domain/entities/view_spec.dart';
import '../../../../../essentials/navigation/domain/navigation_constants.dart';
import '../../../../../essentials/navigation/domain/sidebar_mode.dart';
import '../../../../../essentials/navigation/feature_level_providers.dart';
import '../../../domain/spec_classes/messages_view_spec.dart';

/// Sidebar cassette content for the no-handle/from-me recovered bucket.
class RecoveredNoHandleFromMeNavigatorWidget extends HookConsumerWidget {
  const RecoveredNoHandleFromMeNavigatorWidget({
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
                MessagesSpec.recoveredNoHandleFromMeMessages(),
              ),
            );
      });

      return null;
    }, const []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Experimental slice of recovered orphaned records that are mostly outgoing and no longer retain handle linkage. Useful for inspecting the large no-handle bucket separately from the rest of recovered messages.',
          style: typography.cassetteCardSubtitle,
        ),
        const SizedBox(height: AppSpacing.sm),
        PushButton(
          controlSize: ControlSize.small,
          onPressed: () {
            ref
                .read(panelsViewStateProvider(SidebarMode.messages).notifier)
                .show(
                  panel: WindowPanel.center,
                  spec: const ViewSpec.messages(
                    MessagesSpec.recoveredNoHandleFromMeMessages(),
                  ),
                );
          },
          child: Text(
            'Open Recovered No-Handle Messages',
            style: typography.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
