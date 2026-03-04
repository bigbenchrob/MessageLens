import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../domain/spec_classes/handles_cassette_spec.dart';
import '../../state/stray_handle_mode_provider.dart';
import '../resolvers/stray_emails_resolver.dart';
import '../resolvers/stray_handles_mode_switcher_resolver.dart';
import '../resolvers/stray_handles_review_resolver.dart';
import '../resolvers/stray_handles_type_switcher_resolver.dart';
import '../resolvers/stray_phones_resolver.dart';
import '../resolvers/unmatched_handles_resolver.dart';

part 'cassette_coordinator.g.dart';

/// Handles Cassette Coordinator
///
/// Routes [HandlesCassetteSpec] variants to their respective resolvers.
/// This coordinator is the entry point for all handles-related sidebar cassettes.
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// - Receives a [HandlesCassetteSpec]
/// - Pattern-matches on the spec
/// - Extracts payload parameters
/// - Calls exactly ONE resolver
/// - Returns the resolver's `Future<SidebarCassetteCardViewModel>`
///
/// The coordinator MUST NOT:
/// - Perform IO
/// - Construct widgets
/// - Build view models itself
/// - Pass specs to resolvers
@riverpod
class HandlesCassetteCoordinator extends _$HandlesCassetteCoordinator {
  @override
  void build() {
    // Stateless coordinator
  }

  /// Build a sidebar cassette view model for the given handles cassette spec.
  Future<SidebarCassetteCardViewModel> buildViewModel(
    HandlesCassetteSpec spec, {
    required int cassetteIndex,
  }) async {
    return spec.map(
      unmatchedHandlesList: (_) =>
          ref.read(unmatchedHandlesResolverProvider.notifier).resolve(),
      strayPhoneNumbers: (_) =>
          ref.read(strayPhonesResolverProvider.notifier).resolve(),
      strayEmails: (_) =>
          ref.read(strayEmailsResolverProvider.notifier).resolve(),
      strayHandlesReview: (reviewSpec) {
        // Read mode from global provider (mode switcher controls this)
        final mode = ref.watch(strayHandleModeSettingProvider);
        return ref
            .read(strayHandlesReviewResolverProvider.notifier)
            .resolve(filter: reviewSpec.filter, mode: mode);
      },
      strayHandlesModeSwitcher: (switcherSpec) => ref
          .read(strayHandlesModeSwitcherResolverProvider.notifier)
          .resolve(filter: switcherSpec.filter),
      strayHandlesTypeSwitcher: (typeSpec) => ref
          .read(strayHandlesTypeSwitcherResolverProvider.notifier)
          .resolve(
            selectedFilter: typeSpec.selectedFilter,
            cassetteIndex: cassetteIndex,
          ),
    );
  }
}
