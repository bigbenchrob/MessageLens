// =============================================================================
// SIDEBAR_UTILITIES FEATURE — BARREL FILE
// =============================================================================
//
// This file exports public feature components for use by essentials-level
// coordinators. All implementation details live in subdirectories.
//
// Pattern: Features expose coordinators and constants; essentials routes specs
// to the appropriate feature coordinator.
// =============================================================================

// Spec Coordinators (new cross-surface spec system)
export './application/sidebar_cassette_spec/coordinators/cassette_coordinator.dart';

// Domain Constants
export './domain/sidebar_utilities_constants.dart';
