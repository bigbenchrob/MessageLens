import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../presentation/cassettes/messages_heatmap_cassette.dart';

part 'messages_heatmap_cassette_builder_provider.g.dart';

@riverpod
SidebarCassetteCardViewModel messagesHeatmapCassetteBuilder(
  Ref ref, {
  required int? contactId,
  required bool useV2Timeline,
}) {
  final isContactScoped = contactId != null;

  return SidebarCassetteCardViewModel(
    title: isContactScoped
        ? 'Click on a square to see messages for that month'
        : 'All messages heatmap',
    subtitle: isContactScoped
        ? null
        : 'Discover peaks and gaps across your entire archive.',
    shouldExpand: false,
    child: MessagesHeatmapCassette(
      contactId: contactId,
      useV2Timeline: useV2Timeline,
    ),
  );
}
