import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../presentation/settings/spam_management_view.dart';

part 'spam_management_cassette_builder_provider.g.dart';

/// Builds the cassette view model for spam management.
///
/// This builder is responsible for gathering data and applying any
/// conditional logic before constructing the cassette widget.
@riverpod
SidebarCassetteCardViewModel spamManagementCassetteBuilder(Ref ref) {
  return const SidebarCassetteCardViewModel(
    title: 'Spam Management',
    subtitle: 'Block unwanted handles and manage your blacklist.',
    child: SpamManagementView(),
  );
}
