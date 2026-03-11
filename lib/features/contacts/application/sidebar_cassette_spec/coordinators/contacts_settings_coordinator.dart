import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../domain/spec_classes/contacts_settings_spec.dart';
import '../resolvers/actions_info_resolver.dart';
import '../resolvers/actions_sub_menu_resolver.dart';
import '../resolvers/display_name_info_resolver.dart';
import '../resolvers/reimport_data_info_resolver.dart';

part 'contacts_settings_coordinator.g.dart';

/// Coordinator for ContactsSettingsSpec variants.
///
/// This coordinator routes settings spec variants to their resolvers.
/// It follows the cross-surface spec system rules:
/// - Routes only (no business logic)
/// - Calls exactly one resolver per spec variant
/// - Returns Future<SidebarCassetteCardViewModel>
@riverpod
class ContactsSettingsCoordinator extends _$ContactsSettingsCoordinator {
  @override
  void build() {}

  /// Build a view model for the given [ContactsSettingsSpec].
  ///
  /// Routes to the appropriate resolver based on spec variant.
  /// The [cassetteIndex] is passed through for widgets that need to update
  /// the cassette stack.
  Future<SidebarCassetteCardViewModel> buildViewModel(
    ContactsSettingsSpec spec, {
    required int cassetteIndex,
  }) async {
    return spec.when(
      displayNameInfo: () => ref
          .read(displayNameInfoResolverProvider.notifier)
          .resolve(cassetteIndex: cassetteIndex),
      actionsMenu: (selectedChoice) => ref
          .read(actionsSubMenuResolverProvider.notifier)
          .resolve(currentChoice: selectedChoice, cassetteIndex: cassetteIndex),
      sendLogsInfo: () => ref
          .read(actionsInfoResolverProvider.notifier)
          .resolve(cassetteIndex: cassetteIndex),
      reimportDataInfo: () => ref
          .read(reimportDataInfoResolverProvider.notifier)
          .resolve(cassetteIndex: cassetteIndex),
    );
  }
}
