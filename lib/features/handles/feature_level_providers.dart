// =============================================================================
// HANDLES FEATURE — PUBLIC API
// =============================================================================
//
// This barrel file exports only the public API of the handles feature.
// External code should import ONLY this file.
//
// Exports:
// - Coordinators (application surface handlers)
// - State providers needed externally
//
// Does NOT export:
// - Resolvers
// - Widget builders
// - Infrastructure details
// =============================================================================

export './application/info_cassette_spec/coordinators/info_cassette_coordinator.dart';
export './application/settings_cassette_spec/coordinators/settings_coordinator.dart';
export './application/sidebar_cassette_spec/coordinators/cassette_coordinator.dart';
export './application/state/stray_handle_mode_provider.dart';
export './application/view_spec/coordinators/view_spec_coordinator.dart';
