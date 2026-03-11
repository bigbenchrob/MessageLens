import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../presentation/cassettes/settings/reimport_data_action_button.dart';

part 'reimport_data_info_resolver.g.dart';

/// Resolver for ContactsSettingsSpec.reimportDataInfo().
///
/// Returns an info card explaining the reimport action.
@riverpod
class ReimportDataInfoResolver extends _$ReimportDataInfoResolver {
  @override
  void build() {}

  SidebarCassetteCardViewModel resolve({required int cassetteIndex}) {
    return const SidebarCassetteCardViewModel(
      title: 'Reimport Data',
      child: SizedBox.shrink(),
      cardType: CassetteCardType.info,
      infoBodyText:
          'This will reimport all the chat message and address book '
          'contact data from the databases on your Mac. Any records '
          'you have added (like new contact names for unfamiliar '
          'phone numbers) will not be affected.',
      infoAction: ReimportDataActionButton(),
    );
  }
}
