// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_top_menu_resolver.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$settingsTopMenuResolverHash() =>
    r'fbbed6c8c001886415ca7ace1c2749f9feb523ed';

/// Settings Top Menu Resolver
///
/// This resolver implements the cross-surface spec system contract:
///
/// - Receives explicit parameters (NOT a spec)
/// - Returns Future<SidebarCassetteCardViewModel>
/// - Determines which widget builder is used
/// - Owns all decision-making for this cassette
///
/// The resolver MUST NOT:
/// - Accept a spec object
/// - Read a spec from shared state
/// - Return widgets, builders, or partial results
///
/// See: _AGENT_INSTRUCTIONS/agent-per-project/90-CROSS-SURFACE-SPEC-SYSTEMS/00-cross-surface-spec-system.md
///
/// Copied from [SettingsTopMenuResolver].
@ProviderFor(SettingsTopMenuResolver)
final settingsTopMenuResolverProvider =
    AutoDisposeNotifierProvider<SettingsTopMenuResolver, void>.internal(
      SettingsTopMenuResolver.new,
      name: r'settingsTopMenuResolverProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$settingsTopMenuResolverHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SettingsTopMenuResolver = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
