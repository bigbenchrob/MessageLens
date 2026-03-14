import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../config/theme/spacing/app_spacing.dart';
import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../domain/spec_classes/messages_info_cassette_spec.dart';
import '../widget_builders/recovered_no_handle_from_me_navigator_widget.dart';
import '../widget_builders/recovered_unlinked_navigator_widget.dart';

part 'info_content_resolver.g.dart';

/// Resolved content for a messages info cassette.
class MessagesInfoContent {
  const MessagesInfoContent({
    this.title,
    required this.child,
    this.layoutStyle = SidebarCardLayoutStyle.controlAligned,
    this.topSpacing = 0,
  });

  final String? title;
  final Widget child;
  final SidebarCardLayoutStyle layoutStyle;
  final double topSpacing;
}

/// Resolves content for [MessagesInfoKey] values.
@riverpod
class MessagesInfoContentResolver extends _$MessagesInfoContentResolver {
  @override
  void build() {
    // Stateless resolver
  }

  Future<MessagesInfoContent> resolve(
    MessagesInfoKey key, {
    required int cassetteIndex,
  }) async {
    switch (key) {
      case MessagesInfoKey.recoveredDeletedMessages:
        return MessagesInfoContent(
          child: RecoveredUnlinkedNavigatorWidget(cassetteIndex: cassetteIndex),
          topSpacing: AppSpacing.lg,
        );
      case MessagesInfoKey.recoveredNoHandleMessages:
        return MessagesInfoContent(
          child: RecoveredNoHandleFromMeNavigatorWidget(
            cassetteIndex: cassetteIndex,
          ),
        );
    }
  }
}
