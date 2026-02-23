import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/domain/entities/features/handles_cassette_spec.dart';
import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../presentation/cassettes/stray_handles_review_cassette.dart';

part 'stray_handles_review_resolver.g.dart';

/// Resolver for the unified stray handles review list cassette.
///
/// Receives explicit parameters (not specs) and produces a view model.
/// Widget construction is inline here since it's simple.
@riverpod
class StrayHandlesReviewResolver extends _$StrayHandlesReviewResolver {
  @override
  void build() {
    // Stateless resolver
  }

  /// Resolve filter and mode into a sidebar cassette view model.
  Future<SidebarCassetteCardViewModel> resolve({
    required StrayHandleFilter filter,
    required StrayHandleMode mode,
  }) async {
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
}
