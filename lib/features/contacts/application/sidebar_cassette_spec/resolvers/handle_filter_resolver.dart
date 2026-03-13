import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../widget_builders/handle_filter_widget.dart';

part 'handle_filter_resolver.g.dart';

/// Resolves a handle filter cassette — the "From phone # / email:" dropdown.
///
/// ## Contract
///
/// - Receives explicit parameters (not specs)
/// - Returns `Future<SidebarCassetteCardViewModel>`
/// - Delegates widget construction to [HandleFilterWidget]
@riverpod
class HandleFilterResolver extends _$HandleFilterResolver {
  @override
  void build() {
    // Stateless resolver
  }

  /// Resolve the handle filter cassette.
  Future<SidebarCassetteCardViewModel> resolve({
    required int contactId,
    int? selectedHandleId,
    required int cassetteIndex,
  }) async {
    return SidebarCassetteCardViewModel(
      title: '',
      isNaked: true,
      child: HandleFilterWidget(
        contactId: contactId,
        selectedHandleId: selectedHandleId,
        cassetteIndex: cassetteIndex,
      ),
    );
  }
}
