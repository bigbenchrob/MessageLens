import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Essentials imports (shared sidebar protocol + view model)
// ─────────────────────────────────────────────────────────────────────────────

// The centralized Handles info cassette spec + HandlesInfoKey enum.
import '../../../../../essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import '../../../domain/spec_classes/handles_info_cassette_spec.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Local feature application logic (meaning + formatting)
// ─────────────────────────────────────────────────────────────────────────────

// Resolver that maps HandlesInfoKey → surface-agnostic HandlesInfoContent.
import '../resolvers/info_content_resolver.dart';

// Forward the HandlesInfoContent class for callers that need it.
export '../resolvers/info_content_resolver.dart' show HandlesInfoContent;

part 'info_cassette_coordinator.g.dart';

/// Handles InfoCassetteCoordinator
///
/// This coordinator is part of the Handles feature and is responsible for *routing only*:
///
/// - Accept a HandlesInfoCassetteSpec (sidebar protocol entity)
/// - Pattern-match on the spec variant
/// - Delegate meaning/data/formatting to application-layer case handlers/resolvers
/// - Return a SidebarCassetteCardViewModel (NOT a wrapped widget)
///
/// Why return a view model instead of a widget?
///
/// - The app-level CassetteWidgetCoordinator centralizes UI chrome decisions.
/// - This keeps card layout/padding/header policies consistent across features.
/// - Features remain agnostic to how cards are visually framed.
/// - Future changes to card chrome happen in one place, not N features.
///
/// IMPORTANT:
/// This coordinator should remain small. If you see data fetching or complex formatting
/// happening here, it belongs in spec_cases (e.g., HandlesInfoContentResolver).
@riverpod
class HandlesInfoCassetteCoordinator extends _$HandlesInfoCassetteCoordinator {
  @override
  void build() {
    // Stateless coordinator; invoked imperatively by other coordinators.
  }

  /// Build a sidebar cassette view model for a Handles info cassette request.
  ///
  /// This is async because:
  /// - info content may later depend on repositories (counts, derived values)
  /// - keeping the API async avoids refactoring call sites later
  Future<SidebarCassetteCardViewModel> buildViewModel(
    HandlesInfoCassetteSpec spec, {
    required int cassetteIndex,
  }) async {
    switch (spec) {
      case HandlesInfoCassetteSpecInfoCard(:final key):
        // Delegate meaning + formatting to the feature-owned resolver.
        final content = await ref
            .read(handlesInfoContentResolverProvider.notifier)
            .resolve(key);

        // Convert surface-agnostic content into a *semantic* sidebar view model.
        //
        // NOTE:
        // We do NOT build a Text() widget here.
        // We pass plain data to the view model and let the app-level chrome builder decide
        // how an "info" card is rendered.
        return SidebarCassetteCardViewModel(
          title: content.title ?? '',
          footerText: content.footnote,
          child: const SizedBox.shrink(), // ignored for info cards
          cardType: CassetteCardType.info,
          infoBodyText: content.body,
        );
    }

    // If you add a new HandlesInfoCassetteSpec variant and forget to handle it here,
    // fail loudly rather than returning null.
    throw StateError(
      'Unhandled HandlesInfoCassetteSpec variant: ${spec.runtimeType}',
    );
  }
}
