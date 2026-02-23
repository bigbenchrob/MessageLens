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
  required StrayHandleMode mode,
}) {
  final sectionHeader = _buildSectionHeader(filter, mode);

  return SidebarCassetteCardViewModel(
    title: '', // No card title - use sectionTitle for tighter spacing
    sectionTitle: sectionHeader,
    layoutStyle: SidebarCardLayoutStyle.listDense, // Space-efficient rails
    shouldExpand: true,
    child: StrayHandlesReviewCassette(filter: filter, mode: mode),
  );
}

String _buildSectionHeader(StrayHandleFilter filter, StrayHandleMode mode) {
  final filterLabel = switch (filter) {
    StrayHandleFilter.phones => 'phone numbers',
    StrayHandleFilter.emails => 'email addresses',
    StrayHandleFilter.businessUrns => 'business accounts',
  };

  return switch (mode) {
    StrayHandleMode.allStrays => 'Unfamiliar $filterLabel',
    StrayHandleMode.spamCandidates => 'Spam $filterLabel',
    StrayHandleMode.dismissed => 'Dismissed $filterLabel',
  };
}
