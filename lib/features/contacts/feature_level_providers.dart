// =============================================================================
// CONTACTS FEATURE — PUBLIC API
// =============================================================================
//
// This barrel file exports only the public API of the contacts feature.
// External code should import ONLY this file.
//
// Exports:
// - Spec classes (domain)
// - Coordinators (application)
// - Settings providers
// - Repositories (for cross-feature data access)
//
// Does NOT export:
// - Resolvers
// - Widget builders
// - Infrastructure details
// =============================================================================

export './application/sidebar_cassette_spec/coordinators/cassette_coordinator.dart';
export './application/sidebar_cassette_spec/coordinators/contacts_settings_coordinator.dart';
export './application/sidebar_cassette_spec/coordinators/info_cassette_coordinator.dart';
export './application/tooltips_spec/coordinators/contacts_tooltip_coordinator.dart';
export './application/view_spec/view_spec_coordinator.dart';
export './domain/spec_classes/contacts_cassette_spec.dart';
export './domain/spec_classes/contacts_tooltip_spec.dart';
export './infrastructure/repositories/recent_contacts_repository.dart';
