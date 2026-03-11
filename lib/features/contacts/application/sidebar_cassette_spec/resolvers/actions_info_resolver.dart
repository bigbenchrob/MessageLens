import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../presentation/cassettes/settings/send_logs_action_button.dart';

part 'actions_info_resolver.g.dart';

/// Resolver for ContactsSettingsSpec.sendLogsInfo().
///
/// Returns an info card with diagnostic log export action.
@riverpod
class ActionsInfoResolver extends _$ActionsInfoResolver {
  @override
  void build() {}

  SidebarCassetteCardViewModel resolve({required int cassetteIndex}) {
    return const SidebarCassetteCardViewModel(
      title: 'Send Logs',
      child: SizedBox.shrink(),
      cardType: CassetteCardType.info,
      infoBodyText:
          'If you encounter a problem, you can send diagnostic logs '
          'to help with troubleshooting.',
      infoAction: SendLogsActionButton(),
    );
  }
}
