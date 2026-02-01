import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../presentation/cassettes/settings/contact_short_names_settings_cassette.dart';

part 'short_names_resolver.g.dart';

/// Resolver for the short names settings cassette.
///
/// This resolver builds the view model for the contact short names
/// settings cassette. The cassette allows users to configure how
/// contact names are displayed throughout the app.
@riverpod
class ShortNamesResolver extends _$ShortNamesResolver {
  @override
  void build() {}

  /// Resolve the short names settings cassette.
  ///
  /// Returns a fully-realized [SidebarCassetteCardViewModel].
  /// The [cassetteIndex] is available in case future functionality needs
  /// to update the cassette stack (though this widget currently doesn't).
  Future<SidebarCassetteCardViewModel> resolve({
    required int cassetteIndex,
  }) async {
    // ignore: unused_local_variable
    final _ = cassetteIndex; // Available for future use
    return const SidebarCassetteCardViewModel(
      title: 'Short Names',
      subtitle: 'How contact names appear throughout the app',
      sectionTitle: 'Display format',
      footerText:
          'Nicknames override imported contact names without modifying system data.',
      shouldExpand: false,
      child: ContactShortNamesSettingsCassette(),
    );
  }
}
