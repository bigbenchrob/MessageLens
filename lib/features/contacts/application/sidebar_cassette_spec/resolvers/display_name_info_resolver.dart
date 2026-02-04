import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../presentation/cassettes/settings/contact_display_name_info_cassette.dart';

part 'display_name_info_resolver.g.dart';

/// Resolver for ContactsSettingsSpec.displayNameInfo().
///
/// Returns an info card explaining how to customize contact display names.
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// Resolvers:
/// - Own the semantic interpretation of specs
/// - Read data and make decisions
/// - Return fully-configured ViewModels
@riverpod
class DisplayNameInfoResolver extends _$DisplayNameInfoResolver {
  @override
  void build() {}

  /// Produces a view model containing an info card about name customization.
  SidebarCassetteCardViewModel resolve({required int cassetteIndex}) {
    return const SidebarCassetteCardViewModel(
      title: 'Contact Names',
      child: ContactDisplayNameInfoCassette(),
    );
  }
}
