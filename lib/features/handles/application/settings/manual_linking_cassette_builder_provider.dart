import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../presentation/settings/manual_linking_view.dart';

part 'manual_linking_cassette_builder_provider.g.dart';

/// Builds the cassette view model for manual handle linking.
///
/// This builder is responsible for gathering data and applying any
/// conditional logic before constructing the cassette widget.
@riverpod
SidebarCassetteCardViewModel manualLinkingCassetteBuilder(Ref ref) {
  return const SidebarCassetteCardViewModel(
    title: 'Manual Linking',
    subtitle: 'Link unknown handles to contacts when automatic matching fails.',
    shouldExpand: true,
    child: ManualLinkingView(),
  );
}
