import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../domain/spec_classes/messages_info_cassette_spec.dart';
import '../resolvers/info_content_resolver.dart';

part 'info_cassette_coordinator.g.dart';

/// Messages Info Cassette Coordinator
///
/// Routes [MessagesInfoCassetteSpec] variants to info resolvers.
@riverpod
class MessagesInfoCassetteCoordinator
    extends _$MessagesInfoCassetteCoordinator {
  @override
  void build() {
    // Stateless coordinator
  }

  Future<SidebarCassetteCardViewModel> buildViewModel(
    MessagesInfoCassetteSpec spec, {
    required int cassetteIndex,
  }) async {
    switch (spec) {
      case MessagesInfoCassetteSpecInfoCard(:final key):
        final content = await ref
            .read(messagesInfoContentResolverProvider.notifier)
            .resolve(key, cassetteIndex: cassetteIndex);

        return SidebarCassetteCardViewModel(
          title: content.title ?? '',
          child: content.child,
          layoutStyle: content.layoutStyle,
          topSpacing: content.topSpacing,
        );
    }

    throw StateError(
      'Unhandled MessagesInfoCassetteSpec variant: ${spec.runtimeType}',
    );
  }
}
