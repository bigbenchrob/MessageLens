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

export './application/sidebar_cassette_spec/coordinators/cassette_coordinator.dart';
export './application/sidebar_cassette_spec/payloads/settings_top_menu_cassette_payload.dart';
export './application/sidebar_cassette_spec/payloads/top_chat_menu_cassette_payload.dart';
export './application/sidebar_cassette_spec/rendering/sidebar_utilities_cassette_body_builder.dart';
export './application/sidebar_cassette_spec/resolver_tools/settings_reset_message_data_action_availability_provider.dart';
export './domain/settings_top_menu_row.dart';
export './domain/sidebar_utilities_constants.dart';
export './domain/spec_classes/sidebar_utility_cassette_spec.dart';
