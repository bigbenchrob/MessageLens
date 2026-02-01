// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'top_chat_menu_resolver.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$topChatMenuResolverHash() =>
    r'e54deab393b10ee7167b35dcc5a14cf87e1e9d67';

/// Top Chat Menu Resolver
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
/// Copied from [TopChatMenuResolver].
@ProviderFor(TopChatMenuResolver)
final topChatMenuResolverProvider =
    AutoDisposeNotifierProvider<TopChatMenuResolver, void>.internal(
      TopChatMenuResolver.new,
      name: r'topChatMenuResolverProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$topChatMenuResolverHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TopChatMenuResolver = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
