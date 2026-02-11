import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/sidebar/domain/entities/features/handles_cassette_spec.dart';
import '../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../presentation/cassettes/stray_handles_review_cassette.dart';

part 'stray_handles_review_cassette_builder_provider.g.dart';

/// Builds the cassette view model for the unified stray handles review list.
@riverpod
SidebarCassetteCardViewModel strayHandlesReviewCassetteBuilder(
  Ref ref, {
  required StrayHandleFilter filter,
}) {
  final title = switch (filter) {
    StrayHandleFilter.phones => 'Stray phone numbers',
    StrayHandleFilter.emails => 'Stray email addresses',
  };

  return SidebarCassetteCardViewModel(
    title: title,
    shouldExpand: true,
    child: StrayHandlesReviewCassette(filter: filter),
  );
}
